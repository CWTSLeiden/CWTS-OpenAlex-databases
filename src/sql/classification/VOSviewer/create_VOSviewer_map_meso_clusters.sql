set nocount on

drop table if exists #citing_meso_cluster_cited_meso_cluster
select citing_meso_cluster_id = b.meso_cluster_id, cited_meso_cluster_id = c.meso_cluster_id, n_cits = count(*)
into #citing_meso_cluster_cited_meso_cluster
from $(relational_db_name)..citation as a
join clustering as b on a.citing_work_id = b.work_id
join clustering as c on a.cited_work_id = c.work_id and b.meso_cluster_id <> c.meso_cluster_id
group by b.meso_cluster_id, c.meso_cluster_id

drop table if exists [vosviewer].network_meso_clusters
select citing_meso_cluster_id, cited_meso_cluster_id, n_cits
into [vosviewer].network_meso_clusters
from #citing_meso_cluster_cited_meso_cluster
order by citing_meso_cluster_id, cited_meso_cluster_id

drop table if exists #meso_cluster_n_works
select meso_cluster_id, n_works = count(*), avg_pub_year = avg(cast(b.pub_year as float))
into #meso_cluster_n_works
from clustering as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
group by meso_cluster_id

drop table if exists #meso_cluster_main_field
select a.meso_cluster_id,
	main_field1 = d.main_field,
	main_field2 = e.main_field,
	main_field3 = f.main_field,
	main_field_description = isnull(d.main_field, '') + isnull('; ' + e.main_field, '') + isnull('; ' + f.main_field, '')
into #meso_cluster_main_field
from meso_cluster_main_field as a
left join meso_cluster_main_field as b on a.meso_cluster_id = b.meso_cluster_id and b.main_field_seq = 2
left join meso_cluster_main_field as c on a.meso_cluster_id = c.meso_cluster_id and c.main_field_seq = 3
left join main_field as d on a.main_field_id = d.main_field_id
left join main_field as e on b.main_field_id = e.main_field_id
left join main_field as f on c.main_field_id = f.main_field_id
where a.main_field_seq = 1

drop table if exists #meso_cluster_source
select a.meso_cluster_id, a.source_seq, a.source_id, b.[source], source_url = 'https://openalex.org/works?filter=primary_location.source.id%3AS' + cast(a.source_id as varchar(100))
into #meso_cluster_source
from meso_cluster_source as a
join $(relational_db_name)..[source] as b on a.source_id = b.source_id
where a.source_seq <= 10

drop table if exists #meso_cluster_source2
select a.meso_cluster_id,
	source1 = a.[source],
	source2 = b.[source],
	source3 = c.[source],
	source4 = d.[source],
	source5 = e.[source],
	source6 = f.[source],
	source7 = g.[source],
	source8 = h.[source],
	source9 = i.[source],
	source10 = j.[source],
	source_description1 =
		isnull(a.[source], '')
		+ isnull('; ' + b.[source], '')
		+ isnull('; ' + c.[source], '')
		+ isnull('; ' + d.[source], '')
		+ isnull('; ' + e.[source], ''),
	source_description2 =
		isnull('<a href=''' + a.source_url + '''>' + a.[source] + '</a>', '')
		+ isnull('; <a href=''' + b.source_url + '''>' + b.[source] + '</a>', '')
		+ isnull('; <a href=''' + c.source_url + '''>' + c.[source] + '</a>', '')
		+ isnull('; <a href=''' + d.source_url + '''>' + d.[source] + '</a>', '')
		+ isnull('; <a href=''' + e.source_url + '''>' + e.[source] + '</a>', '')
into #meso_cluster_source2
from #meso_cluster_source as a
left join #meso_cluster_source as b on a.meso_cluster_id = b.meso_cluster_id and b.source_seq = 2
left join #meso_cluster_source as c on a.meso_cluster_id = c.meso_cluster_id and c.source_seq = 3
left join #meso_cluster_source as d on a.meso_cluster_id = d.meso_cluster_id and d.source_seq = 4
left join #meso_cluster_source as e on a.meso_cluster_id = e.meso_cluster_id and e.source_seq = 5
left join #meso_cluster_source as f on a.meso_cluster_id = f.meso_cluster_id and f.source_seq = 6
left join #meso_cluster_source as g on a.meso_cluster_id = g.meso_cluster_id and g.source_seq = 7
left join #meso_cluster_source as h on a.meso_cluster_id = h.meso_cluster_id and h.source_seq = 8
left join #meso_cluster_source as i on a.meso_cluster_id = i.meso_cluster_id and i.source_seq = 9
left join #meso_cluster_source as j on a.meso_cluster_id = j.meso_cluster_id and j.source_seq = 10
where a.source_seq = 1

drop table if exists [vosviewer].map_meso_clusters
select id = a.meso_cluster_id,
	[label] = a.meso_cluster_id,
	[description] = replace(cast('<table>' as nvarchar(max))
		+ '<tr><td>Main fields:</td><td>' + isnull(d.main_field_description, '-') + '</td></tr>'
		+ '<tr><td>Sources:</td><td>' + isnull(e.source_description2, '-') + '</td></tr>'
		+ '</table>', '"', ''),
	x = cast(0 as float),
	y = cast(0 as float),
	cluster = c.main_field_id,
	[weight<Links>] = cast(0 as int),
	[weight<Total link strength>] = cast(0 as int),
	[weight<No. of pub. ($(classification_min_pub_year_core_pub_set)-$(classification_max_pub_year_core_pub_set))>] = b.n_works,
	[score<Avg. pub. year>] = b.avg_pub_year
into [vosviewer].map_meso_clusters
from meso_cluster as a
join #meso_cluster_n_works as b on a.meso_cluster_id = b.meso_cluster_id
left join meso_cluster_main_field as c on a.meso_cluster_id = c.meso_cluster_id and c.is_primary_main_field = 1
left join #meso_cluster_main_field as d on a.meso_cluster_id = d.meso_cluster_id
left join #meso_cluster_source2 as e on a.meso_cluster_id = e.meso_cluster_id
order by id

drop table if exists excel.meso_clusters
select [Meso cluster ID] = a.meso_cluster_id,
	[Meso cluster number] = a.meso_cluster_no,
	[Main fields] = c.main_field_description,
	[Sources] = d.source_description1,
	[No. of pub. ($(classification_min_pub_year_core_pub_set)-$(classification_max_pub_year_core_pub_set))] = b.n_works,
	[Avg. pub. year] = b.avg_pub_year
into excel.meso_clusters
from meso_cluster as a
join #meso_cluster_n_works as b on a.meso_cluster_id = b.meso_cluster_id
left join #meso_cluster_main_field as c on a.meso_cluster_id = c.meso_cluster_id
left join #meso_cluster_source2 as d on a.meso_cluster_id = d.meso_cluster_id
order by a.meso_cluster_id
