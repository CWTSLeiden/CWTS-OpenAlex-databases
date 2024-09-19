set nocount on

-- source_type
drop table if exists source_type
create table source_type
(
	source_type_id smallint not null identity(1, 1),
	source_type varchar(14) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'source_type')
	begin
		set identity_insert source_type on

		insert into source_type with(tablock) (source_type_id, source_type)
		select source_type_id, source_type
		from $(previous_relational_db_name)..source_type

		set identity_insert source_type off
	end
end

insert into source_type with(tablock)
select source_type = [type]
from $(sources_json_db_name)..[source]
where [type] is not null
except
select source_type
from source_type
order by source_type

alter table source_type add constraint pk_source_type primary key(source_type_id)
create index idx_source_type_source_type on source_type(source_type)



-- source
drop table if exists [source]
create table [source]
(
	source_id bigint not null,
	[source] nvarchar(800) null,
	abbreviation nvarchar(100) null,
	source_type_id smallint null,
	country_iso_alpha2_code char(2) null,
	host_organization_publisher_id bigint null,
	host_organization_institution_id bigint null,
	homepage_url varchar(600) null,
	issn_l char(9) null,
	openalex_id varchar(11) not null,
	mag_id bigint null,
	wikidata_id varchar(10) null,
	fatcat_id char(26) null,
	is_in_doaj bit null,
	is_oa bit null,
	apc_price_usd int null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into [source] with(tablock)
select a.source_id,
	b.display_name,
	b.abbreviated_title,
	c.source_type_id,
	b.country_code,
	host_organization_publisher_id = case when patindex('https://openalex.org/P%', b.host_organization) > 0 then replace(b.host_organization, 'https://openalex.org/P', '') else null end,
	host_organization_institution_id = case when patindex('https://openalex.org/I%', b.host_organization) > 0 then replace(b.host_organization, 'https://openalex.org/I', '') else null end,
	b.homepage_url,
	issn_l = case when len(b.id_issn_l) = 9 then b.id_issn_l else null end,
	openalex_id = 'S' + cast(a.source_id as varchar(10)),
	mag_id = b.id_mag,
	wikidata_id = replace(replace(replace(b.id_wikidata, 'https://www.wikidata.org/entity/', ''), 'http://www.wikidata.org/entity/', ''), 'https://www.wikidata.org/wiki/', ''),
	fatcat_id = replace(b.id_fatcat, 'https://fatcat.wiki/container/', ''),
	b.is_in_doaj,
	b.is_oa,
	b.apc_usd,
	b.updated_date,
	b.created_date
from _source as a
join $(sources_json_db_name)..[source] as b on a.folder = b.folder and a.record_id = b.record_id
left join source_type as c on b.[type] = c.source_type
order by len(replace(replace(b.id_wikidata, 'https://www.wikidata.org/entity/', ''), 'http://www.wikidata.org/entity/', '')) desc

drop table if exists #source_from_work
select source_id, openalex_id, [source]
into #source_from_work
from
(
	select source_id = replace(source_id, 'https://openalex.org/S', ''),
		openalex_id = replace(source_id, 'https://openalex.org/', ''),
		[source] = source_display_name,
		[filter] = row_number() over (partition by source_id order by count(*) desc, source_display_name)
	from $(works_json_db_name)..work_location
	where patindex('https://openalex.org/S%', source_id) > 0
	group by source_id, source_display_name
) as a
where [filter] = 1

insert into [source] with(tablock) (source_id, openalex_id, [source])
select a.source_id, a.openalex_id, a.[source]
from #source_from_work as a
left join [source] as b on a.source_id = b.source_id
where b.source_id is null

alter table [source] add constraint pk_source primary key(source_id)
create index idx_source_source on [source]([source])
create index idx_source_abbreviation on [source](abbreviation)
create index idx_source_source_type_id on [source](source_type_id)
create index idx_source_country_iso_alpha2_code on [source](country_iso_alpha2_code)
create index idx_source_host_organization_publisher_id on [source](host_organization_publisher_id)
create index idx_source_host_organization_institution_id on [source](host_organization_institution_id)
create index idx_source_issn_l on [source](issn_l)
create index idx_source_openalex_id on [source](openalex_id)
create index idx_source_mag_id on [source](mag_id)
create index idx_source_wikidata_id on [source](wikidata_id)
create index idx_source_fatcat_id on [source](fatcat_id)
alter table [source] add constraint fk_source_source_type_id_source_type_source_type_id foreign key(source_type_id) references source_type(source_type_id)
alter table [source] add constraint fk_source_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)
alter table [source] add constraint fk_source_host_organization_publisher_id_publisher_publisher_id foreign key(host_organization_publisher_id) references publisher(publisher_id)
alter table [source] add constraint fk_source_host_organization_institution_id_institution_institution_id foreign key(host_organization_institution_id) references institution(institution_id)



alter table institution_repository add constraint fk_institution_repository_source_id_source_source_id foreign key(repository_source_id) references [source](source_id)



-- source_issn
drop table if exists source_issn
create table source_issn
(
	source_id bigint not null,
	issn_seq smallint not null,
	issn char(9) not null
)
go

insert into source_issn with(tablock)
select a.source_id,
	b.issn_seq,
	issn = replace(issn, ' ', '')
from _source as a
join $(sources_json_db_name)..source_issn as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_issn add constraint pk_source_issn primary key(source_id, issn_seq)
create index idx_source_issn_issn on source_issn(issn)
alter table source_issn add constraint fk_source_issn_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_alternative_title
drop table if exists source_alternative_title
create table source_alternative_title
(
	source_id bigint not null,
	alternative_title_seq smallint not null,
	alternative_title nvarchar(700) not null
)
go

insert into source_alternative_title with(tablock)
select a.source_id,
	b.alternate_title_seq,
	b.alternate_title
from _source as a
join $(sources_json_db_name)..source_alternate_title as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_alternative_title add constraint pk_source_alternative_title primary key(source_id, alternative_title_seq)
alter table source_alternative_title add constraint fk_source_alternative_title_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_society
drop table if exists source_society
create table source_society
(
	source_id bigint not null,
	society_seq smallint not null,
	society nvarchar(500) not null,
	homepage_url varchar(250) null
)
go

insert into source_society with(tablock)
select a.source_id, b.society_seq, b.organization, b.url
from _source as a
join $(sources_json_db_name)..source_society as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_society add constraint pk_source_society primary key(source_id, society_seq)
create index idx_source_society_society on source_society(society)
alter table source_society add constraint fk_source_society_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_apc_price
drop table if exists source_apc_price
create table source_apc_price
(
	source_id bigint not null,
	apc_price_seq smallint not null,
	apc_price int not null,
	currency char(3) not null
)
go

insert into source_apc_price with(tablock)
select a.source_id, b.apc_price_seq, b.price, b.currency
from _source as a
join $(sources_json_db_name)..source_apc_price as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_apc_price add constraint pk_source_apc_price primary key(source_id, apc_price_seq)
create index idx_source_apc_price_currency on source_apc_price(currency)
alter table source_apc_price add constraint fk_source_apc_price_source_id_source_source_id foreign key(source_id) references [source](source_id)
