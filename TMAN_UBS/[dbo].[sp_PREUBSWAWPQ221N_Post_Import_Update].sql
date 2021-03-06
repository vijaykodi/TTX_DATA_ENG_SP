/****** Object:  StoredProcedure [dbo].[sp_PREUBSWAWPQ221N_Post_Import_Update]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSWAWPQ221N_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start WAWPQ221N--',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='PL'
where iatanum ='PREUBS'
and recordkey like '%WAWPQ221N-%' and (origcountry is null or origcountry ='XX')

--GPN mapping Upate 6/30/2015 KP
update id
set remarks2 = substring(udefdata,5,8)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'EMP-%' 
and Remarks2 is null

----- Update Text14 with Approver GPN -------------------
update c
set  text14 = substring(udefdata,6,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%WAWPQ221N-%' and udefdata like '%cod7%' and text14 is null

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
--4/16/15 coding added #6291385
update c
set text18 = SUBSTRING(UDEFDATA,5,2)
from dba.comrmks c,
dba.Udef u
where c.iatanum = 'preubs' and c.recordkey like '%WAWPQ221N-%' 
and c.IataNum=u.iatanum and c.RecordKey=u.recordkey and c.SeqNum=u.seqnum
and u.UdefData like 'CD4-%'
and text18 is null
and SUBSTRING(UDEFDATA,5,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')

--update c
--set text18 = 'N/A'
--from dba.comrmks c
--where iatanum = 'preubs'
--and recordkey like '%WAWPQ221N-%' and text18 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation WAWPQ221n-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'COD2/%' and text22 is null

--New GPN mapping provided 6/30/2015
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'EMP-%' and text22 is null


-------Update Text23 = Trip Purpose String ---------------- LOC 5/31/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'COD6/%' and text23 is null

-------Update Text24 = Cost Center String ---------------- LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'COD1/%' and text24 is null

-------Update Text25 = Air ReasonCode1 String ---------------- LOC 5/31/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'SM-RC%' and text25 is null

-------Update Text26 = HtlReasonCode1 String ---------------- LOC 5/31/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'SM-HC%' and text26 is null

-------Update Text27 = TractID String ---------------- LOC 5/31/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'COD9/%' and text27 is null

-------Update Text29 = Approver GPN String ---------------- LOC 5/31/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'COD7/%' and text29 is null

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= right(udefdata,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'rco%' and text47 is null

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= right(udefdata,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%WAWPQ221N-%' and udefdata like 'rco%' and text47 is null






EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End WAWPQ221N-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN

 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  






GO
