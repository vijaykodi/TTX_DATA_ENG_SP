/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/9/2015 7:18:10 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_PREUBSMOWR22590_Post_Import_Update]    Script Date: 7/9/2015 7:18:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[sp_PREUBSMOWR22590_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start MOWR22HS-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='RU'
where iatanum ='PREUBS' and recordkey like '%MOWR22590-%' and (origcountry is null or origcountry ='XX')

update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%MOWR22590-%' and text18 is null

----- Update Text 17 with TractID -------------LOC 7/5/2012
update c
set  text17 = substring(udefdata,charindex('order:',udefdata)+6,6)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACECRM%order%' and isnull(text17,'N/A') = 'N/A'

----- Update Text 17 with TracID when segment selected --- LOC/9/21/2012
update c
set  text17 = substring(udefdata,charindex('order:',udefdata)+6,5)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACECRM%order%/%' and isnull(text17,'N/A') = 'N/A'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation MOWR22590-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACECRF/%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACECRF/%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACECRF/%' and text24 is null

---------Update Text25 = Air Reason Code String --------------------------- LOC 5/29/2012
update c
set text25 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACESV1%' and text25 is null

-----Update Text26 = Htl Reason Code String --------------------------- LOC 5/29/2012
update c
set text26 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACESV1%' and text26 is null

---- Update Text27 = TractID String -------- LOC 7/5/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MOWR22590-%' and udefdata like 'ACECRM%order%' and text27 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End MOWR22HS-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  




GO

ALTER AUTHORIZATION ON [dbo].[sp_PREUBSMOWR22590_Post_Import_Update] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/9/2015 7:18:13 PM ******/
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

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/9/2015 7:18:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNum] [varchar](15) NULL,
	[TicketingBranch] [varchar](10) NULL,
	[BookingBranch] [varchar](10) NULL,
	[TtlInvoiceAmt] [float] NULL,
	[TtlTaxAmt] [float] NULL,
	[TtlCommissionAmt] [float] NULL,
	[CurrCode] [varchar](30) NULL,
	[OrigCountry] [varchar](5) NULL,
	[SalesAgentID] [varchar](10) NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[GDSCode] [varchar](10) NULL,
	[BackOfficeID] [varchar](20) NULL,
	[IMPORTDT] [datetime] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/9/2015 7:18:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ComRmks](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[Text1] [varchar](150) NULL,
	[Text2] [varchar](150) NULL,
	[Text3] [varchar](150) NULL,
	[Text4] [varchar](150) NULL,
	[Text5] [varchar](150) NULL,
	[Text6] [varchar](150) NULL,
	[Text7] [varchar](150) NULL,
	[Text8] [varchar](150) NULL,
	[Text9] [varchar](150) NULL,
	[Text10] [varchar](150) NULL,
	[Text11] [varchar](150) NULL,
	[Text12] [varchar](150) NULL,
	[Text13] [varchar](150) NULL,
	[Text14] [varchar](150) NULL,
	[Text15] [varchar](150) NULL,
	[Text16] [varchar](150) NULL,
	[Text17] [varchar](150) NULL,
	[Text18] [varchar](150) NULL,
	[Text19] [varchar](150) NULL,
	[Text20] [varchar](150) NULL,
	[Text21] [varchar](150) NULL,
	[Text22] [varchar](150) NULL,
	[Text23] [varchar](150) NULL,
	[Text24] [varchar](150) NULL,
	[Text25] [varchar](150) NULL,
	[Text26] [varchar](150) NULL,
	[Text27] [varchar](150) NULL,
	[Text28] [varchar](150) NULL,
	[Text29] [varchar](150) NULL,
	[Text30] [varchar](150) NULL,
	[Text31] [varchar](150) NULL,
	[Text32] [varchar](150) NULL,
	[Text33] [varchar](150) NULL,
	[Text34] [varchar](150) NULL,
	[Text35] [varchar](150) NULL,
	[Text36] [varchar](150) NULL,
	[Text37] [varchar](150) NULL,
	[Text38] [varchar](150) NULL,
	[Text39] [varchar](150) NULL,
	[Text40] [varchar](150) NULL,
	[Text41] [varchar](150) NULL,
	[Text42] [varchar](150) NULL,
	[Text43] [varchar](150) NULL,
	[Text44] [varchar](150) NULL,
	[Text45] [varchar](150) NULL,
	[Text46] [varchar](150) NULL,
	[Text47] [varchar](150) NULL,
	[Text48] [varchar](150) NULL,
	[Text49] [varchar](150) NULL,
	[Text50] [varchar](150) NULL,
	[Num1] [float] NULL,
	[Num2] [float] NULL,
	[Num3] [float] NULL,
	[Num4] [float] NULL,
	[Num5] [float] NULL,
	[Num6] [float] NULL,
	[Num7] [float] NULL,
	[Num8] [float] NULL,
	[Num9] [float] NULL,
	[Num10] [float] NULL,
	[Num11] [float] NULL,
	[Num12] [float] NULL,
	[Num13] [float] NULL,
	[Num14] [float] NULL,
	[Num15] [float] NULL,
	[Num16] [float] NULL,
	[Num17] [float] NULL,
	[Num18] [float] NULL,
	[Num19] [float] NULL,
	[Num20] [float] NULL,
	[Num21] [float] NULL,
	[Num22] [float] NULL,
	[Num23] [float] NULL,
	[Num24] [float] NULL,
	[Num25] [float] NULL,
	[Num26] [float] NULL,
	[Num27] [float] NULL,
	[Num28] [float] NULL,
	[Num29] [float] NULL,
	[Num30] [float] NULL,
	[Int1] [int] NULL,
	[Int2] [int] NULL,
	[Int3] [int] NULL,
	[Int4] [int] NULL,
	[Int5] [int] NULL,
	[Int6] [int] NULL,
	[Int7] [int] NULL,
	[Int8] [int] NULL,
	[Int9] [int] NULL,
	[Int10] [int] NULL,
	[Int11] [int] NULL,
	[Int12] [int] NULL,
	[Int13] [int] NULL,
	[Int14] [int] NULL,
	[Int15] [int] NULL,
	[Int16] [int] NULL,
	[Int17] [int] NULL,
	[Int18] [int] NULL,
	[Int19] [int] NULL,
	[Int20] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Udef]    Script Date: 7/9/2015 7:19:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Udef](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[UdefNum] [smallint] NOT NULL,
	[UdefType] [varchar](20) NULL,
	[UdefData] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Udef] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/9/2015 7:19:07 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[InvoiceDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/9/2015 7:19:08 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [DBA].[ComRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefI1]    Script Date: 7/9/2015 7:19:09 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [DBA].[Udef]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/9/2015 7:19:10 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [DBA].[InvoiceHeader]
(
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/9/2015 7:19:12 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[BackOfficeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/9/2015 7:19:13 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI4] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/9/2015 7:19:14 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/9/2015 7:19:14 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/9/2015 7:19:15 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/9/2015 7:19:16 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [DBA].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/9/2015 7:19:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [DBA].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

