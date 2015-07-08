/****** Object:  StoredProcedure [dbo].[sp_ACM_Stage_Contracts]    Script Date: 7/7/2015 5:07:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		  Chalrie Bradsher
-- Create date:	  2012-08-23
-- Description:	  Stage Contract data for Processing
-- =============================================
CREATE PROCEDURE [dbo].[sp_ACM_Stage_Contracts] (
	@CustomerID varchar(30)   -- MasterCustNo
	--@Contract varchar(30)	   -- ContractNumber....   If contract number is not provided then all contracts are re-staged
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    	
DECLARE @ClientRequestName varchar(20)
DECLARE @ContractCarrier varchar(50)
Declare @Contract varchar(30)

--  Update CustRollUp (adds Master value UBS for new/undefined clientcodes)

Insert into dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
Select IH.IataNum, IH.ClientCode, 'SANOFI'
from dba.InvoiceHeader IH
left outer join dba.CustRollup CRoll on (IH.IataNum = CRoll.AgencyIataNum
and IH.ClientCode = CRoll.CustNo)
where IH.IataNum not like 'Pre%'
Group by  IH.IataNum, IH.ClientCode, CRoll.CustNo
having CRoll.CustNo is null

/************************************************************************
    Delete data for re-processing  (ContractRmks and ACMInfo only)
*************************************************************************/

Delete ACRmks
from dba.ContractRmks ACRmks, dba.CustRollup Croll, dba.AirlineContracts AC
where ACRmks.IataNum = CRoll.AgencyIataNum
and ACRmks.ClientCode = CRoll.CustNo
and ACRmks.ContractID = AC.ContractNumber
and CRoll.MasterCustNo = AC.CustomerID
and CRoll.MasterCustNo = 'SANOFI'
--and ContractID = isnull(@Contract,ContractID)

/************************************************************************
    Insert ContractRmk records
*************************************************************************/

Insert into dba.ContractRmks
( RecordKey
, IataNum
, SeqNum
, SegmentNum
, ClientCode
, InvoiceDate
, IssueDate
, ContractID
, RouteType
, DiscountedFare
, LongHaulOrigCityCode
, LongHaulDestCityCode
, LongHaulMktOrigCityCode
, LongHaulMktDestCityCode
, LongHaulFMS
, LongHaulMileage
, MINOpCarrierCode
, MINFMS
, InterlineFlag
, POSCountry
, DepartureDate
)
 Select 
      ACMI.RecordKey
    , ACMI.IataNum
    , ACMI.SeqNum
    , ACMI.SegmentNum
    , ACMI.ClientCode
    , ACMI.InvoiceDate
    , ACMI.IssueDate
    , AC.ContractNumber
    , ACMI.RouteType
    , ACMI.DiscountedFare
    , ACMI.LongHaulOrigCityCode
    , ACMI.LongHaulDestCityCode
    , ACMI.LongHaulMktOrigCityCode
    , ACMI.LongHaulMktDestCityCode
    , ACMI.LongHaulFMS
    , ACMI.LongHaulMileage
    , ACMI.MINOpCarrierCode
    , MINFMS
    , ACMI.InterlineFlag
    , ACMI.POSCountry
    , ACMI.DepartureDate
    from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollUp CRoll
    where CRoll.MasterCustNo = AC.CustomerID
    and ACMI.IataNum = CRoll.AgencyIataNum
    and ACMI.ClientCode = CRoll.CustNo
    and CRoll.MasterCustNo = 'SANOFI'
   -- and AC.ContractNumber = isnull(@Contract,AC.ContractNumber)
    and ACMI.IssueDate between ( Select Min(ACG.GoalBeginDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)
		  	    and ( Select Max(ACG.GoalEndDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)	    
    and ACMI.DepartureDate between ( Select Min(ACG.TravelBeginDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)
		  	    and ( Select Max(ACG.TravelEndDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)
  

/************************************************************************
    Set Online Flag - contract carrier is the first airline in 
    the contractcarriercodes field of in AirlineContracts table
*************************************************************************/

--  Use AirlineContracts.ContractCarrierCodes on DepartureDate  

DECLARE airline_cursor CURSOR FOR
select Distinct ContractNumber, left(ContractCarrierCodes,2)
from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollup CRoll
where AC.CustomerID = CRoll.MasterCustNo
and ACMI.Iatanum = CRoll.AgencyIataNum
and ACMI.ClientCode = CRoll.CustNo
and CRoll.MasterCustNo = 'SANOFI'
--and AC.ContractNumber = isnull(@Contract,AC.ContractNumber)
order by 1

Open airline_cursor

fetch next from airline_cursor into @Contract, @ContractCarrier

while @@Fetch_Status = 0

  BEGIN
  
	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD, dba.InvoiceHeader IH, dba.CustRollUp CRoll
	 where TS.RecordKey = ACRmks.RecordKey
	 and TS.IataNum = ACRmks.IataNum
	 and TS.SeqNum = ACRmks.SeqNum
	 and TS.SegmentNum = ACRmks.SegmentNum
	 and TS.RecordKey = IH.RecordKey
	 and TS.IataNum = IH.IataNum
	 and ACRmks.RecordKey = IH.RecordKey
	 and ACRmks.IataNum = IH.IataNum
	 and ACRmks.ContractId = @Contract
	 and TS.OriginCityCode = ACSO.StationCode
	 and ACSO.CarrierCode = @ContractCarrier
	 and TS.MinDestCityCode = ACSD.StationCode
	 and ACSD.CarrierCode = @ContractCarrier
	 AND ACRmks.DepartureDate between ACSO.BeginDate and ACSO.EndDate
	 AND ACRmks.DepartureDate between ACSD.BeginDate and ACSD.EndDate
	 and ACRmks.Iatanum = CRoll.AgencyIataNum
	 and ACRmks.ClientCode = CRoll.CustNo
	 and IH.Iatanum = CRoll.AgencyIataNum
	 and IH.ClientCode = CRoll.CustNo
	 and CRoll.MasterCustNo = 'SANOFI'
	 and ACRmks.ContractID = @Contract
	
 
  fetch next from airline_cursor into @Contract, @ContractCarrier
  
  END

CLOSE airline_cursor
DEALLOCATE airline_cursor

--  Use AirlineContracts.ContractCarrierCodes on Current Schedule   

DECLARE airline_cursor CURSOR FOR
select Distinct ContractNumber, left(ContractCarrierCodes,2)
from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollup CRoll
where AC.CustomerID = CRoll.MasterCustNo
and ACMI.Iatanum = CRoll.AgencyIataNum
and ACMI.ClientCode = CRoll.CustNo
and CRoll.MasterCustNo = 'SANOFI'
--and AC.ContractNumber = isnull(@Contract,AC.ContractNumber)
order by 1

Open airline_cursor

-- Fetch gets first record
fetch next from airline_cursor into @Contract, @ContractCarrier

while @@Fetch_Status = 0

  BEGIN
  
	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD, dba.InvoiceHeader IH, dba.CustRollUp CRoll
	 where TS.RecordKey = ACRmks.RecordKey
	 and TS.IataNum = ACRmks.IataNum
	 and TS.SeqNum = ACRmks.SeqNum
	 and TS.SegmentNum = ACRmks.SegmentNum
	 and TS.RecordKey = IH.RecordKey
	 and TS.IataNum = IH.IataNum
	 and ACRmks.RecordKey = IH.RecordKey
	 and ACRmks.IataNum = IH.IataNum
	 and ACRmks.ContractId = @Contract
	 and TS.OriginCityCode = ACSO.StationCode
	 and ACSO.CarrierCode = @ContractCarrier
	 and TS.MinDestCityCode = ACSD.StationCode
	 and ACSD.CarrierCode = @ContractCarrier
	 and ACSO.BeginDate = (select Max(BeginDate) from dba.AirlineContractAirportStats)
	 and ACSD.BeginDate = (select Max(BeginDate) from dba.AirlineContractAirportStats)
	 and ACRmks.OnlineFlag is null
	 and ACRmks.Iatanum = CRoll.AgencyIataNum
	 and ACRmks.ClientCode = CRoll.CustNo
	 and IH.Iatanum = CRoll.AgencyIataNum
	 and IH.ClientCode = CRoll.CustNo
	 and CRoll.MasterCustNo = 'SANOFI'
	 and ACRmks.ContractID = @Contract
 
  fetch next from airline_cursor into @Contract, @ContractCarrier
  
  END

CLOSE airline_cursor
DEALLOCATE airline_cursor

--  Finish up online

update ACRmks
set OnlineFlag = 'N'
from dba.ContractRmks ACRmks, dba.InvoiceHeader IH, dba.CustRollup CRoll
where IH.RecordKey = ACRmks.RecordKey
and IH.IataNum = ACRmks.IataNum
and ACRmks.OnlineFlag is null
and IH.Iatanum = CRoll.AgencyIataNum
and IH.ClientCode = CRoll.CustNo
and CRoll.MasterCustNo = 'SANOFI'
--and ACRmks.ContractID = isnull(@Contract,ACRmks.ContractID)




END


GO

ALTER AUTHORIZATION ON [dbo].[sp_ACM_Stage_Contracts] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 5:07:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NOT NULL,
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
	[CCCode] [varchar](6) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[InvoiceHeader] ADD [CCExp] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CCApprovalCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [GDSCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [BackOfficeID] [varchar](20) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [IMPORTDT] [datetime] NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [TtlCO2Emissions] [float] NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CCLastFour] [varchar](4) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CLIQCID] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CLIQUSER] [varchar](100) NULL
 CONSTRAINT [PK_InvoiceHeader] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CustRollup]    Script Date: 7/7/2015 5:07:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CustRollup](
	[AgencyIATANum] [varchar](8) NULL,
	[MasterCustNo] [varchar](15) NULL,
	[CustNo] [varchar](15) NULL,
	[CustName] [varchar](40) NULL,
	[FeeInd] [varchar](1) NULL,
	[YieldInd] [varchar](1) NULL,
	[StartDate] [datetime] NULL,
	[SalesAgent] [varchar](40) NULL,
	[PaymentType] [varchar](7) NULL,
	[FeeIfUnderAmt] [float] NULL,
	[CreditCardNum] [varchar](25) NULL,
	[CreditCardExpdate] [varchar](7) NULL,
	[DefaultFee] [varchar](2) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CustRollup] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ContractRmks]    Script Date: 7/7/2015 5:07:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ContractRmks](
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

ALTER AUTHORIZATION ON [dba].[ContractRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContracts]    Script Date: 7/7/2015 5:08:06 PM ******/
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

/****** Object:  Table [dba].[AirlineContractGoals]    Script Date: 7/7/2015 5:08:09 PM ******/
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

/****** Object:  Table [dba].[AirlineContractAirportStats]    Script Date: 7/7/2015 5:08:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractAirportStats](
	[StationCode] [varchar](3) NULL,
	[CarrierCode] [varchar](3) NULL,
	[CarrierDepartures] [float] NULL,
	[StationDepartures] [float] NULL,
	[CarrierSeats] [float] NULL,
	[StationSeats] [float] NULL,
	[SeatShare] [float] NULL,
	[FlightShare] [float] NULL,
	[MaxSeatShare] [float] NULL,
	[MaxFlightShare] [float] NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractAirportStats] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ACMInfo]    Script Date: 7/7/2015 5:08:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ACMInfo](
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
	[commission] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ACMInfo] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 5:08:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[OriginCityCode] [varchar](10) NULL,
	[SegmentCarrierCode] [varchar](3) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[CodeShareCarrierCode] [varchar](3) NULL,
	[EquipmentCode] [varchar](10) NULL,
	[PrefAirInd] [varchar](1) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[FlightNum] [varchar](15) NULL,
	[ClassOfService] [varchar](8) NULL,
	[FareBasis] [varchar](30) NULL,
	[TktDesignator] [varchar](15) NULL,
	[ConnectionInd] [varchar](1) NULL,
	[StopOverTime] [int] NULL,
	[FrequentFlyerNum] [varchar](15) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SEGDestCityCode] [varchar](10) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[SEGCO2Emissions] [float] NULL,
	[NOXCO2Emissions] [float] NULL,
	[MINCO2Emissions] [float] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[TtlSeats] [int] NULL,
	[SegTrueTktCount] [int] NULL,
	[YieldInd] [varchar](1) NULL,
	[YieldAmt] [float] NULL,
	[YieldDatePosted] [datetime] NULL,
 CONSTRAINT [PK_TranSeg] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 5:08:40 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CustRollupPX]    Script Date: 7/7/2015 5:08:41 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CustRollupPX] ON [dba].[CustRollup]
(
	[MasterCustNo] ASC,
	[CustNo] ASC,
	[AgencyIATANum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI1]    Script Date: 7/7/2015 5:08:41 PM ******/
CREATE CLUSTERED INDEX [ContractRmksI1] ON [dba].[ContractRmks]
(
	[ClientCode] ASC,
	[ContractID] ASC,
	[DepartureDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractsPX]    Script Date: 7/7/2015 5:08:41 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractsPX] ON [dba].[AirlineContracts]
(
	[CustomerID] ASC,
	[ContractNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractGoalsPX]    Script Date: 7/7/2015 5:08:42 PM ******/
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

/****** Object:  Index [AirlineContractAirportStatsPX1]    Script Date: 7/7/2015 5:08:42 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractAirportStatsPX1] ON [dba].[AirlineContractAirportStats]
(
	[BeginDate] DESC,
	[EndDate] DESC,
	[StationCode] ASC,
	[CarrierCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI1]    Script Date: 7/7/2015 5:08:43 PM ******/
CREATE CLUSTERED INDEX [ACMInfoI1] ON [dba].[ACMInfo]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 5:08:45 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/7/2015 5:08:47 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [dba].[InvoiceHeader]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/7/2015 5:08:48 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [dba].[InvoiceHeader]
(
	[BookingBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 5:08:48 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ContractRmksI2]    Script Date: 7/7/2015 5:08:48 PM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI2] ON [dba].[ContractRmks]
(
	[GoalExhibitNum] ASC,
	[GoalMarketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ContractRmksI3]    Script Date: 7/7/2015 5:08:49 PM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI3] ON [dba].[ContractRmks]
(
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksPx]    Script Date: 7/7/2015 5:08:49 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ContractRmksPx] ON [dba].[ContractRmks]
(
	[ContractID] ASC,
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_AirlineContractGoals]    Script Date: 7/7/2015 5:08:49 PM ******/
CREATE NONCLUSTERED INDEX [IX_AirlineContractGoals] ON [dba].[AirlineContractGoals]
(
	[Status] ASC,
	[GoalType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ACMInfoI2]    Script Date: 7/7/2015 5:08:50 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI2] ON [dba].[ACMInfo]
(
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI3]    Script Date: 7/7/2015 5:08:50 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI3] ON [dba].[ACMInfo]
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

/****** Object:  Index [ACMInfoI4]    Script Date: 7/7/2015 5:08:51 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI4] ON [dba].[ACMInfo]
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

/****** Object:  Index [ACMInfoI5]    Script Date: 7/7/2015 5:08:53 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI5] ON [dba].[ACMInfo]
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

/****** Object:  Index [ACMInfoPX]    Script Date: 7/7/2015 5:08:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ACMInfoPX] ON [dba].[ACMInfo]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TransegI2]    Script Date: 7/7/2015 5:08:56 PM ******/
CREATE NONCLUSTERED INDEX [TransegI2] ON [dba].[TranSeg]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [TransegI3]    Script Date: 7/7/2015 5:08:56 PM ******/
CREATE NONCLUSTERED INDEX [TransegI3] ON [dba].[TranSeg]
(
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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

