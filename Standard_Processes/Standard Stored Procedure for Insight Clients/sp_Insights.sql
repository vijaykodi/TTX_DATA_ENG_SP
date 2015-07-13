--CREATE PROCEDURE [dbo].[sp_@iatanum]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = '@iatanum'
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

-----------------------------------------------------------
--Updating IssueDate to equal InvoiceDate in all tables
----------------------------------------------------------
SET @TransStart = getdate()
Update id
set id.issuedate = ih.invoicedate
from dba.invoicedetail id, dba.invoiceheader ih
where id.iatanum = '@iatanum'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update issuedate for each table',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ts
set ts.issuedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = '@iatanum'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ts',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update car
set car.issuedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = '@iatanum'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update ht
set ht.issuedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = '@iatanum'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ht',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ud
set ud.issuedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = '@iatanum'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ud',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update pt
set pt.issuedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = '@iatanum'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.issuedate <> ih.invoicedate
and ih.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update pt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update tx
set tx.issuedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = '@iatanum'
and tx.recordkey = ih.recordkey
and tx.iatanum = ih.iatanum
and tx.issuedate <> ih.invoicedate
and tx.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update tx',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
-------------------------------------------------------
--Update VendorType to FEES for service fees
-------------------------------------------------------
SET @TransStart = getdate()
Update dba.InvoiceDetail
Set VendorType = 'FEES'
where IataNum = '@iatanum'
and InvoiceType like '%FEE%'
and VendorType <> 'FEES'
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FEES vendortype',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------------------------------------------------------
--- Update class to cabin
-------------------------------------------------------
SET @TransStart = getdate()
---from transeg
insert into dba.classtocabin
select distinct substring(ts.SegmentCarrierCode,1,3), substring(ts.ClassOfService,1,1), 'ECONOMY',ts.segInternationalInd,'Y',NULL,NULL
from dba.transeg ts
where ts.iatanum = '@iatanum'
and ts.SegmentCarrierCode is not null
and ts.ClassOfService is not null
and ts.SegmentCarrierCode+TS.ClassOfService+TS.SegInternationalInd NOT IN (SELECT DISTINCT CarrierCode+ClassOfService+InternationalInd FROM DBA.ClassToCabin)
and ts.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ClassToCabin from transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
---from invoicedetail
insert into dba.classtocabin
select distinct substring(id.valCarrierCode,1,3), substring(id.servicecategory,1,1), 'ECONOMY',id.InternationalInd,'Y',NULL,NULL
from dba.invoicedetail id
where id.iatanum = '@iatanum'
and id.valCarrierCode is not null
and id.Servicecategory is not null
and id.VendorType in ('BSP','NONBSP','RAIL')
and id.valCarrierCode+id.ServiceCategory+id.InternationalInd NOT IN (SELECT DISTINCT CarrierCode+ClassOfService+InternationalInd FROM DBA.ClassToCabin)
and id.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ClassToCabin from transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------------------
--Deleting Comrmks
----------------------
SET @TransStart = getdate()
delete DBA.comrmks
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------------------------------------------------------------------------------------------------
--Updating ComRmks to populated the first 6 standard field and NULL all field afterwards for mapping
---------------------------------------------------------------------------------------------------
insert dba.comrmks 
select RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate, null, null, null, null, null, null, null, null, null, null, 
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null
from dba.invoicedetail id
where id.iatanum = '@iatanum'
and not exists (select 1 from dba.comrmks cr 
                        where cr.recordkey = id.recordkey 
                        and cr.iatanum = id.iatanum 
                        and cr.seqnum = id.seqnum
                        ) 
--and cr.issuedate between @BeginIssueDate and @EndIssueDate

----------------------------------------------------------------------
--Update ComRmks to 'Not Provided' prior to updating with agency data
----------------------------------------------------------------------

SET @TransStart = getdate()

Update dba.comrmks
set Text1 = 'Not Provided',
Text2 = 'Not Provided',
Text3 = 'Not Provided',
Text4 = 'Not Provided',
Text5 = 'Not Provided',
Text6 = 'Not Provided',
Text7 = 'Not Provided',
Text8 = 'Not Provided',
Text9 = 'Not Provided',
Text10 = 'Not Provided',
Text11 = 'Not Provided',
Text12 = 'Not Provided',
Text13 = 'Not Provided',
text14 = 'Not Provided',
Text15 = 'Not Provided',  
Text16 = 'Not Provided',
Text17 = 'Not Provided',
Text18 = 'Not Provided',
Text19 = 'Not Provided',
Text20 = 'Not Provided',
Text21 = 'Not Provided',
Text22 = 'Not Provided',
Text23 = 'Not Provided',
Text24 = 'Not Provided',
Text25 = 'Not Provided'
where iatanum = '@iatanum'
and Text1 is null
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set text fields to Not Provided',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/*
	Text1 = Employee id
	Text2 = POS country
	Text8 = Online Booking System
	Text14 = Highest cabin booked
	Text16 = Entity Code
	Text17 = Concur Login

*/

-----------------------------------
--Update text1 with Employee ID
------------------------------------
update cr
set cr.text1 = substring(ud.UdefData,1,7)
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = ??
and cr.text1 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text1 with employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------
--Update Text2 with POS from InvoiceHeader
--------------------------------------------
SET @TransStart = getdate()
update cr
set Text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = '@iatanum'
and cr.text2 = 'Not Provided'
and cr.issuedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text2 with POS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------
--Update Text8 with Online Booking System
--could be in udef need to check
--------------------------------------------
SET @TransStart = getdate()
update cr
set cr.Text8 = case when id.onlinebookingsystem = 'CGE' then 'ONLINE'
	                when id.OnlineBookingSystem = 'Concur' then 'ONLINE'
	                else 'OFFLINE'
	                end
from dba.invoicedetail id, dba.comrmks cr
where id.iatanum = '@iatanum'
and cr.iatanum = id.iatanum
and cr.clientcode = id.clientcode
and cr.recordkey = id.recordkey
and cr.seqnum = id.seqnum
and cr.text8 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Online Booking Text8',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------
--Update Text 14 with Highest Cabin First 
----------------------------------
SET @TransStart = getdate()
update cr
set cr.text14 = ctc.DomCabin
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc, dba.invoiceheader ih
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ih.recordkey = ts.recordkey
and ih.iatanum = ts.iatanum
and ts.minsegmentcarriercode = ctc.carriercode
and ts.minclassofservice = ctc.classofservice
and ts.mininternationalind = ctc.InternationalInd
and cr.iatanum = '@iatanum'
and ctc.DomCabin = 'First'
and cr.text14 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text14 with First Class',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------
--Update Text 14 with Highest Cabin Business 
----------------------------------
update cr
set cr.text14 = ctc.DomCabin
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc, dba.invoiceheader ih
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ih.recordkey = ts.recordkey
and ih.iatanum = ts.iatanum
and ts.minsegmentcarriercode = ctc.carriercode
and ts.minclassofservice = ctc.classofservice
and ts.mininternationalind = ctc.InternationalInd
and cr.iatanum = '@iatanum'
and ctc.DomCabin = 'Business'
and cr.text14 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text14 with Business Class',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------
--Update Text 14 with Highest Cabin Coach
----------------------------------
update cr
set cr.text14 = ctc.DomCabin
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc, dba.invoiceheader ih
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ih.recordkey = ts.recordkey
and ih.iatanum = ts.iatanum
and ts.minsegmentcarriercode = ctc.carriercode
and ts.minclassofservice = ctc.classofservice
and ts.mininternationalind = ctc.InternationalInd
and cr.iatanum = '@iatanum'
and cr.text14 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text14 with Coach Class',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------
----Update Text16 with Entity Code
------------------------------------
SET @TransStart = getdate()
update cr
set cr.text16 = '???' --in workbook
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.text16 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Entity Code Text16',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------
----Update ih.CLIQCID with data from text16
--------------------------------------------
SET @TransStart = getdate()
update ih
set ih.cliqcid = cr.text16 
from dba.InvoiceHeader ih, dba.comrmks cr
where ih.iatanum = 'SASTRAV'
and cr.iatanum = ih.iatanum
and cr.clientcode = ih.clientcode
and ih.CLIQCID is null
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Entity Code Text16',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------
--Update Text17 with Concur Login ID
--------------------------------------------
SET @TransStart = getdate()
update cr
set cr.Text17 = ud.udefdata
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = ?? --verify
and cr.text17 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Concur Login ID Text17',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------
----Update Ih.Cliquser with same data from text17 
--------------------------------------------------
SET @TransStart = getdate()
update ih
set ih.CLIQUSER = cr.text17
from dba.invoiceheader ih, dba.comrmks cr
where ih.iatanum = 'SASTRAV'
and cr.iatanum = ih.iatanum
and cr.clientcode = ih.clientcode
and cr.recordkey = ih.recordkey
and ih.cliquser is null
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Entity Code Text17',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------------------------------------------------------
----Update text48 with Cost Center for hierarchy purpose
----------------------------------------------------------
--update cr
--set cr.text48 = cr.text3
--from dba.udef ud, dba.comrmks cr
--where ud.iatanum = '@iatanum'
--and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
--and cr.text48 is null
--and Text3 <> 'Not Provided'
--and cr.invoicedate between @BeginIssueDate and @EndIssueDate
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text48 raw cost center',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------------------------------------------------------
--Update text50 with Employee ID for hierarchy purpose
--------------------------------------------------------
--SET @TransStart = getdate()
--update cr
--set cr.text50 = ud.UdefData
--from dba.udef ud, dba.comrmks cr
--where ud.iatanum = '@iatanum'
--and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
--and ud.udefnum = 25
--and cr.invoicedate between @BeginIssueDate and @EndIssueDate
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text50 with employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------
--Update NUM1 with farecompare 1 and NUM2 with farecompare2
----------------------------------------------------------------
--Update NUM1 with FareCompare1
SET @TransStart = getdate()
update cr
set Num1 = id.farecompare1
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum = '@iatanum'
and cr.num1 is null
and id.FareCompare1 is not null
and id.InvoiceDate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Num1 with FC1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update NUM2 with farecompare2
SET @TransStart = getdate()
update cr
set Num2 = id.farecompare2
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum = '@iatanum'
and cr.num2 is null
and id.InvoiceDate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Num2 with FC2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------
--Update Full Fare Compare FC1
------------------------------
SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare1 = TotalAmt
from dba.InvoiceDetail
where IataNum = '@iatanum'
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
and TotalAmt > 0
and FareCompare1 < TotalAmt
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 High Fare < TotalAmt > 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare1 = TotalAmt
from dba.InvoiceDetail
where IataNum = '@iatanum'
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
and TotalAmt < 0
and FareCompare1 > TotalAmt
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 High Fare > TotalAmt < 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare1 = TotalAmt
from dba.InvoiceDetail
where IataNum = '@iatanum'
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
and FareCompare1 is null
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 = TotalAmt if FC1 NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare1 = TotalAmt
where IataNum = '@iatanum'
and TotalAmt = 0
and FareCompare1 <> 0
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 = TotalAmt if TotalAmt = 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------
--Updating Low Fare Compare FC2
----------------------------------------
SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare2 = TotalAmt
from dba.InvoiceDetail
where IataNum = '@iatanum'
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
and TotalAmt > 0
and FareCompare2 > TotalAmt
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 Low Fare > TotalAmt > 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare2 = TotalAmt
from dba.InvoiceDetail
where IataNum = '@iatanum'
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
and TotalAmt < 0
and FareCompare2 > TotalAmt
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 Low Fare > TotalAmt < 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare2 = TotalAmt
from dba.InvoiceDetail
where IataNum = '@iatanum'
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
and FareCompare2 is null
or Farecompare2 = '0'
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 = TotalAmt if FC2 NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare2 = TotalAmt
where IataNum = '@iatanum'
and TotalAmt = 0
and FareCompare2 <> 0
and VendorType in ('BSP','NONBSP','RAIL')
and VoidInd = 'N'
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 = TotalAmt if TotalAmt = 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

