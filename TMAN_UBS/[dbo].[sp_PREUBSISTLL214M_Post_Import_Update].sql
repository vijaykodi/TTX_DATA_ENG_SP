/****** Object:  StoredProcedure [dbo].[sp_PREUBSISTLL214M_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSISTLL214M_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start ISTLL214M-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='TR'
where iatanum ='PREUBS'
and recordkey like '%ISTLL214M-%' and (origcountry is null or origcountry ='XX')

------ Update Text14 with Approver GPN --------------- LOC 5/8/2012---------------
update c
set text14 = substring(udefdata,5,8)
from dba.udef u, dba.comrmks c
where u.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%ISTLL214M-%' and udefdata like '%apn-%' and text14 is null

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%ISTLL214M-%' and text18 is null

-------- Update Text7 with Project Code -------- LOC/11/12/2012
update c
set text7 = substring(udefdata,5,10)
from dba.udef u, dba.comrmks c
where u.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%ISTLL214M-%' and udefdata like '%pjn-%' and text7 is null

-------- Update Text17 with TractID from udef ---- LOC/8/16/2012
update c
set text17 = substring(udefdata,5,7)
from dba.udef u, dba.comrmks c where u.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%ISTLL214M-%' and isnull(text17,'N/A') = 'N/A' and udefdata like 'orn-%'

-------- Update Text6 with T24 Flag --- LOC/3/22/2013

update c
set text6= substring(udefdata,5,3)
from dba.udef u, dba.comrmks c where u.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%ISTLL214M-%' and udefdata like '%msp-%' and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation ISTLL214M-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%ISTLL214M-%' and udefdata like 'EMP-%' and text22 is null

-------Update Text23 = Trip Purpose String ------------------ LOC 5/31/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%ISTLL214M-%' and udefdata like 'RST-%' and text23 is null

-------Update Text24 = Cost Center String ------------------ LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%ISTLL214M-%' and udefdata like 'CCT-%' and text24 is null

-------Update Text25 = Air ReasonCode1 String ------------------ LOC 5/31/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%ISTLL214M-%' and udefdata like 'RCD-%' and text25 is null

-------Update Text26 = HtlReasonCode1 String ------------------ LOC 5/31/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%ISTLL214M-%' and udefdata like 'HR-%' and text26 is null

-------Update Text29 = Approver GPN String ------------------ LOC 5/31/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%ISTLL214M-%' and udefdata like '%apn-%' and text29 is null

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= right(udefdata,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%ISTLL214M-%' and udefdata like 'rco%' and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End ISTLL214M-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
