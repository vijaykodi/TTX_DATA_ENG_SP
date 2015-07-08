/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_ORBITZ']/UnresolvedEntity[@Name='SP_ORBITZ_CO2_MAIN' and @Schema='dbo'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ATL892']/Database[@Name='TMAN503_MC_TMC']/UnresolvedEntity[@Name='sp_MCTMC_postImport_MCORUS' and @Schema='dbo'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_ORBITZWKLY_Update]    Script Date: 7/7/2015 11:22:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ORBITZWKLY_Update]
	
AS

--Update currcode
update dba.invoicedetail
set currcode = 'USD'
where totalamt is null
and currcode <> 'USD'
and iatanum = 'ORBITZ'

--Update client code to lowercase value for 1 client in all data as orbitz is sending in upper and lower and
--it is impacting their outbound feed to Prime Analytics/TravelGPA  TPT-tp5920021 and TPT-TP5920021 per Allen rqst
--KP 9/2/2014

--SET @TransStart = getdate()
update dba.client
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.invoiceheader
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.invoicedetail
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.transeg
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.car
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.hotel
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.udef
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.comrmks
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.payment
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

update dba.tax
set clientcode='TPT-tp5920021'
where IataNum='ORBITZ'
and ClientCode = ('TPT-tp5920021')

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Clientcode update for TPT-TP590021',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---create UDEF records for refund pnrs - Orbitz does not send UDEF in their wkly file so there is no
--fields to create the needed comrmks from #36970 5/16/2014

insert into dba.udef
(RecordKey,IataNum,SeqNum,ClientCode,InvoiceDate,IssueDate,UdefNum,UdefType,UdefData)
select distinct
RecordKey+'-R',IataNum,SeqNum,ClientCode,InvoiceDate,IssueDate,UdefNum,UdefType,UdefData 
from dba.udef 
where iatanum='orbitz' 
and issuedate>='2013-01-01'
and RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) 
in (select SUBSTRING(recordkey,1,24)+IataNum+CONVERT(VARCHAR,SeqNum)
 from dba.Invoicedetail where 
RecordKey like '%-R' and IssueDate>='2013-01-01' and iatanum='orbitz' )
AND RecordKey+'-r'+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.udef
WHERE iatanum in ('ORBITZ')
and issuedate>='2013-01-01')



--Populate Common Remarks for 25 trip reference fields--added 9/28/2007
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT id.RecordKey, id.IataNum, id.SeqNum, id.ClientCode, id.InvoiceDate, id.IssueDate
FROM dba.InvoiceDetail id, dba.invoiceheader ih
WHERE id.iatanum in ('ORBITZ')
and id.recordkey = ih.recordkey 
and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate
and id.ClientCode = ih.ClientCode
and id.issuedate>='2013-01-01'
--and ih.importdt > getdate()-1
AND not exists (select 1,3
				FROM dba.ComRmks cr
				WHERE cr.iatanum in ('ORBITZ')
				and cr.recordkey = id.recordkey
				and cr.iatanum = id.iatanum
				and cr.seqnum = id.seqnum
				and id.issuedate>='2013-01-01')

update cr
set cr.issuedate = id.issuedate
from dba.invoiceheader ih, dba.invoicedetail id,dba.ComRmks cr
WHERE ih.RecordKey = id.RecordKey
AND ih.IataNum = id.IataNum
AND ih.ClientCode = id.ClientCode
AND ih.invoicedate = id.invoicedate
AND ih.importdt >= getdate()-1
AND cr.RecordKey = id.RecordKey
AND cr.IataNum = id.IataNum
AND cr.ClientCode = id.ClientCode
AND cr.issuedate <> id.issuedate
--AND cr.seqnum = id.seqnum
and id.IssueDate>='2013-01-01'
and cr.IssueDate>='2013-01-01'
and cr.iatanum ='ORBITZ'

update cr
set cr.text1 = substring(ud100.udefdata,1,150)
from dba.comrmks cr, dba.udef ud100
where cr.iatanum = ud100.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud100.recordkey
--and cr.seqnum = ud100.seqnum
and ud100.udefnum = 100
and cr.text1 is null
and ud100.udefdata is not null
--and cr.issuedate = ud100.issuedate
and cr.IssueDate>='2013-01-01'
and ud100.IssueDate>='2013-01-01'


update cr
set cr.text2 = substring(ud101.udefdata,1,150)
from dba.comrmks cr, dba.udef ud101
where cr.iatanum = ud101.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud101.recordkey
--and cr.seqnum = ud101.seqnum
and ud101.udefnum = 101
and cr.text2 is null
and ud101.udefdata is not null
--and cr.issuedate = ud101.issuedate
and cr.IssueDate>='2013-01-01'
and ud101.IssueDate>='2013-01-01'


update cr
set cr.text3 = substring(ud102.udefdata,1,150)
from dba.comrmks cr, dba.udef ud102
where cr.iatanum = ud102.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud102.recordkey
--and cr.seqnum = ud102.seqnum
and ud102.udefnum = 102
and cr.text3 is null
and ud102.udefdata is not null
--and cr.issuedate = ud102.issuedate
and cr.IssueDate>='2013-01-01'
and ud102.IssueDate>='2013-01-01'


update cr
set cr.text4 = substring(ud103.udefdata,1,150)
from dba.comrmks cr, dba.udef ud103
where cr.iatanum = ud103.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud103.recordkey
--and cr.seqnum = ud103.seqnum
and ud103.udefnum = 103
and cr.text4 is null
and ud103.udefdata is not null
--and cr.issuedate = ud103.issuedate
and cr.IssueDate>='2013-01-01'
and ud103.IssueDate>='2013-01-01'

update cr
set cr.text5 = substring(ud104.udefdata,1,150)
from dba.comrmks cr, dba.udef ud104
where cr.iatanum = ud104.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud104.recordkey
--and cr.seqnum = ud104.seqnum
and ud104.udefnum = 104
and cr.text5 is null
and ud104.udefdata is not null
--and cr.issuedate = ud104.issuedate
and cr.IssueDate>='2013-01-01'
and ud104.IssueDate>='2013-01-01'


update cr
set cr.text6 = substring(ud120.udefdata,1,150)
from dba.comrmks cr, dba.udef ud120
where cr.iatanum = ud120.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud120.recordkey
--and cr.seqnum = ud120.seqnum
and ud120.udefnum = 120
and cr.text6 is null
and ud120.udefdata is not null
--and cr.issuedate = ud120.issuedate
and cr.IssueDate>='2013-01-01'
and ud120.IssueDate>='2013-01-01'


update cr
set cr.text7 = substring(ud121.udefdata,1,150)
from dba.comrmks cr, dba.udef ud121
where cr.iatanum = ud121.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud121.recordkey
--and cr.seqnum = ud121.seqnum
and ud121.udefnum = 121
and cr.text7 is null
and ud121.udefdata is not null
--and cr.issuedate = ud121.issuedate
and cr.IssueDate>='2013-01-01'
and ud121.IssueDate>='2013-01-01'

update cr
set cr.text8 = substring(ud122.udefdata,1,150)
from dba.comrmks cr, dba.udef ud122
where cr.iatanum = ud122.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud122.recordkey
--and cr.seqnum = ud122.seqnum
and ud122.udefnum = 122
and cr.text8 is null
and ud122.udefdata is not null
and cr.IssueDate>='2013-01-01'
and ud122.IssueDate>='2013-01-01'


update cr
set cr.text9 = substring(ud123.udefdata,1,150)
from dba.comrmks cr, dba.udef ud123
where cr.iatanum = ud123.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud123.recordkey
--and cr.seqnum = ud123.seqnum
and ud123.udefnum = 123
and cr.text9 is null
and ud123.udefdata is not null
--and cr.issuedate = ud123.issuedate
and cr.IssueDate>='2013-01-01'
and ud123.IssueDate>='2013-01-01'



update cr
set cr.text10 = substring(ud124.udefdata,1,150)
from dba.comrmks cr, dba.udef ud124
where cr.iatanum = ud124.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud124.recordkey
--and cr.seqnum = ud124.seqnum
and ud124.udefnum = 124
and cr.text10 is null
and ud124.udefdata is not null
--and cr.issuedate = ud124.issuedate
and cr.IssueDate>='2013-01-01'
and ud124.IssueDate>='2013-01-01'


update cr
set cr.text11 = substring(ud125.udefdata,1,150)
from dba.comrmks cr, dba.udef ud125
where cr.iatanum = ud125.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud125.recordkey
--and cr.seqnum = ud125.seqnum
and ud125.udefnum = 125
and cr.text11 is null
and ud125.udefdata is not null
--and cr.issuedate = ud125.issuedate
and cr.IssueDate>='2013-01-01'
and ud125.IssueDate>='2013-01-01'


update cr
set cr.text12 = substring(ud126.udefdata,1,150)
from dba.comrmks cr, dba.udef ud126
where cr.iatanum = ud126.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud126.recordkey
--and cr.seqnum = ud126.seqnum
and ud126.udefnum = 126
and cr.text12 is null
and ud126.udefdata is not null
--and cr.issuedate = ud126.issuedate
and cr.IssueDate>='2013-01-01'
and ud126.IssueDate>='2013-01-01'


update cr
set cr.text13 = substring(ud127.udefdata,1,150)
from dba.comrmks cr, dba.udef ud127
where cr.iatanum = ud127.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud127.recordkey
--and cr.seqnum = ud127.seqnum
and ud127.udefnum = 127
and cr.text13 is null
and ud127.udefdata is not null
--and cr.issuedate = ud127.issuedate
and cr.IssueDate>='2013-01-01'
and ud127.IssueDate>='2013-01-01'


update cr
set cr.text14 = substring(ud128.udefdata,1,150)
from dba.comrmks cr, dba.udef ud128
where cr.iatanum = ud128.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud128.recordkey
--and cr.seqnum = ud128.seqnum
and ud128.udefnum = 128
and cr.text14 is null
and ud128.udefdata is not null
--and cr.issuedate = ud128.issuedate
and cr.IssueDate>='2013-01-01'
and ud128.IssueDate>='2013-01-01'


update cr
set cr.text15 = substring(ud129.udefdata,1,150)
from dba.comrmks cr, dba.udef ud129
where cr.iatanum = ud129.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud129.recordkey
--and cr.seqnum = ud129.seqnum
and ud129.udefnum = 129
and cr.text15 is null
and ud129.udefdata is not null
--and cr.issuedate = ud129.issuedate
and cr.IssueDate>='2013-01-01'
and ud129.IssueDate>='2013-01-01'


update cr
set cr.text16 = substring(ud130.udefdata,1,150)
from dba.comrmks cr, dba.udef ud130
where cr.iatanum = ud130.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud130.recordkey
--and cr.seqnum = ud130.seqnum
and ud130.udefnum = 130
and cr.text16 is null
and ud130.udefdata is not null
--and cr.issuedate = ud130.issuedate
and cr.IssueDate>='2013-01-01'
and ud130.IssueDate>='2013-01-01'


update cr
set cr.text17 = substring(ud131.udefdata,1,150)
from dba.comrmks cr, dba.udef ud131
where cr.iatanum = ud131.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud131.recordkey
--and cr.seqnum = ud131.seqnum
and ud131.udefnum = 131
and cr.text17 is null
and ud131.udefdata is not null
--and cr.issuedate = ud131.issuedate
and cr.IssueDate>='2013-01-01'
and ud131.IssueDate>='2013-01-01'



update cr
set cr.text18 = substring(ud132.udefdata,1,150)
from dba.comrmks cr, dba.udef ud132
where cr.iatanum = ud132.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud132.recordkey
--and cr.seqnum = ud132.seqnum
and ud132.udefnum = 132
and cr.text18 is null
and ud132.udefdata is not null
--and cr.issuedate = ud132.issuedate
and cr.IssueDate>='2013-01-01'
and ud132.IssueDate>='2013-01-01'

update cr
set cr.text19 = substring(ud133.udefdata,1,150)
from dba.comrmks cr, dba.udef ud133
where cr.iatanum = ud133.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud133.recordkey
--and cr.seqnum = ud133.seqnum
and ud133.udefnum = 133
and cr.text19 is null
and ud133.udefdata is not null
--and cr.issuedate = ud133.issuedate
and cr.IssueDate>='2013-01-01'
and ud133.IssueDate>='2013-01-01'


update cr
set cr.text20 = substring(ud134.udefdata,1,150)
from dba.comrmks cr, dba.udef ud134
where cr.iatanum = ud134.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud134.recordkey
--and cr.seqnum = ud134.seqnum
and ud134.udefnum = 134
and cr.text20 is null
and ud134.udefdata is not null
--and cr.issuedate = ud134.issuedate
and cr.IssueDate>='2013-01-01'
and ud134.IssueDate>='2013-01-01'


update cr
set cr.text21 = substring(ud135.udefdata,1,150)
from dba.comrmks cr, dba.udef ud135
where cr.iatanum = ud135.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud135.recordkey
--and cr.seqnum = ud135.seqnum
and ud135.udefnum = 135
and cr.text21 is null
and ud135.udefdata is not null
--and cr.issuedate = ud135.issuedate
and cr.IssueDate>='2013-01-01'
and ud135.IssueDate>='2013-01-01'


update cr
set cr.text22 = substring(ud136.udefdata,1,150)
from dba.comrmks cr, dba.udef ud136
where cr.iatanum = ud136.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud136.recordkey
--and cr.seqnum = ud136.seqnum
and ud136.udefnum = 136
and cr.text22 is null
and ud136.udefdata is not null
--and cr.issuedate = ud136.issuedate
and cr.IssueDate>='2013-01-01'
and ud136.IssueDate>='2013-01-01'


update cr
set cr.text23 = substring(ud137.udefdata,1,150)
from dba.comrmks cr, dba.udef ud137
where cr.iatanum = ud137.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud137.recordkey
--and cr.seqnum = ud137.seqnum
and ud137.udefnum = 137
and cr.text23 is null
and ud137.udefdata is not null
--and cr.issuedate = ud137.issuedate
and cr.IssueDate>='2013-01-01'
and ud137.IssueDate>='2013-01-01'


update cr
set cr.text24 = substring(ud138.udefdata,1,150)
from dba.comrmks cr, dba.udef ud138
where cr.iatanum = ud138.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud138.recordkey
--and cr.seqnum = ud138.seqnum
and ud138.udefnum = 138
and cr.text24 is null
and ud138.udefdata is not null
--and cr.issuedate = ud138.issuedate
and cr.IssueDate>='2013-01-01'
and ud138.IssueDate>='2013-01-01'


update cr
set cr.text25 = substring(ud139.udefdata,1,150)
from dba.comrmks cr, dba.udef ud139
where cr.iatanum = ud139.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud139.recordkey
--and cr.seqnum = ud139.seqnum
and ud139.udefnum = 139
and cr.text25 is null
and ud139.udefdata is not null
--and cr.issuedate = ud139.issuedate
and cr.IssueDate>='2013-01-01'
and ud139.IssueDate>='2013-01-01'
-------------------------------------------------- Incident #1056633 2009-12-10
update cr
set cr.text26 = substring(ud140.udefdata,1,150)
from dba.comrmks cr, dba.udef ud140
where cr.iatanum = ud140.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud140.recordkey
and ud140.udefnum = 140
and cr.text26 is null
and ud140.udefdata is not null
--and cr.issuedate = ud140.issuedate
and cr.IssueDate>='2013-01-01'
and ud140.IssueDate>='2013-01-01'


update cr
set cr.text27 = substring(ud141.udefdata,1,150)
from dba.comrmks cr, dba.udef ud141
where cr.iatanum = ud141.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud141.recordkey
and ud141.udefnum = 141
and cr.text27 is null
and ud141.udefdata is not null
--and cr.issuedate = ud141.issuedate
and cr.IssueDate>='2013-01-01'
and ud141.IssueDate>='2013-01-01'


update cr
set cr.text28 = substring(ud142.udefdata,1,150)
from dba.comrmks cr, dba.udef ud142
where cr.iatanum = ud142.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud142.recordkey
and ud142.udefnum = 142
and cr.text28 is null
and ud142.udefdata is not null
--and cr.issuedate = ud142.issuedate
and cr.IssueDate>='2013-01-01'
and ud142.IssueDate>='2013-01-01'

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
--and cr.issuedate = ud144.issuedate
and cr.IssueDate>='2013-01-01'
and ud144.IssueDate>='2013-01-01'
-------------------------------------------------------------------------------
update cr
set cr.text50 = substring(ud110.udefdata,1,150)
from dba.comrmks cr, dba.udef ud110
where cr.iatanum = ud110.iatanum
and cr.iatanum ='ORBITZ'
and cr.recordkey = ud110.recordkey
--and cr.seqnum = ud110.seqnum
and ud110.udefnum = 110
and cr.text50 is null
and ud110.udefdata is not null
--and cr.issuedate = ud110.issuedate
and cr.IssueDate>='2013-01-01'
and ud110.IssueDate>='2013-01-01'

-- added 12/10/2008
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
--and cr.invoicedate = ud114.invoicedate
and cr.IssueDate>='2013-01-01'
and ud114.IssueDate>='2013-01-01'


---Who booked it to id.servicedescription
update id
set id.servicedescription = ud.udefdata
from dba.invoicedetail id, dba.udef ud
where ud.udefnum = 143
and id.recordkey = ud.recordkey
--and id.seqnum = ud.seqnum
and id.iatanum ='ORBITZ'
and ud.iatanum = 'ORBITZ'
and id.servicedescription is null
and ud.IssueDate>='2013-01-01'
and id.IssueDate>='2013-01-01'

--Udef mapping to ID.Department
--update for ACS - no longer a client after 2009
--INSERT DBA.Udef
--(RecordKey
--, IataNum
--, SeqNum
--, ClientCode
--, InvoiceDate
--, IssueDate
--, UdefNum
--, UdefType
--, UdefData
--)
--SELECT distinct ID.RecordKey
--, ID.IataNum
--, ID.SeqNum
--, ID.ClientCode
--, ID.InvoiceDate
--, ID.IssueDate
--, 100
--, null
--, 'CORP'
--FROM DBA.invoicedetail ID, dba.udef ud
--WHERE ID.clientcode = 'TPT-TP5005000'

--AND id.recordkey+CAST(ID.seqnum AS VARCHAR) NOT IN (
--              SELECT  ud.recordkey+cast(UD.seqnum AS VARCHAR)
--                 FROM dba.udef ud
--                 where udefnum = 100
--                 and ud.clientcode = 'TPT-TP5005000')



update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025','TPT-TP5913026','TPT-TP5913028','TPT-000938',
'TPT-TP5912997','TPT-TP5913012','TPT-TP5913037','TPT-TP5913033','TPT-TP5913100','TPT-TP5913036','TPT-TP5912979',
'TPT-TP5913040','TPT-TP5912966','TPT-TP5913043','TPT-TP5913079','TPT-TP5913061','TPT-TP5913073','TPT-TP5002100',
'TPT-TP5913092','TPT-TP5913087','TPT-TP5913076','TPT-TP5913203','TPT-TP5913201','TPT-TP5913212','TPT-TP5913205',
'TPT-TP5913217','TPT-TP5913220','TPT-TP5913229','TPT-TP5913224','TPT-TP5913228','TPT-TP5913237','TPT-TP5913241',
'TPT-TP5913222','TPT-TP5913234','TPT-TP5913258','000957','TPT-000957','TPT-TP5913257','001444','001438','TPT-TP5913047','TPT-TP5913284',
'TPT-TP5913286','TPT-TP5913207','TPT-TP5604000','TPT-TP5920006','TPT-TP5921006','TPT-TP5921008',
'TPT-TP5912907','TPT-TP5912959','TPT-TP5920015','TPT-TP5913271','TPT-TP5913072','TPT-TP5920029','TPT-TP521009','TPT-TP5921007',
'TPT-TP5920022','TPT-TP5921010','TPT-TP5003801','TPT-TP5003800','TPT-TP5920041','TPT-TP5920040','TPT-TP5302000','TPT-TP5402000',
'TPT-000325','000325','TPT-TP000115','000115','TPT-TP5913159','TPT-TP5907000','TPT-TP5912976','TPT-TP5913275','TPT-TP5913031','TPT-TP5920038',
'TPT-TP5920053','TPT-TP5920049','TPT-TP5920050','TPT-TP5920048','TPT-TP5920055')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and ud.udefnum = 100
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913023','TPT-TP5913020','TPT-TP5913025','TPT-TP5913026','TPT-TP5913028','TPT-000938',
'TPT-TP5912997','TPT-TP5913012','TPT-TP5913037','TPT-TP5913033','TPT-TP5913100','TPT-TP5913036','TPT-TP5912979',
'TPT-TP5913040','TPT-TP5912966','TPT-TP5913043','TPT-TP5913079','TPT-TP5913061','TPT-TP5913073','TPT-TP5002100',
'TPT-TP5913092','TPT-TP5913087','TPT-TP5913076','TPT-TP5913203','TPT-TP5913201','TPT-TP5913212','TPT-TP5913205',
'TPT-TP5913217','TPT-TP5913220','TPT-TP5913229','TPT-TP5913224','TPT-TP5913228','TPT-TP5913237','TPT-TP5913241',
'TPT-TP5913222','TPT-TP5913234','TPT-TP5913258','000957','TPT-000957','TPT-TP5913257','001444','001438','TPT-TP5913047','TPT-TP5913284',
'TPT-TP5913286','TPT-TP5913207','TPT-TP5604000','TPT-TP5920006','TPT-TP5921006','TPT-TP5921008',
'TPT-TP5912907','TPT-TP5912959','TPT-TP5920015','TPT-TP5913271','TPT-TP5913072','TPT-TP5920029','TPT-TP521009','TPT-TP5921007',
'TPT-TP5920022','TPT-TP5921010','TPT-TP5003801','TPT-TP5003800','TPT-TP5920041','TPT-TP5920040','TPT-TP5302000','TPT-TP5402000',
'TPT-000325','000325','TPT-TP000115','000115','TPT-TP5913159','TPT-TP5907000','TPT-TP5912976','TPT-TP5913275','TPT-TP5913031','TPT-TP5920038',
'TPT-TP5920053','TPT-TP5920049','TPT-TP5920050','TPT-TP5920048','TPT-TP5920055')


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
'TPT-TP5913014','TPT-TP5912818','TPT-TP5912961','TPT-TP5913011','TPT-TP5913016','TPT-TP5913018','TPT-TP5913019',
'TPT-TP5921005')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
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
'TPT-TP5913014','TPT-TP5912818','TPT-TP5912961','TPT-TP5913011','TPT-TP5913016','TPT-TP5913018','TPT-TP5913019',
'TPT-TP5921005')


update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913024','TPT-TP5913041','TPT-TP5912981','TPT-TP5306002','TPT-TP5913077','TPT-TP5913231',
'TPT-TP4003400','TPT-TP5101400','TPT-TP4002004','TPT-TP5101600','TPT-TP5106000','TPT-TP5200000',
'TPT-TP5003500','TPT-TP5003501','TPT-TP5306000','TPT-TP5910300','TPT-TP5002701','TPT-TP5002700',
'TPT-001438','TPT-TP5912946','TPT-TP5910500','TPT-TP5912939','TPT-TP5911100','TPT-001338','TPT-TP5913086','TPT-TP5920008',
'TPT-TP5920018','TPT-TP5920007','TPT-0000217716', 'TPT-217716','TPT-TP5913291','TPT-TP5920026','TPT-TP5921009')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and id.Department is null
and ud.udefnum = 101
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913024','TPT-TP5913041','TPT-TP5912981','TPT-TP5306002','TPT-TP5913077','TPT-TP5913231',
'TPT-TP4003400','TPT-TP5101400','TPT-TP4002004','TPT-TP5101600','TPT-TP5106000','TPT-TP5200000',
'TPT-TP5003500','TPT-TP5003501','TPT-TP5306000','TPT-TP5910300','TPT-TP5002701','TPT-TP5002700',
'TPT-001438','TPT-TP5912946','TPT-TP5910500','TPT-TP5912939','TPT-TP5911100','TPT-001338','TPT-TP5913086','TPT-TP5920008',
'TPT-TP5920018','TPT-TP5920007','TPT-0000217716', 'TPT-217716','TPT-TP5913291','TPT-TP5920026','TPT-TP5921009')


update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5912880','TPT-TP5005000','TPT-TP5105000','TPT-TP5201000','TPT-TP5912821','TPT-TP5912822',
'TPT-TP5912936','TPT-TP5912911','TPT-TP5913208','TPT-TP5913278','TPT-TP5920030','TPT-TP5920031','TPT-TP5920032','TPT-TP5920033','TPT-TP5920034','TPT-TP5920035','TPT-TP5920036','TPT-TP5920037')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and id.Department is null
and ud.udefnum = 102
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5912880','TPT-TP5005000','TPT-TP5105000','TPT-TP5201000','TPT-TP5912821','TPT-TP5912822',
'TPT-TP5912936','TPT-TP5912911','TPT-TP5913208','TPT-TP5913278','TPT-TP5920030','TPT-TP5920031','TPT-TP5920032','TPT-TP5920033','TPT-TP5920034','TPT-TP5920035','TPT-TP5920036','TPT-TP5920037')



update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5900000','TP5912909','TPT-TP5912909','TPT-000173','TPT-TP5920001','TPT-TP5920042')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and id.Department is null
and ud.udefnum = 103
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5900000','TP5912909','TPT-TP5912909','TPT-000173','TPT-TP5920001','TPT-TP5920042')


update id
set  id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5913088','000950','TPT-TP52004000','TPT-000867')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and id.Department is null
and ud.udefnum = 104
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5913088','000950','TPT-TP52004000','TPT-000867')

update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-TP5306001')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
----and id.seqnum = ud.seqnum
and ud.udefnum = 105
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-TP5306001')


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.clientcode  in ('TPT-001327','TPT-TP5002702')
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and ud.udefnum = 120
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode  in ('TPT-001327','TPT-TP5002702')


update id
set id.department = left(ud.udefdata,40)
from dba.invoicedetail id, dba.udef ud
where id.iatanum ='ORBITZ'
and id.recordkey = ud.recordkey
and id.ClientCode=ud.ClientCode
and id.SeqNum=ud.seqnum
and id.IssueDate>='2013-01-01'
and ud.IssueDate>='2013-01-01'
and ud.udefnum = 124
and id.Department is null
and ud.iatanum ='ORBITZ'
and ud.clientcode in ('TPT-TP5912925')

----Update CommonRemarks for Refunds with values from orig booking

update crr
set crr.text1=cro.text1,
crr.Text2=cro.Text2,
crr.Text3=cro.Text3,
crr.Text4=cro.Text4,
crr.Text5=cro.Text5,
crr.Text6=cro.Text6,
crr.Text7=cro.Text7,
crr.Text8=cro.Text8,
crr.Text9=cro.Text9,
crr.Text10=cro.Text10,
crr.Text11=cro.Text11,
crr.Text12=cro.Text12,
crr.Text13=cro.Text13,
crr.Text14=cro.Text14,
crr.Text15=cro.Text15,
crr.Text16=cro.Text16,
crr.Text17=cro.Text17,
crr.Text18=cro.Text18,
crr.Text19=cro.Text19,
crr.Text20=cro.Text20,
crr.Text21=cro.Text21,
crr.Text22=cro.Text22,
crr.Text23=cro.Text23,
crr.Text24=cro.Text24,
crr.Text25=cro.Text25,
crr.Text26=cro.Text26,
crr.Text27=cro.Text27,
crr.Text28=cro.Text28,
crr.Text29=cro.Text29,
crr.Text49=cro.Text49,
crr.Text50=cro.Text50
from dba.ComRmks crr,
dba.ComRmks cro
where 
SUBSTRING(crr.recordkey,1,24)=cro.RecordKey
and crr.IataNum=cro.IataNum
and crr.SeqNum=cro.SeqNum
and crr.ClientCode=cro.ClientCode
and crr.IataNum='ORBITZ'
and crr.recordkey like '%-R'
and crr.IssueDate>='2013-01-01'
and cro.IssueDate>='2013-01-01'

---Who booked it to id.servicedescription and primary cc to id.department for refunds
update idr
set idr.servicedescription = ido.servicedescription,
idr.Department=ido.department
from dba.invoicedetail idr,
dba.InvoiceDetail ido 

where 
SUBSTRING(idr.recordkey,1,24)=ido.RecordKey
and idr.IataNum=ido.IataNum
and idr.SeqNum=ido.SeqNum
and idr.ClientCode=ido.ClientCode
and idr.IataNum='ORBITZ'
and idr.recordkey like '%-R'
and idr.servicedescription is null
and idr.IssueDate>='2013-01-01'
and ido.IssueDate>='2013-01-01'


---hotel updates
update dba.hotel
set htlchainname = 'Radisson'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='RAD'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Sutton Place'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000063'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Conrad'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000053'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Four Points'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='FP'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Sofitel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='VS'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Country Inn and Suites'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='CHI'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Amerihost'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='MQ'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Lexington'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LP'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Pan Pacific'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='PP'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Park Inn'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='PII'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Hotel Providence'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='000194'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Sahara'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LDC'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Walt Disney World'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='WDW'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Wrens House'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='HO'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Novitel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='XN'
and issuedate>='2014-01-01'

update dba.hotel
set htlchainname = 'Palace Hotel'
from dba.hotel
where iatanum = 'ORBITZ'
and htlchainname is null
and htlchaincode ='LC'
and issuedate>='2014-01-01'

--Added per 1066422 on 3/15/11
update dba.invoicedetail
set vendorname = 'AMERICAN',
valcarriercode = 'AA',
valcarriernum = '001'
where valcarriercode ='9B'
and vendorname <> 'AMERICAN'
and issuedate>='2014-01-01'


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
and issuedate>='2014-01-01'
--added by Jim to fix NULL VendorNumber

update t1
set vendornumber = valcarriernum
from dba.invoicedetail t1
where t1.IATANUM='ORBITZ'
AND t1.VENDORTYPE IN ('BSP','NONBSP') 
AND t1.VOIDIND='N' 
AND t1.VENDORNUMBER IS NULL
and t1.issuedate>='2013-01-01'

-- added by Jim to fix NULL ValCarrierCode and VendorName for TT Standard reports

UPDATE ID
SET ID.VendorName = C.CARRIERNAME
FROM DBA.InvoiceDetail ID, DBA.Carriers C
WHERE ID.ValCarrierCode = C.CarrierCode
AND ((ID.VendorName <> C.CarrierName) OR (ID.VendorName IS NULL))
AND C.TYPECODE = 'A' AND C.Status = 'A'
and ID.VendorType in ('bsp','nonbsp')
and id.iatanum = 'ORBITZ'
and id.issuedate>='2013-01-01'

UPDATE TS
SET SegmentCarrierName = cr.CarrierName
FROM DBA.TranSeg TS, dba.Carriers cr
WHERE 1=1
AND ts.SegmentCarrierCode = cr.CarrierCode
AND ((SegmentCarrierName <> cr.CarrierName) OR (SegmentCarrierName IS NULL))
AND CR.TypeCode = 'A' AND CR.Status = 'A'
and ts.iatanum = 'ORBITZ'
and ts.issuedate>='2013-01-01'


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
and id.issuedate>='2013-01-01'



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
--and ih.importdt > (select dateadd(d,-7, max(importdt)) from dba.invoiceheader)
and ih.iatanum = 'ORBITZ'
and id.iatanum = 'ORBITZ'
and ts.iatanum = 'ORBITZ'
and id.origincode is  null
and id.destinationcode is null
and id.issuedate>='2013-01-01'

update id
set id.valcarriernum = cr.carriernumber
from  DBA.INVOICEDETAIL id, dba.carriers cr
WHEre id.IATANUM='ORBITZ' 
AND id.VENDORTYPE IN ('BSP','NONBSP') 
AND id.VOIDIND='N'   
and id.ValCarrierNum IS NULL
and cr.carriercode = id.valcarriercode
and id.issuedate>='2013-01-01'


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


---duplicate document numbers updated to void ind ='D' where one has documentnumber and one does not

update dba.invoicedetail
set voidind='D'
from dba.invoicedetail i
 where exists (select 1 from  
 dba.invoicedetail iSUB 
 WHERE iSUB.recordkey = i.recordkey
	and isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	and isub.documentnumber is not null 
	 AND isub.exchangeind = 'N' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='N'
	and isub.routing=i.routing
	and isub.iatanum='orbitz'
	and valcarriercode<>'WN'
	)
and 
i.issuedate >= '2013-01-01' 
 AND i.exchangeind = 'N' 
and i.vendortype in ('bsp','nonbsp') 
 AND i.voidind = 'N' 
 and i.refundind='n'
 and i.documentnumber is null
 and iatanum='orbitz'
 and valcarriercode<>'wn'
 
 
 --- identify duplicates where documentnumbers are the same and routing the same but one sent
 --in wkly file and one in daily  co2 emissions only updated on wkly
 update dba.invoicedetail
set voidind='D'
from dba.invoicedetail i
 where exists (select 1 from  
 dba.invoicedetail iSUB 
 WHERE iSUB.recordkey = i.recordkey
	and isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.documentnumber =i.documentnumber
	and isub.routing=i.routing
	--and isub.servicedescription is not null
	and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	 and isub.tktco2emissions is not null
	 AND isub.exchangeind = 'N' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='n'
	and iatanum='orbitz' and isub.valcarriercode<>'WN'
	)
and 
i.issuedate >= '2013-01-01' 
 AND i.exchangeind = 'N' 
and i.vendortype in ('bsp','nonbsp') 
 AND i.voidind = 'N' 
 --and i.servicedescription is null
 and i.tktco2emissions is null
 and i.refundind='n'
 and i.iatanum='orbitz'
 and i.documentnumber is not null
 and i.valcarriercode<>'wn'
 
 
  ---duplicates when multiple exchanges on a tkt - setting earliest itin id to void=D
   --case #39163
  update dba.invoicedetail
set voidind='D'
   from dba.invoicedetail i
 where exists (select 1 from  
 dba.invoicedetail iSUB 
 WHERE iSUB.recordkey = i.recordkey
	and isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.documentnumber =i.documentnumber
	and isub.routing=i.routing
		and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	and isub.OrigExchTktNum=i.origexchtktnum
	and isub.remarks3>i.Remarks3 --remarks 3=orbitz itin_hist.id
	 AND isub.exchangeind = 'Y' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='n'
	and iatanum='orbitz' and isub.valcarriercode<>'WN'
	)
and 
i.issuedate >= '2013-01-01' 
 AND i.exchangeind = 'Y' 
and i.vendortype in ('bsp','nonbsp') 
 AND i.voidind = 'N' 
 and i.refundind='N'
 and i.iatanum='orbitz'
 and i.documentnumber is not null
 and i.valcarriercode<>'wn'
 
 
 --- identify duplicates where documentnumbers are the same but record keys are diff
--keeping record with earliest issuedate
update dba.invoicedetail
set voidind='D'
from dba.invoicedetail i
 where exists (select 15 from  
 dba.invoicedetail iSUB 
 WHERE 
 --iSUB.recordkey = i.recordkey
	 isub.iatanum=i.iatanum
	and isub.valcarriercode=i.valcarriercode
	and isub.vendortype=i.vendortype
	and isub.totalamt=i.totalamt
	and isub.documentnumber =i.documentnumber
	and isub.lastname=i.lastname
	and isub.firstname=i.firstname
	and isub.Routing=i.routing
    AND isub.exchangeind = 'N' 
	and isub.vendortype in ('bsp','nonbsp') 
	AND isub.voidind = 'N' 
	and isub.refundind='n'
	and iatanum='orbitz' and isub.valcarriercode<>'WN'
	and isub.InvoiceDate<i.invoicedate
	--and isub.invoicetype='cx'
	)
and 
i.issuedate >= '2013-01-01' 
AND i.exchangeind = 'N' 
and i.vendortype in ('bsp','nonbsp') 
AND i.voidind = 'N' 
and i.refundind='n'
and i.iatanum='orbitz'
and i.documentnumber is not null
and i.valcarriercode<>'wn'



--Update any missing CCNUM and CCCODE in  InvHeader
update b 
set CCNum=a.ccnum,
CCCode=a.cccode
from dba.payment a , 
dba.invoiceheader b, 
dba.InvoiceDetail i 
where 
a.recordkey=b.recordkey 
and a.iatanum=b.iatanum 
and a.clientcode=b.clientcode 
and b.recordkey=i.recordkey 
and b.clientcode=i.clientcode 
and b.iatanum=i.iatanum 
and i.vendortype in ('bsp','nonbsp') 
and i.recordkey=a.recordkey 
and i.iatanum=a.iatanum 
and i.clientcode=a.clientcode 
and i.seqnum=a.seqnum 
and i.invoicedate > '2014/01/01' 
and a.ccnum is not null and 
b.ccnum is null 
and a.IataNum='orbitz'

--setting VoidInd to D when duplicate exchange transactions are sent with identical data

--setting VoidInd to D when duplicate exchange transactions are sent with identical data

update i
set VoidInd='D' from 
 dba.InvoiceDetail i
  where  i.RecordKey in (
 select recordkey
 from dba.InvoiceDetail
 where IataNum='orbitz'
 and VoidInd='n'
 and ExchangeInd='Y'
 and IssueDate>='2013-01-01'
 and valcarriercode<>'WN'
  and DocumentNumber<>'0000000000'
  and RefundInd='N'
  and vendortype in ('bsp','nonbsp') 
 group by RecordKey,IataNum,ClientCode,IssueDate,DocumentNumber,totalamt,routing,Lastname,firstname
 having count(*)>=2)
 and i.Mileage <0
 and i.IataNum='orbitz'
 and i.VoidInd='n'
 and i.ExchangeInd='Y'
 and i.IssueDate>='2013-01-01'
 and i.valcarriercode<>'WN'
 and i.DocumentNumber<>'0000000000'
   and RefundInd='N'
and i.vendortype in ('bsp','nonbsp') 

--setting VoidInd to D when duplicate transactions/tickets are sent with identical data
update i
set VoidInd='D' from 
 dba.InvoiceDetail i
  where  i.RecordKey in (select RecordKey
 from dba.InvoiceDetail i
 where IataNum='orbitz'
 and i.VoidInd='n'
 and i.ExchangeInd='n'
 and i.IssueDate>='2013-01-01'
 and i.valcarriercode<>'WN'
  and i.DocumentNumber<>'0000000000'
  and i.RefundInd='N'
  and i.vendortype in ('bsp','nonbsp') 
  and i.ProductType<>'rail'
 group by RecordKey,IataNum,ClientCode,IssueDate,lastname,firstname,DocumentNumber,totalamt,routing,remarks2
 having count(*)>=2)
 and i.IataNum='orbitz'
 and i.VoidInd='n'
 and i.ExchangeInd='n'
 and i.IssueDate>='2013-01-01'
 and i.valcarriercode<>'WN'
 and i.DocumentNumber<>'0000000000'
   and RefundInd='N'
    and i.vendortype in ('bsp','nonbsp') 
    and i.ProductType<>'rail'
 and RecordKey + cast(SeqNum as VARCHAR)in
 (select 
RecordKey + cast(max(SeqNum) as VARCHAR)
 from dba.InvoiceDetail
 where IataNum='orbitz'
 and VoidInd='n'
 and ExchangeInd='n'
 and IssueDate>='2013-01-01'
 and valcarriercode<>'WN'
  and DocumentNumber<>'0000000000'
  and RefundInd='N'
  and vendortype in ('bsp','nonbsp') 
  and ProductType<>'rail'
 group by RecordKey,IataNum,ClientCode,IssueDate,lastname,firstname,DocumentNumber,totalamt,routing,remarks2
 having count(*)>=2) 


---HarteHanks updating Southwest bookings to the credit card Orbitz says they should be on
--so the records can be picked up in the Airplus weekly feed. #46389 9/25/2014 KP

update pay
set ccnum='80264'
 from dba.InvoiceDetail id,
 dba.Payment pay
 where Remarks2 like 'AP67%'
and id.ClientCode='TPT-TP5920019'
and VendorType in ('bsp','nonbsp')
and ValCarrierCode='WN'
and id.RecordKey=pay.RecordKey
and id.IataNum=pay.IataNum
and id.ClientCode=pay.ClientCode
and id.SeqNum=pay.seqnum
and pay.CCNum<>'80264'


update ih
set ccnum='80264'
 from dba.InvoiceDetail id,
 dba.InvoiceHeader ih
 where Remarks2 like 'AP67%'
and id.ClientCode='TPT-TP5920019'
and VendorType in ('bsp','nonbsp')
and ValCarrierCode='WN'
and id.RecordKey=ih.RecordKey
and id.IataNum=ih.IataNum
and id.ClientCode=ih.ClientCode
and ih.CCNum<>'80264'

EXEC TTXPASQL01.TMAN503_ORBITZ.dbo.SP_ORBITZ_CO2_MAIN

--Orbitz has advised as of 2/28/14 OpenX does not want data imported to Mastercard
--below is commented out to no longer execute sp to send data
--New client USF sending data to MC #33819 - ck with Brian Perry for any errors
EXEC [ATL892].[TMAN503_MC_TMC].dbo.sp_MCTMC_postImport_MCORUS NULL, NULL
GO

ALTER AUTHORIZATION ON [dbo].[sp_ORBITZWKLY_Update] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Payment]    Script Date: 7/7/2015 11:22:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Payment](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[PaymentSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL
) ON [INDEXES]
SET ANSI_PADDING ON
ALTER TABLE [dba].[Payment] ADD [CCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[Payment] ADD [CCExp] [varchar](10) NULL
ALTER TABLE [dba].[Payment] ADD [CCApprovalCode] [varchar](10) NULL
ALTER TABLE [dba].[Payment] ADD [CurrCode] [varchar](3) NULL
ALTER TABLE [dba].[Payment] ADD [PaymentAmt] [float] NULL
ALTER TABLE [dba].[Payment] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[Payment] ADD [CCLastFour] [varchar](4) NULL
 CONSTRAINT [PK_Payment] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Payment] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 11:22:08 PM ******/
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

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 11:22:10 PM ******/
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

/****** Object:  Table [dba].[Hotel]    Script Date: 7/7/2015 11:22:21 PM ******/
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

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/7/2015 11:22:27 PM ******/
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

/****** Object:  Table [dba].[Client]    Script Date: 7/7/2015 11:22:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Client](
	[ClientCode] [varchar](15) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[STATE] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[CustPhone] [varchar](20) NULL,
	[CountryCode] [varchar](5) NULL,
	[AttnLine] [varchar](40) NULL,
	[Email] [varchar](80) NULL,
	[ConsolidationCode] [varchar](50) NULL,
	[ClientRemark1] [varchar](255) NULL,
	[ClientRemark2] [varchar](255) NULL,
	[ClientRemark3] [varchar](255) NULL,
	[ClientRemark4] [varchar](255) NULL,
	[ClientRemark5] [varchar](255) NULL,
	[ClientRemark6] [varchar](255) NULL,
	[ClientRemark7] [varchar](255) NULL,
	[ClientRemark8] [varchar](255) NULL,
	[ClientRemark9] [varchar](255) NULL,
	[ClientRemark10] [varchar](255) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientCode] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Carriers]    Script Date: 7/7/2015 11:22:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Carriers](
	[CarrierCode] [varchar](3) NOT NULL,
	[TypeCode] [varchar](1) NOT NULL,
	[Status] [varchar](1) NOT NULL,
	[CarrierName] [varchar](50) NOT NULL,
	[CarrierNumber] [smallint] NOT NULL,
 CONSTRAINT [PK_Carriers] PRIMARY KEY CLUSTERED 
(
	[CarrierCode] ASC,
	[TypeCode] ASC,
	[Status] ASC,
	[CarrierName] ASC,
	[CarrierNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Carriers] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Car]    Script Date: 7/7/2015 11:22:40 PM ******/
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

/****** Object:  Table [dba].[Udef]    Script Date: 7/7/2015 11:22:45 PM ******/
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

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 11:22:46 PM ******/
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

/****** Object:  Table [dba].[Tax]    Script Date: 7/7/2015 11:22:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Tax](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[TaxSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[TaxId] [varchar](10) NULL,
	[TaxAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[TaxRate] [float] NULL,
 CONSTRAINT [PK_Tax] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Tax] TO  SCHEMA OWNER 
GO

/****** Object:  Index [PaymentI1]    Script Date: 7/7/2015 11:22:54 PM ******/
CREATE CLUSTERED INDEX [PaymentI1] ON [dba].[Payment]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 11:22:55 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 11:22:55 PM ******/
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

/****** Object:  Index [HotelI1]    Script Date: 7/7/2015 11:22:55 PM ******/
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

/****** Object:  Index [ComRmksI1]    Script Date: 7/7/2015 11:22:56 PM ******/
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

/****** Object:  Index [CarI1]    Script Date: 7/7/2015 11:22:56 PM ******/
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

/****** Object:  Index [UdefI1]    Script Date: 7/7/2015 11:22:56 PM ******/
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

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 11:22:57 PM ******/
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

/****** Object:  Index [TaxI1]    Script Date: 7/7/2015 11:22:57 PM ******/
CREATE CLUSTERED INDEX [TaxI1] ON [dba].[Tax]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

/****** Object:  Index [PaymentI2]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE NONCLUSTERED INDEX [PaymentI2] ON [dba].[Payment]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [dba].[InvoiceHeader]
(
	[BookingBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [dba].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI3]    Script Date: 7/7/2015 11:22:58 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI3] ON [dba].[InvoiceDetail]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI5]    Script Date: 7/7/2015 11:22:59 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI5] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailPX]    Script Date: 7/7/2015 11:22:59 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetailPX] ON [dba].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 11:22:59 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/7/2015 11:22:59 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [dba].[Hotel]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelPX]    Script Date: 7/7/2015 11:22:59 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI2]    Script Date: 7/7/2015 11:22:59 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI2] ON [dba].[ComRmks]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI3]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI3] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI4]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI4] ON [dba].[ComRmks]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CarI2]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [dba].[Car]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI3]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [CarI3] ON [dba].[Car]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CarI6]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [CarI6] ON [dba].[Car]
(
	[PickupDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [dba].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI3]    Script Date: 7/7/2015 11:23:00 PM ******/
CREATE NONCLUSTERED INDEX [UdefI3] ON [dba].[Udef]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefI4]    Script Date: 7/7/2015 11:23:01 PM ******/
CREATE NONCLUSTERED INDEX [UdefI4] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI5]    Script Date: 7/7/2015 11:23:01 PM ******/
CREATE NONCLUSTERED INDEX [UdefI5] ON [dba].[Udef]
(
	[UdefNum] ASC,
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/7/2015 11:23:01 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [dba].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC,
	[UdefType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TranSegI4]    Script Date: 7/7/2015 11:23:01 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI4] ON [dba].[TranSeg]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI5]    Script Date: 7/7/2015 11:23:01 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI5] ON [dba].[TranSeg]
(
	[ClientCode] ASC,
	[IataNum] ASC,
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI6]    Script Date: 7/7/2015 11:23:02 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI6] ON [dba].[TranSeg]
(
	[OriginCityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/7/2015 11:23:02 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [dba].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TaxI4]    Script Date: 7/7/2015 11:23:02 PM ******/
CREATE NONCLUSTERED INDEX [TaxI4] ON [dba].[Tax]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

