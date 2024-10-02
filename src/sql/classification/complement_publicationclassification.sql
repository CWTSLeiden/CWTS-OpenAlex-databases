set nocount on

drop table if exists #pub_without_cluster
select a.pub_no, a.work_id
into #pub_without_cluster
from [classification].pub as a
left join [classification].pub_cluster as b on a.pub_no = b.pub_no
where b.pub_no is null

drop table if exists  #pub_cluster_based_on_refs
select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no
into #pub_cluster_based_on_refs
from
(
	select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no, [rank] = row_number() over (partition by pub_no order by n_refs desc, micro_cluster_no desc)
	from
	(
		select a.pub_no, d.micro_cluster_no, d.meso_cluster_no, d.macro_cluster_no, n_refs = count(*)
		from #pub_without_cluster as a
		join $(relational_db_name)..citation as b on a.work_id = b.citing_work_id
		join [classification].pub as c on b.cited_work_id = c.work_id
		join [classification].pub_cluster as d on c.pub_no = d.pub_no
		group by a.pub_no, d.micro_cluster_no, d.meso_cluster_no, d.macro_cluster_no
	) as a
) as a
where [rank] = 1

drop table if exists #pub_without_cluster2
select a.pub_no, a.work_id
into #pub_without_cluster2
from #pub_without_cluster as a
left join #pub_cluster_based_on_refs as b on a.pub_no = b.pub_no
where b.pub_no is null

drop table if exists  #pub_cluster_based_on_cits
select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no
into #pub_cluster_based_on_cits
from
(
	select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no, [rank] = row_number() over (partition by pub_no order by n_cits desc, micro_cluster_no desc)
	from
	(
		select a.pub_no, d.micro_cluster_no, d.meso_cluster_no, d.macro_cluster_no, n_cits = count(*)
		from #pub_without_cluster2 as a
		join $(relational_db_name)..citation as b on a.work_id = b.cited_work_id
		join [classification].pub as c on b.citing_work_id = c.work_id
		join [classification].pub_cluster as d on c.pub_no = d.pub_no
		group by a.pub_no, d.micro_cluster_no, d.meso_cluster_no, d.macro_cluster_no
	) as a
) as a
where [rank] = 1

drop table if exists #pub_cluster
select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no
into #pub_cluster
from
(
	select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no
	from #pub_cluster_based_on_refs
	union
	select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no
	from #pub_cluster_based_on_cits
) as a

insert into [classification].pub_cluster with(tablock)
select pub_no, micro_cluster_no, meso_cluster_no, macro_cluster_no
from #pub_cluster
