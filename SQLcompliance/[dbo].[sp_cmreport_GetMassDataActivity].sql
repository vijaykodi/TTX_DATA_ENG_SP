/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetMassDataActivity]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetMassDataActivity (
   @eventDatabase nvarchar(256), 
   @startDate datetime, 
   @endDate datetime, 
   @privilegedUserOnly bit, 
   @showSqlText bit, 
   @sortColumn nvarchar(256), 
   @rowCount int)
as
declare @stmt nvarchar(4000)
declare @columns nvarchar(2000), @fromClause nvarchar(500), @whereClause nvarchar(1000), @orderByClause nvarchar(200), @category nvarchar(50), @eventTypeString nvarchar(200)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);
	
   -- Idera SQL compliance Manager Version 3.0
   --
   -- (c) Copyright 2004-2007 Idera, a division of BBS Technologies, Inc., all rights reserved.
   -- SQL compliance manager, Idera and the Idera Logo are trademarks or registered trademarks
   -- of BBS Technologies or its subsidiaries in the United States and other jurisdictions.

	-- set category type
	set @eventTypeString = '62, 63, 64, 65, 80, 81, 82'

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	 -- prevents sql injection but set limitations on the database naming
   set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);

	set @columns = 'select top '+ STR(@rowCount) +' applicationName, databaseName, t2.name ''eventType'', hostName, ' +
	               'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
                       'THEN loginName ' + 
                       'ELSE sessionLoginName ' + 
                  'END AS loginName, ' +
	               'targetObject, t1.startTime'

   set @fromClause = 'FROM [' + @eventDatabase + '].dbo.Events t1 LEFT OUTER JOIN EventTypes t2 ON t1.eventType = t2.evtypeid '
	if (@showSqlText = 1)
	begin
		set @columns = @columns + ', t3.sqlText '
		set @fromClause = @fromClause + 'LEFT OUTER JOIN [' + @eventDatabase + '].dbo.EventSQL t3 ON t1.eventId = t3.eventId '
	end
	else
	begin
		set @columns = @columns + ', '''' ''sqlText'' '
	end
	
	set @whereClause = 'where success = 1 and eventCategory=6 and evtypeid in (' + @eventTypeString + ') and t1.startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and t1.startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') ';
	
	if (@privilegedUserOnly = 1)
	begin
		set @whereClause = @whereClause + ' and privilegedUser = 1 '
	end

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY t1.startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
	
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause

	EXEC(@stmt)

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetMassDataActivity] TO [public] AS [dbo]
GO
