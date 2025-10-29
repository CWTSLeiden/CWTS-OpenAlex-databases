set nocount on

select macro_cluster_id, macro_cluster_no, n_works
from macro_cluster
order by 1, 2
