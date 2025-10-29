set nocount on

-- Old pubs.
drop table if exists #pub_old1
select a.*, b.micro_cluster_no
into #pub_old1
from [classification].pub as a
join [classification].pub_cluster as b on a.pub_no = b.pub_no

-- Remove from old pubs those pubs switched from the extended set to focal set.
delete from a
from #pub_old1 as a
join
(
	select a.work_id
	from #pub_old1 as a
	join [classification].pub as b on a.work_id = b.work_id
	where a.core_pub = 0
		and b.core_pub = 1
) as b on a.work_id = b.work_id

-- New pubs and pubs switched from extended set to focal set.
drop table if exists #pub_new1
select a.*
into #pub_new1
from [classification].pub as a
left join #pub_old1 as b on a.pub_no = b.pub_no
where b.pub_no is null

-- Citation links of new pubs.
drop table if exists #cit_link_new
select a.*
into #cit_link_new
from [classification].cit_link as a
join #pub_new1 as b on a.pub_no1 = b.pub_no

-- New pubs with citation links to old pubs.
drop table if exists #pub_new2
select distinct b.*
into #pub_new2
from #cit_link_new as a
join #pub_new1 as b on a.pub_no1 = b.pub_no
join #pub_old1 as c on a.pub_no2 = c.pub_no

-- New pubs with citation links to other new pubs with citation links to old pubs.
insert into #pub_new2 with(tablock)
select distinct b.*
from #cit_link_new as a
join #pub_new1 as b on a.pub_no1 = b.pub_no
join #pub_new2 as c on a.pub_no2 = c.pub_no
except
select *
from #pub_new2

-- Old pubs with citation links to new pubs.
drop table if exists #pub_old2
select distinct c.*
into #pub_old2
from #cit_link_new as a
join #pub_new2 as b on a.pub_no1 = b.pub_no
join #pub_old1 as c on a.pub_no2 = c.pub_no

-- Pubs for complementing classification.
drop table if exists #pub_final
select *, pub_no_new = row_number() over (order by work_id) - 1
into #pub_final
from
(
	select work_id, n_refs_covered, core_pub, pub_no, micro_cluster_no
	from #pub_old2
	union
	select work_id, n_refs_covered, core_pub, pub_no, micro_cluster_no = null
	from #pub_new2
) as a

-- Citation network for complementing classification (including links between new and old pubs and links betweem new pubs).
drop table if exists #cit_link_final
select pub_no1 = b.pub_no_new, pub_no2 = c.pub_no_new, a.cit_weight
into #cit_link_final
from #cit_link_new as a
join #pub_final as b on a.pub_no1 = b.pub_no and b.micro_cluster_no is null
join #pub_final as c on a.pub_no2 = c.pub_no and c.micro_cluster_no is not null
union all
select pub_no1 = b.pub_no_new, pub_no2 = c.pub_no_new, a.cit_weight
from #cit_link_new as a
join #pub_final as b on a.pub_no1 = b.pub_no and b.micro_cluster_no is null
join #pub_final as c on a.pub_no2 = c.pub_no and c.micro_cluster_no is null

drop table if exists [classification].pub_complement
select work_id, n_refs_covered, core_pub, pub_no = pub_no_new, micro_cluster_no
into [classification].pub_complement
from #pub_final

drop table if exists [classification].cit_link_complement
select
	pub_no1 = case when pub_no1 < pub_no2 then pub_no1 else pub_no2 end,
	pub_no2 = case when pub_no1 < pub_no2 then pub_no2 else pub_no1 end,
	cit_weight
into [classification].cit_link_complement
from #cit_link_final
