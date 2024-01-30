create user [$(sql_cwts_group)] from login [$(sql_cwts_group)]
go

grant select on schema::dbo to [$(sql_cwts_group)]
grant select on schema::excel to [$(sql_cwts_group)]
grant select on schema::vosviewer to [$(sql_cwts_group)]
go
