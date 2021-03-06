/****** Object:  StoredProcedure [dbo].[sp_PREUBS3AT_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS3AT_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 3AT-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='ZA'
where iatanum ='PREUBS' and recordkey like'%3AT-%' and (origcountry is null
or origcountry ='XX') 

-------- Update onlinebookingsystem with udefdata -------- LOC/12/19/2012
update i
set onlinebookingsystem = substring(udefdata,9,5)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum and i.iatanum = 'preubs'
and udefdata like '%A23-OAI*%'
and u.recordkey like'%3AT-%' and onlinebookingsystem is null
and substring(udefdata,9,5) in (select lookupvalue from dba.lookupdata where lookupname = 'online')


---Update Trip Purpose from UDEF/ 'ROT*%' #49290 1/6/2015
update c
set Remarks1 = substring(udefdata,5,2)
from dba.invoicedetail c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'ROT*%' and Remarks1 is null


--Remarks 2 with GPN
Update i
set Remarks2 = substring(u.udefdata,4,8) 
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.recordkey = u.recordkey
and i.iatanum = 'preubs'and u.recordkey like'%3AT-%' and udefdata like 'EN*%' and isnull(remarks2,'Unknown') = 'Unknown'

Update i
set Remarks2 = substring(u.udefdata,8,8) 
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.recordkey = u.recordkey
and i.iatanum = 'preubs'and u.recordkey like'%3AT-%' and udefdata like 'A15-EN*%' and isnull(remarks2,'Unknown') = 'Unknown'

--Remarks 5 with Cost Center
update c
set Remarks5 = substring(udefdata,4,5)
from dba.invoicedetail c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'CC*%' and Remarks5 <>substring(udefdata,4,5)

--Air ReasonCode from UDEF if not parsed in ETL #49290 1/6/2015
update c
set reasoncode1 = substring(udefdata,5,2)
from dba.invoicedetail c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'ARD*%' and reasoncode1 is null

--hotel ReasonCode from UDEF if not parsed in ETL #49290 1/6/2015
update c
set htlreasoncode1 = substring(udefdata,5,2)
from dba.hotel c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'hrc*%' and htlreasoncode1 is null

-------- Update Text6 with T24 Flag -------- LOC/3/22/2013
--Updated per Ryan 49290 1/6/2015
update c
set text6= substring(udefdata,4,1)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like'%3AT-%' and udefdata like 'MS*%' and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 3AT-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Approver GPN
update c
set text14 = substring(udefdata,4,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.recordkey like'%3AT-%' and udefdata like 'AP*%' 
and udefdata not in ('AP*0','AP*TEST')
and text14 is null

--Tract ID
update c
set text17 = substring(udefdata,8,7)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.recordkey like'%3AT-%' and udefdata like 'A23-OR*%' and udefdata not like 'A23-OR*0%'

-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'EN*%' and text22 is null

-------Update Text23 = Trip Purpose String ------------------ LOC 5/31/2012
--changed to 'ROT*%' #49290 1/6/2015
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'ROT*%' and text23 is null

-------Update Text24 = Cost Center String ------------------ LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'CC*%' and text24 is null

-------Update Text25 = Air ReasonCode1 String ------------------ LOC 5/31/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'A19-ARD%' and text25 is null

update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'ARD*%' and text25 is null

-------Update Text26 = HtlReasonCode1 string---------------- LOC 5/31/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'A20-HRC%' and text26 is null

--additional logic added 49290 1/9/2015
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'HRC*%' and text26 is null

---------Update Text27 = TractID---------------- LOC 5/31/2012
-----Received Mapping from Ryan via email on 10/4/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like'%3AT-%' and udefdata like 'A23-OR*%'
and udefdata not like 'A23-OR*0%' and text27 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 3AT-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
