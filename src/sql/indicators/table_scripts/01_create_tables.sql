set nocount on

-- collaboration_type
drop table if exists collaboration_type
create table collaboration_type
(
	collaboration_type_no tinyint not null,
	collaboration_type varchar(50) not null
)

insert collaboration_type values
(1, 'No collaboration'),
(2, 'National collaboration'),
(3, 'International collaboration')

alter table collaboration_type add constraint pk_collaboration_type primary key(collaboration_type_no)


-- database
drop table if exists [database]
create table [database]
(
	database_no tinyint not null,
	[database] varchar(50) not null
)

insert [database] values
(1, 'All publications (with required meta-data)'),
(2, 'Core publications')

alter table [database] add constraint pk_database primary key(database_no)


-- classification_system
drop table if exists classification_system
create table classification_system
(
	classification_system_no tinyint not null,
	classification_system varchar(100) not null
)

insert classification_system values
(1, 'Publication-level classification system (about 900 fields)'),
(2, 'Publication-level classification system (about 4500 fields)')

alter table classification_system add constraint pk_classification_system primary key(classification_system_no)


-- doc_type
drop table if exists doc_type
create table doc_type
(
	doc_type_no tinyint not null,
	doc_type varchar(40) not null
)

insert doc_type values
(1, 'Non-citable item'),
(2, 'Article'),
--(3, 'Letter'),
(4, 'Proceeding / chapter')

alter table doc_type add constraint pk_doc_type primary key(doc_type_no)
