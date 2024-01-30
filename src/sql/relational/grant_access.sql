create user [$(sql_cwts_group)] from login [$(sql_cwts_group)]
go

grant execute on type::work_id_table to [$(sql_cwts_group)]
go

grant select on get_work_detail to [$(sql_cwts_group)]
go
