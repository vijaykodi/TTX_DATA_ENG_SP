CREATE PROCEDURE [dbo].[sp_FareCompare_Updates] (@BeginIssueDate DATETIME, 
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

---**************************************************************************************************
----FARECOMPARE UPDATES 
---*************************************************************************************************

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


    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

