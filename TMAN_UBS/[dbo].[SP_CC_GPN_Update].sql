/****** Object:  StoredProcedure [dbo].[SP_CC_GPN_Update]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CC_GPN_Update]
AS

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

--=================================
--Added by rcr  07/08/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @Iata varchar(50)
--, @ProcName varchar(50)
----, @TransStart datetime
--, @BeginIssueDate datetime
--, @ENDIssueDate datetime
, @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)

SET @Iata = 'UBSAXCC'
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------

--Log Activity
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started Logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--

update dba.CCHeader
set EmployeeId = '80704073'
where CreditCardNum =  '378297172051209' 
and IataNum = 'UBSAXCC'


----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update dba.CCHeader'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update dba.CCTicket
set EmployeeId = '80704073'
where TktOriginatingCCNum =  '378297172051209' 
and IataNum = 'UBSAXCC'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update dba.CCTicket'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update dba.CCcar
set EmployeeId = '80704073'
where CarOriginatingCCNum =  '378297172051209' 
and IataNum = 'UBSAXCC'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update dba.CCar'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
		
--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update dba.CCHotel
set EmployeeId = '80704073'
where HTLOriginatingCCNum =  '378297172051209' 
and IataNum = 'UBSAXCC'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update dba.CCHotel'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update cchdrn
set EmployeeId = cchdrm.EmployeeId
from dba.CCHeader cchdrm, dba.CCHeader cchdrn
where cchdrm.CreditCardNum = cchdrn.CreditCardNum
and cchdrm.EmployeeId is not null
and cchdrn.EmployeeId is null
and cchdrn.iatanum = 'UBSAXCC'
and cchdrn.iatanum = 'UBSAXCC'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update cchdrn'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update cctktn
set EmployeeId = cctktm.EmployeeId
from dba.CCticket cctktm, dba.CCticket cctktn
where cctktm.TktOriginatingCCNum = cctktn.TktOriginatingCCNum
and cctktm.EmployeeId is not null
and cctktn.EmployeeId is null
and cctktm.iatanum = 'UBSAXCC'
and cctktn.iatanum = 'UBSAXCC'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update cctktn'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

	---START HERE 0708215  RCR---
--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update cccarn
set EmployeeId = cccarm.EmployeeId
from dba.CCcar cccarm, dba.CCcar cccarn
where cccarm.CarOriginatingCCNum = cccarn.CarOriginatingCCNum
and cccarm.EmployeeId is not null
and cccarn.EmployeeId is null
and cccarm.iatanum = 'UBSAXCC'
and cccarn.iatanum = 'UBSAXCC'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update cctktn'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update cchtln
set EmployeeId = cchtlm.EmployeeId
from dba.CChotel cchtlm, dba.CChotel cchtln
where cchtlm.HTLOriginatingCCNum = cchtln.HTLOriginatingCCNum
and cchtlm.EmployeeId is not null
and cchtln.EmployeeId is null
and cchtlm.iatanum = 'UBSAXCC'
and cchtln.iatanum = 'UBSAXCC'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update cctktn'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update ccexp
set EmployeeId = cchdr.EmployeeId
from dba.CCExpense ccexp, dba.CCheader cchdr
where cchdr.RecordKey = ccexp.RecordKey
and cchdr.IataNum  = ccexp.IataNum
and ccexp.EmployeeId is null
and ccexp.iatanum = 'UBSAXCC'
and cchdr.iatanum = 'UBSAXCC'

 
 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  

GO
