/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:10:15 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_CCMerchant_Exclude]    Script Date: 7/13/2015 1:10:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_CCMerchant_Exclude]
 AS
  /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
 ---------------------------------------------------------------------------------------------------------
 -------- I am working on updating this process. I have created a table DBA.CarServ_Incl_Exc
 -------- This has the merchant ID and Include/Exclude column.  I have requested a SSIS be created
 -------- so that we can have UBS send the file to the AP and have it loaded (Case 41862).
 -------- Once this is completed we can update this process.  I need to make sure we dont have to create
 -------- a temp table first and then import to the Dba.CarServ_Incl_exc table...LOC 7/16/2014
 ----------------------------------------------------------------------------------------------------------
 --#34341  Setting CCMerchant PurgeInd=E for merchants to be Excluded from Preferred Vendor reports
  ------- updated from <> 'E' to not in ('E','Y') as this was changing the Preferreds to E.
 --#50693 - UBS no longer sending Exclude list - only sending Include which is Car Service vendors
 --they want marked as non preferred 
 --UPDATE M
 --SET PurgeInd='E'
 --FROM DBA.CCMerchant M,  DBO.CCMerchant_Exclude ME
 -- WHERE   M.MerchantId=ME.MERCHANTID   AND M.PurgeInd not in ('E','Y')
  
  
 --UPDATE M
 --SET PurgeInd='E'
 --FROM
 --DBA.CCMerchant M,
 --DBO.CCMerchant_Exclude ME
 -- WHERE
 -- M.MerchantId=ME.MERCHANTID
 -- AND M.PurgeInd IS NULL
  
  
 --qrys for merchant include 
--select PurgeInd
--from dba.ccmerchant
--where MerchantId in (select MerchantId from dbo.ccmerchant_include)
--and PurgeInd not in ('Y','N')
 
 
  update dba.CCMerchant
set PurgeInd='N'
from dba.ccmerchant
where MerchantId in (select MerchantId from dbo.ccmerchant_include)
and PurgeInd not in ('Y','N')


--select GenesisDetailIndCode
--from dba.ccmerchant
--where MerchantId in (select MerchantId from dbo.ccmerchant_include)
--and GenesisDetailIndCode not in ('397','398')

update dba.CCMerchant
set GenesisDetailIndCode='397'
where MerchantId in (select MerchantId from dbo.ccmerchant_include)
and GenesisDetailIndCode not in ('397','398')


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_CCMerchant_Exclude] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:10:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](255) NULL,
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

ALTER AUTHORIZATION ON [DBA].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dbo].[CCMerchant_Include]    Script Date: 7/13/2015 1:10:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CCMerchant_Include](
	[MerchantID] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dbo].[CCMerchant_Include] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCMerchant]    Script Date: 7/13/2015 1:10:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCMerchant](
	[MerchantId] [varchar](40) NULL,
	[MerchantName1] [varchar](40) NULL,
	[MerchantName2] [varchar](40) NULL,
	[MerchantAddr1] [varchar](40) NULL,
	[MerchantAddr2] [varchar](40) NULL,
	[MerchantAddr3] [varchar](40) NULL,
	[MerchantAddr4] [varchar](40) NULL,
	[MerchantCity] [varchar](40) NULL,
	[MerchantState] [varchar](20) NULL,
	[MerchantZip] [varchar](15) NULL,
	[MerchantCtryCode] [varchar](15) NULL,
	[MerchantCtryName] [varchar](35) NULL,
	[MerchantPhone] [varchar](20) NULL,
	[SICCode] [varchar](4) NULL,
	[SICName] [varchar](130) NULL,
	[CorporateId] [varchar](19) NULL,
	[RecordofCharge] [varchar](13) NULL,
	[MerchantIndCode] [varchar](2) NULL,
	[MerchantSubIndCode] [varchar](3) NULL,
	[MerchantFederalTaxId] [varchar](9) NULL,
	[MerchantDunBradNum] [varchar](9) NULL,
	[MerchantOwnerTypeCd] [varchar](2) NULL,
	[MerchantPurchCd] [varchar](2) NULL,
	[PurgeInd] [varchar](1) NULL,
	[GenesisMajorIndCode] [varchar](4) NULL,
	[GenesisDetailIndCode] [varchar](4) NULL,
	[MerchantChain] [varchar](30) NULL,
	[MerchantBrand] [varchar](30) NULL,
	[MasterId] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCMerchant] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCMerchantI1]    Script Date: 7/13/2015 1:10:25 PM ******/
CREATE CLUSTERED INDEX [CCMerchantI1] ON [DBA].[CCMerchant]
(
	[GenesisMajorIndCode] ASC,
	[GenesisDetailIndCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCMerchantPx]    Script Date: 7/13/2015 1:10:25 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCMerchantPx] ON [DBA].[CCMerchant]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

