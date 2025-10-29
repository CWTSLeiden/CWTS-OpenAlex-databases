set nocount on

select micro_cluster_id, main_field_seq, main_field_id, [weight], is_primary_main_field = cast(is_primary_main_field as varchar(10))
from micro_cluster_main_field
order by 1, 2
