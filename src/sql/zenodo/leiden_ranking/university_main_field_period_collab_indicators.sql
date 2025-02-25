set nocount on

select [university_id], [main_field_id], [period_begin_year], [p], [p_collab], [p_int_collab], [p_industry_collab], [p_short_dist_collab], [p_long_dist_collab], [pp_collab], [pp_collab_lb], [pp_collab_ub], [pp_int_collab], [pp_int_collab_lb], [pp_int_collab_ub], [pp_industry_collab], [pp_industry_collab_lb], [pp_industry_collab_ub], [pp_short_dist_collab], [pp_short_dist_collab_lb], [pp_short_dist_collab_ub], [pp_long_dist_collab], [pp_long_dist_collab_lb], [pp_long_dist_collab_ub]
from university_main_field_period_collab_indicators
order by 1, 2, 3, 4
