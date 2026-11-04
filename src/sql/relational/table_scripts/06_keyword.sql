set nocount on

drop table if exists #keyword
select keyword = display_name, openalex_id = replace(id, 'https://openalex.org/keywords/', ''), updated_date, created_date
into #keyword
from $(keywords_json_db_name)..keyword



drop table if exists keyword
create table keyword
(
    keyword_id int not null identity(1, 1),
    keyword nvarchar(120) not null,
	openalex_id nvarchar(120) not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'keyword')
	begin
		set identity_insert keyword on

		insert into keyword with(tablock) (keyword_id, keyword, openalex_id, updated_date, created_date)
		select a.keyword_id, a.keyword, b.openalex_id, b.updated_date, b.created_date
		from $(previous_relational_db_name)..keyword as a
		join #keyword as b on a.keyword = b.keyword

		set identity_insert keyword off
	end
end

insert into keyword with(tablock)
select a.keyword, a.openalex_id, a.updated_date, a.created_date
from #keyword as a
left join keyword as b on a.openalex_id = b.openalex_id
where a.keyword is not null
	and b.keyword is null

alter table keyword add constraint pk_keyword primary key(keyword_id)
create index idx_keyword_keyword on keyword(keyword)
create index idx_keyword_openalex_id on keyword(openalex_id)
