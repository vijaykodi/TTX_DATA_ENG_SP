/****** Object:  StoredProcedure [dba].[getMarketGeography]    Script Date: 7/14/2015 8:06:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dba.getMarketGeography(@marketId bigint, @theGeography varchar(4000) output)
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
