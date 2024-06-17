set nocount on

drop table if exists _subfield
create table _subfield
(
	subfield_id smallint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _subfield with(tablock)
select
	subfield_id = replace(id, 'https://openalex.org/subfields/', ''),
	folder,
	record_id
from $(subfields_json_db_name)..subfield

alter table _subfield add constraint pk_tmp_subfield primary key(folder, record_id)
create index idx_tmp_subfield_folder on _subfield(folder)
create index idx_tmp_subfield_record_id on _subfield(record_id)
create index idx_tmp_subfield_subfield_id on _subfield(subfield_id)
go
