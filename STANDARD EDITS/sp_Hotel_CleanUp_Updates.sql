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
      @ERR=@@ERROR -----*******************************************************************************
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


/*************************************************************************************  
-- /* REMOVING BEGINNING AND ENDING SPACES IN ALL HOTEL FIELDS */  
**************************************************************************************/ 
------------------------------------  
    /* HtlPropertyName */ 
----------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlpropertyname = Rtrim(Ltrim(StagHTL.htlpropertyname)) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND SUBSTRING(StagHTL.htlpropertyname, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Remove Begin-End Spaces HTLpropertyname', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------
    /*HtlAddr1*/
---------------------------------- 
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htladdr1 = Rtrim(Ltrim(StagHTL.htladdr1)) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND SUBSTRING(StagHTL.htladdr1, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Remove Begin-End Spaces HtlAddr1', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------
    /*HtlAddr2*/ 
---------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htladdr2 = Rtrim(Ltrim(StagHTL.htladdr2)) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND SUBSTRING(StagHTL.htladdr2, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Remove Begin-End Spaces HtlAddr2', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------
    /*HtlAddr3*/ 
---------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htladdr3 = Rtrim(Ltrim(StagHTL.htladdr3)) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND SUBSTRING(StagHTL.htladdr3, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Remove Begin-End Spaces HtlAddr3', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-----------------------------------
    /*HtlChainCode*/ 
-----------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlchaincode = Rtrim(Ltrim(StagHTL.htlchaincode)) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND SUBSTRING(StagHTL.htlchaincode, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Remove Begin-End Spaces HtlChainCode', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------
    /*HtlPostalCode*/ 
-------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlpostalcode = Rtrim(Ltrim(StagHTL.htlpostalcode)) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND SUBSTRING(StagHTL.htlpostalcode, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Remove Begin-End Spaces HtlPostalCode', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*******************************************************************  
-----UPDATE CITY NAME TO NULL IF STARTSWITH '.'  
*******************************************************************/ 
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htladdr3 = htlcityname 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname LIKE '.%' 
           AND StagHTL.htladdr3 IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlCityName with period (.)', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
---------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = NULL 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.masterID IS NULL 
           AND StagHTL.htlcityname LIKE '.%' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Move HtlCityName to HtlAddr3', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*******************************************************************  
---REMOVING UNSEEN CHARACTERS IN HTLPRPERTYNAME AND HTLADDR1 
*******************************************************************/ 
    SET @TransStart = getdate()

	UPDATE StagHTL
	SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',','')))
	   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
	   ,HtlAddr2 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr2,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
	   ,HtlAddr3 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr3,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
	FROM dba.Hotel StagHTL
	INNER JOIN dba.invoiceheader StagIH 
	ON     (StagIH.IataNum     = StagHTL.IataNum
		and StagIH.recordkey   = StagHTL.recordkey  
		and StagIH.invoicedate = StagHTL.invoicedate)
	WHERE StagIH.importdt = @MaxImportDt
		and StagIH.invoicedate between @FirstInvDate and @LastInvDate
		and StagIH.IataNum = @IataNum
		and StagHTL.IataNum = @IataNum


    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Replace char HtlProperty and Address', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*********************************************************************************  
 --  Move HtlAddr2 data to HtlAddr1 if HtlAddr1 is NULL and HtlAddr2 is not null  
 --  Pam S added this step to standard  
**********************************************************************************/ 
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htladdr1 = htladdr2 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.masterID IS NULL 
           AND StagHTL.htladdr1 IS NULL 
           AND StagHTL.htladdr2 IS NOT NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Move htladdr2 to HtlAddr1 when null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
-------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htladdr2 = NULL 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.masterID IS NULL 
           AND StagHtl.htladdr2 = htladdr1 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlAddr2 to Null if HtlAddr1=HtlAddr2 ', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/**********************************************************************  
-- Master IDto -1 if unalbe to determine property name and HtlAddr1  
***********************************************************************/ 
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    masterID= -1 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND ( HtlPropertyName LIKE 'OTHER%HOTELS%' 
                  OR HtlPropertyName LIKE '%NONAME%' 
                  OR HtlPropertyName IS NULL 
                  OR HtlPropertyName = '' ) 
           AND ( HtlAddr1 IS NULL 
                  OR HtlAddr1 = '' ) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='MasterIDto -1', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*************************************************************************  
----  NEVER USE CITY TABLE FOR HOTEL UPDATES !!!!!  
----  Use Master Zip Code table to update state and country code if Null  
*************************************************************************/ 
    --- First, Updates for Canada based on Zip Codes -------  
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlstate = CASE 
                                WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                                ELSE StagHTL.htlstate 
                              END, 
           StagHTL.htlcountrycode = CASE 
                                      WHEN StagHTL.htlcountrycode <> 'CA' THEN 
                                      'CA' 
                                      ELSE StagHTL.htlcountrycode 
                                    END 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND ( StagHTL.htlpostalcode LIKE 'L%' 
                  OR StagHTL.htlpostalcode LIKE 'N%' ) 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlcitycode IN ( 'BUF', 'DTW' ) 
           AND StagHTL.masterID IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='BUF DTW  -Zip in CA -Not in US', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
--------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlcityname = CASE 
                                   WHEN StagHTL.htlcityname <> Upper( 
                                        'Niagra Falls') 
                                 THEN 
                                   Upper('Niagra Falls') 
                                   ELSE StagHTL.htlcityname 
                                 END, 
           StagHTL.htlstate = CASE 
                                WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                                ELSE StagHTL.htlstate 
                              END, 
           StagHTL.htlcountrycode = CASE 
                                      WHEN StagHTL.htlcountrycode <> 'CA' THEN 
                                      'CA' 
                                      ELSE StagHTL.htlcountrycode 
                                    END 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.htlpostalcode IN ( 'L2G3V9', 'L2G 3V9' ) 
           AND StagHTL.MasterId is NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Zip for Niagra Falls, CA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
-------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlcityname = CASE 
                                   WHEN StagHTL.htlcityname <> Upper( 
                                        'Niagara On The Lake') 
                                        THEN Upper( 
                                   'Niagara On The Lake') 
                                   ELSE StagHTL.htlcityname 
                                 END, 
           StagHTL.htlstate = CASE 
                                WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                                ELSE StagHTL.htlstate 
                              END, 
           StagHTL.htlcountrycode = CASE 
                                      WHEN StagHTL.htlcountrycode <> 'CA' THEN 
                                      'CA' 
                                      ELSE StagHTL.htlcountrycode 
                                    END 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.htlpostalcode = 'L0S 1J0' 
           AND StagHTL.MasterId is NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Zip for Niagara On The Lake, CA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
----------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlcityname = CASE 
                                   WHEN StagHTL.htlcityname <> 'WINDSOR' THEN 
                                   'WINDSOR' 
                                   ELSE StagHTL.htlcityname 
                                 END, 
           StagHTL.htlstate = CASE 
                                WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                                ELSE StagHTL.htlstate 
                              END, 
           StagHTL.htlcountrycode = CASE 
                                      WHEN StagHTL.htlcountrycode <> 'CA' THEN 
                                      'CA' 
                                      ELSE StagHTL.htlcountrycode 
                                    END 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.htlpostalcode IN ( 'N9A 1B2', 'N9A 7H7', 'N9C 2L6' ) 
           AND StagHTL.MasterId is NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Zip for Windsor CA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    StagHTL.htlcityname = CASE 
                                   WHEN StagHTL.htlcityname <> Upper( 
                                        'Point Edward') 
                                 THEN 
                                   Upper('Point Edward') 
                                   ELSE StagHTL.htlcityname 
                                 END, 
           StagHTL.htlstate = CASE 
                                WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                                ELSE StagHTL.htlstate 
                              END, 
           StagHTL.htlcountrycode = CASE 
                                      WHEN StagHTL.htlcountrycode <> 'CA' THEN 
                                      'CA' 
                                      ELSE StagHTL.htlcountrycode 
                                    END 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.htlpostalcode IN ( 'N7T 7W6' ) 
           AND StagHTL.MasterId is NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Zip for Point Edward CA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----M5V 2G5 = TORONTO CA if ever need to add a step for this one  
    -- END Updates for Canada based on Zip Code -------------  
/*************************************************************************************  
-- AFTER Canada updates, BEGIN Updates for US States and Cities based on Zip Codes  
****************************************************************************************/ 
    -- 1st, Remove HtlStateCode if not in these countries: ('US','CA','AU','BR')  
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlState = NULL 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlstate IS NOT NULL 
           AND StagHTL.htlcountrycode NOT IN ( 'US', 'CA', 'AU', 'BR' ) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Null HtlState if not US,CA,AU,BR', 
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
    SET    HtlCountryCode = 'US' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
           INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
                   ON ( SUBSTRING(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND SUBSTRING(StagHTL.htlpostalcode, 1, 5) LIKE 
               '[0-9][0-9][0-9][0-9][0-9]' 
           AND StagHTL.htlcountrycode IS NULL 
           AND StagHTL.htlstate IN ( 'AK', 'AL', 'AR', 'AZ', 
                                     'CA', 'CO', 'CT', 'DC', 
                                     'DE', 'FL', 'GA', 'HI', 
                                     'IA', 'ID', 'IL', 'IN', 
                                     'KS', 'KY', 'LA', 'MA', 
                                     'MD', 'ME', 'MI', 'MN', 
                                     'MO', 'MS', 'MT', 'NC', 
                                     'ND', 'NE', 'NH', 'NJ', 
                                     'NM', 'NV', 'NY', 'OH', 
                                     'OK', 'OR', 'PA', 'RI', 
                                     'SC', 'SD', 'TN', 'TX', 
                                     'UT', 'VA', 'VT', 'WA', 
                                     'WI', 'WV', 'WY' ) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlCountry to US based on zip', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------
-- WHERE State code is null or wrong for US -----  
---------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlState = zp.state 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
           INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
                   ON ( SUBSTRING(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND SUBSTRING(StagHTL.htlpostalcode, 1, 5) LIKE 
               '[0-9][0-9][0-9][0-9][0-9]' 
           AND StagHTL.htlcountrycode = 'US' 
           AND Isnull(StagHTL.htlstate, '') <> zp.state 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlState FROM US Zip', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------
--- WHERE city name is wrong for US cities ----  
-------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlCityName = Upper(zp.city) 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
           INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
                   ON ( SUBSTRING(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND SUBSTRING(StagHTL.htlpostalcode, 1, 5) LIKE 
               '[0-9][0-9][0-9][0-9][0-9]' 
           AND StagHTL.htlcountrycode = 'US' 
           AND Isnull(StagHTL.htlcityname, '') <> zp.city 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CityName by US Zip', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	
/*******************************************************************
-- END US updates based on Zip Code -------  
********************************************************************/

/**************************************************************************************  
--Correct CityName to Paris WHERE zip codes begin with 75 + 3 digit region 
***************************************************************************************/ 
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlCityName = 'PARIS', 
           HtlState = NULL 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'FR' 
           AND StagHTL.htlpostalcode LIKE '75[0-9][0-9][0-9]' 
           AND StagHTL.htlcityname <> 'PARIS' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CityName to Paris by Zip', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------
    -- For GB based on Zip Codes ----  
---------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlState = NULL, 
           HtlCityName = CASE 
                           WHEN htlpostalcode IN ( 'RG1 1DP', 'RG1 1JX', 
                                                   'RG11JX', 
                                                   'RG1 8DB', 
                                                   'RG2 0FL', 'RG2 0GQ' ) 
                                AND htlcityname <> 'READING' THEN 'READING' 
                           WHEN htlpostalcode IN ( 'RG21 3DR' ) 
                                AND htlcityname <> 'BASINGSTOKE' THEN 
                           'BASINGSTOKE' 
                           WHEN htlpostalcode IN ( 'W1G 0PG', 'W1B 2QS', 
                                                   'W1G 9BL', 
                                                   'W1M 8HS', 
                                                   'W1H 5DN', 'W1K 7TN' ) 
                                AND htlcityname <> 'LONDON' THEN 'LONDON' 
                           WHEN htlpostalcode IN ( 'OX2 6JP' ) 
                                AND htlcityname <> 'OXFORD' THEN 'OXFORD' 
                           WHEN htlpostalcode IN ( 'SL3 8PT', 'SL38PT' ) 
                                AND htlcityname <> 'SLOUGH' THEN 'SLOUGH' 
                           WHEN htlpostalcode IN ( 'UB3 5AN' ) 
                                AND htlcityname <> 'HAYES' THEN 'HAYES' 
                           WHEN htlpostalcode IN ( 'TW6 2AQ', 'TW6 3AF' ) 
                                AND htlcityname <> 'Hounslow' THEN Upper( 
                           'Hounslow') 
                           ELSE htlcityname 
                         END 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'GB' 

	 EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HtlState to Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*********************************************************
--  END Updates based on Zip Codes -----------  
*********************************************************/

/***************************************************************  
-- BEGIN Misc UpdaTes for Hotels 
****************************************************************/ 
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = 'AR' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlstate IS NULL 
           AND StagHTL.htladdr2 = 'ARKANSAS' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='ARKANSAS', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-----------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = 'CA' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlstate <> 'CA' 
           AND StagHTL.htladdr2 = 'CALIFORNIA' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CALIFORNIA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-----------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = 'GA' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlstate <> 'GA' 
           AND StagHTL.htladdr2 = 'GEORGIA' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='GEORGIA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = 'MA' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlstate <> 'MA' 
           AND StagHTL.htladdr2 = 'MASSACHUSETTS' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='MASSACHUSETTS', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = 'LA' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlstate <> 'LA' 
           AND StagHTL.htladdr2 = 'LOUISIANA' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='LOUISIANA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = 'AZ' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htlstate <> 'AZ' 
           AND StagHTL.htladdr2 = 'ARIZONA' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='ARIZONA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = NULL, 
           htlcountrycode = 'CA' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htladdr3 = 'CANADA' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CANADA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = NULL, 
           htlcountrycode = 'GB' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htladdr3 = 'UNITED KINGDOM' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='UNITED KINGDOM', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

----------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = NULL, 
           htlcountrycode = 'KR' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htladdr3 = 'SOUTH KOREA' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='SOUTH KOREA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

----------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlstate = NULL, 
           htlcountrycode = 'JP' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcountrycode = 'US' 
           AND StagHTL.htladdr3 = 'JAPAN' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='JAPAN', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = 'NEW DELHI' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname = 'DELHI' 
           AND StagHTL.htlcountrycode = 'IN' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='New Delhi', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------------------------------------------------

    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = 'NEW YORK', 
           htlstate = 'NY' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND ( StagHTL.htlcityname = 'NEW YORK NY' 
                  OR StagHTL.htlcityname = 'NEW YORK, NY' ) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='NEW YORK', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	
	/*********************************************************************************/
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    HtlCityName = 'WASHINGTON', 
           HtlState = 'DC' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname = 'WASHINGTON DC' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Washington DC', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = 'HERTOGENBOSCH' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
           AND StagHTL.htlpropertyname LIKE '%MOEVENPICK HOTEL%' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='HERTOGENBOSCH- MOEVENPICK HOTEL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	
--------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = 'NEW YORK' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
           AND StagHTL.htlpropertyname LIKE '%OAKWOOD CHELSEA%' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='NEW YORK-OAKWOOD CHELSEA', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	
-------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = 'NEW YORK' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
           AND StagHTL.htlpropertyname LIKE '%LONGACRE HOUSE%' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='NEW YORK-LONGACRE HOUSE', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	  	
-------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE StagHTL 
    SET    htlcityname = 'BARCELONA' 
    FROM   dba.hotel StagHTL 
           INNER JOIN dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHTL.IataNum
                        AND StagIH.RecordKey= StagHTL.RecordKey
                        AND StagIH.InvoiceDate = StagHTL.InvoiceDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
           AND StagHTL.htlpropertyname LIKE '%HOTLE PUNTA PALMA%' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='BARCELONA- HOTLE PUNTA PALMA', 
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