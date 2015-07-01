/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Payment' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Payment' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='masterfareclassref_vw' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceHeader' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceHeader' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceDetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='InvoiceDetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='hotel' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='hotel' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='ComRmks' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='ComRmks' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Client' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Client' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Car' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='car' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxsasql03']/Database[@Name='ttxcentral']/UnresolvedEntity[@Name='uszipcodesdeluxe' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='UDef' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='UDef' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Transeg' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Transeg' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Tax' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL09']/Database[@Name='TMAN503_ESTEELAUDER']/UnresolvedEntity[@Name='Tax' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='DataEnhancementAutomation']/UnresolvedEntity[@Name='SP_NewDataEnhancementRequest' and @Schema='dbo'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/1/2015 3:39:22 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_ESLHRG]    Script Date: 7/1/2015 3:39:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ====================================================================================================
-- Author:		  Vijay Kodi
-- Create date:	  2015-04-29
-- Description:	  Stage and Process Data on Staging Server as data is imported
--				  Moving the data from Staging to Production
			  
--					WHAT IT DOES:
--					Processes data for the @ImportDate argument 	
-- ====================================================================================================

CREATE PROCEDURE [dbo].[sp_ESLHRG] (@BeginIssueDate DATETIME, 
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
           @LocalEndIssueDate =	@EndIssueDate 

    -----  For Logging Only -------------------------------------  
    SET @Iata = 'ESLHRG' 
    SET @ProcName = CONVERT(VARCHAR(50), Object_name(@@PROCID)) 
    --------------------------------------------------------------    
    -----  For sp PROMPTSONLY ----------  
    SET @IataNum= 'ESLHRG' 

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

/******************************************************************************************** 
For any Recordkeys WHERE IssueDate is Null  SET IssueDate = InvoiceDate	in all tables 
namely dba.InvoiceDetail,	dba.Transeg, dba.Car, dba.Hotel, dba.UDef, dba.Payment, dba.Tax 
*********************************************************************************************/

--/*******************************************************************************
--		----START OF UPDATES TO THE IssueDate, , WHERE IssueDate IS NULL    
--********************************************************************************/     
     
---------------------------------------------------------------------------------------------------
    ----Updating the dba.InvoiceDetail Table and SET IssueDate = InvoiceDate when IssueDate is NULL  
---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    UPDATE ID
    SET    ID.IssueDate = IH.InvoiceDate 
    FROM   dba.InvoiceDetail ID
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= ID.IataNum
                        AND IH.RecordKey= ID.RecordKey
                        AND IH.InvoiceDate = ID.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND ID.IataNum= @IataNum
           --and ID.IssueDate <> IH.InvoiceDate  
           AND ID.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='1-When InvoiceDetail IssueDate is Null', 
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
                        AND IH.InvoiceDate = TS.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND TS.IataNum= @IataNum
           ----and TS.IssueDate <> IH.InvoiceDate  
           AND TS.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='2-When Transeg IssueDate is Null', 
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
    FROM   dba.Car car 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= car.IataNum
                        AND IH.RecordKey= car.RecordKey
                        AND IH.InvoiceDate = car.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND car.IataNum= @IataNum
           ----and car.IssueDate <> IH.InvoiceDate  
           AND car.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='3-When Car IssueDate is Null', 
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
                        AND IH.InvoiceDate = htl.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND htl.IataNum= @IataNum
           ----and htl.IssueDate <> IH.InvoiceDate  
           AND htl.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='4-When Hotel IssueDate is Null', 
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
                        AND IH.InvoiceDate = UD.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND UD.IataNum= @IataNum
           ----and UD.IssueDate <> IH.InvoiceDate  
           AND UD.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='5-When UDef IssueDate is Null', 
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
    FROM   dba.Payment pay 
           INNER JOIN dba.InvoiceHeader IH
                   ON ( IH.IataNum= pay.IataNum
                        AND IH.RecordKey= pay.RecordKey
                        AND IH.InvoiceDate = pay.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND pay.IataNum= @IataNum
           ----and pay.IssueDate <> IH.InvoiceDate  
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
                        AND IH.InvoiceDate = Tax.InvoiceDate ) 
    WHERE  IH.ImportDt = @MaxImportDt 
           AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND IH.IataNum= @IataNum
           AND Tax.IataNum= @IataNum
           ----and Tax.IssueDate <> IH.InvoiceDate  
           AND Tax.IssueDate IS NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='7-When Tax IssueDate is Null', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/**************************************************************************************** 
------END OF UPDATES FOR THE IssueDate, WHERE IssueDate IS NULL  
****************************************************************************************/ 

/*******************************************************************************************************************/
    
/***********************************************  
--------  BEGIN OTHER UPDATES TO InvoiceDetail 
************************************************/  

--------------------------------------------------------------------------------
----	RAIL
--------------------------------------------------------------------------------

----	Added per SF 06389027 5/11/2015

SET @TransStart = getdate()

UPDATE id
SET id.VendorType = 'RAIL'
FROM dba.Invoicedetail id
INNER JOIN dba.Invoiceheader ih 
ON     (ih.IataNum     = id.IataNum
	and ih.recordkey   = id.recordkey  
	and ih.invoicedate = id.invoicedate)
WHERE ih.importdt = @MaxImportDt
  and ih.invoicedate between @FirstInvDate and @LastInvDate
  and id.IataNum = @IataNum
  and ih.IataNum = @IataNum
  and ID.VendorType not in ('RAIL')
  and ID.ProductType in ('RAIL')

  EXEC dbo.Sp_logprocerrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='8-Vendortype RAIL by ProductType', 
  @BeginDate=@BeginIssueDate, 
  @EndDate=@EndIssueDate, 
  @IataNum=@Iata, 
  @RowCount=@@ROWCOUNT, 
  @ERR=@@ERROR 


----------------------------------------------
----	END VENDORTYPE in InvoiceDetail
---------------------------------------------

/***********************************************  
--------  END OF OTHER UPDATES TO InvoiceDetail 
************************************************/  

/**********************************************************************************************************************/

/***********************************************  
--------  BEGIN VENDOR TYPE UPDATES------------- 
************************************************/

------Need to review how Client does Fees and Rail first  
--------  FEES  ------------  
------------  RAIL  ------------ 

/*********************************************** 
----  END VENDOR TYPE UPDATES ----------  
************************************************/

/**********************************************************************************************************************/

/***********************************************  
----  BEGIN PREFERRED CAR AND AIR UPDATES  
************************************************/
-------------------------------------------------------------
----  PREFERRED CAR VENDOR   
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
	WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.IataNum = @IataNum
		AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.CarChainCode in ('ZL')
		AND CAR.PrefCarInd is null

	   EXEC dbo.sp_LogProcErrors 
		  @ProcedureName=@ProcName, 
		  @LogStart=@TransStart, 
		  @StepName='9-Preferred Car Vendor', 
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
	WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.IataNum = @IataNum
		AND CAR.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND CAR.CarChainCode in ('ET')
		AND CAR.PrefCarInd is null

	   EXEC dbo.sp_LogProcErrors 
		  @ProcedureName=@ProcName, 
		  @LogStart=@TransStart, 
		  @StepName='10-Preferred Car Vendor', 
		  @BeginDate=@LocalBeginIssueDate, 
		  @EndDate= @LocalEndIssueDate, 
		  @IataNum=@Iata, 
		  @RowCount=@@ROWCOUNT, 
		  @ERR=@@ERROR
-----------------------------------------------------------------
----  PREFERRED AIR VENDORS 
--------------------------------------------------------------------
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
	WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND ID.IataNum = @IataNum
		AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND ID.PrefTktInd is null
		and ID.VendorType not in ('NONAIR')
   
	EXEC dbo.sp_LogProcErrors 
		@ProcedureName=@ProcName, 
		@LogStart=@TransStart, 
		@StepName='11-ID.PrefTktInd- AIR Vendor', 
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
	WHERE IH.IMPORTDT = @MaxImportDt
		AND IH.IataNum = @IataNum
		AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND TS.IataNum = @IataNum
		AND TS.InvoiceDate between @FirstInvDate AND @LastInvDate
		AND TS.PrefAirInd is null

	EXEC dbo.sp_LogProcErrors 
		@ProcedureName=@ProcName, 
		@LogStart=@TransStart, 
		@StepName='12-ID.TS.PrefAIRInd', 
		@BeginDate=@LocalBeginIssueDate, 
		@EndDate= @LocalEndIssueDate, 
		@IataNum=@Iata, 
		@RowCount=@@ROWCOUNT, 
		@ERR=@@ERROR


/***********************************************  
----	END PREFERRED CAR AND AIR UPDATES
************************************************/


/***********************************************************************************************************************/


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
 
 ------------------------------------------------------
 --------  BEGIN DELETE AND INSERT COMRMKS -----
 ------------------------------------------------------
 
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
		@StepName='13-Delete DBA.comrmks', 
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
		@StepName='14-Insert Stag CR', 
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
text14 = CASE WHEN Text14 is null then 'Not Provided' ELSE Text14 end,
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
			@StepName='15-SET text fields to Not Provided', 
			@BeginDate=@LocalBeginIssueDate, 
			@EndDate= @LocalEndIssueDate, 
			@IataNum=@Iata, 
			@RowCount=@@ROWCOUNT, 
			@ERR=@@ERROR

	
/**************************************************************************************/  
    /*  
      Text1 = Employee ID 
      Text2 = POS country  
      Text3 = Cost Center  (Employee)
      Text4 = Department  
      Text5 = Division/region  
      Text6 = Project code  
      Text7 = Trip purpose code  
      Text8 = Online indicator (usually the same as ID.OnlineBookingSystem)  
      Text9 = Trip Cost Center  
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
/*********************************************************/

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
      @StepName='16-Text2_IHPOS_Ctry', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


/******************************************************************  
    -----START STANDARD ComRmks MAPPINGS--------------------  
*******************************************************************/   
	


------------------------------	  
----	Text14 = Highest Class
-------------------------------	  
/***************************************************************************************	
/*Added the following logic to update cr.Text14 - sq 3/13/2015 
Updated logic for refunds outer join and refunds missing segmenTS- sq 3/13/2015 */ 
**************************************************************************************/
------  Commenting out on 3/17 until view is created for these steps for Text14
-------------------------------------------------
--		/*First Class Cabin*/ 
-------------------------------------------------
SET @TransStart = Getdate() 

UPDATE cr 
SET    cr.Text14 = CASE 
                     WHEN alfourcosID.cabin IS NULL THEN alfourcosIDoth.cabin 
                     ELSE alfourcosID.cabin 
                   END 
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw ALFOURCOSID
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														  WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
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
       AND ID.IataNum IN ('ESLHRG'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='17-Update Highest class flown - First', 
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
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw 
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw ALFOURCOSID
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														  WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
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
       AND ID.IataNum IN ( 'ESLHRG'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='18-Update Highest class flown - Business', 
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
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw 
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw ALFOURCOSID
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                          WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
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
       AND ID.IataNum IN ( 'ESLHRG'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='19-Update Highest class flown - Premium Economy', 
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
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg TS
               ON ( TS.RecordKey= CR.RecordKey
                    AND TS.IataNum= CR.IataNum
                    AND TS.SeqNum = CR.SeqNum 
                    AND TS.ClientCode = CR.ClientCode 
                    AND TS.IssueDate = CR.IssueDate ) 
       INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw 
                  ALFOURCOSIDOTH 
               ON ( ALFOURCOSIDOTH.airlinecode = '**' 
                    AND ALFOURCOSIDOTH.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
                                                        WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                   ELSE 'Intercontinental' 
                                                   END 
                    AND ALFOURCOSIDOTH.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
       LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.masterfareclassref_vw ALFOURCOSID
                    ON ( ALFOURCOSID.airlinecode = TS.minsegmentcarriercode 
                         AND ALFOURCOSID.stagecode = CASE WHEN Isnull(TS.mininternationalind, 'D') = 'D' THEN 'Domestic' 
														  WHEN Isnull(Abs(TS.minsegmentmileage), 0) < 2500 THEN 'Regional' 
                                                     ELSE 'Intercontinental' 
                                                     END 
                         AND ALFOURCOSID.fareclasscode = Substring(TS.minclassofservice, 1, 1) ) 
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
       AND ID.IataNum IN ( 'ESLHRG'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='20-Update Highest class flown - Economy', 
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
FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID
               ON ( ID.RecordKey= IH.RecordKey
                    AND ID.IataNum= IH.IataNum
                    AND ID.ClientCode = IH.ClientCode ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CR 
               ON ( CR.RecordKey= ID.RecordKey
                    AND CR.IataNum= ID.IataNum
                    AND CR.SeqNum = ID.SeqNum 
                    AND CR.ClientCode = ID.ClientCode 
                    AND CR.IssueDate = ID.IssueDate ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail IDOrig 
               ON ( IDOrig.RecordKey<> ID.RecordKey
                    AND IDOrig.IataNum= ID.IataNum
                    AND IDOrig.ClientCode = ID.ClientCode 
                    AND ID.documentnumber = IDOrig.documentnumber 
                    AND IDOrig.refundind NOT IN ( 'Y', 'P' ) ) 
       INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks CROrig 
               ON ( CROrig.RecordKey= IDOrig.RecordKey
                    AND CROrig.IataNum= IDOrig.IataNum
                    AND CROrig.SeqNum = IDOrig.SeqNum 
                    AND CROrig.ClientCode = IDOrig.ClientCode ) 
WHERE  1 = 1 
       AND ID.voIDind = 'N' 
       AND ID.vendortype IN ( 'BSP', 'NONBSP' ) /*Do we need to handle RAIL/ss*/ 
       AND ID.valcarriercode NOT IN ( '2V', '2R' ) 
       AND CR.Text14 IS NULL 
       AND ID.IataNum IN ( 'ESLHRG'  ) 
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
  @StepName='21-Update Highest class flown - Refunds', 
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

			 
/**************************************************************  
----UPDATE NUM1 WITH FARECOMPARE1 AND NUM2 WITH FARECOMPARE2  
***************************************************************/ 
	
	-------------------------------------------
    ----UPDATE NUM1 WITH FARECOMPARE1 
    --------------------------------------------

	SET @TransStart = Getdate() 

    UPDATE StagCR 
    SET    Num1 = StagID.farecompare1 
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
                        AND StagID.InvoiceDate = StagCR.InvoiceDate 
                        AND StagID.IssueDate = StagCR.IssueDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.IataNum= @IataNum
           AND StagID.IataNum= @IataNum
           AND StagCR.IataNum= @IataNum
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCR.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCR.num1 IS NULL 
           AND StagID.farecompare1 IS NOT NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='22-Num1 FROM FC1', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	
	-------------------------------------------
    ----UPDATE NUM2 with FareCompare2  
	-------------------------------------------

    SET @TransStart = Getdate() 

    UPDATE StagCR 
    SET    Num2 = StagID.farecompare2 
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
                        AND StagID.InvoiceDate = StagCR.InvoiceDate 
                        AND StagID.IssueDate = StagCR.IssueDate ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.IataNum= @IataNum
           AND StagID.IataNum= @IataNum
           AND StagCR.IataNum= @IataNum
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCR.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCR.num2 IS NULL 
           AND StagID.farecompare2 IS NOT NULL 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='23-Num2 FROM FC2', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/***********************************************************************  
 COMPARE FC1 (FULL/(HIGH) FARE) TO TOTALAMT, UPDATE FC1 = TOTALAMT  
************************************************************************/ 

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
      @StepName='24-FC1 High Fare < TotalAmt when Positive', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
      @StepName='25-FC1 High Fare > TotalAmt when Negative', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------
     ------WHEN FARECOMPARE1 IS NULL OR '0'  
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
      @StepName='26-FC1 is Null or 0 then FC1 = TotalAmt', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
      @StepName='27-If FC1 <> 0 and TotalAmt = 0', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/*******************************************************************  
 COMPARE FC2 (LOW FARE) TO TOTALAMT, UPDATE FC2 = TOTALAMT  
*******************************************************************/ 
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
      @StepName='28-FC2 Low Fare > TotalAmt when Positive', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
      @StepName='29-FC2 Low Fare < TotalAmt when Negative', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
      @StepName='30-FC2 is Null or 0 then FC2 = TotalAmt', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
      @StepName='31-FC2 = TotalAmt if TotalAmt = 0', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

	/*********************************************
    ----END STANDARD FC1 AND FC2 UPDATES  
	**********************************************/

    -- Check if ReasonCodes need to be changed  
------------------------------------------------
----AIR REASON CODES
----PER SF Case 06395092 Added 05/12/2015 Vijay Kodi
------------------------------------------------------
	SET @TransStart = getdate()

	Update ID
	Set  ReasonCode1 = CASE 
						WHEN IH.OrigCountry IS NOT NULL and ReasonCode1 ='LL' Then 'L'
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

	SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='32-Update Air Reason Codes', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


    --/////////////////////////////////////////////////////////////////////////  
    -- /* BEGIN PRE-HNN HOTEL CLEANUP -----*/  
    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='33-BEGIN HTL edits', 
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
           AND Substring(StagHTL.htlpropertyname, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='34-Remove Begin-End Spaces HTLpropertyname', 
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
           AND Substring(StagHTL.htladdr1, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='35-Remove Begin-End Spaces HtlAddr1', 
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
           AND Substring(StagHTL.htladdr2, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='36-Remove Begin-End Spaces HtlAddr2', 
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
           AND Substring(StagHTL.htladdr3, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='37-Remove Begin-End Spaces HtlAddr3', 
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
           AND Substring(StagHTL.htlchaincode, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='38-Remove Begin-End Spaces HtlChainCode', 
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
           AND Substring(StagHTL.htlpostalcode, 1, 1) = ' ' 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='39-Remove Begin-End Spaces HtlPostalCode', 
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
      @StepName='40-HtlCityName with period (.)', 
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
      @StepName='41-Move HtlCityName to HtlAddr3', 
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
      @StepName='42-Replace char HtlProperty and Address', 
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
      @StepName='43-Move htladdr2 to HtlAddr1 when null', 
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
      @StepName='44-HtlAddr2 to Null if HtlAddr1=HtlAddr2 ', 
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
      @StepName='45-MasterIDto -1', 
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
      @StepName='46-BUF DTW  -Zip in CA -Not in US', 
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
      @StepName='47-Zip for Niagra Falls, CA', 
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
      @StepName='48-Zip for Niagara On The Lake, CA', 
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
      @StepName='49-Zip for Windsor CA', 
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
      @StepName='50-Zip for Point Edward CA', 
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
      @StepName='51-Null HtlState if not US,CA,AU,BR', 
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
                   ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
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

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='52-HtlCountry to US based on zip', 
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
                   ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE 
               '[0-9][0-9][0-9][0-9][0-9]' 
           AND StagHTL.htlcountrycode = 'US' 
           AND Isnull(StagHTL.htlstate, '') <> zp.state 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='53-HtlState FROM US Zip', 
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
                   ON ( Substring(StagHTL.htlpostalcode, 1, 5) = zp.zipcode 
                        AND zp.primaryrecord = 'p' ) 
    WHERE  StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.IataNum= @IataNum
           AND StagHTL.IataNum= @IataNum
           AND StagHTL.MasterId is NULL 
           AND Substring(StagHTL.htlpostalcode, 1, 5) LIKE 
               '[0-9][0-9][0-9][0-9][0-9]' 
           AND StagHTL.htlcountrycode = 'US' 
           AND Isnull(StagHTL.htlcityname, '') <> zp.city 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='54-CityName by US Zip', 
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
      @StepName='55-CityName to Paris by Zip', 
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
      @StepName='56-HtlState to Null', 
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
      @StepName='57-ARKANSAS', 
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
      @StepName='58-CALIFORNIA', 
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
      @StepName='59-GEORGIA', 
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
      @StepName='60-MASSACHUSETTS', 
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
      @StepName='61-LOUISIANA', 
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
      @StepName='62-ARIZONA', 
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
      @StepName='63-CANADA', 
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
      @StepName='64-UNITED KINGDOM', 
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
      @StepName='65-SOUTH KOREA', 
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
      @StepName='66-JAPAN', 
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
      @StepName='67-New Delhi', 
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
      @StepName='68-NEW YORK', 
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
      @StepName='69-Washington DC', 
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
      @StepName='70-HERTOGENBOSCH- MOEVENPICK HOTEL', 
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
      @StepName='71-NEW YORK-OAKWOOD CHELSEA', 
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
      @StepName='72-NEW YORK-LONGACRE HOUSE', 
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
      @StepName='73-BARCELONA- HOTLE PUNTA PALMA', 
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
      @StepName='74-End htl edits', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ProdID
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdID.IataNum
                        AND ProdIH.ClientCode = ProdID.ClientCode 
                        AND ProdIH.RecordKey= ProdID.RecordKey
                        AND ProdIH.InvoiceDate = ProdID.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdID.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='75-Delete ProdID', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

----------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdTS
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg ProdTS
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdTS.IataNum
                        AND ProdIH.ClientCode = ProdTS.ClientCode 
                        AND ProdIH.RecordKey= ProdTS.RecordKey
                        AND ProdIH.InvoiceDate = ProdTS.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdTS.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='76-Delete ProdTS', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-----------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdCar 
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.car ProdCar 
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdCar.IataNum
                        AND ProdIH.ClientCode = ProdCar.ClientCode 
                        AND ProdIH.RecordKey= ProdCar.RecordKey
                        AND ProdIH.InvoiceDate = ProdCar.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdCar.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='77-Delete ProdCar', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdHtl 
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.hotel ProdHtl 
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdHtl.IataNum
                        AND ProdIH.ClientCode = ProdHtl.ClientCode 
                        AND ProdIH.RecordKey= ProdHtl.RecordKey
                        AND ProdIH.InvoiceDate = ProdHtl.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdHtl.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='78-Delete ProdHtl', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR
	   
------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdUD 
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.UDef ProdUD 
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdUD.IataNum
                        AND ProdIH.ClientCode = ProdUD.ClientCode 
                        AND ProdIH.RecordKey= ProdUD.RecordKey
                        AND ProdIH.InvoiceDate = ProdUD.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdUD.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='79-Delete ProdUD', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdPay 
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.Payment ProdPay 
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdPay.IataNum
                        AND ProdIH.ClientCode = ProdPay.ClientCode 
                        AND ProdIH.RecordKey= ProdPay.RecordKey
                        AND ProdIH.InvoiceDate = ProdPay.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdPay.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='80-Delete ProdPay', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdTax 
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.Tax ProdTax 
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdTax.IataNum
                        AND ProdIH.ClientCode = ProdTax.ClientCode 
                        AND ProdIH.RecordKey= ProdTax.RecordKey
                        AND ProdIH.InvoiceDate = ProdTax.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdTax.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='81-Delete ProdTax', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

----------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdCR 
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks ProdCR 
           INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                   ON ( ProdIH.IataNum= ProdCR.IataNum
                        AND ProdIH.ClientCode = ProdCR.ClientCode 
                        AND ProdIH.RecordKey= ProdCR.RecordKey
                        AND ProdIH.InvoiceDate = ProdCR.InvoiceDate ) 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND ProdCR.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='82-Delete ProdCR', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
	  
--------------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    DELETE ProdIH
    FROM   TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= ProdIH.IataNum
                        AND StagIH.RecordKey= ProdIH.RecordKey) 
    WHERE  ProdIH.IataNum= @IataNum
           AND StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='83-Delete ProdIH', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/********************************************************************
----END  DELETE FROM PRODUCTION TABLES
**********************************************************************/

/*********************************************************************************
--BEGIN INSERTS INTO PRODUCTION  ---------  
*********************************************************************************/
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader 
    SELECT * 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagIH.RecordKey+ StagIH.IataNum NOT IN (SELECT 
               ProdIH.RecordKey+ ProdIH.IataNum
                                                         FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader ProdIH
                                                         WHERE 
               ProdIH.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='84-INSERT ProdIH', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail 
    SELECT StagID.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceDetail StagID
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagID.IataNum
                        AND StagIH.ClientCode = StagID.ClientCode 
                        AND StagIH.RecordKey= StagID.RecordKey
                        AND StagIH.InvoiceDate = StagID.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagID.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagID.IataNum= @IataNum
           AND StagID.RecordKey+ StagID.IataNum
               + CONVERT(VARCHAR, StagID.SeqNum) NOT IN (SELECT 
                   ProdID.RecordKey+ ProdID.IataNum
                   + CONVERT(VARCHAR, ProdID.SeqNum) 
                                                         FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ProdID
                                                         WHERE 
               ProdID.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='85-INSERT ProdID', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg 
    SELECT StagTS.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Transeg StagTS
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagTS.IataNum
                        AND StagIH.ClientCode = StagTS.ClientCode 
                        AND StagIH.RecordKey= StagTS.RecordKey
                        AND StagIH.InvoiceDate = StagTS.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagTS.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagTS.IataNum= @IataNum
           AND StagTS.RecordKey+ StagTS.IataNum
               + CONVERT(VARCHAR, StagTS.SeqNum) NOT IN (SELECT 
                   ProdTS.RecordKey+ ProdTS.IataNum
                   + CONVERT(VARCHAR, ProdTS.SeqNum) 
                                                         FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg ProdTS
                                                         WHERE 
               ProdTS.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='86-INSERT ProdTS', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

--------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.car 
    SELECT StagCar.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Car StagCar 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagCar.IataNum
                        AND StagIH.ClientCode = StagCar.ClientCode 
                        AND StagIH.RecordKey= StagCar.RecordKey
                        AND StagIH.InvoiceDate = StagCar.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCar.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCar.IataNum= @IataNum
           AND StagCar.RecordKey+ StagCar.IataNum
               + CONVERT(VARCHAR, StagCar.SeqNum) NOT IN 
               (SELECT 
                   ProdCar.RecordKey+ ProdCar.IataNum
                   + CONVERT(VARCHAR, ProdCar.SeqNum) 
                                                          FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.car ProdCar 
                                                          WHERE 
               ProdCar.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='87-INSERT ProdCar', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Hotel 
    SELECT StagHtl.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.hotel StagHtl 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagHtl.IataNum
                        AND StagIH.ClientCode = StagHtl.ClientCode 
                        AND StagIH.RecordKey= StagHtl.RecordKey
                        AND StagIH.InvoiceDate = StagHtl.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagHtl.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagHtl.IataNum= @IataNum
           AND StagHtl.RecordKey+ StagHtl.IataNum
               + CONVERT(VARCHAR, StagHtl.SeqNum) NOT IN 
               (SELECT 
                   ProdHtl.RecordKey+ ProdHtl.IataNum
                   + CONVERT(VARCHAR, ProdHtl.SeqNum) 
                                                          FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.hotel ProdHtl 
                                                          WHERE 
               ProdHtl.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='88-INSERT ProdHtl', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.UDef 
    SELECT StagUD.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.UDef StagUD 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagUD.IataNum
                        AND StagIH.ClientCode = StagUD.ClientCode 
                        AND StagIH.RecordKey= StagUD.RecordKey
                        AND StagIH.InvoiceDate = StagUD.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagUD.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagUD.IataNum= @IataNum
           AND StagUD.RecordKey+ StagUD.IataNum
               + CONVERT(VARCHAR, StagUD.SeqNum) NOT IN (SELECT 
                   ProdUD.RecordKey+ ProdUD.IataNum
                   + CONVERT(VARCHAR, ProdUD.SeqNum) 
                                                         FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.UDef ProdUD 
                                                         WHERE 
               ProdUD.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='89-INSERT ProdUDef', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Payment 
    SELECT StagPAY.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Payment StagPAY 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagPAY.IataNum
                        AND StagIH.ClientCode = StagPAY.ClientCode 
                        AND StagIH.RecordKey= StagPAY.RecordKey
                        AND StagIH.InvoiceDate = StagPAY.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagPAY.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagPAY.IataNum= @IataNum
           AND StagPAY.RecordKey+ StagPAY.IataNum
               + CONVERT(VARCHAR, StagPAY.SeqNum) NOT IN 
               (SELECT 
                   ProdPAY.RecordKey+ ProdPAY.IataNum
                   + CONVERT(VARCHAR, ProdPAY.SeqNum) 
                                                          FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.Payment ProdPAY 
                                                          WHERE 
               ProdPAY.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='90-INSERT ProdPay', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Tax 
    SELECT StagTax.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Tax StagTax 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagTax.IataNum
                        AND StagIH.ClientCode = StagTax.ClientCode 
                        AND StagIH.RecordKey= StagTax.RecordKey
                        AND StagIH.InvoiceDate = StagTax.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagTax.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagTax.IataNum= @IataNum
           AND StagTax.RecordKey+ StagTax.IataNum
               + CONVERT(VARCHAR, StagTax.SeqNum) NOT IN 
               (SELECT 
                   ProdTax.RecordKey+ ProdTax.IataNum
                   + CONVERT(VARCHAR, ProdTax.SeqNum) 
                                                          FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.Tax ProdTax 
                                                          WHERE 
               ProdTax.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='91-INSERT ProdTax', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

----------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks 
    SELECT StagCR.* 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.ComRmks StagCR 
           INNER JOIN TTXSASQL03.TMAN503_ESTEELAUDER.dba.InvoiceHeader StagIH
                   ON ( StagIH.IataNum= StagCR.IataNum
                        AND StagIH.ClientCode = StagCR.ClientCode 
                        AND StagIH.RecordKey= StagCR.RecordKey
                        AND StagIH.InvoiceDate = StagCR.InvoiceDate ) 
    WHERE  StagIH.IataNum= @IataNum
           AND StagIH.ImportDt = @MaxImportDt 
           AND StagIH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCR.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
           AND StagCR.IataNum= @IataNum
           AND StagCR.RecordKey+ StagCR.IataNum
               + CONVERT(VARCHAR, StagCR.SeqNum) NOT IN (SELECT 
                   ProdCR.RecordKey+ ProdCR.IataNum
                   + CONVERT(VARCHAR, ProdCR.SeqNum) 
                                                         FROM 
                   TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks ProdCR 
                                                         WHERE 
               ProdCR.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='92-INSERT ProdCR', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IATANUM=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

---------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    INSERT INTO TTXPASQL09.TMAN503_ESTEELAUDER.dba.Client 
    SELECT * 
    FROM   TTXSASQL03.TMAN503_ESTEELAUDER.dba.Client StagCL 
    WHERE  StagCL.IataNum= @IataNum
           AND StagCL.ClientCode NOT IN(SELECT ProdCL.ClientCode 
                                        FROM 
               TTXPASQL09.TMAN503_ESTEELAUDER.dba.client 
               ProdCL 
                                        WHERE  ProdCL.IataNum= @IataNum) 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='93-INSERT into Prod Client', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

-------------------------------------------------------------------------------------------
    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='94-End of INSERT Production', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/******************************************************************************************************
---END OF INSERTSINTO PRODUCTION --------------  
*******************************************************************************************************/

/*******************************************************************************************************
----BEGIN HOTEL HNN ---------------  
*******************************************************************************************************/
    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='95-Begin DEA Query Dates', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

/********************************************************  
----DATA ENHANCEMENT AUTOMATION  HNN QUERIES  
*********************************************************/  

    Declare @HNNBeginDate datetime  
    Declare @HNNEndDate datetime  

    SELECT @HNNBeginDate = Min(IssueDate),@HNNEndDate = Max(IssueDate)  
    FROM TTXSASQL03.TMAN503_ESTEELAUDER.dba.Hotel ProdHTL  
    WHERE ProdHTL.MasterId is NULL  
    AND ProdHTL.IataNum=  @IataNum
    and ProdHTL.IssueDate >'2013-12-31'  

    EXEC TTXSASQL01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]  
    @DatamanRequestName = 'ESLHRG',  
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
		 @StepName='96-END sending to DEA', 
		 @BeginDate=@LocalBeginIssueDate, 
		 @EndDate= @LocalEndIssueDate, 
		 @IataNum=@Iata, 
		 @RowCount=@@ROWCOUNT, 
		 @ERR=@@ERROR 



--		WAITFOR delay '00:00:05' 
--/************************************************************************
--	---SET up Split Ticket to DEA 
--*************************************************************************/

--	DECLARE @FROM AS VARCHAR(3) 
--	DECLARE @To AS VARCHAR(3) 
--	DECLARE @CommandLine AS VARCHAR(100) 

--	SELECT @FROM = Abs(Datediff(dd, Getdate(), @BeginIssueDate)) 

--	SELECT @To = Abs(Datediff(dd, Getdate(), @EndIssueDate)) 

--	SET @CommandLine = '-RNESLHRG -BD45' + @FROM + ' -ED15' + @To 
--					   + ' -UIdatasvc -PWtman2009 -DS_ESTEELAUDER_TTXPASQL09' 

--	EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[Sp_newdataenhancementrequest] 
--	  @DatamanRequestName = 'ESLHRG', 
--	  @Enhancement = 'SplitTkt', 
--	  @Client = 'ESTEELAUDER', 
--	  @Delay = 20, 
--	  @Priority = NULL, 
--	  @Notes = NULL, 
--	  @Suspend = false, 
--	  @RunAtTime = NULL, 
--	  @BeginDate = NULL, 
--	  @EndDate = NULL, 
--	  @DateParam1 = NULL, 
--	  @DateParam2 = NULL, 
--	  @TextParam1 = NULL, 
--	  @TextParam2 = NULL, 
--	  @TextParam3 = NULL, 
--	  @TextParam4 = NULL, 
--	  @TextParam5 = NULL, 
--	  @TextParam6 = NULL, 
--	  @TextParam7 = NULL, 
--	  @TextParam8 = NULL, 
--	  @TextParam9 = NULL, 
--	  @TextParam10 = NULL, 
--	  @TextParam11 = NULL, 
--	  @TextParam12 = NULL, 
--	  @TextParam13 = NULL, 
--	  @TextParam14 = NULL, 
--	  @TextParam15 = NULL, 
--	  @IntParam1 = NULL, 
--	  @IntParam2 = NULL, 
--	  @IntParam3 = NULL, 
--	  @IntParam4 = NULL, 
--	  @IntParam5 = NULL, 
--	  @BoolParam1 = NULL, 
--	  @BoolParam2 = NULL, 
--	  @BoolParam3 = NULL, 
--	  @BoolParam4 = NULL, 
--	  @BoolParam5 = NULL, 
--	  @BoolParam6 = NULL, 
--	  @BoolParam7 = NULL, 
--	  @BoolParam8 = NULL, 
--	  @BoolParam9 = NULL, 
--	  @BoolParam10 = NULL, 
--	  @CommandLineArgs = @CommandLine 
    
-------------------------------------------------------------------------------------------------------------------
--    SET @TransStart = Getdate() 

--    EXEC dbo.sp_LogProcErrors 
--      @ProcedureName=@ProcName, 
--      @LogStart=@TransStart, 
--      @StepName='97-END sending to DEA', 
--      @BeginDate=@LocalBeginIssueDate, 
--      @EndDate= @LocalEndIssueDate, 
--      @IataNum=@Iata, 
--      @RowCount=@@ROWCOUNT, 
--      @ERR=@@ERROR 

/*******************************************************************************************************/
    SET @TransStart = Getdate() 

    EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
GO

ALTER AUTHORIZATION ON [dbo].[sp_ESLHRG] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/1/2015 3:39:24 PM ******/
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

/****** Object:  Table [dba].[Payment]    Script Date: 7/1/2015 3:39:27 PM ******/
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

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/1/2015 3:39:31 PM ******/
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

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/1/2015 3:39:34 PM ******/
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

/****** Object:  Table [dba].[Hotel]    Script Date: 7/1/2015 3:39:43 PM ******/
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

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/1/2015 3:39:48 PM ******/
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

/****** Object:  Table [dba].[Client]    Script Date: 7/1/2015 3:39:58 PM ******/
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

/****** Object:  Table [dba].[Car]    Script Date: 7/1/2015 3:40:00 PM ******/
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

/****** Object:  Table [dba].[Udef]    Script Date: 7/1/2015 3:40:06 PM ******/
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

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/1/2015 3:40:08 PM ******/
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

/****** Object:  Table [dba].[Tax]    Script Date: 7/1/2015 3:40:13 PM ******/
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

/****** Object:  Index [PaymentI1]    Script Date: 7/1/2015 3:40:15 PM ******/
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

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/1/2015 3:40:16 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/1/2015 3:40:16 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [Hotel_I1]    Script Date: 7/1/2015 3:40:16 PM ******/
CREATE CLUSTERED INDEX [Hotel_I1] ON [dba].[Hotel]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ComRmks_I1]    Script Date: 7/1/2015 3:40:16 PM ******/
CREATE CLUSTERED INDEX [ComRmks_I1] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CarI1]    Script Date: 7/1/2015 3:40:16 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [dba].[Car]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [UdefI1]    Script Date: 7/1/2015 3:40:17 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TransegI1]    Script Date: 7/1/2015 3:40:17 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TaxI1]    Script Date: 7/1/2015 3:40:17 PM ******/
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

/****** Object:  Index [FIX_INVOICEHEADER_IATANUM_RECORDKEY_CLIENTCODE]    Script Date: 7/1/2015 3:40:18 PM ******/
CREATE NONCLUSTERED INDEX [FIX_INVOICEHEADER_IATANUM_RECORDKEY_CLIENTCODE] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[RecordKey] ASC,
	[ClientCode] ASC
)
INCLUDE ( 	[InvoiceDate],
	[OrigCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/1/2015 3:40:18 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC,
	[IataNum] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/1/2015 3:40:18 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/1/2015 3:40:18 PM ******/
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

/****** Object:  Index [INvoiceDetailI2]    Script Date: 7/1/2015 3:40:19 PM ******/
CREATE NONCLUSTERED INDEX [INvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEDETAIL_BOOKINGDATE_GDSRECORDLOCATOR]    Script Date: 7/1/2015 3:40:19 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEDETAIL_BOOKINGDATE_GDSRECORDLOCATOR] ON [dba].[InvoiceDetail]
(
	[BookingDate] ASC,
	[GDSRecordLocator] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/1/2015 3:40:19 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [Hotel_PK]    Script Date: 7/1/2015 3:40:19 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [Hotel_PK] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/1/2015 3:40:20 PM ******/
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

/****** Object:  Index [IX_COMRMKS_IATANUM]    Script Date: 7/1/2015 3:40:20 PM ******/
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

/****** Object:  Index [UdefPX]    Script Date: 7/1/2015 3:40:20 PM ******/
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

