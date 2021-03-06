/****** Object:  StoredProcedure [dbo].[sp_OldORBITZ_Update_Old]    Script Date: 7/14/2015 8:13:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_OldORBITZ_Update_Old]
	
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
FROM dba.InvoiceDetail
WHERE iatanum in ('ORBITZ')
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('ORBITZ'))

DECLARE @importdt datetime
SET @importdt = (select max(importdt) from dba.invoiceheader)

update cr
set cr.issuedate = id.issuedate
from dba.invoiceheader ih, dba.invoicedetail id,dba.ComRmks cr
WHERE ih.RecordKey = id.RecordKey
AND ih.IataNum = id.IataNum
AND ih.ClientCode = id.ClientCode
AND ih.invoicedate = id.invoicedate
AND ih.importdt >= @importdt
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

--Quiznos
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='001444'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='001444'
--Tribune
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='001438'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='001438'
---Knight Rider
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='000325'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='000325'

---ACS
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5005000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5005000'
--bioMerieux
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5101100'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101100'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP4003400'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP4003400'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5101400'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101400'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP4002004'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP4002004'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5101500'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101500'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5101600'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101600' 	

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='001556'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='001556'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='001043'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='001043'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='000115'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='000115'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5101700'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101700'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5101500'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101500'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5003900'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5003900'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5106000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5106000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode in ('000950','TPT-TP52004000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 104
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('000950','TPT-TP52004000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5202000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5202000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5105000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5105000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5106000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5106000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5201000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5201000'


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5209000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5209000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5208000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5208000'

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

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5303000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5303000'


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5405000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5405000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5403000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5403000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5003300'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5003300'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5002600'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5002600'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5409000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5409000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5301000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5301000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5503000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5503000'


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode ='TPT-TP5601000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5601000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5508000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5508000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5603000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5603000'

update id
set id.department = substring(ud.udefdata,1,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5407000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5407000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5608000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5608000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5609000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5609000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5601000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5601000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode = 'TPT-TP5101900'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode ='TPT-TP5101900'


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5609000', 'TPT-TP5609001', 'TPT-TP5609002', 'TPT-TP5609003', 'TPT-TP5609004')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5609000', 'TPT-TP5609001', 'TPT-TP5609002', 'TPT-TP5609003', 'TPT-TP5609004')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  = 'TPT-TP5401000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  = 'TPT-TP5401000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  = 'TPT-TP5704000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  = 'TPT-TP5704000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  = 'TPT-TP5200000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  = 'TPT-TP5200000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  = 'TPT-TP5706000'
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  = 'TPT-TP5706000'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5703000' , 'TPT-TP5703001')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5703000' , 'TPT-TP5703001')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5709000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5709000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5803000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5803000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5804000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5804000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5800000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5800000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5801000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5801000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5900000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 103
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5900000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5101600')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5101600')
and id.issuedate > '2007-09-25'

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5003500','TPT-TP5003501')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5003500','TPT-TP5003501')



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


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5306000','TPT-TP5306001')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5306000','TPT-TP5306001')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5003600')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5003600')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5003301')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5003301')

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
and ih.importdt = (select max(importdt) from dba.invoiceheader)
and ih.iatanum = 'ORBITZ'
and id.iatanum = 'ORBITZ'
and ts.iatanum = 'ORBITZ'


update id
set id.valcarriernum = cr.carriernum
from  DBA.INVOICEDETAIL id, dba.carrier cr
WHEre id.IATANUM='ORBITZ' 
AND id.VENDORTYPE IN ('BSP','NONBSP') 
AND id.VOIDIND='N'   
and id.ValCarrierNum IS NULL
and cr.carriercode = id.valcarriercode

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5910300')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5910300')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5911400')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5911400')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5911000')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5911000')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5910100')
and id.recordkey = ud.recordkey
---and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5910100')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5910800','TPT-TP5910801','TPT-TP5910802','TPT-TP5910803','TPT-TP5910804')
and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5910800','TPT-TP5910801','TPT-TP5910802','TPT-TP5910803','TPT-TP5910804')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5002701','TPT-TP5002700')
and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5002701','TPT-TP5002700')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-001043','TPT-001444','TPT-001556')
and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-001043','TPT-001444','TPT-001556')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-001438')
and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-001438')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912863')
and id.recordkey = ud.recordkey
-----and id.seqnum = ud.seqnum
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912863')


--Added per Kara incident #1049753
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5911500')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5911500')


--Added per Kara incident 1048894
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

update dba.invoicedetail
set farecompare2 = null,
reasoncode1 = null
from dba.invoicedetail
where iatanum ='ORBITZ'
and onlinebookingsystem is null
and vendortype in ('BSP','NONBSP')
and issuedate >'2007-12-31'
and farecompare2 is not null

update dba.invoicedetail
set farecompare2 = null,
reasoncode1 = null
from dba.invoicedetail
where iatanum ='ORBITZ'
and onlinebookingsystem is null
and vendortype in ('BSP','NONBSP')
and issuedate >'2007-12-31'
and reasoncode1 is not null

--Added per Kara incident #1050028
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912700')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912700')

--Added per Kara incident #1050286
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5500000')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5500000')

--Incident Number: 1051044
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912912')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912912')


--Incident Number: 1051257
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in('TP5912909','TPT-TP5912909')
and id.recordkey = ud.recordkey
and ud.udefnum = 103
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TP5912909','TPT-TP5912909')

--Incident Number: 1051570
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912910')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912910')

--Incident Number: 1051571
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-001772')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-001772')

--Incident Number: 1052131
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912889')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912889')

--Incident Number: 1051570
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912910')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912910')

--Incident Number: 1052432
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912852')
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912852')

--Incident Number: 1052341
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912821','TPT-TP5912822')

--Incident Number: 1052720
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912926')

--incident number 1053157
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912883')

--incident number 1053491
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912927')

--incident 1053674
update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and ud.udefnum = 100
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5911700')



INSERT INTO DBA.Budgets
select IataNum,ClientCode,NULL,NULL,'2008-01-01','2008-12-31',0,0,0,0,'USD' from dba.client
where iatanum+clientcode not in (select distinct iatanum+clientcode from dba.budgets)

GO
