set nocount on

drop table if exists _author
create table _author
(
	author_id bigint not null,
	folder smallint not null,
	record_id int not null
)
go

insert into _author with(tablock)
select
	author_id = replace(id, 'https://openalex.org/A', ''),
	folder,
	record_id
from $(authors_json_db_name)..author

alter table _author add constraint pk_tmp_author primary key(folder, record_id)
create index idx_tmp_author_folder on _author(folder)
create index idx_tmp_author_record_id on _author(record_id)
create index idx_tmp_author_author_id on _author(author_id)
go
