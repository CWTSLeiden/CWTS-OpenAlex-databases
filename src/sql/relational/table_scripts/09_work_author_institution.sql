set nocount on

drop table if exists #work_author
select a.work_id,
	author_seq = b.authorship_seq,
	author_id = replace(b.author_id, 'https://openalex.org/A', ''),
	b.author_position,
	b.is_corresponding,
	raw_author_name = cast(left(b.raw_author_name, 800) as nvarchar(800)),
	raw_affiliation_string = cast(left(b.raw_affiliation_string, 800) as nvarchar(800))
into #work_author
from _work as a
join $(works_json_db_name)..work_authorship as b on a.folder = b.folder and a.record_id = b.record_id

create clustered columnstore index idx_tmp_work_author on #work_author

drop table if exists #work_author_raw_affiliation_string
select a.work_id,
	author_seq = b.authorship_seq,
	b.raw_affiliation_string_seq,
	raw_affiliation_string = cast(left(b.raw_affiliation_string, 800) as nvarchar(800))
into #work_author_raw_affiliation_string
from _work as a
join $(works_json_db_name)..work_authorship_raw_affiliation_string as b on a.folder = b.folder and a.record_id = b.record_id

create clustered columnstore index idx_tmp_work_author_raw_affiliation_string on #work_author_raw_affiliation_string

declare @n_records_with_missing_raw_affiliation_strings as int

select @n_records_with_missing_raw_affiliation_strings = count(*)
from #work_author as a
left join #work_author_raw_affiliation_string as b on a.work_id = b.work_id and a.author_seq = b.author_seq
where a.raw_affiliation_string is not null
	and b.work_id is null

if @n_records_with_missing_raw_affiliation_strings > 0
begin
	raiserror('Info: Check work_author_raw_affiliation_string.', 2, 1)
	print 'Number of work-author records with missing missing_raw_affiliation_string data: ' + cast(@n_records_with_missing_raw_affiliation_strings as varchar(10))
end



-- author_position
drop table if exists author_position
create table author_position
(
	author_position_id tinyint not null identity(1, 1),
	author_position varchar(6) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'author_position')
	begin
		set identity_insert author_position on

		insert into author_position with(tablock) (author_position_id, author_position)
		select author_position_id, author_position
		from $(previous_relational_db_name)..author_position

		set identity_insert author_position off
	end
end

insert into author_position with(tablock)
select author_position = 'first'
except
select author_position
from author_position

insert into author_position with(tablock)
select author_position = 'middle'
except
select author_position
from author_position

insert into author_position with(tablock)
select author_position = 'last'
except
select author_position
from author_position

insert into author_position with(tablock)
select author_position
from #work_author
where author_position is not null
except
select author_position
from author_position
order by author_position

alter table author_position add constraint pk_author_position primary key(author_position_id)
create index idx_author_position_author_position on author_position(author_position)



-- raw_author_name
drop table if exists raw_author_name
create table raw_author_name
(
	raw_author_name_id int not null identity(1, 1),
	raw_author_name nvarchar(800) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'raw_author_name')
	begin
		set identity_insert raw_author_name on

		insert into raw_author_name with(tablock) (raw_author_name_id, raw_author_name)
		select raw_author_name_id, raw_author_name
		from $(previous_relational_db_name)..raw_author_name

		set identity_insert raw_author_name off
	end
end

insert into raw_author_name with(tablock)
select raw_author_name
from #work_author
where raw_author_name is not null
except
select raw_author_name
from raw_author_name
order by raw_author_name

alter table raw_author_name add constraint pk_raw_author_name primary key(raw_author_name_id)
create index idx_raw_author_name_raw_author_name on raw_author_name(raw_author_name)



-- raw_affiliation_string
drop table if exists raw_affiliation_string
create table raw_affiliation_string
(
	raw_affiliation_string_id int not null identity(1, 1),
	raw_affiliation_string nvarchar(800) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'raw_affiliation_string')
	begin
		set identity_insert raw_affiliation_string on

		insert into raw_affiliation_string with(tablock) (raw_affiliation_string_id, raw_affiliation_string)
		select raw_affiliation_string_id, raw_affiliation_string
		from $(previous_relational_db_name)..raw_affiliation_string

		set identity_insert raw_affiliation_string off
	end
end

insert into raw_affiliation_string with(tablock)
select raw_affiliation_string
from #work_author_raw_affiliation_string
where raw_affiliation_string is not null
except
select raw_affiliation_string
from raw_affiliation_string
order by raw_affiliation_string

alter table raw_affiliation_string add constraint pk_raw_affiliation_string primary key(raw_affiliation_string_id)
create index idx_raw_affiliation_string_raw_affiliation_string on raw_affiliation_string(raw_affiliation_string)



-- work_author
drop table if exists work_author
create table work_author
(
	work_id bigint not null,
	author_seq smallint not null,
	author_id bigint null,
	author_position_id tinyint null,
	is_corresponding_author bit null,
	raw_author_name_id int null
)
go

insert into work_author with(tablock)
select a.work_id,
	a.author_seq,
	a.author_id,
	b.author_position_id,
	a.is_corresponding,
	c.raw_author_name_id
from #work_author as a
left join author_position as b on a.author_position = b.author_position
left join raw_author_name as c on a.raw_author_name = c.raw_author_name

alter table work_author add constraint pk_work_author primary key(work_id, author_seq)
create index idx_work_author_author_id on work_author(author_id)
create index idx_work_author_is_corresponding_author on work_author(is_corresponding_author)
create index idx_work_author_raw_author_name_raw_author_name_id on work_author(raw_author_name_id)
alter table work_author add constraint fk_work_author_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_author add constraint fk_work_author_author_id_author_author_id foreign key(author_id) references author(author_id)
alter table work_author add constraint fk_work_author_author_position_id_author_position_author_position_id foreign key(author_position_id) references author_position(author_position_id)
alter table work_author add constraint fk_work_author_raw_author_name_id_raw_author_name_raw_author_name_id foreign key(raw_author_name_id) references raw_author_name(raw_author_name_id)



-- work_author_country
drop table if exists work_author_country
create table work_author_country
(
	work_id bigint not null,
	author_seq smallint not null,
	country_seq smallint not null,
	country_iso_alpha2_code char(2) not null
)
go

insert into work_author_country with(tablock)
select a.work_id,
	author_seq = b.authorship_seq,
	c.country_seq,
	country_iso_alpha2_code = c.country
from _work as a
join $(works_json_db_name)..work_authorship as b on a.folder = b.folder and a.record_id = b.record_id
join $(works_json_db_name)..work_authorship_country as c on a.folder = c.folder and a.record_id = c.record_id and b.authorship_seq = c.authorship_seq

alter table work_author_country add constraint pk_work_author_country primary key(work_id, author_seq, country_seq)
create index idx_work_author_country_country_iso_alpha2_code on work_author_country(country_iso_alpha2_code)
alter table work_author_country add constraint fk_work_author_country_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_author_country add constraint fk_work_author_country_work_id_author_seq_work_author_work_id_author_seq foreign key(work_id, author_seq) references work_author(work_id, author_seq)
alter table work_author_country add constraint fk_work_author_country_country_iso_alpha2_code_country_country_iso_alpha2_code foreign key(country_iso_alpha2_code) references country(country_iso_alpha2_code)



-- work_author_raw_affiliation_string
drop table if exists work_author_raw_affiliation_string
create table work_author_raw_affiliation_string
(
	work_id bigint not null,
	author_seq smallint not null,
	raw_affiliation_string_seq smallint not null,
	raw_affiliation_string_id int not null
)
go

insert into work_author_raw_affiliation_string with(tablock)
select a.work_id,
	a.author_seq,
	a.raw_affiliation_string_seq,
	b.raw_affiliation_string_id
from #work_author_raw_affiliation_string as a
join raw_affiliation_string as b on a.raw_affiliation_string = b.raw_affiliation_string

alter table work_author_raw_affiliation_string add constraint pk_work_author_raw_affiliation_string primary key(work_id, author_seq, raw_affiliation_string_seq)
create index idx_work_author_raw_affiliation_string_raw_affiliation_string_id on work_author_raw_affiliation_string(raw_affiliation_string_id)
alter table work_author_raw_affiliation_string add constraint fk_work_author_raw_affiliation_string_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_author_raw_affiliation_string add constraint fk_work_author_raw_affiliation_string_work_id_author_seq_work_author_work_id_author_seq foreign key(work_id, author_seq) references work_author(work_id, author_seq)
alter table work_author_raw_affiliation_string add constraint fk_work_author_raw_affiliation_string_raw_affiliation_string_id_raw_affiliation_string_raw_affiliation_string_id foreign key(raw_affiliation_string_id) references raw_affiliation_string(raw_affiliation_string_id)



drop table if exists #work_author_institution
select a.work_id,
	author_institution_seq = row_number() over (partition by a.work_id order by b.authorship_seq, c.institution_seq),
	author_seq = b.authorship_seq,
	institution_seq_org = c.institution_seq,
	institution_id = replace(c.id, 'https://openalex.org/I', ''),
	institution_name = case when c.id is null then cast(left(c.display_name, 800) as nvarchar(800)) else null end
into #work_author_institution
from _work as a
join $(works_json_db_name)..work_authorship as b on a.folder = b.folder and a.record_id = b.record_id
join $(works_json_db_name)..work_authorship_institution as c on a.folder = c.folder and a.record_id = c.record_id and b.authorship_seq = c.authorship_seq



-- institution_name
drop table if exists institution_name
create table institution_name
(
	institution_name_id int not null identity(1, 1),
	institution_name nvarchar(800) not null
)
go

if exists (select * from master.dbo.sysdatabases where name = '$(previous_relational_db_name)')
begin
	if exists (select * from $(previous_relational_db_name).sys.tables where [name] = 'institution_name')
	begin
		set identity_insert institution_name on

		insert into institution_name with(tablock) (institution_name_id, institution_name)
		select institution_name_id, institution_name
		from $(previous_relational_db_name)..institution_name

		set identity_insert institution_name off
	end
end

insert into institution_name with(tablock)
select institution_name
from #work_author_institution
where institution_name is not null
except
select institution_name
from institution_name
order by institution_name

alter table institution_name add constraint pk_institution_name primary key(institution_name_id)
create index idx_institution_name_institution_name on institution_name(institution_name)



drop table if exists #work_author_institution2
select a.work_id,
	a.author_institution_seq,
	a.author_seq,
	a.institution_seq_org,
	a.institution_id,
	b.institution_name_id
into #work_author_institution2
from #work_author_institution as a
left join institution_name as b on a.institution_name = b.institution_name



-- work_institution
drop table if exists work_institution
create table work_institution
(
	work_id bigint not null,
	institution_seq smallint not null,
	institution_id bigint null,
	institution_name_id int null
)
go

insert into work_institution with(tablock)
select work_id,
	institution_seq = row_number() over (partition by work_id order by min(author_institution_seq)),
	institution_id,
	institution_name_id
from #work_author_institution2
group by work_id, institution_id, institution_name_id

alter table work_institution add constraint pk_work_institution primary key(work_id, institution_seq)
create index idx_work_institution_institution_id on work_institution(institution_id)
create index idx_work_institution_institution_name_id on work_institution(institution_name_id)
alter table work_institution add constraint fk_work_institution_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_institution add constraint fk_work_institution_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)
alter table work_institution add constraint fk_work_institution_institution_name_id_institution_name_institution_name_id foreign key(institution_name_id) references institution_name(institution_name_id)



-- work_author_institution
drop table if exists work_author_institution
create table work_author_institution
(
	work_id bigint not null,
	author_seq smallint not null,
	institution_seq smallint not null
)
go

insert into work_author_institution with(tablock)
select distinct a.work_id,
	a.author_seq,
	b.institution_seq
from #work_author_institution2 as a
join work_institution as b on a.work_id = b.work_id and isnull(a.institution_id, -1) = isnull(b.institution_id, -1) and isnull(a.institution_name_id, -1) = isnull(b.institution_name_id, -1)

alter table work_author_institution add constraint pk_work_author_institution primary key(work_id, author_seq, institution_seq)
alter table work_author_institution add constraint fk_work_author_institution_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_author_institution add constraint fk_work_author_institution_work_id_author_seq_work_author_work_id_author_seq foreign key(work_id, author_seq) references work_author(work_id, author_seq)
alter table work_author_institution add constraint fk_work_author_institution_work_id_institution_seq_work_institution_work_id_institution_seq foreign key(work_id, institution_seq) references work_institution(work_id, institution_seq)
