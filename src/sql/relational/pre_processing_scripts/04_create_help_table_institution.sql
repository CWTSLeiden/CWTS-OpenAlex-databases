set nocount on

drop table if exists _institution
create table _institution
(
	institution_id bigint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _institution with(tablock)
select
	institution_id = replace(id, 'https://openalex.org/I', ''),
	folder,
	record_id
from $(institutions_json_db_name)..institution

alter table _institution add constraint pk_tmp_institution primary key(folder, record_id)
create index idx_tmp_institution_folder on _institution(folder)
create index idx_tmp_institution_record_id on _institution(record_id)
create index idx_tmp_institution_institution_id on _institution(institution_id)
go
