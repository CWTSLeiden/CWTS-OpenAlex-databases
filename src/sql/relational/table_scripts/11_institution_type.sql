set nocount on

drop table if exists #institution_type
select institution_type = display_name,
	openalex_id = replace(id, 'https://openalex.org/institution-types/', ''),
	updated_date,
	created_date
into #institution_type
from $(institutiontypes_json_db_name)..institution_type



-- institution_type
drop table if exists institution_type
create table institution_type
(
	institution_type_id tinyint not null identity(1, 1),
	institution_type varchar(15) not null,
	openalex_id varchar(15) null,
	updated_date date null,
	created_date datetime2 null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'institution_type')
	begin
		set identity_insert institution_type on

		insert into institution_type with(tablock) (institution_type_id, institution_type, openalex_id, updated_date, created_date)
		select a.institution_type_id, a.institution_type, b.openalex_id, b.updated_date, b.created_date
		from $(previous_relational_db_name)..institution_type as a
		left join #institution_type as b on a.institution_type = b.institution_type

		set identity_insert institution_type off
	end
end

insert into institution_type with(tablock)
select a.institution_type, a.openalex_id, a.updated_date, a.created_date
from #institution_type as a
left join institution_type as b on a.openalex_id = b.openalex_id
where a.institution_type is not null
	and b.institution_type is null

insert into institution_type with(tablock) (institution_type)
select institution_type = [type]
from $(institutions_json_db_name)..institution
where [type] is not null
except
select institution_type
from institution_type
order by institution_type

alter table institution_type add constraint pk_institution_type primary key(institution_type_id)
create index idx_institution_type_institution_type on institution_type(institution_type)
create index idx_institution_type_openalex_id on institution_type(openalex_id)
