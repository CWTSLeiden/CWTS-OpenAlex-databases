set nocount on

drop table if exists #institution_funder
select a.institution_id, funder_id = replace(b.id, 'https://openalex.org/F', '')
into #institution_funder
from _institution as a
join $(institutions_json_db_name)..institution_role as b on a.record_id = b.record_id
where b.[role] = 'funder'
union
select institution_id = replace(b.id, 'https://openalex.org/I', ''), a.funder_id
from _funder as a
join $(funders_json_db_name)..funder_role as b on a.record_id = b.record_id
where b.[role] = 'institution'

drop table if exists #institution_publisher
select a.institution_id, publisher_id = replace(b.id, 'https://openalex.org/P', '')
into #institution_publisher
from _institution as a
join $(institutions_json_db_name)..institution_role as b on a.record_id = b.record_id
where b.[role] = 'publisher'
union
select institution_id = replace(b.id, 'https://openalex.org/I', ''), a.publisher_id
from _publisher as a
join $(publishers_json_db_name)..publisher_role as b on a.record_id = b.record_id
where b.[role] = 'institution'

drop table if exists #funder_publisher
select a.funder_id, publisher_id = replace(b.id, 'https://openalex.org/P', '')
into #funder_publisher
from _funder as a
join $(funders_json_db_name)..funder_role as b on a.record_id = b.record_id
where b.[role] = 'publisher'
union
select funder_id = replace(b.id, 'https://openalex.org/F', ''), a.publisher_id
from _publisher as a
join $(publishers_json_db_name)..publisher_role as b on a.record_id = b.record_id
where b.[role] = 'funder'
union
select distinct a.funder_id, b.publisher_id
from #institution_funder as a
join #institution_publisher as b on a.institution_id = b.institution_id



-- institution_funder
drop table if exists institution_funder
create table institution_funder
(
	institution_id bigint not null,
	funder_seq smallint not null,
	funder_id bigint not null
)

insert into institution_funder with(tablock)
select a.institution_id,
	funder_seq = row_number() over (partition by a.institution_id order by a.funder_id),
	a.funder_id
from #institution_funder as a
join institution as b on a.institution_id = b.institution_id
join funder as c on a.funder_id = c.funder_id

alter table institution_funder add constraint pk_institution_funder primary key(institution_id, funder_seq)
create index idx_institution_funder_funder_id on institution_funder(funder_id)
alter table institution_funder add constraint fk_institution_funder_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)
alter table institution_funder add constraint fk_institution_funder_funder_id_funder_funder_id foreign key(funder_id) references funder(funder_id)



-- institution_publisher
drop table if exists institution_publisher
create table institution_publisher
(
	institution_id bigint not null,
	publisher_seq smallint not null,
	publisher_id bigint not null
)

insert into institution_publisher with(tablock)
select a.institution_id,
	publisher_seq = row_number() over (partition by a.institution_id order by a.publisher_id),
	a.publisher_id
from #institution_publisher as a
join institution as b on a.institution_id = b.institution_id
join publisher as c on a.publisher_id = c.publisher_id

alter table institution_publisher add constraint pk_institution_publisher primary key(institution_id, publisher_seq)
create index idx_institution_publisher_publisher_id on institution_publisher(publisher_id)
alter table institution_publisher add constraint fk_institution_publisher_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)
alter table institution_publisher add constraint fk_institution_publisher_publisher_id_publisher_publisher_id foreign key(publisher_id) references publisher(publisher_id)



-- funder_publisher
drop table if exists funder_publisher
create table funder_publisher
(
	funder_id bigint not null,
	publisher_seq smallint not null,
	publisher_id bigint not null
)

insert into funder_publisher with(tablock)
select a.funder_id,
	publisher_seq = row_number() over (partition by a.funder_id order by a.publisher_id),
	a.publisher_id
from #funder_publisher as a
join funder as b on a.funder_id = b.funder_id
join publisher as c on a.publisher_id = c.publisher_id

alter table funder_publisher add constraint pk_funder_publisher primary key(funder_id, publisher_seq)
create index idx_funder_publisher_publisher_id on funder_publisher(publisher_id)
alter table funder_publisher add constraint fk_funder_publisher_funder_id_funder_funder_id foreign key(funder_id) references funder(funder_id)
alter table funder_publisher add constraint fk_funder_publisher_publisher_id_publisher_publisher_id foreign key(publisher_id) references publisher(publisher_id)
