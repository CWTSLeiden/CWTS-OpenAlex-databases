set nocount on

-- clustering table.

drop table if exists #pub_cluster
select a.pub_no, micro_cluster_id = a.micro_cluster_no + 1, meso_cluster_id = a.meso_cluster_no + 1, macro_cluster_id = a.macro_cluster_no + 1
into #pub_cluster
from [classification].pub_cluster as a
join [classification].pub as b on a.pub_no = b.pub_no
where b.core_pub = 1

drop table if exists clustering
create table clustering
(
	work_id bigint not null,
	macro_cluster_id smallint not null,
	meso_cluster_id smallint not null,
	micro_cluster_id smallint not null
)

insert into clustering with(tablock)
select a.work_id, b.macro_cluster_id, b.meso_cluster_id, b.micro_cluster_id
from [classification].pub as a
join #pub_cluster as b on a.pub_no = b.pub_no

alter table clustering add constraint pk_clustering primary key(work_id)
create index idx_clustering on clustering(work_id, micro_cluster_id, meso_cluster_id, macro_cluster_id)



-- macro_cluster table.

drop table if exists #macro_cluster
select a.macro_cluster_id, macro_cluster_no = a.macro_cluster_id, a.n_works
into #macro_cluster
from
(
	select macro_cluster_id, n_works = count(*)
	from #pub_cluster
	group by macro_cluster_id
) as a

drop table if exists macro_cluster
create table macro_cluster
(
	macro_cluster_id smallint not null,
	macro_cluster_no varchar(10) not null,
	n_works int not null
)

insert into macro_cluster with(tablock)
select
	macro_cluster_id,
	macro_cluster_no = case when macro_cluster_no < 10 then '0' else '' end + cast(macro_cluster_no as varchar(10)),
	n_works
from #macro_cluster

alter table macro_cluster add constraint pk_macro_cluster primary key(macro_cluster_id)



-- meso_cluster table.

drop table if exists #meso_cluster
select a.meso_cluster_id, a.macro_cluster_id, b.macro_cluster_no, meso_cluster_no = row_number() over (partition by a.macro_cluster_id order by a.meso_cluster_id), a.n_works
into #meso_cluster
from
(
	select meso_cluster_id, macro_cluster_id, n_works = count(*)
	from #pub_cluster
	group by meso_cluster_id, macro_cluster_id
) as a
join #macro_cluster as b on a.macro_cluster_id = b.macro_cluster_id

drop table if exists meso_cluster
create table meso_cluster
(
	meso_cluster_id smallint not null,
	meso_cluster_no varchar(10) not null,
	parent_macro_cluster_id smallint not null,
	n_works int not null,
	
)

insert into meso_cluster with(tablock)
select
	meso_cluster_id,
	meso_cluster_no = case when macro_cluster_no < 10 then '0' else '' end + cast(macro_cluster_no as varchar(10)) + '.'
		+ case when meso_cluster_no < 10 then '00' when meso_cluster_no < 100 then '0' else '' end + cast(meso_cluster_no as varchar(10)),
	macro_cluster_id,
	n_works
from #meso_cluster

alter table meso_cluster add constraint pk_meso_cluster primary key(meso_cluster_id)
create index idx_meso_cluster_parent_macro_cluster_id on meso_cluster(parent_macro_cluster_id)



-- micro_cluster table.

drop table if exists #micro_cluster
select a.micro_cluster_id, a.meso_cluster_id, a.macro_cluster_id, b.macro_cluster_no, b.meso_cluster_no, micro_cluster_no = row_number() over (partition by a.meso_cluster_id order by a.micro_cluster_id), a.n_works
into #micro_cluster
from
(
	select micro_cluster_id, meso_cluster_id, macro_cluster_id, n_works = count(*)
	from #pub_cluster
	group by micro_cluster_id, meso_cluster_id, macro_cluster_id
) as a
join #meso_cluster as b on a.meso_cluster_id = b.meso_cluster_id

drop table if exists micro_cluster
create table micro_cluster
(
	micro_cluster_id smallint not null,
	micro_cluster_no varchar(10) not null,
	short_label varchar(100) not null,
	long_label varchar(200) not null,
	keywords varchar(1000) not null,
	summary varchar(2000) not null,
	wikipedia_url varchar(200) not null,
	parent_macro_cluster_id smallint not null,
	parent_meso_cluster_id smallint not null,
	n_works int not null,
	
)

insert into micro_cluster with(tablock)
select
	a.micro_cluster_id,
	micro_cluster_no = case when a.macro_cluster_no < 10 then '0' else '' end + cast(a.macro_cluster_no as varchar(10)) + '.'
			+ case when a.meso_cluster_no < 10 then '00' when a.meso_cluster_no < 100 then '0' else '' end + cast(a.meso_cluster_no as varchar(10)) + '.'
			+ case when a.micro_cluster_no < 10 then '0' else '' end + cast(a.micro_cluster_no as varchar(10)),
	b.short_label,
	b.long_label,
	b.keywords,
	b.summary,
	b.wikipedia_url,
	a.macro_cluster_id,
	a.meso_cluster_id,
	a.n_works
from #micro_cluster as a
left join [classification].cluster_labeling as b on a.micro_cluster_id - 1 = b.cluster_no

alter table micro_cluster add constraint pk_micro_cluster primary key(micro_cluster_id)
create index idx_micro_cluster_parent_macro_cluster_id on micro_cluster(parent_macro_cluster_id)
create index idx_micro_cluster_parent_meso_cluster_id on micro_cluster(parent_meso_cluster_id)
