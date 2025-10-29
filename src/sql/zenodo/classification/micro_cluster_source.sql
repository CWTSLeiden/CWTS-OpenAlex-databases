set nocount on

select micro_cluster_id, source_seq, source_id, n_works
from micro_cluster_source
order by 1, 2
