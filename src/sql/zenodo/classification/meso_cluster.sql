set nocount on

select meso_cluster_id, meso_cluster_no, parent_macro_cluster_id, n_works
from meso_cluster
order by 1, 2
