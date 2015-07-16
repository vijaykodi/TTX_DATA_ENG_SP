CREATE PROCEDURE [dbo].[sp_Hotel_CleanUp_Updates] (@BeginIssueDate DATETIME, 
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
      @StepName='End htl edits', 
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

---*************************************************************
--- END oF HOTEL CLEANUP
---*************************************************************

