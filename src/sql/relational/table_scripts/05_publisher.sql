set nocount on

-- publisher
drop table if exists publisher
create table publisher
(
	publisher_id bigint not null,
	publisher nvarchar(200) null,
	hierarchy_level smallint null,
	parent_publisher_id bigint null,
	homepage_url varchar(200) null,
	ror_id varchar(9) null,
	openalex_id varchar(11) not null,
	wikidata_id varchar(10) null,
	image_url varchar(700) null,
	thumbnail_url varchar(1200) null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into publisher with(tablock)
select a.publisher_id,
	b.display_name,
	b.hierarchy_level,
	parent_publisher_id = replace(id, 'https://openalex.org/P', ''),
	b.homepage_url,
	ror_id = replace(b.id_ror, 'https://ror.org/', ''),
	openalex_id = 'P' + cast(a.publisher_id as varchar(10)),
	wikidata_id = replace(replace(replace(b.id_wikidata, 'https://www.wikidata.org/entity/', ''), 'https://wikidata.org/entity/', ''), 'https://www.wikidata.org/wiki/', ''),
	b.image_url,
	b.image_thumbnail_url,
	b.updated_date,
	b.created_date
from _publisher as a
join $(publishers_json_db_name)..publisher as b on a.folder = b.folder and a.record_id = b.record_id

drop table if exists #publisher_from_source
select distinct publisher_id = replace(host_organization, 'https://openalex.org/P', ''),
	openalex_id = replace(host_organization, 'https://openalex.org/', ''),
	publisher = host_organization_name
into #publisher_from_source
from $(sources_json_db_name)..[source]
where patindex('https://openalex.org/P%', host_organization) > 0

insert into publisher with(tablock) (publisher_id, openalex_id, publisher)
select a.publisher_id, a.openalex_id, a.publisher
from #publisher_from_source as a
left join publisher as b on a.publisher_id = b.publisher_id
where b.publisher_id is null

alter table publisher add constraint pk_publisher primary key(publisher_id)
create index idx_publisher_publisher on publisher(publisher)
create index idx_publisher_hierarchy_level on publisher(hierarchy_level)
create index idx_publisher_parent_publisher_id on publisher(parent_publisher_id)
create index idx_publisher_ror_id on publisher(ror_id)
create index idx_publisher_openalex_id on publisher(openalex_id)
create index idx_publisher_wikidata_id on publisher(wikidata_id)



-- publisher_alternative_name
drop table if exists publisher_alternative_name
create table publisher_alternative_name
(
	publisher_id bigint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(150) not null
)
go

insert into publisher_alternative_name with(tablock)
select a.publisher_id,
	b.alternate_title_seq,
	b.alternate_title
from _publisher as a
join $(publishers_json_db_name)..publisher_alternate_title as b on a.folder = b.folder and a.record_id = b.record_id

alter table publisher_alternative_name add constraint pk_publisher_alternative_name primary key(publisher_id, alternative_name_seq)
alter table publisher_alternative_name add constraint fk_publisher_alternative_name_publisher_id_publisher_publisher_id foreign key(publisher_id) references publisher(publisher_id)



-- publisher_country
drop table if exists publisher_country
create table publisher_country
(
	publisher_id bigint not null,
	country_seq smallint not null,
	country_iso_alpha2_code char(2) not null
)
go

insert into publisher_country with(tablock)
select a.publisher_id,
	b.country_code_seq,
	b.country_code
from _publisher as a
join $(publishers_json_db_name)..publisher_country_code as b on a.folder = b.folder and a.record_id = b.record_id

alter table publisher_country add constraint pk_publisher_country primary key(publisher_id, country_seq)
alter table publisher_country add constraint fk_publisher_country_publisher_id_publisher_publisher_id foreign key(publisher_id) references publisher(publisher_id)
alter table publisher_country add constraint fk_publisher_country_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)
