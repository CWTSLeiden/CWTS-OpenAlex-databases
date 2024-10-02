set nocount on

drop table if exists [classification].cluster_labeling
select *
into [classification].cluster_labeling
from $(previous_classification_db_name).[classification].cluster_labeling
