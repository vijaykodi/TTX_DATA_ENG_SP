/****** Object:  StoredProcedure [dbo].[sp_CIEBOAExp]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CIEBOAExp] 
@BeginIssueDate datetime = null,
@EndIssueDate datetime = null

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CIEBOAExp'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    



 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CIEBOAExp]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/ 


--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOAExp Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------Update matched fields from CC Header -------- LOC/3/26/2013
update e
set e.ccmatchedrecordkey = c.recordkey, e.ccmatchediatanum = c.iatanum, e.ccmatchedclientcode = c.clientcode,
e.tmcmatchedrecordkey = c.matchedrecordkey,  e.tmcmatchediatanum = c.matchediatanum,
e.tmcmatchedclientcode = c.matchedclientcode
from dba.ExpenseReportDetail e, dba.ccheader c
where e.CreditCardTransReferenceNumber = c.TransactionID
and amount = billedamt and e.tmcmatchedrecordkey is null

-------- Update where the sum of the Expense Amount = Billed Amount)--LOC/3/26/2013
update e
set e.ccmatchedrecordkey = c.recordkey, e.ccmatchediatanum = c.iatanum, e.ccmatchedclientcode = c.clientcode,
e.tmcmatchedrecordkey = c.matchedrecordkey,  e.tmcmatchediatanum = c.matchediatanum,
e.tmcmatchedclientcode = c.matchedclientcode, ccmatchedseqnum = 1 
from dba.ExpenseReportDetail e, dba.ccheader c
where e.CreditCardTransReferenceNumber = c.TransactionID
and e.CreditCardTransReferenceNumber in
(select TransactionID--, sum(amount) 
from dba.ExpenseReportDetail e, dba.ccheader c
where e.CreditCardTransReferenceNumber = c.TransactionID
and ccmatchedrecordkey is null
group by TransactionID,billedamt
having sum(amount) = billedamt)

--update employee ID to be 5 digits with leading 00s--
update dba.ExpenseReportHeader
set EmployeeID = '0000'+EmployeeID
where LEN(employeeid) = 1

update dba.ExpenseReportHeader
set EmployeeID = '000'+EmployeeID
where LEN(employeeid) = 2

update dba.ExpenseReportHeader
set EmployeeID = '00'+EmployeeID
where LEN(employeeid) = 3

update dba.ExpenseReportHeader
set EmployeeID = '0'+EmployeeID
where LEN(employeeid) = 4


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOAExp Update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Category Type, Distribution, and Vendor --- What updates do we need to do


 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/
GO
