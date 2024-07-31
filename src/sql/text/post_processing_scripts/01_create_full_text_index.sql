set nocount on

if exists ( select 1 from sys.fulltext_catalogs where [name] = 'text_catalog')
begin
	drop fulltext catalog text_catalog
end
go

create fulltext catalog text_catalog
go

create fulltext index on text_data(title, abstract, keywords)
key index pk_text_data on text_catalog
with stoplist off, change_tracking off, no population
go

alter fulltext index on text_data
start full population
go
