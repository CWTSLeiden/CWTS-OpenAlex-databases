set nocount on

select [work_id], [p_collab], [p_int_collab], [p_industry], [p_short_dist_collab], [p_long_dist_collab]
from pub_collab_indicators
order by 1, 2
