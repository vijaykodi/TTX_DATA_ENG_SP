/****** Object:  StoredProcedure [dbo].[sp_SABTRVUS]    Script Date: 7/14/2015 8:14:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_SABTRVUS]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'SABTRVUS'
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
where id.iatanum = 'SABTRVUS'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update issuedate for each table',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ts
set ts.issuedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = 'SABTRVUS'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ts',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update car
set car.issuedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = 'SABTRVUS'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ht
set ht.issuedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = 'SABTRVUS'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ht',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ud
set ud.issuedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = 'SABTRVUS'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ud',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update pt
set pt.issuedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = 'SABTRVUS'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update pt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update tx
set tx.issuedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = 'SABTRVUS'
and tx.recordkey = ih.recordkey
and tx.iatanum = ih.iatanum
and tx.issuedate <> ih.invoicedate
and tx.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update tx',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set vendortype = 'FEES'
where iatanum = 'SABTRVUS'
and (vendorname like 'SERVICE FEE%' or vendorname like 'TRANSACTION FEE%')
and vendortype <> 'FEES'
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update vendortype = FEES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.producttype = 'RAIL'
from dba.invoicedetail id, dba.transeg ts
where id.iatanum = 'SABTRVUS'
and id.producttype <> 'RAIL'
and id.recordkey = ts.recordkey
and id.seqnum = ts.seqnum
and id.iatanum = ts.iatanum
and id.clientcode = ts.clientcode
and ts.typecode = 'R'
AND id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update producttype = RAIL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.onlinebookingsystem = ud.udefdata
from dba.invoicedetail id, dba.udef ud
where id.iatanum = 'SABTRVUS'
and id.recordkey = ud.recordkey
and id.seqnum = ud.seqnum
and id.iatanum = ud.iatanum
and id.clientcode = ud.clientcode
and ud.udefnum = 21
and ud.udefdata is not null
AND id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update onlinebookingsystem',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.farecompare1 = CONVERT(float,ud.udefdata)
from dba.invoicedetail id, dba.udef ud
where id.iatanum = 'SABTRVUS'
and id.recordkey = ud.recordkey
and id.seqnum = ud.seqnum
and id.iatanum = ud.iatanum
and id.clientcode = ud.clientcode
and ud.udefnum = 5
and ud.udefdata is not null
and id.vendortype <> 'FEES'
and substring(ud.udefdata,1,1) between '0' and '9'
and ud.udefdata not like '%-%'
AND id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update farecompare1 from UD5',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.farecompare2 = CONVERT(float,ud.udefdata)
from dba.invoicedetail id, dba.udef ud
where id.iatanum = 'SABTRVUS'
and id.recordkey = ud.recordkey
and id.seqnum = ud.seqnum
and id.iatanum = ud.iatanum
and id.clientcode = ud.clientcode
and ud.udefnum = 4
and ud.udefdata is not null
and id.vendortype <> 'FEES'
and substring(ud.udefdata,1,1) between '0' and '9'
and ud.udefdata not like '%-%'
AND id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update farecompare2 from UD4',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
delete DBA.comrmks
WHERE IATANUm in ('SABTRVUS')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
where Invoicedate BETWEEN @BeginIssueDate and @EndIssueDate
and iatanum in ('SABTRVUS')
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE Invoicedate BETWEEN @BeginIssueDate and @EndIssueDate
and iatanum in ('SABTRVUS'))
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update text1 with employee number from remarks1 for client codes 29590 and 75590
UPDATE CR
SET CR.Text1 = ID.remarks1
FROM DBA.ComRmks CR, DBA.InvoiceDetail ID
WHERE CR.RecordKey = ID.RecordKey
AND CR.IataNum = ID.IataNum
AND CR.SeqNum = ID.SeqNum
AND CR.ClientCode = ID.ClientCode
AND CR.InvoiceDate = ID.InvoiceDate
and CR.iatanum = 'SABTRVUS'
and CR.text1 is null
and ID.remarks1 is not null
and ID.ClientCode in ('29590','75590')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text1 from remarks1 for 29590 and 75590',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text1 with employee number from UD1 for client code 12770
UPDATE CR
SET CR.Text1 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 1
and CR.text1 is null
and UD.udefdata is not null
and UD.ClientCode in ('12770')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text1 from UD1 for 12770',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update Text2 with POS from InvoiceHeader
update cr
set Text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = 'SABTRVUS'
and cr.text2 is null
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CR.Text2_POS_Ctry',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text3 with cost center/department code from UD1 for client code 29590
UPDATE CR
SET CR.Text3 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 1
and CR.text3 is null
and UD.udefdata is not null
and UD.ClientCode in ('29590')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text3 from UD1 for 29590',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text3 and text4 with cost center/department code from UD1 for client code 75590
UPDATE CR
SET CR.Text3 = UD.udefdata,
CR.Text4 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 1
and CR.text3 is null
and UD.udefdata is not null
and UD.ClientCode in ('75590')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text3 from UD1 for 75590',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text3 and text4 with cost center/department code from remarks1 for client codes 12770
UPDATE CR
SET CR.Text3 = ID.remarks1,
CR.Text4 = ID.remarks1
FROM DBA.ComRmks CR, DBA.InvoiceDetail ID
WHERE CR.RecordKey = ID.RecordKey
AND CR.IataNum = ID.IataNum
AND CR.SeqNum = ID.SeqNum
AND CR.ClientCode = ID.ClientCode
AND CR.InvoiceDate = ID.InvoiceDate
and CR.iatanum = 'SABTRVUS'
and CR.text3 is null
and ID.remarks1 is not null
and ID.ClientCode in ('12770')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text3 from remarks1 for 12770',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text4 with department name from UD2 for client code 29590
UPDATE CR
SET CR.Text4 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 2
and CR.text4 is null
and UD.udefdata is not null
and UD.ClientCode in ('29590')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text4 from UD2 for 29590',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text5 with Trip purpose from UD6 for client code 29590
UPDATE CR
SET CR.Text5 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 6
and CR.text5 is null
and UD.udefdata is not null
and UD.ClientCode in ('29590')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text5 from UD6 for 29590',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text5 with trip purpose from UD10 for client code 75590
UPDATE CR
SET CR.Text5 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 10
and CR.text5 is null
and UD.udefdata is not null
and UD.ClientCode in ('75590')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text5 from UD10 for 75590',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text5 with trip purpose from UD2 for client code 12770 only if text1 = 99999999
UPDATE CR
SET CR.Text5 = UD.udefdata
FROM DBA.ComRmks CR, DBA.Udef UD
WHERE CR.RecordKey = UD.RecordKey
AND CR.IataNum = UD.IataNum
AND CR.SeqNum = UD.SeqNum
AND CR.ClientCode = UD.ClientCode
AND CR.InvoiceDate = UD.InvoiceDate
and CR.iatanum = 'SABTRVUS'
AND UD.UdefNum = 2
and CR.text5 is null
and UD.udefdata is not null
and CR.text1 = '99999999'
and UD.ClientCode in ('12770')
AND CR.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update text5 from UD2 for 12770',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update text5 with UD21 for online/offline indicator
--Added on 1/28/13 by Nina
update cr
set cr.Text6 = ud.udefdata
from dba.ComRmks cr, dba.udef ud
where cr.iatanum = 'SABTRVUS'
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and ud.udefnum = 21
and cr.Text6 is null
and ud.udefdata is not null
AND cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update Text6 with UD21',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
