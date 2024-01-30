set nocount on

declare @min_pub_year_extended_pub_set int = $(classification_min_pub_year_extended_pub_set)
declare @max_pub_year_extended_pub_set int = $(classification_max_pub_year_extended_pub_set)
declare @min_pub_year_core_pub_set int = $(classification_min_pub_year_core_pub_set)
declare @max_pub_year_core_pub_set int = $(classification_max_pub_year_core_pub_set)

drop table if exists #pub
select a.work_id,
	pub_no = row_number() over (order by a.work_id) - 1,
	core_pub = cast(case when a.pub_year between @min_pub_year_core_pub_set and @max_pub_year_core_pub_set and a.work_type_id in (26, 2) then 1 else 0 end as bit) 
		-- 26: article, 2: book-chapter
into #pub
from $(relational_db_name)..work as a
where a.pub_year between @min_pub_year_extended_pub_set and @max_pub_year_extended_pub_set

create unique index idx_tmp_pub on #pub(work_id)

drop table if exists #pub_n_refs_covered
select b.work_id, b.pub_no, n_refs_covered = count(*)
into #pub_n_refs_covered
from $(relational_db_name)..citation as a
join #pub as b on a.citing_work_id = b.work_id
join #pub as c on a.cited_work_id = c.work_id
where a.citing_work_id <> a.cited_work_id
group by b.work_id, b.pub_no

create unique index idx_tmp_pub_n_refs_covered_pub_id on #pub_n_refs_covered(work_id)

drop table if exists #cit
select pub_no1 = b.pub_no,
	pub_no2 = c.pub_no,
	cit_weight = cast(1 as float) / b.n_refs_covered
into #cit
from $(relational_db_name)..citation as a
join #pub_n_refs_covered as b on a.citing_work_id = b.work_id
join #pub as c on a.cited_work_id = c.work_id
where a.citing_work_id <> a.cited_work_id

drop table if exists [classification].pub
select a.work_id,
	n_refs_covered = isnull(b.n_refs_covered, 0),
	a.core_pub,
	a.pub_no
into [classification].pub
from #pub as a
left join #pub_n_refs_covered as b on a.work_id = b.work_id

drop table if exists [classification].cit_link
select pub_no1, pub_no2, cit_weight = sum(cit_weight)
into [classification].cit_link
from
(
	select pub_no1, pub_no2, cit_weight
	from #cit
	union all
	select pub_no2, pub_no1, cit_weight
	from #cit
) as a
group by pub_no1, pub_no2
