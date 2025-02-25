set nocount on

select a.[work_id], [doi] = isnull(b.[doi], ''), a.[pub_year], [micro_cluster_id] = c.research_area_no
from pub as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
join $(relational_db_name)_indicators..pub_classification_system_research_area as c on a.work_id = c.work_id
    and c.classification_system_no = 2
order by 1, 2
