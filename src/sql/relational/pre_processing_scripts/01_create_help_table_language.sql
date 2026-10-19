set nocount on

drop table if exists #openalex_language
select iso1 = replace(id, 'https://openalex.org/languages/', ''), language_name = display_name
into #openalex_language
from $(languages_json_db_name)..[language]

drop table if exists #language_mapping1
select [language], n_works = count(*), n_works_non_xpac = sum(case when is_xpac = 'false' then 1 else 0 end)
into #language_mapping1
from $(works_json_db_name)..work
where [language] is not null
group by [language]

drop table if exists #manual_language_mapping
create table #manual_language_mapping ([language] nvarchar(10), cleaned_language nvarchar(10))
insert into #manual_language_mapping
values
    ('en-us', 'en'),
    ('en-gb', 'en'),
    ('zh-cn', 'zh'),
    ('zh-tw', 'zh'),
	(N'中文', 'zh'),
	(N'英语', 'en'),
	(N'英文', 'en'),
	(N'日文', 'ja'),
	(N'俄文', 'ru'),
	(N'영어', 'en'),
	('cn', 'zh'),
	('jp', 'ja'),
	('re', 'fr'),
	('ua', 'uk'),
    ('als', 'sq'),
	('english', 'en'),
	('ingles', 'en'),
	('Englisch', 'en'),
	('Deutsch', 'de'),
	('Greek', 'el'),
	('Spanish', 'es')

drop table if exists #language_mapping2
select a.*,
	cleaned_language = lower(isnull(b.cleaned_language, a.[language])),
	openalex_iso1 = c.iso1,
	openalex_language_name = c.language_name,
	geonames_iso1 = coalesce(d.iso1, e.iso1, f.iso1),
	geonames_iso2 = left(coalesce(d.iso2, e.iso2, f.iso2), 3),
	geonames_iso3 = coalesce(d.iso3, e.iso3, f.iso3),
	geonames_language_name = coalesce(d.language_name, e.language_name, f.language_name)
into #language_mapping2
from #language_mapping1 as a
left join #manual_language_mapping as b on a.[language] = b.[language]
left join #openalex_language as c on isnull(b.cleaned_language, a.[language]) = c.iso1
left join $(geonames_db_name)..[language] as d on isnull(b.cleaned_language, a.[language]) = d.iso1
left join $(geonames_db_name)..[language] as e on isnull(b.cleaned_language, a.[language]) = e.iso2
left join $(geonames_db_name)..[language] as f on isnull(b.cleaned_language, a.[language]) = f.iso3

drop table if exists _language
create table _language
(
    [language] nvarchar(10) not null,
    language_iso_alpha2_code char(2) not null,
    language_name varchar(100) not null
)
go

insert into _language with(tablock)
select [language],
	language_iso_alpha2_code = coalesce(openalex_iso1, geonames_iso1),
	language_name = coalesce(openalex_language_name, geonames_language_name)
from #language_mapping2
where coalesce(openalex_iso1, geonames_iso1) is not null

alter table _language add constraint pk_tmp_language primary key([language])
create index idx_tmp_language_language_iso_alpha2_code on _language(language_iso_alpha2_code)
go
