set nocount on

drop table if exists _field
create table _field
(
	field_id tinyint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _field with(tablock)
select
	field_id = replace(id, 'https://openalex.org/fields/', ''),
	folder,
	record_id
from $(fields_json_db_name)..field

alter table _field add constraint pk_tmp_field primary key(folder, record_id)
create index idx_tmp_field_folder on _field(folder)
create index idx_tmp_field_record_id on _field(record_id)
create index idx_tmp_field_field_id on _field(field_id)
go
