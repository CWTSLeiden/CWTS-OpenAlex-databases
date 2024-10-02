set nocount on

-- Count references.
drop table if exists #work_n_refs
select work_id = work_id,
	n_refs = count(*)
into #work_n_refs
from work_reference
group by work_id

alter table #work_n_refs add constraint pk_tmp_work_n_refs primary key(work_id)

-- Update reference count in work table.
update a with(tablock)
set a.n_refs = b.n_refs
from work as a
join #work_n_refs as b on a.work_id = b.work_id
