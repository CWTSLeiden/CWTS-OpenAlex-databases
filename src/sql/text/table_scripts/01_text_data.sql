set nocount on

drop table if exists #work_keywords
select a.work_id, keywords = string_agg(cast(b.keyword as nvarchar(max)), '; ')
into #work_keywords
from $(relational_db_name)..work_keyword as a
join $(relational_db_name)..keyword as b on a.keyword_id = b.keyword_id
group by a.work_id

create clustered index idx_tmp_work_keywords_work_id on #work_keywords(work_id)

drop table if exists #work_abstract_legacy
select a.work_id, abstract_legacy = isnull(a.abstract, a.abstract_legacy)
into #work_abstract_legacy
from $(previous_text_db_name)..text_data as a
left join $(relational_db_name)..work_abstract as b on a.work_id = b.work_id
where isnull(a.abstract, a.abstract_legacy) is not null
	and b.work_id is null

create clustered index idx_tmp_work_abstract_legacy_work_id on #work_abstract_legacy(work_id)

drop table if exists text_data
create table text_data
(
	work_id bigint not null,
	title nvarchar(max),
	abstract nvarchar(max),
	keywords nvarchar(max),
	abstract_legacy nvarchar(max)
)

insert into text_data with(tablock)
select a.work_id, b.title, c.abstract, d.keywords, e.abstract_legacy
from $(relational_db_name)..work as a
left join $(relational_db_name)..work_title as b on a.work_id = b.work_id
left join $(relational_db_name)..work_abstract as c on a.work_id = c.work_id
left join #work_keywords as d on a.work_id = d.work_id
left join #work_abstract_legacy as e on a.work_id = e.work_id
where not(b.title is null and c.abstract is null and d.keywords is null and e.abstract_legacy is null)

alter table text_data add constraint pk_text_data primary key(work_id)
