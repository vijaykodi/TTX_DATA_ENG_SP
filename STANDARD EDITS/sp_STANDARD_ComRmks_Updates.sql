CREATE PROCEDURE [dbo].[sp_STANDARD_ComRmks_Updates] (@BeginIssueDate DATETIME, 
                                            @EndIssueDate   DATETIME) 
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
            @LocalEndIssueDate		DATETIME,
			@ProductionServerName	VARCHAR(50),
			@DatabaseName			VARCHAR(50)

	 SELECT @LocalBeginIssueDate = @BeginIssueDate, 
            @LocalEndIssueDate   = @EndIssueDate 

    -----  For Logging Only -------------------------------------  
    SET @Iata = @IataNum 
    SET @ProcName = CONVERT(VARCHAR(50), Object_name(@@PROCID)) 
    --------------------------------------------------------------    
    -----  For sp PROMPTSONLY ----------  
    --SET @IataNum= @IataNum 

    SELECT @MaxImportDt = Max(StagIH.ImportDt) 
    FROM   dba.InvoiceHeader StagIH
    WHERE  StagIH.IataNum= @IataNum

    --  and StagIH.InvoiceDate BETWEEN @LocalBeginIssueDate  and  @LocalEndIssueDate   
    PRINT @MaxImportDt 

    SELECT @FirstInvDate = Min(InvoiceDate), 
           @LastInvDate = Max(InvoiceDate) 
    FROM   dba.InvoiceHeader 
    WHERE  ImportDt = @MaxImportDt 
           AND IataNum= @IataNum

    PRINT @FirstInvDate 

    PRINT @LastInvDate 

	  ----------------------------------------------------------------    
    -- Any and all ediTScan be logged using sp_LogProcErrors   
    -- INSERT a row into the dbo.procedurelogs table using sp....when the procedure starTS 
    -- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
    --  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run  
    --  @LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction  
    --  @StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'UPDATE ComRmks' OR 'INSERT UDef'
    --  @BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure  
    --  @EndDate datetime = NULL, -- **OPTIONAL**  The EndIssueDate that is pased to the Parent Procedure  
    --  @IataNumvarchar(50) = NULL, -- **OPTIONAL** The IataNumthat is passed to the Parent Procedure  
    --  @RowCount int, -- **REQUIRED** Total number of affected rows  
    --  @ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)  
    --Log Activity  

    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Start', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

----------------------------------------------------
 --------  BEGIN DELETE AND INSERT COMRMKS -----
 ------------------------------------------------------


/***********************************************************************************************************************/
--------  Begin DELETE AND INSERT ComRmks -----
----  **Note DO NOT ADD:
----    these JOINS: 
----      AND IH.InvoiceDate = CR.InvoiceDate
----      AND IH.ClientCode = CR.ClientCode
----    or FILTER:
----      AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
----    because  InvoiceDates or ClientCodes  may have changed with newly arrived data
----   ** Only match on Iatanum AND Recordkey to delete
/***********************************************************************************************************************/
 

 ----------------------------------------------------
 --------  BEGIN DELETE AND INSERT COMRMKS -----
 ------------------------------------------------------


/***********************************************************************************************************************/
--------  Begin DELETE AND INSERT ComRmks -----
----  **Note DO NOT ADD:
----    these JOINS: 
----      AND IH.InvoiceDate = CR.InvoiceDate
----      AND IH.ClientCode = CR.ClientCode
----    or FILTER:
----      AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
----    because  InvoiceDates or ClientCodes  may have changed with newly arrived data
----   ** Only match on Iatanum AND Recordkey to delete
/***********************************************************************************************************************/
 

 ---------------------------------------
 -----------DELETE COMRMKS-----
 ---------------------------------------
	SET @TransStart = getdate()

	DELETE dba.ComRmks
	FROM dba.ComRmks CR
		INNER JOIN dba.InvoiceHeader IH 
	ON (IH.Iatanum   = CR.Iatanum 
		AND IH.RecordKey = CR.RecordKey)
	WHERE IH.ImportDt = @MaxImportDt 
		AND IH.IataNum = @IataNum
		AND CR.Iatanum = @IataNum

	EXEC dbo.sp_LogProcErrors 
		@ProcedureName=@ProcName, 
		@LogStart=@TransStart, 
		@StepName='Delete DBA.comrmks', 
		@BeginDate=@LocalBeginIssueDate, 
		@EndDate= @LocalEndIssueDate, 
		@IataNum=@Iata, 
		@RowCount=@@ROWCOUNT, 
		@ERR=@@ERROR

 ---------------------------------------
 -----------INSERT COMRMKS-----
 ---------------------------------------
 	SET @TransStart = getdate()

	INSERT INTO dba.ComRmks (RecordKey, IATANUM, SeqNum, ClientCode, InvoiceDate, IssueDate,
							 Text1, Text2, Text3, Text4, Text5, Text6, Text7, Text8,	Text9,
							 Text10, Text11, Text12, Text13, Text14,	Text15, Text16, Text17 ,
							 Text18, Text19, Text20, Text21, Text22, Text23, Text24, Text48,
							 Text50)
	SELECT DISTINCT ID.RecordKey, ID.IATANUM, ID.SeqNum, ID.ClientCode, ID.InvoiceDate, ID.IssueDate,
					'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 
					'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided',
					'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 
					'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 
					'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 'Not Provided', 
					'Not Provided'
	FROM dba.InvoiceDetail ID
		INNER JOIN dba.InvoiceHeader IH
			ON (IH.IataNum     = ID.IataNum
				AND IH.ClientCode  = ID.ClientCode
				AND IH.RecordKey   = ID.RecordKey  
				AND IH.InvoiceDate = ID.InvoiceDate)
	WHERE IH.ImportDt = @MaxImportDt 
		AND IH.IataNum = @IataNum
		AND ID.IataNum = @IataNum
		AND ID.RecordKey+ID.IataNum+CONVERT(VARCHAR,ID.SeqNum)
		NOT IN (SELECT CR.RecordKey+CR.IataNum+CONVERT(VARCHAR,CR.SeqNum) 
					FROM DBA.ComRmks CR
					WHERE CR.IataNum = @IataNum)

	EXEC dbo.sp_LogProcErrors 
		@ProcedureName=@ProcName, 
		@LogStart=@TransStart, 
		@StepName='Insert Stag CR', 
		@BeginDate=@LocalBeginIssueDate, 
		@EndDate= @LocalEndIssueDate, 
		@IataNum=@Iata, 
		@RowCount=@@ROWCOUNT, 
		@ERR=@@ERROR


/******************************************************************  
    -----START STANDARD ComRmks MAPPINGS--------------------  
*******************************************************************/ 
--------------------------------------------------------------------
    --STANDARD Text2 WITH WITH POS FROM InvoiceHeader OrigCountry  
--------------------------------------------------------------------
    SET @TransStart = Getdate() 

--jm says why not do this on Insert Statement?

    UPDATE CR 
    SET    Text2 = CASE 
                     WHEN IH.OrigCountry IS NULL THEN 'Not Provided' 
                     ELSE IH.OrigCountry 
                   END 
    FROM   dba.ComRmks CR 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= CR.IataNum
                        AND IH.ClientCode = CR.ClientCode 
                        AND IH.RecordKey= CR.RecordKey
                        AND IH.InvoiceDate = CR.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND CR.IataNum= @IataNum
           

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Text2_IHPOS_Ctry', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


------------------------------	  
----	Text14 = Highest Class
-------------------------------	  
/***************************************************************************************	
/*Added the following logic to update cr.Text14 - sq 3/13/2015 
Updated logic for refunds outer join and refunds missing segmenTS- sq 3/13/2015 */ 
**************************************************************************************/
-------------------------------------------------
--		/*First Class Cabin*/ 
-------------------------------------------------
SET @TransStart = Getdate() 

UPDATE cr 
SET    cr.Text14 = CASE 
                     WHEN alfourcosID.cabin IS NULL THEN alfourcosIDoth.cabin 
                     ELSE alfourcosID.cabin 
                   END 
FROM   dba.InvoiceHeader IH --jm says Are these variables for ProductionServerName and DatabaseName?
       INNER JOIN dba.InvoiceDetail ID --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN dba.ComRmks CR  --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN dba.Transeg TS --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN DATAFEEDS.dba.masterfareclassref ALFOURCOSIDOTH --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN DATAFEEDS.dba.masterfareclassref ALFOURCOSID --jm says Are these variables for ProductionServerName and DatabaseName?
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														  WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
WHERE  1 = 1 
       AND ID.voIDind = 'N' 
       AND ID.vendortype IN ( 'BSP', 'NONBSP' ) /*Do we need to handle RAIL/ss*/ 
       AND ID.valcarriercode NOT IN ( '2V', '2R' ) 
       AND TS.mindestcitycode IS NOT NULL 
       AND CASE 
             WHEN ALFOURCOSID.cabin IS NULL THEN ALFOURCOSIDOTH.cabin 
             ELSE ALFOURCOSID.cabin 
           END = 'First' 
       AND CR.Text14 = 'Not Provided' 
       AND ID.IataNum = @IataNum 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='Update Highest class flown - First', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------------------
		/*Business Class Cabin*/ 
--------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE cr 
SET    cr.Text14 = CASE 
                     WHEN alfourcosID.cabin IS NULL THEN alfourcosIDoth.cabin 
                     ELSE alfourcosID.cabin 
                   END 
FROM   dba.InvoiceHeader IH --jm says Are these variables for ProductionServerName and DatabaseName?
       INNER JOIN dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN dba.ComRmks CR --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN dba.Transeg TS --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN DATAFEEDS.dba.masterfareclassref --jm says Are these variables for ProductionServerName and DatabaseName?
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN DATAFEEDS.dba.masterfareclassref ALFOURCOSID --jm says Are these variables for ProductionServerName and DatabaseName?
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														  WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
WHERE  1 = 1 
       AND ID.voIDind = 'N' 
       AND ID.vendortype IN ( 'BSP', 'NONBSP' ) /*Do we need to handle RAIL/ss*/ 
       AND ID.valcarriercode NOT IN ( '2V', '2R' ) 
       AND TS.mindestcitycode IS NOT NULL 
       AND CASE 
             WHEN ALFOURCOSID.cabin IS NULL THEN ALFOURCOSIDOTH.cabin 
             ELSE ALFOURCOSID.cabin 
           END = 'Business' 
       AND CR.Text14 = 'Not Provided' 
       AND ID.IataNum = @IataNum 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='Update Highest class flown - Business', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-----------------------------------------------------------------
/*Premium Economy Class Cabin*/ 
-----------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE cr 
SET    cr.Text14 = CASE 
                     WHEN alfourcosID.cabin IS NULL THEN alfourcosIDoth.cabin 
                     ELSE alfourcosID.cabin 
                   END 
FROM   dba.InvoiceHeader IH --jm says Are these variables for ProductionServerName and DatabaseName?
       INNER JOIN dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN dba.ComRmks CR --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN dba.Transeg TS --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN DATAFEEDS.dba.masterfareclassref --jm says Are these variables for ProductionServerName and DatabaseName?
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN DATAFEEDS.dba.masterfareclassref ALFOURCOSID --jm says Are these variables for ProductionServerName and DatabaseName?
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                          WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
WHERE  1 = 1 
       AND ID.voIDind = 'N' 
       AND ID.vendortype IN ( 'BSP', 'NONBSP' ) /*Do we need to handle RAIL/ss*/ 
       AND ID.valcarriercode NOT IN ( '2V', '2R' ) 
       AND TS.mindestcitycode IS NOT NULL 
       AND CASE 
             WHEN ALFOURCOSID.cabin IS NULL THEN ALFOURCOSIDOTH.cabin 
             ELSE ALFOURCOSID.cabin 
           END = 'Premium Economy' 
       AND CR.Text14 = 'Not Provided' 
       AND ID.IataNum = @IataNum  
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='Update Highest class flown - Premium Economy', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
  

  --------------------------------------------------------------
/*Economy Class Cabin - inclUDes 'Unclassified' cabin*/ 
--------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE cr 
SET    cr.Text14 = 'Economy' 
FROM   dba.InvoiceHeader IH --jm says Are these variables for ProductionServerName and DatabaseName?
       INNER JOIN dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN dba.ComRmks CR --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN dba.Transeg TS --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN DATAFEEDS.dba.masterfareclassref --jm says Are these variables for ProductionServerName and DatabaseName?
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN DATAFEEDS.dba.masterfareclassref ALFOURCOSID --jm says Are these variables for ProductionServerName and DatabaseName?
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														  WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
WHERE  1 = 1 
       AND ID.voIDind = 'N' 
       AND ID.vendortype IN ( 'BSP', 'NONBSP' ) /*Do we need to handle RAIL/ss*/ 
       AND ID.valcarriercode NOT IN ( '2V', '2R' ) 
       AND CASE 
             WHEN ALFOURCOSID.cabin IS NULL THEN ALFOURCOSIDOTH.cabin 
             ELSE ALFOURCOSID.cabin 
           END IN ( 'Economy', 'Unclassified' ) 
       AND TS.mindestcitycode IS NOT NULL 
       AND CR.Text14 = 'Not Provided' 
       AND ID.IataNum = @IataNum 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='Update Highest class flown - Economy', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

----------------------------------------------------------------------------------------------------
/*Update refunds in dba.InvoiceDetail that do not have corresponding rows in dba.Transeg 
by linking the refund document number back to the original debit transaction and using the value
in cr.Text14 */ 
----------------------------------------------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE cr 
SET    cr.Text14 = crorig.Text14 
FROM  dba.InvoiceHeader IH --jm says Are these variables for ProductionServerName and DatabaseName?
       INNER JOIN dba.InvoiceDetail ID --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN dba.ComRmks CR --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN dba.InvoiceDetail IDOrig --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( IDOrig.RecordKey<> ID.RecordKey
                    AND IDOrig.IataNum= ID.IataNum
                    AND IDOrig.ClientCode = ID.ClientCode 
                    AND ID.documentnumber = IDOrig.documentnumber 
                    AND IDOrig.refundind NOT IN ( 'Y', 'P' ) ) 
       INNER JOIN dba.ComRmks CROrig --jm says Are these variables for ProductionServerName and DatabaseName?
               ON ( CROrig.RecordKey= IDOrig.RecordKey
                    AND CROrig.IataNum= IDOrig.IataNum
                    AND CROrig.SeqNum = IDOrig.SeqNum 
                    AND CROrig.ClientCode = IDOrig.ClientCode ) 
WHERE  1 = 1 
       AND ID.voIDind = 'N' 
       AND ID.vendortype IN ( 'BSP', 'NONBSP' ) /*Do we need to handle RAIL/ss*/ 
       AND ID.valcarriercode NOT IN ( '2V', '2R' ) 
       AND CR.Text14 IS NULL 
       AND ID.IataNum = @IataNum  
       AND IH.ImportDt >= Getdate() - 10 
       AND ID.refundind IN ( 'Y', 'P' ) 
       AND cr.Text14 = 'Not Provided' 
       AND NOT EXISTS(SELECT 1 
                       FROM   dba.Transeg TS
                       WHERE  TS.RecordKey= ID.RecordKey
                              AND TS.IataNum= ID.IataNum
                              AND TS.SeqNum = ID.SeqNum) 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='Update Highest class flown - Refunds', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--/***************************************************
--/*End CR.Text14 update for highest cabin flown*/ 
--***************************************************/

/******************************************************************  
    -----END STANDARD COMRMKS MAPPINGS--------------------  
*******************************************************************/   
  EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
