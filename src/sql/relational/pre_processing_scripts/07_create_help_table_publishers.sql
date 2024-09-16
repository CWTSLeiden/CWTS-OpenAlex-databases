set nocount on

drop table if exists _publisher
create table _publisher
(
	publisher_id bigint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _publisher with(tablock)
select
	publisher_id = replace(id, 'https://openalex.org/P', ''),
	folder,
	record_id
from $(publishers_json_db_name)..publisher

alter table _publisher add constraint pk_tmp_publisher primary key(folder, record_id)
create index idx_tmp_publisher_folder on _publisher(folder)
create index idx_tmp_publisher_record_id on _publisher(record_id)
create index idx_tmp_publisher_institution_id on _publisher(publisher_id)
go
