/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetStatusAlerts]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE sp_cmreport_GetStatusAlerts(@startDate datetime,
											 @endDate datetime,
											 @alertLevel int,
											 @sortColumn nvarchar(256),
											 @rowCount int)
as
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);
declare @stmt nvarchar(4000)
declare @columns nvarchar(2000)
declare @fromClause nvarchar(500)
declare @whereClause nvarchar(1000)
declare @orderByClause nvarchar(200)

-- Process input
set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	-- DEFINE COLUMNS FOR SELECT
	set @columns = 'SELECT TOP '+ STR(@rowCount) + ' ' +
   	'a.created as ''alertTime'', ' +
   	'CASE a.alertLevel ' +
      	'WHEN 4 THEN ''Severe'' ' +
      	'WHEN 3 THEN ''High'' ' +
      	'WHEN 2 THEN ''Medium'' ' +
      	'WHEN 1 THEN ''Low'' ' +
      	'ELSE ''Unknown'' ' +
      	'END as alertLevel, ' +
      	'a.ruleName as ''RuleName'', ' +
      	'a.instance, ' +
      	'a.computerName, ' + 
      	't.RuleName as ''SourceRule'' ';

	-- Build FROM clause
	set @fromClause = 'FROM SQLcompliance..Alerts a JOIN SQLcompliance..StatusRuleTypes t ON a.alertEventId = t.StatusRuleId ';
	
	-- Build WHERE clause		
	set @whereClause = 'WHERE a.created >= CONVERT(DATETIME, ''' + @startDateStr + ''') ' +
   	'AND a.created <= CONVERT(DATETIME, ''' + @endDateStr + ''') ' +
   	'AND a.alertType = 2';
	
	if ( @alertLevel <> 0 )
	   set @whereClause = @whereClause + ' AND a.alertLevel = ' + STR(@alertLevel)
	
    set @orderByClause = ' ORDER BY alertTime DESC';
	
	-- Build Complete SELECT statement
	set @stmt = @columns + ' ' + @fromClause + ' ' + @whereClause + ' ' + @orderByClause
	
	-- Execute SELECT
	EXEC(@stmt)

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetStatusAlerts] TO [public] AS [dbo]
GO
