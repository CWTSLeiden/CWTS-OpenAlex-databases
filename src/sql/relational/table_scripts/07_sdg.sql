set nocount on

-- sdg
drop table if exists sdg
create table sdg
(
	sdg_id tinyint not null,
	sdg varchar(40) not null,
	[description] varchar(200) not null,
	[url] varchar(30) not null,
	openalex_id tinyint not null,
	wikidata_id varchar(10) not null,
	image_url varchar(650) not null,
	thumbnail_url varchar(650) not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into sdg with(tablock)
select sdg_id = replace(id, 'https://openalex.org/sdgs/', ''),
	sdg = display_name,
	[description],
	[url] = id_un,
	openalex_id = replace(id, 'https://openalex.org/sdgs/', ''),
	wikidata_id = replace(id_wikidata, 'https://www.wikidata.org/wiki/', ''),
	image_url,
	thumbnail_url = image_thumbnail_url,
	updated_date,
	created_date
from $(sdgs_json_db_name)..sdg

alter table sdg add constraint pk_sdg primary key(sdg_id)
create index idx_sdg_sdg on sdg(sdg)
create index idx_sdg_openalex_id on sdg(openalex_id)
create index idx_sdg_wikidata_id on sdg(wikidata_id)
