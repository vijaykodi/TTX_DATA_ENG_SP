/****** Object:  StoredProcedure [dbo].[CCTicketFix]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CCTicketFix] AS
BEGIN

INSERT INTO dba.CCTicket
        ( RecordKey
        ,IATANum
        ,ClientCode
        ,TransactionDate        
        ,TicketNum
        ,ValCarrierCode
        ,ValCarrierNum
        ,BilledDate
        ,TicketAmt
        ,BilledCurrCode
        ,BatchName
        ,AdvPurchGroup
        )  
SELECT tCCH.RecordKey
      ,tCCH.IATANum
      ,tCCH.ClientCode
      ,tCCH.TransactionDate
      ,CASE WHEN ISNUMERIC(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''))>0
                  THEN CAST(CAST(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), '') AS BIGINT) AS VARCHAR)
                  ELSE REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), '')
                  END 
      ,CASE WHEN IndustryCode = '01' THEN tCAR.CarrierCode ELSE 'XD' END
      ,CASE WHEN IndustryCode = '01' THEN LEFT(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''), 3) ELSE '999' END
      ,tCCH.BilledDate
      ,tCCH.BilledAmt
      ,tCCH.BilledCurrCode
      ,tCCH.IATANum
      ,CASE WHEN tCCH.RefundInd = 'Y' THEN 'REFUNDS' ELSE 'UNKOWN' END
      
FROM dba.CCHeader AS tCCH
LEFT OUTER JOIN dba.Carriers tCAR ON  LEFT(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''), 3) = tCAR.CarrierNumber
                                  
                                  AND tCAR.Status = 'A'
                                  AND tCAR.TypeCode = 'A'
WHERE (tCCH.MarketCode = '4722' OR tCCH.IndustryCode in ('08', '01'))
AND NOT EXISTS (SELECT 1
                FROM dba.CCTicket AS ct
                WHERE tCCH.RecordKey = ct.RecordKey
                    AND tCCH.IATANum = ct.IATANum
                    AND tCCH.ClientCode = ct.ClientCode
                    AND tCCH.TransactionDate = ct.TransactionDate)
AND  PATINDEX('%[0-9]%', tCCH.ChargeDesc) >0
AND PATINDEX('%[a-z]%', LEFT(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''), 3)) =0  

UPDATE tID
SET DocumentNumber =  CAST(CAST(InvoiceNum AS bigint) AS VARCHAR) + CASE WHEN tih.OrigCountry = 'GB' THEN CAST(CAST(tid.TicketingAgentID AS BIGINT) AS varchar) ELSE '' END 
    ,VendorType = 'NONBSP'
    ,ValCarrierNum = 999
    ,ValCarrierCode = 'XD'   
         
FROM dba.InvoiceDetail tID
INNER JOIN dba.InvoiceHeader tih ON tID.RecordKey = tih.RecordKey
WHERE tid.VendorType = 'NONAIR'
AND tid.IataNum = 'BCCWTAZ'
AND tid.DocumentNumber IS NULL
AND ISNUMERIC(tih.InvoiceNum) > 0

END

GO
