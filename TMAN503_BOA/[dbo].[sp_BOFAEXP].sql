/****** Object:  StoredProcedure [dbo].[sp_BOFAEXP]    Script Date: 7/14/2015 7:50:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_BOFAEXP]
AS

SET NOCOUNT ON



/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_BOFAEXP]
************************************************************************/
--R. Robinson modified added time to stepname
declare @TransStart DATETIME declare @ProcName varchar(50)
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



--Update matched expense data per case 00009760
--Added on 1/28/13 by Nina
--Updated on 2/6/13 by Nina per case 00009760
BEGIN TRAN
update ex
set ex.MatchedInd = 'Y'
,ex.MatchedIataNum = cc.IataNum
,ex.MatchedClientCode = cc.ClientCode
,ex.MatchedRecordKey = cc.RecordKey
from dba.ccheader cc, dba.expensedata ex
where cc.TransactionNum = ex.reference_number 
and RIGHT('0000000000' + cc.Remarks12, 10) = ex.seqnum
and ex.MatchedInd is NULL
and cc.IataNum in ('BOFACCVI')
COMMIT TRAN

--Update matched expense data for Amex cc data 
--Added on 7/2/14 by Nina per case 00039972
BEGIN TRAN
update ex
set ex.MatchedInd = 'Y'
,ex.MatchedIataNum = cc.IataNum
,ex.MatchedClientCode = cc.ClientCode
,ex.MatchedRecordKey = cc.RecordKey
from dba.ccheader cc, dba.expensedata ex
where cc.RecordKey = ex.reference_number 
--and cc.TransactionDate = ex.Transactiondate
and cc.EmployeeId = ex.Employee_ID
and ex.MatchedInd is NULL
and cc.IataNum in ('BOFAAXCC')
COMMIT TRAN


--Update matched expense data for Mastercard cc data 
--Added on 8/4/14 by Eddie
BEGIN TRAN
update ex
set ex.MatchedInd = 'Y'
,ex.MatchedIataNum = cc.IataNum
,ex.MatchedClientCode = cc.ClientCode
,ex.MatchedRecordKey = cc.RecordKey
from dba.ccheader cc, dba.expensedata ex
where cc.TransactionID = ex.reference_number 
--and cc.TransactionDate = ex.Transactiondate
and cc.EmployeeId = ex.Employee_ID
and ex.MatchedInd is NULL
and ex.Payment_Type like '%Mas%'
and cc.IataNum in ('BOFACCMC')
COMMIT TRAN


--Added on 5/3/13 by Nina per case 00014164
BEGIN TRAN
update id
set id.CCMatchedRecordKey = ex.MatchedRecordKey
,id.MatchedInd = '9'
from dba.expensedata ex, dba.InvoiceDetail id, dba.ComRmks cr
where ex.Employee_ID = cr.Text1 
and cr.IssueDate = ex.TransactionDate
and ex.TransactionDate = id.IssueDate
and cr.RecordKey = id.RecordKey 
and ex.Expense_Amount = id.TotalAmt 
and id.MatchedInd is null 
and ex.MatchedRecordKey is not null
COMMIT TRAN

BEGIN TRAN
update cch
set cch.matchedind = '9'
,cch.MatchedRecordKey = id.RecordKey
,cch.MatchedIataNum = id.IataNum
,cch.MatchedSeqNum = id.SeqNum
,cch.MatchedClientCode = id.ClientCode
,cch.CarHtlSeqNum = id.SeqNum
from dba.CCHeader cch, dba.InvoiceDetail id
where cch.RecordKey = id.CCMatchedRecordKey
and cch.IataNum in ('BOFACCVI','BOFAAXCC','BOFACCMC')
and id.MatchedInd = '9'
and cch.MatchedInd is null
and id.CCMatchedRecordKey is not null
and cch.MatchedRecordKey is null
COMMIT TRAN

BEGIN TRAN
Update cct
set cct.MatchedRecordKey = cch.MatchedRecordKey
,cct.MatchedIataNum = cch.MatchedIataNum
,cct.MatchedSeqNum = cch.MatchedSeqNum
,cct.MatchedClientCode = cch.MatchedClientCode
from dba.CCTicket cct, dba.CCHeader cch
where cct.recordkey = cch.recordkey
and cch.IataNum in ('BOFACCVI','BOFAAXCC','BOFACCMC')
and cch.IataNum = cct.IataNum
and cct.MatchedRecordKey is null
and cch.MatchedInd = '9'
and cch.MatchedRecordKey is not null
COMMIT TRAN

BEGIN TRAN
Update cct
set cct.MatchedRecordKey = cch.MatchedRecordKey
,cct.MatchedIataNum = cch.MatchedIataNum
,cct.MatchedSeqNum = cch.MatchedSeqNum
,cct.MatchedClientCode = cch.MatchedClientCode
from dba.CCCar cct, dba.CCHeader cch
where cct.recordkey = cch.recordkey
and cch.IataNum in ('BOFACCVI','BOFAAXCC','BOFACCMC')
and cch.IataNum = cct.IataNum
and cct.MatchedRecordKey is null
and cch.MatchedInd = '9'
and cch.MatchedRecordKey is not null
COMMIT TRAN

BEGIN TRAN
Update cct
set cct.MatchedRecordKey = cch.MatchedRecordKey
,cct.MatchedIataNum = cch.MatchedIataNum
,cct.MatchedSeqNum = cch.MatchedSeqNum
,cct.MatchedClientCode = cch.MatchedClientCode
from dba.CCHotel cct, dba.CCHeader cch
where cct.recordkey = cch.recordkey
and cch.IataNum in ('BOFACCVI','BOFAAXCC','BOFACCMC')
and cch.IataNum = cct.IataNum
and cct.MatchedRecordKey is null
and cch.MatchedInd = '9'
and cch.MatchedRecordKey is not null
COMMIT TRAN



BEGIN TRAN
update ex 
set ex.corpstructure = ex.allocated_company_cost_center,
ex.allocated_company_cost_center = '9999999999'
from dba.expensedata ex 
where ex.allocated_company_cost_center not in (select distinct corporatestructure
from dba.rollup40 where costructid in ('10 Dot','91 Hierarchy'))
COMMIT TRAN

BEGIN TRAN
update ex 
set  ex.allocated_company_cost_center = ex.corpstructure 
from dba.expensedata ex, dba.ROLLUP40 ru
where ex.corpstructure = ru.CORPORATESTRUCTURE 
and ru.costructid in ( '10 Dot', '91 Hierarchy')
and ex.allocated_company_cost_center = '9999999999'
and ex.corpstructure <> '9999999999'
and ru.CORPORATESTRUCTURE <> '9999999999'

COMMIT TRAN



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
