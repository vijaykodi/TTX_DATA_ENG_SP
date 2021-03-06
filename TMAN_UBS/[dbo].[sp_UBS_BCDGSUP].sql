/****** Object:  StoredProcedure [dbo].[sp_UBS_BCDGSUP]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_BCDGSUP]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime

 AS
 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
--- This stored procedure is used when suplemental data is received from BCD from the Global data ----- 

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate
FROM dba.InvoiceDetail 
	where recordkey+iatanum+convert(varchar,seqnum) not in
	(SELECT recordkey+iatanum+convert(varchar,seqnum) from dba.comrmks
	where Invoicedate between @BeginIssueDate and @EndIssueDate
	 and iatanum = 'UBSBCDEU')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and iatanum = 'UBSBCDEU'

-- Move data from remarks 1,2,3,4,5 to text 32,33,34,35,36
update c
set c.text32 = i.remarks1,
	c.text33 = i.remarks2,
	c.text34 = i.remarks3,
	c.text35 =  i.remarks4,
	c.text36 = i.remarks5
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.iatanum = 'UBSBCDEU' 
and text32 is null and text33 is null and text34 is null and text35 is null and text36 is null
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

-- Null Remarks 1,2,3,4,5

update i
set i.remarks1 = null, i.remarks2 = null,i.remarks3 = null,i.remarks4 = null,i.remarks5 = null
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

--Update Remarks2 with GPN -- Non US
update i
set i.remarks2 = ud.udefdata
from dba.invoicedetail i, dba.udef ud, dba.invoiceheader ih
where i.recordkey = ih.recordkey
and i.recordkey = ud.recordkey
and i.seqnum = ud.seqnum
and i.iatanum = 'UBSBCDEU'
and ud.iatanum = 'UBSBCDEU'
and ud.udefnum = 2
and ih.origcountry <> 'US'
and isnull(i.remarks2,'Unknown') = 'Unknown'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

--- Set Remarks1 in invoicedetail to have the Trip Purpose code from Udef

update id
set remarks1 =  udefdata
from dba.invoicedetail id, dba.udef u, dba.invoiceheader ih
where id.recordkey = u.recordkey
and id.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and u.udefnum = '6'
and ih.origcountry <> 'US'
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate



--- Set Remarks3 in invoicedetail to have the Rank code from Udef for Non US

update id
set remarks3 =  udefdata
from dba.invoicedetail id, dba.udef u, dba.invoiceheader ih
where id.recordkey = u.recordkey
and id.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and u.udefnum = '5'
and ih.origcountry <> 'US'
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate


-- Set Remarks5 to Cost Center for EU
update id
set remarks5 = udefdata
from dba.invoicedetail id, dba.udef u, dba.invoiceheader ih
where id.recordkey = u.recordkey
and id.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and u.udefnum = '1'
and ih.origcountry <> 'US'
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate


-- Update value of ReasonCode3 to ReasonCode1
update c
set text47 = i.reasoncode1
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey
and c.seqnum = i.seqnum
and c.text47 is null
and i.iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate


update i
set reasoncode1 = NULL
from dba.invoicedetail i
where iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate


update i
set reasoncode1 = reasoncode3
from dba.invoicedetail i
where iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

-- Set ReasonCode1 where value is FS to A1
update i
set reasoncode1 = 'A1'
from dba.invoicedetail i
where iatanum = 'UBSBCDEU'
and reasoncode1 in('FS','RB','XX')
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate


----Update HtlReasonCode1 to HtlReasonCode2

update c
set text48 = h.htlreasoncode1
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey
and c.seqnum = h.seqnum
and c.text48 is null
and h.iatanum = 'UBSBCDEU'
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate


update h
set htlreasoncode1 = NULL
from dba.hotel h
where iatanum = 'UBSBCDEU'
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate


update h
set htlreasoncode1 = htlreasoncode2
from dba.hotel h
where iatanum = 'UBSBCDEU'
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate

--- Update text 14 with approver

update c
set text14 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'UBSBCDEU'
AND UDEFNUM = '8'
AND c.Invoicedate between @BeginIssueDate and @EndIssueDate

--- Update MCO Fees specific to BCDEU

update i
set vendortype = 'MCO'
from dba.invoicedetail i
where substring(documentnumber,1,3) ='907'
and vendortype <> 'FEES'
and servicedescription like ('%MCO%')
and IATANUM = 'UBSBCDEU'
AND Invoicedate between @BeginIssueDate and @EndIssueDate

-- Online Booking System Mapping --
update i
set onlinebookingsystem =  invoicetypedescription
from dba.invoicedetail i
where invoicetypedescription = 'Online' 
and iatanum = 'UBSBCDEU'
AND Invoicedate between @BeginIssueDate and @EndIssueDate


---- Change Iatanum to UBSBCDUSif data received from UBSBCDEU for BR and UY orig country.

update ih
set iatanum = 'UBSBCDUS'
from dba.invoiceheader ih
where iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND ih.Invoicedate between @BeginIssueDate and @EndIssueDate


update id
set id.iatanum = 'UBSBCDUS'
from dba.invoicedetail id, dba.invoiceheader ih
where id.recordkey = ih.recordkey
and id.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate

update h
set h.iatanum = 'UBSBCDUS'
from dba.hotel h, dba.invoiceheader ih
where h.recordkey = ih.recordkey
and h.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate

update c
set c.iatanum = 'UBSBCDUS'
from dba.car c, dba.invoiceheader ih
where c.recordkey = ih.recordkey
and c.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND c.Invoicedate between @BeginIssueDate and @EndIssueDate

update t
set t.iatanum = 'UBSBCDUS'
from dba.tax t, dba.invoiceheader ih
where t.recordkey = ih.recordkey
and t.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND t.Invoicedate between @BeginIssueDate and @EndIssueDate

update p
set p.iatanum = 'UBSBCDUS'
from dba.payment p, dba.invoiceheader ih
where p.recordkey = ih.recordkey
and p.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND p.Invoicedate between @BeginIssueDate and @EndIssueDate

update ts
set ts.iatanum = 'UBSBCDUS'
from dba.transeg ts, dba.invoiceheader ih
where ts.recordkey = ih.recordkey
and ts.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND ts.Invoicedate between @BeginIssueDate and @EndIssueDate

update u
set u.iatanum = 'UBSBCDUS'
from dba.udef u, dba.invoiceheader ih
where u.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND u.Invoicedate between @BeginIssueDate and @EndIssueDate

update cr
set cr.iatanum = 'UBSBCDUS'
from dba.comrmks cr, dba.invoiceheader ih
where cr.recordkey = ih.recordkey
and cr.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND cr.Invoicedate between @BeginIssueDate and @EndIssueDate




EXEC SP_UBS_MAIN
@IATANUM =  'UBSBCDEU',
@BEGINISSUEDATEMAIN= @BEGINISSUEDATE,
@ENDISSUEDATEMAIN = @ENDISSUEDATE

/************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  


































GO
