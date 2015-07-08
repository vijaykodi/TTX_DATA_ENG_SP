/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 11:01:44 PM ******/
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
	@ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount int, -- **REQUIRED** Total number of affected rows
	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error int, -- Error Trapping for this procedure
	@LogRowCount int, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message varchar(255), -- The Error Message for this Procedure
	@Error_Type int, -- Used to track where errors are raised inside this procedure
	@Error_Loc int -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [datetime] NOT NULL,
			[LogEnd] [datetime] NOT NULL,
			[RunByUSER] [char](30) NOT NULL,
			[StepName] [varchar](50) NOT NULL,
			[BeginIssueDate] [datetime] NULL,
			[EndIssueDate] [datetime] NULL,
			[IataNum] [varchar](50) NULL,
			[RowCount] [int] NOT NULL,
			[Error] [int] NOT NULL,
			[ErrorMessage] [nvarchar](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql nvarchar(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
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
		,[RowCount]
		,Error
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GetDate()
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
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END		


GO

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_ORBITZ_CO2_MAIN]    Script Date: 7/7/2015 11:01:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_ORBITZ_CO2_MAIN]
WITH EXECUTE AS CALLER

AS
declare @TransStart DATETIME 
declare @ProcName varchar(50)
declare @TSUpdateEndSched nvarchar(50)
declare @IATANUM VARCHAR (50)
declare @BEGINISSUEDATEMAIN DATETIME
declare @ENDISSUEDATEMAIN DATETIME


set @ProcName = 'sp_ORBITZ_CO2_MAIN_DATA'--sql update from Brent
set @IATANUM = 'ALL'
--Reset the CO2 and YieldInd values before reprocessing

	--update id
	--set TktCO2Emissions = NULL
	--from dba.InvoiceDetail id
	--where TktCO2Emissions is not null
	
--	update t1
--	set
--	SEGCO2Emissions = NULL,
--	NOXCO2Emissions = NULL,
--	MINCO2Emissions = NULL,
--	FSeats = NULL,
--	BusSeats = NULL,
--	EconSeats = NULL,
--	TtlSeats = NULL,
--	YieldInd = NULL,
--	EquipmentCode = NULL
--	from dba.Transeg_VW t1
--	where issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

	
	--update htl
	--set CO2Emissions = NULL,
	--GroundTransCO2 = NULL,
	--MilesFromAirport = NULL
	--from dba.hotel htl
	--where CO2Emissions is not null

	--update car
	--set CO2Emissions = NULL
	--from dba.car car
	--where CO2Emissions is not null
	
	--log processing
	-- Any and all edits can be logged using sp_LogProcErrors 
	-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
	-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
	--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
	--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	--	@RowCount int, -- **REQUIRED** Total number of affected rows
	--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--4/11/2014 added clientcode as Orbitz only requesting for 1 client.  Legg Mason clientcode='TPT-TP5913257'

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CO2 Stored Procedure Start',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

	SELECT DISTINCT EndSched, IDENTITY(int) AS [ID] 
	INTO #EndSchedList 
	FROM DATAFEEDS.dba.InnovataData
	ORDER BY EndSched desc

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Created EndSched List',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

DECLARE @RowCount int, @ProcEndSched datetime, @lcv int
SELECT @RowCount = MAX([ID]) FROM #EndSchedList

SET @lcv = 1
SET @RowCount = @RowCount + 1
WHILE (@lcv < @RowCount)
                BEGIN
                
                              SELECT @ProcEndSched=EndSched FROM #EndSchedList WHERE [id] = @lcv
                              SET @lcv = @lcv + 1
                              SET @TransStart = getdate()
                              set @TSUpdateEndSched = 'Processing for '+cast(@ProcEndSched as nvarchar(25))
                                
                               update t1
								set t1.equipmentcode = t2.aircrafttype
								   ,t1.FSeats = ISNULL(t2.FSeats,0)
								   ,t1.BusSeats = ISNULL(t2.BusSeats,0)
								   ,t1.EconSeats = ISNULL(t2.EconSeats,0)
								   ,t1.TtlSeats = ISNULL(t2.FSeats,0)+ISNULL(t2.BusSeats,0)+ISNULL(t2.EconSeats,0)
								from dba.Transeg_VW t1,DATAFEEDS.dba.InnovataData t2
								where t1.departuredate between t2.beginservice and t2.endservice 
								and t2.endsched = @ProcEndSched
								--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
								and cast(t1.flightnum as int) = t2.flightnum
								and t1.segmentcarriercode = substring(t2.carrier,1,2)
								and t1.origincitycode = t2.depairport
								and t1.segdestcitycode = t2.arrairport
								AND t1.EquipmentCode is null
								and SEGCO2Emissions is null
								and datepart(dw,t1.departuredate) = case when datepart(dw,t1.departuredate) = 1 then substring(opdaystring,1,1)
																		when datepart(dw,t1.departuredate) = 2 then substring(opdaystring,2,1)
																		when datepart(dw,t1.departuredate) = 3 then substring(opdaystring,3,1)
																		when datepart(dw,t1.departuredate) = 4 then substring(opdaystring,4,1)
																		when datepart(dw,t1.departuredate) = 5 then substring(opdaystring,5,1)
																		when datepart(dw,t1.departuredate) = 6 then substring(opdaystring,6,1)
																	else substring(opdaystring,7,1)
																	END
								and replace(t1.flightnum,',','') NOT LIKE '%[^0-9]%'
								and t1.clientcode='TPT-TP5913257'

			
				EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@TSUpdateEndSched,@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
                
                END

----Update Burn Bucket 125 or Less
----Update Domestic US Travel by 1.07--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode = 'US'
and dest.countrycode = 'US'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 US DOM x 1.07',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Burn Bucket 125 or Less
--Update Intra Europe Flights by 1.10--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and Octry.continentcode = 'EU'
and DCtry.continentcode = 'EU'
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 Intra EU x 1.10',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Burn Bucket 125 or Less
----Update All other Dometic flights by 1.085--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					             end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS((t1.segsegmentmileage)/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and ((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode =  dest.countrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <= 125 DOM x 1.085',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Burn Bucket 125 or Less
----Update All other Short Haul flights by 1.085--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					             end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 short haul x 1.085',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Update All other Burn Buckets--
----Update Domestic US Travel by 1.07--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and orig.countrycode = 'US'
and dest.countrycode = 'US'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket > 125 US x 1.07',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update Intra Europe Flights by 1.10--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country Octry
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and Octry.continentcode = 'EU'
and DCtry.continentcode = 'EU'
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Intra Europe x 1.10',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Dometic flights by 1.085--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode =  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Dom x 1.085',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets --
--Update All other Short Haul flights by 1.085--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 <= 2000
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Short Haul x1.085',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '2000' and '3000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.07 btw 2000-3000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update All other Burn Buckets --
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '3000' and '4000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.06 btw 3000-4000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '4000' and '5000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.05 btw 4000-5000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '5000' and '6000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.04 btw 5000-6000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '6000' and '7000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.03 btw 6000-7000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '7000' and '8000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.02 btw 7000-8000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.01 Distance greter than 8000--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))*CASE WHEN t4.cargoRatio = 0 THEN 1 ELSE isnull(t4.cargoratio,1) END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN t4.loadfactor = 0 THEN 1 ELSE isnull(t4.loadfactor,1) END
					  end ,
yieldind = 'Y'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.equipcode = eq.equivalentcode
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 > '8000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.01 >8000',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--New code inserted by Brent Majors 12/29/2011 to use market averages where we dont get an exact hit--
----Update Burn Bucket 125 or Less
----Update Domestic US Travel by 1.07--
--Use Market Averages
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode = 'US'
and dest.countrycode = 'US'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 US DOM x 1.07 Mkt Avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Burn Bucket 125 or Less
--Update Intra Europe Flights by 1.10--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and Octry.continentcode = 'EU'
and DCtry.continentcode = 'EU'
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 Intra EU x 1.10 Mkt Avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Burn Bucket 125 or Less
----Update All other Dometic flights by 1.085--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					             end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS((t1.segsegmentmileage)/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and ((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode =  dest.countrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <= 125 DOM x 1.085 Mkt Avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Burn Bucket 125 or Less
----Update All other Short Haul flights by 1.085--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					             end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 short haul x 1.085 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Update All other Burn Buckets--
----Update Domestic US Travel by 1.07--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and orig.countrycode = 'US'
and dest.countrycode = 'US'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket > 125 US x 1.07 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update Intra Europe Flights by 1.10--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country Octry
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and Octry.continentcode = 'EU'
and DCtry.continentcode = 'EU'
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Intra Europe x 1.10 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Dometic flights by 1.085--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode =  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Dom x 1.085 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets --
--Update All other Short Haul flights by 1.085--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 <= 2000
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Short Haul x1.085 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '2000' and '3000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.07 btw 2000-3000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update All other Burn Buckets --
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '3000' and '4000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.06 btw 3000-4000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '4000' and '5000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.05 btw 4000-5000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '5000' and '6000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.04 btw 5000-6000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '6000' and '7000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haul x1.03 btw 6000-7000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '7000' and '8000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.02 btw 7000-8000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.01 Distance greter than 8000--
--Use Market Averages--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/t4.avgloadfactor 
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/t4.avgloadfactor 
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))*t4.avgcargoratio)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/t4.avgloadfactor 
					  end ,
yieldind = 'M'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,DATAFEEDS.dba.CO2_Airline_Cargo_Load t4 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t4.carrier = t7.CR
and t4.origin = t1.origincitycode
and t4.dest = t1.segdestcitycode 
and t4.carrier = t1.segmentcarriercode
and t4.year = year(t1.departuredate)
and t4.month = month(t1.departuredate) 
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 > '8000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.01 >8000 mkt avg',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--New Updates inserted by Brent Majors Dec 23 2011 for default load facotrs and cargo ratios
----Update Burn Bucket 125 or Less--
----Update Domestic US Travel by 1.07--
----Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END )/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.07))*CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode = 'US'
and dest.countrycode = 'US'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 US DOM x 1.07 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Burn Bucket 125 or Less
--Update Intra Europe Flights by 1.10--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))*CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.1))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and Octry.continentcode = 'EU'
and DCtry.continentcode = 'EU'
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 Intra EU x 1.10 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Burn Bucket 125 or Less
----Update All other Dometic flights by 1.085--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					             end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS((t1.segsegmentmileage)/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and ((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode =  dest.countrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <= 125 DOM x 1.085 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Burn Bucket 125 or Less
----Update All other Short Haul flights by 1.085--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else ((t2.PoundsCO2PerMile*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.00))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					             end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city orig
,dba.city dest
,dba.country OCtry 
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) <= 125
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket <=125 short haul x 1.085 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Update All other Burn Buckets--
----Update Domestic US Travel by 1.07--
----Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and orig.countrycode = 'US'
and dest.countrycode = 'US'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket > 125 US x 1.07 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update Intra Europe Flights by 1.10--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.10) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.10))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country Octry
,dba.country DCtry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and Octry.continentcode = 'EU'
and DCtry.continentcode = 'EU'
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Intra Europe x 1.10 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Dometic flights by 1.085--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode =  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Dom x 1.085 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets --
--Update All other Short Haul flights by 1.085--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.085) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.085))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 <= 2000
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Processed Burn Bucket >125 Short Haul x1.085 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.07) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.07))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '2000' and '3000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.07 btw 2000-3000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update All other Burn Buckets --
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.06) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.06))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '3000' and '4000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.06 btw 3000-4000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.05) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.05))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low 
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '4000' and '5000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.05 btw 4000-5000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.04) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.04))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '5000' and '6000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.04 btw 5000-6000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.03) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.03))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '6000' and '7000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.03 btw 6000-7000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.02) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.02))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 between '7000' and '8000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.02 btw 7000-8000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update All other Burn Buckets--
--Update All other Long Haul flights by 1.01 Distance greter than 8000--
--Update default cargo and passenger ratios--
SET @TransStart = getdate()

UPDATE t1
SET SegCO2Emissions = case when t5.DomCabin = 'First' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin1,1.8))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       when t5.DomCabin = 'Business' then (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin2,2.0))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
							       else (((((((ABS(t1.segsegmentmileage)/1.150779*1.01) - t3low.BurnUpperValue)*(t2.PoundsCO2PerMile - t2low.PoundsCO2PerMile)) / (t3.BurnUpperValue - t3low.BurnUpperValue)) + t2low.PoundsCO2PerMile)*(ABS(t1.segsegmentmileage)/1.150779*1.01))* CASE WHEN t2.equipclass = 'W' THEN .801 WHEN t2.equipclass = 'J' THEN .983 ELSE 1 END)/((isnull(t1.fseats,0)*isnull(t7.Cabin1,1.8))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,2.0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,1)))*(isnull(t7.Cabin4,1))/CASE WHEN T1.segmentcarriercode in ('AA','US','AS','AQ','CO','DL','NW','UA','2F','3M','4E','4W','5F','8v','9K','B6','FL','GQ','H6','HA','HP','J6','KS','NK','PA','Q5','SY','U5','VQ','VX','WN','YI','YX','ZQ','2E','2Q','3A','3F','3Z','7N','7S','8E','9S','BK','QX','CH','DQ','EJ','HX','IS','JW','K3','K4','K5','LW','M5','M6','UH','WP','YR','YV','Z3','ZK','00','XE','NA','2O','9L','EV','G7','J5','MQ','OH','OO','RP','RW','S6','XJ','ZW','D1','CP','S5','AX','C5','6P','LL','1X','GV','K9','L3','N8','RD','XP','Y0','V2','TJ') THEN .7593 ELSE .6735 END
					  end ,
yieldind = 'C'
from dba.Transeg_VW T1
,DATAFEEDS.dba.CO2_Emissions t2
,DATAFEEDS.dba.CO2_Emissions t2low
,DATAFEEDS.dba.CO2_BurnBucket t3
,DATAFEEDS.dba.CO2_BurnBucket t3low
,dba.classtocabin t5
,DATAFEEDS.dba.CO2_SeatGuru t7
,DATAFEEDS.dba.CO2_AircraftEquiv eq
,dba.city ORIG
,dba.city DEST
,dba.country octry
,dba.country dctry
where t1.equipmentcode is not null 
and t1.equipmentcode = eq.EquipmentCode
and eq.EquivalentCode = t2.EquipCode
and t2.distancegroup = t3.burnuppervalue
and eq.EquivalentCode = t2low.EquipCode
and t2low.distancegroup = t3low.burnuppervalue
and t3low.BucketNum = t3.BucketNum - 1
and ABS(t1.segsegmentmileage/1.150779) between t3.burnlowvalue and t3.burnuppervalue
and t1.segmentcarriercode = t5.carriercode
and ISNULL(t1.classofservice,'Y') = t5.classofservice
and t1.SegInternationalInd = t5.InternationalInd
and t1.segmentcarriercode = t7.CR
and t1.EquipmentCode = eq.equipmentcode
and eq.equivalentcode = t7.EQCode
and t1.segco2emissions is null
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.typecode = 'A'
and (((isnull(t1.fseats,0)*isnull(t7.Cabin1,0))+(isnull(t1.busseats,0)*isnull(t7.Cabin2,0))+(isnull(t1.econseats,0)*isnull(t7.Cabin4,0)))) > 0
and orig.countrycode =  Octry.ctrycode
and dest.countrycode =  DCtry.ctrycode
and orig.countrycode <>  dest.countrycode
and t1.origincitycode = orig.citycode
and t1.segdestcitycode = dest.citycode
and t1.segsegmentmileage/1.150779 > '8000'
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Burn Bucket L-Haulx1.01 >8000 for deafult cargo and passenger ratios',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Step down logic for matching CO2--
SET @TransStart = getdate()

update t2
set t2.SegCO2Emissions = t1.SegCO2Emissions
   ,YieldInd = 'F' ---match on everything --this is where we didn't get a match using the sechedule data...now using same flight details previously updated.  Need to update sql to find most recent record for same flight
from dba.Transeg_VW T1, dba.Transeg_VW t2
where t1.SegCO2Emissions > 0
and ((t2.SegCO2Emissions is null or t2.SegCO2Emissions = 0))
and t1.flightnum = t2.flightnum
and t1.origincitycode = t2.origincitycode
and t1.segdestcitycode = t2.segdestcitycode
and t1.segmentcarriercode = t2.segmentcarriercode
and ISNULL(t1.equipmentcode,'ZZ') = ISNULL(t2.equipmentcode,'ZZ')
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Yield=F-match on everything',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update t2
set t2.SegCO2Emissions = t1.SegCO2Emissions
   ,YieldInd = 'A' -- matched on everything but flight number is different
from dba.Transeg_VW T1, dba.Transeg_VW t2
where t1.SegCO2Emissions > 0
and ((t2.SegCO2Emissions is null or t2.SegCO2Emissions = 0))
and t1.origincitycode = t2.origincitycode
and t1.segdestcitycode = t2.segdestcitycode
and t1.segmentcarriercode = t2.segmentcarriercode
and ISNULL(t1.equipmentcode,'ZZ') = ISNULL(t2.equipmentcode,'ZZ')
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Yield=A-match on everything but flight',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update t2
set t2.SegCO2Emissions = t1.SegCO2Emissions
   ,YieldInd = 'E' -- Match on equipment only
from dba.Transeg_VW T1, dba.Transeg_VW t2
where t1.SegCO2Emissions > 0
and ((t2.SegCO2Emissions is null or t2.SegCO2Emissions = 0))
and t1.origincitycode = t2.origincitycode
and t1.segdestcitycode = t2.segdestcitycode
and ISNULL(t1.equipmentcode,'ZZ') = ISNULL(t2.equipmentcode,'ZZ')
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and t1.clientcode='TPT-TP5913257'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Yield=E-match on equipment only',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update dba.Transeg_VW
set segco2emissions = CASE WHEN ABS(SegSegmentMileage) BETWEEN 0 AND 500 THEN SegSegmentMileage * 0.52
                      ELSE SegSegmentMileage * 0.40
                      END
   ,YieldInd = 'D' --match where nothing matches - using default values .audit trail on why not found
WHERE ((SegCO2Emissions IS NULL or SegCO2Emissions = 0))
and segsegmentmileage is not null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Yield=D-match on nothing',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update dba.Transeg_VW
set yieldind = 'N' --No match at all which shouldn't happen .audit trail on why not found
where segsegmentmileage is Null
and yieldind  is Null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Yield=N-no match at all',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update dba.Transeg_VW
set yieldind = 'Z' --No match on yield and equipcode...audit trail on why not found
where segsegmentmileage is Null
and yieldind  is Null
and equipmentcode is Null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Yield=Z-no match on yield and equipment',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update dba.hotel
set CO2Emissions = (NumNights * NumRooms) * 33.38
where co2emissions is null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and ClientCode='TPT-TP5913257'



update dba.car
set CO2Emissions = (((20 / 23.9) * 8.87) / 1000) * (NumDays * NumCars)
where co2emissions is null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and clientcode='TPT-TP5913257'

update dba.Transeg_VW
set equipmentcode = 'TRN'
where segmentcarriercode in ('2R','2V','9B','9F')--need to insure that all TRAINS are covered...
and equipmentcode is null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN



update dba.Transeg_VW
set segco2emissions = case when segsegmentmileage <= 20 then (.35 * segsegmentmileage) * 1.10 else (.42 * segsegmentmileage) * 1.10 END
, YieldInd = 'T'
where equipmentcode = 'TRN'
and segco2emissions is null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


update dba.Transeg_VW --check...where does equipmentcode is set 'BUS'
set segco2emissions = case when segsegmentmileage <= 20 then (.66 * segsegmentmileage) * 1.10 else (.18 * segsegmentmileage) * 1.10 END
, YieldInd = 'B'
where equipmentcode = 'BUS'
and segco2emissions is null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN




--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process Refunds',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Partial Refunds--
SET @TransStart = getdate()

update t1
set  t1.segco2emissions = (t2.segco2emissions*-1)
from dba.Transeg_VW T1, dba.Transeg_VW t2 , dba.invoicedetail i1, dba.invoicedetail i2
where t1.recordkey = i1.recordkey and t1.seqnum = i1.seqnum
and t1.iatanum = i1.iatanum
and t2.recordkey = i2.recordkey and t2.seqnum = i2.seqnum
and t2.iatanum = i2.iatanum
and t1.segsegmentvalue = t2.segsegmentvalue
and i1.refundind = 'P' and i2.refundind = 'N'
and i1.documentnumber = i2.documentnumber
and t1.origincitycode = t2.origincitycode
and t1.segdestcitycode = t2.segdestcitycode
and t1.recordkey <> t2.recordkey
and i1.documentnumber <> '9999999999'
and i1.iatanum <> 'DEMO'
and t1.iatanum <> 'DEMO'
and i2.iatanum <> 'DEMO'
and t2.iatanum <> 'DEMO'
and i1.clientcode='TPT-TP5913257'
and i2.clientcode='TPT-TP5913257'
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process partial refunds',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Full refunds --
SET @TransStart = getdate()
update t1
set t1.segco2emissions = (t2.segco2emissions*-1)
from dba.Transeg_VW T1, dba.Transeg_VW t2 , dba.invoicedetail i1, dba.invoicedetail i2
where t1.recordkey = i1.recordkey and t1.seqnum = i1.seqnum
and t1.iatanum = i1.iatanum
and t2.recordkey = i2.recordkey and t2.seqnum = i2.seqnum
and t2.iatanum = i2.iatanum
and t1.segmentnum = t2.segmentnum
and i1.refundind = 'Y' and i2.refundind ='N'
and i1.documentnumber = i2.documentnumber
and t1.recordkey <> t2.recordkey
and i1.documentnumber <> '9999999999'
and i1.iatanum <> 'DEMO'
and t1.iatanum <> 'DEMO'
and i2.iatanum <> 'DEMO'
and t2.iatanum <> 'DEMO'
and i1.clientcode='TPT-TP5913257'
and i2.clientcode='TPT-TP5913257'

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process Full Refunds',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--New Refund Updates from Brent 11NOV2011

SET @TransStart = getdate()
Update T1
set segsegmentmileage = ABS(segsegmentmileage)*-1,
segtotalmileage = ABS(segtotalmileage)*-1,
noxsegmentmileage = ABS(noxsegmentmileage)*-1,
noxtotalmileage = ABS(noxtotalmileage)*-1, 
minsegmentmileage = ABS(minsegmentmileage)*-1,
mintotalmileage = ABS(mintotalmileage)*-1,
noxflownmileage = ABS(noxflownmileage)*-1,
minflownmileage = ABS(minflownmileage)*-1,
segco2emissions = ABS(segco2emissions)*-1,
noxco2emissions = ABS(noxco2emissions)*-1,
minco2emissions = ABS(minco2emissions)*-1
from dba.Transeg_VW T1, dba.invoicedetail ID
where id.recordkey = T1.recordkey and id.iatanum = t1.iatanum
and id.seqnum = t1.seqnum and id.clientcode = t1.clientcode
and id.issuedate = t1.issuedate
and id.refundind IN ('Y','P')
and id.iatanum <> 'DEMO'
and t1.iatanum <> 'DEMO'
--and id.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and id.clientcode='TPT-TP5913257'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process Refund segement data',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update ID
set ID.TKTCO2Emissions = (select sum(isnull(SegCO2Emissions,0)) 
      from dba.Transeg_VW ts-- dba.invoicedetail id 
      where ts.iatanum = id.iatanum 
            and ts.recordkey = id.recordkey 
            and ts.seqnum = id.seqnum 
            and id.clientcode = ts.clientcode
            and id.issuedate = ts.issuedate
            --and ts.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
                        and ((id.TKTCO2Emissions IS NULL))
            )
from dba.invoicedetail ID ,dba.transeg ts
where vendortype in ('BSP','BSPSTP','NONBSP','NONBSPSTP')
and TKTCO2Emissions is null
and ts.iatanum = id.iatanum 
            and ts.recordkey = id.recordkey 
            and ts.seqnum = id.seqnum 
            and ts.clientcode = id.clientcode
            and ts.issuedate = id.issuedate
            and ts.segmentnum = 1
            and ts.clientcode='TPT-TP5913257'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update TKT co2',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Process',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



GO

ALTER AUTHORIZATION ON [dbo].[sp_ORBITZ_CO2_MAIN] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 11:01:45 PM ******/
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
	[RowCount] [int] NOT NULL,
	[Error] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 11:01:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[InvoiceType] [varchar](10) NULL,
	[InvoiceTypeDescription] [varchar](255) NULL,
	[DocumentNumber] [varchar](15) NULL,
	[EndDocNumber] [varchar](3) NULL,
	[VendorNumber] [varchar](15) NULL,
	[VendorType] [varchar](10) NULL,
	[ValCarrierNum] [int] NULL,
	[ValCarrierCode] [varchar](6) NULL,
	[VendorName] [varchar](40) NULL,
	[BookingDate] [datetime] NULL,
	[ServiceDate] [datetime] NULL,
	[ServiceCategory] [varchar](8) NULL,
	[InternationalInd] [varchar](1) NULL,
	[ServiceFee] [float] NULL,
	[InvoiceAmt] [float] NULL,
	[TaxAmt] [float] NULL,
	[TotalAmt] [float] NULL,
	[CommissionAmt] [float] NULL,
	[CancelPenaltyAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[FareCompare1] [float] NULL,
	[ReasonCode1] [varchar](6) NULL,
	[FareCompare2] [float] NULL,
	[ReasonCode2] [varchar](6) NULL,
	[FareCompare3] [float] NULL,
	[ReasonCode3] [varchar](6) NULL,
	[FareCompare4] [float] NULL,
	[ReasonCode4] [varchar](6) NULL,
	[Mileage] [float] NULL,
	[Routing] [varchar](120) NULL,
	[DaysAdvPurch] [int] NULL,
	[AdvPurchGroup] [varchar](10) NULL,
	[TrueTktCount] [int] NULL,
	[TripLength] [float] NULL,
	[ExchangeInd] [varchar](1) NULL,
	[OrigExchTktNum] [varchar](15) NULL,
	[Department] [varchar](40) NULL,
	[ETktInd] [varchar](1) NULL,
	[ProductType] [varchar](20) NULL,
	[TourCode] [varchar](15) NULL,
	[EndorsementRemarks] [varchar](60) NULL,
	[FareCalcLine] [varchar](255) NULL,
	[GroupMult] [int] NULL,
	[OneWayInd] [varchar](1) NULL,
	[PrefTktInd] [varchar](1) NULL,
	[HotelNights] [float] NULL,
	[CarDays] [float] NULL,
	[OnlineBookingSystem] [varchar](20) NULL,
	[AccommodationType] [varchar](10) NULL,
	[AccommodationDescription] [varchar](255) NULL,
	[ServiceType] [varchar](10) NULL,
	[ServiceDescription] [varchar](255) NULL,
	[ShipHotelName] [varchar](255) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[IntlSalesInd] [varchar](4) NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[RefundInd] [varchar](1) NULL,
	[OriginalInvoiceNum] [varchar](15) NULL,
	[BranchIataNum] [varchar](8) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[TicketingAgentID] [varchar](10) NULL,
	[OriginCode] [varchar](10) NULL,
	[DestinationCode] [varchar](10) NULL,
	[TktCO2Emissions] [float] NULL,
	[CCMatchedRecordKey] [varchar](100) NULL,
	[CCMatchedIataNum] [varchar](8) NULL,
	[ACQMatchedInd] [varchar](1) NULL,
	[ACQMatchedRecordKey] [varchar](100) NULL,
	[ACQMatchedIataNum] [varchar](8) NULL,
	[CarrierString] [varchar](50) NULL,
	[ClassString] [varchar](50) NULL,
	[CRMatchedInd] [varchar](1) NULL,
	[CRMatchedRecordKey] [varchar](100) NULL,
	[CRMatchedIataNum] [varchar](8) NULL,
	[LastImportDt] [datetime] NULL,
	[GolUpdateDt] [datetime] NULL,
	[OrigTktAmt] [float] NULL,
	[TktWasExchangedInd] [varchar](1) NULL,
	[TicketGroupId] [varchar](50) NULL
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InnovataData]    Script Date: 7/7/2015 11:01:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InnovataData](
	[Carrier] [varchar](3) NULL,
	[FlightNum] [int] NULL,
	[DepAirport] [varchar](3) NULL,
	[DepTerm] [varchar](2) NULL,
	[DepCity] [varchar](3) NULL,
	[DepCountry] [varchar](2) NULL,
	[ArrAirport] [varchar](3) NULL,
	[ArrTerm] [varchar](2) NULL,
	[ArrCity] [varchar](3) NULL,
	[ArrCountry] [varchar](2) NULL,
	[BeginService] [datetime] NULL,
	[EndService] [datetime] NULL,
	[LocalDepTime] [datetime] NULL,
	[LocalArrTime] [datetime] NULL,
	[DepMin] [int] NULL,
	[ArrMin] [int] NULL,
	[ArrDay] [int] NULL,
	[ElapsedTime] [int] NULL,
	[OpMon] [int] NULL,
	[OpTue] [int] NULL,
	[OpWed] [int] NULL,
	[OpThu] [int] NULL,
	[OpFri] [int] NULL,
	[OpSat] [int] NULL,
	[OpSun] [int] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[Stops] [int] NULL,
	[OperatingCarrierFlag] [int] NULL,
	[OperatingCarrier] [varchar](3) NULL,
	[Restrictions] [varchar](1) NULL,
	[AirCraftType] [varchar](3) NULL,
	[OpDayString] [varchar](20) NULL,
	[BeginSched] [datetime] NULL,
	[EndSched] [datetime] NULL
) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InnovataData] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Hotel]    Script Date: 7/7/2015 11:02:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Hotel](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[HtlSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[HtlChainCode] [varchar](6) NULL,
	[HtlChainName] [varchar](40) NULL,
	[GDSPropertyNum] [varchar](15) NULL,
	[HtlPropertyName] [varchar](40) NULL,
	[HtlAddr1] [varchar](40) NULL,
	[HtlAddr2] [varchar](40) NULL,
	[HtlAddr3] [varchar](40) NULL,
	[HtlCityCode] [varchar](10) NULL,
	[HtlCityName] [varchar](25) NULL,
	[HtlState] [varchar](20) NULL,
	[HtlPostalCode] [varchar](15) NULL,
	[HtlCountryCode] [varchar](5) NULL,
	[HtlPhone] [varchar](20) NULL,
	[InternationalInd] [varchar](1) NULL,
	[CheckinDate] [datetime] NULL,
	[CheckoutDate] [datetime] NULL,
	[NumNights] [smallint] NULL,
	[NumRooms] [smallint] NULL,
	[HtlQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[HtlDailyRate] [float] NULL,
	[TtlHtlCost] [float] NULL,
	[RoomType] [varchar](6) NULL,
	[HtlRateCat] [varchar](10) NULL,
	[HtlCompareRate1] [float] NULL,
	[HtlReasonCode1] [varchar](6) NULL,
	[HtlCompareRate2] [float] NULL,
	[HtlReasonCode2] [varchar](6) NULL,
	[HtlCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefHtlInd] [varchar](1) NULL,
	[HtlConfNum] [varchar](30) NULL,
	[FreqGuestProgram] [varchar](13) NULL,
	[HtlStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[HtlCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[MasterId] [int] NULL,
	[CO2Emissions] [float] NULL,
	[MilesFromAirport] [float] NULL,
	[GroundTransCO2] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Hotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Country]    Script Date: 7/7/2015 11:02:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Country](
	[CtryCode] [varchar](5) NOT NULL,
	[CtryName] [varchar](25) NULL,
	[IntlDomCode] [varchar](1) NULL,
	[ContinentCode] [varchar](2) NULL,
	[PhnCode] [varchar](4) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[TSLATEST] [datetime] NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CtryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Country] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CO2_SeatGuru]    Script Date: 7/7/2015 11:02:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CO2_SeatGuru](
	[ID] [float] NULL,
	[CarrierName] [varchar](100) NULL,
	[CR] [varchar](2) NULL,
	[Aircraft] [varchar](50) NULL,
	[EQCode] [varchar](5) NULL,
	[EQClass] [varchar](5) NULL,
	[First_pw] [float] NULL,
	[Business_pw] [float] NULL,
	[PremEcon_pw] [float] NULL,
	[Econ_pw] [float] NULL,
	[Cabin1] [decimal](3, 2) NULL,
	[Cabin2] [decimal](3, 2) NULL,
	[Cabin3] [decimal](3, 2) NULL,
	[Cabin4] [decimal](3, 2) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CO2_SeatGuru] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CO2_Emissions]    Script Date: 7/7/2015 11:02:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CO2_Emissions](
	[EquipClass] [varchar](10) NULL,
	[DistanceGroup] [int] NULL,
	[EquipCode] [varchar](3) NULL,
	[EquipName] [varchar](100) NULL,
	[NumOfPlanes] [float] NULL,
	[PoundsCO2PerMile] [float] NULL,
	[PoundPoints] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CO2_Emissions] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CO2_BurnBucket]    Script Date: 7/7/2015 11:02:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dba].[CO2_BurnBucket](
	[BucketNum] [float] NULL,
	[BurnLowValue] [float] NULL,
	[BurnUpperValue] [float] NULL
) ON [PRIMARY]

GO

ALTER AUTHORIZATION ON [dba].[CO2_BurnBucket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CO2_Airline_Cargo_Load]    Script Date: 7/7/2015 11:02:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CO2_Airline_Cargo_Load](
	[DEPARTURES_SCHEDULED] [float] NULL,
	[DEPARTURES_PERFORMED] [float] NULL,
	[PAYLOAD] [float] NULL,
	[SEATS] [float] NULL,
	[PASSENGERS] [float] NULL,
	[FREIGHT] [float] NULL,
	[MAIL] [float] NULL,
	[DISTANCE] [float] NULL,
	[RAMP_TO_RAMP] [float] NULL,
	[AIR_TIME] [float] NULL,
	[UNIQUE_CARRIER] [varchar](50) NULL,
	[AIRLINE_ID] [float] NULL,
	[UNIQUE_CARRIER_NAME] [varchar](255) NULL,
	[UNIQUE_CARRIER_ENTITY] [nvarchar](6) NULL,
	[REGION] [varchar](50) NULL,
	[CARRIER] [varchar](50) NULL,
	[CARRIER_NAME] [varchar](255) NULL,
	[CARRIER_GROUP] [float] NULL,
	[CARRIER_GROUP_NEW] [float] NULL,
	[ORIGIN_AIRPORT_ID] [float] NULL,
	[ORIGIN_AIRPORT_SEQ_ID] [float] NULL,
	[ORIGIN_CITY_MARKET_ID] [float] NULL,
	[ORIGIN] [varchar](100) NULL,
	[ORIGIN_CITY_NAME] [varchar](100) NULL,
	[ORIGIN_STATE_ABR] [varchar](50) NULL,
	[ORIGIN_STATE_FIPS] [float] NULL,
	[ORIGIN_STATE_NM] [varchar](50) NULL,
	[ORIGIN_COUNTRY] [varchar](100) NULL,
	[ORIGIN_COUNTRY_NAME] [nvarchar](100) NULL,
	[ORIGIN_WAC] [float] NULL,
	[DEST_AIRPORT_ID] [float] NULL,
	[DEST_AIRPORT_SEQ_ID] [float] NULL,
	[DEST_CITY_MARKET_ID] [float] NULL,
	[DEST] [varchar](50) NULL,
	[DEST_CITY_NAME] [varchar](100) NULL,
	[DEST_STATE_ABR] [nvarchar](50) NULL,
	[DEST_STATE_FIPS] [float] NULL,
	[DEST_STATE_NM] [varchar](50) NULL,
	[DEST_COUNTRY] [varchar](100) NULL,
	[DEST_COUNTRY_NAME] [varchar](100) NULL,
	[DEST_WAC] [float] NULL,
	[AIRCRAFT_GROUP] [float] NULL,
	[AIRCRAFT_TYPE] [float] NULL,
	[AIRCRAFT_CONFIG] [float] NULL,
	[YEAR] [float] NULL,
	[QUARTER] [float] NULL,
	[MONTH] [float] NULL,
	[DISTANCE_GROUP] [float] NULL,
	[CLASS] [varchar](50) NULL,
	[DATA_SOURCE] [nvarchar](50) NULL,
	[LoadFactor] [float] NULL,
	[CargoRatio] [float] NULL,
	[EquipCode] [varchar](20) NULL,
	[AvgLoadFactor] [float] NULL,
	[AvgCargoRatio] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CO2_Airline_Cargo_Load] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CO2_AircraftEquiv]    Script Date: 7/7/2015 11:02:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CO2_AircraftEquiv](
	[EquipmentCode] [varchar](50) NULL,
	[EquivalentCode] [varchar](50) NULL,
	[EquipmentClass] [varchar](5) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CO2_AircraftEquiv] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ClassToCabin]    Script Date: 7/7/2015 11:02:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ClassToCabin](
	[CarrierCode] [varchar](3) NOT NULL,
	[ClassOfService] [varchar](1) NOT NULL,
	[DomCabin] [varchar](20) NOT NULL,
	[InternationalInd] [varchar](1) NOT NULL,
	[NewRecord] [char](1) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_ClassToCabin] PRIMARY KEY CLUSTERED 
(
	[CarrierCode] ASC,
	[ClassOfService] ASC,
	[DomCabin] ASC,
	[InternationalInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[ClassToCabin] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[City]    Script Date: 7/7/2015 11:02:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[City](
	[CityCode] [varchar](10) NOT NULL,
	[TypeCode] [varchar](1) NOT NULL,
	[CityName] [varchar](30) NULL,
	[AirportName] [varchar](30) NULL,
	[RegionCode] [varchar](10) NULL,
	[RegionName] [varchar](30) NULL,
	[StateProvinceCode] [varchar](5) NULL,
	[CountryCode] [varchar](5) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[TimeZoneDiff] [float] NULL,
	[TSLATEST] [datetime] NULL,
 CONSTRAINT [PK_City_1] PRIMARY KEY NONCLUSTERED 
(
	[CityCode] ASC,
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[City] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Car]    Script Date: 7/7/2015 11:02:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Car](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[CarSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[CarType] [varchar](6) NULL,
	[CarChainCode] [varchar](6) NULL,
	[CarChainName] [varchar](20) NULL,
	[CarCityCode] [varchar](10) NULL,
	[CarCityName] [varchar](25) NULL,
	[InternationalInd] [varchar](1) NULL,
	[PickupDate] [datetime] NULL,
	[DropoffDate] [datetime] NULL,
	[CarDropoffCityCode] [varchar](10) NULL,
	[NumDays] [smallint] NULL,
	[NumCars] [smallint] NULL,
	[CarQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[CarDailyRate] [float] NULL,
	[TtlCarCost] [float] NULL,
	[CarRateCat] [varchar](10) NULL,
	[CarCompareRate1] [float] NULL,
	[CarReasonCode1] [varchar](6) NULL,
	[CarCompareRate2] [float] NULL,
	[CarReasonCode2] [varchar](6) NULL,
	[CarCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefCarInd] [varchar](1) NULL,
	[CarConfNum] [varchar](30) NULL,
	[FreqRenterProgram] [varchar](13) NULL,
	[CarStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[CarCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[CarDropOffCityName] [varchar](50) NULL,
	[CO2Emissions] [float] NULL,
 CONSTRAINT [PK_Car] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Car] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 11:02:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[OriginCityCode] [varchar](10) NULL,
	[SegmentCarrierCode] [varchar](3) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[CodeShareCarrierCode] [varchar](3) NULL,
	[EquipmentCode] [varchar](10) NULL,
	[PrefAirInd] [varchar](1) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[FlightNum] [varchar](15) NULL,
	[ClassOfService] [varchar](8) NULL,
	[FareBasis] [varchar](30) NULL,
	[TktDesignator] [varchar](15) NULL,
	[ConnectionInd] [varchar](1) NULL,
	[StopOverTime] [int] NULL,
	[FrequentFlyerNum] [varchar](15) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SEGDestCityCode] [varchar](10) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[SEGCO2Emissions] [float] NULL,
	[NOXCO2Emissions] [float] NULL,
	[MINCO2Emissions] [float] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[TtlSeats] [int] NULL,
	[YieldInd] [varchar](1) NULL,
	[YieldAmt] [float] NULL,
	[YieldDatePosted] [datetime] NULL,
	[SegTrueTktCount] [int] NULL
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

/****** Object:  View [dba].[TranSeg_VW]    Script Date: 7/7/2015 11:02:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dba].[TranSeg_VW]
WITH SCHEMABINDING 
AS
SELECT     RecordKey, IataNum, SeqNum, SegmentNum, TypeCode, ClientCode, InvoiceDate, IssueDate, OriginCityCode, SegmentCarrierCode, 
                      SegmentCarrierName, CodeShareCarrierCode, EquipmentCode, PrefAirInd, DepartureDate, DepartureTime, FlightNum, ClassOfService, FareBasis, 
                      TktDesignator, ConnectionInd, StopOverTime, FrequentFlyerNum, FrequentFlyerMileage, CurrCode, SEGDestCityCode, SEGInternationalInd, 
                      SEGArrivalDate, SEGArrivalTime, SEGSegmentValue, SEGSegmentMileage, SEGTotalMileage, SEGFlightTime, SEGMktOrigCityCode, 
                      SEGMktDestCityCode, SEGReturnInd, NOXDestCityCode, NOXInternationalInd, NOXArrivalDate, NOXArrivalTime, NOXSegmentValue, 
                      NOXSegmentMileage, NOXTotalMileage, NOXFlightTime, NOXMktOrigCityCode, NOXMktDestCityCode, NOXConnectionString, NOXReturnInd, 
                      MINDestCityCode, MINInternationalInd, MINArrivalDate, MINArrivalTime, MINSegmentValue, MINSegmentMileage, MINTotalMileage, MINFlightTime, 
                      MINMktOrigCityCode, MINMktDestCityCode, MINConnectionString, MINReturnInd, MealName, NOXSegmentCarrierCode, NOXSegmentCarrierName, 
                      NOXClassOfService, MINSegmentCarrierCode, MINSegmentCarrierName, MINClassOfService, NOXClassString, NOXFareBasisString, MINClassString, 
                      MINFareBasisString, NOXFlownMileage, MINFlownMileage, SEGCO2Emissions, NOXCO2Emissions, MINCO2Emissions, FSeats, BusSeats, 
                      EconSeats, TtlSeats, YieldInd, YieldAmt, YieldDatePosted
FROM         dba.TranSeg


GO

ALTER AUTHORIZATION ON [dba].[TranSeg_VW] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 11:02:41 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [LoadInnovataData_I1]    Script Date: 7/7/2015 11:02:42 PM ******/
CREATE CLUSTERED INDEX [LoadInnovataData_I1] ON [dba].[InnovataData]
(
	[Carrier] ASC,
	[FlightNum] ASC,
	[DepCity] ASC,
	[ArrCity] ASC,
	[BeginSched] ASC,
	[EndSched] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI1]    Script Date: 7/7/2015 11:02:43 PM ******/
CREATE CLUSTERED INDEX [HotelI1] ON [dba].[Hotel]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CO2_AirlineCargoLoadPX]    Script Date: 7/7/2015 11:02:43 PM ******/
CREATE CLUSTERED INDEX [CO2_AirlineCargoLoadPX] ON [dba].[CO2_Airline_Cargo_Load]
(
	[CARRIER] ASC,
	[ORIGIN] ASC,
	[DEST] ASC,
	[YEAR] ASC,
	[MONTH] ASC,
	[EquipCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CityI1]    Script Date: 7/7/2015 11:02:44 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CityI1] ON [dba].[City]
(
	[TypeCode] ASC,
	[CityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/7/2015 11:02:45 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [dba].[Car]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 11:02:45 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO

/****** Object:  Index [Transeg_VW_IX1]    Script Date: 7/7/2015 11:02:46 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Transeg_VW_IX1] ON [dba].[TranSeg_VW]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[OriginCityCode] ASC,
	[SEGDestCityCode] ASC,
	[SegmentCarrierCode] ASC,
	[FlightNum] ASC,
	[ClientCode] ASC,
	[DepartureDate] ASC,
	[ConnectionInd] ASC,
	[RecordKey] ASC,
	[SegmentNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/7/2015 11:02:48 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI3]    Script Date: 7/7/2015 11:02:48 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI3] ON [dba].[InvoiceDetail]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI5]    Script Date: 7/7/2015 11:02:49 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI5] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailPX]    Script Date: 7/7/2015 11:02:49 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetailPX] ON [dba].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 11:02:49 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CO2_Innovata_IDX_EndSched]    Script Date: 7/7/2015 11:02:50 PM ******/
CREATE NONCLUSTERED INDEX [CO2_Innovata_IDX_EndSched] ON [dba].[InnovataData]
(
	[EndSched] ASC
)
INCLUDE ( 	[Carrier],
	[FlightNum],
	[DepAirport],
	[ArrAirport],
	[BeginService],
	[EndService],
	[FSeats],
	[BusSeats],
	[EconSeats],
	[AirCraftType],
	[OpDayString]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CO2_Innovata_IDX_Flights]    Script Date: 7/7/2015 11:02:51 PM ******/
CREATE NONCLUSTERED INDEX [CO2_Innovata_IDX_Flights] ON [dba].[InnovataData]
(
	[FlightNum] ASC,
	[DepAirport] ASC,
	[ArrAirport] ASC,
	[EndSched] ASC,
	[BeginService] ASC,
	[EndService] ASC
)
INCLUDE ( 	[Carrier],
	[FSeats],
	[BusSeats],
	[EconSeats],
	[AirCraftType],
	[OpDayString]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/7/2015 11:02:52 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [dba].[Hotel]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelPX]    Script Date: 7/7/2015 11:02:52 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CO2_SeatGuru]    Script Date: 7/7/2015 11:02:52 PM ******/
CREATE NONCLUSTERED INDEX [CO2_SeatGuru] ON [dba].[CO2_SeatGuru]
(
	[CR] ASC,
	[EQCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CO2_EmissionsPX]    Script Date: 7/7/2015 11:02:52 PM ******/
CREATE NONCLUSTERED INDEX [CO2_EmissionsPX] ON [dba].[CO2_Emissions]
(
	[EquipClass] ASC,
	[DistanceGroup] ASC,
	[EquipCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CO2_BurnBucketPX]    Script Date: 7/7/2015 11:02:52 PM ******/
CREATE NONCLUSTERED INDEX [CO2_BurnBucketPX] ON [dba].[CO2_BurnBucket]
(
	[BucketNum] ASC,
	[BurnLowValue] ASC,
	[BurnUpperValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CO2_AircarftEquivPX]    Script Date: 7/7/2015 11:02:53 PM ******/
CREATE NONCLUSTERED INDEX [CO2_AircarftEquivPX] ON [dba].[CO2_AircraftEquiv]
(
	[EquipmentCode] ASC,
	[EquivalentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CarI2]    Script Date: 7/7/2015 11:02:53 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [dba].[Car]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI3]    Script Date: 7/7/2015 11:02:53 PM ******/
CREATE NONCLUSTERED INDEX [CarI3] ON [dba].[Car]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CarI6]    Script Date: 7/7/2015 11:02:53 PM ******/
CREATE NONCLUSTERED INDEX [CarI6] ON [dba].[Car]
(
	[PickupDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TranSegI4]    Script Date: 7/7/2015 11:02:53 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI4] ON [dba].[TranSeg]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI5]    Script Date: 7/7/2015 11:02:53 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI5] ON [dba].[TranSeg]
(
	[ClientCode] ASC,
	[IataNum] ASC,
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI6]    Script Date: 7/7/2015 11:02:54 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI6] ON [dba].[TranSeg]
(
	[OriginCityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/7/2015 11:02:54 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [dba].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TranSeg (dba)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 9
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'VIEW',@level1name=N'TranSeg_VW'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'VIEW',@level1name=N'TranSeg_VW'
GO

