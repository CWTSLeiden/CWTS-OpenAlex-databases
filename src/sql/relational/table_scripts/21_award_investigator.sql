set nocount on

drop table if exists #award_investigator_affiliation
select award_id, 
	investigator_order = min(investigator_seq),
	first_name,
	last_name,
	orcid = nullif($(etl_db_name).dbo.regex_replace(orcid, '^(?:.*([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]).*|.*)$', '$1'), ''),
	role_start,
	affiliation_country,
	affiliation_name
into #award_investigator_affiliation
from
(
	select a.award_id,
		investigator_seq = -10,
		first_name = b.given_name,
		last_name = b.family_name,
		orcid = b.orcid,
		role_start = cast(b.role_start as date),
		affiliation_country = c.country,
		affiliation_name = c.[name]
	from _award as a
	join $(awards_json_db_name)..award_lead_investigator as b
		on a.folder = b.folder and a.record_id = b.record_id
	left join $(awards_json_db_name)..award_lead_investigator_affiliation as c
		on a.folder = c.folder and a.record_id = c.record_id
	where coalesce(b.family_name, b.given_name, c.country, c.[name]) is not null
	union
	select a.award_id,
		investigator_seq = -5,
		first_name = b.given_name,
		last_name = b.family_name,
		orcid = b.orcid,
		role_start = cast(b.role_start as date),
		affiliation_country = c.country,
		affiliation_name = c.[name]
	from _award as a
	join $(awards_json_db_name)..award_co_lead_investigator as b
		on a.folder = b.folder and a.record_id = b.record_id
	left join $(awards_json_db_name)..award_co_lead_investigator_affiliation as c
		on a.folder = c.folder and a.record_id = c.record_id
	where coalesce(b.family_name, b.given_name, c.country, c.[name]) is not null
	union
	select a.award_id,
		b.investigator_seq,
		first_name = b.given_name,
		last_name = b.family_name,
		orcid = b.orcid,
		role_start = b.role_start,
		affiliation_country = c.country,
		affiliation_name = c.[name]
	from _award as a
	join $(awards_json_db_name)..award_investigator as b
		on a.folder = b.folder and a.record_id = b.record_id
	left join $(awards_json_db_name)..award_investigator_affiliation as c
		on a.folder = c.folder and a.record_id = c.record_id and b.investigator_seq = c.investigator_seq
	where coalesce(b.family_name, b.given_name, c.country, c.[name]) is not null
) as a
group by award_id, first_name, last_name, orcid, role_start, affiliation_country, affiliation_name

update #award_investigator_affiliation with(tablock)
set affiliation_country = null
where affiliation_country in ('Unknown', 'Award does not have an ODA Downstream Partner', 'RI REQUIRED')

update #award_investigator_affiliation with(tablock)
set affiliation_name = null
where affiliation_name in ('DATA NOT AVAILABLE')



-- investigator
drop table if exists investigator
create table investigator
(
	investigator_id int identity not null,
	investigator_first_name nvarchar(200) null,
	investigator_last_name nvarchar(200) null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'investigator')
	begin
		set identity_insert investigator on

		insert into investigator with(tablock) (investigator_id, investigator_first_name, investigator_last_name)
		select investigator_id, investigator_first_name, investigator_last_name
		from $(previous_relational_db_name)..investigator

		set identity_insert investigator off
	end
end

insert into investigator with(tablock)
select investigator_first_name = a.first_name, investigator_last_name = a.last_name
from #award_investigator_affiliation as a
where a.first_name is not null or a.last_name is not null
except
select investigator_first_name, investigator_last_name
from investigator
order by investigator_first_name, investigator_last_name

alter table investigator add constraint pk_investigator primary key(investigator_id)



-- investigator_affiliation
drop table if exists investigator_affiliation
create table investigator_affiliation
(
	investigator_affiliation_id int identity not null,
	investigator_affiliation nvarchar(700) null,
	investigator_affiliation_country nvarchar(200) null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'investigator_affiliation')
	begin
		set identity_insert investigator_affiliation on

		insert into investigator_affiliation with(tablock) (investigator_affiliation_id, investigator_affiliation, investigator_affiliation_country)
		select investigator_affiliation_id, investigator_affiliation, investigator_affiliation_country
		from $(previous_relational_db_name)..investigator_affiliation

		set identity_insert investigator_affiliation off
	end
end

insert into investigator_affiliation with(tablock)
select investigator_affiliation = affiliation_name, investigator_affiliation_country = affiliation_country
from #award_investigator_affiliation
where affiliation_name is not null or affiliation_country is not null
except
select investigator_affiliation, investigator_affiliation_country
from investigator_affiliation
order by investigator_affiliation, investigator_affiliation_country

alter table investigator_affiliation add constraint pk_investigator_affiliation primary key(investigator_affiliation_id)



drop table if exists #award_investigator_affiliation2
select a.award_id,
	a.investigator_order,
	b.investigator_id,
	a.orcid,
	a.role_start,
	c.investigator_affiliation_id
into #award_investigator_affiliation2
from #award_investigator_affiliation as a
left join investigator as b on isnull(a.first_name, '-1') = isnull(b.investigator_first_name, '-1') and isnull(a.last_name, '-1') = isnull(b.investigator_last_name, '-1')
left join investigator_affiliation as c on isnull(a.affiliation_name, '-1') = isnull(c.investigator_affiliation, '-1') and isnull(a.affiliation_country, '-1') = isnull(c.investigator_affiliation_country, '-1')



-- award_investigator
drop table if exists award_investigator
create table award_investigator
(
	award_id bigint not null,
	investigator_seq smallint not null,
	investigator_id int not null,
	orcid varchar(60) null,
	kaken_nrid varchar(50) null,
	role_start date null,
	is_lead_investigator bit not null,
	is_co_lead_investigator bit not null
)
go

insert into award_investigator with(tablock)
select b.award_id,
	investigator_seq = row_number() over (partition by b.award_id order by b.investigator_order),
	b.investigator_id,
	b.orcid,
	kaken_nrid = replace(c.id, 'https://nrid.nii.ac.jp/nrid/', ''),
	b.role_start,
	is_lead_investigator = case when b.investigator_order = -10 then 1 else 0 end,
	is_co_lead_investigator = case when b.investigator_order = -5 then 1 else 0 end
from _award as a
join
(
	select award_id,
		investigator_order = min(investigator_order),
		investigator_id,
		orcid = nullif(min(isnull(orcid, 'zzz')), 'zzz'),
		role_start = nullif(min(isnull(role_start, cast('9999-12-31' as date))), cast('9999-12-31' as date))
	from #award_investigator_affiliation2
	where investigator_id is not null
	group by award_id, investigator_id
) as b on a.award_id = b.award_id
left join $(awards_json_db_name)..award_lead_investigator_affiliation_id as c on b.investigator_order = -10 and a.folder = c.folder and a.record_id = c.record_id and c.asserted_by = 'kaken' and c.[type] = 'nrid'

alter table award_investigator add constraint pk_award_investigator primary key(award_id, investigator_seq)
create index idx_award_investigator_investigator_id on award_investigator(investigator_id)
create index idx_award_investigator_orcid on award_investigator(orcid)
create index idx_award_investigator_kaken_nrid on award_investigator(kaken_nrid)
create index idx_award_investigator_is_lead_investigator on award_investigator(is_lead_investigator)
create index idx_award_investigator_is_co_lead_investigator on award_investigator(is_co_lead_investigator)
alter table award_investigator add constraint fk_award_investigator_award_id_award_award_id foreign key(award_id) references award(award_id)
alter table award_investigator add constraint fk_award_investigator_investigator_id_investigator_investigator_id foreign key(investigator_id) references investigator(investigator_id)




-- award_investigator_affiliation
drop table if exists award_investigator_affiliation
create table award_investigator_affiliation
(
	award_id bigint not null,
	investigator_affiliation_seq smallint not null,
	investigator_affiliation_id int not null,
	ror_id char(9) null,
	anr_rnsr varchar(10) null
)
go

insert into award_investigator_affiliation with(tablock)
select b.award_id,
	investigator_affiliation_seq = row_number() over (partition by b.award_id order by b.investigator_order),
	b.investigator_affiliation_id,
	ror_id = replace(coalesce(d1.id, d2.id, d3.id), 'https://ror.org/', ''),
	anr_rnsr = coalesce(e1.id, e2.id, e3.id)
from _award as a
join
(
	select award_id,
		investigator_order = min(investigator_order),
		investigator_affiliation_id
	from #award_investigator_affiliation2
	where investigator_affiliation_id is not null
group by award_id, investigator_affiliation_id
) as b on a.award_id = b.award_id
left join $(awards_json_db_name)..award_lead_investigator_affiliation_id as d1 on b.investigator_order = -10 and a.folder = d1.folder and a.record_id = d1.record_id and d1.[type] = 'ror' and len(replace(d1.id, 'https://ror.org/', '')) = 9
left join $(awards_json_db_name)..award_co_lead_investigator_affiliation_id as d2 on b.investigator_order = -5 and a.folder = d2.folder and a.record_id = d2.record_id and d2.[type] = 'ror' and len(replace(d2.id, 'https://ror.org/', '')) = 9
left join $(awards_json_db_name)..award_investigator_affiliation_id as d3 on b.investigator_order = d3.investigator_seq and a.folder = d3.folder and a.record_id = d3.record_id and d3.[type] = 'ror' and len(replace(d3.id, 'https://ror.org/', '')) = 9
left join $(awards_json_db_name)..award_lead_investigator_affiliation_id as e1 on b.investigator_order = -10 and a.folder = e1.folder and a.record_id = e1.record_id and e1.asserted_by = 'anr' and e1.[type] = 'rnsr'
left join $(awards_json_db_name)..award_co_lead_investigator_affiliation_id as e2 on b.investigator_order = -5 and a.folder = e2.folder and a.record_id = e2.record_id and e2.asserted_by = 'anr' and e2.[type] = 'rnsr'
left join $(awards_json_db_name)..award_investigator_affiliation_id as e3 on b.investigator_order = e3.investigator_seq and a.folder = e3.folder and a.record_id = e3.record_id and e3.asserted_by = 'anr' and e3.[type] = 'rnsr'

alter table award_investigator_affiliation add constraint pk_award_investigator_affiliation primary key(award_id, investigator_affiliation_seq)
create index idx_award_investigator_affiliation_investigator_affiliation_id on award_investigator_affiliation(investigator_affiliation_id)
create index idx_award_investigator_affiliation_ror_id on award_investigator_affiliation(ror_id)
create index idx_award_investigator_affiliation_anr_rnsr on award_investigator_affiliation(anr_rnsr)
alter table award_investigator_affiliation add constraint fk_award_investigator_affiliation_award_id_award_award_id foreign key(award_id) references award(award_id)
alter table award_investigator_affiliation add constraint fk_award_investigator_affiliation_investigator_affiliation_id_investigator_affiliation_investigator_affiliation_id foreign key(investigator_affiliation_id) references investigator_affiliation(investigator_affiliation_id)



-- award_investigator_investigator_affiliation
drop table if exists award_investigator_investigator_affiliation
create table award_investigator_investigator_affiliation
(
	award_id bigint not null,
	investigator_seq smallint not null,
	investigator_affiliation_seq smallint not null
)
go

insert into award_investigator_investigator_affiliation with(tablock)
select a.award_id, b.investigator_seq, c.investigator_affiliation_seq
from #award_investigator_affiliation2 as a
join award_investigator as b on a.award_id = b.award_id and a.investigator_id = b.investigator_id
join award_investigator_affiliation as c on a.award_id = c.award_id and a.investigator_affiliation_id = c.investigator_affiliation_id
group by a.award_id, b.investigator_seq, c.investigator_affiliation_seq

alter table award_investigator_investigator_affiliation add constraint pk_award_investigator_investigator_aff primary key(award_id, investigator_seq, investigator_affiliation_seq)
alter table award_investigator_investigator_affiliation add constraint fk_award_investigator_investigator_aff_award_id_award_award_id foreign key(award_id) references award(award_id)
alter table award_investigator_investigator_affiliation add constraint fk_award_investigator_investigator_aff_award_id_investigator_seq_award_investigator_award_id_investigator_seq foreign key(award_id, investigator_seq) references award_investigator(award_id, investigator_seq)
alter table award_investigator_investigator_affiliation add constraint fk_award_investigator_investigator_aff_award_id_investigator_aff_seq_award_investigator_aff_award_id_investigator_aff_seq foreign key(award_id, investigator_affiliation_seq) references award_investigator_affiliation(award_id, investigator_affiliation_seq)



declare @new_types varchar(1000) =
(
	select string_agg(asserted_by + ':' + [type] + ':' + cast(n as varchar(10)), ', ')
	from
	(
		select asserted_by, [type], n = count(*)
		from 
		(
			select asserted_by, [type]
			from $(awards_json_db_name)..award_lead_investigator_affiliation_id
			union all
			select asserted_by, [type]
			from $(awards_json_db_name)..award_co_lead_investigator_affiliation_id
			union all
			select asserted_by, [type]
			from $(awards_json_db_name)..award_investigator_affiliation_id
		) as a
		where not ((asserted_by = 'kaken' and [type] = 'nrid') or (asserted_by = 'anr' and [type] = 'rnsr') or [type] = 'ror')
		group by asserted_by, [type]
		having count(*) > 100
	) as a
)
if @new_types <> ''
	raiserror('Warning: new types in award_(co_)(lead_)investigator_affiliation_ids: %s', 0, 1, @new_types)
