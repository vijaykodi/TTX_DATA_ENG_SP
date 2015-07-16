----ONE STANDARD STORED PROCEDURE 

CREATE PROCEDURE [dbo].[sp_ONESTANDARD] (@BeginIssueDate DATETIME, 
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

/****************************************************************************************
---START OF UPDATES TO THE IssueDate, WHERE IssueDate IS NULL    
-***************************************************************************************/    

/******************************************************************************************** 
For any Recordkeys WHERE IssueDate is Null  SET IssueDate = InvoiceDate	in all tables 
namely dba.InvoiceDetail,	dba.Transeg, dba.Car, dba.Hotel, dba.UDef, dba.Payment, dba.Tax 
*********************************************************************************************/

--------------------------------------------------------------------------------------------------
     ----Updating the dba.InvoiceDetail Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
  ---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE ID
    SET    ID.IssueDate = IH.InvoiceDate 
    FROM   dba.InvoiceDetail ID
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= ID.IataNum
                        AND IH.RecordKey= ID.RecordKey
                        AND IH.InvoiceDate = ID.InvoiceDate
						 AND IH.ClientCode = ID.ClientCode) --added by jm 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND ID.IataNum= @IataNum
           AND ID.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When InvoiceDetail IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------------------------------------------------------------------
--Updating the dba.Transeg Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
-------------------------------------------------------------------------------------------------
      SET @TransStart = Getdate() 

    UPDATE TS
    SET    TS.IssueDate = IH.InvoiceDate 
    FROM   dba.Transeg TS
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= TS.IataNum
                        AND IH.RecordKey= TS.RecordKey
                        AND IH.InvoiceDate = TS.InvoiceDate
						 AND IH.ClientCode = TS.ClientCode) --added by jm 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND TS.IataNum= @IataNum
           AND TS.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When Transeg IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------------------
    --Updating the dba.Car Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
-------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE Car 
    SET    car.IssueDate = IH.InvoiceDate 
    FROM   dba.Car CAR 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= CAR.IataNum
                        AND IH.RecordKey= CAR.RecordKey
                        AND IH.InvoiceDate = CAR.InvoiceDate 
						AND IH.ClientCode = CAR.ClientCode) --added by jm
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND car.IataNum= @IataNum
           AND car.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When Car IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------
    --Updating the dba.Hotel Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE htl 
    SET    htl.IssueDate = IH.InvoiceDate 
    FROM   dba.Hotel htl 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= htl.IataNum
                        AND IH.RecordKey= htl.RecordKey
                        AND IH.InvoiceDate = htl.InvoiceDate
						AND IH.ClientCode = htl.ClientCode) --added by jm  
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND htl.IataNum= @IataNum
           AND htl.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When Hotel IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------
    --Updating the dba.UDef Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE UD 
    SET    UD.IssueDate = IH.InvoiceDate 
    FROM   dba.UDef UD 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= UD.IataNum
                        AND IH.RecordKey= UD.RecordKey
                        AND IH.InvoiceDate = UD.InvoiceDate
						AND IH.ClientCode = UD.ClientCode) --added by jm 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND UD.IataNum= @IataNum
           AND UD.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When UDef IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------
--Updating the dba.Payment Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
-----------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE pay 
    SET    pay.IssueDate = IH.InvoiceDate 
    FROM   dba.Payment PAY 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= PAY.IataNum
                        AND IH.RecordKey= PAY.RecordKey
                        AND IH.InvoiceDate = PAY.InvoiceDate
						AND IH.ClientCode = PAY.ClientCode) --added by jm
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND pay.IataNum= @IataNum
           AND pay.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When Payment IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------
--Updating the dba.Tax Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE Tax 
    SET    Tax.IssueDate = IH.InvoiceDate 
    FROM   dba.Tax Tax 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= Tax.IataNum
                        AND IH.RecordKey= Tax.RecordKey
                        AND IH.InvoiceDate = Tax.InvoiceDate
						AND IH.ClientCode = Tax.ClientCode) --added by jm 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND Tax.IataNum= @IataNum
           AND Tax.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='When Tax IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/**************************************************************************************** 
------END OF UPDATES FOR THE IssueDate, WHERE IssueDate IS NULL  
****************************************************************************************/ 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------
--------  BEGIN InvoiceDetail AND TranSeg Updates
--------------------------------------------------------------------------------------
----------------------------------
---- Amtrak Rail VendorType updates to InvoiceDetail and Transeg
----------------------------------

----------------------------------------------
-------  RAIL for ID.VendorType
---------------------------------------------
--------------------
--RAIL
--------------------

	SET @TransStart = Getdate() 

	UPDATE ID 
	SET    ID.Vendortype = CASE 
								WHEN  ID.vendortype NOT IN ( 'RAIL' ) OR ID.vendorname LIKE '%amtrak%' THEN 'RAIL' 
	                            WHEN ID.VendorType NOT IN ( 'RAIL' ) AND ID.ValCarrierCode in ('2V') THEN 'RAIL' ELSE ID.VendorType END
	FROM   dba.Invoicedetail ID 
		   INNER JOIN dba.invoiceheader IH 
				   ON ( IH.iatanum = ID.iatanum 
						AND IH.clientcode = ID.clientcode 
						AND IH.recordkey = ID.recordkey 
						AND IH.invoicedate = ID.invoicedate) 
	WHERE  IH.importdt = @MaxImportDt 
		   AND IH.iatanum = @IataNum 
		   AND ID.iatanum = @IataNum 
		 
				 
	EXEC dbo.Sp_logprocerrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='Vendortype RAIL by Name', 
	  @BeginDate=@BeginIssueDate, 
	  @EndDate=@EndIssueDate, 
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
FROM   DATAFEEDS.dba.InvoiceHeader IH --jm says Are these variables for ProductionServerName and DatabaseName?
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
----***********************************************************************************************************************************
-----------------------------------------------------------------
-----     BEGIN CLIENT SPECIFIC COMRMKS MAPPINGS    -------------
-----------------------------------------------------------------
----------------------------------------------------------------------
/*
	Text1 = Employee id
	Text2 = POS country
	Text3 = Cost Center
 	Text4 = Department
	Text5 = Division/region
	Text6 = Project code
	Text7 = Trip purpose code
	Text8 = Online indicator (usually the same as ID.OnlineBookingSystem)
	Text9 = 
	Text10 = 
	Text11
	Text12
	Text13
	Text14 = Highest cabin booked
	Text15
	Text16 
	Text17
	Text18 = no hotel booked code
	Text19
	Text20
	Text21
	Text22
	Text23
	Text24
	Text25 
*/
---------------------------------------------------------------------
-----------------------------------------------------------------
-----     END CLIENT SPECIFIC COMRMKS MAPPINGS    -------------
-----------------------------------------------------------------
---**************************************************************************************************
	----FARECOMPARE UPDATES 
---*************************************************************************************************

/**************************************************************  
----UPDATE NUM1 WITH FARECOMPARE1 AND NUM2 WITH FARECOMPARE2  
***************************************************************/ 
	
    SET @TransStart = Getdate() 

    UPDATE StagCR 
    SET    Num1 = CASE WHEN StagCR.Num1 IS NULL AND StagID.Farecompare1 IS NOT NULL THEN StagID.Farecompare1  END
		  ,Num2 = CASE WHEN StagCR.Num2 IS NULL AND StagID.Farecompare2 IS NOT NULL THEN StagID.Farecompare2  END	
    FROM   dba.ComRmks StagCR 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagCR.IataNum
                        AND StagIH.ClientCode = StagCR.ClientCode 
                        AND StagIH.RecordKey= StagCR.RecordKey
                        AND StagIH.InvoiceDate = StagCR.InvoiceDate ) 
           INNER JOIN dba.InvoiceDetail StagID
                   ON ( StagID.IataNum= StagCR.IataNum
                        AND StagID.ClientCode = StagCR.ClientCode 
                        AND StagID.RecordKey= StagCR.RecordKey
                        AND StagID.SeqNum = StagCR.SeqNum 
                        AND StagID.IssueDate = StagCR.IssueDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.IataNum= @IataNum
           AND StagID.IataNum= @IataNum
           AND StagCR.IataNum= @IataNum
           AND StagCR.num1 IS NULL 
           AND StagID.farecompare1 IS NOT NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Num1 FROM FC1 AND Num2 FROM FC2', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	
/***********************************************************************  
 COMPARE FC1 (FULL/(HIGH) FARE) TO TOTALAMT, UPDATE FC1 = TOTALAMT  
  COMPARE FC2 (LOW FARE) TO TOTALAMT, UPDATE FC2 = TOTALAMT  
************************************************************************/ 
 ------------------------------------------------------------------------------------------------
----WHEN TOTALAMT IS A POSITIVE, NEGATIVE, ISNULL OR '0', TOTALAMT =0 AND FARECOMPARE1 <> 0  
----WHEN TOTALAMT IS A POSITIVE, NEGATIVE, ISNULL OR '0', TOTALAMT =0 AND FARECOMPARE2 <> 0     
-------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE ID
    SET    FareCompare1 = CASE 
								WHEN VoIDInd = 'N' AND TotalAmt > 0 AND FareCompare1 < TotalAmt THEN TotalAmt  
								WHEN VoIDInd = 'N' AND TotalAmt < 0 AND FareCompare1 > TotalAmt THEN TotalAmt  
								WHEN VoIDInd = 'N' AND ISNULL(FareCompare1, '0') = '0' THEN TotalAmt  
								WHEN VoIDInd = 'N'  AND TotalAmt = 0 AND FareCompare1 <> 0 THEN TotalAmt
								END
           ,FareCompare2 = CASE
								WHEN VoIDInd = 'N' AND TotalAmt < 0 AND FareCompare2 > TotalAmt THEN TotalAmt
								WHEN VoIDInd = 'N' AND TotalAmt > 0 AND FareCompare2 < TotalAmt THEN TotalAmt
								WHEN VoIDInd = 'N' AND ISNULL(FareCompare2, '0') = '0' THEN TotalAmt
								WHEN VoIDInd = 'N'  AND TotalAmt = 0 AND FareCompare2 <> 0 THEN TotalAmt
								END 
    FROM   dba.InvoiceDetail ID
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= ID.IataNum
                        AND IH.ClientCode = ID.ClientCode 
                        AND IH.RecordKey= ID.RecordKey
                        AND IH.InvoiceDate = ID.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.IataNum= @IataNum
           AND ID.IataNum= @IataNum
           AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
           AND VoIDInd = 'N' 
           AND TotalAmt > 0 
           AND FareCompare1 < TotalAmt 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='FC1 High Fare and FC2 Low Fare Updates ', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*********************************************
--END STANDARD FC1 AND FC2 UPDATES  
**********************************************/

-----*******************************************************************************
   -- /* BEGIN PRE-HNN HOTEL CLEANUP -----*/  
-----*******************************************************************************
    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='BEGIN HTL edits', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


/**********************************************************************************************************************  
---REMOVING UNSEEN CHARACTERS IN HTLPRPERTYNAME AND HTLADDR1, htladdr2,htlstate,htlcountrycode and htlcityname  Updates
**********************************************************************************************************************/ 
    SET @TransStart = getdate()
    
    --jm says can't this be done when remobing leading and trailing spaces since this does it as well?
UPDATE StagHTL
SET HtlPropertyName = CASE WHEN Substring(StagHTL.htlpropertyname, 1, 1) = ' ' THEN Rtrim(Ltrim(StagHTL.htlpropertyname)) ELSE RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',',''))) END  
	,HtlAddr1 = CASE WHEN Substring(StagHTL.htladdr1, 1, 1) = ' '  THEN Rtrim(Ltrim(StagHTL.htladdr1))  ELSE RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),''))) END
	,HtlAddr2 = CASE WHEN Substring(StagHTL.htladdr2, 1, 1) = ' '  THEN Rtrim(Ltrim(StagHTL.htladdr2))  ELSE RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr2,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),''))) END
	,HtlAddr3 = CASE WHEN Substring(StagHTL.htladdr3, 1, 1) = ' '  THEN Rtrim(Ltrim(StagHTL.htladdr3)) ELSE RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr3,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),''))) END
	,htlchaincode = CASE WHEN Substring(StagHTL.htlchaincode, 1, 1) = ' ' THEN Rtrim(Ltrim(StagHTL.htlchaincode)) ELSE StagHTL.htlchaincode END
	,htlpostalcode = CASE WHEN Substring(StagHTL.htlpostalcode, 1, 1) = ' ' THEN Rtrim(Ltrim(StagHTL.htlpostalcode)) ELSE StagHTL.htlpostalcode END
	,htladdr3 = CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcityname LIKE '.%' AND StagHTL.htladdr3 IS NULL THEN htlcityname ELSE htladdr3 END
	,htlcityname = CASE WHEN StagHTL.masterID IS NULL AND StagHTL.htlcityname LIKE '.%' THEN NULL ELSE htlcityname END
	,htladdr1 = CASE WHEN StagHTL.masterID IS NULL AND StagHTL.htladdr1 IS NULL AND StagHTL.htladdr2 IS NOT NULL THEN htladdr2 ELSE htladdr1 END
	,htladdr2 = CASE WHEN StagHTL.masterID IS NULL AND StagHtl.htladdr2 = htladdr1 THEN NULL ELSE htladdr2 END
	,MasterID = CASE WHEN (HtlPropertyName LIKE 'OTHER%HOTELS%' OR HtlPropertyName LIKE '%NONAME%' OR HtlPropertyName IS NULL OR HtlPropertyName = '') AND (HtlAddr1 IS NULL OR HtlAddr1 = '') THEN -1 ELSE MasterID END 
	,StagHTL.htlstate = CASE WHEN  (StagHTL.htlpostalcode LIKE 'L%' OR StagHTL.htlpostalcode LIKE 'N%') AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlcitycode IN ('BUF', 'DTW') AND StagHTL.masterID IS NULL AND	StagHTL.htlstate <> 'ON' THEN 'ON' ELSE StagHTL.htlstate END 
	,StagHTL.htlcountrycode = CASE WHEN  (StagHTL.htlpostalcode LIKE 'L%' OR StagHTL.htlpostalcode LIKE 'N%') AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlcitycode IN ('BUF', 'DTW') AND StagHTL.masterID IS NULL AND StagHTL.htlcountrycode <> 'CA' THEN 'CA' ELSE StagHTL.htlcountrycode END   
	,StagHTL.htlcityname = CASE WHEN StagHTL.htlpostalcode IN ('L2G3V9', 'L2G 3V9') AND StagHTL.MasterId is NULL AND StagHTL.htlcityname <> Upper('Niagra Falls') THEN Upper('Niagra Falls') ELSE StagHTL.htlcityname END
	,StagHTL.htlstate = CASE WHEN StagHTL.htlpostalcode IN ('L2G3V9', 'L2G 3V9') AND StagHTL.MasterId is NULL AND StagHTL.htlstate <> 'ON' THEN 'ON' ELSE StagHTL.htlstate END
	,StagHTL.htlcountrycode = CASE WHEN StagHTL.htlpostalcode IN ('L2G3V9', 'L2G 3V9') AND StagHTL.MasterId is NULL AND StagHTL.htlcountrycode <> 'CA' THEN 'CA' ELSE StagHTL.htlcountrycode END   
	,StagHTL.htlcityname = CASE WHEN StagHTL.htlpostalcode IN ('N9A 1B2', 'N9A 7H7', 'N9C 2L6') AND StagHTL.MasterId is NULL AND StagHTL.htlcityname <> 'WINDSOR' THEN 'WINDSOR' ELSE StagHTL.htlcityname END
	,StagHTL.htlstate = CASE WHEN StagHTL.htlpostalcode IN ('N9A 1B2', 'N9A 7H7', 'N9C 2L6') AND StagHTL.MasterId is NULL AND StagHTL.htlstate <> 'ON' THEN 'ON' ELSE StagHTL.htlstate END 
	,StagHTL.htlcountrycode = CASE WHEN StagHTL.htlpostalcode IN ('N9A 1B2', 'N9A 7H7', 'N9C 2L6') AND StagHTL.MasterId is NULL AND StagHTL.htlcountrycode <> 'CA' THEN 'CA' ELSE StagHTL.htlcountrycode END 
	,StagHTL.htlcityname = CASE WHEN StagHTL.htlpostalcode IN ('N7T 7W6') AND StagHTL.MasterId is NULL AND StagHTL.htlcityname <> Upper('Point Edward') THEN Upper('Point Edward') ELSE StagHTL.htlcityname END
	,StagHTL.htlstate = CASE WHEN StagHTL.htlpostalcode IN ('N7T 7W6') AND StagHTL.MasterId is NULL AND StagHTL.htlstate <> 'ON' THEN 'ON' ELSE StagHTL.htlstate END
	,StagHTL.htlcountrycode = CASE WHEN StagHTL.htlpostalcode IN ('N7T 7W6') AND StagHTL.MasterId is NULL AND StagHTL.htlcountrycode <> 'CA' THEN 'CA' ELSE StagHTL.htlcountrycode END 
	,HtlState =  CASE WHEN StagHTL.htlstate IS NOT NULL AND StagHTL.htlcountrycode NOT IN ('US', 'CA', 'AU', 'BR') THEN NULL ELSE HtlState END
	, HtlCityName = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'FR' AND StagHTL.htlpostalcode LIKE '75[0-9][0-9][0-9]' AND StagHTL.htlcityname <> 'PARIS' THEN 'PARIS' ELSE HtlCityName END 
    ,HtlState = CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcountrycode = 'FR' AND StagHTL.htlpostalcode LIKE '75[0-9][0-9][0-9]' AND StagHTL.htlcityname <> 'PARIS' THEN NULL ELSE HtlState END
	,HtlCityName = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('RG1 1DP', 'RG1 1JX', 'RG11JX', 'RG1 8DB', 'RG2 0FL', 'RG2 0GQ') AND htlcityname <> 'READING' THEN 'READING' 
							  WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('RG21 3DR') AND htlcityname <> 'BASINGSTOKE' THEN 'BASINGSTOKE' 
                              WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('W1G 0PG', 'W1B 2QS', 'W1G 9BL', 'W1M 8HS', 'W1H 5DN', 'W1K 7TN') AND htlcityname <> 'LONDON' THEN 'LONDON' 
                              WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('OX2 6JP') AND htlcityname <> 'OXFORD' THEN 'OXFORD' 
							  WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('SL3 8PT', 'SL38PT') AND htlcityname <> 'SLOUGH' THEN 'SLOUGH' 
                              WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('UB3 5AN') AND htlcityname <> 'HAYES' THEN 'HAYES' 
                              WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'GB'	AND htlpostalcode IN ('TW6 2AQ', 'TW6 3AF') AND htlcityname <> 'Hounslow' THEN Upper('Hounslow') ELSE htlcityname END 
	,htlstate =  CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlstate IS NULL AND StagHTL.htladdr2 = 'ARKANSAS' THEN 'AR'ELSE htlstate END 
	,htlstate =  CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlstate <> 'CA' AND StagHTL.htladdr2 = 'CALIFORNIA' THEN 'CA' ELSE htlstate END  
    ,htlstate =  CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlstate <> 'GA' AND StagHTL.htladdr2 = 'GEORGIA'  THEN 'GA' ELSE htlstate END
	,htlstate =  CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlstate <> 'MA' AND StagHTL.htladdr2 = 'MASSACHUSETTS' THEN 'MA' ELSE htlstate END
	,htlstate =  CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlstate <> 'LA' AND StagHTL.htladdr2 = 'LOUISIANA' THEN 'LA' ELSE htlstate END
	,htlstate =  CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htlstate <> 'AZ' AND StagHTL.htladdr2 = 'ARIZONA' THEN 'AR' ELSE htlstate END
	,htlstate =  CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'CANADA' THEN NULL ELSE htlstate END
	,htlcountrycode = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'CANADA' THEN 'CA' ELSE htlcountrycode END
	,htlstate =  CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'UNITED KINGDOM'  THEN NULL ELSE htlstate END
	,htlcountrycode = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'UNITED KINGDOM' THEN 'GB' ELSE htlcountrycode END
	,htlstate =  CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'SOUTH KOREA'   THEN NULL ELSE htlstate END
	,htlcountrycode = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'SOUTH KOREA' THEN 'KR' ELSE htlcountrycode END
	,htlstate =  CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'JAPAN'   THEN NULL ELSE htlstate END
	,htlcountrycode = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcountrycode = 'US' AND StagHTL.htladdr3 = 'JAPAN' THEN 'JP' ELSE htlcountrycode END
	,htlcityname = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcityname = 'DELHI' AND StagHTL.htlcountrycode = 'IN' THEN 'NEW DELHI' ELSE htlcityname END
	,htlcityname = CASE WHEN StagHTL.MasterId is NULL AND (StagHTL.htlcityname = 'NEW YORK NY' OR StagHTL.htlcityname = 'NEW YORK, NY') THEN 'NEW YORK' ELSE  htlcityname END
    ,htlstate = CASE WHEN StagHTL.MasterId IS NULL AND (StagHTL.htlcityname = 'NEW YORK NY' OR StagHTL.htlcityname = 'NEW YORK, NY') THEN 'NY' ELSE htlstate END
	,HtlCityName = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcityname = 'WASHINGTON DC' THEN 'WASHINGTON' ELSE HtlCityName END 
	,HtlState = CASE WHEN StagHTL.MasterId is NULL AND StagHTL.htlcityname = 'WASHINGTON DC' THEN 'DC' ELSE HtlState END
	,htlcityname = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcityname NOT LIKE '[a-z]%' AND StagHTL.htlpropertyname LIKE '%MOEVENPICK HOTEL%' THEN 'HERTOGENBOSCH' ELSE htlcityname END 
	,htlcityname = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcityname NOT LIKE '[a-z]%' AND StagHTL.htlpropertyname LIKE '%OAKWOOD CHELSEA%' THEN 'NEW YORK' ELSE htlcityname END
	,htlcityname = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcityname NOT LIKE '[a-z]%' AND StagHTL.htlpropertyname LIKE '%LONGACRE HOUSE%'  THEN 'NEW YORK' ELSE htlcityname END
	,htlcityname = CASE WHEN StagHTL.MasterId IS NULL AND StagHTL.htlcityname NOT LIKE '[a-z]%' AND StagHTL.htlpropertyname LIKE '%HOTLE PUNTA PALMA%' THEN 'BARCELONA' ELSE htlcityname END
   FROM dba.Hotel StagHTL
INNER JOIN dba.invoiceheader StagIH 
ON     (StagIH.IataNum     = StagHTL.IataNum
	and StagIH.recordkey   = StagHTL.recordkey  
	and StagIH.invoicedate = StagHTL.invoicedate)
WHERE StagIH.importdt = @MaxImportDt
	and StagIH.IataNum = @IataNum
	and StagHTL.IataNum = @IataNum


    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlAddr1, htladdr2,htlstate,htlcountrycode and htlcityname  Updates', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 



----------------------------------------------------------------------------------------------
--  2nd, WHERE Countrycode is Null, update to US based on Htlstate and matching zip code 
----------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlCountryCode = CASE WHEN StagHTL.MasterId is NULL AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE '[0-9][0-9][0-9][0-9][0-9]' AND StagHTL.htlcountrycode IS NULL 
           AND StagHTL.htlstate IN ( 'AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 
                                     'MO', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 
                                     'WI', 'WV', 'WY' ) THEN 'US' ELSE HtlCountryCode END
		   ,HtlState = CASE WHEN StagHTL.MasterId is NULL AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE '[0-9][0-9][0-9][0-9][0-9]' AND StagHTL.htlcountrycode = 'US' AND ISNULL(StagHTL.htlstate, '') <> zp.state THEN zp.state ELSE HtlState END	
		   ,HtlCityName = CASE WHEN StagHTL.MasterId is NULL AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE '[0-9][0-9][0-9][0-9][0-9]' AND StagHTL.htlcountrycode = 'US' AND ISNULL(StagHTL.htlcityname, '') <> zp.city THEN  UPPER(zp.city) ELSE HtlCityName END	
	FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
           INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
                   ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
            

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlCountry to US based on zip', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


--------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='78-End htl edits', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---*************************************************************
--- END oF HOTEL CLEANUP
---*************************************************************

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR

---********************************************************************************************************************************
--- END oF HOTEL CLEANUP
---********************************************************************************************************************************

----*********************************************************************************
----CO2 EMISSION
----*********************************************************************************
--USE [TMAN503_ClientDB] 

--go 

--/****** Object:  StoredProcedure [dbo].[sp_ClientDB_CO2_MAIN]    Script Date: 05/21/2014 14:31:26 ******/ 
--SET ansi_nulls ON 

--go 

--SET quoted_identifier ON 

--go 

--CREATE PROCEDURE [dbo].[Sp_clientdb_co2_main] 
--  --@IATANUM VARCHAR (50), 
--  @BEGINISSUEDATEMAIN DATETIME, 
--  @ENDISSUEDATEMAIN   DATETIME 
--AS 
    DECLARE @TransStart DATETIME 
    DECLARE @ProcName VARCHAR(50) 
    DECLARE @TSUpdateEndSched NVARCHAR(50) 
    DECLARE @IATANUM VARCHAR (50) 

    declare @BEGINISSUEDATEMAIN DATETIME 
    declare @ENDISSUEDATEMAIN DATETIME 

    SET @ProcName = 'sp_ClientDB_CO2_MAIN_DATA'--sql update from Brent 
    SET @IATANUM = 'ALL' 
    --Reset the CO2 and YieldInd values before reprocessing 
    --update id 
    --set TktCO2Emissions = NULL 
    --from dba.InvoiceDetail id 
    --where TktCO2Emissions is not null 
    --  update t1 
    --  set 
    --  SEGCO2Emissions = NULL, 
    --  NOXCO2Emissions = NULL, 
    --  MINCO2Emissions = NULL, 
    --  FSeats = NULL, 
    --  BusSeats = NULL, 
    --  EconSeats = NULL, 
    --  TtlSeats = NULL, 
    --  YieldInd = NULL, 
    --  EquipmentCode = NULL 
    --  from dba.Transeg_VW t1 
    --  where issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    --update htl 
    --set CO2Emissions = NULL, 
    --GroundTransCO2 = NULL, 
    --MilesFromAirport = NULL 
    --from dba.hotel htl 
    --where CO2Emissions is not null 
    --update car 
    --set CO2Emissions = NULL 
    --from dba.car car 
    --where CO2Emissions is not null 
    --log processing 
    -- Any and all edits can be logged using sp_LogProcErrors  
    -- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts 
    -- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
    --  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run 
    --  @LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction 
    --  @StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
    --  @BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure 
    --  @EndDate datetime = NULL, -- **OPTIONAL**  The EndIssueDate that is pased to the Parent Procedure 
    --  @IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure 
    --  @RowCount int, -- **REQUIRED** Total number of affected rows 
    --  @ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero) 
    --Log Activity 
    SET @TransStart = Getdate() 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CO2 Stored Procedure Start', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    SELECT DISTINCT endsched, 
                    IDENTITY(int) AS [ID] 
    INTO   #endschedlist 
    FROM   datafeeds.dba.innovatadata 
    --\\ss why --WHERE EndSched BETWEEN [start] AND [END]  
    ORDER  BY endsched DESC 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='1-Created EndSched List', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @iatanum=@iatanum, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    DECLARE @RowCount     INT, 
            @ProcEndSched DATETIME, 
            @lcv          INT 

    SELECT @RowCount = Max([id]) 
    FROM   #endschedlist 

    SET @lcv = 1 
    SET @RowCount = @RowCount + 1 

    WHILE ( @lcv < @RowCount ) 
      BEGIN 
          SELECT @ProcEndSched = endsched 
          FROM   #endschedlist 
          WHERE  [id] = @lcv 

          SET @lcv = @lcv + 1 
          SET @TransStart = Getdate() 
          SET @TSUpdateEndSched = 'Processing for ' 
                                  + Cast(@ProcEndSched AS NVARCHAR(25)) 

          UPDATE t1 
          SET    t1.equipmentcode = t2.aircrafttype, 
                 t1.fseats = Isnull(t2.fseats, 0), 
                 t1.busseats = Isnull(t2.busseats, 0), 
                 t1.econseats = Isnull(t2.econseats, 0), 
                 t1.ttlseats = Isnull(t2.fseats, 0) + Isnull(t2.busseats, 0) 
                               + Isnull(t2.econseats, 0) 
          FROM   dba.transeg_vw t1, 
                 datafeeds.dba.innovatadata t2 
          WHERE  t1.departuredate BETWEEN t2.beginservice AND t2.endservice 
                 AND t2.endsched = @ProcEndSched 
                 --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
                 AND Cast(t1.flightnum AS INT) = t2.flightnum 
                 AND t1.segmentcarriercode = SUBSTRING(t2.carrier, 1, 2) 
                 AND t1.origincitycode = t2.depairport 
                 AND t1.segdestcitycode = t2.arrairport 
                 AND t1.equipmentcode IS NULL 
                 AND SEGCO2Emissions IS NULL 
                 AND Datepart(dw, t1.departuredate) = CASE 
                                                        WHEN 
                     Datepart(dw, t1.departuredate) = 1 
                                                      THEN 
                     SUBSTRING(opdaystring, 1, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 2 
                                                      THEN 
                     SUBSTRING(opdaystring, 2, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 3 
                                                      THEN 
                     SUBSTRING(opdaystring, 3, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 4 
                                                      THEN 
                     SUBSTRING(opdaystring, 4, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 5 
                                                      THEN 
                     SUBSTRING(opdaystring, 5, 1) 
                     WHEN 
                     Datepart(dw, t1.departuredate) = 6 
                                                      THEN 
                     SUBSTRING(opdaystring, 6, 1) 
                     ELSE 
                     SUBSTRING(opdaystring, 7, 1) 
                                                      END 
                 AND Replace(t1.flightnum, ',', '') NOT LIKE '%[^0-9]%' 

          EXEC dbo.Sp_logprocerrors 
            @ProcedureName=@ProcName, 
            @LogStart=@TransStart, 
            @StepName=@TSUpdateEndSched, 
            @BeginDate=@BEGINISSUEDATEMAIN, 
            @EndDate=@ENDISSUEDATEMAIN, 
            @IataNum=@IATANUM, 
            @RowCount=@@ROWCOUNT, 
            @ERR=@@ERROR 
      END 

    ----Update Burn Bucket 125 or Less 
    ----Update Domestic US Travel by 1.07-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
    END ) / ( 
    ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
    WHEN t4.loadfactor = 0 THEN 1 
    ELSE Isnull(t4.loadfactor, 1) 
    END 
      WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                      Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                    Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                    Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                  Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND orig.countrycode = 'US' 
       AND dest.countrycode = 'US' 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 US DOM x 1.07', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update Burn Bucket 125 or Less 
    --Update Intra Europe Flights by 1.10-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
CASE 
             WHEN t5.domcabin = 'First' THEN 
             ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
             Isnull(t7.cabin1, 1.8) ) / CASE 
  WHEN t4.loadfactor = 0 THEN 1 
  ELSE Isnull(t4.loadfactor, 1) 
  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
      Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
     WHEN t4.loadfactor = 0 THEN 1 
     ELSE Isnull(t4.loadfactor, 1) 
     END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest, 
       dba.country OCtry, 
       dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND Octry.continentcode = 'EU' 
       AND DCtry.continentcode = 'EU' 
       AND orig.countrycode = Octry.ctrycode 
       AND dest.countrycode = DCtry.ctrycode 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 Intra EU x 1.10', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----Update Burn Bucket 125 or Less 
    ----Update All other Dometic flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
CASE 
             WHEN t5.domcabin = 'First' THEN 
           ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
          Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                             WHEN t4.loadfactor = 0 THEN 1 
                             ELSE Isnull(t4.loadfactor, 1) 
                           END 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( 
Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest, 
       dba.country OCtry, 
       dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(( t1.segsegmentmileage ) / 1.150779) <= 125 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                   Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                 Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) ) > 0 
       AND orig.countrycode = Octry.ctrycode 
       AND dest.countrycode = DCtry.ctrycode 
       AND orig.countrycode = dest.countrycode 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <= 125 DOM x 1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----Update Burn Bucket 125 or Less 
    ----Update All other Short Haul flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
CASE 
             WHEN t5.domcabin = 'First' THEN 
           ( 
           ( t2.poundsco2permile * ( 
             Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
             WHEN t4.cargoratio = 0 THEN 1 
             ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
          Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                             WHEN t4.loadfactor = 0 THEN 1 
                             ELSE Isnull(t4.loadfactor, 1) 
                           END 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( ( 
Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
  WHEN t4.cargoratio = 0 THEN 1 
  ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
WHEN t4.loadfactor = 0 THEN 1 
ELSE Isnull(t4.loadfactor, 1) 
END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest, 
       dba.country OCtry, 
       dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.equipcode = eq.equivalentcode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND orig.countrycode = Octry.ctrycode 
       AND dest.countrycode = DCtry.ctrycode 
       AND orig.countrycode <> dest.countrycode 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 short haul x 1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----Update All other Burn Buckets-- 
    ----Update Domestic US Travel by 1.07-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND orig.countrycode = 'US' 
           AND dest.countrycode = 'US' 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket > 125 US x 1.07', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update Intra Europe Flights by 1.10-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country Octry, 
           dba.country DCtry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND Octry.continentcode = 'EU' 
           AND DCtry.continentcode = 'EU' 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket >125 Intra Europe x 1.10', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Dometic flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
                 WHEN t4.loadfactor = 0 THEN 1 
                 ELSE Isnull(t4.loadfactor, 1) 
               END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.equipcode = eq.equivalentcode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket >125 Dom x 1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets -- 
    --Update All other Short Haul flights by 1.085-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t4.cargoratio = 0 THEN 1 
ELSE Isnull(t4.cargoratio, 1) 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
                 WHEN t4.loadfactor = 0 THEN 1 
                 ELSE Isnull(t4.loadfactor, 1) 
               END 
END, 
yieldind = 'Y' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.equipcode = eq.equivalentcode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 <= 2000 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket >125 Short Haul x1.085', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '2000' AND '3000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.07 btw 2000-3000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets -- 
    --Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '3000' AND '4000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.06 btw 3000-4000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '4000' AND '5000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    ----and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.05 btw 4000-5000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '5000' AND '6000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.04 btw 5000-6000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '6000' AND '7000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haul x1.03 btw 6000-7000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 BETWEEN '7000' AND '8000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haulx1.02 btw 7000-8000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update All other Burn Buckets-- 
    --Update All other Long Haul flights by 1.01 Distance greter than 8000-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
                 t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * ( 
           Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * CASE 
                WHEN 
             t4.cargoratio = 0 THEN 1 
                                             ELSE Isnull( 
             t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin1, 1.8) ) / CASE 
                                             WHEN t4.loadfactor = 0 THEN 1 
                                             ELSE Isnull(t4.loadfactor, 1) 
                                             END 
             WHEN t5.domcabin = 'Business' THEN 
           ( 
             ( 
           ( ( 
           ( ( ( 
               Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                       t3low.burnuppervalue ) * ( 
                       t2.poundsco2permile - 
                       t2low.poundsco2permile ) ) / 
           ( t3.burnuppervalue - 
                                                    t3low.burnuppervalue ) ) + 
           t2low.poundsco2permile ) * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * CASE 
                     WHEN 
             t4.cargoratio = 0 THEN 1 
                                                ELSE 
             Isnull(t4.cargoratio, 1) 
           END ) / ( 
           ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
           Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
           Isnull(t7.cabin2, 2.0) ) / CASE 
                                                WHEN t4.loadfactor = 0 THEN 1 
                                                ELSE Isnull(t4.loadfactor, 1) 
                                                END 
             ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                                           t3low.burnuppervalue ) * ( 
                                           t2.poundsco2permile - 
                                           t2low.poundsco2permile ) ) 
                          / 
                                       ( t3.burnuppervalue - 
                        t3low.burnuppervalue ) ) + 
                                   t2low.poundsco2permile ) * ( 
                               Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
                             CASE 
                               WHEN t4.cargoratio = 0 THEN 1 
                               ELSE Isnull(t4.cargoratio, 1) 
                             END ) / ( 
                         ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                           Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
                         Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                         Isnull(t7.cabin4, 1) ) / CASE 
                  WHEN t4.loadfactor = 0 THEN 1 
                  ELSE Isnull(t4.loadfactor, 1) 
                                                  END 
           END, 
           yieldind = 'Y' 
    FROM   dba.transeg_vw T1, 
           datafeeds.dba.co2_emissions t2, 
           datafeeds.dba.co2_emissions t2low, 
           datafeeds.dba.co2_burnbucket t3, 
           datafeeds.dba.co2_burnbucket t3low, 
           datafeeds.dba.co2_airline_cargo_load t4, 
           dba.classtocabin t5, 
           datafeeds.dba.co2_seatguru t7, 
           datafeeds.dba.co2_aircraftequiv eq, 
           dba.city ORIG, 
           dba.city DEST, 
           dba.country octry, 
           dba.country dctry 
    WHERE  t1.equipmentcode IS NOT NULL 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t2.equipcode 
           AND t2.distancegroup = t3.burnuppervalue 
           AND eq.equivalentcode = t2low.equipcode 
           AND t2low.distancegroup = t3low.burnuppervalue 
           AND t3low.bucketnum = t3.bucketnum - 1 
           AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
               t3.burnlowvalue AND t3.burnuppervalue 
           AND t1.segsegmentmileage IS NOT NULL 
           AND t1.segmentcarriercode = t5.carriercode 
           AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
           AND t1.seginternationalind = t5.internationalind 
           AND t1.segmentcarriercode = t7.cr 
           AND t1.equipmentcode = eq.equipmentcode 
           AND eq.equivalentcode = t7.eqcode 
           AND t4.carrier = t7.cr 
           AND t4.origin = t1.origincitycode 
           AND t4.dest = t1.segdestcitycode 
           AND t4.equipcode = eq.equivalentcode 
           AND t4.carrier = t1.segmentcarriercode 
           AND t4.year = Year(t1.departuredate) 
           AND t4.month = Month(t1.departuredate) 
           AND t1.segco2emissions IS NULL 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.typecode = 'A' 
           AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                         Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                       Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
           AND orig.countrycode = Octry.ctrycode 
           AND dest.countrycode = DCtry.ctrycode 
           AND orig.countrycode <> dest.countrycode 
           AND t1.origincitycode = orig.citycode 
           AND t1.segdestcitycode = dest.citycode 
           AND t1.segsegmentmileage / 1.150779 > '8000' 
           AND t1.segsegmentmileage IS NOT NULL 
           AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
           AND t1.typecode = orig.typecode 
           AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Burn Bucket L-Haulx1.01 >8000', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --New code inserted by Brent Majors 12/29/2011 to use market averages where we dont get an exact hit-- 
    ----Update Burn Bucket 125 or Less 
    ----Update Domestic US Travel by 1.07-- 
    --Use Market Averages 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = CASE 
                               WHEN t5.domcabin = 'First' THEN 
    ( 
    ( t2.poundsco2permile * ( 
      Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
    ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
    ( 
    Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
    Isnull(t1.econseats, 0) * 
    Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
      WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                                             Isnull(t1.econseats, 0) * 
                                             Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor
  ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
                                             Isnull(t1.econseats, 0) * 
                                             Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
       datafeeds.dba.co2_emissions t2, 
       datafeeds.dba.co2_emissions t2low, 
       datafeeds.dba.co2_burnbucket t3, 
       datafeeds.dba.co2_burnbucket t3low, 
       datafeeds.dba.co2_airline_cargo_load t4, 
       dba.classtocabin t5, 
       datafeeds.dba.co2_seatguru t7, 
       datafeeds.dba.co2_aircraftequiv eq, 
       dba.city orig, 
       dba.city dest 
WHERE  t1.equipmentcode IS NOT NULL 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t2.equipcode 
       AND t2.distancegroup = t3.burnuppervalue 
       AND eq.equivalentcode = t2low.equipcode 
       AND t2low.distancegroup = t3low.burnuppervalue 
       AND t3low.bucketnum = t3.bucketnum - 1 
       AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
       AND t1.segsegmentmileage IS NOT NULL 
       AND t1.segmentcarriercode = t5.carriercode 
       AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
       AND t1.seginternationalind = t5.internationalind 
       AND t1.segmentcarriercode = t7.cr 
       AND t1.equipmentcode = eq.equipmentcode 
       AND eq.equivalentcode = t7.eqcode 
       AND t4.carrier = t7.cr 
       AND t4.origin = t1.origincitycode 
       AND t4.dest = t1.segdestcitycode 
       AND t4.carrier = t1.segmentcarriercode 
       AND t4.year = Year(t1.departuredate) 
       AND t4.month = Month(t1.departuredate) 
       AND t1.segco2emissions IS NULL 
       AND t1.origincitycode = orig.citycode 
       AND t1.segdestcitycode = dest.citycode 
       AND t1.typecode = 'A' 
       AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
                     Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
                   Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
       AND orig.countrycode = 'US' 
       AND dest.countrycode = 'US' 
       AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
       AND t1.typecode = orig.typecode 
       AND t1.typecode = dest.typecode 

    --and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Processed Burn Bucket <=125 US DOM x 1.07 Mkt Avg', 
      @BeginDate=@BEGINISSUEDATEMAIN, 
      @EndDate=@ENDISSUEDATEMAIN, 
      @IataNum=@IATANUM, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --Update Burn Bucket 125 or Less 
    --Update Intra Europe Flights by 1.10-- 
    --Use Market Averages-- 
    SET @TransStart = Getdate() 

    UPDATE t1 
    SET    SegCO2Emissions = 
           CASE 
             WHEN t5.domcabin = 'First' THEN 
( 
( t2.poundsco2permile * ( 
  Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * 
Isnull(t7.cabin2, 2.00) ) + ( 
                            Isnull(t1.econseats, 0) * 
                            Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
  WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
                            Isnull(t1.busseats, 0) * 
                            Isnull(t7.cabin2, 2.00) ) + ( 
                          Isnull(t1.econseats, 0) * 
                          Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
                            Isnull(t1.busseats, 0) * 
                            Isnull(t7.cabin2, 2.00) ) + ( 
                          Isnull(t1.econseats, 0) * 
                          Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket <=125 Intra EU x 1.10 Mkt Avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Dometic flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(( t1.segsegmentmileage ) / 1.150779) <= 125 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
        Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
      Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) ) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket <= 125 DOM x 1.085 Mkt Avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Short Haul flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / (
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket <=125 short haul x 1.085 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update All other Burn Buckets-- 
----Update Domestic US Travel by 1.07-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND orig.countrycode = 'US' 
AND dest.countrycode = 'US' 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket > 125 US x 1.07 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update Intra Europe Flights by 1.10-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country Octry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket >125 Intra Europe x 1.10 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Dometic flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
 t3low.burnuppervalue ) * ( 
 t2.poundsco2permile - 
 t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket >125 Dom x 1.085 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Short Haul flights by 1.085-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
 t3low.burnuppervalue ) * ( 
 t2.poundsco2permile - 
 t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 <= 2000 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Processed Burn Bucket >125 Short Haul x1.085 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '2000' AND '3000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.07 btw 2000-3000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '3000' AND '4000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.06 btw 3000-4000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '4000' AND '5000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.05 btw 4000-5000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '5000' AND '6000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.04 btw 5000-6000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '6000' AND '7000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haul x1.03 btw 6000-7000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '7000' AND '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haulx1.02 btw 7000-8000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.01 Distance greter than 8000-- 
--Use Market Averages-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
   t3low.burnuppervalue ) * ( 
   t2.poundsco2permile - 
   t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin1, 1.8) ) / t4.avgloadfactor 
WHEN t5.domcabin = 'Business' THEN 
( 
( 
( ( 
( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
t3low.burnuppervalue ) * ( 
t2.poundsco2permile - 
t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin2, 2.0) ) / t4.avgloadfactor 
ELSE 
( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
t3low.burnuppervalue ) * 
( 
t2.poundsco2permile - t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * t4.avgcargoratio ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + 
( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * 
( Isnull(t7.cabin4, 1) ) / t4.avgloadfactor 
END, 
yieldind = 'M' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
datafeeds.dba.co2_airline_cargo_load t4, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t4.carrier = t7.cr 
AND t4.origin = t1.origincitycode 
AND t4.dest = t1.segdestcitycode 
AND t4.carrier = t1.segmentcarriercode 
AND t4.year = Year(t1.departuredate) 
AND t4.month = Month(t1.departuredate) 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 > '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Burn Bucket L-Haulx1.01 >8000 mkt avg', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--New Updates inserted by Brent Majors Dec 23 2011 for default load facotrs and cargo ratios 
----Update Burn Bucket 125 or Less-- 
----Update Domestic US Travel by 1.07-- 
----Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( ( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END 
) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * 
Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * 
Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin1, 1.8) ) / CASE 
WHEN T1.segmentcarriercode IN ( 'AA', 'US', 'AS', 'AQ', 
'CO', 'DL', 'NW', 'UA', 
'2F', '3M', '4E', '4W', 
'5F', '8v', '9K', 'B6', 
'FL', 'GQ', 'H6', 'HA', 
'HP', 'J6', 'KS', 'NK', 
'PA', 'Q5', 'SY', 'U5', 
'VQ', 'VX', 'WN', 'YI', 
'YX', 'ZQ', '2E', '2Q', 
'3A', '3F', '3Z', '7N', 
'7S', '8E', '9S', 'BK', 
'QX', 'CH', 'DQ', 'EJ', 
'HX', 'IS', 'JW', 'K3', 
'K4', 'K5', 'LW', 'M5', 
'M6', 'UH', 'WP', 'YR', 
'YV', 'Z3', 'ZK', '00', 
'XE', 'NA', '2O', '9L', 
'EV', 'G7', 'J5', 'MQ', 
'OH', 'OO', 'RP', 'RW', 
'S6', 'XJ', 'ZW', 'D1', 
'CP', 'S5', 'AX', 'C5', 
'6P', 'LL', '1X', 'GV', 
'K9', 'L3', 'N8', 'RD', 
'XP', 'Y0', 'V2', 'TJ' ) THEN 
.7593 
ELSE .6735 
END 
WHEN t5.domcabin = 'Business' THEN 
( ( t2.poundsco2permile * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN T1.segmentcarriercode IN ( 
'AA', 'US', 'AS', 'AQ', 
'CO', 'DL', 'NW', 'UA', 
'2F', '3M', '4E', '4W', 
'5F', '8v', '9K', 'B6', 
'FL', 'GQ', 'H6', 'HA', 
'HP', 'J6', 'KS', 'NK', 
'PA', 'Q5', 'SY', 'U5', 
'VQ', 'VX', 'WN', 'YI', 
'YX', 'ZQ', '2E', '2Q', 
'3A', '3F', '3Z', '7N', 
'7S', '8E', '9S', 'BK', 
'QX', 'CH', 'DQ', 'EJ', 
'HX', 'IS', 'JW', 'K3', 
'K4', 'K5', 'LW', 'M5', 
'M6', 'UH', 'WP', 'YR', 
'YV', 'Z3', 'ZK', '00', 
'XE', 'NA', '2O', '9L', 
'EV', 'G7', 'J5', 'MQ', 
'OH', 'OO', 'RP', 'RW', 
'S6', 'XJ', 'ZW', 'D1', 
'CP', 'S5', 'AX', 'C5', 
'6P', 'LL', '1X', 'GV', 
'K9', 'L3', 'N8', 'RD', 
'XP', 'Y0', 'V2', 'TJ' ) THEN .7593 
ELSE .6735 
END 
ELSE 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin4, 1) ) / CASE 
WHEN T1.segmentcarriercode IN ( 'AA', 'US', 'AS', 'AQ', 
'CO', 'DL', 'NW', 'UA', 
'2F', '3M', '4E', '4W', 
'5F', '8v', '9K', 'B6', 
'FL', 'GQ', 'H6', 'HA', 
'HP', 'J6', 'KS', 'NK', 
'PA', 'Q5', 'SY', 'U5', 
'VQ', 'VX', 'WN', 'YI', 
'YX', 'ZQ', '2E', '2Q', 
'3A', '3F', '3Z', '7N', 
'7S', '8E', '9S', 'BK', 
'QX', 'CH', 'DQ', 'EJ', 
'HX', 'IS', 'JW', 'K3', 
'K4', 'K5', 'LW', 'M5', 
'M6', 'UH', 'WP', 'YR', 
'YV', 'Z3', 'ZK', '00', 
'XE', 'NA', '2O', '9L', 
'EV', 'G7', 'J5', 'MQ', 
'OH', 'OO', 'RP', 'RW', 
'S6', 'XJ', 'ZW', 'D1', 
'CP', 'S5', 'AX', 'C5', 
'6P', 'LL', '1X', 'GV', 
'K9', 'L3', 'N8', 'RD', 
'XP', 'Y0', 'V2', 'TJ' ) THEN .7593 
ELSE .6735 
END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = 'US' 
AND dest.countrycode = 'US' 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <=125 US DOM x 1.07 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update Burn Bucket 125 or Less 
--Update Intra Europe Flights by 1.10-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = 
CASE 
  WHEN t5.domcabin = 'First' THEN ( ( 
  t2.poundsco2permile * ( 
  Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * 
            CASE 
              WHEN t2.equipclass = 'W' THEN .801 
              WHEN t2.equipclass = 'J' THEN .983 
              ELSE 1 
END 
) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
                       Isnull(t7.cabin1, 1.8) ) / 
                       CASE 
                         WHEN T1.segmentcarriercode IN ( 
                              'AA', 'US', 'AS', 'AQ', 
                              'CO', 'DL', 'NW', 'UA', 
                              '2F', '3M', '4E', '4W', 
                              '5F', '8v', '9K', 'B6', 
                              'FL', 'GQ', 'H6', 'HA', 
                              'HP', 'J6', 'KS', 'NK', 
                              'PA', 'Q5', 'SY', 'U5', 
                              'VQ', 'VX', 'WN', 'YI', 
                              'YX', 'ZQ', '2E', '2Q', 
                              '3A', '3F', '3Z', '7N', 
                              '7S', '8E', '9S', 'BK', 
                              'QX', 'CH', 'DQ', 'EJ', 
                              'HX', 'IS', 'JW', 'K3', 
                              'K4', 'K5', 'LW', 'M5', 
                              'M6', 'UH', 'WP', 'YR', 
                              'YV', 'Z3', 'ZK', '00', 
                              'XE', 'NA', '2O', '9L', 
                              'EV', 'G7', 'J5', 'MQ', 
                              'OH', 'OO', 'RP', 'RW', 
                              'S6', 'XJ', 'ZW', 'D1', 
                              'CP', 'S5', 'AX', 'C5', 
                              '6P', 'LL', '1X', 'GV', 
                              'K9', 'L3', 'N8', 'RD', 
                              'XP', 'Y0', 'V2', 'TJ' ) THEN 
                         .7593 
                         ELSE .6735 
                       END 
WHEN t5.domcabin = 'Business' THEN 
( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( Isnull(t7.cabin2, 2.0) ) / CASE 
WHEN T1.segmentcarriercode IN ( 'AA', 'US', 'AS', 'AQ', 
                     'CO', 'DL', 'NW', 'UA', 
                     '2F', '3M', '4E', '4W', 
                     '5F', '8v', '9K', 'B6', 
                     'FL', 'GQ', 'H6', 'HA', 
                     'HP', 'J6', 'KS', 'NK', 
                     'PA', 'Q5', 'SY', 'U5', 
                     'VQ', 'VX', 'WN', 'YI', 
                     'YX', 'ZQ', '2E', '2Q', 
                     '3A', '3F', '3Z', '7N', 
                     '7S', '8E', '9S', 'BK', 
                     'QX', 'CH', 'DQ', 'EJ', 
                     'HX', 'IS', 'JW', 'K3', 
                     'K4', 'K5', 'LW', 'M5', 
                     'M6', 'UH', 'WP', 'YR', 
                     'YV', 'Z3', 'ZK', '00', 
                     'XE', 'NA', '2O', '9L', 
                     'EV', 'G7', 'J5', 'MQ', 
                     'OH', 'OO', 'RP', 'RW', 
                     'S6', 'XJ', 'ZW', 'D1', 
                     'CP', 'S5', 'AX', 'C5', 
                     '6P', 'LL', '1X', 'GV', 
                     'K9', 'L3', 'N8', 'RD', 
                     'XP', 'Y0', 'V2', 'TJ' ) THEN .7593 
ELSE .6735 
END 
ELSE ( 
( t2.poundsco2permile * ( Abs(t1.segsegmentmileage) / 1.150779 * 1.1 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END 
) / ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
    Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
 Isnull(t7.cabin4, 1) ) / CASE 
                            WHEN T1.segmentcarriercode IN ( 
                                 'AA', 'US', 'AS', 'AQ', 
                                 'CO', 'DL', 'NW', 'UA', 
                                 '2F', '3M', '4E', '4W', 
                                 '5F', '8v', '9K', 'B6', 
                                 'FL', 'GQ', 'H6', 'HA', 
                                 'HP', 'J6', 'KS', 'NK', 
                                 'PA', 'Q5', 'SY', 'U5', 
                                 'VQ', 'VX', 'WN', 'YI', 
                                 'YX', 'ZQ', '2E', '2Q', 
                                 '3A', '3F', '3Z', '7N', 
                                 '7S', '8E', '9S', 'BK', 
                                 'QX', 'CH', 'DQ', 'EJ', 
                                 'HX', 'IS', 'JW', 'K3', 
                                 'K4', 'K5', 'LW', 'M5', 
                                 'M6', 'UH', 'WP', 'YR', 
                                 'YV', 'Z3', 'ZK', '00', 
                                 'XE', 'NA', '2O', '9L', 
                                 'EV', 'G7', 'J5', 'MQ', 
                                 'OH', 'OO', 'RP', 'RW', 
                                 'S6', 'XJ', 'ZW', 'D1', 
                                 'CP', 'S5', 'AX', 'C5', 
                                 '6P', 'LL', '1X', 'GV', 
                                 'K9', 'L3', 'N8', 'RD', 
                                 'XP', 'Y0', 'V2', 'TJ' ) THEN 
                            .7593 
                            ELSE .6735 
                          END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
        Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <=125 Intra EU x 1.10 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Dometic flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( ( t2.poundsco2permile * ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
    WHEN t2.equipclass = 'W' THEN .801 
    WHEN t2.equipclass = 'J' THEN .983 
    ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( ( t2.poundsco2permile * 
    ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                 CASE 
  WHEN t2.equipclass = 'W' THEN .801 
  WHEN t2.equipclass = 'J' THEN .983 
  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( t2.poundsco2permile * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                CASE 
                  WHEN t2.equipclass = 'W' THEN .801 
                  WHEN t2.equipclass = 'J' THEN .983 
                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
              WHEN T1.segmentcarriercode IN ( 
                   'AA', 'US', 'AS', 'AQ', 
                   'CO', 'DL', 'NW', 'UA', 
                   '2F', '3M', '4E', '4W', 
                   '5F', '8v', '9K', 'B6', 
                   'FL', 'GQ', 'H6', 'HA', 
                   'HP', 'J6', 'KS', 'NK', 
                   'PA', 'Q5', 'SY', 'U5', 
                   'VQ', 'VX', 'WN', 'YI', 
                   'YX', 'ZQ', '2E', '2Q', 
                   '3A', '3F', '3Z', '7N', 
                   '7S', '8E', '9S', 'BK', 
                   'QX', 'CH', 'DQ', 'EJ', 
                   'HX', 'IS', 'JW', 'K3', 
                   'K4', 'K5', 'LW', 'M5', 
                   'M6', 'UH', 'WP', 'YR', 
                   'YV', 'Z3', 'ZK', '00', 
                   'XE', 'NA', '2O', '9L', 
                   'EV', 'G7', 'J5', 'MQ', 
                   'OH', 'OO', 'RP', 'RW', 
                   'S6', 'XJ', 'ZW', 'D1', 
                   'CP', 'S5', 'AX', 'C5', 
                   '6P', 'LL', '1X', 'GV', 
                   'K9', 'L3', 'N8', 'RD', 
                   'XP', 'Y0', 'V2', 'TJ' ) 
            THEN 
              .7593 
              ELSE .6735 
            END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(( t1.segsegmentmileage ) / 1.150779) <= 125 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND ( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) ) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <= 125 DOM x 1.085 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update Burn Bucket 125 or Less 
----Update All other Short Haul flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( ( t2.poundsco2permile * ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
    WHEN t2.equipclass = 'W' THEN .801 
    WHEN t2.equipclass = 'J' THEN .983 
    ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( ( t2.poundsco2permile * 
    ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                 CASE 
  WHEN t2.equipclass = 'W' THEN .801 
  WHEN t2.equipclass = 'J' THEN .983 
  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( t2.poundsco2permile * 
           ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
                CASE 
                  WHEN t2.equipclass = 'W' THEN .801 
                  WHEN t2.equipclass = 'J' THEN .983 
                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.00) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
              WHEN T1.segmentcarriercode IN ( 
                   'AA', 'US', 'AS', 'AQ', 
                   'CO', 'DL', 'NW', 'UA', 
                   '2F', '3M', '4E', '4W', 
                   '5F', '8v', '9K', 'B6', 
                   'FL', 'GQ', 'H6', 'HA', 
                   'HP', 'J6', 'KS', 'NK', 
                   'PA', 'Q5', 'SY', 'U5', 
                   'VQ', 'VX', 'WN', 'YI', 
                   'YX', 'ZQ', '2E', '2Q', 
                   '3A', '3F', '3Z', '7N', 
                   '7S', '8E', '9S', 'BK', 
                   'QX', 'CH', 'DQ', 'EJ', 
                   'HX', 'IS', 'JW', 'K3', 
                   'K4', 'K5', 'LW', 'M5', 
                   'M6', 'UH', 'WP', 'YR', 
                   'YV', 'Z3', 'ZK', '00', 
                   'XE', 'NA', '2O', '9L', 
                   'EV', 'G7', 'J5', 'MQ', 
                   'OH', 'OO', 'RP', 'RW', 
                   'S6', 'XJ', 'ZW', 'D1', 
                   'CP', 'S5', 'AX', 'C5', 
                   '6P', 'LL', '1X', 'GV', 
                   'K9', 'L3', 'N8', 'RD', 
                   'XP', 'Y0', 'V2', 'TJ' ) 
            THEN 
              .7593 
              ELSE .6735 
            END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city orig, 
dba.city dest, 
dba.country OCtry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) <= 125 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket <=125 short haul x 1.085 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

----Update All other Burn Buckets-- 
----Update Domestic US Travel by 1.07-- 
----Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND orig.countrycode = 'US' 
AND dest.countrycode = 'US' 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket > 125 US x 1.07 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update Intra Europe Flights by 1.10-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.10 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country Octry, 
dba.country DCtry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND Octry.continentcode = 'EU' 
AND DCtry.continentcode = 'EU' 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket >125 Intra Europe x 1.10 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Dometic flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
      WHEN T1.segmentcarriercode IN ( 
           'AA', 'US', 'AS', 'AQ', 
           'CO', 'DL', 'NW', 'UA', 
           '2F', '3M', '4E', '4W', 
           '5F', '8v', '9K', 'B6', 
           'FL', 'GQ', 'H6', 'HA', 
           'HP', 'J6', 'KS', 'NK', 
           'PA', 'Q5', 'SY', 'U5', 
           'VQ', 'VX', 'WN', 'YI', 
           'YX', 'ZQ', '2E', '2Q', 
           '3A', '3F', '3Z', '7N', 
           '7S', '8E', '9S', 'BK', 
           'QX', 'CH', 'DQ', 'EJ', 
           'HX', 'IS', 'JW', 'K3', 
           'K4', 'K5', 'LW', 'M5', 
           'M6', 'UH', 'WP', 'YR', 
           'YV', 'Z3', 'ZK', '00', 
           'XE', 'NA', '2O', '9L', 
           'EV', 'G7', 'J5', 'MQ', 
           'OH', 'OO', 'RP', 'RW', 
           'S6', 'XJ', 'ZW', 'D1', 
           'CP', 'S5', 'AX', 'C5', 
           '6P', 'LL', '1X', 'GV', 
           'K9', 'L3', 'N8', 'RD', 
           'XP', 'Y0', 'V2', 'TJ' ) 
    THEN 
      .7593 
      ELSE .6735 
    END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode = dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket >125 Dom x 1.085 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Short Haul flights by 1.085-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.085 ) ) * 
CASE 
WHEN t2.equipclass = 'W' THEN .801 
WHEN t2.equipclass = 'J' THEN .983 
ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin4, 1) ) / CASE 
      WHEN T1.segmentcarriercode IN ( 
           'AA', 'US', 'AS', 'AQ', 
           'CO', 'DL', 'NW', 'UA', 
           '2F', '3M', '4E', '4W', 
           '5F', '8v', '9K', 'B6', 
           'FL', 'GQ', 'H6', 'HA', 
           'HP', 'J6', 'KS', 'NK', 
           'PA', 'Q5', 'SY', 'U5', 
           'VQ', 'VX', 'WN', 'YI', 
           'YX', 'ZQ', '2E', '2Q', 
           '3A', '3F', '3Z', '7N', 
           '7S', '8E', '9S', 'BK', 
           'QX', 'CH', 'DQ', 'EJ', 
           'HX', 'IS', 'JW', 'K3', 
           'K4', 'K5', 'LW', 'M5', 
           'M6', 'UH', 'WP', 'YR', 
           'YV', 'Z3', 'ZK', '00', 
           'XE', 'NA', '2O', '9L', 
           'EV', 'G7', 'J5', 'MQ', 
           'OH', 'OO', 'RP', 'RW', 
           'S6', 'XJ', 'ZW', 'D1', 
           'CP', 'S5', 'AX', 'C5', 
           '6P', 'LL', '1X', 'GV', 
           'K9', 'L3', 'N8', 'RD', 
           'XP', 'Y0', 'V2', 'TJ' ) 
    THEN 
      .7593 
      ELSE .6735 
    END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 <= 2000 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Processed Burn Bucket >125 Short Haul x1.085 for deafult cargo and passenger ratios' 
, 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.07 Distance Between 2000 and 3000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.07 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '2000' AND '3000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.07 btw 2000-3000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets -- 
--Update All other Long Haul flights by 1.06 Distance Between 3000 and 4000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.06 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '3000' AND '4000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.06 btw 3000-4000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.05 Distance Between 4000 and 5000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.05 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '4000' AND '5000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.05 btw 4000-5000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.04 Distance Between 5000 and 6000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.04 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '5000' AND '6000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.04 btw 5000-6000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.03 Distance Between 6000 and 7000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.03 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '6000' AND '7000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.03 btw 6000-7000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.02 Distance Between 7000 and 8000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.02 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 BETWEEN '7000' AND '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.02 btw 7000-8000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update All other Burn Buckets-- 
--Update All other Long Haul flights by 1.01 Distance greter than 8000-- 
--Update default cargo and passenger ratios-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    SegCO2Emissions = CASE 
                    WHEN t5.domcabin = 'First' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / ( t3.burnuppervalue - 
      t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * ( 
Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
  CASE 
                                  WHEN 
  t2.equipclass = 'W' THEN .801 
                                  WHEN 
  t2.equipclass = 'J' THEN .983 
                                  ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin1, 1.8) ) / CASE 
                                  WHEN T1.segmentcarriercode IN ( 
                                       'AA', 'US', 'AS', 'AQ', 
                                       'CO', 'DL', 'NW', 'UA', 
                                       '2F', '3M', '4E', '4W', 
                                       '5F', '8v', '9K', 'B6', 
                                       'FL', 'GQ', 'H6', 'HA', 
                                       'HP', 'J6', 'KS', 'NK', 
                                       'PA', 'Q5', 'SY', 'U5', 
                                       'VQ', 'VX', 'WN', 'YI', 
                                       'YX', 'ZQ', '2E', '2Q', 
                                       '3A', '3F', '3Z', '7N', 
                                       '7S', '8E', '9S', 'BK', 
                                       'QX', 'CH', 'DQ', 'EJ', 
                                       'HX', 'IS', 'JW', 'K3', 
                                       'K4', 'K5', 'LW', 'M5', 
                                       'M6', 'UH', 'WP', 'YR', 
                                       'YV', 'Z3', 'ZK', '00', 
                                       'XE', 'NA', '2O', '9L', 
                                       'EV', 'G7', 'J5', 'MQ', 
                                       'OH', 'OO', 'RP', 'RW', 
                                       'S6', 'XJ', 'ZW', 'D1', 
                                       'CP', 'S5', 'AX', 'C5', 
                                       '6P', 'LL', '1X', 'GV', 
                                       'K9', 'L3', 'N8', 'RD', 
                                       'XP', 'Y0', 'V2', 'TJ' ) THEN 
                                  .7593 
                                  ELSE .6735 
                                  END 
  WHEN t5.domcabin = 'Business' THEN 
( 
  ( 
( ( 
( ( ( 
    Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
            t3low.burnuppervalue ) * ( 
            t2.poundsco2permile - 
            t2low.poundsco2permile ) ) / 
( t3.burnuppervalue - 
                                         t3low.burnuppervalue ) ) + 
t2low.poundsco2permile ) * 
( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
  CASE 
                                     WHEN 
  t2.equipclass = 'W' THEN .801 
                                     WHEN 
  t2.equipclass = 'J' THEN .983 
                                     ELSE 1 
END ) / ( 
( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
          Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
Isnull(t7.cabin2, 2.0) ) / CASE 
                                     WHEN T1.segmentcarriercode IN ( 
                                          'AA', 'US', 'AS', 'AQ', 
                                          'CO', 'DL', 'NW', 'UA', 
                                          '2F', '3M', '4E', '4W', 
                                          '5F', '8v', '9K', 'B6', 
                                          'FL', 'GQ', 'H6', 'HA', 
                                          'HP', 'J6', 'KS', 'NK', 
                                          'PA', 'Q5', 'SY', 'U5', 
                                          'VQ', 'VX', 'WN', 'YI', 
                                          'YX', 'ZQ', '2E', '2Q', 
                                          '3A', '3F', '3Z', '7N', 
                                          '7S', '8E', '9S', 'BK', 
                                          'QX', 'CH', 'DQ', 'EJ', 
                                          'HX', 'IS', 'JW', 'K3', 
                                          'K4', 'K5', 'LW', 'M5', 
                                          'M6', 'UH', 'WP', 'YR', 
                                          'YV', 'Z3', 'ZK', '00', 
                                          'XE', 'NA', '2O', '9L', 
                                          'EV', 'G7', 'J5', 'MQ', 
                                          'OH', 'OO', 'RP', 'RW', 
                                          'S6', 'XJ', 'ZW', 'D1', 
                                          'CP', 'S5', 'AX', 'C5', 
                                          '6P', 'LL', '1X', 'GV', 
                                          'K9', 'L3', 'N8', 'RD', 
                                          'XP', 'Y0', 'V2', 'TJ' ) 
                           THEN 
                                     .7593 
                                     ELSE .6735 
                                     END 
  ELSE ( ( ( ( ( ( ( Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) - 
                                t3low.burnuppervalue ) * ( 
                                t2.poundsco2permile - 
                                t2low.poundsco2permile ) ) 
               / 
                            ( t3.burnuppervalue - 
             t3low.burnuppervalue ) ) + 
                        t2low.poundsco2permile ) * ( 
                    Abs(t1.segsegmentmileage) / 1.150779 * 1.01 ) ) * 
                  CASE 
                    WHEN t2.equipclass = 'W' THEN .801 
                    WHEN t2.equipclass = 'J' THEN .983 
                    ELSE 1 
                  END ) / ( 
              ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 1.8) ) + ( 
                Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 2.0) ) + ( 
              Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 1) ) ) * ( 
              Isnull(t7.cabin4, 1) ) / CASE 
                                         WHEN 
       T1.segmentcarriercode IN ( 
       'AA', 'US', 'AS', 'AQ', 
       'CO', 'DL', 'NW', 'UA', 
       '2F', '3M', '4E', '4W', 
       '5F', '8v', '9K', 'B6', 
       'FL', 'GQ', 'H6', 'HA', 
       'HP', 'J6', 'KS', 'NK', 
       'PA', 'Q5', 'SY', 'U5', 
       'VQ', 'VX', 'WN', 'YI', 
       'YX', 'ZQ', '2E', '2Q', 
       '3A', '3F', '3Z', '7N', 
       '7S', '8E', '9S', 'BK', 
       'QX', 'CH', 'DQ', 'EJ', 
       'HX', 'IS', 'JW', 'K3', 
       'K4', 'K5', 'LW', 'M5', 
       'M6', 'UH', 'WP', 'YR', 
       'YV', 'Z3', 'ZK', '00', 
       'XE', 'NA', '2O', '9L', 
       'EV', 'G7', 'J5', 'MQ', 
       'OH', 'OO', 'RP', 'RW', 
       'S6', 'XJ', 'ZW', 'D1', 
       'CP', 'S5', 'AX', 'C5', 
       '6P', 'LL', '1X', 'GV', 
       'K9', 'L3', 'N8', 'RD', 
       'XP', 'Y0', 'V2', 'TJ' ) 
                                       THEN 
                                         .7593 
                                         ELSE .6735 
                                       END 
END, 
yieldind = 'C' 
FROM   dba.transeg_vw T1, 
datafeeds.dba.co2_emissions t2, 
datafeeds.dba.co2_emissions t2low, 
datafeeds.dba.co2_burnbucket t3, 
datafeeds.dba.co2_burnbucket t3low, 
dba.classtocabin t5, 
datafeeds.dba.co2_seatguru t7, 
datafeeds.dba.co2_aircraftequiv eq, 
dba.city ORIG, 
dba.city DEST, 
dba.country octry, 
dba.country dctry 
WHERE  t1.equipmentcode IS NOT NULL 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t2.equipcode 
AND t2.distancegroup = t3.burnuppervalue 
AND eq.equivalentcode = t2low.equipcode 
AND t2low.distancegroup = t3low.burnuppervalue 
AND t3low.bucketnum = t3.bucketnum - 1 
AND Abs(t1.segsegmentmileage / 1.150779) BETWEEN 
    t3.burnlowvalue AND t3.burnuppervalue 
AND t1.segsegmentmileage IS NOT NULL 
AND t1.segmentcarriercode = t5.carriercode 
AND Isnull(t1.classofservice, 'Y') = t5.classofservice 
AND t1.seginternationalind = t5.internationalind 
AND t1.segmentcarriercode = t7.cr 
AND t1.equipmentcode = eq.equipmentcode 
AND eq.equivalentcode = t7.eqcode 
AND t1.segco2emissions IS NULL 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.typecode = 'A' 
AND (( ( Isnull(t1.fseats, 0) * Isnull(t7.cabin1, 0) ) + ( 
              Isnull(t1.busseats, 0) * Isnull(t7.cabin2, 0) ) + ( 
            Isnull(t1.econseats, 0) * Isnull(t7.cabin4, 0) ) )) > 0 
AND orig.countrycode = Octry.ctrycode 
AND dest.countrycode = DCtry.ctrycode 
AND orig.countrycode <> dest.countrycode 
AND t1.origincitycode = orig.citycode 
AND t1.segdestcitycode = dest.citycode 
AND t1.segsegmentmileage / 1.150779 > '8000' 
AND t1.segsegmentmileage IS NOT NULL 
AND Patindex('%[^0-9^.]%', t1.flightnum) = 0 
AND t1.typecode = orig.typecode 
AND t1.typecode = dest.typecode 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName= 
'Burn Bucket L-Haulx1.01 >8000 for deafult cargo and passenger ratios', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Step down logic for matching CO2-- 
SET @TransStart = Getdate() 

UPDATE t2 
SET    t2.segco2emissions = t1.segco2emissions, 
YieldInd = 'F' 
---match on everything --this is where we didn't get a match using the sechedule data...now using same flight details previously updated.  Need to update sql to find most recent record for same flight
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2 
WHERE  t1.segco2emissions > 0 
AND (( t2.segco2emissions IS NULL 
        OR t2.segco2emissions = 0 )) 
AND t1.flightnum = t2.flightnum 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND t1.segmentcarriercode = t2.segmentcarriercode 
AND Isnull(t1.equipmentcode, 'ZZ') = Isnull(t2.equipmentcode, 'ZZ') 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=F-match on everything', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE t2 
SET    t2.segco2emissions = t1.segco2emissions, 
YieldInd = 'A' 
-- matched on everything but flight number is different 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2 
WHERE  t1.segco2emissions > 0 
AND (( t2.segco2emissions IS NULL 
        OR t2.segco2emissions = 0 )) 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND t1.segmentcarriercode = t2.segmentcarriercode 
AND Isnull(t1.equipmentcode, 'ZZ') = Isnull(t2.equipmentcode, 'ZZ') 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=A-match on everything but flight', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE t2 
SET    t2.segco2emissions = t1.segco2emissions, 
YieldInd = 'E' -- Match on equipment only 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2 
WHERE  t1.segco2emissions > 0 
AND (( t2.segco2emissions IS NULL 
        OR t2.segco2emissions = 0 )) 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND Isnull(t1.equipmentcode, 'ZZ') = Isnull(t2.equipmentcode, 'ZZ') 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=E-match on equipment only', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.transeg_vw 
SET    segco2emissions = CASE 
                    WHEN Abs(segsegmentmileage) BETWEEN 0 AND 500 
                  THEN 
                    segsegmentmileage * 0.52 
                    ELSE segsegmentmileage * 0.40 
                  END, 
yieldind = 'D' 
--match where nothing matches - using default values .audit trail on why not found 
WHERE  (( segco2emissions IS NULL 
    OR segco2emissions = 0 )) 
AND segsegmentmileage IS NOT NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=D-match on nothing', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.transeg_vw 
SET    yieldind = 'N' 
--No match at all which shouldn't happen .audit trail on why not found 
WHERE  segsegmentmileage IS NULL 
AND yieldind IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=N-no match at all', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.transeg_vw 
SET    yieldind = 'Z' 
--No match on yield and equipcode...audit trail on why not found 
WHERE  segsegmentmileage IS NULL 
AND yieldind IS NULL 
AND equipmentcode IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Yield=Z-no match on yield and equipment', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE dba.hotel 
SET    co2emissions = ( numnights * numrooms ) * 33.38 
WHERE  co2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.car 
SET    co2emissions = ( ( ( 20 / 23.9 ) * 8.87 ) / 1000 ) * ( 
               numdays * numcars ) 
WHERE  co2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.transeg_vw 
SET    equipmentcode = 'TRN' 
WHERE  segmentcarriercode IN ( '2R', '2V', '9B', '9F' ) 
--need to insure that all TRAINS are covered... 
AND equipmentcode IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.transeg_vw 
SET    segco2emissions = CASE 
                    WHEN segsegmentmileage <= 20 THEN 
                    ( .35 * segsegmentmileage ) * 1.10 
                    ELSE ( .42 * segsegmentmileage ) * 1.10 
                  END, 
yieldind = 'T' 
WHERE  equipmentcode = 'TRN' 
AND segco2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
UPDATE dba.transeg_vw --check...where does equipmentcode is set 'BUS' 
SET    segco2emissions = CASE 
                    WHEN segsegmentmileage <= 20 THEN 
                    ( .66 * segsegmentmileage ) * 1.10 
                    ELSE ( .18 * segsegmentmileage ) * 1.10 
                  END, 
yieldind = 'B' 
WHERE  equipmentcode = 'BUS' 
AND segco2emissions IS NULL 

--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Process Refunds',@BeginDate=@BEGINISSUEDATEMAIN,@EndDate=@ENDISSUEDATEMAIN,@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--Update Partial Refunds-- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    t1.segco2emissions = ( t2.segco2emissions *- 1 ) 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2, 
dba.invoicedetail i1, 
dba.invoicedetail i2 
WHERE  t1.recordkey = i1.recordkey 
AND t1.seqnum = i1.seqnum 
AND t1.iatanum = i1.iatanum 
AND t2.recordkey = i2.recordkey 
AND t2.seqnum = i2.seqnum 
AND t2.iatanum = i2.iatanum 
AND t1.segsegmentvalue = t2.segsegmentvalue 
AND i1.refundind = 'P' 
AND i2.refundind = 'N' 
AND i1.documentnumber = i2.documentnumber 
AND t1.origincitycode = t2.origincitycode 
AND t1.segdestcitycode = t2.segdestcitycode 
AND t1.recordkey <> t2.recordkey 
AND i1.documentnumber <> '9999999999' 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Process partial refunds', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--Update Full refunds -- 
SET @TransStart = Getdate() 

UPDATE t1 
SET    t1.segco2emissions = ( t2.segco2emissions *- 1 ) 
FROM   dba.transeg_vw T1, 
dba.transeg_vw t2, 
dba.invoicedetail i1, 
dba.invoicedetail i2 
WHERE  t1.recordkey = i1.recordkey 
AND t1.seqnum = i1.seqnum 
AND t1.iatanum = i1.iatanum 
AND t2.recordkey = i2.recordkey 
AND t2.seqnum = i2.seqnum 
AND t2.iatanum = i2.iatanum 
AND t1.segmentnum = t2.segmentnum 
AND i1.refundind = 'Y' 
AND i2.refundind = 'N' 
AND i1.documentnumber = i2.documentnumber 
AND t1.recordkey <> t2.recordkey 
AND i1.documentnumber <> '9999999999' 

--and t1.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Process Full Refunds', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

--New Refund Updates from Brent 11NOV2011 
SET @TransStart = Getdate() 

UPDATE T1 
SET    segsegmentmileage = Abs(segsegmentmileage) *- 1, 
segtotalmileage = Abs(segtotalmileage) *- 1, 
noxsegmentmileage = Abs(noxsegmentmileage) *- 1, 
noxtotalmileage = Abs(noxtotalmileage) *- 1, 
minsegmentmileage = Abs(minsegmentmileage) *- 1, 
mintotalmileage = Abs(mintotalmileage) *- 1, 
noxflownmileage = Abs(noxflownmileage) *- 1, 
minflownmileage = Abs(minflownmileage) *- 1, 
segco2emissions = Abs(segco2emissions) *- 1, 
noxco2emissions = Abs(noxco2emissions) *- 1, 
minco2emissions = Abs(minco2emissions) *- 1 
FROM   dba.transeg_vw T1, 
dba.invoicedetail ID 
WHERE  id.recordkey = T1.recordkey 
AND id.iatanum = t1.iatanum 
AND id.seqnum = t1.seqnum 
AND id.clientcode = t1.clientcode 
AND id.issuedate = t1.issuedate 
AND id.refundind IN ( 'Y', 'P' ) 

--and id.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
--update ID 
--set ID.TKTCO2Emissions = (select sum(isnull(SegCO2Emissions,0))  
--  from dba.Transeg_VW ts  
--  where ts.iatanum = id.iatanum and ts.recordkey = id.recordkey and ts.seqnum = id.seqnum and ts.issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)
--from dba.invoicedetail ID 
--where ((tktco2emissions is null) 
--or (tktco2emissions = 0)) 
--and vendortype in ('BSP','BSPSTP','NONBSP','NONBSPSTP') 
--and issuedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='Process Refund segement data', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

EXEC dbo.Sp_logprocerrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='End Process', 
@BeginDate=@BEGINISSUEDATEMAIN, 
@EndDate=@ENDISSUEDATEMAIN, 
@IataNum=@IATANUM, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

---**********************************************************************************************
---END OF CO2 EMISSION UPDATES
--***********************************************************************************************

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
---End of Code

---**********************************************************************************************
---END OF ANCILLARY FEE UPDATES
--***********************************************************************************************
