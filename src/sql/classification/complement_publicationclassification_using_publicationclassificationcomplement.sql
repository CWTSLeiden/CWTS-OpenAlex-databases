set nocount on

drop table if exists #cluster_hierarchy
select distinct micro_cluster_no, meso_cluster_no, macro_cluster_no
into #cluster_hierarchy
from [classification].pub_cluster

insert into [classification].pub_cluster with(tablock)
select b.pub_no, c.micro_cluster_no, c.meso_cluster_no, c.macro_cluster_no
from
(
	select a.work_id, micro_cluster_no = b.new_micro_cluster_no
	from [classification].pub_complement as a
	join [classification].pub_cluster_complement as b on a.pub_no = b.pub_no
	where a.micro_cluster_no is null
) as a
join [classification].pub as b on a.work_id = b.work_id
join #cluster_hierarchy as c on a.micro_cluster_no = c.micro_cluster_no
