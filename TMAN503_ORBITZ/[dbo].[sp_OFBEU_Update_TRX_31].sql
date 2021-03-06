/****** Object:  StoredProcedure [dbo].[sp_OFBEU_Update_TRX_31]    Script Date: 7/14/2015 8:13:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_OFBEU_Update_TRX_31]
@BeginIssueDate datetime,
@EndIssueDate datetime

 AS

update dba.invoicedetail
set farecompare4 = farecompare1
where (farecompare2 is null
or farecompare2 = 0)
and farecompare1 is not null
and issuedate between @BeginIssueDate and @EndIssueDate 
and iatanum = 'OFBEU'


update dba.invoicedetail
set farecompare1 = 0
where (farecompare2 is null
or farecompare2 = 0)
and issuedate between @BeginIssueDate and @EndIssueDate 
and iatanum = 'OFBEU'


update dba.invoicedetail
set farecompare2 = farecompare4
where (farecompare2 is null
or farecompare2 = 0)
and (farecompare4 is not null
or farecompare4 = 0)
and issuedate between @BeginIssueDate and @EndIssueDate 
and iatanum = 'OFBEU'

update dba.invoicedetail
set farecompare4 = 0
where issuedate between @BeginIssueDate and @EndIssueDate 
and iatanum = 'OFBEU'

update id
set id.farecompare1 = substring(ud50.udefdata,1,150)
from dba.invoicedetail id, dba.udef ud50
where id.iatanum = ud50.iatanum
and id.iatanum ='OFBEU'
and id.recordkey = ud50.recordkey
and ud50.udefnum =50
and (id.farecompare1  is null
or id.farecompare1 = 0)
and ud50.udefdata is not null
and id.issuedate = ud50.issuedate
and id.issuedate between @BeginIssueDate and @EndIssueDate 

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
and ih.iatanum = 'OFBEU'
and id.iatanum = 'OFBEU'
and ts.iatanum = 'OFBEU'
and (id.origincode <> ts.origincitycode
or id.destinationcode <> ts.mindestcitycode)

--Populate Common Remarks for 25 trip reference fields--added 2/12/2009
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
WHERE iatanum in ('OFBEU')
and issuedate between @BeginIssueDate and @EndIssueDate 
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('OFBEU'))



update cr
set cr.text1 = substring(ud71.udefdata,1,150)
from dba.comrmks cr, dba.udef ud71
where cr.iatanum = ud71.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud71.recordkey
---and cr.seqnum = ud100.seqnum
and ud71.udefnum = 71
and cr.text1 is null
and ud71.udefdata is not null
and cr.issuedate = ud71.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 


update cr
set cr.text2 = substring(ud72.udefdata,1,150)
from dba.comrmks cr, dba.udef ud72
where cr.iatanum = ud72.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud72.recordkey
---and cr.seqnum = ud72.seqnum
and ud72.udefnum = 72
and cr.text2 is null
and ud72.udefdata is not null
and cr.issuedate = ud72.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text3 = substring(ud73.udefdata,1,150)
from dba.comrmks cr, dba.udef ud73
where cr.iatanum = ud73.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud73.recordkey
---and cr.seqnum = ud73.seqnum
and ud73.udefnum = 73
and cr.text3 is null
and ud73.udefdata is not null
and cr.issuedate = ud73.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text4 = substring(ud74.udefdata,1,150)
from dba.comrmks cr, dba.udef ud74
where cr.iatanum = ud74.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud74.recordkey
---and cr.seqnum = ud74.seqnum
and ud74.udefnum = 74
and cr.text4 is null
and ud74.udefdata is not null
and cr.issuedate = ud74.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text5 = substring(ud75.udefdata,1,150)
from dba.comrmks cr, dba.udef ud75
where cr.iatanum = ud75.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud75.recordkey
---and cr.seqnum = ud75.seqnum
and ud75.udefnum = 75
and cr.text5 is null
and ud75.udefdata is not null
and cr.issuedate = ud75.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text6 = substring(ud76.udefdata,1,150)
from dba.comrmks cr, dba.udef ud76
where cr.iatanum = ud76.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud76.recordkey
---and cr.seqnum = ud76.seqnum
and ud76.udefnum = 76
and cr.text6 is null
and ud76.udefdata is not null
and cr.issuedate = ud76.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text7 = substring(ud77.udefdata,1,150)
from dba.comrmks cr, dba.udef ud77
where cr.iatanum = ud77.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud77.recordkey
---and cr.seqnum = ud77.seqnum
and ud77.udefnum = 77
and cr.text7 is null
and ud77.udefdata is not null
and cr.issuedate = ud77.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text8 = substring(ud78.udefdata,1,150)
from dba.comrmks cr, dba.udef ud78
where cr.iatanum = ud78.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud78.recordkey
---and cr.seqnum = ud78.seqnum
and ud78.udefnum = 78
and cr.text8 is null
and ud78.udefdata is not null
and cr.issuedate = ud78.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text9 = substring(ud79.udefdata,1,150)
from dba.comrmks cr, dba.udef ud79
where cr.iatanum = ud79.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud79.recordkey
---and cr.seqnum = ud79.seqnum
and ud79.udefnum = 79
and cr.text9 is null
and ud79.udefdata is not null
and cr.issuedate = ud79.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 


update cr
set cr.text10 = substring(ud80.udefdata,1,150)
from dba.comrmks cr, dba.udef ud80
where cr.iatanum = ud80.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud80.recordkey
---and cr.seqnum = ud80.seqnum
and ud80.udefnum = 80
and cr.text10 is null
and ud80.udefdata is not null
and cr.issuedate = ud80.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text11 = substring(ud81.udefdata,1,150)
from dba.comrmks cr, dba.udef ud81
where cr.iatanum = ud81.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud81.recordkey
---and cr.seqnum = ud81.seqnum
and ud81.udefnum = 81
and cr.text11 is null
and ud81.udefdata is not null
and cr.issuedate = ud81.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text12 = substring(ud82.udefdata,1,150)
from dba.comrmks cr, dba.udef ud82
where cr.iatanum = ud82.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud82.recordkey
---and cr.seqnum = ud82.seqnum
and ud82.udefnum = 82
and cr.text12 is null
and ud82.udefdata is not null
and cr.issuedate = ud82.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text13 = substring(ud83.udefdata,1,150)
from dba.comrmks cr, dba.udef ud83
where cr.iatanum = ud83.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud83.recordkey
---and cr.seqnum = ud83.seqnum
and ud83.udefnum = 83
and cr.text13 is null
and ud83.udefdata is not null
and cr.issuedate = ud83.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text14 = substring(ud84.udefdata,1,150)
from dba.comrmks cr, dba.udef ud84
where cr.iatanum = ud84.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud84.recordkey
---and cr.seqnum = ud84.seqnum
and ud84.udefnum = 84
and cr.text14 is null
and ud84.udefdata is not null
and cr.issuedate = ud84.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text15 = substring(ud85.udefdata,1,150)
from dba.comrmks cr, dba.udef ud85
where cr.iatanum = ud85.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud85.recordkey
---and cr.seqnum = ud85.seqnum
and ud85.udefnum = 85
and cr.text15 is null
and ud85.udefdata is not null
and cr.issuedate = ud85.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text16 = substring(ud86.udefdata,1,150)
from dba.comrmks cr, dba.udef ud86
where cr.iatanum = ud86.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud86.recordkey
---and cr.seqnum = ud86.seqnum
and ud86.udefnum = 86
and cr.text16 is null
and ud86.udefdata is not null
and cr.issuedate = ud86.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text17 = substring(ud87.udefdata,1,150)
from dba.comrmks cr, dba.udef ud87
where cr.iatanum = ud87.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud87.recordkey
---and cr.seqnum = ud87.seqnum
and ud87.udefnum = 87
and cr.text17 is null
and ud87.udefdata is not null
and cr.issuedate = ud87.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 


update cr
set cr.text18 = substring(ud88.udefdata,1,150)
from dba.comrmks cr, dba.udef ud88
where cr.iatanum = ud88.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud88.recordkey
---and cr.seqnum = ud88.seqnum
and ud88.udefnum = 88
and cr.text18 is null
and ud88.udefdata is not null
and cr.issuedate = ud88.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text19 = substring(ud89.udefdata,1,150)
from dba.comrmks cr, dba.udef ud89
where cr.iatanum = ud89.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud89.recordkey
---and cr.seqnum = ud89.seqnum
and ud89.udefnum = 89
and cr.text19 is null
and ud89.udefdata is not null
and cr.issuedate = ud89.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text20 = substring(ud90.udefdata,1,150)
from dba.comrmks cr, dba.udef ud90
where cr.iatanum = ud90.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud90.recordkey
---and cr.seqnum = ud90.seqnum
and ud90.udefnum = 90
and cr.text20 is null
and ud90.udefdata is not null
and cr.issuedate between @BeginIssueDate and @EndIssueDate 
and cr.issuedate = ud90.issuedate


update cr
set cr.text21 = substring(ud91.udefdata,1,150)
from dba.comrmks cr, dba.udef ud91
where cr.iatanum = ud91.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud91.recordkey
---and cr.seqnum = ud91.seqnum
and ud91.udefnum = 91
and cr.text21 is null
and ud91.udefdata is not null
and cr.issuedate = ud91.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text22 = substring(ud92.udefdata,1,150)
from dba.comrmks cr, dba.udef ud92
where cr.iatanum = ud92.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud92.recordkey
---and cr.seqnum = ud92.seqnum
and ud92.udefnum = 92
and cr.text22 is null
and ud92.udefdata is not null
and cr.issuedate = ud92.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text23 = substring(ud93.udefdata,1,150)
from dba.comrmks cr, dba.udef ud93
where cr.iatanum = ud93.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud93.recordkey
---and cr.seqnum = ud93.seqnum
and ud93.udefnum = 93
and cr.text23 is null
and ud93.udefdata is not null
and cr.issuedate = ud93.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text24 = substring(ud94.udefdata,1,150)
from dba.comrmks cr, dba.udef ud94
where cr.iatanum = ud94.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud94.recordkey
---and cr.seqnum = ud94.seqnum
and ud94.udefnum = 94
and cr.text24 is null
and ud94.udefdata is not null
and cr.issuedate = ud94.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update cr
set cr.text25 = substring(ud95.udefdata,1,150)
from dba.comrmks cr, dba.udef ud95
where cr.iatanum = ud95.iatanum
and cr.iatanum ='OFBEU'
and cr.recordkey = ud95.recordkey
---and cr.seqnum = ud95.seqnum
and ud95.udefnum = 95
and cr.text25 is null
and ud95.udefdata is not null
and cr.issuedate = ud95.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate 

update car
set carreasoncode1 = ud.udefdata
from dba.car car, dba.udef ud
where car.recordkey = ud.recordkey
and car.iatanum = ud.iatanum
and car.seqnum = ud.seqnum
and car.issuedate = ud.issuedate
and car.clientcode = ud.clientcode
and ud.udefnum = 37
and car.iatanum = 'OFBEU'
and car.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate 
and ud.iatanum = 'OFBEU'
and ud.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate 


update htl
set htlreasoncode1 = ud.udefdata
from dba.hotel htl, dba.udef ud
where htl.recordkey = ud.recordkey
and htl.iatanum = ud.iatanum
and htl.seqnum = ud.seqnum
and htl.issuedate = ud.issuedate
and htl.clientcode = ud.clientcode
and ud.udefnum = 34
and htl.iatanum = 'OFBEU'
and htl.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate 
and ud.iatanum = 'OFBEU'
and ud.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate 

--Update online booking system per incident #1066175...added by Nina on 3/10/11
update dba.invoicedetail
set onlinebookingsystem = CASE when bookingagentid  = 'HW' then 'ONLN'
			  ELSE 'OFFLN'
			  END
where iatanum = 'OFBEU'
and IssueDate BETWEEN @BeginIssueDate and @EndIssueDate

--Kara Pauga 5/6/11
--Incident 1067384
update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBEU'
and id.clientcode  in ('1000010','3000009','3000010')
and id.recordkey = ud.recordkey
and ud.udefnum = 72
and ud.iatanum ='OFBEU'
and ud.clientcode  in ('1000010','3000009','3000010')
and ud.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate 

---DETERMINE DOMESTIC SEGMENT---
update TS
set TS.SEGINTERNATIONALIND = 'D'
FROM dba.City ORIG,dba.transeg TS,dba.City XMDEST
 WHERE (( Ts.IataNum = 'OFBEU'))
   AND ((ORIG.CityCode = TS.OriginCityCode
   AND ORIG.TypeCode = TS.TypeCode
   AND XMDEST.CityCode = TS.SEGDestCityCode
   AND XMDEST.TypeCode = TS.TypeCode 
   AND ts.issuedate between @BeginIssueDate and @EndIssueDate
   and orig.countrycode in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR'
,'GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
   and xmdest.countrycode in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR'
,'GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
   ))


---DETERMINE NOXMARKET DOMESTIC---
UPDATE TS
set TS.NOXINTERNATIONALIND ='D'
FROM dba.City ORIG,dba.transeg TS,dba.City XMDEST
 WHERE (( Ts.IataNum = 'OFBEU'))
   AND ((ORIG.CityCode = TS.NOXMKTOrigCityCode
   AND ORIG.TypeCode = TS.TypeCode
   AND XMDEST.CityCode = TS.NOXMKTDestCityCode
   AND XMDEST.TypeCode = TS.TypeCode 
   AND ts.issuedate between @BeginIssueDate and @EndIssueDate
   and orig.countrycode in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR'
,'GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
   and xmdest.countrycode in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR'
,'GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
   ))


---DETERMINE MINMARKET DOMESTIC---
UPDATE TS
set TS.MININTERNATIONALIND ='D'
FROM dba.City ORIG,dba.transeg TS,dba.City XMDEST
 WHERE (( Ts.IataNum = 'OFBEU'))
   AND ((ORIG.CityCode = TS.MINMKTOrigCityCode
   AND ORIG.TypeCode = TS.TypeCode
   AND XMDEST.CityCode = TS.MINMKTDestCityCode
   AND XMDEST.TypeCode = TS.TypeCode 
   AND ts.issuedate between @BeginIssueDate and @EndIssueDate
   and orig.countrycode in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR'
,'GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
   and xmdest.countrycode in ('AT','BE','BG','CY','CZ','DE','DK','EE','ES','FI','FR'
,'GB','GR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK')
   ))


---UPDATE TICKET INTERNATIONAL IND FROM SEGMENT---
UPDATE dba.invoicedetail
SET INTERNATIONALIND ='D'
WHERE IATANUM ='OFBEU'
AND issuedate between @BeginIssueDate and @EndIssueDate
AND VENDORTYPE IN ('BSP','NONBSP')

UPDATE dba.invoicedetail
SET INTERNATIONALIND = 'I'
WHERE IATANUM ='OFBEU'
AND issuedate between @BeginIssueDate and @EndIssueDate
AND VENDORTYPE IN ('BSP','NONBSP')
AND recordkey+iatanum+convert(varchar,seqnum) IN (SELECT recordkey+iatanum+convert(varchar,seqnum)
FROM dba.transeg
WHERE IATANUM ='OFBEU'
AND issuedate between @BeginIssueDate and @EndIssueDate
AND SEGINTERNATIONALIND ='I')

--Kara Pauga 12/28/11
--Incident 1072360
update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBEU'
and id.clientcode  in ('3000014')
and id.recordkey = ud.recordkey
and ud.udefnum = 71
and ud.iatanum ='OFBEU'
and ud.clientcode  in ('3000014')
and ud.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate 

--Kara Pauga 1/6/12
--Incident 1072515
update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBEU'
and id.clientcode  in ('3000016')
and id.recordkey = ud.recordkey
and ud.udefnum = 72
and ud.iatanum ='OFBEU'
and ud.clientcode  in ('3000016')
and ud.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate

--Kara Pauga 4/5/12
--Incident 1075444
update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='OFBEU'
and id.clientcode  in ('3000015')
and id.recordkey = ud.recordkey
and ud.udefnum = 71
and ud.iatanum ='OFBEU'
and ud.clientcode  in ('3000015')
and ud.IssueDate BETWEEN @BeginIssueDate and @EndIssueDate

GO
