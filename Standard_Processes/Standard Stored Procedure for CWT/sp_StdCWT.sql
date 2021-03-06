CREATE PROCEDURE [dbo].[sp_@iatanum_Update]
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


SET @TransStart = getdate()
--Update invoicedate for each table to match invoicedate in invoiceheader
Update id
set id.invoicedate = ih.invoicedate
from dba.invoicedetail id, dba.invoiceheader ih
where id.iatanum = '@iatanum'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in InvoiceDetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ts
set ts.invoicedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = '@iatanum'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update car
set car.invoicedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = '@iatanum'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ht
set ht.invoicedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = '@iatanum'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ud
set ud.invoicedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = '@iatanum'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update pt
set pt.invoicedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = '@iatanum'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Payment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update tx
set tx.invoicedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = '@iatanum'
and tx.recordkey = ih.recordkey
and tx.iatanum = ih.iatanum
and tx.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Tax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update car
set car.issuedate = cr.issuedate
from dba.car car, dba.comrmks cr
where car.issuedate <> cr.issuedate
AND CR.RecordKey = car.RecordKey
AND CR.IataNum = car.IataNum 
AND CR.SeqNum = car.SeqNum 
AND CR.ClientCode = car.ClientCode
and cr.iatanum ='@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Car Issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update htl
set htl.issuedate = cr.issuedate
from dba.hotel htl, dba.comrmks cr
where htl.issuedate <> cr.issuedate
AND CR.RecordKey = HTL.RecordKey
AND CR.IataNum = HTL.IataNum 
AND CR.SeqNum = HTL.SeqNum 
AND CR.ClientCode = HTL.ClientCode
and cr.iatanum ='@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Hotel Issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--update CWT hotel chain codes
--select ht.htlchaincode,ch.trxcode,ht.htlchainname,ch.trxchainname
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, dba.cwthtlchains ch
where len(ht.htlchaincode) > 2
and ht.htlchaincode = ch.cwtcode
AND HT.IATANUM='@iatanum'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CWT Hotel Chain Codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--update car chain code ZL1/ZL2 to ZL and update car chain name to National STANDARD CWT
update dba.car
set carchainname = 'NATIONAL CAR RENTAL',
carchaincode = 'ZL'
where iatanum = '@iatanum'
and carchainname is null
and cardailyrate is not null
and (carchaincode = 'ZL1'
or carchaincode = 'ZL2')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update chain code for National',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update VendorType for Rail and Fees
update id
set VendorType = 'RAIL'
from dba.invoicedetail id
where id.iatanum in ('@iatanum')
and id.producttype = 'R'
and id.vendortype <> 'Rail'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update vendortype for Rail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update VendorType for Rail and Fees
update id
set VendorType = 'FEES'
from dba.invoicedetail id
where id.iatanum in ('@iatanum')
and id.vendorname = 'CARLSON WAGONLIT TRAVEL'
and id.vendortype <> 'FEES'
and id.origincode = '***'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update vendortype for Rail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


/* Mappings per Implementations workbook 
User Defined fields
Text1 = UserID_EmployeeID
Text2 = POS
Text3 = Cost Center
Text4 = Department
Text5 = Division
Text6 = Coalition
Text7 = Trip_Purpose
Text8 = n/a
Text9 = Ordered by
Text10 = Company Unit
********
Num21 farecompare1
Num22 farecompare2
*/


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

SET @TransStart = getdate()
--Insert rows in Comrmks.....
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
from dba.invoicedetail
where recordkey+iatanum+convert(char(2),seqnum) not in 
(select recordkey+iatanum+convert(char(2),seqnum) from dba.comrmks where iatanum = '@iatanum')
and iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
--Update comrmks for Text1 (EmployeeID)
update cr
set cr.text1 = UD.UDEFDATA
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum in ('@iatanum')
and ud.udefnum = @udefnum
and cr.text1 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text1 with Emp',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update Text2 with POS from InvoiceHeader
update CR
set text2 = IH.ORIGCOUNTRY
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = '@iatanum'
and cr.text2 is null
and ih.OrigCountry is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text2 with POS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update comrmks for Text3 COST CENTER 

update cr
set cr.text3 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum in ('@iatanum')
and ud.udefnum = @udefnum
and cr.text3 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text3 with COSTCENTER',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update comrmks for Text7 Trip Purpose 
update cr
set cr.text7 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum = '@iatanum'
and ud.udefnum = @udefnum
and cr.text7 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text7 with TripPurpose',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--SET @TransStart = getdate()
--update dba.invoicedetail
--set reasoncode1 = reasoncode2
--where iatanum = '@iatanum'
--AND reasoncode1 is null
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update reason code1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update dba.HOTEL
--set HTLreasoncode1 = HTLreasoncode2
--where iatanum = '@iatanum'
--AND HTLreasoncode1 is null
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update reason code1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
--Update CR Num21 where ticket amount is greater than full fare
update cr
set Num21 = id.farecompare1
from  dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and cr.num21 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Num21 with FC1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update CR NUM22 where ticket amount is less than full fare
update cr
set Num22 = id.farecompare2
from  dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and cr.num22 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Num22 with FC2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update ID FareCompare1 where ticket amount > 0 and > than full fare
update id
set FareCompare1 = id.TotalAmt
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and abs(id.totalamt) > abs(id.farecompare1)
and id.totalamt >= 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 where ticket amount > 0 and > than full fare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update ID FareCompare1 where ticket amount < 0 and < full fare
update id
set FareCompare1 = id.TotalAmt
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and abs(id.totalamt) < abs(id.farecompare1)
and id.totalamt < 0
and id.refundind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 where ticket amount < 0 and < full fare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update ID FareCompare2 where ticket amount > 0 and < than low fare
update id
set FareCompare2 = id.TotalAmt
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and abs(id.totalamt) < abs(id.farecompare2)
and id.totalamt > 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 where ticket amount > 0 and < than low fare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update ID FareCompare2 where ticket amount < 0 and > than low fare
update id
set FareCompare2 = id.TotalAmt
from  dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and abs(id.totalamt) > abs(id.farecompare2)
and id.totalamt < 0
and id.refundind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 where ticket amount < 0 and > than low fare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update FareCompare1 when null and totalamt is not null
update id
set FareCompare1 = id.TotalAmt
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and id.farecompare1 is null
and id.totalamt is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC1 when null and totalamt is not null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update FareCompare2 when null and totalamt is not null
update id
set FareCompare2 = id.TotalAmt
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey
and id.iatanum = cr.iatanum
and id.seqnum = cr.seqnum
and id.iatanum in ('@iatanum')
and id.farecompare2 is null
and id.totalamt is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update FC2 when null and totalamt is not null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update dba.ClassToCabin 
--from transeg
insert into dba.classtocabin
select distinct substring(ts.SegmentCarrierCode,1,3), substring(ts.ClassOfService,1,1), 'ECONOMY',ts.segInternationalInd,'Y',NULL,NULL
from dba.transeg ts
where ts.iatanum = '@iatanum'
and ts.SegmentCarrierCode is not null
and ts.ClassOfService is not null
and substring(ts.SegmentCarrierCode,1,3)+substring(ts.ClassOfService,1,1)+ts.segInternationalInd not in(select carriercode+classofservice+internationalind
from dba.classtocabin)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update classtocabin from transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--from invoicedetail
insert into dba.classtocabin
select distinct substring(id.valcarriercode,1,3), substring(id.ServiceCategory,1,1), 'ECONOMY',InternationalInd,'Y',NULL,NULL
from dba.InvoiceDetail ID
where ID.IataNum = '@iatanum'
and ID.VendorType in ('BSP','NONBSP','RAIL')
and id.valcarriercode is not null
and id.ServiceCategory is not null
and substring(id.valcarriercode,1,3)+substring(id.ServiceCategory,1,1)+InternationalInd not in (select carriercode+classofservice+internationalind 
from dba.classtocabin)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update classtocabin from invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Standard post import sql update for text14 - HighestCabin
--InvoiceDetail.ServiceCategory is first segment's class of service not highest cabin flown
SET @TransStart = getdate()
update cr
set cr.text14 = 'FIRST'
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ts.Minsegmentcarriercode = ctc.carriercode
and ts.MINclassofservice = ctc.classofservice
and ts.MINinternationalind = ctc.InternationalInd
and cr.iatanum in ('@iatanum')
and ctc.DomCabin = 'First'
and cr.text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = DomCabin where DomCabin = First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text14 = 'BUSINESS'
from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
where cr.recordkey = ts.recordkey
and cr.iatanum = ts.iatanum
and cr.seqnum = ts.seqnum
and ts.MINsegmentcarriercode = ctc.carriercode
and ts.MINclassofservice = ctc.classofservice
and ts.MINinternationalind = ctc.InternationalInd
and cr.iatanum in ('@iatanum')
and ctc.DomCabin = 'Business'
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
and cr.iatanum in ('@iatanum')
and cr.text14 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text14 = DomCabin',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



---HNN Cleanup for DEA

--Clean up unwanted characters in htlpropertyname and htladdr1

SET @TransStart = getdate()
UPDATE DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update dba.hotel
set masterid = -1
where masterid is null
and (htlpropertyname like 'OTHER%HOTELS%' or htlpropertyname like '%NONAME%')

update dba.hotel
set masterid = -1
where masterid is null
and htlpropertyname is null
and htladdr1 is null

 update dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = ''
or HtlAddr1 is null or HtlAddr1 = '' )

update h
set h.htlcountrycode = ct.countrycode
,h.htlstate = ct.stateprovincecode
from dba.hotel h, dba.city ct
where h.htlcitycode = ct.citycode
and  h.masterid is null
and h.htlcountrycode is null
and ct.countrycode <> 'ZZ'
and ct.typecode ='a'
	
update t1
set t1.htlstate = t2.stateprovincecode
from dba.hotel t1, dba.city t2
where t2.typecode = 'A'
and t1.htlcitycode = t2.citycode
and t1.htlcountrycode = t2.countrycode
and t1.htlstate is null
and t1.htlcountrycode = 'US'
and t2.countrycode = 'US'
and t1.masterid is null

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

update dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null

update dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'

update dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'

update dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'

update dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'

update dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'

update dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'


update dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'


update dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null

update dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null

update dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null

update dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null

update dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null

update dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null

UPDATE dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null

	update dba.hotel
	set htlcityname = 'HERTOGENBOSCH'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%MOEVENPICK HOTEL%'
	
	update dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%OAKWOOD CHELSEA%'
	
	update dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%LONGACRE HOUSE%'
	
	update dba.hotel
	set htlcityname = 'BARCELONA'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%HOTLE PUNTA PALMA%'
	


--add to the end after HNN cleanup sql's run
--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from dba.Hotel
Where MasterId is NULL
AND IataNum = '@iatanum'
and issuedate >'2011-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = '@iatanum',
@Enhancement = 'HNN',
@Client = @Client,
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
@TextParam2 = '@productionserver',
@TextParam3 = '@productiondatabasename',
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

--Split ticket setup---
--update dba.InvoiceDetail
--set VendorType = 'BSP'
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and VendorType = 'BSPSTC'

--update dba.InvoiceDetail
--set VendorType = 'NONBSP'
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and VendorType = 'NONBSPSTC'

--update dba.InvoiceDetail
--set VendorType = 'FEES'
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and VendorType = 'FEESSTC'

--delete dba.InvoiceDetail
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and VendorType = 'BSPSTP'

--delete dba.InvoiceDetail
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and VendorType = 'NONBSPSTP'

--delete dba.InvoiceDetail
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and VendorType = 'FEESSTP'

--delete dba.TranSeg
--where IataNum = '@iatanum'
--and InvoiceDate >= '2014-11-01'
--and seqnum >= 1000

--WAITFOR DELAY '00:00:05'
-----set up Split Ticket
--         Declare @From as varchar(3)
--         Declare @To as varchar(3)
--         Declare @CommandLine as varchar(100)
         
  

--      select @From = abs(datediff(dd,getdate(),'2014-11-01'))
--      select @To = abs(datediff(dd,getdate(),@EndIssueDate))
--      set @CommandLine = '-RN@client -BD'+@From+ ' -ED'+@To+' -UIdatasvc -PWtman2009 -DS@production'
--EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
--@DatamanRequestName = '@Client',
--@Enhancement = 'SplitTkt',
--@Client = @Client,
--@Delay = 15,
--@Priority = NULL,
--@Notes = NULL,
--@Suspend = false,
--@RunAtTime = NULL,
--@BeginDate = NULL,
--@EndDate = NULL,
--@DateParam1 = NULL,
--@DateParam2 = NULL,
--@TextParam1 = NULL,
--@TextParam2 = NULL,
--@TextParam3 = NULL,
--@TextParam4 = NULL,
--@TextParam5 = NULL,
--@TextParam6 = NULL,
--@TextParam7 = NULL,
--@TextParam8 = NULL,
--@TextParam9 = NULL,
--@TextParam10 = NULL,
--@TextParam11 = NULL,
--@TextParam12 = NULL,
--@TextParam13 = NULL,
--@TextParam14 = NULL,
--@TextParam15 = NULL,
--@IntParam1 = NULL,
--@IntParam2 = NULL,
--@IntParam3 = NULL,
--@IntParam4 = NULL,
--@IntParam5 = NULL,
--@BoolParam1 = NULL,
--@BoolParam2 = NULL,
--@BoolParam3 = NULL,
--@BoolParam4 = NULL,
--@BoolParam5 = NULL,
--@BoolParam6 = NULL,
--@BoolParam7 = NULL,
--@BoolParam8 = NULL,
--@BoolParam9 = NULL,
--@BoolParam10 = NULL,
--@CommandLineArgs = @CommandLine

