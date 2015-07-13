/****** Object:  StoredProcedure [dbo].[sp_ANCILLARY_FEES]    Script Date: 11/13/2014 09:23:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Laurie Webb>
-- Create date: <11/13/2014>
-- Description:	<Ancillary Fees for VMWare>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ANCILLARY_FEES]

AS

SET NOCOUNT ON 


    DECLARE @Iata					VARCHAR(50), 
            @ProcName				VARCHAR(50), 
            @TransStart				DATETIME, 
            @MaxImportDt			DATETIME, 
            @FirstInvDate			DATETIME, 
            @LastInvDate			DATETIME, 
            @IataNum				VARCHAR(8),
			@LocalBeginIssueDate	DATETIME, 
            @LocalEndIssueDate		DATETIME  

	 SELECT @LocalBeginIssueDate = @BeginIssueDate, 
            @LocalEndIssueDate   = @EndIssueDate 

    -----  For Logging Only -------------------------------------  
    SET @Iata = @IataNum 
    SET @ProcName = CONVERT(VARCHAR(50), Object_name(@@PROCID)) 
    --------------------------------------------------------------    
    -----  For sp PROMPTSONLY ----------  
    --SET @IataNum= @IataNum 

---**********************************************************************************************
---START OF ANCILLARY FEE UPDATES
--***********************************************************************************************
UPDATE CCTKT 
SET    CCTKT.ValCarrierCode = CASE 
								WHEN CCTKT.CarrierStr LIKE '%CA%' AND CCTKT.ValCarrierCode = 'A' THEN 'CA'
								WHEN CCTKT.CarrierStr LIKE '%VX%' AND CCTKT.ValCarrierCode = 'X' THEN 'VX' 
								WHEN CCTKT.CarrierStr LIKE '%QF%' AND CCTKT.ValCarrierCode = 'F' THEN 'QF'
								WHEN CCTKT.CarrierStr LIKE '%BV%' AND CCTKT.ValCarrierCode = 'V' THEN 'BV'
								WHEN CCTKT.CarrierStr LIKE '%41%' AND CCTKT.ValCarrierCode = '41' THEN 'QF'
								WHEN CCTKT.CarrierStr LIKE '%LH%' AND CCTKT.ValCarrierCode = 'H' THEN 'LH'
								WHEN CCTKT.CarrierStr LIKE '%CO%' AND CCTKT.ValCarrierCode = 'O' THEN 'CO'
								WHEN CCTKT.ValCarrierCode IS NULL OR CCTKT.ValCarrierCode= 'N' THEN 'XX'
								ELSE CCTKT.ValCarrierCode
								END 
FROM   dba.CCTicket CCTKT, 
       dba.CCHeader CCHDR 
WHERE  1 = 1 
       AND CCHDR.RecordKey = CCTKT.RecordKey 
       AND CCHDR.IataNum = CCTKT.IataNum 
       AND CCHDR.ImportDate >= Getdate() - 7 

   EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCTKT ValCarrierCode', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR
----------------------------------------------------------------------------------------------------------------------
UPDATE CCTKT 
SET    CCTKT.ValCarrierCode = CASE 
                           WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%AIRASIA%' or CCHDR.CompanyName LIKE '%AIRASIA%') THEN'AK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%ASIANA%' or CCHDR.CompanyName LIKE '%ASIANA%') THEN 'OZ'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%AUSTRIAN%' or CCHDR.CompanyName LIKE '%AUSTRIAN%') THEN 'OS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%AVIANCA%' or CCHDR.CompanyName LIKE '%AVIANCA%') THEN 'AV'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%BRITISH AIR%' or CCHDR.CompanyName LIKE '%BRITISH AIR%') THEN 'BA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%BULGARIA AI%' or CCHDR.CompanyName LIKE '%BULGARIA AI%') THEN 'FB'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%CATHAY PA%' or CCHDR.CompanyName LIKE '%CATHAY PA%') THEN 'CX'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%CONDOR FLU%' or CCHDR.CompanyName LIKE '%CONDOR FLU%') THEN 'DE'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%EASYJET%' or CCHDR.CompanyName LIKE '%EASYJET%') THEN 'U2'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%EGYPTAIR%' or CCHDR.CompanyName LIKE '%EGYPTAIR%') THEN 'MS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%EUROWINGS%' or CCHDR.CompanyName LIKE '%EUROWINGS%') THEN 'EW'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%JET AIRW%' or CCHDR.CompanyName LIKE '%JET AIRW%') THEN '9W'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%GERMANWINGS%' or CCHDR.CompanyName LIKE '%GERMANWINGS%') THEN '4U'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%FLYBE%' or CCHDR.CompanyName LIKE '%FLYBE%') THEN 'BE'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%KOREA%' or CCHDR.CompanyName LIKE '%KOREA%') THEN 'KE'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%JET2%' or CCHDR.CompanyName LIKE '%JET2%') THEN 'LS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%COPA%' or CCHDR.CompanyName LIKE '%COPA%') THEN 'CM'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%JETSTAR%' or CCHDR.CompanyName LIKE '%JETSTAR%') THEN 'JQ'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%WEST JET%' or CCHDR.CompanyName LIKE '%WEST JET%') THEN 'WS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%WESTJET%' or CCHDR.CompanyName LIKE '%WESTJET%') THEN 'WS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%VIRGIN%' AND CCTKT.ValCarrierNum = 856 THEN 'DJ'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%VARIG%' or CCHDR.CompanyName LIKE '%VARIG%') THEN 'RG'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%AIGL%' AND CCTKT.ValCarrierNum = 439 THEN 'ZI'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%BABOO%' AND CCTKT.ValCarrierNum = 33 THEN 'F7'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%QANTAS%' THEN 'QF'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%S A S%' OR CCHDR.ChargeDesc LIKE '%SAS%') THEN  'SK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%SINGAPORE%' THEN 'SQ'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%MALAYSIA%' THEN 'MH'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%SUN COUNT%' THEN 'SY'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%AIR BERLI%' THEN 'AB'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%AIR CHINA%' THEN 'CA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%British AirWays%' THEN 'BA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'American Airlin%' or CCHDR.CompanyName LIKE 'American airlin%')THEN 'AA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'Delta Air%' or CCHDR.CompanyName LIKE 'Delta%') THEN 'DL'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'japan airlin%' THEN 'JL'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'scANDinavian%' THEN 'SK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'etihad%' THEN 'EY'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'US airway%'  OR CCHDR.CompanyName LIKE 'US Airway%')THEN 'US'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'Virgin America%' or CCHDR.CompanyName LIKE 'Virgin America%')THEN 'VX'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Admirals%' THEN 'AA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AA Inflight%' THEN 'AA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AADVANTAGE ELITE%' THEN 'AA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'SURF AIR%' THEN 'XX'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'UNITED%' or CCHDR.CompanyName LIKE 'United%')THEN 'UA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'SPIRIT%' or CCHDR.CompanyName LIKE 'Spirit%')THEN 'NK'
								WHEN CCTKT.ValCarrierCode= '0' AND (CCHDR.ChargeDesc LIKE 'SPIRIT%' or CCHDR.CompanyName LIKE 'Spirit%')THEN 'NK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'AIRTRAN%' or CCHDR.CompanyName LIKE 'AirTran%' )THEN 'FL'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'JETBLUE%' or CCHDR.CompanyName LIKE 'JetBlue%')THEN 'B6'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Alaska air%' THEN 'AS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%AIR Canada%' or CCHDR.CompanyName LIKE '%Air Canada%') THEN'AC'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'Porter%' or CCHDR.CompanyName LIKE 'Porter A%') THEN 'PD'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE '%Southwest%' or CCHDR.CompanyName LIKE '%Southwest%') THEN'WN'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Aeromexico%' THEN 'AM'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Gol Tran%' THEN 'G3'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'TAM%' THEN 'PZ'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Air Inuit%' THEN '3H'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'RyanAir%' Or CCHDR.CompanyName LIKE 'Ryanair%') THEN 'FR'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Swiss Int%' THEN 'LX'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'KLM%' THEN 'KL'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'Spice%' THEN 'SG'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'Frontier%' or CCHDR.CompanyName LIKE 'Frontier%') THEN 'F9'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'InterJet%' THEN '4O'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'CONCESIONARIA%' or CCHDR.CompanyName LIKE 'Volaris%') THEN 'Y4'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'KLM UK%' or CCHDR.CompanyName LIKE 'KLM UK%') THEN 'UK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'CARIBBEAN AIR%' THEN 'B8'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'NORWEGIAN%' THEN 'DY'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%LUFTHA%' THEN 'LH'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'HONG KONG AIR%' THEN 'HX'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%DRAGON%' THEN 'KA'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AIR INDIA%' THEN 'AI'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'CARIBBEAN AIR%' THEN 'B8'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'ALL NIPPON%' OR CCHDR.ChargeDesc LIKE 'ANA%')THEN 'NH'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'CHINA AIR%' THEN 'CI'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'PHILIPPINE AIR%' THEN 'PR'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'THAI AIR%' THEN 'TG'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'VIRGIN ATL%' THEN 'VS'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'EVA AIR%' THEN 'BR'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'CARIBBEAN AIR%' THEN 'B8'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'CHINA EASTER%' THEN 'MU'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'QATAR%' THEN 'QR'  
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'AIR NEW ZEALAND%' OR CCHDR.ChargeDesc LIKE 'AIR NZ%')THEN 'NZ'		 
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE '%POLISH Air%' THEN 'LO' 	
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'VIETNAM%' THEN 'VN' 
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'ALITALIA%' THEN 'AZ' 	
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND (CCHDR.ChargeDesc LIKE 'AIR FRANCE%' OR CCTKT.TICKETISSUER LIKE 'AIR FRANCE%')THEN 'AF'		  
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'FINNAIR%' THEN 'AY'  
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'TURKISH AIR%' THEN 'TK' 
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AIR China%' THEN 'CA'  
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCTKT.TICKETISSUER LIKE 'LAN AIR%' THEN 'LA'	
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AIRLINK%' THEN 'ND'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AEROLINEAS%' THEN 'AR'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'GREAT LAKE%' THEN 'ZK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AER LINGUS%' THEN 'EI'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'EMIRATES%' THEN 'EK'
								WHEN ISNULL(CCTKT.ValCarrierCode, 'XX') = 'XX' AND CCHDR.ChargeDesc LIKE 'AZUL%' THEN 'AD'
								ELSE CCTKT.ValCarrierCode 
								END 
FROM   dba.CCTicket CCTKT, 
       dba.CCHeader CCHDR 
WHERE  1 = 1 
       AND CCHDR.RecordKey = CCTKT.RecordKey 
       AND CCHDR.IataNum = CCTKT.IataNum 
       AND CCTKT.ValCarrierCode = 'XX' 
       AND CCHDR.ImportDate >= Getdate() - 7 

	  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCTKT ValCarrierCode', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
---------------------------------------------------------------------------------------------------------------------
UPDATE CCTKT 
SET    CCTKT.AncillaryFeeInd = CASE 
                                 WHEN CCTKT.TicketIssuer LIKE '%BAGGAGE FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 1  
                                 WHEN CCTKT.TicketIssuer LIKE '%1ST BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 1
							     WHEN CCTKT.TicketIssuer LIKE '%2ND BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.TicketIssuer LIKE '%3RD BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 3 
                                 WHEN CCTKT.TicketIssuer LIKE '%4TH BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 4 
                                 WHEN CCTKT.TicketIssuer LIKE '%5TH BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 5 
                                 WHEN CCTKT.TicketIssuer LIKE '%6TH BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 6 
                                 WHEN CCTKT.TicketIssuer LIKE '%EXCS BAG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA AWRD ACCEL%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA ECNMY PLUS%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA PREM CABIN%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA PREM LINE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA MPI UPGRD%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%SKYMILES FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%OVERWEIGHT%' AND CCTKT.AncillaryFeeInd IS NULL THEN 8 
                                 WHEN CCTKT.TicketIssuer LIKE '%OVERSIZE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 9 
                                 WHEN CCTKT.TicketIssuer LIKE '%SPORT EQUIP%' AND CCTKT.AncillaryFeeInd IS NULL THEN 10
								 WHEN CCTKT.IssuerCity LIKE 'SKYMILES FEE' AND CCTKT.AncillaryFeeInd IS NULL THEN 15 
                                 WHEN CCTKT.TicketIssuer LIKE '%-INFLT%' AND CCTKT.AncillaryFeeInd IS NULL THEN 16 
								 WHEN CCTKT.TicketIssuer LIKE '%*INFLT%' AND CCTKT.AncillaryFeeInd IS NULL THEN 16 
                                 WHEN CCTKT.TicketIssuer LIKE '%EASY CHECK IN%' AND CCTKT.AncillaryFeeInd IS NULL THEN 17 
								 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  UNITED.COM AWARD%' AND CCTKT.AncillaryFeeInd IS NULL THEN 18 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  UNITED CONNECTIO%' AND CCTKT.AncillaryFeeInd IS NULL THEN 19 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  WIPRO BPO PHILIP%' AND CCTKT.AncillaryFeeInd IS NULL THEN 20 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  WIPRO SPECTRAMIN%' AND CCTKT.AncillaryFeeInd IS NULL THEN 20 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  UNITED.COM CUSTO%' AND CCTKT.AncillaryFeeInd IS NULL THEN 21 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  TICKET SVC CENTE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 21 
                                 WHEN CCTKT.TicketIssuer LIKE '%MPI BOOK FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.TicketIssuer LIKE '%RES BOOK FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA TKTG FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA UNCONF CHG%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED-  UNITED.COM%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.TicketIssuer LIKE '%CONFIRM CHG$%' AND CCTKT.AncillaryFeeInd IS NULL THEN 31 
                                 WHEN CCTKT.TicketIssuer LIKE '%CNCL/PNLTY%' AND CCTKT.AncillaryFeeInd IS NULL THEN 32 
                                 WHEN CCTKT.TicketIssuer LIKE '%MUA CO PAY TI%' AND CCTKT.AncillaryFeeInd IS NULL THEN 50 
                                 WHEN CCTKT.TicketIssuer LIKE '%UA MISC FEE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 50 
                                 WHEN CCTKT.TicketIssuer LIKE '%UNITED.COM-SWIT%' AND CCTKT.AncillaryFeeInd IS NULL THEN 50 
                                 WHEN CCTKT.TicketIssuer = 'KLM LOUNGE ACCESS' AND CCTKT.AncillaryFeeInd IS NULL THEN 60 
								 WHEN CCTKT.PassengerName LIKE '%1ST BAG%' AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                                 WHEN CCTKT.PassengerName LIKE '%/FIRST CHE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                           		 WHEN CCTKT.PassengerName LIKE '%/SECOND CH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.PassengerName LIKE '%/THIRD CH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 3 
                                 WHEN CCTKT.PassengerName LIKE '%/FOURTH CH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 4 
                                 WHEN CCTKT.PassengerName LIKE '%/FIFTH CH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 5 
                                 WHEN CCTKT.PassengerName LIKE '%/SIXTH CH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 6
								 WHEN CCTKT.PassengerName LIKE '%EXCESS%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7  
                                 WHEN CCTKT.PassengerName LIKE '%EXCESS BA%' AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.PassengerName LIKE '%/OVERWEIGH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 8 
                                 WHEN CCTKT.PassengerName LIKE '%/OVERSIZED%' AND CCTKT.AncillaryFeeInd IS NULL THEN 9 
                                 WHEN CCTKT.PassengerName LIKE '%SPORT EQU%' AND CCTKT.AncillaryFeeInd IS NULL THEN 10 
                                 WHEN CCTKT.PassengerName LIKE '%/SPORTING%' AND CCTKT.AncillaryFeeInd IS NULL THEN 10 
                                 WHEN CCTKT.PassengerName LIKE '%/EXTRA LEG%' AND CCTKT.AncillaryFeeInd IS NULL THEN 12 
								 WHEN CCTKT.PassengerName LIKE '%bulkhead%' AND CCTKT.AncillaryFeeInd IS NULL THEN 12 
                                 WHEN CCTKT.PassengerName LIKE '%/FIRST CLA%' AND CCTKT.AncillaryFeeInd IS NULL THEN 13 
                                 WHEN CCTKT.PassengerName LIKE '%/ONEPASS R%' AND CCTKT.AncillaryFeeInd IS NULL THEN 15 
                                 WHEN CCTKT.PassengerName LIKE '%/REWARD BO%' AND CCTKT.AncillaryFeeInd IS NULL THEN 15 
                                 WHEN CCTKT.PassengerName LIKE '%/REWARD CH%' AND CCTKT.AncillaryFeeInd IS NULL THEN 15 
                                 WHEN CCTKT.PassengerName LIKE '%/INFLIGHT%' AND CCTKT.AncillaryFeeInd IS NULL THEN 16 
                                 WHEN CCTKT.PassengerName LIKE '%/LIQUOR%' AND CCTKT.AncillaryFeeInd IS NULL THEN 16 
                                 WHEN CCTKT.PassengerName LIKE '%/SPECIAL S%' AND CCTKT.AncillaryFeeInd IS NULL THEN 21 
                                 WHEN CCTKT.PassengerName LIKE '%/RESERVATI%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.PassengerName LIKE '%/TICKETING%' AND CCTKT.AncillaryFeeInd IS NULL THEN 30 
                                 WHEN CCTKT.PassengerName LIKE '%/CHANGE FE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 31 
                                 WHEN CCTKT.PassengerName LIKE '%/PAST DATE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 31 
                                 WHEN CCTKT.PassengerName LIKE '%/CHANGE PE%' AND CCTKT.AncillaryFeeInd IS NULL THEN 32 
                                 WHEN CCTKT.PassengerName LIKE '%/P-CLUB DA%' AND CCTKT.AncillaryFeeInd IS NULL THEN 60 
                                 WHEN CCTKT.PassengerName LIKE '%P-CLUB%' AND CCTKT.AncillaryFeeInd IS NULL THEN 60 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XAE%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 1 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XUP%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 15 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XDF%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 16 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XTD%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 21 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XPC%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 25 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XOT%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 30 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XAO%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 30 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XPE%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 31 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XCA%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 50 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XAA%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 50 
                                 WHEN CCTKT.Routing LIKE 'XAA%' AND CCTKT.Routing LIKE '%XAF%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 60 
                                 WHEN CCTKT.ValCarrierCode = 'CO' AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('29', '26') AND CCTKT.TicketAmt IN (23, 25) AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN (25) AND SUBSTRING(CCTKT.TicketNum, 1, 3) IN ('025','026', '027', '028') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN (25) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('26') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (23, 25, 32, 35, 27, 30, 50, 55) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('25','29', '82') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'UA' AND CCTKT.TicketAmt IN (25) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('40','46', '45') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'US' AND CCTKT.TicketAmt IN (23, 25) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('24') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'BA' AND (( CCTKT.TicketAmt IN (40, 50, 48, 60) AND CCTKT.BilledCurrCode = 'USD' AND CCTKT.MatchedRecordKey IS NULL OR CCTKT.TicketAmt IN (28, 35, 32, 40) AND CCTKT.BilledCurrCode = 'GBP' )) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('26','90') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'AS' AND CCTKT.TicketAmt IN (20) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('21','16') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 1 
                                 WHEN CCTKT.ValCarrierCode = 'CO' AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('29','26') AND CCTKT.TicketAmt IN (27, 30, 32, 35, 45, 50, 9, 10) AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN (35, 30, 50, 60) AND SUBSTRING(CCTKT.TicketNum, 1, 3) IN ('025', '026', '027', '028') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN ( 35, 30, 50, 60 ) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('26') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (32, 35, 27, 30, 50, 55) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('25', '29', '82') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'UA' AND CCTKT.TicketAmt IN (35, 50) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('40','46', '45') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'US' AND CCTKT.TicketAmt IN (35, 50) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('24') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'LH' AND CCTKT.TicketAmt IN (50) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('16','26', '27') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 2 
                                 WHEN CCTKT.ValCarrierCode = 'AF' AND CCTKT.TicketAmt IN (55, 100) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('82', '16') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 2 
								 WHEN CCTKT.ValCarrierCode = 'AS' AND CCTKT.TicketAmt IN (50) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('21','16') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 4 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN (100) AND SUBSTRING(CCTKT.TicketNum, 1, 3) IN ('025', '026', '027', '028') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN (100) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('26') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'WN' AND CCTKT.TicketAmt IN (50, 110) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('26') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'LH' AND CCTKT.TicketAmt IN (150) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('16', '26', '27') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'BA' AND ((CCTKT.TicketAmt IN (112, 140) AND CCTKT.BilledCurrCode = 'USD' AND CCTKT.MatchedRecordKey IS NULL OR CCTKT.TicketAmt IN (72, 90) AND CCTKT.BilledCurrCode = 'GBP')) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('26', '90') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'SQ' AND CCTKT.TicketAmt IN (8, 12, 22, 50, 15, 30, 55, 40, 60, 50, 109, 150, 84, 110, 121, 117, 160, 94, 115, 130, 129, 149, 165, 128) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('16', '18') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'AF' AND CCTKT.TicketAmt IN (200) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('82', '16') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'AC' AND CCTKT.TicketAmt IN (30, 50, 75, 100, 225) AND SUBSTRING(CCTKT.TicketNum, 1, 2) IN ('20', '51') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.ValCarrierCode = 'LX' AND CCTKT.TicketAmt IN (250, 150, 50, 120, 450) AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer IN ('AIR NEW ZEALAND EXCESS BAG WL7', 'AIR NEW ZEALAND EXCESS BAG CH8', 'MAS EXCESS BAGGAGE - DOME', 'VIRGIN ATLANTIC CC ANCILLARIES', 'AIR NEW ZEALAND EXCESS BAG AK7') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%extra baggage%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 2
								 WHEN CCTKT.TicketIssuer LIKE '%excess bag%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN CCTKT.TicketIssuer LIKE '%VIRGIN ATLANTIC XX ANCILLARIES%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
								 WHEN CCTKT.PassengerName LIKE '%/FIRST CHE%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 1 
                                 WHEN ((CCTKT.PassengerName LIKE '%/1ST BAG -%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 1 
								 WHEN CCTKT.PassengerName LIKE '%/SECOND%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 2 
                                 WHEN CCTKT.PassengerName LIKE '%/EXCESS%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 7 
                                 WHEN ((CCM.MerchantName1 LIKE '%DELTA AIR CARGO%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN ((CCM.MerchantName2 LIKE '%AIR CARGO%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN ((CCHDR.ChargeDesc LIKE '%EX BAG%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
                                 WHEN CCTKT.PassengerName LIKE '%/OVERWEIGH%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 8 
                                 WHEN ((CCTKT.PassengerName LIKE '%/OWH - HEA%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 8 
                                 WHEN ((CCTKT.PassengerName LIKE '%/GARMENT B%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 9 
                                 WHEN ((CCTKT.PassengerName LIKE '%/DUFFEL BA%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 10 
                                 WHEN CCTKT.PassengerName LIKE '%/SPECIAL%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 11 
                                 WHEN ((CCTKT.PassengerName LIKE '%/ECONOMY P%'OR CCTKT.PassengerName LIKE '%/BULKHEAD%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 12 
                                 WHEN CCTKT.PassengerName LIKE '%/FIRST CLA%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 13 
                                 WHEN CCTKT.PassengerName LIKE '%/EXT ST%' OR CCTKT.PassengerName LIKE '%/EXTRA SEAT%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 14 
                                 WHEN CCTKT.PassengerName LIKE '%ONEPASS%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 15 
                                 WHEN ((CCM.MerchantName1 LIKE '%AMEX LIFEMILES%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 15 
                                 WHEN ((CCTKT.PassengerName LIKE '%/MILEAGE P%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 15 
                                 WHEN CCTKT.ValCarrierCode = 'AA' AND CCTKT.TicketAmt IN (3.29, 5.29, 6, 4.49, 8.29, 10, 7) AND CCTKT.AncillaryFeeInd IS NULL THEN 16 
								 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (40, 50)  AND ((CCTKT.TicketNum LIKE '014%' OR CCTKT.TicketNum LIKE '015%' OR CCTKT.TicketNum LIKE '016%')) AND CCTKT.MatchedRecordKey IS NULL  AND CCTKT.AncillaryFeeInd IS NULL THEN 7 
								 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (59) AND ((CCTKT.TicketNum LIKE '014%' OR CCTKT.TicketNum LIKE '015%' OR CCTKT.TicketNum LIKE '016%')) AND CCTKT.MatchedRecordKey AND CCTKT.AncillaryFeeInd IS NULL THEN 12 
                                 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (7) AND ((CCTKT.TicketNum LIKE '014%' OR CCTKT.TicketNum LIKE '015%' OR CCTKT.TicketNum LIKE '016%'))  AND CCTKT.AncillaryFeeInd IS NULL THEN 20  
								 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (9) AND ((CCTKT.TicketNum LIKE '014%' OR CCTKT.TicketNum LIKE '015%' OR CCTKT.TicketNum LIKE '016%'))  AND CCTKT.IssuerCity = 'delta.com' AND CCTKT.AncillaryFeeInd IS NULL THEN 17 
								 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN (9) AND ((CCTKT.TicketNum LIKE '014%' OR CCTKT.TicketNum LIKE '015%' OR CCTKT.TicketNum LIKE '016%'))  AND (CCTKT.IssuerCity <> 'delta.com' OR CCTKT.IssuerCity IS NULL) AND CCTKT.AncillaryFeeInd IS NULL THEN 12 
								 WHEN CCTKT.ValCarrierCode = 'DL' AND CCTKT.TicketAmt IN ( 19, 9.5, 14.5, 29, 29.5, 39, 39.5, 49, 79 )  AND ((CCTKT.TicketNum LIKE '014%' OR CCTKT.TicketNum LIKE '015%' OR CCTKT.TicketNum LIKE '016%'))  AND CCTKT.MatchedRecordKey IS NULL  AND CCTKT.AncillaryFeeInd IS NULL THEN 12 
								 WHEN CCHDR.ChargeDesc LIKE '%inflight%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 16 
                                 WHEN CCTKT.TicketIssuer IN ('JETBLUE BUY ON BOARD', 'AMTRAK ONBOARD/ BOS 0049', 'ALASKA AIRLINES IN FLIGHT', 'FRONTIER ON BOARD SALES', 'AMTRAK ONBOARD/ PDX  WASHINGTON', 'AMTRAK ONBOARD/ PHL  WASHINGTON', 'KOREAN AIR DUTY-FREE (  )', 'WESTJET-BUY ON BOARD', 'ONBOARD SALES', 'AMTRAK ONBOARD/ SAC  WASHINGTON', 'EVA AIRWAYS IN FLIGHT DUTY FEE', 'AMTRAK ONBOARD/ NYP  WASHINGTON', 'EL AL DUTY FREE', 'SOUTHWEST ON BOARD', 'AMTRAK ONBOARD/ HAR  WASHINGTON', 'AMTRAK ONBOARD/ RVR  WASHINGTON', 'AMTRAK ONBOARD/ WAS  WASHINGTON', 'AMTRAK ONBOARD/ OAK  WASHINGTON', 'KOREAN AIR DUTY-FREE ($)') AND CCTKT.MatchedRecordKey  IS NULL AND CCTKT.AncillaryFeeInd  IS NULL THEN 16
								 WHEN CCTKT.TicketIssuer LIKE '%IN FLIGHT%' OR CCTKT.TicketIssuer LIKE '%INFLIGHT%' OR CCTKT.TicketIssuer LIKE '%ONBOARD%' OR CCTKT.TicketIssuer LIKE '%ON BOARD%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 16
								 WHEN CCTKT.TicketIssuer LIKE '%DUTY FREE%' OR CCTKT.TicketIssuer LIKE '%DUTY-FREE%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 16
								 WHEN CCTKT.TicketIssuer LIKE '%KLM OPTIONAL SERVICES%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 16
								 WHEN CCTKT.PassengerName LIKE '%/HEADSET%' OR CCTKT.PassengerName LIKE '%/INFLIGHT%' OR CCTKT.PassengerName LIKE '%/LIQUOR%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 16
								 WHEN ((CCM.MerchantName1 LIKE '%FRONTIER ON BOARD SALES%' or CCM.MerchantName1 LIKE '%HORIZON AIR INFLIGHT%' OR CCM.MerchantName1 LIKE '%IN FLIGHT SALES%' OR CCM.MerchantName1 LIKE '%IN-FLIGHT PRCHASE JETBLUE%' OR CCM.MerchantName1 LIKE '%ONBOARD SALES%'   OR CCM.MerchantName1 LIKE '%SOUTHWEST ON BOARD%' OR CCM.MerchantName1 LIKE '%UNITED AIRLINES ONBOARD%' OR CCM.MerchantName1 LIKE '%US AIRWAYS COMPANY STORE%' OR CCM.MerchantName1 LIKE '%INFLIGHT ENTERTAINMENT%' or CCM.MerchantName1 LIKE '%SNCB/NMBS ON-BOARD%' OR CCM.MerchantName1 LIKE '%SNACK BAR T2%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 16
								 WHEN ((CCM.MerchantName2 LIKE '%ONBOARD%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 16
								 WHEN ((CCM.MerchantName2 LIKE '%ON BOARD%' OR CCM.MerchantName2 LIKE '%MOVIE SALES%' OR CCM.MerchantName2 LIKE '%VIRGIN AMERICA ON BO%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 16
								 WHEN ((CCTKT.PassengerName LIKE '%/FOOD S-UA%' OR CCTKT.PassengerName LIKE '%/CO INFLIG%' OR CCTKT.PassengerName LIKE '%/INCABIN P%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 16
								 WHEN CCTKT.ValCarrierCode = 'WN' AND CCTKT.TicketAmt IN (10) AND SUBSTRING(CCTKT.TicketNum,1,2) IN ('06') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 17
								 WHEN CCTKT.PassengerName LIKE '%/EXTRA LEG%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 18
								 WHEN CCTKT.PassengerName = 'MISC' OR CCTKT.PassengerName = 'MISceLLaNeOUS' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 19
								 WHEN CCTKT.TicketIssuer IN ('AIR DO INTERNET', 'SOUTHWEST ONBOARD INTERNT', 'AIR FRANCE USA INTERNET') and CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 20
								 WHEN CCTKT.PassengerName LIKE '%/FARELOCK%' OR CCTKT.PassengerName LIKE '%/FEE' OR CCTKT.PassengerName LIKE '%/REFUND%' OR CCTKT.PassengerName LIKE '%FEE.%' OR CCTKT.PassengerName LIKE '%KIOSK.%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 30
								 WHEN ((CCHDR.ChargeDesc LIKE '%REGIONAL EXPRESS CREDIT CARD SURCHARGE%')) AND CCTKT.AncillaryFeeInd is null THEN 30
								 WHEN CCTKT.PassengerName LIKE '%/CHANGE PR%' OR CCTKT.PassengerName LIKE '%/SAME DAY%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 31
								 WHEN ((CCM.MerchantName1 LIKE '%AIRPORT KIOSKS%' )) AND CCTKT.AncillaryFeeInd IS NULL THEN 50
								 WHEN ((CCTKT.PassengerName LIKE '%/AU TRAVEL%' OR CCTKT.PassengerName LIKE '%/CTO TRANS%' OR CCTKT.PassengerName LIKE '%/UNACCOMPA%' OR CCTKT.PassengerName LIKE '%/OTHER%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 50
								 WHEN CCTKT.TicketIssuer IN ('ADMIRAL CLUB', 'US AIRWAYS CLUB', 'CONTINENTAL PRESIDENT CLU', 'UNITED RED CARPET CLUB', 'THE LOUNGE VIRGIN BLUE') AND CCTKT.MatchedRecordKey IS NULL AND CCTKT.AncillaryFeeInd IS NULL THEN 60
								 WHEN (CCTKT.TicketIssuer LIKE '%ADMIRALS CLUB%' OR CCTKT.TicketIssuer LIKE '%PRESIDENT CLU%' OR CCTKT.TicketIssuer LIKE '%CARPET CLUB%' OR CCTKT.TicketIssuer LIKE '%ADMIRAL CLUB%' OR CCTKT.TicketIssuer LIKE '%THE LOUNGE VIRGIN%' OR CCTKT.TicketIssuer LIKE '%US AIRWAYS CLUB%' OR CCTKT.TicketIssuer LIKE '%VIP LOUNGE%') AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 60
								 WHEN CCTKT.PassengerName LIKE '%P-CLUB%' AND CCTKT.AncillaryFeeInd IS NULL AND CCTKT.MatchedRecordKey IS NULL THEN 60
								 WHEN ((CCM.MerchantName1 LIKE '%admirals club%' OR CCM.MerchantName1 LIKE '%admiral club%' OR CCM.MerchantName1 LIKE '%CONTINENTAL PRESIDENT%'  OR CCM.MerchantName1 LIKE '%RED CARPET CLUB%'  OR CCM.MerchantName1 LIKE '%AIRWAYS CLUB%'  OR CCM.MerchantName1 LIKE '%club spirit%')) AND CCTKT.AncillaryFeeInd IS NULL THEN 60
								 END 
FROM   dba.CCTicket CCTKT 
       INNER JOIN dba.CCHeader CCHDR 
               ON ( CCTKT.RecordKey = CCHDR.RecordKey 
                    AND CCTKT.IataNum = CCHDR.IataNum ) 
       LEFT OUTER JOIN dba.ccmerchant ccm 
                    ON ( CCTKT.merchantid = CCM.merchantid ) 
WHERE  1 = 1 
       AND CCTKT.AncillaryFeeInd IS NULL 
       AND CCHDR.ImportDate >= Getdate() - 7 

	  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCTKT AncillaryFeeInd', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
------------------------------------------------------------------------------------------------
UPDATE CCEXP 
SET    CCEXP.AncillaryFeeInd = CASE 
                                WHEN CCEXP.MCHRGDESC1 LIKE '%GATWICK S BAGGAGE%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%GOVTRIPTAV 0QYBAG%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R2BAG%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R6BAG%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R7BAG%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%LHR T3- BAGGAGE%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%LHR T4 BAGGAGE%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%%T1  BAGGAGE RECLAIM%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%%T3- BAGGAGE BELT%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%T%BAGGAGE RECLAIM%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (1)%' AND CCEXP.AncillaryFeeInd IS NULL THEN 1
								WHEN CCEXP.MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (2)%' AND CCEXP.AncillaryFeeInd IS NULL THEN 2
								WHEN CCEXP.MCHRGDESC1 LIKE '%EXCESS BAGGAGE CO%' AND CCEXP.AncillaryFeeInd IS NULL THEN 7
								WHEN CCEXP.MCHRGDESC1 LIKE '%KLM OVERBAGAGEKAS%' AND CCEXP.AncillaryFeeInd IS NULL THEN 8
								WHEN CCM.MerchantName1 IN ('DELTAMILES BY POINTS') and CCEXP.AncillaryFeeInd IS NULL THEN 15
								WHEN CCEXP.MCHRGDESC1 LIKE '%inflight%' AND CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCEXP.MCHRGDESC1 LIKE '%ALASKA AIR IN FLIGHT%' AND CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCEXP.MCHRGDESC1 LIKE '%FLY DUBAI-INFLIGHT%' AND CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCEXP.MCHRGDESC1 LIKE '%IN FLIGHT US AIRWAYS%' AND CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCEXP.MCHRGDESC1 LIKE '%INFLIGHT FOOD PURCHASE%' AND CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCM.MerchantName1 IN ('AMTRAK - CAP CORR CAFE', 'AMTRAK - SURFLINER CAFE','AMTRAK CASCADES CAFE','AMTRAK FOOD & BEVERAGE','AMTRAK-CAFE','AMTRAK-DINING CAR','AMTRAK-EAST CAFE','AMTRAK-MIDWEST CAFE','AMTRAK-NORTHEAST CAFE','AMTRAK-SAN JOAQUINS CAFE')and CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCM.MerchantName1 IN ('DFASS CANADA COMPANY') and CCEXP.mchrgdesc1 LIKE '%air canada on board%' and CCEXP.AncillaryFeeInd IS NULL THEN 16 
								WHEN CCM.MerchantName1 IN ('ALPHA FLIGHT SERVICES') and CCEXP.AncillaryFeeInd IS NULL THEN 16 
								WHEN CCM.MerchantName1 IN ('BAA ADVANCE') and CCEXP.AncillaryFeeInd IS NULL THEN 17
								WHEN CCHDR.ChargeDesc LIKE '%inflight%' and cchdr.recordkey = CCEXP.recordkey and CCEXP.AncillaryFeeInd IS NULL THEN 16
								WHEN CCEXP.MCHRGDESC1 LIKE '%GOGOAIR%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%GOGO DAY PAS%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%AIRCELL GOGO INFLIGHT%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%AIRCELL*GOGO INFLIGHT%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%INFLIGHT US AIRWAYSQPS%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%SWA INFLIGHT WIFI%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%TRLPAY  GOGO INFLIGHT%' AND CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN ((CCM.MerchantName1 LIKE '%AIPORTWIRELESS%' OR CCM.MerchantName1 LIKE '%AIRPORT WIRELESS%'OR CCM.MerchantName1 like '%BOINGO%' OR CCM.MerchantName1 like 'VIASAT'))and CCEXP.AncillaryFeeInd IS NULL THEN 20
								WHEN CCM.MerchantName1 IN ('AIRCELL-ABS') and CCEXP.AncillaryFeeInd IS NULL  THEN 20
								WHEN CCEXP.MCHRGDESC1 LIKE '%AIRPORTBAGS.COM%' AND CCEXP.AncillaryFeeInd IS NULL THEN 55
								WHEN CCEXP.MCHRGDESC1 LIKE '%AA ADMIRAL%' AND CCEXP.AncillaryFeeInd IS NULL THEN 60
								WHEN CCEXP.MCHRGDESC1 LIKE '%AA ADMRL%' AND CCEXP.AncillaryFeeInd IS NULL THEN 60
								WHEN CCEXP.MCHRGDESC1 LIKE '%ADMIRALS CLUB%' AND CCEXP.AncillaryFeeInd IS NULL THEN 60
								WHEN CCM.MerchantName1 IN ('AA ADMIRAL CLUB AUS', 'AA ADMIRAL CLUB LAX','AA ADMIRAL CLUB LGA D3','AA ADMIRALS CLUB MIAMI D','AIR CANADA CLUB','AMERICAN EXPRESS PLATINUM LOUNGE') AND CCEXP.AncillaryFeeInd IS NULL THEN 60
								WHEN CCEXP.MCHRGDESC1 LIKE '%INFLIGHT MEDICAL%' AND CCEXP.AncillaryFeeInd IS NULL THEN 70
								END 
FROM   dba.CCEXPense CCEXP 
       INNER JOIN dba.CCHeader CCHDR 
               ON ( CCEXP.RecordKey = CCHDR.RecordKey 
                    AND CCEXP.IataNum = CCHDR.IataNum ) 
       LEFT OUTER JOIN dba.ccmerchant ccm 
                    ON ( CCEXP.merchantid = CCM.merchantid ) 
WHERE  1 = 1 
       AND CCEXP.AncillaryFeeInd IS NULL 
       AND CCHDR.ImportDate >= Getdate() - 7 

	  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCEXP AncillaryFeeInd', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
-------------------------------------------------------------------------------------------------------------------
----Update dba.CCHeader 
UPDATE CCHDR 
SET    CCHDR.AncillaryFeeInd = CASE 
								WHEN ((CCHDR.ChargeDesc LIKE '%1ST BAG FEE%' OR CCHDR.ChargeDesc LIKE '%baggage fee%')) AND CCHDR.AncillaryFeeInd is null THEN 1
								WHEN ((CCHDR.ChargeDesc LIKE '%CARGO POR EMISION%')) AND CCHDR.AncillaryFeeInd is null THEN 7 
								WHEN ((CCHDR.ChargeDesc LIKE '%OVERWEIGHT%')) AND cchdr.AncillaryFeeInd is null THEN 8
								WHEN ((CCHDR.ChargeDesc LIKE '%ALASKA AIRLINES SEAT%' OR CCHDR.ChargeDesc LIKE '%ECNMY PLUS%' OR CCHDR.ChargeDesc LIKE '%ECONOMYPLUS%' OR CCHDR.ChargeDesc LIKE '%ECONOMY PLUS%')) AND cchdr.AncillaryFeeInd is null THEN 12 
								WHEN ((CCHDR.ChargeDesc LIKE '%BUY FLYING BLUE MILE%' OR CCHDR.ChargeDesc LIKE '%MILEAGE PLUS%')) AND cchdr.AncillaryFeeInd is null THEN 15
								WHEN ((CCHDR.ChargeDesc LIKE '%ALASKA AIR CO STORE%'  OR CCHDR.ChargeDesc LIKE '%INFLIGHT%' OR CCHDR.ChargeDesc LIKE '%ALASKA AIRLINE ONBOA%' OR CCHDR.ChargeDesc LIKE '%ONBOARD%' OR CCHDR.ChargeDesc LIKE '%IN-FLIGHT%' OR CCHDR.ChargeDesc LIKE '%DUTY FREE%' OR CCHDR.ChargeDesc LIKE '%SOUTHWESTAIR*INFLIGH%' OR CCHDR.ChargeDesc LIKE '%*INFLT%' OR CCHDR.ChargeDesc LIKE '%WESTJET BUY ON BOARD%' OR CCHDR.ChargeDesc LIKE '%PURCHASE ON JETBLUE%')) AND CCHDR.AncillaryFeeInd is null THEN 16
								WHEN ((CCHDR.ChargeDesc LIKE '%ALASKA AIR CO STORE%'  OR CCHDR.ChargeDesc LIKE '%IN FLIGHT%' OR CCHDR.ChargeDesc LIKE '%ALASKA AIRLINE ONBOA%' OR CCHDR.ChargeDesc LIKE '%ONBOARD%' OR CCHDR.ChargeDesc LIKE '%IN-FLIGHT%' OR CCHDR.ChargeDesc LIKE '%DUTY FREE%' OR CCHDR.ChargeDesc LIKE '%SOUTHWESTAIR*INFLIGH%' OR CCHDR.ChargeDesc LIKE '%*INFLT%' OR CCHDR.ChargeDesc LIKE '%WESTJET BUY ON BOARD%' OR CCHDR.ChargeDesc LIKE '%PURCHASE ON JETBLUE%')) AND CCHDR.AncillaryFeeInd is null THEN 16
								WHEN ((CCHDR.ChargeDesc LIKE '%WIFI%')) AND CCHDR.AncillaryFeeInd is null THEN 20
								WHEN ((CCHDR.ChargeDesc LIKE '%RES BOOK FEE%' OR CCHDR.ChargeDesc LIKE '%UNCONF CHG%')) AND cchdr.AncillaryFeeInd is null THEN 30
								WHEN ((CCHDR.ChargeDesc LIKE '%CNCL/PNLTY%')) AND CCHDR.AncillaryFeeInd is null THEN 32
								WHEN ((CCHDR.ChargeDesc LIKE '%OPTIONAL SERVICE%' OR CCHDR.ChargeDesc LIKE '%NON-FLIGHT%' OR CCHDR.ChargeDesc LIKE '%MISC FEE%')) AND CCHDR.AncillaryFeeInd is null THEN 50
								WHEN ((CCHDR.ChargeDesc LIKE '%ADMIRALS CLUB%' OR CCHDR.ChargeDesc LIKE '%SKY TEAM LOUNGE%' OR CCHDR.ChargeDesc LIKE '%REDCARPETCLUB%' OR CCHDR.ChargeDesc LIKE '%US AIRWAYS CLUB%' OR CCHDR.ChargeDesc LIKE '%ALASKA AIR BOARDRM%' OR CCHDR.ChargeDesc LIKE '%-BOARDROOM%')) AND CCHDR.AncillaryFeeInd is null THEN 60 
								END 
FROM   dba.CCHeader CCHDR 
       LEFT OUTER JOIN dba.CCTicket CCTKT 
                    ON ( CCHDR.RecordKey = CCTKT.RecordKey 
                         AND CCHDR.IataNum = CCTKT.IataNum ) 
       LEFT OUTER JOIN dba.CCEXPense CCEXP 
                    ON ( CCHDR.RecordKey = CCEXP.RecordKey 
                         AND CCHDR.IataNum = CCEXP.IataNum ) 
WHERE  1 = 1 
       AND CCHDR.ImportDate >= Getdate() - 7 

	  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCHDR AncillaryFeeInd', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
---------------------------------------------------------------------------------------------
----Update related tables where AncillaryFeeInd is populated in one and not in the other 
----update CCTKT using CCHDR 
UPDATE CCTKT 
SET    CCTKT.AncillaryFeeInd = CCHDR.AncillaryFeeInd 
FROM   dba.CCTicket CCTKT 
       INNER JOIN dba.CCHeader CCHDR 
               ON ( CCTKT.RecordKey = CCHDR.RecordKey 
                    AND CCTKT.IataNum = CCHDR.IataNum ) 
WHERE  CCTKT.AncillaryFeeInd IS NULL 
       AND CCHDR.AncillaryFeeInd IS NOT NULL 
       AND CCHDR.ImportDate >= Getdate() - 7 

	  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCTKT AncillaryFeeInd EQUALS CCHDR.AncillaryFeeInd', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
------------------------------------------------------
----update CCEXP using CCHDR 
UPDATE CCEXP 
SET    CCEXP.AncillaryFeeInd = CCHDR.AncillaryFeeInd 
FROM   dba.CCEXPense CCEXP 
       INNER JOIN dba.CCHeader CCHDR 
               ON ( CCEXP.RecordKey = CCHDR.RecordKey 
                    AND CCEXP.IataNum = CCHDR.IataNum ) 
WHERE  CCEXP.AncillaryFeeInd IS NULL 
       AND CCHDR.AncillaryFeeInd IS NOT NULL 
       AND CCHDR.ImportDate >= Getdate() - 7 

	  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCEXP AncillaryFeeInd', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------------------------------
----update CCHDR using CCTKT  

	UPDATE CCHDR 
	SET    CCHDR.AncillaryFeeInd = CASE 
									 WHEN CCTKT.AncillaryFeeInd IS NOT NULL 
										  AND CCHDR.AncillaryFeeInd IS NULL THEN 
									 CCTKT.AncillaryFeeInd 
									 WHEN CCEXP.AncillaryFeeInd IS NOT NULL 
										  AND CCHDR.AncillaryFeeInd IS NULL THEN 
									 CCEXP.AncillaryFeeInd 
								   END 
	FROM   dba.CCHeader CCHDR 
		   LEFT OUTER JOIN dba.CCTicket CCTKT 
						ON ( CCHDR.RecordKey = CCTKT.RecordKey 
							 AND CCHDR.IataNum = CCTKT.IataNum ) 
		   LEFT OUTER JOIN dba.CCEXPense CCEXP 
						ON ( CCHDR.RecordKey = CCEXP.RecordKey 
							 AND CCHDR.IataNum = CCEXP.IataNum ) 
	WHERE  1 = 1 
		   AND CCHDR.AncillaryFeeInd IS NULL 
		   AND ( CCTKT.AncillaryFeeInd IS NOT NULL 
				  OR CCEXP.AncillaryFeeInd IS NOT NULL ) 
		   AND CCHDR.ImportDate >= Getdate() - 7 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UPDATE CCHDR AncillaryFeeInd', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 



---**********************************************************************************************
---END OF ANCILLARY FEE UPDATES
--***********************************************************************************************
    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
