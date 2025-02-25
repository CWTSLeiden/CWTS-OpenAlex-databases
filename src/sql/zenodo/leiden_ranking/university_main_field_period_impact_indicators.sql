set nocount on

select [university_id], [main_field_id], [period_begin_year], [fractional_counting], [p], [tcs], [tncs], [p_top_1], [p_top_5], [p_top_10], [p_top_50], [mcs], [mcs_lb], [mcs_ub], [mncs], [mncs_lb], [mncs_ub], [pp_top_1], [pp_top_1_lb], [pp_top_1_ub], [pp_top_5], [pp_top_5_lb], [pp_top_5_ub], [pp_top_10], [pp_top_10_lb], [pp_top_10_ub], [pp_top_50], [pp_top_50_lb], [pp_top_50_ub]
from university_main_field_period_impact_indicators
order by 1, 2, 3, 4
