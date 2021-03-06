/****** Object:  StoredProcedure [dbo].[PurgeForeignData]    Script Date: 7/14/2015 7:49:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC PurgeForeignData AS

BEGIN


DECLARE @PurgeKeys TABLE (RecordKey   VARCHAR(200))

INSERT INTO @PurgeKeys
SELECT tCCH.RecordKey
FROM dba.CCHeader AS tCCH
WHERE NOT EXISTS (SELECT 1
                  FROM dba.dbbins dbB
                  WHERE LEFT(tCCH.CreditCardNum, 6) = dbB.BinNumber
                   )
                   
DELETE cas 
FROM dba.CCAirSeg AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCAirSeg_Historical AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCAtm AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCCar AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCCar_Historical AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCEvent AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCExpense AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCExpense_Historical AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHeader_Historical AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHeader_old AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHotel AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHotel_Historical AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHotelFolio AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHotelFolioItem AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCInsurance AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCMailorder AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCMATCHCAR AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCMATCHHTL AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCMATCHTKT AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCOil AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCRestaurant AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCRetail AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCTelephone AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCTicket AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCTicket_Historical AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCAirSeg AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey

DELETE cas 
FROM dba.CCHeader AS cas
INNER JOIN @PurgeKeys tPK ON cas.RecordKey = tPK.RecordKey


                   
DECLARE @PurgeCo TABLE (CompanyiID   VARCHAR(200))

INSERT INTO @PurgeCo (CompanyiID)
SELECT DISTINCT ct.HeaderTrailerCompanyIdentification
FROM dba.CardTransaction AS ct WITH (NOLOCK)
WHERE NOT EXISTS (SELECT 1
                  FROM dba.dbbins dbB WITH (NOLOCK)
                  WHERE LEFT(ct.AccountNumber, 6) = dbB.BinNumber
                   )  
                   
DELETE cas 
FROM dba.AccountBalance AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.Allocation AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.AllocationDescription AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.CardAccount  AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.CardHolder AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.CardTransaction  AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.CarRentalDetail AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.CarRentalSummary AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.company AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.FleetProduct  AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.FleetService AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.HeaderTrailer AS cas
INNER JOIN @PurgeCo AS pc ON cas.CompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.HeadquarterRelationship AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.LegSpecificInformation AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.LineItemDetail AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.LineItemSummary AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.LodgingDetail AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.LodgingSummary AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.Organization AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.PassengerItinerary AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.Period  AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID



DELETE cas 
FROM dba.Period_Historical AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.AccountBalance AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.Phone AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.Phone_Historical AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.ReferenceData AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.ShippingServices AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID




DELETE cas 
FROM dba.supplier AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID


DELETE cas 
FROM dba.TemporaryServices AS cas
INNER JOIN @PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyiID

END
GO
