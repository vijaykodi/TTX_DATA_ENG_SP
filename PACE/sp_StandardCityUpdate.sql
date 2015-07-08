/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 9:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Trent Watkins
-- Create date: 5/19/2011
-- Last update: 8/5/2011
-- Description:	Standardized logging and error handling for stored procedures
-- =============================================
CREATE PROCEDURE [dbo].[sp_LogProcErrors] (
	-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
	@ProcedureName VARCHAR(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart DATETIME, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName VARCHAR(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate DATETIME = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate DATETIME = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum VARCHAR(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount INT, -- **REQUIRED** Total number of affected rows
	@ERR INT) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error INT, -- Error Trapping for this procedure
	@LogRowCount INT, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message VARCHAR(255), -- The Error Message for this Procedure
	@Error_Type INT, -- Used to track where errors are raised inside this procedure
	@Error_Loc INT -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [DATETIME] NOT NULL,
			[LogEnd] [DATETIME] NOT NULL,
			[RunByUSER] [CHAR](30) NOT NULL,
			[StepName] [VARCHAR](50) NOT NULL,
			[BeginIssueDate] [DATETIME] NULL,
			[EndIssueDate] [DATETIME] NULL,
			[IataNum] [VARCHAR](50) NULL,
			[ROWCOUNT] [INT] NOT NULL,
			[ERROR] [INT] NOT NULL,
			[ErrorMessage] [NVARCHAR](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql NVARCHAR(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [TEXT] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
	END

INSERT INTO dba.ProcedureLogs (
		ProcedureName
		,LogStart
		,LogEnd
		,RunByUSER
		,StepName
		,BeginIssueDate
		,EndIssueDate
		,IataNum
		,[ROWCOUNT]
		,ERROR
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GETDATE()
		,@RunByUSER
		,@StepName
		,@BeginDate
		,@EndDate
		,@IataNum
		,@RowCount
		,@ERR
		,@Error_Message

IF @ERR <> 0
	BEGIN
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [TEXT] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END

/****** Object:  StoredProcedure [dbo].[sp_StandardCityUpdate]    Script Date: 10/18/2011 12:25:03 ******/
SET ANSI_NULLS ON

GO

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_StandardCityUpdate]    Script Date: 7/7/2015 9:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Trent Watkins
-- Create date: 8/8/2011
-- Description:	This stored procedure updates the
-- the TTXCENTRAL.dba.City table with city codes that
-- currently do NOT EXIST in the city table.
-- =============================================
CREATE PROCEDURE [dbo].[sp_StandardCityUpdate](
	@BeginIDate			NVARCHAR(16),	-- Passed from the calling Parent Procedure
	@EndIDate			NVARCHAR(16),	-- Passed from the calling Parent Procedure 
	@ProductionServer	NVARCHAR(7),	-- The customers Production Server Name
	@StagingServer		NVARCHAR(7) = NULL,	-- The customers Staging Server Name
	@DatabaseName		NVARCHAR(20),	-- The Customers Database Name
	@Iata				NVARCHAR(10),	-- The Customers IataNumber
	@UpdateMain			INT = 1)			-- Set to zero to NOT update the TTXCENTRAL.dba.City table
AS

SET NOCOUNT ON

DECLARE @TransStart DATETIME	-- Capture the timestamp at the start of every transaction
DECLARE @sql NVARCHAR(3000)		-- Used to build and execute each sql statement
DECLARE @ProcName sysname		-- Hold the name of this procedure for logging
DECLARE @TransName NVARCHAR(50) -- TransactionName, Holds the name of each transaction so that variables can be concattinated into @StepName

SET @ProcName = OBJECT_NAME(@@PROCID)

-- LOG PROCEDURE START
SET @TransStart = GETDATE()
SET @TransName = 'START of sp_StandardCityUpdate for '+@DatabaseName
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/**** PRODUCTION TRANSEG.OrigCityCode ****/
-- LOG TRANSACTION START
SET @TransStart = GETDATE()
-- Update Production Server with Transeg.OriginCityCode
SET @sql = N'INSERT INTO '+@ProductionServer+'.'+@DatabaseName+'.dba.City
	SELECT DISTINCT ts.OriginCityCode,ts.TypeCode, ts.OriginCityCode,''UNKNOWN CITY'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
	FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.invoicedetail id, '+@ProductionServer+'.'+@DatabaseName+'.dba.transeg ts
	WHERE id.recordkey = ts.recordkey
	AND id.iatanum = ts.iatanum
	AND id.seqnum = ts.seqnum 
	AND ts.IataNum = '''+@Iata+'''
	AND id.vendortype in (''BSP'',''NONBSP'',''RAIL'')
	AND ts.issuedate BETWEEN '''+@BeginIDate+''' AND  '''+@EndIDate+'''
	AND NOT EXISTS (SELECT citycode from '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
					WHERE CityCode = isnull(ts.OriginCityCode,''ZZZ'')
					AND TypeCode = ts.Typecode)'

EXEC sp_executesql @sql
-- LOG TRANSACTION END
SET @TransName = 'Insert '+@ProductionServer+'.'+@DatabaseName+' dba.city-missing ts.origincitycode'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert dba.city-missing ts.origincitycode',@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

IF (SELECT @StagingServer) IS NOT NULL
BEGIN 
	/**** STAGING TRANSEG.OrigCityCode ****/
	-- LOG TRANSACTION START
	SET @TransStart = GETDATE()
	-- Update Production Server with Transeg.OriginCityCode
	SET @sql = N'INSERT INTO '+@StagingServer+'.'+@DatabaseName+'.dba.City
		SELECT DISTINCT ts.OriginCityCode,ts.TypeCode, ts.OriginCityCode,''UNKNOWN CITY'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
		FROM '+@StagingServer+'.'+@DatabaseName+'.dba.invoicedetail id, '+@StagingServer+'.'+@DatabaseName+'.dba.transeg ts
		WHERE id.recordkey = ts.recordkey
		AND id.iatanum = ts.iatanum
		AND id.seqnum = ts.seqnum 
		AND ts.IataNum = '''+@Iata+'''
		AND id.vendortype in (''BSP'',''NONBSP'',''RAIL'')
		AND ts.issuedate BETWEEN '''+@BeginIDate+''' AND  '''+@EndIDate+'''
		AND NOT EXISTS (SELECT citycode from '+@StagingServer+'.'+@DatabaseName+'.dba.City 
						WHERE CityCode = isnull(ts.OriginCityCode,''ZZZ'')
						AND TypeCode = ts.Typecode)'

	EXEC sp_executesql @sql
	-- LOG TRANSACTION END
	SET @TransName = 'Insert '+@StagingServer+'.'+@DatabaseName+' dba.city-missing ts.origincitycode'
	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert dba.city-missing ts.origincitycode',@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
END

/**** PRODUCTION TRANSEG.SegDestCityCode ****/
-- LOG TRANSACTION START
SET @TransStart = GETDATE()
-- Update Production with Transeg.SegDestCityCode
SET @sql = N'INSERT INTO '+@ProductionServer+'.'+@DatabaseName+'.dba.City
	SELECT DISTINCT ts.SegDestCityCode,ts.TypeCode, ts.SegDestCityCode,''UNKNOWN CITY'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
	FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.invoicedetail id, '+@ProductionServer+'.'+@DatabaseName+'.dba.transeg ts
	WHERE id.recordkey = ts.recordkey
	AND id.iatanum = ts.iatanum
	AND id.seqnum = ts.seqnum 
	AND ts.IataNum = '''+@Iata+'''
	AND id.vendortype in (''BSP'',''NONBSP'',''RAIL'')
	AND ts.issuedate between '''+@BeginIDate+''' AND  '''+@EndIDate+'''
	AND NOT EXISTS (SELECT citycode from '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
					WHERE CityCode = isnull(ts.OriginCityCode,''ZZZ'')
					AND TypeCode = ts.Typecode)'
EXEC sp_executesql @sql
-- LOG TRANSACTION END
SET @TransName = 'Insert '+@ProductionServer+'.'+@DatabaseName+' dba.city-missing ts.segdestcitycode'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

IF (SELECT @StagingServer) IS NOT NULL
BEGIN
	/**** STAGING TRANSEG.SegDestCityCode ****/
	-- LOG TRANSACTION START
	SET @TransStart = GETDATE()
	-- Update Staging with Transeg.SegDestCityCode
	SET @sql = N'INSERT INTO '+@StagingServer+'.'+@DatabaseName+'.dba.City
		SELECT DISTINCT ts.SegDestCityCode,ts.TypeCode, ts.SegDestCityCode,''UNKNOWN CITY'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
		FROM '+@StagingServer+'.'+@DatabaseName+'.dba.invoicedetail id, '+@StagingServer+'.'+@DatabaseName+'.dba.transeg ts
		WHERE id.recordkey = ts.recordkey
		AND id.iatanum = ts.iatanum
		AND id.seqnum = ts.seqnum 
		AND ts.IataNum = '''+@Iata+'''
		AND id.vendortype in (''BSP'',''NONBSP'',''RAIL'')
		AND ts.issuedate between '''+@BeginIDate+''' AND  '''+@EndIDate+'''
		AND NOT EXISTS (SELECT citycode from '+@StagingServer+'.'+@DatabaseName+'.dba.City 
						WHERE CityCode = isnull(ts.OriginCityCode,''ZZZ'')
						AND TypeCode = ts.Typecode)'
	EXEC sp_executesql @sql
	-- LOG TRANSACTION END
	SET @TransName = 'Insert '+@StagingServer+'.'+@DatabaseName+' dba.city-missing ts.segdestcitycode'
	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
END

/**** PRODUCTION HTLCITYCODE ****/
-- LOG TRANSACTION START
SET @TransStart = GETDATE()
-- Update Production With Hotel.HtlCityCode, HtlCityName
SET @sql = N'INSERT INTO '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
	SELECT DISTINCT HTL.HtlCityCode,''H'', replace(isnull(HTL.HtlCityName,''UNKNOWN CITY''),''.'',''''),replace(isnull(HTL.HtlCityName,''UNKNOWN CITY''),''.'',''''), NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
	FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.Hotel HTL
	WHERE HTL.IataNum = '''+@Iata+'''
	AND htl.issuedate between '''+@BeginIDate+''' AND '''+@EndIDate+'''
	AND HTL.HtlCityCode is not null
	AND NOT EXISTS (SELECT citycode FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
					WHERE CityCode = isnull(HTL.HtlCityCode,''ZZZ''))'
EXEC sp_executesql @sql
-- LOG TRANSACTION END
SET @TransName = 'Insert '+@ProductionServer+'.'+@DatabaseName+' dba.city-missing htl.htlcitycode'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

IF (SELECT @StagingServer) IS NOT NULL
BEGIN
	/**** STAGING HTLCITYCODE ****/
	-- LOG TRANSACTION START
	SET @TransStart = GETDATE()
	-- Update Staging With Hotel.HtlCityCode, HtlCityName
	SET @sql = N'INSERT INTO '+@StagingServer+'.'+@DatabaseName+'.dba.City 
		SELECT DISTINCT HTL.HtlCityCode,''H'', replace(isnull(HTL.HtlCityName,''UNKNOWN CITY''),''.'',''''),replace(isnull(HTL.HtlCityName,''UNKNOWN CITY''),''.'',''''), NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
		FROM '+@StagingServer+'.'+@DatabaseName+'.dba.Hotel HTL
		WHERE HTL.IataNum = '''+@Iata+'''
		AND htl.issuedate between '''+@BeginIDate+''' AND '''+@EndIDate+'''
		AND HTL.HtlCityCode is not null
		AND NOT EXISTS (SELECT citycode FROM '+@StagingServer+'.'+@DatabaseName+'.dba.City 
						WHERE CityCode = isnull(HTL.HtlCityCode,''ZZZ''))'
	EXEC sp_executesql @sql
	-- LOG TRANSACTION END
	SET @TransName = 'Insert '+@StagingServer+'.'+@DatabaseName+' dba.city-missing htl.htlcitycode'
	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
END

/**** PRODUCTION CARCITYCODE ****/
-- LOG TRANSACTION START
SET @TransStart = GETDATE()
-- Update Production With Car.CarCityCode, CarCityName					
SET @sql = N'INSERT INTO '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
	SELECT DISTINCT Car.CarCityCode,''C'', replace(isnull(Car.CarCityName,''UNKNOWN CITY''),''.'',''''),replace(isnull(Car.CarCityName,''UNKNOWN CITY''),''.'',''''), NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
	FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.Car Car
	WHERE Car.IataNum = '''+@Iata+'''
	AND Car.issuedate between '''+@BeginIDate+''' AND '''+@EndIDate+'''
	AND Car.CarCityCode is not null
	AND NOT EXISTS (SELECT citycode from '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
					WHERE CityCode = isnull(Car.CarCityCode,''ZZZ''))'
EXEC sp_executesql @sql
-- LOG TRANSACTION END
SET @TransName = 'Insert '+@ProductionServer+'.'+@DatabaseName+' dba.city-missing car.carcitycode'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

IF (SELECT @StagingServer) IS NOT NULL
BEGIN
	/**** STAGING CARCITYCODE ****/
	-- LOG TRANSACTION START
	SET @TransStart = GETDATE()
	-- Update Staging With Car.CarCityCode, CarCityName					
	SET @sql = N'INSERT INTO '+@StagingServer+'.'+@DatabaseName+'.dba.City 
		SELECT DISTINCT Car.CarCityCode,''C'', replace(isnull(Car.CarCityName,''UNKNOWN CITY''),''.'',''''),replace(isnull(Car.CarCityName,''UNKNOWN CITY''),''.'',''''), NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
		FROM '+@StagingServer+'.'+@DatabaseName+'.dba.Car Car
		WHERE Car.IataNum = '''+@Iata+'''
		AND Car.issuedate between '''+@BeginIDate+''' AND '''+@EndIDate+'''
		AND Car.CarCityCode is not null
		AND NOT EXISTS (SELECT citycode from '+@StagingServer+'.'+@DatabaseName+'.dba.City 
						WHERE CityCode = isnull(Car.CarCityCode,''ZZZ''))'
	EXEC sp_executesql @sql
	-- LOG TRANSACTION END
	SET @TransName = 'Insert '+@StagingServer+'.'+@DatabaseName+' dba.city-missing car.carcitycode'
	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
END

IF @UpdateMain = 1
	BEGIN
		
		-- LOG TRANSACTION START
		SET @TransStart = GETDATE()
		-- Update TTXSASQL03.TTXCENTRAL
		SET @sql = N'INSERT INTO TTXSASQL03.TTXCENTRAL.dba.City
			SELECT DISTINCT ts.OriginCityCode,ts.TypeCode, ts.OriginCityCode,''UNKNOWN CITY'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
			FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.invoicedetail id, '+@ProductionServer+'.'+@DatabaseName+'.dba.transeg ts
			WHERE id.recordkey = ts.recordkey
			AND id.iatanum = ts.iatanum
			AND id.seqnum = ts.seqnum 
			AND ts.IataNum = '''+@Iata+'''
			AND id.vendortype in (''BSP'',''NONBSP'',''RAIL'')
			AND ts.issuedate between '''+@BeginIDate+''' AND  '''+@EndIDate+'''
			AND NOT EXISTS (SELECT citycode from '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
							WHERE CityCode = isnull(ts.OriginCityCode,''ZZZ'')
							AND TypeCode = ts.Typecode)'
		EXEC sp_executesql @sql
		-- LOG TRANSACTION END
		EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert TTXSASQL03.TTXCENTRAL dba.city-missing ts.origincitycode',@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
		
		
		-- LOG TRANSACTION START
		SET @TransStart = GETDATE()
		-- Update TTXSASQL03.TTXCENTRAL	Transeg.SegDestCityCode
		SET @sql = N'INSERT INTO TTXSASQL03.TTXCENTRAL.dba.City
			SELECT DISTINCT ts.SegDestCityCode,ts.TypeCode, ts.SegDestCityCode,''UNKNOWN CITY'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
			FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.invoicedetail id, '+@ProductionServer+'.'+@DatabaseName+'.dba.transeg ts
			WHERE id.recordkey = ts.recordkey
			AND id.iatanum = ts.iatanum
			AND id.seqnum = ts.seqnum 
			AND ts.IataNum = '''+@Iata+'''
			AND id.vendortype in (''BSP'',''NONBSP'',''RAIL'')
			AND ts.issuedate between '''+@BeginIDate+''' AND  '''+@EndIDate+'''
			AND NOT EXISTS (SELECT citycode from '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
							WHERE CityCode = isnull(ts.OriginCityCode,''ZZZ'')
							AND TypeCode = ts.Typecode)'
		EXEC sp_executesql @sql
		-- LOG TRANSACTION END
		EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert TTXSASQL03.TTXCENTRAL dba.city-missing ts.segdestcitycode',@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
					
		
		-- LOG TRANSACTION START
		SET @TransStart = GETDATE()
		-- Update TTXSASQL03 With Hotel.HtlCityCode, HtlCityName	
		SET @sql = N'INSERT INTO TTXSASQL03.TTXCENTRAL.dba.City 
			SELECT DISTINCT HTL.HtlCityCode,''H'', replace(isnull(HTL.HtlCityName,''UNKNOWN CITY''),''.'',''''),replace(isnull(HTL.HtlCityName,''UNKNOWN CITY''),''.'',''''), NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
			FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.Hotel HTL
			WHERE HTL.IataNum = '''+@Iata+'''
			AND htl.issuedate between '''+@BeginIDate+''' AND '''+@EndIDate+'''
			AND HTL.HtlCityCode is not null
			AND NOT EXISTS (SELECT citycode FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
							WHERE CityCode = isnull(HTL.HtlCityCode,''ZZZ''))'
		EXEC sp_executesql @sql
		-- LOG TRANSACTION END
		EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert TTXSASQL03.TTXCENTRAL dba.city-missing htl.htlcitycode',@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


		-- LOG TRANSACTION START
		SET @TransStart = GETDATE()
		-- Update TTXSASQL03 With Car.CarCityCode, CarCityName
		SET @sql = N'INSERT INTO TTXSASQL03.TTXCENTRAL.dba.City 
			SELECT DISTINCT Car.CarCityCode,''C'', replace(isnull(Car.CarCityName,''UNKNOWN CITY''),''.'',''''),replace(isnull(Car.CarCityName,''UNKNOWN CITY''),''.'',''''), NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
			FROM '+@ProductionServer+'.'+@DatabaseName+'.dba.Car Car
			WHERE Car.IataNum = '''+@Iata+'''
			AND Car.issuedate between '''+@BeginIDate+''' AND '''+@EndIDate+'''
			AND Car.CarCityCode is not null
			AND NOT EXISTS (SELECT citycode from '+@ProductionServer+'.'+@DatabaseName+'.dba.City 
							WHERE CityCode = isnull(Car.CarCityCode,''ZZZ''))'
		EXEC sp_executesql @sql
		-- LOG TRANSACTION END
		EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert TTXSASQL03.TTXCENTRAL dba.city-missing car.carcitycode',@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
	END

-- LOG PROCEDURE END
SET @TransStart = GETDATE()
SET @TransName = 'END of sp_StandardCityUpdate for '+@DatabaseName
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TransName,@BeginDate=@BeginIDate,@EndDate=@EndIDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



GO

ALTER AUTHORIZATION ON [dbo].[sp_StandardCityUpdate] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 9:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](255) NULL,
	[BeginIssueDate] [datetime] NULL,
	[EndIssueDate] [datetime] NULL,
	[IataNum] [varchar](50) NULL,
	[ROWCOUNT] [int] NOT NULL,
	[ERROR] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

