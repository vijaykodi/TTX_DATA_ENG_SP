/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContracts' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContractMarkets' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContractGoals' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContractExhibits' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_ACM_RefreshContractTerms]    Script Date: 7/7/2015 5:05:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ======================================================
-- Author:		  Chalrie Bradsher
-- Create date:	  2012-11-14
-- Update date:	  2013-03-25
-- Update Desc:	  Added refresh of AirlineContractFields table
-- Description:	  Refreshes Contract Terms from ACM Master

--			  DO NOT RUN ON ttxpaSQL09 DATABASES!!!!!

--			  Check to see what will be deleted
--			  Select * from dba.airlinecontracts			  
-- ======================================================
CREATE PROCEDURE [dbo].[sp_ACM_RefreshContractTerms]
AS
BEGIN
	SET NOCOUNT ON;
	
Declare @CustomerID varchar(30)
Set @CustomerID = 'Sanofi'

Declare @string nvarchar(500)
Declare @pos int
Declare @piece nvarchar(500)
Declare @strings table(string nvarchar(512))
Declare @Contract varchar(30)
Declare @Exhibit int
Declare @Market int
Declare @FieldName varchar(200)

--  Drop back-up tables and back up existing terms data

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContracts_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContracts_Bak]

Select *
into dba.AirlineContracts_Bak
from dba.AirlineContracts

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractExhibits_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractExhibits_Bak]

Select *
into dba.AirlineContractExhibits_Bak
from dba.AirlineContractExhibits

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractMarkets_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractMarkets_Bak]

Select *
into dba.AirlineContractMarkets_Bak
from dba.AirlineContractMarkets

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractGoals_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractGoals_Bak]

Select *
into dba.AirlineContractGoals_Bak
from dba.AirlineContractGoals

delete from dba.AirlineContracts 
where CustomerID = @CustomerID

delete from dba.AirlineContractExhibits 
where CustomerID = @CustomerID

delete from dba.AirlineContractMarkets 
where CustomerID = @CustomerID

delete from dba.AirlineContractGoals 
where CustomerID = @CustomerID

Insert into dba.AirlineContracts
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContracts
where CustomerID = @CustomerID

Insert into dba.AirlineContractExhibits
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractExhibits
where CustomerID = @CustomerID

Insert into dba.AirlineContractMarkets
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractMarkets
where CustomerID = @CustomerID

Insert into dba.AirlineContractGoals
SELECT [CustomerID]
      ,[ContractNumber]
      ,[ExhibitNumber]
      ,[MarketNumber]
      ,[GoalNumber]
      ,[Status]
      ,[GoalType]
      ,[GoalValue]
      ,[Discount]
      ,[DiscountType]
      ,[Target]
      ,[Allowance]
      ,[GoalBeginDate]
      ,[GoalEndDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
      ,[TravelBeginDate]
      ,[TravelEndDate]
      ,[CurrCode]      
      ,[DiscCurrCode]
      ,[MinPerformance]
      ,[InflectionPoint]
      ,[MaxPerformance]
      ,[MinPayment]
      ,[InflectionPayment]
      ,[MaxPayment]
      ,[Description]
      
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractGoals
where CustomerID = @CustomerID

    
--  Update ACF

Delete from dba.AirlineContractFields where CustomerID = @CustomerID

Insert into dba.AirlineContractFields
Select CustomerID, ContractNumber, null, null, 'ContractCarrierCodes',null, null
from dba.AirlineContracts
where CustomerID = @CustomerID
and ContractCarrierCodes is null
Union
Select CustomerID, ContractNumber, ExhibitNumber, null, 'PointOfSale',null, null
from dba.AirlineContractExhibits
where CustomerID = @CustomerID
and PointOfSale is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ClassOfService',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and ClassOfService is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FareBasis',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and FareBasis is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FlownCarriers',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and FlownCarriers is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'OperatingCarriers',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and OperatingCarriers is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ValidatingCarriers',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and ValidatingCarriers is null


DECLARE ParseField_cursor CURSOR FOR
Select distinct Customerid, ContractNumber, null, null, 'ContractCarrierCodes' as "FieldName", ContractCarrierCodes as "FieldValue"
from dba.AirlineContracts
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, null, 'PointOfSale', PointOfSale
from dba.AirlineContractExhibits
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ClassOfService', ClassOfService
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FareBasis',FareBasis
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FlownCarriers', FlownCarriers
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'OperatingCarriers', OperatingCarriers
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ValidatingCarriers', ValidatingCarriers
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Order by 1,2,3

Open ParseField_cursor

fetch next from ParseField_cursor into @CustomerID, @Contract, @Exhibit, @Market, @FieldName, @String

while @@Fetch_Status = 0

  BEGIN
         
	  if right(rtrim(@string),1) <> ','
          SELECT @string = @string  + ','

	  SELECT @pos =  patindex('%,%' , @string)
	  while @pos <> 0 
	  begin
	    SELECT @piece = left(@string, (@pos-1))
	    
	   insert into @strings(string) values ( cast(@piece as nvarchar(512)))

	   SELECT @string = stuff(@string, 1, @pos, '')
	   SELECT @pos =  patindex('%,%' , @string)
	  end

       
        Insert into dba.AirlineContractFields
	  SELECT @Customerid, @Contract, @Exhibit, @Market, @FieldName, null, string FROM @Strings
	  
	  Delete from @Strings
	  
fetch next from ParseField_cursor into @CustomerID, @Contract, @Exhibit, @Market, @FieldName, @String

  END

CLOSE ParseField_cursor
DEALLOCATE ParseField_cursor



   
END


GO

ALTER AUTHORIZATION ON [dbo].[sp_ACM_RefreshContractTerms] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContracts]    Script Date: 7/7/2015 5:05:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContracts](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[AirlineName] [varchar](30) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[CustomerType] [varchar](2) NOT NULL,
	[ContractExtension] [int] NULL,
	[ContractSignedDate] [datetime] NULL,
	[Description] [varchar](100) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[Approved] [bit] NULL,
	[Notes] [varchar](1000) NULL,
	[Scenario] [char](1) NULL,
	[Processed] [char](1) NULL,
	[DNADomAdjustment] [float] NULL,
	[DNAIntAdjustment] [float] NULL,
	[ContractCarrierCodes] [varchar](255) NULL,
	[MeasureGoalsOnDate] [char](1) NULL,
	[MeasurePayOnDate] [char](1) NULL,
	[GoalMeasurementPeriod] [char](1) NULL,
	[PayMeasurementPeriod] [char](1) NULL,
	[GDS] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContracts] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContractMarkets]    Script Date: 7/7/2015 5:05:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractMarkets](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[ExhibitNumber] [int] NOT NULL,
	[MarketNumber] [int] NOT NULL,
	[Description] [varchar](200) NULL,
	[RouteType] [varchar](2) NULL,
	[ConnectionInd] [varchar](2) NULL,
	[OriginCityOperand] [varchar](2) NULL,
	[OriginCity] [varchar](2000) NULL,
	[DestinationCityOperand] [char](1) NULL,
	[DestinationCity] [varchar](2000) NULL,
	[OriginStateOperand] [char](1) NULL,
	[OriginState] [varchar](2000) NULL,
	[DestinationStateOperand] [char](1) NULL,
	[DestinationState] [varchar](2000) NULL,
	[OriginCountryOperand] [char](1) NULL,
	[OriginCountry] [varchar](2000) NULL,
	[DestinationCountryOperand] [char](1) NULL,
	[DestinationCountry] [varchar](2000) NULL,
	[ClassOfServiceOperand] [char](1) NULL,
	[ClassOfService] [varchar](255) NULL,
	[FareBasisOperand] [char](1) NULL,
	[FareBasis] [varchar](2000) NULL,
	[FlownCarriersOperand] [char](1) NULL,
	[FlownCarriers] [varchar](255) NULL,
	[TourCode] [varchar](255) NULL,
	[TicketDesignator] [varchar](15) NULL,
	[FlightNumberOperand] [char](1) NULL,
	[FlightNumber] [varchar](2000) NULL,
	[OriginContinentOperand] [char](1) NULL,
	[OriginContinent] [varchar](2000) NULL,
	[DestContinentOperand] [char](1) NULL,
	[DestContinent] [varchar](2000) NULL,
	[DirectionalInd] [char](1) NULL,
	[GatewayCityOperand] [char](1) NULL,
	[GatewayCity] [varchar](2000) NULL,
	[GatewayStateOperand] [char](1) NULL,
	[GatewayState] [varchar](2000) NULL,
	[GatewayCountryOperand] [char](1) NULL,
	[GatewayCountry] [varchar](2000) NULL,
	[GatewayContinentOperand] [char](1) NULL,
	[GatewayContinent] [varchar](2000) NULL,
	[ConnectingAirlineOperand] [char](1) NULL,
	[ConnectingAirline] [varchar](2000) NULL,
	[OWMinFare] [float] NULL,
	[RTMinFare] [float] NULL,
	[OvernightRqd] [char](1) NULL,
	[SatNightRqd] [char](1) NULL,
	[ValidDaysOperand] [char](1) NULL,
	[ValidDays] [varchar](20) NULL,
	[MktBeginDate] [datetime] NULL,
	[MktEndDate] [datetime] NULL,
	[ProcessLevel] [char](1) NULL,
	[TripOrigCityOperand] [char](1) NULL,
	[TripOrigCity] [varchar](2000) NULL,
	[TripOrigCountryOperand] [char](1) NULL,
	[TripOrigCountry] [varchar](2000) NULL,
	[TripOrigContinentOperand] [char](1) NULL,
	[TripOrigContinent] [varchar](2000) NULL,
	[DaysAdv] [int] NULL,
	[MktPairOperand] [char](1) NULL,
	[MktPair] [varchar](2000) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[ValidatingCarriersOperand] [char](1) NULL,
	[ValidatingCarriers] [varchar](255) NULL,
	[OperatingCarriersOperand] [char](1) NULL,
	[OperatingCarriers] [varchar](255) NULL,
	[InterlineInd] [char](1) NULL,
	[MinimumQSI] [float] NULL,
	[MinimumStay] [int] NULL,
	[OnlineInd] [char](1) NULL,
	[OriginRegion] [varchar](40) NULL,
	[DestinationRegion] [varchar](40) NULL,
	[TripOriginRegion] [varchar](40) NULL,
	[GatewayRegion] [varchar](40) NULL,
	[MarketPairRegion] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractMarkets] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContractGoals]    Script Date: 7/7/2015 5:06:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractGoals](
	[CustomerID] [varchar](30) NULL,
	[ContractNumber] [varchar](30) NULL,
	[ExhibitNumber] [int] NULL,
	[MarketNumber] [int] NULL,
	[GoalNumber] [int] NULL,
	[Status] [char](1) NULL,
	[GoalType] [varchar](50) NULL,
	[GoalValue] [float] NULL,
	[Discount] [float] NULL,
	[DiscountType] [char](1) NULL,
	[Target] [float] NULL,
	[Allowance] [float] NULL,
	[GoalBeginDate] [datetime] NULL,
	[GoalEndDate] [datetime] NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[TravelBeginDate] [datetime] NULL,
	[TravelEndDate] [datetime] NULL,
	[CurrCode] [varchar](3) NULL,
	[DiscCurrCode] [varchar](3) NULL,
	[MinPerformance] [float] NULL,
	[InflectionPoint] [float] NULL,
	[MaxPerformance] [float] NULL,
	[MinPayment] [float] NULL,
	[InflectionPayment] [float] NULL,
	[MaxPayment] [float] NULL,
	[Description] [varchar](1000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractGoals] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContractFields]    Script Date: 7/7/2015 5:06:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractFields](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[ExhibitNumber] [int] NULL,
	[MarketNumber] [int] NULL,
	[FieldName] [varchar](200) NOT NULL,
	[IntValue] [int] NULL,
	[TextValue] [varchar](2000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractFields] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContractExhibits]    Script Date: 7/7/2015 5:06:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractExhibits](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[ExhibitNumber] [int] NOT NULL,
	[Description] [varchar](100) NULL,
	[CustomerSubType] [varchar](100) NULL,
	[CustomerSubTypeInfo] [varchar](100) NULL,
	[ContractType] [varchar](2) NULL,
	[Commission] [char](1) NULL,
	[PointOfSaleOperand] [char](1) NULL,
	[PointOfSale] [varchar](2000) NULL,
	[AgencyName] [varchar](100) NULL,
	[IataNums] [varchar](2000) NULL,
	[CreatedBy] [varchar](30) NULL,
	[CreateDate] [datetime] NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[CashPayPercent] [float] NULL,
	[CashPayCapAmount] [float] NULL,
	[TtlPayCapAmount] [float] NULL,
	[PayOnTicketTypeOperand] [char](1) NULL,
	[PayOnTicketType] [varchar](255) NULL,
	[GDS] [varchar](6) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractExhibits] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractsPX]    Script Date: 7/7/2015 5:06:19 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractsPX] ON [dba].[AirlineContracts]
(
	[CustomerID] ASC,
	[ContractNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractMarketsPX]    Script Date: 7/7/2015 5:06:19 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractMarketsPX] ON [dba].[AirlineContractMarkets]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractGoalsPX]    Script Date: 7/7/2015 5:06:19 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractGoalsPX] ON [dba].[AirlineContractGoals]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC,
	[GoalNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractFieldsI2]    Script Date: 7/7/2015 5:06:20 PM ******/
CREATE CLUSTERED INDEX [AirlineContractFieldsI2] ON [dba].[AirlineContractFields]
(
	[FieldName] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractExhibitsPX]    Script Date: 7/7/2015 5:06:20 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractExhibitsPX] ON [dba].[AirlineContractExhibits]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_AirlineContractGoals]    Script Date: 7/7/2015 5:06:20 PM ******/
CREATE NONCLUSTERED INDEX [IX_AirlineContractGoals] ON [dba].[AirlineContractGoals]
(
	[Status] ASC,
	[GoalType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractFieldsI3]    Script Date: 7/7/2015 5:06:20 PM ******/
CREATE NONCLUSTERED INDEX [AirlineContractFieldsI3] ON [dba].[AirlineContractFields]
(
	[ContractNumber] ASC,
	[FieldName] ASC
)
INCLUDE ( 	[CustomerID],
	[ExhibitNumber],
	[MarketNumber],
	[TextValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractFieldsPX]    Script Date: 7/7/2015 5:06:21 PM ******/
CREATE NONCLUSTERED INDEX [AirlineContractFieldsPX] ON [dba].[AirlineContractFields]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_ContractExtension]  DEFAULT ((0)) FOR [ContractExtension]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Approved]  DEFAULT ((0)) FOR [Approved]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Scenario]  DEFAULT ('N') FOR [Scenario]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Processed]  DEFAULT ('N') FOR [Processed]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_MeasureGoalsOnDate]  DEFAULT ('F') FOR [MeasureGoalsOnDate]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_MeasurePayOnDate]  DEFAULT ('F') FOR [MeasurePayOnDate]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_GoalMeasurementPeriod]  DEFAULT ('Q') FOR [GoalMeasurementPeriod]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_PayMeasurementPeriod]  DEFAULT ('Q') FOR [PayMeasurementPeriod]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_FlownCarriersOperand]  DEFAULT ('N') FOR [FlownCarriersOperand]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_FlightNumberOperand]  DEFAULT ('I') FOR [FlightNumberOperand]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_DirectionalInd]  DEFAULT ('N') FOR [DirectionalInd]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_OvernightRqd]  DEFAULT ('N') FOR [OvernightRqd]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_SatNightRqd]  DEFAULT ('N') FOR [SatNightRqd]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_ValidDaysOperand]  DEFAULT ('I') FOR [ValidDaysOperand]
GO

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_OperatingCarriersOperand]  DEFAULT ('I') FOR [OperatingCarriersOperand]
GO

ALTER TABLE [dba].[AirlineContractExhibits] ADD  CONSTRAINT [DF_AirlineContractExhibits_Commission]  DEFAULT ('N') FOR [Commission]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lists of contract carrier codes' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'ContractCarrierCodes'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measure goals on flown or ticket date?' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'MeasureGoalsOnDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measure payment on flown or issued date?' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'MeasurePayOnDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Period for measuring performance goals' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'GoalMeasurementPeriod'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date period for payments' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'PayMeasurementPeriod'
GO

