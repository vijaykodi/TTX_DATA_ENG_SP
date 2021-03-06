/****** Object:  StoredProcedure [dbo].[extend_businessdays_table]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[extend_businessdays_table]  @newyear int, @modelyear int, @msg varchar(300) OUTPUT
as
begin

	declare @numofdays int,  
		@s_newyear varchar(4), @s_modelyear varchar(4),
		@expectednewdays int, @expectedmodeldays int

	if isnull(@newyear, 0) = 0 
		select @newyear = max(year(paiddate)) + 1
		from dbo.BusinessDays

	if isnull(@modelyear, 0) = 0 
		select @modelyear = max(year(paiddate))
		from dbo.BusinessDays
		where isdate('2/29/' + cast(year(paiddate) as varchar(4))) = 
			isdate('2/29/' + cast(@newyear as varchar(4)))

	if isnull(@newyear, 0) = 0 or isnull(@modelyear, 0) = 0
	begin
		set @msg = 'Neither newyear or modelyear may be zero'
		print @msg
		return 1
	end

	select @s_newyear = cast(@newyear as varchar(4)),
		@s_modelyear = cast(@modelyear as varchar(4)),
		@expectednewdays = case when isdate('2/29/' + @s_newyear) = 1 then 366 else 365 end,
		@expectedmodeldays = case when isdate('2/29/' + @s_modelyear) = 1 then 366 else 365 end

	if @expectednewdays <> @expectedmodeldays 
	begin
		set @msg = case when @expectednewdays = 366 
			then 'New year is a leap year but the model year is not!'
			else 'Model year is a leap year but the new year is not!'
			end 
		print @msg
		return 1
	end
	
	select @numofdays = count(*)
	from dbo.BusinessDays
	where year(paiddate) = @newyear

	if @numofdays > 0 
	begin
		set @msg = cast(@numofdays as varchar(4)) + ' new year records already exist in BusinessDays! ' + CHAR(13) +
			'Please confirm!' 
		print @msg
		return 1
	end

	select @numofdays = count(*)
	from dbo.BusinessDays
	where year(paiddate) = @modelyear

	if @numofdays <> @expectedmodeldays
	begin
		set @msg = 'Found ' + cast(@numofdays as varchar(4)) + ' model year records in BusinessDays! ' + CHAR(13) +
			'Expected ' + cast(@expectedmodeldays as varchar(4)) + '.'
		print @msg
		return 1
	end
	 
	insert into dbo.BusinessDays
		select  paiddate = cast( cast(month(paiddate) as varchar(2)) + '/' 
				+ cast(day(paiddate) as varchar(2)) + '/'
				+ @s_newyear as datetime)
			, [weekday] = case datepart(weekday, cast( cast(month(paiddate) as varchar(2)) + '/' 
				+ cast(day(paiddate) as varchar(2)) + '/'
				+ @s_newyear as datetime))
				when 7 then 0
				when 1 then 0
				else 1 end
			, holiday = case when month(paiddate) = 1 and day(paiddate) = 1 then -1
					when month(paiddate) = 12 and day(paiddate) = 25 then -1
					else 0
					end
			, descript = case when month(paiddate) = 1 and day(paiddate) = 1 then 'New Years'
					when month(paiddate) = 12 and day(paiddate) = 25 then 'Christmas'
					else null
					end
			, businessday = case when month(paiddate) = 1 and day(paiddate) = 1 then 0
					when month(paiddate) = 12 and day(paiddate) = 25 then 0
					else
						 case datepart(weekday, cast( cast(month(paiddate) as varchar(2)) + '/' 
						+ cast(day(paiddate) as varchar(2)) + '/'
						+ @s_newyear as datetime))
						when 7 then 0
						when 1 then 0
						else 1 end
					end 
		from dbo.businessdays
		where year(paiddate) = @modelyear 

	select @numofdays = count(*)
	from dbo.BusinessDays
	where year(paiddate) = @newyear

	if @numofdays <> @expectednewdays
	begin
		set @msg = 'Found ' + cast(@numofdays as varchar(4)) + ' new year records in BusinessDays after insertion!  ' + CHAR(13) +
			'Expected ' + cast(@expectednewdays as varchar(4)) + '.'
		print @msg
		return 1
	end

	set @msg = 'Inserted ' + cast(@expectednewdays as varchar(4)) + ' records in BusinessDays!  ' + CHAR(13) +
		'Please update the holidays!'
	print @msg
	return 0

end

GO
