/****** Object:  StoredProcedure [dbo].[sp_PREUBS94V_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS94V_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Log Activity

select @BeginIssueDate =min(InvoiceDate), @EndIssueDate = max(InvoiceDate)
from dba.InvoiceHeader
where iatanum = 'preubs'
and recordkey like '%94V-%'
and importdt = (select max(ImportDt) from dba.InvoiceHeader
					where iatanum = 'preubs'
					and recordkey like '%94V-%')

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 94V-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='JP'
where iatanum ='PREUBS' and recordkey like '%94V-%' and (origcountry is null or origcountry ='XX')

---- Update GPN from Udef like FF25/----------------------------------------
update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%94V-%' and isnull(remarks2,'Unknown') = 'Unknown' and udefdata like 'FF25/%'
and substring(udefdata,6,8) in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and i.InvoiceDate between @BeginIssueDate and @EndIssueDate

---- Update Trip Purpose from Udef FF12/ -----------------------------------
update i
set remarks1 = substring(udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%94V-%' and remarks1 is null and udefdata like 'FF16/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')
and i.InvoiceDate between @BeginIssueDate and @EndIssueDate

---- Update Rank from Rollup40 in Remarks 3

---- Update Cost Center From Udef16 -------------------------------------
update i
set remarks5 = substring(udefdata,6,20)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%94V-%' and remarks5 is null and udefdata like 'FF10/%'

---- Update Air Reason code from Udef FF13/ --------------------------------
update i
set reasoncode1 = substring (udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%94V-%' and reasoncode1 is null and udefdata like 'FF54/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'reascode')
	
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='2-Update Air ReasonCode1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---- Update Hotel Reason Code from Udef FF19/ -------------------------------
update h
set htlreasoncode1 = substring (udefdata,6,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.recordkey like '%94V-%' and htlreasoncode1 is null and udefdata like 'FF19/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'reascode')
and h.InvoiceDate between @BeginIssueDate and @EndIssueDate
	
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='2-Update Hotel ReasonCode1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---- Update Online Booking System ----Not online at this time 4/18/2012 .. LOC-----

--UPDATE ID
--SET id.onlinebookingsystem = RIGHT(RTRIM(UD.UDEFDATA), 2)
----SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,5)
--FROM DBA.UDEF UD, DBA.invoicedetail ID
--WHERE id.RECORDKEY = UD.RECORDKEY
--AND id.IATANUM = UD.IATANUM
--AND id.CLIENTCODE = UD.CLIENTCODE
--AND UD.UDEFTYPE = 'ACCTDTLS'
--AND ID.recordkey like '%94V-%'
--AND SUBSTRING(UD.UDEFDATA,1,5) LIKE 'FF34/'
--and id.InvoiceDate between @BeginIssueDate and @EndIssueDate

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%94V-%' and text18 is null

----- Update Text17 with TrackID from Udef FF15/ ----------------------------
update c
set text17 = substring (udefdata,6,20)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.recordkey like '%94V-%' and text17 is null
and udefdata like 'FF15/%'
and c.InvoiceDate between @BeginIssueDate and @EndIssueDate

----- Update Text8 with Booker GPN -- LOC/9/4/2012
update c
set text8 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where  u.recordkey like '%94V-%'  and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF17%'

----- Update Text14 with Approver GPN -- LOC/9/4/2012
update c
set text14 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%94V-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF20%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 94V-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF15/%' and text27 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF19/%' and text26 is null

-------Update Text25 = ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF54/%' and text25 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF16/%' and text23 is null

-------Update Text24 = CostCenter String --------------------------- LOC 5/29/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF10/%' and text24 is null

-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = udefdata 
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and u.udefdata like 'FF25/%' and text22 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 9/4/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF17/%' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%94V-%' and udefdata like 'FF20/%' and text29 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='2-Stored Procedure End 94V-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN
 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  







GO
