set nocount on

-- continent
drop table if exists continent
create table continent
(
	continent_id int not null,
	continent varchar(15) not null,
	openalex_id varchar(11) not null,
	wikidata_id varchar(6) not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into continent with(tablock)
select a.continent_id,
	continent = b.display_name,
	openalex_id = 'Q' + cast(a.continent_id as varchar(10)),
	wikidata_id = b.id_wikidata,
	b.updated_date,
	b.created_date
from _continent as a
join $(continents_json_db_name)..continent as b on a.folder = b.folder and a.record_id = b.record_id

alter table continent add constraint pk_continent primary key(continent_id)
create index idx_continent_continent on continent(continent)
create index idx_continent_openalex_id on continent(openalex_id)
create index idx_continent_wikidata_id on continent(wikidata_id)
