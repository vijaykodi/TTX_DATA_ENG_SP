/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetLoginHistory]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetLoginHistory (
   @eventDatabaseAll nvarchar(256), 
   @loginStatus int, 
   @loginName nvarchar(256), 
   @startDate datetime, 
   @endDate datetime, 
   @sortColumn nvarchar(256), 
   @rowCount int
   )
as
declare @stmt nvarchar(4000) --we still have to work on SQL Server 2000. Otherwise, it would be nvarchar(max)
declare @columns nvarchar(2000), @fromClause nvarchar(500), @whereClause nvarchar(1000), @orderByClause nvarchar(200), @eventTypeString nvarchar(200)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

	if (@loginStatus = 1)
		set @eventTypeString = '50'
	else if (@loginStatus = 2)
		set @eventTypeString = '51'
	else
		set @eventTypeString = '50, 51'	

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

	 -- prevents sql injection but set limitations on the database naming
   set @loginName = UPPER(dbo.fn_cmreport_ProcessString(@loginName));

	set @columns = 'SELECT TOP '+ STR(@rowCount) +' applicationName, t2.name ''eventType'', hostName, ' +
	               'CASE WHEN sessionLoginName IS NULL OR DATALENGTH(sessionLoginName) = 0 ' +
                       'THEN loginName ELSE sessionLoginName END AS loginName, ' +
	               'startTime '
	               
	set @whereClause = 'WHERE evtypeid in (' + @eventTypeString + ') ' +
	                   'AND eventCategory=1 ' +
	                   'AND (UPPER(sessionLoginName) LIKE ''' + @loginName + ''' OR UPPER(loginName) LIKE ''' + @loginName + ''') ' +
	                   ' and t1.startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and t1.startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') '

	if(@sortColumn = 'date')
	   set @orderByClause = ' ORDER BY t1.startTime DESC';
	else
	   set @orderByClause = ' ORDER BY loginName' ;
			
if (@eventDatabaseAll = '<ALL>')
begin
	declare @eventDatabase nvarchar(128),
			@description nvarchar(512),
			@length int,
			@tempColumns nvarchar(2000)
			
		if (object_id(N'tempdb..#loginInfo') IS NOT NULL)
			drop table #loginInfo
			
		create table #loginInfo (
			applicationName nvarchar(128), 
			eventType nvarchar(64), 
			hostName nvarchar(128), 
			loginName nvarchar(128), 
			startTime dateTime,
			instanceName nvarchar(256)) 

	DECLARE eventDatabases CURSOR FOR 
	   SELECT DISTINCT databaseName, instance + CASE WHEN UPPER(databaseType) LIKE 'EVENT' THEN '' ELSE ' - ' + displayName END AS description
		  FROM SQLcompliance..SystemDatabases
		  WHERE(UPPER(databaseType) IN ('ARCHIVE', 'EVENT'))
		  ORDER BY description;
    OPEN eventDatabases;
	FETCH eventDatabases INTO @eventDatabase, @description
	
	while @@Fetch_Status = 0
	begin
		set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);
		set @fromClause = 'FROM [' + @eventDatabase + '].dbo.Events t1 LEFT OUTER JOIN EventTypes t2 ON t1.eventType = t2.evtypeid '
		set @tempColumns = @columns + ', ''' + @description + ''' as ''instanceName'' '
		set @stmt = @tempColumns + @fromClause + @whereClause + @orderByClause
		
		insert into #loginInfo exec (@stmt) 
	
	fetch eventDatabases into @eventDatabase, @description
	end
	
	close eventDatabases  
	deallocate eventDatabases
	
	select * from #loginInfo
end
else
begin
	set @eventDatabaseAll = dbo.fn_cmreport_ProcessString(@eventDatabaseAll);
	set @fromClause = 'FROM [' + @eventDatabaseAll + '].dbo.Events t1 LEFT OUTER JOIN EventTypes t2 ON t1.eventType = t2.evtypeid '
	set @columns = @columns + ', ''' + @eventDatabaseAll + ''' as ''instanceName'' '
	set @stmt = @columns + @fromClause + @whereClause + @orderByClause
	exec(@stmt)
end


GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetLoginHistory] TO [public] AS [dbo]
GO
