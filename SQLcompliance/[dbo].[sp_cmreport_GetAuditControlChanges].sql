/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetAuditControlChanges]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetAuditControlChanges 
(
   @startDate datetime, 
   @endDate datetime, 
   @sortColumn nvarchar(256), 
   @rowCount int)
as
declare @stmt nvarchar(4000), @columns nvarchar(2000), @fromClause nvarchar(500), @whereClause nvarchar(1000), @orderByClause nvarchar(200)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

   -- Idera SQL compliance Manager Version 3.0
   --
   -- (c) Copyright 2004-2007 Idera, a division of BBS Technologies, Inc., all rights reserved.
   -- SQL compliance manager, Idera and the Idera Logo are trademarks or registered trademarks
   -- of BBS Technologies or its subsidiaries in the United States and other jurisdictions.

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	set @columns = 'select top '+ STR(@rowCount) +' eventTime, t2.Name, logUser, logSqlServer, logInfo  '
	set @fromClause = 'from ChangeLog t1 LEFT OUTER JOIN ChangeLogEventTypes t2 ON t1.logType = t2.eventId '
	set @whereClause = 'where eventTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and eventTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') ';

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY eventTime DESC';
	else
	   set @orderByClause = ' ORDER BY logUser' ;
	
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause

	EXEC(@stmt)


GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetAuditControlChanges] TO [public] AS [dbo]
GO
