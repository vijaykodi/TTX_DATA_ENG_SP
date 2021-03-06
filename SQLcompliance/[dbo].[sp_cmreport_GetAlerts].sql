/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetAlerts]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE sp_cmreport_GetAlerts( @eventDatabase nvarchar(256),
                                        @startDate datetime,
                                        @endDate datetime,
                                        @eventCategory int,
                                        @alertLevel int,
                                        @databaseName nvarchar(256),
                                        @objectName nvarchar(256),
                                        @privilegedUserOnly bit,
                                        @showSqlText bit,
                                        @sortColumn nvarchar(256),
                                        @rowCount int)
as
declare @stmt nvarchar(4000)
declare @columns nvarchar(2000), @fromClause nvarchar(500), @whereClause nvarchar(1000), @orderByClause nvarchar(200)

declare @eventTable       nvarchar(256)
declare @eventSqlTable    nvarchar(256)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);
declare @instanceName nvarchar(256);

--get the instance name
set @instanceName = coalesce((select instance from SQLcompliance..SystemDatabases where databaseName = @eventDatabase), '')

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

   -- prevents sql injection but set limitations on the database naming
   set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);
   set @databaseName = UPPER(dbo.fn_cmreport_ProcessString(@databaseName));
   set @objectName = UPPER(dbo.fn_cmreport_ProcessString(@objectName));
	 
   -- table used in queries
	set @eventTable       = '[' + @eventDatabase + '].dbo.Events'
	set @eventSqlTable    = '[' + @eventDatabase + '].dbo.EventSQL'

	-- DEFINE COLUMNS FOR SELECT
	set @columns = 'SELECT TOP '+ STR(@rowCount) + ' ' +
   	'a.created ''alertTime'', ' +
   	'CASE a.alertLevel ' +
      	'WHEN 4 THEN ''Severe'' ' +
      	'WHEN 3 THEN ''High'' ' +
      	'WHEN 2 THEN ''Medium'' ' +
      	'WHEN 1 THEN ''Low'' ' +
      	'ELSE ''Unknown'' ' +
      	'END as alertLevel, ' +
   	'et.name ''eventType'', ' +
   	'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
      	'THEN loginName ' + 
      	'ELSE sessionLoginName ' + 
      	'END AS loginName, ' +
   	'e.applicationName, ' +
   	'e.hostName, ' +
   	'e.databaseName, ' +
   	'e.targetObject, ' +
   	'e.details, ';
   	
   if(@showSqlText = 1)
      set @columns = @columns + 'es.sqlText ';
   else
      set @columns = @columns + ' '''' ''sqlText'' ';
   	
	-- Build FROM clause
	set @fromClause = 'FROM SQLcompliance..Alerts a LEFT OUTER JOIN ' + @eventTable + ' e ON a.alertEventId = e.eventId ';
	
	if (@showSqlText = 1)
	   set @fromClause = @fromClause + 'LEFT OUTER JOIN ' + @eventSqlTable + ' es ON e.eventId = es.eventId ' ;
	
	set @fromClause = @fromClause + 'LEFT OUTER JOIN SQLcompliance..EventTypes et ON a.eventType = et.evtypeid ' ;
	
	-- Build WHERE clause		
	set @whereClause = 'WHERE a.created >= CONVERT(DATETIME, ''' + @startDateStr + ''') ' +
   	'AND a.created <= CONVERT(DATETIME, ''' + @endDateStr + ''') ' +
   	'AND a.alertType = 1' +
   	'AND a.instance = ''' + @instanceName + ''' ' +
   	'AND UPPER(databaseName) LIKE ''' + @databaseName + ''' ' +
   	'AND UPPER(e.targetObject) LIKE ''' + @objectName + ''' ';
	if( @eventCategory >= 0 )
	   set @whereClause = @whereClause + 'AND a.eventType=' + STR(@eventCategory)
	
	if ( @alertLevel <> 0 )
	   set @whereClause = @whereClause + ' AND a.alertLevel = ' + STR(@alertLevel)
	
	if (@privilegedUserOnly = 1)
	   set @whereClause = @whereClause + ' and privilegedUser = 1 '
	
	--set @whereClause = @whereClause + 'AND e.eventType = et.evtypeid '
	
	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY alertTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	-- Build Complete SELECT statement
	set @stmt = @columns + ' ' + @fromClause + ' ' + @whereClause + ' ' + @orderByClause
	
	-- Execute SELECT
	EXEC(@stmt)

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetAlerts] TO [public] AS [dbo]
GO
