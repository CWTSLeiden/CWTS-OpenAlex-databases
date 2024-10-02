set nocount on

-- concept
drop table if exists concept
create table concept
(
	concept_id bigint not null,
	concept nvarchar(120) not null,
	[description] nvarchar(250) null,
	[level] smallint not null,
	openalex_id varchar(11) not null,
	mag_id bigint null,
	wikidata_id varchar(10) null,
	wikipedia_url varchar(180) null,
	image_url varchar(700) null,
	thumbnail_url varchar(900) null,
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
	mag_id = b.id_mag,
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
create index idx_concept_mag_id on concept(mag_id)
create index idx_concept_wikidata_id on concept(wikidata_id)



-- concept_ancestor
drop table if exists concept_ancestor
create table concept_ancestor
(
	concept_id bigint not null,
	ancestor_concept_seq smallint not null,
	ancestor_concept_id bigint not null
)
go

insert into concept_ancestor with(tablock)
select a.concept_id,
	b.ancestor_seq,
	ancestor_concept_id = replace(b.id, 'https://openalex.org/C', '')
from _concept as a
join $(concepts_json_db_name)..concept_ancestor as b on a.folder = b.folder and a.record_id = b.record_id

alter table concept_ancestor add constraint pk_concept_ancestor primary key(concept_id, ancestor_concept_seq)
create index idx_concept_ancestor_ancestor_concept_id on concept_ancestor(ancestor_concept_id)
alter table concept_ancestor add constraint fk_concept_ancestor_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)
alter table concept_ancestor add constraint fk_concept_ancestor_ancestor_concept_id_concept_concept_id foreign key(ancestor_concept_id) references concept(concept_id)



-- concept_related
drop table if exists concept_related
create table concept_related
(
	concept_id bigint not null,
	related_concept_seq smallint not null,
	related_concept_id bigint not null,
	score float not null
)
go

insert into concept_related with(tablock)
select a.concept_id,
	b.related_concept_seq,
	related_concept_id = replace(b.id, 'https://openalex.org/C', ''),
	b.score
from _concept as a
join $(concepts_json_db_name)..concept_related_concept as b on a.folder = b.folder and a.record_id = b.record_id

alter table concept_related add constraint pk_concept_related primary key(concept_id, related_concept_seq)
create index idx_concept_related_related_concept_id on concept_related(related_concept_id)
alter table concept_related add constraint fk_concept_related_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)
alter table concept_related add constraint fk_concept_related_related_concept_id_concept_concept_id foreign key(related_concept_id) references concept(concept_id)



-- concept_umls_aui
drop table if exists concept_umls_aui
create table concept_umls_aui
(
	concept_id bigint not null,
	umls_aui_seq smallint not null,
	umls_aui varchar(9) not null
)
go

insert into concept_umls_aui with(tablock)
select a.concept_id,
	b.id_umls_aui_seq,
	b.id_umls_aui
from _concept as a
join $(concepts_json_db_name)..concept_id_umls_aui as b on a.folder = b.folder and a.record_id = b.record_id

alter table concept_umls_aui add constraint pk_concept_umls_aui primary key(concept_id, umls_aui_seq)
create index idx_concept_umls_aui_umls_aui on concept_umls_aui(umls_aui)
alter table concept_umls_aui add constraint fk_concept_umls_aui_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)



-- concept_umls_cui
drop table if exists concept_umls_cui
create table concept_umls_cui
(
	concept_id bigint not null,
	umls_cui_seq smallint not null,
	umls_cui char(8) not null
)
go

insert into concept_umls_cui with(tablock)
select a.concept_id,
	b.id_umls_cui_seq,
	b.id_umls_cui
from _concept as a
join $(concepts_json_db_name)..concept_id_umls_cui as b on a.folder = b.folder and a.record_id = b.record_id

alter table concept_umls_cui add constraint pk_concept_umls_cui primary key(concept_id, umls_cui_seq)
create index idx_concept_umls_cui_umls_cui on concept_umls_cui(umls_cui)
alter table concept_umls_cui add constraint fk_concept_umls_cui_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)



-- concept_international_name
drop table if exists concept_international_name
create table concept_international_name
(
	concept_id bigint not null,
	language_code varchar(11) not null,
	concept_international_name nvarchar(200) not null
)
go

insert into concept_international_name with(tablock)
select a.concept_id,
	b.international_display_name,
	b.display_name
from _concept as a
join $(concepts_json_db_name)..concept_international_display_name as b on a.folder = b.folder and a.record_id = b.record_id
where b.display_name is not null

alter table concept_international_name add constraint pk_concept_international_name primary key(concept_id, language_code)
alter table concept_international_name add constraint fk_concept_international_name_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)



-- concept_international_description
drop table if exists concept_international_description
create table concept_international_description
(
	concept_id bigint not null,
	language_code varchar(16) not null,
	concept_international_description nvarchar(800) not null
)
go

insert into concept_international_description with(tablock)
select a.concept_id,
	b.international_description,
	b.[description]
from _concept as a
join $(concepts_json_db_name)..concept_international_description as b on a.folder = b.folder and a.record_id = b.record_id
where b.[description] is not null

alter table concept_international_description add constraint pk_concept_international_description primary key(concept_id, language_code)
alter table concept_international_description add constraint fk_concept_international_description_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)
