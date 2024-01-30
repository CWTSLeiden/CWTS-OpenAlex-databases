set nocount on

drop table if exists #text_data
select
	a.work_id,
	b.title,
	c.abstract,
	keywords = string_agg(cast(e.keyword as nvarchar(max)), '; ')
into #text_data
from $(relational_db_name)..work as a
left join $(relational_db_name)..work_title as b on a.work_id = b.work_id
left join $(relational_db_name)..work_abstract as c on a.work_id = c.work_id
left join $(relational_db_name)..work_keyword as d on a.work_id = d.work_id
left join $(relational_db_name)..keyword as e on d.keyword_id = e.keyword_id
group by a.work_id, b.title, c.abstract

drop table if exists text_data
create table text_data
(
	work_id bigint not null,
	title nvarchar(max),
	abstract nvarchar(max),
	keywords nvarchar(max)
)

insert into text_data with(tablock)
select work_id, title, abstract, keywords
from #text_data
where not(title is null and abstract is null and keywords is null)

alter table text_data add constraint pk_text_data primary key(work_id)
