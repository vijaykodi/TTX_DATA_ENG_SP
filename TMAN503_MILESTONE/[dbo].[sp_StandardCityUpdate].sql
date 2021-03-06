/****** Object:  StoredProcedure [dbo].[sp_StandardCityUpdate]    Script Date: 7/14/2015 8:12:05 PM ******/
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
