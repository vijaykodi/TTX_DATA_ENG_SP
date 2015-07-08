/****** Cannot script Unresolved Entities : Server[@Name='ttxsasql01']/Database[@Name='tman_ubs']/UnresolvedEntity[@Name='contractrmks' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='ACMInfo' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/8/2015 7:39:40 AM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_ACM_Move_to_Production_ManualImportDt]    Script Date: 7/8/2015 7:39:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



 CREATE PROCEDURE [dbo].[sp_ACM_Move_to_Production_ManualImportDt]
AS
BEGIN

/************************************************************************
    Set arguments and variables
*************************************************************************/
   
   DECLARE @Iata VARCHAR(50);
   DECLARE @ProcName VARCHAR(50);
   DECLARE @TransStart DATETIME;
   DECLARE @BeginIssueDate DATETIME = getdate();
   DECLARE @ENDIssueDate DATETIME = getdate(); 
   Declare @importdt datetime = getdate();

 --=================================
--Added by rcr  07/07/2015
--Adding variables for logging.
--=================================
   Declare @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(50)
--SET @Iata = ''
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID)) --> initialized below
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()   --> initialized below
--=================================

   -------- This SP is used when specific importdate / date ranges are needed -------------------------------------------
   ------- The Import data will need to be adjusted to what is needed at the time the SP is run--------LOC/8/29/2014
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

-------------------************** Hoping this will work ****************--------------------
--  Pushes data to production when ACMProcessor completes
--  Program will fail if time to process > MaxProcessingTime for customer in ACMDatabases
--  Default fail time is 180 minutes 		---- UBS is set for 360 in the table.	    				    
--  SET @TransStart = GETDATE();
--    IF >='10-1-2013' IS NULL
--    BEGIN
--	 SET >='10-1-2013' = (SELECT MAX(ImportDt)FROM DBA.InvoiceHeader WHERE IataNum NOT LIKE 'PRE%');
--    END;

SET @TransStart = getdate()

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity

--Next Line Commented out .. rcr 07/07/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
  -------Delete redundant ACMInfo records on production
	  Delete   from dba.ACMinfo 
	  where ImportDt  >='10-1-2013'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACMI_PROD',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_DEL_ACMI_PROD'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
	
	
				 
--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--			 
  	--Add new ACMInfo records to production
	 Insert into dba.ACMInfo
	 Select *
	 from TTXSASQL01.TMAN_UBS.dba.ACMInfo
	 where ImportDt  >='10-1-2013'
	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_PUSH_ACMI',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
	
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_PUSH_ACMI'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
		
	
	
				 
--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--					  
		  
		   --Delete redundant ContractRmk records on production
		 
	  Delete from dba.contractrmks 
	  where recordkey in (select recordkey from ttxsasql01.tman_ubs.dba.contractrmks where procenddate > getdate()-3)
	  --where recordkey in (select recordkey from dba.acminfo where ImportDt  >='10-1-2013')
	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACRMKS_PROD',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_DEL_ACRMKS_PROD'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
		


--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--	
			  
		--Add new ContractRmk records to production
-----**** Quering the ACMINFO table is causing major delays in the insert process .. The link was only being used to get the
-----     importdate so we will do this with the code below.---- LOC/8/1/2014
--declare @begindate datetime, @enddate datetime, @iatanum varchar (10)

--set @begindate = (select min(invoicedate) from dba.invoiceheader where importdt  >='10-1-2013')
--set @enddate = (select max(invoicedate) from dba.invoiceheader where importdt  >='10-1-2013')
--set @iatanum =(select distinct substring(iatanum,1,6) from dba.invoiceheader where importdt  >='10-1-2013')

Insert into dba.contractrmks
select * from TTXSASQL01.tman_ubs.dba.contractrmks
where recordkey in (select recordkey from ttxsasql01.tman_ubs.dba.contractrmks where procenddate > getdate()-3)

--where recordkey in (select recordkey from dba.acminfo where importdt >='10-1-2013')
--and recordkey not in (select recordkey from dba.contractrmks)
--where invoicedate between @begindate and @enddate
--and iatanum <> 'preubs'
	
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-@SQL_PUSH_ACRMKS',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 		    

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-@SQL_PUSH_ACRMKS'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	




--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--	

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ACM Processing Complete',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 
----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACM Processing Complete'
----

EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR



 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--	

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 ----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
----

EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
end
--EXEC TTXPASQL01.TMAN_UBS.dbo.sp_UBS_Matchback;



GO

ALTER AUTHORIZATION ON [dbo].[sp_ACM_Move_to_Production_ManualImportDt] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/8/2015 7:39:41 AM ******/
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

/****** Object:  Table [DBA].[ContractRmks]    Script Date: 7/8/2015 7:39:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ContractRmks](
	[RecordKey] [varchar](50) NULL,
	[IataNum] [varchar](8) NULL,
	[SeqNum] [smallint] NULL,
	[SegmentNum] [smallint] NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[ContractID] [varchar](30) NULL,
	[CompliantInd] [char](1) NULL,
	[RouteType] [char](1) NULL,
	[RouteTypeInd] [char](1) NULL,
	[FlownCarrierInd] [char](1) NULL,
	[MarketInd] [char](1) NULL,
	[DesignatorInd] [char](1) NULL,
	[FareBasisInd] [char](1) NULL,
	[CodeShareInd] [char](1) NULL,
	[ClassInd] [char](1) NULL,
	[FlightNumInd] [char](1) NULL,
	[POSInd] [char](1) NULL,
	[DiscountInd] [char](1) NULL,
	[FareAmtInd] [char](1) NULL,
	[TourCodeInd] [char](1) NULL,
	[OverNightInd] [char](1) NULL,
	[DOWInd] [char](1) NULL,
	[CarrierString] [varchar](50) NULL,
	[DaysAdvInd] [char](1) NULL,
	[ExcludedItem] [char](1) NULL,
	[ExhibitNum] [int] NULL,
	[MarketNum] [int] NULL,
	[StgyExhibitNum] [int] NULL,
	[StgyMarketNum] [int] NULL,
	[FareAmt] [float] NULL,
	[LongHaulOrigCityCode] [varchar](10) NULL,
	[LongHaulDestCityCode] [varchar](10) NULL,
	[LongHaulMktOrigCityCode] [varchar](10) NULL,
	[LongHaulMktDestCityCode] [varchar](10) NULL,
	[LongHaulFMS] [float] NULL,
	[LongHaulMileage] [float] NULL,
	[PublishedFare] [money] NULL,
	[DiscountedFare] [money] NULL,
	[MktRegionInd] [char](1) NULL,
	[RefundInd] [char](1) NULL,
	[FairMktShr] [float] NULL,
	[QSI] [float] NULL,
	[GoalNumber] [int] NULL,
	[ValCarrierInd] [char](1) NULL,
	[SatNtRqdInd] [char](1) NULL,
	[GoalExhibitNum] [int] NULL,
	[GoalMarketNum] [int] NULL,
	[GoalFlownCarrierInd] [char](1) NULL,
	[OnlineInd] [char](1) NULL,
	[InterlineInd] [char](1) NULL,
	[GDSInd] [char](1) NULL,
	[COSString] [varchar](50) NULL,
	[COSTicketString] [varchar](50) NULL,
	[MinStayInd] [char](1) NULL,
	[DepartureDate] [datetime] NULL,
	[MINFMS] [float] NULL,
	[MINOpCarrierCode] [varchar](3) NULL,
	[OnlineFlag] [char](1) NULL,
	[InterlineFlag] [char](1) NULL,
	[ContractCarrierFlag] [char](1) NULL,
	[POSCountry] [varchar](2) NULL,
	[SEGOpCarrierCode] [varchar](3) NULL,
	[NOXOpCarrierCode] [varchar](3) NULL,
	[farepct] [float] NULL,
	[SegNum] [int] NULL,
	[Miles] [float] NULL,
	[ProcEndDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ContractRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ACMInfo]    Script Date: 7/8/2015 7:39:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ACMInfo](
	[RecordKey] [varchar](50) NULL,
	[IataNum] [varchar](8) NULL,
	[SeqNum] [smallint] NULL,
	[SegmentNum] [smallint] NULL,
	[ClientCode] [varchar](15) NULL,
	[CustomerID] [varchar](30) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[DepartureDate] [datetime] NULL,
	[FareBeforeDiscount] [float] NULL,
	[DiscountedFare] [float] NULL,
	[ContractID] [varchar](30) NULL,
	[ExhibitNumber] [int] NULL,
	[MarketNumber] [int] NULL,
	[GoalNumber] [int] NULL,
	[RestrictionLevel] [float] NULL,
	[CabinCategory] [varchar](10) NULL,
	[ComfortLevel] [real] NULL,
	[FareCategory] [varchar](10) NULL,
	[ProjectedFare] [float] NULL,
	[ClassOfServiceScore] [float] NULL,
	[RefundedInd] [char](1) NULL,
	[POSCountry] [varchar](2) NULL,
	[RouteType] [char](1) NULL,
	[ContractCarrierFlag] [char](1) NULL,
	[InterlineFlag] [char](1) NULL,
	[MINOpCarrierCode] [varchar](3) NULL,
	[MINFMS] [float] NULL,
	[CO2Emissions] [float] NULL,
	[LongHaulOrigCityCode] [varchar](10) NULL,
	[LongHaulDestCityCode] [varchar](10) NULL,
	[LongHaulMktOrigCityCode] [varchar](10) NULL,
	[LongHaulMktDestCityCode] [varchar](10) NULL,
	[LongHaulFMS] [float] NULL,
	[LongHaulMileage] [float] NULL,
	[MktElasticityFactor] [float] NULL,
	[MarketCategory] [varchar](4) NULL,
	[SegNum] [int] NULL,
	[Miles] [float] NULL,
	[ImportDt] [datetime] NULL,
	[ProcEndDate] [datetime] NULL,
	[Commission] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ACMInfo] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI1]    Script Date: 7/8/2015 7:39:56 AM ******/
CREATE CLUSTERED INDEX [ContractRmksI1] ON [DBA].[ContractRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI1]    Script Date: 7/8/2015 7:39:56 AM ******/
CREATE CLUSTERED INDEX [ACMInfoI1] ON [DBA].[ACMInfo]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ContractRmksI2]    Script Date: 7/8/2015 7:39:56 AM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI2] ON [DBA].[ContractRmks]
(
	[GoalExhibitNum] ASC,
	[GoalMarketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI4]    Script Date: 7/8/2015 7:39:57 AM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI4] ON [DBA].[ContractRmks]
(
	[ContractID] ASC,
	[MarketNum] ASC,
	[DepartureDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[CompliantInd],
	[ExhibitNum],
	[POSCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksPx]    Script Date: 7/8/2015 7:39:58 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ContractRmksPx] ON [DBA].[ContractRmks]
(
	[ContractID] ASC,
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID]    Script Date: 7/8/2015 7:39:58 AM ******/
CREATE NONCLUSTERED INDEX [IX_CONTRACTRMKS_CONTRACTID] ON [DBA].[ContractRmks]
(
	[ContractID] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI2]    Script Date: 7/8/2015 7:39:58 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI2] ON [DBA].[ACMInfo]
(
	[ImportDt] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI3]    Script Date: 7/8/2015 7:39:59 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI3] ON [DBA].[ACMInfo]
(
	[IssueDate] ASC,
	[DepartureDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[DiscountedFare]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI4]    Script Date: 7/8/2015 7:39:59 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI4] ON [DBA].[ACMInfo]
(
	[ContractCarrierFlag] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[IssueDate],
	[FareBeforeDiscount],
	[DiscountedFare],
	[ContractID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI5]    Script Date: 7/8/2015 7:40:01 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI5] ON [DBA].[ACMInfo]
(
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[FareBeforeDiscount],
	[DiscountedFare],
	[ContractID],
	[ContractCarrierFlag],
	[MINFMS]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoPX]    Script Date: 7/8/2015 7:40:01 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ACMInfoPX] ON [DBA].[ACMInfo]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

