USE [TMAN503_@clientdatabase]
GO
/****** Object:  StoredProcedure [dbo].[sp_Iatanum]    Script Date: 05/15/2014 10:27:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_Iatanum]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = '@iatanum'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @IataNum = '@iatanum'

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
or FareCompare2 = '0'
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

----------------------------------
--AMEX Standard Vendortypes Update
----------------------------------
--BSP
update dba.invoicedetail
set VendorType = 'BSP'
where iatanum = '@iatanum'
and producttype in ('0')
and vendortype <> 'BSP'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Vendortypes for BSP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--NONBSP
update dba.invoicedetail
set VendorType = 'NONBSP'
where iatanum = '@iatanum'
and producttype in ('8','9')
and vendortype <> 'NONBSP'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Vendortypes for NONBSP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--RAIL
update dba.invoicedetail
set VendorType = 'RAIL'
where iatanum = '@iatanum'
and producttype in ('7')
and vendortype <> 'RAIL'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Vendortypes for RAIL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--RAIL
update dba.invoicedetail
set VendorType = 'RAIL'
where iatanum = '@iatanum'
and vendortype <> 'RAIL'
and valcarriercode in ('2V','2R')
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Vendortype to RAIL where valcarriercodes in 2V/2R',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--FEES
update dba.invoicedetail
set VendorType = 'FEES'
where iatanum = '@iatanum'
and producttype in ('F')
and vendortype <> 'FEES'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Vendortypes for FEES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--NONAIR
update dba.invoicedetail
set VendorType = 'NONAIR'
where iatanum = '@iatanum'
and producttype not in ('0','8','9','7','F')
and VendorType <> 'NONAIR'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Vendortypes for NONAIR',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.invoicedetail
set servicefee = totalamt
from dba.invoicedetail
where iatanum = '@iatanum'
and vendortype = 'FEES'
and servicefee = '0'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ServiceFee from TotalAmt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------
--New AMEX Standard Rail Carriers
------------------------------------------

SET @TransStart = getdate()
update dba.invoicedetail
set vendorname = case when valcarriercode = 'R0' then 'DEFAULT RAIL'
when valcarriercode = '0A' then 'ATOC-RSP'
when valcarriercode = '0A' then 'ATOC-RSP'
when valcarriercode = '0E' then 'FIRST GREAT WESTERN'
when valcarriercode = '0F' then 'GATWICK EXPRESS'
when valcarriercode = '0G' then 'HULL TRAINS'
when valcarriercode = '0H' then 'GREAT NORTH EASTERN RAILWAY'
when valcarriercode = '0I' then 'VIRGIN WEST COAST'
when valcarriercode = '0J' then 'VIRGIN CROSSCOUNTRY TRAINS'
when valcarriercode = '0K' then 'C2C'
when valcarriercode = '0L' then 'LONDON UNDERGROUND'
when valcarriercode = '0M' then 'MIDLAND MAINLINE'
when valcarriercode = '0N' then 'THE CHILTERN RAILWAY COMPANY'
when valcarriercode = '0O' then 'ISLAND LINE'
when valcarriercode = '0Q' then 'SOUTHERN/SOUTH CENTRAL'
when valcarriercode = '0R' then 'SOUTH EASTERN TRAINS'
when valcarriercode = '0S' then 'FIRST GREAT WESTERN LINK'
when valcarriercode = '0T' then 'MERSEYRAIL PTE'
when valcarriercode = '0U' then 'STRATHCLYDE PTE'
when valcarriercode = '0W' then 'SOUTH YORKSHIRE PTE'
when valcarriercode = '0X' then 'NEXUS TYNE AND WEAR PTE'
when valcarriercode = '0Y' then 'WEST MIDLANDS PTE'
when valcarriercode = '0Z' then 'WEST YORKSHIRE PTE'
when valcarriercode = '02' then 'CENTRAL TRAINS'
when valcarriercode = '03' then 'MERSEYRAIL'
when valcarriercode = '04' then 'ARRIVA TRAINS NORTHERN'
when valcarriercode = '06' then 'ARRIVA TRAINS WALES'
when valcarriercode = '08' then 'FIRST SCOTRAIL/SCOTRAIL RAILWAYS'
when valcarriercode = '09' then 'SOUTH WEST TRAINS'
when valcarriercode = '10' then 'THAMESLINK RAIL'
when valcarriercode = '11' then 'TRANSPENNINE EXPRESS'
when valcarriercode = '12' then 'ONE GER'
when valcarriercode = '13' then 'ONE LER'
when valcarriercode = '14' then 'WEST ANGLIA GREAT NORTHERN RAIL'
when valcarriercode = '19' then 'NORTHERN'
when valcarriercode = '2H' then 'THALYS INTL RAILWAY SAL'
when valcarriercode = '20' then 'RAIL CHINA'
when valcarriercode = '21' then 'RAIL MALAYSIA'
when valcarriercode = '22' then 'RAIL SINGAPORE'
when valcarriercode = '23' then 'RAIL HONG KONG'
when valcarriercode = '24' then 'ARLANDA EXPRESS'
when valcarriercode = '25' then 'FLYTOGET'
when valcarriercode = '26' then 'OBB - AUSTRIAN RAILWAYS'
when valcarriercode = '30' then 'SWISS RAIL'
when valcarriercode = '31' then 'TRENITALIA'
when valcarriercode = '32' then 'ITALIAN RAIL'
when valcarriercode = '34' then 'ONTARIO NORTHLAND'
when valcarriercode = '36' then 'FIRST GREAT WESTERN ADVANCE'
when valcarriercode = '38' then 'PRIVATE RAIL CO - JAPAN' 
when valcarriercode = '41' then 'NMBS/SNCB NATIONAL RAILWAYS OF BELGIUM'       
when valcarriercode = '42' then 'RAIL EUROPE'
when valcarriercode = '43' then 'EUROTUNNEL SHUTTLE'
when valcarriercode = '44' then 'BELGIUM RAIL SERVICE CENTER'
when valcarriercode = '45' then 'JALPAK INTERNATIONAL'
when valcarriercode = '46' then 'FIRST CAPITAL CONNECT'
when valcarriercode = '47' then 'JAPAN RAILWAYS'
when valcarriercode = '6I' then 'GRAND RAIL CENTRAL'
when valcarriercode = '6X' then 'LONDON MIDLAND'
when valcarriercode = '7O' then 'LONDON OVERGROUND'
when valcarriercode = '9G' then 'AIRPORT EXPRESS RAIL LTD'
when valcarriercode = '9I' then 'EAST MIDLANDS TRAINS'
when valcarriercode = '9O' then 'WREXHAM SHROPSHIRE MARYLEBONE'
when valcarriercode = '92' then 'RENFE SPAIN RAIL'
when valcarriercode = '93' then 'RUSSIAN RAIL'
end
where vendortype = 'RAIL'
and vendorname is null
and iatanum = '@iatanum'
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID Rail carrier names',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
-------------------------------------------------------
SET @TransStart = getdate()
--Update Text21 with Client ID from CustAddr1
update cr
set cr.Text21 = cl.custaddr1
from dba.comrmks cr, dba.client cl
where cr.iatanum = '@iatanum'
and cr.iatanum = cl.iatanum
and cr.clientcode = cl.clientcode
and cr.text21 ='Not Provided'
and cl.custaddr1 is not null
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text21 with Client ID from CustAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
-----------------------------------------------------------------------------------------
---example of update using client id from text21 when no custom defined udef supplied by Amex--
SET @TransStart = getdate()
--Update Text1 with Employee UD2
update cr
set Text1 = substring(ud.udefdata,1,5)
from dba.udef ud, dba.comrmks cr
where ud.recordkey = cr.recordkey
and ud.iatanum = cr.iatanum
and ud.seqnum = cr.seqnum
and ud.iatanum = '@iatanum'
and cr.text21 in ('client ids')
and ud.clientcode = cr.clientcode
and cr.text1 = 'Not Provided'
and ud.udefnum = 2
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text1 with Employee UD2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------VOLV81, VOLV82

SET @TransStart = getdate()
--Update Text1 with Employee UD2
update cr
set Text1 = substring(ud.udefdata,1,6)
from dba.udef ud, dba.comrmks cr
where ud.recordkey = cr.recordkey
and ud.iatanum = cr.iatanum
and ud.seqnum = cr.seqnum
and ud.iatanum = '@iatanum'
and cr.text21 in ('client ids')
and ud.clientcode = cr.clientcode
and cr.text1 is null
and ud.udefnum = 3
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text1 with Employee UD3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------

SET @TransStart = getdate()
--Update Text1 with Employee UD2
update cr
set Text1 = substring(ud.udefdata,1,7)
from dba.udef ud, dba.comrmks cr
where ud.recordkey = cr.recordkey
and ud.iatanum = cr.iatanum
and ud.seqnum = cr.seqnum
and ud.iatanum = '@iatanum'
and cr.text21 in ('client ids')
and ud.clientcode = cr.clientcode
and cr.text1 is null
and ud.udefnum = 2
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text1 with Employee UD2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------
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
and cr.invoicedate between @BeginIssueDate and @EndIssueDate

--------------------------------------------
--Update Text3 with Cost Center
--------------------------------------------

SET @TransStart = getdate()
update cr
set cr.text3 = Substring(id.Remarks1, 6, 5)
from dba.InvoiceDetail id, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = id.clientcode
and cr.recordkey = id.recordkey
and cr.seqnum = id.seqnum
and cr.text21 in ('client ids')
and cr.text3 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
-------------------------------------------------------------
---Clarify with eddie and then update
--SET @TransStart = getdate()
--update cr
--set cr.text3 = Substring(id.Remarks1, 1, 7)
--from dba.InvoiceDetail id, dba.comrmks cr
--where ud.iatanum = '@iatanum'
--and cr.iatanum = ud.iatanum
--and cr.clientcode = id.clientcode
--and cr.recordkey = id.recordkey
--and cr.seqnum = id.seqnum
--and cr.text21 in ('client ids')
--and cr.text3 = 'Not Provided'
--and cr.invoicedate between @BeginIssueDate and @EndIssueDate
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----------------------------------------------------------

--Mexico - UDID8/Position 1-13

SET @TransStart = getdate()
update cr
set cr.text3 =  ud.udefdata
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 8
and cr.text21 in ('client ids')
and cr.text3 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--France - UDID3/Position 1-4

SET @TransStart = getdate()
update cr
set cr.text3 =  ud.udefdata
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 3
and cr.text21 in  ('client ids')
and cr.text3 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()
update cr
set cr.text4 = Substring(id.Remarks1, 1, 4)
from dba.InvoiceDetail id, dba.comrmks cr
where id.iatanum = '@iatanum'
and cr.iatanum = id.iatanum
and cr.clientcode = id.clientcode
and cr.recordkey = id.recordkey
and cr.seqnum = id.seqnum
and cr.text21 in ('client ids')
and cr.text4 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text4',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
-------------------------------------------------------------
---Update Text7

SET @TransStart = getdate()
update cr
set cr.text7 = Substring(ud.Udefdata, 1, 2)
from dba.Udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 6
and cr.text21 in ('client ids')
and cr.text7 = 'Not Provided'
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text7',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------------------------------------------------------------
---Update Text7 - Mexico
SET @TransStart = getdate()
update cr
set cr.text7 =  ud.udefdata
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 4
and cr.text21 in ('client ids')
and cr.text7 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text7',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--------------------------------------------------------------------------------
---Update Text7 - France
SET @TransStart = getdate()
update cr
set cr.text7 =  Substring(ud.Udefdata, 1, 10)
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 9
and cr.text21 in  ('client ids')
and cr.text7 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text7',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------------------------------------------------------
---Update text10 -  Belgium
SET @TransStart = getdate()
update cr
set cr.text10 =  Substring(ud.Udefdata, 1, 7)
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 8
and cr.text21 in  ('client ids')
and cr.text10 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text10',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------------------------------------------------------

---Update text10 -  France
SET @TransStart = getdate()
update cr
set cr.text10 =  Substring(ud.Udefdata, 1, 10)
from dba.udef ud, dba.comrmks cr
where ud.iatanum = '@iatanum'
and cr.iatanum = ud.iatanum
and cr.clientcode = ud.clientcode
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and ud.udefnum = 7
and cr.text21 in  ('client ids')
and cr.text10 = 'Not Provided'
and ud.udefdata <> ''
and cr.invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Cost Center Text10',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---------------------------------------------------------------------------------------------------------------


SET @TransStart = getdate()
/*
Added the following logic to update cr.Text14 - sq 3/13/2015
Updated logic for refunds outer join and refunds missing segments - sq 3/13/2015
*/

SET @TransStart = getdate()
/*First Class Cabin*/
update cr
set cr.Text14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM @productionserver.@productiondatabasename.dba.InvoiceHeader IH
INNER JOIN @productionserver.@productiondatabasename.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 
 INNER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' 
 AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' 
                                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' 
                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 

WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'First'
   AND CR.Text14 = 'Not Provided'
   AND ID.Iatanum IN ('@IataNum')
   AND IH.Importdt >= getdate()-14
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Business Class Cabin*/
update cr
set cr.Text14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM @productionserver.@productiondatabasename.dba.InvoiceHeader IH
INNER JOIN @productionserver.@productiondatabasename.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Business'
   AND CR.Text14 ='Not Provided'
   AND ID.Iatanum IN ('@IataNum')
   AND IH.Importdt >= getdate()-14
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Business',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Premium Economy Class Cabin*/
update cr
set cr.Text14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM @productionserver.@productiondatabasename.dba.InvoiceHeader IH
INNER JOIN @productionserver.@productiondatabasename.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Premium Economy'
   AND CR.Text14 ='Not Provided'
   AND ID.Iatanum IN ('@IataNum')
   AND IH.Importdt >= getdate()-14
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Premium Economy',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Economy Class Cabin - includes 'Unclassified' cabin*/
update cr
set cr.Text14 = 'Economy'
FROM @productionserver.@productiondatabasename.dba.InvoiceHeader IH
INNER JOIN @productionserver.@productiondatabasename.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN @productionserver.@productiondatabasename.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end in ('Economy', 'Unclassified')
   AND TS.MinDestCityCode is not null
   AND CR.Text14 ='Not Provided'
   AND ID.Iatanum IN ('@IataNum')
   AND IH.Importdt >= getdate()-14
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Economy',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/*
Update refunds in dba.invoicedetail that do not have corresponding rows in dba.transeg
by linking the refund document number back to the original debit transaction and using the value
in cr.Text14
*/
SET @TransStart = getdate()
update cr
set cr.Text14 = crorig.Text14
FROM @productionserver.@productiondatabasename.dba.InvoiceHeader IH  
 INNER JOIN @productionserver.@productiondatabasename.dba.InvoiceDetail ID  ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 

INNER JOIN @productionserver.@productiondatabasename.dba.InvoiceDetail IDOrig ON (IDOrig.Recordkey <> ID.Recordkey and IDOrig.IataNum = ID.IataNum AND IDOrig.ClientCode = ID.ClientCode and ID.documentnumber = IDOrig.DocumentNumber and IDOrig.RefundInd not in ('Y','P') ) 
 INNER JOIN @productionserver.@productiondatabasename.dba.ComRmks CROrig ON ( CROrig.RecordKey = IDOrig.RecordKey AND CROrig.IataNum = IDOrig.IataNum AND CROrig.SeqNum = IDOrig.SeqNum AND CROrig.ClientCode = IDOrig.ClientCode) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND CR.Text14 is null
   AND ID.Iatanum IN ('@IataNum')
   AND IH.Importdt >= getdate()-14
   and id.refundind in ('Y','P')
   and cr.Text14 = 'Not Provided'
   and not exists (select 1 from dba.transeg ts
                                                                                where ts.recordkey = id.recordkey
                                                                                and ts.iatanum = id.iatanum
                                                                                and ts.seqnum = id.seqnum
                                                                                )
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Refunds',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/*End CR.Text14 update for highest cabin flown*/



-----------------------------------------------------------
--Deleting  existing data from customer production database
-----------------------------------------------------------
SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.Invoiceheader
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.Invoiceheader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.Invoicedetail
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.Invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.Transeg
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.Payment
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.Payment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.Tax
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.Tax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.car
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.hotel
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.udef
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
delete @productionserver.@productiondatabasename.DBA.comrmks
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='delete @productionserver.@productiondatabasename.DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------------------
--Insert data into customer production database from customer staging database
------------------------------------------------------------------------------

SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.Invoiceheader
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.dba.Invoiceheader
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and recordkey not in(select recordkey
from @productionserver.@productiondatabasename.DBA.Invoiceheader
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.InvHeader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.Invoicedetail
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.Invoicedetail
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.Invoicedetail
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.Invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.Transeg
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.Transeg
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.Transeg
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.Payment
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.Payment
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.Payment
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.Payment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.Tax
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.Tax
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.Tax
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.Tax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.car
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.car
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.car
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.hotel
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.hotel
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.hotel
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.udef
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.udef
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.udef
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into @productionserver.@productiondatabasename.DBA.comrmks
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.comrmks
WHERE IATANUm in ('@iatanum')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) not in(select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
from @productionserver.@productiondatabasename.DBA.comrmks
WHERE IATANUm in ('@iatanum'))
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

insert into @productionserver.@productiondatabasename.DBA.client
SELECT *
FROM TTXSASQL02.TMAN503_VOLVO.DBA.client
WHERE IATANUm in ('@iatanum')
AND clientcode not in(select clientcode
from @productionserver.@productiondatabasename.DBA.client
where iatanum = '@iatanum')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT @productionserver.@productiondatabasename.DBA.client',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--------------------------------------------------------------
--Removing beginning and ending spaces in all hotel fields
--------------------------------------------------------------
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from @productionserver.@productiondatabasename.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------
--Removing unseen characters in htlpropertyname and htladdr1
--------------------------------------------------------------

SET @TransStart = getdate()
UPDATE @productionserver.@productiondatabasename.DBA.Hotel
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
update @productionserver.@productiondatabasename.dba.hotel
set masterid = -1
where masterid is null
and (htlpropertyname like 'OTHER%HOTELS%' or htlpropertyname like '%NONAME%')
and (HtlAddr1 is null or HtlAddr1 = '' )
and iatanum = '@iatanum'

 update @productionserver.@productiondatabasename.dba.hotel
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
from @productionserver.@productiondatabasename.dba.hotel htl, atl889.ttxcentral.dba.USZipCodesDeluxe zp
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

update @productionserver.@productiondatabasename.dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null

update @productionserver.@productiondatabasename.dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'


update @productionserver.@productiondatabasename.dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null

update @productionserver.@productiondatabasename.dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null

update @productionserver.@productiondatabasename.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null

update @productionserver.@productiondatabasename.dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null

UPDATE @productionserver.@productiondatabasename.dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null

update @productionserver.@productiondatabasename.dba.hotel
set htlcityname = 'HERTOGENBOSCH'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%MOEVENPICK HOTEL%'

update @productionserver.@productiondatabasename.dba.hotel
set htlcityname = 'NEW YORK'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%OAKWOOD CHELSEA%'

update @productionserver.@productiondatabasename.dba.hotel
set htlcityname = 'NEW YORK'
where masterid is null
and htlcityname not like '[a-z]%'
and htlpropertyname like '%LONGACRE HOUSE%'

update @productionserver.@productiondatabasename.dba.hotel
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
from @productionserver.@productiondatabasename.dba.Hotel
Where MasterId is NULL
AND IataNum = '@iatanum'
and issuedate >'2011-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = '@iatanum',
@Enhancement = 'HNN',
@Client = '@Clientname',
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


