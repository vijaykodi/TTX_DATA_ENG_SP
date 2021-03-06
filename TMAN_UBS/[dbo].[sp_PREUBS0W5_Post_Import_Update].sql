/****** Object:  StoredProcedure [dbo].[sp_PREUBS0W5_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS0W5_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()
--=================================
--Added by rcr  07/13/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(50)
--==------------------------------------------------------------------------------------------------------------------------------

/************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity
 ----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----
/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Log Activity
--Added by rcr  07/13/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 0W5-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-Stored Procedure Start 0W5-% '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='ZA'
where iatanum ='PREUBS' and recordkey like'%0W5-%' and (origcountry is null or origcountry ='XX')
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update ih.origcountry if NULL '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
------ Update Text8 with Booker GPN -----------------------LOC 5/8/2012
------ Update per case #19007 --- Tbo 7/30/2013
update c
set text8 = substring(udefdata,9,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.recordkey like'%0W5-%' and udefdata like '%a16%'
and isnull(text8,'Not') like 'Not%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text8 with Booker GPN '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
----- Update Text14 with approver GPN -----------------LOC 5/8/2012
------ Update per case #19007 --- Tbo 7/30/2013

update c
set text14 = substring(udefdata,8,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.recordkey like'%0W5-%' and udefdata like '%a17-ap*%'
and isnull(text8,'Not') like 'Not%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text14 with approver GPN '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs'  and c.recordkey like'%0W5-%' 

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 0w5-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Begin Update to Comrmks for Validation 0w5-%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text22 = GPN String --------------------------- LOC 6/1/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = 'preubs'
and c.recordkey like'%0W5-%' and udefdata like 'A15-EN%' and text22 is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text22 = GPN String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text23 = Trip Purpose String --------------------------- LOC 6/1/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = 'preubs'
and c.recordkey like'%0W5-%' and udefdata like 'A13-ROT%' and text23 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text23 = Trip Purpose String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text24 = Cost Center String --------------------------- LOC 6/1/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = 'preubs'
and c.recordkey like'%0W5-%' and udefdata like 'A14-CC%' and text24 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text24 = Cost Center String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = 'preubs'
and c.recordkey like'%0W5-%' and udefdata like 'A19-ARD%' and text25 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text25 = Air ReasonCode1 String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and c.recordkey like'%0W5-%' and udefdata like 'A20-HRC%' and text26 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text26 = HtlReasonCode1 String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text28 = Booker GPN String --------------------------- LOC 6/1/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and c.recordkey like'%0W5-%' and udefdata like '%A16%' and text28 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text28 = Booker GPN String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text29 = Approver GPN String --------------------------- LOC 6/1/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and c.recordkey like'%0W5-%' and udefdata like '%A17-AP*%' and text29 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 0W5-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 2-Stored Procedure End 0W5-%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN

 
 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity

WAITFOR DELAY '00:00.30' 
--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  




GO
