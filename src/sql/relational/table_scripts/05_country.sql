set nocount on

-- country
drop table if exists country
create table country
(
	country_iso_alpha2_code char(2) not null,
	country varchar(50) null
)
go

insert into country with(tablock) (country_iso_alpha2_code)
select geo_country_code
from $(institutions_json_db_name)..institution
where geo_country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select country_code
from $(funders_json_db_name)..funder
where country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select isnull(b.country_iso2_code, a.country_code)
from $(publishers_json_db_name)..publisher_country_code as a
left join $(geonames_db_name)..country as b on a.country_code = b.country_iso3_code
where a.country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select isnull(b.country_iso2_code, a.country_code)
from $(sources_json_db_name)..[source] as a
left join $(geonames_db_name)..country as b on a.country_code = b.country_iso3_code
where a.country_code is not null
except
select country_iso_alpha2_code
from country

insert into country with(tablock) (country_iso_alpha2_code)
select country
from $(works_json_db_name)..work_authorship_country
where country is not null
except
select country_iso_alpha2_code
from country

update a
set a.country = b.country
from country as a
join
(
	select country_iso_alpha2_code = geo_country_code, country = geo_country, [filter] = row_number() over (partition by geo_country_code order by count(*) desc)
	from $(institutions_json_db_name)..institution
	where geo_country_code is not null
		and geo_country is not null
	group by geo_country_code, geo_country
) as b on a.country_iso_alpha2_code = b.country_iso_alpha2_code
	and b.[filter] = 1

update a
set a.country = b.[name]
from country as a
join $(geonames_db_name)..country as b on a.country_iso_alpha2_code = b.country_iso2_code
where a.country is null

alter table country add constraint pk_country primary key(country_iso_alpha2_code)
create index idx_country_country on country(country)
