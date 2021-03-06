/****** Object:  StoredProcedure [dbo].[sp_UBS_MAIN]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_MAIN]
@IATANUM VARCHAR (50),
@BEGINISSUEDATEMAIN DATETIME,
@ENDISSUEDATEMAIN DATETIME

 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start UBS Main-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------GPN Padding to ensure 8 characters for all -----------------------------------------
update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where len(remarks2) <> 8 and remarks2 <> 'Unknown'
and IATANUM like @IATANUM
and Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='GPN Padding Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 not in (select corporatestructure from dba.rollup40)
and remarks2 <> 'Unknown' 
and IATANUM like @IATANUM

--------Update Reamrks1 with NULL when not in lookuptable .... LOC/12-3-2012
update id
set remarks1 = NULL
from dba.invoicedetail id
where remarks1 not in (select lookupvalue from dba.lookupdata
	where lookupname = 'trippur') and remarks1 is not NULL
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


-------- Update Remarks2 with Unknown when remarks2 is NULL-----------------------------------
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 is null and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Remarks2/GPN Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------CAR -- Move remarks values to comrmks -----------------------------------------------------
update c
set text42= remarks1 
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text42 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text43= remarks2 
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text43 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN
 
update c
set text44= remarks3
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text44 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text45= remarks4
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text45 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text46= remarks5
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text46 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

-------CAR --Null remarks fields ---------------------------------------------------------------
update c
set c.remarks1 = null,c.remarks2 = null,c.remarks3 = null, c.remarks4 = NULL,c.remarks5 = NULL
from dba.car c
where  c.iatanum like @IATANUM AND c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

--------CAR -- Update remarks from invoicedetail remarks --------------------------------------
update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3, car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car
where i.recordkey = car.recordkey and i.seqnum = car.seqnum and i.iatanum = car.iatanum 
and i.iatanum like @IATANUM and i.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Car remark fields Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- HOTEL --- Copy remarks to Comrmks ------------------------------------------------------
update c
set text37 = remarks1
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text37 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text38 = remarks2
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text38 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text39 = remarks3
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text39 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text40 = remarks4
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text40 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text41 = remarks5
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text41 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN


--------HOTEL --Null remarks fields  ---------------------------------------------------------------
update h
set h.remarks1 = null, h.remarks2 = null, h.remarks3 = null, h.remarks4 = null ,h.remarks5 = null
from dba.hotel h
where  h.iatanum like @IATANUM
AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

--------HOTEL -- Update remarks from invoicedetail remarks -------------------------------------
update h
set h.remarks1 = i.remarks1,  h.remarks2 = i.remarks2,h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum
and i.iatanum like @IATANUM and i.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Hotel remark fields Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update null carrier code where carrier num exists -------------------------------------
update id
set id.valcarriercode = cr.carriercode
from dba.carriers cr, dba.invoicedetail id
where valcarriernum = carriernumber and valcarriernum is NULL and iatanum like @IATANUM
AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

--------  Update Carrier Names------------------------------------------------------------------
update id
set id.vendorname = cr.carriername
from dba.carriers cr, dba.invoicedetail id
where id.valcarriercode = cr.carriercode and id.vendorname <> cr.carriername and iatanum like @IATANUM
AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update id
set id.segmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.segmentcarriercode = cr.carriercode and id.segmentcarriername <> cr.carriername
and iatanum like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update id
set id.minsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.minsegmentcarriercode = cr.carriercode and id.minsegmentcarriername <> cr.carriername
and iatanum like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update id
set id.noxsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.noxsegmentcarriercode = cr.carriercode and  id.noxsegmentcarriername <> cr.carriername
and iatanum like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Update Porter Airlines in ID table -----------------------------------------------------
update i
set valcarriercode = 'PD', vendorname = 'PORTER AIRLINES', valcarriernum = '329'
from dba.transeg t, dba.invoicedetail i
where valcarriercode <> 'pd' and segmentcarriercode = 'pd'
and t.recordkey = i.recordkey and t.seqnum = i.seqnum and t.iatanum like @IATANUM
AND i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Carrier Name updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update Text10 with refund value for the Days in Country report------------------------
update c
set text10 = 'Refunded'
from dba.invoicedetail id, dba.invoicedetail  idd, dba.comrmks c
where id.recordkey <> idd.recordkey and id.documentnumber = idd.documentnumber and id.firstname = idd.firstname
and id.lastname = idd.lastname and id.recordkey = c.recordkey and id.seqnum = c.seqnum
and id.refundind = 'N' and idd.refundind = 'Y' and id.iatanum like @IATANUM
AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update c
set text10 = 'Not Refunded'
from dba.comrmks c
where text10 is NULL and iatanum like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text10 Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update Rail Data ------------------------------------------------------------
update dba.invoicedetail
set vendortype = 'RAIL'
where valcarriercode in ('9b','9f','2v','2r','TTL','ES','DB','2A')
and vendortype <>'FEES' and vendortype <>'RAIL' and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.transeg 
set typecode = 'R'
where segmentcarriercode in ('9b','9f','2v','2r','TTL','ES','DB','2A')
and typecode <>'R' and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update i
set vendortype = 'RAIL'
from dba.invoicedetail i, dba.transeg t
where i.recordkey = t.recordkey and i.seqnum = t.seqnum
and typecode = 'R'
and valcarriercode IN('@@','2C','3Y','2A') and segmentcarriercode IN('@@','2C','3Y','2A')
and i.IATANUM like @IATANUM and i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update i
set vendortype = 'RAIL'
from dba.invoicedetail i
where valcarriercode IN('@@','2C','3Y','2A') 
and recordkey not in (select recordkey from dba.transeg)
and i.IATANUM like @IATANUM and i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update t
set segmentcarriercode = '2V'
from dba.transeg t
where segmentcarriername = 'AMTRAK' and segmentcarriercode <>'2v'
and t.IATANUM like @IATANUM and t.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update i
set valcarriercode = segmentcarriercode
from dba.invoicedetail i, dba.transeg t
where valcarriercode = '2v' and i.iatanum <> 'preubs'
and i.recordkey = t.recordkey and i.seqnum = t.seqnum
and segmentcarriercode <>'2v' and segmentcarriername <> 'amtrak'
and i.IATANUM like @IATANUM and i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Rail updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update Fees -----------------------------------------------------------------------
update dba.invoicedetail
set vendortype = 'FEES'
where valcarriercode = 'XD'
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

----------Update Text1 with Booker Name from Text8 -------- Not at this time only in PreTrip data
---------- will update once we receive in post trip ------------------------ LOC/6/15/2012
update c
set text1 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text8 = substring(r.description,1,8)
and costructid = 'functional' and text8 is not null and text1 is null
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

----- Update Text2 with Approver Name from GPN value in Text14 ---------------------------- LOC/6/15/2012

update c
set text2 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text14 is not null and text2 is  null
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

----------------------------------------------------------------------------------
-------Update the comrmks with the Travelers Name from the Hierarchy table provided by UBS.

-------- Transaction updates
-------- Update Text30 with any values in the remarks2 field that are not in the GPN list

update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i
where i.remarks2 not in (select gpn from dba.Employee) and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM like @IATANUM and c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and text30 is null


SET @TransStart = getdate()

--------Update Tex20 with the Traveler Name from the Hierarchy File ---------------------------------
------- Updated query to added the isnull(text20.... <> e.paxname .  This should update any values 
------- in text 20 when the GPN gets updated ... invoicedate can be changed throughout time as
------- as not to use such a large date range.
------- also added the remarks2 value of 000007% as this is another "unknown" gpn value...
update c
set text20 = paxname
from dba.Employee e, dba.comrmks c, dba.invoicedetail i
where e.gpn = i.remarks2
and remarks2 not like '99999%' and remarks2 not like '000007%' 
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM like @IATANUM and c.Invoicedate > '12-31-2012' and isnull(text20,'X') <> e.paxname

-------- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey 
AND C.IATANUM =I.IATANUM
and c.seqnum = i.seqnum  
and (isnull(c.text20, 'Non GPN') like '%Non GPN%'
	or c.text20 = ' ')
and ((i.remarks2 like ('99999%')) or (i.remarks2 like ('11111%'))
or (i.remarks2 ='Unknown'))
and c.IATANUM like @IATANUM and c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text20 Update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Per email from Sue Shore on 2/3/2011
--------Updating GPN 00193610 fro Julie Zehnter to 99999997--------------------------------------------------------

update dba.invoicedetail
set remarks2 = '99999997'
where remarks2 = '00193619'

--------Update InvoiceDates to = ID Invoicedate ----------------------
update car
set car.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.car car
where car.invoicedate <> id.invoicedate and car.recordkey = id.recordkey and car.seqnum = id.seqnum
and car.IATANUM like @IATANUM and car.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update hotel
set hotel.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.hotel hotel
where hotel.invoicedate <> id.invoicedate and  hotel.recordkey = id.recordkey and hotel.seqnum = id.seqnum
and hotel.IATANUM like @IATANUM and hotel.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update cr
set cr.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.comrmks cr
where cr.invoicedate <> id.invoicedate and cr.recordkey = id.recordkey and cr.seqnum = id.seqnum
and cr.IATANUM like @IATANUM and cr.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update ts
set ts.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.transeg ts
where ts.invoicedate <> id.invoicedate and ts.recordkey = id.recordkey and ts.seqnum = id.seqnum
and ts.IATANUM like @IATANUM and ts.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update u
set u.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.udef u
where u.invoicedate <> id.invoicedate and u.recordkey = id.recordkey and u.seqnum = id.seqnum
and u.IATANUM like @IATANUM and u.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

--------------------------------------------------------------------
-------- Update issuedates to equal invoicedates --------------------------------------------------
update dba.car
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.comrmks
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.hotel
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.transeg
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.udef
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.invoicedetail
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Issue/Invoice Date match Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

------------------------------------------------------------------
-------- Update the booking data to the invoice date where null per email
-------- from UBS on 11/11/11. --------------------------------------------------------------------

update dba.invoicedetail
set bookingdate = invoicedate
where bookingdate is null
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

------Update Text5 with the region 
update c
set text5 = rollup2
from dba.rollup40 r, dba.invoicedetail i, dba.comrmks c
where r.corporatestructure = i.remarks2
and i.recordkey = c.recordkey and i.seqnum = c.seqnum
and remarks2 not like ('99999%') and costructid = 'GEO'
and c.IATANUM like @IATANUM and c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update cr
set text5 = 'Europe EMEA'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AT','AE','BE','CZ','FR','DE','HU','IL','IT','LU','NL','PL','RU','ES','SA','SE','CH','TR','GB','ZA')
and isnull(text5,'Unknown') = 'Unknown'

update cr
set text5 = 'Asia Pacific'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AU','CN','HK','ID','IN','JP','MY','NZ','PH','KR','SG','TW','TH')
and isnull(text5,'Unknown') = 'Unknown'

update cr
set text5 = 'Americas'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('US','CA','BR') and isnull(text5,'Unknown') = 'Unknown'

--------Update remarks3 with rank code from HRI (rollup40)---------------------- LOC 7/12/2012

update i
set remarks3 = rollup10
from dba.invoicedetail i, dba.rollup40 r
where remarks2 = corporatestructure
and remarks3 is null and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Update any old PNR's where the GPN is not valid any more.  UBS says all GPNS are in the HRI file but we
-------- tend to find a few every month where they were in the list and now they are not so this is to catch
-------- those as they throw off the numbers of some reports ... LOC 7/27/2012
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and remarks2 <> 'Unknown' and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

------ Update Text17 (TractID) to N/A where the value does not appear to be a TractID.---LOC /7/31/2012---
update c
set Text17 = 'N/A'
from dba.comrmks c
where isnull(c.Text17,'X') like '%' and not ((c.Text17  like '[1-9][0-9][0-9][0-9][0-9]') or 
(c.Text17 like '[1-9][0-9][0-9][0-9][0-9][0-9]') 
or(c.text17 like '[0-9][0-9][A-Z][A-Z][A-Z][1-9][0-9]')
or (c.Text17 = 'O') or (c.text17 = 'A')) 
and c.Text17 <> 'N/A'
and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

Update c
set Text17 = 'N/A'
from dba.comrmks c
where Text17 is null and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

Update c
set Text17 = 'N/A'
from dba.comrmks c
where Text17 in ('11111','111111') and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Booker GPN Validation ---When NULL------------------LOC/8/3/2012
update c
set text8 = 'Not Provided'
from dba.comrmks c
where  text8 is NULL and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Booker GPN Validation ----When Invalid-----------------LOC/8/3/2012
update c
set text8 = 'Not Valid'
from dba.comrmks c
where text8 <> 'Not Provided'
and text8 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Approver GPN Validation ------When Null---------------LOC/8/3/2012
update c
set text14 = 'Not Provided'
from dba.comrmks c
where text14 is NULL and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Approver GPN Validation -----When Invalid----------------LOC/8/3/2012
update c
set text14 = 'Not Valid'
from dba.comrmks c
where text14 <> 'Not Provided'
and text14 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Begin Delete/Insert',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update hotel and car dupe flags to N incase of data reload or changes .. LOC/4/23/2013
update dba.hotel set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and IATANUM like @IATANUM
update dba.car set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and IATANUM like @IATANUM


SET @TransStart = getdate()
-------- Update hotel dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM like @IATANUM and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator and First.htlConfNum = Second.htlConfNum
and First.IssueDate < Second.Issuedate and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and datediff(dd,first.checkindate,second.checkindate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.invoicedate > '12-31-2010'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel Dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
-------- Update Car dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.car First , dba.car Second
where First.IATANUM like @IATANUM and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator and First.CarConfNum = Second.CarConfNum
and First.IssueDate < Second.Issuedate and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.invoicedate > '12-31-2010'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--- Update product type to be consistant... LOC/12/4/2012
update dba.invoicedetail
set producttype = Case when producttype = 'Air' then 'AIR' 
when producttype = 'Hotel' then 'HOTEL'
when producttype = 'Misc' then 'MISC'
when producttype = 'Rail' then 'RAIL'
end 

-------- Update Num1 with htlcomparerate2 from TMC data so that we can use this field for
	---- hotel rates in local currency ------ LOC/11/2/2012
update c
set num1 = htlcomparerate2
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum
and num1 is null
and c.IATANUM like @IATANUM
AND c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.hotel
set htlcomparerate2 = NULL
where htlcomparerate2 is not NULL
and IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Move document number to Text4 where length is greater than 10 .. LOC/5/28/2013
update c
set text4 = documentnumber
from dba.comrmks c, dba.invoicedetail id
where c.recordkey = id.recordkey  and c.seqnum = id.seqnum
and len(documentnumber) > 10 and id.iatanum <> 'preubs' and id.recordkey = c.recordkey
and c.IATANUM like @IATANUM
AND c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Update document number to first 10 of dataprovided where match is made to cc data...LOC/5/28/2013
update id
set documentnumber = substring(documentnumber,1,10)
from TTXPASQL01.tman_UBS.dba.invoicedetail id, TTXPASQL01.tman_UBS.dba.ccticket cct
where len(documentnumber) > 10
and id.iatanum <> 'preubs' and id.iatanum like 'ubsbcd%'
and vendortype in ('bsp','nonbsp') and substring(documentnumber,1,10) = ticketnum 
and substring(passengername,1,5) = substring((lastname+'/'+firstname),1,5)
and matchedrecordkey is null

-------- Manual updates to be processed ------- these come from UBS and are run each month
-------- as both BCD and CWT data get over written ---- LOC 6/26/2013

update i
set remarks2 = (cast(correctgpn as decimal(2000))) 
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where i.recordkey = d.recordkey and iatanum like 'ubsbcd%'

update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where len(remarks2) <> 8 and remarks2 <> 'Unknown' and iatanum like 'ubsbcd%'

update h
set remarks2 = (cast(correctgpn as decimal(2000))) 
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where h.recordkey = d.recordkey and iatanum like 'ubsbcd%'

update h
set remarks2 = right('00000000'+Remarks2,8)
from dba.hotel h
where len(remarks2) <> 8 and remarks2 <> 'Unknown' and iatanum like 'ubsbcd%'

update c
set remarks2 = (cast(correctgpn as decimal(2000))) 
from dba.car c, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where c.recordkey = d.recordkey and iatanum like 'ubsbcd%'

update c
set remarks2 = right('00000000'+Remarks2,8)
from dba.car c
where len(remarks2) <> 8 and remarks2 <> 'Unknown' and iatanum like 'ubsbcd%'

update c 
set text20 = paxname 
from dba.Employee e, 
dba.comrmks c, 
dba.invoicedetail i 
where e.gpn = i.remarks2 
and remarks2 not like ('99999%') and remarks2 not like '000007%'
and c.recordkey = i.recordkey 
and c.seqnum = i.seqnum 
and c.IATANUM like @IATANUM 
and c.invoicedate > '1-1-2013' and c.text20 <> e.paxname

update i
set reasoncode1 = [air reason code]
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where i.recordkey = d.recordkey 
and [air reason code] is not null

update c
set text14 = [approver]
from dba.comrmks c, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where c.recordkey = d.recordkey 
and approver is not null

update c
set text2 = [approver name]
from dba.comrmks c, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where c.recordkey = d.recordkey 
and [approver name] is not null

update h
set htlreasoncode1 = htlreasoncode
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where h.recordkey = d.recordkey 
and htlreasoncode is not null

--------- Updates to EMEA Reason Codes ----- LOC/9/19/2013
update i
set reasoncode1 = newairrc
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where i.recordkey = r.recordkey and i.seqnum = r.seqnum and newairrc is not null

update r
set lastupdate = getdate()
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where i.recordkey = r.recordkey and i.seqnum = r.seqnum and newairrc is not null

update h
set htlreasoncode1 = newhtlrc
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where h.recordkey = r.recordkey and h.seqnum = r.seqnum and newhtlrc is not null

update r
set lastupdate = getdate()
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where h.recordkey = r.recordkey and h.seqnum = r.seqnum and newhtlrc is not null


-------- Update TrackID from Pre Trip where mising or invalid ----- LOC/7/9/2013
update c2
set c2.text17 = c1.text17
from TTXPASQL01.TMAN_UBS.dba.comrmks c1, dba.comrmks c2, 
	 TTXPASQL01.TMAN_UBS.dba.invoicedetail i1, dba.invoicedetail i2
where c1.recordkey = i1.recordkey and c1.seqnum = i1.seqnum and c1.iatanum ='preubs'
and c2.recordkey = i2.recordkey and c2.seqnum = i2.seqnum and c2.iatanum like 'ubsbcd%'
and i1.documentnumber= i2.documentnumber and i1.gdsrecordlocator = i2.gdsrecordlocator
and c1.text17 <> 'N/A' and c2.text17 = 'N/A'
and c1.invoicedate > '1-1-2013' and c1.text17 not like '1111%'
and i1.lastname = i2.lastname

-------- Update the min and nox segment mileage where it is negative when it should be positive.
-------- This is happening throught the .dll and is occuring with exchanges.  -- This is affecting
-------- the UBS Segment Mileage reports ----- LOC/9/27/2013
update t
set  noxsegmentmileage = noxsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and noxsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'

update t
set  minsegmentmileage = minsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and minsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'

update i
set  mileage = mileage*-1
from dba.invoicedetail i
where i.mileage <0 
and i.invoicedate > '1-1-2012' and i.exchangeind = 'y'

-------- Update Hotel and Car Remakrs2 where not = to Invoicedetail Remarks2
update h set h.remarks2 = i.remarks2
from dba.hotel h, dba.invoicedetail i
where h.recordkey = i.recordkey and h.seqnum = i.seqnum
and h.remarks2 <> i.remarks2
and h.invoicedate > '1-1-2013' and i.iatanum <> 'preubs'

update c set c.remarks2 = i.remarks2
from dba.car c, dba.invoicedetail i
where c.recordkey = i.recordkey and c.seqnum = i.seqnum
and c.remarks2 <> i.remarks2
and c.invoicedate > '1-1-2013' and i.iatanum <> 'preubs'


---DELETE -- INSERT -- TO TABLES

delete TTXPASQL01.TMAN_ubs.dba.Invoiceheader
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


delete TTXPASQL01.TMAN_ubs.dba.Invoicedetail
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.payment
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.tax
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.transeg
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.comrmks
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.car
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.hotel
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.udef
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Delete Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


----------------------------- INSERT  ---------------------------------------------------
insert into TTXPASQL01.TMAN_ubs.dba.Invoiceheader
SELECT *
from DBA.Invoiceheader
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_UBS.dba.Invoiceheader
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)


insert into TTXPASQL01.TMAN_UBS.dba.Invoicedetail
SELECT *
from DBA.Invoicedetail
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_UBS.dba.Invoicedetail
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_UBS.dba.Transeg
SELECT  *
from DBA.Transeg
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_UBS.dba.Transeg
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.Payment
SELECT *
from DBA.Payment
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.Payment
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)


insert into TTXPASQL01.TMAN_ubs.dba.Tax
SELECT *
from DBA.Tax
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.Tax 
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.car
SELECT *
from DBA.car
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.car
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)


insert into TTXPASQL01.TMAN_ubs.dba.hotel
SELECT *
from DBA.hotel
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.hotel
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.udef
SELECT *
from DBA.udef
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.udef
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.comrmks
SELECT *
from DBA.comrmks
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.comrmks
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.client
SELECT *
from DBA.client
WHERE IATANUM like @IATANUM AND clientcode+iatanum not in(select clientcode+iatanum
from TTXPASQL01.TMAN_ubs.dba.client)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Insert Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum <> 'preubs'
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(25)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,5) = substring(passengername,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
and id.IATANUM like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum <> 'preubs'
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(25)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,5) = substring(passengername,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
and id.IATANUM like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.matchedind = '2'
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum <> 'preubs'
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(25)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,5) = substring(passengername,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
and id.IATANUM like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBS Main SP Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 




















GO
