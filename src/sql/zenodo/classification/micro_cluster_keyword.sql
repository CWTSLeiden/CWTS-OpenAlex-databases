set nocount on

select micro_cluster_id, keyword_seq, keyword
from micro_cluster_keyword
order by 1, 2
