set nocount on

drop table if exists #language
select
	language_iso_alpha2_code = replace(id, 'https://openalex.org/languages/', ''),
	[language] = display_name,
	openalex_id = replace(id, 'https://openalex.org/languages/', ''),
	updated_date,
	created_date
into #language
from $(languages_json_db_name)..[language]



-- language
drop table if exists [language]
create table [language]
(
	language_iso_alpha2_code char(2) not null,
	[language] varchar(100) not null,
	openalex_id char(2) not null,
	updated_date date null,
	created_date datetime2 null
)
go

insert into [language] with(tablock)
select a.language_iso_alpha2_code, a.[language], a.language_iso_alpha2_code, b.updated_date, b.created_date
from
(
	select distinct language_iso_alpha2_code, [language] = language_name
	from _language
) as a
left join #language as b on a.language_iso_alpha2_code = b.language_iso_alpha2_code

alter table [language] add constraint pk_language primary key(language_iso_alpha2_code)
create index idx_language_language on [language]([language])
