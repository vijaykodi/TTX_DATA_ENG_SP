/****** Object:  StoredProcedure [dbo].[p_cmreport_GetSensitiveColumns]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure p_cmreport_GetSensitiveColumns (
   @eventDatabase nvarchar(256), 
   @databaseName nvarchar(256), 
   @loginName nvarchar(256), 
   @tableName nvarchar(256), 
   @startDate nvarchar(50), 
   @endDate nvarchar(50), 
   @showSqlText bit, 
   @sortColumn nvarchar(1000), 
   @rowCount nvarchar(16)
   )
as
declare @stmt nvarchar(4000), @columns nvarchar(2000), @fromClause nvarchar(500), @whereClause nvarchar(1000), @orderByClause nvarchar(200)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	 -- prevents sql injection but set limitations on the database naming
   set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);
   set @databaseName = UPPER(dbo.fn_cmreport_ProcessString(@databaseName));
   set @loginName = UPPER(dbo.fn_cmreport_ProcessString(@loginName));
   set @tableName = UPPER(dbo.fn_cmreport_ProcessString(@tableName));

	set @columns = 'select top '+ STR(@rowCount) +' e.applicationName, e.databaseName, ' +
	               'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
                       'THEN loginName ' + 
                       'ELSE sessionLoginName ' + 
                  'END AS loginName, ' +
                  'CASE WHEN eventType=1 THEN ''Select'' ' +
                  'ELSE ''Unknown'' END AS eventTypeString, ' +
	               'e.startTime, e.targetObject as ''tableName'', sc.columnName, e.eventId '
	               
	               
   set @fromClause = 'FROM [' + @eventDatabase + '].dbo.Events as e ' + 
    'JOIN [' + @eventDatabase + '].dbo.SensitiveColumns as sc ON e.eventId = sc.eventId '
    
	if (@showSqlText = 1)
	begin
		set @columns = @columns + ', es.sqlText '
		set @fromClause = @fromClause +    'LEFT OUTER JOIN [' + @eventDatabase + '].dbo.EventSQL es ON e.eventId = es.eventId '
	end
	else
	begin
		set @columns = @columns + ', '''' ''sqlText'' '
	end

	set @whereClause = 'where UPPER(databaseName) like ''' + @databaseName+ ''' ' +
	                   'AND (UPPER(sessionLoginName) LIKE ''' + @loginName + ''' OR UPPER(loginName) LIKE ''' + @loginName + ''') ' +
                      'AND UPPER(targetObject) like ''' + @tableName + ''' ' +
	                   'and eventType = 1 ' +
	                   ' and e.startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and e.startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') '

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY e.startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause

	EXEC(@stmt)


GO
