/****** Object:  StoredProcedure [dbo].[sp_PREUBSFP70_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PREUBSFP70_Post_Import_Update]

AS
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start FP70-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


-------- Update Remarks2 with GPN  from UDID 91 --------- LOC/9/25/2012
update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' 
and  udefdata like 'U*91-%'
and isnull(remarks2,'Unknown') = 'Unknown'
and i.recordkey like '%FP70-%'

-------- Update Air Policy .. need to determine how we are pulling from U*41?

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation FP70-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Update Text22 = GPN String --------------------------- LOC 9/25/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'U*91-' and text22 is null
and c.recordkey like '%FP70-%'

-------- Hard coding data same as post trip ------ LOC /12/11/2012

 -- Update remarks1 for Trip Purpose default
update i
set i.remarks1 = 'DI'
from dba.invoicedetail i
where  i.recordkey like '%FP70-%' and remarks1 is null and iatanum = 'preubs'

-- Update  ReasonCode1
update i
set reasoncode1 = 'A5'
from dba.invoicedetail i
where i.recordkey like '%FP70-%' and reasoncode1 is null and iatanum = 'preubs'

----Update HtlReasonCode1 
update h
set htlreasoncode1 = 'H3'
from dba.hotel h
where h.recordkey like '%FP70-%' and htlreasoncode1 is null  and iatanum = 'preubs'

--- Update Onlinebookingsystem to "OffLine"
update i
set onlinebookingsystem = 'OFFLINE'
from dba.invoicedetail i
where i.recordkey like '%FP70-%' and onlinebookingsystem is null and iatanum = 'preubs'

------- Update Text18 (online reason code) with N/A as they do not book online-----LOC 8/3/2012
update dba.comrmks
set text18 = 'N/A'
where recordkey like '%FP70-%' and text18 is null and iatanum = 'preubs'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End FP70-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN 'PREUBSFP70'

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 













GO
