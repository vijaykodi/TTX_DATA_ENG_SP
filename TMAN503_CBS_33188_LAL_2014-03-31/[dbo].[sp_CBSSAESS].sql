/****** Object:  StoredProcedure [dbo].[sp_CBSSAESS]    Script Date: 7/14/2015 7:51:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_CBSSAESS]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CBSSAESS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Added on 2/28/14 by Nina per Case #000
SET @TransStart = getdate()
update ex 
set ex.TMCMatchedRecordkey = id.recordkey, 
ex.TMCMatchedIataNum = id.iatanum, 
ex.TMCMatchedClientCode = id.clientcode, 
ex.TMCMatchedSeqNum = id.seqNum 
from dba.expensereportdetail ex, dba.invoicedetail id 
where 1 = 1 
and ((substring(ex.remarks14,4,11) = id.documentnumber) 
	or(ex.remarks14 = id.documentnumber)) 
and ex.TMCMatchedRecordkey is null 
and ex.transactiontype = 'airfare'
and ex.ExpIataNum = 'CBSSAESS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Added on 2/28/14 by Nina per Case #00031707
SET @TransStart = getdate()
update dba.expensereportheader 
set remarks10 = 'Simon & Schuster' 
where expiatanum = 'CBSSAESS'
and Remarks10 is null
and ImportDate >= getdate()-1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



GO
