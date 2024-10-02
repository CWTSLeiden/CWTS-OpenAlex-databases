set nocount on

-- country
drop table if exists country
create table country
(
	country_iso_alpha2_code char(2) not null,
	country varchar(50) null
)
go

insert into country with(tablock) (country_iso_alpha2_code)
select geo_country_code
from $(institutions_json_db_name)..institution
where geo_country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select country_code
from $(funders_json_db_name)..funder
where country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select country_code
from $(publishers_json_db_name)..publisher_country_code
where country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select country_code
from $(sources_json_db_name)..[source]
where country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select country
from $(works_json_db_name)..work_authorship_country
where country is not null
except
select country_iso_alpha2_code
from country

update a
set a.country = b.country
from country as a
join
(
	select country_iso_alpha2_code = geo_country_code, country = geo_country, [filter] = row_number() over (partition by geo_country_code order by count(*) desc)
	from $(institutions_json_db_name)..institution
	where geo_country_code is not null
		and geo_country is not null
	group by geo_country_code, geo_country
) as b on a.country_iso_alpha2_code = b.country_iso_alpha2_code
	and b.[filter] = 1

alter table country add constraint pk_country primary key(country_iso_alpha2_code)
create index idx_country_country on country(country)



-- city
drop table if exists city
create table city
(
	geonames_city_id int not null,
	city nvarchar(100) null
)
go

insert into city with(tablock) (geonames_city_id)
select geo_geonames_city_id
from $(institutions_json_db_name)..institution
where geo_geonames_city_id is not null
except
select geonames_city_id
from city

update a
set a.city = b.city
from city as a
join
(
	select geonames_city_id = geo_geonames_city_id, city = geo_city, [filter] = row_number() over (partition by geo_geonames_city_id order by count(*) desc)
	from $(institutions_json_db_name)..institution
	where geo_geonames_city_id is not null
		and geo_city is not null
	group by geo_geonames_city_id, geo_city
) as b on a.geonames_city_id = b.geonames_city_id
	and b.[filter] = 1

alter table city add constraint pk_city primary key(geonames_city_id)
create index idx_city_city on city(city)



-- region
drop table if exists region
create table region
(
	region_id smallint not null identity(1, 1),
	region varchar(50) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'region')
	begin
		set identity_insert region on

		insert into region with(tablock) (region_id, region)
		select region_id, region
		from $(previous_relational_db_name)..region

		set identity_insert region off
	end
end

insert into region with(tablock)
select region = geo_region
from $(institutions_json_db_name)..institution
where geo_region is not null
except
select region
from region
order by region

alter table region add constraint pk_region primary key(region_id)
create index idx_region_region on region(region)



-- institution_type
drop table if exists institution_type
create table institution_type
(
	institution_type_id smallint not null identity(1, 1),
	institution_type varchar(10) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'institution_type')
	begin
		set identity_insert institution_type on

		insert into institution_type with(tablock) (institution_type_id, institution_type)
		select institution_type_id, institution_type
		from $(previous_relational_db_name)..institution_type

		set identity_insert institution_type off
	end
end

insert into institution_type with(tablock)
select institution_type = [type]
from $(institutions_json_db_name)..institution
where [type] is not null
except
select institution_type
from institution_type
order by institution_type

alter table institution_type add constraint pk_institution_type primary key(institution_type_id)
create index idx_institution_type_institution_type on institution_type(institution_type)



-- institution
drop table if exists institution
create table institution
(
	institution_id bigint not null,
	institution nvarchar(200) null,
	institution_type_id smallint null,
	country_iso_alpha2_code char(2) null,
	region_id smallint null,
	geonames_city_id int null,
	latitude float null,
	longitude float null,
	homepage_url varchar(600) null,
	is_super_system bit null,
	ror_id varchar(9) null,
	grid_id varchar(13) null,
	openalex_id varchar(11) not null,
	mag_id bigint null,
	wikidata_id varchar(10) null,
	wikipedia_url varchar(800) null,
	image_url varchar(800) null,
	thumbnail_url varchar(1200) null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into institution with(tablock)
select a.institution_id,
	b.display_name,
	c.institution_type_id,
	b.country_code,
	d.region_id,
	b.geo_geonames_city_id,
	b.geo_latitude,
	b.geo_longitude,
	b.homepage_url,
	is_super_system = case when b.is_super_system = 'true' then 1 when b.is_super_system = 'false' then 0 else null end,
	ror_id = replace(b.id_ror, 'https://ror.org/', ''),
	grid_id = b.id_grid,
	openalex_id = 'I' + cast(a.institution_id as varchar(10)),
	mag_id = b.id_mag,
	wikidata_id = replace(b.id_wikidata, 'https://www.wikidata.org/wiki/', ''),
	wikipedia_url = b.id_wikipedia,
	b.image_url,
	b.image_thumbnail_url,
	b.updated_date,
	b.created_date
from _institution as a
join $(institutions_json_db_name)..institution as b on a.folder = b.folder and a.record_id = b.record_id
left join institution_type as c on b.[type] = c.institution_type
left join region as d on b.geo_region = d.region

drop table if exists #institution_from_source
select institution_id, openalex_id, institution
into #institution_from_source
from
(
	select institution_id = replace(host_organization, 'https://openalex.org/I', ''),
		openalex_id = replace(host_organization, 'https://openalex.org/', ''),
		institution = host_organization_name,
		[filter] = row_number() over (partition by host_organization order by count(*) desc, host_organization_name)
	from $(sources_json_db_name)..[source]
	where patindex('https://openalex.org/I%', host_organization) > 0
	group by host_organization, host_organization_name
) as a
where [filter] = 1

insert into institution with(tablock) (institution_id, openalex_id, institution)
select a.institution_id, a.openalex_id, a.institution
from #institution_from_source as a
left join institution as b on a.institution_id = b.institution_id
where b.institution_id is null

drop table if exists #institution_from_work1
select distinct institution_id = replace(institution_id, 'https://openalex.org/I', ''),	openalex_id = replace(institution_id, 'https://openalex.org/', '')
into #institution_from_work1
from $(works_json_db_name)..work_authorship_affiliation_institution_id

insert into institution with(tablock) (institution_id, openalex_id)
select a.institution_id, a.openalex_id
from #institution_from_work1 as a
left join institution as b on a.institution_id = b.institution_id
where b.institution_id is null

drop table if exists #institution_from_work2
select distinct institution_id = replace(id, 'https://openalex.org/I', ''), openalex_id = replace(id, 'https://openalex.org/', '')
into #institution_from_work2
from $(works_json_db_name)..work_authorship_institution

insert into institution with(tablock) (institution_id, openalex_id)
select a.institution_id, a.openalex_id
from #institution_from_work2 as a
left join institution as b on a.institution_id = b.institution_id
where b.institution_id is null

drop table if exists #institution_from_author
select distinct institution_id = replace(institution_id, 'https://openalex.org/I', ''), openalex_id = replace(institution_id, 'https://openalex.org/', '')
into #institution_from_author
from $(authors_json_db_name)..author_affiliation

insert into institution with(tablock) (institution_id, openalex_id)
select a.institution_id, a.openalex_id
from #institution_from_author as a
left join institution as b on a.institution_id = b.institution_id
where b.institution_id is null

alter table institution add constraint pk_institution primary key(institution_id)
create index idx_institution_institution on institution(institution)
create index idx_institution_institution_type_id on institution(institution_type_id)
create index idx_institution_country_iso_alpha2_code on institution(country_iso_alpha2_code)
create index idx_institution_region_id on institution(region_id)
create index idx_institution_geonames_city_id on institution(geonames_city_id)
create index idx_institution_ror_id on institution(ror_id)
create index idx_institution_grid_id on institution(grid_id)
create index idx_institution_openalex_id on institution(openalex_id)
create index idx_institution_mag_id on institution(mag_id)
create index idx_institution_wikidata_id on institution(wikidata_id)
alter table institution add constraint fk_institution_institution_type_id_institution_type_institution_type_id foreign key(institution_type_id) references institution_type(institution_type_id)
alter table institution add constraint fk_institution_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)
alter table institution add constraint fk_institution_region_id_region_region_id foreign key(region_id) references region(region_id)
alter table institution add constraint fk_institution_geonames_city_id_city_geonames_city_id foreign key(geonames_city_id) references city(geonames_city_id)



-- institution_relationship_type
drop table if exists institution_relationship_type
create table institution_relationship_type
(
	institution_relationship_type_id smallint not null identity(1, 1),
	institution_relationship_type varchar(10) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'institution_relationship_type')
	begin
		set identity_insert institution_relationship_type on

		insert into institution_relationship_type with(tablock) (institution_relationship_type_id, institution_relationship_type)
		select institution_relationship_type_id, institution_relationship_type
		from $(previous_relational_db_name)..institution_relationship_type

		set identity_insert institution_relationship_type off
	end
end

insert into institution_relationship_type with(tablock)
select institution_relationship_type = relationship
from $(institutions_json_db_name)..institution_associated_institution
where relationship is not null
except
select institution_relationship_type
from institution_relationship_type
order by institution_relationship_type

alter table institution_relationship_type add constraint pk_institution_relationship_type primary key(institution_relationship_type_id)
create index idx_institution_relationship_type_institution_relationship_type on institution_relationship_type(institution_relationship_type)



-- institution_associated
drop table if exists institution_associated
create table institution_associated
(
	institution_id bigint not null,
	associated_institution_seq smallint not null,
	associated_institution_id bigint not null,
	institution_relationship_type_id smallint not null
)
go

insert into institution_associated with(tablock)
select a.institution_id,
	b.associated_institution_seq,
	associated_institution_id = replace(b.id, 'https://openalex.org/I', ''),
	c.institution_relationship_type_id
from _institution as a
join $(institutions_json_db_name)..institution_associated_institution as b on a.folder = b.folder and a.record_id = b.record_id
left join institution_relationship_type as c on b.relationship = c.institution_relationship_type

delete from a
from institution_associated as a
left join institution as b on a.associated_institution_id = b.institution_id
where b.institution_id is null

alter table institution_associated add constraint pk_institution_associated primary key(institution_id, associated_institution_seq)
create index idx_institution_associated_associated_institution_id on institution_associated(associated_institution_id)
create index idx_institution_associated_institution_relationship_type_id on institution_associated(institution_relationship_type_id)
alter table institution_associated add constraint fk_institution_associated_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)
alter table institution_associated add constraint fk_institution_associated_associated_institution_id_institution_institution_id foreign key(associated_institution_id) references institution(institution_id)
alter table institution_associated add constraint fk_institution_associated_institution_relationship_type_id_institution_relationship_type_institution_relationship_type_id foreign key(institution_relationship_type_id) references institution_relationship_type(institution_relationship_type_id)



-- institution_acronym
drop table if exists institution_acronym
create table institution_acronym
(
	institution_id bigint not null,
	acronym_seq smallint not null,
	acronym nvarchar(70) not null
)
go

insert into institution_acronym with(tablock)
select a.institution_id,
	b.display_name_acronym_seq,
	b.display_name_acronym
from _institution as a
join $(institutions_json_db_name)..institution_display_name_acronym as b on a.folder = b.folder and a.record_id = b.record_id

alter table institution_acronym add constraint pk_institution_acronym primary key(institution_id, acronym_seq)
alter table institution_acronym add constraint fk_institution_acronym_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)



-- institution_alternative_name
drop table if exists institution_alternative_name
create table institution_alternative_name
(
	institution_id bigint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(250) not null
)
go

insert into institution_alternative_name with(tablock)
select a.institution_id,
	b.display_name_alternative_seq,
	b.display_name_alternative
from _institution as a
join $(institutions_json_db_name)..institution_display_name_alternative as b on a.folder = b.folder and a.record_id = b.record_id

alter table institution_alternative_name add constraint pk_institution_alternative_name primary key(institution_id, alternative_name_seq)
alter table institution_alternative_name add constraint fk_institution_alternative_name_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)



-- institution_international_name
drop table if exists institution_international_name
create table institution_international_name
(
	institution_id bigint not null,
	language_code varchar(16) not null,
	institution_international_name nvarchar(200) not null
)
go

insert into institution_international_name with(tablock)
select a.institution_id,
	b.international_display_name,
	b.display_name
from _institution as a
join $(institutions_json_db_name)..institution_international_display_name as b on a.folder = b.folder and a.record_id = b.record_id
where b.display_name is not null

alter table institution_international_name add constraint pk_institution_international_name primary key(institution_id, language_code)
alter table institution_international_name add constraint fk_institution_international_name_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)



-- institution_repository
drop table if exists institution_repository
create table institution_repository
(
	institution_id bigint not null,
	repository_seq smallint not null,
	repository_source_id bigint not null
)
go

insert into institution_repository with(tablock)
select a.institution_id,
	b.repository_seq,
	repository_source_id = replace(b.id, 'https://openalex.org/S', '')
from _institution as a
join $(institutions_json_db_name)..institution_repository as b on a.folder = b.folder and a.record_id = b.record_id

alter table institution_repository add constraint pk_institution_repository primary key(institution_id, repository_seq)
create index idx_institution_repository_repository_source_id on institution_repository(repository_source_id)
alter table institution_repository add constraint fk_institution_repository_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)



-- institution_lineage
drop table if exists institution_lineage
create table institution_lineage
(
	institution_id bigint not null,
	lineage_institution_seq smallint not null,
	lineage_institution_id bigint not null
)
go

insert into institution_lineage with(tablock)
select a.institution_id,
	b.lineage_seq,
	lineage_institution_id = replace(b.lineage, 'https://openalex.org/I', '')
from _institution as a
join $(institutions_json_db_name)..institution_lineage as b on a.folder = b.folder and a.record_id = b.record_id

delete from a
from institution_lineage as a
left join institution as b on a.lineage_institution_id = b.institution_id
where b.institution_id is null

alter table institution_lineage add constraint pk_institution_lineage primary key(institution_id, lineage_institution_seq)
create index idx_institution_lineage_lineage_institution_id on institution_lineage(lineage_institution_id)
alter table institution_lineage add constraint fk_institution_lineage_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)
alter table institution_lineage add constraint fk_institution_lineage_lineage_institution_id_institution_institution_id foreign key(lineage_institution_id) references institution(institution_id)



-- author_institution
drop table if exists author_institution
create table author_institution
(
	author_id bigint not null,
	institution_seq smallint not null,
	institution_id bigint not null
)
go

insert into author_institution with(tablock)
select a.author_id,
	institution_seq = b.affiliation_seq,
	institution_id = replace(b.institution_id, 'https://openalex.org/I', '')
from _author as a
join $(authors_json_db_name)..author_affiliation as b on a.folder = b.folder and a.record_id = b.record_id

alter table author_institution add constraint pk_author_institution primary key(author_id, institution_seq)
alter table author_institution add constraint fk_author_institution_author_id_author_author_id foreign key(author_id) references author(author_id)
alter table author_institution add constraint fk_author_institution_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)



-- author_institution_year
drop table if exists author_institution_year
create table author_institution_year
(
	author_id bigint not null,
	institution_seq smallint not null,
	year_seq smallint not null,
	[year] smallint not null
)
go

insert into author_institution_year with(tablock)
select a.author_id,
	institution_seq = b.affiliation_seq,
	b.year_seq,
	b.[year]
from _author as a
join $(authors_json_db_name)..author_affiliation_year as b on a.folder = b.folder and a.record_id = b.record_id

alter table author_institution_year add constraint pk_author_institution_year primary key(author_id, institution_seq, year_seq)
alter table author_institution_year add constraint fk_author_institution_year_author_id_author_author_id foreign key(author_id) references author(author_id)
alter table author_institution_year add constraint fk_author_institution_year_author_id_author_institution_author_id_institution_seq foreign key(author_id, institution_seq) references author_institution(author_id, institution_seq)



-- author_last_known_institution
drop table if exists author_last_known_institution
create table author_last_known_institution
(
	author_id bigint not null,
	last_known_institution_seq smallint not null,
	last_known_institution_id bigint not null
)
go

insert into author_last_known_institution with(tablock)
select a.author_id,
	last_known_institution_seq = b.affiliation_seq,
	last_known_institution_id = replace(b.institution_id, 'https://openalex.org/I', '')
from _author as a
join $(authors_json_db_name)..author_affiliation as b on a.folder = b.folder and a.record_id = b.record_id

alter table author_last_known_institution add constraint pk_author_last_known_institution primary key(author_id, last_known_institution_seq)
alter table author_last_known_institution add constraint fk_author_last_known_institution_author_id_author_author_id foreign key(author_id) references author(author_id)
alter table author_last_known_institution add constraint fk_author_last_known_institution_institution_id_institution_institution_id foreign key(last_known_institution_id) references institution(institution_id)
