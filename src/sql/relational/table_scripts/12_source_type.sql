set nocount on

drop table if exists #source_type
select source_type = display_name,
	openalex_id = replace(id, 'https://openalex.org/source-types/', ''),
	updated_date,
	created_date
into #source_type
from $(sourcetypes_json_db_name)..source_type



-- source_type
drop table if exists source_type
create table source_type
(
	source_type_id tinyint not null identity(1, 1),
	source_type varchar(15) not null,
	openalex_id varchar(15) null,
	updated_date date null,
	created_date datetime2 null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'source_type')
	begin
		set identity_insert source_type on

		insert into source_type with(tablock) (source_type_id, source_type, openalex_id, updated_date, created_date)
		select a.source_type_id, a.source_type, b.openalex_id, b.updated_date, b.created_date
		from $(previous_relational_db_name)..source_type as a
		left join #source_type as b on a.source_type = b.source_type

		set identity_insert source_type off
	end
end

insert into source_type with(tablock)
select a.source_type, a.openalex_id, a.updated_date, a.created_date
from #source_type as a
left join source_type as b on a.openalex_id = b.openalex_id
where a.source_type is not null
	and b.source_type is null

insert into source_type with(tablock) (source_type)
select source_type = [type]
from $(sources_json_db_name)..[source]
where [type] is not null
except
select source_type
from source_type
order by source_type

alter table source_type add constraint pk_source_type primary key(source_type_id)
create index idx_source_type_work_type on source_type(source_type)
create index idx_source_type_openalex_id on source_type(openalex_id)
