set nocount on

-- domain
drop table if exists domain
create table domain
(
	domain_id tinyint not null,
	domain nvarchar(120) not null,
	[description] nvarchar(250) null,
	openalex_id tinyint not null,
	wikidata_id varchar(10) null,
	wikipedia_url varchar(180) null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into domain with(tablock)
select a.domain_id,
	b.display_name,
	b.[description],
	openalex_id = a.domain_id,
	wikidata_id = replace(b.id_wikidata, 'https://www.wikidata.org/wiki/', ''),
	wikipedia_url = b.id_wikipedia,
	b.updated_date,
	b.created_date
from _domain as a
join $(domains_json_db_name)..domain as b on a.folder = b.folder and a.record_id = b.record_id

alter table domain add constraint pk_domain primary key(domain_id)
create index idx_domain_openalex_id on domain(openalex_id)
create index idx_domain_wikidata_id on domain(wikidata_id)



-- domain_alternative_name
drop table if exists domain_alternative_name
create table domain_alternative_name
(
	domain_id tinyint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(255) not null
)
go

insert into domain_alternative_name with(tablock)
select a.domain_id,
	b.display_name_alternative_seq,
	b.display_name_alternative
from _domain as a
join $(domains_json_db_name)..domain_display_name_alternative as b on a.folder = b.folder and a.record_id = b.record_id

alter table domain_alternative_name add constraint pk_domain_alternative_name primary key(domain_id, alternative_name_seq)
alter table domain_alternative_name add constraint fk_domain_alternative_name_domain_id_domain_domain_id foreign key(domain_id) references domain(domain_id)



-- domain_sibling
drop table if exists domain_sibling
create table domain_sibling
(
	domain_id tinyint not null,
	sibling_domain_seq smallint not null,
	sibling_domain_id tinyint not null
)
go

insert into domain_sibling with(tablock)
select a.domain_id,
	b.sibling_seq,
	sibling_domain_id = replace(b.id, 'https://openalex.org/domains/', '')
from _domain as a
join $(domains_json_db_name)..domain_sibling as b on a.folder = b.folder and a.record_id = b.record_id

alter table domain_sibling add constraint pk_domain_sibling primary key(domain_id, sibling_domain_seq)
create index idx_domain_sibling_sibling_domain_id on domain_sibling(sibling_domain_id)
alter table domain_sibling add constraint fk_domain_sibling_domain_id_domain_domain_id foreign key(domain_id) references domain(domain_id)
alter table domain_sibling add constraint fk_domain_sibling_sibling_domain_id_domain_domain_id foreign key(sibling_domain_id) references domain(domain_id)
