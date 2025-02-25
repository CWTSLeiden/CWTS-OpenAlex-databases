set nocount on

drop table if exists #source_n_works
select b.source_id, n_works = count(*), n_core_works = sum(case when a.is_core_work = 1 then 1 else 0 end)
into #source_n_works
from work as a
join openalex_2024aug..work as b on a.work_id = b.work_id
where a.is_core_work is not null
group by b.source_id

select
	source_id = a.source_id, 
	source = b.[source],
	source_type = c.source_type,
	issn_l = b.issn_l,
	is_core_source = cast(a.is_core_source as varchar(10)),
	n_works = d.n_works,
	n_core_works = d.n_core_works
from [source] as a
join openalex_2024aug..[source] as b on a.source_id = b.source_id
left join openalex_2024aug..source_type as c on b.source_type_id = c.source_type_id
join #source_n_works as d on a.source_id = d.source_id
where a.is_core_source is not null
order by 1
