/****** Object:  StoredProcedure [dbo].[CCTicketFix]    Script Date: 7/14/2015 7:49:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CCTicketFix] AS
BEGIN

SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @ProcName varchar(50), @TransStart datetime

	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=NULL,@EndDate=NULL,@IataNum='CCFix',@RowCount=@@ROWCOUNT,@ERR=@@ERROR



INSERT INTO dba.CCTicket
        (RecordKey
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
        
SELECT distinct tCCH.RecordKey -- added distinct by Y.L. 2014-11-03
      ,tCCH.IATANum
      ,tCCH.ClientCode
      ,tCCH.TransactionDate
      ,CASE WHEN ISNUMERIC(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''))>0
                  THEN CAST(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), '') AS VARCHAR)
                  ELSE REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), '')
                  END 
      ,CASE WHEN IndustryCode = '01' THEN tCAR.CarrierCode ELSE 'ZZ' END
      ,CASE WHEN IndustryCode = '01' THEN LEFT(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''), 3) ELSE '999' END
      ,tCCH.BilledDate
      ,tCCH.BilledAmt
      ,tCCH.BilledCurrCode
      ,tCCH.IATANum
      ,CASE WHEN tCCH.RefundInd = 'Y' THEN 'REFUNDS' ELSE 'UNKOWN' END
FROM dba.CCHeader AS tCCH
LEFT OUTER JOIN dba.Carriers tCAR ON LEFT(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''), 3) = tCAR.CarrierNumber
                                  AND tCAR.Status = 'A'
                                  AND tCAR.TypeCode = 'A'
                                  AND tCAR.CarrierNumber <> '101'
WHERE ISNUMERIC(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''))>0
AND (tCCH.MarketCode = '4722' OR tCCH.IndustryCode in ('08', '01'))
AND NOT EXISTS (SELECT 1
                FROM dba.CCTicket AS ct
                WHERE tCCH.RecordKey = ct.RecordKey
                    AND tCCH.IATANum = ct.IATANum
                    AND tCCH.ClientCode = ct.ClientCode
                    AND tCCH.TransactionDate = ct.TransactionDate)
AND PATINDEX('%[0-9]%', tCCH.ChargeDesc) > 0
AND PATINDEX('%[a-z]%', LEFT(REPLACE(tcch.chargedesc, LEFT(tCCH.ChargeDesc, PATINDEX('%[0-9]%', tCCH.ChargeDesc)-1), ''), 3)) = 0  
AND tCCH.ChargeDesc NOT LIKE 'WWW.FLYBE.CO%'
AND tCCH.ChargeDesc NOT LIKE 'CW%' 
AND tcch.ChargeDesc NOT LIKE 'HRG%'
AND tcch.ChargeDesc NOT LIKE 'carlson%'
AND tCCH.ChargeDesc NOT LIKE 'agent%'
AND tcch.ChargeDesc NOT LIKE 'chambers%'
AND tCCH.ChargeDesc NOT LIKE 'the travl%'
AND tCCH.ChargeDesc NOT LIKE 'ATP NEDERLAN%'
AND tCCH.ChargeDesc NOT LIKE 'ATP UK LTD%'
AND tCCH.ChargeDesc NOT LIKE 'AIR CHINA%'
AND tCCH.ChargeDesc NOT LIKE 'CAPITA TRVL%'
AND tCCH.ChargeDesc NOT LIKE 'REED & MACKAY%'
AND tCCH.ChargeDesc NOT LIKE 'BCD TRAVEL F844642546518'
AND tCCH.ChargeDesc NOT LIKE 'JET2 0%'
AND tCCH.ChargeDesc NOT LIKE 'PROMOVIATGES%'
AND tcch.ChargeDesc NOT LIKE 'FLYPEGASUS%'
AND tcch.ChargeDesc NOT LIKE 'GERMANWINGS%'
AND tcch.ChargeDesc NOT LIKE 'AMEXFEE%'
AND tcch.ChargeDesc NOT LIKE 'INTER+S POR COMPRAS @ 2.0%'


--Set Bank Charges/Payment to Unmatchable as TMC transactions will never match.
--Generic description MISC BANK CHARGES to replace all existing reason.
UPDATE cch
SET MatchedInd = 'U'
,Remarks10 = 'MISC BANK CHARGES'
--SELECT *
FROM dba.CCHeader cch
WHERE cch.CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
AND matchedind is null
and EXISTS (
SELECT *
FROM dba.ProfileBuilds pb
WHERE PARENTCARD IS null
AND cch.CreditCardNum = pb.CHILDCARD
)


UPDATE cct
SET ValCarrierCode = '2V'
--SELECT ValCarrierCode , '2V'
FROM dba.CCTicket cct
INNER JOIN dba.CCHeader cch ON (cct.RecordKey = cch.RecordKey)
WHERE cch.ChargeDesc LIKE 'AMTRAK%'
AND ValCarrierCode IS NULL


--Update CWTDE Vendor/Carrier Information (TAKEN OUT AS WAS NOT RUNNING - TESTED WITH CWTDE DATA NEED TO CONFIRM WITH CMORSE - ----- d cutts
	UPDATE tID
	SET  VendorType = 'NONBSP'
		,ValCarrierNum = 999
		,ValCarrierCode = CASE WHEN (tIH.OrigCountry = 'DE' AND tID.ProductType = 'TR') THEN 'DB' ELSE 'ZZ' END
		,VendorName = ISNULL(VendorName, CASE WHEN ProductType IN  ('TR', 'RAILSTC') THEN 'RAIL' ELSE NULL END)
	FROM dba.InvoiceDetail tID
	INNER JOIN dba.InvoiceHeader tih ON tID.RecordKey = tih.RecordKey
	WHERE (tid.VendorType IN ( 'NONAIR', 'RAIL', 'NONBSP', 'RAILSTC', 'NONBSPSTC') OR tid.VendorType IS NULL)
	AND tid.IataNum like 'BCCWTDE'
	AND (ValCarrierCode NOT IN ( 'ZZ', 'XD' ) OR tid.ValCarrierCode IS NULL )
	AND ValCarrierNum = 0

	UPDATE dba.InvoiceDetail
	SET VendorType = 'NONBSP'
	WHERE VendorType = 'NONBSPSTC'

--HRG UPDATE ticketnums to be InvoiceNums to help with the hand matching
	UPDATE tID
	SET VendorType = 'NONBSP'
		,ValCarrierNum = 999
		,ValCarrierCode = 'ZZ'                
	FROM dba.InvoiceDetail tID
	INNER JOIN dba.InvoiceHeader tih ON tID.RecordKey = tih.RecordKey
	WHERE (tid.VendorType IN ( 'NONAIR', 'RAIL', 'NONBSP') OR tid.VendorType IS NULL)
	AND tid.IataNum = 'BCHRGFR'
	AND ValCarrierCode != 'ZZ'

--Update all other NONBSP
	UPDATE dba.InvoiceDetail
	SET VendorType = 'NONBSP'
	WHERE VendorType NOT IN ('BSP', 'NONBSP', 'HOTEL', 'NOMATCH') OR VendorType IS NULL


--Fix Bad AF TicketNums
	UPDATE ct
	SET ct.TicketNum = LEFT(RIGHT(dbo.f_ParseTicketNum(chargedesc), 11), 10)
	FROM dba.CCTicket AS ct
	INNER JOIN dba.CCHeader AS ch ON ct.RecordKey = ch.RecordKey
	WHERE (ValCarrierCode IN ('AF', 'KL', 'TP') )
	AND LEFT(dbo.f_ParseTicketNum(chargedesc), 2) IN  ('57', '74', '47')
	AND ct.ticketnum != LEFT(RIGHT(dbo.f_ParseTicketNum(chargedesc), 11), 10)


--Fix AerLingus Tickets
	UPDATE ct
	SET ct.TicketNum =  LEFT(pi.TicketNumber, 6)
		,ct.TktReferenceNum =  LEFT(pi.TicketNumber, 6)
	FROM dba.CCTicket AS ct
	INNER JOIN dba.CCHeader AS ch ON ct.RecordKey = ch.RecordKey
	INNER JOIN dba.PassengerItinerary AS pi ON ch.TransactionNum = pi.TransactionReferenceNumber
	--INNER JOIN dba.CardTransaction AS ct2 ON ch.TransactionNum = ct2.TransactionReferenceNumber
	WHERE (ValCarrierCode = 'EI' OR ch.ChargeDesc LIKE '%RYANAIR%')
	AND ct.TicketNum IS NULL 
	AND CHARINDEX(' ', pi.TicketNumber) > 0

--Group Germany Fees ....Sort of
--EXEC dbo.FixBCRemarksAndUdefs
	UPDATE ct
	SET ct.remarks1 = PI.passengername
	--PATINDEX('%[0-9]%', ch.ChargeDesc)
	FROM dba.CCHeader AS ch
	INNER JOIN dba.CCTicket AS ct ON ch.RecordKey = ct.RecordKey
	INNER JOIN dba.CCHeader AS cchOrig ON RIGHT(cchOrig.ChargeDesc, LEN(cchOrig.ChargeDesc)-(PATINDEX('%[0-9]%', cchOrig.ChargeDesc))) = RIGHT(ch.ChargeDesc, LEN(ch.ChargeDesc)-(PATINDEX('%[0-9]%', ch.ChargeDesc)))
	INNER JOIN dba.PassengerItinerary AS pi ON cchOrig.TransactionNum = pi.TransactionReferenceNumber
	WHERE ch.ChargeDesc LIKE 'CARLSON WAGO%'
	AND PATINDEX('%[0-9]%', ch.ChargeDesc)>0
	AND ct.remarks1 IS NULL

--Unpad ticket numbers
	UPDATE id
	--set DocumentNumber = CAST(CAST(DocumentNumber AS BIGINT) AS VARCHAR)
	set DocumentNumber = CAST(CAST(DocumentNumber AS NUMERIC(20)) AS VARCHAR)
	FROM dba.InvoiceDetail id
	WHERE LEFT(DocumentNumber,1) = '0' AND ISNUMERIC(DocumentNumber) = 1
	AND DocumentNumber <> '0'
	
	UPDATE ih
	set InvoiceNum = CAST(CAST(InvoiceNum AS BIGINT) AS VARCHAR)
	FROM dba.InvoiceHeader AS ih
	WHERE LEFT(InvoiceNum,1) = '0' AND ISNUMERIC(InvoiceNum) = 1
	AND InvoiceNum <> '0'

--FIX A PREFIX IN AUTHCODES
	UPDATE dba.invoiceheader
	set ccapprovalcode = lTRIM(RTRIM(SUBSTRING(CCApprovalCode,2, LEN(CCApprovalCode) - 1)))
	from dba.InvoiceHeader AS ih 
	where lTRIM(RTRIM(SUBSTRING(ih.CCApprovalCode,1, 1))) like 'A%' 
	AND ISNUMERIC( lTRIM(RTRIM(SUBSTRING(ih.CCApprovalCode,2, LEN(ih.CCApprovalCode) - 1)))) = 1  

	UPDATE dba.Payment
	set ccapprovalcode = lTRIM(RTRIM(SUBSTRING(CCApprovalCode,2, LEN(CCApprovalCode) - 1)))
	from dba.payment AS p 
	where lTRIM(RTRIM(SUBSTRING(p.CCApprovalCode,1, 1))) like 'A%' 
	AND ISNUMERIC( lTRIM(RTRIM(SUBSTRING(p.CCApprovalCode,2, LEN(p.CCApprovalCode) - 1)))) = 1  

--FIX CCNUMS

	UPDATE ih
	set ccnum = RIGHT(ccnum, 16)
	FROM dba.InvoiceHeader AS ih
	WHERE LEFT(ccnum,4) = '0000' and LEN(ccnum) > 16

-- Fix BCREEUK LCC Doc Numbers

	UPDATE id
	SET id.DocumentNumber = RIGHT(id.DocumentNumber, LEN(id.DocumentNumber) - 3)
	FROM dba.InvoiceDetail id
	WHERE id.IataNum = 'BCREEUK' AND id.ValCarrierCode IN ('BE','U2')
	AND (id.DocumentNumber LIKE '000%' OR id.DocumentNumber LIKE '267%')
	
	
--BTD Serco fee record in CCT -IP 15OCT13

	INSERT INTO dba.CCTicket
        (RecordKey
        ,IATANum
        ,ClientCode
        ,TransactionDate        
        ,ValCarrierCode
        ,ValCarrierNum
        ,BilledDate
        ,TicketAmt
        ,BilledCurrCode
        ,BatchName
        ,AdvPurchGroup
        ,Remarks1
        ,Remarks2
        )  
	SELECT tCCH.RecordKey
      ,tCCH.IATANum
      ,tCCH.ClientCode
      ,tCCH.TransactionDate
      ,'ZZ'
      ,'00'
      ,tCCH.BilledDate
      ,tCCH.BilledAmt
      ,tCCH.BilledCurrCode
      ,tCCH.IATANum
      ,CASE WHEN tCCH.RefundInd = 'Y' THEN 'REFUNDS' ELSE 'UNKOWN' END
      ,tCCH.Remarks11
      ,tCCH.ChargeDesc
	FROM dba.CCHeader AS tCCH
	WHERE tCCH.IndustryCode in ('08', '01')
	AND NOT EXISTS (SELECT 1
		            FROM dba.CCTicket AS ct
			        WHERE tCCH.RecordKey = ct.RecordKey
                    AND tCCH.IATANum = ct.IATANum
                    AND tCCH.ClientCode = ct.ClientCode
                    AND tCCH.TransactionDate = ct.TransactionDate)
	AND tCCH.ChargeDesc IN ('BUSINESSTRAVELDIRE', 'AMERICAN EXPRESS L10 G45')
	AND tCCH.Remarks11 IS NOT NULL
		
	UPDATE cct
	SET cct.TicketNum = id.DocumentNumber
	FROM dba.CCTicket cct
	JOIN dba.InvoiceHeader ih ON cct.Remarks1 = ih.CCApprovalCode
	JOIN dba.InvoiceDetail id ON ih.RecordKey = id.RecordKey
	WHERE cct.Remarks2 = 'BUSINESSTRAVELDIRE'
	AND ih.IataNum = 'BCBTDUK'
	AND id.VendorName = 'Merchant Fee'
	AND cct.TicketNum IS NULL




--BCAMXG4 Service Fee fix

	--UPDATE cct
	--SET cct.TicketNum = id.DocumentNumber
	--FROM dba.CCTicket cct
	--JOIN dba.InvoiceHeader ih ON cct.Remarks1 = ih.CCApprovalCode
	--JOIN dba.InvoiceDetail id ON ih.RecordKey = id.RecordKey
	--WHERE cct.Remarks2 = 'AMERICAN EXPRESS L10 G45'
	--AND ih.IataNum = 'BCAMXG4'
	--AND id.ServiceDescription = 'FEE'
	--AND cct.TicketNum IS NULL
--BCGDGDF 
	--Update remarks5 with Originator Determined from ID.InvoiceTypeDescription
		--HOTEL TX
		update id
		set id.remarks5 = '760300'
		from dba.invoicedetail id
		where (id.InvoiceTypeDescription LIKE '%HOTELS%' OR VendorName LIKE '%HOTEL%')
		and id.iatanum = 'BCGDGDF' AND id.Remarks5 IN ('Y','N')
		
		--AIR TX
		--UPDATE REMARKS FUDGED A BIT MAY NEED TWEAKING - DCUTTS
		update id
		set id.remarks5 = '760010'
		from dba.invoicedetail id
		where (id.InvoiceTypeDescription LIKE '%Air%' OR VendorName LIKE '%AIR%')
		and id.iatanum = 'BCGDGDF' AND id.Remarks5 IN ('Y','N')
		
		--AIR TX
		--UPDATE REMARKS FUDGED A BIT MAY NEED TWEAKING - DCUTTS
		update id
		set id.remarks5 = '760010'
		from dba.invoicedetail id JOIN dba.Carriers AS c ON c.CarrierCode = id.ValCarrierCode
		WHERE id.iatanum = 'BCGDGDF' AND id.InvoiceTypeDescription IS NULL AND c.TypeCode = 'A'
		AND id.Remarks5 IN ('Y','N')		
				
		--RAIL TX
		update id
		set id.remarks5 = '760020'
		from dba.invoicedetail id
		where (id.InvoiceTypeDescription LIKE '%Rail%' OR VendorName LIKE '%TRAINLINE%')
		and id.iatanum = 'BCGDGDF' AND id.Remarks5 IN ('Y','N')
		
		update id
		set id.remarks5 = '760020'
		from dba.invoicedetail id JOIN dba.Carriers AS c ON c.CarrierCode = id.ValCarrierCode
		WHERE id.iatanum = 'BCGDGDF' AND id.InvoiceTypeDescription IS NULL AND c.TypeCode = 'R'
		AND id.Remarks5 IN ('Y','N')		
		
		--OTHER TX (FEES ETC) - updated to set all other fee's to new code
		update id
		set id.remarks5 = '760700'
		from dba.invoicedetail id
		WHERE id.iatanum = 'BCGDGDF'
		AND id.Remarks5 IN ('Y','N')
		AND VendorName IN (
			'ALLSEVEN 24 LTD',
			'EUROPCAR',
			'EVENT MGT',
			'SERVEBASE GLOBAL SOLUTIONS',
			'TRANSACTION FEE',
			'UK CAR HIRE'
			)
		AND id.InvoiceTypeDescription 
		NOT IN ('Airline Tickets','Domestic Rail','Foreign Rail','Hotels')

--ADD UNMATCHABLE TRANSACTIONS

	----Update SWIFT PAYMENT transactions to Unmatchable
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'SWIFT PAYMENT TRANSACTION'
	--WHERE MatchedInd IS NULL
	--AND ChargeDesc LIKE '%SWIFT PAYMENT%'

	----MISC BUSINESS SERVICES
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'MISC BUSINESS CHARGES'
	--WHERE MatchedInd IS NULL
	--AND ChargeDesc LIKE '%VIP BUSINESS SERVICES%'
	----MISAPPLIED PAYMENT
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'MISAPPLIED PAYMENT'
	--WHERE MatchedInd IS NULL
	--AND ChargeDesc LIKE '%MISAPPLIED PAYMENT%'

	----MISC INTEREST REFUND
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'MISC BANK CHARGES'
	--WHERE MatchedInd IS NULL
	--AND ChargeDesc = 'INTEREST REFUND'

	----AFTS PAYMENT	AFTS PAYMENT
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'MISC BANK CHARGES'
	--WHERE MatchedInd IS NULL
	--AND ChargeDesc LIKE '%AFTS PAYMENT%'
	
	--Amazon Web Services
	UPDATE dba.CCHeader
	SET MatchedInd = 'U',
	Remarks10 = 'AMAZON WEB SERVICES'
	WHERE MatchedInd IS NULL
	AND ChargeDesc = 'Amazon Web Services'

	----LATE PAYMENT FEE
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'MISC BANK CHARGES'
	--WHERE MatchedInd IS NULL AND (ChargeDesc = 'LATE PAYMENT FEE'
	--OR ChargeDesc like '%LATE PMT FEE REFUND%' 
	--OR ChargeDesc LIKE '%FRAIS PAIEMENT TARDIF%' 
	--OR ChargeDesc LIKE '%PURCHASE INTEREST 2.000%')
	
	----PURCHASE *FINANCE CHARGE*
	--UPDATE dba.CCHeader
	--SET MatchedInd = 'U',
	--Remarks10 = 'MISC BANK CHARGES'
	--WHERE MatchedInd IS NULL
	--AND ChargeDesc LIKE 'PURCHASE *FINANCE CHARGE*'	
	
	
		--CUSTOMER STATEMENT PAYMENTS
	UPDATE CCH
	SET MatchedInd = 'U', Remarks10 = 'MANUALLY CHARGED TRANSACTIONS'
	--SELECT MatchedInd,  'U', Remarks10, 'MANUALLY CHARGED TRANSACTIONS', billedamt, transactiondate
	FROM dba.CCHeader CCH
	WHERE MatchedInd IS NULL
		AND (ChargeDesc = 'CAPITA TRAVEL AND')


	
	----CUSTOMER STATEMENT PAYMENTS
	--UPDATE CCH
	--SET MatchedInd = 'U', Remarks10 = 'CUSTOMER PAYMENT'
	----SELECT MatchedInd,  'U', Remarks10, 'CUSTOMER PAYMENT'
	--FROM dba.CCHeader CCH
	--WHERE MatchedInd IS NULL
	--	AND (ChargeDesc = 'PAYMENT' OR ChargeDesc = 'DIRECT DEBIT PAYMENT THAN' OR Chargedesc = 'PAYMENT RECEIVED -- THANK')


	--DB UK BOOKING CENTRE
	UPDATE cch
	SET cch.MatchedInd = 'U',
	cch.Remarks10 = 'BCD UNABLE TO HAND OFF DB TRANSACTIONS'
	FROM dba.CCHeader AS cch
	JOIN dba.ProfileBuilds AS pb ON cch.creditcardNum = pb.CHILDCARD
	WHERE cch.MatchedInd IS NULL
	AND ChargeDesc IN ('DB UK BOOKING CENTRE', 'DB BAHN')
	AND AGENCYIATA = 'BCURENCO'

	
	--Gray Dawes unable to provide Hotel/Car data for GDF matching. 17/06/13 IP.
    UPDATE dba.CCHeader
	SET MatchedInd = 'U', Remarks10 = 'HOTEL EXPENSES NOT INVOICED'
	WHERE ClientCode = '129264669'
	AND IndustryCode = '03'
	AND MatchedInd IS NULL

	UPDATE dba.CCHeader
	SET MatchedInd = 'U', Remarks10 = 'CAR EXPENSES NOT INVOICED'
	WHERE ClientCode = '129264669'
	AND IndustryCode = '04'
	AND MatchedInd IS NULL

--Set ferry transactions to unmatchable for Amex bookings 
--####################################
--Added CONDOR FERRIES LTD + CONDOR LTD and removed "AND pb.AGENCYIATA = 'BCAMXG4'" from query //IanP - 18AUG14
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH FERRY TRANSACTIONS'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.ChargeDesc IN ('WWW.ISLEOFSCILLY-TRAVEL.','ORKNEY FERRIES',
'REDFUNNEL.CO.UK', 'WWW.CALMAC.CO.UK', 'CALMAC GOUROCK', 'WIGHTLINK FERRIES',
'WWW.WIGHTLINK.CO.UK', 'NORTHLINK FERRIES', 'IOM STEAM PACKET','ISLES OF SCILLY S S CO L',
'WWW.POFERRIES.COM', 'NORTHLINK', 'Stena Freight UK', 'Stena Line Ltd', 'WWW.PENTLANDFERRIES.CO','CALMAC ULLAPOOL'
,'CONDOR FERRIES LTD','CONDOR LTD','STEAM-PACKET.COM','BRITTANY FERRIES')
AND cch.MatchedInd IS NULL

-- Set Channel Islands (CI) flight transactions - BLUE ISLANDSMOCJAV to unmatchable - IanP // 18AUG14
--Commented out per SF52247. MJ
--UPDATE cch
--SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH CI FLIGHT TRANSACTIONS'
--SELECT cch.*
--FROM dba.CCHeader cch
--JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
--WHERE cch.ChargeDesc like ('BLUE ISLANDS%')
--ORDER BY cch.transactiondate desc
----AND cch.MatchedInd IS NULL

--Set Eurotunnel transactions to unmatchable for Amex bookings (G4S)
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH EUROTUNNEL TRANSACTIONS'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.ChargeDesc IN ('EUROTUNNEL PRESALE', 'E/TUNNEL INTERNET')
AND pb.AGENCYIATA = 'BCAMXG4'
AND cch.MatchedInd IS NULL

--Set CIBT transactions to unmatchable for Amex bookings (G4S)
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH CIBT TRANSACTIONS'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.ChargeDesc IN ('CIBT-ZVS','CIBT VISA SERVICES')
AND cch.MatchedInd IS NULL
AND pb.AGENCYIATA = 'BCAMXG4'

--Set LCC transactions to unmatchable for Amex bookings (G4S)
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH LCC TRANSACTIONS'
--SELECT CCH.*
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.ChargeDesc IN ('CITYWING AVIATION SERV','WWW.AURIGNY.COM','THOMAS COOK')
AND pb.AGENCYIATA = 'BCAMXG4'
AND cch.MatchedInd IS NULL

--Set unmatchable for Amex rail bookings = AEV AG.VOYAGES  4512851. IanP // 19AUG14
--UPDATE cch
--SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH AEV AG.VOYAGES'
--FROM dba.CCHeader cch
--JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
--WHERE cch.ChargeDesc IN ('AEV AG.VOYAGES  4512851')
--AND pb.AGENCYIATA like 'BCAMX%'
--AND cch.MatchedInd IS NULL


--Set unmatchable for Amex rail bookings = THE TRAINLINE.COM. IanP // 19AUG14 
UPDATE cch 
SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH THE TRAINLINE.COM' 
--SELECT cch.MatchedInd, 'U', cch.remarks10, 'UNABLE TO MATCH THE TRAINLINE.COM' 
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD 
WHERE cch.ChargeDesc IN ('THE TRAINLINE.COM') 
AND pb.AGENCYIATA like 'BCAMX%' 
AND cch.MatchedInd IS NULL 

--Set unmatchable for Uni of Northumbria fees. IanP // 19AUG14
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'UNABLE TO MATCH UNIVERSITY FEES'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.ChargeDesc IN ('GOODENOUGH COLLEGE','MAYNOOTH CAMPUS CONFER','HERTFORD COLLEGE OXFORD',
'WWW.GLA.AC.UK')
AND pb.AGENCYIATA like 'BCCAPUK'
AND cch.MatchedInd IS NULL


--Set Unmatchable for accounts marked as inactive in Profile builds. MJ 18Sep14
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'INACTIVE ACCOUNT. TMC FEED NOT AVAILABLE'
--SELECT cch.CreditCardNum, cch.MatchedInd , 'U', cch.remarks10 , 'INACTIVE ACCOUNT. TMC FEED NOT AVAILABLE'
FROM DBA.CCHeader cch
WHERE cch.TransactionDate >= GETDATE()-90
AND cch.MatchedInd IS null
AND EXISTS (SELECT 1 FROM dba.ProfileBuilds pb
WHERE pb.CHILDCARD = cch.CreditCardNum
AND pb.ACTIVEACCOUNT = 'N')



--Update IndustryCode for Reed&Mackay hotels
UPDATE cch
SET cch.industrycode = '03'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.IndustryCode = '02'
AND pb.AGENCYIATA = 'BCREEUK'

UPDATE cch
SET cch.matchedind = 'U', remarks10 = 'UNABLE TO MATCH HOTEL TRANSACTION'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.IndustryCode = '03'
AND pb.AGENCYIATA = 'BCREEUK'
AND MatchedInd IS NULL

--Set Hotels to Unmatchable when Cycle Date is more than 14 days old. Outside of matching window. 03 Ind Code is Hotel.
UPDATE cch
SET cch.matchedind = 'U', remarks10 = 'UNABLE TO MATCH HOTEL TRANSACTION'
FROM dba.CCHeader cch
WHERE cch.IndustryCode = '03'
AND MatchedInd IS NULL
AND cccycledate < getdate() --End of cycle


UPDATE cch
SET cch.matchedind = 'U'
,cch.Remarks10 = 'UNABLE TO MATCH HOTEL TRANSACTION'
--SELECT *
FROM dba.CCHeader cch
WHERE MatchedInd IS NULL
AND ChargeDesc LIKE '%HOTEL%'


UPDATE cch
SET cch.matchedind = 'U', remarks10 = 'UNABLE TO MATCH CAR TRANSACTION'
--select cch.chargedesc, cch.matchedind , 'U', remarks10 , 'UNABLE TO MATCH CAR TRANSACTION'
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
WHERE cch.IndustryCode = '04'
--AND pb.AGENCYIATA = 'BCREEUK'
AND MatchedInd IS NULL



--Update document numbers in ID for Eisai transactions based on auth code
UPDATE id
SET id.DocumentNumber = RIGHT(cch.ChargeDesc,8) 
-- select id.DocumentNumber, RIGHT(cch.ChargeDesc,8) 
FROM dba.InvoiceDetail id
JOIN dba.InvoiceHeader ih ON id.RecordKey = ih.RecordKey AND id.IataNum = ih.IataNum
JOIN dba.CCHeader cch ON ih.CCNum = cch.CreditCardNum AND ih.CCApprovalCode = cch.Remarks11
JOIN dba.ProfileBuilds pb ON ih.CCNum = pb.CHILDCARD
WHERE pb.GROUPNAME LIKE '%eisai%'
AND id.IataNum = 'BCCHAMB'
AND cch.ChargeDesc LIKE 'CHAMBERS TVL %'
AND id.DocumentNumber IS NULL
AND id.IssueDate > '20 feb 14'


--CHAMBERS DATA FIXES
	-- FIX AND POPULATE NULL TTLAMOUNT IN INVOICEDETAIL WHERE FEE 
	-- AMOUNTS IS IN THE TICKET BUT NOT THE FEE RECORD
update id
set id.TotalAmt = ltrim(rtrim(
	SUBSTRING(id.invoicetypedescription,
	CHARINDEX('Amount : ',id.invoicetypedescription)+9,len(id.invoicetypedescription)
		-CHARINDEX('Amount : ',id.invoicetypedescription)+9))),
	id.VendorType = 'NONBSP'
from dba.InvoiceDetail id
where id.InvoiceTypeDescription like '%Amount : %'
	and isnumeric(ltrim(rtrim(
	SUBSTRING(id.invoicetypedescription,
	CHARINDEX('Amount : ',id.invoicetypedescription)+9,len(id.invoicetypedescription)
		-CHARINDEX('Amount : ',id.invoicetypedescription)+9)))) = 1
and id.TotalAmt is NULL
and id.iatanum = 'BCCHAMB'

update id
set id.TotalAmt = '-'+ltrim(rtrim(
	SUBSTRING(id.invoicetypedescription,
	CHARINDEX('Amount : ',id.invoicetypedescription)+9,len(id.invoicetypedescription)
		-CHARINDEX('Amount : ',id.invoicetypedescription)+9))),
	id.VendorType = 'NONBSP'
from dba.InvoiceDetail id
where id.InvoiceTypeDescription like '%Amount : %'
	and isnumeric(ltrim(rtrim(
	SUBSTRING(id.invoicetypedescription,
	CHARINDEX('Amount : ',id.invoicetypedescription)+9,len(id.invoicetypedescription)
		-CHARINDEX('Amount : ',id.invoicetypedescription)+9)
))) = 1
and id.TotalAmt = '0'
AND id.RefundInd = 'Y'
and id.iatanum = 'BCCHAMB'


UPDATE id1
SET id1.TotalAmt = id1.TotalAmt-isnull(id2.TotalAmt,0), id1.ServiceFee = '0'
FROM dba.InvoiceDetail id1
JOIN dba.InvoiceDetail id2 ON id1.RecordKey = id2.RecordKey
						  AND id1.ServiceFee = id2.TotalAmt
WHERE id1.IataNum = 'BCCHAMB'
AND (id1.ServiceFee IS NOT NULL OR id1.ServiceFee != '0')


		--Move Chambers chargeno's to documentnumber for hand matching
		 -- UPDATE id
		 -- SET DocumentNumber = AccommodationType + CAST(seqnum AS varchar)
		 -- FROM
			--dba.InvoiceDetail AS id
		 -- WHERE
			--AccommodationType IS NOT NULL
			--AND IataNum = 'bcchamb'
			--AND DocumentNumber IS NULL

--Populate CWT DocumentNumbers where missing using InvoiceNum
UPDATE vrm2
SET vrm2.documentnumber = vrm1.documentnumber
--select pb.agencyiata, vrm2.recordkey, vrm1.documentnumber
FROM dbo.v_RelevantMatch vrm1
JOIN dbo.v_RelevantMatch vrm2 ON vrm1.InvoiceNum = vrm2.InvoiceNum
JOIN dba.ProfileBuilds pb ON vrm1.CCNum = pb.CHILDCARD
WHERE vrm1.DocumentNumber IS NOT NULL
AND vrm2.DocumentNumber IS NULL
AND vrm2.MatchedInd IS NULL
AND pb.AGENCYIATA LIKE '%cwt%'

--Populate Promoviatges ChargeDesc with InvoiceNumber where CCApprovalCode matches
UPDATE cch
SET cch.chargedesc = cch.chargedesc+' - '+ih.invoicenum
FROM dba.CCHeader cch
JOIN dba.InvoiceHeader ih ON ih.CCApprovalCode = cch.Remarks11
JOIN dba.InvoiceDetail id ON ih.RecordKey = id.RecordKey
WHERE ih.IataNum = 'BCPROMDE'
AND ih.CCApprovalCode IS NOT NULL
AND cch.MatchedInd IS NULL
AND id.MatchedInd IS NULL
AND cch.ChargeDesc = 'PROMOVIATGES'



--Update for invalid CCticket ticket nums
UPDATE CCT
SET cct.TicketNum = RIGHT(cct.TicketNum,8)
FROM dba.CCTicket cct
WHERE cct.TicketNum LIKE '2       00000%'

UPDATE CCT
SET cct.TicketNum = REPLACE(cct.TicketNum,'CANALE BSP','')
FROM dba.CCTicket cct
WHERE cct.TicketNum LIKE '%CANALE BSP%'



UPDATE cch
SET cch.matchedind = 'U', cch.remarks10 = 'UNABLE TO MATCH DAILY COMBINED TMC FEES'
--SELECT cch.matchedind , 'U', cch.remarks10 , 'UNABLE TO MATCH COMBINED FEES'
FROM dba.CCHeader cch, dba.ProfileBuilds pb
WHERE cch.CreditCardNum = pb.CHILDCARD
AND pb.AGENCYIATA = 'BCCLDUK'
And cch.ChargeDesc = 'CLYDE TRAVEL LTD'
AND cch. MatchedInd IS NULL


--Unmatchable HRG UK Heathrow Express transactions
UPDATE cch
SET cch.matchedind = 'U', cch.remarks10 = 'BOOKED OUTSIDE TMC'
FROM dba.CCHeader cch, dba.ProfileBuilds pb
WHERE cch.CreditCardNum = pb.CHILDCARD
AND pb.AGENCYIATA = 'BCHRGUK'
And cch.ChargeDesc = 'HEATHROW EXPRESS'
AND cch. MatchedInd IS NULL

UPDATE cch
SET cch.matchedind = 'U', cch.remarks10 = 'UNABLE TO MATCH FERRY TX'
FROM dba.CCHeader cch, dba.ProfileBuilds pb
WHERE cch.CreditCardNum = pb.CHILDCARD
And cch.ChargeDesc = 'P & O FERRIES LTD'
AND cch. MatchedInd IS NULL

UPDATE cch
SET cch.matchedind = 'U', cch.remarks10 = 'UNABLE TO MATCH PARKING TX'
FROM dba.CCHeader cch, dba.ProfileBuilds pb
WHERE cch.CreditCardNum = pb.CHILDCARD
And cch.ChargeDesc IN ('WWW.PURPLEPARKING.COM','PURPLE PARKING LIMITED')
AND cch. MatchedInd IS NULL

UPDATE cch
SET cch.matchedind = 'U', cch.remarks10 = 'BOOKED OUTSIDE THE TMC'
FROM dba.CCHeader cch, dba.ProfileBuilds pb
WHERE cch.CreditCardNum = pb.CHILDCARD
And cch.ChargeDesc = 'WWW.FLYBE.COE1HBSE'
AND cch. MatchedInd IS NULL

--Clear duplicate matched
EXEC dbo.ClearDupeHandMatches

--Recreate matches on anything previously purged
EXEC dbo.InvoiceDetailCCMatchFix



--SET CREDIT CARDS RECORDS TO UNMATCHABLE WHERE CARD NOT AVAILABLE IN TMC FEED.
UPDATE cch
SET cch.MatchedInd = 'U', cch.remarks10 = 'CARD NOT ACTIVE IN TMC FEED'
--SELECT *
FROM dba.CCHeader cch
WHERE MatchedInd IS NULL
AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
AND NOT EXISTS (SELECT 1 FROM dba.InvoiceHeader ih
				WHERE ih.ccnum = cch.CreditCardNum
				AND IH.InvoiceDate >= GETDATE()-180)

--Unmatch Records where New TMC Data Recieved.
update cch
set matchedind = null, remarks10 = null
--select CreditCardNum, matchedind , null, remarks10 , null
from dba.CCHeader cch
where CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
and cch.Remarks10 in ('CARD NOT ACTIVE IN TMC FEED','CC NUMBER NOT ACTIVE IN TMC FEED')
and exists (select ccnum, min(ih.InvoiceDate) from dba.InvoiceHeader ih
				where cch.CreditCardNum = ih.CCNum
				group by ccnum
				having cch.TransactionDate >= min(ih.InvoiceDate))


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure End',@BeginDate=NULL,@EndDate=NULL,@IataNum='CCFix',@RowCount=@@ROWCOUNT,@ERR=@@ERROR


END
GO
