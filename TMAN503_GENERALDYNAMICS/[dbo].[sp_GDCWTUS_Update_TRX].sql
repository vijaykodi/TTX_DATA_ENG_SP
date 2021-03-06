/****** Object:  StoredProcedure [dbo].[sp_GDCWTUS_Update_TRX]    Script Date: 7/14/2015 8:07:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GDCWTUS_Update_TRX] 

	@BeginIssueDate	datetime,
	@EndIssueDate	datetime

AS


SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'GDCWTUS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




SET @TransStart = getdate()
--
--update CWT hotel chain codes added 7/27/09
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, dba.cwthtlchains ch
where len(ht.htlchaincode) > 2
and ht.htlchaincode = ch.cwtcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update CWT hotel chain codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 
SET @TransStart = getdate()
--
--update car chain code ZL1/ZL2 to ZL and update car chain name to National 3/19/10
update dba.car
set carchainname = 'NATIONAL CAR RENTAL',
carchaincode = 'ZL'
where iatanum = 'GDCWTUS'
and issuedate  between @BeginIssueDate and @EndIssueDate
and carchainname is null
and cardailyrate is not null
and (carchaincode = 'ZL1'
or carchaincode = 'ZL2')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update car chain code ZL1/ZL2 to ZL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
--
update dba.invoicedetail
set servicefee = null
where vendortype in ('BSP','NONBSP')
and servicefee is not null
and invoiceamt+taxamt = totalamt
and iatanum = 'GDCWTUS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update dba.invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 

 
SET @TransStart = getdate()
---
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail
set vendortype = 'BSPMCO'
where iatanum ='GDCWTUS'
and vendortype in ('BSP','NONBSP')
and documentnumber like '89%'
and issuedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail
set vendortype ='BSPMCO'
where issuedate between @BeginIssueDate and @EndIssueDate
and vendortype in ('BSP','NONBSP')
and voidind ='N'
and  exchangeind ='N'
and documentnumber like '81%'
and iatanum ='GDCWTUS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail
set vendortype ='FEES'
where issuedate between @BeginIssueDate and @EndIssueDate
and vendortype in ('BSP','NONBSP')
and voidind ='N'
and  exchangeind ='N'
and documentnumber like '809%'
and iatanum ='GDCWTUS'
and totalamt is null
and servicefee is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail
set vendortype = 'FEES'
where valcarriercode in ('89','XD','X6')
and issuedate between @BeginIssueDate and @EndIssueDate
AND VENDORTYPE <> 'FEES'
and iatanum ='GDCWTUS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail
set vendortype = 'FEES'
where valcarriercode is null
and issuedate between @BeginIssueDate and @EndIssueDate
AND VENDORTYPE <> 'FEES'
and VendorNumber ='890'
and iatanum ='GDCWTUS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail
set vendortype = 'FEES'
where voidind ='N'
and vendortype in ('BSP','NONBSP')
and vendorname is null
and totalamt between 1 and 50
and routing is null
and issuedate between @BeginIssueDate and @EndIssueDate
and iatanum ='GDCWTUS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--start 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.car
set ttlcarcost = numdays*numcars*cardailyrate
where iatanum = 'GDCWTUS'
and issuedate between @BeginIssueDate and @EndIssueDate
and ttlcarcost is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.car
set carchaincode = 'ZZ',
carchainname ='UNKNOWN CHAIN'
where iatanum = 'GDCWTUS'
and issuedate between @BeginIssueDate and @EndIssueDate
and carchaincode is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 
SET @TransStart = getdate()
--
---added 5/19/06
---cost center
update tk
set tk.remarks2 = ud.udefdata
from TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail tk, TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.udef ud
where tk.iatanum = 'GDCWTUS'
and tk.recordkey = ud.recordkey
and tk.iatanum = ud.iatanum
and tk.seqnum = ud.seqnum
and ud.udefnum = 1
and tk.remarks2 is null
and tk.issuedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TK cost center',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 
SET @TransStart = getdate()
--
--employee number
update tk
set tk.remarks3 = ud.udefdata
from TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.invoicedetail tk, TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.udef ud
where tk.iatanum = 'GDCWTUS'
and tk.recordkey = ud.recordkey
and tk.iatanum = ud.iatanum
and tk.seqnum = ud.seqnum
and ud.udefnum = 2
and tk.remarks3 is null
and tk.issuedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TK employee number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 
SET @TransStart = getdate()
--
update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.hotel
set htlchaincode = 'ZZ',
htlchainname ='UNKNOWN CHAIN'
where iatanum = 'GDCWTUS'
and issuedate between @BeginIssueDate and @EndIssueDate
and htlchaincode is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update TTXPASQL01.TMAN503_GENERALDYNAMICS.dba.hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



GO
