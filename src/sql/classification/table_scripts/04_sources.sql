set nocount on

-- meso_cluster_source table.

drop table if exists #meso_cluster_source
select a.meso_cluster_id, source_seq = row_number() over (partition by a.meso_cluster_id order by count(*) desc, b.source_id), b.source_id, n_works = count(*)
into #meso_cluster_source
from clustering as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
where b.source_id is not null
group by a.meso_cluster_id, b.source_id

drop table if exists meso_cluster_source
create table meso_cluster_source
(
	meso_cluster_id smallint not null,
	source_seq tinyint not null,
	source_id bigint not null,
	n_works int not null
)

insert into meso_cluster_source with(tablock)
select meso_cluster_id, source_seq, source_id, n_works
from #meso_cluster_source
where source_seq <= 10

alter table meso_cluster_source add constraint pk_meso_cluster_source primary key(meso_cluster_id, source_id)



-- micro_cluster_source table.

drop table if exists #micro_cluster_source
select a.micro_cluster_id, source_seq = row_number() over (partition by a.micro_cluster_id order by count(*) desc, b.source_id), b.source_id, n_works = count(*)
into #micro_cluster_source
from clustering as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
where b.source_id is not null
group by a.micro_cluster_id, b.source_id

drop table if exists micro_cluster_source
create table micro_cluster_source
(
	micro_cluster_id smallint not null,
	source_seq tinyint not null,
	source_id bigint not null,
	n_works int not null
)

insert into micro_cluster_source with(tablock)
select micro_cluster_id, source_seq, source_id, n_works
from #micro_cluster_source
where source_seq <= 10

alter table micro_cluster_source add constraint pk_micro_cluster_source primary key(micro_cluster_id, source_id)
