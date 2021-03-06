/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetServerLoginActivityHelper]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetServerLoginActivityHelper (
	@eventDatabase nvarchar(256), 
	@loginStatus int, 
	@startDate datetime, 
   @endDate datetime, 
	@sortColumn nvarchar(256),
	@rowCount int)
as
declare @string nvarchar(4000), @columns nvarchar(1000), @fromClause nvarchar(500), @whereClause nvarchar(2000), @orderByClause nvarchar(200);
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

   -- prevents sql injection but set limitations on the database naming
   set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);


	set @columns = 'select top ' + STR(@rowCount) + ' applicationName, eventType, ' +
	               'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
                       'THEN loginName ' + 
                       'ELSE sessionLoginName ' + 
                  'END AS loginName, ' +
                  'startTime ';
                  
   set @fromClause = 'FROM [' + @eventDatabase + '].dbo.Events  ';
	
	set @whereClause = 'where startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') ';
	
	if (@loginStatus = 1)
		set @whereClause = @whereClause + ' and eventType=50 ';
	else if (@loginStatus = 2)
		set @whereClause = @whereClause + ' and eventType=51 ';
	else
	   set @whereClause = @whereClause + ' and (eventType=50 or eventType=51) ';

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	set @string = @columns + @fromClause + @whereClause + @orderByClause ;

   print @string;
   EXEC(@string);


GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetServerLoginActivityHelper] TO [public] AS [dbo]
GO
