set nocount on

drop table if exists _work
create table _work
(
	work_id bigint not null,
	folder smallint not null,
	record_id int not null
)
go

insert into _work with(tablock)
select
	work_id = replace(id, 'https://openalex.org/W', ''),
	folder,
	record_id
from $(works_json_db_name)..work

alter table _work add constraint pk_tmp_work primary key(folder, record_id)
--create index idx_tmp_work_folder on _work(folder)
--create index idx_tmp_work_record_id on _work(record_id)
create index idx_tmp_work_work_id on _work(work_id)
