/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetLoginDeletionHistory]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetLoginDeletionHistory (
   @eventDatabase nvarchar(256), 
   @loginName nvarchar(256), 
   @startDate datetime, 
   @endDate datetime, 
   @sortColumn nvarchar(256), 
   @rowCount int)
as
declare @stmt nvarchar(4000), @columns nvarchar(2000), @fromClause nvarchar(500), @whereClause nvarchar(1000), @orderByClause nvarchar(200), @eventTypeString nvarchar(200)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

   -- Idera SQL compliance Manager Version 3.0
   --
   -- (c) Copyright 2004-2007 Idera, a division of BBS Technologies, Inc., all rights reserved.
   -- SQL compliance manager, Idera and the Idera Logo are trademarks or registered trademarks
   -- of BBS Technologies or its subsidiaries in the United States and other jurisdictions.

	-- set category type
	set @eventTypeString = '711,718,346,347,343,344,339,369'	


	 -- prevents sql injection but set limitations on the database naming
    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	 -- prevents sql injection but set limitations on the database naming
   set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);
   set @loginName = UPPER(dbo.fn_cmreport_ProcessString(@loginName));

	set @columns = 'select top '+ STR(@rowCount) +' applicationName, hostName, loginName, startTime, targetObject as targetLoginName '
	set @fromClause = 'from [' + @eventDatabase + '].dbo.Events t1 LEFT OUTER JOIN EventTypes t2 ON t1.eventType = t2.evtypeid '
	set @whereClause = 'where success = 1 and eventCategory=3 and evtypeid in (' + @eventTypeString + ') and upper(t1.targetLoginName) like ''' + @loginName + ''' and t1.startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and t1.startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') ';

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY t1.startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause

	EXEC(@stmt)

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetLoginDeletionHistory] TO [public] AS [dbo]
GO
