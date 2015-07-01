/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Payment' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Payment' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='MasterFareClassRef_VW' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceHeader' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceHeader' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceDetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceDetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Hotel' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Hotel' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='ComRmks' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='ComRmks' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='client' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='client' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Car' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Car' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxsasql03']/Database[@Name='ttxcentral']/UnresolvedEntity[@Name='uszipcodesdeluxe' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='udef' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Udef' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Transeg' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='TranSeg' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Tax' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Tax' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxsasql01']/Database[@Name='DataEnhancementAutomation']/UnresolvedEntity[@Name='Sp_newdataenhancementrequest' and @Schema='dbo'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/1/2015 3:29:06 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_ELAXTVL3]    Script Date: 7/1/2015 3:29:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ====================================================================================================
-- Author:		  Vijay Kodi
-- Create date:	  2015-05-04
-- Description:	  Stage and Process Data on Staging Server as data is imported
			  
--					WHAT IT DOES:
--					Processes data for the @ImportDate argument 	
-- ====================================================================================================


CREATE PROCEDURE [dbo].[sp_ELAXTVL3] (@BeginIssueDate DATETIME,
									 @EndIssueDate DATETIME)

AS

SET NOCOUNT ON

DECLARE @Iata					VARCHAR(50), 
		@ProcName				VARCHAR(50),
		@TransStart				DATETIME, 
		@IataNum				VARCHAR(50), 
		@MaxImportDt			DATETIME, 
        @FirstInvDate			DATETIME, 
        @LastInvDate			DATETIME, 
        @LocalBeginIssueDate	DATETIME, 
        @LocalEndIssueDate		DATETIME  
		


		SELECT @LocalBeginIssueDate = @BeginIssueDate, 
			   @LocalEndIssueDate   = @EndIssueDate

	-----  For Logging Only -------------------------------------
		SET @Iata = 'ELAXTVL3'
		SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	--------------------------------------------------------------    
		-----  For sp PROMPTSONLY ----------  
		SET @IataNum = 'ELAXTVL3'

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


	

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....WHEN the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

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
/******************************************************************************************** 
For any Recordkeys WHERE IssueDate is Null  SET IssueDate = InvoiceDate	in all tables 
namely dba.InvoiceDetail,	dba.Transeg, dba.Car, dba.Hotel, dba.UDef, dba.Payment, dba.Tax 
*********************************************************************************************/

--/*******************************************************************************
--		----START OF UPDATES TO THE IssueDate, , WHERE IssueDate IS NULL    
--********************************************************************************/     
     
--------------------------------------------------------------------------------------------------
    ----Updating the dba.InvoiceDetail Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
---------------------------------------------------------------------------------------------------
   SET @TransStart = Getdate() 

	UPDATE ID 
	SET    ID.issuedate = IH.invoicedate 
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
		   --and ID.IssueDate <> IH.InvoiceDate   
		   AND ID.issuedate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='1-WHEN InvoiceDetail IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------------------------------------------------------------------
--Updating the dba.Transeg Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
-------------------------------------------------------------------------------------------------
      SET @TransStart = Getdate() 

    UPDATE TS
    SET    TS.IssueDate = IH.InvoiceDate 
    FROM   dba.Transeg TS
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= TS.IataNum
						AND IH.clientcode = TS.clientcode 
                        AND IH.RecordKey= TS.RecordKey
                        AND IH.InvoiceDate = TS.InvoiceDate ) 
	WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.IataNum = @IataNum
	AND TS.InvoiceDate between @FirstInvDate AND @LastInvDate
----AND TS.IssueDate <> IH.InvoiceDate
	AND TS.IssueDate IS NULL

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='2-WHEN Transeg IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------------------
    --Updating the dba.Car Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
-------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE Car 
    SET    car.IssueDate = IH.InvoiceDate 
    FROM   dba.Car CAR 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= CAR.IataNum
						AND IH.clientcode = CAR.clientcode 
                        AND IH.RecordKey= CAR.RecordKey
                        AND IH.InvoiceDate = CAR.InvoiceDate ) 
   WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.IataNum = @IataNum
		AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate
	----AND CAR.IssueDate <> IH.InvoiceDate
		AND CAR.IssueDate IS NULL

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='3-WHEN Car IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------
    --Updating the dba.Hotel Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE htl 
    SET    htl.IssueDate = IH.InvoiceDate 
    FROM   dba.Hotel htl 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= htl.IataNum
						AND IH.clientcode = htl.clientcode 
                        AND IH.RecordKey= htl.RecordKey
                        AND IH.InvoiceDate = htl.InvoiceDate ) 
	WHERE IH.IMPORTDT = @MaxImportDt
			AND IH.IataNum = @IataNum
			AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
			AND HTL.IataNum = @IataNum
			AND HTL.InvoiceDate between @FirstInvDate AND @LastInvDate
		----AND HTL.IssueDate <> IH.InvoiceDate
			AND HTL.IssueDate IS NULL

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='4-WHEN Hotel IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------
    --Updating the dba.UDef Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE UD 
    SET    UD.IssueDate = IH.InvoiceDate 
    FROM   dba.UDef UD 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= UD.IataNum
						AND IH.clientcode = UD.clientcode 
                        AND IH.RecordKey= UD.RecordKey
                        AND IH.InvoiceDate = UD.InvoiceDate ) 
	WHERE IH.IMPORTDT = @MaxImportDt
			AND IH.IataNum = @IataNum
			AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
			AND UD.IataNum = @IataNum
			AND UD.InvoiceDate between @FirstInvDate AND @LastInvDate
		----AND UD.IssueDate <> IH.InvoiceDate
			AND UD.IssueDate IS NULL

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='5-WHEN UDef IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------
--Updating the dba.Payment Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
-----------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

	UPDATE PAY
	SET PAY.IssueDate = IH.InvoiceDate
	FROM dba.Payment PAY
	INNER JOIN dba.InvoiceHeader IH
		ON (IH.IataNum     = PAY.IataNum
		AND IH.ClientCode  = PAY.ClientCode
		AND IH.RecordKey   = PAY.RecordKey  
		AND IH.InvoiceDate = PAY.InvoiceDate)
	WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND PAY.IataNum = @IataNum
		AND PAY.InvoiceDate between @FirstInvDate AND @LastInvDate
	----AND PAY.IssueDate <> IH.InvoiceDate
		AND PAY.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='6-WHEN Payment IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	  
---------------------------------------------------------------------------------------------------
--Updating the dba.Tax Table and SET IssueDate = InvoiceDate WHEN IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

	UPDATE TAX
	SET TAX.IssueDate = IH.InvoiceDate
	FROM dba.Tax TAX
	INNER JOIN dba.InvoiceHeader IH
		ON (IH.IataNum     = TAX.IataNum
		AND IH.ClientCode  = TAX.ClientCode
		AND IH.RecordKey   = TAX.RecordKey  
		AND IH.InvoiceDate = TAX.InvoiceDate)
	WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND TAX.IataNum = @IataNum
		AND TAX.InvoiceDate between @FirstInvDate AND @LastInvDate
	----AND TAX.IssueDate <> IH.InvoiceDate
		AND TAX.IssueDate IS NULL

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='7-WHEN Tax IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/**************************************************************************************** 
------END OF UPDATES FOR THE IssueDate, WHERE IssueDate IS NULL  
****************************************************************************************/ 


----------------------------------------------
--------  BEGIN InvoiceDetail AND TranSeg Updates
----------------------------------------------
----------------------------------
--AMEX Standard VendorTypes Update
----------------------------------
--------------------
--BSP
--------------------
    SET @TransStart = Getdate() 
	
	UPDATE ID 
	SET    ID.VendorType = 'BSP' 
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
		   AND ID.producttype IN ( '0' ) 
		   AND ID.VendorType <> 'BSP' 
   

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='8-Update VendorTypes for BSP', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 
--------------------
--NONBSP
--------------------
    SET @TransStart = Getdate() 

	UPDATE ID 
	SET    ID.VendorType = 'NONBSP' 
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
		   AND ID.producttype IN ('8','9')
		   AND ID.VendorType <> 'NONBSP' 
   

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='9-Update VendorTypes for NONBSP', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 

----------------------------------------------
-------  RAIL for ID.VendorType
---------------------------------------------
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
		   AND ID.producttype IN ( '7' ) 

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='10-Update VendorTypes for RAIL by ProductType 7', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 


		-------  To catch RAIL sold as ProductType 8 AND ServiceDescription as 'AIR' such as Amtrak, Eurostar, etc like when a ticket is issued
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
		   AND ( ID.vendorname LIKE '%rail%' 
				  OR ID.vendorname LIKE '%amtrak%' 
				  OR ID.vendorname = 'EUROSTAR' ) 

	EXEC dbo.Sp_logprocerrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='11-Vendortype RAIL by Name', 
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
		   AND ID.ValCarrierCode in ('2V','2R')

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='12-Update VendorType to RAIL where ValCarrierCodes in 2V/2R', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 

----------------------------------------------
-------  FEES for ID.VendorType
----------------------------------------------

-------- FEES  for Amex  ------------
--------------------
--FEES
--------------------
	SET @TransStart = Getdate() 

	UPDATE ID 
	SET    ID.vendortype = 'FEES' 
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
		   AND ID.vendortype NOT IN ( 'FEES' ) 
		   AND ID.producttype IN ( 'F', 'V' ) 

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='13-Update VendorType to FEES', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 

--------------------
--NONAIR
--------------------
	SET @TransStart = Getdate() 

	UPDATE ID 
	SET    VendorType = 'NONAIR' 
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
		   AND ID.VendorType NOT IN ( 'NONAIR' ) 
		   AND ID.producttype not in ('0','8','9','7','F') 

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='14-Update VendorTypes for NONAIR', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 


SET @TransStart = Getdate() 

UPDATE ID 
SET    ID.Servicefee = TotalAmt 
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
       AND ID.VendorType  IN ( 'FEES' ) 
       AND ID.Servicefee = '0'

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='15-Update ServiceFee from TotalAmt', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

------------------------------------------
--New AMEX Standard Rail Carriers
------------------------------------------
SET @TransStart = getdate()

update dba.InvoiceDetail
SET VendorName = CASE 
WHEN ValCarrierCode = 'R0' THEN 'DEFAULT RAIL'
WHEN ValCarrierCode = '0A' THEN 'ATOC-RSP'
WHEN ValCarrierCode = '0A' THEN 'ATOC-RSP'
WHEN ValCarrierCode = '0E' THEN 'FIRST GREAT WESTERN'
WHEN ValCarrierCode = '0F' THEN 'GATWICK EXPRESS'
WHEN ValCarrierCode = '0G' THEN 'HULL TRAINS'
WHEN ValCarrierCode = '0H' THEN 'GREAT NORTH EASTERN RAILWAY'
WHEN ValCarrierCode = '0I' THEN 'VIRGIN WEST COAST'
WHEN ValCarrierCode = '0J' THEN 'VIRGIN CROSSCOUNTRY TRAINS'
WHEN ValCarrierCode = '0K' THEN 'C2C'
WHEN ValCarrierCode = '0L' THEN 'LONDON UNDERGROUND'
WHEN ValCarrierCode = '0M' THEN 'MIDLAND MAINLINE'
WHEN ValCarrierCode = '0N' THEN 'THE CHILTERN RAILWAY COMPANY'
WHEN ValCarrierCode = '0O' THEN 'ISLAND LINE'
WHEN ValCarrierCode = '0Q' THEN 'SOUTHERN/SOUTH CENTRAL'
WHEN ValCarrierCode = '0R' THEN 'SOUTH EASTERN TRAINS'
WHEN ValCarrierCode = '0S' THEN 'FIRST GREAT WESTERN LINK'
WHEN ValCarrierCode = '0T' THEN 'MERSEYRAIL PTE'
WHEN ValCarrierCode = '0U' THEN 'STRATHCLYDE PTE'
WHEN ValCarrierCode = '0W' THEN 'SOUTH YORKSHIRE PTE'
WHEN ValCarrierCode = '0X' THEN 'NEXUS TYNE AND WEAR PTE'
WHEN ValCarrierCode = '0Y' THEN 'WEST MIDLANDS PTE'
WHEN ValCarrierCode = '0Z' THEN 'WEST YORKSHIRE PTE'
WHEN ValCarrierCode = '02' THEN 'CENTRAL TRAINS'
WHEN ValCarrierCode = '03' THEN 'MERSEYRAIL'
WHEN ValCarrierCode = '04' THEN 'ARRIVA TRAINS NORTHERN'
WHEN ValCarrierCode = '06' THEN 'ARRIVA TRAINS WALES'
WHEN ValCarrierCode = '08' THEN 'FIRST SCOTRAIL/SCOTRAIL RAILWAYS'
WHEN ValCarrierCode = '09' THEN 'SOUTH WEST TRAINS'
WHEN ValCarrierCode = '10' THEN 'THAMESLINK RAIL'
WHEN ValCarrierCode = '11' THEN 'TRANSPENNINE EXPRESS'
WHEN ValCarrierCode = '12' THEN 'ONE GER'
WHEN ValCarrierCode = '13' THEN 'ONE LER'
WHEN ValCarrierCode = '14' THEN 'WEST ANGLIA GREAT NORTHERN RAIL'
WHEN ValCarrierCode = '19' THEN 'NORTHERN'
WHEN ValCarrierCode = '2H' THEN 'THALYS INTL RAILWAY SAL'
WHEN ValCarrierCode = '20' THEN 'RAIL CHINA'
WHEN ValCarrierCode = '21' THEN 'RAIL MALAYSIA'
WHEN ValCarrierCode = '22' THEN 'RAIL SINGAPORE'
WHEN ValCarrierCode = '23' THEN 'RAIL HONG KONG'
WHEN ValCarrierCode = '24' THEN 'ARLANDA EXPRESS'
WHEN ValCarrierCode = '25' THEN 'FLYTOGET'
WHEN ValCarrierCode = '26' THEN 'OBB - AUSTRIAN RAILWAYS'
WHEN ValCarrierCode = '30' THEN 'SWISS RAIL'
WHEN ValCarrierCode = '31' THEN 'TRENITALIA'
WHEN ValCarrierCode = '32' THEN 'ITALIAN RAIL'
WHEN ValCarrierCode = '34' THEN 'ONTARIO NORTHLAND'
WHEN ValCarrierCode = '36' THEN 'FIRST GREAT WESTERN ADVANCE'
WHEN ValCarrierCode = '38' THEN 'PRIVATE RAIL CO - JAPAN' 
WHEN ValCarrierCode = '41' THEN 'NMBS/SNCB NATIONAL RAILWAYS OF BELGIUM'       
WHEN ValCarrierCode = '42' THEN 'RAIL EUROPE'
WHEN ValCarrierCode = '43' THEN 'EUROTUNNEL SHUTTLE'
WHEN ValCarrierCode = '44' THEN 'BELGIUM RAIL SERVICE CENTER'
WHEN ValCarrierCode = '45' THEN 'JALPAK INTERNATIONAL'
WHEN ValCarrierCode = '46' THEN 'FIRST CAPITAL CONNECT'
WHEN ValCarrierCode = '47' THEN 'JAPAN RAILWAYS'
WHEN ValCarrierCode = '6I' THEN 'GRAND RAIL CENTRAL'
WHEN ValCarrierCode = '6X' THEN 'LONDON MIDLAND'
WHEN ValCarrierCode = '7O' THEN 'LONDON OVERGROUND'
WHEN ValCarrierCode = '9G' THEN 'AIRPORT EXPRESS RAIL LTD'
WHEN ValCarrierCode = '9I' THEN 'EAST MIDLANDS TRAINS'
WHEN ValCarrierCode = '9O' THEN 'WREXHAM SHROPSHIRE MARYLEBONE'
WHEN ValCarrierCode = '92' THEN 'RENFE SPAIN RAIL'
WHEN ValCarrierCode = '93' THEN 'RUSSIAN RAIL'
ELSE VendorName
END
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
	AND ID.VendorType = 'RAIL'
----AND ID.VendorName is null  ---- (Removing in case during import carriers table overwrites with an airline name instead of rail)
	AND ID.ValCarrierCode IS NOT NULL

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='16-ID Rail Carrier Names', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


----  RAIL specifics only for AMEX for SegmentCarrierName in Transeg 

SET @TransStart = getdate()

UPDATE dba.TranSeg
SET SegmentCarrierName = CASE
WHEN SegmentCarrierName = 'R0' THEN 'DEFAULT RAIL'
WHEN SegmentCarrierName = '0A' THEN 'ATOC-RSP'
WHEN SegmentCarrierName = '0A' THEN 'ATOC-RSP'
WHEN SegmentCarrierName = '0E' THEN 'FIRST GREAT WESTERN'
WHEN SegmentCarrierName = '0F' THEN 'GATWICK EXPRESS'
WHEN SegmentCarrierName = '0G' THEN 'HULL TRAINS'
WHEN SegmentCarrierName = '0H' THEN 'GREAT NORTH EASTERN RAILWAY'
WHEN SegmentCarrierName = '0I' THEN 'VIRGIN WEST COAST'
WHEN SegmentCarrierName = '0J' THEN 'VIRGIN CROSSCOUNTRY TRAINS'
WHEN SegmentCarrierName = '0K' THEN 'C2C'
WHEN SegmentCarrierName = '0L' THEN 'LONDON UNDERGROUND'
WHEN SegmentCarrierName = '0M' THEN 'MIDLAND MAINLINE'
WHEN SegmentCarrierName = '0N' THEN 'THE CHILTERN RAILWAY COMPANY'
WHEN SegmentCarrierName = '0O' THEN 'ISLAND LINE'
WHEN SegmentCarrierName = '0Q' THEN 'SOUTHERN/SOUTH CENTRAL'
WHEN SegmentCarrierName = '0R' THEN 'SOUTH EASTERN TRAINS'
WHEN SegmentCarrierName = '0S' THEN 'FIRST GREAT WESTERN LINK'
WHEN SegmentCarrierName = '0T' THEN 'MERSEYRAIL PTE'
WHEN SegmentCarrierName = '0U' THEN 'STRATHCLYDE PTE'
WHEN SegmentCarrierName = '0W' THEN 'SOUTH YORKSHIRE PTE'
WHEN SegmentCarrierName = '0X' THEN 'NEXUS TYNE AND WEAR PTE'
WHEN SegmentCarrierName = '0Y' THEN 'WEST MIDLANDS PTE'
WHEN SegmentCarrierName = '0Z' THEN 'WEST YORKSHIRE PTE'
WHEN SegmentCarrierName = '02' THEN 'CENTRAL TRAINS'
WHEN SegmentCarrierName = '03' THEN 'MERSEYRAIL'
WHEN SegmentCarrierName = '04' THEN 'ARRIVA TRAINS NORTHERN'
WHEN SegmentCarrierName = '06' THEN 'ARRIVA TRAINS WALES'
WHEN SegmentCarrierName = '08' THEN 'FIRST SCOTRAIL/SCOTRAIL RAILWAYS'
WHEN SegmentCarrierName = '09' THEN 'SOUTH WEST TRAINS'
WHEN SegmentCarrierName = '10' THEN 'THAMESLINK RAIL'
WHEN SegmentCarrierName = '11' THEN 'TRANSPENNINE EXPRESS'
WHEN SegmentCarrierName = '12' THEN 'ONE GER'
WHEN SegmentCarrierName = '13' THEN 'ONE LER'
WHEN SegmentCarrierName = '14' THEN 'WEST ANGLIA GREAT NORTHERN RAIL'
WHEN SegmentCarrierName = '19' THEN 'NORTHERN'
WHEN SegmentCarrierName = '2H' THEN 'THALYS INTL RAILWAY SAL'
WHEN SegmentCarrierName = '20' THEN 'RAIL CHINA'
WHEN SegmentCarrierName = '21' THEN 'RAIL MALAYSIA'
WHEN SegmentCarrierName = '22' THEN 'RAIL SINGAPORE'
WHEN SegmentCarrierName = '23' THEN 'RAIL HONG KONG'
WHEN SegmentCarrierName = '24' THEN 'ARLANDA EXPRESS'
WHEN SegmentCarrierName = '25' THEN 'FLYTOGET'
WHEN SegmentCarrierName = '26' THEN 'OBB - AUSTRIAN RAILWAYS'
WHEN SegmentCarrierName = '30' THEN 'SWISS RAIL'
WHEN SegmentCarrierName = '31' THEN 'TRENITALIA'
WHEN SegmentCarrierName = '32' THEN 'ITALIAN RAIL'
WHEN SegmentCarrierName = '34' THEN 'ONTARIO NORTHLAND'
WHEN SegmentCarrierName = '36' THEN 'FIRST GREAT WESTERN ADVANCE'
WHEN SegmentCarrierName = '38' THEN 'PRIVATE RAIL CO - JAPAN' 
WHEN SegmentCarrierName = '41' THEN 'NMBS/SNCB NATIONAL RAILWAYS OF BELGIUM'       
WHEN SegmentCarrierName = '42' THEN 'RAIL EUROPE'
WHEN SegmentCarrierName = '43' THEN 'EUROTUNNEL SHUTTLE'
WHEN SegmentCarrierName = '44' THEN 'BELGIUM RAIL SERVICE CENTER'
WHEN SegmentCarrierName = '45' THEN 'JALPAK INTERNATIONAL'
WHEN SegmentCarrierName = '46' THEN 'FIRST CAPITAL CONNECT'
WHEN SegmentCarrierName = '47' THEN 'JAPAN RAILWAYS'
WHEN SegmentCarrierName = '6I' THEN 'GRAND RAIL CENTRAL'
WHEN SegmentCarrierName = '6X' THEN 'LONDON MIDLAND'
WHEN SegmentCarrierName = '7O' THEN 'LONDON OVERGROUND'
WHEN SegmentCarrierName = '9G' THEN 'AIRPORT EXPRESS RAIL LTD'
WHEN SegmentCarrierName = '9I' THEN 'EAST MIDLANDS TRAINS'
WHEN SegmentCarrierName = '9O' THEN 'WREXHAM SHROPSHIRE MARYLEBONE'
WHEN SegmentCarrierName = '92' THEN 'RENFE SPAIN RAIL'
WHEN SegmentCarrierName = '93' THEN 'RUSSIAN RAIL'
ELSE SegmentCarrierName
END
FROM dba.TranSeg TS
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = TS.IataNum
	AND IH.ClientCode  = TS.ClientCode
	AND IH.RecordKey   = TS.RecordKey  
	AND IH.InvoiceDate = TS.InvoiceDate)
WHERE IH.ImportDt = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.IataNum = @IataNum
	AND TS.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.TypeCode = 'R'
---	AND TS.SegmentCarrierName is null  ---- (Removing in case during import carriers table overwrites with an airline name instead of rail)
	AND TS.SegmentCarrierName IS NOT NULL

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='17-Rail TS SegmentCarrierNames', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-----------------------------------------------
----------End FEE AND RAIL Updates ----------
-----------------------------------------------

------------------------------------------------
----	BEGIN PREFERRED VENDORS FOR CAR AND AIR
------------------------------------------------

-------------------------------------------------------------
----  PREFERRED CAR VENDORS   
----	Preferred Car Vendor where  CarChainName is NATIONAL(ZL) AND ENTERPRISE(ET)
----	Added Per SF 06372985 05.05.2015 Vijay Kodi
-------------------------------------------------------------
	SET @TransStart = getdate()

		Update dba.car
		set prefcarind = 'Y'
		FROM dba.Car CAR
	INNER JOIN dba.InvoiceHeader IH
		ON (IH.IataNum     = CAR.IataNum
		AND IH.ClientCode  = CAR.ClientCode
		AND IH.RecordKey   = CAR.RecordKey  
		AND IH.InvoiceDate = CAR.InvoiceDate)
	WHERE IH.ImportDt = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.IataNum = @IataNum
		AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.CarChainCode in ('ZL')
		AND CAR.PrefCarInd is null

	   EXEC dbo.sp_LogProcErrors 
		  @ProcedureName=@ProcName, 
		  @LogStart=@TransStart, 
		  @StepName='18-Preferred Car Vendor', 
		  @BeginDate=@LocalBeginIssueDate, 
		  @EndDate= @LocalEndIssueDate, 
		  @IataNum=@Iata, 
		  @RowCount=@@ROWCOUNT, 
		  @ERR=@@ERROR


		SET @TransStart = getdate()

		Update dba.car
		set prefcarind = 'Y'
		FROM dba.Car CAR
	INNER JOIN dba.InvoiceHeader IH
		ON (IH.IataNum     = CAR.IataNum
		AND IH.ClientCode  = CAR.ClientCode
		AND IH.RecordKey   = CAR.RecordKey  
		AND IH.InvoiceDate = CAR.InvoiceDate)
	WHERE IH.ImportDt = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.IataNum = @IataNum
		AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.CarChainCode in ('ET')
		AND CAR.PrefCarInd is null

	   EXEC dbo.sp_LogProcErrors 
		  @ProcedureName=@ProcName, 
		  @LogStart=@TransStart, 
		  @StepName='19-Preferred Car Vendor', 
		  @BeginDate=@LocalBeginIssueDate, 
		  @EndDate= @LocalEndIssueDate, 
		  @IataNum=@Iata, 
		  @RowCount=@@ROWCOUNT, 
		  @ERR=@@ERROR
---------------------------------------------------
----	Preferred Air Vendors 
----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
----  PREFERRED AIR VENDORS 
----Per SF 06372985  -  Preferred carriers are BA British Airways (BA), American Airlines (AA), Iberia (IB),
----Japan Airlines (JL), US Airways (US), Delta (DL), Air France (AF), KLM 9KL), GOL Airlines (G3), Alitalia (AZ),
----Cathay Pacific (CX), Korean Airlines (KE), Jet Airways (9W), Singapore Airlines (SQ), Porter Airlines (PD), 
----WestJet (WS), Virgin Atlantic (VS), Southwest (WN), LAN/TAM (LA) and China Eastern Airlines (MU)
-----------------------------------------------------------------------------------------------------------------
	SET @TransStart = getdate()

	UPDATE dba.InvoiceDetail
	SET PrefTktInd =  CASE
		WHEN valcarriercode in ('BA', 'AA', 'IB', 'JL', 'US', 'DL', 'AF', 'KL', 'G3', 'AZ', 'CX', 'KE', '9W', 'SQ', 'PD', 'WS', 'VS', 'WN', 'LA', 'MU' ) THEN 'Y'
		ELSE PrefTktInd END
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
		AND ID.PrefTktInd is null
		and ID.VendorType not in ('NONAIR')
   
	EXEC dbo.sp_LogProcErrors 
		@ProcedureName=@ProcName, 
		@LogStart=@TransStart, 
		@StepName='20-ID.PrefTktInd- AIR Vendor', 
		@BeginDate=@LocalBeginIssueDate, 
		@EndDate= @LocalEndIssueDate, 
		@IataNum=@Iata, 
		@RowCount=@@ROWCOUNT, 
		@ERR=@@ERROR


	SET @TransStart = getdate()

	UPDATE dba.Transeg
	SET PrefAirInd =  CASE
		WHEN SegmentCarrierCode in ('BA', 'AA', 'IB', 'JL', 'US', 'DL', 'AF', 'KL', 'G3', 'AZ', 'CX', 'KE', '9W', 'SQ', 'PD', 'WS', 'VS', 'WN', 'LA', 'MU' ) THEN 'Y'
		ELSE PrefAirInd END
	FROM dba.TranSeg TS
	INNER JOIN dba.InvoiceHeader IH
		ON (IH.IataNum     = TS.IataNum
		AND IH.ClientCode  = TS.ClientCode
		AND IH.RecordKey   = TS.RecordKey  
		AND IH.InvoiceDate = TS.InvoiceDate)
	WHERE IH.ImportDt = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND TS.IataNum = @IataNum
		AND TS.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND TS.PrefAirInd is null

	EXEC dbo.sp_LogProcErrors 
		@ProcedureName=@ProcName, 
		@LogStart=@TransStart, 
		@StepName='21-ID.TS.PrefAIRInd', 
		@BeginDate=@LocalBeginIssueDate, 
		@EndDate= @LocalEndIssueDate, 
		@IataNum=@Iata, 
		@RowCount=@@ROWCOUNT, 
		@ERR=@@ERROR


/***********************************************  
----	END PREFERRED CAR AND AIR UPDATES
************************************************/

---------------------------------------------------------------------------------------------------------------------------
--Updating ComRmks to populated the first 6 standard field and and SET to 'Not Provided' all field afterwards for mapping
---------------------------------------------------------------------------------------------------------------------------
-------------------------------------

--------  Begin DELETE AND INSERT ComRmks -----
----  **Note DO NOT ADD:
----    these JOINS: 
----      AND IH.InvoiceDate = CR.InvoiceDate
----      AND IH.ClientCode = CR.ClientCode
----    or FILTER:
----      AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
----    in case InvoiceDates or ClientCodes changed with newly arrived data
----   ** Only match on IataNum AND Recordkey to delete
 ------------------------------------
 ---DELETE COMRMKS
 ------------------------------------
	SET @TransStart = Getdate() 

	DELETE dba.ComRmks 
	FROM   dba.ComRmks CR 
		   INNER JOIN dba.InvoiceHeader IH 
				   ON ( IH.IataNum = CR.IataNum 
						AND IH.recordkey = CR.recordkey ) 
	WHERE  IH.ImportDt = @MaxImportDt 
		   AND IH.IataNum = @IataNum 
		   AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
		   AND CR.IataNum = @IataNum 
		   AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate

	EXEC dbo.sp_LogProcErrors 
	  @ProcedureName=@ProcName, 
	  @LogStart=@TransStart, 
	  @StepName='22-Delete DBA.ComRmks', 
	  @BeginDate=@LocalBeginIssueDate, 
	  @EndDate=@LocalEndIssueDate, 
	  @IataNum=@Iata, 
	  @RowCount=@@ROWCOUNT, 
	  @ERR=@@ERROR 
 ------------------------------------
 ---INSERT COMRMKS
 ------------------------------------

SET @TransStart = Getdate() 

INSERT INTO dba.ComRmks 
            (recordkey, 
             IataNum, 
             seqnum, 
             clientcode, 
             InvoiceDate, 
             issuedate) 
SELECT DISTINCT ID.recordkey, 
                ID.IataNum, 
                ID.seqnum, 
                ID.clientcode, 
                ID.InvoiceDate, 
                ID.issuedate 
FROM   dba.InvoiceDetail ID 
       INNER JOIN dba.InvoiceHeader IH 
               ON ( IH.IataNum		   = ID.IataNum 
                    AND IH.clientcode  = ID.clientcode 
                    AND IH.recordkey   = ID.recordkey 
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
       AND IH.IataNum = @IataNum 
       AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
       AND ID.IataNum = @IataNum 
       AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
       AND ID.recordkey + ID.IataNum 
           + CONVERT(VARCHAR, ID.seqnum) NOT IN (SELECT 
           CR.recordkey + CR.IataNum 
           + CONVERT(VARCHAR, CR.seqnum) 
                                                 FROM   dba.ComRmks CR 
                                                 WHERE  CR.IataNum = @IataNum) 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='23-Insert Stag CR', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
-----------------------------------------------------------------------
----------------------------------------------------------------------
----	ComRmks to 'Not Provided' prior to updating with agency data
----------------------------------------------------------------------

SET @TransStart = getdate()

UPDATE dba.ComRmks
SET
Text1 = CASE WHEN Text1 is null then 'Not Provided' ELSE Text1 end,
Text2 = CASE WHEN Text2 is null then 'Not Provided' ELSE Text2 end,
Text3 = CASE WHEN Text3 is null then 'Not Provided' ELSE Text3 end,
Text4 = CASE WHEN Text4 is null then 'Not Provided' ELSE Text4 end,
Text5 = CASE WHEN Text5 is null then 'Not Provided' ELSE Text5 end,
Text6 = CASE WHEN Text6 is null then 'Not Provided' ELSE Text6 end,
Text7 = CASE WHEN Text7 is null then 'Not Provided' ELSE Text7 end,
Text8 = CASE WHEN Text8 is null then 'Not Provided' ELSE Text8 end,
Text9 = CASE WHEN Text9 is null then 'Not Provided' ELSE Text9 end,
Text10 = CASE WHEN Text10 is null then 'Not Provided' ELSE Text10 end,
Text11 = CASE WHEN Text11 is null then 'Not Provided' ELSE Text11 end,
Text12 = CASE WHEN Text12 is null then 'Not Provided' ELSE Text12 end,
Text13 = CASE WHEN Text13 is null then 'Not Provided' ELSE Text13 end,
Text14 = CASE WHEN Text14 is null then 'Not Provided' ELSE Text14 end,
Text15 = CASE WHEN Text15 is null then 'Not Provided' ELSE Text15 end,  
Text16 = CASE WHEN Text16 is null then 'Not Provided' ELSE Text16 end,
Text17 = CASE WHEN Text17 is null then 'Not Provided' ELSE Text17 end,
Text18 = CASE WHEN Text18 is null then 'Not Provided' ELSE Text18 end,
Text19 = CASE WHEN Text19 is null then 'Not Provided' ELSE Text19 end,
Text20 = CASE WHEN Text20 is null then 'Not Provided' ELSE Text20 end,
Text21 = CASE WHEN Text21 is null then 'Not Provided' ELSE Text21 end,
Text22 = CASE WHEN Text22 is null then 'Not Provided' ELSE Text22 end,
Text23 = CASE WHEN Text23 is null then 'Not Provided' ELSE Text23 end,
Text24 = CASE WHEN Text24 is null then 'Not Provided' ELSE Text24 end,
Text25 = CASE WHEN Text25 is null then 'Not Provided' ELSE Text25 end,
Text48 = CASE WHEN Text48 is null then 'Not Provided' ELSE Text48 end,
Text50 = CASE WHEN Text50 is null then 'Not Provided' ELSE Text50 end
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
  @StepName='24-SET Text Fields To Not Provided', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
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
----	STANDARD Text2 with POS from InvoiceHeader OrigCountry
--------------------------------------------------------

SET @TransStart = Getdate() 

UPDATE CR 
SET    Text2 = CASE 
                 WHEN IH.OrigCountry IS NULL THEN 'Not Provided' 
                 ELSE IH.OrigCountry 
               END 
FROM   dba.ComRmks CR 
       INNER JOIN dba.InvoiceHeader IH 
               ON ( IH.IataNum = CR.IataNum 
                    AND IH.clientcode = CR.clientcode 
                    AND IH.recordkey = CR.recordkey 
                    AND IH.InvoiceDate = CR.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
       AND IH.IataNum = @IataNum 
       AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
       AND CR.IataNum = @IataNum 
       AND CR.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='25-Update Text2_IH POS_Ctry', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-----------------------------------------------------------------
-----     End Of Standard ComRmks Mappings    -------------
-----------------------------------------------------------------

-----------------------------------------------------------------
-----     Begin client Specific ComRmks Mappings    -------------
-----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
----	Text1 for EmployeeID 
----	Text50 for EmployeeID Raw Data as received without substrings other than 1,150 to fit in text field
------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------					
----Update Text1 with Employee ID based off POS Set in Text2 for BE(BELGIUM) UDID2/ position 1-7
----And BR(BRAZIL) UDID2
-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()
UPDATE CR
SET CR.Text1  = CASE
				WHEN IH.OrigCountry in ('BR') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('BR') AND UD.UdefData IS NOT NULL  THEN UD.UdefData 
				WHEN IH.OrigCountry in ('BE') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('BE') AND UD.UdefData IS NOT NULL THEN substring(UD.UdefData, 1,7)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 2
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE83','ESTE91')
	AND IH.OrigCountry in ('BE', 'BR')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='26-Update Text1 Based On Text2 for BE,BR', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------					
----Update Text1 with Employee ID based off POS Set in Text2 for CN(China) UDID3, JP(Japan) UDID3
----and TR(Turkey) UDID3
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text1  = CASE
				WHEN IH.OrigCountry in ('CN', 'JP', 'TR') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('CN', 'JP', 'TR') AND UD.UdefData IS NOT NULL  THEN Replace (UD.UdefData, '.', '') 
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 3
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE1C', 'ESTE1J', 'ESTETR')
	AND IH.OrigCountry in ('CN', 'JP', 'TR')

EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='27-Update Text1 Based On Text2 for CN,JP,TR', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------					
--Update Text1 with Employee ID based off POS Set in Text2 for DE(Germany) UDID6/Position 1-10
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text1  = CASE
				WHEN IH.OrigCountry in ('DE') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('DE') AND UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,1,10)<> '' THEN SUBSTRING(UD.UdefData,1,10)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 6
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE94' )
	AND IH.OrigCountry in ('DE')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='27-Update Text1 Based On Text2 for DE', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------					
--Update Text1 with Employee ID based off POS Set in Text2 for MY(Malaysia) UDID 8 PART 2
---( POSITION 8-12 )and TR(Taiwan) UDID8/PART1(TR(UDID8/1-9 numeric) and (Vietnam) TF8 (Text Field)
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text1  = CASE
				WHEN IH.OrigCountry in ('VN') AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry in ('VN') AND UD.UdefData IS NOT NULL  AND SUBSTRING(UD.UdefData,1,8) <> '' THEN  SUBSTRING(UD.UdefData,1,8)
				WHEN IH.OrigCountry in ('MY') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('MY') AND UD.UdefData IS NOT NULL  THEN REPLACE(REPLACE(SUBSTRING (UDEFData, Charindex(' ', (UDEFDATA), 0) +8,7), '/',''), '-','')
				WHEN IH.OrigCountry in ('TW') AND UD.UdefData IS NULL THEN 'Not Provided'
				WHEN IH.OrigCountry in ('TW') AND UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,21,9) <> '' THEN SUBSTRING(UD.UdefData,21,9)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 8
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE1M', 'ESTE1W', 'ESTEVN')
	AND IH.OrigCountry in ('MY', 'TW', 'VN')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='28-Update Text1 Based On Text2 for MY, TW, VN', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------					
--Update Text1 with Employee ID based off POS Set in Text2 for MX(Mexico) Statement Info/ 1-10
--------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text1  = CASE
				WHEN IH.OrigCountry in ('MX') AND ID.Remarks1 IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('MX') AND ID.Remarks1 IS NOT NULL AND SUBSTRING(ID.Remarks1,1,10) <> '' THEN Substring(ID.Remarks1,1,10)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
	AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE80' )
	AND IH.OrigCountry in ('MX')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='29-Update Text1 Based On Text2 for MX', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------					
--Update Text1 with Employee ID based off POS Set in Text2 for UK(United Kingdom) UDID7 
--------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text1  = CASE
				WHEN IH.OrigCountry in ('GB') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('GB') AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 7
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE90')
	AND IH.OrigCountry in ('GB')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='30-Update Text1 Based On Text2 for GB', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR 

------------------------------------------------------------------------------------------------------------
----Update Text3 with Cost Center based off POS Set in Text2 for AU(Australia) UDID 8/Position 3-12, 
----CN(China) UDID8-PART2 (ex:1041813111), MX(Mexico) UDID 8/Position 1-6, TH(Thailand) UDID8Part 2 position 8,
----GB(Great Britain) Udid8 (part2-position3-6)
------------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text3  = CASE
				WHEN IH.OrigCountry = 'AU' AND UD.UdefData IS NULL THEN 'Not Provided'
				WHEN IH.OrigCountry = 'AU' AND UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,3,10) <> '' THEN  SUBSTRING(UD.UdefData,3,10)
				WHEN IH.OrigCountry = 'CN' AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry = 'CN' AND (UD.Udefdata like '%-'or UD.Udefdata like '%-%') AND CHARINDEX('-',REVERSE(UD.Udefdata),0)-1 <> 0  THEN  right(UD.Udefdata,CHARINDEX('-',REVERSE(UD.Udefdata),0)-1)
				WHEN IH.OrigCountry = 'CN' AND (UD.Udefdata like '%-'or UD.Udefdata like '%-%') AND CHARINDEX('-',REVERSE(UD.Udefdata),0)-1  = 0  THEN 'Not Provided'
				WHEN IH.OrigCountry = 'MX' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry = 'MX' AND UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,1,6) <> '' THEN  SUBSTRING(UD.UdefData,1,6)
				WHEN IH.OrigCountry = 'TH' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry = 'TH' AND UD.UdefData IS NOT NULL AND CHARINDEX('-',REVERSE(UD.Udefdata),0)-1 <> 0 then right(UD.Udefdata,CHARINDEX('-',REVERSE(UD.Udefdata),0)-1)
				WHEN IH.OrigCountry = 'TH' AND UD.UdefData IS NOT NULL AND CHARINDEX('-',REVERSE(UD.Udefdata),0)-1  = 0 then 'Not Provided'
				WHEN IH.OrigCountry = 'GB' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry = 'GB' AND UD.UdefData IS NOT NULL AND LEFT(substring(UD.Udefdata,8,charindex(' ',UD.Udefdata)+3),4) <>  '' THEN  LEFT(substring(UD.Udefdata,8,charindex(' ',UD.Udefdata)+3),4)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum	   = 8
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	--AND CL.CustAddr1 in ('ESTE1A', 'ESTE1C', 'ESTE80', 'ESTE1T', 'ESTE90')
	AND IH.OrigCountry IN ('AU', 'CN', 'MX', 'TH', 'GB')

	
	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='31-Update Text3 Based On Text2 for AU, CN, MX, TH, GB', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-------------------------------------------------------------------------------------------------
----Update Text3 with Cost Center based off POS Set in Text2 for  AT(Austria) UDID 1
---- and BR(Brazil) UDID 1
-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text3  = CASE
				WHEN IH.OrigCountry ='AT' AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='AT' AND UD.UdefData IS NOT NULL THEN UD.UdefData 
				WHEN IH.OrigCountry ='BR' AND UD.UdefData IS NULL THEN 'Not Provided'
				WHEN IH.OrigCountry ='BR' AND UD.UdefData IS NOT NULL THEN REPLACE(UD.UdefData, '/', '') 
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum	   = 1
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry IN ('AT', 'BR')
	AND CL.CustAddr1 in ('ESTEA1', 'ESTE83')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='32-Update Text3 Based On Text2 for AT, BR', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-------------------------------------------------------------------------------------------------
-----Update Text3 with Cost Center based off POS Set in Text2 for  HK(Hongkong) UDID2/P2 / Position 1-13
---- JP(Japan) UDID2 and NZ (New Zealand) UDID 2 / Positiion 1-25
-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text3  = CASE
				WHEN IH.OrigCountry ='HK' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry ='HK' AND (UD.Udefdata like '%/'or UD.Udefdata like '%/%') AND CHARINDEX('/',REVERSE(UD.Udefdata),0)-1 <> 0 THEN  right(UD.Udefdata,CHARINDEX('/',REVERSE(UD.Udefdata),0)-1)
				WHEN IH.OrigCountry ='HK' AND (UD.Udefdata like '%/'or UD.Udefdata like '%/%') AND CHARINDEX('/',REVERSE(UD.Udefdata),0)-1  = 0 then 'Not Provided'
				WHEN IH.OrigCountry ='JP' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry ='JP' AND UD.UdefData IS NOT NULL THEN UD.UdefData 
				WHEN IH.OrigCountry ='NZ' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry ='NZ' AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData, 1,25) 
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 2
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE1H', 'ESTE1J', 'ESTE12')
	AND IH.OrigCountry IN ('HK', 'JP', 'NZ')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='33-Update Text3 Based On Text2 for HK, JP, NZ', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-------------------------------------------------------------------------------------------------
-----Update Text3 with Cost Center based off POS Set in Text2 for  DE(Germany) UDID3/Position 1-10
---- CH(Switzerland) UDID3 / Position 2 (numeric 10 digits) 
-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text3  = CASE
				WHEN IH.OrigCountry ='DE' AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry ='DE' AND UD.UdefData IS NOT NULL  THEN SUBSTRING(UD.UdefData, 1,10) 				
				WHEN IH.OrigCountry ='CH' AND UD.UdefData IS NULL THEN 'Not Provided'
				WHEN IH.OrigCountry ='CH' AND UD.UdefData <> '0' THEN SUBSTRING(UD.UdefData, 1,25) 
				WHEN IH.OrigCountry ='CH' AND UD.UdefData = '0' THEN 'Not Provided' 
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 3
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry IN ('DE', 'CH') 
	AND CL.CustAddr1 in ('ESTE94', 'ESTE98')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='34-Update Text3 Based On Text2 for DE, CH', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR


-------------------------------------------------------------------------------------------------
-----Update Text3 with Cost Center based off POS Set in Text2 for  GR(Greece) Udid 6/position 1-9
-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text3  = CASE
				WHEN IH.OrigCountry ='GR'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='GR'AND UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,1,9) <> '' THEN  SUBSTRING(UD.UdefData,1,9)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 6
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='GR'
	AND CL.CustAddr1 in ('ESTE99')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='35-Update Text3 Based On Text2 for GR', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-------------------------------------------------------------------------------------------------					
--Update Text4 with Department based off POS Set in Text2 for HK(Hongkong) UDID1/ Position 1-18
-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text4  = CASE
				WHEN IH.OrigCountry in ('HK') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('HK') AND UD.UdefData IS NOT NULL THEN substring(UD.UdefData, 1,18)
				WHEN IH.OrigCountry in ('TW') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('TW') AND UD.UdefData IS NOT NULL THEN substring(UD.UdefData, 1,9)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 1
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE1H', 'ESTE1W')
	AND IH.OrigCountry in ('HK', 'TW')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='36-Update Text4 Based On Text2 for HK, TW', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR


----------------------------------------------------------------------------------------------				
--Update Text4 with Department based off POS Set in Text2 for BE(Belgium) udid 3/ position 1-10 

-------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text4  = CASE
				WHEN IH.OrigCountry in ('BE') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('BE') AND UD.UdefData IS NOT NULL THEN substring(UD.UdefData, 1,10)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 3
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE91')
	AND IH.OrigCountry in ('BE')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='37-Update Text4 Based On Text2 for BE', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

---------------------------------------------------------------------------------------					
--Update Text4 with Department based off POS Set in Text2 for MX(Mexico) UDID4/Position 1-25
---and NZ(New zealand) UDID4/Position 1-25
--------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text4  = CASE
				WHEN IH.OrigCountry in ('MX') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('MX') AND UD.UdefData IS NOT NULL THEN substring(UD.UdefData, 1,25)
				WHEN IH.OrigCountry in ('NZ') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('NZ') AND UD.UdefData IS NOT NULL THEN substring(UD.UdefData, 1,25)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 4
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE12','ESTE80')
	AND IH.OrigCountry in ('MX', 'NZ')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='38-Update Text4 Based On Text2 for MX, NZ', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

--------------------------------------------------------------------------------------------------------------					
--Update Text4 with Department based off POS Set in Text2 for GB(United Kingdom)  Udid8 (part2-position3-6)
----------------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text4  = CASE
				WHEN IH.OrigCountry in ('GB') AND UD.UdefData IS NULL  THEN 'Not Provided'
				WHEN IH.OrigCountry in ('GB') AND UD.UdefData IS NOT NULL THEN SUBSTRING (UDEFData, Charindex(' ', (UD.UDEFDATA), 0) +7,2)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 8
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE90')
	AND IH.OrigCountry in ('GB')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='39-Update Text4 Based On Text2 for GB', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

---------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2 for  JP(Japan) UDID 1 and TR(Turkey) UDID 1
---------------------------------------------------------------------------------------------------------

SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='JP'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='JP'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				WHEN IH.OrigCountry ='TR'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='TR'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 1
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry IN ('JP', 'TR')
	AND CL.CustAddr1 in ('ESTE1J', 'ESTETR')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='40-Update Text6 Based On Text2 for JP, TR', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

------------------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2 for RU(Russia) UDID2, HK(Hongkong) UDID2/P1/ Position 1-13, 
-----CH(Switzerland) UDID2 / Position1, TW(Taiwan) UDID2/Position 1-2
---------------------------------------------------------------------------------------------------------

SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='RU'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='RU'AND UD.UdefData IS NOT NULL THEN UD.UdefData 
				WHEN IH.OrigCountry ='HK'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='HK'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData,1,6)
				WHEN IH.OrigCountry ='CH'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='CH'AND UD.UdefData IS NOT NULL THEN UD.UdefData 
				WHEN IH.OrigCountry ='TW'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='TW'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData,1,2) 
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 2
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTER1', 'ESTE1H', 'ESTE98', 'ESTE1W')
	AND IH.OrigCountry IN('RU','HK', 'CH', 'TW')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='41-Update Text6 Based On Text2 for RU, HK, CH, TW', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR


------------------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2  for MX(Mexico) UDID3/Position 1-25
---------------------------------------------------------------------------------------------------------

SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='MX'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='MX'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData,1,25)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 3
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE80')
	AND IH.OrigCountry = 'MX'

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='42-Update Text6 Based On Text2 for MX', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

--------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2  for BE(Belgium) UDID 6/position 1-2
--------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='BE'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='BE'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData,1,2)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 6
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE91')
	AND IH.OrigCountry = 'BE'

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='43-Update Text6 Based On Text2 for BE', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR


--------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2  for DE(Germany) UDID7/Position 1-4
--------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='DE'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='DE'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData,1,4)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 7
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ESTE94')
	AND IH.OrigCountry = 'DE'

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='44-Update Text6 Based On Text2 for DE', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR
------------------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2 for CN(China) UDID8-PART1 (ex: EL), 
-----GB(BreatBritain) Udid8 (part2-position1-2)
---------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='CN'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='CN'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.Udefdata, CHARINDEX('-',(UD.Udefdata),0)+1,2)
				WHEN IH.OrigCountry ='GB'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='GB'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.Udefdata, CHARINDEX(' ',(UD.Udefdata),0)+1,2) 
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 8
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	--AND CL.CustAddr1 in ('ESTE1C', 'ESTE90')
	AND IH.OrigCountry IN ('CN', 'GB')

EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='45-Update Text6 Based On Text2 for CN,  GB', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

------------------------------------------------------------------------------------------------------------------
-----Update Text6 with Brand based off POS Set in Text2 for MY(Malaysia) "UDID 8 PART 1( POSITION 3-4 )"
-----and Th(Thailand) UDID8Part1  position 9,
---------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text6  = CASE
				WHEN IH.OrigCountry ='MY'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='MY'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.Udefdata, CHARINDEX('-',(UD.Udefdata),0)+1,2)
				WHEN IH.OrigCountry ='TH'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='TH'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.Udefdata, CHARINDEX('-',(UD.Udefdata),0)+6,19)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 8
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ( 'ESTE1M', 'ESTE1T')
	AND IH.OrigCountry IN ('MY', 'TH')

EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='46-Update Text6 Based On Text2 for  MY, TH', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

---------------------------------------------------------------------------------------------------------
-----Update Text7 with Trip Purpose based off POS Set in Text2 for  AU(Australia) UDID 1 P 1/Position 1-2
---------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text7  = CASE
				WHEN IH.OrigCountry ='AU'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='AU'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 1
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='AU'
	AND CL.CustAddr1 in ('ESTE1A')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='47-Update Text7 Based On Text2 for AU', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR


---------------------------------------------------------------------------------------------------------
-----Update Text7 with Trip Purpose based off POS Set in Text2 for  MX(Mexico) UDID6/Position 1-25
---------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text7  = CASE
				WHEN IH.OrigCountry ='MX'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='MX'AND UD.UdefData IS NOT NULL THEN SUBSTRING(UD.UdefData, 1, 25)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 6
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='MX'
	AND CL.CustAddr1 in ('ESTE80')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='48-Update Text7 Based On Text2 for MX', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR



---------------------------------------------------------------------------------------------------------
-----Update Text7 with Trip Purpose based off POS Set in Text2 for  GB(Great Britain) udid3
---------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text7  = CASE
				WHEN IH.OrigCountry ='GB'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='GB'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 3
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='GB'
	AND CL.CustAddr1 in ('ESTE90')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='49-Update Text7 Based On Text2 for GB', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-----------------------------------------------------------------------------------------------------
-----Update Text10 with Full Fare based off POS Set in Text2 for  JP(Japan) UDID19
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text10  = CASE
				WHEN IH.OrigCountry ='JP'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='JP'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 19
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='JP'
	AND CL.CustAddr1 in ('ESTE1J')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='50-Update Text10 Based On Text2 for JP', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-----------------------------------------------------------------------------------------------------
-----Update Text11 with Air Reason based off POS Set in Text2 for  JP(Japan) UDID20
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text11  = CASE
				WHEN IH.OrigCountry ='JP'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='JP'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 20
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='JP'
	AND CL.CustAddr1 in ('ESTE1J')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='51-Update Text11 Based On Text2 for JP', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR


-----------------------------------------------------------------------------------------------------
-----Update Text11 with Air Reason based off POS Set in Text2 for  TR(Turkey) UDID5
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text11  = CASE
				WHEN IH.OrigCountry ='TR'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='TR'AND UD.UdefData IS NOT NULL THEN UD.UdefData
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 5
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='TR'
	AND CL.CustAddr1 in ('ESTETR')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='52-Update Text11 Based On Text2 for TR', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR

-----------------------------------------------------------------------------------------------------
-----Update Text12 with Position Name based off POS Set in Text2 for  MX(Mexico) UDID5/Position 1-25
-----------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

UPDATE CR
SET CR.Text12  = CASE
				WHEN IH.OrigCountry ='MX'AND UD.UdefData IS NULL   THEN 'Not Provided'
				WHEN IH.OrigCountry ='MX'AND UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,1,25) <> '' THEN  SUBSTRING(UD.UdefData,1,25)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
		AND ID.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.Client CL
	ON (CL.IataNum     = CR.Iatanum
	AND CL.ClientCode  = CR.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND UD.UdefNum     = 5
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND IH.OrigCountry ='MX'
	AND CL.CustAddr1 in ('ESTE80')

	EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName, 
	@LogStart=@TransStart, 
	@StepName='53-Update Text11 Based On Text2 for MX', 
	@BeginDate=@BeginIssueDate, 
	@EndDate=@LocalEndIssueDate, 
	@IataNum=@Iata, 
	@RowCount=@@ROWCOUNT, 
	@ERR=@@ERROR





SET @TransStart = getdate()
-------------------------------------------------------------------------------------
/*Added the following logic to update cr.Text14 - sq 3/13/2015
Updated logic for refunds outer join and refunds missing segments - sq 3/13/2015*/
----------------------------------------------------------------------------------------

----	See SF 06512840 -- Business and First Class were not updating because joins had:
----	ON (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierName 
----	Should be: ON (ALFOURCOSID.AirlineCode = ts.MINSegmentCarrierCode
----	So Pam S updating 6/9/2015
 
--------------------------
/*First Class Cabin*/
-------------------------
SET @TransStart = getdate()

update cr
set cr.Text14 = case WHEN alfourcosid.cabin is null THEN alfourcosidoth.cabin else alfourcosid.cabin end
FROM TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' 
 AND ALFOURCOSIDOTH.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' 
                                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = ts.MINSegmentCarrierCode
 AND ALFOURCOSID.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' 
                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 

WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case WHEN ALFOURCOSID.Cabin is null THEN ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'First'
   AND CR.Text14 = 'Not Provided'
   AND ID.IataNum IN ('ELAXTVL3')
   AND IH.ImportDt >= getdate()-14

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='54-Update Highest class flown - First', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
----------------------------
/*Business Class Cabin*/
----------------------------
SET @TransStart = getdate()

update cr
set cr.Text14 = case WHEN alfourcosid.cabin is null THEN alfourcosidoth.cabin else alfourcosid.cabin end
FROM TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = ts.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case WHEN ALFOURCOSID.Cabin is null THEN ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Business'
   AND CR.Text14 ='Not Provided'
   AND ID.IataNum IN ('ELAXTVL3')
   AND IH.ImportDt >= getdate()-14

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='55-Update Highest class flown - Business', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
-------------------------------
/*Premium Economy Class Cabin*/
-------------------------------
SET @TransStart = getdate()

update cr
set cr.Text14 = case WHEN alfourcosid.cabin is null THEN alfourcosidoth.cabin else alfourcosid.cabin end
FROM TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = ts.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case WHEN ALFOURCOSID.Cabin is null THEN ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Premium Economy'
   AND CR.Text14 ='Not Provided'
   AND ID.IataNum IN ('ELAXTVL3')
   AND IH.ImportDt >= getdate()-14

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='56-Update Highest class flown - Premium Economy', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
---------------------------------------------------------
/*Economy Class Cabin - includes 'Unclassified' cabin*/
---------------------------------------------------------
SET @TransStart = getdate()

update cr
set cr.Text14 = 'Economy'
FROM TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = ts.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case WHEN isnull(TS.MINInternationalInd,'D') = 'D' THEN 'Domestic' WHEN isnull(abs(ts.MINSegmentMileage),0) < 2500 THEN 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND case WHEN ALFOURCOSID.Cabin is null THEN ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end in ('Economy', 'Unclassified')
   AND TS.MinDestCityCode is not null
   AND CR.Text14 ='Not Provided'
   AND ID.IataNum IN ('ELAXTVL3')
   AND IH.ImportDt >= getdate()-14

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='57-Update Highest class flown - Economy', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
--------------------------------------------------------------------------------------------------------
/*Update refunds in dba.InvoiceDetail that do not have corresponding rows in dba.transeg by linking
 the refund document number back to the original debit transaction and using the value in cr.Text14*/
-------------------------------------------------------------------------------------------------------
SET @TransStart = getdate()

update cr
set cr.Text14 = crorig.Text14
FROM TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH  
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID  ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 

INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail IDOrig ON (IDOrig.Recordkey <> ID.Recordkey and IDOrig.IataNum = ID.IataNum AND IDOrig.ClientCode = ID.ClientCode and ID.documentnumber = IDOrig.DocumentNumber and IDOrig.RefundInd not in ('Y','P') ) 
 INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CROrig ON ( CROrig.RecordKey = IDOrig.RecordKey AND CROrig.IataNum = IDOrig.IataNum AND CROrig.SeqNum = IDOrig.SeqNum AND CROrig.ClientCode = IDOrig.ClientCode) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND CR.Text14 is null
   AND ID.IataNum IN ('ELAXTVL3')
   AND IH.ImportDt >= getdate()-14
   and id.refundind in ('Y','P')
   and cr.Text14 = 'Not Provided'
   and not exists (select 1 from dba.transeg ts
							where ts.recordkey = id.recordkey
							and ts.IataNum = id.IataNum
							and ts.seqnum = id.seqnum
							)
EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='58-Update Highest class flown - Refunds', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR
  
 /*End CR.Text14 update for highest cabin flown*/

----------------------------------------------------------------
--Update NUM1 with Farecompare 1 and NUM2 with Farecompare2
----------------------------------------------------------------
-----------------------------------
--Update NUM1 with FareCompare1
-----------------------------------
SET @TransStart = getdate()
UPDATE CR
SET Num1 = ID.Farecompare1
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
	AND ID.InvoiceDate = CR.InvoiceDate)
WHERE IH.ImportDt = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.Num1 IS NULL
	AND ID.FareCompare1 IS NOT NULL

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='59-Update Num1 with FC1', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
--------------------------------
--Update NUM2 with farecompare2
---------------------------------
SET @TransStart = getdate()

UPDATE CR
SET Num2 = ID.Farecompare2
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.InvoiceDetail ID
	ON (ID.IataNum     = CR.IataNum
	AND ID.ClientCode  = CR.ClientCode
	AND ID.RecordKey   = CR.RecordKey
	AND ID.SeqNum	   = CR.SeqNum
	AND ID.InvoiceDate = CR.InvoiceDate)
WHERE IH.ImportDt = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND CR.Num1 IS NULL
	AND ID.FareCompare2 IS NOT NULL

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='60-Update Num2 with FC2', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------
----	END STANDARD FC1 AND FC2 UPDATES
--------------------------------------------

----	Check if ReasonCodes need to be changed

------------------------------------------------
----AIR REASON CODES
----PER SF Case 06395092 Added 05/12/2015 Vijay Kodi
------------------------------------------------------
	SET @TransStart = getdate()

	Update ID
	Set  ReasonCode1 = CASE 
						WHEN IH.OrigCountry ='AT' and  ReasonCode1 ='C' Then 'AT'
						WHEN IH.OrigCountry ='BR' and  ReasonCode1 ='C' Then 'AC'
						WHEN IH.OrigCountry ='BR' and  ReasonCode1 ='R' Then 'RR'
						WHEN IH.OrigCountry ='BR' and  ReasonCode1 ='S' Then 'FS'
						WHEN IH.OrigCountry ='BR' and  ReasonCode1 ='T' Then 'AR'			
						WHEN IH.OrigCountry ='CZ' and  ReasonCode1 ='C' Then 'AT'
						WHEN IH.OrigCountry ='DE' and  ReasonCode1 ='C' Then 'NP'	
						WHEN IH.OrigCountry ='DE' and  ReasonCode1 ='R' Then 'RL'
						WHEN IH.OrigCountry ='MX' and  ReasonCode1 ='AC' Then 'NR'			
						WHEN IH.OrigCountry ='TR' and  ReasonCode1 ='R' Then 'AR'
						WHEN IH.OrigCountry ='UK' and  ReasonCode1 ='C' Then 'NP'
						WHEN IH.OrigCountry ='UK' and  ReasonCode1 ='E' Then 'NF'
						WHEN IH.OrigCountry ='VN' and  ReasonCode1 ='HH' Then 'EZ'
						WHEN IH.OrigCountry IS NOT NULL and ReasonCode1 ='F' Then 'D'
						WHEN IH.OrigCountry IS NOT NULL and ReasonCode1 ='PP' Then 'RP'
						WHEN IH.OrigCountry IS NOT NULL and ReasonCode1 ='PS' Then 'IP'
						ELSE ReasonCode1  
						END
	FROM dba.InvoiceDetail ID
	INNER JOIN dba.InvoiceHeader IH
		ON (IH.IataNum     = ID.IataNum
		AND IH.ClientCode  = ID.ClientCode
		AND IH.RecordKey   = ID.RecordKey  
		AND IH.InvoiceDate = ID.InvoiceDate)
	WHERE 	IH.IMPORTDT = @MaxImportDt
			AND IH.IataNum = @IataNum
			AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
			AND ID.IataNum = @IataNum
			AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate

  EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='61-Update Air Reason Codes', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR

----/////////////////////////////////////////////////////////////////////////

/***********************************************************************  
 COMPARE FC1 (FULL/(HIGH) FARE) TO TOTALAMT, UPDATE FC1 = TOTALAMT  
************************************************************************/ 
------------------------------
--Update Full Fare Compare FC1
------------------------------
 -------------------------------------------
 ----WHEN TOTALAMT IS A POSITIVE    
---------------------------------------------
    SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare1 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND TotalAmt > 0 
        AND FareCompare1 < TotalAmt 
		
EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='62-Update FC1 High Fare < TotalAmt when Positive', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-------------------------------------------- 
    ----WHEN TOTALAMT IS NEGATIVE
---------------------------------------------
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare1 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND TotalAmt < 0 
        AND FareCompare1 > TotalAmt 
		   
EXEC dbo.sp_LogProcErrors 
@ProcedureName=@ProcName, 
@LogStart=@TransStart, 
@StepName='63-Update FC1 High Fare > TotalAmt when Negative', 
@BeginDate=@LocalBeginIssueDate, 
@EndDate=@LocalEndIssueDate, 
@IataNum=@Iata, 
@RowCount=@@ROWCOUNT, 
@ERR=@@ERROR 

---------------------------------------------------------
 -----WHEN FARECOMPARE1 IS NULL OR '0'  
----------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare1 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND Isnull(FareCompare1, '0') = '0' 
		   
EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='64- FC1 is Null or 0 Then FC1 = TotalAmt', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

----------------------------------------------------------- 
     ------WHEN TOTALAMT =0 AND FARECOMPARE1 <> 0  
-----------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare1 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND TotalAmt = 0 
        AND FareCompare1 <> 0 
		
EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='65-If FC1 <> 0 and TotalAmt = 0', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

/*******************************************************************  
 COMPARE FC2 (LOW FARE) TO TOTALAMT, UPDATE FC2 = TOTALAMT  
*******************************************************************/ 
----------------------------------------
--Updating Low Fare Compare FC2
----------------------------------------
------------------------------------------  
----WHEN TOTALAMT IS POSITIVE    
------------------------------------------ 
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare2 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND TotalAmt > 0 
        AND FareCompare2 > TotalAmt 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='66-FC2 Low Fare > TotalAmt when Positive', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------------------
     ----WHEN TOTALAMT IS NEGATIVE   
--------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare2 = TotalAmt 
FROM   dba.InvoiceDetail ID
       INNER JOIN dba.InvoiceHeader IH
               ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
       AND IH.IataNum= @IataNum
       AND ID.IataNum= @IataNum
       AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
       AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
       AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
       AND VoIDInd = 'N' 
       AND TotalAmt < 0 
       AND FareCompare2 < TotalAmt 
	
EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='67-FC2 Low Fare < TotalAmt when Negative', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

------------------------------------------------------------
     ----WHEN FARECOMPARE2 IS NULL OR '0'  
-------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare2 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND Isnull(FareCompare2, '0') = '0' 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='68-FC2 is Null or 0 then FC2 = TotalAmt', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-------------------------------------------------------
     ----WHEN TOTALAMT =0 AND FARECOMAPARE2 <> 0
-------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE ID
SET    FareCompare2 = TotalAmt 
FROM   dba.InvoiceDetail ID
        INNER JOIN dba.InvoiceHeader IH
                ON ( IH.IataNum= ID.IataNum
                    AND IH.ClientCode = ID.ClientCode 
                    AND IH.RecordKey= ID.RecordKey
                    AND IH.InvoiceDate = ID.InvoiceDate ) 
WHERE  IH.ImportDt = @MaxImportDt 
        AND IH.IataNum= @IataNum
        AND ID.IataNum= @IataNum
        AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND ID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
        AND VendorType IN ( 'BSP', 'NONBSP', 'RAIL' ) 
        AND VoIDInd = 'N' 
        AND TotalAmt = 0 
        AND FareCompare2 <> 0 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='69-FC2 = TotalAmt if TotalAmt = 0', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

/*********************************************
----END STANDARD FC1 AND FC2 UPDATES  
**********************************************/

-- Check if ReasonCodes need to be changed  
--/////////////////////////////////////////////////////////////////////////  
-- /* BEGIN PRE-HNN HOTEL CLEANUP -----*/

SET @TransStart = Getdate() 

EXEC dbo.sp_LogProcErrors 
    @ProcedureName=@ProcName, 
    @LogStart=@TransStart, 
    @StepName='70-BEGIN HTL edits', 
    @BeginDate=@LocalBeginIssueDate, 
    @EndDate= @LocalEndIssueDate, 
    @IataNum=@Iata, 
    @RowCount=@@ROWCOUNT, 
    @ERR=@@ERROR   
--------------------------------------------------------------
--Removing beginning and ending spaces in all hotel fields
--------------------------------------------------------------
--------------------------
/*htlpropertyname*/
--------------------------
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
        AND Substring(StagHTL.htlpropertyname, 1, 1) = ' ' 
		AND StagHTL.masterid IS NULL 
        AND StagHTL.InvoiceDate > '2011-12-31' 

EXEC dbo.sp_LogProcErrors 
    @ProcedureName=@ProcName, 
    @LogStart=@TransStart, 
    @StepName='71-Remove Begin-End Spaces HTLpropertyname', 
    @BeginDate=@LocalBeginIssueDate, 
    @EndDate= @LocalEndIssueDate, 
    @IataNum=@Iata, 
    @RowCount=@@ROWCOUNT, 
    @ERR=@@ERROR 
	  
--------------------------
/*HtlAddr1*/
--------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htladdr1 = Rtrim(Ltrim(StagHTL.htladdr1)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.htladdr1, 1, 1) = ' ' 
	   AND StagHTL.masterid IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='72-Remove Begin-End Spaces HtlAddr1', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
SET @TransStart = Getdate() 

--------------------------
/*HtlAddr2*/
--------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htladdr2 = Rtrim(Ltrim(StagHTL.htladdr2)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.htladdr2, 1, 1) = ' '
	   AND StagHTL.masterid IS NULL  

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='73-Remove Begin-End Spaces HtlAddr2', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

------------------------
/*HtlAddr3*/
-------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htladdr3 = Rtrim(Ltrim(StagHTL.htladdr3)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.htladdr3, 1, 1) = ' ' 
	   AND StagHTL.masterid IS NULL

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='74-Remove Begin-End Spaces HtlAddr3', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------
/*HtlChainCode*/
--------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlchaincode = Rtrim(Ltrim(StagHTL.htlchaincode)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.htlchaincode, 1, 1) = ' ' 
	   AND StagHTL.masterid IS NULL

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='75-Remove Begin-End Spaces HtlChainCode', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------
/*HtlCountryCode*/
--------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlcountrycode = Rtrim(Ltrim(StagHTL.htlcountrycode)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.HtlCountryCode, 1, 1) = ' ' 
	   AND StagHTL.masterid IS NULL

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='76-Remove Begin-End Spaces HtlCountryCode', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------
/*HtlPhone*/
--------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlphone = Rtrim(Ltrim(StagHTL.htlphone)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.htlphone, 1, 1) = ' ' 
	   AND StagHTL.masterid IS NULL

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='77-Remove Begin-End Spaces HtlCountryCode', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
  
-------------------------
/*HtlPostalCode*/
------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlpostalcode = Rtrim(Ltrim(StagHTL.htlpostalcode)) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND Substring(StagHTL.htlpostalcode, 1, 1) = ' ' 
	   AND StagHTL.masterid IS NULL

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='78-Remove Begin-End Spaces HtlPostalCode', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------
--Update City Name to NULL if start with '.'
--------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htladdr3 = htlcityname 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname LIKE '.%' 
       AND StagHTL.htladdr3 IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='79-Update HtlAddr3 to HtlCityName', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = NULL 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname LIKE '.%' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='80-Update HtlCityName to null', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------------------------
--Removing unseen characters in htlpropertyname and htladdr1
--------------------------------------------------------------
UPDATE StagHTL
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',','')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
   ,HtlAddr2 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr2,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
   ,HtlAddr3 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr3,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
FROM dba.Hotel StagHTL
INNER JOIN dba.InvoiceHeader StagIH 
	ON (StagIH.IataNum     = StagHTL.IataNum
	AND StagIH.RecordKey   = StagHTL.RecordKey  
	AND StagIH.InvoiceDate = StagHTL.InvoiceDate)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.IataNum = @IataNum
	AND StagHTL.InvoiceDate between @FirstInvDate AND @LastInvDate

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='81-Update htlpropertyname and Address', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


-------------------------------------------------------------------------------------------- 
----  Move HtlAddr2 data to HtlAddr1 if HtlAddr1 IS NULL AND HtlAddr2 IS NOT NULL 
------------------------------------------------------------------------------------------- 
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htladdr1 = htladdr2, 
       htladdr2 = NULL 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htladdr1 IS NULL 
       AND StagHTL.htladdr2 IS NOT NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='82-Move htladdr2 to HtlAddr1 when null', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htladdr2 = NULL 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htladdr2 = htladdr1 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='83-HtlAddr2 to Null if HtlAddr1=HtlAddr2 ', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------------------------
--Update Master ID to -1 if property name and address is NULL
--------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    masterid = -1 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND ( HtlPropertyName LIKE 'OTHER%HOTELS%' 
              OR HtlPropertyName LIKE '%NONAME%' 
              OR HtlPropertyName IS NULL 
              OR HtlPropertyName = '' ) 
       AND ( HtlAddr1 IS NULL 
              OR HtlAddr1 = '' ) 
		AND StagHTL.Masterid IS NULL

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='84-MasterID to -1', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


----------------------------------------------------------------- 
------  NEVER USE CITY TABLE FOR HOTEL UPDATES !!!!! 
------  Use Master Zip Code table to update state AND country code if Null 
------------------------------------------------------------------ 
----- First, Updates for Canada based on Zip Codes ------- 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlstate = CASE 
                            WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                            ELSE StagHTL.htlstate 
                          END, 
       StagHTL.htlcountrycode = CASE 
                                  WHEN StagHTL.htlcountrycode <> 'CA' THEN 'CA' 
                                  ELSE StagHTL.htlcountrycode 
                                END 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND ( StagHTL.htlpostalcode LIKE 'L%' 
              OR StagHTL.htlpostalcode LIKE 'N%' ) 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlcitycode IN ( 'BUF', 'DTW' ) 
       AND StagHTL.masterid IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='85-BUF DTW  -Zip in CA -Not in US', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlcityname = CASE 
                               WHEN StagHTL.htlcityname <> Upper('Niagra Falls') 
                             THEN 
                               Upper('Niagra Falls') 
                               ELSE StagHTL.htlcityname 
                             END, 
       StagHTL.htlstate = CASE 
                            WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                            ELSE StagHTL.htlstate 
                          END, 
       StagHTL.htlcountrycode = CASE 
                                  WHEN StagHTL.htlcountrycode <> 'CA' THEN 'CA' 
                                  ELSE StagHTL.htlcountrycode 
                                END 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.htlpostalcode IN ( 'L2G3V9', 'L2G 3V9' ) 
       AND StagHTL.masterid IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='86-Zip for Niagra Falls, CA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

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
                                  WHEN StagHTL.htlcountrycode <> 'CA' THEN 'CA' 
                                  ELSE StagHTL.htlcountrycode 
                                END 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.htlpostalcode = 'L0S 1J0' 
       AND StagHTL.masterid IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='87-Zip for Niagara On The Lake, CA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

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
                                  WHEN StagHTL.htlcountrycode <> 'CA' THEN 'CA' 
                                  ELSE StagHTL.htlcountrycode 
                                END 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.htlpostalcode IN ( 'N9A 1B2', 'N9A 7H7', 'N9C 2L6' ) 
       AND StagHTL.masterid IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='88-Zip for Windsor CA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    StagHTL.htlcityname = CASE 
                               WHEN StagHTL.htlcityname <> Upper('Point Edward') 
                             THEN 
                               Upper('Point Edward') 
                               ELSE StagHTL.htlcityname 
                             END, 
       StagHTL.htlstate = CASE 
                            WHEN StagHTL.htlstate <> 'ON' THEN 'ON' 
                            ELSE StagHTL.htlstate 
                          END, 
       StagHTL.htlcountrycode = CASE 
                                  WHEN StagHTL.htlcountrycode <> 'CA' THEN 'CA' 
                                  ELSE StagHTL.htlcountrycode 
                                END 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.htlpostalcode IN ( 'N7T 7W6' ) 
       AND StagHTL.masterid IS NULL 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='89-Zip for Point Edward CA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
----------------------------------------------------------------------
------M5V 2G5 = TORONTO CA if ever need to add a step for this one 
---- END Updates for Canada based on Zip Code ------------- 
----------------------------------------------------------------------


------------------------------------------------------------------------------------- 
---- AFTER Canada updates, BEGIN Updates for US States AND Cities based on Zip Codes 
------------------------------------------------------------------------------------- 
---- 1st, Remove HtlStateCode if not in these countries: ('US','CA','AU','BR') 
-------------------------------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlState = NULL 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlstate IS NOT NULL 
       AND StagHTL.htlcountrycode NOT IN ( 'US', 'CA', 'AU', 'BR' ) 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='90-Null HtlState if not US,CA,AU,BR', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

------------------------------------------------------------------------------------------
----  2nd, Where Countrycode IS NULL, update to US based on Htlstate AND matching zip code 
---------------------------------------------------------------------------------------------

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlCountryCode = 'US' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
       INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
               ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                    AND zp.primaryrecord = 'p' ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE 
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

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='91-HtlCountry to US based on zip', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-----------------------------------------------------
---- Where State code IS NULL or wrong for US ----- 
-------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlState = zp.state 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
       INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
               ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                    AND zp.primaryrecord = 'p' ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE 
           '[0-9][0-9][0-9][0-9][0-9]' 
       AND StagHTL.htlcountrycode = 'US' 
       AND Isnull(StagHTL.htlstate, '') <> zp.state 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='92-HtlState from US Zip', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

----------------------------------------------------
----- Where city name is wrong for US cities ---- 
------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlCityName = Upper(zp.city) 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
       INNER JOIN ttxsasql03.ttxcentral.dba.uszipcodesdeluxe zp 
               ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                    AND zp.primaryrecord = 'p' ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE 
           '[0-9][0-9][0-9][0-9][0-9]' 
       AND StagHTL.htlcountrycode = 'US' 
       AND Isnull(StagHTL.htlcityname, '') <> zp.city 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='93-CityName by US Zip', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
-------------------------------------------------
---- END US updates based on Zip Code ------- 
---------------------------------------------------

-------------------------------------------------------------------------------- 
----Correct CityName to Paris where zip codes begin with 75 + 3 digit region 
--------------------------------------------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlCityName = 'PARIS', 
       HtlState = NULL 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'FR' 
       AND StagHTL.htlpostalcode LIKE '75[0-9][0-9][0-9]' 
       AND StagHTL.htlcityname <> 'PARIS' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='94-CityName to Paris by Zip', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------
---- For GB based on Zip Codes ---- 
--------------------------------------

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlState = NULL, 
       HtlCityName = CASE 
                       WHEN htlpostalcode IN ( 'RG1 1DP', 'RG1 1JX', 'RG11JX', 
                                               'RG1 8DB', 
                                               'RG2 0FL', 'RG2 0GQ' ) 
                            AND htlcityname <> 'READING' THEN 'READING' 
                       WHEN htlpostalcode IN ( 'RG21 3DR' ) 
                            AND htlcityname <> 'BASINGSTOKE' THEN 'BASINGSTOKE' 
                       WHEN htlpostalcode IN ( 'W1G 0PG', 'W1B 2QS', 'W1G 9BL', 
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
                            AND htlcityname <> 'Hounslow' THEN Upper('Hounslow') 
                       ELSE htlcityname 
                     END 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'GB' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='95-For GB CityName based on Zip Codes', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

----------------------------------------------------
----  END Updates based on Zip Codes ----------- 
----------------------------------------------------

-------------------------------------------
---- BEGIN Misc Updaes for Hotels 
-------------------------------------------
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = 'AR' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlstate IS NULL 
       AND StagHTL.htladdr2 = 'ARKANSAS' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='96-ARKANSAS', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = 'CA' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlstate <> 'CA' 
       AND StagHTL.htladdr2 = 'CALIFORNIA' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='97-CALIFORNIA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = 'GA' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlstate <> 'GA' 
       AND StagHTL.htladdr2 = 'GEORGIA' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='98-GEORGIA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = 'MA' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlstate <> 'MA' 
       AND StagHTL.htladdr2 = 'MASSACHUSETTS' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='99-MASSACHUSETTS', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = 'LA' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlstate <> 'LA' 
       AND StagHTL.htladdr2 = 'LOUISIANA' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='100-LOUISIANA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = 'AZ' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htlstate <> 'AZ' 
       AND StagHTL.htladdr2 = 'ARIZONA' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='101-ARIZONA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = NULL, 
       HtlCountryCode = 'CA' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htladdr3 = 'CANADA' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='102-CANADA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = NULL, 
       htlcountrycode = 'GB' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htladdr3 = 'UNITED KINGDOM' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='103-UNITED KINGDOM', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = NULL, 
       htlcountrycode = 'KR' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htladdr3 = 'SOUTH KOREA' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='104-SOUTH KOREA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlstate = NULL, 
       htlcountrycode = 'JP' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcountrycode = 'US' 
       AND StagHTL.htladdr3 = 'JAPAN' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='105-JAPAN', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------- 
SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = 'NEW DELHI' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname = 'DELHI' 
       AND StagHTL.htlcountrycode = 'IN' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='106-New Delhi', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = 'NEW YORK', 
       htlstate = 'NY' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND ( StagHTL.htlcityname = 'NEW YORK NY' 
              OR StagHTL.htlcityname = 'NEW YORK, NY' ) 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='107-NEW YORK', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    HtlCityName = 'WASHINGTON', 
       HtlState = 'DC' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname = 'WASHINGTON DC' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='108-Washington DC', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = 'HERTOGENBOSCH' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
       AND StagHTL.htlpropertyname LIKE '%MOEVENPICK HOTEL%' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='109-HERTOGENBOSCH- MOEVENPICK HOTEL', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = 'NEW YORK' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
       AND StagHTL.htlpropertyname LIKE '%OAKWOOD CHELSEA%' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='110-NEW YORK-OAKWOOD CHELSEA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = 'NEW YORK' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
       AND StagHTL.htlpropertyname LIKE '%LONGACRE HOUSE%' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='111-NEW YORK -%LONGACRE HOUSE%', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

UPDATE StagHTL 
SET    htlcityname = 'BARCELONA' 
FROM   dba.hotel StagHTL 
       INNER JOIN dba.invoiceheader StagIH 
               ON ( StagIH.iatanum = StagHTL.iatanum 
                    AND StagIH.recordkey = StagHTL.recordkey 
                    AND StagIH.invoicedate = StagHTL.invoicedate ) 
WHERE  StagIH.importdt = @MaxImportDt 
       AND StagIH.iatanum = @IataNum 
       AND StagIH.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.iatanum = @IataNum 
       AND StagHTL.invoicedate BETWEEN @FirstInvDate AND @LastInvDate 
       AND StagHTL.masterid IS NULL 
       AND StagHTL.htlcityname NOT LIKE '[a-z]%' 
       AND StagHTL.htlpropertyname LIKE '%HOTLE PUNTA PALMA%' 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='112-BARCELONA- HOTLE PUNTA PALMA', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='113-End htl edits', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


/**** DO NOT INSERT INTO PRODUCTION UNTIL DATA HAS BEEN VALIDATE *************/  
------------------------------------------------------------------------  
------------------------------------------------------------------------  
/*********************************************************************************** 
----BEGIN DELETE FROM PRODUCTION TABLES, LEAVING INVOICEHEADER LAST DUE TO JOINS 
***********************************************************************************/
SET @TransStart = Getdate() 

DELETE ProdID
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ProdID
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH 
	ON (ProdIH.IataNum     = ProdID.IataNum
	AND ProdIH.ClientCode  = ProdID.ClientCode
	AND ProdIH.RecordKey   = ProdID.RecordKey
	AND ProdIH.InvoiceDate = ProdID.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdID.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='114-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceDetail', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
--------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdTS
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.TranSeg ProdTS
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdTS.IataNum
	AND ProdIH.ClientCode  = ProdTS.ClientCode
	AND ProdIH.RecordKey   = ProdTS.RecordKey
	AND ProdIH.InvoiceDate = ProdTS.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdTS.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='115-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.TranSeg', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
--------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdCar
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Car ProdCar
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdCar.IataNum
	AND ProdIH.ClientCode  = ProdCar.ClientCode
	AND ProdIH.RecordKey   = ProdCar.RecordKey
	AND ProdIH.InvoiceDate = ProdCar.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdCar.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='116-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Car', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-----------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdHtl
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Hotel ProdHtl
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdHTL.IataNum
	AND ProdIH.ClientCode  = ProdHTL.ClientCode
	AND ProdIH.RecordKey   = ProdHTL.RecordKey
	AND ProdIH.InvoiceDate = ProdHTL.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdHTL.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='117-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Hotel', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

------------------------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdPay
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Payment ProdPay
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdPAY.IataNum
	AND ProdIH.ClientCode  = ProdPAY.ClientCode
	AND ProdIH.RecordKey   = ProdPAY.RecordKey
	AND ProdIH.InvoiceDate = ProdPAY.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdPAY.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='118-Delete TTXPASQL09.TMAN503_ESTEELAUDER.dba.Payment', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


-----------------------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdTax
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Tax ProdTax
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdTax.IataNum
	AND ProdIH.ClientCode  = ProdTax.ClientCode
	AND ProdIH.RecordKey   = ProdTax.RecordKey
	AND ProdIH.InvoiceDate = ProdTax.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdTax.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='119-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Tax', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdUD
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Udef ProdUD
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdUD.IataNum
	AND ProdIH.ClientCode  = ProdUD.ClientCode
	AND ProdIH.RecordKey   = ProdUD.RecordKey
	AND ProdIH.InvoiceDate = ProdUD.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdUD.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='120-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Udef', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

-------------------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdCR
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.ComRmks ProdCR
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdCR.IataNum
	AND ProdIH.ClientCode  = ProdCR.ClientCode
	AND ProdIH.RecordKey   = ProdCR.RecordKey
	AND ProdIH.InvoiceDate = ProdCR.InvoiceDate)
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdCR.IataNum = @IataNum

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='121-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.ComRmks', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

--------------------------------------------------------------------------------
SET @TransStart = Getdate() 

DELETE ProdIH
FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='122-Delete TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
------------------------------------------------------------------------------
--Insert data into customer production database from customer staging database
------------------------------------------------------------------------------

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader 
SELECT * 
FROM  TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND IH.RecordKey+ IH.IataNum 
		NOT IN (SELECT ProdIH.RecordKey+ProdIH.IataNum
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader ProdIH
				WHERE ProdIH.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='123-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.InvoiceHeader', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
 @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail 
SELECT ID.* 
FROM  TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = ID.IataNum
	AND IH.ClientCode  = ID.ClientCode
	AND IH.RecordKey   = ID.RecordKey  
	AND IH.InvoiceDate = ID.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.RecordKey+ID.IataNum+CONVERT(VARCHAR,ID.SeqNum) 
		NOT IN (SELECT ProdID.RecordKey+ProdID.IataNum+CONVERT(VARCHAR,ProdID.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ProdID
				WHERE ProdID.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='124-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Invoicedetail', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.TranSeg 
SELECT TS.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.TranSeg TS
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = TS.IataNum
	AND IH.ClientCode  = TS.ClientCode
	AND IH.RecordKey   = TS.RecordKey  
	AND IH.InvoiceDate = TS.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.IataNum = @IataNum
	AND TS.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.RecordKey+TS.IataNum+CONVERT(VARCHAR,TS.SeqNum)
		NOT IN (SELECT ProdTS.RecordKey+ProdTS.IataNum+CONVERT(VARCHAR,ProdTS.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.TranSeg ProdTS
				WHERE ProdTS.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='125-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Transeg', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Car 
SELECT CAR.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Car CAR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CAR.IataNum
	AND IH.ClientCode  = CAR.ClientCode
	AND IH.RecordKey   = CAR.RecordKey  
	AND IH.InvoiceDate = CAR.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CAR.IataNum = @IataNum
	AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND Car.RecordKey+Car.IataNum+CONVERT(VARCHAR,Car.SeqNum) 
		NOT IN (SELECT ProdCar.RecordKey+ProdCar.IataNum+CONVERT(VARCHAR,ProdCar.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Car ProdCar
				WHERE ProdCar.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='126-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Car', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Hotel 
SELECT HTL.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Hotel HTL
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = HTL.IataNum
	AND IH.ClientCode  = HTL.ClientCode
	AND IH.RecordKey   = HTL.RecordKey  
	AND IH.InvoiceDate = HTL.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND HTL.IataNum = @IataNum
	AND HTL.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND HTL.RecordKey+HTL.IataNum+CONVERT(VARCHAR,HTL.SeqNum)
		NOT IN (SELECT ProdHTL.RecordKey+ProdHTL.IataNum+CONVERT(VARCHAR,ProdHTL.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Hotel ProdHtl
				WHERE ProdHTL.IataNum = @IataNum) 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='127-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Hotel', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Payment 
SELECT PAY.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Payment PAY
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = PAY.IataNum
	AND IH.ClientCode  = PAY.ClientCode
	AND IH.RecordKey   = PAY.RecordKey  
	AND IH.InvoiceDate = PAY.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND PAY.IataNum = @IataNum
	AND PAY.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND PAY.RecordKey+PAY.IataNum+CONVERT(VARCHAR,PAY.SeqNum)
		NOT IN (SELECT ProdPAY.RecordKey+ProdPAY.IataNum+CONVERT(VARCHAR,ProdPAY.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Payment ProdPAY
				WHERE ProdPAY.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='128-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.dba.Payment', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Tax 
SELECT TAX.* 
FROM  TTXSASQL03.TMAN503_ESTEELAUDER.dba.Tax TAX
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = TAX.IataNum
	AND IH.ClientCode  = TAX.ClientCode
	AND IH.RecordKey   = TAX.RecordKey  
	AND IH.InvoiceDate = TAX.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TAX.IataNum = @IataNum
	AND TAX.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TAX.RecordKey+TAX.IataNum+CONVERT(VARCHAR,TAX.SeqNum)
	NOT IN (SELECT ProdTAX.RecordKey+ProdTAX.IataNum+CONVERT(VARCHAR,ProdTAX.SeqNum) 
	FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.TAX ProdTAX
	WHERE ProdTAX.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='129-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Tax', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.udef 
SELECT UD.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.udef UD
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = UD.IataNum
	AND IH.ClientCode  = UD.ClientCode
	AND IH.RecordKey   = UD.RecordKey  
	AND IH.InvoiceDate = UD.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND UD.IataNum = @IataNum
	AND UD.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND UD.RecordKey+UD.IataNum+CONVERT(VARCHAR,UD.SeqNum)
		NOT IN (SELECT ProdUD.RecordKey+ProdUD.IataNum+CONVERT(VARCHAR,ProdUD.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Udef ProdUD
				WHERE ProdUD.IataNum = @IataNum)
    
EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='130-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.udef', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks 
SELECT CR.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.RecordKey+CR.IataNum+CONVERT(VARCHAR,CR.SeqNum)
		NOT IN (SELECT ProdCR.RecordKey+ProdCR.IataNum+CONVERT(VARCHAR,ProdCR.SeqNum) 
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.ComRmks ProdCR
				WHERE ProdCR.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='131-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.ComRmks', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

SET @TransStart = Getdate() 

INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.client 
SELECT DISTINCT CL.* 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.client CL
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CL.IataNum
	AND IH.ClientCode  = CL.ClientCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.ClientCode+CL.IataNum
		NOT IN (SELECT ProdCL.ClientCode+ProdCL.IataNum
				FROM TTXPASQL09.TMAN503_ESTEELAUDER.DBA.Client ProdCL
				WHERE ProdCL.IataNum = @IataNum)

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='132-INSERT TTXPASQL09.TMAN503_ESTEELAUDER.DBA.client', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 



------------------------------------------
--Data Enhancement Automation HNN Queries
------------------------------------------
DECLARE @HNNBeginDate DATETIME 
DECLARE @HNNEndDate DATETIME 

SELECT @HNNBeginDate = Min(issuedate), 
       @HNNEndDate = Max(issuedate) 
FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.hotel 
WHERE  masterid IS NULL 
       AND IataNum = 'ELAXTVL3' 
       AND issuedate > '2011-12-31' 

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[Sp_newdataenhancementrequest] 
  @DatamanRequestName = 'ELAXTVL3', 
  @Enhancement = 'HNN', 
  @Client = 'ESTEELAUDER', 
  @Delay = 15, 
  @Priority = NULL, 
  @Notes = NULL, 
  @Suspend = false, 
  @RunAtTime = NULL, 
  @BeginDate = @HNNBeginDate, 
  @EndDate = @HNNEndDate, 
  @DateParam1 = NULL, 
  @DateParam2 = NULL, 
  @TextParam1 = 'agency', 
  @TextParam2 = 'TTXPASQL09', 
  @TextParam3 = 'TMAN503_ESTEELAUDER', 
  @TextParam4 = 'DBA', 
  @TextParam5 = 'datasvc', 
  @TextParam6 = 'tman2009', 
  @TextParam7 = 'TTXSASQL03', 
  @TextParam8 = 'TTXCENTRAL', 
  @TextParam9 = 'DBA', 
  @TextParam10 = 'datasvc', 
  @TextParam11 = 'tman2009', 
  @TextParam12 = 'Push', 
  @TextParam13 = 'R', 
  @TextParam14 = NULL, 
  @TextParam15 = NULL, 
  @IntParam1 = NULL, 
  @IntParam2 = NULL, 
  @IntParam3 = NULL, 
  @IntParam4 = NULL, 
  @IntParam5 = NULL, 
  @BoolParam1 = NULL, 
  @BoolParam2 = NULL, 
  @BoolParam3 = NULL, 
  @BoolParam4 = NULL, 
  @BoolParam5 = NULL, 
  @BoolParam6 = NULL, 
  @BoolParam7 = NULL, 
  @BoolParam8 = NULL, 
  @BoolParam9 = NULL, 
  @BoolParam10 = NULL, 
  @CommandLineArgs = NULL 

SET @TransStart = Getdate() 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='133-END sending to DEA', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 
-------------------------------------------------------
SET @TransStart = Getdate() 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName =@ProcName, 
  @LogStart=@TransStart, 
  @StepName='Stored Procedure Ended', 
  @BeginDate=@LocalBeginIssueDate, 
  @EndDate=@LocalEndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 

GO

ALTER AUTHORIZATION ON [dbo].[sp_ELAXTVL3] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/1/2015 3:29:08 PM ******/
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

/****** Object:  Table [dba].[Payment]    Script Date: 7/1/2015 3:29:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Payment](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[PaymentSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[CurrCode] [varchar](3) NULL,
	[PaymentAmt] [float] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Payment] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/1/2015 3:29:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[InvoiceHeader](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](25) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNum] [varchar](20) NULL,
	[TicketingBranch] [varchar](10) NULL,
	[BookingBranch] [varchar](10) NULL,
	[TtlInvoiceAmt] [float] NULL,
	[TtlTaxAmt] [float] NULL,
	[TtlCommissionAmt] [float] NULL,
	[CurrCode] [varchar](30) NULL,
	[OrigCountry] [varchar](5) NULL,
	[SalesAgentID] [varchar](10) NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[GDSCode] [varchar](10) NULL,
	[BackOfficeID] [varchar](20) NULL,
	[IMPORTDT] [datetime] NULL,
	[TtlCO2Emissions] [float] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[JobInstanceId] [varchar](50) NULL,
	[IsItineraryProcessed] [bit] NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CLIQCID] [varchar](100) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CLIQUSER] [varchar](100) NULL
 CONSTRAINT [PK_InvoiceHeader_1] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/1/2015 3:29:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceDetail](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
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
	[Mileage] [float] NULL,
	[Routing] [varchar](120) NULL,
	[DaysAdvPurch] [smallint] NULL,
	[AdvPurchGroup] [varchar](10) NULL,
	[TrueTktCount] [int] NULL,
	[TripLength] [float] NULL,
	[ExchangeInd] [varchar](1) NULL,
	[OrigExchTktNum] [varchar](15) NULL,
	[Department] [varchar](40) NULL,
	[ETktInd] [varchar](1) NULL,
	[ProductType] [varchar](20) NULL,
	[TourCode] [varchar](15) NULL,
	[EndorsementRemarks] [varchar](60) NULL,
	[FareCalcLine] [varchar](255) NULL,
	[GroupMult] [smallint] NULL,
	[OneWayInd] [varchar](1) NULL,
	[PrefTktInd] [varchar](1) NULL,
	[HotelNights] [float] NULL,
	[CarDays] [float] NULL,
	[OnlineBookingSystem] [varchar](20) NULL,
	[AccommodationType] [varchar](10) NULL,
	[AccommodationDescription] [varchar](255) NULL,
	[ServiceType] [varchar](10) NULL,
	[ServiceDescription] [varchar](255) NULL,
	[ShipHotelName] [varchar](255) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[IntlSalesInd] [varchar](4) NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[RefundInd] [varchar](1) NULL,
	[OriginalInvoiceNum] [varchar](20) NULL,
	[BranchIataNum] [varchar](8) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[TicketingAgentID] [varchar](10) NULL,
	[OriginCode] [varchar](10) NULL,
	[DestinationCode] [varchar](10) NULL,
	[TktCO2Emissions] [float] NULL,
	[CCMatchedRecordKey] [varchar](100) NULL,
	[CCMatchedIataNum] [varchar](8) NULL,
	[ACQMatchedInd] [varchar](1) NULL,
	[ACQMatchedRecordKey] [varchar](100) NULL,
	[ACQMatchedIataNum] [varchar](8) NULL,
	[CarrierString] [varchar](50) NULL,
	[ClassString] [varchar](50) NULL,
	[CRMatchedInd] [varchar](1) NULL,
	[CRMatchedRecordKey] [varchar](100) NULL,
	[CRMatchedIataNum] [varchar](8) NULL,
	[LastImportDt] [datetime] NULL,
	[GolUpdateDt] [datetime] NULL,
	[OrigTktAmt] [float] NULL,
	[TktWasExchangedInd] [varchar](1) NULL,
	[TicketGroupId] [varchar](50) NULL,
	[OrigBaseFare] [float] NULL,
	[TktOrder] [int] NULL,
	[OrigFareCompare1] [float] NULL,
	[OrigFareCompare2] [float] NULL,
	[TktWasRefundedInd] [char](1) NULL,
	[NetTktAmt] [float] NULL,
 CONSTRAINT [PK_InvoiceDetail] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Hotel]    Script Date: 7/1/2015 3:29:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Hotel](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[HtlSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
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

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/1/2015 3:29:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[ComRmks](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Client]    Script Date: 7/1/2015 3:29:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Client](
	[ClientCode] [varchar](25) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[STATE] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[CustPhone] [varchar](20) NULL,
	[CountryCode] [varchar](5) NULL,
	[AttnLine] [varchar](40) NULL,
	[Email] [varchar](80) NULL,
	[ConsolidationCode] [varchar](50) NULL,
	[ClientRemark1] [varchar](255) NULL,
	[ClientRemark2] [varchar](255) NULL,
	[ClientRemark3] [varchar](255) NULL,
	[ClientRemark4] [varchar](255) NULL,
	[ClientRemark5] [varchar](255) NULL,
	[ClientRemark6] [varchar](255) NULL,
	[ClientRemark7] [varchar](255) NULL,
	[ClientRemark8] [varchar](255) NULL,
	[ClientRemark9] [varchar](255) NULL,
	[ClientRemark10] [varchar](255) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientCode] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Car]    Script Date: 7/1/2015 3:29:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Car](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[CarSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Car] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Udef]    Script Date: 7/1/2015 3:29:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Udef](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
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

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/1/2015 3:29:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](25) NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Tax]    Script Date: 7/1/2015 3:30:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Tax](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[TaxSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](25) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[TaxId] [varchar](10) NULL,
	[TaxAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[TaxRate] [float] NULL,
 CONSTRAINT [PK_Tax] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Tax] TO  SCHEMA OWNER 
GO

/****** Object:  Index [PaymentI1]    Script Date: 7/1/2015 3:30:07 PM ******/
CREATE CLUSTERED INDEX [PaymentI1] ON [dba].[Payment]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/1/2015 3:30:08 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[InvoiceDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/1/2015 3:30:08 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [Hotel_I1]    Script Date: 7/1/2015 3:30:09 PM ******/
CREATE CLUSTERED INDEX [Hotel_I1] ON [dba].[Hotel]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ComRmks_I1]    Script Date: 7/1/2015 3:30:09 PM ******/
CREATE CLUSTERED INDEX [ComRmks_I1] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CarI1]    Script Date: 7/1/2015 3:30:11 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [dba].[Car]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [UdefI1]    Script Date: 7/1/2015 3:30:11 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TransegI1]    Script Date: 7/1/2015 3:30:11 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TaxI1]    Script Date: 7/1/2015 3:30:11 PM ******/
CREATE CLUSTERED INDEX [TaxI1] ON [dba].[Tax]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [FIX_INVOICEHEADER_IATANUM_RECORDKEY_CLIENTCODE]    Script Date: 7/1/2015 3:30:12 PM ******/
CREATE NONCLUSTERED INDEX [FIX_INVOICEHEADER_IATANUM_RECORDKEY_CLIENTCODE] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[RecordKey] ASC,
	[ClientCode] ASC
)
INCLUDE ( 	[InvoiceDate],
	[OrigCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/1/2015 3:30:12 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC,
	[IataNum] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/1/2015 3:30:12 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/1/2015 3:30:12 PM ******/
CREATE NONCLUSTERED INDEX [IDExchProc_I1] ON [dba].[InvoiceDetail]
(
	[VoidInd] ASC,
	[ExchangeInd] ASC,
	[VendorType] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[IssueDate],
	[DocumentNumber],
	[TicketGroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [INvoiceDetailI2]    Script Date: 7/1/2015 3:30:13 PM ******/
CREATE NONCLUSTERED INDEX [INvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEDETAIL_BOOKINGDATE_GDSRECORDLOCATOR]    Script Date: 7/1/2015 3:30:13 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEDETAIL_BOOKINGDATE_GDSRECORDLOCATOR] ON [dba].[InvoiceDetail]
(
	[BookingDate] ASC,
	[GDSRecordLocator] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/1/2015 3:30:13 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [Hotel_PK]    Script Date: 7/1/2015 3:30:13 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [Hotel_PK] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/1/2015 3:30:14 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [dba].[Hotel]
(
	[IssueDate] ASC
)
INCLUDE ( 	[VoidInd],
	[FirstName],
	[Lastname],
	[HtlAddr1],
	[HtlCityCode],
	[HtlState],
	[HtlPostalCode],
	[HtlCountryCode],
	[HtlPhone],
	[CheckinDate],
	[CheckoutDate],
	[NumNights],
	[NumRooms],
	[HtlDailyRate],
	[HtlRateCat],
	[HtlCommAmt],
	[CurrCode],
	[MasterId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [IX_COMRMKS_IATANUM]    Script Date: 7/1/2015 3:30:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_COMRMKS_IATANUM] ON [dba].[ComRmks]
(
	[IataNum] ASC
)
INCLUDE ( 	[RecordKey],
	[SeqNum],
	[ClientCode],
	[IssueDate],
	[Text9],
	[Text19],
	[Text20],
	[Text45]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [UdefPX]    Script Date: 7/1/2015 3:30:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [dba].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC,
	[UdefType] ASC
)
INCLUDE ( 	[ClientCode],
	[InvoiceDate],
	[IssueDate],
	[UdefData]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

ALTER TABLE [dba].[InvoiceHeader] ADD  DEFAULT ((0)) FOR [IsItineraryProcessed]
GO

