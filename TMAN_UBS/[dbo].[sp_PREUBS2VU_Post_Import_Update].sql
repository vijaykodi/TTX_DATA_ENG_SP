/****** Object:  StoredProcedure [dbo].[sp_PREUBS2VU_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS2VU_Post_Import_Update]


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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
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
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 2VU-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-Stored Procedure Start 2VU-'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='CH'
where iatanum ='PREUBS'
and recordkey like '%2VU-%%' and (origcountry is null or origcountry ='XX')
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update ih.origcountry if NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--


UPDATE id
SET id.reasoncode1 = RIGHT(RTRIM(UD.UDEFDATA), 2)
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,1)
FROM DBA.UDEF UD, DBA.INVOICEDETAIL ID
WHERE ID.RECORDKEY = UD.RECORDKEY
AND ID.IATANUM = UD.IATANUM AND ID.CLIENTCODE = UD.CLIENTCODE AND UD.UDEFTYPE = 'AIRREASONCD' 
AND UD.RECORDKEY LIKE '%2VU-%' AND SUBSTRING(UD.UDEFDATA,1,1) LIKE 'U%'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') id.reasoncode1 = RIGHT(RTRIM(UD.UDEFDATA), 2)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
UPDATE HTL
SET HTL.HTLREASONCODE1 = RIGHT(RTRIM(UD.UDEFDATA), 2)
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,1)
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY
AND HTL.IATANUM = UD.IATANUM AND HTL.CLIENTCODE = UD.CLIENTCODE AND UD.UDEFTYPE = 'HTLREASONCD'
AND HTL.RECORDKEY LIKE '%2VU-%' AND SUBSTRING(UD.UDEFDATA,1,1) LIKE 'U%'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') HTL.HTLREASONCODE1 = RIGHT(RTRIM(UD.UDEFDATA), 2)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' 
and recordkey like '%2VU-%'
and text18 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') text18 = N/A'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
--update i
-- set farecompare2 =
--Cast((substring(udefdata,charindex('/NF',udefdata)+3,charindex('/',udefdata)-3)* (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))as decimal)
--from dba.udef u, dba.invoicedetail id ,DBA.Currency CURRBASE,DBA.Currency CURRTO, dba.invoiceheader ih
--where u.recordkey = id.recordkey and u.seqnum = id.seqnum and id.iatanum = 'preubs'
--and substring(id.recordkey,15,charindex('-',id.recordkey)-15) = '2VU'
--and udefdata like 'lf%nf%'
--and CURRTO.CurrCode ='CHF'
--AND ((CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode    AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate
--   AND CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate
--   AND IH.RecordKey = Id.RecordKey AND IH.IataNum = ID.IataNum
--   AND IH.InvoiceDate = ID.InvoiceDate AND CURRBASE.BaseCurrCode = 'USD'))

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 2VU-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Begin Update to Comrmks for Validation 2VU-%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-----------------------------------------------------------------------------------
-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'CRM/NOAPP-%'
and text29 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text29 = Approver GPN String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text27 = TractID String --------------------------- LOC 5/25/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'CRM/NOPER-%'
and text27 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text27 = TractID String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/25/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'HV1%'
and text26 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text26 = HtlReasonCode1 String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/25/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'LF%'
and text25 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text25 = Air ReasonCode1 String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text23 = Trip Purpose String --------------------------- LOC 5/25/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'CRM/NOBUD-%'
and text23 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text23 = Trip Purpose String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text22 = gpn String --------------------------- LOC 5/25/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'CRM/ININF-%'
and text22 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text22 = gpn String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text24 = Cost Center String --------------------------- LOC 5/25/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%2VU-%'
and udefdata like 'CRM/COST2-%'
and text24 is null



--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 2VU-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 2-Stored Procedure End 2VU-% '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN
 
 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Added by rcr  07/10/2015
WAITFOR DELAY '00:00.30' 
SET @TransStart = Getdate() 
--
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/
GO
