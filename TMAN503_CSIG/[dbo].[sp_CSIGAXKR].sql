/****** Object:  StoredProcedure [dbo].[sp_CSIGAXKR]    Script Date: 7/14/2015 8:00:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CSIGAXKR] 

	@BeginIssueDate	datetime,
	@EndIssueDate	datetime

AS
--

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CSIGAXKR'
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

SET @TransStart = getdate()
update dba.ccheader
set importdate = rptcreatedate
where iatanum ='CSIGAXKR'
and importdate is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='importdate = rptcreatedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--
--select *
--from dba.ccheader
--where importdate >'2012-05-01'
GO
