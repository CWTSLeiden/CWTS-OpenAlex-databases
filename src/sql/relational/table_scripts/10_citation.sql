set nocount on

drop table if exists #citation
select 
	citation_id = identity(int, 1, 1),
	citing_work_id = work_id,
	reference_seq,
	cited_work_id
into #citation
from work_reference

drop table if exists #citation2
select a.citation_id, a.citing_work_id, a.reference_seq, a.cited_work_id
into #citation2
from
(
	select *, [filter] = row_number() over (partition by citing_work_id, cited_work_id order by reference_seq asc)
	from #citation
) as a
where a.[filter] = 1

drop table if exists #citation

drop table if exists #self_cit
select distinct citation_id
into #self_cit
from
(
	select distinct a.citation_id, b.author_id
	from #citation2 as a
	join work_author as b on a.citing_work_id = b.work_id
	union all
	select distinct a.citation_id, b.author_id
	from #citation2 as a
	join work_author as b on a.cited_work_id = b.work_id
) as a
group by citation_id, author_id
having count(*) > 1

drop table if exists #pub_year
select work_id, pub_year
into #pub_year
from work

create index idx_tmp_pub_year_work_id on #pub_year(work_id)


-- citation
drop table if exists citation
create table citation
(
	citing_work_id bigint not null,
	reference_seq int not null,
	cited_work_id bigint not null,
	pub_year smallint null,
	cit_window smallint null,
	is_self_cit bit not null
)

insert into citation with(tablock)
select 
	a.citing_work_id,
	a.reference_seq,
	a.cited_work_id,
	pub_year = c.pub_year,
	cit_window = b.pub_year - c.pub_year,
	is_self_cit = case when d.citation_id is not null then 1 else 0 end
from #citation2 as a
join #pub_year as b on a.citing_work_id = b.work_id
join #pub_year as c on a.cited_work_id = c.work_id
left join #self_cit as d on a.citation_id = d.citation_id
where b.work_id != c.work_id

alter table citation add constraint pk_citation primary key(citing_work_id, reference_seq)
create index idx_citation_citing_work_id on citation(citing_work_id)
create index idx_citation_cited_work_id on citation(cited_work_id)
alter table citation add constraint fk_citation_citing_work_id_work_work_id foreign key(citing_work_id) references work(work_id)
alter table citation add constraint fk_citation_cited_work_id_work_work_id foreign key(cited_work_id) references work(work_id)

drop table if exists #citation2
drop table if exists #self_cit
