set nocount on

select meso_cluster_id, source_seq, source_id, n_works
from meso_cluster_source
order by 1, 2
