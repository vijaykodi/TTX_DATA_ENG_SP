CREATE PROCEDURE [dbo].[sp_IssueDate_NULL] (@BeginIssueDate DATETIME, 
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
						AND IH.ClientCode = CAR.ClientCode) ----added by jm
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
      @StepName='6-When Payment IssueDate is Null', 
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

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 