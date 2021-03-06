/****** Object:  StoredProcedure [dbo].[sp_SVKCWT]    Script Date: 7/14/2015 8:14:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_svkcwt] @BeginIssueDate DATETIME, 
                                  @EndIssueDate   DATETIME 
AS 
    SET NOCOUNT ON 

    DECLARE @Iata         VARCHAR(50), 
            @ProcName     VARCHAR(50), 
            @TransStart   DATETIME, 
            @MaxImportDt  DATETIME, 
            @FirstInvDate DATETIME, 
            @LastInvDate  DATETIME, 
            @IataNum      VARCHAR(8) 

    -----  For Logging Prompts Only ------------------------------------- 
    SET @Iata = 'SVKCWT' 
    SET @ProcName = CONVERT(VARCHAR(50), Object_name(@@PROCID)) 
    --------------------------------------------------------------   
    -----  For SP PROMPTS ONLY ---------- 
    SET @IataNum = 'SVKCWT' 

    -----  *Note: CWT sends by Change Date 
    -----  So DO NOT use filter: and IH.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate
    SELECT @MaxImportDt = Max(IH.importdt) 
    FROM   dba.invoiceheader IH 
    WHERE  IH.iatanum = @IataNum 

    ----  and IH.InvoiceDate BETWEEN @BeginIssueDate and @EndIssueDate 
    PRINT @MaxImportDt 

    SELECT @FirstInvDate = Min(invoicedate), 
           @LastInvDate = Max(invoicedate) 
    FROM   dba.invoiceheader 
    WHERE  importdt = @MaxImportDt 
           AND iatanum = @IataNum 

    PRINT @FirstInvDate 

    PRINT @LastInvDate 

    ----------------------------------------------------------------   
    -- Any and all edits can be logged using sp_LogProcErrors  
    -- INSERT a row into the dbo.procedurelogs table using sp....when the procedure starts 
    -- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
    --  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run 
    --  @LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction 
    --  @StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'UPDATE ComRmks' OR 'INSERT Udef'
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
      @StepName='Stored Procedure Start', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    -------------------------------------------------------------------------------- 
    --------------------------------------------------- 
    ----  BEGIN CWT STANDARD  UPDATES  
    --------------------------------------------------- 
    -----------------------------------------------------------------------------------------
    ----  CWT STANDARD - Set Car IssueDate = InvoiceDetail IssueDate when not matching 
    -----------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE Car 
    SET    car.issuedate = ID.issuedate 
    FROM   dba.car CAR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = car.iatanum 
                        AND IH.clientcode = car.clientcode 
                        AND IH.recordkey = car.recordkey 
                        AND IH.invoicedate = car.invoicedate ) 
           INNER JOIN dba.invoicedetail ID 
                   ON ( ID.iatanum = car.iatanum 
                        AND ID.clientcode = car.clientcode 
                        AND ID.recordkey = car.recordkey 
                        AND ID.seqnum = car.seqnum ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CAR.iatanum = @IataNum 
           AND CAR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CAR.issuedate <> ID.issuedate 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='1-Car to ID.IssueDate', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    -----------------------------------------------------------------------------------------
    ----  CWT STANDARD - Set Hotel IssueDate = InvoiceDetail IssueDate when not matching 
    -----------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE HTL 
    SET    HTL.issuedate = ID.issuedate 
    FROM   dba.hotel HTL 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = HTL.iatanum 
                        AND IH.clientcode = HTL.clientcode 
                        AND IH.recordkey = HTL.recordkey 
                        AND IH.invoicedate = HTL.invoicedate ) 
           INNER JOIN dba.invoicedetail ID 
                   ON ( ID.iatanum = HTL.iatanum 
                        AND ID.clientcode = HTL.clientcode 
                        AND ID.recordkey = HTL.recordkey 
                        AND ID.seqnum = HTL.seqnum ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND HTL.iatanum = @IataNum 
           AND HTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND HTL.issuedate <> ID.issuedate 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='2-HTL to ID.IssueDate', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    -------------------------------------------------------------------------------------- 
    ----  CWT STANDARD Updates for CWT hotel chain codes based on dba.CWTHtlChains table 
    -------------------------------------------------------------------------------------- 
    ----  Questioned Sue and Nina - about if CWT still doing this and where to get data to populate table*****
    ----  Per Sue's comment in SF 00052946 on 12/29/2014: 
    ----  "As for the CWTHtlChains table, this was created a long time ago and really hasn't been maintained much.
    ----  CWT uses 3 character chain codes and this was used to convert them to the standard 2 characters.
    ----  Now that HNN is used for most clients, it is probably not necessary." 
    ----  Per SF 00052838 Pam S commented out this step after reviewing and analyzing data after CWTHtlChains table was loaded 
    ----  See comments in SF 00052838 on 1/26/2015. 
    --SET @TransStart = getdate() 
    --UPDATE HTL 
    --SET HTL.HtlChainCode = CWTCH.trxcode, 
    --HTL.HtlChainName = CWTCH.TRXChainName 
    --FROM dba.Hotel HTL 
    --INNER JOIN dba.CWTHtlChains CWTCH 
    --ON (HTL.HtlChainCode = CWTCH.CWTcode) 
    --INNER JOIN dba.InvoiceHeader IH 
    --ON     (HTL.Iatanum     = IH.Iatanum  
    --  and HTL.ClientCode  = IH.ClientCode 
    --  and HTL.Recordkey   = IH.Recordkey 
    --  and HTL.InvoiceDate = IH.InvoiceDate) 
    --WHERE IH.IMPORTDT  = @MaxImportDt 
    --  AND IH.Iatanum = @IataNum 
    --  AND IH.InvoiceDate between @FirstInvDate and @LastInvDate 
    --  AND HTL.IataNum = @IataNum 
    --  AND HTL.InvoiceDate between @FirstInvDate and @LastInvDate 
    --  AND len(HTL.HtlChainCode) > 2 
    --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CWT hotel chain codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
    ----------------------------------------------------------------------------------------------------- 
    ----  CWT STANADARD  - SET car chain code ZL1/ZL2 to ZL and update car chain name to National 
    ----------------------------------------------------------------------------------------------------- 
    SET @TransStart = Getdate() 

    UPDATE dba.Car 
    SET    CarChainName = 'NATIONAL CAR RENTAL', 
           CarChainCode = 'ZL' 
    FROM   dba.car CAR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = car.iatanum 
                        AND IH.clientcode = car.clientcode 
                        AND IH.recordkey = car.recordkey 
                        AND IH.invoicedate = car.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CAR.iatanum = @IataNum 
           AND CAR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CAR.carchainname IS NULL 
           AND CAR.cardailyrate IS NOT NULL 
           AND ( CAR.carchaincode = 'ZL1' 
                  OR CAR.carchaincode = 'ZL2' ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='3-CWT car chain code ZL1/ZL2 to ZL', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ------------------------------------------------------------------------------------- 
    ----  CWT STANDARD - For CarChainCode 'IM' set CarChainName = 'EUROPCAR SO. AFRICA' 
    ------------------------------------------------------------------------------------- 
    ---- Added step per SF Case 06079153 3/3/2015 Pam S 
    SET @TransStart = Getdate() 

    UPDATE dba.Car 
    SET    CarChainName = 'EUROPCAR SO. AFRICA' 
    FROM   dba.car CAR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = car.iatanum 
                        AND IH.clientcode = car.clientcode 
                        AND IH.recordkey = car.recordkey 
                        AND IH.invoicedate = car.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CAR.iatanum = @IataNum 
           AND CAR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CarChainCode = 'IM' 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='4-Update car', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --------------------------------------------------- 
    ----  END CWT STANDARD  UPDATES  
    --------------------------------------------------- 
    --------------------------------------------------------------------------------- 
    ----  BEGIN PREFERRED VENDORS for CAR and AIR 
    --------------------------------------------------------------------------------- 
    ----------------------------------- 
    ------  Preferred Car Vendor  
    ----------------------------------- 
    ------  For dba.Car 
    ------  based on CarChainCode per CLIENT SPECIFIC 
    --SET @TransStart = getdate() 
    --update dba.car 
    --set prefcarind = 'Y' 
    --FROM dba.Car CAR 
    --INNER JOIN dba.InvoiceHeader IH 
    --  ON (IH.IataNum     = CAR.IataNum 
    --  AND IH.ClientCode  = CAR.ClientCode 
    --  AND IH.RecordKey   = CAR.RecordKey   
    --  AND IH.InvoiceDate = CAR.InvoiceDate) 
    --WHERE IH.IMPORTDT = @MaxImportDt 
    --  AND IH.IataNum = @IataNum 
    --  AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate 
    --  AND CAR.IataNum = @IataNum 
    --  AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate 
    --  AND CAR.CarChainCode in ('') 
    --  AND CAR.PrefCarInd is null 
    --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Preferred Car Vendor',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
    ----------------------------------- 
    ------  Preferred Hotel Vendor -  
    -------------------------------------------------- 
    ------  For dba.Hotel 
    ------  based on HtlChainCode per CLIENT SPECIFIC 
    --------------------------------------------------- 
    ----  Update When the Hotel Chain is IC or RT set the preferred indicator to 'Y'  - case 00031149 - CB 02/14/2014
    SET @TransStart = Getdate() 

    UPDATE dba.hotel 
    SET    prefhtlind = 'Y' 
    FROM   dba.hotel HTL 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = HTL.iatanum 
                        AND IH.clientcode = HTL.clientcode 
                        AND IH.recordkey = HTL.recordkey 
                        AND IH.invoicedate = HTL.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND HTL.iatanum = @IataNum 
           AND HTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND HTL.htlchaincode IN ( 'IC', 'RT' ) 
           AND HTL.prefhtlind IS NULL 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='5-Preferred HTL Vendor', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----------------------------------- 
    ------  PREFERRED AIR VENDORS 
    ----------------------------------- 
    ------------------------------------------------------------------------------------------ 
    ------  For dba.InvoiceDetal 
    ------  based on ID.ValCarrierCode and sometimes IH.OrigCountry per CLIENT SPECIFIC 
    ------  So will need to either add a Case when statement or filter depending on complexity 
    ------------------------------------------------------------------------------------------ 
    ----  Update when the Airline is SK, EK, DL, UA, AB or CA set the preferred indicator to 'Y - case 00031149 - CB 02/14/2014
    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    preftktind = 'Y' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
           INNER JOIN dba.country CTRY 
                   ON ( IH.origcountry = CTRY.ctrycode ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.preftktind IS NULL 
           AND valcarriercode IN ( 'SK', 'EK', 'DL', 'UA', 
                                   'AB', 'CA' ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='6-ID.PrefTktInd- AIR Vendor', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    -------------------------------------------------------------------------------------------- 
    ------  For dba.Transeg 
    ------  based on TS.SegmentCarrierCode and sometimes IH.OrigCountry 
    ------  So will need to either add a Case when statement or filter depending on complexity 
    -------------------------------------------------------------------------------------------- 
    -----  Per SF case: 06124659 
    -----  While moving sp into Production db, noticed this step had been eliminated for Preferred Carriers
    -----   and should have been here so adding step Pam S 3/6/2015 
    SET @TransStart = Getdate() 

    UPDATE dba.transeg 
    SET    prefairind = 'Y' 
    FROM   dba.transeg TS 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = TS.iatanum 
                        AND IH.clientcode = TS.clientcode 
                        AND IH.recordkey = TS.recordkey 
                        AND IH.invoicedate = TS.invoicedate ) 
           INNER JOIN dba.country CTRY 
                   ON ( IH.origcountry = CTRY.ctrycode ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.iatanum = @IataNum 
           AND TS.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.prefairind IS NULL 
           AND TS.segmentcarriercode IN ( 'SK', 'EK', 'DL', 'UA', 
                                          'AB', 'CA' ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='7-TS.PrefAIRInd', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    --------------------------------------------------------------------------------- 
    ----  END PREFERRED  CAR and AIR Vendors 
    --------------------------------------------------------------------------------- 
    -------------------------------------------------------------------------------- 
    ----  BEGIN CLIENT SPECIFIC OTHER UPDATES TO INVOICE DETAIL 
    -------------------------------------------------------------------------------- 
    ---------------------------------------------- 
    ----  BEGIN ID.ProductTypes for SVKCWT 
    ---------------------------------------------- 
    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    producttype = 'A' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.vendortype IN ( 'BSP', 'NONBSP' ) 
           AND ( ID.producttype <> 'A' 
                  OR ID.producttype IS NULL ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='8-ProductType to A', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    producttype = 'R' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.vendortype = 'RAIL' 
           AND ( ID.producttype <> 'R' 
                  OR ID.producttype IS NULL ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='9-ProductType to R', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    producttype = 'H' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.vendortype = 'NONAIR' 
           AND ID.hotelnights IS NOT NULL 
           AND ( ID.producttype <> 'H' 
                  OR ID.producttype IS NULL ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='10-ProductType to H', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    producttype = 'C' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.vendortype = 'NONAIR' 
           AND ID.cardays IS NOT NULL 
           AND ( ID.producttype <> 'C' 
                  OR ID.producttype IS NULL ) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='11-ProductType to C', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ---------------------------------------------------------------- 
    ----  END ID.ProductTypes for CLEITN SPECIFIC -SVKCWT 
    ---------------------------------------------------------------- 
    ----------------------------------------------------------------- 
    ----  BEGIN ID.ONLINEBOOKING SYSTEM for CLIENT SPECIFIC -SVKCWT 
    ----------------------------------------------------------------- 
    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    onlinebookingsystem = CASE 
                                   WHEN ticketingagentid = 'MZON' THEN 'ONLINE' 
                                   ELSE 'OFFLINE' 
                                 END 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='12-Onlinebookingsystem-TicketAgentID', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----  update online booking - IP 29706 
    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    onlinebookingsystem = 'ONLINE' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.onlinebookingsystem IS NOT NULL 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='13-Onlinebookingsystem not null', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----  update online booking - IP 29706 
    SET @TransStart = Getdate() 

    UPDATE dba.invoicedetail 
    SET    onlinebookingsystem = 'OFFLINE' 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.onlinebookingsystem IS NULL 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='14-Onlinebookingsystem is null', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----------------------------------------------------------------- 
    ----  END ID.ONLINEBOOKING SYSTEM for CLIENT SPECIFIC -SVKCWT 
    ----------------------------------------------------------------- 
    -------------------------------------------------------------------------------- 
    ----  END CLIENT SPECIFIC OTHER UPDATES TO INVOICE DETAIL 
    -------------------------------------------------------------------------------- 
    ---------------------------------- 
    ----  STANDARD CLASS TO CABIN 
    ---------------------------------- 
    ---------------------------------------------------------------------------------------------- 
    ----  Before Insert and Updates to ComRmks for Text14 Highest Class 
    ---------------------------------------------------------------------------------------------- 
    ----- From InvoiceDetail into Production Class to Cabin: 
    SET @TransStart = Getdate() 

    INSERT INTO dba.classtocabin 
    SELECT DISTINCT Substring(ID.valcarriercode, 1, 3), 
                    Substring(ID.servicecategory, 1, 1), 
                    'ECONOMY', 
                    ID.internationalind, 
                    'Y', 
                    NULL, 
                    NULL 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.valcarriercode IS NOT NULL 
           AND ID.servicecategory IS NOT NULL 
           AND ID.vendortype IN ( 'BSP', 'NONBSP', 'RAIL' ) 
           AND Substring(ID.valcarriercode, 1, 3) 
               + Substring(ID.servicecategory, 1, 1) 
               + ID.internationalind NOT IN (SELECT DISTINCT 
                                            carriercode + classofservice 
                                            + internationalind 
                                             FROM   .dba.classtocabin) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='15-ClassToCabin FROM InvoiceDetalil', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----------------------------------------------------- 
    ----  From Transeg into Production Class to Cabin: 
    ----------------------------------------------------- 
    SET @TransStart = Getdate() 

    INSERT INTO .dba.classtocabin 
    SELECT DISTINCT Substring(TS.segmentcarriercode, 1, 3), 
                    Substring(TS.classofservice, 1, 1), 
                    'ECONOMY', 
                    TS.seginternationalind, 
                    'Y', 
                    NULL, 
                    NULL 
    FROM   dba.transeg TS 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = TS.iatanum 
                        AND IH.clientcode = TS.clientcode 
                        AND IH.recordkey = TS.recordkey 
                        AND IH.invoicedate = TS.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.iatanum = @IataNum 
           AND TS.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.segmentcarriercode IS NOT NULL 
           AND TS.classofservice IS NOT NULL 
           AND Substring(TS.segmentcarriercode, 1, 3) 
               + Substring(TS.classofservice, 1, 1) 
               + TS.seginternationalind NOT IN (SELECT DISTINCT 
                                               carriercode + classofservice 
                                               + internationalind 
                                                FROM   .dba.classtocabin) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='16-ClassToCabin from Transeg', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    -------------------------------------------------------------------------- 
    --------  Begin DELETE AND INSERT ComRmks ----- 
    -------------------------------------------------------------------------- 
    ----  **Note DO NOT ADD: 
    ----    these JOINS:  
    ----      AND IH.InvoiceDate = CR.InvoiceDate 
    ----      AND IH.ClientCode = CR.ClientCode 
    ----    or FILTER: 
    ----      AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate 
    ----    in case InvoiceDates or ClientCodes changed with newly arrived data 
    ----   ** Only match on Iatanum AND Recordkey to delete 
    SET @TransStart = Getdate() 

    DELETE dba.comrmks 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.recordkey = CR.recordkey ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='17-Delete DBA.comrmks', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    INSERT INTO dba.comrmks 
                (recordkey, 
                 iatanum, 
                 seqnum, 
                 clientcode, 
                 invoicedate, 
                 issuedate) 
    SELECT DISTINCT ID.recordkey, 
                    ID.iatanum, 
                    ID.seqnum, 
                    ID.clientcode, 
                    ID.invoicedate, 
                    ID.issuedate 
    FROM   dba.invoicedetail ID 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = ID.iatanum 
                        AND IH.clientcode = ID.clientcode 
                        AND IH.recordkey = ID.recordkey 
                        AND IH.invoicedate = ID.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.iatanum = @IataNum 
           AND ID.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND ID.recordkey + ID.iatanum 
               + CONVERT(VARCHAR, ID.seqnum) NOT IN (SELECT CR.recordkey + CR.iatanum + CONVERT(VARCHAR, CR.seqnum) 
                                                     FROM   dba.comrmks CR 
                                                     WHERE 
													 CR.iatanum = @IataNum) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='18-Insert dba.ComRmks', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----------------------------------------------------------------------- 
    ---------------------------------------------------------------------- 
    ----  ComRmks to 'Not Provided' prior to updating with agency data 
    ---------------------------------------------------------------------- 
    SET @TransStart = Getdate() 

    UPDATE dba.comrmks 
    SET    text1 = CASE 
                     WHEN text1 IS NULL THEN 'Not Provided' 
                     ELSE text1 
                   END, 
           text2 = CASE 
                     WHEN text2 IS NULL THEN 'Not Provided' 
                     ELSE text2 
                   END, 
           text3 = CASE 
                     WHEN text3 IS NULL THEN 'Not Provided' 
                     ELSE text3 
                   END, 
           text4 = CASE 
                     WHEN text4 IS NULL THEN 'Not Provided' 
                     ELSE text4 
                   END, 
           text5 = CASE 
                     WHEN text5 IS NULL THEN 'Not Provided' 
                     ELSE text5 
                   END, 
           text6 = CASE 
                     WHEN text6 IS NULL THEN 'Not Provided' 
                     ELSE text6 
                   END, 
           text7 = CASE 
                     WHEN text7 IS NULL THEN 'Not Provided' 
                     ELSE text7 
                   END, 
           text8 = CASE 
                     WHEN text8 IS NULL THEN 'Not Provided' 
                     ELSE text8 
                   END, 
           text9 = CASE 
                     WHEN text9 IS NULL THEN 'Not Provided' 
                     ELSE text9 
                   END, 
           text10 = CASE 
                      WHEN text10 IS NULL THEN 'Not Provided' 
                      ELSE text10 
                    END, 
           text11 = CASE 
                      WHEN text11 IS NULL THEN 'Not Provided' 
                      ELSE text11 
                    END, 
           text12 = CASE 
                      WHEN text12 IS NULL THEN 'Not Provided' 
                      ELSE text12 
                    END, 
           text13 = CASE 
                      WHEN text13 IS NULL THEN 'Not Provided' 
                      ELSE text13 
                    END, 
           text14 = CASE 
                      WHEN text14 IS NULL THEN 'Not Provided' 
                      ELSE text14 
                    END, 
           text15 = CASE 
                      WHEN text15 IS NULL THEN 'Not Provided' 
                      ELSE text15 
                    END, 
           text16 = CASE 
                      WHEN text16 IS NULL THEN 'Not Provided' 
                      ELSE text16 
                    END, 
           text17 = CASE 
                      WHEN text17 IS NULL THEN 'Not Provided' 
                      ELSE text17 
                    END, 
           text18 = CASE 
                      WHEN text18 IS NULL THEN 'Not Provided' 
                      ELSE text18 
                    END, 
           text19 = CASE 
                      WHEN text19 IS NULL THEN 'Not Provided' 
                      ELSE text19 
                    END, 
           text20 = CASE 
                      WHEN text20 IS NULL THEN 'Not Provided' 
                      ELSE text20 
                    END, 
           text21 = CASE 
                      WHEN text21 IS NULL THEN 'Not Provided' 
                      ELSE text21 
                    END, 
           text22 = CASE 
                      WHEN text22 IS NULL THEN 'Not Provided' 
                      ELSE text22 
                    END, 
           text23 = CASE 
                      WHEN text23 IS NULL THEN 'Not Provided' 
                      ELSE text23 
                    END, 
           text24 = CASE 
                      WHEN text24 IS NULL THEN 'Not Provided' 
                      ELSE text24 
                    END, 
           text48 = CASE 
                      WHEN text48 IS NULL THEN 'Not Provided' 
                      ELSE text48 
                    END, 
           text50 = CASE 
                      WHEN text50 IS NULL THEN 'Not Provided' 
                      ELSE text50 
                    END 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='19-SET text fields to Not Provided', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

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
    -------------------------------------------------------- 
    ----  STANDARD Text2 with POS from InvoiceHeader OrigCountry 
    -------------------------------------------------------- 
    SET @TransStart = Getdate() 

    UPDATE CR 
    SET    Text2 = CASE 
                     WHEN IH.origcountry IS NULL THEN 'Not Provided' 
                     ELSE IH.origcountry 
                   END 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='20-Text2_IH POS_Ctry', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----------------------------------------------------------------- 
    -----     End Standard ComRmks Mappings       
    ----------------------------------------------------------------- 
    ----------------------------------------------------------------- 
    -----     Begin client Specific ComRmks Mappings     
    ----------------------------------------------------------------- 
    ------------------------------------------------------------------------------------------------------------ 
    ----  Text1 for EmployeeID  
    ----  Text50 for EmployeeID Raw Data as received without substrings other than 1,150 to fit in text field
    -------------------------------------------------------------------------------------------------------------- 
    ---------------------------------------------------------------------------------------- 
    ----  Update Text8 with COST CENTER - IP 29706 
    SET @TransStart = Getdate() 

    UPDATE dba.comrmks 
    SET    text8 = Substring(UD.udefdata, 1, 150) 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
           INNER JOIN dba.udef UD 
                   ON ( UD.iatanum = CR.iatanum 
                        AND UD.clientcode = CR.clientcode 
                        AND UD.recordkey = CR.recordkey 
                        AND UD.seqnum = CR.seqnum 
                        AND UD.invoicedate = CR.invoicedate 
                        AND UD.issuedate = CR.issuedate ) 
    WHERE  IH.iatanum = @IataNum 
           AND IH.importdt = @MaxImportDt 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.text8 = 'Not Provided' 
           AND UD.udefnum = CASE 
                              WHEN ih.origcountry = 'IN' THEN '1' 
                              WHEN ih.origcountry = 'CL' THEN '2' 
                              WHEN ih.origcountry = 'PE' THEN '3' 
                            END 
           AND UD.udefdata IS NOT NULL 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='21-CR.Text8_CostCenter', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ----  Removing following step from old sp as 'Not Provided' being used mow as a standard 
    ----    See SF Case 06124659 3/6/2015 Pam S 
    --SET @TransStart = getdate() 
    ----Updated Text8 to Unknown where NULL - IP - #32954 
    --UPDATE cr 
    --SET cr.text8 = 'Unknown' 
    --FROM dba.ComRmks cr 
    --WHERE cr.text8 IS NULL 
    --AND cr.IataNum = 'SVKCWT' 
    --and cr.invoicedate between @BeginIssueDate and @EndIssueDate 
    --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CR.Text8_costcenter to Unknown where NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
    ----------------------------------------------------------------- 
    ------  Text14 - STANDARD Highest Cabin  
    ------  Only if Client Purchased - Verify with Implementation Consultant 
    ----------------------------------------------------------------- 
    ----  Note: InvoiceDetail.ServiceCategory is first segment's class of service not highest cabin flown
    ----------------------------- 
    ------  1st) For First class 
    ----------------------------- 
    ----  Old sp had filter and ts.farebasis not like '%UP%' --See SF Case 06124659 3/6/2015 Pam S where moved from Staging to Prod. 
    SET @TransStart = Getdate() 

    UPDATE CR 
    SET    CR.text14 = CTC.domcabin 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
           INNER JOIN dba.transeg TS 
                   ON ( CR.iatanum = TS.iatanum 
                        AND CR.clientcode = TS.clientcode 
                        AND CR.recordkey = TS.recordkey 
                        AND CR.seqnum = TS.seqnum ) 
           INNER JOIN dba.classtocabin CTC 
                   ON ( TS.minsegmentcarriercode = CTC.carriercode 
                        AND TS.minclassofservice = CTC.classofservice 
                        AND TS.mininternationalind = CTC.internationalind ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.iatanum = @IataNum 
           AND TS.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CTC.domcabin = 'First' 
           AND TS.farebasis NOT LIKE '%UP%' 

    ----AND CR.text14 = 'Not Provided' 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='22-Text14 Highest Cabin = FIRST', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    -------------------------------- 
    ----  2nd) For Business Class 
    -------------------------------- 
    ----  Old sp had filter and ts.farebasis not like '%UP%' --See SF Case 06124659 3/6/2015 Pam S where moved from Staging to Prod. 
    SET @TransStart = Getdate() 

    UPDATE CR 
    SET    CR.text14 = CTC.domcabin 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
           INNER JOIN dba.transeg TS 
                   ON ( CR.iatanum = TS.iatanum 
                        AND CR.clientcode = TS.clientcode 
                        AND CR.recordkey = TS.recordkey 
                        AND CR.seqnum = TS.seqnum ) 
           INNER JOIN dba.classtocabin CTC 
                   ON ( TS.minsegmentcarriercode = CTC.carriercode 
                        AND TS.minclassofservice = CTC.classofservice 
                        AND TS.mininternationalind = CTC.internationalind ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.iatanum = @IataNum 
           AND TS.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CTC.domcabin = 'Business' 
           AND TS.farebasis NOT LIKE '%UP%' 

    ----AND CR.text14 = 'Not Provided' 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='23-Text14 Highest Cabin = BUSINESS', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    ------  3rd) Then all others 
    ----  Old sp had filter and ts.farebasis like '%UP%' --See SF Case 06124659 3/6/2015 Pam S where moved from Staging to Prod. 
    SET @TransStart = Getdate() 

    UPDATE CR 
    SET    CR.text14 = 'ECONOMY' 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
           INNER JOIN dba.transeg TS 
                   ON ( CR.iatanum = TS.iatanum 
                        AND CR.clientcode = TS.clientcode 
                        AND CR.recordkey = TS.recordkey 
                        AND CR.seqnum = TS.seqnum ) 
           INNER JOIN dba.classtocabin CTC 
                   ON ( TS.minsegmentcarriercode = CTC.carriercode 
                        AND TS.minclassofservice = CTC.classofservice 
                        AND TS.mininternationalind = CTC.internationalind ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.iatanum = @IataNum 
           AND TS.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.farebasis LIKE '%UP%' 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='24-Text14 = DomCabin for YUP', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    UPDATE CR 
    SET    CR.text14 = CTC.domcabin 
    FROM   dba.comrmks CR 
           INNER JOIN dba.invoiceheader IH 
                   ON ( IH.iatanum = CR.iatanum 
                        AND IH.clientcode = CR.clientcode 
                        AND IH.recordkey = CR.recordkey 
                        AND IH.invoicedate = CR.invoicedate ) 
           INNER JOIN dba.transeg TS 
                   ON ( CR.iatanum = TS.iatanum 
                        AND CR.clientcode = TS.clientcode 
                        AND CR.recordkey = TS.recordkey 
                        AND CR.seqnum = TS.seqnum ) 
           INNER JOIN dba.classtocabin CTC 
                   ON ( TS.minsegmentcarriercode = CTC.carriercode 
                        AND TS.minclassofservice = CTC.classofservice 
                        AND TS.mininternationalind = CTC.internationalind ) 
    WHERE  IH.importdt = @MaxImportDt 
           AND IH.iatanum = @IataNum 
           AND IH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND CR.iatanum = @IataNum 
           AND CR.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
           AND TS.iatanum = @IataNum 
           AND TS.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 

    ----AND CR.text14 = 'Not Provided' 
    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='25-Highest Cabin = all others', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

	EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@BeginIssueDate, 
      @EndDate=@EndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

		
GO
