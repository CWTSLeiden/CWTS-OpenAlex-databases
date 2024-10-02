set nocount on

drop table if exists [classification].pub_cluster
select a.pub_no, c.micro_cluster_no, c.meso_cluster_no, c.macro_cluster_no
into [classification].pub_cluster
from [classification].pub as a
join $(previous_classification_db_name).[classification].pub as b on a.work_id = b.work_id
join $(previous_classification_db_name).[classification].pub_cluster as c on b.pub_no = c.pub_no
