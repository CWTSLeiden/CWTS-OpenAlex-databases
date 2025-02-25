set nocount on

select [university_ror_id], [relation_type], [affiliated_organization_ror_id], [affiliated_organization_weight]
from university_affiliated_organization
order by 1, 2, 3
