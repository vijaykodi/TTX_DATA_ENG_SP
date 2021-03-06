/****** Object:  StoredProcedure [dbo].[sp_PREUBS7N3K_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS7N3K_Post_Import_Update]

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

/*Get min and max invoicedate from dba.InvoiceHeader for most recent import*/ --added 9APR2012/SS
SET @TransStart = getdate()

select @BeginIssueDate =min(InvoiceDate), @EndIssueDate = max(InvoiceDate)
from dba.InvoiceHeader ih
where ih.iatanum = 'preubs'
and ih.recordkey like '%7B3K-%'
and ih.importdt = (select max(ImportDt) from dba.InvoiceHeader ih2
					where ih2.iatanum = 'preubs'
					and ih2.recordkey like '%7B3K-%')

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 7B3K-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='IN'
where iatanum ='PREUBS' and recordkey like '%7B3K-%' and (origcountry is null or origcountry ='XX')

---- Update GPN from Udef like FF25/----------------------------------------

update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%7B3K-%' and isnull(remarks2,'Unknown') = 'Unknown' and udefdata like 'FF25/%'
and substring(udefdata,6,8) in (select corporatestructure from dba.rollup40 where costructid = 'functional')

---- Update Trip Purpose from Udef FF12/ -----------------------------------
update i
set remarks1 = substring(udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%7B3K-%' and remarks1 is null  and udefdata like 'FF12/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')


---- Update Cost Center From Udef16 -------------------------------------
update i
set remarks5 = substring(udefdata,6,20)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%7B3K-%' and remarks5 is null and udefdata like 'FF16/%'

------- Update reasoncode1 from FF13 field-------
SET @TransStart = getdate()
update id
set reasoncode1 = substring(udefdata,6,2)
from dba.udef u, dba.invoicedetail id
where u.recordkey like '%7B3K-%' and u.recordkey = id.recordkey and u.seqnum = id.seqnum
and reasoncode1 is null and u.iatanum = 'preubs' and udefdata like 'ff13%'
and substring(udefdata,6,2) in (select lookupvalue  	from dba.lookupdata where lookupname = 'reascode')

update id
set reasoncode1 = substring(udefdata,7,2)
from dba.udef u, dba.invoicedetail id
where u.recordkey like '%7B3K-%' and u.recordkey = id.recordkey and u.seqnum = id.seqnum
and reasoncode1 is null and u.iatanum = 'preubs' and udefdata like 'ff13%'
and substring(udefdata,7,2) in (select lookupvalue  from dba.lookupdata where lookupname = 'reascode')

---- Update Hotel Reason Code from Udef FF19/ -------------------------------
update h
set htlreasoncode1 = substring (udefdata,6,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%7B3K-%' and htlreasoncode1 is null and udefdata like 'FF19/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'reascode')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='PREUBS7B3K-Update htlreasoncode1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------ Online booking --
--na for now

update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%7B3K-%' and text18 is null

----- Update Text17 with TrackID from Udef FF15/ ----------------------------
update c
set text17 = substring (udefdata,6,20)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%7B3K-%' and text17 is null and udefdata like 'FF15/%'

----- Update Text8 with Booker GPN -- LOC/9/4/2012
update c
set text8 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%7B3K-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF17%'

----- Update Text14 with Approver GPN -- LOC/9/4/2012
update c
set text14 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%7B3K-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF20%'

-------- Update Text7 with Project code ---- LOC/12/11/2012
update c
set text7 = substring(udefdata,6,10)
from dba.udef u, dba.comrmks c
where u.recordkey like '%7B3K-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs' and udefdata like 'FF18%' and text7 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 7B3K-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/25/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF15/%' and text27 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/25/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF19/%' and text26 is null

-------Update Text25 = ReasonCode1 String --------------------------- LOC 5/25/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF13/%' and text25 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/25/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF12/%' and text23 is null

-------Update Text22 = GPN String --------------------------- LOC 5/25/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF25/%' and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/25/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF16/%' and text24 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 9/4/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF17/%' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%7B3K-%' and udefdata like 'FF20/%' and text29 is null

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 7B3K-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
