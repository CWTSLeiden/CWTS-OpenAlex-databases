set nocount on

-- Main fields.

drop table if exists main_field
create table main_field
(
	main_field_id tinyint not null,
	main_field varchar(50) not null
)

insert into main_field with(tablock)
select *
from wos_2313_classification..LR_main_field

alter table main_field add constraint pk_main_field primary key(main_field_id)



-- Mapping of OpenAlex level 0 concepts to Leiden Ranking main fields.

drop table if exists #level0_concept_main_field
create table #level0_concept_main_field
(
	concept varchar(50) not null,
	main_field varchar(50) not null
)

insert into #level0_concept_main_field
values
	('Art', 'Social sciences and humanities'),
	('Biology', 'Life and earth sciences'),
	('Business', 'Social sciences and humanities'),
	('Chemistry', 'Physical sciences and engineering'),
	('Computer science', 'Mathematics and computer science'),
	('Economics', 'Social sciences and humanities'),
	('Engineering', 'Physical sciences and engineering'),
	('Environmental science', 'Life and earth sciences'),
	('Geography', 'Life and earth sciences'),
	('Geology', 'Life and earth sciences'),
	('History', 'Social sciences and humanities'),
	('Materials science', 'Physical sciences and engineering'),
	('Mathematics', 'Mathematics and computer science'),
	('Medicine', 'Biomedical and health sciences'),
	('Philosophy', 'Social sciences and humanities'),
	('Physics', 'Physical sciences and engineering'),
	('Political science', 'Social sciences and humanities'),
	('Psychology', 'Social sciences and humanities'),
	('Sociology', 'Social sciences and humanities')

drop table if exists level0_concept_main_field
create table level0_concept_main_field
(
	concept_id bigint not null,
	main_field_id tinyint not null
)

insert into level0_concept_main_field with(tablock)
select b.concept_id, c.main_field_id
from #level0_concept_main_field as a
join $(relational_db_name)..concept as b on a.concept = b.concept
join main_field as c on a.main_field = c.main_field
where b.[level] = 0

alter table level0_concept_main_field add constraint pk_level0_concept_main_field primary key(concept_id, main_field_id)

-- Check if all level 0 concepts are assigned to a Leiden Ranking main field.
if exists
(
	select 0
	from $(relational_db_name)..concept as a
	left join level0_concept_main_field as b on a.concept_id = b.concept_id
	where a.[level] = 0
		and b.main_field_id is null
)
begin
	raiserror('One or more level 0 concepts are not assigned to a Leiden Ranking main field.', 2, 0)
end



-- Mapping of OpenAlex level 1 concepts to Leiden Ranking main fields.

drop table if exists #level1_concept_main_field
create table #level1_concept_main_field
(
	concept_id bigint not null,
	concept varchar(50) not null,
	main_field_id tinyint not null,
	main_field varchar(50) not null
)

insert into #level1_concept_main_field
values
	(105702510, 'Anatomy', 2, 'Biomedical and health sciences'),
	(16685009, 'Andrology', 2, 'Biomedical and health sciences'),
	(42219234, 'Anesthesia', 2, 'Biomedical and health sciences'),
	(548259974, 'Audiology', 2, 'Biomedical and health sciences'),
	(55493867, 'Biochemistry', 2, 'Biomedical and health sciences'),
	(60644358, 'Bioinformatics', 2, 'Biomedical and health sciences'),
	(186060115, 'Biological system', 2, 'Biomedical and health sciences'),
	(136229726, 'Biomedical engineering', 2, 'Biomedical and health sciences'),
	(12554922, 'Biophysics', 2, 'Biomedical and health sciences'),
	(502942594, 'Cancer research', 2, 'Biomedical and health sciences'),
	(164705383, 'Cardiology', 2, 'Biomedical and health sciences'),
	(95444343, 'Cell biology', 2, 'Biomedical and health sciences'),
	(70410870, 'Clinical psychology', 2, 'Biomedical and health sciences'),
	(70721500, 'Computational biology', 2, 'Biomedical and health sciences'),
	(149923435, 'Demography', 2, 'Biomedical and health sciences'),
	(199343813, 'Dentistry', 2, 'Biomedical and health sciences'),
	(16005928, 'Dermatology', 2, 'Biomedical and health sciences'),
	(194828623, 'Emergency medicine', 2, 'Biomedical and health sciences'),
	(134018914, 'Endocrinology', 2, 'Biomedical and health sciences'),
	(99454951, 'Environmental health', 2, 'Biomedical and health sciences'),
	(512399662, 'Family medicine', 2, 'Biomedical and health sciences'),
	(90924648, 'Gastroenterology', 2, 'Biomedical and health sciences'),
	(61434518, 'General surgery', 2, 'Biomedical and health sciences'),
	(54355233, 'Genetics', 2, 'Biomedical and health sciences'),
	(74909509, 'Gerontology', 2, 'Biomedical and health sciences'),
	(29456083, 'Gynecology', 2, 'Biomedical and health sciences'),
	(203014093, 'Immunology', 2, 'Biomedical and health sciences'),
	(177713679, 'Intensive care medicine', 2, 'Biomedical and health sciences'),
	(126322002, 'Internal medicine', 2, 'Biomedical and health sciences'),
	(509550671, 'Medical education', 2, 'Biomedical and health sciences'),
	(545542383, 'Medical emergency', 2, 'Biomedical and health sciences'),
	(19527891, 'Medical physics', 2, 'Biomedical and health sciences'),
	(89423630, 'Microbiology', 2, 'Biomedical and health sciences'),
	(153911025, 'Molecular biology', 2, 'Biomedical and health sciences'),
	(169760540, 'Neuroscience', 2, 'Biomedical and health sciences'),
	(2989005, 'Nuclear medicine', 2, 'Biomedical and health sciences'),
	(159110408, 'Nursing', 2, 'Biomedical and health sciences'),
	(131872663, 'Obstetrics', 2, 'Biomedical and health sciences'),
	(143998085, 'Oncology', 2, 'Biomedical and health sciences'),
	(118487528, 'Ophthalmology', 2, 'Biomedical and health sciences'),
	(119767625, 'Optometry', 2, 'Biomedical and health sciences'),
	(29694066, 'Orthodontics', 2, 'Biomedical and health sciences'),
	(142724271, 'Pathology', 2, 'Biomedical and health sciences'),
	(187212893, 'Pediatrics', 2, 'Biomedical and health sciences'),
	(98274493, 'Pharmacology', 2, 'Biomedical and health sciences'),
	(99508421, 'Physical medicine and rehabilitation', 2, 'Biomedical and health sciences'),
	(1862650, 'Physical therapy', 2, 'Biomedical and health sciences'),
	(42407357, 'Physiology', 2, 'Biomedical and health sciences'),
	(118552586, 'Psychiatry', 2, 'Biomedical and health sciences'),
	(126838900, 'Radiology', 2, 'Biomedical and health sciences'),
	(141071460, 'Surgery', 2, 'Biomedical and health sciences'),
	(33070731, 'Toxicology', 4, 'Life and earth sciences'),
	(556039675, 'Traditional medicine', 2, 'Biomedical and health sciences'),
	(126894567, 'Urology', 2, 'Biomedical and health sciences'),
	(159047783, 'Virology', 2, 'Biomedical and health sciences'),
	(88463610, 'Agricultural engineering', 4, 'Life and earth sciences'),
	(37621935, 'Agricultural science', 4, 'Life and earth sciences'),
	(54286561, 'Agroforestry', 4, 'Life and earth sciences'),
	(6557445, 'Agronomy', 4, 'Life and earth sciences'),
	(140793950, 'Animal science', 4, 'Life and earth sciences'),
	(166957645, 'Archaeology', 4, 'Life and earth sciences'),
	(91586092, 'Atmospheric sciences', 4, 'Life and earth sciences'),
	(150903083, 'Biotechnology', 4, 'Life and earth sciences'),
	(59822182, 'Botany', 4, 'Life and earth sciences'),
	(58640448, 'Cartography', 4, 'Life and earth sciences'),
	(49204034, 'Climatology', 4, 'Life and earth sciences'),
	(1965285, 'Earth science', 4, 'Life and earth sciences'),
	(18903297, 'Ecology', 4, 'Life and earth sciences'),
	(107872376, 'Environmental chemistry', 4, 'Life and earth sciences'),
	(87717796, 'Environmental engineering', 4, 'Life and earth sciences'),
	(91375879, 'Environmental planning', 4, 'Life and earth sciences'),
	(526734887, 'Environmental protection', 4, 'Life and earth sciences'),
	(107826830, 'Environmental resource management', 4, 'Life and earth sciences'),
	(78458016, 'Evolutionary biology', 4, 'Life and earth sciences'),
	(505870484, 'Fishery', 4, 'Life and earth sciences'),
	(31903555, 'Food science', 4, 'Life and earth sciences'),
	(97137747, 'Forestry', 4, 'Life and earth sciences'),
	(17409809, 'Geochemistry', 4, 'Life and earth sciences'),
	(13280743, 'Geodesy', 4, 'Life and earth sciences'),
	(114793014, 'Geomorphology', 4, 'Life and earth sciences'),
	(8058405, 'Geophysics', 4, 'Life and earth sciences'),
	(144027150, 'Horticulture', 4, 'Life and earth sciences'),
	(153294291, 'Meteorology', 4, 'Life and earth sciences'),
	(199289684, 'Mineralogy', 4, 'Life and earth sciences'),
	(175605778, 'Natural resource economics', 4, 'Life and earth sciences'),
	(111368507, 'Oceanography', 4, 'Life and earth sciences'),
	(151730666, 'Paleontology', 4, 'Life and earth sciences'),
	(5900021, 'Petrology', 4, 'Life and earth sciences'),
	(100970517, 'Physical geography', 4, 'Life and earth sciences'),
	(62649853, 'Remote sensing', 4, 'Life and earth sciences'),
	(165205528, 'Seismology', 4, 'Life and earth sciences'),
	(159390177, 'Soil science', 4, 'Life and earth sciences'),
	(42972112, 'Veterinary medicine', 4, 'Life and earth sciences'),
	(548081761, 'Waste management', 4, 'Life and earth sciences'),
	(524765639, 'Water resource management', 4, 'Life and earth sciences'),
	(90856448, 'Zoology', 4, 'Life and earth sciences'),
	(11413529, 'Algorithm', 5, 'Mathematics and computer science'),
	(28826006, 'Applied mathematics', 5, 'Mathematics and computer science'),
	(94375191, 'Arithmetic', 5, 'Mathematics and computer science'),
	(154945302, 'Artificial intelligence', 5, 'Mathematics and computer science'),
	(114614502, 'Combinatorics', 5, 'Mathematics and computer science'),
	(459310, 'Computational science', 5, 'Mathematics and computer science'),
	(118524514, 'Computer architecture', 5, 'Mathematics and computer science'),
	(113775141, 'Computer engineering', 5, 'Mathematics and computer science'),
	(121684516, 'Computer graphics (images)', 5, 'Mathematics and computer science'),
	(9390403, 'Computer hardware', 5, 'Mathematics and computer science'),
	(31258907, 'Computer network', 5, 'Mathematics and computer science'),
	(38652104, 'Computer security', 5, 'Mathematics and computer science'),
	(31972630, 'Computer vision', 5, 'Mathematics and computer science'),
	(133731056, 'Control engineering', 5, 'Mathematics and computer science'),
	(124101348, 'Data mining', 5, 'Mathematics and computer science'),
	(2522767166, 'Data science', 5, 'Mathematics and computer science'),
	(77088390, 'Database', 5, 'Mathematics and computer science'),
	(118615104, 'Discrete mathematics', 5, 'Mathematics and computer science'),
	(120314980, 'Distributed computing', 5, 'Mathematics and computer science'),
	(119599485, 'Electrical engineering', 5, 'Mathematics and computer science'),
	(24326235, 'Electronic engineering', 5, 'Mathematics and computer science'),
	(149635348, 'Embedded system', 5, 'Mathematics and computer science'),
	(2524010, 'Geometry', 5, 'Mathematics and computer science'),
	(107457646, 'Human–computer interaction', 5, 'Mathematics and computer science'),
	(23123220, 'Information retrieval', 5, 'Mathematics and computer science'),
	(108827166, 'Internet privacy', 5, 'Mathematics and computer science'),
	(119857082, 'Machine learning', 5, 'Mathematics and computer science'),
	(134306372, 'Mathematical analysis', 5, 'Mathematics and computer science'),
	(144237770, 'Mathematical economics', 5, 'Mathematics and computer science'),
	(126255220, 'Mathematical optimization', 5, 'Mathematics and computer science'),
	(49774154, 'Multimedia', 5, 'Mathematics and computer science'),
	(204321447, 'Natural language processing', 5, 'Mathematics and computer science'),
	(111919701, 'Operating system', 5, 'Mathematics and computer science'),
	(21547014, 'Operations management', 5, 'Mathematics and computer science'),
	(42475967, 'Operations research', 5, 'Mathematics and computer science'),
	(173608175, 'Parallel computing', 5, 'Mathematics and computer science'),
	(199360897, 'Programming language', 5, 'Mathematics and computer science'),
	(202444582, 'Pure mathematics', 5, 'Mathematics and computer science'),
	(79403827, 'Real-time computing', 5, 'Mathematics and computer science'),
	(112930515, 'Risk analysis (engineering)', 5, 'Mathematics and computer science'),
	(44154836, 'Simulation', 5, 'Mathematics and computer science'),
	(115903868, 'Software engineering', 5, 'Mathematics and computer science'),
	(28490314, 'Speech recognition', 5, 'Mathematics and computer science'),
	(105795698, 'Statistics', 5, 'Mathematics and computer science'),
	(76155785, 'Telecommunications', 5, 'Mathematics and computer science'),
	(80444323, 'Theoretical computer science', 5, 'Mathematics and computer science'),
	(136764020, 'World Wide Web', 5, 'Mathematics and computer science'),
	(24890656, 'Acoustics', 3, 'Physical sciences and engineering'),
	(178802073, 'Aeronautics', 3, 'Physical sciences and engineering'),
	(146978453, 'Aerospace engineering', 3, 'Physical sciences and engineering'),
	(170154142, 'Architectural engineering', 3, 'Physical sciences and engineering'),
	(87355193, 'Astrobiology', 3, 'Physical sciences and engineering'),
	(1276947, 'Astronomy', 3, 'Physical sciences and engineering'),
	(44870925, 'Astrophysics', 3, 'Physical sciences and engineering'),
	(184779094, 'Atomic physics', 3, 'Physical sciences and engineering'),
	(171146098, 'Automotive engineering', 3, 'Physical sciences and engineering'),
	(183696295, 'Biochemical engineering', 3, 'Physical sciences and engineering'),
	(42360764, 'Chemical engineering', 3, 'Physical sciences and engineering'),
	(159467904, 'Chemical physics', 3, 'Physical sciences and engineering'),
	(43617362, 'Chromatography', 3, 'Physical sciences and engineering'),
	(147176958, 'Civil engineering', 3, 'Physical sciences and engineering'),
	(74650414, 'Classical mechanics', 3, 'Physical sciences and engineering'),
	(21951064, 'Combinatorial chemistry', 3, 'Physical sciences and engineering'),
	(159985019, 'Composite material', 3, 'Physical sciences and engineering'),
	(147597530, 'Computational chemistry', 3, 'Physical sciences and engineering'),
	(30475298, 'Computational physics', 3, 'Physical sciences and engineering'),
	(26873012, 'Condensed matter physics', 3, 'Physical sciences and engineering'),
	(107053488, 'Construction engineering', 3, 'Physical sciences and engineering'),
	(8010536, 'Crystallography', 3, 'Physical sciences and engineering'),
	(199639397, 'Engineering drawing', 3, 'Physical sciences and engineering'),
	(61696701, 'Engineering physics', 3, 'Physical sciences and engineering'),
	(77595967, 'Forensic engineering', 3, 'Physical sciences and engineering'),
	(187320778, 'Geotechnical engineering', 3, 'Physical sciences and engineering'),
	(13736549, 'Industrial engineering', 3, 'Physical sciences and engineering'),
	(179104552, 'Inorganic chemistry', 3, 'Physical sciences and engineering'),
	(117671659, 'Manufacturing engineering', 3, 'Physical sciences and engineering'),
	(199104240, 'Marine engineering', 3, 'Physical sciences and engineering'),
	(37914503, 'Mathematical physics', 3, 'Physical sciences and engineering'),
	(78519656, 'Mechanical engineering', 3, 'Physical sciences and engineering'),
	(57879066, 'Mechanics', 3, 'Physical sciences and engineering'),
	(155647269, 'Medicinal chemistry', 3, 'Physical sciences and engineering'),
	(191897082, 'Metallurgy', 3, 'Physical sciences and engineering'),
	(16674752, 'Mining engineering', 3, 'Physical sciences and engineering'),
	(41999313, 'Molecular physics', 3, 'Physical sciences and engineering'),
	(171250308, 'Nanotechnology', 3, 'Physical sciences and engineering'),
	(13965031, 'Nuclear chemistry', 3, 'Physical sciences and engineering'),
	(116915560, 'Nuclear engineering', 3, 'Physical sciences and engineering'),
	(46141821, 'Nuclear magnetic resonance', 3, 'Physical sciences and engineering'),
	(185544564, 'Nuclear physics', 3, 'Physical sciences and engineering'),
	(120665830, 'Optics', 3, 'Physical sciences and engineering'),
	(49040817, 'Optoelectronics', 3, 'Physical sciences and engineering'),
	(178790620, 'Organic chemistry', 3, 'Physical sciences and engineering'),
	(109214941, 'Particle physics', 3, 'Physical sciences and engineering'),
	(78762247, 'Petroleum engineering', 3, 'Physical sciences and engineering'),
	(75473681, 'Photochemistry', 3, 'Physical sciences and engineering'),
	(147789679, 'Physical chemistry', 3, 'Physical sciences and engineering'),
	(188027245, 'Polymer chemistry', 3, 'Physical sciences and engineering'),
	(126348684, 'Polymer science', 3, 'Physical sciences and engineering'),
	(21880701, 'Process engineering', 3, 'Physical sciences and engineering'),
	(528095902, 'Pulp and paper industry', 3, 'Physical sciences and engineering'),
	(3079626, 'Quantum electrodynamics', 3, 'Physical sciences and engineering'),
	(62520636, 'Quantum mechanics', 3, 'Physical sciences and engineering'),
	(177322064, 'Radiochemistry', 3, 'Physical sciences and engineering'),
	(200601418, 'Reliability engineering', 3, 'Physical sciences and engineering'),
	(121864883, 'Statistical physics', 3, 'Physical sciences and engineering'),
	(71240020, 'Stereochemistry', 3, 'Physical sciences and engineering'),
	(66938386, 'Structural engineering', 3, 'Physical sciences and engineering'),
	(201995342, 'Systems engineering', 3, 'Physical sciences and engineering'),
	(33332235, 'Theoretical physics', 3, 'Physical sciences and engineering'),
	(97355855, 'Thermodynamics', 3, 'Physical sciences and engineering'),
	(22212356, 'Transport engineering', 3, 'Physical sciences and engineering'),
	(121955636, 'Accounting', 1, 'Social sciences and humanities'),
	(162118730, 'Actuarial science', 1, 'Social sciences and humanities'),
	(112698675, 'Advertising', 1, 'Social sciences and humanities'),
	(107038049, 'Aesthetics', 1, 'Social sciences and humanities'),
	(48824518, 'Agricultural economics', 1, 'Social sciences and humanities'),
	(195244886, 'Ancient history', 1, 'Social sciences and humanities'),
	(19165224, 'Anthropology', 1, 'Social sciences and humanities'),
	(75630572, 'Applied psychology', 1, 'Social sciences and humanities'),
	(52119013, 'Art history', 1, 'Social sciences and humanities'),
	(178550888, 'Business administration', 1, 'Social sciences and humanities'),
	(167562979, 'Classical economics', 1, 'Social sciences and humanities'),
	(74916050, 'Classics', 1, 'Social sciences and humanities'),
	(180747234, 'Cognitive psychology', 1, 'Social sciences and humanities'),
	(188147891, 'Cognitive science', 1, 'Social sciences and humanities'),
	(54750564, 'Commerce', 1, 'Social sciences and humanities'),
	(46312422, 'Communication', 1, 'Social sciences and humanities'),
	(73484699, 'Criminology', 1, 'Social sciences and humanities'),
	(4249254, 'Demographic economics', 1, 'Social sciences and humanities'),
	(47768531, 'Development economics', 1, 'Social sciences and humanities'),
	(138496976, 'Developmental psychology', 1, 'Social sciences and humanities'),
	(149782125, 'Econometrics', 1, 'Social sciences and humanities'),
	(26271046, 'Economic geography', 1, 'Social sciences and humanities'),
	(50522688, 'Economic growth', 1, 'Social sciences and humanities'),
	(6303427, 'Economic history', 1, 'Social sciences and humanities'),
	(105639569, 'Economic policy', 1, 'Social sciences and humanities'),
	(74363100, 'Economic system', 1, 'Social sciences and humanities'),
	(136264566, 'Economy', 1, 'Social sciences and humanities'),
	(55587333, 'Engineering ethics', 1, 'Social sciences and humanities'),
	(110354214, 'Engineering management', 1, 'Social sciences and humanities'),
	(134560507, 'Environmental economics', 1, 'Social sciences and humanities'),
	(95124753, 'Environmental ethics', 1, 'Social sciences and humanities'),
	(111472728, 'Epistemology', 1, 'Social sciences and humanities'),
	(2549261, 'Ethnology', 1, 'Social sciences and humanities'),
	(10138342, 'Finance', 1, 'Social sciences and humanities'),
	(106159729, 'Financial economics', 1, 'Social sciences and humanities'),
	(73283319, 'Financial system', 1, 'Social sciences and humanities'),
	(107993555, 'Gender studies', 1, 'Social sciences and humanities'),
	(53553401, 'Genealogy', 1, 'Social sciences and humanities'),
	(15708023, 'Humanities', 1, 'Social sciences and humanities'),
	(40700, 'Industrial organization', 1, 'Social sciences and humanities'),
	(18547055, 'International economics', 1, 'Social sciences and humanities'),
	(155202549, 'International trade', 1, 'Social sciences and humanities'),
	(165556158, 'Keynesian economics', 1, 'Social sciences and humanities'),
	(56739046, 'Knowledge management', 1, 'Social sciences and humanities'),
	(145236788, 'Labour economics', 1, 'Social sciences and humanities'),
	(199539241, 'Law', 1, 'Social sciences and humanities'),
	(190253527, 'Law and economics', 1, 'Social sciences and humanities'),
	(161191863, 'Library science', 1, 'Social sciences and humanities'),
	(41895202, 'Linguistics', 1, 'Social sciences and humanities'),
	(124952713, 'Literature', 1, 'Social sciences and humanities'),
	(139719470, 'Macroeconomics', 1, 'Social sciences and humanities'),
	(187736073, 'Management', 1, 'Social sciences and humanities'),
	(539667460, 'Management science', 1, 'Social sciences and humanities'),
	(34447519, 'Market economy', 1, 'Social sciences and humanities'),
	(162853370, 'Marketing', 1, 'Social sciences and humanities'),
	(145420912, 'Mathematics education', 1, 'Social sciences and humanities'),
	(29595303, 'Media studies', 1, 'Social sciences and humanities'),
	(175444787, 'Microeconomics', 1, 'Social sciences and humanities'),
	(556758197, 'Monetary economics', 1, 'Social sciences and humanities'),
	(133425853, 'Neoclassical economics', 1, 'Social sciences and humanities'),
	(19417346, 'Pedagogy', 1, 'Social sciences and humanities'),
	(138921699, 'Political economy', 1, 'Social sciences and humanities'),
	(118084267, 'Positive economics', 1, 'Social sciences and humanities'),
	(195094911, 'Process management', 1, 'Social sciences and humanities'),
	(11171543, 'Psychoanalysis', 1, 'Social sciences and humanities'),
	(542102704, 'Psychotherapist', 1, 'Social sciences and humanities'),
	(3116431, 'Public administration', 1, 'Social sciences and humanities'),
	(100001284, 'Public economics', 1, 'Social sciences and humanities'),
	(39549134, 'Public relations', 1, 'Social sciences and humanities'),
	(148383697, 'Regional science', 1, 'Social sciences and humanities'),
	(24667770, 'Religious studies', 1, 'Social sciences and humanities'),
	(77805123, 'Social psychology', 1, 'Social sciences and humanities'),
	(36289849, 'Social science', 1, 'Social sciences and humanities'),
	(45355965, 'Socioeconomics', 1, 'Social sciences and humanities'),
	(27206212, 'Theology', 1, 'Social sciences and humanities'),
	(153349607, 'Visual arts', 1, 'Social sciences and humanities'),
	(549774020, 'Welfare economics', 1, 'Social sciences and humanities')

drop table if exists level1_concept_main_field
create table level1_concept_main_field
(
	concept_id bigint not null,
	main_field_id tinyint not null
)

insert into level1_concept_main_field with(tablock)
select b.concept_id, c.main_field_id
from #level1_concept_main_field as a
join $(relational_db_name)..concept as b on a.concept = b.concept
join main_field as c on a.main_field = c.main_field
where b.[level] = 1

alter table level1_concept_main_field add constraint pk_level1_concept_main_field primary key(concept_id, main_field_id)

-- Check if all level 1 concepts are assigned to a Leiden Ranking main field.
if exists
(
	select 0
	from $(relational_db_name)..concept as a
	left join level1_concept_main_field as b on a.concept_id = b.concept_id
	where a.[level] = 1
		and b.main_field_id is null
)
begin
	raiserror('One or more level 1 concepts are not assigned to a Leiden Ranking main field.', 2, 0)
end



-- Mapping of works to level 0 concepts.

drop table if exists #work_level0_concept
select a.work_id, b.concept_id, b.score
into #work_level0_concept
from clustering as a
join $(relational_db_name)..work_concept as b on a.work_id = b.work_id
join $(relational_db_name)..concept as c on b.concept_id = c.concept_id
where c.[level] = 0
	and b.score >= 0.2

drop table if exists #work_level0_concept2
select a.work_id, a.concept_id, [weight] = a.score / b.sum_score
into #work_level0_concept2
from #work_level0_concept as a
join
(
	select work_id, sum_score = sum(score)
	from #work_level0_concept
	group by work_id
) as b on a.work_id = b.work_id



-- Mapping of works to level 1 concepts.

drop table if exists #work_level1_concept
select a.work_id, b.concept_id, b.score
into #work_level1_concept
from clustering as a
join $(relational_db_name)..work_concept as b on a.work_id = b.work_id
join $(relational_db_name)..concept as c on b.concept_id = c.concept_id
where c.[level] = 1
	and b.score >= 0.2

drop table if exists #work_level1_concept2
select a.work_id, a.concept_id, [weight] = a.score / b.sum_score
into #work_level1_concept2
from #work_level1_concept as a
join
(
	select work_id, sum_score = sum(score)
	from #work_level1_concept
	group by work_id
) as b on a.work_id = b.work_id



-- Mapping of macro clusters.

-- Mapping of macro clusters to level 0 concepts.

drop table if exists #macro_cluster_level0_concept
select a.macro_cluster_id, concept_id, n_works = sum(b.[weight])
into #macro_cluster_level0_concept
from clustering as a
join #work_level0_concept2 as b on a.work_id = b.work_id
group by a.macro_cluster_id, b.concept_id

drop table if exists #macro_cluster_level0_concept2
select a.macro_cluster_id, a.concept_id, a.n_works, [weight] = a.n_works / b.total_n_works, [rank] = row_number() over (partition by a.macro_cluster_id order by a.n_works desc, a.concept_id)
into #macro_cluster_level0_concept2
from #macro_cluster_level0_concept as a
join
(
	select macro_cluster_id, total_n_works = sum(n_works)
	from #macro_cluster_level0_concept
	group by macro_cluster_id
) as b on a.macro_cluster_id = b.macro_cluster_id

-- Mapping of macro clusters to level 1 concepts.

drop table if exists #macro_cluster_level1_concept
select a.macro_cluster_id, concept_id, n_works = sum(b.[weight])
into #macro_cluster_level1_concept
from clustering as a
join #work_level1_concept2 as b on a.work_id = b.work_id
group by a.macro_cluster_id, b.concept_id

drop table if exists #macro_cluster_level1_concept2
select a.macro_cluster_id, a.concept_id, a.n_works, [weight] = a.n_works / b.total_n_works, [rank] = row_number() over (partition by a.macro_cluster_id order by a.n_works desc, a.concept_id)
into #macro_cluster_level1_concept2
from #macro_cluster_level1_concept as a
join
(
	select macro_cluster_id, total_n_works = sum(n_works)
	from #macro_cluster_level1_concept
	group by macro_cluster_id
) as b on a.macro_cluster_id = b.macro_cluster_id

-- Mapping of macro clusters to Leiden Ranking main fields.

drop table if exists #macro_cluster_main_field
select a.macro_cluster_id, b.main_field_id, [weight] = sum(a.[weight]), [rank] = row_number() over (partition by a.macro_cluster_id order by sum(a.[weight]) desc, b.main_field_id)
into #macro_cluster_main_field
from #macro_cluster_level1_concept2 as a
join level1_concept_main_field as b on a.concept_id = b.concept_id
group by a.macro_cluster_id, b.main_field_id

drop table if exists macro_cluster_main_field
create table macro_cluster_main_field
(
	macro_cluster_id smallint not null,
	main_field_seq tinyint not null,
	main_field_id tinyint not null,
	[weight] float not null,
	is_primary_main_field bit not null
)

insert into macro_cluster_main_field with(tablock)
select a.macro_cluster_id, main_field_seq = a.[rank], a.main_field_id, [weight] = cast(1 as float) / c.n_main_fields, primary_main_field = (case when [rank] = 1 then 1 else 0 end)
from #macro_cluster_main_field as a
join macro_cluster as b on a.macro_cluster_id = b.macro_cluster_id
join
(
	select macro_cluster_id, n_main_fields = count(*)
	from #macro_cluster_main_field
	where [weight] >= 0.25
	group by macro_cluster_id
) as c on a.macro_cluster_id = c.macro_cluster_id
where a.[weight] >= 0.25

alter table macro_cluster_main_field add constraint pk_macro_cluster_main_field primary key(macro_cluster_id, main_field_id)



-- Mapping of meso clusters.

-- Mapping of meso clusters to level 0 concepts.

drop table if exists #meso_cluster_level0_concept
select a.meso_cluster_id, concept_id, n_works = sum(b.[weight])
into #meso_cluster_level0_concept
from clustering as a
join #work_level0_concept2 as b on a.work_id = b.work_id
group by a.meso_cluster_id, b.concept_id

drop table if exists #meso_cluster_level0_concept2
select a.meso_cluster_id, a.concept_id, a.n_works, [weight] = a.n_works / b.total_n_works, [rank] = row_number() over (partition by a.meso_cluster_id order by a.n_works desc, a.concept_id)
into #meso_cluster_level0_concept2
from #meso_cluster_level0_concept as a
join
(
	select meso_cluster_id, total_n_works = sum(n_works)
	from #meso_cluster_level0_concept
	group by meso_cluster_id
) as b on a.meso_cluster_id = b.meso_cluster_id

drop table if exists meso_cluster_level0_concept
create table meso_cluster_level0_concept
(
	meso_cluster_id smallint not null,
	concept_seq tinyint not null,
	concept_id bigint not null,
	[weight] float not null,
	is_primary_level0_concept bit not null
)

insert into meso_cluster_level0_concept with(tablock)
select a.meso_cluster_id, concept_seq = a.[rank], a.concept_id, [weight] = cast(1 as float) / c.n_concepts, primary_concept = (case when a.[rank] = 1 then 1 else 0 end)
from #meso_cluster_level0_concept2 as a
join meso_cluster as b on a.meso_cluster_id = b.meso_cluster_id
join
(
	select meso_cluster_id, n_concepts = count(*)
	from #meso_cluster_level0_concept2
	where [weight] >= 0.15
	group by meso_cluster_id
) as c on a.meso_cluster_id = c.meso_cluster_id
where a.[weight] >= 0.15

alter table meso_cluster_level0_concept add constraint pk_meso_cluster_level0_concept primary key(meso_cluster_id, concept_id)

-- Mapping of meso clusters to level 1 concepts.

drop table if exists #meso_cluster_level1_concept
select a.meso_cluster_id, concept_id, n_works = sum(b.[weight])
into #meso_cluster_level1_concept
from clustering as a
join #work_level1_concept2 as b on a.work_id = b.work_id
group by a.meso_cluster_id, b.concept_id

drop table if exists #meso_cluster_level1_concept2
select a.meso_cluster_id, a.concept_id, a.n_works, [weight] = a.n_works / b.total_n_works, [rank] = row_number() over (partition by a.meso_cluster_id order by a.n_works desc, a.concept_id)
into #meso_cluster_level1_concept2
from #meso_cluster_level1_concept as a
join
(
	select meso_cluster_id, total_n_works = sum(n_works)
	from #meso_cluster_level1_concept
	group by meso_cluster_id
) as b on a.meso_cluster_id = b.meso_cluster_id

drop table if exists meso_cluster_level1_concept
create table meso_cluster_level1_concept
(
	meso_cluster_id smallint not null,
	concept_seq tinyint not null,
	concept_id bigint not null,
	[weight] float not null,
	is_primary_level1_concept bit not null
)

insert into meso_cluster_level1_concept with(tablock)
select a.meso_cluster_id, concept_seq = a.[rank], a.concept_id, [weight] = cast(1 as float) / c.n_concepts, primary_concept = (case when a.[rank] = 1 then 1 else 0 end)
from #meso_cluster_level1_concept2 as a
join meso_cluster as b on a.meso_cluster_id = b.meso_cluster_id
join
(
	select meso_cluster_id, n_concepts = count(*)
	from #meso_cluster_level1_concept2
	where [weight] >= 0.1
	group by meso_cluster_id
) as c on a.meso_cluster_id = c.meso_cluster_id
where a.[weight] >= 0.1

alter table meso_cluster_level1_concept add constraint pk_meso_cluster_level1_concept primary key(meso_cluster_id, concept_id)

-- Mapping of meso clusters to Leiden Ranking main fields.

drop table if exists #meso_cluster_main_field
select a.meso_cluster_id, b.main_field_id, [weight] = sum(a.[weight]), [rank] = row_number() over (partition by a.meso_cluster_id order by sum(a.[weight]) desc, b.main_field_id)
into #meso_cluster_main_field
from #meso_cluster_level1_concept2 as a
join level1_concept_main_field as b on a.concept_id = b.concept_id
group by a.meso_cluster_id, b.main_field_id

drop table if exists meso_cluster_main_field
create table meso_cluster_main_field
(
	meso_cluster_id smallint not null,
	main_field_seq tinyint not null,
	main_field_id tinyint not null,
	[weight] float not null,
	is_primary_main_field bit not null
)

insert into meso_cluster_main_field with(tablock)
select a.meso_cluster_id, main_field_seq = a.[rank], a.main_field_id, [weight] = cast(1 as float) / c.n_main_fields, primary_main_field = (case when a.[rank] = 1 then 1 else 0 end)
from #meso_cluster_main_field as a
join meso_cluster as b on a.meso_cluster_id = b.meso_cluster_id
join
(
	select meso_cluster_id, n_main_fields = count(*)
	from #meso_cluster_main_field
	where [weight] >= 0.25
	group by meso_cluster_id
) as c on a.meso_cluster_id = c.meso_cluster_id
where a.[weight] >= 0.25

alter table meso_cluster_main_field add constraint pk_meso_cluster_main_field primary key(meso_cluster_id, main_field_id)



-- Mapping of micro clusters.

-- Mapping of micro clusters to level 0 concepts.

drop table if exists #micro_cluster_level0_concept
select a.micro_cluster_id, concept_id, n_works = sum(b.[weight])
into #micro_cluster_level0_concept
from clustering as a
join #work_level0_concept2 as b on a.work_id = b.work_id
group by a.micro_cluster_id, b.concept_id

drop table if exists #micro_cluster_level0_concept2
select a.micro_cluster_id, a.concept_id, a.n_works, [weight] = a.n_works / b.total_n_works, [rank] = row_number() over (partition by a.micro_cluster_id order by a.n_works desc, a.concept_id)
into #micro_cluster_level0_concept2
from #micro_cluster_level0_concept as a
join
(
	select micro_cluster_id, total_n_works = sum(n_works)
	from #micro_cluster_level0_concept
	group by micro_cluster_id
) as b on a.micro_cluster_id = b.micro_cluster_id

drop table if exists micro_cluster_level0_concept
create table micro_cluster_level0_concept
(
	micro_cluster_id smallint not null,
	concept_seq tinyint not null,
	concept_id bigint not null,
	[weight] float not null,
	is_primary_level0_concept bit not null
)

insert into micro_cluster_level0_concept with(tablock)
select a.micro_cluster_id, concept_seq = a.[rank], a.concept_id, [weight] = cast(1 as float) / c.n_concepts, primary_concept = (case when a.[rank] = 1 then 1 else 0 end)
from #micro_cluster_level0_concept2 as a
join micro_cluster as b on a.micro_cluster_id = b.micro_cluster_id
join
(
	select micro_cluster_id, n_concepts = count(*)
	from #micro_cluster_level0_concept2
	where [weight] >= 0.125
	group by micro_cluster_id
) as c on a.micro_cluster_id = c.micro_cluster_id
where a.[weight] >= 0.125

alter table micro_cluster_level0_concept add constraint pk_micro_cluster_level0_concept primary key(micro_cluster_id, concept_id)

-- Mapping of micro clusters to level 1 concepts.

drop table if exists #micro_cluster_level1_concept
select a.micro_cluster_id, concept_id, n_works = sum(b.[weight])
into #micro_cluster_level1_concept
from clustering as a
join #work_level1_concept2 as b on a.work_id = b.work_id
group by a.micro_cluster_id, b.concept_id

drop table if exists #micro_cluster_level1_concept2
select a.micro_cluster_id, a.concept_id, a.n_works, [weight] = a.n_works / b.total_n_works, [rank] = row_number() over (partition by a.micro_cluster_id order by a.n_works desc, a.concept_id)
into #micro_cluster_level1_concept2
from #micro_cluster_level1_concept as a
join
(
	select micro_cluster_id, total_n_works = sum(n_works)
	from #micro_cluster_level1_concept
	group by micro_cluster_id
) as b on a.micro_cluster_id = b.micro_cluster_id

drop table if exists micro_cluster_level1_concept
create table micro_cluster_level1_concept
(
	micro_cluster_id smallint not null,
	concept_seq tinyint not null,
	concept_id bigint not null,
	[weight] float not null,
	is_primary_level1_concept bit not null
)

insert into micro_cluster_level1_concept with(tablock)
select a.micro_cluster_id, concept_seq = a.[rank], a.concept_id, [weight] = cast(1 as float) / c.n_concepts, primary_concept = (case when a.[rank] = 1 then 1 else 0 end)
from #micro_cluster_level1_concept2 as a
join micro_cluster as b on a.micro_cluster_id = b.micro_cluster_id
join
(
	select micro_cluster_id, n_concepts = count(*)
	from #micro_cluster_level1_concept2
	where [weight] >= 0.1
	group by micro_cluster_id
) as c on a.micro_cluster_id = c.micro_cluster_id
where a.[weight] >= 0.1

alter table micro_cluster_level1_concept add constraint pk_micro_cluster_level1_concept primary key(micro_cluster_id, concept_id)

-- Mapping of micro clusters to Leiden Ranking main fields.

drop table if exists #micro_cluster_main_field
select a.micro_cluster_id, b.main_field_id, [weight] = sum(a.[weight]), [rank] = row_number() over (partition by a.micro_cluster_id order by sum(a.[weight]) desc, b.main_field_id)
into #micro_cluster_main_field
from #micro_cluster_level1_concept2 as a
join level1_concept_main_field as b on a.concept_id = b.concept_id
group by a.micro_cluster_id, b.main_field_id

drop table if exists micro_cluster_main_field
create table micro_cluster_main_field
(
	micro_cluster_id smallint not null,
	main_field_seq tinyint not null,
	main_field_id tinyint not null,
	[weight] float not null,
	is_primary_main_field bit not null
)

insert into micro_cluster_main_field with(tablock)
select a.micro_cluster_id, main_field_seq = a.[rank], a.main_field_id, [weight] = cast(1 as float) / c.n_main_fields, primary_main_field = (case when a.[rank] = 1 then 1 else 0 end)
from #micro_cluster_main_field as a
join micro_cluster as b on a.micro_cluster_id = b.micro_cluster_id
join
(
	select micro_cluster_id, n_main_fields = count(*)
	from #micro_cluster_main_field
	where [weight] >= 0.2
	group by micro_cluster_id
) as c on a.micro_cluster_id = c.micro_cluster_id
where a.[weight] >= 0.2

alter table micro_cluster_main_field add constraint pk_micro_cluster_main_field primary key(micro_cluster_id, main_field_id)
