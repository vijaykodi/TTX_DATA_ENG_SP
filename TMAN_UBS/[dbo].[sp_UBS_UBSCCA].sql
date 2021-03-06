/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCCA]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSCCA]

 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime ,@BeginIssueDate datetime,@ENDIssueDate datetime

	SET @Iata = 'UBSCCA'
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Carey Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

-------Insert into Production Table ---------------------------------------------LOC/6/14/2013
INSERT INTO DBA.CarTransportation
SELECT 'CAREY',res_date,DATEadd(MONTH,datediff(month,0,getdate())-1,0),
Invoice,docket,Passenger, GPIN, booked_by, res_date, pickup_time, 
pickup +' '+pickup_postcode, Destination+' '+destination_postcode,'0:00' as dropofftime ,journey_type, 
cost_center, Product_Code, third_party, vehicle_type, Net, other , Waiting, Parking , 0 AS 
MeetGreatCharges, 0 AS PhoneCharges , 0 AS ServiceCharges, 0 AS 
AdditionalStops, waiting_time, grats,0 AS FuelSurcharge ,0 AS Package,
0 AS Events,0 AS NYCWorkmansComp, 0 AS Extras, [admin], Discount, 
net, VAT, gross, 0 , 0, 'GBP','GB',GPIN, getdate(),NULL, 'Credit Card'
FROM DBA.CareyTemp

update dba.cartransportation
set gpn = 'Unknown' 
where isnull(gpn,'X') not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and source = 'Carey'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Carey Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


Truncate table dba.Careytemp

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
