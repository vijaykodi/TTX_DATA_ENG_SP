/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCCC]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSCCC]

 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime ,@BeginIssueDate datetime,@ENDIssueDate datetime

	SET @Iata = 'UBSCCC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @ENDIssueDate = Null 
    set @beginissuedate = NULL
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
SET @TransStart = getdate()

-------- Remove the British Pound Sign from the data ---- LOC/1/6/2014-----------------
update dba.comcabtemp
set waitcost = substring(waitcost,2,10) where substring(waitcost,1,1) not like '[0-9]'
update dba.comcabtemp
set cost=substring(cost,2,10) where substring(cost,1,1) not like '[0-9]'
update dba.comcabtemp
set gratuity=substring(gratuity,2,10) where substring(gratuity,1,1) not like '[0-9]'
update dba.comcabtemp
set administration=substring(administration,2,10) where substring(administration,1,1) not like '[0-9]'
update dba.comcabtemp
set prevattotal=substring(prevattotal,2,10) where substring(prevattotal,1,1) not like '[0-9]'
update dba.comcabtemp
set vat=substring(vat,2,10) where substring(vat,1,1) not like '[0-9]'
update dba.comcabtemp
set totaldue=substring(totaldue,2,10) where substring(totaldue,1,1) not like '[0-9]'
update dba.comcabtemp
set meteratpassengeronboard=substring(meteratpassengeronboard,2,10) where substring(meteratpassengeronboard,1,1) not like '[0-9]'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Remove British Pound',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cct
set GPIN = right('00000000'+GPIN,8)
from DBA.comcabtemp cct
where len(GPIN) <> 8 


-------Insert into Production Table ---------------------------------------------LOC/10/2/2012
SET @TransStart = getdate()
--Insert Com Cab Data-- UBSCCC
INSERT INTO DBA.CarTransportation
SELECT 'COMCAB',DateBooked,
--'2015-01-01',
DATEadd(MONTH,datediff(month,0,getdate())-1,0),
InvoiceNumber,NULL AS 
ConfirmationNumber,substring(PassengerFirstName + ' ' +
PassengerLastName,1,100) , GPIN, BookerName, ArrivedDate, ArrivedTime, 
PickUpAddress, DestinationAddress,EndOfJourneyTime ,clientnonclient, 
CostCentre AS CostCenter , JobRefNumber AS ProjectCode, Vendor, 
TypeOfVehicle, Cost, 0 AS Tolls, WaitCost, 0 AS Parking , 0 AS 
MeetGreatCharges, 0 AS PhoneCharges , 0 AS ServiceCharges, 0 AS 
AdditionalStops, 0 AS WaitingMinutes, Gratuity,0 AS FuelSurcharge ,0 AS Package,
0 AS Events,0 AS NYCWorkmansComp, 0 AS Extras, Administration, 0 AS Discount, 
PreVatTotal, VAT, TotalDue, Mileage AS Mileage, 0 AS CarbonEmissions , 'GBP','GB',GPIN, getdate(),
NULL, 'Credit Card'
FROM DBA.ComCabTemp

update dba.cartransportation
set gpn = 'Unknown' 
where isnull(gpn,'X') not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and source = 'COMCAB'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-Com Cab Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

Truncate table dba.COMCABTemp

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
