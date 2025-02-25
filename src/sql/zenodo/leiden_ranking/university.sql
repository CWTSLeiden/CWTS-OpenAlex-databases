set nocount on

select [university_id], [university], [university_full_name], [ror_id], [ror_name], [country_code], [latitude], [longitude], [is_mtor_university]
from university
order by 1, 2
