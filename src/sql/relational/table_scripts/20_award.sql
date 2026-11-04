set nocount on

-- award_provenance
drop table if exists award_provenance
create table award_provenance
(
	award_provenance_id smallint identity not null,
	award_provenance varchar(50) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'award_provenance')
	begin
		set identity_insert award_provenance on

		insert into award_provenance with(tablock) (award_provenance_id, award_provenance)
		select award_provenance_id, award_provenance
		from $(previous_relational_db_name)..award_provenance

		set identity_insert award_provenance off
	end
end

insert into award_provenance with(tablock)
select provenance
from $(awards_json_db_name)..award
where provenance is not null
except
select award_provenance
from award_provenance
order by provenance

alter table award_provenance add constraint pk_award_provenance primary key(award_provenance_id)
create index idx_award_provenance_award_provenance on award_provenance(award_provenance)



-- funding_type
drop table if exists funding_type
create table funding_type
(
	funding_type_id smallint identity not null,
	funding_type varchar(50) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'funding_type')
	begin
		set identity_insert funding_type on

		insert into funding_type with(tablock) (funding_type_id, funding_type)
		select funding_type_id, funding_type
		from $(previous_relational_db_name)..funding_type

		set identity_insert funding_type off
	end
end

insert into funding_type with(tablock)
select funding_type
from $(awards_json_db_name)..award
where funding_type is not null
	and funding_type <> 'unknown'
except
select funding_type
from funding_type
order by funding_type

alter table funding_type add constraint pk_funding_type primary key(funding_type_id)
create index idx_funding_type_funding_type on funding_type(funding_type)



-- funder_award_scheme
drop table if exists funder_award_scheme
create table funder_award_scheme
(
	funder_award_scheme_id int identity not null,
	funder_award_scheme nvarchar(800) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'funder_award_scheme')
	begin
		set identity_insert funder_award_scheme on

		insert into funder_award_scheme with(tablock) (funder_award_scheme_id, funder_award_scheme)
		select funder_award_scheme_id, funder_award_scheme
		from $(previous_relational_db_name)..funder_award_scheme

		set identity_insert funder_award_scheme off
	end
end

insert into funder_award_scheme with(tablock)
select funder_award_scheme = left(funder_scheme, 800)
from $(awards_json_db_name)..award
where funder_scheme is not null
	and funder_scheme not in ('unknown', 'none')
except
select funder_award_scheme
from funder_award_scheme
order by funder_award_scheme

alter table funder_award_scheme add constraint pk_funder_award_scheme primary key(funder_award_scheme_id)
create index idx_funder_award_scheme_funder_award_scheme on funder_award_scheme(funder_award_scheme)



-- award
drop table if exists award
create table award
(
	award_id bigint not null,
	funder_id bigint null,
	funding_type_id smallint null,
	funder_award_scheme_id int null,
	award_provenance_id smallint not null,
	amount float null,
	currency char(3) null,
	[start_date] date null,
	start_year smallint null,
	end_date date null,
	end_year smallint null,
	landing_page_url nvarchar(1000) null,
	funder_award_id nvarchar(1200) null,
	doi varchar(100) null,
	openalex_id varchar(11) not null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into award with(tablock)
select
	a.award_id,
	funder_id = replace(b.funder_id, 'https://openalex.org/F', ''),
	c.funding_type_id,
	d.funder_award_scheme_id,
	e.award_provenance_id,
	b.amount,
	b.currency,
	b.[start_date],
	b.start_year,
	b.end_date,
	b.end_year,
	b.landing_page_url,
	b.funder_award_id,	
	doi = cwtsdb_etl.dbo.regex_replace(b.doi, '(.*doi.org/)(10.*)', '$2'),
	openalex_id = 'G' + cast(a.award_id as varchar(10)),
	b.updated_date,
	b.created_date	
from _award as a
join $(awards_json_db_name)..award as b on a.folder = b.folder and a.record_id = b.record_id
left join funding_type as c on b.funding_type = c.funding_type
left join funder_award_scheme as d on left(b.funder_scheme, 800) = d.funder_award_scheme
left join award_provenance as e on b.provenance = e.award_provenance

alter table award add constraint pk_award primary key(award_id)
create index idx_award_funder_id on award(funder_id)
create index idx_award_funding_type_id on award(funding_type_id)
create index idx_award_funder_award_scheme_id on award(funder_award_scheme_id)
create index idx_award_award_provenance_id on award(award_provenance_id)
create index idx_award_start_date on award(start_date)
create index idx_award_start_year on award(start_year)
create index idx_award_end_date on award(end_date)
create index idx_award_end_year on award(end_year)
create index idx_award_doi on award(doi)
create index idx_award_openalex_id on award(openalex_id)
alter table award add constraint fk_award_funder_id foreign key(funder_id) references funder(funder_id)
alter table award add constraint fk_award_funding_type_id foreign key(funding_type_id) references funding_type(funding_type_id)
alter table award add constraint fk_award_funder_award_scheme_id foreign key(funder_award_scheme_id) references funder_award_scheme(funder_award_scheme_id)
alter table award add constraint fk_award_award_provenance_id foreign key(award_provenance_id) references award_provenance(award_provenance_id)



drop table if exists #award_text_na
create table #award_text_na(award_text_na nvarchar(100))
insert into #award_text_na with(tablock)
values
	('#n/a'),
	('(no summary)'),
	('(none)'),
	('-'),
	('.'),
	('0'),
	('keine zusammenfassung vorhanden'),
	('keine zusammenfassung vorhanden.'),
	('n/a'),
	('no abstract available.'),
	('no data entered'),
	('no description available'),
	('no phr'),
	('no public description'),
	('no summary - aucun sommaire'),
	('no text'),
	('no title - aucun titre'),
	('none'),
	('not applicable'),
	('not applicable.'),
	('not available'),
	('not available'),
	('null'),
	('project narrative n/a'),
	('sans objet'),
	('tba'),
	('tbd'),
	('untitled')



-- award_title
drop table if exists award_title
create table award_title
(
	award_id bigint not null,
	title nvarchar(max) not null
)
go

insert into award_title with(tablock)
select a.award_id,
	title = trim(cwtsdb_etl.dbo.regex_replace(cwtsdb_etl.dbo.remove_html_tags(cwtsdb_etl.dbo.decode_html_characters2(b.display_name)), '[\r\n\t]', ' '))
from _award as a
join $(awards_json_db_name)..award as b on a.folder = b.folder and a.record_id = b.record_id
left join #award_text_na as c on b.display_name = c.award_text_na
where b.display_name is not null
	and len(b.display_name) > 4
	and c.award_text_na is null

alter table award_title add constraint pk_award_title primary key(award_id)
alter table award_title add constraint fk_award_title_award_id foreign key(award_id) references award(award_id)



-- award_description
drop table if exists award_description
create table award_description
(
	award_id bigint not null,
	[description] nvarchar(max) not null
)
go

insert into award_description with(tablock)
select a.award_id,
	[description] = trim(cwtsdb_etl.dbo.regex_replace(cwtsdb_etl.dbo.remove_html_tags(cwtsdb_etl.dbo.decode_html_characters2(b.[description])), '[\r\n\t]', ' '))
from _award as a
join $(awards_json_db_name)..award as b on a.folder = b.folder and a.record_id = b.record_id
left join #award_text_na as c on b.[description] = c.award_text_na
where b.[description] is not null
	and len(b.[description]) > 4
	and c.award_text_na is null

alter table award_description add constraint pk_award_description primary key(award_id)
alter table award_description add constraint fk_award_description_award_id foreign key(award_id) references award(award_id)



-- award_topic
drop table if exists award_topic
create table award_topic
(
	award_id bigint not null,
	topic_seq smallint not null,
	topic_id smallint not null,
	score float not null,
	is_primary_topic bit not null
)
go

insert into award_topic with(tablock)
select a.award_id,
	b.topic_seq,
	topic_id = replace(b.id, 'https://openalex.org/T', ''),
	b.score,
	is_primary_topic = case when b.topic_seq = 1 then 1 else 0 end
from _award as a
join $(awards_json_db_name)..award_topic as b on a.folder = b.folder and a.record_id = b.record_id

alter table award_topic add constraint pk_award_topic primary key(award_id, topic_seq)
create index idx_award_topic_topic_id on award_topic(topic_id)
create index idx_award_topic_is_primary_topic on award_topic(is_primary_topic)
alter table award_topic add constraint fk_award_topic_award_id_award_award_id foreign key(award_id) references award(award_id)
alter table award_topic add constraint fk_award_topic_topic_id_topic_topic_id foreign key(topic_id) references topic(topic_id)



-- award_institution
drop table if exists award_institution
create table award_institution
(
	award_id bigint not null,
	institution_seq smallint not null,
	institution_id bigint not null
)
go

insert into award_institution with(tablock)
select a.award_id,
	institution_seq = b.institution_awarded_seq,
	institution_id = replace(b.id, 'https://openalex.org/I', '')
from _award as a
join $(awards_json_db_name)..award_institution_awarded as b on a.folder = b.folder and a.record_id = b.record_id

alter table award_institution add constraint pk_award_institution primary key(award_id, institution_seq)
create index idx_award_institution_institution_id on award_institution(institution_id)
alter table award_institution add constraint fk_award_institution_award_id_award_award_id foreign key(award_id) references award(award_id)
alter table award_institution add constraint fk_award_institution_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)



-- award_work
drop table if exists award_work
create table award_work
(
	award_id bigint not null,
	work_seq smallint not null,
	work_id bigint not null
)
go

insert into award_work with(tablock)
select a.award_id,
	work_seq = b.funded_output_seq,
	work_id = replace(b.funded_output, 'https://openalex.org/W', '')
from _award as a
join $(awards_json_db_name)..award_funded_output as b on a.folder = b.folder and a.record_id = b.record_id

alter table award_work add constraint pk_award_work primary key(award_id, work_seq)
create index idx_award_work_work_id on award_work(work_id)
alter table award_work add constraint fk_award_work_award_id_award_award_id foreign key(award_id) references award(award_id)
