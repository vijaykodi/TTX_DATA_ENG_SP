/****** Object:  StoredProcedure [dbo].[sp_OFBDaily]    Script Date: 7/14/2015 8:13:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_OFBDaily] 

	@BeginIssueDate	datetime,
	@EndIssueDate	datetime

AS
--

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'ORBITZ'
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
update id
set id.currcode = 'USD'
from dba.invoicedetail id, dba.invoiceheader ih
where id.totalamt is null
and id.currcode <> 'USD'
and id.IataNum = 'ORBITZ'
and id.recordkey = ih.recordkey 
and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate
and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID CuurCode USD',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update client code to lowercase value for 1 client in all data as orbitz is sending in upper and lower and
--it is impacting their outbound feed to Prime Analytics/TravelGPA  TPT-tp5920021 and TPT-TP5920021

SET @TransStart = getdate()
update dba.client
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.invoiceheader
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.invoicedetail
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.transeg
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.car
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.hotel
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.udef
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.comrmks
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.payment
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.tax
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Clientcode update for TPT-TP590021',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ht
set ht.issuedate = id.issuedate
from dba.hotel ht, dba.invoicedetail id
where ht.issuedate <> id.issuedate
and ht.recordkey = id.recordkey
and ht.seqnum = id.seqnum
and ht.iatanum = id.iatanum
and ht.iatanum in('ORBITZ')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HT Issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update ht
set ht.issuedate = id.issuedate
from dba.car ht, dba.invoicedetail id
where ht.issuedate <> id.issuedate
and ht.recordkey = id.recordkey
and ht.seqnum = id.seqnum
and ht.iatanum = id.iatanum
and ht.iatanum in('ORBITZ')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CAR Issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Populate Common Remarks for 25 trip reference fields--added 9/28/2007
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT id.RecordKey, id.IataNum, id.SeqNum, id.ClientCode, id.InvoiceDate, id.IssueDate
FROM dba.InvoiceDetail id, dba.invoiceheader ih
WHERE id.iatanum in ('ORBITZ')
and id.recordkey = ih.recordkey 
and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate
and id.ClientCode = ih.ClientCode
and ih.invoicedate >='2013-01-01'
AND not exists (select 1,3
				FROM dba.ComRmks cr
				WHERE cr.iatanum in ('ORBITZ')
				and cr.recordkey = id.recordkey
				and cr.iatanum = id.iatanum
				and cr.seqnum = id.seqnum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- DECLARE @importdt datetime
-- SET @importdt = (select max(importdt) from dba.invoiceheader)

-- every time we import old records the dba.invoiceheader.importdt stays old as per first import.
-- this makes comrmks.issuedate be different then id.issudate
-- I commented AND ih.importdt >= @importdt  in update statement below. It may slow down entire querry
-- incident 1057770 - Yuliya Tsizh
SET @TransStart = getdate()
update cr
set cr.issuedate = id.issuedate
from dba.invoiceheader ih, dba.invoicedetail id,dba.ComRmks cr
WHERE ih.RecordKey = id.RecordKey
AND ih.IataNum = id.IataNum
AND ih.ClientCode = id.ClientCode
AND ih.invoicedate = id.invoicedate
--AND ih.importdt >= @importdt
AND id.RecordKey+id.IataNum+CONVERT(VARCHAR,id.SeqNum) = cr.RecordKey+cr.IataNum+CONVERT(VARCHAR,cr.SeqNum)
AND cr.ClientCode = id.ClientCode
AND cr.issuedate <> id.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CR issuedate update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text1 = substring(ud100.udefdata,1,150)
from dba.comrmks cr, dba.udef ud100
where cr.iatanum = ud100.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud100.recordkey
---and cr.seqnum = ud100.seqnum
and ud100.udefnum = 100
and cr.text1 is null
and ud100.udefdata is not null
and cr.issuedate = ud100.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text2 = substring(ud101.udefdata,1,150)
from dba.comrmks cr, dba.udef ud101
where cr.iatanum = ud101.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud101.recordkey
---and cr.seqnum = ud101.seqnum
and ud101.udefnum = 101
and cr.text2 is null
and ud101.udefdata is not null
and cr.issuedate = ud101.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text3 = substring(ud102.udefdata,1,150)
from dba.comrmks cr, dba.udef ud102
where cr.iatanum = ud102.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud102.recordkey
---and cr.seqnum = ud102.seqnum
and ud102.udefnum = 102
and cr.text3 is null
and ud102.udefdata is not null
and cr.issuedate = ud102.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text4 = substring(ud103.udefdata,1,150)
from dba.comrmks cr, dba.udef ud103
where cr.iatanum = ud103.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud103.recordkey
---and cr.seqnum = ud103.seqnum
and ud103.udefnum = 103
and cr.text4 is null
and ud103.udefdata is not null
and cr.issuedate = ud103.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text4',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text5 = substring(ud104.udefdata,1,150)
from dba.comrmks cr, dba.udef ud104
where cr.iatanum = ud104.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud104.recordkey
---and cr.seqnum = ud104.seqnum
and ud104.udefnum = 104
and cr.text5 is null
and ud104.udefdata is not null
and cr.issuedate = ud104.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text5',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text6 = substring(ud120.udefdata,1,150)
from dba.comrmks cr, dba.udef ud120
where cr.iatanum = ud120.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud120.recordkey
---and cr.seqnum = ud120.seqnum
and ud120.udefnum = 120
and cr.text6 is null
and ud120.udefdata is not null
and cr.issuedate = ud120.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text6',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text7 = substring(ud121.udefdata,1,150)
from dba.comrmks cr, dba.udef ud121
where cr.iatanum = ud121.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud121.recordkey
---and cr.seqnum = ud121.seqnum
and ud121.udefnum = 121
and cr.text7 is null
and ud121.udefdata is not null
and cr.issuedate = ud121.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text7',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text8 = substring(ud122.udefdata,1,150)
from dba.comrmks cr, dba.udef ud122
where cr.iatanum = ud122.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud122.recordkey
---and cr.seqnum = ud122.seqnum
and ud122.udefnum = 122
and cr.text8 is null
and ud122.udefdata is not null
and cr.issuedate = ud122.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text8',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text9 = substring(ud123.udefdata,1,150)
from dba.comrmks cr, dba.udef ud123
where cr.iatanum = ud123.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud123.recordkey
---and cr.seqnum = ud123.seqnum
and ud123.udefnum = 123
and cr.text9 is null
and ud123.udefdata is not null
and cr.issuedate = ud123.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text9',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text10 = substring(ud124.udefdata,1,150)
from dba.comrmks cr, dba.udef ud124
where cr.iatanum = ud124.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud124.recordkey
---and cr.seqnum = ud124.seqnum
and ud124.udefnum = 124
and cr.text10 is null
and ud124.udefdata is not null
and cr.issuedate = ud124.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text10',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text11 = substring(ud125.udefdata,1,150)
from dba.comrmks cr, dba.udef ud125
where cr.iatanum = ud125.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud125.recordkey
---and cr.seqnum = ud125.seqnum
and ud125.udefnum = 125
and cr.text11 is null
and ud125.udefdata is not null
and cr.issuedate = ud125.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text11',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text12 = substring(ud126.udefdata,1,150)
from dba.comrmks cr, dba.udef ud126
where cr.iatanum = ud126.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud126.recordkey
---and cr.seqnum = ud126.seqnum
and ud126.udefnum = 126
and cr.text12 is null
and ud126.udefdata is not null
and cr.issuedate = ud126.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text12',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text13 = substring(ud127.udefdata,1,150)
from dba.comrmks cr, dba.udef ud127
where cr.iatanum = ud127.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud127.recordkey
---and cr.seqnum = ud127.seqnum
and ud127.udefnum = 127
and cr.text13 is null
and ud127.udefdata is not null
and cr.issuedate = ud127.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text13',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text14 = substring(ud128.udefdata,1,150)
from dba.comrmks cr, dba.udef ud128
where cr.iatanum = ud128.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud128.recordkey
---and cr.seqnum = ud128.seqnum
and ud128.udefnum = 128
and cr.text14 is null
and ud128.udefdata is not null
and cr.issuedate = ud128.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text14',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text15 = substring(ud129.udefdata,1,150)
from dba.comrmks cr, dba.udef ud129
where cr.iatanum = ud129.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud129.recordkey
---and cr.seqnum = ud129.seqnum
and ud129.udefnum = 129
and cr.text15 is null
and ud129.udefdata is not null
and cr.issuedate = ud129.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text15',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text16 = substring(ud130.udefdata,1,150)
from dba.comrmks cr, dba.udef ud130
where cr.iatanum = ud130.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud130.recordkey
---and cr.seqnum = ud130.seqnum
and ud130.udefnum = 130
and cr.text16 is null
and ud130.udefdata is not null
and cr.issuedate = ud130.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text16',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text17 = substring(ud131.udefdata,1,150)
from dba.comrmks cr, dba.udef ud131
where cr.iatanum = ud131.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud131.recordkey
---and cr.seqnum = ud131.seqnum
and ud131.udefnum = 131
and cr.text17 is null
and ud131.udefdata is not null
and cr.issuedate = ud131.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text17',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text18 = substring(ud132.udefdata,1,150)
from dba.comrmks cr, dba.udef ud132
where cr.iatanum = ud132.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud132.recordkey
---and cr.seqnum = ud132.seqnum
and ud132.udefnum = 132
and cr.text18 is null
and ud132.udefdata is not null
and cr.issuedate = ud132.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text18',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text19 = substring(ud133.udefdata,1,150)
from dba.comrmks cr, dba.udef ud133
where cr.iatanum = ud133.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud133.recordkey
---and cr.seqnum = ud133.seqnum
and ud133.udefnum = 133
and cr.text19 is null
and ud133.udefdata is not null
and cr.issuedate = ud133.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text19',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text20 = substring(ud134.udefdata,1,150)
from dba.comrmks cr, dba.udef ud134
where cr.iatanum = ud134.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud134.recordkey
---and cr.seqnum = ud134.seqnum
and ud134.udefnum = 134
and cr.text20 is null
and ud134.udefdata is not null
and cr.issuedate = ud134.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text20',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text21 = substring(ud135.udefdata,1,150)
from dba.comrmks cr, dba.udef ud135
where cr.iatanum = ud135.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud135.recordkey
---and cr.seqnum = ud135.seqnum
and ud135.udefnum = 135
and cr.text21 is null
and ud135.udefdata is not null
and cr.issuedate = ud135.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text21',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text22 = substring(ud136.udefdata,1,150)
from dba.comrmks cr, dba.udef ud136
where cr.iatanum = ud136.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud136.recordkey
---and cr.seqnum = ud136.seqnum
and ud136.udefnum = 136
and cr.text22 is null
and ud136.udefdata is not null
and cr.issuedate = ud136.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text22',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text23 = substring(ud137.udefdata,1,150)
from dba.comrmks cr, dba.udef ud137
where cr.iatanum = ud137.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud137.recordkey
---and cr.seqnum = ud137.seqnum
and ud137.udefnum = 137
and cr.text23 is null
and ud137.udefdata is not null
and cr.issuedate = ud137.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text23',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text24 = substring(ud138.udefdata,1,150)
from dba.comrmks cr, dba.udef ud138
where cr.iatanum = ud138.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud138.recordkey
---and cr.seqnum = ud138.seqnum
and ud138.udefnum = 138
and cr.text24 is null
and ud138.udefdata is not null
and cr.issuedate = ud138.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text24',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text25 = substring(ud139.udefdata,1,150)
from dba.comrmks cr, dba.udef ud139
where cr.iatanum = ud139.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud139.recordkey
---and cr.seqnum = ud139.seqnum
and ud139.udefnum = 139
and cr.text25 is null
and ud139.udefdata is not null
and cr.issuedate = ud139.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text25',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text26 = substring(ud140.udefdata,1,150)
from dba.comrmks cr, dba.udef ud140
where cr.iatanum = ud140.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud140.recordkey
---and cr.seqnum = ud139.seqnum
and ud140.udefnum = 140
and cr.text26 is null
and ud140.udefdata is not null
and cr.issuedate = ud140.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text26',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text27 = substring(ud141.udefdata,1,150)
from dba.comrmks cr, dba.udef ud141
where cr.iatanum = ud141.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud141.recordkey
and ud141.udefnum = 141
and cr.text27 is null
and ud141.udefdata is not null
and cr.issuedate = ud141.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text27',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text28 = substring(ud142.udefdata,1,150)
from dba.comrmks cr, dba.udef ud142
where cr.iatanum = ud142.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud142.recordkey
and ud142.udefnum = 142
and cr.text28 is null
and ud142.udefdata is not null
and cr.issuedate = ud142.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text28',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text29 = substring(ud144.udefdata,1,150)
from dba.comrmks cr, dba.udef ud144
where cr.iatanum = ud144.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud144.recordkey
and ud144.udefnum = 144
and cr.text29 is null
and ud144.udefdata is not null
and cr.issuedate = ud144.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text29',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text49 = substring(ud114.udefdata,1,150)
from dba.comrmks cr, dba.udef ud114
where cr.iatanum = ud114.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud114.recordkey
---and cr.seqnum <> ud114.seqnum
and ud114.udefnum = 114
and cr.text49 is null
and ud114.udefdata is not null
and cr.invoicedate = ud114.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text49',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text50 = substring(ud110.udefdata,1,150)
from dba.comrmks cr, dba.udef ud110
where cr.iatanum = ud110.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud110.recordkey
---and cr.seqnum = ud110.seqnum
and ud110.udefnum = 110
and cr.text50 is null
and ud110.udefdata is not null
and cr.issuedate = ud110.issuedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Radisson'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='RAD'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel RAD',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Sutton Place'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000063'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel 000063',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Conrad'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000053'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel 000053',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Four Points'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='FP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel FP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Sofitel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='VS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel VS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Country Inn and Suites'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='CHI'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel CHI',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Amerihost'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='MQ'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel MQ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Lexington'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel LP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Pan Pacific'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='PP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel PP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Park Inn'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='PII'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel PII',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Hotel Providence'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000194'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel 000194',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Sahara'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LDC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel LDC',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Walt Disney World'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='WDW'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel WDW',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Wrens House'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='HO'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel HO',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Novitel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='XN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel XN',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.hotel
set htlchainname = 'Palace Hotel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel LC',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
-- added by Jim to fix NULL VendorNumber

UPDATE ID
SET ID.VendorName = C.CARRIERNAME
FROM DBA.InvoiceDetail ID, DBA.Carriers C
WHERE ID.ValCarrierCode = C.CarrierCode
AND ((ID.VendorName <> C.CarrierName) OR (ID.VendorName IS NULL))
AND C.TYPECODE = 'A' AND C.Status = 'A'
and ID.VendorType in ('bsp','nonbsp')
and id.iatanum = 'ORBITZ'
and id.issuedate>='2013-01-01'

UPDATE TS
SET SegmentCarrierName = cr.CarrierName
FROM DBA.TranSeg TS, dba.Carriers cr
WHERE 1=1
AND ts.SegmentCarrierCode = cr.CarrierCode
AND ((SegmentCarrierName <> cr.CarrierName) OR (SegmentCarrierName IS NULL))
AND CR.TypeCode = 'A' AND CR.Status = 'A'
and ts.iatanum = 'ORBITZ'
and ts.issuedate>='2013-01-01'



update t1
set vendornumber = valcarriernum
from dba.invoicedetail t1
where t1.IATANUM='ORBITZ'
AND t1.VENDORTYPE IN ('BSP','NONBSP') 
AND t1.VOIDIND='N' 
AND t1.VENDORNUMBER IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Vendornum',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
-- added by Jim to fix NULL ValCarrierCode and VendorName for TT Standard reports
UPDATE id
SET id.ValCarrierCode = TS.SegmentCarrierCode,
      id.VendorName = TS.SegmentCarrierName
FROM dba.invoicedetail id, dba.transeg ts
where id.iatanum = 'ORBITZ'
and id.recordkey = ts.recordkey
and id.iatanum = ts.iatanum
and id.seqnum = ts.seqnum
and id.voidind = 'N'
and id.vendortype in ('BSP','NONBSP')
and id.vendorname is NULL
and ts.segmentnum = 1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='SegCarrier',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
UPDATE ID
SET id.OriginCode = ts.origincitycode,
    id.DestinationCode = ts.mindestcitycode
from dba.invoicedetail id, dba.transeg ts, dba.invoiceheader ih
where id.recordkey = ts.recordkey
and id.iatanum = ts.iatanum
and id.clientcode = ts.clientcode
and id.seqnum = ts.seqnum
and id.issuedate = ts.issuedate
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.clientcode = ih.clientcode
and id.invoicedate = ih.invoicedate
and ts.segmentnum = 1
and ih.importdt > (select dateadd(d,-7,max(importdt)) from dba.invoiceheader)
and ih.iatanum = 'ORBITZ'
and id.iatanum = 'ORBITZ'
and ts.iatanum = 'ORBITZ'
and id.origincode is  null
and id.destinationcode is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Orig and Dest',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
--Added per Kara incident 1048894
--Removed the edit about onlinebookingsystem = NULL per Kara incident #1070050
update dba.invoicedetail
set farecompare2 = null,
reasoncode1 = null
from dba.invoicedetail
where iatanum ='ORBITZ'
and exchangeind ='Y'
and vendortype in ('BSP','NONBSP')
and issuedate >'2007-12-31'
and farecompare2 is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Fare Compare Null EXCH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update dba.invoicedetail
set farecompare2 = null,
reasoncode1 = null
from dba.invoicedetail
where iatanum ='ORBITZ'
and exchangeind ='Y'
and vendortype in ('BSP','NONBSP')
and issuedate >'2007-12-31'
and reasoncode1 is not null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Fare Compare Null EXCH2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Car chain name when not provided in the data #42451 - updating regardless of IATANUM
--to solve for multiple feeds not including it
SET @TransStart = getdate()
update c
set CarChainName=substring(ch.chainname,1,20)
from dba.car c,
dba.Chains ch
 where c.CarChainName is null
 and c.CarChainCode is not null
 and ch.TYPECODE='c'
 and c.carchaincode=ch.chaincode
 and c.IssueDate>'2013-01-01'
 
update c
set CarChainName=carchaincode
from dba.car c
 where c.CarChainName is null
 and c.CarChainCode is not null
and c.IssueDate>'2013-01-01'
and CarChainCode
not in (select chaincode from dba.Chains where TYPECODE='c')
 
 EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Car Chain Code',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--added per Jim 11/25/2009
update t1
set t1.htlstate = t2.code
from dba.hotel t1, dba.statecode t2
where t1.htlstate = t2.name
and len(t1.htlstate) > 2
and t1.htlcountrycode in ('US')
and t1.MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL State US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update dba.hotel
set htlcountrycode = 'AU'
where htlstate in ('New South Wales','Victoria','Melbourne','Queensland')
and htlcountrycode <>'AU'
and MasterId is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL country AU',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--update dba.hotel
--set htlcountrycode = 'AU'
--where htlstate ='Victoria'
--and htlcityname ='Melbourne'
--and htlcountrycode <>'AU'
--and MasterId is null  

--update dba.hotel
--set htlcountrycode = 'AU'
--where htlstate ='Queensland'
--and htlcityname ='Brisbane'
--and htlcountrycode <>'AU'
--and MasterId is null 
SET @TransStart = getdate()
update dba.hotel
set htlstate = CASE when htlstate ='Ontario' then 'ON'
when htlstate = 'Alberta' then 'AB'
when htlstate = 'British Columbia' then 'BC'
when htlstate = 'Quebec' then 'PQ'
when htlstate = 'Nova Scotia' then 'NV'
when htlstate = 'Saskatchewan' then 'SK'
when htlstate = 'Manitoba' then 'MB'
when htlstate = 'New Brunswick' then 'NB'
when htlstate = 'Northwest Territorie' then 'NW'
end
where len(htlstate) > 2
and htlcountrycode in ('CA')
and MasterId is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL state CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

-------------------------------------
--    HNN Updates
-----------------------------------
UPDATE DBA.Hotel
SET HtlCityName = 'WASHINGTON' ,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL state DC',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update t1
set t1.htlstate = t2.stateprovincecode
from dba.hotel t1, dba.city t2
where t2.typecode = 'A'
and t1.htlcitycode = t2.citycode
and t1.htlcountrycode = t2.countrycode
and t1.htlstate is null
and t1.htlcountrycode = 'US'
and t2.countrycode = 'US'
and t1.MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL state City',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update t1
set t1.htlcountrycode = t2.countrycode
from dba.hotel t1, dba.city t2
where t2.typecode = 'A'
and t1.htlcitycode = t2.citycode
and t1.htlcountrycode <> t2.countrycode
and t1.htlcountrycode = 'US'
and t2.countrycode <> 'US'
and t1.MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL country',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update dba.hotel
set htlpostalcode = NULL
where LEN(HTLPOSTALCODE) < 5
and MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL postal code',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

--UPDATE DBA.HOTEL
--SET HTLSTATE = NULL
--WHERE HTLCOUNTRYCODE NOT IN ('US','CA')
--and MasterId is null

update dba.hotel
set htladdr1 = htladdr2
,htladdr2 = null
where htladdr1 is null
and htladdr2 is not null
and MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL addr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update dba.hotel
set htladdr2 = null
where htladdr2 = htladdr1
and MasterId is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTL addr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set id.servicedescription = ud.udefdata
from dba.invoicedetail id, dba.udef ud
where ud.udefnum = 143
and id.recordkey = ud.recordkey
and id.seqnum = ud.seqnum
and id.iatanum ='ORBITZ'
and ud.iatanum = 'ORBITZ'
and id.servicedescription is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Service description',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025','TPT-TP5913026','TPT-TP5913028','TPT-000938',
'TPT-TP5912997','TPT-TP5913012','TPT-TP5913037','TPT-TP5913033','TPT-TP5913100','TPT-TP5913036','TPT-TP5912979',
'TPT-TP5913040','TPT-TP5912966','TPT-TP5913043','TPT-TP5913079','TPT-TP5913061','TPT-TP5913073','TPT-TP5002100',
'TPT-TP5913092','TPT-TP5913087','TPT-TP5913076','TPT-TP5913203','TPT-TP5913201','TPT-TP5913212','TPT-TP5913205',
'TPT-TP5913217','TPT-TP5913220','TPT-TP5913229','TPT-TP5913224','TPT-TP5913228','TPT-TP5913237','TPT-TP5913241',
'TPT-TP5913222','TPT-TP5913234','TPT-TP5913258','000957','TPT-000957','TPT-TP5913257','001444','001438','TPT-TP5913047','TPT-TP5913284',
'TPT-TP5913286','TPT-TP5913207','TPT-TP5604000','TPT-TP5920006','TPT-TP5921006','TPT-TP5921008',
'TPT-TP5912907','TPT-TP5912959','TPT-TP5920015','TPT-TP5913271','TPT-TP5913072','TPT-TP5920029','TPT-TP521009','TPT-TP5921007',
'TPT-TP5920022','TPT-TP5921010','TPT-TP5003801','TPT-TP5003800','TPT-TP5920041','TPT-TP5920040','TPT-TP5302000','TPT-TP5402000',
'TPT-000325','000325','TPT-TP000115','000115','TPT-TP5913159','TPT-TP5907000','TPT-TP5912976','TPT-TP5913275','TPT-TP5913031','TPT-TP5920038',
'TPT-TP5920053','TPT-TP5920049','TPT-TP5920050','TPT-TP5920048','TPT-TP5920055')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025','TPT-TP5913026','TPT-TP5913028','TPT-000938',
'TPT-TP5912997','TPT-TP5913012','TPT-TP5913037','TPT-TP5913033','TPT-TP5913100','TPT-TP5913036','TPT-TP5912979',
'TPT-TP5913040','TPT-TP5912966','TPT-TP5913043','TPT-TP5913079','TPT-TP5913061','TPT-TP5913073','TPT-TP5002100',
'TPT-TP5913092','TPT-TP5913087','TPT-TP5913076','TPT-TP5913203','TPT-TP5913201','TPT-TP5913212','TPT-TP5913205',
'TPT-TP5913217','TPT-TP5913220','TPT-TP5913229','TPT-TP5913224','TPT-TP5913228','TPT-TP5913237','TPT-TP5913241',
'TPT-TP5913222','TPT-TP5913234','TPT-TP5913258','000957','TPT-000957','TPT-TP5913257','001444','001438','TPT-TP5913047','TPT-TP5913284',
'TPT-TP5913286','TPT-TP5913207','TPT-TP5604000','TPT-TP5920006','TPT-TP5921006','TPT-TP5921008',
'TPT-TP5912907','TPT-TP5912959','TPT-TP5920015','TPT-TP5913271','TPT-TP5913072','TPT-TP5920029','TPT-TP521009','TPT-TP5921007',
'TPT-TP5920022','TPT-TP5921010','TPT-TP5003801','TPT-TP5003800','TPT-TP5920041','TPT-TP5920040','TPT-TP5302000','TPT-TP5402000',
'TPT-000325','000325','TPT-TP000115','000115','TPT-TP5913159','TPT-TP5907000','TPT-TP5912976','TPT-TP5913275','TPT-TP5913031','TPT-TP5920038',
'TPT-TP5920053','TPT-TP5920049','TPT-TP5920050','TPT-TP5920048','TPT-TP5920055')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 100 a',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5101100','TPT-TP5101500','001556','001043','TPT-TP5101700','TPT-TP5101500','TPT-TP5003900','TPT-TP5202000','TPT-TP5106000','TPT-TP5912957',
'TPT-TP5209000','TPT-TP5208000','TPT-TP5303000','TPT-TP5405000','TPT-TP5403000','TPT-TP5003300','TPT-TP5002600',
'TPT-TP5409000','TPT-TP5301000','TPT-TP5503000','TPT-TP5601000','TPT-TP5508000','TPT-TP5603000','TPT-TP5407000',
'TPT-TP5608000','TPT-TP5609000','TPT-TP5601000','TPT-TP5101900','TPT-TP5609000','TPT-TP5609001','TPT-TP5609002',
'TPT-TP5609003','TPT-TP5609004','TPT-TP5401000','TPT-TP5704000','TPT-TP5706000','TPT-TP5703000' , 'TPT-TP5703001',
'TPT-TP5709000','TPT-TP5803000','TPT-TP5804000','TPT-TP5800000','TPT-TP5801000','TPT-TP5101600','TPT-TP5003600',
'TPT-TP5003301','TPT-TP5911400','TPT-TP5911000','TPT-TP5910100','TPT-TP5910800','TPT-TP5910801','TPT-TP5910802',
'TPT-TP5910803','TPT-TP5910804','TPT-001043','TPT-001444','TPT-001556','TPT-TP5912863','TPT-TP5911500','TPT-TP5912974',
'TPT-TP5912700','TPT-TP5500000','TPT-TP5912912','TPT-TP5912910','TPT-001772','TPT-TP5912889','TPT-TP5912910',
'TPT-TP5912852','TPT-TP5912926','TPT-TP5912883','TPT-TP5912927','TPT-TP5911700','TPT-TP5912921','TPT-TP5912950',
'TPT-TP5912854','TPT-TP5912962','TPT-TP5912960','TPT-TP5912971','TPT-TP5912977','TPT-TP591298','TPT-TP5906000',
'TPT-TP5912983','TPT-TP5912988','TPT-TP5912999','TPT-TP5913004','TPT-TP5913005','TPT-TP5913008','TPT-TP5912998',
'TPT-TP5913014','TPT-TP5912818','TPT-TP5912961','TPT-TP5913011','TPT-TP5913016','TPT-TP5913018','TPT-TP5913019',
'TPT-TP5921005')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5101100','TPT-TP5101500','001556','001043','TPT-TP5101700','TPT-TP5101500','TPT-TP5003900','TPT-TP5202000','TPT-TP5106000','TPT-TP5912957',
'TPT-TP5209000','TPT-TP5208000','TPT-TP5303000','TPT-TP5405000','TPT-TP5403000','TPT-TP5003300','TPT-TP5002600',
'TPT-TP5409000','TPT-TP5301000','TPT-TP5503000','TPT-TP5601000','TPT-TP5508000','TPT-TP5603000','TPT-TP5407000',
'TPT-TP5608000','TPT-TP5609000','TPT-TP5601000','TPT-TP5101900','TPT-TP5609000','TPT-TP5609001','TPT-TP5609002',
'TPT-TP5609003','TPT-TP5609004','TPT-TP5401000','TPT-TP5704000','TPT-TP5706000','TPT-TP5703000' , 'TPT-TP5703001',
'TPT-TP5709000','TPT-TP5803000','TPT-TP5804000','TPT-TP5800000','TPT-TP5801000','TPT-TP5101600','TPT-TP5003600',
'TPT-TP5003301','TPT-TP5911400','TPT-TP5911000','TPT-TP5910100','TPT-TP5910800','TPT-TP5910801','TPT-TP5910802',
'TPT-TP5910803','TPT-TP5910804','TPT-001043','TPT-001444','TPT-001556','TPT-TP5912863','TPT-TP5911500','TPT-TP5912974',
'TPT-TP5912700','TPT-TP5500000','TPT-TP5912912','TPT-TP5912910','TPT-001772','TPT-TP5912889','TPT-TP5912910',
'TPT-TP5912852','TPT-TP5912926','TPT-TP5912883','TPT-TP5912927','TPT-TP5911700','TPT-TP5912921','TPT-TP5912950',
'TPT-TP5912854','TPT-TP5912962','TPT-TP5912960','TPT-TP5912971','TPT-TP5912977','TPT-TP591298','TPT-TP5906000',
'TPT-TP5912983','TPT-TP5912988','TPT-TP5912999','TPT-TP5913004','TPT-TP5913005','TPT-TP5913008','TPT-TP5912998',
'TPT-TP5913014','TPT-TP5912818','TPT-TP5912961','TPT-TP5913011','TPT-TP5913016','TPT-TP5913018','TPT-TP5913019',
'TPT-TP5921005')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 100 b',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913024','TPT-TP5913041','TPT-TP5912981','TPT-TP5306002','TPT-TP5913077','TPT-TP5913231',
'TPT-TP4003400','TPT-TP5101400','TPT-TP4002004','TPT-TP5101600','TPT-TP5106000','TPT-TP5200000',
'TPT-TP5003500','TPT-TP5003501','TPT-TP5306000','TPT-TP5910300','TPT-TP5002701','TPT-TP5002700',
'TPT-001438','TPT-TP5912946','TPT-TP5910500','TPT-TP5912939','TPT-TP5911100','TPT-001338','TPT-TP5913086','TPT-TP5920008',
'TPT-TP5920018','TPT-TP5920007','TPT-0000217716', 'TPT-217716','TPT-TP5913291','TPT-TP5920026','TPT-TP5921009')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913024','TPT-TP5913041','TPT-TP5912981','TPT-TP5306002','TPT-TP5913077','TPT-TP5913231',
'TPT-TP4003400','TPT-TP5101400','TPT-TP4002004','TPT-TP5101600','TPT-TP5106000','TPT-TP5200000',
'TPT-TP5003500','TPT-TP5003501','TPT-TP5306000','TPT-TP5910300','TPT-TP5002701','TPT-TP5002700',
'TPT-001438','TPT-TP5912946','TPT-TP5910500','TPT-TP5912939','TPT-TP5911100','TPT-001338','TPT-TP5913086','TPT-TP5920008',
'TPT-TP5920018','TPT-TP5920007','TPT-0000217716', 'TPT-217716','TPT-TP5913291','TPT-TP5920026','TPT-TP5921009')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 101',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912880','TPT-TP5005000','TPT-TP5105000','TPT-TP5201000','TPT-TP5912821','TPT-TP5912822',
'TPT-TP5912936','TPT-TP5912911','TPT-TP5913208','TPT-TP5913278','TPT-TP5920030','TPT-TP5920031','TPT-TP5920032','TPT-TP5920033','TPT-TP5920034','TPT-TP5920035','TPT-TP5920036','TPT-TP5920037')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912880','TPT-TP5005000','TPT-TP5105000','TPT-TP5201000','TPT-TP5912821','TPT-TP5912822',
'TPT-TP5912936','TPT-TP5912911','TPT-TP5913208','TPT-TP5913278','TPT-TP5920030','TPT-TP5920031','TPT-TP5920032','TPT-TP5920033','TPT-TP5920034','TPT-TP5920035','TPT-TP5920036','TPT-TP5920037')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 102',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5900000','TP5912909','TPT-TP5912909','TPT-000173','TPT-TP5920001','TPT-TP5920042')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 103
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5900000','TP5912909','TPT-TP5912909','TPT-000173','TPT-TP5920001','TPT-TP5920042')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 103',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913088','000950','TPT-TP52004000','TPT-000867')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 104
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913088','000950','TPT-TP52004000','TPT-000867')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-001327','TPT-TP5002702')
and id.recordkey = ud.recordkey
and ud.udefnum = 120
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-001327','TPT-TP5002702')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 120',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 124
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912925')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 124',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5306001')
and id.recordkey = ud.recordkey
----and id.seqnum = ud.seqnum
and ud.udefnum = 105
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5306001')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Dept 105',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




SET @TransStart = getdate()
---duplicate document numbers updated to void ind ='D' where one has documentnumber and one does not

update dba.invoicedetail
set voidind='D'
from dba.invoicedetail i
 where exists (select 1 from  
 dba.invoicedetail iSUB 
 WHERE iSUB.recordkey = i.recordkey
	and isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	and isub.documentnumber is not null 
	 AND isub.exchangeind = 'N' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='N'
	and isub.routing=i.routing
	and isub.iatanum='orbitz'
	and valcarriercode<>'WN'
	)
and 
i.issuedate >= '2013-01-01' 
 AND i.exchangeind = 'N' 
and i.vendortype in ('bsp','nonbsp') 
 AND i.voidind = 'N' 
 and i.refundind='n'
 and i.documentnumber is null
 and iatanum='orbitz'
 and valcarriercode<>'wn'
 
 
 --- identify duplicates where documentnumbers are the same and routing the same
 --and one sent in daily feed, the other in weekly feed. Use of tktco2 emissions 
 update dba.invoicedetail
set voidind='D'
from dba.invoicedetail i
 where exists (select 1 from  
 dba.invoicedetail iSUB 
 WHERE iSUB.recordkey = i.recordkey
	and isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.documentnumber =i.documentnumber
	and isub.routing=i.routing
	--and isub.servicedescription is not null
	and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	 and isub.tktco2emissions is not null
	 AND isub.exchangeind = 'N' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='n'
	and iatanum='orbitz' and isub.valcarriercode<>'WN'
	)
and 
i.issuedate >= '2013-01-01' 
 AND i.exchangeind = 'N' 
and i.vendortype in ('bsp','nonbsp') 
 AND i.voidind = 'N' 
 --and i.servicedescription is null
 and i.tktco2emissions is null
 and i.refundind='n'
 and i.iatanum='orbitz'
 and i.documentnumber is not null
 and i.valcarriercode<>'wn'
 
 ---duplicates when multiple exchanges on a tkt - setting earliest itin id to void=D
 --case #39163
  update dba.invoicedetail
set voidind='D'
   from dba.invoicedetail i
 where exists (select 1 from  
 dba.invoicedetail iSUB 
 WHERE iSUB.recordkey = i.recordkey
	and isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.documentnumber =i.documentnumber
	and isub.routing=i.routing
		and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	and isub.OrigExchTktNum=i.origexchtktnum
	and isub.remarks3>i.Remarks3 --remarks 3=orbitz itin_hist.id
	 AND isub.exchangeind = 'Y' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='n'
	and iatanum='orbitz' and isub.valcarriercode<>'WN'
	)
and 
i.issuedate >= '2013-01-01' 
 AND i.exchangeind = 'Y' 
and i.vendortype in ('bsp','nonbsp') 
 AND i.voidind = 'N' 
 and i.refundind='N'
 and i.iatanum='orbitz'
 and i.documentnumber is not null
 and i.valcarriercode<>'wn'
 
 
 --- identify duplicates where documentnumbers are the same but record keys are diff
--keeping record with earliest issuedate
update dba.invoicedetail
set voidind='D'
from dba.invoicedetail i
 where exists (select 15 from  
 dba.invoicedetail iSUB 
 WHERE 
 --iSUB.recordkey = i.recordkey
	 isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.documentnumber =i.documentnumber
	and isub.lastname=i.lastname
	and isub.firstname=i.firstname
    AND isub.exchangeind = 'N' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='n'
	and iatanum='orbitz' and isub.valcarriercode<>'WN'
	and isub.INVOICEDate<i.iNVOICEDate
	--and isub.invoicetype='cx'
)
and 
i.issuedate >= '2013-01-01' 
AND i.exchangeind = 'N' 
and i.vendortype in ('bsp','nonbsp') 
AND i.voidind = 'N' 
and i.refundind='n'
and i.iatanum='orbitz'
and i.documentnumber is not null
and i.valcarriercode<>'wn'

--setting VoidInd to D when duplicate exchange transactions are sent with identical data

update i
set VoidInd='D' from 
 dba.InvoiceDetail i
  where  i.RecordKey in (
 select recordkey
 from dba.InvoiceDetail
 where IataNum='orbitz'
 and VoidInd='n'
 and ExchangeInd='Y'
 and IssueDate>='2013-01-01'
 and valcarriercode<>'WN'
  and DocumentNumber<>'0000000000'
  and RefundInd='N'
  and vendortype in ('bsp','nonbsp') 
 group by RecordKey,IataNum,ClientCode,IssueDate,DocumentNumber,totalamt,routing,Lastname,firstname
 having count(*)>=2)
 and i.Mileage <0
 and i.IataNum='orbitz'
 and i.VoidInd='n'
 and i.ExchangeInd='Y'
 and i.IssueDate>='2013-01-01'
 and i.valcarriercode<>'WN'
 and i.DocumentNumber<>'0000000000'
   and RefundInd='N'
and i.vendortype in ('bsp','nonbsp') 

--setting VoidInd to D when duplicate transactions/tickets are sent with identical data
update i
set VoidInd='D' from 
 dba.InvoiceDetail i
  where  i.RecordKey in (select RecordKey
 from dba.InvoiceDetail i
 where IataNum='orbitz'
 and i.VoidInd='n'
 and i.ExchangeInd='n'
 and i.IssueDate>='2013-01-01'
 and i.valcarriercode<>'WN'
  and i.DocumentNumber<>'0000000000'
  and i.RefundInd='N'
  and i.vendortype in ('bsp','nonbsp') 
  and i.ProductType<>'rail'
 group by RecordKey,IataNum,ClientCode,IssueDate,lastname,firstname,DocumentNumber,totalamt,routing,remarks2
 having count(*)>=2)
 and i.IataNum='orbitz'
 and i.VoidInd='n'
 and i.ExchangeInd='n'
 and i.IssueDate>='2013-01-01'
 and i.valcarriercode<>'WN'
 and i.DocumentNumber<>'0000000000'
   and RefundInd='N'
    and i.vendortype in ('bsp','nonbsp') 
    and i.ProductType<>'rail'
 and RecordKey + cast(SeqNum as VARCHAR)in
 (select 
RecordKey + cast(max(SeqNum) as VARCHAR)
 from dba.InvoiceDetail
 where IataNum='orbitz'
 and VoidInd='n'
 and ExchangeInd='n'
 and IssueDate>='2013-01-01'
 and valcarriercode<>'WN'
  and DocumentNumber<>'0000000000'
  and RefundInd='N'
  and vendortype in ('bsp','nonbsp') 
  and ProductType<>'rail'
 group by RecordKey,IataNum,ClientCode,IssueDate,lastname,firstname,DocumentNumber,totalamt,routing,remarks2
 having count(*)>=2) 


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Duplicates marked as D',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---HarteHanks updating Southwest bookings to the credit card Orbitz says they should be on
--so the records can be picked up in the Airplus weekly feed. #46389 9/25/2014 KP

SET @TransStart = getdate()
update pay
set ccnum='80264'
 from dba.InvoiceDetail id,
 dba.Payment pay
 where Remarks2 like 'AP67%'
and id.ClientCode='TPT-TP5920019'
and VendorType in ('bsp','nonbsp')
and ValCarrierCode='WN'
and id.RecordKey=pay.RecordKey
and id.IataNum=pay.IataNum
and id.ClientCode=pay.ClientCode
and id.SeqNum=pay.seqnum
and pay.CCNum<>'80264'


update ih
set ccnum='80264'
 from dba.InvoiceDetail id,
 dba.InvoiceHeader ih
 where Remarks2 like 'AP67%'
and id.ClientCode='TPT-TP5920019'
and VendorType in ('bsp','nonbsp')
and ValCarrierCode='WN'
and id.RecordKey=ih.RecordKey
and id.IataNum=ih.IataNum
and id.ClientCode=ih.ClientCode
and ih.CCNum<>'80264'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Harte Hanks Updates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()

--HNN added to OFB daily per Sue's recommendation on 7/29/2014 to deal with variance in 
--times the daily file is being sent.
--add to the end after HNN cleanup sql's run
--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from  TTXPASQL01.TMAN503_ORBITZ.dba.Hotel
Where MasterId is NULL
and issuedate >'2013-01-01'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'OFB',
@Enhancement = 'HNN',
@Client = 'ORBITZ',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNBeginDate,
@EndDate = @HNNEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'agency',
@TextParam2 = 'TTXPASQL01',
@TextParam3 = 'TMAN503_ORBITZ',
@TextParam4 = 'DBA',
@TextParam5 = 'datasvc',
@TextParam6 = 'tman2009',
@TextParam7 = 'TTXSASQL03',
@TextParam8 = 'TTXCENTRAL',
@TextParam9 = 'DBA',
@TextParam10 = 'datasvc',
@TextParam11 = 'tman2009',
@TextParam12 = 'Push',
@TextParam13 = 'R',
@TextParam14 = NULL,
@TextParam15 = NULL,
@IntParam1 = NULL,
@IntParam2 = NULL,
@IntParam3 = NULL,
@IntParam4 = NULL,
@IntParam5 = NULL,
@BoolParam1 = NULL,
@BoolParam2 = NULL,
@BoolParam3 = NULL,
@BoolParam4 = NULL,
@BoolParam5 = NULL,
@BoolParam6 = NULL,
@BoolParam7 = NULL,
@BoolParam8 = NULL,
@BoolParam9 = NULL,
@BoolParam10 = NULL,
@CommandLineArgs = NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HNN kickoff',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

--This executes sp to transfer OpenX data to MC tables #27639
--per Orbitz/openx this has been removed 3/1/2014 no longer want to pursue the project
--New client USF sending data to MC #33819 - ck with Brian Perry for any errors
EXEC [ATL892].[TMAN503_MC_TMC].dbo.sp_MCTMC_postImport_MCORUS NULL, NULL


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='MC sp executed',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


GO
