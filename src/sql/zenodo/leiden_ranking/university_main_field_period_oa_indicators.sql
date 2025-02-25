set nocount on

select [university_id], [main_field_id], [period_begin_year], [p], [p_oa_unknown], [p_oa], [p_gold_oa], [p_hybrid_oa], [p_bronze_oa], [p_green_oa], [pp_oa_unknown], [pp_oa_unknown_lb], [pp_oa_unknown_ub], [pp_oa], [pp_oa_lb], [pp_oa_ub], [pp_gold_oa], [pp_gold_oa_lb], [pp_gold_oa_ub], [pp_hybrid_oa], [pp_hybrid_oa_lb], [pp_hybrid_oa_ub], [pp_bronze_oa], [pp_bronze_oa_lb], [pp_bronze_oa_ub], [pp_green_oa], [pp_green_oa_lb], [pp_green_oa_ub]
from university_main_field_period_oa_indicators
order by 1, 2, 3, 4
