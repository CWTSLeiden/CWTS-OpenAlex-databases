set nocount on

drop table if exists pub_classification_system_research_area
create table pub_classification_system_research_area
(
	work_id bigint not null,
	classification_system_no tinyint not null,
	research_area_no smallint not null,
	[weight] float not null
)

drop table if exists #pub_with_cluster
select a.work_id, b.micro_cluster_id, b.meso_cluster_id, b.macro_cluster_id
into #pub_with_cluster
from pub as a
join $(classification_db_name)..clustering as b on a.work_id = b.work_id


-- Identify publication not included in the classification.

drop table if exists #pub_without_cluster
select a.work_id, a.source_id
into #pub_without_cluster
from pub as a
left join #pub_with_cluster as b on a.work_id = b.work_id
where a.pub_year >= $(indicators_min_pub_year)
	and a.doc_type_no <> 1
	and b.work_id is null


-- Assign publications not included in the classification to one of the meso clusters (based on references or source).

drop table if exists  #pub_cluster_based_on_refs
select work_id, cluster_id
into #pub_cluster_based_on_refs
from
(
	select work_id, cluster_id, [rank] = row_number() over (partition by work_id order by n_refs desc, cluster_id desc)
	from
	(
		select a.work_id, cluster_id = c.meso_cluster_id, n_refs = count(*)
		from #pub_without_cluster as a
		join $(relational_db_name)..citation as b on a.work_id = b.citing_work_id
		join $(classification_db_name)..clustering as c on b.cited_work_id = c.work_id
		group by a.work_id, c.meso_cluster_id
	) as a
) as a
where [rank] = 1

drop table if exists #source_cluster
select a.source_id, a.cluster_id
into #source_cluster
from
(
	select source_id, cluster_id, [rank] = row_number() over (partition by source_id order by n_works desc, cluster_id)
	from
	(
		select b.source_id, cluster_id = a.meso_cluster_id, n_works = count(*)
		from #pub_with_cluster as a
		join pub as b on a.work_id = b.work_id
		where source_id is not null
		group by b.source_id, a.meso_cluster_id
	) as a
) as a
where a.[rank] = 1

drop table if exists #pub_cluster_based_on_source
select a.work_id, c.cluster_id
into #pub_cluster_based_on_source
from #pub_without_cluster as a
left join #pub_cluster_based_on_refs as b on a.work_id = b.work_id
join #source_cluster as c on a.source_id = c.source_id
where b.work_id is null


-- Add the classification of publications to meso clusters.

insert pub_classification_system_research_area with(tablock)
select b.work_id, classification_system_no = 1, cluster_id, [weight] = 1
from
(
	select work_id, cluster_id = meso_cluster_id
	from #pub_with_cluster
	union
	select work_id, cluster_id
	from #pub_cluster_based_on_refs
	union
	select work_id, cluster_id
	from #pub_cluster_based_on_source
) as a
join pub as b on a.work_id = b.work_id
go


-- Assign publications not included in the classification to one of the micro clusters (based on references or source).

drop table if exists #pub_cluster_based_on_refs
select work_id, cluster_id
into #pub_cluster_based_on_refs
from
(
	select work_id, cluster_id, [rank] = row_number() over (partition by work_id order by n_refs desc, cluster_id desc)
	from
	(
		select a.work_id, cluster_id = c.micro_cluster_id, n_refs = count(*)
		from #pub_without_cluster as a
		join $(relational_db_name)..citation as b on a.work_id = b.citing_work_id
		join $(classification_db_name)..clustering as c on b.cited_work_id = c.work_id
		group by a.work_id, c.micro_cluster_id
	) as a
) as a
where [rank] = 1

drop table if exists #source_cluster
select a.source_id, a.cluster_id
into #source_cluster
from
(
	select source_id, cluster_id, [rank] = row_number() over (partition by source_id order by n_works desc, cluster_id)
	from
	(
		select b.source_id, cluster_id = a.micro_cluster_id, n_works = count(*)
		from #pub_with_cluster as a
		join pub as b on a.work_id = b.work_id
		where source_id is not null
		group by b.source_id, a.micro_cluster_id
	) as a
) as a
where a.[rank] = 1

drop table if exists #pub_cluster_based_on_source
select a.work_id, c.cluster_id
into #pub_cluster_based_on_source
from #pub_without_cluster as a
left join #pub_cluster_based_on_refs as b on a.work_id = b.work_id
join #source_cluster as c on a.source_id = c.source_id
where b.work_id is null


-- Add the classification of publications to micro clusters.

insert pub_classification_system_research_area with(tablock)
select b.work_id, classification_system_no = 2, cluster_id, [weight] = 1
from
(
	select work_id, cluster_id = micro_cluster_id
	from #pub_with_cluster
	union
	select work_id, cluster_id
	from #pub_cluster_based_on_refs
	union
	select work_id, cluster_id
	from #pub_cluster_based_on_source
) as a
join pub as b on a.work_id = b.work_id
go


alter table pub_classification_system_research_area add constraint pk_pub_classification_system_research_area primary key(work_id, classification_system_no, research_area_no)
