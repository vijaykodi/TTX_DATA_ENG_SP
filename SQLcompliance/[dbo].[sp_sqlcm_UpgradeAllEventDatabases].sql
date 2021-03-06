/****** Object:  StoredProcedure [dbo].[sp_sqlcm_UpgradeAllEventDatabases]    Script Date: 7/14/2015 7:35:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[sp_sqlcm_UpgradeAllEventDatabases]
as
BEGIN
	-- Create a cursor to iterate through the tables
	DECLARE @dbname varchar(255)
	
	DECLARE db_name INSENSITIVE CURSOR FOR
	SELECT databaseName FROM [SQLcompliance]..SystemDatabases WHERE databaseType='Archive' OR databaseType='Event'
	FOR READ ONLY
	
	SET NOCOUNT ON
	OPEN db_name 
	FETCH db_name INTO @dbname 
	WHILE @@fetch_status = 0 
	BEGIN
		EXEC sp_sqlcm_UpgradeEventDatabase @dbname
		FETCH db_name INTO @dbname 
	END
	CLOSE db_name 
	DEALLOCATE db_name
END

GO
