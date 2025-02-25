set nocount on

select macro_cluster_id, main_field_seq, main_field_id, [weight], is_primary_main_field
from macro_cluster_main_field
order by 1, 2
