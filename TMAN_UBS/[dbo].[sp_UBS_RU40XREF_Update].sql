/****** Object:  StoredProcedure [dbo].[sp_UBS_RU40XREF_Update]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_RU40XREF_Update]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'xref'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

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

 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='RUXREF -Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

--Truncate  table dba.ru40xref

INSERT INTO DBA.RU40XREF
select Costructid,CorporateStructure,CorporateStructure,substring(Description,1,50),Description
from dba.rollup40
where costructid = 'Functional'  

union

select Costructid,CorporateStructure,rollup8,substring(Description,1,50),RollupDesc8
from dba.rollup40
where costructid = 'Functional'  
and rollup8 <> rollup9

union

select Costructid,CorporateStructure,rollup7,substring(Description,1,50),RollupDesc7
from dba.rollup40
where costructid = 'Functional'  
and rollup7 <> rollup8

union

select Costructid,CorporateStructure,rollup6,substring(Description,1,50),RollupDesc6
from dba.rollup40
where costructid = 'Functional'  
and rollup6 <> rollup7

union

select Costructid,CorporateStructure,rollup5,substring(Description,1,50),RollupDesc5
from dba.rollup40
where costructid = 'Functional'  
and rollup5 <> rollup6

union

select Costructid,CorporateStructure,rollup4,substring(Description,1,50),RollupDesc4
from dba.rollup40
where costructid = 'Functional'  
and rollup4 <> rollup5

union

select Costructid,CorporateStructure,rollup3,substring(Description,1,50),RollupDesc3
from dba.rollup40
where costructid = 'Functional'  
and rollup3 <> rollup4

union

select Costructid,CorporateStructure,rollup2,substring(Description,1,50),RollupDesc2
from dba.rollup40
where costructid = 'Functional'  
and rollup2 <> rollup3

union

select Costructid,CorporateStructure,rollup1,substring(Description,1,50),RollupDesc1
from dba.rollup40
where costructid = 'Functional'  
and rollup1 <> rollup2

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='RUXREF -Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
