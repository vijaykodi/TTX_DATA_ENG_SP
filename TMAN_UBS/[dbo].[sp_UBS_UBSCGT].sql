/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCGT]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSCGT]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSCGT'
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

-------Insert into Production Table ---------------------------------------------LOC/10/2/2012
--Insert Global Transfers Data--  UBSCGT
INSERT INTO DBA.CarTransportation
SELECT 'GLOBALTRANSFER',Date,TransactionDate,Invoice,Docket AS ConfirmationNumber,Passenger , 
GPIN, BookedBy, Date, PickupTime, PickUp, Destination,DropOffTime ,
Journeydescription, CostCentre_ProjectCode AS CostCenter , CostCentre_ProjectCode AS ProjectCode, CompanyName, 
VehicleType, JourneyCost, 0 AS Tolls, WaitingCost, Parking AS Parking , 0 AS MeetGreatCharges, Phone AS PhoneCharges , 
0 AS ServiceCharges, 0 AS AdditionalStops, 0 AS WaitingTimeMinutes, Gratuity,0 AS FuelSurcharge ,0 AS Package,
0 AS Events,0 AS NYCWorkmansComp, Other AS Extras, Admin, Discount, NetTotal, VAT, Total, 0 AS Mileage, 
0 AS CarbonEmissions,'GBP','GB',GPIN, getdate(), NULL,NULL
FROM DBA.globaltransfertemp

update dba.cartransportation
set gpn = 'Unknown' 
where gpn not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and source = 'GLOBALTRANSFER'



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Global Transfer Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()




Truncate table dba.globaltransfertemp

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
