set nocount on

-- funder
drop table if exists funder
create table funder
(
	funder_id bigint not null,
	funder nvarchar(200) null,
	country_iso_alpha2_code char(2) null,
	[description] nvarchar(250) null,
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

insert into funder with(tablock)
select a.funder_id,
	b.display_name,
	b.country_code,
	b.[description],
	b.homepage_url,
	ror_id = replace(b.id_ror, 'https://ror.org/', ''),
	openalex_id = 'F' + cast(a.funder_id as varchar(10)),
	wikidata_id = replace(replace(replace(b.id_wikidata, 'https://www.wikidata.org/entity/', ''), 'https://www.wikidata.org/wiki/', ''), 'wikidata.org/wiki/', ''),
	b.image_url,
	b.image_thumbnail_url,
	b.updated_date,
	b.created_date
from _funder as a
join $(funders_json_db_name)..funder as b on a.folder = b.folder and a.record_id = b.record_id

alter table funder add constraint pk_funder primary key(funder_id)
create index idx_funder_funder on funder(funder)
create index idx_funder_country_iso_alpha2_code on funder(country_iso_alpha2_code)
create index idx_funder_ror_id on funder(ror_id)
create index idx_funder_openalex_id on funder(openalex_id)
create index idx_funder_wikidata_id on funder(wikidata_id)
alter table funder add constraint fk_funder_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)



-- funder_alternative_name
drop table if exists funder_alternative_name
create table funder_alternative_name
(
	funder_id bigint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(300) not null
)
go

insert into funder_alternative_name with(tablock)
select a.funder_id,
	b.alternate_title_seq,
	b.alternate_title
from _funder as a
join $(funders_json_db_name)..funder_alternate_title as b on a.folder = b.folder and a.record_id = b.record_id

alter table funder_alternative_name add constraint pk_funder_alternative_name primary key(funder_id, alternative_name_seq)
alter table funder_alternative_name add constraint fk_funder_alternative_name_funder_id_funder_funder_id foreign key(funder_id) references funder(funder_id)
