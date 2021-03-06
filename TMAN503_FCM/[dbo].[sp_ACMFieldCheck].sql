/****** Object:  StoredProcedure [dbo].[sp_ACMFieldCheck]    Script Date: 7/14/2015 8:06:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:          Charlie Bradsher
-- Create date:     2013-07-10
-- Description:     Finds invalid city, country and airport codes in contract builds
-- =============================================
CREATE PROCEDURE [dbo].[sp_ACMFieldCheck]

AS
BEGIN
      SET NOCOUNT ON;

TRUNCATE TABLE DBA.ACMFieldCheck

--  Remove spaces in fields

update dba.AirlineContracts
Set ContractCarrierCodes = Replace(ContractCarrierCodes,' ','')

update dba.AirlineContractExhibits
Set PointOfSale = Replace(PointOfSale,' ','')

update dba.AirlineContractMarkets
Set OriginCountry = Replace(OriginCountry,' ','')
,DestinationCountry = Replace(DestinationCountry,' ','')
,GatewayCountry = Replace(GatewayCountry,' ','')
,TripOrigCountry = Replace(TripOrigCountry,' ','')
,OriginCity = Replace(OriginCity,' ','')
,DestinationCity = Replace(DestinationCity,' ','')
,GatewayCity = Replace(GatewayCity,' ','')
,TripOrigCity = Replace(TripOrigCity,' ','')
,MktPair = Replace(MktPair,' ','')
,ValidatingCarriers = Replace(ValidatingCarriers,' ','')
,FlownCarriers = Replace(FlownCarriers,' ','')
,OperatingCarriers = Replace(OperatingCarriers,' ','')
,ClassOfService = Replace(ClassOfService,' ','')

/**********************************************************************
          Check Country Codes
**********************************************************************/
-- Exhibits - Point Of Sale

Declare @MaxLen int
Declare @Start int

Set @MaxLen = (select max(Len(PointOfSale))from dba.AirlineContractExhibits)
Set @Start = 1
While @Start < @MaxLen
Begin
Insert into dba.ACMFieldCheck
      Select distinct CustomerID, 'CountryCode',PointOfSale, substring(PointOfSale,@Start,2), 'ACE.PointOfSale' , @Start, ContractNumber, ExhibitNumber, null
      from dba.airlinecontractexhibits
      left outer join dba.country on (Substring(PointOfSale,@Start,2) = CtryCode )
      where PointOfSale is not null
      and Substring(PointOfSale,@Start,2) <> ''
      group by CustomerID, PointOfSale, CtryCode,ContractNumber, ExhibitNumber
      having CtryCode is null
  Set @Start = @Start+3
End


--  M - OriginCountry


Set @MaxLen = (select max(Len(OriginCountry))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck
        Select distinct CustomerID, 'CountryCode',OriginCountry , substring(OriginCountry,@Start,2), 'ACM.OriginCountry', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.country on (Substring(OriginCountry,@Start,2) = CtryCode)
        where OriginCountry is not null
        and Substring(OriginCountry,@Start,2) <> ''
        group by CustomerID, OriginCountry, CtryCode, ContractNumber, ExhibitNumber, MarketNumber
        having CtryCode is null
Set @Start = @Start+3
End

--  M - DestinationCountry

Set @MaxLen = (select max(Len(DestinationCountry))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck
        Select distinct CustomerID, 'CountryCode',DestinationCountry , substring(DestinationCountry,@Start,2), 'ACM.DestinationCountry', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.country on (Substring(DestinationCountry,@Start,2) = CtryCode)
        where DestinationCountry is not null
        and Substring(DestinationCountry,@Start,2) <> ''      
        group by CustomerID, DestinationCountry, CtryCode, ContractNumber, ExhibitNumber, MarketNumber
        having CtryCode is null
        
        
Set @Start = @Start+3
End

--  M - GatewayCountry

Set @MaxLen = (select max(Len(GatewayCountry))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck
        Select distinct CustomerID, 'CountryCode',GatewayCountry , substring(GatewayCountry,@Start,2), 'ACM.GatewayCountry', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.country on (Substring(GatewayCountry,@Start,2) = CtryCode)
        where GatewayCountry is not null
        and Substring(GatewayCountry,@Start,2) <> ''    
        group by CustomerID, GatewayCountry, CtryCode, ContractNumber, ExhibitNumber, MarketNumber
        having CtryCode is null
Set @Start = @Start+3
End


--  M - TripOrigCountry


Set @MaxLen = (select max(Len(TripOrigCountry))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck
        Select distinct CustomerID, 'CountryCode',TripOrigCountry , substring(TripOrigCountry,@Start,2), 'ACM.TripOrigCountry', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.country on (Substring(TripOrigCountry,@Start,2) = CtryCode)
        where TripOrigCountry is not null
        and Substring(TripOrigCountry,@Start,2) <> ''   
        group by CustomerID, TripOrigCountry, CtryCode, ContractNumber, ExhibitNumber, MarketNumber
        having CtryCode is null
Set @Start = @Start+3
End


--  M - OriginCity

Set @MaxLen = (select max(Len(OriginCity))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'AirportCode',OriginCity , substring(OriginCity,@Start,3), 'ACM.OriginCity', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCity on (Substring(OriginCity,@Start,3) = StationCode)
        where OriginCity is not null
        and Substring(OriginCity,@Start,3) <> ''        
        and TypeCode = 'A'      
        group by CustomerID, OriginCity, StationCode, ContractNumber, ExhibitNumber, MarketNumber
        having StationCode is null
Set @Start = @Start+4
End

--  M - DestinationCity

Set @MaxLen = (select max(Len(DestinationCity))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'AirportCode',DestinationCity , substring(DestinationCity,@Start,3), 'ACM.DestinationCity', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCity on (Substring(DestinationCity,@Start,3) = StationCode)
        where DestinationCity is not null
        and TypeCode = 'A'
        and Substring(DestinationCity,@Start,3) <> ''   
        group by CustomerID, DestinationCity, StationCode, ContractNumber, ExhibitNumber, MarketNumber
        having StationCode is null
Set @Start = @Start+4
End

--  M - GatewayCity

Set @MaxLen = (select max(Len(GatewayCity))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'AirportCode',GatewayCity , substring(GatewayCity,@Start,3), 'ACM.GatewayCity', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCity on (Substring(GatewayCity,@Start,3) = StationCode)
        where GatewayCity is not null
        and TypeCode = 'A'
        and Substring(GatewayCity,@Start,3) <> ''       
        group by CustomerID, GatewayCity, StationCode, ContractNumber, ExhibitNumber, MarketNumber
        having StationCode is null
Set @Start = @Start+4
End

--  M - TripOrigCity

Set @MaxLen = (select max(Len(TripOrigCity))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'AirportCode',TripOrigCity , substring(TripOrigCity,@Start,3), 'ACM.TripOrigCity', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCity on (Substring(TripOrigCity,@Start,3) = StationCode)
        where TripOrigCity is not null
        and TypeCode = 'A'
        and Substring(TripOrigCity,@Start,3) <> ''      
        group by CustomerID, TripOrigCity, StationCode, ContractNumber, ExhibitNumber, MarketNumber
        having StationCode is null
Set @Start = @Start+4
End

--  M - MktPair

Set @MaxLen = (select max(Len(MktPair))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'AirportCode',MktPair , substring(MktPair,@Start,3), 'ACM.MktPair', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCity on (Substring(MktPair,@Start,3) = StationCode)
        where MktPair is not null
        and TypeCode = 'A'
        and Substring(MktPair,@Start,3) <> ''     
        group by CustomerID, MktPair, StationCode, ContractNumber, ExhibitNumber, MarketNumber
        having StationCode is null
Set @Start = @Start+4
End

-- M - Validating Carriers

Set @MaxLen = (select max(Len(ValidatingCarriers))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'CarrierCode',ValidatingCarriers , substring(ValidatingCarriers,@Start,2), 'ACM.ValidatingCarriers', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCarriers on (Substring(ValidatingCarriers,@Start,2) = CarrierCode)
        where ValidatingCarriers is not null
        and Substring(ValidatingCarriers,@Start,2) <> ''      
        group by CustomerID, ValidatingCarriers, CarrierCode, ContractNumber, ExhibitNumber, MarketNumber
        having CarrierCode is null
Set @Start = @Start+3
End

-- M - Flown Carriers

Set @MaxLen = (select max(Len(FlownCarriers))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'CarrierCode',FlownCarriers , substring(FlownCarriers,@Start,2), 'ACM.FlownCarriers', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCarriers on (Substring(FlownCarriers,@Start,2) = CarrierCode)
        where FlownCarriers is not null
        and Substring(FlownCarriers,@Start,2) <> ''     
        group by CustomerID, FlownCarriers, CarrierCode, ContractNumber, ExhibitNumber, MarketNumber
        having CarrierCode is null
Set @Start = @Start+3
End

-- M - Operating Carriers

Set @MaxLen = (select max(Len(OperatingCarriers))from dba.airlinecontractmarkets)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'CarrierCode',OperatingCarriers , substring(OperatingCarriers,@Start,2), 'ACM.OperatingCarriers', @Start, ContractNumber, ExhibitNumber, MarketNumber
        from dba.airlinecontractmarkets
        left outer join dba.ACMCarriers on (Substring(OperatingCarriers,@Start,2) = CarrierCode)
        where OperatingCarriers is not null
        and Substring(OperatingCarriers,@Start,2) <> ''       
        group by CustomerID, OperatingCarriers, CarrierCode, ContractNumber, ExhibitNumber, MarketNumber
        having CarrierCode is null
Set @Start = @Start+3
End

-- C - ContractCarrierCodes

Set @MaxLen = (select max(Len(ContractCarrierCodes))from dba.airlinecontracts)
Set @Start = 1
While @Start < @MaxLen
Begin
   Insert into dba.ACMFieldCheck 
        Select distinct CustomerID, 'CarrierCode',ContractCarrierCodes , substring(ContractCarrierCodes,@Start,2), 'AC.ContractCarrierCodes', @Start, ContractNumber, null, null
        from dba.airlinecontracts
        left outer join dba.ACMCarriers on (Substring(ContractCarrierCodes,@Start,2) = CarrierCode)
        where ContractCarrierCodes is not null
        and Substring(ContractCarrierCodes,@Start,2) <> ''    
        group by CustomerID, ContractCarrierCodes, CarrierCode, ContractNumber
        having CarrierCode is null
Set @Start = @Start+3
End

--  Delele correct rail terms

Delete ACF
from dba.ACMFieldCheck acf, dba.ACMCity
where ReferenceValue = StationCode
and TypeCode = 'R'


END

GO
