/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:02:10 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_CarMain]    Script Date: 7/13/2015 1:02:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_CarMain]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime


	SET @Iata = 'UBSCB'
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()


update dba.cartransportation
set journeydescription = 'car0001'
where Source = 'ALEPHUS'
and journeydescription like '%001%'

update dba.cartransportation
set journeydescription = 'car0002'
where Source = 'ALEPHUS'
and journeydescription like '%002%'

update dba.cartransportation
set journeydescription = 'car0003'
where Source = 'ALEPHUS'
and journeydescription like '%003%'

update dba.cartransportation
set journeydescription = 'car0004'
where Source = 'ALEPHUS'
and journeydescription like '%004%'

update dba.cartransportation
set journeydescription = 'car0005'
where Source = 'ALEPHUS'
and journeydescription like '%005%'

update dba.cartransportation
set journeydescription = 'car0006'
where Source = 'ALEPHUS'
and journeydescription like '%006%'

update dba.cartransportation
set journeydescription = 'car0007'
where Source = 'ALEPHUS'
and journeydescription like '%007%'

Delete dba.CarTransportation
where Source = 'ALEPHUS'
and journeydescription = 'car0007'

update dba.cartransportation
set vendorname  = 'Concord Limousine'
where Source = 'ALEPHUS'
and vendorname like '%Concord%'

update dba.cartransportation
set vendorname  = 'CTS Limousine'
where Source = 'ALEPHUS'
and vendorname like 'CTS%'

update dba.cartransportation
set vendorname  = 'Carey International'
where Source = 'ALEPHUS'
and vendorname like 'Carey%'

update dba.cartransportation
set vendorname  = 'EmpireCLS Worldwide'
where Source = 'ALEPHUS'
and vendorname like 'Empire%'

update dba.cartransportation
set vendorname  = 'Bali Limousine'
where Source = 'ALEPHUS'
and vendorname like '%Bali%'

update dba.cartransportation
set vendorname  = 'MTC Limousine'
where Source = 'ALEPHUS'
and vendorname like 'MTC%'

update dba.cartransportation
set vendorname  = 'Flyte Tyme Worldwide'
where Source = 'ALEPHUS'
and vendorname like '%Flyte Tyme%'

Update dba.CarTransportation 
Set baserate =  isnull(baserate,0),
tolls = isnull(tolls,0),
WaitTimeCost =  isnull(WaitTimeCost,0),
Parking = isnull(Parking,0),
MeetGreatCharges = isnull(MeetGreatCharges,0),
PhoneCharges = isnull(PhoneCharges,0), 
ServiceCharges = isnull(ServiceCharges,0), 
AdditionalStops = isnull(AdditionalStops,0), 
AdditionalStopsWaitTime = isnull(AdditionalStopsWaitTime,0), 
TipsGratuity = isnull(TipsGratuity,0), 
FuelSurcharge = isnull(FuelSurcharge,0), 
Package = isnull(Package,0), 
Events = isnull(Events,0), 
NYCWorkmansComp = isnull(NYCWorkmansComp,0),  
Extras = isnull(Extras,0), 
adminfee = isnull(adminfee,0), 
Discount = isnull(Discount,0), 
NetCost = isnull(NetCost,0), 
StateSalesTaxVat = isnull(StateSalesTaxVat,0), 
TotalCost = isnull(TotalCost,0), 
Mileage = isnull(Mileage,0), 
CarbonEmissions = isnull(CarbonEmissions,0) 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Car Main Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_CarMain] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:02:11 PM ******/
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

/****** Object:  Table [DBA].[CarTransportation]    Script Date: 7/13/2015 1:02:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CarTransportation](
	[Source] [varchar](50) NULL,
	[BookingDate] [datetime] NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNumber] [varchar](50) NULL,
	[ConfirmationNbr] [varchar](50) NULL,
	[PassengerName] [varchar](100) NULL,
	[GPN] [varchar](50) NULL,
	[BookedBy] [varchar](100) NULL,
	[PickupDate] [datetime] NULL,
	[PickupTime] [varchar](50) NULL,
	[PickupAddress] [varchar](255) NULL,
	[Destination] [varchar](255) NULL,
	[DropOffTime] [datetime] NULL,
	[JourneyDescription] [varchar](50) NULL,
	[CostCenter] [varchar](100) NULL,
	[ProjectCode] [varchar](100) NULL,
	[VendorName] [varchar](50) NULL,
	[VehicleType] [varchar](50) NULL,
	[BaseRate] [float] NULL,
	[Tolls] [float] NULL,
	[WaitTimeCost] [float] NULL,
	[Parking] [float] NULL,
	[MeetGreatCharges] [float] NULL,
	[PhoneCharges] [float] NULL,
	[ServiceCharges] [float] NULL,
	[AdditionalStops] [float] NULL,
	[AdditionalStopsWaitTime] [float] NULL,
	[TipsGratuity] [float] NULL,
	[FuelSurcharge] [float] NULL,
	[Package] [float] NULL,
	[Events] [float] NULL,
	[NYCWorkmansComp] [float] NULL,
	[Extras] [float] NULL,
	[AdminFee] [float] NULL,
	[Discount] [float] NULL,
	[NetCost] [float] NULL,
	[StateSalesTaxVat] [float] NULL,
	[TotalCost] [float] NULL,
	[Mileage] [float] NULL,
	[CarbonEmissions] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[POS] [varchar](5) NULL,
	[RcvdGPN] [varchar](50) NULL,
	[ImportDt] [datetime] NULL,
	[CarNumber] [varchar](20) NULL,
	[PaymentType] [varchar](20) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CarTransportation] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarTrans_PX]    Script Date: 7/13/2015 1:02:22 PM ******/
CREATE CLUSTERED INDEX [CarTrans_PX] ON [DBA].[CarTransportation]
(
	[Source] ASC,
	[InvoiceDate] ASC,
	[POS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarTrans_I1]    Script Date: 7/13/2015 1:02:22 PM ******/
CREATE NONCLUSTERED INDEX [CarTrans_I1] ON [DBA].[CarTransportation]
(
	[InvoiceDate] ASC,
	[JourneyDescription] ASC,
	[WaitTimeCost] ASC
)
INCLUDE ( 	[PassengerName],
	[GPN],
	[CurrCode],
	[POS]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

