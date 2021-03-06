/****** Object:  StoredProcedure [dbo].[sp_SSBCWT]    Script Date: 7/14/2015 8:15:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_SSBCWT]
@BeginIssueDate datetime,
@EndIssueDate datetime

 AS


SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'SSBCWT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))



--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



/* Mappings per Implementations workbook 12/12/13...Nina
User Defined fields
Text1 = UserID_EmployeeID
Text2 = POS
Text3 = CostCenter
Text4 = 
Text5 = 
Text6 =  
Text7 = Trip_Purpose
Text8 = Online Booking
Text9 = 
Text10 = 
Text11 = 
Text12 = Booker
Text14 = Highest Cabin (added 12/19/2014 #50322)
********

*/

SET @TransStart = getdate()
--Update invoicedate for each table to match invoicedate in invoiceheader
Update id
set id.invoicedate = ih.invoicedate
from dba.invoicedetail id, dba.invoiceheader ih
where id.iatanum = 'SSBCWT'
and id.recordkey = ih.recordkey
and id.iatanum = ih.iatanum
and id.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in InvoiceDetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ts
set ts.invoicedate = ih.invoicedate
from dba.transeg ts, dba.invoiceheader ih
where ts.iatanum = 'SSBCWT'
and ts.recordkey = ih.recordkey
and ts.iatanum = ih.iatanum
and ts.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update car
set car.invoicedate = ih.invoicedate
from dba.car car, dba.invoiceheader ih
where car.iatanum = 'SSBCWT'
and car.recordkey = ih.recordkey
and car.iatanum = ih.iatanum
and car.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ht
set ht.invoicedate = ih.invoicedate
from dba.hotel ht, dba.invoiceheader ih
where ht.iatanum = 'SSBCWT'
and ht.recordkey = ih.recordkey
and ht.iatanum = ih.iatanum
and ht.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update ud
set ud.invoicedate = ih.invoicedate
from dba.udef ud, dba.invoiceheader ih
where ud.iatanum = 'SSBCWT'
and ud.recordkey = ih.recordkey
and ud.iatanum = ih.iatanum
and ud.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update pt
set pt.invoicedate = ih.invoicedate
from dba.payment pt, dba.invoiceheader ih
where pt.iatanum = 'SSBCWT'
and pt.recordkey = ih.recordkey
and pt.iatanum = ih.iatanum
and pt.invoicedate <> ih.invoicedate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update InvoiceDate in Payment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update tx
set tx.invoicedate = ih.invoicedate
from dba.tax tx, dba.invoiceheader ih
where tx.iatanum = 'SSBCWT'
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
and cr.iatanum ='SSBCWT'
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
and cr.iatanum ='SSBCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Hotel Issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update InvoiceDetail to remove Mr/Mrs/Ms from First name - impacting grouping in reports when group by lastname,firstname
--SF#6477984 7/14/2015 KP
SET @TransStart = getdate()
update id
set firstname=Case when FirstName like '%MS' then REPLACE(FirstName,'MS','')
else FirstName end
From dba.invoicedetail ID
where iatanum='SSBCWT'
AND FIRSTNAME NOT IN ('MS')
AND FIRSTNAME LIKE '%MS'
     
update id
set firstname=Case when FirstName like '%MRS' then REPLACE(FirstName,'MRS','')
else FirstName end
from dba.invoicedetail ID
where iatanum='SSBCWT'
AND FIRSTNAME NOT IN ('MRS')
AND FIRSTNAME LIKE '%MRS'
     
update id
set firstname=Case when FirstName like '%MR' then REPLACE(FirstName,'MR','')
else FirstName end
from dba.invoicedetail ID
where iatanum='SSBCWT'
AND FIRSTNAME NOT IN ('MR')
AND FIRSTNAME LIKE '%MR'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Hotel Issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--update CWT hotel chain codes
--select ht.htlchaincode,ch.trxcode,ht.htlchainname,ch.trxchainname
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, ttxpaSQL09.tman503_Halliburton.dba.cwthtlchains ch
where len(ht.htlchaincode) > 2
and ht.htlchaincode = ch.cwtcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CWT Hotel Chain Codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--update car chain code ZL1/ZL2 to ZL and update car chain name to National 3/19/10
update dba.car
set carchainname = 'NATIONAL CAR RENTAL',
carchaincode = 'ZL'
where iatanum = 'SSBCWT'
and carchainname is null
and cardailyrate is not null
and (carchaincode = 'ZL1'
or carchaincode = 'ZL2')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update chain code for National',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.invoicedetail
set vendortype = 'RAIL'
where iatanum = 'SSBCWT'
and vendortype = 'NONAIR'
and vendorname like '%rail%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update vendortype = RAIL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update vendortype to Rail for specific rail codes that do not have 'Rail' in the vendor name
--Added on 6/12/14 by Nina per case 00039034
SET @TransStart = getdate()
update dba.InvoiceDetail
set VendorType = 'RAIL'
where IataNum = 'SSBCWT'
and vendornumber in ('2A','2R','2V','9F', 'TRNL') 
and VendorType = 'NONAIR'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update vendortype = RAIL2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.InvoiceDetail
set VendorType = 'RAIL'
where IataNum = 'SSBCWT'
and VendorName in ('FERROVIE DELLO STATO',
'INTERNATIONAL RAIL SUPPLIER',
'NEDERLANDSE SPOORWEGEN',
'NMBS - SNCB',
'Nuovo Trasporto Viaggiatori',
'POLSKIE KOLEJE PANSTWOWE',
'SNCF') 
and VendorType <> 'RAIL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update vendortype = RAIL2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
----Update IntlSalesInd = InternationalInd
----Added on 2/27/15 by Nina per case 06019867
update dba.invoicedetail
set intlsalesind = internationalind
from dba.invoicedetail
where intlsalesind is null
and internationalind is not null
and iatanum in ('SSBCWT')
and issuedate >= '2011-01-01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update IntlSalesInd = InternationalInd',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
----Update InternationalInd to D for Domestic, C for Continental, and I for Intercontinental
----Added on 2/27/15 by Nina per case 06019867
update id
set id.intlsalesind = case when destctry.ctrycode = origctry.ctrycode then 'D'
						   when origctry.continentcode = destctry.continentcode then 'C'
						   end
from dba.invoicedetail id, dba.transeg ts, dba.city origcit, dba.city destcit, 
dba.country origctry, dba.country destctry
where id.origincode = origcit.citycode
and origcit.countrycode = origctry.ctrycode
and id.destinationcode = destcit.citycode
and destcit.countrycode = destctry.ctrycode
and origcit.typecode = ts.typecode
and destcit.typecode = ts.typecode
and id.recordkey = ts.recordkey
and id.seqnum = ts.seqnum
and ts.segmentnum = 1
and id.iatanum in ('SSBCWT')
and id.issuedate >= '2011-01-01'
and id.internationalind = 'I'
and origctry.continentcode = destctry.continentcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update IntlSalesInd to D or C or I',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
----Update MealName = MinInternationalInd
----Added on 2/27/15 by Nina per case 06019867
update ts
set ts.mealname = ts.mininternationalind
from dba.transeg ts
where ts.iatanum in ('SSBCWT')
and ts.issuedate >= '2011-01-01'
and (ts.mealname not in ('C','D','I')
or ts.mealname is null)
and ts.minMktDestCityCode >'A'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update MealName = MinInternationalInd',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
----Update MealName to D for Domestic, C for Continental, and I for Intercontinental
----Added on 2/27/15 by Nina per case 06019867
update ts
set ts.mealname = case when destctry.ctrycode = origctry.ctrycode then 'D'
				       when origctry.continentcode = destctry.continentcode then 'C'
				       end
from dba.transeg ts, dba.city origcit, dba.city destcit, 
dba.country origctry, dba.country destctry
where ts.minMktOrigCityCode = origcit.citycode
and origcit.countrycode = origctry.ctrycode
and ts.minMktDestCityCode = destcit.citycode
and destcit.countrycode = destctry.ctrycode
and origcit.typecode = ts.typecode
and destcit.typecode = ts.typecode
and ts.iatanum in ('SSBCWT')
and ts.issuedate >= '2011-01-01'
and ts.mininternationalind = 'I'
and origctry.continentcode = destctry.continentcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update MealName to D or C or I',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update NumNights in hotel to show as a negative when the amount is a refund
--Added on 10/28/14 by Nina per case #00046693
SET @TransStart = getdate()
update dba.Hotel
set NumNights = -1*NumNights
where iatanum = 'SSBCWT'
and TtlHtlCost < 0
and NumNights > 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update NumNights for Refunds',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update NumDays in car to show as a negative when the amount is a refund
--Added on 10/28/14 by Nina per case #00046693
SET @TransStart = getdate()
update dba.car
set NumDays = -1*NumDays
where iatanum = 'SSBCWT'
and TtlCarCost < 0
and NumDays > 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update NumDays for Refunds',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Insert rows in Comrmks.....
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
from dba.invoicedetail
where recordkey+iatanum+convert(char(2),seqnum) not in 
(select recordkey+iatanum+convert(char(2),seqnum) from dba.comrmks where iatanum = 'SSBCWT')
and iatanum = 'SSBCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text2 with POS from InvoiceHeader
update CR
set text2 = IH.ORIGCOUNTRY
from dba.invoiceheader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = cr.iatanum
and ih.iatanum = 'SSBCWT'
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text2 with POS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
--Update comrmks for Text1 (EmployeeID/UserID) From UDEF 1
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum in ('SSBCWT')
and ud.udefnum = 1
and cr.text1 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text1 from UD1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text3 (Cost Center) from UD11
update cr
set cr.text3 = substring(ud.udefdata,1,7)
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum in ('SSBCWT')
and ud.udefnum = 11
and cr.Text3 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text3 from UD11',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update comrmks for Text7 Trip Purpose from UDEF 3
update cr
set cr.text7 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum = 'SSBCWT'
and ud.udefnum = 3
and cr.Text7 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text7 with TripPurpose from UD3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--Update Text8 with Online/Offline based on country code and verbiage in Online Booking System
--Updated on 1/28/15 by Nina per case #
SET @TransStart = getdate()
--Update Text8 with Online/Offline for US
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('REARDEN CO') then 'Online'
				when id.OnlineBookingSystem in ('OTHERS') then 'Offline'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.Text8
				end
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'US'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Online/Offline for CA
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('REARDEN CO') then 'Online'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.text8
				end		
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'CA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Online/Offline for GB
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('CONCUR TRA','AMADEUS E-','E-TRAVELLE','KDS CORPOR','TRAVEL-DOO') then 'Online'
				when id.OnlineBookingSystem in ('CWT WEBFAR','HARP AGENC','OTHERS','TELEPHONE','TRAINLINE','HOTEL HUB') then 'Offline'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.Text8
				end		
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'GB'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for GB',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Online/Offline for IE
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('CONCUR TRA','E-TRAVELLE','KDS CORPOR','AMADEUS E-') then 'Online'
				when id.OnlineBookingSystem in ('CWT WEBFAR','HARP AGENC') then 'Offline'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.Text8
				end		
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'IE'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for IE',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Online/Offline for DE
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('CONCUR TRA','AMADEUS E-','CWT TRAIN','E-TRAVELLE','KDS CORPOR','KDS PORTAL') then 'Online'
				when id.OnlineBookingSystem in ('HARP AGENC','OTHERS','TELEPHONE','ADVISOR','E-MAIL','FAX','BTS') then 'Offline'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.Text8
				end		
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'DE'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for DE',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Online/Offline for LU
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('HARP AGENC','CWT WEBFAR','WEBFARES') then 'Offline'
				when id.OnlineBookingSystem in ('E-TRAVELLE') then 'Online'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.Text8
				end		
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'LU'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for LU',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Online/Offline for NL
update cr
set cr.Text8 =	case when id.OnlineBookingSystem in ('HARP AGENC','CWT WEBFAR','E-MAIL') then 'Offline'
				when id.onlinebookingsystem IS NULL then 'Offline'
				else cr.Text8
				end		
from dba.invoicedetail id, dba.comrmks cr, dba.InvoiceHeader ih
where id.recordkey = cr.recordkey
and id.recordkey = ih.RecordKey
and id.seqnum = cr.seqnum
and id.iatanum = 'SSBCWT'
and id.iatanum = cr.iatanum
and id.IataNum = ih.IataNum
and cr.text8 is null
and ih.OrigCountry = 'NL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Online/Agent for NL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update Text8 with Offline for all other countries
update cr
set cr.Text8 = 'Offline'
from dba.InvoiceHeader ih, dba.comrmks cr
where ih.recordkey = cr.recordkey
and ih.iatanum = 'SSBCWT'
and ih.iatanum = cr.iatanum
and ih.OrigCountry not in ('US','CA','GB','IE','DE','LU','NL')
and cr.text8 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text8 with Offline for all other countries',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
--update Text9 with Employee Title from dba.hierarchy_temp
update cr
set cr.text9 = h.BankTitleDescr
from dba.ComRmks cr, dba.hierarchy_temp h
where cr.text1 = h.emplid 
and cr.text9 is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text9 with Employee title from dba.hierarchy_temp',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
----Update comrmks for Text12 Booker From UDEF 2
update cr
set cr.text12 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.recordkey = ud.recordkey
and cr.iatanum = ud.iatanum
and cr.seqnum = ud.seqnum
and cr.iatanum in ('SSBCWT')
and ud.udefnum = 2
and cr.Text12 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text12 with SupvUserID from UD12',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
----Update comrmks for Text47 = text3 - CB - 03/03 - case 00031709
update cr 
set cr.text47 = cr.text3 
from dba.comrmks cr 
where cr.text3 in (select distinct corporatestructure from dba.rollup40) 
and cr.text47 is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update comrmks for Text47 = text3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
----Update comrmks for Text47 = hr.deptid - CB - 03/03 - case 00031709
update cr 
set cr.text47 = hr.deptid 
from dba.comrmks cr, dba.hierarchy_temp hr 
where cr.text1 = hr.emplid 
and cr.text47 is null 
--and hr.enddate >= getdate() 
and hr.deptid in (select distinct corporatestructure from dba.rollup40)
and cr.issuedate between hr.begindate and hr.enddate 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update comrmks for Text47 = hr.deptid',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update comrmks for Text50 for hierarchy validation and 100% association
SET @TransStart = getdate()
update  cr
set cr.Text50 = 'NOT VALID'
from dba.ComRmks cr 
where cr.Text50 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update comrmks for Text50 = NOT VALID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Update comrmks for Text50 for hierarchy validation and 100% association
SET @TransStart = getdate()
update cr
set cr.text50 = CR.TEXT47
from dba.ComRmks cr, dba.ROLLUP40 ru
where cr.Text47 = ru.CORPORATESTRUCTURE 
and ru.COSTRUCTID = 'functional'
and cr.text50<>CR.text47
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update comrmks for Text50 = TEXT 47',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




SET @TransStart = getdate()
--Update dba.ClassToCabin 
--from transeg
insert into dba.classtocabin
select distinct substring(ts.SegmentCarrierCode,1,3), substring(ts.ClassOfService,1,1), 'ECONOMY',ts.segInternationalInd,'Y',NULL,NULL
from dba.transeg ts
where ts.iatanum = 'SSBCWT'
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
where ID.IataNum = 'SSBCWT'
and ID.VendorType in ('BSP','NONBSP','RAIL')
and id.valcarriercode is not null
and id.ServiceCategory is not null
and substring(id.valcarriercode,1,3)+substring(id.ServiceCategory,1,1)+InternationalInd not in (select carriercode+classofservice+internationalind 
from dba.classtocabin)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update classtocabin from invoicedetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--New Highest Cabin - update for Text14 50332 12/19/2014
/*First Class Cabin*/

update cr
set CR.TEXT14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_statestreet.dba.InvoiceHeader IH
INNER JOIN tman503_statestreet.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_statestreet.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 
 INNER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' 
 AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' 
                                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' 
                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 

WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND ID.iatanum = 'SSBCWT'
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'First'
   AND CR.TEXT14 is null
   --AND IH.Importdt >= getdate()-10

/*Business Class Cabin*/

update cr
set CR.TEXT14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_statestreet.dba.InvoiceHeader IH
INNER JOIN tman503_statestreet.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_statestreet.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND ID.iatanum = 'SSBCWT'
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Business'
   AND CR.TEXT14 is null
   --AND IH.Importdt >= getdate()-10

/*Premium Economy Class Cabin*/
update cr
set CR.TEXT14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_statestreet.dba.InvoiceHeader IH
INNER JOIN tman503_statestreet.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_statestreet.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND ID.iatanum = 'SSBCWT'
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Premium Economy'
   AND CR.TEXT14 is null
   --AND IH.Importdt >= getdate()-10


/*Economy Class Cabin - includes 'Unclassified' cabin*/
update cr
set CR.TEXT14 = 'Economy'
FROM tman503_statestreet.dba.InvoiceHeader IH
INNER JOIN tman503_statestreet.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_statestreet.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN tman503_statestreet.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND ID.iatanum = 'SSBCWT'
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end in ('Economy', 'Unclassified')
   AND TS.MinDestCityCode is not null
   AND CR.TEXT14 is null
  -- AND IH.Importdt >= getdate()-10

--Standard post import sql update for text24 - HighestCabin Removed 12/19/14 and update moved to Text14 #50332 
--InvoiceDetail.ServiceCategory is first segment's class of service not highest cabin flown
--SET @TransStart = getdate()
--update cr
--set cr.text24 = 'FIRST'
--from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
--where cr.recordkey = ts.recordkey
--and cr.iatanum = ts.iatanum
--and cr.seqnum = ts.seqnum
--and ts.Minsegmentcarriercode = ctc.carriercode
--and ts.MINclassofservice = ctc.classofservice
--and ts.MINinternationalind = ctc.InternationalInd
--and cr.iatanum in ('SSBCWT')
--and ctc.DomCabin = 'First'
--and cr.text24 is null
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text24 = DomCabin where DomCabin = First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--update cr
--set cr.text24 = 'BUSINESS'
--from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
--where cr.recordkey = ts.recordkey
--and cr.iatanum = ts.iatanum
--and cr.seqnum = ts.seqnum
--and ts.MINsegmentcarriercode = ctc.carriercode
--and ts.MINclassofservice = ctc.classofservice
--and ts.MINinternationalind = ctc.InternationalInd
--and cr.iatanum in ('SSBCWT')
--and ctc.DomCabin = 'Business'
--and cr.text24 is null
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text24 = DomCabin where DomCabin = Business',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--update cr
--set cr.text24 = 'ECONOMY'
--from dba.comrmks cr,dba.transeg ts, dba.classtocabin ctc
--where cr.recordkey = ts.recordkey
--and cr.iatanum = ts.iatanum
--and cr.seqnum = ts.seqnum
--and ts.MINsegmentcarriercode = ctc.carriercode
--and ts.MINclassofservice = ctc.classofservice
--and ts.MINinternationalind = ctc.InternationalInd
--and cr.iatanum in ('SSBCWT')
--and cr.text24 is null
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text24 = DomCabin',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



---HNN Cleanup for DEA

--Clean up hotel spaces
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Clean up unwanted characters in htlpropertyname and htladdr1
--Added on 4/18/13 by Nina per case 00011353
SET @TransStart = getdate()
UPDATE TTXPASQL01.TMAN503_STATESTREET.DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null
and iatanum in ('PREHGP')
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set masterid = -1
where masterid is null
and (htlpropertyname like 'OTHER%HOTELS%' or htlpropertyname like '%NONAME%')
and (htladdr1 is null or htladdr1 = '')
and invoicedate > '2011-12-31'


 update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = '')
and (HtlAddr1 is null or HtlAddr1 = '')
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Parent id -1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update htl
set htl.htlstate = zp.state
from TTXPASQL01.TMAN503_STATESTREET.dba.hotel htl, TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
where substring(htl.htlpostalcode,1,5) = zp.zipcode
and substring(htl.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P'
and htl.masterid is null
and htl.htlstate is null
and htl.htlcountrycode = 'US'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null
and invoicedate > '2011-12-31'

UPDATE TTXPASQL01.TMAN503_STATESTREET.dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null
and invoicedate > '2011-12-31'

	update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
	set htlcityname = 'HERTOGENBOSCH'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%MOEVENPICK HOTEL%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%OAKWOOD CHELSEA%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%LONGACRE HOUSE%'
	and invoicedate > '2011-12-31'


	update TTXPASQL01.TMAN503_STATESTREET.dba.hotel
	set htlcityname = 'BARCELONA'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%HOTLE PUNTA PALMA%'
	and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End htl edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

SET @TransStart = getdate()
Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from TTXPASQL01.TMAN503_STATESTREET.dba.Hotel
Where MasterId is NULL
AND IataNum = 'SSBCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Get dates for NULL MasterIDs',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'SSBCWT',
@Enhancement = 'HNN',
@Client = 'StateStreet',
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
@TextParam2 = 'ttxpasql01',
@TextParam3 = 'TMAN503_STATESTREET',
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Execute HNN',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = GETDATE()
                 


EXEC TTXPASQL01.TMAN503_STATESTREET.dbo.SP_StateStreet_CO2



---sp_ACMPreProcess_Agency is being called in SP_StateStreet_CO2 - CB 12/16/14











GO
