/****** Object:  StoredProcedure [dba].[getMarketGeography]    Script Date: 7/7/2015 3:32:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dba].[getMarketGeography](@marketId bigint, @theGeography varchar(4000) output)
as begin
set @theGeography = 
(
SELECT 
	'OriginCity:' + (case when [OriginCity] is null then '' else [OriginCity] end) + ' ' +
		(case when [OriginCityOperand] is null then '' else [OriginCityOperand] end) + ';' +
	'DestinationCity:' + (case when [DestinationCity] is null then '' else [DestinationCity] end) + ' ' +
		(case when [DestinationCityOperand] is null then '' else [DestinationCityOperand] end) + ';' +
	'OriginState:' + (case when [OriginStateOperand] is null then '' else [OriginStateOperand] end) + ' ' + 
		(case when [OriginState] is null then '' else [OriginState] end) + ';' +
	'DestinationState:' + (case when DestinationStateOperand is null then '' else DestinationStateOperand end) + ' ' +
		(case when DestinationState is null then '' else DestinationState end) + ';' +
	'OriginCountry:' + (case when OriginCountryOperand is null then '' else OriginCountryOperand end) + ' ' +
		(case when OriginCountry is null then '' else OriginCountry end) + ';' +
	'DestinationCountry:' + (case when DestinationCountryOperand is null then '' else DestinationCountryOperand end) + ' ' +
		(case when DestinationCountry is null then '' else DestinationCountry end) + ';' +
	'OriginContinent:' + (case when OriginContinentOperand is null then '' else OriginContinentOperand end) + ' ' +
		(case when OriginContinent is null then '' else OriginContinent end) + ';' +
	'DestContinent:' + (case when DestContinentOperand is null then '' else DestContinentOperand end) + ' ' + 
		(case when DestContinent is null then '' else DestContinent end) + ';' +
	'GatewayCity:' + (case when GatewayCityOperand is null then '' else GatewayCityOperand end) + ' ' +
		(case when GatewayCity is null then '' else GatewayCity end) + ';' +
	'GatewayState:' + (case when GatewayStateOperand is null then '' else GatewayStateOperand end) + ' ' +
		(case when GatewayState is null then '' else GatewayState end) + ';' +
	'GatewayCountry:' + (case when GatewayCountryOperand is null then '' else GatewayCountryOperand end) + ' ' +
		(case when GatewayCountry is null then '' else GatewayCountry end) + ';' +
	'GatewayContinent:' + (case when GatewayContinentOperand is null then '' else GatewayContinentOperand end) + ' ' +
		(case when GatewayContinent is null then '' else GatewayContinent end) + ';' +
	'TripOrigCity:' + (case when TripOrigCityOperand is null then '' else TripOrigCityOperand end) + ' ' +
		(case when TripOrigCity is null then '' else TripOrigCity end) + ';' +
	'TripOrigCountry:' + (case when TripOrigCountryOperand is null then '' else TripOrigCountryOperand end) + ' '  +
		(case when TripOrigCountry is null then '' else TripOrigCountry end) + ';' +
	'TripOrigContinent:' + (case when TripOrigContinentOperand is null then '' else TripOrigContinentOperand end) + ' ' +
		(case when TripOrigContinent is null then '' else TripOrigContinent end) + ';' +
	'MktPair:' + (case when MktPairOperand is null then '' else MktPairOperand end) + ' ' +
		(case when MktPair is null then '' else MktPair end) + ';' +
	'PointOfSale:' + (case when PointOfSaleOperand is null then '' else PointOfSaleOperand end) + ' ' +
		(case when PointOfSale is null then '' else PointOfSale end) + ';' +
	'TripOrigState:' + (case when TripOrigStateOperand is null then '' else TripOrigStateOperand end) + ' ' +
		(case when TripOrigState is null then '' else TripOrigState end) + ';'
  FROM [dba].[AirlineContractMarkets] acm
  where acm.[ID] = @marketId
)
end;

GO

ALTER AUTHORIZATION ON [dba].[getMarketGeography] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContracts]    Script Date: 7/7/2015 3:32:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContracts](
	[ContractNumber] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [varchar](30) NOT NULL,
	[ContractName] [varchar](30) NOT NULL,
	[AirlineName] [varchar](50) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[ContractExtension] [datetime] NULL,
	[CustomerType] [varchar](2) NOT NULL,
	[ContractSignedDate] [datetime] NULL,
	[Description] [varchar](100) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[Approved] [bit] NULL,
	[Notes] [varchar](1000) NULL,
	[Status] [char](1) NULL,
	[Processed] [char](1) NULL,
	[ContractCarrierCodes] [varchar](255) NULL,
	[MeasureGoalsOnDate] [char](1) NULL,
	[MeasurePayOnDate] [char](1) NULL,
	[GoalMeasurementPeriod] [char](1) NULL,
	[PayMeasurementPeriod] [char](1) NULL,
	[TourCode] [varchar](255) NULL,
	[CreatedBy] [varchar](30) NULL,
	[CreatedDate] [datetime] NULL,
	[ApprovedBy] [varchar](30) NULL,
	[ApprovedDate] [datetime] NULL,
	[ProcessedDate] [datetime] NULL,
	[ContractType] [varchar](30) NULL,
	[Round] [int] NULL,
	[ProcessingStatus] [char](1) NULL,
 CONSTRAINT [PK_AirlineContracts] PRIMARY KEY CLUSTERED 
(
	[ContractNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContracts] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContractMarkets]    Script Date: 7/7/2015 3:32:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractMarkets](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [int] NOT NULL,
	[ExhibitNumber] [int] NOT NULL,
	[MarketNumber] [int] NOT NULL,
	[Description] [varchar](100) NULL,
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
	[MktBeginDate] [datetime] NULL,
	[MktEndDate] [datetime] NULL,
	[TripOrigCityOperand] [char](1) NULL,
	[TripOrigCity] [varchar](2000) NULL,
	[TripOrigCountryOperand] [char](1) NULL,
	[TripOrigCountry] [varchar](2000) NULL,
	[TripOrigContinentOperand] [char](1) NULL,
	[TripOrigContinent] [varchar](2000) NULL,
	[MktPairOperand] [char](1) NULL,
	[MktPair] [varchar](2000) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[PointOfSaleOperand] [char](1) NULL,
	[PointOfSale] [varchar](255) NULL,
	[QuestionFlag] [char](1) NULL,
	[Comments] [varchar](2000) NULL,
	[Validated] [char](1) NULL,
	[OriginRegion] [varchar](40) NULL,
	[DestinationRegion] [varchar](40) NULL,
	[TripOriginRegion] [varchar](40) NULL,
	[GatewayRegion] [varchar](40) NULL,
	[TripOrigStateOperand] [char](1) NULL,
	[TripOrigState] [varchar](2000) NULL,
	[MarketPairRegion] [varchar](40) NULL,
	[NeedsReview] [bit] NULL,
	[ReviewComments] [varchar](2000) NULL,
	[NeedsValidation] [bit] NULL,
	[EndorsementOrInstruction] [varchar](1000) NULL,
	[ProcessingOrder] [int] NULL,
	[OriginIataRegionOperand] [char](1) NULL,
	[OriginIataRegion] [varchar](1000) NULL,
	[TripOrigIataRegionOperand] [char](1) NULL,
	[TripOrigIataRegion] [varchar](1000) NULL,
	[DestIataRegionOperand] [char](1) NULL,
	[DestIataRegion] [varchar](1000) NULL,
	[GatewayIataRegionOperand] [char](1) NULL,
	[GatewayIataRegion] [varchar](1000) NULL,
 CONSTRAINT [PK_AirlineContractMarkets] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractMarkets] TO  SCHEMA OWNER 
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Approved]  DEFAULT ((0)) FOR [Approved]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Scenario]  DEFAULT ('I') FOR [Status]
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

ALTER TABLE [dba].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_DirectionalInd]  DEFAULT ('N') FOR [DirectionalInd]
GO

ALTER TABLE [dba].[AirlineContractMarkets]  WITH CHECK ADD  CONSTRAINT [FK_AirlineContractM​arkets_AirlineContra​cts] FOREIGN KEY([ContractNumber])
REFERENCES [dba].[AirlineContracts] ([ContractNumber])
ON DELETE CASCADE
GO

ALTER TABLE [dba].[AirlineContractMarkets] CHECK CONSTRAINT [FK_AirlineContractM​arkets_AirlineContra​cts]
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

