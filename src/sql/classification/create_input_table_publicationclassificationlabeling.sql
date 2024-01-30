set nocount on

drop table if exists #cluster_title
select
	cluster_no = a.micro_cluster_no,
	title_seq = row_number() over (partition by a.micro_cluster_no order by c.n_cits desc, c.pub_year desc, c.work_id),
	c.title
into #cluster_title
from [classification].pub_cluster as a
join [classification].pub as b on a.pub_no = b.pub_no
join $(relational_db_name)..work_detail as c on b.work_id = c.work_id
where b.core_pub = 1
	and c.title is not null

declare @n_work_titles_per_cluster int = $(classification_n_pub_titles_per_cluster)

drop table if exists #cluster_title2
select cluster_no, title_seq, title
into #cluster_title2
from #cluster_title
where title_seq <= @n_work_titles_per_cluster
order by cluster_no, title_seq

drop table if exists [classification].cluster_pub_titles
select cluster_no, pub_titles = string_agg(cast(title as nvarchar(max)), ' | ') within group (order by title_seq)
into [classification].cluster_pub_titles
from #cluster_title2
group by cluster_no
