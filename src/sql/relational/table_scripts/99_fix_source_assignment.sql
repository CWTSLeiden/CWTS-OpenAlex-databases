set nocount on

-- Conference proceedings.

-- Proceedings of SPIE, the International Society for Optical Engineering/Proceedings of SPIE (journal)
update work with(tablock)
set source_id = 183492911
where source_id is null
	and doi like '10.1117/12.%'

-- IEEE Conference Proceedings
update a with(tablock)
set a.source_id = 4306512817
from work as a
join $(crossref_db_name)..pub as b on a.doi = b.doi
where a.source_id is null
	and (a.doi like '10.1109/%' or a.doi like '10.23919/%')
	and b.[type_id] = 2  -- conference_paper

-- ACM Proceedings (journal)
update a with(tablock)
set a.source_id = 4306500161
from work as a
join $(crossref_db_name)..pub as b on a.doi = b.doi
where a.source_id is null
	and a.doi like '10.1145/%'
	and b.[type_id] = 2  -- conference_paper

-- ASME Conference Proceedings
update a with(tablock)
set a.source_id = 4306503498
from work as a
join $(crossref_db_name)..pub as b on a.doi = b.doi
where a.source_id is null
	and a.doi like '10.1115/%'
	and b.[type_id] = 2  -- conference_paper



-- Preprint repositories.

-- Authorea (Authorea)
update work with(tablock)
set source_id = 4306402105
where source_id is null
	and doi like '10.22541/au.%'

-- arXiv (Cornell University)
update work with(tablock)
set source_id = 4306400194
where source_id is null
	and doi like '10.48550/arxiv.%'

-- Research Square
update work with(tablock)
set source_id = 4306525896
where source_id is null
	and doi like '10.21203/rs.%'



-- Ebook platforms.

-- Springer eBooks
update work with(tablock)
set source_id = 4306463937
where source_id is null
	and (doi like '10.1007/978%' or doi like '10.1007/[0-9]-%-[0-9X]' or doi like '10.1007/%[_]%' or doi like '10.1007/b[0-9]%' or doi like '10.1007/bfb[0-9]%')
	and doi not like '10.1007/s%'

-- Taylor & Francis eBooks
update work with(tablock)
set source_id = 4306463973
where source_id is null
	and doi like '10.4324/978%'

-- De Gruyter eBooks
update work with(tablock)
set source_id = 4306463091
where source_id is null
	and doi like '10.1515/978%'

-- CRC Press eBooks
update work with(tablock)
set source_id = 4306463075
where source_id is null
	and (doi like '10.1201/978%' or doi like '10.1201/b%')

-- BRILL eBooks
update work with(tablock)
set source_id = 4306462964
where source_id is null
	and (doi like '10.1163/978%' or doi like '10.30965/978%')

-- University of California Press eBooks
update work with(tablock)
set source_id = 4306464154
where source_id is null
	and (doi like '10.1525/978%' or doi like '10.1525/california/978%')

-- Oxford University Press eBooks
update work with(tablock)
set source_id = 4306463708
where source_id is null
	and (doi like '10.1093/978%' or doi like '10.1093/%/978%')

-- Duke University Press eBooks
update work with(tablock)
set source_id = 4306463122
where source_id is null
	and doi like '10.1215/978%'

-- Thieme eBooks
update work with(tablock)
set source_id = 4306464010
where source_id is null
	and doi like '10.1055/b-%'

-- SAGE Publications Ltd eBooks
update work with(tablock)
set source_id = 4306463871
where source_id is null
	and doi like '10.4135/978%'

-- EDP Sciences eBooks
update work with(tablock)
set source_id = 4306463217
where source_id is null
	and doi like '10.1051/978%'

-- Emerald eBooks
update work with(tablock)
set source_id = 4306470099
where source_id is null
	and doi like '10.1108/978%'

-- University of Chicago Press eBooks
update work with(tablock)
set source_id = 4306464156
where source_id is null
	and (doi like '10.7208/978%' or doi like '10.7208/chicago/978%')

-- Bloomsbury Academic eBooks
update work with(tablock)
set source_id = 4306462936
where source_id is null
	and doi like '10.5040/978%'

-- International Union of Pure and Applied Chemistry (IUPAC) eBooks
update work with(tablock)
set source_id = 4306488284
where source_id is null
	and doi like '10.1351/goldbook%'

-- Wiley eBooks
update work with(tablock)
set source_id = 4306464293
where source_id is null
	and doi like '10.1002/978%'

-- Presses universitaires du Midi eBooks
update work with(tablock)
set source_id = 4306463801
where source_id is null
	and doi like '10.4000/books.pum%'

-- MDPI eBooks
update work with(tablock)
set source_id = 4306463611
where source_id is null
	and doi like '10.3390/books978%'

-- Institute of Physics eBooks
update work with(tablock)
set source_id = 4306473083
where source_id is null
	and (doi like '10.1088/978%' or doi like '10.1888/033375%' or doi like '10.1887/075030%' or doi like '10.1887/085274%' or doi like '10.1088/2514-3433/%')

-- Iberoamericana Vervuert eBooks
update work with(tablock)
set source_id = 4306463402
where source_id is null
	and doi like '10.31819/978%'

-- ASM Press eBooks
update work with(tablock)
set source_id = 4306462867
where source_id is null
	and doi like '10.1128/978%'

-- The University Press of Kentucky eBooks
update work with(tablock)
set source_id = 4306464007
where source_id is null
	and doi like '10.5810/kentucky/978%'

-- Institute of Electrical and Electronics Engineers eBooks
update work with(tablock)
set source_id = 4306473032
where source_id is null
	and doi like '10.1109/978%'

-- Royal Society of Chemistry eBooks
update work with(tablock)
set source_id = 4306463862
where source_id is null
	and doi like '10.1039/978%'

-- IGI Global eBooks
update work with(tablock)
set source_id = 4306463409
where source_id is null
	and (doi like '10.4018/978%' or doi like '10.4018/979%')

-- Amsterdam University Press eBooks
update work with(tablock)
set source_id = 4306462833
where source_id is null
	and doi like '10.5117/978%'

-- WORLD SCIENTIFIC eBooks
update work with(tablock)
set source_id = 4306464320
where source_id is null
	and doi like '10.1142/978%'

-- KARGER eBooks
update work with(tablock)
set source_id = 4306463508
where source_id is null
	and doi like '10.1159/000%'

-- Informa Healthcare eBooks
update work with(tablock)
set source_id = 4306463421
where source_id is null
	and doi like '10.3109/978%'

-- World Bank, Washington, DC eBooks
update work with(tablock)
set source_id = 4306464317
where source_id is null
	and doi like '10.1596/978%'

-- Ankara Pegem Akademi Yayıncılık eBooks
update work with(tablock)
set source_id = 4306485964
where source_id is null
	and doi like '10.14527/978%'

-- American Society of Civil Engineers eBooks
update work with(tablock)
set source_id = 4306462827
where source_id is null
	and doi like '10.1061/978%'

-- SPIE eBooks
update work with(tablock)
set source_id = 4306463935
where source_id is null
	and doi like '10.1117/3.%'



-- Update source title in work_detail table.

update a with(tablock)
set a.[source] = c.[source]
from work_detail as a
join work as b on a.work_id = b.work_id
join [source] as c on b.source_id = c.source_id
where a.[source] is null
	and c.[source] is not null
