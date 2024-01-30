set nocount on

drop function if exists get_work_detail
go

create function get_work_detail
(
	@work work_id_table readonly,
	@abbreviate bit = 0,
	@include_title bit = 1,
	@include_citations bit = 1
)
returns @work_details table
(
	work_id bigint,
	ref_string nvarchar(max),
	authors nvarchar(1000),
	institutions nvarchar(500),
	title nvarchar(450),
	[source] nvarchar(800),
	pub_year smallint,
	volume nvarchar(100),
	issue nvarchar(80),
	pages nvarchar(350),
	doi varchar(330),
	work_type varchar(20),
	n_cits int,
	n_self_cits int
)
as
begin
	insert @work_details
	select 
		work_id,
		ref_string =
			lower(
				isnull(authors, 'anonymous')
				+ case
					when pub_year is null then ' (n.d.). '
					else ' (' + cast(pub_year as char(4)) + '). '
				  end
				+ case
					when @include_title = 1 then title + '. '
					else ''
				  end
				+ isnull([source], '')
				+ case
					when volume is not null and issue is not null then ', ' + volume + '(' + issue + ')'
					when volume is not null then ', ' + volume
					when issue is not null then ', ' + issue
					else ''
				  end
				+ case
					when pages is not null then ', ' + pages
					else ''
				  end
				+ '.'
				+ case
					when @include_citations = 1 then ' (' + cast(n_cits as varchar(16)) + ' cit., ' + cast(n_self_cits as varchar(16)) + ' self cit.)'
					else ''
				  end
			),
		authors,
		institutions,
		title,
		[source],
		pub_year,
		volume,
		issue,
		pages,
		doi,
		work_type,
		n_cits,
		n_self_cits
	from
	(
		select 
			a.work_id,
			authors =
				case
					when @abbreviate = 0 then
						(author_first + case when author_et_al is not null then '; ' + author_et_al else '' end)
					else
						(author_first + case when author_et_al is not null then '; et al.' else '' end)
				end,
			institutions =
				case
					when @abbreviate = 0 then
						(institution_first + case when institution_et_al is not null then '; ' + institution_et_al else '' end)
					else
						(institution_first + case when institution_et_al is not null then '; et al.' else '' end)
				end,
			title,
			[source],
			pub_year,
			volume,
			issue,
			pages,
			doi,
			work_type,
			n_cits,
			n_self_cits
		from work_detail as a
		right join @work as b on a.work_id = b.work_id
	) as a
	return
end
go

/*
declare @work_id as work_id_table

insert into @work_id
select work_id
from work_author as a
join author as b on a.author_id = b.author_id
where author = 'nees jan van eck'

select *
from dbo.get_work_detail(@work_id, 0, 1, 1)
order by work_type, pub_year desc
*/
