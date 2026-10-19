set nocount on

-- source
drop table if exists [source]
create table [source]
(
	source_id bigint not null,
	[source] nvarchar(800) null,
	source_type_id tinyint null,
	country_iso_alpha2_code char(2) null,
	host_organization_publisher_id bigint null,
	host_organization_institution_id bigint null,
	homepage_url varchar(600) null,
	is_preprint_repository bit null,
	issn_l char(9) null,
	openalex_id varchar(11) not null,
	mag_id bigint null,
	wikidata_id varchar(10) null,
	first_publication_year smallint null,
	last_publication_year smallint null,
	is_oa bit null,
	has_high_oa_rate bit null,
	has_high_oa_rate_since_year smallint null,
	oa_flip_year smallint null,
	is_in_doaj bit null,
	is_in_doaj_since_year smallint null,
	is_in_scielo bit null,
	is_ojs bit null,
	apc_price_usd int null,
	is_cwts_core_source bit null,
	updated_date date null,
	created_date datetime2 null	
)
go

insert into [source] with(tablock)
select a.source_id,
	b.display_name,
	c.source_type_id,
	country_iso_alpha2_code = e.country_iso_alpha2_code,
	host_organization_publisher_id = case when patindex('https://openalex.org/P%', b.host_organization) > 0 then replace(b.host_organization, 'https://openalex.org/P', '') else null end,
	host_organization_institution_id = case when patindex('https://openalex.org/I%', b.host_organization) > 0 then replace(b.host_organization, 'https://openalex.org/I', '') else null end,
	homepage_url = case when len(b.homepage_url) <= 600 then b.homepage_url else null end,
	is_preprint_repository = case when b.is_preprint_repository = 'true' then 1 when b.is_preprint_repository = 'false' then 0 else null end,
	issn_l = case when len(b.issn_l) = 9 then b.issn_l else null end,
	openalex_id = 'S' + cast(a.source_id as varchar(10)),
	mag_id = b.id_mag,
	wikidata_id = replace(replace(replace(b.id_wikidata, 'https://www.wikidata.org/entity/', ''), 'http://www.wikidata.org/entity/', ''), 'https://www.wikidata.org/wiki/', ''),
	b.first_publication_year,
	b.last_publication_year,
	b.is_oa,
	b.is_high_oa_rate,
	b.is_high_oa_rate_since_year,
	b.oa_flip_year,
	b.is_in_doaj,
	b.is_in_doaj_since_year,
	b.is_in_scielo,
	b.is_ojs,
	b.apc_usd,
	is_cwts_core_source = null,
	b.updated_date,
	b.created_date
from _source as a
join $(sources_json_db_name)..[source] as b on a.folder = b.folder and a.record_id = b.record_id
left join source_type as c on b.[type] = c.source_type
left join $(geonames_db_name)..country as d on b.country_code = d.country_iso3_code
left join country as e on isnull(d.country_iso2_code, b.country_code) = e.country_iso_alpha2_code

drop table if exists #source_from_work
select source_id, openalex_id, [source]
into #source_from_work
from
(
	select source_id = replace(source_id, 'https://openalex.org/S', ''),
		openalex_id = replace(source_id, 'https://openalex.org/', ''),
		[source] = source_display_name,
		[filter] = row_number() over (partition by source_id order by count(*) desc, source_display_name)
	from $(works_json_db_name)..work_location
	where patindex('https://openalex.org/S%', source_id) > 0
	group by source_id, source_display_name
) as a
where [filter] = 1

insert into [source] with(tablock) (source_id, openalex_id, [source])
select a.source_id, a.openalex_id, a.[source]
from #source_from_work as a
left join [source] as b on a.source_id = b.source_id
where b.source_id is null

drop table if exists #source_from_institution
select distinct source_id = replace(id, 'https://openalex.org/S', ''), openalex_id = replace(id, 'https://openalex.org/', ''), [source] = display_name
into #source_from_institution
from $(institutions_json_db_name)..institution_repository

insert into [source] with(tablock) (source_id, openalex_id, [source])
select a.source_id, a.openalex_id, a.[source]
from #source_from_institution as a
left join [source] as b on a.source_id = b.source_id
where b.source_id is null

alter table [source] add constraint pk_source primary key(source_id)
create index idx_source_source on [source]([source])
create index idx_source_source_type_id on [source](source_type_id)
create index idx_source_country_iso_alpha2_code on [source](country_iso_alpha2_code)
create index idx_source_host_organization_publisher_id on [source](host_organization_publisher_id)
create index idx_source_host_organization_institution_id on [source](host_organization_institution_id)
create index idx_source_issn_l on [source](issn_l)
create index idx_source_openalex_id on [source](openalex_id)
create index idx_source_mag_id on [source](mag_id)
create index idx_source_wikidata_id on [source](wikidata_id)
create index idx_source_first_publication_year on [source](first_publication_year)
create index idx_source_last_publication_year on [source](last_publication_year)
create index idx_source_is_oa on [source](is_oa)
create index idx_source_has_high_oa_rate on [source](has_high_oa_rate)
create index idx_source_has_high_oa_rate_since_year on [source](has_high_oa_rate_since_year)
create index idx_source_oa_flip_year on [source](oa_flip_year)
create index idx_source_is_in_doaj on [source](is_in_doaj)
create index idx_source_is_in_doaj_since_year on [source](is_in_doaj_since_year)
create index idx_source_is_in_scielo on [source](is_in_scielo)
create index idx_source_is_ojs on [source](is_ojs)
create index idx_source_apc_price_usd on [source](apc_price_usd)
create index idx_source_is_cwts_core_source on [source](is_cwts_core_source)
alter table [source] add constraint fk_source_source_type_id_source_type_source_type_id foreign key(source_type_id) references source_type(source_type_id)
alter table [source] add constraint fk_source_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)
alter table [source] add constraint fk_source_host_organization_publisher_id_publisher_publisher_id foreign key(host_organization_publisher_id) references publisher(publisher_id)
alter table [source] add constraint fk_source_host_organization_institution_id_institution_institution_id foreign key(host_organization_institution_id) references institution(institution_id)



alter table institution_repository add constraint fk_institution_repository_source_id_source_source_id foreign key(repository_source_id) references [source](source_id)



-- source_issn
drop table if exists source_issn
create table source_issn
(
	source_id bigint not null,
	issn_seq smallint not null,
	issn char(9) not null
)
go

insert into source_issn with(tablock)
select a.source_id,
	b.issn_seq,
	issn = replace(replace(issn, 'issn-l: ', ''), ' ', '')
from _source as a
join $(sources_json_db_name)..source_issn as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_issn add constraint pk_source_issn primary key(source_id, issn_seq)
create index idx_source_issn_issn on source_issn(issn)
alter table source_issn add constraint fk_source_issn_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_alternative_title
drop table if exists source_alternative_title
create table source_alternative_title
(
	source_id bigint not null,
	alternative_title_seq smallint not null,
	alternative_title nvarchar(700) not null
)
go

insert into source_alternative_title with(tablock)
select a.source_id,
	b.alternate_title_seq,
	b.alternate_title
from _source as a
join $(sources_json_db_name)..source_alternate_title as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_alternative_title add constraint pk_source_alternative_title primary key(source_id, alternative_title_seq)
alter table source_alternative_title add constraint fk_source_alternative_title_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_society
drop table if exists source_society
create table source_society
(
	source_id bigint not null,
	society_seq smallint not null,
	society nvarchar(500) not null,
	homepage_url varchar(600) null
)
go

insert into source_society with(tablock)
select a.source_id, b.society_seq, b.organization, b.url
from _source as a
join $(sources_json_db_name)..source_society as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_society add constraint pk_source_society primary key(source_id, society_seq)
create index idx_source_society_society on source_society(society)
alter table source_society add constraint fk_source_society_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_apc_price
drop table if exists source_apc_price
create table source_apc_price
(
	source_id bigint not null,
	apc_price_seq smallint not null,
	apc_price int not null,
	currency char(3) not null
)
go

insert into source_apc_price with(tablock)
select a.source_id, b.apc_price_seq, b.price, b.currency
from _source as a
join $(sources_json_db_name)..source_apc_price as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_apc_price add constraint pk_source_apc_price primary key(source_id, apc_price_seq)
create index idx_source_apc_price_currency on source_apc_price(currency)
alter table source_apc_price add constraint fk_source_apc_price_source_id_source_source_id foreign key(source_id) references [source](source_id)



-- source_apc_year_price_usd
drop table if exists source_year_apc_price_usd
create table source_year_apc_price_usd
(
	source_id bigint not null,
	[year] smallint not null,
	apc_price_usd int not null
)
go

insert into source_year_apc_price_usd with(tablock)
select a.source_id, b.[year], b.price
from _source as a
join $(sources_json_db_name)..source_apc_usd_by_year as b on a.folder = b.folder and a.record_id = b.record_id

alter table source_year_apc_price_usd add constraint pk_source_year_apc_price_usd primary key(source_id, [year])
alter table source_year_apc_price_usd add constraint fk_source_year_apc_price_usd_source_id_source_source_id foreign key(source_id) references [source](source_id)
