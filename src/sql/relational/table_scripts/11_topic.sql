set nocount on

-- topic
drop table if exists topic
create table topic
(
	topic_id smallint not null,
	topic nvarchar(120) not null,
	[description] nvarchar(1000) null,
	openalex_id smallint not null,
	wikipedia_url varchar(180) null,
	domain_id tinyint not null,
	field_id tinyint not null,
	subfield_id smallint not null,
	updated_date date not null,
	created_date datetime2 not null
)
go

insert into topic with(tablock)
select a.topic_id,
	b.display_name,
	b.[description],
	openalex_id = a.topic_id,
	wikipedia_url = b.id_wikipedia,
	domain_id = replace(b.domain_id, 'https://openalex.org/domains/', ''),
	field_id = replace(b.field_id, 'https://openalex.org/fields/', ''),
	subfield_id = replace(b.subfield_id, 'https://openalex.org/subfields/', ''),
	b.updated_date,
	b.created_date
from _topic as a
join $(topics_json_db_name)..topic as b on a.folder = b.folder and a.record_id = b.record_id

alter table topic add constraint pk_topic primary key(topic_id)
alter table topic add constraint fk_topic_domain_id_domain_domain_id foreign key(domain_id) references domain(domain_id)
alter table topic add constraint fk_topic_field_id_field_field_id foreign key(field_id) references field(field_id)
alter table topic add constraint fk_topic_subfield_id_subfield_subfield_id foreign key(subfield_id) references subfield(subfield_id)
create index idx_topic_openalex_id on topic(openalex_id)
create index idx_topic_domain_id on topic(domain_id)
create index idx_topic_field_id on topic(field_id)
create index idx_topic_subfield_id on topic(subfield_id)



-- topic_keyword
drop table if exists topic_keyword
create table topic_keyword
(
	topic_id smallint not null,
	keyword_seq smallint not null,
	keyword nvarchar(100) not null
)
go

insert into topic_keyword with(tablock)
select a.topic_id,
	b.keyword_seq,
	b.keyword
from _topic as a
join $(topics_json_db_name)..topic_keyword as b on a.folder = b.folder and a.record_id = b.record_id

alter table topic_keyword add constraint pk_topic_keyword primary key(topic_id, keyword_seq)
alter table topic_keyword add constraint fk_topic_keyword_topic_id_topic_topic_id foreign key(topic_id) references topic(topic_id)



-- topic_sibling
drop table if exists topic_sibling
create table topic_sibling
(
	topic_id smallint not null,
	sibling_topic_seq smallint not null,
	sibling_topic_id smallint not null
)
go

insert into topic_sibling with(tablock)
select a.topic_id,
	b.sibling_seq,
	sibling_topic_id = replace(b.id, 'https://openalex.org/T', '')
from _topic as a
join $(topics_json_db_name)..topic_sibling as b on a.folder = b.folder and a.record_id = b.record_id

alter table topic_sibling add constraint pk_topic_sibling primary key(topic_id, sibling_topic_seq)
create index idx_topic_sibling_sibling_topic_id on topic_sibling(sibling_topic_id)
alter table topic_sibling add constraint fk_topic_sibling_topic_id_topic_topic_id foreign key(topic_id) references topic(topic_id)
alter table topic_sibling add constraint fk_topic_sibling_sibling_topic_id_topic_topic_id foreign key(sibling_topic_id) references topic(topic_id)



-- subfield_topic
drop table if exists subfield_topic
create table subfield_topic
(
	subfield_id smallint not null,
	topic_seq smallint not null,
	topic_id smallint not null
)
go

insert into subfield_topic with(tablock)
select a.subfield_id,
	b.topic_seq,
	topic_id = replace(b.id, 'https://openalex.org/T', '')
from _subfield as a
join $(subfields_json_db_name)..subfield_topic as b on a.folder = b.folder and a.record_id = b.record_id

alter table subfield_topic add constraint pk_subfield_topic primary key(subfield_id, topic_seq)
create index idx_subfield_topic_topic_id on subfield_topic(topic_id)
alter table subfield_topic add constraint fk_subfield_topic_subfield_id_subfield_subfield_id foreign key(subfield_id) references subfield(subfield_id)
alter table subfield_topic add constraint fk_subfield_topic_topic_id_topic_topic_id foreign key(topic_id) references topic(topic_id)
