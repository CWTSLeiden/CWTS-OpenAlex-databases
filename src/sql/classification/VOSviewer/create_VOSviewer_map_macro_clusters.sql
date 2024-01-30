set nocount on

drop table if exists #citing_macro_cluster_cited_macro_cluster
select citing_macro_cluster_id = b.macro_cluster_id, cited_macro_cluster_id = c.macro_cluster_id, n_cits = count(*)
into #citing_macro_cluster_cited_macro_cluster
from $(relational_db_name)..citation as a
join clustering as b on a.citing_work_id = b.work_id
join clustering as c on a.cited_work_id = c.work_id and b.macro_cluster_id <> c.macro_cluster_id
group by b.macro_cluster_id, c.macro_cluster_id

drop table if exists [vosviewer].network_macro_clusters
select citing_macro_cluster_id, cited_macro_cluster_id, n_cits
into [vosviewer].network_macro_clusters
from #citing_macro_cluster_cited_macro_cluster
order by citing_macro_cluster_id, cited_macro_cluster_id

drop table if exists #macro_cluster_n_works
select macro_cluster_id, n_works = count(*), avg_pub_year = avg(cast(b.pub_year as float))
into #macro_cluster_n_works
from clustering as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
group by macro_cluster_id

drop table if exists #macro_cluster_main_field
select a.macro_cluster_id,
	main_field1 = d.main_field,
	main_field2 = e.main_field,
	main_field3 = f.main_field,
	main_field_description = isnull(d.main_field, '') + isnull('; ' + e.main_field, '') + isnull('; ' + f.main_field, '')
into #macro_cluster_main_field
from macro_cluster_main_field as a
left join macro_cluster_main_field as b on a.macro_cluster_id = b.macro_cluster_id and b.main_field_seq = 2
left join macro_cluster_main_field as c on a.macro_cluster_id = c.macro_cluster_id and c.main_field_seq = 3
left join main_field as d on a.main_field_id = d.main_field_id
left join main_field as e on b.main_field_id = e.main_field_id
left join main_field as f on c.main_field_id = f.main_field_id
where a.main_field_seq = 1

drop table if exists [vosviewer].map_macro_clusters
select id = a.macro_cluster_id,
	[label] = a.macro_cluster_id,
	[description] = replace(cast('<table>' as nvarchar(max))
		+ '<tr><td>Main fields:</td><td>' + isnull(d.main_field_description, '-') + '</td></tr>'
		+ '</table>', '"', ''),
	x = cast(0 as float),
	y = cast(0 as float),
	cluster = c.main_field_id,
	[weight<Links>] = cast(0 as int),
	[weight<Total link strength>] = cast(0 as int),
	[weight<No. of pub. ($(classification_min_pub_year_core_pub_set)-$(classification_max_pub_year_core_pub_set))>] = b.n_works,
	[score<Avg. pub. year>] = b.avg_pub_year
into [vosviewer].map_macro_clusters
from macro_cluster as a
join #macro_cluster_n_works as b on a.macro_cluster_id = b.macro_cluster_id
left join macro_cluster_main_field as c on a.macro_cluster_id = c.macro_cluster_id and c.is_primary_main_field = 1
left join #macro_cluster_main_field as d on a.macro_cluster_id = d.macro_cluster_id
order by id

drop table if exists excel.macro_clusters
select [Macro cluster ID] = a.macro_cluster_id,
	[Macro cluster number] = a.macro_cluster_no,
	[Main fields] = c.main_field_description,
	[No. of pub. ($(classification_min_pub_year_core_pub_set)-$(classification_max_pub_year_core_pub_set))] = b.n_works,
	[Avg. pub. year] = b.avg_pub_year
into excel.macro_clusters
from macro_cluster as a
join #macro_cluster_n_works as b on a.macro_cluster_id = b.macro_cluster_id
left join #macro_cluster_main_field as c on a.macro_cluster_id = c.macro_cluster_id
order by a.macro_cluster_id
