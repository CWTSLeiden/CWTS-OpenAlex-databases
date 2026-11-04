set nocount on

drop table if exists _topic
create table _topic
(
	topic_id smallint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _topic with(tablock)
select
	topic_id = replace(id, 'https://openalex.org/T', ''),
	folder,
	record_id
from $(topics_json_db_name)..topic

alter table _topic add constraint pk_tmp_topic primary key(folder, record_id)
create index idx_tmp_topic_folder on _topic(folder)
create index idx_tmp_topic_record_id on _topic(record_id)
create index idx_tmp_topic_topic_id on _topic(topic_id)
go
