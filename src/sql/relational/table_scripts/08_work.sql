set nocount on

drop table if exists #work_location
select *
into #work_location
from $(works_json_db_name)..work_location
where not(location_seq is null and source_id is null and landing_page_url is null and pdf_url is null and [version] is null and license is null and is_oa is null and is_accepted is null and is_published is null)

create clustered columnstore index idx_tmp_work_location on #work_location

drop table if exists #work_primary_location
select *
into #work_primary_location
from $(works_json_db_name)..work_primary_location
where not(source_id is null and landing_page_url is null and pdf_url is null and [version] is null and license is null and is_oa is null and is_accepted is null and is_published is null)

create clustered columnstore index idx_tmp_work_primary_location on #work_primary_location

drop table if exists #work_best_oa_location
select *
into #work_best_oa_location
from $(works_json_db_name)..work_best_oa_location
where not(source_id is null and landing_page_url is null and pdf_url is null and [version] is null and license is null and is_oa is null and is_accepted is null and is_published is null)

create clustered columnstore index idx_tmp_work_best_oa_location on #work_best_oa_location

drop table if exists #work_location2
select a.work_id,
	b.location_seq,
	source_id = replace(b.source_id, 'https://openalex.org/S', ''),
	b.doi,
	b.landing_page_url,
	b.pdf_url,
	b.[version],
	b.license,
	b.is_oa,
	b.is_accepted,
	b.is_published,
	is_primary_location = case when c.folder is not null then 1 else 0 end,
	is_best_oa_location = case when d.folder is not null then 1 else 0 end
into #work_location2
from _work as a
join #work_location as b on a.folder = b.folder and a.record_id = b.record_id
left join #work_primary_location as c on a.folder = c.folder and a.record_id = c.record_id
	and isnull(b.source_id, '-1') = isnull(c.source_id, '-1')
	and isnull(b.doi, '-1') = isnull(c.doi, '-1')
	and isnull(b.landing_page_url, N'-1') = isnull(c.landing_page_url, N'-1')
	and isnull(b.pdf_url, N'-1') = isnull(c.pdf_url, N'-1')
	and isnull(b.[version], '-1') = isnull(c.[version], '-1')
	and isnull(b.license, '-1') = isnull(c.license, '-1')
	and isnull(b.is_oa, '-1') = isnull(c.is_oa, '-1')
	and isnull(b.is_accepted, '-1') = isnull(c.is_accepted, '-1')
	and isnull(b.is_published, '-1') = isnull(c.is_published, '-1')
left join #work_best_oa_location as d on a.folder = d.folder and a.record_id = d.record_id
	and isnull(b.source_id, '-1') = isnull(d.source_id, '-1')
	and isnull(b.doi, '-1') = isnull(d.doi, '-1')
	and isnull(b.landing_page_url, N'-1') = isnull(d.landing_page_url, N'-1')
	and isnull(b.pdf_url, N'-1') = isnull(d.pdf_url, N'-1')
	and isnull(b.[version], '-1') = isnull(d.[version], '-1')
	and isnull(b.license, '-1') = isnull(d.license, '-1')
	and isnull(b.is_oa, '-1') = isnull(d.is_oa, '-1')
	and isnull(b.is_accepted, '-1') = isnull(d.is_accepted, '-1')
	and isnull(b.is_published, '-1') = isnull(d.is_published, '-1')
where b.location_seq is not null

drop table if exists #work_location3
select work_id,
	location_seq = row_number() over (partition by work_id order by min(location_seq)),
	source_id,
	doi,
	landing_page_url,
	pdf_url,
	[version],
	license,
	is_oa,
	is_accepted,
	is_published,
	is_primary_location,
	is_best_oa_location
into #work_location3
from #work_location2
group by work_id, source_id, doi, landing_page_url, pdf_url, [version], license, is_oa, is_accepted, is_published, is_primary_location, is_best_oa_location

declare @n_works_primary_location1 int = (select count(*) from #work_primary_location)
declare @n_works_primary_location2 int = (select count(*) from #work_location3 where is_primary_location = 1)
if @n_works_primary_location1 <> @n_works_primary_location2
begin
	raiserror('Info: Check work_primary_location.', 2, 1)
	print @n_works_primary_location1
	print @n_works_primary_location2
end

declare @n_works_best_oa_location1 int = (select count(*) from #work_best_oa_location)
declare @n_works_best_oa_location2 int = (select count(*) from #work_location3 where is_best_oa_location = 1)
if @n_works_best_oa_location1 <> @n_works_best_oa_location2
begin
	raiserror('Info: Check work_best_oa_location.', 2, 1)
	print @n_works_best_oa_location1
	print @n_works_best_oa_location2
end



-- work_type
drop table if exists work_type
create table work_type
(
	work_type_id tinyint not null identity(1, 1),
	work_type varchar(25) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'work_type')
	begin
		set identity_insert work_type on

		insert into work_type with(tablock) (work_type_id, work_type)
		select work_type_id, work_type
		from $(previous_relational_db_name)..work_type

		set identity_insert work_type off
	end
end

insert into work_type with(tablock)
select work_type = [type]
from $(works_json_db_name)..work
where [type] is not null
except
select work_type
from work_type
order by work_type

insert into work_type with(tablock)
select work_type = type_crossref
from $(works_json_db_name)..work
where type_crossref is not null
except
select work_type
from work_type
order by work_type

alter table work_type add constraint pk_work_type primary key(work_type_id)
create index idx_work_type_work_type on work_type(work_type)



-- oa_status
drop table if exists oa_status
create table oa_status
(
	oa_status_id tinyint not null identity(1, 1),
	oa_status varchar(10) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'oa_status')
	begin
		set identity_insert oa_status on

		insert into oa_status with(tablock) (oa_status_id, oa_status)
		select oa_status_id, oa_status
		from $(previous_relational_db_name)..oa_status

		set identity_insert oa_status off
	end
end

insert into oa_status with(tablock)
select oa_status = open_access_oa_status
from $(works_json_db_name)..work
where open_access_oa_status is not null
except
select oa_status
from oa_status
order by oa_status

alter table oa_status add constraint pk_oa_status primary key(oa_status_id)
create index idx_oa_status_oa_status on oa_status(oa_status)



-- doi_registration_agency
drop table if exists doi_registration_agency
create table doi_registration_agency
(
	doi_registration_agency_id tinyint not null identity(1, 1),
	doi_registration_agency varchar(20) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'doi_registration_agency')
	begin
		set identity_insert doi_registration_agency on

		insert into doi_registration_agency with(tablock) (doi_registration_agency_id, doi_registration_agency)
		select doi_registration_agency_id, doi_registration_agency
		from $(previous_relational_db_name)..doi_registration_agency

		set identity_insert doi_registration_agency off
	end
end

insert into doi_registration_agency with(tablock)
select doi_registration_agency
from $(works_json_db_name)..work
where doi_registration_agency is not null
except
select doi_registration_agency
from doi_registration_agency
order by doi_registration_agency

alter table doi_registration_agency add constraint pk_doi_registration_agency primary key(doi_registration_agency_id)
create index idx_doi_registration_agency_doi_registration_agency on doi_registration_agency(doi_registration_agency)



-- apc_provenance
drop table if exists apc_provenance
create table apc_provenance
(
	apc_provenance_id tinyint not null identity(1, 1),
	apc_provenance varchar(20) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'apc_provenance')
	begin
		set identity_insert apc_provenance on

		insert into apc_provenance with(tablock) (apc_provenance_id, apc_provenance)
		select apc_provenance_id, apc_provenance
		from $(previous_relational_db_name)..apc_provenance

		set identity_insert apc_provenance off
	end
end

insert into apc_provenance with(tablock)
select apc_provenance = apc_list_provenance
from $(works_json_db_name)..work
where apc_list_provenance is not null
union
select apc_paid_provenance
from $(works_json_db_name)..work
where apc_paid_provenance is not null
except
select apc_provenance
from apc_provenance
order by apc_provenance

alter table apc_provenance add constraint pk_apc_provenance primary key(apc_provenance_id)
create index idx_apc_provenance_apc_provenance on apc_provenance(apc_provenance)



-- fulltext_origin
drop table if exists fulltext_origin
create table fulltext_origin
(
	fulltext_origin_id tinyint not null identity(1, 1),
	fulltext_origin varchar(20) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'fulltext_origin')
	begin
		set identity_insert fulltext_origin on

		insert into fulltext_origin with(tablock) (fulltext_origin_id, fulltext_origin)
		select fulltext_origin_id, fulltext_origin
		from $(previous_relational_db_name)..fulltext_origin

		set identity_insert fulltext_origin off
	end
end

insert into fulltext_origin with(tablock)
select fulltext_origin
from $(works_json_db_name)..work
where fulltext_origin is not null
except
select fulltext_origin
from fulltext_origin
order by fulltext_origin

alter table fulltext_origin add constraint pk_fulltext_origin primary key(fulltext_origin_id)
create index idx_fulltext_origin_fulltext_origin on fulltext_origin(fulltext_origin)



-- work
drop table if exists work
create table work
(
	work_id bigint not null,
	work_type_id tinyint null,
	crossref_work_type_id tinyint null,
	source_id bigint null,
	pub_date date null,
	pub_year smallint null,
	volume nvarchar(100) null,
	issue nvarchar(80) null,
	page_first nvarchar(200) null,
	page_last nvarchar(300) null,
	doi_registration_agency_id tinyint null,
	doi varchar(350) null,
	openalex_id varchar(32) not null,
	mag_id bigint null,
	pmid bigint null,
	pmcid bigint null,
	arxiv_id varchar(80) null,
	language_iso2_code char(2) null,
	is_paratext bit null,
	is_retracted bit null,
	is_oa bit null,
	any_repository_has_fulltext bit null,
	oa_status_id tinyint null,
	oa_url nvarchar(4000) null,
	apc_list_currency char(3) null,
	apc_list_price int null,
	apc_list_price_usd int null,
	apc_list_apc_provenance_id tinyint null,
	apc_paid_currency char(3) null,
	apc_paid_price int null,
	apc_paid_price_usd int null,
	apc_paid_apc_provenance_id tinyint null,
	fulltext_origin_id tinyint null,
	n_refs int not null,
	n_cits int not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into work with(tablock)
select a.work_id,
	c.work_type_id,
	crossref_work_type_id = d.work_type_id,
	e.source_id,
	b.publication_date,
	b.publication_year,
	b.biblio_volume,
	b.biblio_issue,
	b.biblio_first_page,
	b.biblio_last_page,
	f.doi_registration_agency_id,
	doi = replace(b.id_doi, 'https://doi.org/', ''),
	openalex_id = 'W' + cast(a.work_id as varchar(31)),
	mag_id = b.id_mag,
	pmid = case when left(b.id_pmid, 35) <> 'https://pubmed.ncbi.nlm.nih.gov/PMC' then replace(b.id_pmid, 'https://pubmed.ncbi.nlm.nih.gov/', '') else null end,
	pmcid = replace(b.id_pmcid, 'https://www.ncbi.nlm.nih.gov/pmc/articles/', ''),
	b.id_arxiv_id,
	language_iso2_code = left(b.[language], 2),
	b.is_paratext,
	b.is_retracted,
	b.open_access_is_oa,
	b.open_access_any_repository_has_fulltext,
	g.oa_status_id,
	b.open_access_oa_url,
	b.apc_list_currency,
	b.apc_list_value,
	b.apc_list_value_usd,
	apc_list_apc_provenance_id = h.apc_provenance_id,
	b.apc_paid_currency,
	b.apc_paid_value,
	b.apc_paid_value_usd,
	apc_paid_apc_provenance_id = i.apc_provenance_id,
	j.fulltext_origin_id,
	n_refs = 0,
	n_cits = 0,
	b.updated_date,
	b.created_date
from _work as a
join $(works_json_db_name)..work as b on a.folder = b.folder and a.record_id = b.record_id
left join work_type as c on b.[type] = c.work_type
left join work_type as d on b.type_crossref = d.work_type
left join #work_location3 as e on a.work_id = e.work_id and e.is_primary_location = 1
left join doi_registration_agency as f on b.doi_registration_agency = f.doi_registration_agency
left join oa_status as g on b.open_access_oa_status = g.oa_status
left join apc_provenance as h on b.apc_list_provenance = h.apc_provenance
left join apc_provenance as i on b.apc_paid_provenance = i.apc_provenance
left join fulltext_origin as j on b.fulltext_origin = j.fulltext_origin

alter table work add constraint pk_work primary key(work_id)
create index idx_work_work_type_id on work(work_type_id)
create index idx_work_crossref_work_type_id on work(crossref_work_type_id)
create index idx_work_source_id on work(source_id)
create index idx_work_pub_date on work(pub_date)
create index idx_work_pub_year on work(pub_year)
create index idx_work_doi_registration_agency_id on work(doi_registration_agency_id)
create index idx_work_doi on work(doi)
create index idx_work_openalex_id on work(openalex_id)
create index idx_work_mag_id on work(mag_id)
create index idx_work_pmid on work(pmid)
create index idx_work_pmcid on work(pmcid)
create index idx_work_arxiv_id on work(arxiv_id)
create index idx_work_language_iso2_code on work(language_iso2_code)
create index idx_work_is_paratext on work(is_paratext)
create index idx_work_is_retracted on work(is_retracted)
create index idx_work_is_oa on work(is_oa)
create index idx_work_oa_status_id on work(oa_status_id)
create index idx_work_apc_list_currency on work(apc_list_currency)
create index idx_work_apc_list_apc_provenance_id on work(apc_list_apc_provenance_id)
create index idx_work_apc_paid_currency on work(apc_paid_currency)
create index idx_work_apc_paid_apc_provenance_id on work(apc_paid_apc_provenance_id)
create index idx_work_fulltext_origin_id on work(fulltext_origin_id)
alter table work add constraint fk_work_work_type_id_work_type_work_type_id foreign key(work_type_id) references work_type(work_type_id)
alter table work add constraint fk_work_crossref_work_type_id_work_type_work_type_id foreign key(crossref_work_type_id) references work_type(work_type_id)
alter table work add constraint fk_work_source_id_source_source_id foreign key(source_id) references [source](source_id)
alter table work add constraint fk_work_doi_registration_agency_id_doi_registration_agency_doi_registration_agency_id foreign key(doi_registration_agency_id) references doi_registration_agency(doi_registration_agency_id)
alter table work add constraint fk_work_oa_status_id_oa_status_oa_status_id foreign key(oa_status_id) references oa_status(oa_status_id)
alter table work add constraint fk_work_apc_list_apc_provenance_id_apc_provenance_apc_provenance_id foreign key(apc_list_apc_provenance_id) references apc_provenance(apc_provenance_id)
alter table work add constraint fk_work_apc_paid_apc_provenance_id_apc_provenance_apc_provenance_id foreign key(apc_paid_apc_provenance_id) references apc_provenance(apc_provenance_id)
alter table work add constraint fk_work_fulltext_origin_id_fulltext_origin_fulltext_origin_id foreign key(fulltext_origin_id) references fulltext_origin(fulltext_origin_id)



-- version
drop table if exists [version]
create table [version]
(
	version_id tinyint not null identity(1, 1),
	[version] varchar(16) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'version')
	begin
		set identity_insert [version] on

		insert into [version] with(tablock) (version_id, [version])
		select version_id, [version]
		from $(previous_relational_db_name)..[version]

		set identity_insert [version] off
	end
end

insert into [version] with(tablock)
select [version]
from $(works_json_db_name)..work_location
where [version] is not null
except
select [version]
from [version]
order by [version]

alter table [version] add constraint pk_version primary key(version_id)
create index idx_version_version on [version]([version])



-- license
drop table if exists license
create table license
(
	license_id tinyint not null identity(1, 1),
	license varchar(60) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'license')
	begin
		set identity_insert license on

		insert into license with(tablock) (license_id, license)
		select license_id, license
		from $(previous_relational_db_name)..license

		set identity_insert license off
	end
end

insert into license with(tablock)
select license
from $(works_json_db_name)..work_location
where license is not null
except
select license
from license
order by license

alter table license add constraint pk_license primary key(license_id)
create index idx_license_license on license(license)



-- work_location
drop table if exists work_location
create table work_location
(
	work_id bigint not null,
	location_seq smallint not null,
	is_primary_location bit not null,
	is_best_oa_location bit not null,
	source_id bigint null,
	landing_page_url varchar(2000) null,
	pdf_url varchar(4000) null,
	version_id tinyint null,
	license_id tinyint null,
	is_oa bit null,
	is_accepted bit null,
	is_published bit null
)
go

insert into work_location with(tablock)
select a.work_id,
	a.location_seq,
	a.is_primary_location,
	a.is_best_oa_location,
	source_id = replace(a.source_id, 'https://openalex.org/S', ''),
	a.landing_page_url,
	a.pdf_url,
	b.version_id,
	c.license_id,
	a.is_oa,
	a.is_accepted,
	a.is_published
from #work_location3 as a
left join [version] as b on a.[version] = b.[version]
left join license as c on a.license = c.license

alter table work_location add constraint pk_work_location primary key(work_id, location_seq)
create index idx_work_location_is_primary_location on work_location(is_primary_location)
create index idx_work_location_is_best_oa_location on work_location(is_best_oa_location)
create index idx_work_location_source_id on work_location(source_id)
create index idx_work_location_version_id on work_location(version_id)
create index idx_work_location_license_id on work_location(license_id)
create index idx_work_location_is_oa on work_location(is_oa)
create index idx_work_location_is_accepted on work_location(is_accepted)
create index idx_work_location_is_published on work_location(is_published)
alter table work_location add constraint fk_work_location_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_location add constraint fk_work_location_source_id_source_source_id foreign key(source_id) references [source](source_id)
alter table work_location add constraint fk_work_location_version_id_version_version_id foreign key(version_id) references [version](version_id)
alter table work_location add constraint fk_work_location_license_id_license_license_id foreign key(license_id) references license(license_id)



-- work_title
drop table if exists work_title
create table work_title
(
	work_id bigint not null,
	title nvarchar(max) not null
)
go

insert into work_title with(tablock)
select a.work_id,
	trim($(etl_db_name).dbo.remove_html_tags($(etl_db_name).dbo.decode_html_characters2(b.title)))
from _work as a
join $(works_json_db_name)..work as b on a.folder = b.folder and a.record_id = b.record_id
where b.title is not null

alter table work_title add constraint pk_work_title primary key(work_id)
alter table work_title add constraint fk_work_title_work_id_work_work_id foreign key(work_id) references work(work_id)



-- work_abstract
drop table if exists work_abstract
create table work_abstract
(
	work_id bigint not null,
	abstract nvarchar(max) not null
)
go

insert into work_abstract with(tablock)
select a.work_id,
	trim($(etl_db_name).dbo.remove_html_tags($(etl_db_name).dbo.decode_html_characters2(b.abstract)))
from _work as a
join $(works_json_db_name)..work_abstract as b on a.folder = b.folder and a.record_id = b.record_id
where b.abstract is not null

alter table work_abstract add constraint pk_work_abstract primary key(work_id)
alter table work_abstract add constraint fk_work_abstract_work_id_work_work_id foreign key(work_id) references work(work_id)



-- work_related
drop table if exists work_related
create table work_related
(
	work_id bigint not null,
	related_work_seq smallint not null,
	related_work_id bigint not null
)
go

insert into work_related with(tablock)
select a.work_id,
	b.related_work_seq,
	related_work_id = replace(b.related_work, 'https://openalex.org/W', '')
from _work as a
join $(works_json_db_name)..work_related_work as b on a.folder = b.folder and a.record_id = b.record_id

delete a with(tablock)
from work_related as a
left join work as b on a.related_work_id = b.work_id
where b.work_id is null

alter table work_related add constraint pk_work_related primary key(work_id, related_work_seq)
create index idx_work_related_related_work_id on work_related(related_work_id)
alter table work_related add constraint fk_work_related_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_related add constraint fk_work_related_related_work_id_work_work_id foreign key(related_work_id) references work(work_id)



-- work_reference
drop table if exists work_reference
create table work_reference
(
	work_id bigint not null,
	reference_seq int not null,
	cited_work_id bigint not null
)
go

insert into work_reference with(tablock)
select a.work_id,
	b.referenced_work_seq,
	cited_work_id = replace(b.referenced_work, 'https://openalex.org/W', '')
from _work as a
join $(works_json_db_name)..work_referenced_work as b on a.folder = b.folder and a.record_id = b.record_id

delete a with(tablock)
from work_reference as a
left join work as b on a.cited_work_id = b.work_id
where b.work_id is null

alter table work_reference add constraint pk_work_reference primary key(work_id, reference_seq)
create index idx_work_reference_cited_work_id on work_reference(cited_work_id)
alter table work_reference add constraint fk_work_reference_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_reference add constraint fk_work_reference_cited_work_id_work_work_id foreign key(cited_work_id) references work(work_id)



-- work_concept
drop table if exists work_concept
create table work_concept
(
	work_id bigint not null,
	concept_seq smallint not null,
	concept_id bigint not null,
	score float not null
)
go

insert into work_concept with(tablock)
select a.work_id,
	b.concept_seq,
	concept_id = replace(b.id, 'https://openalex.org/C', ''),
	b.score
from _work as a
join $(works_json_db_name)..work_concept as b on a.folder = b.folder and a.record_id = b.record_id

alter table work_concept add constraint pk_work_concept primary key(work_id, concept_seq)
create index idx_work_concept_concept_id on work_concept(concept_id)
alter table work_concept add constraint fk_work_concept_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_concept add constraint fk_work_concept_concept_id_concept_concept_id foreign key(concept_id) references concept(concept_id)



-- mesh_descriptor
drop table if exists mesh_descriptor
create table mesh_descriptor
(
	mesh_descriptor_ui varchar(10) not null,
	mesh_descriptor varchar(120) not null
)
go

insert into mesh_descriptor with(tablock)
select mesh_descriptor_ui, mesh_descriptor
from
(
	select mesh_descriptor_ui = descriptor_ui,
		mesh_descriptor = descriptor_name,
		[filter] = row_number() over (partition by descriptor_ui order by count(*) desc, descriptor_name)
	from $(works_json_db_name)..work_mesh
	where descriptor_ui is not null
	group by descriptor_ui, descriptor_name
) as a
where [filter] = 1
except
select mesh_descriptor_ui, mesh_descriptor
from mesh_descriptor

alter table mesh_descriptor add constraint pk_mesh_descriptor primary key(mesh_descriptor_ui)
create index idx_mesh_descriptor_mesh_descriptor on mesh_descriptor(mesh_descriptor)



-- mesh_qualifier
drop table if exists mesh_qualifier
create table mesh_qualifier
(
	mesh_qualifier_ui varchar(10) not null,
	mesh_qualifier varchar(40) not null
)
go

insert into mesh_qualifier with(tablock)
select mesh_qualifier_ui, mesh_qualifier
from
(
	select mesh_qualifier_ui = qualifier_ui,
		mesh_qualifier = qualifier_name,
		[filter] = row_number() over (partition by qualifier_ui order by count(*) desc, qualifier_name)
	from $(works_json_db_name)..work_mesh
	where qualifier_ui is not null
	group by qualifier_ui, qualifier_name
) as a
where [filter] = 1
except
select mesh_qualifier_ui, mesh_qualifier
from mesh_qualifier

alter table mesh_qualifier add constraint pk_mesh_qualifier primary key(mesh_qualifier_ui)
create index idx_mesh_qualifier_mesh_qualifier on mesh_qualifier(mesh_qualifier)



-- work_mesh
drop table if exists work_mesh
create table work_mesh
(
	work_id bigint not null,
	mesh_seq smallint not null,
	mesh_descriptor_ui varchar(10) not null,
	mesh_qualifier_ui varchar(10) null,
	is_major_topic bit not null
)
go

insert into work_mesh with(tablock)
select a.work_id,
	b.mesh_seq,
	b.descriptor_ui,
	b.qualifier_ui,
	b.is_major_topic
from _work as a
join $(works_json_db_name)..work_mesh as b on a.folder = b.folder and a.record_id = b.record_id

alter table work_mesh add constraint pk_work_mesh primary key(work_id, mesh_seq)
create index idx_work_mesh_descriptor_ui on work_mesh(mesh_descriptor_ui)
create index idx_work_mesh_qualifier_ui on work_mesh(mesh_qualifier_ui)
create index idx_work_is_major_topic on work_mesh(is_major_topic)
alter table work_mesh add constraint fk_work_mesh_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_mesh add constraint fk_work_mesh_mesh_descriptor_ui_mesh_descriptor_mesh_descriptor_ui foreign key(mesh_descriptor_ui) references mesh_descriptor(mesh_descriptor_ui)
alter table work_mesh add constraint fk_work_mesh_mesh_qualifier_ui_mesh_qualifier_mesh_qualifier_ui foreign key(mesh_qualifier_ui) references mesh_qualifier(mesh_qualifier_ui)



-- work_grant
drop table if exists work_grant
create table work_grant
(
	work_id bigint not null,
	grant_seq smallint not null,
	award_id nvarchar(1000) null,
	funder_id bigint not null
)
go

insert into work_grant with(tablock)
select a.work_id,
	b.grant_seq,
	b.award_id,
	funder_id = replace(b.funder, 'https://openalex.org/F', '')
from _work as a
join $(works_json_db_name)..work_grant as b on a.folder = b.folder and a.record_id = b.record_id

alter table work_grant add constraint pk_work_grant primary key(work_id, grant_seq)
create index idx_work_grant_funder_id on work_grant(funder_id)
alter table work_grant add constraint fk_work_grant_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_grant add constraint fk_work_grant_funder_id_funder_funder_id foreign key(funder_id) references funder(funder_id)



drop table if exists #work_sustainable_development_goal
select a.work_id,
	b.sustainable_development_goal_seq,
	sustainable_development_goal = b.display_name,
	taxonomy_url = replace(b.id, 'http://', 'https://'),
	b.score
into #work_sustainable_development_goal
from _work as a
join $(works_json_db_name)..work_sustainable_development_goal as b on a.folder = b.folder and a.record_id = b.record_id

drop table if exists #sustainable_development_goal
select sustainable_development_goal_id, sustainable_development_goal, taxonomy_url
into #sustainable_development_goal
from
(
	select sustainable_development_goal_id = cast(replace(taxonomy_url, 'https://metadata.un.org/sdg/', '') as tinyint),
		sustainable_development_goal,
		taxonomy_url,
		[filter] = row_number() over (partition by taxonomy_url order by count(*) desc, sustainable_development_goal)
	from #work_sustainable_development_goal
	where sustainable_development_goal is not null
	group by taxonomy_url, sustainable_development_goal
) as a
where [filter] = 1



-- sustainable_development_goal
drop table if exists sustainable_development_goal
create table sustainable_development_goal
(
	sustainable_development_goal_id tinyint not null,
	sustainable_development_goal varchar(40) not null,
	taxonomy_url varchar(30) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'sustainable_development_goal')
	begin
		insert into sustainable_development_goal with(tablock) (sustainable_development_goal_id, sustainable_development_goal, taxonomy_url)
		select sustainable_development_goal_id, sustainable_development_goal, taxonomy_url
		from $(previous_relational_db_name)..sustainable_development_goal
	end
end

update a
set a.sustainable_development_goal = b.sustainable_development_goal, a.taxonomy_url = b.taxonomy_url
from sustainable_development_goal as a
join #sustainable_development_goal as b on a.sustainable_development_goal_id = b.sustainable_development_goal_id

insert into sustainable_development_goal with(tablock)
select a.sustainable_development_goal_id, a.sustainable_development_goal, a.taxonomy_url
from #sustainable_development_goal as a
left join sustainable_development_goal as b on a.sustainable_development_goal_id = b.sustainable_development_goal_id
where b.sustainable_development_goal_id is null

alter table sustainable_development_goal add constraint pk_sustainable_development_goal primary key(sustainable_development_goal_id)



-- work_sustainable_development_goal
drop table if exists work_sustainable_development_goal
create table work_sustainable_development_goal
(
	work_id bigint not null,
	sustainable_development_goal_seq smallint not null,
	sustainable_development_goal_id tinyint not null,
	score float not null
)
go

insert into work_sustainable_development_goal with(tablock)
select a.work_id,
	a.sustainable_development_goal_seq,
	b.sustainable_development_goal_id,
	a.score
from #work_sustainable_development_goal as a
join #sustainable_development_goal as b on a.taxonomy_url = b.taxonomy_url

alter table work_sustainable_development_goal add constraint pk_work_sustainable_development_goal primary key(work_id, sustainable_development_goal_seq)
create index idx_work_sustainable_development_goal_sustainable_development_goal_id on work_sustainable_development_goal(sustainable_development_goal_id)
alter table work_sustainable_development_goal add constraint fk_work_sustainable_development_goal_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_sustainable_development_goal add constraint fk_work_sdg_sustainable_development_goal_id_sdg_sustainable_development_goal_id foreign key(sustainable_development_goal_id) references sustainable_development_goal(sustainable_development_goal_id)



-- keyword
drop table if exists keyword
create table keyword
(
	keyword_id int not null identity(1, 1),
	keyword nvarchar(200) not null,
)
go

--if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
--begin
--	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'keyword')
--	begin
--		set identity_insert keyword on

--		insert into keyword with(tablock) (keyword_id, keyword)
--		select keyword_id, keyword
--		from $(previous_relational_db_name)..keyword

--		set identity_insert keyword off
--	end
--end

insert into keyword with(tablock)
select keyword = display_name
from $(works_json_db_name)..work_keyword
where display_name is not null
except
select keyword
from keyword
order by keyword

alter table keyword add constraint pk_keyword primary key(keyword_id)
create index idx_keyword_keyword on keyword(keyword)



-- work_keyword
drop table if exists work_keyword
create table work_keyword
(
	work_id bigint not null,
	keyword_seq smallint not null,
	keyword_id int not null,
	score float not null
)
go

insert into work_keyword with(tablock)
select a.work_id,
	b.keyword_seq,
	c.keyword_id,
	b.score
from _work as a
join $(works_json_db_name)..work_keyword as b on a.folder = b.folder and a.record_id = b.record_id
join keyword as c on b.display_name = c.keyword

alter table work_keyword add constraint pk_work_keyword primary key(work_id, keyword_seq)
create index idx_work_keyword_keyword_id on work_keyword(keyword_id)
alter table work_keyword add constraint fk_work_keyword_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_keyword add constraint fk_work_keyword_keyword_id_keyword_keyword_id foreign key(keyword_id) references keyword(keyword_id)



-- work_topic
drop table if exists work_topic
create table work_topic
(
	work_id bigint not null,
	topic_seq smallint not null,
	topic_id smallint not null,
	score float not null,
	is_primary_topic bit not null
)
go

insert into work_topic with(tablock)
select a.work_id,
	b.topic_seq,
	topic_id = replace(b.id, 'https://openalex.org/T', ''),
	b.score,
	is_primary_topic = case when b.topic_seq = 1 then 1 else 0 end
from _work as a
join $(works_json_db_name)..work_topic as b on a.folder = b.folder and a.record_id = b.record_id

alter table work_topic add constraint pk_work_topic primary key(work_id, topic_seq)
create index idx_work_topic_topic_id on work_topic(topic_id)
create index idx_work_topic_is_primary_topic on work_topic(is_primary_topic)
alter table work_topic add constraint fk_work_topic_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_topic add constraint fk_work_topic_topic_id_topic_topic_id foreign key(topic_id) references topic(topic_id)



-- data_source
drop table if exists [data_source]
create table [data_source]
(
	data_source_id int not null identity(1, 1),
	[data_source] varchar(20) not null,
)
go

--if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
--begin
--	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'data_source')
--	begin
--		set identity_insert [data_source] on

--		insert into [data_source] with(tablock) (data_source_id, [data_source])
--		select data_source_id, [data_source]
--		from $(previous_relational_db_name)..[data_source]

--		set identity_insert [data_source] off
--	end
--end

insert into [data_source] with(tablock)
select [data_source] = indexed_in
from $(works_json_db_name)..work_indexed_in
where indexed_in is not null
except
select [data_source]
from [data_source]
order by [data_source]

alter table [data_source] add constraint pk_data_source primary key(data_source_id)
create index idx_data_source_data_source on [data_source](data_source)



-- work_data_source
drop table if exists work_data_source
create table work_data_source
(
	work_id bigint not null,
	data_source_seq smallint not null,
	data_source_id int not null
)
go

insert into work_data_source with(tablock)
select a.work_id,
	data_source_seq = b.indexed_in_seq,
	c.data_source_id
from _work as a
join $(works_json_db_name)..work_indexed_in as b on a.folder = b.folder and a.record_id = b.record_id
join [data_source] as c on b.indexed_in = c.[data_source]

alter table work_data_source add constraint pk_work_data_source primary key(work_id, data_source_seq)
create index idx_work_data_source_data_source_id on work_data_source(data_source_id)
alter table work_data_source add constraint fk_work_data_source_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_data_source add constraint fk_work_data_source_data_source_id_data_source_data_source_id foreign key(data_source_id) references [data_source](data_source_id)
