CREATE PROCEDURE [dbo].[sp_VendorType_Updates] (@BeginIssueDate DATETIME, 
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

	UPDATE dba.invoicedetail 
	SET    vendortype = 'RAIL' 
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
		   AND ID.vendortype NOT IN ( 'RAIL' ) 
		   OR ID.vendorname LIKE '%amtrak%' 
				 
	EXEC dbo.Sp_logprocerrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='Vendortype RAIL by Name', 
	  @BeginDate=@BeginIssueDate, 
	  @EndDate=@EndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 

--------------------
--RAIL
--------------------
	SET @TransStart = getdate()
	
	UPDATE ID 
	SET    ID.VendorType = 'RAIL' 
	FROM   dba.InvoiceDetail ID 
		   INNER JOIN dba.InvoiceHeader IH 
				   ON ( IH.IataNum = ID.IataNum 
						AND IH.ClientCode = ID.ClientCode 
						AND IH.recordkey = ID.recordkey 
						AND IH.InvoiceDate = ID.InvoiceDate ) 
	WHERE  IH.ImportDt = @MaxImportDt 
		   AND IH.IataNum = @IataNum 
		   AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
		   AND ID.IataNum = @IataNum 
		   AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
		   AND ID.VendorType NOT IN ( 'RAIL' ) 
		   AND ID.ValCarrierCode in ('2V')

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='Update VendorType to RAIL where ValCarrierCodes in 2V', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 


/******************************************************************  
    -----END SVendorType Updates--------------------  
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
