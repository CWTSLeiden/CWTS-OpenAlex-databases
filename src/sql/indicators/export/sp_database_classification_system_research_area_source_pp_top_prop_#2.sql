set nocount ON

select *
from [sp].[database_classification_system_research_area_source_pp_top_prop]
order by 1
offset 2000000000 rows fetch next 1000000000 rows only