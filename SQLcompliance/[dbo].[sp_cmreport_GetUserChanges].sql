/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetUserChanges]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetUserChanges (
   @eventDatabase nvarchar(256), 
   @databaseName nvarchar(256), 
   @loginName nvarchar(1000), 
   @startDate nvarchar(50), 
   @endDate nvarchar(50), 
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

	set @columns = 'select top '+ STR(@rowCount) +' applicationName, databaseName, t2.name ''eventType'', details, hostName, ' +
	               'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
                       'THEN loginName ' + 
                       'ELSE sessionLoginName ' + 
                  'END AS loginName, ' +
	               'startTime, targetObject '
	               
   set @fromClause = 'FROM [' + @eventDatabase + '].dbo.Events t1 LEFT OUTER JOIN EventTypes t2 ON t1.eventType = t2.evtypeid '
	
	set @whereClause = 'where UPPER(databaseName) like ''' + @databaseName+ ''' ' +
	                   'AND (UPPER(sessionLoginName) LIKE ''' + @loginName + ''' OR UPPER(loginName) LIKE ''' + @loginName + ''') ' +
	                   'and eventCategory=3 ' +
	                   ' and t1.startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and t1.startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') '

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY t1.startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause

	EXEC(@stmt)


GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetUserChanges] TO [public] AS [dbo]
GO
