set nocount on

drop table if exists #author
select a.author_id,
	author = b.display_name,
	orcid = $(etl_db_name).dbo.regex_replace(b.id_orcid, '(https://orcid.org/)|[/]|[ ]', ''),
	openalex_id = 'A' + cast(a.author_id as varchar(10)),
	b.updated_date,
	b.created_date
into #author
from _author as a
join $(authors_json_db_name)..author as b on a.folder = b.folder and a.record_id = b.record_id



-- author
drop table if exists author
create table author
(
	author_id bigint not null,
	author nvarchar(100) null,
	orcid char(19) null,
	openalex_id varchar(11) not null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into author with(tablock)
select author_id,
	left(author, 100),
	case when len(orcid) = 19 then orcid else null end,
	openalex_id,
	updated_date,
	created_date
from #author

insert into author with(tablock) (author_id, openalex_id)
select author_id = replace(author_id, 'https://openalex.org/A', ''),
	openalex_id = replace(author_id, 'https://openalex.org/', '')
from $(works_json_db_name)..work_authorship
where author_id is not null
except
select author_id, openalex_id
from author

alter table author add constraint pk_author primary key(author_id)
create index idx_author_orcid on author(orcid)
create index idx_author_openalex_id on author(openalex_id)



-- author_alternative_name
drop table if exists author_alternative_name
create table author_alternative_name
(
	author_id bigint not null,
	alternative_name_seq smallint not null,
	alternative_name nvarchar(100) not null
)
go

insert into author_alternative_name with(tablock)
select a.author_id,
	b.display_name_alternative_seq,
	left(b.display_name_alternative, 100)
from _author as a
join $(authors_json_db_name)..author_display_name_alternative as b on a.folder = b.folder and a.record_id = b.record_id

alter table author_alternative_name add constraint pk_author_alternative_name primary key(author_id, alternative_name_seq)
alter table author_alternative_name add constraint fk_author_alternative_name_author_id_author_author_id foreign key(author_id) references author(author_id)



-- author_raw_name
drop table if exists author_raw_name
create table author_raw_name
(
	author_id bigint not null,
	raw_name_seq smallint not null,
	raw_name nvarchar(100) not null
)
go

insert into author_raw_name with(tablock)
select a.author_id,
	b.raw_author_name_seq,
	left(b.raw_author_name, 100)
from _author as a
join $(authors_json_db_name)..author_raw_author_name as b on a.folder = b.folder and a.record_id = b.record_id

alter table author_raw_name add constraint pk_author_raw_name primary key(author_id, raw_name_seq)
alter table author_raw_name add constraint fk_author_raw_name_author_id_author_author_id foreign key(author_id) references author(author_id)
