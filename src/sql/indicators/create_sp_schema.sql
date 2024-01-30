if (not exists (select * from sys.schemas where name = 'sp')) 
begin
	exec ('create schema [sp] authorization [dbo]')
end
