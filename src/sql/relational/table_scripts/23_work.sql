set nocount on

drop table if exists #work_location
select a.work_id, b.location_seq, b.id, b.source_id, b.landing_page_url, b.pdf_url, b.[version], b.license, b.is_oa, b.is_accepted, b.is_published, b.raw_type, b.raw_source_name, b.provenance
into #work_location
from _work as a
join $(works_json_db_name)..work_location as b on a.folder = b.folder and a.record_id = b.record_id
where b.id is not null

create clustered columnstore index idx_tmp_work_location on #work_location

drop table if exists #work_location2
select work_id, location_seq = min(location_seq)
into #work_location2
from #work_location
group by work_id, id, source_id, landing_page_url, pdf_url, [version], license, is_oa, is_accepted, is_published, provenance

create clustered columnstore index idx_tmp_work_location2 on #work_location2

drop table if exists #work_primary_location
select a.work_id, b.id, b.source_id, b.landing_page_url, b.pdf_url, b.[version], b.license, b.is_oa, b.is_accepted, b.is_published, b.provenance
into #work_primary_location
from _work as a
join $(works_json_db_name)..work_primary_location as b on a.folder = b.folder and a.record_id = b.record_id
where b.id is not null

create clustered columnstore index idx_tmp_work_primary_location on #work_primary_location

drop table if exists #work_best_oa_location
select a.work_id, b.id, b.source_id, b.landing_page_url, b.pdf_url, b.[version], b.license, b.is_oa, b.is_accepted, b.is_published, b.provenance
into #work_best_oa_location
from _work as a
join $(works_json_db_name)..work_best_oa_location as b on a.folder = b.folder and a.record_id = b.record_id
where b.id is not null

create clustered columnstore index idx_tmp_work_best_oa_location on #work_best_oa_location

drop table if exists #work_location3
select a.work_id,
	a.location_seq,
    a.id,
	source_id = replace(a.source_id, 'https://openalex.org/S', ''),
    a.landing_page_url,
    a.pdf_url,
    a.[version],
    a.license,
    a.is_oa,
    a.is_accepted,
    a.is_published,
    a.raw_type,
	a.raw_source_name,
    a.provenance,
	is_primary_location = case when c.work_id is not null then 1 else 0 end,
	is_best_oa_location = case when d.work_id is not null then 1 else 0 end
into #work_location3
from #work_location as a
join #work_location2 as b on a.work_id = b.work_id and a.location_seq = b.location_seq
left join #work_primary_location as c on a.work_id = c.work_id
	and a.id = c.id
	and isnull(a.source_id, '-1') = isnull(c.source_id, '-1')
	and isnull(a.landing_page_url, N'-1') = isnull(c.landing_page_url, N'-1')
	and isnull(a.pdf_url, N'-1') = isnull(c.pdf_url, N'-1')
	and isnull(a.[version], '-1') = isnull(c.[version], '-1')
	and isnull(a.license, '-1') = isnull(c.license, '-1')
	and isnull(a.is_oa, '-1') = isnull(c.is_oa, '-1')
	and isnull(a.is_accepted, '-1') = isnull(c.is_accepted, '-1')
	and isnull(a.is_published, '-1') = isnull(c.is_published, '-1')
left join #work_best_oa_location as d on a.work_id = d.work_id
	and a.id = d.id
	and isnull(a.source_id, '-1') = isnull(d.source_id, '-1')
	and isnull(a.landing_page_url, N'-1') = isnull(d.landing_page_url, N'-1')
	and isnull(a.pdf_url, N'-1') = isnull(d.pdf_url, N'-1')
	and isnull(a.[version], '-1') = isnull(d.[version], '-1')
	and isnull(a.license, '-1') = isnull(d.license, '-1')
	and isnull(a.is_oa, '-1') = isnull(d.is_oa, '-1')
	and isnull(a.is_accepted, '-1') = isnull(d.is_accepted, '-1')
	and isnull(a.is_published, '-1') = isnull(d.is_published, '-1')

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



-- work
drop table if exists work
create table work
(
	work_id bigint not null,
	work_type_id tinyint null,
	source_id bigint null,
	pub_date date null,
	pub_year smallint null,
	volume nvarchar(100) null,
	issue nvarchar(150) null,
	page_first nvarchar(200) null,
	page_last nvarchar(300) null,
	doi varchar(250) null,
	openalex_id varchar(32) not null,
	mag_id bigint null,
	pmid bigint null,
--	pmcid bigint null,
--	arxiv_id varchar(80) null,
	language_iso_alpha2_code char(2) null,
	is_xpac bit not null,
	is_paratext bit null,
	is_retracted bit null,
	is_oa bit null,
	any_repository_has_fulltext bit null,
	oa_status_id tinyint null,
	oa_url nvarchar(2500) null,
	apc_list_currency char(3) null,
	apc_list_price int null,
	apc_list_price_usd int null,
	apc_paid_currency char(3) null,
	apc_paid_price int null,
	apc_paid_price_usd int null,
	has_cwts_required_metadata bit not null,
	is_cwts_extended_pub bit not null,
	is_cwts_core_pub bit null,
	n_refs int not null,
	n_cits int not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into work with(tablock)
select a.work_id,
	c.work_type_id,
	d.source_id,
	b.publication_date,
	b.publication_year,
	b.biblio_volume,
	b.biblio_issue,
	b.biblio_first_page,
	b.biblio_last_page,
	doi = left(replace(b.id_doi, 'https://doi.org/', ''), 250),
	openalex_id = 'W' + cast(a.work_id as varchar(31)),
	mag_id = b.id_mag,
	pmid = case when left(b.id_pmid, 35) <> 'https://pubmed.ncbi.nlm.nih.gov/PMC' then replace(b.id_pmid, 'https://pubmed.ncbi.nlm.nih.gov/', '') else null end,
--	pmcid = replace(b.id_pmcid, 'https://www.ncbi.nlm.nih.gov/pmc/articles/', ''),
--	b.id_arxiv_id,
	e.language_iso_alpha2_code,
	is_xpac = case when b.is_xpac = 'true' then 1 else 0 end,
	b.is_paratext,
	b.is_retracted,
	b.open_access_is_oa,
	b.open_access_any_repository_has_fulltext,
	f.oa_status_id,
	b.open_access_oa_url,
	b.apc_list_currency,
	b.apc_list_value,
	b.apc_list_value_usd,
	b.apc_paid_currency,
	b.apc_paid_value,
	b.apc_paid_value_usd,
	has_cwts_required_metadata = 0,
	is_cwts_extended_pub = 0,
	is_cwts_core_pub = null,
	n_refs = 0,
	n_cits = 0,
	b.updated_date,
	b.created_date
from _work as a
join $(works_json_db_name)..work as b on a.folder = b.folder and a.record_id = b.record_id
left join work_type as c on b.[type] = c.work_type
left join #work_location3 as d on a.work_id = d.work_id and d.is_primary_location = 1
left join _language as e on b.[language] = e.[language]
left join oa_status as f on b.open_access_oa_status = f.oa_status

alter table work add constraint pk_work primary key(work_id)
create index idx_work_work_type_id on work(work_type_id)
create index idx_work_source_id on work(source_id)
create index idx_work_pub_date on work(pub_date)
create index idx_work_pub_year on work(pub_year)
create index idx_work_doi on work(doi)
create index idx_work_openalex_id on work(openalex_id)
create index idx_work_mag_id on work(mag_id)
create index idx_work_pmid on work(pmid)
--create index idx_work_pmcid on work(pmcid)
--create index idx_work_arxiv_id on work(arxiv_id)
create index language_iso_alpha2_code on work(language_iso_alpha2_code)
create index idx_work_is_paratext on work(is_paratext)
create index idx_work_is_retracted on work(is_retracted)
create index idx_work_is_oa on work(is_oa)
create index idx_work_oa_status_id on work(oa_status_id)
create index idx_work_apc_list_currency on work(apc_list_currency)
create index idx_work_apc_paid_currency on work(apc_paid_currency)
create index idx_work_has_cwts_required_metadata on work(has_cwts_required_metadata)
create index idx_work_is_cwts_extended_pub on work(is_cwts_extended_pub)
create index idx_work_is_cwts_core_pub on work(is_cwts_core_pub)
alter table work add constraint fk_work_work_type_id_work_type_work_type_id foreign key(work_type_id) references work_type(work_type_id)
alter table work add constraint fk_work_source_id_source_source_id foreign key(source_id) references [source](source_id)
alter table work add constraint fk_work_language_iso_alpha2_code_language_language_iso_alpha2_code foreign key(language_iso_alpha2_code) references [language](language_iso_alpha2_code)
alter table work add constraint fk_work_oa_status_id_oa_status_oa_status_id foreign key(oa_status_id) references oa_status(oa_status_id)



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



-- raw_type
drop table if exists raw_type
create table raw_type
(
	raw_type_id int identity not null,
	raw_type nvarchar(1000) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'raw_type')
	begin
		set identity_insert raw_type on

		insert into raw_type with(tablock) (raw_type_id, raw_type)
		select raw_type_id, raw_type
		from $(previous_relational_db_name)..raw_type

		set identity_insert raw_type off
	end
end

insert into raw_type with(tablock)
select raw_type = left(raw_type, 1000)
from #work_location3
where raw_type is not null
except
select raw_type
from raw_type
order by raw_type

alter table raw_type add constraint pk_raw_type primary key(raw_type_id)
--create index idx_raw_type on raw_type(raw_type)



-- raw_source_name
drop table if exists raw_source_name
create table raw_source_name
(
	raw_source_name_id int identity not null,
	raw_source_name nvarchar(1000) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'raw_source_name')
	begin
		set identity_insert raw_source_name on

		insert into raw_source_name with(tablock) (raw_source_name_id, raw_source_name)
		select raw_source_name_id, raw_source_name
		from $(previous_relational_db_name)..raw_source_name

		set identity_insert raw_source_name off
	end
end

insert into raw_source_name with(tablock)
select raw_source_name = left(raw_source_name, 1000)
from #work_location3
where raw_source_name is not null
except
select raw_source_name
from raw_source_name
order by raw_source_name

alter table raw_source_name add constraint pk_raw_source_name primary key(raw_source_name_id)
--create index idx_raw_source_name on raw_source_name(raw_source_name)



-- provenance
drop table if exists provenance
create table provenance
(
	provenance_id tinyint identity not null,
	provenance varchar(10) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'provenance')
	begin
		set identity_insert provenance on

		insert into provenance with(tablock) (provenance_id, provenance)
		select provenance_id, provenance
		from $(previous_relational_db_name)..provenance

		set identity_insert provenance off
	end
end

insert into provenance with(tablock)
select provenance
from #work_location3
where provenance is not null
except
select provenance
from provenance
order by provenance

alter table provenance add constraint pk_provenance primary key(provenance_id)
create index idx_provenance on provenance(provenance)



-- work_location
drop table if exists work_location
create table work_location
(
	work_id bigint not null,
	location_seq smallint not null,
	is_primary_location bit not null,
	is_best_oa_location bit not null,
	id nvarchar(325) not null,
	source_id bigint null,
	landing_page_url varchar(2000) null,
	pdf_url varchar(2000) null,
	version_id tinyint null,
	license_id tinyint null,
	raw_type_id int null,
	raw_source_name_id int null,
	provenance_id tinyint null,
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
	a.id,
	a.source_id,
	landing_page_url = left(a.landing_page_url, 2000),
	pdf_url = left(a.pdf_url, 2000),
	b.version_id,
	c.license_id,
	d.raw_type_id,
	e.raw_source_name_id,
	f.provenance_id,
	a.is_oa,
	a.is_accepted,
	a.is_published
from #work_location3 as a
left join [version] as b on a.[version] = b.[version]
left join license as c on a.license = c.license
left join raw_type as d on left(a.raw_type, 1000) = d.raw_type
left join raw_source_name as e on left(a.raw_source_name, 1000) = e.raw_source_name
left join provenance as f on a.provenance = f.provenance

alter table work_location add constraint pk_work_location primary key(work_id, location_seq)
create index idx_work_location_is_primary_location on work_location(is_primary_location)
create index idx_work_location_is_best_oa_location on work_location(is_best_oa_location)
create index idx_work_location_source_id on work_location(source_id)
create index idx_work_location_version_id on work_location(version_id)
create index idx_work_location_license_id on work_location(license_id)
create index idx_work_location_raw_type_id on work_location(raw_type_id)
create index idx_work_location_raw_source_name_id on work_location(raw_source_name_id)
create index idx_work_location_provenance_id on work_location(provenance_id)
create index idx_work_location_is_oa on work_location(is_oa)
create index idx_work_location_is_accepted on work_location(is_accepted)
create index idx_work_location_is_published on work_location(is_published)
alter table work_location add constraint fk_work_location_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_location add constraint fk_work_location_source_id_source_source_id foreign key(source_id) references [source](source_id)
alter table work_location add constraint fk_work_location_version_id_version_version_id foreign key(version_id) references [version](version_id)
alter table work_location add constraint fk_work_location_license_id_license_license_id foreign key(license_id) references license(license_id)
alter table work_location add constraint fk_work_location_raw_type_id_raw_type_raw_type_id foreign key(raw_type_id) references raw_type(raw_type_id)
alter table work_location add constraint fk_work_location_raw_source_name_id_raw_source_name_raw_source_name_id foreign key(raw_source_name_id) references raw_source_name(raw_source_name_id)
alter table work_location add constraint fk_work_location_provenance_id_provenance_provenance_id foreign key(provenance_id) references provenance(provenance_id)



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
	trim($(etl_db_name).dbo.regex_replace($(etl_db_name).dbo.remove_html_tags($(etl_db_name).dbo.decode_html_characters2(b.title)), '[\r\n\t]', ' '))
from _work as a
join $(works_json_db_name)..work as b on a.folder = b.folder and a.record_id = b.record_id
where b.title is not null

delete a with(tablock)
from work_title as a
where len(a.title) = 0

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
	trim($(etl_db_name).dbo.regex_replace($(etl_db_name).dbo.remove_html_tags($(etl_db_name).dbo.decode_html_characters2(b.abstract)), '[\r\n\t]', ' '))
from _work as a
join $(works_json_db_name)..work_abstract as b on a.folder = b.folder and a.record_id = b.record_id
where b.abstract is not null

delete a with(tablock)
from work_abstract as a
where len(a.abstract) = 0

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



-- work_award
drop table if exists work_award
create table work_award
(
	work_id bigint not null,
	award_seq smallint not null,
	award_id bigint not null
)
go

insert into work_award with(tablock)
select a.work_id,
	award_seq = row_number() over (partition by a.work_id order by b.awards_seq),
	c.award_id
from _work as a
join $(works_json_db_name)..work_awards as b on a.folder = b.folder and a.record_id = b.record_id
join award as c on cast(replace(b.id, 'https://openalex.org/G', '') as bigint) = c.award_id

alter table work_award add constraint pk_work_award primary key(work_id, award_seq)
create index idx_work_award_award_id on work_award(award_id)
alter table work_award add constraint fk_work_award_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_award add constraint fk_work_award_award_id_award_award_id foreign key(award_id) references award(award_id)



alter table award_work add constraint fk_award_work_work_id_work_work_id foreign key(work_id) references work(work_id)



-- work_funder
drop table if exists work_funder
create table work_funder
(
    work_id bigint not null,
    funder_seq smallint not null,
    funder_id bigint not null
)
go

insert into work_funder with(tablock)
select a.work_id,
	b.funder_seq,
	funder_id = replace(b.id, 'https://openalex.org/F', '')
from _work as a
join $(works_json_db_name)..work_funder as b on a.folder = b.folder and a.record_id = b.record_id

alter table work_funder add constraint pk_work_funder primary key(work_id, funder_seq)
create index idx_work_funder_funder_id on work_funder(funder_id)
alter table work_funder add constraint fk_work_funder_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_funder add constraint fk_work_funder_funder_id_funder_funder_id foreign key(funder_id) references funder(funder_id)



-- work_sdg
drop table if exists work_sdg
create table work_sdg
(
	work_id bigint not null,
	sdg_seq smallint not null,
	sdg_id tinyint not null,
	score float not null
)
go

insert into work_sdg with(tablock)
select a.work_id,
	sdg_seq = b.sustainable_development_goal_seq,
	sdg_id = replace(b.id, 'https://metadata.un.org/sdg/', ''),
	b.score
from _work as a
join $(works_json_db_name)..work_sustainable_development_goal as b on a.folder = b.folder and a.record_id = b.record_id

alter table work_sdg add constraint pk_work_sdg primary key(work_id, sdg_seq)
create index idx_work_sdg_sdg_id on work_sdg(sdg_id)
alter table work_sdg add constraint fk_work_sdg_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_sdg add constraint fk_work_sdg_sdg_id_sdg_sdg_id foreign key(sdg_id) references sdg(sdg_id)



drop table if exists #keyword;
select keyword_id, id = 'https://openalex.org/keywords/' + openalex_id
into #keyword
from keyword;
create unique clustered index #ux_keyword on #keyword(id)



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
inner merge join $(works_json_db_name)..work_keyword as b on a.folder = b.folder and a.record_id = b.record_id
inner hash join #keyword as c on b.id = c.id

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



-- index
drop table if exists [index]
create table [index]
(
	index_id int not null identity(1, 1),
	[index] varchar(20) not null,
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'data_source')
	begin
		set identity_insert [index] on

		insert into [index] with(tablock) (index_id, [index])
		select data_source_id, [data_source]
		from $(previous_relational_db_name)..[data_source]

		set identity_insert [index] off
	end
end

insert into [index] with(tablock)
select [index] = indexed_in
from $(works_json_db_name)..work_indexed_in
where indexed_in is not null
except
select [index]
from [index]
order by [index]

alter table [index] add constraint pk_index primary key(index_id)
create index idx_index_index on [index]([index])



-- work_index
drop table if exists work_index
create table work_index
(
	work_id bigint not null,
	index_seq smallint not null,
	index_id int not null
)
go

insert into work_index with(tablock)
select a.work_id,
	index_seq = b.indexed_in_seq,
	c.index_id
from _work as a
join $(works_json_db_name)..work_indexed_in as b on a.folder = b.folder and a.record_id = b.record_id
join [index] as c on b.indexed_in = c.[index]

alter table work_index add constraint pk_work_index primary key(work_id, index_seq)
create index idx_work_index_index_id on work_index(index_id)
alter table work_index add constraint fk_work_index_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_index add constraint fk_work_index_index_id_index_index_id foreign key(index_id) references [index](index_id)
