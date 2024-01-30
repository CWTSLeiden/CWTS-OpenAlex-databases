drop type if exists pub_set_table
create type pub_set_table as table
(
	pub_set_no1 varchar(max) null,
	pub_set_no2 varchar(max) null,
	pub_set_no3 varchar(max) null,
	work_id bigint not null,
	[weight] float null
)
