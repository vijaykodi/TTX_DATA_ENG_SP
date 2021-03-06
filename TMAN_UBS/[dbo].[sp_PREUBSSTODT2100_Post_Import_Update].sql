/****** Object:  StoredProcedure [dbo].[sp_PREUBSSTODT2100_Post_Import_Update]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSSTODT2100_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start STODT2100-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='SE'
where iatanum ='PREUBS'
and recordkey like '%STODT2100-%' and (origcountry is null or origcountry ='XX')

---- Update text14 with Approver GPN -----------------LOC 5/8/2012
update c
set text14 = substring(udefdata,10,charindex(')',udefdata)-10)
from dba.udef u, dba.comrmks c
where u.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%STODT2100-%' and udefdata like '(rfc=app=%' and text14 is null

---- Update htlreasoncode1 -- asking Tanya to change DM Parsing ---- LOC 5/8/2012
update h
set htlreasoncode1 = udefdata
from dba.udef u, dba.hotel h
where u.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%STODT2100-%' and udeftype = 'htlreasoncd'

----- update Air Reason Code --------------LOC .. updated 5/15/2012 per email from Ryan
--- AU to A1 not confirmed .. will update if necessare 5/15/2012
update i
set reasoncode1 = case when  substring(udefdata,9,2) = 'SR' then 'B3'
					   when substring(udefdata,9,2) = 'AU' then 'A1'
end
from dba.udef u, dba.invoicedetail i
where u.recordkey like '%STODT2100-%' and udefdata like '%ivl=rsr%'
and u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum

update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%STODT2100-%' and text18 is null

---------------- TractID update from Udef ------ LOC/9/19/212
update c
set text17 = substring(udefdata,10,charindex(')',udefdata)-10) 
from dba.udef u, dba.comrmks c
where u.recordkey like '%STODT2100-%' and u.iatanum = 'preubs' and ((udefdata like '(rfc=ono%')
and (udefdata not like '%?%')) and isnull(text17,'N/A') = 'N/A'
and u.recordkey = c.recordkey and u.seqnum = c.seqnum

---------Update Text7 with Project Code ---- LOC/11/12/212
update c
set text7 = substring(udefdata,charindex('rfc=pro=',udefdata)+8,charindex(')',udefdata)-12) 
from dba.udef u, dba.comrmks c
where u.recordkey like '%STODT2100-%' and u.iatanum = 'preubs'
and udefdata like '%rfc=pro%)%' and udefdata not like '%(RFC=PRO=)%'
and isnull(text7,'N/A') = 'N/A' and u.recordkey = c.recordkey and u.seqnum = c.seqnum

-------- Update Text6 with T24 Flag -------- LOC/3/22/2013
update c
set text6= substring(udefdata,29,1)
from dba.udef u, dba.comrmks c
where u.recordkey like '%STODT2100-%' and u.iatanum = 'preubs'
and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and udefdata like '%rfc=cl7%)%' and udefdata not like '%(RFC=CL7=?T24 ISSUED TKT)%' and text6 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation STODT2100-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%STODT2100-%' and udefdata like '%RFC=EMP=%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%STODT2100-%' and udefdata like '%RFC=POT=%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%STODT2100-%' and udefdata like '%RFC=COS=%' and udefdata not like '%RFC=COS=%?%'
and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%STODT2100-%' and udefdata  like '%(IVL=RSR%' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
--update c
--set text26 = udefdata
--from dba.comrmks c, dba.udef u
--where c.recordkey = u.recordkey and c.seqnum = u.seqnum
--and c.iatanum = 'preubs'
--and u.recordkey like '%STODT2100-%' --and udefdata  like 'RTT-%'
--and text26 is null

-------Update Text27 = TractID String --------------------------- LOC 5/31/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%STODT2100-%' and ((udefdata like '(rfc=ONO=%') and (udefdata not like '%?%'))
and text27 is null

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= right(udefdata,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%STODT2100-%' and udefdata like 'tt%'--and text47 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End STODT2100-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC sp_PRE_UBS_MAIN_Mini 

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  




GO
