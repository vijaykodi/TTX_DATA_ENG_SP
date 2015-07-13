----*********************************************************************************
----CO2 EMISSION
----*********************************************************************************
USE [TMAN503_ClientDB] 

go 

/****** Object:  StoredProcedure [dbo].[sp_ClientDB_CO2_MAIN]    Script Date: 05/21/2014 14:31:26 ******/ 
SET ansi_nulls ON 

go 

SET quoted_identifier ON 

go 

CREATE PROCEDURE [dbo].[Sp_clientdb_co2_main] 
  --@IATANUM VARCHAR (50), 
  @BEGINISSUEDATEMAIN DATETIME, 
  @ENDISSUEDATEMAIN   DATETIME 
AS 
    DECLARE @TransStart DATETIME 
    DECLARE @ProcName VARCHAR(50) 
    DECLARE @TSUpdateEndSched NVARCHAR(50) 
    DECLARE @IATANUM VARCHAR (50) 

    --declare @BEGINISSUEDATEMAIN DATETIME 
    --declare @ENDISSUEDATEMAIN DATETIME 
    SET @ProcName = 'sp_ClientDB_CO2_MAIN_DATA'--sql update from Brent 
    SET @IATANUM = 'ALL' 
    --Reset the CO2 and YieldInd values before reprocessing 
    --update id 
    --set TktCO2Emissions = NULL 
    --from dba.InvoiceDetail id 
    --where TktCO2Emissions is not null 
    --  update t1 
    --  set 
    --  SEGCO2Emissions = NULL, 
    --  NOXCO2Emissions = NULL, 
    --  MINCO2Emissions = NULL, 
    --  FSeats = NULL, 
    --  BusSeats = NULL, 
    --  EconSeats = NULL, 
    --  TtlSeats = NULL, 
    --  YieldInd = NULL, 
    --  EquipmentCode = NULL 
    --  from dba.Transeg_VW t1 
    --  where issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
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
    --  @LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction 
    --  @StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
    --  @BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure 
    --  @EndDate datetime = NULL, -- **OPTIONAL**  The EndIssueDate that is pased to the Parent Procedure 
    --  @IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure 
    --  @RowCount int, -- **REQUIRED** Total number of affected rows 
    --  @ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero) 
    --Log Activity 
    SET @TransStart = Getdate() 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CO2 Stored Procedure Start', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    SELECT DISTINCT endsched, 
                    IDENTITY(int) AS [ID] 
    INTO   #endschedlist 
    FROM   datafeeds.dba.innovatadata 
    --\\ss why --WHERE EndSched BETWEEN [start] AND [END]  
    ORDER  BY endsched DESC 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='1-Created EndSched List', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @iatanum=@iatanum, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    DECLARE @RowCount     INT, 
            @ProcEndSched DATETIME, 
            @lcv          INT 

    SELECT @RowCount = Max([id]) 
    FROM   #endschedlist 

    SET @lcv = 1 
    SET @RowCount = @RowCount + 1 

    WHILE ( @lcv < @RowCount ) 
      BEGIN 
          SELECT @ProcEndSched = endsched 
          FROM   #endschedlist 
          WHERE  [id] = @lcv 

          SET @lcv = @lcv + 1 
          SET @TransStart = Getdate() 
          SET @TSUpdateEndSched = 'Processing for ' 
                                  + Cast(@ProcEndSched AS NVARCHAR(25)) 

          UPDATE t1 
          SET    t1.equipmentcode = t2.aircrafttype, 
                 t1.fseats = Isnull(t2.fseats, 0), 
                 t1.busseats = Isnull(t2.busseats, 0), 
                 t1.econseats = Isnull(t2.econseats, 0), 
                 t1.ttlseats = Isnull(t2.fseats, 0) + Isnull(t2.busseats, 0) 
                               + Isnull(t2.econseats, 0) 
          FROM   dba.transeg_vw t1, 
                 datafeeds.dba.innovatadata t2 
          WHERE  t1.departuredate BETWEEN t2.beginservice AND t2.endservice 
                 AND t2.endsched = @ProcEndSched 
                 --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
                 AND Cast(t1.flightnum AS INT) = t2.flightnum 
                 AND t1.segmentcarriercode = SUBSTRING(t2.carrier, 1, 2) 
                 AND t1.origincitycode = t2.depairport 
                 AND t1.segdestcitycode = t2.arrairport 
                 AND t1.equipmentcode IS NULL 
                 AND SEGCO2Emissions IS NULL 
                 AND Datepart(dw, t1.departuredate) = CASE 
                                                        WHEN 
                     Datepart(dw, t1.departuredate) = 1 
                                                      THEN 
                     SUBSTRING(opdaystring, 1, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 2 
                                                      THEN 
                     SUBSTRING(opdaystring, 2, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 3 
                                                      THEN 
                     SUBSTRING(opdaystring, 3, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 4 
                                                      THEN 
                     SUBSTRING(opdaystring, 4, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 5 
                                                      THEN 
                     SUBSTRING(opdaystring, 5, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 6 
                                                      THEN 
                     SUBSTRING(opdaystring, 6, 1) 
                     ELSE 
                     SUBSTRING(opdaystring, 7, 1) 
                                                      END 
                 AND Replace(t1.flightnum, ',', '') NOT LIKE '%[^0-9]%' 

          EXEC dbo.Sp_logprocerrors 
            @ProcedureName=@ProcName, 
            @LogStart=@TransStart, 
            @StepName=@TSUpdateEndSched, 
            @BeginDate=@BEGINISSUEDATEMAIN, 
            @EndDate=@ENDISSUEDATEMAIN, 
            @IataNum=@IATANUM, 
            @RowCount=@@ROWCOUNT, 
            @ERR=@@ERROR 
      END 

    ----Update Burn Bucket 125 or Less 
    ----Update Domestic US Travel by 1.07-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
    END ) / ( 
    ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
    WHEN t4.loadfactor = 0 THEN 1 
    ELSE Isnull(t4.loadfactor, 1) 
    END 
      WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                      Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                    Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                    Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                  Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND orig.countrycode = 'US' 
       AND dest.countrycode = 'US' 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 US DOM x 1.07', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update Burn Bucket 125 or Less 
    --Update Intra Europe Flights by 1.10-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
CASE 
             WHEN t5.domcabin = 'First' THEN 
             ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
             Isnull(t7.cabin1, 1.8) ) / CASE 
  WHEN t4.loadfactor = 0 THEN 1 
  ELSE Isnull(t4.loadfactor, 1) 
  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
      Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
     WHEN t4.loadfactor = 0 THEN 1 
     ELSE Isnull(t4.loadfactor, 1) 
     END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest, 
       dba.country OCtry, 
       dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND Octry.continentcode = 'EU' 
       AND DCtry.continentcode = 'EU' 
       AND orig.countrycode = Octry.ctrycode 
       AND dest.countrycode = DCtry.ctrycode 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 Intra EU x 1.10', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----Update Burn Bucket 125 or Less 
    ----Update All other Dometic flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
CASE 
             WHEN t5.domcabin = 'First' THEN 
           ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
          Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                             WHEN t4.loadfactor = 0 THEN 1 
                             ELSE Isnull(t4.loadfactor, 1) 
                           END 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( 
Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest, 
       dba.country OCtry, 
       dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(( t1.segsegmentmileage ) / 1.150779) <= 125 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                   Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                 Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) ) > 0 
       AND orig.countrycode = Octry.ctrycode 
       AND dest.countrycode = DCtry.ctrycode 
       AND orig.countrycode = dest.countrycode 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <= 125 DOM x 1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----Update Burn Bucket 125 or Less 
    ----Update All other Short Haul flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
CASE 
             WHEN t5.domcabin = 'First' THEN 
           ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
          Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                             WHEN t4.loadfactor = 0 THEN 1 
                             ELSE Isnull(t4.loadfactor, 1) 
                           END 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( 
Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest, 
       dba.country OCtry, 
       dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND orig.countrycode = Octry.ctrycode 
       AND dest.countrycode = DCtry.ctrycode 
       AND orig.countrycode <> dest.countrycode 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 short haul x 1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----Update All other Burn Buckets-- 
    ----Update Domestic US Travel by 1.07-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND orig.countrycode = 'US' 
           AND dest.countrycode = 'US' 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket > 125 US x 1.07', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update Intra Europe Flights by 1.10-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country Octry, 
           dba.country DCtry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND Octry.continentcode = 'EU' 
           AND DCtry.continentcode = 'EU' 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket >125 Intra Europe x 1.10', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Dometic flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
                 WHEN t4.loadfactor = 0 THEN 1 
                 ELSE Isnull(t4.loadfactor, 1) 
               END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.equipcode = eq.equivalentcode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket >125 Dom x 1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets -- 
    --Update All other Short Haul flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
                 WHEN t4.loadfactor = 0 THEN 1 
                 ELSE Isnull(t4.loadfactor, 1) 
               END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.equipcode = eq.equivalentcode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 <= 2000 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket >125 Short Haul x1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '2000' AND '3000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.07 btw 2000-3000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets -- 
    --Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '3000' AND '4000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.06 btw 3000-4000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '4000' AND '5000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.05 btw 4000-5000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '5000' AND '6000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.04 btw 5000-6000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '6000' AND '7000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.03 btw 6000-7000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '7000' AND '8000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haulx1.02 btw 7000-8000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.01 Distance greter than 8000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 > '8000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haulx1.01 >8000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --New code inserted by Brent Majors 12/29/2011 to use market averages where we dont get an exact hit-- 
    ----Update Burn Bucket 125 or Less 
    ----Update Domestic US Travel by 1.07-- 
    --Use Market Averages 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
    ( 
    ( t2.poundsco2permile * ( 
      Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
    ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
    ( 
    Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
    Isnull(t1.econseats, 0) * 
    Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
      WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                                             Isnull(t1.econseats, 0) * 
                                             Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                                             Isnull(t1.econseats, 0) * 
                                             Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND orig.countrycode = 'US' 
       AND dest.countrycode = 'US' 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 US DOM x 1.07 Mkt Avg', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update Burn Bucket 125 or Less 
    --Update Intra Europe Flights by 1.10-- 
    --Use Market Averages-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
           CASE 
             WHEN t5.domcabin = 'First' THEN 
( 
( t2.poundsco2permile * ( 
  Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * 
Isnull(t7.cabin2, 2.00) ) + ( 
                            Isnull(t1.econseats, 0) * 
                            Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
                            Isnull(t1.busseats, 0) * 
                            Isnull(t7.cabin2, 2.00) ) + ( 
                          Isnull(t1.econseats, 0) * 
                          Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
                            Isnull(t1.busseats, 0) * 
                            Isnull(t7.cabin2, 2.00) ) + ( 
                          Isnull(t1.econseats, 0) * 
                          Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket <=125 Intra EU x 1.10 Mkt Avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Dometic flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(( t1.segsegmentmileage ) / 1.150779) <= 125 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
      Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) ) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket <= 125 DOM x 1.085 Mkt Avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Short Haul flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket <=125 short haul x 1.085 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update All other Burn Buckets-- 
----Update Domestic US Travel by 1.07-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND orig.countrycode = 'US' 
AND dest.countrycode = 'US' 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket > 125 US x 1.07 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update Intra Europe Flights by 1.10-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country Octry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket >125 Intra Europe x 1.10 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Dometic flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
 t3low.burnuppervalue ) * ( 
 t2.poundsco2permile - 
 t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket >125 Dom x 1.085 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Short Haul flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
 t3low.burnuppervalue ) * ( 
 t2.poundsco2permile - 
 t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 <= 2000 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket >125 Short Haul x1.085 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '2000' AND '3000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.07 btw 2000-3000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '3000' AND '4000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.06 btw 3000-4000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '4000' AND '5000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.05 btw 4000-5000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '5000' AND '6000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.04 btw 5000-6000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '6000' AND '7000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.03 btw 6000-7000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '7000' AND '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haulx1.02 btw 7000-8000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.01 Distance greter than 8000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 > '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haulx1.01 >8000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--New Updates inserted by Brent Majors Dec 23 2011 for default load facotrs and cargo ratios 
----Update Burn Bucket 125 or Less-- 
----Update Domestic US Travel by 1.07-- 
----Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( ( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END 
) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * 
Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * 
Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin1, 1.8) ) / CASE 
WHEN T1.segmentcarriercode IN ( 'AA', 'US', 'AS', 'AQ', 
'CO', 'DL', 'NW', 'UA', 
'2F', '3M', '4E', '4W', 
'5F', '8v', '9K', 'B6', 
'FL', 'GQ', 'H6', 'HA', 
'HP', 'J6', 'KS', 'NK', 
'PA', 'Q5', 'SY', 'U5', 
'VQ', 'VX', 'WN', 'YI', 
'YX', 'ZQ', '2E', '2Q', 
'3A', '3F', '3Z', '7N', 
'7S', '8E', '9S', 'BK', 
'QX', 'CH', 'DQ', 'EJ', 
'HX', 'IS', 'JW', 'K3', 
'K4', 'K5', 'LW', 'M5', 
'M6', 'UH', 'WP', 'YR', 
'YV', 'Z3', 'ZK', '00', 
'XE', 'NA', '2O', '9L', 
'EV', 'G7', 'J5', 'MQ', 
'OH', 'OO', 'RP', 'RW', 
'S6', 'XJ', 'ZW', 'D1', 
'CP', 'S5', 'AX', 'C5', 
'6P', 'LL', '1X', 'GV', 
'K9', 'L3', 'N8', 'RD', 
'XP', 'Y0', 'V2', 'TJ' ) THEN 
.7593 
ELSE .6735 
END 
WHEN t5.domcabin = 'Business' THEN 
( ( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN T1.segmentcarriercode IN ( 
'AA', 'US', 'AS', 'AQ', 
'CO', 'DL', 'NW', 'UA', 
'2F', '3M', '4E', '4W', 
'5F', '8v', '9K', 'B6', 
'FL', 'GQ', 'H6', 'HA', 
'HP', 'J6', 'KS', 'NK', 
'PA', 'Q5', 'SY', 'U5', 
'VQ', 'VX', 'WN', 'YI', 
'YX', 'ZQ', '2E', '2Q', 
'3A', '3F', '3Z', '7N', 
'7S', '8E', '9S', 'BK', 
'QX', 'CH', 'DQ', 'EJ', 
'HX', 'IS', 'JW', 'K3', 
'K4', 'K5', 'LW', 'M5', 
'M6', 'UH', 'WP', 'YR', 
'YV', 'Z3', 'ZK', '00', 
'XE', 'NA', '2O', '9L', 
'EV', 'G7', 'J5', 'MQ', 
'OH', 'OO', 'RP', 'RW', 
'S6', 'XJ', 'ZW', 'D1', 
'CP', 'S5', 'AX', 'C5', 
'6P', 'LL', '1X', 'GV', 
'K9', 'L3', 'N8', 'RD', 
'XP', 'Y0', 'V2', 'TJ' ) THEN .7593 
ELSE .6735 
END 
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
WHEN T1.segmentcarriercode IN ( 'AA', 'US', 'AS', 'AQ', 
'CO', 'DL', 'NW', 'UA', 
'2F', '3M', '4E', '4W', 
'5F', '8v', '9K', 'B6', 
'FL', 'GQ', 'H6', 'HA', 
'HP', 'J6', 'KS', 'NK', 
'PA', 'Q5', 'SY', 'U5', 
'VQ', 'VX', 'WN', 'YI', 
'YX', 'ZQ', '2E', '2Q', 
'3A', '3F', '3Z', '7N', 
'7S', '8E', '9S', 'BK', 
'QX', 'CH', 'DQ', 'EJ', 
'HX', 'IS', 'JW', 'K3', 
'K4', 'K5', 'LW', 'M5', 
'M6', 'UH', 'WP', 'YR', 
'YV', 'Z3', 'ZK', '00', 
'XE', 'NA', '2O', '9L', 
'EV', 'G7', 'J5', 'MQ', 
'OH', 'OO', 'RP', 'RW', 
'S6', 'XJ', 'ZW', 'D1', 
'CP', 'S5', 'AX', 'C5', 
'6P', 'LL', '1X', 'GV', 
'K9', 'L3', 'N8', 'RD', 
'XP', 'Y0', 'V2', 'TJ' ) THEN .7593 
ELSE .6735 
END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = 'US' 
AND dest.countrycode = 'US' 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <=125 US DOM x 1.07 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update Burn Bucket 125 or Less 
--Update Intra Europe Flights by 1.10-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN ( ( 
  t2.poundsco2permile * ( 
  Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * 
            CASE 
              WHEN t2.equipclass = 'W' THEN .801 
              WHEN t2.equipclass = 'J' THEN .983 
              ELSE 1 
END 
) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                       Isnull(t7.cabin1, 1.8) ) / 
                       CASE 
                         WHEN T1.segmentcarriercode IN ( 
                              'AA', 'US', 'AS', 'AQ', 
                              'CO', 'DL', 'NW', 'UA', 
                              '2F', '3M', '4E', '4W', 
                              '5F', '8v', '9K', 'B6', 
                              'FL', 'GQ', 'H6', 'HA', 
                              'HP', 'J6', 'KS', 'NK', 
                              'PA', 'Q5', 'SY', 'U5', 
                              'VQ', 'VX', 'WN', 'YI', 
                              'YX', 'ZQ', '2E', '2Q', 
                              '3A', '3F', '3Z', '7N', 
                              '7S', '8E', '9S', 'BK', 
                              'QX', 'CH', 'DQ', 'EJ', 
                              'HX', 'IS', 'JW', 'K3', 
                              'K4', 'K5', 'LW', 'M5', 
                              'M6', 'UH', 'WP', 'YR', 
                              'YV', 'Z3', 'ZK', '00', 
                              'XE', 'NA', '2O', '9L', 
                              'EV', 'G7', 'J5', 'MQ', 
                              'OH', 'OO', 'RP', 'RW', 
                              'S6', 'XJ', 'ZW', 'D1', 
                              'CP', 'S5', 'AX', 'C5', 
                              '6P', 'LL', '1X', 'GV', 
                              'K9', 'L3', 'N8', 'RD', 
                              'XP', 'Y0', 'V2', 'TJ' ) THEN 
                         .7593 
                         ELSE .6735 
                       END 
WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN T1.segmentcarriercode IN ( 'AA', 'US', 'AS', 'AQ', 
                     'CO', 'DL', 'NW', 'UA', 
                     '2F', '3M', '4E', '4W', 
                     '5F', '8v', '9K', 'B6', 
                     'FL', 'GQ', 'H6', 'HA', 
                     'HP', 'J6', 'KS', 'NK', 
                     'PA', 'Q5', 'SY', 'U5', 
                     'VQ', 'VX', 'WN', 'YI', 
                     'YX', 'ZQ', '2E', '2Q', 
                     '3A', '3F', '3Z', '7N', 
                     '7S', '8E', '9S', 'BK', 
                     'QX', 'CH', 'DQ', 'EJ', 
                     'HX', 'IS', 'JW', 'K3', 
                     'K4', 'K5', 'LW', 'M5', 
                     'M6', 'UH', 'WP', 'YR', 
                     'YV', 'Z3', 'ZK', '00', 
                     'XE', 'NA', '2O', '9L', 
                     'EV', 'G7', 'J5', 'MQ', 
                     'OH', 'OO', 'RP', 'RW', 
                     'S6', 'XJ', 'ZW', 'D1', 
                     'CP', 'S5', 'AX', 'C5', 
                     '6P', 'LL', '1X', 'GV', 
                     'K9', 'L3', 'N8', 'RD', 
                     'XP', 'Y0', 'V2', 'TJ' ) THEN .7593 
ELSE .6735 
END 
ELSE ( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END 
) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
    Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
 Isnull(t7.cabin4, 1) ) / CASE 
                            WHEN T1.segmentcarriercode IN ( 
                                 'AA', 'US', 'AS', 'AQ', 
                                 'CO', 'DL', 'NW', 'UA', 
                                 '2F', '3M', '4E', '4W', 
                                 '5F', '8v', '9K', 'B6', 
                                 'FL', 'GQ', 'H6', 'HA', 
                                 'HP', 'J6', 'KS', 'NK', 
                                 'PA', 'Q5', 'SY', 'U5', 
                                 'VQ', 'VX', 'WN', 'YI', 
                                 'YX', 'ZQ', '2E', '2Q', 
                                 '3A', '3F', '3Z', '7N', 
                                 '7S', '8E', '9S', 'BK', 
                                 'QX', 'CH', 'DQ', 'EJ', 
                                 'HX', 'IS', 'JW', 'K3', 
                                 'K4', 'K5', 'LW', 'M5', 
                                 'M6', 'UH', 'WP', 'YR', 
                                 'YV', 'Z3', 'ZK', '00', 
                                 'XE', 'NA', '2O', '9L', 
                                 'EV', 'G7', 'J5', 'MQ', 
                                 'OH', 'OO', 'RP', 'RW', 
                                 'S6', 'XJ', 'ZW', 'D1', 
                                 'CP', 'S5', 'AX', 'C5', 
                                 '6P', 'LL', '1X', 'GV', 
                                 'K9', 'L3', 'N8', 'RD', 
                                 'XP', 'Y0', 'V2', 'TJ' ) THEN 
                            .7593 
                            ELSE .6735 
                          END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <=125 Intra EU x 1.10 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Dometic flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( ( t2.poundsco2permile * ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
    WHEN t2.equipclass = 'W' THEN .801 
    WHEN t2.equipclass = 'J' THEN .983 
    ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( ( t2.poundsco2permile * 
    ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                 CASE 
  WHEN t2.equipclass = 'W' THEN .801 
  WHEN t2.equipclass = 'J' THEN .983 
  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( t2.poundsco2permile * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                CASE 
                  WHEN t2.equipclass = 'W' THEN .801 
                  WHEN t2.equipclass = 'J' THEN .983 
                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
              WHEN T1.segmentcarriercode IN ( 
                   'AA', 'US', 'AS', 'AQ', 
                   'CO', 'DL', 'NW', 'UA', 
                   '2F', '3M', '4E', '4W', 
                   '5F', '8v', '9K', 'B6', 
                   'FL', 'GQ', 'H6', 'HA', 
                   'HP', 'J6', 'KS', 'NK', 
                   'PA', 'Q5', 'SY', 'U5', 
                   'VQ', 'VX', 'WN', 'YI', 
                   'YX', 'ZQ', '2E', '2Q', 
                   '3A', '3F', '3Z', '7N', 
                   '7S', '8E', '9S', 'BK', 
                   'QX', 'CH', 'DQ', 'EJ', 
                   'HX', 'IS', 'JW', 'K3', 
                   'K4', 'K5', 'LW', 'M5', 
                   'M6', 'UH', 'WP', 'YR', 
                   'YV', 'Z3', 'ZK', '00', 
                   'XE', 'NA', '2O', '9L', 
                   'EV', 'G7', 'J5', 'MQ', 
                   'OH', 'OO', 'RP', 'RW', 
                   'S6', 'XJ', 'ZW', 'D1', 
                   'CP', 'S5', 'AX', 'C5', 
                   '6P', 'LL', '1X', 'GV', 
                   'K9', 'L3', 'N8', 'RD', 
                   'XP', 'Y0', 'V2', 'TJ' ) 
            THEN 
              .7593 
              ELSE .6735 
            END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(( t1.segsegmentmileage ) / 1.150779) <= 125 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) ) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <= 125 DOM x 1.085 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Short Haul flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( ( t2.poundsco2permile * ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
    WHEN t2.equipclass = 'W' THEN .801 
    WHEN t2.equipclass = 'J' THEN .983 
    ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( ( t2.poundsco2permile * 
    ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                 CASE 
  WHEN t2.equipclass = 'W' THEN .801 
  WHEN t2.equipclass = 'J' THEN .983 
  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( t2.poundsco2permile * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                CASE 
                  WHEN t2.equipclass = 'W' THEN .801 
                  WHEN t2.equipclass = 'J' THEN .983 
                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
              WHEN T1.segmentcarriercode IN ( 
                   'AA', 'US', 'AS', 'AQ', 
                   'CO', 'DL', 'NW', 'UA', 
                   '2F', '3M', '4E', '4W', 
                   '5F', '8v', '9K', 'B6', 
                   'FL', 'GQ', 'H6', 'HA', 
                   'HP', 'J6', 'KS', 'NK', 
                   'PA', 'Q5', 'SY', 'U5', 
                   'VQ', 'VX', 'WN', 'YI', 
                   'YX', 'ZQ', '2E', '2Q', 
                   '3A', '3F', '3Z', '7N', 
                   '7S', '8E', '9S', 'BK', 
                   'QX', 'CH', 'DQ', 'EJ', 
                   'HX', 'IS', 'JW', 'K3', 
                   'K4', 'K5', 'LW', 'M5', 
                   'M6', 'UH', 'WP', 'YR', 
                   'YV', 'Z3', 'ZK', '00', 
                   'XE', 'NA', '2O', '9L', 
                   'EV', 'G7', 'J5', 'MQ', 
                   'OH', 'OO', 'RP', 'RW', 
                   'S6', 'XJ', 'ZW', 'D1', 
                   'CP', 'S5', 'AX', 'C5', 
                   '6P', 'LL', '1X', 'GV', 
                   'K9', 'L3', 'N8', 'RD', 
                   'XP', 'Y0', 'V2', 'TJ' ) 
            THEN 
              .7593 
              ELSE .6735 
            END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <=125 short haul x 1.085 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update All other Burn Buckets-- 
----Update Domestic US Travel by 1.07-- 
----Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND orig.countrycode = 'US' 
AND dest.countrycode = 'US' 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket > 125 US x 1.07 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update Intra Europe Flights by 1.10-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country Octry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket >125 Intra Europe x 1.10 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Dometic flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
      WHEN T1.segmentcarriercode IN ( 
           'AA', 'US', 'AS', 'AQ', 
           'CO', 'DL', 'NW', 'UA', 
           '2F', '3M', '4E', '4W', 
           '5F', '8v', '9K', 'B6', 
           'FL', 'GQ', 'H6', 'HA', 
           'HP', 'J6', 'KS', 'NK', 
           'PA', 'Q5', 'SY', 'U5', 
           'VQ', 'VX', 'WN', 'YI', 
           'YX', 'ZQ', '2E', '2Q', 
           '3A', '3F', '3Z', '7N', 
           '7S', '8E', '9S', 'BK', 
           'QX', 'CH', 'DQ', 'EJ', 
           'HX', 'IS', 'JW', 'K3', 
           'K4', 'K5', 'LW', 'M5', 
           'M6', 'UH', 'WP', 'YR', 
           'YV', 'Z3', 'ZK', '00', 
           'XE', 'NA', '2O', '9L', 
           'EV', 'G7', 'J5', 'MQ', 
           'OH', 'OO', 'RP', 'RW', 
           'S6', 'XJ', 'ZW', 'D1', 
           'CP', 'S5', 'AX', 'C5', 
           '6P', 'LL', '1X', 'GV', 
           'K9', 'L3', 'N8', 'RD', 
           'XP', 'Y0', 'V2', 'TJ' ) 
    THEN 
      .7593 
      ELSE .6735 
    END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket >125 Dom x 1.085 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Short Haul flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
      WHEN T1.segmentcarriercode IN ( 
           'AA', 'US', 'AS', 'AQ', 
           'CO', 'DL', 'NW', 'UA', 
           '2F', '3M', '4E', '4W', 
           '5F', '8v', '9K', 'B6', 
           'FL', 'GQ', 'H6', 'HA', 
           'HP', 'J6', 'KS', 'NK', 
           'PA', 'Q5', 'SY', 'U5', 
           'VQ', 'VX', 'WN', 'YI', 
           'YX', 'ZQ', '2E', '2Q', 
           '3A', '3F', '3Z', '7N', 
           '7S', '8E', '9S', 'BK', 
           'QX', 'CH', 'DQ', 'EJ', 
           'HX', 'IS', 'JW', 'K3', 
           'K4', 'K5', 'LW', 'M5', 
           'M6', 'UH', 'WP', 'YR', 
           'YV', 'Z3', 'ZK', '00', 
           'XE', 'NA', '2O', '9L', 
           'EV', 'G7', 'J5', 'MQ', 
           'OH', 'OO', 'RP', 'RW', 
           'S6', 'XJ', 'ZW', 'D1', 
           'CP', 'S5', 'AX', 'C5', 
           '6P', 'LL', '1X', 'GV', 
           'K9', 'L3', 'N8', 'RD', 
           'XP', 'Y0', 'V2', 'TJ' ) 
    THEN 
      .7593 
      ELSE .6735 
    END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 <= 2000 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket >125 Short Haul x1.085 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '2000' AND '3000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.07 btw 2000-3000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '3000' AND '4000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.06 btw 3000-4000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '4000' AND '5000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.05 btw 4000-5000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '5000' AND '6000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.04 btw 5000-6000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '6000' AND '7000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.03 btw 6000-7000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '7000' AND '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.02 btw 7000-8000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.01 Distance greter than 8000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 > '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.01 >8000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Step down logic for matching CO2-- 
SET @TransStart = Getdate() 

UPDATE t2 
SET    t2.segco2emissions = t1.segco2emissions, 
YieldInd = 'F' 
---match on everything --this is where we didn't get a match using the sechedule data...now using same flight details previously updated.  Need to update sql to find most recent record for same flight
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2 
WHERE  t1.segco2emissions > 0 
AND (( t2.segco2emissions IS NULL 
        OR t2.segco2emissions = 0 )) 
AND t1.flightnum = t2.flightnum 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND t1.segmentcarriercode = t2.segmentcarriercode 
AND Isnull(t1.equipmentcode, 'ZZ') = Isnull(t2.equipmentcode, 'ZZ') 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=F-match on everything', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE t2 
SET    t2.segco2emissions = t1.segco2emissions, 
YieldInd = 'A' 
-- matched on everything but flight number is different 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2 
WHERE  t1.segco2emissions > 0 
AND (( t2.segco2emissions IS NULL 
        OR t2.segco2emissions = 0 )) 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND t1.segmentcarriercode = t2.segmentcarriercode 
AND Isnull(t1.equipmentcode, 'ZZ') = Isnull(t2.equipmentcode, 'ZZ') 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=A-match on everything but flight', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE t2 
SET    t2.segco2emissions = t1.segco2emissions, 
YieldInd = 'E' -- Match on equipment only 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2 
WHERE  t1.segco2emissions > 0 
AND (( t2.segco2emissions IS NULL 
        OR t2.segco2emissions = 0 )) 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND Isnull(t1.equipmentcode, 'ZZ') = Isnull(t2.equipmentcode, 'ZZ') 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=E-match on equipment only', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.transeg_vw 
SET    segco2emissions = CASE 
                    WHEN Abs(segsegmentmileage) BETWEEN 0 AND 500 
                  THEN 
                    segsegmentmileage * 0.52 
                    ELSE segsegmentmileage * 0.40 
                  END, 
yieldind = 'D' 
--match where nothing matches - using default values .audit trail on why not found 
WHERE  (( segco2emissions IS NULL 
    OR segco2emissions = 0 )) 
AND segsegmentmileage IS NOT NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=D-match on nothing', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.transeg_vw 
SET    yieldind = 'N' 
--No match at all which shouldn't happen .audit trail on why not found 
WHERE  segsegmentmileage IS NULL 
AND yieldind IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=N-no match at all', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.transeg_vw 
SET    yieldind = 'Z' 
--No match on yield and equipcode...audit trail on why not found 
WHERE  segsegmentmileage IS NULL 
AND yieldind IS NULL 
AND equipmentcode IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=Z-no match on yield and equipment', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.hotel 
SET    co2emissions = ( numnights * numrooms ) * 33.38 
WHERE  co2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.car 
SET    co2emissions = ( ( ( 20 / 23.9 ) * 8.87 ) / 1000 ) * ( 
               numdays * numcars ) 
WHERE  co2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.transeg_vw 
SET    equipmentcode = 'TRN' 
WHERE  segmentcarriercode IN ( '2R', '2V', '9B', '9F' ) 
--need to insure that all TRAINS are covered... 
AND equipmentcode IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.transeg_vw 
SET    segco2emissions = CASE 
                    WHEN segsegmentmileage <= 20 THEN 
                    ( .35 * segsegmentmileage ) * 1.10 
                    ELSE ( .42 * segsegmentmileage ) * 1.10 
                  END, 
yieldind = 'T' 
WHERE  equipmentcode = 'TRN' 
AND segco2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.transeg_vw --check...where does equipmentcode is set 'BUS' 
SET    segco2emissions = CASE 
                    WHEN segsegmentmileage <= 20 THEN 
                    ( .66 * segsegmentmileage ) * 1.10 
                    ELSE ( .18 * segsegmentmileage ) * 1.10 
                  END, 
yieldind = 'B' 
WHERE  equipmentcode = 'BUS' 
AND segco2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process Refunds',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--Update Partial Refunds-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    t1.segco2emissions = ( t2.segco2emissions *- 1 ) 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2, 
dba.invoicedetail i1, 
dba.invoicedetail i2 
WHERE  t1.recordkey = i1.recordkey 
AND t1.seqnum = i1.seqnum 
AND t1.iatanum = i1.iatanum 
AND t2.recordkey = i2.recordkey 
AND t2.seqnum = i2.seqnum 
AND t2.iatanum = i2.iatanum 
AND t1.segsegmentvalue = t2.segsegmentvalue 
AND i1.refundind = 'P' 
AND i2.refundind = 'N' 
AND i1.documentnumber = i2.documentnumber 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND t1.recordkey <> t2.recordkey 
AND i1.documentnumber <> '9999999999' 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Process partial refunds', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update Full refunds -- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    t1.segco2emissions = ( t2.segco2emissions *- 1 ) 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2, 
dba.invoicedetail i1, 
dba.invoicedetail i2 
WHERE  t1.recordkey = i1.recordkey 
AND t1.seqnum = i1.seqnum 
AND t1.iatanum = i1.iatanum 
AND t2.recordkey = i2.recordkey 
AND t2.seqnum = i2.seqnum 
AND t2.iatanum = i2.iatanum 
AND t1.segmentnum = t2.segmentnum 
AND i1.refundind = 'Y' 
AND i2.refundind = 'N' 
AND i1.documentnumber = i2.documentnumber 
AND t1.recordkey <> t2.recordkey 
AND i1.documentnumber <> '9999999999' 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Process Full Refunds', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--New Refund Updates from Brent 11NOV2011 
SET @TransStart = Getdate() 

UPDATE T1 
SET    segsegmentmileage = Abs(segsegmentmileage) *- 1, 
segtotalmileage = Abs(segtotalmileage) *- 1, 
noxsegmentmileage = Abs(noxsegmentmileage) *- 1, 
noxtotalmileage = Abs(noxtotalmileage) *- 1, 
minsegmentmileage = Abs(minsegmentmileage) *- 1, 
mintotalmileage = Abs(mintotalmileage) *- 1, 
noxflownmileage = Abs(noxflownmileage) *- 1, 
minflownmileage = Abs(minflownmileage) *- 1, 
segco2emissions = Abs(segco2emissions) *- 1, 
noxco2emissions = Abs(noxco2emissions) *- 1, 
minco2emissions = Abs(minco2emissions) *- 1 
FROM   dba.transeg_vw T1, 
dba.invoicedetail ID 
WHERE  id.recordkey = T1.recordkey 
AND id.iatanum = t1.iatanum 
AND id.seqnum = t1.seqnum 
AND id.clientcode = t1.clientcode 
AND id.issuedate = t1.issuedate 
AND id.refundind IN ( 'Y', 'P' ) 

--and id.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
--update ID 
--set ID.TKTCO2Emissions = (select sum(isnull(SegCO2Emissions,0))  
--  from dba.Transeg_VW ts  
--  where ts.iatanum = id.iatanum and ts.recordkey = id.recordkey and ts.seqnum = id.seqnum and ts.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)
--from dba.invoicedetail ID 
--where ((tktco2emissions is null) 
--or (tktco2emissions = 0)) 
--and vendortype in ('BSP','BSPSTP','NONBSP','NONBSPSTP') 
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Process Refund segement data', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='End Process', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

---**********************************************************************************************
---END OF CO2 EMISSION UPDATES
--***********************************************************************************************
