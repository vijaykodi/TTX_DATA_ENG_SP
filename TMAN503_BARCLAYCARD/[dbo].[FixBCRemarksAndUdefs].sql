/****** Object:  StoredProcedure [dbo].[FixBCRemarksAndUdefs]    Script Date: 7/14/2015 7:49:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FixBCRemarksAndUdefs] AS
BEGIN
  DECLARE @error INT
  BEGIN TRY  
    --Move Dossiers/Remarks1-5 to UD101-105
    --Should think about changing udefnum to 900
    BEGIN TRANSACTION
      --DECLARE @UdefSQL  NVARCHAR(2000)
      --DECLARE @iatanum  VARCHAR(8) = 'BCCWT%'
      --DECLARE @parmDefinition NVARCHAR(500)
      --DECLARE @intVariable INT = 1


      --    WHILE @intVariable != 6 
      --    BEGIN
      --      SET @UdefSQL = 
      --                  N'INSERT INTO dba.Udef
      --                      (RecordKey
      --                     , IataNum
      --                     , SeqNum
      --                     , ClientCode
      --                     , InvoiceDate
      --                     , IssueDate
      --                     , UdefNum                   
      --                     , UdefData
      --                      )
      --                  SELECT     RecordKey
      --                                 , IataNum
      --                                 , SeqNum
      --                                 , ClientCode
      --                                 , InvoiceDate
      --                                 , IssueDate
      --                                 , 100+@UdefNum                           
      --                                 , Remarks'+CAST(@intVariable AS VARCHAR)+
      --                              ' FROM dba.InvoiceDetail AS id
      --                              WHERE NOT EXISTS (SELECT 1
      --                                              FROM dba.Udef u 
      --                                              WHERE u.RecordKey = id.RecordKey
      --                                              AND u.IataNum = id.IataNum
      --                                              AND u.SeqNum = id.SeqNum
      --                                              AND u.ClientCode = id.ClientCode
      --                                              AND u.IssueDate = id.IssueDate
      --                                              AND u.UdefNum = 100+@UdefNum
      --                                              and u.IataNum = id.iatanum                          
      --                                              )
      --                                and id.iatanum like @iatanum
      --                                and Remarks'+CAST(@intVariable AS VARCHAR)+' IS NOT NULL'

      --      SET @parmDefinition = N'@UdefNum INTEGER, @iatanum varchar(8)'
      --      PRINT 'Build Udef ' + CAST(@intVariable AS VARCHAR)

      --      EXECUTE sp_executesql @UdefSQL, @parmdefinition, @UdefNum = @intVariable, @iatanum = @iatanum
      --    SELECT @intVariable = @intVariable +1
      --    END

    --Update Remarks 1-5 and ShipHotelName
    

    --Pull out records that need to be updated  
        PRINT 'Build Work Table'
        SELECT RecordKey, IataNum, SeqNum  INTO #RecordKeyTmp
        FROM dba.InvoiceDetail AS id
        WHERE id.ShipHotelName IS NULL
        AND ID.IataNum IN ('BCGDGDF', 'BCCWTIT', 'BCCWTIE', 'BCCWTUK', 'BCCWTES', 'BCCWTFR',
						'BCCWTDE', 'BCCWTLU')

      --Back Stuff up in case something goes wrong before we validate this stuff
      PRINT 'create backup'
      INSERT INTO dba.InvoiceDetailCMBackup
          (RecordKey
         , IataNum
         , SeqNum
         , ClientCode
         , InvoiceDate
         , IssueDate
         , VoidInd
         , VoidReasonType
         , Salutation
         , FirstName
         , Lastname
         , MiddleInitial
         , InvoiceType
         , InvoiceTypeDescription
         , DocumentNumber
         , EndDocNumber
         , VendorNumber
         , VendorType
         , ValCarrierNum
         , ValCarrierCode
         , VendorName
         , BookingDate
         , ServiceDate
         , ServiceCategory
         , InternationalInd
         , ServiceFee
         , InvoiceAmt
         , TaxAmt
         , TotalAmt
         , CommissionAmt
         , CancelPenaltyAmt
         , CurrCode
         , FareCompare1
         , ReasonCode1
         , FareCompare2
         , ReasonCode2
         , FareCompare3
         , ReasonCode3
         , FareCompare4
         , ReasonCode4
         , Mileage
         , Routing
         , DaysAdvPurch
         , AdvPurchGroup
         , TrueTktCount
         , TripLength
         , ExchangeInd
         , OrigExchTktNum
         , Department
         , ETktInd
         , ProductType
         , TourCode
         , EndorsementRemarks
         , FareCalcLine
         , GroupMult
         , OneWayInd
         , PrefTktInd
         , HotelNights
         , CarDays
         , OnlineBookingSystem
         , AccommodationType
         , AccommodationDescription
         , ServiceType
         , ServiceDescription
         , ShipHotelName
         , Remarks1
         , Remarks2
         , Remarks3
         , Remarks4
         , Remarks5
         , IntlSalesInd
         , MatchedInd
         , MatchedFields
         , RefundInd
         , OriginalInvoiceNum
         , BranchIataNum
         , GDSRecordLocator
         , BookingAgentID
         , TicketingAgentID
         , OriginCode
         , DestinationCode
         , TktCO2Emissions
         , CCMatchedRecordKey
         , CCMatchedIataNum
         , ACQMatchedInd
         , ACQMatchedRecordKey
         , ACQMatchedIataNum
         , CarrierString
         , ClassString
         , CRMatchedInd
         , CRMatchedRecordKey
         , CRMatchedIataNum
         , LastImportDt
         , GolUpdateDt
          )
      SELECT
           tid.RecordKey
         , tid.IataNum
         , tid.SeqNum
         , tid.ClientCode
         , tid.InvoiceDate
         , tid.IssueDate
         , tid.VoidInd
         , tid.VoidReasonType
         , tid.Salutation
         , tid.FirstName
         , tid.Lastname
         , tid.MiddleInitial
         , tid.InvoiceType
         , tid.InvoiceTypeDescription
         , tid.DocumentNumber
         , tid.EndDocNumber
         , tid.VendorNumber
         , tid.VendorType
         , tid.ValCarrierNum
         , tid.ValCarrierCode
         , tid.VendorName
         , tid.BookingDate
         , tid.ServiceDate
         , tid.ServiceCategory
         , tid.InternationalInd
         , tid.ServiceFee
         , tid.InvoiceAmt
         , tid.TaxAmt
         , tid.TotalAmt
         , tid.CommissionAmt
         , tid.CancelPenaltyAmt
         , tid.CurrCode
         , tid.FareCompare1
         , tid.ReasonCode1
         , tid.FareCompare2
         , tid.ReasonCode2
         , tid.FareCompare3
         , tid.ReasonCode3
         , tid.FareCompare4
         , tid.ReasonCode4
         , tid.Mileage
         , tid.Routing
         , tid.DaysAdvPurch
         , tid.AdvPurchGroup
         , tid.TrueTktCount
         , tid.TripLength
         , tid.ExchangeInd
         , tid.OrigExchTktNum
         , tid.Department
         , tid.ETktInd
         , tid.ProductType
         , tid.TourCode
         , tid.EndorsementRemarks
         , tid.FareCalcLine
         , tid.GroupMult
         , tid.OneWayInd
         , tid.PrefTktInd
         , tid.HotelNights
         , tid.CarDays
         , tid.OnlineBookingSystem
         , tid.AccommodationType
         , tid.AccommodationDescription
         , tid.ServiceType
         , tid.ServiceDescription
         , tid.ShipHotelName
         , tid.Remarks1
         , tid.Remarks2
         , tid.Remarks3
         , tid.Remarks4
         , tid.Remarks5
         , tid.IntlSalesInd
         , tid.MatchedInd
         , tid.MatchedFields
         , tid.RefundInd
         , tid.OriginalInvoiceNum
         , tid.BranchIataNum
         , tid.GDSRecordLocator
         , tid.BookingAgentID
         , tid.TicketingAgentID
         , tid.OriginCode
         , tid.DestinationCode
         , tid.TktCO2Emissions
         , tid.CCMatchedRecordKey
         , tid.CCMatchedIataNum
         , tid.ACQMatchedInd
         , tid.ACQMatchedRecordKey
         , tid.ACQMatchedIataNum
         , tid.CarrierString
         , tid.ClassString
         , tid.CRMatchedInd
         , tid.CRMatchedRecordKey
         , tid.CRMatchedIataNum
         , tid.LastImportDt
         , tid.GolUpdateDt
    
      FROM dba.invoicedetail tID
      INNER JOIN #RecordKeyTmp AS rkt ON tID.Recordkey = rkt.RecordKey
                                      AND tID.iatanum = rkt.IataNum
                                      AND tiD.Seqnum = rkt.SeqNum
      WHERE NOT EXISTS (SELECT 1 
                          FROM dba.InvoiceDetailCMBackup AS idcb
                          WHERE tID.Recordkey = idcb.RecordKey
                                      AND tID.iatanum = idcb.IataNum
                                      AND tiD.Seqnum = idcb.SeqNum)
      AND tID.IataNum IN ('BCGDGDF', 'BCCWTIT', 'BCCWTIE', 'BCCWTUK', 'BCCWTES', 'BCCWTFR',
						'BCCWTDE', 'BCCWTLU')
 
      --Move UDEFS to remarks  --This should be temporary...Ultimately should map all to ComRmks and update 5503 report accordingly
      PRINT 'update remarks'
       UPDATE id
      SET id.remarks1 = COALESCE(u1.UdefData, ID.remarks1, 'NO TMC DATA AVAILABLE')
          ,id.remarks2 = COALESCE(u2.udefdata, id.remarks2, 'NO TMC DATA AVAILABLE')
          ,id.remarks3 = COALESCE(u3.udefdata, id.remarks3, 'NO TMC DATA AVAILABLE')
          ,id.remarks4 = COALESCE(u4.udefdata, id.remarks4, 'NO TMC DATA AVAILABLE')
          ,id.remarks5 = COALESCE(u5.udefdata, id.remarks5, 'NO TMC DATA AVAILABLE')
          ,id.shiphotelname = ISNULL(u103.UdefData, 'X')
      --SELECT DISTINCT * 
      FROM dba.InvoiceDetail AS id
      INNER JOIN #RecordKeyTmp AS rkt ON id.RecordKey = rkt.RecordKey
                                     AND id.IataNum = rkt.IataNum
                                     AND id.SeqNum = rkt.SeqNum

      LEFT OUTER  JOIN dba.udef u1 ON u1.RecordKey = id.RecordKey
                              AND u1.SeqNum = id.SeqNum
                              AND u1.IataNum = id.IataNum
                              AND u1.UdefNum = 1
      LEFT OUTER  JOIN dba.udef u2 ON u2.RecordKey = id.RecordKey
                              AND u2.SeqNum = id.SeqNum
                              AND u2.IataNum = id.IataNum
                              AND u2.UdefNum = 2
      LEFT OUTER  JOIN dba.udef u3 ON u3.RecordKey = id.RecordKey
                              AND u3.SeqNum = id.SeqNum
                              AND u3.IataNum = id.IataNum
                              AND u3.UdefNum = 3
      LEFT OUTER  JOIN dba.udef u4 ON u4.RecordKey = id.RecordKey
                              AND u4.SeqNum = id.SeqNum
                              AND u4.IataNum = id.IataNum
                              AND u4.UdefNum = 4
      LEFT OUTER  JOIN dba.udef u5 ON u5.RecordKey = id.RecordKey
                              AND u5.SeqNum = id.SeqNum
                              AND u5.IataNum = id.IataNum
                              AND u5.UdefNum = 5
      LEFT OUTER  JOIN dba.udef u103 ON u5.RecordKey = id.RecordKey
                              AND u103.SeqNum = id.SeqNum
                              AND u103.IataNum = id.IataNum
                              AND u103.UdefNum = 103     
      WHERE id.ShipHotelName IS NULL
     AND ID.IataNum IN ('BCGDGDF', 'BCCWTIT', 'BCCWTIE', 'BCCWTUK', 'BCCWTES', 'BCCWTFR',
						'BCCWTDE', 'BCCWTLU')
      

INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
FROM dba.InvoiceDetail
where iatanum in ('BCHRGFR')
AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
FROM dba.ComRmks
WHERE iatanum in ('BCHRGFR'))

      
      	  UPDATE cr
      SET cr.Text1 = COALESCE(u1.UdefData, cr.text1, 'NO TMC DATA AVAILABLE')
         ,cr.Text2 = COALESCE(u2.udefdata, cr.text2, 'NO TMC DATA AVAILABLE')
         ,cr.Text3 = COALESCE(u3.udefdata, cr.text3, 'NO TMC DATA AVAILABLE')
         ,cr.Text4 = COALESCE(u4.udefdata, cr.text4, 'NO TMC DATA AVAILABLE')
         ,cr.Text5 = COALESCE(u5.udefdata, cr.text5, 'NO TMC DATA AVAILABLE')
      FROM dba.ComRmks cr
     INNER JOIN #RecordKeyTmp AS rkt ON cr.RecordKey = rkt.RecordKey
                                     AND cr.IataNum = rkt.IataNum
                                     AND cr.SeqNum = rkt.SeqNum
	  
	  LEFT OUTER JOIN dba.udef u1 ON u1.RecordKey = cr.RecordKey
                              AND u1.SeqNum = cr.SeqNum
                              AND u1.IataNum = cr.IataNum
                              AND u1.UdefNum = 1
      LEFT OUTER JOIN dba.udef u2 ON u2.RecordKey = cr.RecordKey
                              AND u2.SeqNum = cr.SeqNum
                              AND u2.IataNum = cr.IataNum
                              AND u2.UdefNum = 2
      LEFT OUTER JOIN dba.udef u3 ON u3.RecordKey = cr.RecordKey
                              AND u3.SeqNum = cr.SeqNum
                              AND u3.IataNum = cr.IataNum
                              AND u3.UdefNum = 3
      LEFT OUTER JOIN dba.udef u4 ON u4.RecordKey = cr.RecordKey
                              AND u4.SeqNum = cr.SeqNum
                              AND u4.IataNum = cr.IataNum
                              AND u4.UdefNum = 4
      LEFT OUTER JOIN dba.udef u5 ON u5.RecordKey = cr.RecordKey
                              AND u5.SeqNum = cr.SeqNum
                              AND u5.IataNum = cr.IataNum
                              AND u5.UdefNum = 5
      LEFT OUTER JOIN dba.udef u103 ON u5.RecordKey = cr.RecordKey
                              AND u103.SeqNum = cr.SeqNum
                              AND u103.IataNum = cr.IataNum
                              AND u103.UdefNum = 103     
      WHERE cr.IataNum IN ('BCGDGDF', 'BCCWTIT', 'BCCWTIE', 'BCCWTUK', 'BCCWTES', 'BCCWTFR',
						'BCCWTDE', 'BCCWTLU')
      
      
      UPDATE cr
      SET cr.Text1 = COALESCE(u4.udefdata, cr.text1, 'NO TMC DATA AVAILABLE')
         ,cr.Text2 = COALESCE(u1.udefdata, cr.text2, 'NO TMC DATA AVAILABLE')
         ,cr.Text3 = COALESCE(u2.udefdata, cr.text3, 'NO TMC DATA AVAILABLE')
         ,cr.Text4 = 'NO TMC DATA AVAILABLE'
         ,cr.Text5 = 'NO TMC DATA AVAILABLE'
         ,cr.Text6 = 'NO TMC DATA AVAILABLE'
         ,cr.Text7 = 'NO TMC DATA AVAILABLE'
         ,cr.Text8 = COALESCE(u3.udefdata, cr.text8, 'NO TMC DATA AVAILABLE')
         FROM dba.ComRmks cr
     INNER JOIN #RecordKeyTmp AS rkt ON cr.RecordKey = rkt.RecordKey
                                     AND cr.IataNum = rkt.IataNum
                                     AND cr.SeqNum = rkt.SeqNum
	  
	  LEFT OUTER JOIN dba.udef u1 ON u1.RecordKey = cr.RecordKey
                              AND u1.SeqNum = cr.SeqNum
                              AND u1.IataNum = cr.IataNum
                              AND u1.UdefNum = 1
      LEFT OUTER JOIN dba.udef u2 ON u2.RecordKey = cr.RecordKey
                              AND u2.SeqNum = cr.SeqNum
                              AND u2.IataNum = cr.IataNum
                              AND u2.UdefNum = 2
      LEFT OUTER JOIN dba.udef u3 ON u3.RecordKey = cr.RecordKey
                              AND u3.SeqNum = cr.SeqNum
                              AND u3.IataNum = cr.IataNum
                              AND u3.UdefNum = 3
      LEFT OUTER JOIN dba.udef u4 ON u4.RecordKey = cr.RecordKey
                              AND u4.SeqNum = cr.SeqNum
                              AND u4.IataNum = cr.IataNum
                              AND u4.UdefNum = 4
      WHERE cr.IataNum IN ('BCHRGFR')
      
      
      
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    SELECT @error = @@ERROR
    IF @@TRANCOUNT > 0 
    BEGIN 
    DECLARE @today DATETIME
    SELECT @today = getdate() 
    ROLLBACK TRANSACTION
      EXEC [dbo].[sp_LogProcErrors]       'UpdateBarclayCardUdefs'
            ,@today
            ,''
            ,NULL
            ,NULL
            ,NULL
            ,0
            ,@ERROR
    END    	
  END CATCH  
END


GO
