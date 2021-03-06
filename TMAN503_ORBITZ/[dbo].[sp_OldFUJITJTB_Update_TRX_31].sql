/****** Object:  StoredProcedure [dbo].[sp_OldFUJITJTB_Update_TRX_31]    Script Date: 7/14/2015 8:13:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_OldFUJITJTB_Update_TRX_31]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime

 AS

INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, clientcode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, clientcode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
WHERE iatanum in ('FUJITJTB')
and issuedate between @BeginIssueDate and @EndIssueDate
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('FUJITJTB'))

INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, clientcode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, clientcode, InvoiceDate, IssueDate
FROM dba.hotel
WHERE iatanum in ('FUJITJTB')
and issuedate between @BeginIssueDate and @EndIssueDate
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('FUJITJTB'))

INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, clientcode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, clientcode, InvoiceDate, IssueDate
FROM dba.car
WHERE iatanum in ('FUJITJTB')
and issuedate between @BeginIssueDate and @EndIssueDate
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('FUJITJTB'))



update cr
set cr.text1 = case 
	when clientcode = '9012414' then 'FCAI'
	when clientcode = '9112414' then 'FCAI'
	when clientcode = '9112725' then 'FCS'
	when clientcode = '9662414' then 'FCAI'
	when clientcode = '9662615' then 'GI'
	when clientcode = '9662619' then 'FMA'
	when clientcode = '9662625' then 'FCS'
	when clientcode = '9772414' then 'FCAI'
	when clientcode = '9772603' then 'FAI'
	when clientcode = '9772615' then 'GI'
	when clientcode = '9772616' then 'FCPA'	
	when clientcode = '9772619' then 'FMA'
	when clientcode = '9772625' then 'FCS'
	when clientcode = '9772628' then 'FLA'
	when clientcode = '9772639' then 'FMA'
	when clientcode = '9772931' then 'FC'
	end
from dba.comrmks cr
where cr.iatanum ='FUJITJTB'
and cr.text1 is null
and cr.issuedate between @BeginIssueDate and @EndIssueDate

update id
set id.department = cr.text1
from dba.comrmks cr, dba.invoicedetail id
where cr.iatanum ='FUJITJTB'
and cr.text1 is not null
and cr.iatanum = id.iatanum
and cr.recordkey = id.recordkey
and cr.seqnum = id.seqnum
and cr.issuedate = id.issuedate
and cr.issuedate between @BeginIssueDate and @EndIssueDate

GO
