/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 9:16:19 PM ******/
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

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_PACEAXKR]    Script Date: 7/7/2015 9:16:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PACEAXKR] 

	@BeginIssueDate	datetime,
	@EndIssueDate	datetime

AS
--

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'PACEAXKR'
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
where iatanum ='PACEAXKR'
and importdate is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='importdate = rptcreatedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO

ALTER AUTHORIZATION ON [dbo].[sp_PACEAXKR] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 9:16:20 PM ******/
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
	[StepName] [varchar](255) NULL,
	[BeginIssueDate] [datetime] NULL,
	[EndIssueDate] [datetime] NULL,
	[IataNum] [varchar](50) NULL,
	[ROWCOUNT] [int] NOT NULL,
	[ERROR] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCHeader]    Script Date: 7/7/2015 9:16:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CCHeader](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[MerchantId] [varchar](40) NULL,
	[CCSourceFile] [varchar](10) NULL,
	[RptCreateDate] [datetime] NULL,
	[CCCycleDate] [datetime] NULL,
	[TransactionDate] [datetime] NULL,
	[PostDate] [datetime] NULL,
	[BilledDate] [datetime] NULL,
	[RecordType] [varchar](2) NULL,
	[TransactionNum] [varchar](23) NULL,
	[BatchNum] [varchar](24) NULL,
	[ControlCCNum] [varchar](50) NULL,
	[BasicCCNum] [varchar](50) NULL,
	[CreditCardNum] [varchar](50) NULL,
	[ChargeDesc] [varchar](50) NULL,
	[TransactionType] [varchar](5) NULL,
	[RefundInd] [varchar](1) NULL,
	[ChargeType] [varchar](20) NULL,
	[FinancialCatCode] [varchar](1) NULL,
	[DisputedFlag] [varchar](25) NULL,
	[CardHolderName] [varchar](50) NULL,
	[LocalCurrAmt] [float] NULL,
	[LocalTaxAmt] [float] NULL,
	[LocalCurrCode] [varchar](3) NULL,
	[BilledAmt] [float] NULL,
	[BilledTaxAmt] [float] NULL,
	[BilledTaxAmt2] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BaseFare] [float] NULL,
	[IndustryCode] [varchar](2) NULL,
	[MatchedInd] [varchar](1) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BatchName] [varchar](30) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[CompanyName] [varchar](20) NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[CarHtlSeqNum] [int] NULL,
	[MatchedSeqNum] [int] NULL,
	[Remarks1] [varchar](40) NULL,
	[Remarks2] [varchar](40) NULL,
	[Remarks3] [varchar](40) NULL,
	[Remarks4] [varchar](40) NULL,
	[Remarks5] [varchar](40) NULL,
	[Remarks6] [varchar](40) NULL,
	[Remarks7] [varchar](40) NULL,
	[Remarks8] [varchar](40) NULL,
	[Remarks9] [varchar](40) NULL,
	[Remarks10] [varchar](40) NULL,
	[Remarks11] [varchar](40) NULL,
	[Remarks12] [varchar](40) NULL,
	[Remarks13] [varchar](40) NULL,
	[Remarks14] [varchar](40) NULL,
	[Remarks15] [varchar](40) NULL,
	[TransactionFlag] [char](1) NULL,
	[TransactionID] [varchar](20) NULL,
	[MarketCode] [varchar](10) NULL,
	[ImportDate] [datetime] NULL,
	[AncillaryFeeInd] [int] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[OriginatingCMAcctNum] [varchar](20) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHeader] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI1]    Script Date: 7/7/2015 9:16:33 PM ******/
CREATE CLUSTERED INDEX [CCHeaderI1] ON [dba].[CCHeader]
(
	[IataNum] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeader_AncFee]    Script Date: 7/7/2015 9:16:34 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_AncFee] ON [dba].[CCHeader]
(
	[AncillaryFeeInd] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[BilledCurrCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI2]    Script Date: 7/7/2015 9:16:34 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI2] ON [dba].[CCHeader]
(
	[BilledDate] ASC,
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI3]    Script Date: 7/7/2015 9:16:34 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI3] ON [dba].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderPX]    Script Date: 7/7/2015 9:16:34 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCHeaderPX] ON [dba].[CCHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [IX_CCHEADER_IMPORTDATE]    Script Date: 7/7/2015 9:16:35 PM ******/
CREATE NONCLUSTERED INDEX [IX_CCHEADER_IMPORTDATE] ON [dba].[CCHeader]
(
	[ImportDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

