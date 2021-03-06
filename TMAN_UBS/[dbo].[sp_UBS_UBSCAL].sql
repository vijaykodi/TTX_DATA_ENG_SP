/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCAL]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSCAL]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSCAL'
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
--Insert Aleph Data--  UBSCAL
INSERT INTO DBA.CarTransportation
SELECT 'ALEPHUS',UsagePeriod , ProcessDate , InvoiceNumber , Conf 
, Name , GPN, BookedBy , DateofTravel , 
timeofpu,pickupaddress + towncityborough+ statepickup,
finalDestination + towncityboroughdest + destinationstate ,Null as Dropofftime,
justificationcode, costcenter, projectcode, vendor, VehicleType,isnull(BaseRate,'0'), isnull(tolls,'0'),
isnull(waittime,'0'),isnull(parking,'0'),isnull(MeetGreetCharges,'0'), isnull(phonecharges,'0'), 
isnull(servicecharges,'0'), isnull(additionalstops,'0'), isnull(stopwaittime,'0'),isnull(gratuity,'0'), 
isnull(fuelsurcharge,'0'),isnull(packages,'0'), isnull(event,'0'), isnull([2NYSurcharge],'0'), 
isnull(misc,'0'), isnull(premium,'0'), isnull(discount,'0'), isnull(subtotal,'0'), isnull(StateSalesTax,'0'),
isnull(Total,'0'), isnull(mileage,'0'),isnull(carbonemissions,'0'),
'USD','US',ISNULL(RIGHT('00000000'+GPN,8),GPN),Getdate(), car, creditcardvoucher
from dba.alephtemp
where conf not in (select confirmationnbr from dba.cartransportation c1 , dba.alephtemp c2
where c1.source = 'alephus' 
and c1.invoicenumber = c2.invoicenumber
and c1.confirmationnbr = c2.conf
and c1.passengername = c2.name 
and c1.pickupdate = c2.dateoftravel
and c1.pickuptime = c2.timeofpu
and c1.destination = c2.towncityboroughdest
and c1.baserate = c2.baserate)


update dba.cartransportation
set gpn = 'Unknown' 
where gpn not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and source = 'ALEPHUS'

--0 AS Package,
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Aleph Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

--verified the temp file is trunicated as requested
--12.6.12
Truncate table dba.AlephTemp

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
