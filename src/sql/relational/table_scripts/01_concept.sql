set nocount on

-- concept
drop table if exists concept
create table concept
(
	concept_id bigint not null,
	concept nvarchar(120) not null,
	[description] nvarchar(550) null,
	[level] smallint not null,
	openalex_id varchar(11) not null,
	wikidata_id varchar(10) null,
	wikipedia_url varchar(150) null,
	image_url varchar(800) null,
	thumbnail_url varchar(1200) null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into concept with(tablock)
select a.concept_id,
	b.display_name,
	b.[description],
	b.[level],
	openalex_id = 'C' + cast(a.concept_id as varchar(10)),
	wikidata_id = replace(b.id_wikidata, 'https://www.wikidata.org/wiki/', ''),
	wikipedia_url = b.id_wikipedia,
	b.image_url,
	b.image_thumbnail_url,
	b.updated_date,
	b.created_date
from _concept as a
join $(concepts_json_db_name)..concept as b on a.folder = b.folder and a.record_id = b.record_id

alter table concept add constraint pk_concept primary key(concept_id)
create index idx_concept_level on concept([level])
create index idx_concept_openalex_id on concept(openalex_id)
create index idx_concept_wikidata_id on concept(wikidata_id)
