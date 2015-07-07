/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 5:04:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Trent Watkins
-- Create date: 5/19/2011
-- Last update: 8/5/2011
-- Description:	Standardized logging and error handling for stored procedures
-- =============================================
CREATE PROCEDURE [dbo].[sp_LogProcErrors] (
	-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
	@ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount int, -- **REQUIRED** Total number of affected rows
	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error int, -- Error Trapping for this procedure
	@LogRowCount int, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message varchar(255), -- The Error Message for this Procedure
	@Error_Type int, -- Used to track where errors are raised inside this procedure
	@Error_Loc int -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [datetime] NOT NULL,
			[LogEnd] [datetime] NOT NULL,
			[RunByUSER] [char](30) NOT NULL,
			[StepName] [varchar](50) NOT NULL,
			[BeginIssueDate] [datetime] NULL,
			[EndIssueDate] [datetime] NULL,
			[IataNum] [varchar](50) NULL,
			[RowCount] [int] NOT NULL,
			[Error] [int] NOT NULL,
			[ErrorMessage] [nvarchar](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql nvarchar(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
	END

INSERT INTO dba.ProcedureLogs (
		ProcedureName
		,LogStart
		,LogEnd
		,RunByUSER
		,StepName
		,BeginIssueDate
		,EndIssueDate
		,IataNum
		,[RowCount]
		,Error
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GetDate()
		,@RunByUSER
		,@StepName
		,@BeginDate
		,@EndDate
		,@IataNum
		,@RowCount
		,@ERR
		,@Error_Message

IF @ERR <> 0
	BEGIN
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END		

GO

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[LoadCostructLoad]    Script Date: 7/7/2015 5:04:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[LoadCostructLoad] @enddate as datetime, @begindate as datetime
as


--Step 1 to delete everything on employee_sanofi except Chattem (comes in separate file)
--done in SSIS

--Step 2 Mover data from Staging DBA.HR_File to Production DBA.Employee_Sanofi
--done in SSIS
--------------------------------------------------------------------------------------
---- Adding Logging per Jim's request in SF 00047318
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'SANHR'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Start Stored Procedure',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------------------------------------------------------------------------------------
--Step 3 Close period for Employee Table  This needs to come from date of file
SET @TransStart = getdate()
UPDATE DBA.Employee
SET EndDate = dateadd(d,-1,@begindate)
WHERE EndDate = '2099-12-31'
AND OrganizationUnit <> 'chattem'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 3 -Set EndDate',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--Step 4 Insert into DBA.Employee from DBA.Employee_Sanofi for all except Chattem
--If we have issues with dupes again, we will need to delete the duplicate Chattem employees from DBA.Employee

SET @TransStart = getdate()
insert into dba.employee
select left(convergenceID,20) AS EmployeeId1
,left(UPPER(LastName),35) AS LastName
,left(UPPER(FirstName),25) AS FirstName
,left(UPPER(MiddleName),15) AS MiddleName
,emailaddress AS EMPEmail
, Remote AS EmployeeType
,EmploymentStatus AS EmployeeStatus
,left(localid,20) AS EmployeeId2
,null AS BusinessAddress
,null AS BusinessCity
,null AS BusinessStateCd
,null AS BusinessCountry
,null AS BusinessRegion
,left(managerconvergenceid,20) as supervisorid
,left(UPPER(managerfirstname),25) AS SuroervisorFirstName
,left(UPPER(managerlastname),35) AS SupervisorLastName
,manageremailaddress AS SupervisorEmail
,costcenter AS CostCenter
,null AS DeptNumber
,null,businessUnit as organizationunit
,entitydescription as company
,null AS AdditionalInfo1
,null AS AdditionalInfo2
,null AS AdditionalInfo3
,null AS AdditionalInfo4
,null AS AdditionalInfo5
,null AS AdditionalInfo6
,null AS AdditionalInfo7
,null AS AdditionalInfo8
,null AS AdditionalInfo9
,null AS AdditionalInfo10
,@begindate as begindate --This needs to come from date of file
, '2099-12-31' as enddate
, getdate() as importdate
from dba.employee_sanofi
where BusinessUnit <> 'chattem'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Sep 4 Insert into dba.Employee',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Step 5: Delete duplicate Chattem employees

SET @TransStart = getdate()
delete dba.employee
where ((organizationunit = 'chattem' or company = 'USCHATTEM'))
and employeeid1 in (select distinct employeeid1 from dba.employee
where employeeid1 in ('00056950','00057025')
and ((organizationunit <> 'chattem' or company <> 'USCHATTEM')) )
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Sep 5 Delete duplicate Chattem',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Step 6: Create DBA.CostructLoad

-- Truncate table to clear out last loaded

SET @TransStart = getdate()
TRUNCATE TABLE DBA.CostructLoad
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 6a -Truncate dba.CostructLoad',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Insert data into CostructLoad excluding data that creates circular references.

SET @TransStart = getdate()
INSERT INTO DBA.CostructLoad
SELECT EmployeeId1,UPPER(LastName)+'/'+UPPER(FirstName),'SANOFI' 
FROM DBA.Employee 
where SupervisorId not in 
(SELECT DISTINCT EmployeeId1 FROM DBA.Employee)
AND EndDate = '2099-12-31'
AND EmployeeStatus in ('1','3','A')



UNION

SELECT EmployeeId1,UPPER(LastName)+'/'+UPPER(FirstName),SupervisorId
FROM DBA.Employee 
WHERE SupervisorId IN 
(SELECT DISTINCT EmployeeId1 FROM DBA.Employee)
AND EndDate = '2099-12-31'
AND EmployeeStatus in ('1','3','A')


UNION

SELECT DISTINCT 'SANOFI','SANOFI','' FROM DBA.Employee

order by 3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 6b -Insert dba.CostructLoad',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='END Stored Procedure',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO

ALTER AUTHORIZATION ON [dbo].[LoadCostructLoad] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[employee_sanofi]    Script Date: 7/7/2015 5:04:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[employee_sanofi](
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[LocalID] [varchar](50) NULL,
	[ConvergenceID] [varchar](50) NULL,
	[EmailAddress] [varchar](50) NULL,
	[Remote] [varchar](50) NULL,
	[ManagerFirstName] [varchar](50) NULL,
	[ManagerLastName] [varchar](50) NULL,
	[ManagerLocalID] [varchar](50) NULL,
	[ManagerConvergenceID] [varchar](50) NULL,
	[ManagerEmailAddress] [varchar](50) NULL,
	[NorthAmericaManager] [varchar](50) NULL,
	[CostCenter] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[EmploymentStatus] [varchar](50) NULL,
	[EntityID] [varchar](50) NULL,
	[EntityDescription] [varchar](50) NULL,
	[ExpatInpat] [varchar](50) NULL,
	[JobTitle] [varchar](255) NULL,
	[BusinessUnit] [varchar](50) NULL,
	[ExecutiveCommitteeMember] [varchar](50) NULL,
	[ExecutiveCommitteeMembeName2] [varchar](50) NULL,
	[OrganizationID] [varchar](50) NULL,
	[OrganizationName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[employee_sanofi] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Employee]    Script Date: 7/7/2015 5:04:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Employee](
	[EmployeeID1] [varchar](20) NULL,
	[LastName] [varchar](35) NULL,
	[FirstName] [varchar](25) NULL,
	[MiddleName] [varchar](15) NULL,
	[EmpEmail] [varchar](100) NULL,
	[EmployeeType] [varchar](50) NULL,
	[EmployeeStatus] [varchar](20) NULL,
	[EmployeeID2] [varchar](20) NULL,
	[BusinessAddress] [varchar](50) NULL,
	[BusinessCity] [varchar](50) NULL,
	[BusinessStateCd] [varchar](20) NULL,
	[BusinessCountry] [varchar](50) NULL,
	[BusinessRegion] [varchar](50) NULL,
	[SupervisorID] [varchar](20) NULL,
	[SupervisorFirstName] [varchar](25) NULL,
	[SupervisorLastName] [varchar](35) NULL,
	[SupervisorEmail] [varchar](100) NULL,
	[CostCenter] [varchar](50) NULL,
	[DeptNumber] [varchar](50) NULL,
	[DivisionNumber] [varchar](50) NULL,
	[OrganizationUnit] [varchar](50) NULL,
	[Company] [varchar](50) NULL,
	[AdditionalInfo1] [varchar](50) NULL,
	[AdditionalInfo2] [varchar](50) NULL,
	[AdditionalInfo3] [varchar](50) NULL,
	[AdditionalInfo4] [varchar](50) NULL,
	[AdditionalInfo5] [varchar](50) NULL,
	[AdditionalInfo6] [varchar](50) NULL,
	[AdditionalInfo7] [varchar](50) NULL,
	[AdditionalInfo8] [varchar](50) NULL,
	[AdditionalInfo9] [varchar](50) NULL,
	[AdditionalInfo10] [varchar](50) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ImportDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Employee] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CostructLoad]    Script Date: 7/7/2015 5:04:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CostructLoad](
	[child] [varchar](40) NOT NULL,
	[description] [varchar](255) NULL,
	[parent] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CostructLoad] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 5:04:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](50) NOT NULL,
	[BeginIssueDate] [datetime] NULL,
	[EndIssueDate] [datetime] NULL,
	[IataNum] [varchar](50) NULL,
	[RowCount] [int] NOT NULL,
	[Error] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Employee_PX]    Script Date: 7/7/2015 5:04:58 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Employee_PX] ON [dba].[Employee]
(
	[EmployeeID1] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

