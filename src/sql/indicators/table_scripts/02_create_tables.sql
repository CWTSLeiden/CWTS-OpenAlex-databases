set nocount on

drop table if exists #pub_n_authors
select work_id, n_authors = count(*)
into #pub_n_authors
from $(relational_db_name)..work_author
group by work_id

create index idx_tmp_pub_n_authors_work_id on #pub_n_authors(work_id)


drop table if exists #pub_n_affiliations
select work_id, n_affiliations = count(*)
into #pub_n_affiliations
from $(relational_db_name)..work_affiliation
group by work_id

create index idx_tmp_pub_n_affiliations_work_id on #pub_n_affiliations(work_id)


drop table if exists #pub_n_institutions
select work_id, n_institutions = count(distinct institution_id)
into #pub_n_institutions
from $(relational_db_name)..work_affiliation_institution
where institution_id is not null
group by work_id

create index idx_tmp_pub_n_institutions_work_id on #pub_n_institutions(work_id)


drop table if exists #country
select country_iso_alpha2_code, cleaned_country_iso_alpha2_code = country_iso_alpha2_code
into #country
from $(relational_db_name)..country
where country_iso_alpha2_code not in ('cn', 'hk', 'mo')
union
select country_iso_alpha2_code, 'cn'  -- Map Hong Kong and Macao to China.
from $(relational_db_name)..country
where country_iso_alpha2_code in ('cn', 'hk', 'mo')


drop table if exists #pub_country
select a.work_id, country_code = c.cleaned_country_iso_alpha2_code
into #pub_country
from $(relational_db_name)..work_affiliation_institution as a
join $(relational_db_name)..institution as b on a.institution_id = b.institution_id
join #country as c on b.country_iso_alpha2_code = c.country_iso_alpha2_code
union
select a.work_id, b.cleaned_country_iso_alpha2_code
from $(relational_db_name)..work_author_country as a
join #country as b on a.country_iso_alpha2_code = b.country_iso_alpha2_code


drop table if exists #pub_n_countries
select work_id, n_countries = count(distinct country_code)
into #pub_n_countries
from #pub_country
group by work_id

create index idx_tmp_pub_n_countries_work_id on #pub_n_countries(work_id)


drop table if exists #pub_industry
select distinct a.work_id
into #pub_industry
from $(relational_db_name)..work_affiliation_institution as a
join $(relational_db_name)..institution as b on a.institution_id = b.institution_id
where b.institution_type_id = 2  -- Company.

create index idx_tmp_pub_industry_work_id on #pub_industry(work_id)


drop table if exists #pub_oa
select
	a.work_id,
	is_oa,
	is_gold_oa = cast(case when oa_status_id in (3, 6) then 1 else 0 end as bit),
	is_hybrid_oa = cast(case when oa_status_id = 5 then 1 else 0 end as bit),
	is_bronze_oa = cast(case when oa_status_id = 1 then 1 else 0 end as bit),
	is_green_oa = cast(case when oa_status_id = 4 then 1 when b.work_id is not null then 1 else 0 end as bit)
into #pub_oa
from $(relational_db_name)..work as a
left join
(
	select distinct a.work_id
	from $(relational_db_name)..work_location as a
	join $(relational_db_name)..[source] as b on a.source_id = b.source_id
	where a.is_oa = 1
		and b.source_type_id = 4  -- Repository.
) as b on a.work_id = b.work_id
where is_oa is not null

create index idx_tmp_pub_oa_work_id on #pub_oa(work_id)


drop table if exists #pub_coordinates
select a.work_id, latitude = b.latitude * pi() / 180, longitude = b.longitude * pi() / 180
into #pub_coordinates
from $(relational_db_name)..work_affiliation_institution as a
join $(relational_db_name)..institution as b on a.institution_id = b.institution_id
where b.latitude is not null
	and b.longitude is not null


drop table if exists #pub_gcd
select a.work_id, gcd = max(2 * 6371.01 * asin(sqrt(((1 - cos(b.latitude - a.latitude)) / 2) + cos(a.latitude) * cos(b.latitude) * ((1 - cos(b.longitude - a.longitude)) / 2))))
into #pub_gcd
from #pub_coordinates as a
join #pub_coordinates as b on a.work_id = b.work_id
group by a.work_id
having count(*) > 1

create index idx_tmp_pub_gcd_work_id on #pub_gcd(work_id)


drop table if exists #pub
select a.work_id,
	work_no = row_number() over (order by a.work_id),
	a.work_type_id,
	doc_type_no =
		case
			when a.work_type_id in (2, 26, 34, 40, 42) /* book-chapter, article, review, data-paper, software-paper */
					and b.source_type_id = 3 /* journal */
				then 2  -- Journal paper / book chapter in book series.
			when a.work_type_id in (2, 26, 34, 39, 40, 42) /* book-chapter, article, review, conference-paper, data-paper, software-paper */
					and b.source_type_id = 5 /* book series */
				then 2  -- Journal paper / book chapter in book series.
			when a.work_type_id in (2, 26, 34, 39, 40, 42) /* book-chapter, article, review, conference-paper, data-paper, software-paper */
					and b.source_type_id in (1, 2) /* conference, ebook platform */
				then 4  -- Conference paper / book chapter in book.
			when a.work_type_id = 39 /* conference-paper */
					and b.source_type_id = 3 /* journal */
				then 4  -- Conference paper / book chapter in book.
			else 1  -- Non-citable work.
		end,
	a.source_id,
	a.pub_year,
	a.is_retracted,
	has_cwts_required_metadata = cast(
		case
			when a.pub_year is not null
					and a.source_id is not null
					and isnull(d.n_authors, 0) > 0
					and isnull(e.n_affiliations, 0) > 0
					and a.n_refs > 0
				then 1
			else 0
		end as bit),
	is_cwts_extended_pub = cast(
		case
			when a.pub_year is not null
					and a.source_id is not null
					and isnull(d.n_authors, 0) > 0
					and isnull(e.n_affiliations, 0) > 0
					and a.n_refs > 0
				and a.work_type_id in (2, 26, 34, 39, 40, 42) /* book-chapter, article, review, conference-paper, data-paper, software-paper */
					and b.source_type_id in (1, 2, 3, 5) /* conference, ebook platform, journal, book series */
				then 1
			else 0
		end as bit),
	c.is_cwts_core_pub,
	n_authors = isnull(d.n_authors, 1),
	n_institutions = isnull(f.n_institutions, 1),
	n_countries = isnull(g.n_countries, 1),
	is_industry = case when h.work_id is null then 0 else 1 end,
	gcd = isnull(i.gcd, 0),
	is_oa = isnull(j.is_oa, 0),
	is_gold_oa = isnull(j.is_gold_oa, 0),
	is_hybrid_oa = isnull(j.is_hybrid_oa, 0),
	is_bronze_oa = isnull(j.is_bronze_oa, 0),
	is_green_oa = isnull(j.is_green_oa, 0),
	is_oa_unknown = cast(case when j.work_id is null then 1 else 0 end as bit)
into #pub
from $(relational_db_name)..work as a
left join $(relational_db_name)..[source] as b on a.source_id = b.source_id
left join $(core_db_name)..work as c on a.work_id = c.work_id
left join #pub_n_authors as d on a.work_id = d.work_id
left join #pub_n_affiliations as e on a.work_id = e.work_id
left join #pub_n_institutions as f on a.work_id = f.work_id
left join #pub_n_countries as g on a.work_id = g.work_id
left join #pub_industry as h on a.work_id = h.work_id
left join #pub_gcd as i on a.work_id = i.work_id
left join #pub_oa as j on a.work_id = j.work_id


drop table if exists pub
create table pub
(
	work_id bigint not null,
	doc_type_no tinyint not null,
	source_id bigint null,
	pub_year smallint not null,
	is_cwts_extended_pub bit not null,
	is_cwts_core_pub bit not null,
	n_authors smallint not null,
	n_institutions smallint not null,
	n_countries smallint not null,
	collaboration_type_no tinyint not null,
	is_industry bit not null,
	gcd float not null,
	is_oa bit not null,
	is_gold_oa bit not null,
	is_hybrid_oa bit not null,
	is_bronze_oa bit not null,
	is_green_oa bit not null,
	is_oa_unknown bit not null
)

insert pub with(tablock)
select work_id,
	doc_type_no,
	source_id,
	pub_year,
	is_cwts_extended_pub,
	is_cwts_core_pub,
	n_authors,
	n_institutions,
	n_countries,
	collaboration_type_no =
		case
			when n_institutions <= 1 then 1
			when (n_institutions > 1) and (n_countries <= 1) then 2
			when (n_institutions > 1) and (n_countries > 1) then 3
		end,
	is_industry,
	gcd,
	is_oa,
	is_gold_oa,
	is_hybrid_oa,
	is_bronze_oa,
	is_green_oa,
	is_oa_unknown
from #pub
where pub_year >= $(indicators_min_pub_year)
	and work_type_id not in (7, 41)  -- Exclude datasets and software.
	and has_cwts_required_metadata = 1
	and is_retracted = 0

alter table pub add constraint pk_pub primary key(work_id)
create index idx_pub_doc_type_no on pub(doc_type_no)
create index idx_pub_source_no on pub(source_id)
create index idx_pub_pub_year on pub(pub_year)
create index idx_pub_is_cwts_extended_pub on pub(is_cwts_extended_pub)
create index idx_pub_is_cwts_core_pub on pub(is_cwts_core_pub)


drop table if exists [source]
create table [source]
(
	source_id bigint not null,
	is_cwts_core_source bit not null
)

insert [source] with(tablock)
select a.source_id, is_cwts_core_source = isnull(a.is_cwts_core_source, 0)
from $(core_db_name)..[source] as a
join
(
	select distinct source_id
	from pub
	where source_id is not null
) as b on a.source_id = b.source_id

alter table [source] add constraint pk_source primary key(source_id)
create index idx_source_is_cwts_core_source on [source](is_cwts_core_source)


drop table if exists #pub_database
select work_id, database_no = 1
into #pub_database
from pub
union
select work_id, database_no = 2
from pub
where is_cwts_extended_pub = 1
union
select work_id, database_no = 3
from pub
where is_cwts_core_pub = 1


drop table if exists pub_database
create table pub_database
(
	work_id bigint not null,
	database_no tinyint not null,
	n_refs smallint not null,
	n_refs_covered smallint not null
)

insert pub_database with(tablock)
select a.work_id, b.database_no, b.n_refs, n_refs_covered = case when b.n_refs < isnull(c.n_refs_covered, 0) then b.n_refs else isnull(c.n_refs_covered, 0) end
from pub as a
join
(
	select a.work_id, a.database_no, n_refs = isnull(b.n_refs, 0)
	from #pub_database as a
	left join
	(
		select work_id = a.citing_work_id, n_refs = count(*)
		from $(relational_db_name)..citation as a
		join $(relational_db_name)..work as b on a.cited_work_id = b.work_id
		where b.pub_year >= $(indicators_min_pub_year)
		group by a.citing_work_id
	) as b on a.work_id = b.work_id
) as b on a.work_id = b.work_id
left join
(
	select work_id = a.citing_work_id, b.database_no, n_refs_covered = count(*)
	from $(relational_db_name)..citation as a
	join #pub_database as b on a.cited_work_id = b.work_id
	group by a.citing_work_id, b.database_no
) as c on b.work_id = c.work_id
	and b.database_no = c.database_no

alter table pub_database add constraint pk_pub_database primary key(work_id, database_no)


update a with(tablock)
set a.has_cwts_required_metadata = b.has_cwts_required_metadata, a.is_cwts_extended_pub = b.is_cwts_extended_pub, a.is_cwts_core_pub = b.is_cwts_core_pub
from $(relational_db_name)..work as a
join #pub as b on a.work_id = b.work_id


update a with(tablock)
set a.is_cwts_core_source = b.is_cwts_core_source
from $(relational_db_name)..[source] as a
join $(core_db_name)..[source] as b on a.source_id = b.source_id
