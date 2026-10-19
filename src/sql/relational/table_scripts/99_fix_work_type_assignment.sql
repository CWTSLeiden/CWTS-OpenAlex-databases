set nocount on

-- Letter.
update a with(tablock)
set work_type_id = 29
from work as a
join
(
	select distinct doi
	from $(pubmed_db_name)..pub as a
	join $(pubmed_db_name)..pub_type as b on a.pmid = b.pmid
	join $(pubmed_db_name)..[type] as c on b.type_ui = c.type_ui
	where a.doi is not null
		and c.[type] in ('letter', 'comment')
) as b on a.doi = b.doi

-- Editorial.
update a with(tablock)
set work_type_id = 27
from work as a
join
(
	select distinct doi
	from $(pubmed_db_name)..pub as a
	join $(pubmed_db_name)..pub_type as b on a.pmid = b.pmid
	join $(pubmed_db_name)..[type] as c on b.type_ui = c.type_ui
	where a.doi is not null
		and c.[type] = 'editorial'
) as b on a.doi = b.doi

-- Erratum.
update a with(tablock)
set work_type_id = 28
from work as a
join
(
	select distinct doi
	from $(pubmed_db_name)..pub as a
	join $(pubmed_db_name)..pub_type as b on a.pmid = b.pmid
	join $(pubmed_db_name)..[type] as c on b.type_ui = c.type_ui
	where a.doi is not null
		and c.[type] = 'published erratum'
) as b on a.doi = b.doi

-- Retraction.
update a with(tablock)
set work_type_id = 33
from work as a
join
(
	select distinct doi
	from $(pubmed_db_name)..pub as a
	join $(pubmed_db_name)..pub_type as b on a.pmid = b.pmid
	join $(pubmed_db_name)..[type] as c on b.type_ui = c.type_ui
	where a.doi is not null
		and c.[type] = 'retraction notice'
) as b on a.doi = b.doi



-- Update work_type in work_detail table.

update a with(tablock)
set a.work_type = c.work_type
from work_detail as a
left join work as b on a.work_id = b.work_id
left join work_type as c on b.work_type_id = c.work_type_id
where isnull(a.work_type, '-1') <> isnull(c.work_type, '-1')
