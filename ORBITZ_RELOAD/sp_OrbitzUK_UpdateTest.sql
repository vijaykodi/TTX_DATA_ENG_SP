/****** Object:  StoredProcedure [dbo].[sp_OrbitzUK_UpdateTest]    Script Date: 7/7/2015 11:19:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_OrbitzUK_UpdateTest]
@BeginIssueDate datetime,
@EndIssueDate datetime

 AS

update dba.transeg
set typecode ='A'
where typecode is null
and (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
and iatanum = 'OFBUK'

update dba.invoicedetail
set farecompare4 = farecompare1
where (farecompare2 is null
or farecompare2 = 0)
and farecompare1 is not null
and (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
and iatanum = 'OFBUK'


update dba.invoicedetail
set farecompare1 = null
where (farecompare2 is null
or farecompare2 = 0)
and farecompare1 is not null
and (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
and iatanum = 'OFBUK'


update dba.invoicedetail
set farecompare2 = farecompare4
where (farecompare2 is null
or farecompare2 = 0)
and (farecompare4 is not null
or farecompare4 = 0)
and (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
and iatanum = 'OFBUK'


update dba.invoicedetail
set farecompare4 = 0
where (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
and iatanum = 'OFBUK'

update id
set id.farecompare1 = substring(ud50.udefdata,1,150)
from dba.invoicedetail id, dba.udef ud50
where id.iatanum = ud50.iatanum
and id.iatanum ='OFBUK'
and id.recordkey = ud50.recordkey
and ud50.udefnum =50
and (id.farecompare1  is null
or id.farecompare1 = 0)
and ud50.udefdata is not null
and id.issuedate = ud50.issuedate
and (id.issuedate between @BeginIssueDate and @EndIssueDate or id.invoicedate between @BeginIssueDate and @EndIssueDate) 

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
--and ih.importdt > (select dateadd(d,-7,max(importdt)) from dba.invoiceheader)
and ih.iatanum = 'OFBUK'
and id.iatanum = 'OFBUK'
and ts.iatanum = 'OFBUK'
and (id.origincode <> ts.origincitycode
or id.destinationcode <> ts.mindestcitycode)
and (id.issuedate between @BeginIssueDate and @EndIssueDate or id.invoicedate between @BeginIssueDate and @EndIssueDate) 


--Populate Common Remarks for 25 trip reference fields--added 2/12/2009
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
WHERE iatanum in ('OFBUK')
--and (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('OFBUK'))



update cr
set cr.text1 = substring(ud71.udefdata,1,150)
from dba.comrmks cr, dba.udef ud71
where cr.iatanum = ud71.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud71.recordkey
---and cr.seqnum = ud100.seqnum
and ud71.udefnum = 71
and cr.text1 is null
and ud71.udefdata is not null
and cr.issuedate = ud71.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 


update cr
set cr.text2 = substring(ud72.udefdata,1,150)
from dba.comrmks cr, dba.udef ud72
where cr.iatanum = ud72.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud72.recordkey
---and cr.seqnum = ud72.seqnum
and ud72.udefnum = 72
and cr.text2 is null
and ud72.udefdata is not null
and cr.issuedate = ud72.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text3 = substring(ud73.udefdata,1,150)
from dba.comrmks cr, dba.udef ud73
where cr.iatanum = ud73.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud73.recordkey
---and cr.seqnum = ud73.seqnum
and ud73.udefnum = 73
and cr.text3 is null
and ud73.udefdata is not null
and cr.issuedate = ud73.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text4 = substring(ud74.udefdata,1,150)
from dba.comrmks cr, dba.udef ud74
where cr.iatanum = ud74.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud74.recordkey
---and cr.seqnum = ud74.seqnum
and ud74.udefnum = 74
and cr.text4 is null
and ud74.udefdata is not null
and cr.issuedate = ud74.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text5 = substring(ud75.udefdata,1,150)
from dba.comrmks cr, dba.udef ud75
where cr.iatanum = ud75.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud75.recordkey
---and cr.seqnum = ud75.seqnum
and ud75.udefnum = 75
and cr.text5 is null
and ud75.udefdata is not null
and cr.issuedate = ud75.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text6 = substring(ud76.udefdata,1,150)
from dba.comrmks cr, dba.udef ud76
where cr.iatanum = ud76.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud76.recordkey
---and cr.seqnum = ud76.seqnum
and ud76.udefnum = 76
and cr.text6 is null
and ud76.udefdata is not null
and cr.issuedate = ud76.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text7 = substring(ud77.udefdata,1,150)
from dba.comrmks cr, dba.udef ud77
where cr.iatanum = ud77.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud77.recordkey
---and cr.seqnum = ud77.seqnum
and ud77.udefnum = 77
and cr.text7 is null
and ud77.udefdata is not null
and cr.issuedate = ud77.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text8 = substring(ud78.udefdata,1,150)
from dba.comrmks cr, dba.udef ud78
where cr.iatanum = ud78.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud78.recordkey
---and cr.seqnum = ud78.seqnum
and ud78.udefnum = 78
and cr.text8 is null
and ud78.udefdata is not null
and cr.issuedate = ud78.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text9 = substring(ud79.udefdata,1,150)
from dba.comrmks cr, dba.udef ud79
where cr.iatanum = ud79.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud79.recordkey
---and cr.seqnum = ud79.seqnum
and ud79.udefnum = 79
and cr.text9 is null
and ud79.udefdata is not null
and cr.issuedate = ud79.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 


update cr
set cr.text10 = substring(ud80.udefdata,1,150)
from dba.comrmks cr, dba.udef ud80
where cr.iatanum = ud80.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud80.recordkey
---and cr.seqnum = ud80.seqnum
and ud80.udefnum = 80
and cr.text10 is null
and ud80.udefdata is not null
and cr.issuedate = ud80.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text11 = substring(ud81.udefdata,1,150)
from dba.comrmks cr, dba.udef ud81
where cr.iatanum = ud81.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud81.recordkey
---and cr.seqnum = ud81.seqnum
and ud81.udefnum = 81
and cr.text11 is null
and ud81.udefdata is not null
and cr.issuedate = ud81.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text12 = substring(ud82.udefdata,1,150)
from dba.comrmks cr, dba.udef ud82
where cr.iatanum = ud82.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud82.recordkey
---and cr.seqnum = ud82.seqnum
and ud82.udefnum = 82
and cr.text12 is null
and ud82.udefdata is not null
and cr.issuedate = ud82.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text13 = substring(ud83.udefdata,1,150)
from dba.comrmks cr, dba.udef ud83
where cr.iatanum = ud83.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud83.recordkey
---and cr.seqnum = ud83.seqnum
and ud83.udefnum = 83
and cr.text13 is null
and ud83.udefdata is not null
and cr.issuedate = ud83.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text14 = substring(ud84.udefdata,1,150)
from dba.comrmks cr, dba.udef ud84
where cr.iatanum = ud84.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud84.recordkey
---and cr.seqnum = ud84.seqnum
and ud84.udefnum = 84
and cr.text14 is null
and ud84.udefdata is not null
and cr.issuedate = ud84.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text15 = substring(ud85.udefdata,1,150)
from dba.comrmks cr, dba.udef ud85
where cr.iatanum = ud85.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud85.recordkey
---and cr.seqnum = ud85.seqnum
and ud85.udefnum = 85
and cr.text15 is null
and ud85.udefdata is not null
and cr.issuedate = ud85.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text16 = substring(ud86.udefdata,1,150)
from dba.comrmks cr, dba.udef ud86
where cr.iatanum = ud86.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud86.recordkey
---and cr.seqnum = ud86.seqnum
and ud86.udefnum = 86
and cr.text16 is null
and ud86.udefdata is not null
and cr.issuedate = ud86.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text17 = substring(ud87.udefdata,1,150)
from dba.comrmks cr, dba.udef ud87
where cr.iatanum = ud87.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud87.recordkey
---and cr.seqnum = ud87.seqnum
and ud87.udefnum = 87
and cr.text17 is null
and ud87.udefdata is not null
and cr.issuedate = ud87.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 


update cr
set cr.text18 = substring(ud88.udefdata,1,150)
from dba.comrmks cr, dba.udef ud88
where cr.iatanum = ud88.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud88.recordkey
---and cr.seqnum = ud88.seqnum
and ud88.udefnum = 88
and cr.text18 is null
and ud88.udefdata is not null
and cr.issuedate = ud88.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text19 = substring(ud89.udefdata,1,150)
from dba.comrmks cr, dba.udef ud89
where cr.iatanum = ud89.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud89.recordkey
---and cr.seqnum = ud89.seqnum
and ud89.udefnum = 89
and cr.text19 is null
and ud89.udefdata is not null
and cr.issuedate = ud89.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text20 = substring(ud90.udefdata,1,150)
from dba.comrmks cr, dba.udef ud90
where cr.iatanum = ud90.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud90.recordkey
---and cr.seqnum = ud90.seqnum
and ud90.udefnum = 90
and cr.text20 is null
and ud90.udefdata is not null
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 
and cr.issuedate = ud90.issuedate


update cr
set cr.text21 = substring(ud91.udefdata,1,150)
from dba.comrmks cr, dba.udef ud91
where cr.iatanum = ud91.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud91.recordkey
---and cr.seqnum = ud91.seqnum
and ud91.udefnum = 91
and cr.text21 is null
and ud91.udefdata is not null
and cr.issuedate = ud91.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text22 = substring(ud92.udefdata,1,150)
from dba.comrmks cr, dba.udef ud92
where cr.iatanum = ud92.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud92.recordkey
---and cr.seqnum = ud92.seqnum
and ud92.udefnum = 92
and cr.text22 is null
and ud92.udefdata is not null
and cr.issuedate = ud92.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text23 = substring(ud93.udefdata,1,150)
from dba.comrmks cr, dba.udef ud93
where cr.iatanum = ud93.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud93.recordkey
---and cr.seqnum = ud93.seqnum
and ud93.udefnum = 93
and cr.text23 is null
and ud93.udefdata is not null
and cr.issuedate = ud93.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text24 = substring(ud94.udefdata,1,150)
from dba.comrmks cr, dba.udef ud94
where cr.iatanum = ud94.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud94.recordkey
---and cr.seqnum = ud94.seqnum
and ud94.udefnum = 94
and cr.text24 is null
and ud94.udefdata is not null
and cr.issuedate = ud94.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update cr
set cr.text25 = substring(ud95.udefdata,1,150)
from dba.comrmks cr, dba.udef ud95
where cr.iatanum = ud95.iatanum
and cr.iatanum ='OFBUK'
and cr.recordkey = ud95.recordkey
---and cr.seqnum = ud95.seqnum
and ud95.udefnum = 95
and cr.text25 is null
and ud95.udefdata is not null
and cr.issuedate = ud95.issuedate
and (cr.issuedate between @BeginIssueDate and @EndIssueDate or cr.invoicedate between @BeginIssueDate and @EndIssueDate) 

update car
set carreasoncode1 = ud.udefdata
from dba.car car, dba.udef ud
where car.recordkey = ud.recordkey
and car.iatanum = ud.iatanum
and car.seqnum = ud.seqnum
and car.issuedate = ud.issuedate
and car.clientcode = ud.clientcode
and ud.udefnum = 37
and car.iatanum = 'OFBUK'
and (car.issuedate between @BeginIssueDate and @EndIssueDate or car.invoicedate between @BeginIssueDate and @EndIssueDate) 
and ud.iatanum = 'OFBUK'
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 


update htl
set htlreasoncode1 = ud.udefdata
from dba.hotel htl, dba.udef ud
where htl.recordkey = ud.recordkey
and htl.iatanum = ud.iatanum
and htl.seqnum = ud.seqnum
and htl.issuedate = ud.issuedate
and htl.clientcode = ud.clientcode
and ud.udefnum = 34
and htl.iatanum = 'OFBUK'
and (htl.issuedate between @BeginIssueDate and @EndIssueDate or htl.invoicedate between @BeginIssueDate and @EndIssueDate) 
and ud.iatanum = 'OFBUK'
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 

--Update online booking system per incident #1066175...added by Nina on 3/10/11
update dba.invoicedetail
set onlinebookingsystem = CASE when bookingagentid  = 'HW' then 'ONLN'
			  ELSE 'OFFLN'
			  END
where iatanum = 'OFBUK'
and (IssueDate BETWEEN @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 


--Kara Pauga 5/6/11
--Incident 1067384
update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBUK'
and id.clientcode  in ('1000010','3000009','3000010')
and id.recordkey = ud.recordkey
and ud.udefnum = 72
and ud.iatanum ='OFBUK'
and ud.clientcode  in ('1000010','3000009','3000010')
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 

--Kara Pauga 10/26/11
--Incident 1071141
update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBUK'
and id.clientcode  in ('1000012')
and id.recordkey = ud.recordkey
and ud.udefnum = 71
and ud.iatanum ='OFBUK'
and ud.clientcode  in ('1000012')
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 

---DETERMINE DOMESTIC SEGMENT---
update TS
set TS.SEGINTERNATIONALIND = 'D'
FROM dba.City ORIG,dba.transeg TS,dba.City XMDEST
 WHERE (( Ts.IataNum = 'OFBUK'))
   AND ((ORIG.CityCode = TS.OriginCityCode
   AND ORIG.TypeCode = TS.TypeCode
   AND XMDEST.CityCode = TS.SEGDestCityCode
   AND XMDEST.TypeCode = TS.TypeCode 
   and (ts.issuedate between @BeginIssueDate and @EndIssueDate or ts.invoicedate between @BeginIssueDate and @EndIssueDate) 
   and orig.countrycode = 'GB'
   and xmdest.countrycode = 'GB'
   ))


---DETERMINE NOXMARKET DOMESTIC---
UPDATE TS
set TS.NOXINTERNATIONALIND ='D'
FROM dba.City ORIG,dba.transeg TS,dba.City XMDEST
 WHERE (( Ts.IataNum = 'OFBUK'))
   AND ((ORIG.CityCode = TS.NOXMKTOrigCityCode
   AND ORIG.TypeCode = TS.TypeCode
   AND XMDEST.CityCode = TS.NOXMKTDestCityCode
   AND XMDEST.TypeCode = TS.TypeCode 
   and (ts.issuedate between @BeginIssueDate and @EndIssueDate or ts.invoicedate between @BeginIssueDate and @EndIssueDate) 
    and orig.countrycode = 'GB'
   and xmdest.countrycode = 'GB'
   ))


---DETERMINE MINMARKET DOMESTIC---
UPDATE TS
set TS.MININTERNATIONALIND ='D'
FROM dba.City ORIG,dba.transeg TS,dba.City XMDEST
 WHERE (( Ts.IataNum = 'OFBUK'))
   AND ((ORIG.CityCode = TS.MINMKTOrigCityCode
   AND ORIG.TypeCode = TS.TypeCode
   AND XMDEST.CityCode = TS.MINMKTDestCityCode
   AND XMDEST.TypeCode = TS.TypeCode 
   and (ts.issuedate between @BeginIssueDate and @EndIssueDate or ts.invoicedate between @BeginIssueDate and @EndIssueDate) 
    and orig.countrycode = 'GB'
   and xmdest.countrycode = 'GB'
   ))


---UPDATE TICKET INTERNATIONAL IND FROM SEGMENT---
UPDATE dba.invoicedetail
SET INTERNATIONALIND ='D'
WHERE IATANUM ='OFBUK'
AND (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
AND VENDORTYPE IN ('BSP','NONBSP')

UPDATE dba.invoicedetail
SET INTERNATIONALIND = 'I'
WHERE IATANUM ='OFBUK'
AND (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
AND VENDORTYPE IN ('BSP','NONBSP')
AND recordkey+iatanum+convert(varchar,seqnum) IN (SELECT recordkey+iatanum+convert(varchar,seqnum)
FROM dba.transeg
WHERE IATANUM ='OFBUK'
AND (issuedate between @BeginIssueDate and @EndIssueDate or invoicedate between @BeginIssueDate and @EndIssueDate) 
AND SEGINTERNATIONALIND ='I')

--Kara Pauga 12/28/11
--Incident 1072360
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBUK'
and id.clientcode  in ('1000014')
and id.recordkey = ud.recordkey
and ud.udefnum = 71
and ud.iatanum ='OFBUK'
and ud.clientcode  in ('1000014')
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 

--Kara Pauga 1/6/12
--Incident 1072515
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBUK'
and id.clientcode  in ('1000016')
and id.recordkey = ud.recordkey
and ud.udefnum = 72
and ud.iatanum ='OFBUK'
and ud.clientcode  in ('1000016')
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 

--Kara Pauga 4/5/12
--Incident 1075444
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBUK'
and id.clientcode  in ('1000015')
and id.recordkey = ud.recordkey
and ud.udefnum = 71
and ud.iatanum ='OFBUK'
and ud.clientcode  in ('1000015')
and (ud.issuedate between @BeginIssueDate and @EndIssueDate or ud.invoicedate between @BeginIssueDate and @EndIssueDate) 

GO

ALTER AUTHORIZATION ON [dbo].[sp_OrbitzUK_UpdateTest] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 11:19:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNum] [varchar](15) NULL,
	[TicketingBranch] [varchar](10) NULL,
	[BookingBranch] [varchar](10) NULL,
	[TtlInvoiceAmt] [float] NULL,
	[TtlTaxAmt] [float] NULL,
	[TtlCommissionAmt] [float] NULL,
	[CurrCode] [varchar](30) NULL,
	[OrigCountry] [varchar](5) NULL,
	[SalesAgentID] [varchar](10) NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[GDSCode] [varchar](10) NULL,
	[BackOfficeID] [varchar](20) NULL,
	[IMPORTDT] [datetime] NULL,
	[TtlCO2Emissions] [float] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 11:19:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[InvoiceType] [varchar](10) NULL,
	[InvoiceTypeDescription] [varchar](255) NULL,
	[DocumentNumber] [varchar](15) NULL,
	[EndDocNumber] [varchar](3) NULL,
	[VendorNumber] [varchar](15) NULL,
	[VendorType] [varchar](10) NULL,
	[ValCarrierNum] [int] NULL,
	[ValCarrierCode] [varchar](6) NULL,
	[VendorName] [varchar](40) NULL,
	[BookingDate] [datetime] NULL,
	[ServiceDate] [datetime] NULL,
	[ServiceCategory] [varchar](8) NULL,
	[InternationalInd] [varchar](1) NULL,
	[ServiceFee] [float] NULL,
	[InvoiceAmt] [float] NULL,
	[TaxAmt] [float] NULL,
	[TotalAmt] [float] NULL,
	[CommissionAmt] [float] NULL,
	[CancelPenaltyAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[FareCompare1] [float] NULL,
	[ReasonCode1] [varchar](6) NULL,
	[FareCompare2] [float] NULL,
	[ReasonCode2] [varchar](6) NULL,
	[FareCompare3] [float] NULL,
	[ReasonCode3] [varchar](6) NULL,
	[FareCompare4] [float] NULL,
	[ReasonCode4] [varchar](6) NULL,
	[Mileage] [float] NULL,
	[Routing] [varchar](120) NULL,
	[DaysAdvPurch] [int] NULL,
	[AdvPurchGroup] [varchar](10) NULL,
	[TrueTktCount] [int] NULL,
	[TripLength] [float] NULL,
	[ExchangeInd] [varchar](1) NULL,
	[OrigExchTktNum] [varchar](15) NULL,
	[Department] [varchar](40) NULL,
	[ETktInd] [varchar](1) NULL,
	[ProductType] [varchar](20) NULL,
	[TourCode] [varchar](15) NULL,
	[EndorsementRemarks] [varchar](60) NULL,
	[FareCalcLine] [varchar](255) NULL,
	[GroupMult] [int] NULL,
	[OneWayInd] [varchar](1) NULL,
	[PrefTktInd] [varchar](1) NULL,
	[HotelNights] [float] NULL,
	[CarDays] [float] NULL,
	[OnlineBookingSystem] [varchar](20) NULL,
	[AccommodationType] [varchar](10) NULL,
	[AccommodationDescription] [varchar](255) NULL,
	[ServiceType] [varchar](10) NULL,
	[ServiceDescription] [varchar](255) NULL,
	[ShipHotelName] [varchar](255) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[IntlSalesInd] [varchar](4) NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[RefundInd] [varchar](1) NULL,
	[OriginalInvoiceNum] [varchar](15) NULL,
	[BranchIataNum] [varchar](8) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[TicketingAgentID] [varchar](10) NULL,
	[OriginCode] [varchar](10) NULL,
	[DestinationCode] [varchar](10) NULL,
	[TktCO2Emissions] [float] NULL,
	[CCMatchedRecordKey] [varchar](100) NULL,
	[CCMatchedIataNum] [varchar](8) NULL,
	[ACQMatchedInd] [varchar](1) NULL,
	[ACQMatchedRecordKey] [varchar](100) NULL,
	[ACQMatchedIataNum] [varchar](8) NULL,
	[CarrierString] [varchar](50) NULL,
	[ClassString] [varchar](50) NULL,
	[CRMatchedInd] [varchar](1) NULL,
	[CRMatchedRecordKey] [varchar](100) NULL,
	[CRMatchedIataNum] [varchar](8) NULL,
	[LastImportDt] [datetime] NULL,
	[GolUpdateDt] [datetime] NULL,
	[OrigTktAmt] [float] NULL,
	[TktWasExchangedInd] [varchar](1) NULL,
	[TicketGroupId] [varchar](50) NULL
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Hotel]    Script Date: 7/7/2015 11:19:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Hotel](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[HtlSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[HtlChainCode] [varchar](6) NULL,
	[HtlChainName] [varchar](40) NULL,
	[GDSPropertyNum] [varchar](15) NULL,
	[HtlPropertyName] [varchar](40) NULL,
	[HtlAddr1] [varchar](40) NULL,
	[HtlAddr2] [varchar](40) NULL,
	[HtlAddr3] [varchar](40) NULL,
	[HtlCityCode] [varchar](10) NULL,
	[HtlCityName] [varchar](25) NULL,
	[HtlState] [varchar](20) NULL,
	[HtlPostalCode] [varchar](15) NULL,
	[HtlCountryCode] [varchar](5) NULL,
	[HtlPhone] [varchar](20) NULL,
	[InternationalInd] [varchar](1) NULL,
	[CheckinDate] [datetime] NULL,
	[CheckoutDate] [datetime] NULL,
	[NumNights] [smallint] NULL,
	[NumRooms] [smallint] NULL,
	[HtlQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[HtlDailyRate] [float] NULL,
	[TtlHtlCost] [float] NULL,
	[RoomType] [varchar](6) NULL,
	[HtlRateCat] [varchar](10) NULL,
	[HtlCompareRate1] [float] NULL,
	[HtlReasonCode1] [varchar](6) NULL,
	[HtlCompareRate2] [float] NULL,
	[HtlReasonCode2] [varchar](6) NULL,
	[HtlCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefHtlInd] [varchar](1) NULL,
	[HtlConfNum] [varchar](30) NULL,
	[FreqGuestProgram] [varchar](13) NULL,
	[HtlStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[HtlCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[MasterId] [int] NULL,
	[CO2Emissions] [float] NULL,
	[MilesFromAirport] [float] NULL,
	[GroundTransCO2] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Hotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/7/2015 11:20:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ComRmks](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[Text1] [varchar](150) NULL,
	[Text2] [varchar](150) NULL,
	[Text3] [varchar](150) NULL,
	[Text4] [varchar](150) NULL,
	[Text5] [varchar](150) NULL,
	[Text6] [varchar](150) NULL,
	[Text7] [varchar](150) NULL,
	[Text8] [varchar](150) NULL,
	[Text9] [varchar](150) NULL,
	[Text10] [varchar](150) NULL,
	[Text11] [varchar](150) NULL,
	[Text12] [varchar](150) NULL,
	[Text13] [varchar](150) NULL,
	[Text14] [varchar](150) NULL,
	[Text15] [varchar](150) NULL,
	[Text16] [varchar](150) NULL,
	[Text17] [varchar](150) NULL,
	[Text18] [varchar](150) NULL,
	[Text19] [varchar](150) NULL,
	[Text20] [varchar](150) NULL,
	[Text21] [varchar](150) NULL,
	[Text22] [varchar](150) NULL,
	[Text23] [varchar](150) NULL,
	[Text24] [varchar](150) NULL,
	[Text25] [varchar](150) NULL,
	[Text26] [varchar](150) NULL,
	[Text27] [varchar](150) NULL,
	[Text28] [varchar](150) NULL,
	[Text29] [varchar](150) NULL,
	[Text30] [varchar](150) NULL,
	[Text31] [varchar](150) NULL,
	[Text32] [varchar](150) NULL,
	[Text33] [varchar](150) NULL,
	[Text34] [varchar](150) NULL,
	[Text35] [varchar](150) NULL,
	[Text36] [varchar](150) NULL,
	[Text37] [varchar](150) NULL,
	[Text38] [varchar](150) NULL,
	[Text39] [varchar](150) NULL,
	[Text40] [varchar](150) NULL,
	[Text41] [varchar](150) NULL,
	[Text42] [varchar](150) NULL,
	[Text43] [varchar](150) NULL,
	[Text44] [varchar](150) NULL,
	[Text45] [varchar](150) NULL,
	[Text46] [varchar](150) NULL,
	[Text47] [varchar](150) NULL,
	[Text48] [varchar](150) NULL,
	[Text49] [varchar](150) NULL,
	[Text50] [varchar](150) NULL,
	[Num1] [float] NULL,
	[Num2] [float] NULL,
	[Num3] [float] NULL,
	[Num4] [float] NULL,
	[Num5] [float] NULL,
	[Num6] [float] NULL,
	[Num7] [float] NULL,
	[Num8] [float] NULL,
	[Num9] [float] NULL,
	[Num10] [float] NULL,
	[Num11] [float] NULL,
	[Num12] [float] NULL,
	[Num13] [float] NULL,
	[Num14] [float] NULL,
	[Num15] [float] NULL,
	[Num16] [float] NULL,
	[Num17] [float] NULL,
	[Num18] [float] NULL,
	[Num19] [float] NULL,
	[Num20] [float] NULL,
	[Num21] [float] NULL,
	[Num22] [float] NULL,
	[Num23] [float] NULL,
	[Num24] [float] NULL,
	[Num25] [float] NULL,
	[Num26] [float] NULL,
	[Num27] [float] NULL,
	[Num28] [float] NULL,
	[Num29] [float] NULL,
	[Num30] [float] NULL,
	[Int1] [int] NULL,
	[Int2] [int] NULL,
	[Int3] [int] NULL,
	[Int4] [int] NULL,
	[Int5] [int] NULL,
	[Int6] [int] NULL,
	[Int7] [int] NULL,
	[Int8] [int] NULL,
	[Int9] [int] NULL,
	[Int10] [int] NULL,
	[Int11] [int] NULL,
	[Int12] [int] NULL,
	[Int13] [int] NULL,
	[Int14] [int] NULL,
	[Int15] [int] NULL,
	[Int16] [int] NULL,
	[Int17] [int] NULL,
	[Int18] [int] NULL,
	[Int19] [int] NULL,
	[Int20] [int] NULL,
 CONSTRAINT [PK_ComRmks] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[City]    Script Date: 7/7/2015 11:20:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[City](
	[CityCode] [varchar](10) NOT NULL,
	[TypeCode] [varchar](1) NOT NULL,
	[CityName] [varchar](30) NULL,
	[AirportName] [varchar](30) NULL,
	[RegionCode] [varchar](10) NULL,
	[RegionName] [varchar](30) NULL,
	[StateProvinceCode] [varchar](5) NULL,
	[CountryCode] [varchar](5) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[TimeZoneDiff] [float] NULL,
	[TSLATEST] [datetime] NULL,
 CONSTRAINT [PK_City_1] PRIMARY KEY NONCLUSTERED 
(
	[CityCode] ASC,
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[City] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Car]    Script Date: 7/7/2015 11:20:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Car](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[CarSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[CarType] [varchar](6) NULL,
	[CarChainCode] [varchar](6) NULL,
	[CarChainName] [varchar](20) NULL,
	[CarCityCode] [varchar](10) NULL,
	[CarCityName] [varchar](25) NULL,
	[InternationalInd] [varchar](1) NULL,
	[PickupDate] [datetime] NULL,
	[DropoffDate] [datetime] NULL,
	[CarDropoffCityCode] [varchar](10) NULL,
	[NumDays] [smallint] NULL,
	[NumCars] [smallint] NULL,
	[CarQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[CarDailyRate] [float] NULL,
	[TtlCarCost] [float] NULL,
	[CarRateCat] [varchar](10) NULL,
	[CarCompareRate1] [float] NULL,
	[CarReasonCode1] [varchar](6) NULL,
	[CarCompareRate2] [float] NULL,
	[CarReasonCode2] [varchar](6) NULL,
	[CarCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefCarInd] [varchar](1) NULL,
	[CarConfNum] [varchar](30) NULL,
	[FreqRenterProgram] [varchar](13) NULL,
	[CarStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[CarCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[CarDropOffCityName] [varchar](50) NULL,
	[CO2Emissions] [float] NULL,
 CONSTRAINT [PK_Car] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Car] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Udef]    Script Date: 7/7/2015 11:20:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Udef](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[UdefNum] [smallint] NOT NULL,
	[UdefType] [varchar](20) NULL,
	[UdefData] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Udef] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 11:20:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[OriginCityCode] [varchar](10) NULL,
	[SegmentCarrierCode] [varchar](3) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[CodeShareCarrierCode] [varchar](3) NULL,
	[EquipmentCode] [varchar](10) NULL,
	[PrefAirInd] [varchar](1) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[FlightNum] [varchar](15) NULL,
	[ClassOfService] [varchar](8) NULL,
	[FareBasis] [varchar](30) NULL,
	[TktDesignator] [varchar](15) NULL,
	[ConnectionInd] [varchar](1) NULL,
	[StopOverTime] [int] NULL,
	[FrequentFlyerNum] [varchar](15) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SEGDestCityCode] [varchar](10) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[SEGCO2Emissions] [float] NULL,
	[NOXCO2Emissions] [float] NULL,
	[MINCO2Emissions] [float] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[TtlSeats] [int] NULL,
	[YieldInd] [varchar](1) NULL,
	[YieldAmt] [float] NULL,
	[YieldDatePosted] [datetime] NULL,
	[SegTrueTktCount] [int] NULL
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 11:20:36 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC,
	[OrigCountry] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 11:20:37 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI1]    Script Date: 7/7/2015 11:20:37 PM ******/
CREATE CLUSTERED INDEX [HotelI1] ON [dba].[Hotel]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/7/2015 11:20:38 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [dba].[ComRmks]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CityI1]    Script Date: 7/7/2015 11:20:38 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CityI1] ON [dba].[City]
(
	[TypeCode] ASC,
	[CityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/7/2015 11:20:38 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [dba].[Car]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefI1]    Script Date: 7/7/2015 11:20:39 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 11:20:39 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/7/2015 11:20:39 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [dba].[InvoiceHeader]
(
	[BookingBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/7/2015 11:20:39 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/7/2015 11:20:40 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [dba].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 11:20:40 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/7/2015 11:20:40 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI3]    Script Date: 7/7/2015 11:20:40 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI3] ON [dba].[InvoiceDetail]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI5]    Script Date: 7/7/2015 11:20:40 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI5] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailPX]    Script Date: 7/7/2015 11:20:40 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetailPX] ON [dba].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [dba].[Hotel]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelPX]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI2]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI2] ON [dba].[ComRmks]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI3]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI3] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI4]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI4] ON [dba].[ComRmks]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CarI2]    Script Date: 7/7/2015 11:20:41 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [dba].[Car]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI3]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE NONCLUSTERED INDEX [CarI3] ON [dba].[Car]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CarI6]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE NONCLUSTERED INDEX [CarI6] ON [dba].[Car]
(
	[PickupDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [dba].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI3]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE NONCLUSTERED INDEX [UdefI3] ON [dba].[Udef]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefI4]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE NONCLUSTERED INDEX [UdefI4] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI5]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE NONCLUSTERED INDEX [UdefI5] ON [dba].[Udef]
(
	[UdefNum] ASC,
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/7/2015 11:20:42 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [dba].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC,
	[UdefType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TranSegI4]    Script Date: 7/7/2015 11:20:43 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI4] ON [dba].[TranSeg]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI5]    Script Date: 7/7/2015 11:20:43 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI5] ON [dba].[TranSeg]
(
	[ClientCode] ASC,
	[IataNum] ASC,
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI6]    Script Date: 7/7/2015 11:20:43 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI6] ON [dba].[TranSeg]
(
	[OriginCityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/7/2015 11:20:43 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [dba].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

