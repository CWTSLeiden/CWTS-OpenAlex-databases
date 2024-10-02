set nocount on

drop table if exists #work_author
select a.work_id,
	author_seq = b.authorship_seq,
	author_id = replace(b.author_id, 'https://openalex.org/A', ''),
	b.author_position,
	b.is_corresponding,
	raw_author_name = cast(left(b.raw_author_name, 800) as nvarchar(800))
into #work_author
from _work as a
join $(works_json_db_name)..work_authorship as b on a.folder = b.folder and a.record_id = b.record_id

create clustered columnstore index idx_tmp_work_author on #work_author



drop table if exists #work_author_raw_affiliation_string
select a.work_id,
	author_seq = b.authorship_seq,
	b.raw_affiliation_string_seq,
	raw_affiliation_string = cast($(etl_db_name).dbo.regex_replace(left(b.raw_affiliation_string, 800), '^\s*|\s*$', '') as nvarchar(800))
into #work_author_raw_affiliation_string
from _work as a
join $(works_json_db_name)..work_authorship_raw_affiliation_string as b on a.folder = b.folder and a.record_id = b.record_id

create clustered columnstore index idx_tmp_work_author_raw_affiliation_string on #work_author_raw_affiliation_string

delete from #work_author_raw_affiliation_string with(tablock)
where len(raw_affiliation_string) = 0

delete from #work_author_raw_affiliation_string with(tablock)
where raw_affiliation_string is null

drop table if exists #work_author_affiliation
select a.work_id,
	author_seq = b.authorship_seq,
	author_affiliation_seq = b.affiliation_seq,
	raw_affiliation_string = cast($(etl_db_name).dbo.regex_replace(left(b.raw_affiliation_string, 800), '^\s*|\s*$', '') as nvarchar(800))
into #work_author_affiliation
from _work as a
join $(works_json_db_name)..work_authorship_affiliation as b on a.folder = b.folder and a.record_id = b.record_id

create clustered columnstore index idx_tmp_work_author_affiliation on #work_author_affiliation

delete from #work_author_affiliation with(tablock)
where len(raw_affiliation_string) = 0

delete from #work_author_affiliation with(tablock)
where raw_affiliation_string is null

declare @n_missing_raw_affiliation_strings as int

select @n_missing_raw_affiliation_strings = count(*)
from #work_author_raw_affiliation_string as a
left join #work_author_affiliation as b on a.work_id = b.work_id and a.author_seq = b.author_seq and a.raw_affiliation_string = b.raw_affiliation_string
where b.work_id is null

if @n_missing_raw_affiliation_strings > 0
begin
	raiserror('Info: Check work_authorship_affiliation.', 2, 1)
	print 'Number of missing raw_affiliation_strings in work_authorship_affiliation: ' + cast(@n_missing_raw_affiliation_strings as varchar(10))
end

select @n_missing_raw_affiliation_strings = count(*)
from #work_author_affiliation as a
left join #work_author_raw_affiliation_string as b on a.work_id = b.work_id and a.author_seq = b.author_seq and a.raw_affiliation_string = b.raw_affiliation_string
where b.work_id is null

if @n_missing_raw_affiliation_strings > 0
begin
	raiserror('Info: Check work_authorship_raw_affiliation_string.', 2, 1)
	print 'Number of missing raw_affiliation_strings in work_authorship_raw_affiliation_string: ' + cast(@n_missing_raw_affiliation_strings as varchar(10))
end



drop table if exists #work_author_institution
select a.work_id,
	author_seq = b.authorship_seq,
	author_institution_seq = c.institution_seq,
	institution_id = replace(c.id, 'https://openalex.org/I', '')
into #work_author_institution
from _work as a
join $(works_json_db_name)..work_authorship as b on a.folder = b.folder and a.record_id = b.record_id
join $(works_json_db_name)..work_authorship_institution as c on a.folder = c.folder and a.record_id = c.record_id and b.authorship_seq = c.authorship_seq

create clustered columnstore index idx_tmp_work_author_institution on #work_author_institution

drop table if exists #work_author_affiliation_institution
select a.work_id,
	author_seq = b.authorship_seq,
	author_affiliation_seq = b.affiliation_seq,
	author_affiliation_institution_seq = b.institution_id_seq,
	institution_id = replace(b.institution_id, 'https://openalex.org/I', '')
into #work_author_affiliation_institution
from _work as a
join $(works_json_db_name)..work_authorship_affiliation_institution_id as b on a.folder = b.folder and a.record_id = b.record_id

create clustered columnstore index idx_tmp_work_author_affiliation_institution on #work_author_affiliation_institution

declare @n_missing_institution_ids as int

select @n_missing_institution_ids = count(*)
from #work_author_institution as a
left join #work_author_affiliation_institution as b on a.work_id = b.work_id and a.author_seq = b.author_seq and a.institution_id = b.institution_id
where b.work_id is null

if @n_missing_institution_ids > 0
begin
	raiserror('Info: Check work_authorship_affiliation_institution_id.', 2, 1)
	print 'Number of missing institution_ids in work_authorship_affiliation_institution_id: ' + cast(@n_missing_institution_ids as varchar(10))
end

select @n_missing_institution_ids = count(*)
from #work_author_affiliation_institution as a
left join #work_author_institution as b on a.work_id = b.work_id and a.author_seq = b.author_seq and a.institution_id = b.institution_id
where b.work_id is null

if @n_missing_institution_ids > 0
begin
	raiserror('Info: Check work_authorship_institution.', 2, 1)
	print 'Number of missing institution_ids in work_authorship_institution: ' + cast(@n_missing_institution_ids as varchar(10))
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
from #work_author_affiliation
where raw_affiliation_string is not null
except
select raw_affiliation_string
from raw_affiliation_string
order by raw_affiliation_string

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



drop table if exists #work_author_affiliation2
select a.work_id,
	a.author_seq,
	a.author_affiliation_seq,
	author_affiliation_seq2 = row_number() over (partition by work_id order by author_seq, author_affiliation_seq),
	b.raw_affiliation_string_id
into #work_author_affiliation2
from #work_author_affiliation as a
join raw_affiliation_string as b on a.raw_affiliation_string = b.raw_affiliation_string



-- work_affiliation
drop table if exists work_affiliation
create table work_affiliation
(
	work_id bigint not null,
	affiliation_seq smallint not null,
	raw_affiliation_string_id int not null
)
go

insert into work_affiliation with(tablock)
select work_id,
	affiliation_seq = row_number() over (partition by work_id order by min(author_affiliation_seq2)),
	raw_affiliation_string_id
from #work_author_affiliation2
group by work_id, raw_affiliation_string_id

alter table work_affiliation add constraint pk_work_affiliation primary key(work_id, affiliation_seq)
create index idx_work_affiliation_raw_affiliation_string_id on work_affiliation(raw_affiliation_string_id)
alter table work_affiliation add constraint fk_work_affiliation_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_affiliation add constraint fk_work_affiliation_raw_affiliation_string_id_raw_affiliation_string_raw_affiliation_string_id foreign key(raw_affiliation_string_id) references raw_affiliation_string(raw_affiliation_string_id)



-- work_author_affiliation
drop table if exists work_author_affiliation
create table work_author_affiliation
(
	work_id bigint not null,
	author_seq  smallint not null,
	affiliation_seq smallint not null
)
go

insert into work_author_affiliation with(tablock)
select distinct a.work_id,
	a.author_seq,
	b.affiliation_seq
from #work_author_affiliation2 as a
join work_affiliation as b on a.work_id = b.work_id and a.raw_affiliation_string_id = b.raw_affiliation_string_id

alter table work_author_affiliation add constraint pk_work_author_affiliation primary key(work_id, author_seq, affiliation_seq)
alter table work_author_affiliation add constraint fk_work_author_affiliation_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_author_affiliation add constraint fk_work_author_affiliation_work_id_author_seq_pub_author_work_id_author_seq foreign key(work_id, author_seq) references work_author(work_id, author_seq)
alter table work_author_affiliation add constraint fk_work_author_affiliation_work_id_affiliation_seq_work_affiliation_work_id_affiliation_seq foreign key(work_id, affiliation_seq) references work_affiliation(work_id, affiliation_seq)



drop table if exists #work_author_affiliation_institution2
select a.work_id,
	a.author_seq,
	c.affiliation_seq,
	a.author_affiliation_institution_seq,
	a.institution_id
into #work_author_affiliation_institution2
from #work_author_affiliation_institution as a
join #work_author_affiliation2 as b on a.work_id = b.work_id and a.author_seq = b.author_seq and a.author_affiliation_seq = b.author_affiliation_seq
join work_affiliation as c on a.work_id = c.work_id and b.raw_affiliation_string_id = c.raw_affiliation_string_id



-- work_affiliation_institution
drop table if exists work_affiliation_institution
create table work_affiliation_institution
(
	work_id bigint not null,
	affiliation_seq smallint not null,
	institution_seq smallint not null,
	institution_id bigint not null
)
go

insert into work_affiliation_institution with(tablock)
select work_id,
	affiliation_seq,
	institution_seq = row_number() over (partition by work_id, affiliation_seq order by institution_id),
	institution_id
from #work_author_affiliation_institution2
group by work_id, affiliation_seq, institution_id

alter table work_affiliation_institution add constraint pk_work_affiliation_institution primary key(work_id, affiliation_seq, institution_seq)
alter table work_affiliation_institution add constraint fk_work_affiliation_institution_work_id_work_work_id foreign key(work_id) references work(work_id)
alter table work_affiliation_institution add constraint fk_work_affiliation_institution_work_id_affiliation_seq_work_affiliation_work_id_affiliation_seq foreign key(work_id, affiliation_seq) references work_affiliation(work_id, affiliation_seq)
alter table work_affiliation_institution add constraint fk_work_affiliation_institution_institution_id_institution_institution_id foreign key(institution_id) references institution(institution_id)
