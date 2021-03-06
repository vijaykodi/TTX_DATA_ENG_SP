/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetBeforeAfterData]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetBeforeAfterData (
   @eventDatabase nvarchar(256), 
   @databaseName nvarchar(256), 
   @loginName nvarchar(256), 
   @objectName nvarchar(256), 
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
   set @objectName = UPPER(dbo.fn_cmreport_ProcessString(@objectName));

	set @columns = 'select top '+ STR(@rowCount) +' e.applicationName, e.databaseName, ' +
	               'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
                       'THEN loginName ' + 
                       'ELSE sessionLoginName ' + 
                  'END AS loginName, ' +
                  'CASE WHEN eventType=8 THEN ''Insert'' ' +
                  'WHEN eventType=2 THEN ''Update'' ' +
                  'WHEN eventType=16 THEN ''Delete'' ' +
                  'ELSE ''Unknown'' END AS eventTypeString, ' +
	               'e.startTime, e.targetObject, d.primaryKey,c.columnName,c.beforeValue,c.afterValue '
	               
   set @fromClause = 'FROM [' + @eventDatabase + '].dbo.Events as e ' + 
    'JOIN [' + @eventDatabase + '].dbo.DataChanges as d ON (d.startTime >= e.startTime AND d.startTime <= e.endTime ' +
    'AND d.eventSequence >= e.startSequence AND d.eventSequence <= e.endSequence) ' +
    'LEFT OUTER JOIN [' + @eventDatabase + '].dbo.ColumnChanges as c ON (c.startTime = d.startTime AND d.eventSequence = c.eventSequence)'
	
	set @whereClause = 'where UPPER(databaseName) like ''' + @databaseName+ ''' ' +
	                   'AND (UPPER(sessionLoginName) LIKE ''' + @loginName + ''' OR UPPER(loginName) LIKE ''' + @loginName + ''') ' +
                      'AND UPPER(targetObject) like ''' + @objectName + ''' ' +
	                   'and eventType IN (8,2,16) ' +
	                   'AND recordNumber<>0 ' +
	                   ' and e.startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and e.startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') '

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY e.startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause

	EXEC(@stmt)


GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetBeforeAfterData] TO [public] AS [dbo]
GO
