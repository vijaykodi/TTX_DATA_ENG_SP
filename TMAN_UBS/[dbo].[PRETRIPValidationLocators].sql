/****** Object:  StoredProcedure [dbo].[PRETRIPValidationLocators]    Script Date: 7/14/2015 7:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[PRETRIPValidationLocators] 
as 

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime, @LogSegNbr int = 0
, @LogStep varchar(250)

	SET @Iata = 'NOIATA'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

	--=================================
	--Added by rcr  06/30/2015
	--Adding two variables for logging.
	--
	--@LogSegNbr is an incremented number that is automatically generated to show 
	--the actual number of Logged Segments within a stored procedure.
	--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
	--Example: 'Stored Procedure Started logging'
	--=================================
	DECLARE @LocalBeginIssueDate DATETIME = GETDATE(), @LocalEndIssueDate DATETIME = GETDATE()
	  

--Log Activity
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

begin

delete from  dba.PRETRIPValidationLocators 
where PNRlocator is null

--========================
--Added by rcr  06/30/2015
--========================
-- update with today date for new PNRs
update dba.PRETRIPValidationLocators 
set receivedate =DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
, PNRQueueDate = DATEADD(dd, -1, DATEDIFF(dd, 0, GETDATE()))
,AgencyCustomerName = 'UBS'
where receivedate is null
and PNRQueueDate is null


--========================
--Added by rcr  06/30/2015
--========================
SET @TransStart = Getdate() 
WAITFOR DELAY '00:00.30'
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') PRETRIPValidationLocators'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--========================
--Added by rcr  06/30/2015
--========================
SET @TransStart = Getdate() 

--Lisa's new fields
update dba.PRETRIPValidationLocators 
set ClientCode = 'UBS'
,CtryCode = 'US'
where ClientCode is null


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') PRETRIPValidationLocators - ClientCode'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
--========================


--Added by rcr  06/30/2015
SET @TransStart = Getdate() 

--update SQLServerPNR if it is in PNR_ALL
update  pre
set SQLServerPNR = 'Y'
from dba.PRETRIPValidationLocators  pre inner join TTXSASQL01.TMAN503_Correx.dbo.PNR_ALL pnr
on pnr.LOCATOR = pre.PNRlocator
where pre.SQLServerPNR is null

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') SQLServerPNR = Y'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  06/30/2015
SET @TransStart = Getdate() 

--update others with 'N'
update  pre
set SQLServerPNR = 'N'
from dba.PRETRIPValidationLocators pre 
where pre.SQLServerPNR is null

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') SQLServerPNR = N'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  06/30/2015
SET @TransStart = Getdate() 

update  pre
set STDInvDtl = 'Y'
from dba.PRETRIPValidationLocators  pre inner join TTXSASQL01.TMAN503_Correx.dba.stdinvdtl std
on std.gdsrecordLOCATOR = pre.PNRlocator
where pre.STDInvDtl is null

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STDInvDtl = Y'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
--Added by rcr  06/30/2015
SET @TransStart = Getdate()
 
update  pre
set STDInvDtl = 'N'
from dba.PRETRIPValidationLocators  pre
where pre.STDInvDtl is null

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STDInvDtl = N'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  06/30/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = getdate()

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended Logging'
----
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
end



GO
