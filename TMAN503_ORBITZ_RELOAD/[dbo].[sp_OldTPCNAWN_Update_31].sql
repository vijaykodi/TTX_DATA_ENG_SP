/****** Object:  StoredProcedure [dbo].[sp_OldTPCNAWN_Update_31]    Script Date: 7/14/2015 8:13:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_OldTPCNAWN_Update_31]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime

 AS

--set remarks 1 to null
update dba.invoicedetail
set remarks1 = null
from dba.invoicedetail
where iatanum like 'TPCNAWN'
and issuedate between @BeginIssueDate and @EndIssueDate
and remarks1 is not null

update dba.invoicedetail
set farecompare1 = totalamt
from dba.invoicedetail
where iatanum like 'TPCNAWN'
and issuedate between @BeginIssueDate and @EndIssueDate
and farecompare1 is null

update dba.invoicedetail
set farecompare2 = totalamt
from dba.invoicedetail
where iatanum like 'TPCNAWN'
and issuedate between @BeginIssueDate and @EndIssueDate
and farecompare2 is null

update dba.invoicedetail
set reasoncode1 = 'SB'
from dba.invoicedetail
where iatanum like 'TPCNAWN'
and issuedate between @BeginIssueDate and @EndIssueDate
and reasoncode1 is null

update dba.invoicedetail
set reasoncode2 = 'SB'
from dba.invoicedetail
where iatanum like 'TPCNAWN'
and issuedate between @BeginIssueDate and @EndIssueDate
and reasoncode2 is null

GO
