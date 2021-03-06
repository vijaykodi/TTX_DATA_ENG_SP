/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetEventDatabases]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure sp_cmreport_GetEventDatabases (@includeAll bit = 0)
as
   IF (@includeAll = 1)
   BEGIN
	   SELECT '<ALL>' as databaseName, '<ALL>' as description 
	   UNION
	   SELECT DISTINCT databaseName, instance + CASE WHEN UPPER(databaseType) LIKE 'EVENT' THEN '' ELSE ' - ' + displayName END AS description
		  FROM SystemDatabases
		  WHERE(UPPER(databaseType) IN ('ARCHIVE', 'EVENT'))
		  ORDER BY description
   END
   ELSE
   BEGIN
	   SELECT DISTINCT databaseName, instance + CASE WHEN UPPER(databaseType) LIKE 'EVENT' THEN '' ELSE ' - ' + displayName END AS description
		  FROM SystemDatabases
		  WHERE(UPPER(databaseType) IN ('ARCHIVE', 'EVENT'))
		  ORDER BY description
   END

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetEventDatabases] TO [public] AS [dbo]
GO
