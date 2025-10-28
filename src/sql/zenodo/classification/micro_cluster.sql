set nocount on

select micro_cluster_id, micro_cluster_no, short_label, long_label, keywords, summary, wikipedia_url, parent_macro_cluster_id, parent_meso_cluster_id, n_works
from micro_cluster
order by 1, 2
