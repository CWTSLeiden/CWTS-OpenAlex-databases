set nocount on

select
    work_id = a.work_id,
    work_type = c.work_type,
    pub_year = b.pub_year,
    source_id = b.source_id,
    doi = b.doi,
    is_core_work = cast(a.is_core_work as varchar(10))
from work as a
join $(relational_db_name)..work as b on a.work_id = b.work_id
left join $(relational_db_name)..work_type as c on b.work_type_id = c.work_type_id
where a.is_core_work is not null
order by 1
