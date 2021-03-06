/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/14/2015 8:00:14 PM ******/
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
	@ProcedureName VARCHAR(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart DATETIME, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName VARCHAR(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate DATETIME = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate DATETIME = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum VARCHAR(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount INT, -- **REQUIRED** Total number of affected rows
	@ERR INT) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error INT, -- Error Trapping for this procedure
	@LogRowCount INT, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message VARCHAR(255), -- The Error Message for this Procedure
	@Error_Type INT, -- Used to track where errors are raised inside this procedure
	@Error_Loc INT -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [DATETIME] NOT NULL,
			[LogEnd] [DATETIME] NOT NULL,
			[RunByUSER] [CHAR](30) NOT NULL,
			[StepName] [VARCHAR](50) NOT NULL,
			[BeginIssueDate] [DATETIME] NULL,
			[EndIssueDate] [DATETIME] NULL,
			[IataNum] [VARCHAR](50) NULL,
			[ROWCOUNT] [INT] NOT NULL,
			[ERROR] [INT] NOT NULL,
			[ErrorMessage] [NVARCHAR](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql NVARCHAR(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [TEXT] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
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
		,[ROWCOUNT]
		,ERROR
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GETDATE()
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
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [TEXT] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END

/****** Object:  StoredProcedure [dbo].[sp_StandardCityUpdate]    Script Date: 10/18/2011 12:25:03 ******/
SET ANSI_NULLS ON

GO
