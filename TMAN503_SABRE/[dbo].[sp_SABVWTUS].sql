/****** Object:  StoredProcedure [dbo].[sp_SABVWTUS]    Script Date: 7/14/2015 8:14:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_SABVWTUS]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'SABVWTUS'
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
--Update issuedate for each table to match invoicedate in invoiceheader
Update id
set id.issuedate = ih.invoicedate
from dba.invoicedetail id, dba.invoiceheader ih
where id.iatanum = 'SABVWTUS'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update issuedate for each table',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ts
set ts.issuedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = 'SABVWTUS'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ts',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update car
set car.issuedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = 'SABVWTUS'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ht
set ht.issuedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = 'SABVWTUS'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ht',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ud
set ud.issuedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = 'SABVWTUS'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ud',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update pt
set pt.issuedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = 'SABVWTUS'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update pt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update tx
set tx.issuedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = 'SABVWTUS'
and tx.recordkey = ih.recordkey
and tx.iatanum = ih.iatanum
and tx.issuedate <> ih.invoicedate
and tx.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update tx',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete DBA.comrmks
WHERE IATANUm in ('SABVWTUS')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
where Invoicedate BETWEEN @BeginIssueDate and @EndIssueDate
and iatanum in ('SABVWTUS')
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE Invoicedate BETWEEN @BeginIssueDate and @EndIssueDate
and iatanum in ('SABVWTUS'))
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text2 with POS from InvoiceHeader
update cr
set Text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = 'SABVWTUS'
and cr.text2 is null
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CR.Text2_POS_Ctry',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update text3 with cost center/department code from UD99
UPDATE CR
SET CR.Text3 = UD.udefdata,
CR.Text4 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABVWTUS'
AND UD.UdefNum = 99
and CR.text3 is null
and UD.ClientCode in ('C511526','C635705','C640744','C640745','C754754','C867849','C868892')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text3 cost center from UD99',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text7 with project code/WBS code from UD83
UPDATE CR
SET CR.Text7 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABVWTUS'
AND UD.UdefNum = 83
and CR.text7 is null
and UD.ClientCode in ('C511526','C635705','C640744','C640745','C754754','C867849','C868892')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text7 project code from UD83',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update dba.invoicedetail 
set valcarriercode = 'ZZ',
Valcarriernum = 999
from dba.InvoiceDetail
where IataNum ='SABVWTUS'
and VendorType in ('BSP','NONBSP')
--and InvoiceType ='Air'
and ValCarrierCode is null
and InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update null valcarriercode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
