/****** Object:  StoredProcedure [dbo].[sp_PREUBSGLZWR3100_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREUBSGLZWR3100_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start GLZWR3100-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='NL'
where iatanum ='PREUBS' and recordkey like '%GLZWR3100-%' and (origcountry is null or origcountry ='XX')

------ update Remarks5 (cost center) ------------ LOC 5/7/2012
update i
set remarks5 =  right(udefdata,charindex('/',udefdata)-2)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like '%acecrf//%' and right(udefdata,charindex('/',udefdata)-2) not like '%/%'
and remarks5 is null


update i
set remarks5 =  right(udefdata,charindex('/',udefdata)-2)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like '%acecrf//%' and right(udefdata,charindex('/',udefdata)-2) not like '%/%'
and remarks5 ='GLZWR3100'
and right(udefdata,charindex('/',udefdata)-2) in (select rollup8 from dba.rollup40 where costructid = 'functional' )

--------- Update ReasonCode1 from Udef Data
update i
set reasoncode1 = substring(udefdata,charindex('/S',udefdata)-2,2)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like '%acesv1/%' and reasoncode1 is null

---- Update text14 with Approver GPN ---------------------LOC 5/8/2012
update c
set text14 = substring(udefdata,15,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%GLZWR3100-%' and udefdata like '%acecrm/app nm-%' and text14 is null
and u.udeftype='RM OTHER'

--- Update TractID where DM Parsing does not -----------LOC 6/6/2012
update c
set text17 = substring(udefdata,charindex('CN/',udefdata)+12,7)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like '%ACECRF//%CN%' and isnull(text17,'N/A') = 'N/A'

-------- Update Text6 with T24 Flag ------- LOC/3/22/2013
update c
set text6 =  substring(udefdata,13,5)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like '%acecrm/mngr%' and udefdata not like '(C)RM*ACECRM/MNGR-<T24>'
and text6 is null

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs'and recordkey like '%GLZWR3100-%'and text18 is null

-------- Update Text7 with Project Code -------------LOC/11/12/2012
--update c
--set text7 = substring(udefdata,charindex('CN/',udefdata)+12,7)
--from dba.comrmks c, dba.udef u
--where c.recordkey = u.recordkey and c.seqnum = u.seqnum
--and c.iatanum = 'preubs'
--and substring(c.recordkey,15,charindex('-',c.recordkey)-15) = 'GLZWR3100'
--and udefdata like '%ACECRF%' and isnull(text7,'N/A') = 'N/A'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation GLZWR3100-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%GLZWR3100-%' and udefdata like '%ACECRF//%' and text22 is null

-------Update Text23 = Trip Purpose String ---------------------- LOC 5/31/2012
update c
set text23 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%GLZWR3100-%' 
and udefdata like '%ACECRM/TR REA-%' and text23 is null

-------Update Text24 = Cost Center String ---------------------- LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like '%acecrf//%' and right(udefdata,charindex('/',udefdata)-2) not like '%/%'
and text24 is null

-------Update Text25 = GPN String --------------------------- LOC 5/31/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%GLZWR3100-%' and udefdata like '%ACESV1%' and text25 is null

-------Update Text26 = HtlReasonCode1 String ---------------- LOC 5/31/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%GLZWR3100-%' and udefdata like 'HOTEL REASON CODE%' and text26 is null

-------Update Text27 = TractID String --------------------------- LOC 5/31/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%GLZWR3100-%' and udefdata like '%ACECRF//%' and text27 is null

-------Update Text29 = GPN String --------------------------- LOC 5/31/2012
update c
set text29 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%GLZWR3100-%' and udefdata like '%acecrm/app nm-%' and text29 is null
and u.udeftype='RM OTHER'

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47=substring(udefdata,charindex('/S',udefdata)-2,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%GLZWR3100-%' and udefdata like 'acesv2%' and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End GLZWR3100-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
