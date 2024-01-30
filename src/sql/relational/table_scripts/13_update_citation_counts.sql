set nocount on

-- Count citations.
drop table if exists #work_n_cits
select work_id = cited_work_id, 
	n_cits = count(*),
	n_self_cits = sum(case when is_self_cit = 1 then 1 else 0 end)
into #work_n_cits
from citation
group by cited_work_id

alter table #work_n_cits add constraint pk_tmp_work_n_cits primary key(work_id)

-- Update citation count in work table.
update a with(tablock)
set a.n_cits = b.n_cits
from work as a
join #work_n_cits as b on a.work_id = b.work_id

-- Update citation counts in work_detail table.
update a with(tablock)
set a.n_cits = b.n_cits,
	a.n_self_cits = b.n_self_cits
from work_detail as a
join #work_n_cits as b on a.work_id = b.work_id
