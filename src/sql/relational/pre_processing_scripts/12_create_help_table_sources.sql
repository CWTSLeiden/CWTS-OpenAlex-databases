set nocount on

drop table if exists _source
create table _source
(
	source_id bigint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _source with(tablock)
select
	source_id = replace(id, 'https://openalex.org/S', ''),
	folder,
	record_id
from $(sources_json_db_name)..[source]

alter table _source add constraint pk_tmp_source primary key(folder, record_id)
create index idx_tmp_source_folder on _source(folder)
create index idx_tmp_source_record_id on _source(record_id)
create index idx_tmp_source_source_id on _source(source_id)
go
