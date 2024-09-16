set nocount on

-- subfield
drop table if exists subfield
create table subfield
(
	subfield_id smallint not null,
	subfield nvarchar(120) not null,
	[description] nvarchar(250) null,
	openalex_id smallint not null,
	wikidata_id varchar(10) null,
	wikipedia_url varchar(180) null,
	domain_id tinyint not null,
	field_id tinyint not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into subfield with(tablock)
select a.subfield_id,
	b.display_name,
	b.[description],
	openalex_id = a.subfield_id,
	wikidata_id = replace(replace(b.id_wikidata, 'https://www.wikidata.org/wiki/', ''), 'http://www.wikidata.org/entity/', ''),
	wikipedia_url = b.id_wikipedia,
	domain_id = replace(b.domain_id, 'https://openalex.org/domains/', ''),
	field_id = replace(b.field_id, 'https://openalex.org/fields/', ''),
	b.updated_date,
	b.created_date
from _subfield as a
join $(subfields_json_db_name)..subfield as b on a.folder = b.folder and a.record_id = b.record_id

alter table subfield add constraint pk_subfield primary key(subfield_id)
alter table subfield add constraint fk_subfield_domain_id_domain_domain_id foreign key(domain_id) references domain(domain_id)
alter table subfield add constraint fk_subfield_field_id_field_field_id foreign key(field_id) references field(field_id)
create index idx_subfield_openalex_id on subfield(openalex_id)
create index idx_subfield_wikidata_id on subfield(wikidata_id)
create index idx_subfield_domain_id on subfield(domain_id)
create index idx_subfield_field_id on subfield(field_id)



-- subfield_alternative_name
drop table if exists subfield_alternative_name
create table subfield_alternative_name
(
	subfield_id smallint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(255) not null
)
go

insert into subfield_alternative_name with(tablock)
select a.subfield_id,
	b.display_name_alternative_seq,
	b.display_name_alternative
from _subfield as a
join $(subfields_json_db_name)..subfield_display_name_alternative as b on a.folder = b.folder and a.record_id = b.record_id

alter table subfield_alternative_name add constraint pk_subfield_alternative_name primary key(subfield_id, alternative_name_seq)
alter table subfield_alternative_name add constraint fk_subfield_alternative_name_subfield_id_subfield_subfield_id foreign key(subfield_id) references subfield(subfield_id)



-- subfield_sibling
drop table if exists subfield_sibling
create table subfield_sibling
(
	subfield_id smallint not null,
	sibling_subfield_seq smallint not null,
	sibling_subfield_id smallint not null
)
go

insert into subfield_sibling with(tablock)
select a.subfield_id,
	b.sibling_seq,
	sibling_subfield_id = replace(b.id, 'https://openalex.org/subfields/', '')
from _subfield as a
join $(subfields_json_db_name)..subfield_sibling as b on a.folder = b.folder and a.record_id = b.record_id

alter table subfield_sibling add constraint pk_subfield_sibling primary key(subfield_id, sibling_subfield_seq)
create index idx_subfield_sibling_sibling_subfield_id on subfield_sibling(sibling_subfield_id)
alter table subfield_sibling add constraint fk_subfield_sibling_subfield_id_subfield_subfield_id foreign key(subfield_id) references subfield(subfield_id)
alter table subfield_sibling add constraint fk_subfield_sibling_sibling_subfield_id_subfield_subfield_id foreign key(sibling_subfield_id) references subfield(subfield_id)



-- field_subfield
drop table if exists field_subfield
create table field_subfield
(
	field_id tinyint not null,
	subfield_seq smallint not null,
	subfield_id smallint not null
)
go

insert into field_subfield with(tablock)
select a.field_id,
	b.subfield_seq,
	subfield_id = replace(b.id, 'https://openalex.org/subfields/', '')
from _field as a
join $(fields_json_db_name)..field_subfield as b on a.folder = b.folder and a.record_id = b.record_id

alter table field_subfield add constraint pk_field_subfield primary key(field_id, subfield_seq)
create index idx_field_subfield_subfield_id on field_subfield(subfield_id)
alter table field_subfield add constraint fk_field_subfield_field_id_field_field_id foreign key(field_id) references field(field_id)
alter table field_subfield add constraint fk_field_subfield_subfield_id_subfield_subfield_id foreign key(subfield_id) references subfield(subfield_id)
