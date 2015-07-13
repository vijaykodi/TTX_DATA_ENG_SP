USE [TMAN503_ClientDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_ClientDB_CO2_MAIN]    Script Date: 05/21/2014 14:31:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[sp_ClientDB_CO2_MAIN]
--@IATANUM VARCHAR (50),
@BEGINISSUEDATEMAIN DATETIME,
@ENDISSUEDATEMAIN DATETIME
AS
declare @TransStart DATETIME 
declare @ProcName varchar(50)
declare @TSUpdateEndSched nvarchar(50)
declare @IATANUM VARCHAR (50)
--declare @BEGINISSUEDATEMAIN DATETIME
--declare @ENDISSUEDATEMAIN DATETIME


set @ProcName = 'sp_ClientDB_CO2_MAIN_DATA'--sql update from Brent
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



--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CO2 Stored Procedure Start',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

	SELECT DISTINCT EndSched, IDENTITY(int) AS [ID] 
	INTO #EndSchedList 
	FROM DATAFEEDS.dba.InnovataData
	--\\ss why --WHERE EndSched BETWEEN [start] AND [END] 
	ORDER BY EndSched desc

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Created EndSched List',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@iatanum=@iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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
and t1.segSegmentMileage is not null
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
and t1.segSegmentMileage is not null
and PATINDEX('%[^0-9^.]%', t1.flightnum)= 0
and t1.typecode = orig.typecode 
and t1.typecode = dest.typecode
--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

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


update dba.car
set CO2Emissions = (((20 / 23.9) * 8.87) / 1000) * (NumDays * NumCars)
where co2emissions is null
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


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
where id.recordkey = T1.recordkey
and id.iatanum = t1.iatanum
and id.seqnum = t1.seqnum
and id.clientcode = t1.clientcode
and id.issuedate = t1.issuedate
and id.refundind IN ('Y','P')
--and id.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

--update ID
--set ID.TKTCO2Emissions = (select sum(isnull(SegCO2Emissions,0)) 
--	from dba.Transeg_VW ts 
--	where ts.iatanum = id.iatanum and ts.recordkey = id.recordkey and ts.seqnum = id.seqnum and ts.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)
--from dba.invoicedetail ID
--where ((tktco2emissions is null)
--or (tktco2emissions = 0))
--and vendortype in ('BSP','BSPSTP','NONBSP','NONBSPSTP')
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process Refund segement data',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Process',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




