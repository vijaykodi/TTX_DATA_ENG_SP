/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 8:44:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Trent Watkins
-- Create date: 5/19/2011
-- Last update: 8/5/2011
-- Description:	Standardized logging and error handling for stored procedures
-- =============================================
CREATE PROCEDURE [dbo].[sp_LogProcErrors] (
	-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
	@ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount int, -- **REQUIRED** Total number of affected rows
	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error int, -- Error Trapping for this procedure
	@LogRowCount int, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message varchar(255), -- The Error Message for this Procedure
	@Error_Type int, -- Used to track where errors are raised inside this procedure
	@Error_Loc int -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [datetime] NOT NULL,
			[LogEnd] [datetime] NOT NULL,
			[RunByUSER] [char](30) NOT NULL,
			[StepName] [varchar](50) NOT NULL,
			[BeginIssueDate] [datetime] NULL,
			[EndIssueDate] [datetime] NULL,
			[IataNum] [varchar](50) NULL,
			[RowCount] [int] NOT NULL,
			[Error] [int] NOT NULL,
			[ErrorMessage] [nvarchar](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql nvarchar(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
	END

INSERT INTO dba.ProcedureLogs (
		ProcedureName
		,LogStart
		,LogEnd
		,RunByUSER
		,StepName
		,BeginIssueDate
		,EndIssueDate
		,IataNum
		,[RowCount]
		,Error
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GetDate()
		,@RunByUSER
		,@StepName
		,@BeginDate
		,@EndDate
		,@IataNum
		,@RowCount
		,@ERR
		,@Error_Message

IF @ERR <> 0
	BEGIN
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END		

GO

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_SVKCWT]    Script Date: 7/7/2015 8:44:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_SVKCWT] @BeginIssueDate DATETIME, 
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

ALTER AUTHORIZATION ON [dbo].[sp_SVKCWT] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 8:44:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](50) NOT NULL,
	[BeginIssueDate] [datetime] NULL,
	[EndIssueDate] [datetime] NULL,
	[IataNum] [varchar](50) NULL,
	[RowCount] [int] NOT NULL,
	[Error] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 8:44:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNum] [varchar](15) NULL,
	[TicketingBranch] [varchar](10) NULL,
	[BookingBranch] [varchar](10) NULL,
	[TtlInvoiceAmt] [float] NULL,
	[TtlTaxAmt] [float] NULL,
	[TtlCommissionAmt] [float] NULL,
	[CurrCode] [varchar](30) NULL,
	[OrigCountry] [varchar](5) NULL,
	[SalesAgentID] [varchar](10) NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[InvoiceHeader] ADD [CCExp] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CCApprovalCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [GDSCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [BackOfficeID] [varchar](20) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [IMPORTDT] [datetime] NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [TtlCO2Emissions] [float] NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CCLastFour] [varchar](4) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CLIQCID] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CLIQUSER] [varchar](100) NULL
 CONSTRAINT [PK_InvoiceHeader] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 8:44:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[InvoiceType] [varchar](10) NULL,
	[InvoiceTypeDescription] [varchar](255) NULL,
	[DocumentNumber] [varchar](15) NULL,
	[EndDocNumber] [varchar](3) NULL,
	[VendorNumber] [varchar](15) NULL,
	[VendorType] [varchar](10) NULL,
	[ValCarrierNum] [smallint] NULL,
	[ValCarrierCode] [varchar](6) NULL,
	[VendorName] [varchar](40) NULL,
	[BookingDate] [datetime] NULL,
	[ServiceDate] [datetime] NULL,
	[ServiceCategory] [varchar](8) NULL,
	[InternationalInd] [varchar](1) NULL,
	[ServiceFee] [float] NULL,
	[InvoiceAmt] [float] NULL,
	[TaxAmt] [float] NULL,
	[TotalAmt] [float] NULL,
	[CommissionAmt] [float] NULL,
	[CancelPenaltyAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[FareCompare1] [float] NULL,
	[ReasonCode1] [varchar](6) NULL,
	[FareCompare2] [float] NULL,
	[ReasonCode2] [varchar](6) NULL,
	[FareCompare3] [float] NULL,
	[ReasonCode3] [varchar](6) NULL,
	[FareCompare4] [float] NULL,
	[ReasonCode4] [varchar](6) NULL,
	[Mileage] [float] NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceDetail] ADD [Routing] [varchar](120) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [DaysAdvPurch] [smallint] NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[InvoiceDetail] ADD [AdvPurchGroup] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [TrueTktCount] [int] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [TripLength] [float] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ExchangeInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [OrigExchTktNum] [varchar](15) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [Department] [varchar](40) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ETktInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ProductType] [varchar](20) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [TourCode] [varchar](15) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [EndorsementRemarks] [varchar](60) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [FareCalcLine] [varchar](255) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [GroupMult] [smallint] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [OneWayInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [PrefTktInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [HotelNights] [float] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CarDays] [float] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [OnlineBookingSystem] [varchar](20) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [AccommodationType] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [AccommodationDescription] [varchar](255) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ServiceType] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ServiceDescription] [varchar](255) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ShipHotelName] [varchar](255) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [Remarks1] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [Remarks2] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [Remarks3] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [Remarks4] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [Remarks5] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [IntlSalesInd] [varchar](4) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [MatchedInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [MatchedFields] [varchar](255) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [RefundInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [OriginalInvoiceNum] [varchar](15) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [BranchIataNum] [varchar](8) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [GDSRecordLocator] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [BookingAgentID] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [TicketingAgentID] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [OriginCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [DestinationCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [TktCO2Emissions] [float] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CCMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CCMatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ACQMatchedInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ACQMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ACQMatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CarrierString] [varchar](50) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [ClassString] [varchar](50) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CRMatchedInd] [varchar](1) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CRMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [CRMatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [LastImportDt] [datetime] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [GolUpdateDt] [datetime] NULL
ALTER TABLE [dba].[InvoiceDetail] ADD [OrigTktAmt] [float] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceDetail] ADD [TktWasExchangedInd] [varchar](1) NULL
 CONSTRAINT [PK_InvoiceDetail] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Hotel]    Script Date: 7/7/2015 8:44:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Hotel](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[HtlSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[HtlChainCode] [varchar](6) NULL,
	[HtlChainName] [varchar](40) NULL,
	[GDSPropertyNum] [varchar](15) NULL,
	[HtlPropertyName] [varchar](40) NULL,
	[HtlAddr1] [varchar](40) NULL,
	[HtlAddr2] [varchar](40) NULL,
	[HtlAddr3] [varchar](40) NULL,
	[HtlCityCode] [varchar](10) NULL,
	[HtlCityName] [varchar](25) NULL,
	[HtlState] [varchar](20) NULL,
	[HtlPostalCode] [varchar](15) NULL,
	[HtlCountryCode] [varchar](5) NULL,
	[HtlPhone] [varchar](20) NULL,
	[InternationalInd] [varchar](1) NULL,
	[CheckinDate] [datetime] NULL,
	[CheckoutDate] [datetime] NULL,
	[NumNights] [smallint] NULL,
	[NumRooms] [smallint] NULL,
	[HtlQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[HtlDailyRate] [float] NULL,
	[TtlHtlCost] [float] NULL,
	[RoomType] [varchar](6) NULL,
	[HtlRateCat] [varchar](10) NULL,
	[HtlCompareRate1] [float] NULL,
	[HtlReasonCode1] [varchar](6) NULL,
	[HtlCompareRate2] [float] NULL,
	[HtlReasonCode2] [varchar](6) NULL,
	[HtlCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefHtlInd] [varchar](1) NULL,
	[HtlConfNum] [varchar](30) NULL,
	[FreqGuestProgram] [varchar](13) NULL,
	[HtlStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[HtlCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[MasterId] [int] NULL,
	[CO2Emissions] [float] NULL,
	[MilesFromAirport] [float] NULL,
	[GroundTransCO2] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Hotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Country]    Script Date: 7/7/2015 8:44:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Country](
	[CtryCode] [varchar](5) NULL,
	[CtryName] [varchar](25) NULL,
	[IntlDomCode] [varchar](1) NULL,
	[ContinentCode] [varchar](2) NULL,
	[PhnCode] [varchar](4) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[TSLATEST] [datetime] NULL,
	[RegionCode] [varchar](10) NULL,
	[RegionName] [varchar](20) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Country] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/7/2015 8:44:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ComRmks](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[Text1] [varchar](150) NULL,
	[Text2] [varchar](150) NULL,
	[Text3] [varchar](150) NULL,
	[Text4] [varchar](150) NULL,
	[Text5] [varchar](150) NULL,
	[Text6] [varchar](150) NULL,
	[Text7] [varchar](150) NULL,
	[Text8] [varchar](150) NULL,
	[Text9] [varchar](150) NULL,
	[Text10] [varchar](150) NULL,
	[Text11] [varchar](150) NULL,
	[Text12] [varchar](150) NULL,
	[Text13] [varchar](150) NULL,
	[Text14] [varchar](150) NULL,
	[Text15] [varchar](150) NULL,
	[Text16] [varchar](150) NULL,
	[Text17] [varchar](150) NULL,
	[Text18] [varchar](150) NULL,
	[Text19] [varchar](150) NULL,
	[Text20] [varchar](150) NULL,
	[Text21] [varchar](150) NULL,
	[Text22] [varchar](150) NULL,
	[Text23] [varchar](150) NULL,
	[Text24] [varchar](150) NULL,
	[Text25] [varchar](150) NULL,
	[Text26] [varchar](150) NULL,
	[Text27] [varchar](150) NULL,
	[Text28] [varchar](150) NULL,
	[Text29] [varchar](150) NULL,
	[Text30] [varchar](150) NULL,
	[Text31] [varchar](150) NULL,
	[Text32] [varchar](150) NULL,
	[Text33] [varchar](150) NULL,
	[Text34] [varchar](150) NULL,
	[Text35] [varchar](150) NULL,
	[Text36] [varchar](150) NULL,
	[Text37] [varchar](150) NULL,
	[Text38] [varchar](150) NULL,
	[Text39] [varchar](150) NULL,
	[Text40] [varchar](150) NULL,
	[Text41] [varchar](150) NULL,
	[Text42] [varchar](150) NULL,
	[Text43] [varchar](150) NULL,
	[Text44] [varchar](150) NULL,
	[Text45] [varchar](150) NULL,
	[Text46] [varchar](150) NULL,
	[Text47] [varchar](150) NULL,
	[Text48] [varchar](150) NULL,
	[Text49] [varchar](150) NULL,
	[Text50] [varchar](150) NULL,
	[Num1] [float] NULL,
	[Num2] [float] NULL,
	[Num3] [float] NULL,
	[Num4] [float] NULL,
	[Num5] [float] NULL,
	[Num6] [float] NULL,
	[Num7] [float] NULL,
	[Num8] [float] NULL,
	[Num9] [float] NULL,
	[Num10] [float] NULL,
	[Num11] [float] NULL,
	[Num12] [float] NULL,
	[Num13] [float] NULL,
	[Num14] [float] NULL,
	[Num15] [float] NULL,
	[Num16] [float] NULL,
	[Num17] [float] NULL,
	[Num18] [float] NULL,
	[Num19] [float] NULL,
	[Num20] [float] NULL,
	[Num21] [float] NULL,
	[Num22] [float] NULL,
	[Num23] [float] NULL,
	[Num24] [float] NULL,
	[Num25] [float] NULL,
	[Num26] [float] NULL,
	[Num27] [float] NULL,
	[Num28] [float] NULL,
	[Num29] [float] NULL,
	[Num30] [float] NULL,
	[Int1] [int] NULL,
	[Int2] [int] NULL,
	[Int3] [int] NULL,
	[Int4] [int] NULL,
	[Int5] [int] NULL,
	[Int6] [int] NULL,
	[Int7] [int] NULL,
	[Int8] [int] NULL,
	[Int9] [int] NULL,
	[Int10] [int] NULL,
	[Int11] [int] NULL,
	[Int12] [int] NULL,
	[Int13] [int] NULL,
	[Int14] [int] NULL,
	[Int15] [int] NULL,
	[Int16] [int] NULL,
	[Int17] [int] NULL,
	[Int18] [int] NULL,
	[Int19] [int] NULL,
	[Int20] [int] NULL,
 CONSTRAINT [PK_ComRmks] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ClassToCabin]    Script Date: 7/7/2015 8:44:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ClassToCabin](
	[CarrierCode] [varchar](3) NOT NULL,
	[ClassOfService] [varchar](1) NOT NULL,
	[DomCabin] [varchar](20) NOT NULL,
	[InternationalInd] [varchar](1) NOT NULL,
	[NewRecord] [char](1) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_ClassToCabin] PRIMARY KEY CLUSTERED 
(
	[CarrierCode] ASC,
	[ClassOfService] ASC,
	[DomCabin] ASC,
	[InternationalInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ClassToCabin] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Car]    Script Date: 7/7/2015 8:44:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Car](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[CarSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[CarType] [varchar](6) NULL,
	[CarChainCode] [varchar](6) NULL,
	[CarChainName] [varchar](20) NULL,
	[CarCityCode] [varchar](10) NULL,
	[CarCityName] [varchar](25) NULL,
	[InternationalInd] [varchar](1) NULL,
	[PickupDate] [datetime] NULL,
	[DropoffDate] [datetime] NULL,
	[CarDropoffCityCode] [varchar](10) NULL,
	[NumDays] [smallint] NULL,
	[NumCars] [smallint] NULL,
	[CarQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[CarDailyRate] [float] NULL,
	[TtlCarCost] [float] NULL,
	[CarRateCat] [varchar](10) NULL,
	[CarCompareRate1] [float] NULL,
	[CarReasonCode1] [varchar](6) NULL,
	[CarCompareRate2] [float] NULL,
	[CarReasonCode2] [varchar](6) NULL,
	[CarCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefCarInd] [varchar](1) NULL,
	[CarConfNum] [varchar](30) NULL,
	[FreqRenterProgram] [varchar](13) NULL,
	[CarStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[CarCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[CarDropOffCityName] [varchar](50) NULL,
	[CO2Emissions] [float] NULL,
 CONSTRAINT [PK_Car] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Car] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Udef]    Script Date: 7/7/2015 8:44:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Udef](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[UdefNum] [smallint] NOT NULL,
	[UdefType] [varchar](20) NULL,
	[UdefData] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Udef] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 8:44:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[OriginCityCode] [varchar](10) NULL,
	[SegmentCarrierCode] [varchar](3) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[CodeShareCarrierCode] [varchar](3) NULL,
	[EquipmentCode] [varchar](10) NULL,
	[PrefAirInd] [varchar](1) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[FlightNum] [varchar](15) NULL,
	[ClassOfService] [varchar](8) NULL,
	[FareBasis] [varchar](30) NULL,
	[TktDesignator] [varchar](15) NULL,
	[ConnectionInd] [varchar](1) NULL,
	[StopOverTime] [int] NULL,
	[FrequentFlyerNum] [varchar](15) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SEGDestCityCode] [varchar](10) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[SEGCO2Emissions] [float] NULL,
	[NOXCO2Emissions] [float] NULL,
	[MINCO2Emissions] [float] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[TtlSeats] [int] NULL,
	[SegTrueTktCount] [int] NULL,
	[YieldInd] [varchar](1) NULL,
	[YieldAmt] [float] NULL,
	[YieldDatePosted] [datetime] NULL,
 CONSTRAINT [PK_TranSeg] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 8:45:04 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 8:45:04 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [HotelI1]    Script Date: 7/7/2015 8:45:04 PM ******/
CREATE CLUSTERED INDEX [HotelI1] ON [dba].[Hotel]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/7/2015 8:45:05 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [dba].[ComRmks]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/7/2015 8:45:05 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [dba].[Car]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [UdefI1]    Script Date: 7/7/2015 8:45:06 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 8:45:06 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/7/2015 8:45:07 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [dba].[InvoiceHeader]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/7/2015 8:45:07 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [dba].[InvoiceHeader]
(
	[BookingBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 8:45:07 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [INvoiceDetailI2]    Script Date: 7/7/2015 8:45:07 PM ******/
CREATE NONCLUSTERED INDEX [INvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI3]    Script Date: 7/7/2015 8:45:07 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI3] ON [dba].[InvoiceDetail]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI5]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI5] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [dba].[Hotel]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [HotelPX]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CountryPX]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CountryPX] ON [dba].[Country]
(
	[CtryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON [PRIMARY]
GO

/****** Object:  Index [ComRmksI2]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI2] ON [dba].[ComRmks]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI3]    Script Date: 7/7/2015 8:45:08 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI3] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI4]    Script Date: 7/7/2015 8:45:09 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI4] ON [dba].[ComRmks]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CarI2]    Script Date: 7/7/2015 8:45:09 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [dba].[Car]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI3]    Script Date: 7/7/2015 8:45:09 PM ******/
CREATE NONCLUSTERED INDEX [CarI3] ON [dba].[Car]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CarI6]    Script Date: 7/7/2015 8:45:09 PM ******/
CREATE NONCLUSTERED INDEX [CarI6] ON [dba].[Car]
(
	[PickupDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/7/2015 8:45:09 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [dba].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI3]    Script Date: 7/7/2015 8:45:09 PM ******/
CREATE NONCLUSTERED INDEX [UdefI3] ON [dba].[Udef]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI4]    Script Date: 7/7/2015 8:45:10 PM ******/
CREATE NONCLUSTERED INDEX [UdefI4] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI5]    Script Date: 7/7/2015 8:45:10 PM ******/
CREATE NONCLUSTERED INDEX [UdefI5] ON [dba].[Udef]
(
	[UdefNum] ASC,
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefPX]    Script Date: 7/7/2015 8:45:10 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [dba].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC,
	[UdefType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [TransegI2]    Script Date: 7/7/2015 8:45:10 PM ******/
CREATE NONCLUSTERED INDEX [TransegI2] ON [dba].[TranSeg]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

