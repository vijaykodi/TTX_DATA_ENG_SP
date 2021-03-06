/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetServerLoginActivity]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE procedure sp_cmreport_GetServerLoginActivity (
	@eventDatabase nvarchar(256), 
	@loginStatus int, 
	@startDate datetime, 
   @endDate datetime, 
	@sortColumn nvarchar(256),
	@rowCount int)
as
	-- Creates the temporary table to store the result of the procedure which returns 
   -- the result from the original "get_application_activity" proceudre for us to 
   -- work on the returned data
   CREATE TABLE #UserLoginHistory
   (
      ApplicationName	NVARCHAR (255),
      EventType		int,
      LoginName		NVARCHAR (255),
      StartTime		DATETIME
   )


   -- Gets the data from the Application Activity proc for, then, format
   -- the data the way we need, because we don't want Databas, EventTypes,
   -- Logins in separate columns, we want it to be a category for our
   -- summarization.

   INSERT #UserLoginHistory EXEC sp_cmreport_GetServerLoginActivityHelper
   	@eventDatabase, 
	   @loginStatus, 
	   @startDate, 
      @endDate, 
	   @sortColumn,
	   @rowCount;

   -- Now we develop the query to return the data we want devided by category.
   SELECT  LoginName, EventType, ApplicationName, COUNT(StartTime) as DataCount
   	FROM #UserLoginHistory
   	GROUP BY
   	LoginName, EventType, ApplicationName

   -- After using it, we now drop our temporary table to free memory space
   DROP TABLE #UserLoginHistory

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetServerLoginActivity] TO [public] AS [dbo]
GO
