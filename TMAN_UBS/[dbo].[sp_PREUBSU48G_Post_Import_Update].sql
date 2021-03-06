/****** Object:  StoredProcedure [dbo].[sp_PREUBSU48G_Post_Import_Update]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSU48G_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start U48G--',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='MX'
where iatanum ='PREUBS' and recordkey like '%U48G-%' and (origcountry is null
or origcountry ='XX')


-------Update Air ReasonCode1 if not done via parsing
update c
set reasoncode1 = substring(udefdata,3,2)
from dba.invoicedetail c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like '%FJ%' and udeftype = '5.S*' 
and reasoncode1 is null

-- Update Text 18 with Online Reason Code ------------------ LOC 6/12/12
update c
set text18 = substring(udefdata,6,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%U48G-%' and udefdata like 'U*71-%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')
and text18 is null

-- Update Text8 with Booker GPN ------------------ LOC 8/29/12
update c
set text8 = substring(udefdata,6,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*64-%' and ((text8 is null) or (text8 like 'Not%'))

-- Update Text17 TRACTID ------------------ LOC 9/13/12
update c
set text17 = substring(udefdata,6,7)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*65-%' and isnull(text17,'N/A') ='N/A'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation U48G-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 6/1/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*46-%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 6/1/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*62-%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 6/1/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*45-%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like '%FJ%' and udeftype = '5.S*' and text25 is null

-------Update Text26 = HtlReasonCode String --------------------------- LOC 6/1/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*40-%' and text26 is null

-- Update Text 13 with Online Reason Code String ------------------ LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udeftype = 'Z G5 REMARKS' and text13 is null

-- Update Text28 with Booker GPN String----------------- LOC 8/29/12
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like  'U*64-%' and text28 is null

-- Update Text27 TRACTID GPN ------------------ LOC 8/29/12
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%U48G-%' and udefdata like 'U*65-%' and text27 is null 

-------- Update Text6 with T-24 Flag -------- LOC/3/19/2013
---- commenting out the validation piece until we hear from Ryan .. just sending as is..loc/3/19/2013
update c
set text6 = substring(udefdata,6,3)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%U48G-%' and udefdata like 'U*73%'  --and substring(udefdata,6,3) in ('Yes','No') 
and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End U48G-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
