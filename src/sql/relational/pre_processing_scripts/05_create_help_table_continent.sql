set nocount on

drop table if exists _continent
create table _continent
(
	continent_id int not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _continent with(tablock)
select
	continent_id = replace(id, 'https://openalex.org/continents/Q', ''),
	folder,
	record_id
from $(continents_json_db_name)..continent

alter table _continent add constraint pk_tmp_continent primary key(folder, record_id)
create index idx_tmp_continent_folder on _continent(folder)
create index idx_tmp_continent_record_id on _continent(record_id)
create index idx_tmp_continent_continent_id on _continent(continent_id)
go
