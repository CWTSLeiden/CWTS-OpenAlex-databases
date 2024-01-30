drop type if exists pub_table
create type pub_table as table
(
	work_id bigint not null
)
