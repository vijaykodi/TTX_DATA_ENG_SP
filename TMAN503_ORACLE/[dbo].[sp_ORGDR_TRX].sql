/****** Object:  StoredProcedure [dbo].[sp_ORGDR_TRX]    Script Date: 7/14/2015 8:12:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_ORGDR_TRX]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime
	
 AS
 
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'ORGDR'
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
update car
set car.issuedate = id.issuedate
from dba.car car, dba.invoicedetail id
where id.issuedate <> car.issuedate
and id.recordkey = car.recordkey
and id.seqnum = car.seqnum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set car.issuedate = id.issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update car
set car.issuedate = id.issuedate
from dba.hotel car, dba.invoicedetail id
where id.issuedate <> car.issuedate
and id.recordkey = car.recordkey
and id.seqnum = car.seqnum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set car.issuedate = id.issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
WHERE IataNum = 'ORGDR' 
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE IataNum = 'ORGDR')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks FROM dba.InvoiceDetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.Hotel
WHERE IataNum = 'ORGDR' 
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE IataNum = 'ORGDR')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks FROM dba.Hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.Car
WHERE IataNum = 'ORGDR' 
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE IataNum = 'ORGDR')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks FROM dba.Car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--update text50 from invoiceheader country
update cr
set cr.text50 = ih.origcountry,
cr.text49 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where cr.text50 is null
and cr.recordkey = ih.recordkey
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text50 = ih.origcountry',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--update countrycode MEA from udef 15 --added 12/13/07
--stopped per Brian 4/09
--update ih
--set ih.origcountry = ct.countrycode
--from dba.udef ud, dba.city ct, dba.invoiceheader ih
--where ud.clientcode in ('174EG1','NLD','174/EG')
--and ud.invoicedate > '2007-08-31'
--and ud.udefnum = 15
--and ct.citycode = ud.udefdata
--and ct.typecode ='A'
--and ih.recordkey = ud.recordkey
--and  ih.origcountry <> ct.countrycode


SET @TransStart = getdate()
update cr
set cr.text50 = ct.countrycode
from dba.udef ud, dba.city ct, dba.comrmks cr
where ud.clientcode in ('174EG1','NLD','174/EG')
and ud.invoicedate > '2007-08-31'
and ud.udefnum = 15
and ct.citycode = ud.udefdata
and ct.typecode ='A'
and cr.recordkey = ud.recordkey
and cr.text50 <> ct.countrycode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text50 = ct.countrycode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



---LATAM Country codes from udef 15 added 12/13/07
--stopeed per Brian 4/09
--update ih
--set ih.origcountry = left(ud.udefdata,2)
--from dba.udef ud, dba.invoiceheader ih
--where ud.clientcode in ( 'U1BUHUS1','BUH-US/US')
--and ud.invoicedate > '2007-08-31'
--and ud.udefnum = 15
--and ih.recordkey = ud.recordkey
--and ih.origcountry <> left(ud.udefdata,2)
--and ud.udefdata not like 'ORACLE LATIN%'


SET @TransStart = getdate()
update cr
set cr.text50 = left(ud.udefdata,2)
from dba.udef ud, dba.comrmks cr
where ud.clientcode in ( 'U1BUHUS1','BUH-US/US')
and ud.invoicedate > '2007-08-31'
and ud.udefnum = 15
and cr.recordkey = ud.recordkey
and  cr.text50 <> left(ud.udefdata,2)
and ud.udefdata not like 'ORACLE LATIN%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text50 = left(ud.udefdata,2)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--stopped per Brian 4/09
--update ih
--set ih.origcountry = 'BR'
--from dba.udef ud, dba.invoiceheader ih
--where ud.clientcode in ( 'U1BUHUS1','BUH-US/US')
--and ud.invoicedate > '2007-08-31'
--and ud.udefnum = 15
--and ih.recordkey = ud.recordkey
--and ih.origcountry <> left(ud.udefdata,2)
--and ud.udefdata like 'ORACLE LATIN%'


SET @TransStart = getdate()
update cr
set cr.text50 = 'BR'
from dba.udef ud, dba.comrmks cr
where ud.clientcode in ( 'U1BUHUS1','BUH-US/US')
and ud.invoicedate > '2007-08-31'
and ud.udefnum = 15
and cr.recordkey = ud.recordkey
--and  cr.text50 <> left(ud.udefdata,2)
and ud.udefdata like 'ORACLE LATIN%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text50 = BR',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--select ih.importdt,id.issuedate, id.lastname,id.firstname
--stopped per Brian 4/09
--update ih
--set ih.origcountry ='AR'
--from dba.invoicedetail id,dba.invoiceheader ih
--where ih.origcountry ='BR'
--and id.recordkey = ih.recordkey
--and id.lastname = 'BARMAT'
--and id.firstname = 'DANIEL'

---Oracle Country


SET @TransStart = getdate()
update cr
set cr.text1 = ud1.udefdata
from dba.comrmks cr,dba.udef ud1
where cr.iatanum ='ORGDR'
and ud1.iatanum = 'ORGDR'
and cr.recordkey = ud1.recordkey
and cr.issuedate = ud1.issuedate
and cr.seqnum = ud1.seqnum
and ud1.udefnum = 1
--and cr.clientcode ='174EG1'
and cr.text1 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text1 = ud1.udefdata',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE CR
SET Text1 = CASE
  WHEN IH.OrigCOuntry = ('US') THEN '001'
WHEN IH.OrigCOuntry = ('CA') THEN '040' 
WHEN IH.OrigCOuntry = ('AR') THEN '044' 
WHEN IH.OrigCOuntry = ('BR') THEN '062'
WHEN IH.OrigCOuntry = ('MX') THEN '061' 
WHEN IH.OrigCOuntry = ('CL') THEN '041' 
WHEN IH.OrigCOuntry = ('PE') THEN '04E'
WHEN IH.OrigCOuntry = ('VE') THEN '059' 
WHEN IH.OrigCOuntry = ('CO') THEN '045' 
WHEN IH.OrigCOuntry = ('CR') THEN '056'
WHEN IH.OrigCOuntry = ('PR') THEN '055' 
WHEN IH.OrigCOuntry = ('AU') THEN '060' 
WHEN IH.OrigCOuntry = ('CN') THEN '054'
WHEN IH.OrigCOuntry = ('HK') THEN '052' 
WHEN IH.OrigCOuntry = ('IN') THEN '05D' 
WHEN IH.OrigCOuntry = ('ID') THEN '039'
WHEN IH.OrigCOuntry = ('JP') THEN '050' 
WHEN IH.OrigCOuntry = ('KR') THEN '058' 
WHEN IH.OrigCOuntry = ('MY') THEN '051'
WHEN IH.OrigCOuntry = ('NZ') THEN '067' 
WHEN IH.OrigCOuntry = ('PH') THEN '046' 
WHEN IH.OrigCOuntry = ('SG') THEN '066'
WHEN IH.OrigCOuntry = ('TW') THEN '047' 
WHEN IH.OrigCOuntry = ('TH') THEN '053' 
WHEN IH.OrigCOuntry = ('AT') THEN '011'
WHEN IH.OrigCOuntry = ('BE') THEN '012' 
WHEN IH.OrigCOuntry = ('CZ') THEN '04X' 
WHEN IH.OrigCOuntry = ('HR') THEN '02N'
WHEN IH.OrigCOuntry = ('DK') THEN '013' 
WHEN IH.OrigCOuntry = ('EG') THEN '08U' 
WHEN IH.OrigCOuntry = ('FI') THEN '014'
WHEN IH.OrigCOuntry = ('FR') THEN '032' 
WHEN IH.OrigCOuntry = ('DE') THEN '020' 
WHEN IH.OrigCOuntry = ('GR') THEN '063'
WHEN IH.OrigCOuntry = ('HU') THEN '022' 
WHEN IH.OrigCOuntry = ('IE') THEN '031' 
WHEN IH.OrigCOuntry = ('IT') THEN '048'
WHEN IH.OrigCOuntry = ('IL') THEN '08R' 
WHEN IH.OrigCOuntry = ('NL') THEN '015' 
WHEN IH.OrigCOuntry = ('NO') THEN '016'
WHEN IH.OrigCOuntry = ('PL') THEN '023'
WHEN IH.OrigCOuntry = ('PT') THEN '057' 
WHEN IH.OrigCOuntry = ('RU') THEN '10B' 
WHEN IH.OrigCOuntry = ('ES') THEN '017'
WHEN IH.OrigCOuntry = ('SK') THEN '037' 
WHEN IH.OrigCOuntry = ('SI') THEN '029' 
WHEN IH.OrigCOuntry = ('SE') THEN '018'
WHEN IH.OrigCOuntry = ('CH') THEN '019' 
WHEN IH.OrigCOuntry = ('GB') THEN '030' 
WHEN IH.OrigCOuntry = ('UK') THEN '030'
WHEN IH.OrigCOuntry = ('TR') THEN '042' 
WHEN IH.OrigCOuntry = ('ZA') THEN '070' 
WHEN IH.OrigCOuntry = ('SA') THEN '008'
WHEN IH.OrigCOuntry = ('EE') THEN '02F' 
WHEN IH.OrigCOuntry = ('BG') THEN '02A' 
WHEN IH.OrigCOuntry = ('BA') THEN '02P'
WHEN IH.OrigCOuntry = ('CY') THEN '08X' 
WHEN IH.OrigCOuntry = ('KZ') THEN '10C' 
WHEN IH.OrigCOuntry = ('LV') THEN '02E'
WHEN IH.OrigCOuntry = ('LT') THEN '02D' 
WHEN IH.OrigCOuntry = ('RO') THEN '10E' 
WHEN IH.OrigCOuntry = ('UA') THEN '10D'
WHEN IH.OrigCOuntry = ('AE') THEN '069' 
WHEN IH.OrigCOuntry = ('PK') THEN '05F' 
WHEN IH.OrigCOuntry = ('LK') THEN '04T'

ELSE IH.OrigCountry
END
FROM DBA.InvoiceHeader IH, DBA.ComRmks CR
WHERE IH.IataNum = CR.Iatanum
AND IH.ClientCode = CR.ClientCode
AND IH.RecordKey = CR.RecordKey
AND CR.TEXT1 IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='SET Text1 = CASE',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--LOB daily countries
update cr
set cr.text2 = ud5.udefdata
from dba.comrmks cr,dba.udef ud5
where cr.iatanum ='ORGDR'
and ud5.iatanum = 'ORGDR'
and cr.recordkey = ud5.recordkey
and cr.issuedate = ud5.issuedate
and cr.seqnum = ud5.seqnum
and ud5.udefnum = 5
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='LOB daily countries',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text2 = ud5.udefdata
from dba.comrmks cr,dba.udef ud5
where cr.iatanum ='ORGDR'
and ud5.iatanum = 'ORGDR'
and cr.recordkey = ud5.recordkey
and cr.issuedate = ud5.issuedate
and cr.seqnum = ud5.seqnum
and ud5.udefnum = 5
and cr.clientcode  in ('174EG1','NLD','174/EG')
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text2 = ud5.udefdata',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--LOB for non-daily countries
update cr
set cr.text2 = ud99.udefdata
from dba.comrmks cr,dba.udef ud99,dba.invoiceheader ih
where cr.iatanum ='ORGDR'
and ud99.iatanum = 'ORGDR'
and cr.recordkey = ud99.recordkey
and cr.issuedate = ud99.issuedate
and cr.seqnum = ud99.seqnum
and ud99.udefnum = 99
and ih.origcountry not in ('AT','AU','BE','BR','CA','CH','DE','DK','ES','FR','GB','IT','NL','SE','US')
and ih.recordkey = cr.recordkey
and ih.recordkey = ud99.recordkey
and ih.iatanum ='ORGDR'
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='LOB for non-daily countries',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--update LOB ending in 0 per Brian added 6/26/08
update dba.comrmks
set text2 = substring(text2,1,2)+'9'
where issuedate > '2007-06-06'
and iatanum = 'ORGDR'
and substring(text2,3,1) = '0'
and text2 not in ('A00','000')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update LOB ending in 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--cost center daily countries
update cr
set cr.text3 = right(ud6.udefdata,6)
from dba.comrmks cr,dba.udef ud6
where cr.iatanum ='ORGDR'
and ud6.iatanum = 'ORGDR'
and cr.recordkey = ud6.recordkey
and cr.issuedate = ud6.issuedate
and cr.seqnum = ud6.seqnum
and ud6.udefnum = 6
and cr.text3 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='cost center daily countries',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text3 = right(ud6.udefdata,6)
from dba.comrmks cr,dba.udef ud6
where cr.iatanum ='ORGDR'
and ud6.iatanum = 'ORGDR'
and cr.recordkey = ud6.recordkey
and cr.issuedate = ud6.issuedate
and cr.seqnum = ud6.seqnum
and ud6.udefnum = 6
and cr.clientcode in ('174EG1','NLD','174/EG')
and cr.text3 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text3 = right(ud6.udefdata,4)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--cost center NOT daily countries
update cr
set cr.text3 = RIGHT(ud98.udefdata,6)
from dba.comrmks cr,dba.udef ud98,dba.invoiceheader ih
where cr.iatanum ='ORGDR'
and ud98.iatanum = 'ORGDR'
and cr.recordkey = ud98.recordkey
and cr.issuedate = ud98.issuedate
and cr.seqnum = ud98.seqnum
and ud98.udefnum = 98
and ih.origcountry not in ('AT','AU','BE','BR','CA','CH','DE','DK','ES','FR','GB','IT','NL','SE','US')
and ih.recordkey = cr.recordkey
and ih.recordkey = ud98.recordkey
and ih.iatanum ='ORGDR'
and cr.text3 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='cost center NOT daily countries',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--employee
--NL Reversed prior to 11/06/06
update cr
set cr.text4 = ud1.udefdata
from dba.comrmks cr,dba.udef ud1
where cr.iatanum ='ORGDR'
and ud1.iatanum = 'ORGDR'
and cr.recordkey = ud1.recordkey
and cr.issuedate = ud1.issuedate
and cr.seqnum = ud1.seqnum
and ud1.udefnum = 1
and cr.text4 is null
and cr.clientcode in ('6055NL1','7660NL1','GTV','174/NL')
and cr.issuedate < '2006-11-06'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='NL Reversed',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
-- employee after NL update
update cr
set cr.text4 = ud2.udefdata
from dba.comrmks cr,dba.udef ud2
where cr.iatanum ='ORGDR'
and ud2.iatanum = 'ORGDR'
and cr.recordkey = ud2.recordkey
and cr.issuedate = ud2.issuedate
and cr.seqnum = ud2.seqnum
and ud2.udefnum = 2
and cr.text4 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='employee after NL update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Career Level
update cr
set cr.text7 = ud4.udefdata
from dba.comrmks cr,dba.udef ud4
where cr.iatanum ='ORGDR'
and ud4.iatanum = 'ORGDR'
and cr.recordkey = ud4.recordkey
and cr.issuedate = ud4.issuedate
and cr.seqnum = ud4.seqnum
and ud4.udefnum = 4
and cr.text7 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Career Level',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Purpose of Trip
update cr
set cr.text8 = substring(ud3.udefdata,1,2)
from dba.comrmks cr,dba.udef ud3
where cr.iatanum ='ORGDR'
and ud3.iatanum = 'ORGDR'
and cr.recordkey = ud3.recordkey
and cr.issuedate = ud3.issuedate
and cr.seqnum = ud3.seqnum
and ud3.udefnum = 3
and cr.text8 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Purpose of Trip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Global ID US--U1JXFUS1 after 12/5/06
update cr
set cr.text9 = ud7.udefdata
from dba.comrmks cr,dba.udef ud7
where cr.iatanum ='ORGDR'
and ud7.iatanum = 'ORGDR'
and cr.recordkey = ud7.recordkey
and cr.issuedate = ud7.issuedate
and cr.seqnum = ud7.seqnum
and ud7.udefnum = 7
and cr.text9 is null
and cr.clientcode in ('U1JXFUS1','JXF-US/US')
and cr.issuedate >'2006-12-05'
and ud7.clientcode in ('U1JXFUS1','JXF-US/US')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Global ID US--U1JXFUS1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--trip purpose
update cr
set cr.text8 = ud3.udefdata
from dba.comrmks cr,dba.udef ud3
where cr.iatanum ='ORGDR'
and ud3.iatanum = 'ORGDR'
and cr.recordkey = ud3.recordkey
and cr.issuedate = ud3.issuedate
and cr.seqnum = ud3.seqnum
and ud3.udefnum = 3
and cr.text8 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='trip purpose',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Global ID US--U1JXFUS1 between 9/18-12/5/06
update cr
set cr.text9 = ud12.udefdata
from dba.comrmks cr,dba.udef ud12
where cr.iatanum ='ORGDR'
and ud12.iatanum = 'ORGDR'
and cr.recordkey = ud12.recordkey
and cr.issuedate = ud12.issuedate
and cr.seqnum = ud12.seqnum
and ud12.udefnum = 12
and cr.text9 is null
and cr.clientcode in ('U1JXFUS1','JXF-US/US')
and cr.issuedate between '2006-09-18' and '2006-12-05'
and ud12.clientcode in ('U1JXFUS1','JXF-US/US')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Global ID US--U1JXFUS1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Global ID Not US--U1JXFUS1
update cr
set cr.text9 = ud7.udefdata
from dba.comrmks cr,dba.udef ud7
where cr.iatanum ='ORGDR'
and ud7.iatanum = 'ORGDR'
and cr.recordkey = ud7.recordkey
and cr.issuedate = ud7.issuedate
and cr.seqnum = ud7.seqnum
and ud7.udefnum = 7
and cr.text9 is null
and cr.clientcode not in ('U1JXFUS1','JXF-US/US')
and ud7.clientcode not in ('U1JXFUS1','JXF-US/US')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Global ID Not US--U1JXFUS1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--US Department
update cr
set cr.text10 = ud14.udefdata
from dba.comrmks cr,dba.udef ud14
where cr.iatanum ='ORGDR'
and ud14.iatanum = 'ORGDR'
and cr.recordkey = ud14.recordkey
and cr.issuedate = ud14.issuedate
and cr.seqnum = ud14.seqnum
and ud14.udefnum = 14
and cr.text10 is null
and cr.clientcode in ('U1JXFUS1','JXF-US/US')
and ud14.clientcode in ('U1JXFUS1','JXF-US/US')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='US Department',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--US DeptName
update cr
set cr.text11 = ud15.udefdata
from dba.comrmks cr,dba.udef ud15
where cr.iatanum ='ORGDR'
and ud15.iatanum = 'ORGDR'
and cr.recordkey = ud15.recordkey
and cr.issuedate = ud15.issuedate
and cr.seqnum = ud15.seqnum
and ud15.udefnum = 15
and cr.text11 is null
and cr.clientcode in ('U1JXFUS1','JXF-US/US')
and ud15.clientcode in ('U1JXFUS1','JXF-US/US')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='US DeptName',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Project Code (added by JMesser 04/29/2008)
update cr
set cr.text12 = ud10.udefdata
from dba.comrmks cr,dba.udef ud10
where cr.iatanum ='ORGDR'
and ud10.iatanum = 'ORGDR'
and cr.recordkey = ud10.recordkey
and cr.issuedate = ud10.issuedate
and cr.seqnum = ud10.seqnum
and ud10.udefnum = 10
and cr.text12 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Project Code',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--manager hierarchy
update dba.comrmks
set text5 = text1+text3
where iatanum ='ORGDR'
and text5 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='manager hierarchy',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.comrmks
set text6 = 'C'+text5
where iatanum ='ORGDR'
and text6 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text6 = C+text5',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text50 = ih.countrycode
from dba.comrmks cr, dba.client ih
where cr.iatanum in ('ORGDR')
and ih.iatanum in ('ORGDR')
and cr.clientcode = ih.clientcode
and cr.text50 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text50 = ih.countrycode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory = 'A'
and valcarriercode ='AC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = AC',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- commented out 12/10/13 until dba.employee corrected
-- added back per Gary 1/7/14
---case 25428

--Step 1 we copy the GEID from text 9 to text20, then we check the validity of the GEID and if it is invalid, it is updated with 9999999999

update dba.comrmks
set text20 = text9
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text20 is null

update dba.comrmks
set text9 = '9999999999',
text26 = 'UPDATED'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text9 is null

update dba.comrmks
set text9 = '9999999999',
text26 = 'UPDATED'
from dba.comrmks
where iatanum = 'ORGDR'
and issuedate > '2012-01-01' 
and text9 <> '9999999999'
and RIGHT('000000000000000'+text9,15) not in (select RIGHT('000000000000000'+globalemployeeid,15) from dba.employee)

--Step 2 line of business is copied from text 2 to text 22 then validated. If not valid, then based on the GEID it is updated and the invalid records are replaced with null

update dba.comrmks
set text22 = text2
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text22 is null
 
update dba.comrmks
set text2 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text2 is null
 
update dba.comrmks
set text2 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text2 <> 'UNKNOWN'
and text2 not in (select distinct lineofbusiness from dba.employee)
 
update cr
set cr.text2 = em.lineofbusiness,
cr.text26 = 'UPDATED'
from dba.comrmks cr, dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text2 = 'UNKNOWN'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  dba.comrmks
set text2 = NULL
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text2 = 'UNKNOWN'
--Step 3 the same for cost center, copied from text 3 to text 23 then validated. If not valid, then based on the GEID it is updated and the invalid records are replaced with null

update dba.comrmks
set text23 = text3
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text23 is null
 
update dba.comrmks
set text3 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text3 is null 

update dba.comrmks
set text3 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and Right('000000'+text3,6) not in (select distinct Right('000000'+costcenter,6) from dba.employee)
and Text3 <> 'UNKNOWN'


update cr
set cr.text3 = em.costcenter,
cr.text26 = 'UPDATED'
from dba.comrmks cr, dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text3 = 'UNKNOWN'
and cr.Text7 not in ('N0','C0','NH','NO','CO')
and cr.Text9 <> '9999999999'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  dba.comrmks
set text3 = NULL
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text3 = 'UNKNOWN'
--Step 4 is the employee EID copied from text 4 to text 24, then validated. Then we update text 4with EID based on global EID

update dba.comrmks
set text24 = text4
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text24 is null

update dba.comrmks
set text4 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text4 is null

update dba.comrmks
set text4 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text4 <> 'UNKNOWN'
and Text8 not in ('N0','C0','NH','NO','CO')
and RIGHT('0000000000'+text4,10) not in (select distinct RIGHT('0000000000'+employeeid,10) from dba.employee)


update cr
set cr.text4 = em.employeeid,
cr.text26 = 'UPDATED'
from dba.comrmks cr, dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text4 = 'UNKNOWN'
and Text7 not in ('N0','C0','NH','NO','CO')
and Text9 <> '9999999999'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  dba.comrmks
set text4 = NULL
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text4 = 'UNKNOWN'
--Step 5 MLevel is copied from text 7 to text 25, then validated. If not valid, then based on the GEID it is updated and the invalid records are replaced with null

update dba.comrmks
set text25 = text7
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text25 is null

update dba.comrmks
set text7 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text7 is null

update dba.comrmks
set text7 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text7 not in (select distinct MLevel from dba.employee)
and (Text7 <> 'UNKNOWN'
or Text7 not in ('N0','C0','NH','NO','CO'))
and Text9 <> '9999999999'

update cr
set cr.text7 = em.MLevel,
cr.text26 = 'UPDATED'
from dba.comrmks cr, dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and (cr.text7 = 'UNKNOWN'
or cr.Text7 not in ('N0','C0','NH','NO','CO'))
and cr.Text9 <> '9999999999'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update cr
set cr.text7 = cr.text25
from dba.comrmks cr
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.Text7 not in ('N0','C0','NH','NO','CO')
and cr.text25 in ('N0','C0','NH','NO','CO')

update  dba.comrmks
set text7 = NULL
where iatanum = 'ORGDR'
and issuedate > '2009-12-31'
and text7 = 'UNKNOWN'


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory = 'A'
and valcarriercode ='AF'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = AF',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where valcarriercode ='AB'
and servicecategory <> 'Y'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = AB',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('A','Z')
and valcarriercode ='FI'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = FI',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('A')
and valcarriercode ='IB'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = IB',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('Z')
and valcarriercode ='EI'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = EI',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('Z')
and valcarriercode ='DI'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = DI',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('C')
and valcarriercode ='LG'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = LG',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('Z')
and valcarriercode ='MA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = MA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('C','D')
and valcarriercode ='SN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = SN',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('C','D','J')
and valcarriercode ='TF'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = TF',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where valcarriercode ='CF'
and servicecategory <> 'Y'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = CF',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('C')
and valcarriercode ='OL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = OL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('A')
and valcarriercode ='MX'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = MX',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where valcarriercode ='P8'
and servicecategory <> 'Y'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = P8',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('Z')
and valcarriercode ='JJ'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = JJ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory ='Y'
where servicecategory in ('J')
and valcarriercode ='G3'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update servicecategory where valcarriercode = G3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set daysadvpurch = 0
where iatanum ='ORGDR'
and daysadvpurch < 0
and refundind ='N'
and vendortype in ('BSP','NONBSP')
and voidind ='N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set daysadvpurch = 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set voidind = 'C',
voidreasontype ='CWT'
where lastname = 'PETESCH'
and voidind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update invoicedetail where lastname = PETESCH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.hotel
set voidind = 'C',
voidreasontype ='CWT'
where lastname = 'PETESCH'
and voidind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update hotel where lastname = PETESCH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.car
set voidind = 'C',
voidreasontype ='CWT'
where lastname = 'PETESCH'
and voidind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update car where lastname = PETESCH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set voidind = 'C',
voidreasontype ='CWT'
where lastname = 'NISENBERG'
and voidind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update invoicedetail where lastname = NISENBERG',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.hotel
set voidind = 'C',
voidreasontype ='CWT'
where lastname = 'NISENBERG'
and voidind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update hotel where lastname = NISENBERG',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.car
set voidind = 'C',
voidreasontype ='CWT'
where lastname = 'NISENBERG'
and voidind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update car where lastname = NISENBERG',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set lastname ='DELBARRIO CRUZ'
where lastname like '%DEL%BARRIO%CRU%'
and clientcode like '8400%SP1'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set lastname =DELBARRIO CRUZ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.car
set prefcarind = 'N'
where prefcarind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set prefcarind = N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.car
set prefcarind = 'Y'
where carchaincode in ('ZE','ZI')
and prefcarind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set prefcarind = Y',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




SET @TransStart = getdate()
update t1
set text13 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and t2.clientcode in ('1orlca1','orl','CA-ORL/CA')
and udefnum = 8
and text13 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text13 = udefdata where udefnum = 8',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update t1
set text13 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and t2.clientcode in ('buh','jxf','u1buhus1','U1JXFUS1','BUH-US/US','JXF-US/US')
and udefnum = 502
and text13 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text13 = udefdata where udefnum = 502',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update t1
set text13 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and t2.clientcode in ('buh','jxf','u1buhus1','U1JXFUS1','BUH-US/US','JXF-US/US')
and udefnum = 503
and text13 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text13 = udefdata where udefnum = 503',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update t1
set text13 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and t2.clientcode in ('U1JXFUS1','JXF-US/US')
and udefnum = 509
and text13 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text13 = udefdata where udefnum = 509',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update t1
set text13 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and t2.clientcode in ('U1JXFUS1','JXF-US/US')
and udefnum = 510
and text13 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text13 = udefdata where udefnum = 510',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update t1
set text14 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and udefnum = 13
and text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = udefdata',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update t1
set text15 = udefdata
from dba.comrmks t1, dba.udef t2
where t1.iatanum = t2.iatanum
and t1.clientcode = t2.clientcode
and t1.recordkey = t2.recordkey
and t1.issuedate = t2.issuedate
and t1.seqnum = t2.seqnum
and udefnum = 28
and text15 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text15 = udefdata',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--insert into dba.classtocabin
--select distinct substring(segmentcarriercode,1,3),substring(classofservice,1,1),'ECONOMY',seginternationalind,'Y',NULL,NULL
-- from dba.transeg
--where substring(segmentcarriercode,1,3)+substring(classofservice,1,1)+seginternationalind not in (select distinct carriercode+substring(classofservice,1,1)+internationalind
-- from dba.classtocabin)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert into dba.classtocabin from dba.transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--insert into dba.classtocabin
--select distinct substring(valcarriercode,1,3),substring(servicecategory,1,1),'ECONOMY',internationalind,'Y',NULL,NULL
-- from dba.invoicedetail
--where substring(valcarriercode,1,3)+substring(servicecategory,1,1)+internationalind not in
--(select distinct carriercode+substring(servicecategory,1,1)+internationalind
-- from dba.classtocabin)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert into dba.classtocabin from dba.invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update dba.transeg
set segmentcarriercode = '2V',
segmentcarriername ='AMTRAK'
where typecode = 'R'
and iatanum ='ORGDR'
and segmentcarriercode = 'AM'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set segmentcarriercode = 2V',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set valcarriercode = '2V',
vendorname = 'AMTRAK',
valcarriernum = 554,
vendortype = 'BSP'
where iatanum ='ORGDR'
and vendornumber = 'AM'
and producttype ='R'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set valcarriercode = 2V',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set servicecategory = 'Y'
where iatanum ='ORGDR'
and valcarriercode = '2V'
and servicecategory is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set servicecategory = Y',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set firstname ='BONNIE',
middleinitial = 'L'
where lastname ='BARGER'
and firstname like 'BONNIE L%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set firstname =BONNIE in invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.car
set firstname ='BONNIE',
middleinitial = 'L'
where lastname ='BARGER'
and firstname like 'BONNIE L%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set firstname =BONNIE in car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.hotel
set firstname ='BONNIE',
middleinitial = 'L'
where lastname ='BARGER'
and firstname like 'BONNIE L%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set firstname =BONNIE in hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SF Case# 00019085 - Update EMIRATES --

SET @TransStart = getdate()
UPDATE dba.InvoiceDetail
set VendorName = 'EMIRATES'
where VendorName = 'EMIRATES AIR'
and ValCarrierCode = 'EK'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set lastname =DELBARRIO CRUZ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE dba.Transeg
set SegmentCarrierName = 'EMIRATES'
where SegmentCarrierName = 'EMIRATES AIR'
and SegmentCarrierCode = 'EK'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set lastname =DELBARRIO CRUZ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--End of EMIRATES Update 

SET @TransStart = getdate()
--update ind icator to L for Leisure booking added 05/13/09
update id
set id.voidind ='L',
id.voidreasontype = 'LEI'
from dba.comrmks cr, dba.invoicedetail id
where cr.text10 ='L836'
and id.recordkey = cr.recordkey
and id.voidind ='N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set id.voidind =L from invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update id
set id.voidind ='L',
id.voidreasontype = 'LEI'
from dba.comrmks cr, dba.hotel id
where cr.text10 ='L836'
and id.recordkey = cr.recordkey
and id.voidind ='N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set id.voidind =L from hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update id
set id.voidind ='L',
id.voidreasontype = 'LEI'
from dba.comrmks cr, dba.car id
where cr.text10 ='L836'
and id.recordkey = cr.recordkey
and id.voidind ='N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set id.voidind =L from car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, dba.cwthtlchains ch
where len(ht.htlchaincode) > 2
and ht.htlchaincode = ch.cwtcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set ht.htlchaincode = ch.trxcode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--update car chain code ZL1/ZL2 to ZL and update car chain name to National 3/19/10
update dba.car
set carchainname = 'NATIONAL CAR RENTAL',
carchaincode = 'ZL'
where iatanum = 'ORGDR'
and carchainname is null
and cardailyrate is not null
and (carchaincode = 'ZL1'
or carchaincode = 'ZL2')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='pdate car chain code ZL1/ZL2 to ZL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT into dba.City
select distinct ts.OriginCityCode,ts.TypeCode, ts.OriginCityCode,'Unknown', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
from dba.transeg ts
where ts.origincitycode is not null
and not exists (select citycode from dba.City 
					where CityCode = ts.OriginCityCode
					and TypeCode = ts.Typecode)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT OriginCityCode into dba.City',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO DBA.City 
select distinct ts.SegDestCityCode,ts.TypeCode, ts.SegDestCityCode,'Unknown', NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE()
from dba.transeg ts
where ts.SegDestCityCode is not null
and not exists (select citycode from dba.City 
					where CityCode = ts.SegDestCityCode
					and TypeCode = ts.Typecode)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT SegDestCityCode into dba.City',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---HNN Cleanup for DEA
update dba.hotel
set htlstate = NULL
where htlcountrycode not in ('US','CA','AU','BR')
and HtlState is not null
and MasterId is null

update dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null

update dba.hotel
set htlcityname = htladdr3 
where masterid is null
and htlcityname like '.%'
and htladdr3 is not null

 update dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = ''
or HtlAddr1 is null or HtlAddr1 = '' )

update dba.hotel
set masterid = -1
where masterid is null
and HtlAddr1 = '***'
and HtlAddr2 is null
and HtlPropertyName like 'OTHER%HOTELS%'

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

update t1
set t1.htlcountrycode = t2.countrycode
from dba.hotel t1, dba.city t2
where t2.typecode = 'A'
and t1.htlcitycode = t2.citycode
and t1.htlcountrycode <> t2.countrycode
and t1.htlcountrycode = 'US'
and t2.countrycode <> 'US'
and t1.MasterId is null


update dba.hotel
set htladdr1 = htladdr2
,htladdr2 = null
where htladdr1 is null
and htladdr2 is not null
and MasterId is null

update h
set h.htlcountrycode = ct.countrycode
,h.htlstate = ct.stateprovincecode
from dba.hotel h, dba.city ct
where h.htlcitycode = ct.citycode
and  h.masterid is null
and h.htlcountrycode <> ct.countrycode
and ct.typecode ='a'

update ht
set ht.htlstate = zp.state
from dba.hotel ht, TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
where substring(ht.htlpostalcode,1,5) = zp.zipcode
and substring(ht.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P'
and ht.masterid is null
and ht.htlstate is null
and ht.htlcountrycode = 'US'

--add to the end after HNN cleanup sql's run
--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from dba.Hotel
Where MasterId is NULL
AND IataNum like 'OR%'
and issuedate >'2010-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'ORCWT',
@Enhancement = 'HNN',
@Client = 'Oracle',
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
@TextParam3 = 'TMAN503_Oracle',
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




--CC MasterID
--Data Enhancement Automation HNN Queries
Declare @HNNCCBeginDate datetime
Declare @HNNCCEndDate datetime

Select @HNNCCBeginDate = Min(transactiondate),@HNNCCEndDate = Max(transactiondate)
from dba.CCHotel cht, dba.ccmerchant cm
Where cm.MasterId is NULL
AND cht.IataNum like 'OR%'
and cht.transactiondate >'2014-12-31'
and cht.merchantid = cm.merchantid

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'ORCWT',
@Enhancement = 'HNN',
@Client = 'Oracle',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNCCBeginDate,
@EndDate = @HNNCCEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'card',
@TextParam2 = 'ttxpaSQL01',
@TextParam3 = 'TMAN503_Oracle',
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









--created job to start 2/15/13 at 10PM
--exec sp_ORACLE_CO2_MAIN



GO
