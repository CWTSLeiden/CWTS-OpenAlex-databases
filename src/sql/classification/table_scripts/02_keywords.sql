set nocount on

-- string_split_ordered function.

drop function if exists [classification].string_split_ordered
go

create function [classification].string_split_ordered
(
  @list nvarchar(max),
  @delimiter nchar(1)
)
returns table with schemabinding
as
	return
	(
		select value, ordinal = [key]
		from openjson(N'["' + replace(@list, @delimiter, N'","') + N'"]') as x
	);
go



-- micro_cluster_keyword table.

drop table if exists micro_cluster_keyword
create table micro_cluster_keyword
(
	micro_cluster_id smallint not null,
	keyword_seq tinyint not null,
	keyword varchar(100) not null
)

insert into micro_cluster_keyword with(tablock)
select a.micro_cluster_id, b.keyword_seq, b.keyword
from micro_cluster as a
left join
(
	select a.cluster_no, keyword_seq = b.ordinal + 1, keyword = trim(b.value)
	from [classification].cluster_labeling as a
	cross apply [classification].string_split_ordered(keywords, ';') as b
) as b on a.micro_cluster_id - 1 = b.cluster_no

alter table micro_cluster_keyword add constraint pk_micro_cluster_keyword primary key(micro_cluster_id, keyword_seq)
create index idx_micro_cluster_keyword_keyword on micro_cluster_keyword(keyword)
