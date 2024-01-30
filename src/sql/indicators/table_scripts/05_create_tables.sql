set nocount on

drop table if exists sp.database_classification_system_research_area_mean_n_cits
create table sp.database_classification_system_research_area_mean_n_cits
(
	database_no tinyint not null,
	classification_system_no tinyint not null,
	research_area_no smallint not null,
	doc_type_no tinyint not null,
	pub_year smallint not null,
	cit_window smallint not null,
	self_cit bit not null,
	mean_n_cits float not null
	constraint pk_database_classification_system_research_area_mean_n_cits primary key(database_no, classification_system_no, research_area_no, doc_type_no, pub_year, cit_window, self_cit)
)

drop table if exists sp.database_classification_system_research_area_top_threshold
create table sp.database_classification_system_research_area_top_threshold
(
	database_no tinyint not null,
	classification_system_no tinyint not null,
	research_area_no smallint not null,
	doc_type_no tinyint not null,
	pub_year smallint not null,
	cit_window smallint not null,
	self_cit bit not null,
	top_prop float not null,
	top_threshold int not null,
	top_weight_pubs_at_threshold float not null
	constraint pk_database_classification_system_research_area_top_threshold primary key(database_no, classification_system_no, research_area_no, doc_type_no, pub_year, cit_window, self_cit, top_prop)
)

drop table if exists sp.database_classification_system_research_area_source_mcs_mncs_pp_uncited
create table sp.database_classification_system_research_area_source_mcs_mncs_pp_uncited
(
	database_no tinyint not null,
	classification_system_no tinyint not null,
	research_area_no smallint not null,
	doc_type_no tinyint not null,
	pub_year smallint not null,
	cit_window smallint not null,
	self_cit bit not null,
	source_id bigint not null,
	mcs float not null,
	mncs float not null,
	pp_uncited float not null
)

drop table if exists sp.database_classification_system_source_pp_top_n_cits
create table sp.database_classification_system_source_pp_top_n_cits
(
	database_no tinyint not null,
	classification_system_no tinyint not null,
	doc_type_no tinyint not null,
	pub_year smallint not null,
	cit_window smallint not null,
	self_cit bit not null,
	source_id bigint not null,
	top_n_cits int not null,
	pp_top_n_cits float not null
)

drop table if exists sp.database_classification_system_research_area_source_pp_top_prop
create table sp.database_classification_system_research_area_source_pp_top_prop
(
	database_no tinyint not null,
	classification_system_no tinyint not null,
	research_area_no smallint not null,
	doc_type_no tinyint not null,
	pub_year smallint not null,
	cit_window smallint not null,
	self_cit bit not null,
	source_id bigint not null,
	top_prop float not null,
	pp_top_prop float not null
)

drop table if exists #top_n_cits
create table #top_n_cits
(
	top_n_cits_no tinyint not null,
	top_n_cits smallint not null
)

insert #top_n_cits values
(1, 10),
(2, 20),
(3, 50),
(4, 100),
(5, 200),
(6, 500)

drop table if exists #top_prop
create table #top_prop
(
	top_prop_no tinyint not null,
	top_prop float not null
)

insert #top_prop values
(1, 0.01),
(2, 0.02),
(3, 0.05),
(4, 0.1),
(5, 0.2),
(6, 0.5)

declare @max_database_no tinyint = (select max(database_no) from [database])
declare @max_pub_year smallint = dbo.constants('max_pub_year') + 1
declare @max_top_prop_no tinyint = (select max(top_prop_no) from #top_prop)
declare @database_no tinyint = 1
while @database_no <= @max_database_no
begin
	drop table if exists #pub1
	select a.work_id, a.doc_type_no, a.pub_year, a.source_id
	into #pub1
	from pub as a
	join pub_database as b on a.work_id = b.work_id
	where b.database_no = @database_no

	drop table if exists #classification_system_research_area_n_pubs
	select a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, n_pubs = sum(a.[weight])
	into #classification_system_research_area_n_pubs
	from pub_classification_system_research_area as a
	join #pub1 as b on a.work_id = b.work_id
	group by a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year

	declare @min_pub_year smallint = (select min(pub_year) from #pub1)
	declare @max_cit_window tinyint = @max_pub_year - @min_pub_year
	declare @cit_window tinyint = 0
	while @cit_window <= @max_cit_window
	begin
		drop table if exists #pub2
		select work_id, doc_type_no, pub_year, source_id
		into #pub2
		from #pub1
		where pub_year <= @max_pub_year - @cit_window

		declare @self_cit tinyint = 0
		while @self_cit <= 1
		begin
			drop table if exists #pub_n_cits
			select a.work_id, a.doc_type_no, a.pub_year, a.source_id, n_cits = isnull(b.n_cits, 0)
			into #pub_n_cits
			from #pub2 as a
			left join
			(
				select a.work_id, n_cits = count(*)
				from #pub2 as a
				join citation as b on a.work_id = b.cited_work_id
				join #pub1 as c on b.citing_work_id = c.work_id
				where b.cit_window <= @cit_window
					and (b.self_cit = 0 or @self_cit = 1)
				group by a.work_id
			) as b on a.work_id = b.work_id

			drop table if exists #classification_system_research_area_cit_dist
			select a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, b.n_cits, prop_pubs = sum(a.[weight]) / c.n_pubs
			into #classification_system_research_area_cit_dist
			from pub_classification_system_research_area as a
			join #pub_n_cits as b on a.work_id = b.work_id
			join #classification_system_research_area_n_pubs as c on a.classification_system_no = c.classification_system_no
				and a.research_area_no = c.research_area_no
				and b.doc_type_no = c.doc_type_no
				and b.pub_year = c.pub_year
			group by a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, b.n_cits, c.n_pubs

			insert sp.database_classification_system_research_area_mean_n_cits with(tablock)
			select @database_no, classification_system_no, research_area_no, doc_type_no, pub_year, @cit_window, @self_cit, sum(prop_pubs * n_cits)
			from #classification_system_research_area_cit_dist
			group by classification_system_no, research_area_no, doc_type_no, pub_year

			drop table if exists #classification_system_research_area_cum_cit_dist
			select classification_system_no, research_area_no, doc_type_no, pub_year, n_cits, prop_pubs, cum_prop_pubs = sum(prop_pubs) over (partition by classification_system_no, research_area_no, doc_type_no, pub_year order by n_cits)
			into #classification_system_research_area_cum_cit_dist
			from #classification_system_research_area_cit_dist

			declare @top_prop_no tinyint = 1
			while @top_prop_no <= @max_top_prop_no
			begin
				declare @top_prop float = (select top_prop from #top_prop where top_prop_no = @top_prop_no)

				drop table if exists #classification_system_research_area_top_threshold
				select classification_system_no, research_area_no, doc_type_no, pub_year, top_threshold = min(n_cits)
				into #classification_system_research_area_top_threshold
				from #classification_system_research_area_cum_cit_dist
				where cum_prop_pubs >= (1 - @top_prop)
				group by classification_system_no, research_area_no, doc_type_no, pub_year

				insert sp.database_classification_system_research_area_top_threshold with(tablock)
				select @database_no, a.classification_system_no, a.research_area_no, a.doc_type_no, a.pub_year, @cit_window, @self_cit, @top_prop, a.n_cits, (a.cum_prop_pubs - (1 - @top_prop)) / a.prop_pubs
				from #classification_system_research_area_cum_cit_dist as a
				join #classification_system_research_area_top_threshold as b on a.classification_system_no = b.classification_system_no
					and a.research_area_no = b.research_area_no
					and a.doc_type_no = b.doc_type_no
					and a.pub_year = b.pub_year
					and a.n_cits = b.top_threshold

				set @top_prop_no += 1
			end

			insert sp.database_classification_system_research_area_source_mcs_mncs_pp_uncited with(tablock)
			select @database_no, a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, @cit_window, @self_cit, b.source_id, sum(a.[weight] * b.n_cits) / sum(a.[weight]), sum(a.[weight] * (case when c.mean_n_cits = 0 then 1 else b.n_cits / c.mean_n_cits end)) / sum(a.[weight]), sum(a.[weight] * (case when b.n_cits = 0 then 1 else 0 end)) / sum(a.[weight])
			from pub_classification_system_research_area as a
			join #pub_n_cits as b on a.work_id = b.work_id
			join sp.database_classification_system_research_area_mean_n_cits as c on a.classification_system_no = c.classification_system_no
				and a.research_area_no = c.research_area_no
				and b.doc_type_no = c.doc_type_no
				and b.pub_year = c.pub_year
			where c.database_no = @database_no
				and c.cit_window = @cit_window
				and c.self_cit = @self_cit
			group by a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, b.source_id

			insert sp.database_classification_system_source_pp_top_n_cits with(tablock)
			select @database_no, a.classification_system_no, b.doc_type_no, b.pub_year, @cit_window, @self_cit, b.source_id, c.top_n_cits, sum(a.[weight] * (case when b.n_cits >= c.top_n_cits then 1 else 0 end)) / sum(a.[weight])
			from pub_classification_system_research_area as a
			join #pub_n_cits as b on a.work_id = b.work_id
			cross join #top_n_cits as c
			group by a.classification_system_no, b.doc_type_no, b.pub_year, b.source_id, c.top_n_cits

			insert sp.database_classification_system_research_area_source_pp_top_prop with(tablock)
			select @database_no, a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, @cit_window, @self_cit, b.source_id, c.top_prop, sum(a.[weight] * (case when b.n_cits > c.top_threshold then 1 else (case when b.n_cits = c.top_threshold then c.top_weight_pubs_at_threshold else 0 end) end)) / sum(a.[weight])
			from pub_classification_system_research_area as a
			join #pub_n_cits as b on a.work_id = b.work_id
			join sp.database_classification_system_research_area_top_threshold as c on a.classification_system_no = c.classification_system_no
				and a.research_area_no = c.research_area_no
				and b.doc_type_no = c.doc_type_no
				and b.pub_year = c.pub_year
			where c.database_no = @database_no
				and c.cit_window = @cit_window
				and c.self_cit = @self_cit
			group by a.classification_system_no, a.research_area_no, b.doc_type_no, b.pub_year, b.source_id, c.top_prop

			set @self_cit += 1
		end

		set @cit_window += 1
	end

	set @database_no += 1
end
go

alter table sp.database_classification_system_research_area_source_mcs_mncs_pp_uncited add constraint pk_database_classification_system_research_area_source_mcs_mncs_pp_uncited primary key(database_no, classification_system_no, research_area_no, doc_type_no, pub_year, cit_window, self_cit, source_id)
alter table sp.database_classification_system_source_pp_top_n_cits add constraint pk_database_classification_system_source_pp_top_n_cits primary key(database_no, classification_system_no, doc_type_no, pub_year, cit_window, self_cit, source_id, top_n_cits)
alter table sp.database_classification_system_research_area_source_pp_top_prop add constraint pk_database_classification_system_research_area_source_pp_top_prop primary key(database_no, classification_system_no, research_area_no, doc_type_no, pub_year, cit_window, self_cit, source_id, top_prop)
