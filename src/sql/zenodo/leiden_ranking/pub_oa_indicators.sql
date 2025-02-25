set nocount on

select [work_id], [p_oa_unknown], [p_oa], [p_gold_oa], [p_hybrid_oa], [p_bronze_oa], [p_green_oa]
from pub_oa_indicators
order by 1, 2
