/****** Object:  StoredProcedure [dbo].[sp_PREUBSC8R2_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[sp_PREUBSC8R2_Post_Import_Update]

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
--Create new sp for C8R2, data from Maritz - copy sp for FP70 to mirror updates #55054 1/17/2015
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start C8R2-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


-------- Update Remarks2 with GPN  from UDID 91 --------- 
update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' 
and  udefdata like 'U*91-%'
and isnull(remarks2,'Unknown') = 'Unknown'
and i.recordkey like '%C8R2-%'

-------- Update Air Policy .. need to determine how we are pulling from U*41?

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation C8R2-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Update Text22 = GPN String --------------------------- 
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'U*91-' and text22 is null
and c.recordkey like '%C8R2-%'

-------- Hard coding data same as post trip ------ 

 -- Update remarks1 for Trip Purpose default
update i
set i.remarks1 = 'DI'
from dba.invoicedetail i
where  i.recordkey like '%C8R2-%' and remarks1 is null and iatanum = 'preubs'

-- Update  ReasonCode1
update i
set reasoncode1 = 'A5'
from dba.invoicedetail i
where i.recordkey like '%C8R2-%' and reasoncode1 is null and iatanum = 'preubs'

----Update HtlReasonCode1 
update h
set htlreasoncode1 = 'H3'
from dba.hotel h
where h.recordkey like '%C8R2-%' and htlreasoncode1 is null  and iatanum = 'preubs'

--- Update Onlinebookingsystem to "OffLine"
update i
set onlinebookingsystem = 'OFFLINE'
from dba.invoicedetail i
where i.recordkey like '%C8R2-%' and onlinebookingsystem is null and iatanum = 'preubs'

------- Update Text18 (online reason code) with N/A as they do not book online-----
update dba.comrmks
set text18 = 'N/A'
where recordkey like '%C8R2-%' and text18 is null and iatanum = 'preubs'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End C8R2-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 













GO
