/****** Object:  StoredProcedure [dbo].[sp_ORBITZ_Update]    Script Date: 7/14/2015 8:13:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ORBITZ_Update]
	
AS
--Update currcode
update dba.invoicedetail
set currcode = 'USD'
where totalamt is null
and currcode <> 'USD'
and iatanum = 'ORBITZ'

--Populate Common Remarks for 25 trip reference fields--added 9/28/2007
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail id
WHERE id.iatanum in ('ORBITZ')
--AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)

AND not exists (select 1
				FROM dba.ComRmks cr
				WHERE cr.iatanum in ('ORBITZ')
				and cr.recordkey = id.recordkey
				and cr.iatanum = id.iatanum
				and cr.seqnum = id.seqnum)


-- DECLARE @importdt datetime
-- SET @importdt = (select max(importdt) from dba.invoiceheader)

-- every time we import old records the dba.invoiceheader.importdt stays old as per first import.
-- this makes comrmks.issuedate be different then id.issudate
-- I commented AND ih.importdt >= @importdt  in update statement below. It may slow down entire querry
-- incident 1057770 - Yuliya Tsizh

update cr
set cr.issuedate = id.issuedate
from dba.invoiceheader ih, dba.invoicedetail id,dba.ComRmks cr
WHERE ih.RecordKey = id.RecordKey
AND ih.IataNum = id.IataNum
AND ih.ClientCode = id.ClientCode
AND ih.invoicedate = id.invoicedate
--AND ih.importdt >= @importdt
AND id.RecordKey+id.IataNum+CONVERT(VARCHAR,id.SeqNum) = cr.RecordKey+cr.IataNum+CONVERT(VARCHAR,cr.SeqNum)
AND cr.ClientCode = id.ClientCode
AND cr.issuedate <> id.issuedate


update cr
set cr.text1 = substring(ud100.udefdata,1,150)
from dba.comrmks cr, dba.udef ud100
where cr.iatanum = ud100.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud100.recordkey
---and cr.seqnum = ud100.seqnum
and ud100.udefnum = 100
and cr.text1 is null
and ud100.udefdata is not null
and cr.issuedate = ud100.issuedate



update cr
set cr.text2 = substring(ud101.udefdata,1,150)
from dba.comrmks cr, dba.udef ud101
where cr.iatanum = ud101.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud101.recordkey
---and cr.seqnum = ud101.seqnum
and ud101.udefnum = 101
and cr.text2 is null
and ud101.udefdata is not null
and cr.issuedate = ud101.issuedate


update cr
set cr.text3 = substring(ud102.udefdata,1,150)
from dba.comrmks cr, dba.udef ud102
where cr.iatanum = ud102.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud102.recordkey
---and cr.seqnum = ud102.seqnum
and ud102.udefnum = 102
and cr.text3 is null
and ud102.udefdata is not null
and cr.issuedate = ud102.issuedate


update cr
set cr.text4 = substring(ud103.udefdata,1,150)
from dba.comrmks cr, dba.udef ud103
where cr.iatanum = ud103.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud103.recordkey
---and cr.seqnum = ud103.seqnum
and ud103.udefnum = 103
and cr.text4 is null
and ud103.udefdata is not null
and cr.issuedate = ud103.issuedate

-- Incident #1058541 Client: Yale (TPT-000173) has requested the update of UDEF103/CR10 to be mapped to ID049. Can you please update historical data with the new specified UDEF and update the stored daily and weekly procedure for future bookings. Thank you
update id
set id.department = substring(ud103.udefdata,1,40)
from dba.invoicedetail id, dba.udef ud103
where id.iatanum = ud103.iatanum
and id.iatanum ='ORBITZ'
and id.recordkey = ud103.recordkey
---and cr.seqnum = ud103.seqnum
and ud103.udefnum = 103
and id.department is null
and ud103.udefdata is not null
and id.issuedate = ud103.issuedate
and id.clientcode = 'TPT-000173'
and id.clientcode = ud103.clientcode

update cr
set cr.text5 = substring(ud104.udefdata,1,150)
from dba.comrmks cr, dba.udef ud104
where cr.iatanum = ud104.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud104.recordkey
---and cr.seqnum = ud104.seqnum
and ud104.udefnum = 104
and cr.text5 is null
and ud104.udefdata is not null
and cr.issuedate = ud104.issuedate


update cr
set cr.text6 = substring(ud120.udefdata,1,150)
from dba.comrmks cr, dba.udef ud120
where cr.iatanum = ud120.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud120.recordkey
---and cr.seqnum = ud120.seqnum
and ud120.udefnum = 120
and cr.text6 is null
and ud120.udefdata is not null
and cr.issuedate = ud120.issuedate


update cr
set cr.text7 = substring(ud121.udefdata,1,150)
from dba.comrmks cr, dba.udef ud121
where cr.iatanum = ud121.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud121.recordkey
---and cr.seqnum = ud121.seqnum
and ud121.udefnum = 121
and cr.text7 is null
and ud121.udefdata is not null
and cr.issuedate = ud121.issuedate

update cr
set cr.text8 = substring(ud122.udefdata,1,150)
from dba.comrmks cr, dba.udef ud122
where cr.iatanum = ud122.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud122.recordkey
---and cr.seqnum = ud122.seqnum
and ud122.udefnum = 122
and cr.text8 is null
and ud122.udefdata is not null
and cr.issuedate = ud122.issuedate


update cr
set cr.text9 = substring(ud123.udefdata,1,150)
from dba.comrmks cr, dba.udef ud123
where cr.iatanum = ud123.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud123.recordkey
---and cr.seqnum = ud123.seqnum
and ud123.udefnum = 123
and cr.text9 is null
and ud123.udefdata is not null
and cr.issuedate = ud123.issuedate



update cr
set cr.text10 = substring(ud124.udefdata,1,150)
from dba.comrmks cr, dba.udef ud124
where cr.iatanum = ud124.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud124.recordkey
---and cr.seqnum = ud124.seqnum
and ud124.udefnum = 124
and cr.text10 is null
and ud124.udefdata is not null
and cr.issuedate = ud124.issuedate


update cr
set cr.text11 = substring(ud125.udefdata,1,150)
from dba.comrmks cr, dba.udef ud125
where cr.iatanum = ud125.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud125.recordkey
---and cr.seqnum = ud125.seqnum
and ud125.udefnum = 125
and cr.text11 is null
and ud125.udefdata is not null
and cr.issuedate = ud125.issuedate


update cr
set cr.text12 = substring(ud126.udefdata,1,150)
from dba.comrmks cr, dba.udef ud126
where cr.iatanum = ud126.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud126.recordkey
---and cr.seqnum = ud126.seqnum
and ud126.udefnum = 126
and cr.text12 is null
and ud126.udefdata is not null
and cr.issuedate = ud126.issuedate


update cr
set cr.text13 = substring(ud127.udefdata,1,150)
from dba.comrmks cr, dba.udef ud127
where cr.iatanum = ud127.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud127.recordkey
---and cr.seqnum = ud127.seqnum
and ud127.udefnum = 127
and cr.text13 is null
and ud127.udefdata is not null
and cr.issuedate = ud127.issuedate


update cr
set cr.text14 = substring(ud128.udefdata,1,150)
from dba.comrmks cr, dba.udef ud128
where cr.iatanum = ud128.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud128.recordkey
---and cr.seqnum = ud128.seqnum
and ud128.udefnum = 128
and cr.text14 is null
and ud128.udefdata is not null
and cr.issuedate = ud128.issuedate


update cr
set cr.text15 = substring(ud129.udefdata,1,150)
from dba.comrmks cr, dba.udef ud129
where cr.iatanum = ud129.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud129.recordkey
---and cr.seqnum = ud129.seqnum
and ud129.udefnum = 129
and cr.text15 is null
and ud129.udefdata is not null
and cr.issuedate = ud129.issuedate


update cr
set cr.text16 = substring(ud130.udefdata,1,150)
from dba.comrmks cr, dba.udef ud130
where cr.iatanum = ud130.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud130.recordkey
---and cr.seqnum = ud130.seqnum
and ud130.udefnum = 130
and cr.text16 is null
and ud130.udefdata is not null
and cr.issuedate = ud130.issuedate


update cr
set cr.text17 = substring(ud131.udefdata,1,150)
from dba.comrmks cr, dba.udef ud131
where cr.iatanum = ud131.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud131.recordkey
---and cr.seqnum = ud131.seqnum
and ud131.udefnum = 131
and cr.text17 is null
and ud131.udefdata is not null
and cr.issuedate = ud131.issuedate



update cr
set cr.text18 = substring(ud132.udefdata,1,150)
from dba.comrmks cr, dba.udef ud132
where cr.iatanum = ud132.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud132.recordkey
---and cr.seqnum = ud132.seqnum
and ud132.udefnum = 132
and cr.text18 is null
and ud132.udefdata is not null
and cr.issuedate = ud132.issuedate


update cr
set cr.text19 = substring(ud133.udefdata,1,150)
from dba.comrmks cr, dba.udef ud133
where cr.iatanum = ud133.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud133.recordkey
---and cr.seqnum = ud133.seqnum
and ud133.udefnum = 133
and cr.text19 is null
and ud133.udefdata is not null
and cr.issuedate = ud133.issuedate


update cr
set cr.text20 = substring(ud134.udefdata,1,150)
from dba.comrmks cr, dba.udef ud134
where cr.iatanum = ud134.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud134.recordkey
---and cr.seqnum = ud134.seqnum
and ud134.udefnum = 134
and cr.text20 is null
and ud134.udefdata is not null

and cr.issuedate = ud134.issuedate


update cr
set cr.text21 = substring(ud135.udefdata,1,150)
from dba.comrmks cr, dba.udef ud135
where cr.iatanum = ud135.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud135.recordkey
---and cr.seqnum = ud135.seqnum
and ud135.udefnum = 135
and cr.text21 is null
and ud135.udefdata is not null
and cr.issuedate = ud135.issuedate


update cr
set cr.text22 = substring(ud136.udefdata,1,150)
from dba.comrmks cr, dba.udef ud136
where cr.iatanum = ud136.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud136.recordkey
---and cr.seqnum = ud136.seqnum
and ud136.udefnum = 136
and cr.text22 is null
and ud136.udefdata is not null
and cr.issuedate = ud136.issuedate


update cr
set cr.text23 = substring(ud137.udefdata,1,150)
from dba.comrmks cr, dba.udef ud137
where cr.iatanum = ud137.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud137.recordkey
---and cr.seqnum = ud137.seqnum
and ud137.udefnum = 137
and cr.text23 is null
and ud137.udefdata is not null
and cr.issuedate = ud137.issuedate


update cr
set cr.text24 = substring(ud138.udefdata,1,150)
from dba.comrmks cr, dba.udef ud138
where cr.iatanum = ud138.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud138.recordkey
---and cr.seqnum = ud138.seqnum
and ud138.udefnum = 138
and cr.text24 is null
and ud138.udefdata is not null
and cr.issuedate = ud138.issuedate


update cr
set cr.text25 = substring(ud139.udefdata,1,150)
from dba.comrmks cr, dba.udef ud139
where cr.iatanum = ud139.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud139.recordkey
---and cr.seqnum = ud139.seqnum
and ud139.udefnum = 139
and cr.text25 is null
and ud139.udefdata is not null
and cr.issuedate = ud139.issuedate
-------------------------------------------------- Incident #1056633 2009-12-10
update cr
set cr.text26 = substring(ud140.udefdata,1,150)
from dba.comrmks cr, dba.udef ud140
where cr.iatanum = ud140.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud140.recordkey
---and cr.seqnum = ud139.seqnum
and ud140.udefnum = 140
and cr.text26 is null
and ud140.udefdata is not null
and cr.issuedate = ud140.issuedate


update cr
set cr.text27 = substring(ud141.udefdata,1,150)
from dba.comrmks cr, dba.udef ud141
where cr.iatanum = ud141.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud141.recordkey
and ud141.udefnum = 141
and cr.text27 is null
and ud141.udefdata is not null
and cr.issuedate = ud141.issuedate


update cr
set cr.text28 = substring(ud142.udefdata,1,150)
from dba.comrmks cr, dba.udef ud142
where cr.iatanum = ud142.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud142.recordkey
and ud142.udefnum = 142
and cr.text28 is null
and ud142.udefdata is not null
and cr.issuedate = ud142.issuedate

--added on 4/2/12 per incident #1074936
update cr
set cr.text29 = substring(ud144.udefdata,1,150)
from dba.comrmks cr, dba.udef ud144
where cr.iatanum = ud144.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud144.recordkey
and ud144.udefnum = 144
and cr.text29 is null
and ud144.udefdata is not null
and cr.issuedate = ud144.issuedate

------------------------------------------------------------------
update cr
set cr.text50 = substring(ud110.udefdata,1,150)
from dba.comrmks cr, dba.udef ud110
where cr.iatanum = ud110.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud110.recordkey
---and cr.seqnum = ud110.seqnum
and ud110.udefnum = 110
and cr.text50 is null
and ud110.udefdata is not null
and cr.issuedate = ud110.issuedate

update cr
set cr.text50 = substring(ud110.udefdata,1,150)
from dba.comrmks cr, dba.udef ud110
where cr.iatanum = ud110.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud110.recordkey
---and cr.seqnum <> ud110.seqnum
and ud110.udefnum = 110
and cr.text50 is null
and ud110.udefdata is not null
and cr.issuedate = ud110.issuedate

update cr
set cr.text50 = substring(ud110.udefdata,1,150)
from dba.comrmks cr, dba.udef ud110
where cr.iatanum = ud110.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud110.recordkey
---and cr.seqnum <> ud110.seqnum
and ud110.udefnum = 110
and cr.text50 is null
and ud110.udefdata is not null
and cr.invoicedate = ud110.invoicedate
--added 12/10/08
update cr
set cr.text49 = substring(ud114.udefdata,1,150)
from dba.comrmks cr, dba.udef ud114
where cr.iatanum = ud114.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud114.recordkey
---and cr.seqnum <> ud114.seqnum
and ud114.udefnum = 114
and cr.text49 is null
and ud114.udefdata is not null
and cr.invoicedate = ud114.invoicedate


----Quiznos
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='001444'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='001444'
--Tribune
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='001438'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='001438'
---Knight Rider
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='000325'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='000325'

---ACS
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5005000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 102
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5005000'
--bioMerieux
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5101100'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5101100'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP4003400'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP4003400'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5101400'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5101400'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP4002004'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP4002004'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5101500'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5101500'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5101600'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
----and ud.clientcode ='TPT-TP5101600' 	

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='001556'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='001556'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='001043'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='001043'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='000115'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='000115'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5101700'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5101700'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5101500'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5101500'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5003900'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5003900'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5106000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5106000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode in ('000950','TPT-TP52004000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 104
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('000950','TPT-TP52004000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5202000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5202000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5105000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 102
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5105000'

----------------------------???--------Energy Transfer Partners
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode in('TPT-TP5106000','TPT-TP5912957')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in('TPT-TP5106000','TPT-TP5912957')


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5201000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 102
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5201000'


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5209000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5209000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5208000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5208000'

INSERT DBA.Udef
(RecordKey
, IataNum
, SeqNum
, ClientCode
, InvoiceDate
, IssueDate
, UdefNum
, UdefType
, UdefData
)
SELECT distinct ID.RecordKey
, ID.IataNum
, ID.SeqNum
, ID.ClientCode
, ID.InvoiceDate
, ID.IssueDate
, 100
, null
, 'CORP'
FROM DBA.invoicedetail ID, dba.udef ud
WHERE ID.clientcode = 'TPT-TP5005000'

AND id.recordkey+CAST(ID.seqnum AS VARCHAR) NOT IN (
              SELECT  ud.recordkey+cast(UD.seqnum AS VARCHAR)
                 FROM dba.udef ud
                 where udefnum = 100
                 and ud.clientcode = 'TPT-TP5005000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5303000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5303000'


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5405000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5405000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5403000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5403000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5003300'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5003300'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5002600'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5002600'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5409000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5409000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5301000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5301000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5503000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5503000'


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5601000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5601000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5508000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5508000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5603000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5603000'

--update id
--set id.department = substring(ud.udefdata,1,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5407000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5407000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5608000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5608000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5609000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5609000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5601000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5601000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode = 'TPT-TP5101900'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5101900'


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5609000', 'TPT-TP5609001', 'TPT-TP5609002', 'TPT-TP5609003', 'TPT-TP5609004')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5609000', 'TPT-TP5609001', 'TPT-TP5609002', 'TPT-TP5609003', 'TPT-TP5609004')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  = 'TPT-TP5401000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  = 'TPT-TP5401000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  = 'TPT-TP5704000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  = 'TPT-TP5704000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  = 'TPT-TP5200000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  = 'TPT-TP5200000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  = 'TPT-TP5706000'
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  = 'TPT-TP5706000'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5703000' , 'TPT-TP5703001')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5703000' , 'TPT-TP5703001')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5709000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5709000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5803000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5803000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5804000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5804000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5800000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5800000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5801000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5801000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5900000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 103
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5900000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5101600')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5101600')
--and id.issuedate > '2007-09-25'

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5003500','TPT-TP5003501')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5003500','TPT-TP5003501')



update dba.hotel
set htlchainname = 'Radisson'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='RAD'

update dba.hotel
set htlchainname = 'Sutton Place'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000063'

update dba.hotel
set htlchainname = 'Conrad'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000053'

update dba.hotel
set htlchainname = 'Four Points'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='FP'

update dba.hotel
set htlchainname = 'Sofitel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='VS'

update dba.hotel
set htlchainname = 'Country Inn and Suites'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='CHI'

update dba.hotel
set htlchainname = 'Amerihost'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='MQ'

update dba.hotel
set htlchainname = 'Lexington'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LP'

update dba.hotel
set htlchainname = 'Pan Pacific'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='PP'

update dba.hotel
set htlchainname = 'Park Inn'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='PII'

update dba.hotel
set htlchainname = 'Hotel Providence'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000194'

update dba.hotel
set htlchainname = 'Sahara'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LDC'

update dba.hotel
set htlchainname = 'Walt Disney World'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='WDW'

update dba.hotel
set htlchainname = 'Wrens House'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='HO'

update dba.hotel
set htlchainname = 'Novitel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='XN'

update dba.hotel
set htlchainname = 'Palace Hotel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LC'

-- added by Jim to fix NULL VendorNumber

update t1
set vendornumber = valcarriernum
from dba.invoicedetail t1
where t1.IATANUM='ORBITZ'
AND t1.VENDORTYPE IN ('BSP','NONBSP') 
AND t1.VOIDIND='N' 
AND t1.VENDORNUMBER IS NULL

-- added by Jim to fix NULL ValCarrierCode and VendorName for TT Standard reports

UPDATE id
SET id.ValCarrierCode = TS.SegmentCarrierCode,
      id.VendorName = TS.SegmentCarrierName
FROM dba.invoicedetail id, dba.transeg ts
where id.iatanum = 'ORBITZ'
and id.recordkey = ts.recordkey
and id.iatanum = ts.iatanum
and id.seqnum = ts.seqnum
and id.voidind = 'N'
and id.vendortype in ('BSP','NONBSP')
and id.vendorname is NULL
and ts.segmentnum = 1


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5306001')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5306001')

-- Incident #1058805  Kara Pauga 01/12/10
--Updated on 10/6/11 to pull from UDEF101 instead of 120 per Kara #1070681 

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5306000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5306000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5003600')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5003600')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5003301')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5003301')

update ht
set ht.issuedate = id.issuedate
from dba.hotel ht, dba.invoicedetail id
where ht.issuedate <> id.issuedate
and ht.recordkey = id.recordkey
and ht.seqnum = id.seqnum
and ht.iatanum = id.iatanum
and ht.iatanum in('ORBITZ')

update ht
set ht.issuedate = id.issuedate
from dba.car ht, dba.invoicedetail id
where ht.issuedate <> id.issuedate
and ht.recordkey = id.recordkey
and ht.seqnum = id.seqnum
and ht.iatanum = id.iatanum
and ht.iatanum in('ORBITZ')

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
and ih.iatanum = 'ORBITZ'
and id.iatanum = 'ORBITZ'
and ts.iatanum = 'ORBITZ'
and id.origincode is  null
and id.destinationcode is null


update id
set id.valcarriernum = cr.carriernumber
from  DBA.INVOICEDETAIL id, dba.carriers cr
WHEre id.IATANUM='ORBITZ' 
AND id.VENDORTYPE IN ('BSP','NONBSP') 
AND id.VOIDIND='N'   
and id.ValCarrierNum IS NULL
and cr.carriercode = id.valcarriercode

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5910300')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5910300')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5911400')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5911400')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5911000')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5911000')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5910100')
--and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5910100')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5910800','TPT-TP5910801','TPT-TP5910802','TPT-TP5910803','TPT-TP5910804')
--and id.recordkey = ud.recordkey
-------and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode = id.clientcode  

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5002701','TPT-TP5002700')
--and id.recordkey = ud.recordkey
-------and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5002701','TPT-TP5002700')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-001043','TPT-001444','TPT-001556')
--and id.recordkey = ud.recordkey
-------and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-001043','TPT-001444','TPT-001556')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-001438')
--and id.recordkey = ud.recordkey
-------and id.seqnum = ud.seqnum
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-001438')

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912863')
--and id.recordkey = ud.recordkey
-------and id.seqnum = ud.seqnum
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912863')


--Added per Kara incident #1049753
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5911500','TPT-TP5912974')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode=id.clientcode 


--Added per Kara incident 1048894
--Removed the edit about onlinebookingsystem = NULL per Kara incident #1070050
update dba.invoicedetail
set farecompare2 = null,
reasoncode1 = null
from dba.invoicedetail
where iatanum ='ORBITZ'
and exchangeind ='Y'
and vendortype in ('BSP','NONBSP')
and issuedate >'2007-12-31'
and farecompare2 is not null

update dba.invoicedetail
set farecompare2 = null,
reasoncode1 = null
from dba.invoicedetail
where iatanum ='ORBITZ'
and exchangeind ='Y'
and vendortype in ('BSP','NONBSP')
and issuedate >'2007-12-31'
and reasoncode1 is not null


--Added per Kara incident #1050028
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912700')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912700')

--Added per Kara incident #1050286
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5500000')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5500000')

--Incident Number: 1051044
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912912')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912912')


--Incident Number: 1051257
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in('TP5912909','TPT-TP5912909')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 103
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TP5912909','TPT-TP5912909')

--Incident Number: 1051570
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912910')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912910')

--Incident Number: 1051571
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-001772')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-001772')

--Incident Number: 1052131
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912889')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912889')

--Incident Number: 1051570
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912910')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912910')

--Incident Number: 1052432
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912852')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912852')

--Incident Number: 1052341
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 102
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912821','TPT-TP5912822')

--Incident Number: 1052720
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912926')

--incident number 1053157
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912883')

--incident number 1053491
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912927')

--incident 1053674
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5911700')

--incident 1054104
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 124
--and id.Department is null
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912925')

--incident 1054561
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912921')

--incident 1054815
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 102
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912936')

--incident 1055315
--changed to map to udef 101 instead of 100 per Kara on 8/13
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5912946')

--incident 1055364
--changed to look at udef 101 instead of 100 per Kara on 7/24
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode in ('TPT-TP5910500')

-- insident 1056071
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912950')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912950')

-- insident 1056304
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912854')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912854')

-- insident 1056389
-- Incident #1062078
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912939')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912939')
--and id.issuedate >'2010-06-01'

---- insident 1058633 2010-01-04
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912962')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912962')

--Incident #1059 Kara Pauga 02/05/10 
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912960')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912960')


--INSERT INTO DBA.Budgets
--select IataNum,ClientCode,NULL,NULL,'2008-01-01','2008-12-31',0,0,0,0,'USD' from dba.client
--where iatanum+clientcode not in (select distinct iatanum+clientcode from dba.budgets)

-- Incident #1057380  Kara Pauga 10/20/2009 
--  Client Bendix - TPT-TP5911100 has requested the update of UDEF101/CR08 to be mapped to ID049. Can you please update historical data with the new specified UDEF and update the stored daily and weekly procedure for future bookings. Thank you


--update id
--set id.department = ud.udefdata
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5911100')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5911100')

--Incident #1057389 Kara Pauga 10/20/2009 

--update id
--set id.department = ud.udefdata
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-000867')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 104
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-000867')

--Incident #1059475  Kara Pauga 02/10/10 
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912971')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912971')

--added per Jim 11/25/2009
update t1
set t1.htlstate = t2.code
from dba.hotel t1, dba.statecode t2
where t1.htlstate = t2.name
and len(t1.htlstate) > 2
and htlcountrycode in ('US')

update dba.hotel
set htlcountrycode = 'AU'
where htlstate ='New South Wales'
and htlcountrycode <>'AU'

update dba.hotel
set htlcountrycode = 'AU'
where htlstate ='Victoria'
and htlcityname ='Melbourne'
and htlcountrycode <>'AU'

update dba.hotel
set htlcountrycode = 'AU'
where htlstate ='Queensland'
and htlcityname ='Brisbane'
and htlcountrycode <>'AU'

update dba.hotel
set htlstate = CASE when htlstate ='Ontario' then 'ON'
when htlstate = 'Alberta' then 'AB'
when htlstate = 'British Columbia' then 'BC'
when htlstate = 'Quebec' then 'PQ'
when htlstate = 'Nova Scotia' then 'NV'
when htlstate = 'Saskatchewan' then 'SK'
when htlstate = 'Manitoba' then 'MB'
when htlstate = 'New Brunswick' then 'NB'
when htlstate = 'Northwest Territorie' then 'NW'
end
where len(htlstate) > 2
and htlcountrycode in ('CA')


----Added per 1058319
--update dba.invoicedetail
--set vendorname = 'NORTHWEST AIRLINES'
--where valcarriercode ='NW'
--and issuedate >= '2008-01-01'
--and vendorname <> 'NORTHWEST AIRLINES'

----Added per 1058319
--update dba.transeg
--set segmentcarriername = 'NORTHWEST AIRLINES'
--where segmentcarriercode ='NW'
--and issuedate >= '2008-01-01'
--and segmentcarriername <> 'NORTHWEST AIRLINES'

--Added per 1066422 on 3/15/11
update dba.invoicedetail
set vendorname = 'AMERICAN',
valcarriercode = 'AA',
valcarriernum = '001'
where valcarriercode ='9B'
and vendorname <> 'AMERICAN'


--Added per 1066422 on 3/15/11
update dba.transeg
set segmentcarriername = 'AMERICAN',
segmentcarriercode = 'AA',
NOXsegmentcarriername = 'AMERICAN',
NOXsegmentcarriercode = 'AA',
MINsegmentcarriername = 'AMERICAN',
MINsegmentcarriercode = 'AA'
where segmentcarriercode ='9B'
and segmentcarriername <> 'AMERICAN'
and typecode = 'A'


--Incident 1059902   Kara Pauga 03/03/10 
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912911')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 102 --incident 1062879 
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912911')
--and id.issuedate >='2010-07-01' --incident 1062879 

--incident 1060227 Kara Pauga

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912977')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912977')


--Incident #1060255
 

--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP591298')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP591298')

--Incident #1060312


--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-001327')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 120
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-001327')

-- Garda 
-- Incident #1060794
-- Kara Pauga 04/15/2010 
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5906000')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5906000')
--and id.issuedate>'2010-04-15'



--TSA Stores Inc
--Kara Pauga 05/10/2010
--Incident #1061185
--Incident #1062696 08/03/2010
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912983')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912983')
--and ud.issuedate >= '2010-08-02'

--Active Media Services Inc
--Kara Pauga 05/19/2010
--Incident #1061414
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912988')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912988')



--Bank of the West
--Kara Pauga 06/24/2010
--Incident 1061944
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912999')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912999')
 


--Avee Laboratories
--Kara Pauga 07/02/2010
--Incident 1062225
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913004')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913004')

--BreakAway-BancorpSouth
--Kara Pauga 07/02/2010
--Incident 1062226
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913005')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913005')



--Federal Reserve Bank DFW
--Kara Pauga 07/06/2010
--Incident 1062248
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-001338')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-001338')
--and id.issuedate >='2010-01-01'



--Marfood USA
--Kara Pauga 07/12/2010
--Incident 1062365
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913008')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913008')



--Creative Channel Service
--Kara Pauga 07/19/10
--Incident 1062483
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912998')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912998')

--DCPRO Powercom Inc
--Kara Pauga 08/05/10
--Incident 1062764 
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913014')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913014')

--IKON Office Solutions
--Kara Pauga 08/09/10
----Incident 1062809  
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912818')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912818')
--and id.issuedate >= '2010-04-20'

--Cooper Industries
--Kara Pauga 08/16/10
--Incident 1062824   
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912961')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912961')

--Cobham 
--Kara Pauga 09/08/10
----Incident 1063272   
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913011')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913011')

--Consolidated Resource Imaging
--Kara Pauga 09/21/10
--Incident 1063435   
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913016')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913016')

--Englobal Corporation
--Kara Pauga 10/04/10
--Incident 1063668   
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913018')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913018')

--Rope Partners
--Kara Pauga 10/04/10
----Incident 1063685   
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913019')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913019')
-------------------------------------
--    HNN Updates
-----------------------------------
UPDATE DBA.Hotel
SET HtlCityName = 'WASHINGTON' ,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and MasterId is null

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
set htlpostalcode = NULL
where LEN(HTLPOSTALCODE) < 5
and MasterId is null

UPDATE DBA.HOTEL
SET HTLSTATE = NULL
WHERE HTLCOUNTRYCODE NOT IN ('US','CA')
and MasterId is null

update dba.hotel
set htladdr1 = htladdr2
,htladdr2 = null
where htladdr1 is null
and htladdr2 is not null
and MasterId is null

update dba.hotel
set htladdr2 = null
where htladdr2 = htladdr1
and MasterId is null

update id
set id.servicedescription = ud.udefdata
from dba.invoicedetail id, dba.udef ud
where ud.udefnum = 143
and id.recordkey = ud.recordkey
and id.seqnum = ud.seqnum
and id.iatanum ='ORBITZ'
and ud.iatanum = 'ORBITZ'
and id.servicedescription is null


--Addison Prof
--Kara Pauga 10/13/10
--Incident 1063901  
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913023')

--Berkadia
--Kara Pauga 10/13/10
--Incident 1063937 
--Changed on 12/7/10 to look at UDID 101 per incident #1064752 
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913024')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913024')

----Kara Pauga 10/18/10
----Incident 1063713
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913020')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913020')

--Kara Pauga 11/1/10
--Incident 1064250
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913025')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913025')

----Kara Pauga 11/8/10
--Incident 1064327
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913026')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913026')

--Kara Pauga 11/17/10
--Incident 1064471
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913028')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913028')

--Kara Pauga 11/22/10
--Incident 1064533
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-000938')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-000938')

--Kara Pauga 11/30/10
--Incident 1064623
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912997')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912997')

--Kara Pauga 12/7/10
--Incident 1064753
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913012')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913012')

--Kara Pauga 3/1/11
--Incident 1066167
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913037','TPT-TP5913033','TPT-TP5913100')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913037','TPT-TP5913033','TPT-TP5913100')

--Kara Pauga 3/9/11
--Incident 1066346
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913036')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913036')

--Kara Pauga 3/23/11
--Incident 1066455
--changed on 5/11/12 per incident #107650....NL
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912979')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912979')

--Kara Pauga 4/5/11
--Incident 1066787
--Commented out per incident 1068085
--update id
--set id.department = ud100.udefdata+'-'+ud101.udefdata
--from dba.invoicedetail id, dba.udef ud100, dba.udef ud101
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912966')
--and id.recordkey = ud100.recordkey
--and id.recordkey = ud101.recordkey
--and ud100.recordkey = ud101.recordkey
--and ud100.udefnum = 100
--and ud101.udefnum = 101
--and ud100.iatanum ='ORBITZ'
--and ud101.iatanum ='ORBITZ'
--and ud100.clientcode  in ('TPT-TP5912966')
--and ud101.clientcode  in ('TPT-TP5912966')

--Kara Pauga 5/5/11
----Incident 1067249
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912880')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 102
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912880')

--Kara Pauga 5/5/11
----Incident 1067374
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913041')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913041')

--Kara Pauga 5/6/11
--Incident 1067384
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5912981')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5912981')


--Kara Pauga 8/3/11
-- Incident #1069265 

--update id
--set id.department = left(ud100.udefdata,40)
--from dba.invoicedetail id, dba.udef ud100
--where id.iatanum = ud100.iatanum
--and id.recordkey = ud100.recordkey
--and id.clientcode ='TPT-TP5913040'
--and id.iatanum  ='ORBITZ'
--and ud100.udefnum = 100

-----incident 1070422 9/20/2011
--update id
--set id.department =  left(ud100.udefdata,40)
--from dba.invoicedetail id, dba.udef ud100
--where id.iatanum = ud100.iatanum
--and id.recordkey = ud100.recordkey
--and id.clientcode ='TPT-TP5912966'
--and id.iatanum  ='ORBITZ'
--and ud100.udefnum = 100

--Kara Pauga 10/6/11
--Incident 1070681
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5306002')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5306002')

--Kara Pauga 10/26/11
--Incident 1071141
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913043')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913043')

--Kara Pauga 11/15/11
--Incident 1071618
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913079')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913079')

--Kara Pauga 12/5/11
--Incident 1071955
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913077')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913077')

--Kara Pauga 12/7/11
----Incident 1072042
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913061')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913061')

--Kara Pauga 12/28/11
--Incident 1072361
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913073')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913073')

--Kara Pauga 12/28/11
--Incident 1072360
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5002100')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5002100')

--Kara Pauga 1/26/12
--Incident 1073064
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913092')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913092')

--Kara Pauga 3/1/12
--Incident 1074185
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913087')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913087')

--Kara Pauga 3/20/12
--Incident 1074855
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913088')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 104
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913088')

--Kara Pauga 4/5/12
--Incident 1075444
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913076')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913076')

--Kara Pauga 5/11/12
--Incident 1076733
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913203')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913203')

--Kara Pauga 6/12/12
----Incident 1077663
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913201')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913201')

--Kara Pauga 7/13/12
--Incident 1078963
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913212')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913212')

--Kara Pauga 8/1/12
--Incident 1079383
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913205')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913205')

--Kara Pauga 8/1/12
--Incident 1079384
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913217')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913217')

--Kara Pauga 8/16/12
--Incident 1079658
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913220')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913220')

--Kara Pauga 8/16/12
--Incident 1079671
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913229')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913229')

--Kara Pauga 8/17/12
--Incident 1079711
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913224')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913224')

--Kara Pauga 8/17/12
--Incident 1079713
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913228')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913228')

--Kara Pauga 9/5/12
--Incident 1079810
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913237')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913237')

--Kara Pauga 9/19/12
--Incident 1079945 and Case 00004031
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913241')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913241')

---Kara Pauga 10/1/12
--Incident 1080050 and SF Case 00004445
--Audatex
--update id
--set id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode ='TPT-TP5913222'
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode ='TPT-TP5913222'

--Kara Pauga 11/19/12
--Incident 1079945 and Case 00006551
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913234')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913234')

--Kara Pauga 12/3/12
--Case 00007306 --AVX CORPORATION
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913231')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 101
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913231')

--Kara Pauga 1/17/13
--Case 00009224 --Capsugel
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913258')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913258')

--Kara Pauga 1/24/13
--Case 00009530 --OCLC
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('000957','TPT-000957')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('000957','TPT-000957')

--Kara Pauga 1/24/13
--Case 00009787 --Legg Mason
--update id
--set  id.department = left(ud.udefdata,40)
--from dba.invoicedetail id, dba.udef ud
--where id.iatanum ='ORBITZ'
--and id.clientcode  in ('TPT-TP5913257')
--and id.recordkey = ud.recordkey
--and ud.udefnum = 100
--and ud.iatanum ='ORBITZ'
--and ud.clientcode  in ('TPT-TP5913257')

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025','TPT-TP5913026','TPT-TP5913028','TPT-000938',
'TPT-TP5912997','TPT-TP5913012','TPT-TP5913037','TPT-TP5913033','TPT-TP5913100','TPT-TP5913036','TPT-TP5912979',
'TPT-TP5913040','TPT-TP5912966','TPT-TP5913043','TPT-TP5913079','TPT-TP5913061','TPT-TP5913073','TPT-TP5002100',
'TPT-TP5913092','TPT-TP5913087','TPT-TP5913076','TPT-TP5913203','TPT-TP5913201','TPT-TP5913212','TPT-TP5913205',
'TPT-TP5913217','TPT-TP5913220','TPT-TP5913229','TPT-TP5913224','TPT-TP5913228','TPT-TP5913237','TPT-TP5913241',
'TPT-TP5913222','TPT-TP5913234','TPT-TP5913258','000957','TPT-000957','TPT-TP5913257','001444','001438',
'TPT-T5921005')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025','TPT-TP5913026','TPT-TP5913028','TPT-000938',
'TPT-TP5912997','TPT-TP5913012','TPT-TP5913037','TPT-TP5913033','TPT-TP5913100','TPT-TP5913036','TPT-TP5912979',
'TPT-TP5913040','TPT-TP5912966','TPT-TP5913043','TPT-TP5913079','TPT-TP5913061','TPT-TP5913073','TPT-TP5002100',
'TPT-TP5913092','TPT-TP5913087','TPT-TP5913076','TPT-TP5913203','TPT-TP5913201','TPT-TP5913212','TPT-TP5913205',
'TPT-TP5913217','TPT-TP5913220','TPT-TP5913229','TPT-TP5913224','TPT-TP5913228','TPT-TP5913237','TPT-TP5913241',
'TPT-TP5913222','TPT-TP5913234','TPT-TP5913258','000957','TPT-000957','TPT-TP5913257','001444','001438',
'TPT-T5921005')

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5101100','TPT-TP5101500','001556','001043','TPT-TP5101700','TPT-TP5101500','TPT-TP5003900','TPT-TP5202000','TPT-TP5106000','TPT-TP5912957',
'TPT-TP5209000','TPT-TP5208000','TPT-TP5303000','TPT-TP5405000','TPT-TP5403000','TPT-TP5003300','TPT-TP5002600',
'TPT-TP5409000','TPT-TP5301000','TPT-TP5503000','TPT-TP5601000','TPT-TP5508000','TPT-TP5603000','TPT-TP5407000',
'TPT-TP5608000','TPT-TP5609000','TPT-TP5601000','TPT-TP5101900','TPT-TP5609000','TPT-TP5609001','TPT-TP5609002',
'TPT-TP5609003','TPT-TP5609004','TPT-TP5401000','TPT-TP5704000','TPT-TP5706000','TPT-TP5703000' , 'TPT-TP5703001',
'TPT-TP5709000','TPT-TP5803000','TPT-TP5804000','TPT-TP5800000','TPT-TP5801000','TPT-TP5101600','TPT-TP5003600',
'TPT-TP5003301','TPT-TP5911400','TPT-TP5911000','TPT-TP5910100','TPT-TP5910800','TPT-TP5910801','TPT-TP5910802',
'TPT-TP5910803','TPT-TP5910804','TPT-001043','TPT-001444','TPT-001556','TPT-TP5912863','TPT-TP5911500','TPT-TP5912974',
'TPT-TP5912700','TPT-TP5500000','TPT-TP5912912','TPT-TP5912910','TPT-001772','TPT-TP5912889','TPT-TP5912910',
'TPT-TP5912852','TPT-TP5912926','TPT-TP5912883','TPT-TP5912927','TPT-TP5911700','TPT-TP5912921','TPT-TP5912950',
'TPT-TP5912854','TPT-TP5912962','TPT-TP5912960','TPT-TP5912971','TPT-TP5912977','TPT-TP591298','TPT-TP5906000',
'TPT-TP5912983','TPT-TP5912988','TPT-TP5912999','TPT-TP5913004','TPT-TP5913005','TPT-TP5913008','TPT-TP5912998',
'TPT-TP5913014','TPT-TP5912818','TPT-TP5912961','TPT-TP5913011','TPT-TP5913016','TPT-TP5913018','TPT-TP5913019')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5101100','TPT-TP5101500','001556','001043','TPT-TP5101700','TPT-TP5101500','TPT-TP5003900','TPT-TP5202000','TPT-TP5106000','TPT-TP5912957',
'TPT-TP5209000','TPT-TP5208000','TPT-TP5303000','TPT-TP5405000','TPT-TP5403000','TPT-TP5003300','TPT-TP5002600',
'TPT-TP5409000','TPT-TP5301000','TPT-TP5503000','TPT-TP5601000','TPT-TP5508000','TPT-TP5603000','TPT-TP5407000',
'TPT-TP5608000','TPT-TP5609000','TPT-TP5601000','TPT-TP5101900','TPT-TP5609000','TPT-TP5609001','TPT-TP5609002',
'TPT-TP5609003','TPT-TP5609004','TPT-TP5401000','TPT-TP5704000','TPT-TP5706000','TPT-TP5703000' , 'TPT-TP5703001',
'TPT-TP5709000','TPT-TP5803000','TPT-TP5804000','TPT-TP5800000','TPT-TP5801000','TPT-TP5101600','TPT-TP5003600',
'TPT-TP5003301','TPT-TP5911400','TPT-TP5911000','TPT-TP5910100','TPT-TP5910800','TPT-TP5910801','TPT-TP5910802',
'TPT-TP5910803','TPT-TP5910804','TPT-001043','TPT-001444','TPT-001556','TPT-TP5912863','TPT-TP5911500','TPT-TP5912974',
'TPT-TP5912700','TPT-TP5500000','TPT-TP5912912','TPT-TP5912910','TPT-001772','TPT-TP5912889','TPT-TP5912910',
'TPT-TP5912852','TPT-TP5912926','TPT-TP5912883','TPT-TP5912927','TPT-TP5911700','TPT-TP5912921','TPT-TP5912950',
'TPT-TP5912854','TPT-TP5912962','TPT-TP5912960','TPT-TP5912971','TPT-TP5912977','TPT-TP591298','TPT-TP5906000',
'TPT-TP5912983','TPT-TP5912988','TPT-TP5912999','TPT-TP5913004','TPT-TP5913005','TPT-TP5913008','TPT-TP5912998',
'TPT-TP5913014','TPT-TP5912818','TPT-TP5912961','TPT-TP5913011','TPT-TP5913016','TPT-TP5913018','TPT-TP5913019')


update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913024','TPT-TP5913041','TPT-TP5912981','TPT-TP5306002','TPT-TP5913077','TPT-TP5913231',
'000325','TPT-TP4003400','TPT-TP5101400','TPT-TP4002004','TPT-TP5101600','000115','TPT-TP5106000','TPT-TP5200000',
'TPT-TP5003500','TPT-TP5003501','TPT-TP5306001','TPT-TP5306000','TPT-TP5910300','TPT-TP5002701','TPT-TP5002700',
'TPT-001438','TPT-TP5912946','TPT-TP5910500','TPT-TP5912939','TPT-TP5911100','TPT-001338')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913024','TPT-TP5913041','TPT-TP5912981','TPT-TP5306002','TPT-TP5913077','TPT-TP5913231',
'000325','TPT-TP4003400','TPT-TP5101400','TPT-TP4002004','TPT-TP5101600','000115','TPT-TP5106000','TPT-TP5200000',
'TPT-TP5003500','TPT-TP5003501','TPT-TP5306001','TPT-TP5306000','TPT-TP5910300','TPT-TP5002701','TPT-TP5002700',
'TPT-001438','TPT-TP5912946','TPT-TP5910500','TPT-TP5912939','TPT-TP5911100','TPT-001338')

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912880','TPT-TP5005000','TPT-TP5105000','TPT-TP5201000','TPT-TP5912821','TPT-TP5912822',
'TPT-TP5912936','TPT-TP5912911','TPT-TP5913208')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912880','TPT-TP5005000','TPT-TP5105000','TPT-TP5201000','TPT-TP5912821','TPT-TP5912822',
'TPT-TP5912936','TPT-TP5912911','TPT-TP5913208')


update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5900000','TP5912909','TPT-TP5912909','TPT-000173','TPT-TP5920001')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 103
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5900000','TP5912909','TPT-TP5912909','TPT-000173','TPT-TP5920001')

update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913088','000950','TPT-TP52004000','TPT-000867')
and id.recordkey = ud.recordkey
and id.Department is null
and ud.udefnum = 104
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913088','000950','TPT-TP52004000','TPT-000867')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-001327','TPT-TP5002702')
and id.recordkey = ud.recordkey
and ud.udefnum = 120
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-001327','TPT-TP5002702')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 124
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912925')
GO
