/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCOT]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSCOT]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSCOT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

--update dba.onetransport
--set date = case when period = '4' and date is null then '4/1/2011'
--when period = '5' and date is null then '5/1/2011'


--UPdate GPN in temp table if not sent full 8 characters - leading zeros left off

update ott
set GPIN = right('00000000'+GPIN,8)
from DBA.onetransporttemp ott
where len(GPIN) <> 8 

-------Insert into Production Table ---------------------------------------------LOC/10/2/2012
--removed 3rd field of transactiondate and replaced with calculation to set to priormonth based on import date
--case#25970 kp 12/17/2013
--Insert One Transport Data-- - UBSCOT
INSERT INTO DBA.CarTransportation
SELECT 'ONETRANSPORT',Date,
DATEadd(MONTH,datediff(month,0,getdate())-1,0),
--'2015-01-01',
Invoice,Docket AS 
ConfirmationNumber,Passenger , GPIN, BookedBy, Date, PickupTime, 
PickUp, Destination,DropOffTime ,JourneyClassification, 
CostCentre_ProjectCode AS CostCenter , CostCentre_ProjectCode AS 
ProjectCode, CompanyName, VehicleType, 
CAST(REPLACE(JourneyCost,'£','') AS FLOAT), 0 AS Tolls , 
CAST(REPLACE(WaitingCost,'£','') AS FLOAT) ,
CAST(REPLACE(Parking,'£','') AS FLOAT) AS Parking , 0 AS 
MeetGreatCharges, 0 AS PhoneCharges , 0 AS ServiceCharges, 0 AS 
AdditionalStops, CAST(WaitingTimeMinutes AS FLOAT) AS 
WaitingTimeMinutes , CAST(REPLACE(Gratuity,'£','') AS FLOAT) AS
Gratuity,0 AS FuelSurcharge ,0 AS Package,0 AS Events,0 AS 
NYCWorkmansComp , CAST(REPLACE(Other,'£','') AS FLOAT) AS Extras,
CAST(REPLACE(Admin,'£','') AS FLOAT) AS Administration, 0 AS Discount ,
CAST(REPLACE(NettTotal,'£','') AS FLOAT) AS NetCost,
CAST(REPLACE(VAT,'£','') AS FLOAT) AS VAT ,
CAST(REPLACE(TotalCost,'£','') AS FLOAT) AS TotalCost, 0 AS Mileage, 0 
AS CarbonEmissions, 'GBP','GB',GPIN,getdate(), NULL, 'CreditCard'
FROM DBA.onetransporttemp
where docket not in (select confirmationnbr from dba.cartransportation where source = 'onetransport')



update dba.cartransportation
set gpn = 'Unknown' 
where gpn not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and source = 'ONETRANSPORT'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-One Transport Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


Truncate table dba.ONETRANSPORTTemp

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
