CREATE PROCEDURE [dbo].[sp_@Iatanum]
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


-------------------------------
--Creating Class to Cabin
-------------------------------
SET @TransStart = getdate()
---from transeg
insert into @productionservcer.@productiondatabasename.dba.classtocabin
select distinct substring(ts.SegmentCarrierCode,1,3), substring(ts.ClassOfService,1,1), 'ECONOMY',ts.segInternationalInd,'Y',NULL,NULL
from @stagingserver.@stagingdatabasename.dba.transeg ts
where ts.iatanum = '@iatanum'
and ts.SegmentCarrierCode is not null
and ts.ClassOfService is not null
and ts.SegmentCarrierCode+TS.ClassOfService+TS.SegInternationalInd NOT IN (SELECT DISTINCT CarrierCode+ClassOfService+InternationalInd FROM @productionservcer.@productiondatabasename.DBA.ClassToCabin)
and ts.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ClassToCabin from transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
---from invoicedetail

insert into @productionservcer.@productiondatabasename.dba.classtocabin
select distinct substring(id.valCarrierCode,1,3), substring(id.servicecategory,1,1), 'ECONOMY',id.InternationalInd,'Y',NULL,NULL
from @stagingserver.@stagingdatabasename.dba.invoicedetail id
where id.iatanum = '@iatanum'
and id.valCarrierCode is not null
and id.Servicecategory is not null
and id.VendorType in ('BSP','NONBSP','RAIL')
and id.valCarrierCode+id.ServiceCategory+id.InternationalInd NOT IN (SELECT DISTINCT CarrierCode+ClassOfService+InternationalInd FROM @productionservcer.@productiondatabasename.DBA.ClassToCabin)
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

SET @TransStart = getdate()
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='create DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
	Text1 = employee id
	Text2 = POS country
	Text3 = Cost Center
 	Text4 = Department
	Text5 = Division/region
	Text6 = Project code
	Text7 = Trip purpose code
	Text8 = Online indicator (usually the same as ID.OnlineBookingSystem)
	Text9 = Management Code
	Text10 = Exec VP Name
	Text11
	Text12
	Text13
	Text14 = Highest cabin booked
	Text15
	Text16 
	Text17
	Text18 = no hotel booked code
	Text19
	Text20
	Text21
	Text22
	Text23
	Text24
	Text25 
*/
SET @TransStart = getdate()
-----------------------------------
--Update text1 with Employee ID
------------------------------------
update cr
set cr.text1 = ud.UdefData
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = @udefnum
and ud.udefdata <> ''
and cr.text1 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text1 with employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
--------------------------------------------
--Update Text2 with POS from InvoiceHeader
--------------------------------------------
update cr
set Text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = '@iatanum'
and cr.text2 = 'Not Provided'
and cr.issuedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text2 POS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------
--Update Text3 with Cost Center
--------------------------------------------
SET @TransStart = getdate()
update cr
set cr.text3 = ud.udefdata
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = @udefnum
and cr.text3 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
-----------------------
--Update Highest Cabin 
-----------------------

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
and ih.importdt >= getdate()-1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text14 First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
and ctc.DomCabin = 'Business'
and cr.text14 = 'Not Provided'
and ih.importdt >= getdate()-1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text14 Business',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
and cr.text14 = 'Not Provided'
and ih.importdt >= getdate()-1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text14 D',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-------------------------------------------------------
--Update text50 with Employee ID for hierarchy purpose
--------------------------------------------------------

SET @TransStart = getdate()
update cr
set cr.text50 = cr.text1
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.text50 is null
and Text1 <> 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text1 with employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------------------------------------------------------
--Update text49 with Cost Center for hierarchy purpose
--------------------------------------------------------
SET @TransStart = getdate()
update cr
set cr.text49 = cr.text3
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = @udefnum
and cr.text49 is null
and Text49 <> 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update text3 with cost center',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------
--Update NUM1 with farecompare 1 and NUM2 with farecompare2
----------------------------------------------------------------

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
and FareCompare2 < TotalAmt
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



-----------------------------------------------------------
--Deleting  existing data from customer production database
-----------------------------------------------------------
SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.Invoiceheader
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.Invoiceheader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.Invoicedetail
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.Invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.Transeg
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.Payment
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.Payment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.Tax
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.Tax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.car
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.hotel
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.udef
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionservcer.@productiondatabasename.DBA.comrmks
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionservcer.@productiondatabasename.DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------------------
--Insert data into customer production database from customer staging database
------------------------------------------------------------------------------

SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.Invoiceheader
SELECT *
FROM @stagingserver.@stagingdatabasename.dba.Invoiceheader
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and recordkey not in(select recordkey
from @productionservcer.@productiondatabasename.DBA.Invoiceheader
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.InvHeader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.Invoicedetail
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.Invoicedetail
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.Invoicedetail
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.Invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.Transeg
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.Transeg
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.Transeg
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.Payment
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.Payment
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.Payment
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.Payment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.Tax
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.Tax
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.Tax
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.Tax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.car
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.car
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.car
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.hotel
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.hotel
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.hotel
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.udef
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.udef
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.udef
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionservcer.@productiondatabasename.DBA.comrmks
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.comrmks
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionservcer.@productiondatabasename.DBA.comrmks
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

insert into @productionservcer.@productiondatabasename.DBA.client
SELECT *
FROM @stagingserver.@stagingdatabasename.DBA.client
WHERE IATANUm in ('@iatanum')
AND clientcode not in(select clientcode
from @productionservcer.@productiondatabasename.DBA.client
where iatanum = '@iatanum')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionservcer.@productiondatabasename.DBA.client',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--------------------------------------------------------------
--Removing beginning and ending spaces in all hotel fields
--------------------------------------------------------------
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------
--Removing unseen characters in htlpropertyname and htladdr1
--------------------------------------------------------------

SET @TransStart = getdate()
UPDATE @productionservcer.@productiondatabasename.DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',','')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null
and iatanum in ('@iatanum')
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------
--Update Master ID to -1 if property name and address is NULL
--------------------------------------------------------------

SET @TransStart = getdate()
update @productionservcer.@productiondatabasename.dba.hotel
set masterid = -1
where masterid is null
and (htlpropertyname like 'OTHER%HOTELS%' or htlpropertyname like '%NONAME%')
and (HtlAddr1 is null or HtlAddr1 = '' )
and iatanum = '@iatanum'

 update @productionservcer.@productiondatabasename.dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = '')
and (HtlAddr1 is null or HtlAddr1 = '' )
and iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Parent id -1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------
--Update state and country code if NULL with Master Zip Code table
------------------------------------------------------------------

SET @TransStart = getdate()
update htl
set htl.htlstate = zp.state
from @productionservcer.@productiondatabasename.dba.hotel htl, atl889.ttxcentral.dba.USZipCodesDeluxe zp
where substring(htl.htlpostalcode,1,5) = zp.zipcode
and substring(htl.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P'
and htl.masterid is null
and htl.htlstate is null
and htl.htlcountrycode = 'US'
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------
--Update City Name to NULL if start with '.'
--------------------------------------------
SET @TransStart = getdate()

update @productionservcer.@productiondatabasename.dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'


update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null

UPDATE @productionservcer.@productiondatabasename.dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = 'HERTOGENBOSCH'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%MOEVENPICK HOTEL%'

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = 'NEW YORK'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%OAKWOOD CHELSEA%'

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = 'NEW YORK'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%LONGACRE HOUSE%'

update @productionservcer.@productiondatabasename.dba.hotel
set htlcityname = 'BARCELONA'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%HOTLE PUNTA PALMA%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End htl edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

	
------------------------------------------
--Data Enhancement Automation HNN Queries
------------------------------------------
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from @productionservcer.@productiondatabasename.dba.Hotel
Where MasterId is NULL
AND IataNum = '@iatanum'
and issuedate >'2011-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = '@iatanum',
@Enhancement = 'HNN',
@Client = '@clientname',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNBeginDate,
@EndDate = @HNNEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = '@agency',
@TextParam2 = '@productionserver',
@TextParam3 = '@productiondatabasename',
@TextParam4 = 'DBA',
@TextParam5 = 'datasvc',
@TextParam6 = 'tman2009',
@TextParam7 = 'ATL889',
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


