set nocount on

drop table if exists _concept
create table _concept
(
	concept_id bigint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _concept with(tablock)
select
	concept_id = replace(id, 'https://openalex.org/C', ''),
	folder,
	record_id
from $(concepts_json_db_name)..concept

alter table _concept add constraint pk_tmp_concept primary key(folder, record_id)
create index idx_tmp_concept_folder on _concept(folder)
create index idx_tmp_concept_record_id on _concept(record_id)
create index idx_tmp_concept_concept_id on _concept(concept_id)
go
