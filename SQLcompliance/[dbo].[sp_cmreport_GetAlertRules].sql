/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetAlertRules]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure sp_cmreport_GetAlertRules (
	@ruleName nvarchar(50), 
	@serverInstance nvarchar(50), 
	@alertLevel int, 
	@logMessage int, 
   @emailMessage int,
   @ruleType int
)
as
begin

declare @string nvarchar(500)
declare @stmt nvarchar(2000)
declare @fromClause nvarchar(500)
declare @whereClause nvarchar(500)
declare @orderByClause nvarchar(200)

   -- prevents sql injection but set limitations on the database naming
   set @ruleName = dbo.fn_cmreport_ProcessString(@ruleName);
   set @serverInstance = UPPER(dbo.fn_cmreport_ProcessString(@serverInstance));

   set @string = 'SELECT name, alertLevel, targetInstances, logMessage, emailMessage FROM AlertRules ';

   set @whereClause = ' WHERE name LIKE (''' + @ruleName + ''') AND UPPER(targetInstances) LIKE (''' + @serverInstance + ''')';

   if(@alertLevel > 0)
      set @whereClause = @whereClause + ' AND alertLevel=' + STR(@alertLevel);
   if(@logMessage > -1)
   	set @whereClause = @whereClause + ' AND logMessage=' + STR(@logMessage);
   if(@emailMessage > -1)
   	set @whereClause = @whereClause + ' AND emailMessage = ' + STR(@emailMessage);
   	
   if (@ruleType > 0)
      set @whereClause = @whereClause + ' AND alertType = ' + STR(@ruleType);

   set @orderByClause = ''

   set @stmt = @string + @whereClause + @orderByClause	

   EXEC(@stmt);
end

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetAlertRules] TO [public] AS [dbo]
GO
