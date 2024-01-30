if (not exists (select * from sys.schemas where name = 'classification'))
begin
	exec ('create schema [classification] authorization [dbo]')
end

if (not exists (select * from sys.schemas where name = 'vosviewer'))
begin
	exec ('create schema [vosviewer] authorization [dbo]')
end

if (not exists (select * from sys.schemas where name = 'excel'))
begin
	exec ('create schema [excel] authorization [dbo]')
end
