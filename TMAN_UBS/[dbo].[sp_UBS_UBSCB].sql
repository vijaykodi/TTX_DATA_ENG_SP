/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCB]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSCB]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSCB'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 


 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

-------Insert into Production Table ---------------------------------------------LOC/10/2/2012
--Insert Brunel Data--  UBSCB
INSERT INTO DBA.CarTransportation
SELECT 'BRUNEL', Date, isnull(TransDate,Date) , Invoice , Docket 
, Passenger , GPIN, BookedBy , Date , PickupTime , PickUp , 
 Destination ,substring(DropOffTime,12,5) ,JourneyDescription, NULL AS CostCenter, NULL 
AS ProjectCode, Company, VehicleType, JourneyCost, 0 AS Tolls, 
WaitingCost , Parking , 0 AS MeetGreatCharges, Phone, 0 AS 
ServiceCharges, 0 AS AdditionalStops, WaitingMinutes, Grats, 0 AS 
FuelSurcharge  , 0 AS Package, 0 AS Events, 0 AS NYCWorkmansComp, 
Extras, Admin, Discount, Net, VAT, Total, 0 AS Mileage, 0 AS 
CarbonEmissions, 'GBP','GB',GPIN,getdate(),Null, 'CreditCard'
FROM DBA.BrunelTemp 

update dba.cartransportation
set gpn = 'Unknown' 
where gpn not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and source = 'BRUNEL'



-------- Invoice Date ---- Using Pickupdate when no Transaction date is in the file ---- 12/5/2012

--------Originally using this statement to get the date for the "Booking Date" however this field does not
--------always have a date and sometimes the date has the year 1900 so we will use the "Date" which is the 
--------pickup date for the booking date.
--CASE WHEN LEN(TimeBookingMade) < 9 THEN Date ELSE 
--TimeBookingMade END AS TimeBookingMade

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Brunel Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

--truncate statement for temp file is active as of 12.6.12
Truncate table dba.BrunelTemp

exec dbo.sp_UBS_CarMain

 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
