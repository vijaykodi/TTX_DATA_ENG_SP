/****** Object:  StoredProcedure [dbo].[sp_ALESTEE]    Script Date: 7/1/2015 3:20:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================================================
-- Author:		  Vijay Kodi
-- Create date:	  2015-04-30
-- Description:	  Stage and Process Data on Staging Server as data is imported
--				  Moving the data from Staging to Production
			  
--					WHAT IT DOES:
--					Processes data for the @ImportDate argument 	
-- ====================================================================================================

CREATE PROCEDURE [dbo].[sp_ALESTEE] (@BeginIssueDate DATETIME, 
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
    SET @Iata = 'ALESTEE' 
    SET @ProcName = CONVERT(VARCHAR(50), Object_name(@@PROCID)) 
    --------------------------------------------------------------    
    -----  For sp PROMPTSONLY ----------  
    SET @IataNum= 'ALESTEE' 

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

/***********************************************  
--------  BEGIN UPDATES TO DBA.CAR
************************************************/  
----	Pam S added .25.2015  SF 06021282 to use VendorName for CarChainName
----	Note CarChainName field only has 20 characters

SET @TransStart = Getdate() 

Update car
Set CarChainName = Case when id.vendorname = 'XDrive Car Rental LLC' then 'XDrive Car Rental'
						else substring(id.vendorname,1,20) end
from dba.invoicedetail id
inner join dba.invoiceheader ih
	on (id.iatanum = ih.iatanum and id.clientcode = ih.clientcode
	and id.recordkey = ih.recordkey)
inner join dba.car car
	on (id.iatanum = car.iatanum and id.clientcode = car.clientcode
	and id.recordkey = car.recordkey and id.seqnum = car.seqnum)

WHERE  IH.ImportDt = @MaxImportDt 
	AND IH.InvoiceDate BETWEEN @FirstInvDate AND @LastInvDate 
	AND IH.IataNum = @IataNum
	AND ID.IataNum = @IataNum
	AND car.Iatanum = @IataNum

EXEC dbo.sp_LogProcErrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='CarChainName from ID.VendorName', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


/***********************************************  
--------  END OF OTHER UPDATES TO DBA.CAR
************************************************/ 



/*******************************************************************************************************************/
    
/***********************************************  
--------  BEGIN OTHER UPDATES TO InvoiceDetail 
************************************************/  


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
----PREFERRED CAR VENDOR   
----Preferred Car Vendor where  CarChainName is NATIONAL(ZL) AND ENTERPRISE(ET)
----Added Per SF 06372985 05.05.2015 Vijay Kodi
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
		  @StepName='8-Preferred Car Vendor', 
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
		  @StepName='9-Preferred Car Vendor', 
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
		@StepName='10-ID.PrefTktInd- AIR Vendor', 
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
		@StepName='11-ID.TS.PrefAIRInd', 
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
		@StepName='12-Delete DBA.comrmks', 
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
		@StepName='13-Insert Stag CR', 
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
			@StepName='14-SET text fields to Not Provided', 
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
      @StepName='15-Text2_IHPOS_Ctry', 
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
       AND ID.IataNum IN ('ALESTEE'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='16-Update Highest class flown - First', 
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
       AND ID.IataNum IN ( 'ALESTEE'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='17-Update Highest class flown - Business', 
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
       AND ID.IataNum IN ( 'ALESTEE'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='18-Update Highest class flown - Premium Economy', 
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
       AND ID.IataNum IN ( 'ALESTEE'  ) 
       AND IH.ImportDt >= Getdate() - 10 

EXEC dbo.sp_LogProcErrors 
  @ProcedureName=@ProcName, 
  @LogStart=@TransStart, 
  @StepName='19-Update Highest class flown - Economy', 
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
       AND ID.IataNum IN ( 'ALESTEE'  ) 
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
  @StepName='20-Update Highest class flown - Refunds', 
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
      @StepName='21-Num1 FROM FC1', 
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
      @StepName='22-Num2 FROM FC2', 
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
      @StepName='23-FC1 High Fare < TotalAmt when Positive', 
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
      @StepName='24-FC1 High Fare > TotalAmt when Negative', 
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
      @StepName='25-FC1 is Null or 0 then FC1 = TotalAmt', 
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
      @StepName='26-If FC1 <> 0 and TotalAmt = 0', 
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
      @StepName='27-FC2 Low Fare > TotalAmt when Positive', 
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
      @StepName='28-FC2 Low Fare < TotalAmt when Negative', 
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
      @StepName='29-FC2 is Null or 0 then FC2 = TotalAmt', 
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
      @StepName='30-FC2 = TotalAmt if TotalAmt = 0', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate= @LocalEndIssueDate, 
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
      @StepName='31-BEGIN HTL edits', 
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
      @StepName='32-Remove Begin-End Spaces HTLpropertyname', 
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
      @StepName='33-Remove Begin-End Spaces HtlAddr1', 
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
      @StepName='34-Remove Begin-End Spaces HtlAddr2', 
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
      @StepName='35-Remove Begin-End Spaces HtlAddr3', 
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
      @StepName='36-Remove Begin-End Spaces HtlChainCode', 
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
      @StepName='37-Remove Begin-End Spaces HtlPostalCode', 
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
      @StepName='38-HtlCityName with period (.)', 
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
      @StepName='39-Move HtlCityName to HtlAddr3', 
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
      @StepName='40-Replace char HtlProperty and Address', 
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
      @StepName='41-Move htladdr2 to HtlAddr1 when null', 
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
      @StepName='42-HtlAddr2 to Null if HtlAddr1=HtlAddr2 ', 
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
      @StepName='43-MasterIDto -1', 
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
      @StepName='44-BUF DTW  -Zip in CA -Not in US', 
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
      @StepName='45-Zip for Niagra Falls, CA', 
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
      @StepName='46-Zip for Niagara On The Lake, CA', 
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
      @StepName='47-Zip for Windsor CA', 
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
      @StepName='48-Zip for Point Edward CA', 
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
      @StepName='49-Null HtlState if not US,CA,AU,BR', 
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
      @StepName='50-HtlCountry to US based on zip', 
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
      @StepName='51-HtlState FROM US Zip', 
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
      @StepName='52-CityName by US Zip', 
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
      @StepName='53-CityName to Paris by Zip', 
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
      @StepName='54-HtlState to Null', 
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
      @StepName='55-ARKANSAS', 
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
      @StepName='56-CALIFORNIA', 
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
      @StepName='57-GEORGIA', 
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
      @StepName='58-MASSACHUSETTS', 
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
      @StepName='59-LOUISIANA', 
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
      @StepName='60-ARIZONA', 
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
      @StepName='61-CANADA', 
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
      @StepName='62-UNITED KINGDOM', 
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
      @StepName='63-SOUTH KOREA', 
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
      @StepName='64-JAPAN', 
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
      @StepName='65-New Delhi', 
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
      @StepName='66-NEW YORK', 
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
      @StepName='67-Washington DC', 
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
      @StepName='68-HERTOGENBOSCH- MOEVENPICK HOTEL', 
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
      @StepName='69-NEW YORK-OAKWOOD CHELSEA', 
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
      @StepName='70-NEW YORK-LONGACRE HOUSE', 
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
      @StepName='71-BARCELONA- HOTLE PUNTA PALMA', 
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
      @StepName='72-End htl edits', 
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
      @StepName='73-Delete ProdID', 
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
      @StepName='74-Delete ProdTS', 
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
      @StepName='75-Delete ProdCar', 
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
      @StepName='76-Delete ProdHtl', 
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
      @StepName='77-Delete ProdUD', 
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
      @StepName='78-Delete ProdPay', 
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
      @StepName='79-Delete ProdTax', 
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
      @StepName='80-Delete ProdCR', 
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
      @StepName='81-Delete ProdIH', 
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
      @StepName='82-INSERT ProdIH', 
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
      @StepName='83-INSERT ProdID', 
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
      @StepName='84-INSERT ProdTS', 
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
      @StepName='85-INSERT ProdCar', 
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
      @StepName='86-INSERT ProdHtl', 
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
      @StepName='87-INSERT ProdUDef', 
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
      @StepName='88-INSERT ProdPay', 
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
      @StepName='89-INSERT ProdTax', 
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
      @StepName='90-INSERT ProdCR', 
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
      @StepName='91-INSERT into Prod Client', 
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
      @StepName='92-End of INSERT Production', 
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
      @StepName='93-Begin DEA Query Dates', 
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
    @DatamanRequestName = 'ALESTEE',  
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
		 @StepName='94-END sending to DEA', 
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

--	SET @CommandLine = '-RNALESTEE -BD' + @FROM + ' -ED' + @To 
--					   + ' -UIDatasvc -PWtman2009 -DS_ESTEELAUDER_TTXPASQL09' 

--	EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[Sp_newdataenhancementrequest] 
--	  @DatamanRequestName = 'ALESTEE', 
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
--      @StepName='95-END sending to DEA', 
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
