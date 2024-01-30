set nocount on

drop table if exists #citing_micro_cluster_cited_micro_cluster
select citing_micro_cluster_id = b.micro_cluster_id, cited_micro_cluster_id = c.micro_cluster_id, n_cits = count(*)
into #citing_micro_cluster_cited_micro_cluster
from $(relational_db_name)..citation as a
join clustering as b on a.citing_work_id = b.work_id
join clustering as c on a.cited_work_id = c.work_id and b.micro_cluster_id <> c.micro_cluster_id
group by b.micro_cluster_id, c.micro_cluster_id

drop table if exists [vosviewer].network_micro_clusters
select citing_micro_cluster_id, cited_micro_cluster_id, n_cits
into [vosviewer].network_micro_clusters
from #citing_micro_cluster_cited_micro_cluster
order by citing_micro_cluster_id, cited_micro_cluster_id

drop table if exists #micro_cluster_n_works
select micro_cluster_id, n_works = count(*), avg_pub_year = avg(cast(b.pub_year as float))
into #micro_cluster_n_works
from clustering as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
group by micro_cluster_id

drop table if exists #micro_cluster_main_field
select a.micro_cluster_id,
	main_field1 = d.main_field,
	main_field2 = e.main_field,
	main_field3 = f.main_field,
	main_field_description = isnull(d.main_field, '') + isnull('; ' + e.main_field, '') + isnull('; ' + f.main_field, '')
into #micro_cluster_main_field
from micro_cluster_main_field as a
left join micro_cluster_main_field as b on a.micro_cluster_id = b.micro_cluster_id and b.main_field_seq = 2
left join micro_cluster_main_field as c on a.micro_cluster_id = c.micro_cluster_id and c.main_field_seq = 3
left join main_field as d on a.main_field_id = d.main_field_id
left join main_field as e on b.main_field_id = e.main_field_id
left join main_field as f on c.main_field_id = f.main_field_id
where a.main_field_seq = 1

drop table if exists #micro_cluster_source
select a.micro_cluster_id, a.source_seq, a.source_id, b.[source], source_url = 'https://openalex.org/works?filter=primary_location.source.id%3AS' + cast(a.source_id as varchar(100))
into #micro_cluster_source
from micro_cluster_source as a
join $(relational_db_name)..[source] as b on a.source_id = b.source_id
where a.source_seq <= 10

drop table if exists #micro_cluster_source2
select a.micro_cluster_id,
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
into #micro_cluster_source2
from #micro_cluster_source as a
left join #micro_cluster_source as b on a.micro_cluster_id = b.micro_cluster_id and b.source_seq = 2
left join #micro_cluster_source as c on a.micro_cluster_id = c.micro_cluster_id and c.source_seq = 3
left join #micro_cluster_source as d on a.micro_cluster_id = d.micro_cluster_id and d.source_seq = 4
left join #micro_cluster_source as e on a.micro_cluster_id = e.micro_cluster_id and e.source_seq = 5
left join #micro_cluster_source as f on a.micro_cluster_id = f.micro_cluster_id and f.source_seq = 6
left join #micro_cluster_source as g on a.micro_cluster_id = g.micro_cluster_id and g.source_seq = 7
left join #micro_cluster_source as h on a.micro_cluster_id = h.micro_cluster_id and h.source_seq = 8
left join #micro_cluster_source as i on a.micro_cluster_id = i.micro_cluster_id and i.source_seq = 9
left join #micro_cluster_source as j on a.micro_cluster_id = j.micro_cluster_id and j.source_seq = 10
where a.source_seq = 1

drop table if exists #micro_cluster_keyword
select micro_cluster_id, keyword_seq, keyword, keyword_url = 'https://openalex.org/works?filter=default.search%3A%22' + keyword + '%22'
into #micro_cluster_keyword
from micro_cluster_keyword

drop table if exists #micro_cluster_keyword2
select a.micro_cluster_id,
	keyword1 = a.keyword,
	keyword2 = b.keyword,
	keyword3 = c.keyword,
	keyword4 = d.keyword,
	keyword5 = e.keyword,
	keyword6 = f.keyword,
	keyword7 = g.keyword,
	keyword8 = h.keyword,
	keyword9 = i.keyword,
	keyword10 = j.keyword,
	keyword_description1 =
		isnull(a.keyword, '')
		+ isnull('; ' + b.keyword, '')
		+ isnull('; ' + c.keyword, '')
		+ isnull('; ' + d.keyword, '')
		+ isnull('; ' + e.keyword, '')
		+ isnull('; ' + f.keyword, '')
		+ isnull('; ' + g.keyword, '')
		+ isnull('; ' + h.keyword, '')
		+ isnull('; ' + i.keyword, '')
		+ isnull('; ' + j.keyword, ''),
	keyword_description2 =
		isnull('<a href=''' + a.keyword_url + '''>' + a.keyword + '</a>', '')
		+ isnull('; <a href=''' + b.keyword_url + '''>' + b.keyword + '</a>', '')
		+ isnull('; <a href=''' + c.keyword_url + '''>' + c.keyword + '</a>', '')
		+ isnull('; <a href=''' + d.keyword_url + '''>' + d.keyword + '</a>', '')
		+ isnull('; <a href=''' + e.keyword_url + '''>' + e.keyword + '</a>', '')
		+ isnull('; <a href=''' + f.keyword_url + '''>' + f.keyword + '</a>', '')
		+ isnull('; <a href=''' + g.keyword_url + '''>' + g.keyword + '</a>', '')
		+ isnull('; <a href=''' + h.keyword_url + '''>' + h.keyword + '</a>', '')
		+ isnull('; <a href=''' + i.keyword_url + '''>' + i.keyword + '</a>', '')
		+ isnull('; <a href=''' + j.keyword_url + '''>' + j.keyword + '</a>', '')
into #micro_cluster_keyword2
from #micro_cluster_keyword as a
left join #micro_cluster_keyword as b on a.micro_cluster_id = b.micro_cluster_id and b.keyword_seq = 2
left join #micro_cluster_keyword as c on a.micro_cluster_id = c.micro_cluster_id and c.keyword_seq = 3
left join #micro_cluster_keyword as d on a.micro_cluster_id = d.micro_cluster_id and d.keyword_seq = 4
left join #micro_cluster_keyword as e on a.micro_cluster_id = e.micro_cluster_id and e.keyword_seq = 5
left join #micro_cluster_keyword as f on a.micro_cluster_id = f.micro_cluster_id and f.keyword_seq = 6
left join #micro_cluster_keyword as g on a.micro_cluster_id = g.micro_cluster_id and g.keyword_seq = 7
left join #micro_cluster_keyword as h on a.micro_cluster_id = h.micro_cluster_id and h.keyword_seq = 8
left join #micro_cluster_keyword as i on a.micro_cluster_id = i.micro_cluster_id and i.keyword_seq = 9
left join #micro_cluster_keyword as j on a.micro_cluster_id = j.micro_cluster_id and j.keyword_seq = 10
where a.keyword_seq = 1

drop table if exists [vosviewer].map_micro_clusters
select id = a.micro_cluster_id,
	[label] = a.short_label,
	[description] = replace(cast('<table>' as nvarchar(max))
		+ '<tr><td>Full name:</td><td>' + a.long_label + '</td></tr>'
		+ '<tr><td>Main fields:</td><td>' + isnull(d.main_field_description, '-') + '</td></tr>'
		+ '<tr><td>Sources:</td><td>' + isnull(e.source_description2, '-') + '</td></tr>'
		+ '<tr><td>Keywords:</td><td>' + isnull(f.keyword_description2, '-') + '</td></tr>'
		+ '<tr><td>Summary:</td><td>' + isnull(a.summary, '-') + '</td></tr>'
		+ '<tr><td>Wikipedia:</td><td>' + isnull('<a href=''' + a.wikipedia_url + '''>' + a.wikipedia_url + '</a>', '-') + '</td></tr>'
		+ '</table>', '"', ''),
	x = cast(0 as float),
	y = cast(0 as float),
	cluster = c.main_field_id,
	[weight<Links>] = cast(0 as int),
	[weight<Total link strength>] = cast(0 as int),
	[weight<No. of pub. ($(classification_min_pub_year_core_pub_set)-$(classification_max_pub_year_core_pub_set))>] = b.n_works,
	[score<Avg. pub. year>] = b.avg_pub_year
into [vosviewer].map_micro_clusters
from micro_cluster as a
join #micro_cluster_n_works as b on a.micro_cluster_id = b.micro_cluster_id
left join micro_cluster_main_field as c on a.micro_cluster_id = c.micro_cluster_id and c.is_primary_main_field = 1
left join #micro_cluster_main_field as d on a.micro_cluster_id = d.micro_cluster_id
left join #micro_cluster_source2 as e on a.micro_cluster_id = e.micro_cluster_id
left join #micro_cluster_keyword2 as f on a.micro_cluster_id = f.micro_cluster_id
order by id

drop table if exists excel.micro_clusters
select [Micro cluster ID] = a.micro_cluster_id,
	[Micro cluster number] = a.micro_cluster_no,
	[Short label] = a.short_label,
	[Long label] = a.long_label,
	[Main fields] = c.main_field_description,
	[Sources] = d.source_description1,
	[Keywords] = a.keywords,
	[Summary] = a.summary,
	[Wikipedia] = a.wikipedia_url,
	[No. of pub. ($(classification_min_pub_year_core_pub_set)-$(classification_max_pub_year_core_pub_set))] = b.n_works,
	[Avg. pub. year] = b.avg_pub_year
into excel.micro_clusters
from micro_cluster as a
join #micro_cluster_n_works as b on a.micro_cluster_id = b.micro_cluster_id
left join #micro_cluster_main_field as c on a.micro_cluster_id = c.micro_cluster_id
left join #micro_cluster_source2 as d on a.micro_cluster_id = d.micro_cluster_id
left join #micro_cluster_keyword2 as e on a.micro_cluster_id = e.micro_cluster_id
order by a.micro_cluster_id
