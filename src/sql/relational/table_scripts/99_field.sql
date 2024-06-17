set nocount on

-- field
drop table if exists field
create table field
(
	field_id tinyint not null,
	field nvarchar(120) not null,
	[description] nvarchar(250) null,
	openalex_id tinyint not null,
	wikidata_id varchar(10) null,
	wikipedia_url varchar(180) null,
	domain_id tinyint not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into field with(tablock)
select a.field_id,
	b.display_name,
	b.[description],
	openalex_id = a.field_id,
	wikidata_id = replace(b.id_wikidata, 'https://www.wikidata.org/wiki/', ''),
	wikipedia_url = b.id_wikipedia,
	domain_id = replace(b.domain_id, 'https://openalex.org/domains/', ''),
	b.updated_date,
	b.created_date
from _field as a
join $(fields_json_db_name)..field as b on a.folder = b.folder and a.record_id = b.record_id

alter table field add constraint pk_field primary key(field_id)
alter table field add constraint fk_field_domain_id_domain_domain_id foreign key(domain_id) references domain(domain_id)
create index idx_field_openalex_id on field(openalex_id)
create index idx_field_wikidata_id on field(wikidata_id)
create index idx_field_domain_id on field(domain_id)



-- field_alternative_name
drop table if exists field_alternative_name
create table field_alternative_name
(
	field_id tinyint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(255) not null
)
go

insert into field_alternative_name with(tablock)
select a.field_id,
	b.display_name_alternative_seq,
	b.display_name_alternative
from _field as a
join $(fields_json_db_name)..field_display_name_alternative as b on a.folder = b.folder and a.record_id = b.record_id

alter table field_alternative_name add constraint pk_field_alternative_name primary key(field_id, alternative_name_seq)
alter table field_alternative_name add constraint fk_field_alternative_name_field_id_field_field_id foreign key(field_id) references field(field_id)



-- field_sibling
drop table if exists field_sibling
create table field_sibling
(
	field_id tinyint not null,
	sibling_field_seq smallint not null,
	sibling_field_id tinyint not null
)
go

insert into field_sibling with(tablock)
select a.field_id,
	b.sibling_seq,
	sibling_field_id = replace(b.id, 'https://openalex.org/fields/', '')
from _field as a
join $(fields_json_db_name)..field_sibling as b on a.folder = b.folder and a.record_id = b.record_id

alter table field_sibling add constraint pk_field_sibling primary key(field_id, sibling_field_seq)
create index idx_field_sibling_sibling_field_id on field_sibling(sibling_field_id)
alter table field_sibling add constraint fk_field_sibling_field_id_field_field_id foreign key(field_id) references field(field_id)
alter table field_sibling add constraint fk_field_sibling_sibling_field_id_field_field_id foreign key(sibling_field_id) references field(field_id)



-- domain_field
drop table if exists domain_field
create table domain_field
(
	domain_id tinyint not null,
	field_seq smallint not null,
	field_id tinyint not null
)
go

insert into domain_field with(tablock)
select a.domain_id,
	b.field_seq,
	field_id = replace(b.id, 'https://openalex.org/fields/', '')
from _domain as a
join $(domains_json_db_name)..domain_field as b on a.folder = b.folder and a.record_id = b.record_id

alter table domain_field add constraint pk_domain_field primary key(domain_id, field_seq)
create index idx_domain_field_field_id on domain_field(field_id)
alter table domain_field add constraint fk_domain_field_domain_id_domain_domain_id foreign key(domain_id) references domain(domain_id)
alter table domain_field add constraint fk_domain_field_field_id_field_field_id foreign key(field_id) references field(field_id)

