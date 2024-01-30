drop function if exists constants
go

create function constants(@constant varchar(50)) returns int
begin
	declare @value int
	if @constant = 'max_pub_year'
		set @value = $(indicators_max_pub_year)  -- The most recent year fully covered in the database.
	else
		set @value = 1 / 0
	return @value
end
