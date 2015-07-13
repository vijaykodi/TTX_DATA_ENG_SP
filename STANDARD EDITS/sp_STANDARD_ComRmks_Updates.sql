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
            @LocalEndIssueDate		DATETIME  

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
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
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

	INSERT INTO dba.ComRmks (RecordKey, IATANUM, SeqNum, ClientCode, InvoiceDate, IssueDate)
	SELECT DISTINCT ID.RecordKey, ID.IATANUM, ID.SeqNum, ID.ClientCode, ID.InvoiceDate, ID.IssueDate
	FROM dba.InvoiceDetail ID
		INNER JOIN dba.InvoiceHeader IH
			ON (IH.IataNum     = ID.IataNum
				AND IH.ClientCode  = ID.ClientCode
				AND IH.RecordKey   = ID.RecordKey  
				AND IH.InvoiceDate = ID.InvoiceDate)
	WHERE IH.ImportDt = @MaxImportDt 
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND ID.IataNum = @IataNum
		AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
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

-----------------------------------------------------------------------
----------------------------------------------------------------------
--UPDATE COMRMKS TO 'Not Provided'PRIOR TO updating with agency data
----------------------------------------------------------------------

SET @TransStart = getdate()

UPDATE dba.comrmks
SET
Text1 = CASE WHEN Text1 is null THEN 'Not Provided' ELSE Text1 END,
Text2 = CASE WHEN Text2 is null THEN 'Not Provided' ELSE Text2 END,
Text3 = CASE WHEN Text3 is null THEN 'Not Provided' ELSE Text3 END,
Text4 = CASE WHEN Text4 is null THEN 'Not Provided' ELSE Text4 END,
Text5 = CASE WHEN Text5 is null THEN 'Not Provided' ELSE Text5 END,
Text6 = CASE WHEN Text6 is null THEN 'Not Provided' ELSE Text6 END,
Text7 = CASE WHEN Text7 is null THEN 'Not Provided' ELSE Text7 END,
Text8 = CASE WHEN Text8 is null THEN 'Not Provided' ELSE Text8 END,
Text9 = CASE WHEN Text9 is null THEN 'Not Provided' ELSE Text9 END,
Text10 = CASE WHEN Text10 is null THEN 'Not Provided' ELSE Text10 END,
Text11 = CASE WHEN Text11 is null THEN 'Not Provided' ELSE Text11 END,
Text12 = CASE WHEN Text12 is null THEN 'Not Provided' ELSE Text12 END,
Text13 = CASE WHEN Text13 is null THEN 'Not Provided' ELSE Text13 END,
text14 = CASE WHEN Text14 is null THEN 'Not Provided' ELSE Text14 END,
Text15 = CASE WHEN Text15 is null THEN 'Not Provided' ELSE Text15 END,  
Text16 = CASE WHEN Text16 is null THEN 'Not Provided' ELSE Text16 END,
Text17 = CASE WHEN Text17 is null THEN 'Not Provided' ELSE Text17 END,
Text18 = CASE WHEN Text18 is null THEN 'Not Provided' ELSE Text18 END,
Text19 = CASE WHEN Text19 is null THEN 'Not Provided' ELSE Text19 END,
Text20 = CASE WHEN Text20 is null THEN 'Not Provided' ELSE Text20 END,
Text21 = CASE WHEN Text21 is null THEN 'Not Provided' ELSE Text21 END,
Text22 = CASE WHEN Text22 is null THEN 'Not Provided' ELSE Text22 END,
Text23 = CASE WHEN Text23 is null THEN 'Not Provided' ELSE Text23 END,
Text24 = CASE WHEN Text24 is null THEN 'Not Provided' ELSE Text24 END,
Text48 = CASE WHEN Text48 is null THEN 'Not Provided' ELSE Text48 END,
Text50 = CASE WHEN Text50 is null THEN 'Not Provided' ELSE Text50 END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
WHERE IH.ImportDt = @MaxImportDt 
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate

EXEC dbo.sp_LogProcErrors 
			@ProcedureName=@ProcName, 
			@LogStart=@TransStart, 
			@StepName='SET text fields to Not Provided', 
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
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.IataNum= @IataNum
           AND CR.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

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
FROM   ProductionServerName.DatabaseName.dba.InvoiceHeader IH
       INNER JOIN ProductionServerName.DatabaseName.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw ALFOURCOSID
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
FROM   ProductionServerName.DatabaseName.dba.InvoiceHeader IH
       INNER JOIN ProductionServerName.DatabaseName.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw 
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw ALFOURCOSID
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
FROM   ProductionServerName.DatabaseName.dba.InvoiceHeader IH
       INNER JOIN ProductionServerName.DatabaseName.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw 
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw ALFOURCOSID
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
FROM   ProductionServerName.DatabaseName.dba.InvoiceHeader IH
       INNER JOIN ProductionServerName.DatabaseName.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw 
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = SUBSTRING(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN ProductionServerName.DatabaseName.dba.masterfareclassref_vw ALFOURCOSID
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
FROM   ProductionServerName.DatabaseName.dba.InvoiceHeader IH
       INNER JOIN ProductionServerName.DatabaseName.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.InvoiceDetail IDOrig 
               ON ( IDOrig.RecordKey<> ID.RecordKey
                    AND IDOrig.IataNum= ID.IataNum
                    AND IDOrig.ClientCode = ID.ClientCode 
                    AND ID.documentnumber = IDOrig.documentnumber 
                    AND IDOrig.refundind NOT IN ( 'Y', 'P' ) ) 
       INNER JOIN ProductionServerName.DatabaseName.dba.ComRmks CROrig 
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
