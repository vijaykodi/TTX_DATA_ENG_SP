/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetAgentHistory]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure sp_cmreport_GetAgentHistory (@instance nvarchar(256), @startDate datetime, @endDate datetime, @sortColumn nvarchar(256), @rowCount int)
as
declare @stmt nvarchar(2000);
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	set @stmt = 'SELECT TOP ' + STR(@rowCount) + ' t1.eventTime, t1.agentServer, t1.instance, t2.Name ''eventType'' ' +
		'from AgentEvents t1 LEFT OUTER JOIN AgentEventTypes t2 on t1.eventType=t2.eventId  ' +
		'where eventTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and eventTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') '

	if(@instance != '<ALL>')
		set @stmt = @stmt + ' and UPPER(t1.instance) = ''' + UPPER(@instance) + ''' '

	-- Descinding for time columns
	if(@sortColumn = 'date')
	   set @stmt = @stmt + ' ORDER BY t1.eventTime DESC';
	else
	   set @stmt = @stmt + ' ORDER BY t1.agentServer' ;
	   
	
	EXEC(@stmt)

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetAgentHistory] TO [public] AS [dbo]
GO
