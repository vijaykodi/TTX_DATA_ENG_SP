/****** Object:  StoredProcedure [dbo].[OLDsp_PREHGP_Main_Post_Import_Update]    Script Date: 7/14/2015 8:10:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLDsp_PREHGP_Main_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREHGP'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start RC5-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/*Update Client Table*/

insert into dba.client
select DISTINCT clientcode,'PREHGP',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from dba.invoicedetail 
where clientcode not in (select clientcode from dba.client where iatanum = 'PREHGP')
and iatanum = 'PREHGP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Add client codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cl
set cl.custname = 'Wyndham Jade'
from dba.Client cl, dba.InvoiceHeader ih
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum
and ih.BackOfficeID in ('L850','KK70','6L31','9LD2','J495')
and ih.iatanum = 'PREHGP'

update cl
set cl.custname = 'TS24'
from dba.Client cl, dba.InvoiceHeader ih
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum
and ih.BackOfficeID in ('0GH7','X8D4','3DCB','G965','6Z2C','DS07','6WAF','0XTF','CMH1S211T','KA0C','1TN6','15QN')
and ih.iatanum = 'PREHGP'

update cl
set cl.custname = 'World Travel Partners'
from dba.Client cl, dba.InvoiceHeader ih
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum
and ih.BackOfficeID in ('0ZA','1EB','2BS','2VH','3DK','57K','59T','5HV','5TL','63D','6KH','7CD','7CR','7DR','7IA',
'7SR','7TP','7UU','7X1','85T','86F','89T','8CI','9HB','9HU','9NW','9TI','AQD','BH0','FJY','G7G','H86','IPM','JJ5',
'K8M','L3P','M8S','O08','T67','T8P','BH0')
and ih.iatanum = 'PREHGP'

update cl
set cl.custname = 'Campbell Travel Services'
from dba.Client cl, dba.InvoiceHeader ih
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum
and ih.BackOfficeID in ('03NA','03QA','03RA','1BRB','1RI7','4JMF','4JOF','4JPF','4JQF','4Z4B','WL8A','WU9A','WU8A',
'WR2A','U430','S23B','S22B','R22B','OE5A','GM80','FS2A','6ZM1','3IGA','1JM4','Z9BB')
and ih.iatanum = 'PREHGP'

update cl
set cl.custname = 'Caldwell Travel'
from dba.Client cl, dba.InvoiceHeader ih
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum
and ih.BackOfficeID in ('3Q32','C7F0','F7L0','P6U0','R26B')
and ih.iatanum = 'PREHGP'


update cl
set cl.custname = 'Atlas Travel'
from dba.Client cl, dba.InvoiceHeader ih
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum
and ih.BackOfficeID in ('C8FC','E8JC','M45B','TL7A','3SDB','5J82','6RT0','7VZA','8CIC','BOS1S210G','WLM1S2100')
and ih.iatanum = 'PREHGP'

update cl 
set custname = 'Plaza Travel' 
from dba.Client cl, dba.InvoiceHeader ih 
where ih.clientcode = cl.clientcode 
and ih.iatanum = cl.iatanum 
and ih.BackOfficeID in ('0REA','R9TG','F379','V5CF','SB6G','RQ0','TV3','JB0','1QH1','1XG0')
and ih.iatanum = 'PREHGP'

update ih 
set GDSCode = 'SA' 
from dba.InvoiceHeader ih 
where BackOfficeID in ('L850','KK70','6L31','9LD2','J495','0GH7','X8D4','3DCB','G965','6Z2C','DS07','6WAF','0XTF','03NA','03QA','03RA','1BRB', 
'1RI7','4JMF','4JOF','4JPF','4JQF','4Z4B','WL8A','WU9A','WU8A','WR2A','U430','S23B','S22B','R22B','OE5A','GM80','FS2A', 
'6ZM1','3IGA','3Q32','C7F0','F7L0','P6U0','R26B','C8FC','E8JC','M45B','TL7A','3SDB','5J82','6RT0','7VZA','8CIC','0REA','R9TG','F379','V5CF','SB6G','KA0C') 
and iatanum = 'PREHGP'

update ih
set GDSCode = 'AM'
from dba.InvoiceHeader ih
where BackOfficeID in ('CMH1S211T','BOS1S210G','WLM1S2100')
and iatanum = 'PREHGP'

update ih 
set GDSCode = 'AP' 
from dba.InvoiceHeader ih 
where BackOfficeID in ('KA0C','1TN6','15QN','BH0','1JM4','Z9BB','RQ0','TV3','JB0','1QH1','1XG0')
and iatanum = 'PREHGP'

update ih
set GDSCode = 'WS'
from dba.InvoiceHeader ih
where BackOfficeID in ('0ZA','1EB','2BS','2VH','3DK','57K','59T','5HV','5TL','63D','6KH','7CD','7CR','7DR','7IA',
'7SR','7TP','7UU','7X1','85T','86F','89T','8CI','9HB','9HU','9NW','9TI','AQD','BH0','FJY','G7G','H86','IPM','JJ5',
'K8M','L3P','M8S','O08','T67','T8P')
and iatanum = 'PREHGP'


--Updated on 9/25/12 by Nina per Case #00004214
 UPDATE  htl
 SET htl.HtlRateCat = SUBSTRING(udefdata,CHARINDEX('/',ud.udefdata)+1,10)
 FROM    dba.hotel htl,dba.udef ud
 WHERE   htl.recordkey = ud.recordkey
 AND htl.iatanum = ud.iatanum
 AND htl.seqnum = ud.seqnum
 AND htl.clientcode = ud.clientcode
 --AND SUBSTRING(htl.RecordKey,CHARINDEX('-',htl.RecordKey)-4,4)  IN ('KK70','J495','6L31','9LD2','L850')
 AND ud.udeftype = 'RATECATEGORY'
 AND htl.iatanum = 'PREHGP'

--Updated on 9/25/12 by Nina per Case #00004214
UPDATE  htl
 SET htl.RoomType = SUBSTRING(udefdata,CHARINDEX('/',ud.udefdata)+1,6)
 FROM    dba.hotel htl,dba.udef ud
 WHERE   htl.recordkey = ud.recordkey
 AND htl.iatanum = ud.iatanum
 AND htl.seqnum = ud.seqnum
 AND htl.clientcode = ud.clientcode
--AND SUBSTRING(htl.RecordKey,CHARINDEX('-',htl.RecordKey)-4,4)  IN ('KK70','J495','6L31','9LD2','L850')
 AND ud.udeftype = 'ROOMTYPE'
 AND htl.iatanum = 'PREHGP'
 
 --Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.HtlRateCat = SUBSTRING(htl.RoomType,4,10)
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and LEN(htl.RoomType) > 3

--Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.HtlRateCat = htl.RoomType
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and LEN(htl.RoomType) = 3

--Updated on 9/25/12 by Nina per Case #00004214
UPDATE  htl
 SET htl.remarks1 = SUBSTRING(udefdata,CHARINDEX('/',ud.udefdata)+1,100)
 FROM    dba.hotel htl,dba.udef ud
 WHERE   htl.recordkey = ud.recordkey
 AND htl.iatanum = ud.iatanum
 AND htl.seqnum = ud.seqnum
 AND htl.clientcode = ud.clientcode
--AND SUBSTRING(htl.RecordKey,CHARINDEX('-',htl.RecordKey)-4,4)  IN ('KK70','J495','6L31','9LD2','L850')
 AND ud.udeftype = 'CDNUM'
 AND htl.iatanum = 'PREHGP'
 
 --Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks1 = substring(htl.Remarks1,1,charindex('SYS',htl.Remarks1)-1)
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and htl.Remarks1 like '%[0-9]SYS%'

--Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks1 = substring(htl.Remarks1,1,charindex('SYS',htl.Remarks1)-2)
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and htl.Remarks1 like '% SYS%'

--Updated on 9/25/12 by Nina per Case #00004214
UPDATE  htl
 SET htl.remarks2 = SUBSTRING(udefdata,CHARINDEX('/',ud.udefdata)+1,100)
 FROM    dba.hotel htl,dba.udef ud
 WHERE   htl.recordkey = ud.recordkey
 AND htl.iatanum = ud.iatanum
 AND htl.seqnum = ud.seqnum
 AND htl.clientcode = ud.clientcode
--AND SUBSTRING(htl.RecordKey,CHARINDEX('-',htl.RecordKey)-4,4)  IN ('KK70','J495','6L31','9LD2','L850')
 AND ud.udeftype = 'CMNCODE'
 AND htl.iatanum = 'PREHGP'
 
 --Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks2 = 'N'
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and htl.Remarks2 like '%NO%'

--Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks2 = 'C'
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and htl.Remarks2 not like '%NO%'
and htl.Remarks2 is not null

--Updated on 9/25/12 by Nina per Case #00004214
UPDATE dba.hotel
SET htlconfnum = substring(htlconfnum,1,charindex('-',htlconfnum)-1)
WHERE iatanum = 'PREHGP'
AND htlconfnum like '%-%'

--Added on 11/20/12 by Nina per Case #00006772
UPDATE dba.InvoiceHeader
SET TicketingBranch = SUBSTRING(ticketingbranch,CHARINDEX('/',ticketingbranch)+1,10)
where IataNum = 'PREHGP'
and TicketingBranch <> '0'
and TicketingBranch like '%/%'
GO
