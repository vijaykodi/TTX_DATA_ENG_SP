/****** Object:  StoredProcedure [dbo].[PurgeForeignData]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PurgeForeignData] AS
BEGIN
DECLARE
	@ProcedureName varchar(50)
	,@LogStart datetime
	,@StepName varchar(50)
	,@BeginDate datetime 
	,@EndDate datetime 
	,@IataNum varchar(50) 
	,@RowCount int
	,@ERR int

  SET @ProcedureName  = 'PurgeForeignData'
  SET @LogStart  = GETDATE()
  SET @ERR = 0
    BEGIN TRY

          BEGIN TRANSACTION
                 DECLARE @ForeignTxCount  BIGINT        
                --DECLARE @PurgeKeys TABLE (RecordKey   VARCHAR(200))
                
                

                --INSERT INTO #PurgeKeys
                SELECT tCCH.RecordKey INTO #PurgeKeys 
                FROM dba.CCHeader AS tCCH WITH (NOLOCK)
                WHERE NOT EXISTS (SELECT 1
                                  FROM dba.dbbins dbB
                                  WHERE LEFT(tCCH.CreditCardNum, 6) = dbB.BinNumber
                                   )
                                   
                SELECT @ForeignTxCount =  @@ROWCOUNT
                SELECT @RowCount = @ForeignTxCount
                SELECT @STEPNAME = '1'
                IF @ForeignTxCount > 0
                BEGIN
                   
                    DELETE cas 
                    FROM dba.CCAirSeg AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '2'
                    DELETE cas 
                    FROM dba.CCAirSeg_Historical AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '3'
                    DELETE cas 
                    FROM dba.CCAtm AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '4'
                    DELETE cas 
                    FROM dba.CCCar AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '5'
                    DELETE cas 
                    FROM dba.CCCar_Historical AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '6'
                    DELETE cas 
                    FROM dba.CCEvent AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '7'
                    DELETE cas 
                    FROM dba.CCExpense AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '8'
                    DELETE cas 
                    FROM dba.CCExpense_Historical AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '9'
                    --DELETE cas 
                    --FROM dba.CCHeader_old AS cas
                    --INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    --SELECT @STEPNAME = '10'
                    DELETE cas 
                    FROM dba.CCHotel AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '11'
                    DELETE cas 
                    FROM dba.CCHotel_Historical AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '12'
                    DELETE cas 
                    FROM dba.CCHotelFolio AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '13'
                    DELETE cas 
                    FROM dba.CCHotelFolioItem AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '14'
                    DELETE cas 
                    FROM dba.CCInsurance AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '15'
                    DELETE cas 
                    FROM dba.CCMailorder AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '16'
                    DELETE cas 
                    FROM dba.CCMATCHCAR AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '17'
                    DELETE cas 
                    FROM dba.CCMATCHHTL AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '18'
                    DELETE cas 
                    FROM dba.CCMATCHTKT AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '19'
                    DELETE cas 
                    FROM dba.CCOil AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '20'
                    DELETE cas 
                    FROM dba.CCRestaurant AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '21'
                    DELETE cas 
                    FROM dba.CCRetail AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '22'
                    DELETE cas 
                    FROM dba.CCTelephone AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '23'
                    DELETE cas 
                    FROM dba.CCTicket AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '24'
                    DELETE cas 
                    FROM dba.CCTicket_Historical AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '25'
                    DELETE cas 
                    FROM dba.CCAirSeg AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '26'
                    DELETE cas 
                    FROM dba.CCHeader AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '27'

                   
                    --DECLARE #PurgeCo TABLE (CompanyId   VARCHAR(200))

                    --INSERT INTO #PurgeCo (CompanyId)
                    SELECT DISTINCT ct.HeaderTrailerCompanyIdentification AS companyId into #PurgeCo
                    FROM dba.CardTransaction AS ct WITH (NOLOCK)
                    WHERE NOT EXISTS (SELECT 1
                                      FROM dba.dbbins dbB WITH (NOLOCK)
                                      WHERE LEFT(ct.AccountNumber, 6) = dbB.BinNumber
                                       )  
                    SELECT @STEPNAME = '28'                   
                    DELETE cas 
                    FROM dba.AccountBalance AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.companyId
                    SELECT @STEPNAME = '29'

                    --SELECT TOP 10 * FROM dba.AccountBalance AS ab

                    DELETE cas 
                    FROM dba.Allocation AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '30'

                    DELETE cas 
                    FROM dba.AllocationDescription AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '31'

                    DELETE cas 
                    FROM dba.CardAccount  AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '32'

                    DELETE cas 
                    FROM dba.CardHolder AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '33'
                    DELETE cas 
                    FROM dba.CardTransaction  AS cas WITH (TABLOCKX)
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '34'
                    DELETE cas 
                    FROM dba.CarRentalDetail AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '35'

                    DELETE cas 
                    FROM dba.CarRentalSummary AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '36'

                    DELETE cas 
                    FROM dba.company AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '37'

                    DELETE cas 
                    FROM dba.FleetProduct  AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '38'

                    DELETE cas 
                    FROM dba.FleetService AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '39'

                    DELETE cas 
                    FROM dba.HeaderTrailer AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.CompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '40'

                    DELETE cas 
                    FROM dba.HeadquarterRelationship AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '41'

                    DELETE cas 
                    FROM dba.LegSpecificInformation AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '42'

                    DELETE cas 
                    FROM dba.LineItemDetail AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '43'
                    DELETE cas 
                    FROM dba.LineItemSummary AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '44'
                    DELETE cas 
                    FROM dba.LodgingDetail AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '45'
                    DELETE cas 
                    FROM dba.LodgingSummary AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '46'
                    DELETE cas 
                    FROM dba.Organization AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '47'
                    DELETE cas 
                    FROM dba.PassengerItinerary AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId

                    SELECT @STEPNAME = '48'
                    DELETE cas 
                    FROM dba.Period  AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '49'


                    DELETE cas 
                    FROM dba.AccountBalance AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '51'

                    DELETE cas 
                    FROM dba.Phone AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '52'

                    DELETE cas 
                    FROM dba.ReferenceData AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '54'

                    DELETE cas 
                    FROM dba.ShippingServices AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '55'



                    DELETE cas 
                    FROM dba.supplier AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '56'

                    DELETE cas 
                    FROM dba.TemporaryServices AS cas
                    INNER JOIN #PurgeCo AS pc ON cas.HeaderTrailerCompanyIdentification = pc.CompanyId
                    SELECT @STEPNAME = '57'

                    DELETE cas 
                    FROM dba.CCHeader_Historical AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '58'
                    DELETE cas 
                    FROM dba.CCHeader AS cas
                    INNER JOIN #purgekeys tPK ON cas.RecordKey = tPK.RecordKey
                    SELECT @STEPNAME = '59'
                    --Log this even though it didn't error...It's still an error situation Code 0 means Ran Successful 1 Unsuccessful
                    EXEC [dbo].[sp_LogProcErrors]       
                    @ProcedureName
                   ,@LogStart
                   ,@StepName
                   ,@BeginDate
                   ,@EndDate
                   ,@IataNum
                   ,@RowCount
                   ,@ERR 
                END             
          COMMIT TRANSACTION
          DROP TABLE #PurgeKeys
          DROP TABLE #PurgeCo
    END TRY
    BEGIN CATCH
      IF @@TRANCOUNT > 0 BEGIN   
        ROLLBACK TRANSACTION
        SELECT @ERR = 1
        EXEC [dbo].[sp_LogProcErrors]       @ProcedureName
             ,@LogStart
             ,@StepName
             ,@BeginDate
             ,@EndDate
             ,@IataNum
             ,@RowCount
             ,@ERR      
      END
    END CATCH 
	
END 


GO
