set nocount on

drop table if exists citation
create table citation
(
	citing_work_id bigint not null,
	cited_work_id bigint not null,
	cit_window smallint not null,
	self_cit bit not null
)

insert into citation with(tablock)
select b.work_id, c.work_id, case when a.cit_window < 0 then 0 else a.cit_window end, a.is_self_cit
from $(relational_db_name)..citation as a
join pub as b on a.citing_work_id = b.work_id
join pub as c on a.cited_work_id = c.work_id

alter table citation add constraint pk_citation primary key(citing_work_id, cited_work_id)
create index idx_citation_citing_work_id on citation(citing_work_id)
create index idx_citation_cited_work_id on citation(cited_work_id)
