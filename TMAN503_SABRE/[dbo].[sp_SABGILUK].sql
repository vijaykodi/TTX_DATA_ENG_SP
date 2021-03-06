/****** Object:  StoredProcedure [dbo].[sp_SABGILUK]    Script Date: 7/14/2015 8:14:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_SABGILUK]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'SABGILUK'
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
where id.iatanum = 'SABGILUK'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update issuedate for each table',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ts
set ts.issuedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = 'SABGILUK'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ts',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update car
set car.issuedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = 'SABGILUK'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ht
set ht.issuedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = 'SABGILUK'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ht',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ud
set ud.issuedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = 'SABGILUK'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ud',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update pt
set pt.issuedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = 'SABGILUK'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update pt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update tx
set tx.issuedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = 'SABGILUK'
and tx.recordkey = ih.recordkey
and tx.iatanum = ih.iatanum
and tx.issuedate <> ih.invoicedate
and tx.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update tx',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.invoicedetail
set vendortype = 'FEES'
where iatanum = 'SABGILUK'
and vendorname like 'TRANSACTION FEE%'
and vendortype <> 'FEES'
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update vendortype = FEES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.producttype = 'RAIL'
from dba.invoicedetail id, dba.transeg ts
where id.iatanum = 'SABGILUK'
and (id.producttype <> 'RAIL' or id.ProductType is null)
and id.recordkey = ts.recordkey
and id.seqnum = ts.seqnum
and id.iatanum = ts.iatanum
and id.clientcode = ts.clientcode
and ts.typecode = 'R'
AND id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update producttype = RAIL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update dba.invoicedetail
set producttype = 'RAIL'
where iatanum = 'SABGILUK'
and (producttype <> 'RAIL' or ProductType is null)
and InvoiceTypeDescription like 'RAIL%'
AND invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update producttype = RAIL B',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ts
set ts.typecode = 'R'
from dba.invoicedetail id, dba.transeg ts
where id.iatanum = 'SABGILUK'
and id.recordkey = ts.recordkey
and id.seqnum = ts.seqnum
and id.iatanum = ts.iatanum
and id.clientcode = ts.clientcode
and id.producttype = 'RAIL'
and ts.typecode <> 'R'
AND id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update typecode = R',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update online booking system with online/offline indicator from reasoncode1 for client code ('3490','1460','1470','1620','2780')
UPDATE dba.InvoiceDetail
SET OnlineBookingSystem = ReasonCode1
WHERE iatanum = 'SABGILUK'
and OnlineBookingSystem is null
and ReasonCode1 is not null
and ClientCode in ('3490','1460','1470','1620','2780')
AND InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update OnlineBookingSystem from ReasonCode1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete DBA.comrmks
WHERE IATANUm in ('SABGILUK')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
where Invoicedate BETWEEN @BeginIssueDate and @EndIssueDate
and iatanum in ('SABGILUK')
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE Invoicedate BETWEEN @BeginIssueDate and @EndIssueDate
and iatanum in ('SABGILUK'))
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
--Update Text2 with POS from InvoiceHeader
update cr
set Text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = 'SABGILUK'
and cr.text2 is null
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CR.Text2_POS_Ctry',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update text3 with cost center/department code from Remarks1 for client code ('3490','2780')
UPDATE CR
SET CR.Text3 = ID.Remarks1
FROM DBA.ComRmks CR, DBA.InvoiceDetail ID
WHERE CR.RecordKey = ID.RecordKey
AND CR.IataNum = ID.IataNum
AND CR.SeqNum = ID.SeqNum
AND CR.ClientCode = ID.ClientCode
AND CR.InvoiceDate = ID.InvoiceDate
and CR.iatanum = 'SABGILUK'
and CR.text3 is null
and ID.Remarks1 is not null
and ID.ClientCode in ('3490','2780')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text3 from Remarks1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text3 with cost center/department code from UD2 for client code (1460,1470)
UPDATE CR
SET CR.Text3 = ud.UdefData
FROM DBA.ComRmks CR, DBA.Udef ud
WHERE CR.RecordKey = ud.RecordKey
AND CR.IataNum = ud.IataNum
AND CR.SeqNum = ud.SeqNum
AND CR.ClientCode = ud.ClientCode
AND CR.InvoiceDate = ud.InvoiceDate
and CR.iatanum = 'SABGILUK'
and ud.UdefNum = 2
and CR.text3 is null
and ud.UdefData is not null
and ud.ClientCode in ('1460','1470')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text3 from UD2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text6 with online/offline indicator from reasoncode1 for client code 3490
UPDATE CR
SET CR.Text6 = ID.ReasonCode1
FROM DBA.ComRmks CR, DBA.InvoiceDetail ID
WHERE CR.RecordKey = ID.RecordKey
AND CR.IataNum = ID.IataNum
AND CR.SeqNum = ID.SeqNum
AND CR.ClientCode = ID.ClientCode
AND CR.InvoiceDate = ID.InvoiceDate
and CR.iatanum = 'SABGILUK'
and CR.Text6 is null
and ID.ReasonCode1 is not null
and ID.ClientCode in ('3490','1460','1470','1620','2780')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text6 from ReasonCode1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text7 with expense code from Remarks2 for client code 3490
UPDATE CR
SET CR.Text7 = ID.Remarks2
FROM DBA.ComRmks CR, DBA.InvoiceDetail ID
WHERE CR.RecordKey = ID.RecordKey
AND CR.IataNum = ID.IataNum
AND CR.SeqNum = ID.SeqNum
AND CR.ClientCode = ID.ClientCode
AND CR.InvoiceDate = ID.InvoiceDate
and CR.iatanum = 'SABGILUK'
and CR.text7 is null
and ID.Remarks2 is not null
and ID.ClientCode in ('3490','1460','1470')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text7 from Remarks2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text7 with expense code from Remarks2 for client code (2780)
UPDATE CR
SET CR.Text7 = ud.UdefData
FROM DBA.ComRmks CR, DBA.Udef ud
WHERE CR.RecordKey = ud.RecordKey
AND CR.IataNum = ud.IataNum
AND CR.SeqNum = ud.SeqNum
AND CR.ClientCode = ud.ClientCode
AND CR.InvoiceDate = ud.InvoiceDate
and CR.iatanum = 'SABGILUK'
and ud.UdefNum = 2
and CR.Text7 is null
and ud.UdefData is not null
and ud.ClientCode in ('2780')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text7 from UD2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


GO
