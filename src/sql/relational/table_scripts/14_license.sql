set nocount on

drop table if exists #license
select license = replace(id, 'https://openalex.org/licenses/', ''),
	[name] = display_name,
	[description],
	[url],
	openalex_id = replace(id, 'https://openalex.org/licenses/', ''),
	updated_date,
	created_date
into #license
from $(licenses_json_db_name)..license



-- work_type
drop table if exists license
create table license
(
	license_id tinyint not null identity(1, 1),
	license varchar(60) not null,
	[name] varchar(60) not null,
	[description] varchar(300) null,
	[url] varchar(100) null,
	openalex_id varchar(60) null,
	updated_date date null,
	created_date datetime2 null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'license')
	begin
		set identity_insert license on

		insert into license with(tablock) (license_id, license, [name], [description], [url], openalex_id, updated_date, created_date)
		select a.license_id, b.license, b.[name], b.[description], b.[url], b.openalex_id, b.updated_date, b.created_date
		from $(previous_relational_db_name)..license as a
		join #license as b on a.license = b.license

		set identity_insert license off
	end
end

insert into license with(tablock)
select a.license, a.[name], a.[description], a.[url], a.openalex_id, a.updated_date, a.created_date
from #license as a
left join license as b on a.openalex_id = b.openalex_id
where a.license is not null
	and b.license is null

insert into license with(tablock) (license)
select license
from $(works_json_db_name)..work_location
where license is not null
except
select license
from license
order by license

alter table license add constraint pk_license primary key(license_id)
create index idx_license_license on license(license)
create index idx_license_openalex_id on license(openalex_id)
