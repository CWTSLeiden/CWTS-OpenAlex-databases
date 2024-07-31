set nocount on

drop table if exists #work_n_authors
select work_id, n_authors = count(*)
into #work_n_authors
from $(relational_db_name)..work_author
group by work_id

create index idx_tmp_work_n_authors_work_id on #work_n_authors(work_id)


drop table if exists #work_n_author_raw_affiliation_strings
select work_id, n_author_raw_affiliation_strings = count(*)
into #work_n_author_raw_affiliation_strings
from $(relational_db_name)..work_author_raw_affiliation_string
group by work_id

create index idx_tmp_work_n_author_raw_affiliation_strings_work_id on #work_n_author_raw_affiliation_strings(work_id)


drop table if exists #work_country
select work_id, country_code = country_iso_alpha2_code
into #work_country
from $(relational_db_name)..work_institution as a
join $(relational_db_name)..institution as b on a.institution_id = b.institution_id
where b.country_iso_alpha2_code is not null
union
select work_id, country_iso_alpha2_code
from $(relational_db_name)..work_author_country
where country_iso_alpha2_code is not null

drop table if exists #work_n_countries
select work_id, n_countries = count(distinct country_code)
into #work_n_countries
from #work_country
group by work_id

create index idx_tmp_work_n_countries_work_id on #work_n_countries(work_id)


drop table if exists #work
select a.work_id,
	a.work_type_id,
	a.source_id,
	b.source_type_id,
	a.pub_year,
	a.language_iso2_code,
	n_authors = isnull(c.n_authors, 0),
	n_author_raw_affiliation_strings = isnull(d.n_author_raw_affiliation_strings, 0),
	n_countries = isnull(e.n_countries, 0),
	a.n_refs,
	a.n_cits,
	a.doi
into #work
from $(relational_db_name)..work as a
left join $(relational_db_name)..[source] as b on a.source_id = b.source_id
left join #work_n_authors as c on a.work_id = c.work_id
left join #work_n_author_raw_affiliation_strings as d on a.work_id = d.work_id
left join #work_n_countries as e on a.work_id = e.work_id
where a.pub_year >= ($(core_min_pub_year_core_pubs) - 5)



-- Start identification of core publications.

-- Step 1: Exclude works that do not have an article/review work type and a journal source type, a book chapter/article/review work type and a book series source type.

drop table if exists #work_step1
select a.*
into #work_step1
from #work as a
join $(relational_db_name)..work_type as b on a.work_type_id = b.work_type_id
join $(relational_db_name)..source_type as c on a.source_type_id = c.source_type_id
where
	(
		b.work_type in ('article', 'review')
			and c.source_type = 'journal'
	)
	or
	(
		b.work_type in ('book-chapter', 'article', 'review')
			and c.source_type = 'book series'
	)


-- Step 2: Exclude works that are not in English.

drop table if exists #work_step2
select *
into #work_step2
from #work_step1
where language_iso2_code = 'en'


-- Step 3: Exclude works that do not have any authors.

drop table if exists #work_step3
select *
into #work_step3
from #work_step2
where n_authors > 0


-- Step 4: Exclude works that do not have any affiliations.

drop table if exists #work_step4
select *
into #work_step4
from #work_step3
where n_author_raw_affiliation_strings > 0


-- Step 5: Exclude works that do not have any references.

drop table if exists #work_step5
select *
into #work_step5
from #work_step4
where n_refs > 0


-- Step 6: Exclude sources that do not have a sufficiently international focus.

drop table if exists #work_country2
select b.*, [weight] = cast(1 as float) / c.n_countries
into #work_country2
from #work_step5 as a
join #work_country as b on a.work_id = b.work_id
join
(
	select work_id, n_countries = count(*)
	from #work_country
	group by work_id
) as c on a.work_id = c.work_id

drop table if exists #source_country1
select a.source_id, a.country_code, [weight] = sum(a.[weight])
into #source_country1
from
(
	select a.source_id, b.country_code, b.[weight]
	from #work_step5 as a
	join #work_country2 as b on a.work_id = b.work_id
	union all
	select a.source_id, c.country_code, c.[weight]
	from #work_step5 as a
	join $(relational_db_name)..citation as b on a.work_id = b.cited_work_id
	join #work_country2 as c on b.citing_work_id = c.work_id
	where b.is_self_cit = 0
) as a
group by a.source_id, a.country_code

drop table if exists #source_country2
select a.source_id, a.country_code, [weight] = a.[weight] / b.total_weight
into #source_country2
from #source_country1 as a
join
(
	select source_id, total_weight = sum([weight])
	from #source_country1
	group by source_id
) as b on a.source_id = b.source_id

drop table if exists #country1
select country_code, [weight] = sum([weight])
into #country1
from #source_country1
group by country_code

drop table if exists #country2
select a.country_code, [weight] = a.[weight] / b.total_weight
into #country2
from #country1 as a
cross join
(
	select total_weight = sum([weight])
	from #country1
) as b

drop table if exists #source_KL_distance
select a.source_id, KL_distance = sum(a.[weight] * log(a.[weight] / b.[weight]))
into #source_KL_distance
from #source_country2 as a
join #country2 as b on a.country_code = b.country_code
group by a.source_id

drop table if exists #KL_distance_threshold
select KL_distance_threshold = log(1.0 / max([weight]))
into #KL_distance_threshold
from #country2

drop table if exists #source_step6
select a.source_id
into #source_step6
from #source_KL_distance as a
join #KL_distance_threshold as b on a.KL_distance < b.KL_distance_threshold

drop table if exists #work_step6
select a.*
into #work_step6
from #work_step5 as a
join #source_step6 as b on a.source_id = b.source_id


-- Step 7: Exclude sources that do not have a sufficiently large proportion of publications with active references. Also exclude publications from the first five years.

drop table if exists #cit
select distinct b.citing_work_id, citing_source_id = a.source_id, cited_source_id = c.source_id
into #cit
from #work_step6 as a
join $(relational_db_name)..citation as b on a.work_id = b.citing_work_id
join #work_step6 as c on b.cited_work_id = c.work_id
where a.pub_year >= $(core_min_pub_year_core_pubs)
	and b.cit_window between 0 and 5
	and b.is_self_cit = 0

drop table if exists #source_n_works
select source_id, n_works = count(*)
into #source_n_works
from #work_step6
where pub_year >= $(core_min_pub_year_core_pubs)
group by source_id
having count(*) >= 1

drop table if exists #sel_source
select source_id
into #sel_source
from #source_n_works

declare @n_sel_sources int = (select count(*) from #sel_source)
declare @n_sel_sources_old int = @n_sel_sources + 1
while @n_sel_sources < @n_sel_sources_old
begin
	drop table if exists #source_n_works_with_refs
	select a.source_id, n_works_with_refs = count(distinct b.citing_work_id)
	into #source_n_works_with_refs
	from #sel_source as a
	join #cit as b on a.source_id = b.citing_source_id
	join #sel_source as c on b.cited_source_id = c.source_id
	group by a.source_id

	truncate table #sel_source
	insert #sel_source
	select a.source_id
	from #source_n_works as a
	join #source_n_works_with_refs as b on a.source_id = b.source_id
		and 0.4 * a.n_works <= b.n_works_with_refs

	set @n_sel_sources_old = @n_sel_sources
	set @n_sel_sources = (select count(*) from #sel_source)
end

drop table if exists #source_p_works_with_active_refs
select a.source_id, p_works_with_active_refs = cast(b.n_works_with_refs as float) / a.n_works
into #source_p_works_with_active_refs
from #source_n_works as a
join #source_n_works_with_refs as b on a.source_id = b.source_id

drop table if exists #source_step7
select source_id
into #source_step7
from #sel_source

drop table if exists #work_step7
select a.*
into #work_step7
from #work_step6 as a
join #source_step7 as b on a.source_id = b.source_id
where a.pub_year >= $(core_min_pub_year_core_pubs)

-- End identification of core publications.


drop table if exists work
create table work
(
	work_id bigint not null,
	is_core_work bit null
)

insert into work with(tablock)
select a.work_id, is_core_work = case when b.work_id is not null then 1 when a.pub_year >= $(core_min_pub_year_core_pubs) then 0 else null end
from $(relational_db_name)..work as a
left join #work_step7 as b on a.work_id = b.work_id

alter table work add constraint pk_work primary key(work_id)
create index idx_work_is_core_work on work(is_core_work)


drop table if exists [source]
create table [source]
(
	source_id bigint not null,
	is_core_source bit null
)

insert into [source] with(tablock)
select a.source_id, is_core_source = case when b.source_id is not null then 1 when c.source_id is not null then 0 else null end
from $(relational_db_name)..[source] as a
left join #source_step7 as b on a.source_id = b.source_id
left join
(
	select distinct source_id
	from $(relational_db_name)..work
	where pub_year >= $(core_min_pub_year_core_pubs)
) as c on a.source_id = c.source_id

alter table [source] add constraint pk_source primary key(source_id)
create index idx_source_is_core_source on [source](is_core_source)
