set nocount on

drop table if exists _domain
create table _domain
(
	domain_id tinyint not null,
	folder varchar(12) not null,
	record_id int not null
)
go

insert into _domain with(tablock)
select
	domain_id = replace(id, 'https://openalex.org/domains/', ''),
	folder,
	record_id
from $(domains_json_db_name)..domain

alter table _domain add constraint pk_tmp_domain primary key(folder, record_id)
create index idx_tmp_domain_folder on _domain(folder)
create index idx_tmp_domain_record_id on _domain(record_id)
create index idx_tmp_domain_domain_id on _domain(domain_id)
go
