drop procedure if exists calc_indicators_pubs
go

create procedure calc_indicators_pubs
(
	@pub_table pub_table readonly,
	@database_no int = null,
	@classification_system_no int = null,
	@pub_window_begin int = null,
	@pub_window_end int = null,
	@cit_window_length int = null,
	@cit_window_end int = null,
	@counting_method int = null,
	@self_cit bit = null,
	@top_n_cits int = null,
	@top_prop float = null
)
as
begin
	set nocount on

	drop table if exists #pub_table
	select work_id
	into #pub_table
	from @pub_table

	if exists
		(
			select 0
			from #pub_table
			group by work_id
			having count(*) > 1
		)
	begin
		raiserror('Error: Duplicate publication.', 0, 1)
		return 1
	end

	declare @var_database_no int = @database_no
	if @var_database_no is null
		set @var_database_no = 1
	if not exists
		(
			select 0
			from [database]
			where database_no = @var_database_no
		)
	begin
		raiserror('Error: Parameter @database_no has an invalid value.', 0, 1)
		return 1
	end

	declare @var_classification_system_no int = @classification_system_no
	if @var_classification_system_no is null
		set @var_classification_system_no = 2
	if not exists
		(
			select 0
			from classification_system
			where classification_system_no = @var_classification_system_no
		)
	begin
		raiserror('Error: Parameter @classification_system_no has an invalid value.', 0, 1)
		return 1
	end

	declare @var_min_pub_year int = $(indicators_min_pub_year)
	declare @var_max_pub_year int = dbo.constants('max_pub_year')
	declare @var_max_cit_window_end int = @var_max_pub_year + 1

	declare @var_pub_window_begin int = @pub_window_begin
	if @var_pub_window_begin is null
		set @var_pub_window_begin = @var_min_pub_year
	if @var_pub_window_begin < @var_min_pub_year or @var_pub_window_begin > @var_max_pub_year
	begin
		raiserror('Error: Parameter @pub_window_begin must have a value between %i and %i.', 0, 1, @var_min_pub_year, @var_max_pub_year)
		return 1
	end

	declare @var_pub_window_end int = @pub_window_end
	if @var_pub_window_end is null
		if @var_pub_window_begin = @var_max_pub_year
			set @var_pub_window_end = @var_max_pub_year
		else
			set @var_pub_window_end = @var_max_pub_year - 1
	if @var_pub_window_end < @var_min_pub_year or @var_pub_window_end > @var_max_pub_year
	begin
		raiserror('Error: Parameter @pub_window_end must have a value between %i and %i.', 0, 1, @var_min_pub_year, @var_max_pub_year)
		return 1
	end
	if @var_pub_window_end < @var_pub_window_begin
	begin
		raiserror('Error: The value of the parameter @pub_window_end must be greater than or equal to the value of the parameter @pub_window_begin.', 0, 1)
		return 1
	end
	if @var_pub_window_end = @var_max_pub_year
		raiserror('Warning: It is strongly recommended that the parameter @pub_window_end has a value less than %i.', 0, 1, @var_max_pub_year)

	declare @var_cit_window_length int = @cit_window_length
	declare @var_cit_window_end int = @cit_window_end
	if @var_cit_window_length is not null and @var_cit_window_end is not null
	begin
		raiserror('Error: Parameters @cit_window_length and @cit_window_end cannot be used together.', 0, 1)
		return 1
	end

	if @var_cit_window_length is null and @var_cit_window_end is null
		set @var_cit_window_end = @var_max_cit_window_end

	if @var_cit_window_length < 1
	begin
		raiserror('Error: Parameter @cit_window_length must have a positive value.', 0, 1)
		return 1
	end
	if @var_cit_window_length = 1
		raiserror('Warning: It is strongly recommended that the parameter @cit_window_length has a value greater than 1.', 0, 1)
	set @var_cit_window_length -= 1

	if @var_cit_window_end < @var_min_pub_year or @var_cit_window_end > @var_max_cit_window_end
	begin
		raiserror('Error: Parameter @cit_window_end must have a value between %i and %i.', 0, 1, @var_min_pub_year, @var_max_cit_window_end)
		return 1
	end
	if @var_cit_window_end < @var_pub_window_end
	begin
		raiserror('Error: The value of the parameter @cit_window_end must be greater than or equal to the value of the parameter @pub_window_end.', 0, 1)
		return 1
	end
	if @var_cit_window_end = @var_pub_window_end
		raiserror('Warning: It is strongly recommended that the value of the parameter @cit_window_end is greater than the value of the parameter @pub_window_end.', 0, 1)

	declare @var_counting_method int = @counting_method
	if @var_counting_method is null
		set @var_counting_method = 1
	if @var_counting_method < 1 or @var_counting_method > 4
	begin
		raiserror('Error: Parameter @counting_method must have a value between 1 and 4.', 0, 1)
		return 1
	end

	declare @var_self_cit bit = @self_cit
	if @var_self_cit is null
		set @var_self_cit = 0

	declare @var_top_n_cits int = @top_n_cits
	if @var_top_n_cits is null
		set @var_top_n_cits = 10
	if @var_top_n_cits not in (10, 20, 50, 100, 200, 500)
	begin
		raiserror('Error: Parameter @top_n_cits must have a value of 10, 20, 50, 100, 200, or 500.', 0, 1)
		return 1
	end

	declare @var_top_prop float = @top_prop
	if @var_top_prop is null
		set @var_top_prop = 0.1
	if @var_top_prop not in (0.01, 0.02, 0.05, 0.1, 0.2, 0.5)
	begin
		raiserror('Error: Parameter @top_prop must have a value of 0.01, 0.02, 0.05, 0.1, 0.2, or 0.5.', 0, 1)
		return 1
	end

	select work_id
	into #tab_pub1
	from #pub_table

	select a.work_id,
		b.doc_type_no,
		b.pub_year,
		cit_window = (case when @var_cit_window_length is not null then (case when @var_cit_window_length > (@var_max_pub_year + 1) - b.pub_year then (@var_max_pub_year + 1) - b.pub_year else @var_cit_window_length end) else @var_cit_window_end - b.pub_year end),
		b.source_id,
		c.n_refs,
		c.n_refs_covered,
		b.collaboration_type_no,
		b.is_industry,
		b.gcd,
		b.is_oa,
		b.is_gold_oa,
		b.is_hybrid_oa,
		b.is_bronze_oa,
		b.is_green_oa,
		b.is_oa_unknown,
		[weight] = cast(1 as float) / (case @var_counting_method when 1 then 1 when 2 then b.n_authors when 3 then b.n_institutions when 4 then b.n_countries end)
	into #tab_pub2
	from #tab_pub1 as a
	join pub as b on a.work_id = b.work_id
	join pub_database as c on b.work_id = c.work_id
	where b.doc_type_no in (2, 3, 4)
		and b.pub_year between @var_pub_window_begin and @var_pub_window_end
		and c.database_no = @var_database_no

	create index idx_pub2 on #tab_pub2(work_id, doc_type_no, pub_year, cit_window, source_id)

	select a.work_id, n_non_self_cits = count(*), n_self_cits = sum(cast(b.self_cit as int))
	into #tab_pub3
	from #tab_pub2 as a
	join citation as b on a.work_id = b.cited_work_id
	join pub_database as c on b.citing_work_id = c.work_id
	where b.cit_window <= a.cit_window
		and c.database_no = @var_database_no
	group by a.work_id

	select a.work_id,
		n_cits = (case when @var_self_cit = 1 then isnull(b.n_non_self_cits, 0) else isnull(b.n_non_self_cits, 0) - isnull(b.n_self_cits, 0) end),
		n_self_cits = isnull(b.n_self_cits, 0)
	into #tab_pub_n_cits
	from #tab_pub2 as a
	left join #tab_pub3 as b on a.work_id = b.work_id

	create index idx_pub_n_cits on #tab_pub_n_cits(work_id)

	select a.work_id,
		p = sum(a.[weight] * c.[weight]),
		cs = sum(a.[weight] * c.[weight] * b.n_cits),
		ncs = sum(a.[weight] * c.[weight] * (case when d.mean_n_cits = 0 then 1 else b.n_cits / d.mean_n_cits end)),
		p_top_n_cits = sum(a.[weight] * c.[weight] * (case when b.n_cits >= @var_top_n_cits then 1 else 0 end)),
		p_top_prop = sum(a.[weight] * c.[weight] * (case when b.n_cits > e.top_threshold then 1 else (case when b.n_cits = e.top_threshold then e.top_weight_pubs_at_threshold else 0 end) end)),
		p_uncited = sum(a.[weight] * c.[weight] * (case when b.n_cits = 0 then 1 else 0 end)),
		js_mcs = sum(a.[weight] * c.[weight] * f.mcs),
		njs_mncs = sum(a.[weight] * c.[weight] * f.mncs),
		js_pp_top_n_cits = sum(a.[weight] * c.[weight] * g.pp_top_n_cits),
		njs_pp_top_prop = sum(a.[weight] * c.[weight] * h.pp_top_prop),
		js_pp_uncited = sum(a.[weight] * c.[weight] * f.pp_uncited),
		n_self_cits = sum(a.[weight] * c.[weight] * b.n_self_cits),
		n_refs = sum(a.[weight] * c.[weight] * a.n_refs),
		n_refs_covered = sum(a.[weight] * c.[weight] * a.n_refs_covered),
		p_collab = sum(a.[weight] * c.[weight] * (case when a.collaboration_type_no in (2, 3) then 1 else 0 end)),
		p_int_collab = sum(a.[weight] * c.[weight] * (case when a.collaboration_type_no = 3 then 1 else 0 end)),
		p_industry = sum(a.[weight] * c.[weight] * a.is_industry),
		gcd = sum(a.[weight] * c.[weight] * a.gcd),
		p_short_dist_collab = sum(a.[weight] * c.[weight] * (case when a.collaboration_type_no in (2, 3) and a.gcd <= 100 then 1 else 0 end)),
		p_long_dist_collab = sum(a.[weight] * c.[weight] * (case when a.collaboration_type_no in (2, 3) and a.gcd >= 1000 then 1 else 0 end)),
		p_oa = sum(a.[weight] * c.[weight] * a.is_oa),
		p_gold_oa = sum(a.[weight] * c.[weight] * a.is_gold_oa),
		p_hybrid_oa = sum(a.[weight] * c.[weight] * a.is_hybrid_oa),
		p_bronze_oa = sum(a.[weight] * c.[weight] * a.is_bronze_oa),
		p_green_oa = sum(a.[weight] * c.[weight] * a.is_green_oa),
		p_oa_unknown = sum(a.[weight] * c.[weight] * a.is_oa_unknown)
	into #tab_pub_indics
	from #tab_pub2 as a
	join #tab_pub_n_cits as b on a.work_id = b.work_id
	join pub_classification_system_research_area as c on a.work_id = c.work_id
	join sp.database_classification_system_research_area_mean_n_cits as d on a.doc_type_no = d.doc_type_no
		and a.pub_year = d.pub_year
		and a.cit_window = d.cit_window
		and c.classification_system_no = d.classification_system_no
		and c.research_area_no = d.research_area_no
	join sp.database_classification_system_research_area_top_threshold as e on a.doc_type_no = e.doc_type_no
		and a.pub_year = e.pub_year
		and a.cit_window = e.cit_window
		and c.classification_system_no = e.classification_system_no
		and c.research_area_no = e.research_area_no
		and d.database_no = e.database_no
		and d.self_cit = e.self_cit
	join sp.database_classification_system_research_area_source_mcs_mncs_pp_uncited as f on a.doc_type_no = f.doc_type_no
		and a.pub_year = f.pub_year
		and a.cit_window = f.cit_window
		and a.source_id = f.source_id
		and c.classification_system_no = f.classification_system_no
		and c.research_area_no = f.research_area_no
		and d.database_no = f.database_no
		and d.self_cit = f.self_cit
	join sp.database_classification_system_source_pp_top_n_cits as g on a.doc_type_no = g.doc_type_no
		and a.pub_year = g.pub_year
		and a.cit_window = g.cit_window
		and a.source_id = g.source_id
		and c.classification_system_no = g.classification_system_no
		and d.database_no = g.database_no
		and d.self_cit = g.self_cit
	join sp.database_classification_system_research_area_source_pp_top_prop as h on a.doc_type_no = h.doc_type_no
		and a.pub_year = h.pub_year
		and a.cit_window = h.cit_window
		and a.source_id = h.source_id
		and c.classification_system_no = h.classification_system_no
		and c.research_area_no = h.research_area_no
		and d.database_no = h.database_no
		and d.self_cit = h.self_cit
		and e.top_prop = h.top_prop
	where c.classification_system_no = @var_classification_system_no
		and d.database_no = @var_database_no
		and d.self_cit = @var_self_cit
		and e.top_prop = @var_top_prop
		and g.top_n_cits = @var_top_n_cits
	group by a.work_id

	declare @var_n_rows_excluded int = (select count(*) from #pub_table) - (select count(*) from #tab_pub_indics)
	if @var_n_rows_excluded > 0
		raiserror('Warning: %i rows from @pub_table have been excluded from the analysis.', 0, 1, @var_n_rows_excluded)

	select *
	from #tab_pub_indics
	order by work_id

	declare @var_database varchar(100) = (select [database] from [database] where database_no = @var_database_no)
	declare @var_classification_system varchar(100) = (select classification_system from classification_system where classification_system_no = @var_classification_system_no)
	print ''
	print 'Parameters:'
	print ''
	print 'Database:			  ' + @var_database
	print 'Classification system: ' + @var_classification_system
	print 'Publication window:	' + cast(@var_pub_window_begin as char(4)) + '-' + cast(@var_pub_window_end as char(4))
	print 'Citation window:	   ' + (case when @var_cit_window_length is not null then 'Fixed length of ' + cast((@var_cit_window_length + 1) as varchar(2)) + ' year(s)' else 'Variable length until ' + cast(@var_cit_window_end as char(4)) end)
	print 'Counting method:	   ' + (case @var_counting_method when 1 then 'Full counting' when 2 then 'Fractional counting at the level of authors' when 3 then 'Fractional counting at the level of organisations' else 'Fractional counting at the level of countries' end)
	print 'Self citations:		' + (case when @var_self_cit = 0 then 'Excluded' else 'Included' end)
	print 'Top indicators:		' + cast(@var_top_n_cits as varchar(max)) + ' or more citations / top ' + cast(100 * @var_top_prop as varchar(max)) + '%'
end
