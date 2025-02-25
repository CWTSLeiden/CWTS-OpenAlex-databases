set nocount on

select a.work_id, doi = isnull(b.doi, ''), a.macro_cluster_id, a.meso_cluster_id, a.micro_cluster_id
from clustering as a
join openalex_2024aug..work as b on a.work_id = b.work_id
order by 1, 2, 3, 4
