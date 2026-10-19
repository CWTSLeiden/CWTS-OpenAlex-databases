set nocount on

drop table if exists _country
create table _country
(
	country_id char(2) not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _country with(tablock)
select
	country_id = replace(id, 'https://openalex.org/countries/', ''),
	folder,
	record_id
from $(countries_json_db_name)..country

alter table _country add constraint pk_tmp_country primary key(folder, record_id)
create index idx_tmp_country_folder on _country(folder)
create index idx_tmp_country_record_id on _country(record_id)
create index idx_tmp_country_country_id on _country(country_id)
go
