/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetApplicationActivitySummary]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROC sp_cmreport_GetApplicationActivitySummary
(
	@eventDatabase nvarchar(256), 
	@databaseName nvarchar(256), 
	@applicationName nvarchar(256), 
	@eventCategory int, 
	@startDate datetime, 
   @endDate datetime, 
	@privilegedUserOnly bit, 
	@rowCount int)
AS
BEGIN
   -- Idera SQL compliance Manager Version 3.0
   --
   -- (c) Copyright 2004-2007 Idera, a division of BBS Technologies, Inc., all rights reserved.
   -- SQL compliance manager, Idera and the Idera Logo are trademarks or registered trademarks
   -- of BBS Technologies or its subsidiaries in the United States and other jurisdictions.

-- Creates the temporary table to store the result of the procedure which returns 
-- the result from the original "get_application_activity" proceudre for us to 
-- work on the returned data
CREATE TABLE #ApplicationActivities
(
  ApplicationName	nvarchar (255)
, Details		nvarchar (300)
, DatabaseName		nvarchar (255)
, EventType		nvarchar (40)
, HostName		nvarchar (255)
, LoginName 		nvarchar (255)
, TargetObject		nvarchar (500)
, StartTime		DATETIME
, SqlText		nvarchar (10)
)


-- Gets the data from the Application Activity proc for, then, format
-- the data the way we need, because we don't want Databas, EventTypes,
-- Logins in separate columns, we want it to be a category for our
-- summarization.
INSERT #ApplicationActivities
EXEC sp_cmreport_GetApplicationActivity @eventDatabase
	,@databaseName
	,@applicationName
	,@eventCategory
	,@startDate
	,@endDate
	,@privilegedUserOnly
	,0
	,'date'
	,@rowCount

-- Now we develop the query to return the data we want devided by category.
SELECT  ApplicationName,'Grouped By Database' as 'Category', DatabaseName as 'Data', COUNT(DatabaseName) 'DataCount'
	FROM #ApplicationActivities
	--WHERE DatabaseName IS NOT NULL AND DatabaseName != ''
	GROUP BY
	ApplicationName, DatabaseName

UNION ALL
SELECT  ApplicationName, 'Grouped By EventType' as 'Category', EventType as 'Data', COUNT(EventType) 'DataCount'
	FROM #ApplicationActivities
	--WHERE EventType IS NOT NULL AND EventType != ''
	GROUP BY 
	ApplicationName, EventType
UNION ALL
SELECT  ApplicationName , 'Grouped By LoginName' as 'Category', LoginName as 'Data', COUNT(LoginName) 'DataCount'
	FROM #ApplicationActivities
	--WHERE LoginName IS NOT NULL AND LoginName != ''
	GROUP BY
	ApplicationName, LoginName
UNION ALL
SELECT  ApplicationName, 'Grouped By TargetObject' as 'Category', TargetObject as 'Data', COUNT(TargetObject) 'DataCount'
	FROM #ApplicationActivities
	--WHERE TargetObject IS NOT NULL AND TargetObject != ''
	GROUP BY ApplicationName, TargetObject

-- After using it, we now drop our temporary table to free memory space
DROP TABLE #ApplicationActivities

END

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetApplicationActivitySummary] TO [public] AS [dbo]
GO
