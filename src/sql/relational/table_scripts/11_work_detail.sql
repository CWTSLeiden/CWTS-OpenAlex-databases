set nocount on

-- author

drop table if exists #work_author
select 
	work_id,
	author_seq,
	author_id,
	author_seq2 = row_number() over (partition by work_id order by author_seq)
into #work_author
from work_author
where author_id is not null

-- If a publication has eight or more authors, list the names of the first six authors followed by an ellipsis and then the last author's name.
drop table if exists #work_last_author_seq
select 
	work_id, 
	last_author_seq = max(author_seq2)
into #work_last_author_seq
from #work_author
group by work_id

update a
set a.author_id = -1
from #work_author as a
join #work_last_author_seq as b on a.work_id = b.work_id
where b.last_author_seq > 7 and a.author_seq2 = 7

delete a
from #work_author as a
join #work_last_author_seq as b on a.work_id = b.work_id
where b.last_author_seq > 8 and a.author_seq2 between 8 and (b.last_author_seq - 1)

drop table if exists #work_last_author_seq
create index idx_tmp_work_author on #work_author(work_id, author_seq2, author_id)

drop table if exists #author_first
select 
	a.work_id, 
	author_first = b.author
into #author_first
from #work_author as a
join author as b on a.author_id = b.author_id
where a.author_seq2 = 1

alter table #author_first add constraint pk_tmp_author_first primary key(work_id)

drop table if exists #author_et_al
select 
	a.work_id,
	author_et_al = nullif(string_agg(isnull(b.author, '...'), '; ') within group (order by a.author_seq2), '') 
into #author_et_al
from #work_author as a
left join author as b on a.author_id = b.author_id
where a.author_seq2 > 1
group by a.work_id

drop table if exists #author
drop table if exists #work_author
alter table #author_et_al add constraint pk_tmp_author_et_al primary key(work_id)


-- institution

drop table if exists #work_institution
select 
	work_id,
	institution_seq,
	institution_id,
	institution_seq2 = row_number() over (partition by work_id order by institution_seq)
into #work_institution
from work_institution
where institution_id is not null

-- If a publication has eight or more institutions, list the names of the first six institutions followed by an ellipsis and then the last institutions' name.
drop table if exists #work_last_institution_seq
select 
	work_id, 
	last_institution_seq = max(institution_seq2)
into #work_last_institution_seq
from #work_institution
group by work_id

update a
set a.institution_id = -1
from #work_institution as a
join #work_last_institution_seq as b on a.work_id = b.work_id
where b.last_institution_seq > 7 and a.institution_seq2 = 7

delete a
from #work_institution as a
join #work_last_institution_seq as b on a.work_id = b.work_id
where b.last_institution_seq > 8 and a.institution_seq2 between 8 and (b.last_institution_seq - 1)

drop table if exists #work_last_institution_seq
create index #work_institution on #work_institution(work_id, institution_seq2, institution_id)

drop table if exists #institution_first
select 
	a.work_id, 
	institution_first = b.institution
into #institution_first
from #work_institution as a
join institution as b on a.institution_id = b.institution_id
where a.institution_seq2 = 1

alter table #institution_first add constraint pk_tmp_institution_first primary key(work_id)

drop table if exists #institution_et_al
select 
	a.work_id,
	institution_et_al = nullif(string_agg(isnull(b.institution, '...'), '; ') within group (order by a.institution_seq2), '')
into #institution_et_al
from #work_institution as a
left join institution as b on a.institution_id = b.institution_id
where a.institution_seq2 > 1
group by a.work_id

drop table if exists #institution
drop table if exists #work_institution
alter table #institution_et_al add constraint pk_tmp_institution_et_al primary key(work_id)



-- work_detail

drop table if exists work_detail
create table work_detail
(
	work_id bigint not null,
	author_first nvarchar(1000) null,
	author_et_al nvarchar(800) null,
	institution_first nvarchar(200) null,
	institution_et_al nvarchar(500) null,
	title nvarchar(450) null,
	[source] nvarchar(800) null,
	pub_year smallint null,
	volume nvarchar(100) null,
	issue nvarchar(80) null,
	pages nvarchar(350) null,
	doi varchar(330) null,
	pmid int null,
	work_type varchar(20) null,
	n_cits int not null,
	n_self_cits int not null
)
go

insert into work_detail with(tablock)
select 
	a.work_id,
	author_first = left(b.author_first, 1000),
	author_et_al = left(c.author_et_al, 800),
	d.institution_first,
	e.institution_et_al,
	title = left(f.title, 447) + case when len(f.title) > 447 then '...' else '' end,
	g.[source],
	a.pub_year,
	a.volume,
	a.issue,
	pages =
		case
			when (a.page_first is not null and a.page_last is not null) and (a.page_first = a.page_last or a.page_last = '+') then a.page_first
			when (a.page_first is not null and a.page_last is not null) then a.page_first + '-' + a.page_last
			when a.page_first is not null then a.page_first
			else null
		end,
	a.doi,
	a.pmid,
	h.work_type,
	n_cits = 0,
	n_self_cits = 0
from work as a
left join #author_first as b on a.work_id = b.work_id
left join #author_et_al as c on a.work_id = c.work_id
left join #institution_first as d on a.work_id = d.work_id
left join #institution_et_al as e on a.work_id = e.work_id
left join work_title as f on a.work_id = f.work_id
left join [source] as g on a.source_id = g.source_id
left join work_type as h on a.work_type_id = h.work_type_id

alter table work_detail add constraint pk_work_detail primary key(work_id)
create index idx_work_detail_doi on work_detail(doi)
create index idx_work_detail_pmid on work_detail(pmid)
alter table work_detail add constraint fk_work_detail_work_id_work_work_id foreign key(work_id) references work(work_id)
