set nocount on

select [work_id], [main_field_id], [weight]
from pub_main_field
order by 1, 2
