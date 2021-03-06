/****** Object:  StoredProcedure [dbo].[sp_PREUBS51LD_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS51LD_Post_Import_Update]

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
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 51LD-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='CN'
where iatanum ='PREUBS' and recordkey like '%51LD-%' and (origcountry is null or origcountry ='XX')

--********************************************************************************************************
-------- Updating the udeftype in the udef FF fields to look at 5 remakrs as this is how the data is coded
------- looks like it has been this way since JUly 2013 however we were just notified .. LOC/6/15/2015
--*********************************************************************************************************

------ Update Remarks2 with FF14/ --------
update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and u.recordkey like '%51LD-%' and udeftype = '5 REMARKS' 
and udefdata like 'FF14/%' and isnull(remarks2,'unknown') = 'Unknown'

------ Update Remarks1- Trip Purpose with ff12 --------
update i
set remarks1 = substring(udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and u.recordkey like '%51LD-%' 
and udeftype = '5 REMARKS' and udefdata like 'FF12/%'
--and remarks1 is NULL -- comment out until Dataman is updated because dataman is wrong

------ Update Remark5- Cost Center with ff16 --------
update i
set remarks5 = substring(udefdata,6,20)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and u.recordkey like '%51LD-%' 
and udeftype = '5 REMARKS' and udefdata like 'FF16/%' and remarks5 is NULL 

------ Update Hotel ReasonCode1 ff19 --------
update h
set htlreasoncode1 = substring(udefdata,6,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%51LD-%' 
and udeftype = '5 REMARKS' and udefdata like 'FF19/%' and htlreasoncode1 is NULL


------ Update ReasonCode1 with ff13 --------
update i
set reasoncode1 = substring(udefdata,7,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and u.recordkey like '%51LD-%' 
and udeftype = '5 REMARKS' and udefdata like 'FF13/%' and reasoncode1 is NULL 

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
update c
set text18 = 'N/A'
from dba.comrmks c
where c.iatanum = 'preubs' and c.recordkey like '%51LD-%'  and text18 is null

----- Update Text8 with Booker GPN -- LOC/9/4/2012
update c
set text8 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%51LD-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF17%'

----- Update Text14 with Approver GPN -- LOC/9/4/2012
update c
set text14 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%51LD-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text14,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF20%'

-- Update Text7 with Project Code ------ LOC/11/20/2012
update c
set text7 = substring(udefdata,6,10)
from dba.udef u, dba.comrmks c
where u.recordkey like '%51LD-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text7,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF18%'

-- Update Text17 with TractID ------ LOC/11/20/2012
update c
set text17 = substring(udefdata,6,10)
from dba.udef u, dba.comrmks c
where u.recordkey like '%51LD-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text17,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF15%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 51LD-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text22 =GPN String --------------------------- LOC 5/29/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udeftype = '5 REMARKS' and udefdata like 'FF14/%'
and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udeftype = '5 REMARKS' and udefdata like 'FF12/%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udeftype = '5 REMARKS' and udefdata like 'FF16/%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udeftype = '5 REMARKS' and udefdata like 'FF13/%' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udeftype = '5 REMARKS' and udefdata like 'FF19/%' and text26 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 9/4/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udefdata like 'FF17/%' and text28 is null 

-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%51LD-%' and udefdata like 'FF20/%' and text29 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 51LD-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
