set nocount on

drop table if exists _award
create table _award
(
	award_id bigint not null,
	folder char(6) not null,
	record_id int not null
)
go

insert into _award with(tablock)
select
	award_id = replace(id, 'https://openalex.org/G', ''),
	folder,
	record_id
from $(awards_json_db_name)..award

alter table _award add constraint pk_tmp_award primary key(folder, record_id)
create index idx_tmp_award_folder on _award(folder)
create index idx_tmp_award_record_id on _award(record_id)
create index idx_tmp_award_award_id on _award(award_id)
go
