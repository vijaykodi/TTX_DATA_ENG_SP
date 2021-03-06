/****** Object:  StoredProcedure [dbo].[sp_BCCWTAZ]    Script Date: 7/14/2015 7:49:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_BCCWTAZ]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'BCCWTAZ'
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
where id.iatanum = 'BCCWTAZ'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update issuedate for each table',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ts
set ts.issuedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = 'BCCWTAZ'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ts',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update car
set car.issuedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = 'BCCWTAZ'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ht
set ht.issuedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = 'BCCWTAZ'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ht',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ud
set ud.issuedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = 'BCCWTAZ'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ud',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update pt
set pt.issuedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = 'BCCWTAZ'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update pt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update tx
set tx.issuedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = 'BCCWTAZ'
and tx.recordkey = ih.recordkey
and tx.iatanum = ih.iatanum
and tx.issuedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update tx',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
WHERE iatanum in ('BCCWTAZ')
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
where iatanum in ('BCCWTAZ'))
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text2 with POS from InvoiceHeader
update cr
set Text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = 'BCCWTAZ'
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CR.Text2_POS_Ctry',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update dba.ClassToCabin 
---from transeg
insert into dba.classtocabin
select distinct substring(ts.SegmentCarrierCode,1,3), substring(ts.ClassOfService,1,1), 'ECONOMY',ts.segInternationalInd,'Y',NULL,NULL
from dba.transeg ts
where ts.iatanum = 'BCCWTAZ'
and ts.SegmentCarrierCode is not null
and ts.ClassOfService is not null
and not exists (select 1 from dba.classtocabin b
where b.carriercode = substring(ts.SegmentCarrierCode,1,3)
and b.classofservice =  substring(ts.ClassOfService,1,1)
and b.InternationalInd = ts.segInternationalInd)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ClassToCabin from transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
---from invoicedetail
insert into dba.classtocabin
select distinct substring(id.valcarriercode,1,3), substring(id.ServiceCategory,1,1), 'ECONOMY',InternationalInd,'Y',NULL,NULL
from dba.InvoiceDetail ID
where ID.IataNum = 'BCCWTAZ'
and ID.VendorType in ('BSP','NONBSP','RAIL')
and id.valcarriercode is not null
and id.ServiceCategory is not null
and not exists (select 1 from dba.classtocabin b
where b.carriercode = substring(id.valcarriercode,1,3) 
and b.classofservice =  substring(id.ServiceCategory,1,1)
and b.InternationalInd = id.InternationalInd)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ClassToCabin from invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Standard post import sql update for Text14 - HighestCabin
--InvoiceDetail.ServiceCategory is first segment's class of service not highest cabin flown
SET @TransStart = getdate()
update cr
set cr.text14 = ctc.DomCabin
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ts.Minsegmentcarriercode = ctc.carriercode
and ts.MINclassofservice = ctc.classofservice
and ts.MINinternationalind = ctc.InternationalInd
and cr.iatanum in ('BCCWTAZ')
and ctc.DomCabin = 'First'
and ts.farebasis not like '%UP%'
and cr.text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = DomCabin where DomCabin = First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text14 = ctc.DomCabin
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ts.MINsegmentcarriercode = ctc.carriercode
and ts.MINclassofservice = ctc.classofservice
and ts.MINinternationalind = ctc.InternationalInd
and cr.iatanum in ('BCCWTAZ')
and ctc.DomCabin = 'Business'
and ts.farebasis not like '%UP%'
and cr.text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = DomCabin where DomCabin = Business',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text14 = 'ECONOMY'
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ts.MINsegmentcarriercode = ctc.carriercode
and ts.MINclassofservice = ctc.classofservice
and ts.MINinternationalind = ctc.InternationalInd
and cr.iatanum in ('BCCWTAZ')
and ts.farebasis like '%UP%'
and cr.text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = DomCabin for YUP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text14 = ctc.DomCabin
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ts.MINsegmentcarriercode = ctc.carriercode
and ts.MINclassofservice = ctc.classofservice
and ts.MINinternationalind = ctc.InternationalInd
and cr.iatanum in ('BCCWTAZ')
and cr.text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = DomCabin',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



GO
