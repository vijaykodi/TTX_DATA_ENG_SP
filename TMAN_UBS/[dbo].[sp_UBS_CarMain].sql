/****** Object:  StoredProcedure [dbo].[sp_UBS_CarMain]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_CarMain]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime


	SET @Iata = 'UBSCB'
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


update dba.cartransportation
set journeydescription = 'car0001'
where Source = 'ALEPHUS'
and journeydescription like '%001%'

update dba.cartransportation
set journeydescription = 'car0002'
where Source = 'ALEPHUS'
and journeydescription like '%002%'

update dba.cartransportation
set journeydescription = 'car0003'
where Source = 'ALEPHUS'
and journeydescription like '%003%'

update dba.cartransportation
set journeydescription = 'car0004'
where Source = 'ALEPHUS'
and journeydescription like '%004%'

update dba.cartransportation
set journeydescription = 'car0005'
where Source = 'ALEPHUS'
and journeydescription like '%005%'

update dba.cartransportation
set journeydescription = 'car0006'
where Source = 'ALEPHUS'
and journeydescription like '%006%'

update dba.cartransportation
set journeydescription = 'car0007'
where Source = 'ALEPHUS'
and journeydescription like '%007%'

Delete dba.CarTransportation
where Source = 'ALEPHUS'
and journeydescription = 'car0007'

update dba.cartransportation
set vendorname  = 'Concord Limousine'
where Source = 'ALEPHUS'
and vendorname like '%Concord%'

update dba.cartransportation
set vendorname  = 'CTS Limousine'
where Source = 'ALEPHUS'
and vendorname like 'CTS%'

update dba.cartransportation
set vendorname  = 'Carey International'
where Source = 'ALEPHUS'
and vendorname like 'Carey%'

update dba.cartransportation
set vendorname  = 'EmpireCLS Worldwide'
where Source = 'ALEPHUS'
and vendorname like 'Empire%'

update dba.cartransportation
set vendorname  = 'Bali Limousine'
where Source = 'ALEPHUS'
and vendorname like '%Bali%'

update dba.cartransportation
set vendorname  = 'MTC Limousine'
where Source = 'ALEPHUS'
and vendorname like 'MTC%'

update dba.cartransportation
set vendorname  = 'Flyte Tyme Worldwide'
where Source = 'ALEPHUS'
and vendorname like '%Flyte Tyme%'

Update dba.CarTransportation 
Set baserate =  isnull(baserate,0),
tolls = isnull(tolls,0),
WaitTimeCost =  isnull(WaitTimeCost,0),
Parking = isnull(Parking,0),
MeetGreatCharges = isnull(MeetGreatCharges,0),
PhoneCharges = isnull(PhoneCharges,0), 
ServiceCharges = isnull(ServiceCharges,0), 
AdditionalStops = isnull(AdditionalStops,0), 
AdditionalStopsWaitTime = isnull(AdditionalStopsWaitTime,0), 
TipsGratuity = isnull(TipsGratuity,0), 
FuelSurcharge = isnull(FuelSurcharge,0), 
Package = isnull(Package,0), 
Events = isnull(Events,0), 
NYCWorkmansComp = isnull(NYCWorkmansComp,0),  
Extras = isnull(Extras,0), 
adminfee = isnull(adminfee,0), 
Discount = isnull(Discount,0), 
NetCost = isnull(NetCost,0), 
StateSalesTaxVat = isnull(StateSalesTaxVat,0), 
TotalCost = isnull(TotalCost,0), 
Mileage = isnull(Mileage,0), 
CarbonEmissions = isnull(CarbonEmissions,0) 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Car Main Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO
