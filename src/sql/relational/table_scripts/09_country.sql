set nocount on

-- country
drop table if exists country
create table country
(
	country_iso_alpha2_code char(2) not null,
	country varchar(60) not null,
    continent_id int not null,
	is_global_south bit not null,
    openalex_id char(2) not null,
    wikidata_id varchar(10) not null,
    wikipedia_url varchar(100) not null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into country with(tablock)
select a.country_id,
	country = b.display_name,
	continent_id = replace(b.continent_id, 'https://openalex.org/continents/Q', ''),
	is_global_south = case when b.is_global_south = 'true' then 1 else 0 end,
	openalex_id = a.country_id,
	wikidata_id = replace(b.id_wikidata, 'https://www.wikidata.org/wiki/', ''),
	wikipedia_url = b.id_wikipedia,
	b.updated_date,
	b.created_date
from _country as a
join $(countries_json_db_name)..country as b on a.folder = b.folder and a.record_id = b.record_id

insert into country with(tablock)
values
    ('EH', 'Western Sahara', '15', 1, 'EH', 'Q6250', 'https://en.wikipedia.org/wiki/Western_Sahara', null, null)

alter table country add constraint pk_country primary key(country_iso_alpha2_code)
create index idx_country_country on country(country)
create index idx_country_continent_id on country(continent_id)
create index idx_country_is_global_south on country(is_global_south)
create index idx_country_openalex_id on country(openalex_id)
create index idx_country_wikidata_id on country(wikidata_id)
alter table country add constraint fk_country_continent_id_continent_continent_id foreign key(continent_id) references continent(continent_id)



-- country_alternative_name
drop table if exists country_alternative_name
create table country_alternative_name
(
	country_iso_alpha2_code char(2) not null,
	alternative_name_seq tinyint not null,
	alternative_name nvarchar(100) not null
)
go

insert into country_alternative_name with(tablock)
select a.country_id,
	b.display_name_alternative_seq,
	left(b.display_name_alternative, 100)
from _country as a
join $(countries_json_db_name)..country_display_name_alternative as b on a.folder = b.folder and a.record_id = b.record_id

alter table country_alternative_name add constraint pk_country_alternative_name primary key(country_iso_alpha2_code, alternative_name_seq)
alter table country_alternative_name add constraint fk_country_alternative_name_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)
