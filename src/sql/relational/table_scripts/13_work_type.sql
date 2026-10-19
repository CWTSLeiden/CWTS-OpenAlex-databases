set nocount on

drop table if exists #work_type
select work_type = display_name,
	[description],
	openalex_id = replace(id, 'https://openalex.org/types/', ''),
	updated_date,
	created_date
into #work_type
from $(worktypes_json_db_name)..work_type



-- work_type
drop table if exists work_type
create table work_type
(
	work_type_id tinyint not null identity(1, 1),
	work_type varchar(25) not null,
	[description] varchar(200) null,
	openalex_id varchar(25) null,
	updated_date date null,
	created_date datetime2 null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'work_type')
	begin
		set identity_insert work_type on

		insert into work_type with(tablock) (work_type_id, work_type, [description], openalex_id, updated_date, created_date)
		select a.work_type_id, a.work_type, b.[description], b.openalex_id, b.updated_date, b.created_date
		from $(previous_relational_db_name)..work_type as a
		left join #work_type as b on a.work_type = b.work_type

		set identity_insert work_type off
	end
end

insert into work_type with(tablock)
select a.work_type, a.[description], a.openalex_id, a.updated_date, a.created_date
from #work_type as a
left join work_type as b on a.openalex_id = b.openalex_id
where a.work_type is not null
	and b.work_type is null

insert into work_type with(tablock) (work_type)
select work_type = [type]
from $(works_json_db_name)..work
where [type] is not null
except
select work_type
from work_type
order by work_type

alter table work_type add constraint pk_work_type primary key(work_type_id)
create index idx_work_type_work_type on work_type(work_type)
create index idx_work_type_openalex_id on work_type(openalex_id)
