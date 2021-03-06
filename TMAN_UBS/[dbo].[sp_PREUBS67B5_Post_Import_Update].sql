/****** Object:  StoredProcedure [dbo].[sp_PREUBS67B5_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS67B5_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 67B5-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='CH'
where iatanum ='PREUBS' and recordkey like '%67B5-%' and (origcountry is null or origcountry ='XX')

UPDATE id
SET id.reasoncode1 = RIGHT(RTRIM(UD.UDEFDATA), 2)
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,1)
FROM DBA.UDEF UD, DBA.INVOICEDETAIL ID
WHERE ID.RECORDKEY = UD.RECORDKEY AND ID.IATANUM = UD.IATANUM AND ID.CLIENTCODE = UD.CLIENTCODE
AND UD.UDEFTYPE = 'AIRREASONCD' AND UD.RECORDKEY LIKE '%67B5-%' AND SUBSTRING(UD.UDEFDATA,1,1) LIKE 'U%'

UPDATE HTL
SET HTL.HTLREASONCODE1 = RIGHT(RTRIM(UD.UDEFDATA), 2)
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY AND HTL.IATANUM = UD.IATANUM
AND HTL.seqnum = UD.seqnum AND HTL.RECORDKEY LIKE '%67B5-%' AND udefdata LIKE 'HV1%U%'
and isnull(htlreasoncode1,'') not in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')
and RIGHT(RTRIM(UD.UDEFDATA), 2) in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')

--- Update TractID (Text17) incase DB processing does not -----
update c
set text17 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'CRM/NOPER-%' and isnull(text17,'N/A') ='N/A'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 67B5-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5' and udefdata like 'CRM/NOAPP-%' and text29 is null

-------Update Text27 = TractID String --------------------------- LOC 5/25/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'CRM/NOPER-%' and text27 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/25/2012
update c
set text26 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'HV1%' and text26 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/25/2012
update c
set text25 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'LF%' and text25 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/25/2012
update c
set text23 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'CRM/NOBUD-%' and text23 is null

-------Update Text22 = GPN String --------------------------- LOC 5/25/2012
update c
set text22 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'CRM/ININF-%' and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/25/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%67B5-%' and udefdata like 'CRM/COST2-%' and text24 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 67B5-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
