set nocount on

select [work_id], [period_begin_year], [cs], [ncs], [p_top_1], [p_top_5], [p_top_10], [p_top_50]
from pub_period_impact_indicators
order by 1, 2
