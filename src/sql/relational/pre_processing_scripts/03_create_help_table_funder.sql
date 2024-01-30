set nocount on

drop table if exists _funder
create table _funder
(
	funder_id bigint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _funder with(tablock)
select
	funder_id = replace(id, 'https://openalex.org/F', ''),
	folder,
	record_id
from $(funders_json_db_name)..funder

alter table _funder add constraint pk_tmp_funder primary key(folder, record_id)
create index idx_tmp_funder_folder on _funder(folder)
create index idx_tmp_funder_record_id on _funder(record_id)
create index idx_tmp_funder_funder_id on _funder(funder_id)
go
