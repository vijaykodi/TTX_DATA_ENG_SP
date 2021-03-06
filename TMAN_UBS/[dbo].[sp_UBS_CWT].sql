/****** Object:  StoredProcedure [dbo].[sp_UBS_CWT]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_CWT]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'UBSCWT'
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

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update car
set car.issuedate = id.issuedate
from dba.car car, dba.invoicedetail id
where car.issuedate <> id.issuedate 
AND id.RecordKey = car.RecordKey and id.SeqNum = car.SeqNum and id.iatanum ='UBSCWT'

update htl
set htl.issuedate = i.issuedate
from dba.hotel htl, dba.invoicedetail i
where htl.issuedate <> i.issuedate
AND i.RecordKey = HTL.RecordKey AND i.SeqNum = HTL.SeqNum and i.iatanum ='UBSCWT'

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate
FROM dba.InvoiceDetail 
	where recordkey+iatanum+convert(varchar,seqnum) not in
	(SELECT recordkey+iatanum+convert(varchar,seqnum) from dba.comrmks
	where iatanum = 'UBSCWT')
and iatanum = 'UBSCWT'

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Insert Comrmks Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Move data from remarks 1,2,3,4,5 to text 32,33,34,35,36
update c
set c.text32 = i.remarks1, 	c.text33 = i.remarks2, 	c.text34 = i.remarks3,
	c.text35 =  i.remarks4, 	c.text36 = i.remarks5
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum and i.iatanum = 'UBSCWT' 
and text32 is null and text33 is null and text34 is null and text35 is null and text36 is null

------- Null Remarks 1,2,3,4,5
update i
set i.remarks1 = null, i.remarks2 = null,i.remarks3 = null,i.remarks4 = null,i.remarks5 = null
from dba.invoicedetail i, dba.comrmks c
where  i.iatanum = 'UBSCWT'
and i.recordkey = c.recordkey and i.seqnum = c.seqnum


------- Set remarks2 to GPN
update i
set i.remarks2 = substring(ud.udefdata,1,8)
from dba.invoicedetail i, dba.udef ud
where i.iatanum = 'UBSCWT' and ud.udefnum = 3
and substring(ud.udefdata,1,8) in (select corporatestructure 
	from dba.rollup40 where costructid = 'functional')
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum
and isnull(i.remarks2,'unknown') = ('unknown')

update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where len(remarks2) <> 8 and iatanum = 'UBSCWT' and remarks2 <>'Unknown'

------- Set remarks1 in invoicedetail to have the Trip Purpose code from Udef
update id
set remarks1 = substring(udefdata,1,100)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and u.iatanum = 'ubscwt' and u.udefnum = '1' and remarks1 is null

------- Set remarks5 to Udef 5 (cost center)
update i
set i.remarks5 = substring(udefdata,1,100)
from dba.invoicedetail i, dba.udef ud
where i.iatanum = 'UBSCWT' and ud.udefnum = 5
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum and remarks5 is null

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Remarks Updates Complete B - UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update onlinebooking system
update i
set onlinebookingsystem = 'Y'
from dba.invoicedetail i
where onlinebookingsystem is not NULL and i.iatanum = 'UBSCWT'

update i
set onlinebookingsystem = 'N'
from dba.invoicedetail i
where onlinebookingsystem is NULL and i.iatanum = 'UBSCWT'

update i
set onlinebookingsystem = 'N'
from dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey and origcountry = 'JP' and i.iatanum = 'UBSCWT'

----- Update Text17 with TRACTID -----  LOC -- 5/17/2012
update c
set text17 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where udefnum = '4' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'ubscwt' and text17 is null

update c
set Text17 = 'N/A'
from dba.comrmks c
where isnull(text17,'X') like '%' and not ((text17  like '[1-9][0-9][0-9][0-9][0-9]') or 
(text17 like '[1-9][0-9][0-9][0-9][0-9][0-9]')
or (text17 = 'O')
or(text17 = 'A'))
and text17 <> 'N/A' and IATANUM ='ubscwt'

Update c
set Text17 = 'N/A'
from dba.comrmks c
where Text17 is null and IATANUM = 'ubscwt'

-------Update approver name in text14
update c
set text14 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'ubscwt' and udefnum = '9'   and c.iatanum = 'UBSCWT'

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Approver Name update Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update Air and Hotel Reason Codes from Udids

-------- Air -------------
update c
set text47 = reasoncode1
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum and i.iatanum = 'UBSCWT' and text47 is null

update i
set reasoncode1 = NULL from dba.invoicedetail i where iatanum = 'UBSCWT'

update i
set reasoncode1 = substring(udefdata,1,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udefnum = '2'  and i.iatanum = 'UBSCWT'

------ Hotel ----------------
update c
set text48 = htlreasoncode1
from dba.hotel h, dba.comrmks c
where h.recordkey = c.recordkey and h.seqnum = c.seqnum and h.iatanum = 'UBSCWT' and text48 is null

update h
set htlreasoncode1 = NULL from dba.hotel h where iatanum = 'UBSCWT'

update h
set htlreasoncode1 = substring(udefdata,1,3)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum and udefnum = '8' and h.iatanum = 'UBSCWT'
and SUBSTRING(udefdata,1,3) in ('X10','X11','X12','X13')


update h
set htlreasoncode1 = substring(udefdata,1,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum and udefnum = '8' and h.iatanum = 'UBSCWT'
AND htlreasoncode1 is NULL and SUBSTRING(udefdata,1,3) NOT in ('X10','X11','X12','X13')
SET @TransStart = getdate()

--update h
--set htlreasoncode1 = substring(udefdata,1,3)
--from dba.hotel h, dba.udef u
--where h.recordkey = u.recordkey and h.seqnum = u.seqnum and udefnum = '8' and h.iatanum = 'UBSCWT'
--and substring(udefdata,1,3) in ('X10','X11','X12','X13')

SET @TransStart = getdate()


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='HtlReasonCode1 Update Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Added hotel chain code update provided by Sue 1DEC2009
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, dba.cwthtlchains ch
where len(ht.htlchaincode) > 2 and ht.htlchaincode = ch.cwtcode and iatanum ='UBSCWT'	

-------update car chain code ZL1/ZL2 to ZL and update car chain name to National 3/19/10
update dba.car
set carchainname = 'NATIONAL CAR RENTAL', carchaincode = 'ZL'
where iatanum = 'UBSCWT' and carchainname is null and cardailyrate is not null
and (carchaincode = 'ZL1' or carchaincode = 'ZL2')

-------CAR -- Move remarks values to comrmks
update c
set text42 = remarks1, text43 = remarks2, text44 = remarks3,text45 = remarks4, text46 = remarks5
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and c.iatanum = car.iatanum
and text42 is null and text43 is null and text44 is null and text45 is null and text46 is null
and c.iatanum = 'UBSCWT'

-------CAR --Null remarks fields 
update c
set c.remarks1 = null, c.remarks2 = null,c.remarks3 = null, c.remarks4 = NULL,c.remarks5 = NULL
from dba.car c
where  c.iatanum = 'UBSCWT' and c.remarks1 is not null

-------CAR -- Update remarks from invoicedetail remarks
update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3,
car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car
where i.recordkey = car.recordkey and i.seqnum = car.seqnum and i.iatanum = car.iatanum
and i.iatanum = 'UBSCWT' and car.remarks1 is null
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Car Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------HOTEL -- Move remarks values to comrmks
update c
set text21 = remarks1, text22 = remarks2, text23 = remarks3,text25 = remarks5
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and text21 is null and text22 is null and text23 is null and text25 is null
and c.iatanum = 'UBSCWT'

-------HOTEL --Null remarks fields 
update h
set h.remarks1 = null,h.remarks2 = null,h.remarks3 = null,h.remarks5 = null
from dba.hotel h
where  h.iatanum = 'UBSCWT' and h.remarks1 is not null

-------HOTEL -- Update remarks from invoicedetail remarks
update h
set h.remarks1 = i.remarks1, h.remarks2 = i.remarks2, h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum
and i.iatanum = 'UBSCWT' and h.remarks1 is null

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Hotel Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update null carrier code where carrier num exists
update id
set id.valcarriercode = cr.carriercode
from dba.carriers cr, dba.invoicedetail id
where valcarriernum = carriernumber and valcarriernum is NULL and iatanum = 'UBSCWT'

-------  Update Carrier Names
update id
set id.vendorname = cr.carriername
from dba.carriers cr, dba.invoicedetail id
where id.valcarriercode = cr.carriercode and id.vendorname <> cr.carriername
and iatanum = 'UBSCWT'

update id
set id.segmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.segmentcarriercode = cr.carriercode and id.segmentcarriername <> cr.carriername
and iatanum = 'UBSCWT'

update id
set id.minsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.minsegmentcarriercode = cr.carriercode and id.minsegmentcarriername <> cr.carriername
and iatanum = 'UBSCWT'

update id
set id.noxsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.noxsegmentcarriercode = cr.carriercode and id.noxsegmentcarriername <> cr.carriername
and iatanum = 'UBSCWT'

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Carrier Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update Text10 with refund value for the Days in Country report
update c
set text10 = 'Refunded'
from dba.invoicedetail id, dba.invoicedetail idd, dba.comrmks c
where id.recordkey <> idd.recordkey
and id.documentnumber = idd.documentnumber
and id.firstname = idd.firstname
and id.lastname = idd.lastname and id.recordkey = c.recordkey and id.seqnum = c.seqnum
and id.refundind = 'N' and idd.refundind = 'Y' and id.iatanum = 'UBSCWT' and c.text10 is NULL

update c
set text10 = 'Not Refunded'
from dba.comrmks c
where text10 is NULL and iatanum = 'UBSCWT'

----------------------------------------------------------------------------
-------Modify Invoice dates to be consistant using the ID invoice date
-------..transeg..

update ts
set ts.InvoiceDate = id.Invoicedate
from dba.invoicedetail id, dba.transeg ts
where id.recordkey = ts.recordkey and id.iatanum = ts.iatanum and id.seqnum = ts.seqnum
and id.invoicedate <> ts.invoicedate and id.iatanum = 'UBSCWT'  

--..hotel..
update htl
set htl.InvoiceDate = id.invoicedate
from dba.invoicedetail id, dba.hotel htl
where id.recordkey = htl.recordkey and id.iatanum = htl.iatanum and id.seqnum = htl.seqnum
and id.invoicedate <> htl.invoicedate and id.iatanum = 'UBSCWT' 

--..car..
update car
set car.Invoicedate = id.InvoiceDate
from dba.invoicedetail id, dba.car car
where id.recordkey = car.recordkey and id.iatanum = car.iatanum and id.seqnum = car.seqnum
and id.invoicedate <> car.invoicedate and id.iatanum = 'UBSCWT' 

--..udef..
update ud
set ud.InvoiceDate = id.InvoiceDate
from dba.invoicedetail id, dba.udef ud
where id.recordkey = ud.recordkey and id.iatanum = ud.iatanum and id.seqnum = ud.seqnum
and id.invoicedate <> ud.invoicedate and id.iatanum = 'UBSCWT' 

--..comrmks..
update cr 
set cr.InvoiceDate = id.invoicedate
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey and id.iatanum = cr.iatanum and id.seqnum = cr.seqnum
and id.invoicedate <> cr.invoicedate and id.iatanum = 'UBSCWT' 

--..tax..
update tax
set tax.InvoiceDate = id.InvoiceDate
from dba.invoicedetail id, dba.tax tax
where id.recordkey = tax.recordkey and id.iatanum = tax.iatanum and id.seqnum = tax.seqnum
and id.invoicedate <> tax.invoicedate  and id.iatanum = 'UBSCWT' 

--..payment..
Update Pay
set Pay.InvoiceDate = id.InvoiceDate
from dba.invoicedetail id, dba.payment pay
where id.recordkey = pay.recordkey and id.iatanum = pay.iatanum and id.seqnum = pay.seqnum
and id.invoicedate <> pay.invoicedate and id.iatanum = 'UBSCWT' 

--..invoicehaader..
update ih
set ih.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.invoiceheader ih
where id.recordkey = ih.recordkey and id.iatanum = ih.iatanum 
and id.invoicedate <> ih.invoicedate and id.iatanum = 'UBSCWT'
 
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Inv/Iss Date Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------------------------
--Update the comrmks with the Travelers Name from the Hierarchy table provided by UBS.

----- Transaction updates
------- Update Text30 with any values in the remarks2 field that are not in the GPN list
update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i
where i.remarks2 not in (select gpn from dba.Employee)
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and remarks2 not in ('Unknown','999999NE','99999ANE') and c.IATANUM = 'UBSCWT'

------- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 not in (select corporatestructure from dba.rollup40) and IATANUM = 'UBSCWT'

-------Update Remarks2 with Unknown code when remarks2 is NULL
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 is null and IATANUM = 'UBSCWT'

-------Update Tex20 with the Traveler Name from the Hierarchy File

update c set text20 = substring(paxname,1,150)
from dba.Employee e, dba.comrmks c, dba.invoicedetail i
where e.gpn = i.remarks2
and remarks2 not in ('Unknown','99999999','99999990','99999989')
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM = 'UBSCWT'  and isnull(text20,' ') = ' '

------- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used
update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey  AND C.IATANUM =I.IATANUM and c.seqnum = i.seqnum  
and (isnull(c.text20, '- Non GPN') like '%- Non GPN%'
	or c.text20 = ' ')
and ((i.remarks2 like ('99999%')) or (i.remarks2 like ('11111%'))
or (i.remarks2 ='Unknown'))
and i.iatanum = 'UBSCWT'

update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where  remarks2 ='Unknown'
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM = 'UBSCWT' and  isnull(text20,' ') = ' '

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text20 Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------
-- Update issuedates to equal invoicedates
update dba.car
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.comrmks
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.hotel
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.transeg
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.invoicedetail
set issuedate = invoicedate where issuedate <> invoicedate and IATANUM = 'UBSCWT'


------------------------------------------------------------------
-- Update the booking data to the invoice date where null per email
-- from UBS on 11/11/11.

update dba.invoicedetail
set bookingdate = invoicedate
where bookingdate is null and IATANUM = 'UBSCWT'

------Update Text5 with the region 
update c
set text5 = rollup2
from dba.rollup40 r, dba.invoicedetail i, dba.comrmks c
where r.corporatestructure = i.remarks2
and i.recordkey = c.recordkey and i.seqnum = c.seqnum
and remarks2 not like ('99999%') and costructid = 'GEO' and c.iatanum ='UBSCWT'

update cr
set text5 = 'Europe EMEA'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AT','AE','BE','CZ','FR','DE','HU','IL','IT','LU','NL','PL','RU','ES','SA','SE','CH','TR','GB','ZA')
and isnull(text5,'Unknown') = 'Unknown' and cr.iatanum ='UBSCWT'

update cr
set text5 = 'Asia Pacific'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AU','CN','HK','ID','IN','JP','MY','NZ','PH','KR','SG','TW','TH')
and cr.iatanum ='UBSCWT' and isnull(text5,'Unknown') = 'Unknown'

update cr
set text5 = 'Americas'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('US','CA','BR')
and cr.iatanum ='UBSCWT' and isnull(text5,'Unknown') = 'Unknown'

-----------------------------------------------------------------------
---**********************************************************************************
---This should begin to show up correctly in the Aug data ------------------------------


----- Update Opportunity/Project Code ----Remarks4 from Udef 7 ----- LOC 5/17/2012
----- This is on hold until CWT confirms.  As of now I see a country name in the UDID 7 field
------ added back in per Yap - 6/18/2013

update c
set text7 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'ubscwt'
and udefnum = '7' and text7 is null
and c.invoicedate > '6-1-2012'

----- Update Text8 with Booker GPN -- Per CWT on 5/16/2012 this is not yet in place so we may
----- not see a lot of movement for a month or 2 ...-- As well they will only be able to provide
----- the first and last name and not the GPN---------- LOC 5/17/2012 --------------------------

update c
set text8 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where udefnum = '6' and c.iatanum = 'ubscwt' and isnull(text8,'Not') like 'Not%'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum

----- Update Text14 with Approver GPN -- -- As well they will only be able to provide
----- the first and last name and not the GPN---------- LOC 5/17/2012 ---------------

update c
set text14 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where udefnum = '9' and c.iatanum = 'ubscwt' and isnull(text14,'Not') like 'Not%'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text14 Approver GPN Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------Start  Udef String data for Validation report ---------LOC  7/31/2012

-------Update Text22 = GPN String----------------------------------- LOC 7/31/2012
update c
set text22 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text22 is null and udefnum = '3' and c.iatanum = 'UBSCWT' 

-------Update Text23 = Trip Purpose String--------------------------- LOC 7/31/2012
update c
set text23 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text23 is null and udefnum = '1' and c.iatanum = 'UBSCWT' 

-------Update Text24 = Cost Center String --------------------------- LOC 7/31/2012
update c
set text24 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text24 is null and udefnum = '5' and c.iatanum = 'UBSCWT' 

---- Not putting in Air and Hotel Reason Codes (Text25 and Text26 as they are in the actual
---- data fields and not from a string of data or udef.---- LOC/7/31/2012

-------Update Text27 = TractID String --------------------------- LOC 7/31/2012
update c
set text27 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text27 is null and udefnum = '4' and c.iatanum = 'UBSCWT' 

------ Will add Booker  once we have confirmed ----- LOC 7/31/2012

-------Update Text29 = Approver GPN String --------------------------- LOC 7/31/2012
update c
set text29 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text29 is null and udefnum = '9' and c.iatanum = 'UBSCWT' 


-----Online booking is Y if there is a value and N if not so no mapping required for
--  the validation..loc/7/31/2012.

update c
set num1 = htlcomparerate2
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum
and num1 is null
and c.IATANUM like 'UBSCWT'

update dba.hotel
set htlcomparerate2 = NULL
where htlcomparerate2 is not NULL
and IATANUM like 'UBSCWT'


--------update Product Type ---- LOC/11/30/2012
update t1
set producttype = 'Air'
from dba.invoicedetail t1, dba.transeg t2
where t1.recordkey = t2.recordkey
and t1.iatanum = t2.iatanum and t1.seqnum = t2.seqnum and t1.clientcode = t2.clientcode 
and t1.vendortype in ('BSP','NONBSP') and t1.producttype <> 'Air'
and t2.typecode = 'A'  and t1.IATANUM = 'UBSCWT'

update t1
set producttype = 'Hotel'
from dba.invoicedetail t1, dba.hotel t2
where t1.recordkey = t2.recordkey and t1.iatanum = t2.iatanum and t1.seqnum = t2.seqnum
and t1.clientcode = t2.clientcode and t1.issuedate = t2.issuedate and vendortype = 'NONAIR'
and t1.producttype <> 'Hotel'  and t1.IATANUM = 'UBSCWT'

update t1
set producttype = 'Car'
from dba.invoicedetail t1, dba.car t2
where t1.recordkey = t2.recordkey and t1.iatanum = t2.iatanum and t1.seqnum = t2.seqnum
and t1.clientcode = t2.clientcode and t1.issuedate = t2.issuedate and vendortype = 'NONAIR'
and t1.producttype <> 'Car'  and t1.IATANUM = 'UBSCWT'

update t1 
set producttype = 'Misc' from dba.invoicedetail t1 where producttype in ('M','R','H','C')
and vendortype = 'NONAIR'  and t1.IATANUM = 'UBSCWT'

update dba.invoicedetail
set producttype = 'FEES' where vendortype = 'FEES'
and iatanum = 'UBSCWT' and producttype <> 'FEES'

-------- Update hotel and car dupe flags to N incase of data reload or changes .. LOC/4/23/2013
update dba.hotel set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and Iatanum = 'UBSCWT'
update dba.car set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and Iatanum = 'UBSCWT'

-------- Update hotel dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.hotel First , dba.hotel Second, dba.InvoiceHeader IH
where First.Iatanum = 'UBSCWT' and second.IataNum = 'UBSCWT' and ih.IataNum = 'UBSCWT'
and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum and First.IssueDate < Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and datediff(dd,first.checkindate,second.checkindate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.RecordKey = ih.RecordKey and First.IataNum = ih.IataNum
and First.InvoiceDate = ih.InvoiceDate and first.ClientCode = ih.ClientCode
and Second.RecordKey = ih.RecordKey and Second.IataNum = ih.IataNum
and Second.InvoiceDate = ih.InvoiceDate and Second.ClientCode = ih.ClientCode
and first.invoicedate > '12-31-2010'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel Dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
-------- Update Car dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.car First , dba.car Second, dba.InvoiceHeader IH
where First.Iatanum = 'Preubs' and second.IataNum = 'preubs' and ih.IataNum = 'preubs'
and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum and First.IssueDate < Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and datediff(dd,first.pickupdate,second.pickupdate) <5 and First.voidind = 'N'
and Second.voidind = 'N' and first.RecordKey = ih.RecordKey and First.IataNum = ih.IataNum
and First.InvoiceDate = ih.InvoiceDate and first.ClientCode = ih.ClientCode and Second.RecordKey = ih.RecordKey
and Second.IataNum = ih.IataNum and Second.InvoiceDate = ih.InvoiceDate and Second.ClientCode = ih.ClientCode
and first.invoicedate > '12-31-2010'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Move document number to Text4 where length is greater than 10 .. LOC/5/28/2013
update c
set text4 = documentnumber
from dba.comrmks c, dba.invoicedetail id
where c.recordkey = id.recordkey  and c.seqnum = id.seqnum
and len(documentnumber) > 10 and id.iatanum = 'UBSCWT' and id.recordkey = c.recordkey

update id
set documentnumber = substring(documentnumber,6,10)
from dba.invoicedetail id, dba.ccticket cct
where len(documentnumber) > 10
and id.iatanum <> 'preubs' and id.invoicedate > '12-31-2011' and id.iatanum like 'ubscwt%'
and vendortype in ('bsp','nonbsp') and substring(documentnumber,6,10) = ticketnum 
and substring(passengername,1,5) = substring((lastname+'/'+firstname),1,5)
and matchedrecordkey is null


SET @TransStart = getdate()

-------- Update the min and nox segment mileage where it is negative when it should be positive.
-------- This is happening throught the .dll and is occuring with exchanges.  -- This is affecting
-------- the UBS Segment Mileage reports ----- LOC/9/27/2013
update t
set  noxsegmentmileage = noxsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and noxsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'
and i.iatanum = 'ubscwt'

update t
set  minsegmentmileage = minsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and minsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'
and i.iatanum = 'ubscwt'

update i
set  mileage = mileage*-1
from dba.invoicedetail i
where i.mileage <0 
and i.invoicedate > '1-1-2012' and i.exchangeind = 'y'
and i.iatanum = 'ubscwt'

-------- Update Refundable / Non refundable Indicator from the Pre Trip data as not received in the CWT feed..LOC/8/8/2014
update boc
set boc.text9 = ptc.text9--, count(*)
from dba.invoicedetail boi, dba.invoicedetail pti, dba.comrmks boc, dba.comrmks ptc
where boi.recordkey = boc.recordkey and boi.seqnum = boc.seqnum
and pti.recordkey = ptc.recordkey and pti.seqnum = ptc.seqnum
and boi.iatanum = 'ubscwt' and pti.iatanum = 'preubs'
and boi.voidind = 'n' and pti.voidind = 'n'
and boi.gdsrecordlocator = pti.gdsrecordlocator
and boi.documentnumber = pti.documentnumber
and boi.invoicedate >= '1-1-2012'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBSCWT mileage update-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Update data based on montly update file sent by Ryan for reasoncodes, GPN, Approvers etc
SET @TransStart = getdate()

--------- Reason code Updates ---------------------------
update i
set i.reasoncode1 = d.ReasonCode
from dba.invoicedetail i, dba.DataUpdates d
where product = 'Air' and i.recordkey = d.recordidentifier
and i.gdsrecordlocator = d.recordlocator 
and d.reasoncode is not NULL
--and d.reasoncode not in ( NULL ,'')
AND I.Seqnum=D.Sequence
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' 
and lookupname = 'rcda')
and i.reasoncode1 <> d.reasoncode
AND D.ImportDt>= '2014-01-01'
and I.iatanum = 'ubscwt'

update h
set h.htlreasoncode1 = d.ReasonCode
from dba.hotel h, dba.DataUpdates d
where product = 'Hotel' and h.recordkey = d.recordidentifier
and d.reasoncode is not NULL
--and d.reasoncode not in ( NULL ,'')
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcdh')
and h.htlreasoncode1 <> d.reasoncode
AND H.Seqnum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and H.iatanum = 'ubscwt'


update c
set c.carreasoncode1 = d.ReasonCode
from dba.car c, dba.DataUpdates d
where product = 'Car' and c.recordkey = d.recordidentifier
and d.reasoncode is not NULL
--and d.reasoncode not in ( NULL ,'')
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcdc')
and c.carreasoncode1 <> d.reasoncode
AND C.Seqnum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and C.iatanum = 'ubscwt'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ReasonCode Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

--------- Update Booker and Approver GPN's and Names ----------------------------------------------------
update c
set text14 = ApproverGPN
from dba.comrmks c, dba.dataupdates d
where c.recordkey = d.recordidentifier
and approvergpn is not null
--and approvergpn not in ( NULL ,'') 
and approvergpn <> text14
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and c.iatanum = 'ubscwt'
------ Once GPN is updated -- update name ---------
update c
set text2 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text2 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)
and c.iatanum = 'ubscwt'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UPDATE-approver GPNS AND NAME-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------- Update Booker GPN and Name ----------------------------------------------------
update c
set text8 = BookerGPN
from dba.comrmks c, dba.dataupdates d
where c.recordkey = d.recordidentifier
and BookerGPN is not null
--and bookergpn not in ( NULL ,'') 
and bookergpn <> text8
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and c.iatanum = 'ubscwt'

------ Once BookerGPN is updated -- update name ---------
update c
set text1 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text1 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)
and c.iatanum = 'ubscwt'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update Booker GPN and Name-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------- Update Traveler GPN AND NAME  ----------------------------------------------------
UPDATE id
SET id.remarks2 = d.TravelerGPN
FROM dba.InvoiceDetail id, dba.DataUpdates d
WHERE id.RecordKey=d.RecordIdentifier
--AND d.TravelerGPN not in ( NULL ,'')
AND d.TravelerGPN is not NULL 
AND d.TravelerGPN <> id.Remarks2 
AND ID.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

UPDATE htl
SET htl.remarks2 = d.TravelerGPN
FROM dba.DataUpdates d, dba.hotel htl
WHERE d.RecordIdentifier = htl.RecordKey
AND d.PRODUCT = 'hotel'
AND d.BookerGPN IS NOT NULL
--AND d.BookerGPN not in ( NULL ,'')
AND d.BookerGPN <> htl.Remarks2
AND HTL.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

UPDATE car
SET car.remarks2 = d.TravelerGPN
FROM dba.DataUpdates d, dba.car car
WHERE d.RecordIdentifier = car.RecordKey
AND d.PRODUCT = 'car'
AND d.TravelerGPN IS NOT NULL
--AND d.TravelerGPN not in ( NULL ,'')
AND d.TravelerGPN <> car.Remarks2
AND CAR.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'


------ Once Traveler GPN is updated -- update name ---------
update c
set text20 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text20 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdatesTemp)
and c.iatanum = 'ubscwt'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UPDATE-TRAVELER GPNS AND NAME-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

------ update TractID ---------
UPDATE c
SET c.text17 = d.tractid
FROM dba.ComRmks c, dba.DataUpdates d
WHERE d.RecordIdentifier = c.RecordKey
AND d.TractID IS NOT NULL
--AND d.TractID not in ( NULL ,'')
AND d.TractID <> c.Text17
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and c.iatanum = 'ubscwt'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update TractID-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


------ update Trip Purpose ---------
UPDATE id
SET id.remarks1 = d.TripPurpose
FROM dba.invoicedetail id, dba.DataUpdates d
WHERE d.RecordIdentifier = id.RecordKey
AND d.trippurpose IS NOT NULL
--AND d.trippurpose not in ( NULL ,'')
AND d.trippurpose <> id.remarks1
AND id.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and Id.iatanum = 'ubscwt'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update TripPurpose-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----********************************************************************************************
------------- These updates must remain in the SP so they are run prior to the Exchange Refund process
------------- These updates were approved by UBS on 3/0/2015 to clean up the ticket numbers where the TMC's are
------------- adding digits to the end/beginning of the numbers.  This is causing issues with matchback as the 
------------- Refund Exchange process.... LOC
-------------
------------- Updates for tickets that have 14 digets.  Updating to 10.  this is for the original document number
------------- removing the last 4 digits.  the -O in the Text12 field will denote that this is an original Ticket Number
update c
set text12 = io.documentnumber +' -O'
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '14' and len(ie.origexchtktnum) = '10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2013' and text12 is null
and io.iatanum <> 'preubs'

Update io
set io.documentnumber = substring (io.documentnumber,1,10)
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '14' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 = io.documentnumber+' -O'
and io.iatanum <> 'preubs'

------------- Updates for tickets that have 13 digets.  Updating to 10.  this is for the original document number
------------- removing the last 4 digits.  the -O in the Text12 field will denote that this is an original Ticket Number
update c
set text12 = io.documentnumber +' -O'
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '13' and len(ie.origexchtktnum) = '10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2013' and text12 is null
and io.iatanum <> 'preubs'

Update io
set io.documentnumber = substring (io.documentnumber,1,10)
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '13' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 = io.documentnumber+' -O'
and io.iatanum <> 'preubs'

------------- Updates for tickets that have 15 digets.  Updating to 10.  this is for the original document number
------------- removing the first 5 digets.  the -O in the Text12 field will denote that this is an original Ticket Number
------------- Adding this to CWT procedure on production -- these are APAC transactions for the most part.
update c
set text12 = io.documentnumber +' -O'
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '15' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,6,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 is null
and io.iatanum <> 'preubs'

Update io
set io.documentnumber = substring (io.documentnumber,1,10)
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '15' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,6,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 = io.documentnumber+' -O'
and io.iatanum <> 'preubs'
----********************************************************************************************


EXEC TTXPASQL01.tman_ubs.dbo.sp_RefundExchange
@BEGINISSUEDATE=@BEGINISSUEDATE,
@ENDISSUEDATE=@ENDISSUEDATE 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Updates complete -- Refund Exchange Excecuted',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
------ update lowAirFare and Full Air Fare ---------
--UPDATE id
--SET id.farecompare2 = ISNULL(D.lowfare,0)*CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase
--FROM dba.invoicedetail id, 
--dba.DataUpdates d
--INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate AND CURRBASE.BaseCurrCode = d.currcode 
--INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
--WHERE d.RecordIdentifier = id.RecordKey
--and product = 'Air'
--and CURRTO.CurrCode ='USD'
--AND d.lowairfare not in ( NULL ,'')
--AND d.lowairfare <> id.farecompare2
--AND id.SeqNum=D.Sequence
--and d.importdt>='2014-01-01
--and Id.iatanum = 'ubscwt'



--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='Update LowFare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--UPDATE id
--SET id.farecompare1 = d.fullairfare *(need currency conversion)
--FROM dba.invoicedetail id, dba.DataUpdates d
--INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate AND CURRBASE.BaseCurrCode = d.currcode 
--INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
--WHERE d.RecordIdentifier = id.RecordKey
--and product = 'Air'
--and CURRTO.CurrCode ='USD'
--AND d.fullairfare not in ( NULL ,'')
--AND d.fullairfare <> id.farecompare1
--AND id.SeqNum=D.Sequence
--AND D.ImportDt>= '2014-01-01'
--and Id.iatanum = 'ubscwt'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='Update FullFare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBSCWT DataUpdates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


--------******** Update Staging with CWT data for ACM Procdessing ********************--------
insert into TTXSASQL01.Tman_UBS.dba.Client
select * 
from dba.client where clientcode not in (select clientcode 
from TTXSASQL01.Tman_UBS.dba.Client where iatanum ='UBSCWT')
and iatanum = 'UBSCWT'

insert into TTXSASQL01.Tman_UBS.dba.Invoiceheader
select * 
from dba.Invoiceheader where recordkey not in (select recordkey 
from TTXSASQL01.Tman_UBS.dba.Invoiceheader where iatanum ='UBSCWT' and invoicedate > '12-31-2013')
and iatanum = 'UBSCWT' and invoicedate > '12-31-2013'

insert into TTXSASQL01.Tman_UBS.dba.Invoicedetail
select * 
from dba.Invoicedetail where recordkey+convert(varchar,seqnum) not in (select recordkey +convert(varchar,seqnum)
from TTXSASQL01.Tman_UBS.dba.Invoicedetail where iatanum ='UBSCWT' and invoicedate > '12-31-2013')
and iatanum = 'UBSCWT' and invoicedate > '12-31-2013'

insert into TTXSASQL01.Tman_UBS.dba.Transeg
select * 
from dba.Transeg where recordkey+convert(varchar,seqnum) not in (select recordkey +convert(varchar,seqnum)
from TTXSASQL01.Tman_UBS.dba.Transeg where iatanum ='UBSCWT' and invoicedate > '12-31-2013')
and iatanum = 'UBSCWT' and invoicedate > '12-31-2013'
--****************************************************************
EXEC dbo.sp_ACM_AutoProcess_UBS
--****************************************************************
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ACM process SP Kicked Off',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------------------------------------------------
---HNN Cleanup for DEA
--Make sure to update the Iatanums for all agency data and update the production server
--ADDED per Case #19267.... TBo 07.30.2013

--Clean up hotel spaces
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Clean up unwanted characters in htlpropertyname and htladdr1
--Added on 4/18/13 by Nina per case 00011353
SET @TransStart = getdate()
UPDATE TTXPASQL01.TMAN_UBS.DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',','')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update TTXPASQL01.TMAN_UBS.dba.hotel
set masterid = -1
where masterid is null
and htlpropertyname like 'OTHER%HOTELS%'
or htlpropertyname like '%NONAME%'
and invoicedate > '2011-12-31'

-------------------------------------------------------------------------------------
 ---Pam S added:
SET @TransStart = getdate()
update TTXPASQL01.TMAN_UBS.dba.hotel
set htladdr1 = htladdr2
,htladdr2 = null
where masterid is null
and htladdr1 is null
and htladdr2 is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Move htladdr2 to 1 when null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update TTXPASQL01.TMAN_UBS.dba.hotel
set htladdr2 = null
where htladdr2 = htladdr1

------------------------------------------------------------------------

update TTXPASQL01.TMAN_UBS.dba.hotel
set masterid = -1
where masterid is null
and htlpropertyname is null
and htladdr1 is null
and invoicedate > '2011-12-31'

 update TTXPASQL01.TMAN_UBS.dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = ''
or HtlAddr1 is null or HtlAddr1 = '' )
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Parent id -1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update htl
set htl.htlcountrycode = ct.countrycode
,htl.htlstate = ct.stateprovincecode
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXPASQL01.TMAN_UBS.dba.city ct
where htl.htlcitycode = ct.citycode
and  htl.masterid is null
and htl.htlcountrycode is null
and ct.countrycode <> 'ZZ'
and ct.typecode ='a'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Country',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update htl
set htl.htlstate = t2.stateprovincecode
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXPASQL01.TMAN_UBS.dba.city t2
where t2.typecode = 'A'
and htl.htlcitycode = t2.citycode
and htl.htlcountrycode = t2.countrycode
and htl.htlstate is null
and htl.htlcountrycode = 'US'
and t2.countrycode = 'US'
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='State when Country = US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update htl
set htl.htlcountrycode = ct.countrycode
,htl.htlstate = ct.stateprovincecode
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXPASQL01.TMAN_UBS.dba.city ct
where htl.htlcitycode = ct.citycode
and  htl.masterid is null
and htl.htlcountrycode <> ct.countrycode
and ct.typecode ='a'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='State',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update htl
set htl.htlstate = zp.state
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
where substring(htl.htlpostalcode,1,5) = zp.zipcode
and substring(htl.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P'
and htl.masterid is null
and htl.htlstate is null
and htl.htlcountrycode = 'US'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update TTXPASQL01.TMAN_UBS.dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null
and invoicedate > '2011-12-31'

UPDATE TTXPASQL01.TMAN_UBS.dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null
and invoicedate > '2011-12-31'

	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'HERTOGENBOSCH'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%MOEVENPICK HOTEL%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%OAKWOOD CHELSEA%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%LONGACRE HOUSE%'
	and invoicedate > '2011-12-31'


	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'BARCELONA'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%HOTLE PUNTA PALMA%'
	and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End htl edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBSCWT Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

	
--add to the end after HNN cleanup sql's run
--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from  TTXPASQL01.TMAN_UBS.dba.Hotel
Where MasterId is NULL
and invoicedate > '2011-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'UBSCWT',
@Enhancement = 'HNN',
@Client = 'UBS',
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
@TextParam3 = 'TMAN_UBS',
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

 
/************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  








































GO
