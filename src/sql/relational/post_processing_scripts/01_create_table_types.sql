set nocount on

if exists(select 1 from sys.types where name='work_id_table') drop type work_id_table
create type work_id_table as table
(
	work_id bigint not null
)
