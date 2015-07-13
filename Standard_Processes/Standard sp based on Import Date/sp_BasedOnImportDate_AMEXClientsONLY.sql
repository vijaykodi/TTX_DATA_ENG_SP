USE [TMAN503_@client]
GO
/****** Object:  StoredProcedure [dbo].[sp_@iatanum_New]    Script Date: 05/07/2015 15:49:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_@iatanum]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime
        ,@MaxImportDt datetime,@FirstInvDate datetime,@LastInvDate datetime
        ,@IataNum varchar(8)
        
-----  For Logging Only -------------------------------------
	SET @Iata = '@iatanum'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--------------------------------------------------------------	

-----  For sp PROMPTS ONLY ----------
	
	SET @IataNum = '@iatanum'
		
	SELECT @MaxImportDt = max(StagIH.IMPORTDT)
	FROM dba.InvoiceHeader StagIH
	WHERE StagIH.IataNum = @IataNum 
	AND StagIH.InvoiceDate BETWEEN @BeginIssueDate AND @EndIssueDate
	print  @MaxImportDt 
	
	SELECT @FirstInvDate = min(InvoiceDate),@LastInvDate = max(InvoiceDate)
	FROM dba.InvoiceHeader 
	WHERE importdt = @MaxImportDt
	AND IataNum = @IataNum
	print @FirstInvDate
	print @LastInvDate
----------------------------------------------------------------	
	

-- Any AND all edits can be logged using sp_LogProcErrors 
-- INSERT a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure AND raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable AND capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'UPDATE ComRmks' OR 'INSERT Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------ For any RecordKeys WHERE IssueDate IS NULL
------ BEGIN SET IssueDate = InvoiceDate when IssueDate IS NULL, in all tables

SET @TransStart = getdate()
UPDATE ID
SET ID.IssueDate = IH.InvoiceDate
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
----AND ID.IssueDate <> IH.InvoiceDate
	AND ID.IssueDate IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When ID.IssueDate IS NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE TS
SET TS.IssueDate = IH.InvoiceDate
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
----AND TS.IssueDate <> IH.InvoiceDate
	AND TS.IssueDate IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When TS.IssueDate IS NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE CAR
SET CAR.IssueDate = IH.InvoiceDate
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
----AND CAR.IssueDate <> IH.InvoiceDate
	AND CAR.IssueDate IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When Car.IssueDate IS NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE HTL
SET HTL.IssueDate = IH.InvoiceDate
FROM dba.Hotel HTL
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
----AND HTL.IssueDate <> IH.InvoiceDate
	AND HTL.IssueDate IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When HTL.IssueDate IS NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE UD
SET UD.IssueDate = IH.InvoiceDate
FROM dba.Udef UD
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
----AND UD.IssueDate <> IH.InvoiceDate
	AND UD.IssueDate IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When UD.IssueDate IS NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When PAY.IssueDate IS NULL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When TAX.IssueDate is Null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------
------    END SET IssueDate = InvoiceDate when IssueDate is NULL, in all tables
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

----------------------------------------------
--------  BEGIN InvoiceDetail AND TranSeg Updates
----------------------------------------------

----------------------------------------------
-------  FEES for ID.VendorType
----------------------------------------------

-------- FEES  for Amex  ------------

-------  Added stANDard FEES updates per SF 00053978 Pam S 12.31.2014 
-------  For @iatanum, Producttype, 'F', is also showing ServiceType = F AND ServiceDescription = 'FEE'
-------  1/27/2015 Pam S Added ProductType 'V' for 'FEES' where VendorType was showing as 'V' per SF 00051931 - Created By: Chantal Belosic (1/20/2015 3:15 PM) 
-------  "AMEX advised Vendor Type transactions with a value of 'V' are Value Add- Incidental or Misc charges, like for visa fees, etc. Please update these transactions to Vendor Type = 'FEE' "

SET @TransStart = getdate()
UPDATE ID
SET ID.VendorType = 'FEES'
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
	AND ID.VendorType not in ('FEES')
	AND ID.ProductType in ('F','V')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Vendortype to FEES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----------------------------------------------
-------  RAIL for ID.VendorType
---------------------------------------------

-------- RAIL for Amex  -------------

-------  Added Amex stANDard RAIL updates per SF 00053978 Pam S 12-30-2014
-------  Note: ID.ServiceType is also showing '7' with ID.ServiceDescription as 'RAIL'

SET @TransStart = getdate()
UPDATE dba.invoicedetail
set VendorType = 'RAIL'
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
	AND ID.VendorType not in ('RAIL')
	AND ID.ProductType in ('7')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='VendorType RAIL by ProductType 7',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------  To catch RAIL sold as ProductType 8 AND ServiceDescription as 'AIR' such as Amtrak, Eurostar, etc like when a ticket is issued

SET @TransStart = getdate()
UPDATE dba.invoicedetail
set VendorType = 'RAIL'
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
	AND ID.VendorType not in ('RAIL')
	AND (ID.VendorName like '%rail%' or ID.VendorName like '%amtrak%' or ID.Vendorname = 'EUROSTAR')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Vendortype RAIL by Name',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------RAIL for Transeg aready shows TypeCode as 'R' for '@iatanum' including Amtrak (2V)

-------- RAIL specifics only for AMEX to update VendorName

SET @TransStart = getdate()
UPDATE dba.InvoiceDetail
SET vendorname = CASE
when valcarriercode = 'R0' then 'DEFAULT RAIL'
when valcarriercode = '0A' then 'ATOC-RSP'
when valcarriercode = '0A' then 'ATOC-RSP'
when valcarriercode = '0E' then 'FIRST GREAT WESTERN'
when valcarriercode = '0F' then 'GATWICK EXPRESS'
when valcarriercode = '0G' then 'HULL TRAINS'
when valcarriercode = '0H' then 'GREAT NORTH EASTERN RAILWAY'
when valcarriercode = '0I' then 'VIRGIN WEST COAST'
when valcarriercode = '0J' then 'VIRGIN CROSSCOUNTRY TRAINS'
when valcarriercode = '0K' then 'C2C'
when valcarriercode = '0L' then 'LONDON UNDERGROUND'
when valcarriercode = '0M' then 'MIDLAND MAINLINE'
when valcarriercode = '0N' then 'THE CHILTERN RAILWAY COMPANY'
when valcarriercode = '0O' then 'ISLAND LINE'
when valcarriercode = '0Q' then 'SOUTHERN/SOUTH CENTRAL'
when valcarriercode = '0R' then 'SOUTH EASTERN TRAINS'
when valcarriercode = '0S' then 'FIRST GREAT WESTERN LINK'
when valcarriercode = '0T' then 'MERSEYRAIL PTE'
when valcarriercode = '0U' then 'STRATHCLYDE PTE'
when valcarriercode = '0W' then 'SOUTH YORKSHIRE PTE'
when valcarriercode = '0X' then 'NEXUS TYNE AND WEAR PTE'
when valcarriercode = '0Y' then 'WEST MIDLANDS PTE'
when valcarriercode = '0Z' then 'WEST YORKSHIRE PTE'
when valcarriercode = '02' then 'CENTRAL TRAINS'
when valcarriercode = '03' then 'MERSEYRAIL'
when valcarriercode = '04' then 'ARRIVA TRAINS NORTHERN'
when valcarriercode = '06' then 'ARRIVA TRAINS WALES'
when valcarriercode = '08' then 'FIRST SCOTRAIL/SCOTRAIL RAILWAYS'
when valcarriercode = '09' then 'SOUTH WEST TRAINS'
when valcarriercode = '10' then 'THAMESLINK RAIL'
when valcarriercode = '11' then 'TRANSPENNINE EXPRESS'
when valcarriercode = '12' then 'ONE GER'
when valcarriercode = '13' then 'ONE LER'
when valcarriercode = '14' then 'WEST ANGLIA GREAT NORTHERN RAIL'
when valcarriercode = '19' then 'NORTHERN'
when valcarriercode = '2H' then 'THALYS INTL RAILWAY SAL'
when valcarriercode = '20' then 'RAIL CHINA'
when valcarriercode = '21' then 'RAIL MALAYSIA'
when valcarriercode = '22' then 'RAIL SINGAPORE'
when valcarriercode = '23' then 'RAIL HONG KONG'
when valcarriercode = '24' then 'ARLANDA EXPRESS'
when valcarriercode = '25' then 'FLYTOGET'
when valcarriercode = '26' then 'OBB - AUSTRIAN RAILWAYS'
when valcarriercode = '30' then 'SWISS RAIL'
when valcarriercode = '31' then 'TRENITALIA'
when valcarriercode = '32' then 'ITALIAN RAIL'
when valcarriercode = '34' then 'ONTARIO NORTHLAND'
when valcarriercode = '36' then 'FIRST GREAT WESTERN ADVANCE'
when valcarriercode = '38' then 'PRIVATE RAIL CO - JAPAN' 
when valcarriercode = '41' then 'NMBS/SNCB NATIONAL RAILWAYS OF BELGIUM'       
when valcarriercode = '42' then 'RAIL EUROPE'
when valcarriercode = '43' then 'EUROTUNNEL SHUTTLE'
when valcarriercode = '44' then 'BELGIUM RAIL SERVICE CENTER'
when valcarriercode = '45' then 'JALPAK INTERNATIONAL'
when valcarriercode = '46' then 'FIRST CAPITAL CONNECT'
when valcarriercode = '47' then 'JAPAN RAILWAYS'
when valcarriercode = '6I' then 'GRAND RAIL CENTRAL'
when valcarriercode = '6X' then 'LONDON MIDLAND'
when valcarriercode = '7O' then 'LONDON OVERGROUND'
when valcarriercode = '9G' then 'AIRPORT EXPRESS RAIL LTD'
when valcarriercode = '9I' then 'EAST MIDLANDS TRAINS'
when valcarriercode = '9O' then 'WREXHAM SHROPSHIRE MARYLEBONE'
when valcarriercode = '92' then 'RENFE SPAIN RAIL'
when valcarriercode = '93' then 'RUSSIAN RAIL'
ELSE VendorName
END
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
	AND ID.VendorType = 'RAIL'
----AND ID.VendorName is null  ---- (Removing in case during import carriers table overwrites with an airline name instead of rail)
	AND ID.ValCarrierCode IS NOT NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Rail ID VendorName',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----  RAIL specifics only for AMEX for SegmentCarrierCode in Transeg 


SET @TransStart = getdate()
UPDATE dba.TranSeg
SET SegmentCarrierName = CASE
when segmentcarriercode = 'R0' then 'DEFAULT RAIL'
when segmentcarriercode = '0A' then 'ATOC-RSP'
when segmentcarriercode = '0A' then 'ATOC-RSP'
when segmentcarriercode = '0E' then 'FIRST GREAT WESTERN'
when segmentcarriercode = '0F' then 'GATWICK EXPRESS'
when segmentcarriercode = '0G' then 'HULL TRAINS'
when segmentcarriercode = '0H' then 'GREAT NORTH EASTERN RAILWAY'
when segmentcarriercode = '0I' then 'VIRGIN WEST COAST'
when segmentcarriercode = '0J' then 'VIRGIN CROSSCOUNTRY TRAINS'
when segmentcarriercode = '0K' then 'C2C'
when segmentcarriercode = '0L' then 'LONDON UNDERGROUND'
when segmentcarriercode = '0M' then 'MIDLAND MAINLINE'
when segmentcarriercode = '0N' then 'THE CHILTERN RAILWAY COMPANY'
when segmentcarriercode = '0O' then 'ISLAND LINE'
when segmentcarriercode = '0Q' then 'SOUTHERN/SOUTH CENTRAL'
when segmentcarriercode = '0R' then 'SOUTH EASTERN TRAINS'
when segmentcarriercode = '0S' then 'FIRST GREAT WESTERN LINK'
when segmentcarriercode = '0T' then 'MERSEYRAIL PTE'
when segmentcarriercode = '0U' then 'STRATHCLYDE PTE'
when segmentcarriercode = '0W' then 'SOUTH YORKSHIRE PTE'
when segmentcarriercode = '0X' then 'NEXUS TYNE AND WEAR PTE'
when segmentcarriercode = '0Y' then 'WEST MIDLANDS PTE'
when segmentcarriercode = '0Z' then 'WEST YORKSHIRE PTE'
when segmentcarriercode = '02' then 'CENTRAL TRAINS'
when segmentcarriercode = '03' then 'MERSEYRAIL'
when segmentcarriercode = '04' then 'ARRIVA TRAINS NORTHERN'
when segmentcarriercode = '06' then 'ARRIVA TRAINS WALES'
when segmentcarriercode = '08' then 'FIRST SCOTRAIL/SCOTRAIL RAILWAYS'
when segmentcarriercode = '09' then 'SOUTH WEST TRAINS'
when segmentcarriercode = '10' then 'THAMESLINK RAIL'
when segmentcarriercode = '11' then 'TRANSPENNINE EXPRESS'
when segmentcarriercode = '12' then 'ONE GER'
when segmentcarriercode = '13' then 'ONE LER'
when segmentcarriercode = '14' then 'WEST ANGLIA GREAT NORTHERN RAIL'
when segmentcarriercode = '19' then 'NORTHERN'
when segmentcarriercode = '2H' then 'THALYS INTL RAILWAY SAL'
when segmentcarriercode = '20' then 'RAIL CHINA'
when segmentcarriercode = '21' then 'RAIL MALAYSIA'
when segmentcarriercode = '22' then 'RAIL SINGAPORE'
when segmentcarriercode = '23' then 'RAIL HONG KONG'
when segmentcarriercode = '24' then 'ARLANDA EXPRESS'
when segmentcarriercode = '25' then 'FLYTOGET'
when segmentcarriercode = '26' then 'OBB - AUSTRIAN RAILWAYS'
when segmentcarriercode = '30' then 'SWISS RAIL'
when segmentcarriercode = '31' then 'TRENITALIA'
when segmentcarriercode = '32' then 'ITALIAN RAIL'
when segmentcarriercode = '34' then 'ONTARIO NORTHLAND'
when segmentcarriercode = '36' then 'FIRST GREAT WESTERN ADVANCE'
when segmentcarriercode = '38' then 'PRIVATE RAIL CO - JAPAN' 
when segmentcarriercode = '41' then 'NMBS/SNCB NATIONAL RAILWAYS OF BELGIUM'       
when segmentcarriercode = '42' then 'RAIL EUROPE'
when segmentcarriercode = '43' then 'EUROTUNNEL SHUTTLE'
when segmentcarriercode = '44' then 'BELGIUM RAIL SERVICE CENTER'
when segmentcarriercode = '45' then 'JALPAK INTERNATIONAL'
when segmentcarriercode = '46' then 'FIRST CAPITAL CONNECT'
when segmentcarriercode = '47' then 'JAPAN RAILWAYS'
when segmentcarriercode = '6I' then 'GRAND RAIL CENTRAL'
when segmentcarriercode = '6X' then 'LONDON MIDLAND'
when segmentcarriercode = '7O' then 'LONDON OVERGROUND'
when segmentcarriercode = '9G' then 'AIRPORT EXPRESS RAIL LTD'
when segmentcarriercode = '9I' then 'EAST MIDLANDS TRAINS'
when segmentcarriercode = '9O' then 'WREXHAM SHROPSHIRE MARYLEBONE'
when segmentcarriercode = '92' then 'RENFE SPAIN RAIL'
when segmentcarriercode = '93' then 'RUSSIAN RAIL'
ELSE SegmentCarrierName
END
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
	AND TS.TypeCode = 'R'
---	AND TS.SegmentCarrierName is null  ---- (Removing in case during import carriers table overwrites with an airline name instead of rail)
	AND TS.SegmentCarrierCode IS NOT NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Rail TS SegmentCarrierNames',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------End FEE AND RAIL Updates ----------

---------------------------------------------
----	PREFERRED CAR and AIR 
---------------------------------------------

----	Preferred Car Vendor where POS = Global  (Avis)
----	Added per SF 06022839 2.9.2015 Pam S

SET @TransStart = getdate()
update dba.car
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
	AND CAR.CarChainCode in ('ZI')
	AND CAR.PrefCarInd is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Preferred Car Vendor',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----	Preferred Air Vendors 
----	Added per SF 06022839 2.9.2015 Pam S

SET @TransStart = getdate()
UPDATE dba.InvoiceDetail
SET PrefTktInd =  CASE
	when valcarriercode in ('CA') and origcountry in ('CN','SG') then 'Y'
	when valcarriercode in ('LO') and origcountry in ('PL','FR','US') then 'Y'
	when valcarriercode in ('SA') and (origcountry in ('US','ZA','GB','DE') or CTRY.ContinentCode in ('AS','AU','SA')) then 'Y'
	when valcarriercode in ('TK') and origcountry in ('US','BR','RU','FR','ES','JP','CN','ZA','SA','TR') then 'Y'
	when valcarriercode in ('TP') and origcountry in ('TP') then 'Y'
	when valcarriercode in ('SK') and origcountry in ('DK','DE','FI','FR','NO','SE','US') then 'Y'
	when valcarriercode in ('EI') and origcountry in ('US','IE') then 'Y'
	when valcarriercode in ('UX') and (origcountry in ('ES','US','VE','BR','PE','AR','BO','UY','CL') or CTRY.ContinentCode in ('EU'))  then 'Y'
	when valcarriercode in ('OZ') and origcountry in ('AS','US') then 'Y'
	when valcarriercode in ('AD') and origcountry in ('BR') then 'Y'
	when valcarriercode in ('CM') and origcountry in ('BR') then 'Y'
	when valcarriercode in ('EY') and origcountry in ('RU','AE','SG','MY','US','AU') then 'Y'
	when valcarriercode in ('9W') and origcountry in ('IN','US') then 'Y'
	when valcarriercode in ('DY') and origcountry in ('NO','SE','DK','FI','FR','NL','GB') then 'Y'
	when valcarriercode in ('SV') then 'Y'
	when valcarriercode in ('WN','FL') and origcountry in ('US') then 'Y'
	when valcarriercode in ('SQ') and origcountry in ('AU','CN','ES','FR','DE','IN','JP','NZ','MY','SG','TW','GB','US') then 'Y'
	when valcarriercode in ('AV','TA') and origcountry in ('CO') then 'Y'
	when valcarriercode in ('EK') and (origcountry in ('IN','ZA','AU','NZ','MY','SG','TH','FR','DE','NL','ES','GB','AE') or CTRY.ContinentCode in ('AS')) then 'Y'
	when valcarriercode in ('DL') and origcountry in ('US') then 'Y'
	when valcarriercode in ('AF') and origcountry in ('FR') then 'Y'
	when valcarriercode in ('AZ') and origcountry in ('IT') then 'Y'
	when valcarriercode in ('KL') and origcountry in ('NL') then 'Y'
	ELSE PrefTktInd END
FROM dba.InvoiceDetail ID
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = ID.IataNum
	AND IH.ClientCode  = ID.ClientCode
	AND IH.RecordKey   = ID.RecordKey  
	AND IH.InvoiceDate = ID.InvoiceDate)
INNER JOIN dba.Country CTRY
	On (IH.OrigCountry = CTRY.CtryCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.PrefTktInd is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID.PrefTktInd- AIR Vendor',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE dba.Transeg
SET PrefAirInd =  CASE
	when SegmentCarrierCode in ('CA') and origcountry in ('CN','SG') then 'Y'
	when SegmentCarrierCode in ('LO') and origcountry in ('PL','FR','US') then 'Y'
	when SegmentCarrierCode in ('SA') and (origcountry in ('US','ZA','GB','DE') or CTRY.ContinentCode in ('AS','AU','SA')) then 'Y'
	when SegmentCarrierCode in ('TK') and origcountry in ('US','BR','RU','FR','ES','JP','CN','ZA','SA','TR') then 'Y'
	when SegmentCarrierCode in ('TP') and origcountry in ('TP') then 'Y'
	when SegmentCarrierCode in ('SK') and origcountry in ('DK','DE','FI','FR','NO','SE','US') then 'Y'
	when SegmentCarrierCode in ('EI') and origcountry in ('US','IE') then 'Y'
	when SegmentCarrierCode in ('UX') and (origcountry in ('ES','US','VE','BR','PE','AR','BO','UY','CL') or CTRY.ContinentCode in ('EU'))  then 'Y'
	when SegmentCarrierCode in ('OZ') and origcountry in ('AS','US') then 'Y'
	when SegmentCarrierCode in ('AD') and origcountry in ('BR') then 'Y'
	when SegmentCarrierCode in ('CM') and origcountry in ('BR') then 'Y'
	when SegmentCarrierCode in ('EY') and origcountry in ('RU','AE','SG','MY','US','AU') then 'Y'
	when SegmentCarrierCode in ('9W') and origcountry in ('IN','US') then 'Y'
	when SegmentCarrierCode in ('DY') and origcountry in ('NO','SE','DK','FI','FR','NL','GB') then 'Y'
	when SegmentCarrierCode in ('SV') then 'Y'
	when SegmentCarrierCode in ('WN','FL') and origcountry in ('US') then 'Y'
	when SegmentCarrierCode in ('SQ') and origcountry in ('AU','CN','ES','FR','DE','IN','JP','NZ','MY','SG','TW','GB','US') then 'Y'
	when SegmentCarrierCode in ('AV','TA') and origcountry in ('CO') then 'Y'
	when SegmentCarrierCode in ('EK') and (origcountry in ('IN','ZA','AU','NZ','MY','SG','TH','FR','DE','NL','ES','GB','AE') or CTRY.ContinentCode in ('AS')) then 'Y'
	when SegmentCarrierCode in ('DL') and origcountry in ('US') then 'Y'
	when SegmentCarrierCode in ('AF') and origcountry in ('FR') then 'Y'
	when SegmentCarrierCode in ('AZ') and origcountry in ('IT') then 'Y'
	when SegmentCarrierCode in ('KL') and origcountry in ('NL') then 'Y'
	ELSE PrefAirInd END
FROM dba.TranSeg TS
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = TS.IataNum
	AND IH.ClientCode  = TS.ClientCode
	AND IH.RecordKey   = TS.RecordKey  
	AND IH.InvoiceDate = TS.InvoiceDate)
INNER JOIN dba.Country CTRY
	On (IH.OrigCountry = CTRY.CtryCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.IataNum = @IataNum
	AND TS.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND TS.PrefAirInd is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TS.PrefAIRInd',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------
----	END Preferred CAR and AIR Updates
------------------------------------------------


-----------------------------
----  Class to Cabin
-----------------------------
----------------------------------------------------------------------------------------------
---- Before ComRmks Updates for Text14 Highest Class
----------------------------------------------------------------------------------------------

----- From Staging InvoiceDetail into Production Class to Cabin:

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.dba.classtocabin
SELECT distinct substring(ID.valCarrierCode,1,3), substring(ID.servicecategory,1,1), 'ECONOMY',ID.InternationalInd,'Y',NULL,NULL
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
	AND ID.ValCarrierCode IS NOT NULL
	AND ID.Servicecategory IS NOT NULL
	AND ID.VendorType in ('BSP','NONBSP','RAIL')
	AND substring(ID.ValCarrierCode,1,3)+substring(ID.servicecategory,1,1)+ID.InternationalInd
		NOT IN (SELECT DISTINCT CarrierCode+ClassOfService+InternationalInd 
				FROM @Prodserver.database.DBA.ClassToCabin)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ClassToCabin FROM InvoiceDetalil',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----From Staging Transeg into Production Class to Cabin:

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.dba.classtocabin
SELECT distinct substring(TS.SegmentCarrierCode,1,3), substring(TS.ClassOfService,1,1), 'ECONOMY',TS.segInternationalInd,'Y',NULL,NULL
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
	AND TS.SegmentCarrierCode IS NOT NULL
	AND TS.ClassOfService IS NOT NULL
	AND substring(TS.SegmentCarrierCode,1,3)+substring(TS.ClassOfService,1,1)+TS.SegInternationalInd 
		NOT IN (SELECT DISTINCT CarrierCode+ClassOfService+InternationalInd 
				FROM @Prodserver.database.DBA.ClassToCabin)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ClassToCabin from Transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------------------------------------

--------  Begin DELETE AND INSERT ComRmks -----
----  **Note DO NOT ADD:
----    these JOINS: 
----      AND IH.InvoiceDate = CR.InvoiceDate
----      AND IH.ClientCode = CR.ClientCode
----    or FILTER:
----      AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
----    in case InvoiceDates or ClientCodes changed with newly arrived data
----   ** Only match on Iatanum AND Recordkey to delete
 
SET @TransStart = getdate()
DELETE dba.ComRmks
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH 
	ON (IH.Iatanum   = CR.Iatanum 
	AND IH.RecordKey = CR.RecordKey)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.Iatanum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete DBA.comrmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IATANUM, SeqNum, ClientCode, InvoiceDate, IssueDate)
SELECT DISTINCT ID.RecordKey, ID.IATANUM, ID.SeqNum, ID.ClientCode, ID.InvoiceDate, ID.IssueDate
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
	AND ID.RecordKey+ID.IataNum+CONVERT(VARCHAR,ID.SeqNum)
		NOT IN (SELECT CR.RecordKey+CR.IataNum+CONVERT(VARCHAR,CR.SeqNum) 
				FROM DBA.ComRmks CR
				WHERE CR.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Stag CR',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------
----------------------------------------------------------------------
----	ComRmks to 'Not Provided' prior to updating with agency data
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
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='SET text fields to Not Provided',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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

SET @TransStart = getdate()
UPDATE CR
SET Text2 = CASE WHEN IH.OrigCountry IS NULL THEN 'Not Provided' ELSE IH.OrigCountry END
FROM dba.ComRmks CR
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
 EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text2_IH POS_Ctry',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------
-----     End StANDard ComRmks Mappings      --------------------
-----------------------------------------------------------------

-----------------------------------------------------------------
-----     Begin client Specific ComRmks Mappings    -------------
-----------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
----	Text1 for EmployeeID 
----	Text50 for EmployeeID Raw Data as received without substrings other than 1,150 to fit in text field
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
----	Text1 ID.Remarks1 using SUBSTRING(ID.Remarks1,2,8)
----	Text50 Raw Data as received in ID.Remarks1 without substrings other than 1,150 to fit in text field
------------------------------------------------------------------------------------------------------------
----	For ABBV00','ABBV01','ABBV02'
----	Per Chantal's email on 1/26/2015 - SF 51931 - "I will send Deborah some PNR examples, but in the interim please update the AMEX stored procedure to use a substring to 8 for Employee Id until we can confirm that UDEF102 will always store the value for Employee Id."
----	Checked Employee table -(IDs are 8 characters) AND analyzed data (starting position is 2) so substring should be SUBSTRING(id.Remarks1,2,8)
----	Pam S modified this on 1/27/2015 AND updated data

SET @TransStart = getdate()
UPDATE CR
SET CR.Text1  = CASE
				WHEN ID.Remarks1 IS NULL THEN 'Not Provided'
				WHEN ID.Remarks1 IS NOT NULL AND SUBSTRING(ID.Remarks1,2,8) <> '' THEN SUBSTRING(ID.Remarks1,2,8)
				ELSE 'Not Provided'
				END
,CR.Text50 = substring(ID.Remarks1,1,150)
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
	AND CL.CustAddr1 in ('ABBV00','ABBV01','ABBV02')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from SUBSTRING(ID.Remarks1,2,8)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------------------------------
----	Text1  from U2 using SUBSTRING(UD.UdefData,1,8)
----	Text50 from U2 as Raw Data Received in UdefData - StANDard per Jim Messer
--------------------------------------------------------------------------------------
----	For ('ABBVP1','ABBV93','ABBVBT') 
----	Per SF 51931 - 1/27/2015 - Pam S modified substring to include all 8 digits for EmployeeID1	(Was pulling only 7 characters)
-----------------------------------------------
SET @TransStart = getdate()
UPDATE CR
SET CR.Text1  = CASE
				WHEN UD.UdefData IS NULL THEN 'Not Provided'
				WHEN UD.UdefData IS NOT NULL AND UD.UdefData like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' THEN SUBSTRING(UD.UdefData,1,8)
				ELSE 'Not Provided'
				END
,Text50 = substring(UD.UdefData,1,150)
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 2
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.IataNum = @IataNum
	AND CL.CustAddr1 in ('ABBVP1','ABBV93','ABBVBT')
----AND CR.Text1 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from U2 SUBSTRING(UD.UdefData,1,8)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------------
----	Text1  from U4 using SUBSTRING(UD.UdefData,1,8)  
----	Text50 from U4 as Raw Data Received in UdefData - StANDard per Jim Messer
--------------------------------------------------------------------------------------
----	For ABBV83
----	Per SF 51931 - Pam S modified substring to include all 8 digits for EmployeeID1 (Was pulling only 7 characters)

SET @TransStart = getdate()
UPDATE CR
SET 
CR.Text1  = CASE
			WHEN UD.UdefData IS NULL THEN 'Not Provided'
			WHEN UD.UdefData IS NOT NULL AND SUBSTRING(UD.UdefData,1,8) <> '' THEN SUBSTRING(UD.UdefData,1,8)
			ELSE 'Not Provided'
			END
,CR.Text50 = substring(UD.UdefData,1,150)
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 4
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.CustAddr1 in ('ABBV83')
----AND CR.Text1 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from U4 SUBSTRING(UD.UdefData,1,8)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------------------------
----	Text3 for Cost Center 
--------------------------------------------------------------------------------

----	Text3 for Cost Center now from dba.Employee table on Production 
----	for all records from Data Provider per SF 06174423 -3/24/2015
----	So, on 3/24/2015, Pam S making 
----	Text47 as the original Text3 updates for Cost Center of each ClientCode/CustAddr1 specific
----	Text48 as raw data received from Data Provider in field where original Cost Center resides per ClientCode/CustAddr1 specific
SET @TransStart = getdate()
UPDATE CR
SET CR.Text3 = CASE WHEN isnull(EMP.CostCenter,'') = '' then 'Not Provided'
	                ELSE EMP.CostCenter END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (CR.IataNum     = IH.IataNum
	AND CR.ClientCode  = IH.ClientCode
	AND CR.RecordKey   = IH.RecordKey  
	AND CR.InvoiceDate = IH.InvoiceDate)
INNER JOIN @Prodserver.database.dba.Employee EMP
	ON (CR.Text1   = EMP.EmployeeID1)
INNER JOIN dba.Client CL
	ON (CR.IataNum     = CL.Iatanum
	AND CR.ClientCode  = CL.ClientCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
--	and CR.Text3 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text3 from EMP.CostCenter',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------------------------------------------------------------------------
----	Text47 Original Data Provider Cost Center substringed - from ID.Remarks1 using SUBSTRING(id.Remarks1,14,6)
----	Text48 Original Data Provider Cost Center Raw Data as received in ID.Remarks1 without substrings other than 1,150 to fit in text field
------------------------------------------------------------------------------------------------------------
----	For CustAddr1 ABBV00','ABBV01','ABBV02 (US/Puerto Rico)

SET @TransStart = getdate()
UPDATE CR
SET CR.Text47  = CASE
				WHEN ID.Remarks1 IS NULL THEN 'Not Provided'
				WHEN ID.Remarks1 IS NOT NULL AND SUBSTRING(ID.Remarks1,14,6) <> '' THEN SUBSTRING(ID.Remarks1,14,6)
				ELSE 'Not Provided'
				END
,CR.Text48 = substring(ID.Remarks1,1,150)
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
	AND CL.CustAddr1 in ('ABBV00','ABBV01','ABBV02')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text47 from SUBSTRING(ID.Remarks1,14,6)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------------------------------------------------------------------------------------
----	Text47 Original Data Provider Cost Center substringed from U4 SUBSTRING(UD.UdefData,1,6)
----	Text48 Original Data Provider Cost Center from U4 as Raw Data Received in UdefData - Standard per Jim Messer
--------------------------------------------------------------------------------------
----	For custaddr1 ABBVP1','ABBVBT','ABBV93'

SET @TransStart = getdate()
UPDATE CR
SET 
CR.Text47  = CASE
			WHEN UD.UdefData IS NULL THEN 'Not Provided'
			WHEN UD.UdefData IN ('.') THEN 'Not Provided' 
			WHEN UD.UdefData IS NOT NULL AND UD.UdefData NOT IN ('.') AND SUBSTRING(UD.UdefData,1,6) <> '' THEN SUBSTRING(UD.UdefData,1,6)
			ELSE 'Not Provided'
			END
,CR.Text48 = substring(UD.UdefData,1,150)
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 4
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.CustAddr1 in ('ABBVP1','ABBVBT','ABBV93')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text47 from U4 SUBSTRING(UD.UdefData,1,6)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------
----	Text4 for Department 
----------------------------------------------------------------------------------------------------------------------------------------------------
---- Per SF SF case 06174423 3/31/2015 -Pam S
----	Removed steps for Text4 from TMC/Data provider fields -- to use EMP.OrganizationUnit from Employee table instead, for all ClientCodes/CustAddr1
----	Was:
----	Text4 from SUBSTRING(ID.Remarks1,10,4)	For ABBV00','ABBV01','ABBV02
----	Text4 fromm U3 SUBSTRING(UD.UdefData,1,4) For ABBVP1','ABBVBT','ABBV93'
----------------------------------------------------------------------------------------------------------------------------------------------------

SET @TransStart = getdate()
UPDATE CR
SET CR.Text4 =
case when isnull(EMP.OrganizationUnit,'') = '' then 'Not Provided'
	              Else EMP.OrganizationUnit END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (CR.IataNum     = IH.IataNum
	AND CR.ClientCode  = IH.ClientCode
	AND CR.RecordKey   = IH.RecordKey  
	AND CR.InvoiceDate = IH.InvoiceDate)
INNER JOIN @Prodserver.database.dba.Employee EMP
	ON (CR.Text1   = EMP.EmployeeID1)
INNER JOIN dba.Client CL
	ON (CR.IataNum     = CL.Iatanum
	AND CR.ClientCode  = CL.ClientCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text4 fromm EMP.OrganizationUnit',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------
----	Text5 for Division
-------------------------------------------------------------

---- Per SF SF case 06174423 3/31/2015 -Pam S
----	Added step for Text5 from EMP.AdditionalInfo1 for Division

SET @TransStart = getdate()
UPDATE CR
SET CR.Text5 =
case when isnull(EMP.AdditionalInfo1,'') = '' then 'Not Provided'
	              Else EMP.AdditionalInfo1 END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (CR.IataNum     = IH.IataNum
	AND CR.ClientCode  = IH.ClientCode
	AND CR.RecordKey   = IH.RecordKey  
	AND CR.InvoiceDate = IH.InvoiceDate)
INNER JOIN @Prodserver.database.dba.Employee EMP
	ON (CR.Text1   = EMP.EmployeeID1)
INNER JOIN dba.Client CL
	ON (CR.IataNum     = CL.Iatanum
	AND CR.ClientCode  = CL.ClientCode)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text5 fromm EMP.EMP.AdditionalInfo1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------
----	Text7 for Trip Purpose
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
----	Text7 from U7 SUBSTRING(ud.udefdata,1,2)
--------------------------------------------------------------------------------
----	For US/Puerto Rico AND Spain using CL.CustAddr1  in ('ABBV00','ABBV01','ABBV02','ABBV93')
----	Pam S 1.28.2015
----	Modified from former step for Trip Purpose where Text7 was pulling from UD 117 substring (UD.Udefdata,1,1) with no CustAddr1 filters
----	Researched Imp.Wkbk v3 in SF 00051931 - In ComRmks tab, saw where only US/Puerto Rico AND Spain pulling from Sort3 for Trip Purpose
----	Data Feed tab for @iatanum, only shows US Puerto Rico with Sort 3/Pos 1-2 (Nothing for Spain)
----	Spreadsheet, 'GlobalMaxUdefs-Amex shows U17	Sort Field Remark 3	U117 C
----	Saw where Amex has Lookup values of (IM,EC,SM,CM,OT) for Trip Purpose
----	Queried U117 for US/Puerto Rico AND Spain using CL.CustAddr1  in ('ABBV00','ABBV01','ABBV02','ABBV93') -- Data appears incorrect
----	Then queried for U17 for US/Puerto Rico AND Spain using CL.CustAddr1  in ('ABBV00','ABBV01','ABBV02','ABBV93') -- Data appears correct according to codes given in ImpWkbk
----	Therefore changing step to pull from U17 instead of U117 for US/Puerto Rico AND Spain using CL.CustAddr1  in ('ABBV00','ABBV01','ABBV02','ABBV93')
----	Also changing substring to pull 2 characters instead of 1  --SUBSTRING(ud.udefdata,1,2)
----	Note: Only Us/Puerto Rico is sending Trip Purpose codes in U7 - Spain ('ABBV93') is not.

SET @TransStart = getdate()
UPDATE CR
SET CR.Text7  = CASE
				WHEN UD.UdefData IS NULL THEN 'Not Provided'
				WHEN UD.UdefData IS NOT NULL AND SUBSTRING(ud.udefdata,1,2) <> '' THEN SUBSTRING(ud.udefdata,1,2)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 17
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.CustAddr1 in ('ABBV00','ABBV01','ABBV02','ABBV93')
----AND CR.Text7 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text7 fromm U17 SUBSTRING(UD.UdefData,1,2)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------------------------
----	Text8 for Reservation Type - Online / Offline
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
----	Text8 from U29 - To Amex, also known has G3 (Government remark 3)
--------------------------------------------------------------------------------
----	For US/Puerto Rico AND Spain ('ABBV00','ABBV01','ABBV02','ABBV93') -- Q,N,J means Online

--------------------------------------------------------
---- Per email from Deborah A Doerr at Amex in SF 51931: 
---- "The presence of a G3 field indicates the transaction started online; the absence of the field (or null) indicates offline."
---- ***Note using Outer Join from Udef to get those records not existing in Udef table
---- Also eliminates need to use clientcodes, '00000037346' for Online AND '00000037348' for Offline - Had brought to attention other clientcodes that were not getting coded in SF 51931 so using G3 instead which is equivalent to U29
-------------------------------------------------------

SET @TransStart = getdate()
UPDATE CR
set CR.text8  = CASE
				WHEN UD.UdefData IS NOT NULL THEN 'ONLINE' 
				WHEN UD.UdefData IS NULL THEN 'OFFLINE'
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 29
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.CustAddr1 in ('ABBV00','ABBV01','ABBV02','ABBV93')
----AND CR.Text8 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text8 fromm U29',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------
----	Text8 from U110 for Brazil ('ABBV83') added per SF 51931:
--------------------------------------------------------------------------------

SET @TransStart = getdate()
UPDATE CR
set cr.text8  = CASE
				WHEN substring(udefdata,1,2) in ('SN') then 'ONLINE' 
				WHEN substring(udefdata,1,2) in ('NN') then 'OFFLINE'
				ELSE 'OFFLINE'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 110
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.CustAddr1 in ('ABBV83')
----AND CR.Text8 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text8 from U110 substring(udefdata,1,2)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------------------------
----	Text9 for Hotel Reason Code - (Why No Hotel Booked)
--------------------------------------------------------------------------------
----	Amex values in Lookup are B,C,,F,N,U

--------------------------------------------------------------------------------
----	Text9 from U1 substring (UD.Udefdata,1,1)
--------------------------------------------------------------------------------
----	For US Peurto Rico: Udid1/Pos 1	 - Hotel Reason (Booking)	UDID1	U1-B

----	Pam S 1.28.2015
----	Modified from former step of Hotel Reason Code where Text9 pulling from UD1 substring (UD.Udefdata,1,1) with no CustAddr1 filters
----	Researched Imp.Wkbk v3 in SF 00051931 - Added filter for US/Puerto Rico - CL.CustAddr1 in ('ABBV00','ABBV01','ABBV02')

SET @TransStart = getdate()
UPDATE CR
SET CR.Text9 = CASE
				WHEN UD.UdefData IS NULL THEN 'Not Provided'
				WHEN UD.UdefData IS NOT NULL AND SUBSTRING(ud.udefdata,1,1) <> '' THEN SUBSTRING(ud.udefdata,1,1)
				ELSE 'Not Provided'
				END
FROM dba.ComRmks CR
INNER JOIN dba.InvoiceHeader IH
	ON (IH.IataNum     = CR.IataNum
	AND IH.ClientCode  = CR.ClientCode
	AND IH.RecordKey   = CR.RecordKey  
	AND IH.InvoiceDate = CR.InvoiceDate)
INNER JOIN dba.client CL 
	ON (CR.IataNum = CL.Iatanum 
	AND CR.ClientCode = CL.ClientCode)
LEFT OUTER JOIN dba.Udef UD
	ON (CR.Iatanum     = UD.Iatanum
	AND CR.ClientCode  = UD.ClientCode
	AND CR.Recordkey   = UD.Recordkey
	AND CR.Seqnum      = UD.Seqnum
	AND CR.InvoiceDate = UD.InvoiceDate
	AND UD.Udefnum	   = 1
	AND UD.IataNum	   = @IataNum)
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CL.CustAddr1 in ('ABBV00','ABBV01','ABBV02')
----AND CR.Text9 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text9 fromm U1 SUBSTRING(UD.UdefData,1,1)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------------------------------------
----	Text14 - STANDARD Highest Cabin 
---------------------------------------

----	1st) For First class
 
SET @TransStart = getdate()
UPDATE StagCR
SET StagCR.Text14 = ProdCTC.DomCabin 
FROM @StagServer.database.dba.ComRmks StagCR 
INNER JOIN @StagServer.database.dba.InvoiceHeader StagIH 
	ON (StagIH.Iatanum     = StagCR.Iatanum
	AND StagIH.Clientcode  = StagCR.ClientCode
	AND StagIH.RecordKey   = StagCR.RecordKey
	AND StagIH.InvoiceDate = StagCR.InvoiceDate)
INNER JOIN @StagServer.database.dba.TranSeg StagTS 
	ON (StagCR.Iatanum     = StagTS.Iatanum
	AND StagCR.ClientCode  = StagTS.ClientCode
	AND StagCR.RecordKey   = StagTS.RecordKey
	AND StagCR.Seqnum      = StagTS.SeqNum)
INNER JOIN @Prodserver.database.dba.classtocabin ProdCTC 
	ON (StagTS.minsegmentcarriercode = ProdCTC.carriercode
	AND StagTS.minclassofservice     = ProdCTC.classofservice
	AND StagTS.mininternationalind   = ProdCTC.InternationalInd)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.iatanum  = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagCR.iatanum  = @IataNum
	AND StagCR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagTS.IataNum  = @IataNum
	AND StagTS.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdCTC.DomCabin = 'First' 
----AND StagCR.text14 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Highest Cabin = FIRST',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----	2nd) For Business Class
 
SET @TransStart = getdate()
UPDATE StagCR
SET StagCR.Text14 = ProdCTC.DomCabin 
FROM @StagServer.database.dba.ComRmks StagCR 
INNER JOIN @StagServer.database.dba.InvoiceHeader StagIH
	ON (StagIH.Iatanum     = StagCR.Iatanum
	AND StagIH.Clientcode  = StagCR.ClientCode
	AND StagIH.RecordKey   = StagCR.RecordKey
	AND StagIH.InvoiceDate = StagCR.InvoiceDate)
INNER JOIN @StagServer.database.dba.TranSeg StagTS
	ON (StagCR.Iatanum     = StagTS.Iatanum
	AND StagCR.ClientCode  = StagTS.ClientCode
	AND StagCR.RecordKey   = StagTS.RecordKey
	AND StagCR.Seqnum      = StagTS.SeqNum)
INNER JOIN @Prodserver.database.dba.classtocabin ProdCTC 
	ON (StagTS.minsegmentcarriercode = ProdCTC.carriercode
	AND StagTS.minclassofservice     = ProdCTC.classofservice
	AND StagTS.mininternationalind   = ProdCTC.InternationalInd)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.iatanum  = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagCR.iatanum  = @IataNum
	AND StagCR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagTS.IataNum  = @IataNum
	AND StagTS.InvoiceDate between @FirstInvDate AND @LastInvDate 
	AND ProdCTC.DomCabin = 'Business'
----AND StagCR.text14 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Highest Cabin = BUSINESS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----	3rd) Then all others

SET @TransStart = getdate()
UPDATE StagCR
SET StagCR.Text14 = ProdCTC.DomCabin 
FROM @StagServer.database.dba.ComRmks StagCR 
INNER JOIN @StagServer.database.dba.InvoiceHeader StagIH
	ON (StagIH.Iatanum     = StagCR.Iatanum
	AND StagIH.Clientcode  = StagCR.ClientCode
	AND StagIH.RecordKey   = StagCR.RecordKey
	AND StagIH.InvoiceDate = StagCR.InvoiceDate)
INNER JOIN @StagServer.database.dba.TranSeg StagTS
	ON (StagCR.Iatanum     = StagTS.Iatanum
	AND StagCR.ClientCode  = StagTS.ClientCode
	AND StagCR.RecordKey   = StagTS.RecordKey
	AND StagCR.Seqnum      = StagTS.SeqNum)
INNER JOIN @Prodserver.database.dba.classtocabin ProdCTC 
	ON (StagTS.minsegmentcarriercode = ProdCTC.carriercode
	AND StagTS.minclassofservice     = ProdCTC.classofservice
	AND StagTS.mininternationalind   = ProdCTC.InternationalInd)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.iatanum  = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagCR.iatanum  = @IataNum
	AND StagCR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagTS.IataNum  = @IataNum
	AND StagTS.InvoiceDate between @FirstInvDate AND @LastInvDate
----AND StagCR.text14 = 'Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Highest Cabin = all others',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-------------------------------------------------------
----	Text48 for Cost Center for hierarchy purpose
--------------------------------------------------------

---- Need to verify if this is really being used


---------------------------------------------------------
----	Text50 for EmployeeID at beginning before Text1 updates
---------------------------------------------------------

----------------------------------------------------------------
----	NUM1 from Farecompare 1 AND NUM2 from Farecompare2
----------------------------------------------------------------

----	NUM1 from FareCompare1

SET @TransStart = getdate()
UPDATE CR
SET Num1 = ID.farecompare1
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
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	AND ID.InvoiceDate between @FirstInvDate AND @LastInvDate
AND CR.num1 IS NULL
AND ID.FareCompare1 IS NOT NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Num1 from FC1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

    									  
----	NUM2 from FareCompare2

SET @TransStart = getdate()
UPDATE CR
SET Num2 = ID.farecompare2
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
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND CR.IataNum = @IataNum
	AND CR.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ID.IataNum = @IataNum
	
--------------------------------------------
----	END STANDARD FC1 AND FC2 UPDATES
--------------------------------------------

----	Check if ReasonCodes need to be changed

----/////////////////////////////////////////////////////////////////////////

---- /* BEGIN PRE-HNN HOTEL CLEANUP -----*/

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='BEGIN HTL edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------------------------------
---- /* Removing beginning AND ending spaces in all hotel fields */
----------------------------------------------------------------------------------------
	/* HtlPropertyName */
SET @TransStart = getdate()
UPDATE StagHTL
SET StagHTL.htlpropertyname = rtrim(ltrim(StagHTL.htlpropertyname))
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
	AND substring(StagHTL.HtlPropertyName,1,1) = ' '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remove Begin-End Spaces HTLpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

	/*HtlAddr1*/
SET @TransStart = getdate()
UPDATE StagHTL
SET StagHTL.HtlAddr1 = rtrim(ltrim(StagHTL.HtlAddr1))
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
	AND substring(StagHTL.HtlAddr1,1,1) = ' '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remove Begin-End Spaces HtlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

	/*HtlAddr2*/
SET @TransStart = getdate()
UPDATE StagHTL
SET StagHTL.HtlAddr2 = rtrim(ltrim(StagHTL.HtlAddr2))
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
	AND substring(StagHTL.HtlAddr2,1,1) = ' '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remove Begin-End Spaces HtlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


	/*HtlAddr3*/
SET @TransStart = getdate()
UPDATE StagHTL
SET StagHTL.HtlAddr3 = rtrim(ltrim(StagHTL.HtlAddr3))
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
	AND substring(StagHTL.HtlAddr3,1,1) = ' '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remove Begin-End Spaces HtlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


	/*HtlChainCode*/
SET @TransStart = getdate()
UPDATE StagHTL
SET StagHTL.HtlChainCode = rtrim(ltrim(StagHTL.HtlChainCode))
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
	AND substring(StagHTL.HtlChainCode,1,1) = ' '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remove Begin-End Spaces HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


	/*HtlPostalCode*/
SET @TransStart = getdate()
UPDATE StagHTL
SET StagHTL.HtlPostalCode = rtrim(ltrim(StagHTL.HtlPostalCode))
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
	AND substring(StagHTL.HtlPostalCode,1,1) = ' '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remove Begin-End Spaces HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------
--UPDATE City Name to NULL if start with '.'
--------------------------------------------
----	Verified with Nina - This covers a data provider having HtlCityName preceded by period(.) which was not actually a city
SET @TransStart = getdate()
UPDATE StagHTL
SET htladdr3 = htlcityname
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.HtlCityName like '.%'
	AND StagHTL.HtlAddr3 IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HtlCityName with period (.)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = null
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcityname like '.%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Move HtlCityName to HtlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------
--Removing unseen characters in htlpropertyname AND htladdr1
--------------------------------------------------------------

SET @TransStart = getdate()
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Replace char HtlProperty AND Address',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------------------
 ----  Move HtlAddr2 data to HtlAddr1 if HtlAddr1 IS NULL AND HtlAddr2 IS NOT NULL
 ----  Pam S added this step to stANDard
 -------------------------------------------------------------------------------------------
SET @TransStart = getdate()
UPDATE StagHTL
set  htladdr1 = htladdr2
	,htladdr2 = NULL
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
	AND StagHTL.masterid IS NULL
	AND StagHTL.htladdr1 IS NULL
	AND StagHTL.htladdr2 IS NOT NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Move htladdr2 to HtlAddr1 when null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
set htladdr2 = null
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
	AND StagHTL.masterid IS NULL
	AND StagHTL.htladdr2 = htladdr1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HtlAddr2 to Null if HtlAddr1=HtlAddr2 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------------
---- Master ID to -1 if unalbe to determine property name AND HtlAddr1
----------------------------------------------------------------------

SET @TransStart = getdate()
UPDATE StagHTL
SET masterid = -1
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
	AND (HtlPropertyName like 'OTHER%HOTELS%' 
	 or  HtlPropertyName like '%NONAME%'
	 or  HtlPropertyName IS NULL
	 or  HtlPropertyName = '')
	AND (HtlAddr1 IS NULL or HtlAddr1 = '' )
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='MasterID to -1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------------------------------
------  NEVER USE CITY TABLE FOR HOTEL UPDATES !!!!!
------  Use Master Zip Code table to update state AND country code if Null
------------------------------------------------------------------

----- First, Updates for Canada based on Zip Codes -------

SET @TransStart = getdate()
UPDATE StagHTL
SET  StagHTL.HtlState       = CASE when StagHTL.HtlState <> 'ON' then 'ON' ELSE StagHTL.HtlState END
	,StagHTL.HtlCountryCode = CASE when StagHTL.HtlCountryCode <> 'CA' then 'CA' Else StagHTL.HtlCountryCode END
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
	AND (StagHTL.htlpostalcode like 'L%'or StagHTL.HtlPostalcode like 'N%')
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlcitycode in ('BUF','DTW')
	AND StagHTL.masterid IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='BUF DTW  -Zip in CA -Not in US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE StagHTL
SET  StagHTL.htlcityname	= CASE when StagHTL.htlcityname <> Upper('Niagra Falls') then Upper('Niagra Falls') ELSE StagHTL.htlcityname END
	,StagHTL.HtlState		= CASE when StagHTL.HtlState <> 'ON' then 'ON' ELSE StagHTL.HtlState END
	,StagHTL.HtlCountryCode = CASE when StagHTL.HtlCountryCode <> 'CA' then 'CA' ELSE StagHTL.HtlCountryCode END
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
	AND StagHTL.htlpostalcode in ('L2G3V9','L2G 3V9')
	AND StagHTL.masterid IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip for Niagra Falls, CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE StagHTL
SET  StagHTL.htlcityname	= CASE when StagHTL.htlcityname <> Upper('Niagara On The Lake') then Upper('Niagara On The Lake') ELSE StagHTL.htlcityname END
	,StagHTL.HtlState		= CASE when StagHTL.HtlState <> 'ON' then 'ON' ELSE StagHTL.HtlState END
	,StagHTL.HtlCountryCode = CASE when StagHTL.HtlCountryCode <> 'CA' then 'CA' ELSE StagHTL.HtlCountryCode END
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
	AND StagHTL.htlpostalcode = 'L0S 1J0'
	AND StagHTL.masterid IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip for Niagara On The Lake, CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE StagHTL
SET  StagHTL.htlcityname    = CASE when StagHTL.htlcityname		<> 'WINDSOR' then 'WINDSOR' ELSE StagHTL.htlcityname END
	,StagHTL.htlstate       = CASE when StagHTL.htlstate		<> 'ON'	     then 'ON'		ELSE StagHTL.htlstate END
	,StagHTL.HtlCountryCode = CASE when StagHTL.HtlCountryCode	<> 'CA'		 then 'CA'		ELSE StagHTL.HtlCountryCode END
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
	AND StagHTL.HtlPostalCode in ('N9A 1B2','N9A 7H7','N9C 2L6')
	AND StagHTL.masterid IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip for Windsor CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET  StagHTL.htlcityname	= CASE when StagHTL.htlcityname <> upper('Point Edward') then upper('Point Edward') ELSE StagHTL.htlcityname END
	,StagHTL.HtlState		= CASE when StagHTL.HtlState <> 'ON' then 'ON' ELSE StagHTL.HtlState END
	,StagHTL.HtlCountryCode = CASE when StagHTL.HtlCountryCode <> 'CA' then 'CA' ELSE StagHTL.HtlCountryCode END
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
	AND StagHTL.htlpostalcode in ('N7T 7W6')
	AND StagHTL.masterid IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip for Point Edward CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------M5V 2G5 = TORONTO CA if ever need to add a step for this one

---- END Updates for Canada based on Zip Code -------------

-------------------------------------------------------------------------------------
---- AFTER Canada updates, BEGIN Updates for US States AND Cities based on Zip Codes
-------------------------------------------------------------------------------------

---- 1st, Remove HtlStateCode if not in these countries: ('US','CA','AU','BR')

SET @TransStart = getdate()
UPDATE StagHTL
SET HtlState = NULL
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlstate IS NOT NULL
	AND StagHTL.HtlCountryCode not in ('US','CA','AU','BR')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Null HtlState if not US,CA,AU,BR',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 	
----  2nd, Where Countrycode IS NULL, update to US based on Htlstate AND matching zip code

SET @TransStart = getdate()
UPDATE StagHTL
SET HtlCountryCode = 'US'
FROM dba.Hotel StagHTL
INNER JOIN dba.InvoiceHeader StagIH 
	ON (StagIH.IataNum     = StagHTL.IataNum
	AND StagIH.RecordKey   = StagHTL.RecordKey  
	AND StagIH.InvoiceDate = StagHTL.InvoiceDate)
INNER JOIN TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
	ON 	(substring(StagHTL.htlpostalcode,1,5) = zp.zipcode AND zp.primaryrecord = 'p')
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.IataNum = @IataNum
	AND StagHTL.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.MasterID IS NULL
	AND substring(StagHTL.HtlPostalCode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
	AND StagHTL.HtlCountryCode IS NULL
	AND StagHTL.htlstate in ('AK','AL','AR','AZ','CA','CO','CT','DC','DE','FL','GA','HI','IA'
 		,'ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN','MO','MS','MT','NC','ND','NE'
 		,'NH','NJ','NM','NV','NY','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VA','VT'
 		,'WA','WI','WV','WY')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HtlCountry to US based on zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 
---- Where State code IS NULL or wrong for US -----
SET @TransStart = getdate()
UPDATE StagHTL
SET HtlState = zp.state
FROM dba.Hotel StagHTL
INNER JOIN dba.InvoiceHeader StagIH 
	ON (StagIH.IataNum     = StagHTL.IataNum
	AND StagIH.RecordKey   = StagHTL.RecordKey  
	AND StagIH.InvoiceDate = StagHTL.InvoiceDate)
INNER JOIN TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
	ON 	(substring(StagHTL.htlpostalcode,1,5) = zp.zipcode AND zp.primaryrecord = 'p')
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.IataNum = @IataNum
	AND StagHTL.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.MasterID IS NULL
	AND substring(StagHTL.HtlPostalCode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
	AND StagHTL.HtlCountryCode = 'US'
	AND isnull(StagHTL.HtlState,'') <> zp.state
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HtlState from US Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----- Where city name is wrong for US cities ----
SET @TransStart = getdate()
UPDATE StagHTL
SET HtlCityName = Upper(zp.city)
FROM dba.Hotel StagHTL
INNER JOIN dba.InvoiceHeader StagIH 
	ON (StagIH.IataNum     = StagHTL.IataNum
	AND StagIH.RecordKey   = StagHTL.RecordKey  
	AND StagIH.InvoiceDate = StagHTL.InvoiceDate)
INNER JOIN TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
	ON 	(substring(StagHTL.htlpostalcode,1,5) = zp.zipcode AND zp.primaryrecord = 'p')
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.IataNum = @IataNum
	AND StagHTL.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND StagHTL.MasterID IS NULL
	AND substring(StagHTL.HtlPostalCode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'	
	AND StagHTL.htlcountrycode = 'US'
	AND isnull(StagHTL.HtlCityName,'') <> zp.city
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CityName by US Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---- END US updates based on Zip Code -------

--------------------------------------------------------------------
----Correct CityName to Paris where zip codes begin with 75 + 3 digit region

SET @TransStart = getdate()
UPDATE StagHTL
SET  HtlCityName = 'PARIS'
	,HtlState = NULL
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.HtlCountryCode = 'FR' 
	AND StagHTL.HtlPostalCode like '75[0-9][0-9][0-9]'
	AND StagHTL.HtlCityName <> 'PARIS'
	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CityName to Paris by Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---- For GB based on Zip Codes ----

SET @TransStart = getdate()
UPDATE StagHTL
SET  HtlState = NULL
	,HtlCityName =
	CASE 
	when htlpostalcode in ('RG1 1DP','RG1 1JX','RG11JX','RG1 8DB','RG2 0FL','RG2 0GQ')AND htlcityname <> 'READING' then 'READING'
	when htlpostalcode in ('RG21 3DR')AND htlcityname <> 'BASINGSTOKE' then 'BASINGSTOKE'
	when htlpostalcode in ('W1G 0PG','W1B 2QS','W1G 9BL','W1M 8HS','W1H 5DN','W1K 7TN')AND htlcityname <> 'LONDON' then 'LONDON'
	when htlpostalcode in ('OX2 6JP')AND htlcityname <> 'OXFORD' then 'OXFORD'
	when htlpostalcode in ('SL3 8PT','SL38PT')AND htlcityname <> 'SLOUGH' then 'SLOUGH'
	when htlpostalcode in ('UB3 5AN')AND htlcityname <> 'HAYES' then 'HAYES'
	when htlpostalcode in ('TW6 2AQ','TW6 3AF')AND htlcityname <> 'Hounslow' then upper('Hounslow')
	ELSE htlcityname
	END
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.HtlCountryCode = 'GB'

----  END Updates based on Zip Codes -----------

--------------------------------

---- BEGIN Misc Updaes for Hotels

SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = 'AR'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlstate IS NULL
	AND StagHTL.htladdr2 = 'ARKANSAS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ARKANSAS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = 'CA'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlstate <> 'CA'
	AND StagHTL.htladdr2 = 'CALIFORNIA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CALIFORNIA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = 'GA'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlstate <> 'GA'
	AND StagHTL.htladdr2 = 'GEORGIA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='GEORGIA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = 'MA'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlstate <> 'MA'
	AND StagHTL.htladdr2 = 'MASSACHUSETTS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='MASSACHUSETTS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = 'LA'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlstate <> 'LA'
	AND StagHTL.htladdr2 = 'LOUISIANA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='LOUISIANA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = 'AZ'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htlstate <> 'AZ'
	AND StagHTL.htladdr2 = 'ARIZONA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ARIZONA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = null
,HtlCountryCode = 'CA'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htladdr3 = 'CANADA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CANADA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = null,
htlcountrycode = 'GB'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htladdr3 = 'UNITED KINGDOM'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='UNITED KINGDOM',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = null,
htlcountrycode = 'KR'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htladdr3 = 'SOUTH KOREA'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='SOUTH KOREA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
UPDATE StagHTL
SET htlstate = null,
htlcountrycode = 'JP'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcountrycode = 'US'
	AND StagHTL.htladdr3 = 'JAPAN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='JAPAN',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



---------------------------------------
SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = 'NEW DELHI'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcityname = 'DELHI'
	AND StagHTL.HtlCountryCode = 'IN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='New Delhi',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = 'NEW YORK'
,htlstate = 'NY'
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
	AND StagHTL.MasterID IS NULL
	AND (StagHTL.htlcityname = 'NEW YORK NY' OR StagHTL.htlCityName = 'NEW YORK, NY')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='NEW YORK',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
UPDATE StagHTL
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.HtlCityName = 'WASHINGTON DC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Washington DC',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = 'HERTOGENBOSCH'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcityname not like '[a-z]%'
	AND StagHTL.htlpropertyname like '%MOEVENPICK HOTEL%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HERTOGENBOSCH- MOEVENPICK HOTEL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = 'NEW YORK'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcityname not like '[a-z]%'
	AND StagHTL.htlpropertyname like '%OAKWOOD CHELSEA%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='NEW YORK-OAKWOOD CHELSEA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = 'NEW YORK'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcityname not like '[a-z]%'
	AND StagHTL.htlpropertyname like '%LONGACRE HOUSE%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='NEW YORK -%LONGACRE HOUSE%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE StagHTL
SET htlcityname = 'BARCELONA'
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
	AND StagHTL.MasterID IS NULL
	AND StagHTL.htlcityname not like '[a-z]%'
	AND StagHTL.htlpropertyname like '%HOTLE PUNTA PALMA%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='BARCELONA- HOTLE PUNTA PALMA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End htl edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

---------------------------------------------------------------------------
----Delete from Productionm Tables, Leaving InvoiceHeader last due to joins
---------------------------------------------------------------------------

SET @TransStart = getdate()
DELETE ProdID
FROM @Prodserver.database.dba.InvoiceDetail ProdID
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH 
	ON (ProdIH.IataNum     = ProdID.IataNum
	AND ProdIH.ClientCode  = ProdID.ClientCode
	AND ProdIH.RecordKey   = ProdID.RecordKey
	AND ProdIH.InvoiceDate = ProdID.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdID.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
  
  
SET @TransStart = getdate()  
DELETE ProdTS
FROM @Prodserver.database.dba.TranSeg ProdTS
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdTS.IataNum
	AND ProdIH.ClientCode  = ProdTS.ClientCode
	AND ProdIH.RecordKey   = ProdTS.RecordKey
	AND ProdIH.InvoiceDate = ProdTS.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdTS.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdTS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
   

SET @TransStart = getdate()  
DELETE ProdCar
FROM @Prodserver.database.DBA.Car ProdCar
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdCar.IataNum
	AND ProdIH.ClientCode  = ProdCar.ClientCode
	AND ProdIH.RecordKey   = ProdCar.RecordKey
	AND ProdIH.InvoiceDate = ProdCar.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdCar.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdCar',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
     

SET @TransStart = getdate()  
DELETE ProdHtl
FROM @Prodserver.database.DBA.Hotel ProdHtl
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdHTL.IataNum
	AND ProdIH.ClientCode  = ProdHTL.ClientCode
	AND ProdIH.RecordKey   = ProdHTL.RecordKey
	AND ProdIH.InvoiceDate = ProdHTL.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdHTL.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdHtl',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
   

SET @TransStart = getdate()  
DELETE ProdUD
FROM @Prodserver.database.DBA.Udef ProdUD
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdUD.IataNum
	AND ProdIH.ClientCode  = ProdUD.ClientCode
	AND ProdIH.RecordKey   = ProdUD.RecordKey
	AND ProdIH.InvoiceDate = ProdUD.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdUD.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdUD',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
      

SET @TransStart = getdate()  
DELETE ProdPay
FROM @Prodserver.database.DBA.Payment ProdPay
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdPAY.IataNum
	AND ProdIH.ClientCode  = ProdPAY.ClientCode
	AND ProdIH.RecordKey   = ProdPAY.RecordKey
	AND ProdIH.InvoiceDate = ProdPAY.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdPAY.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdPay',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
      

SET @TransStart = getdate()  
DELETE ProdTax
FROM @Prodserver.database.DBA.Tax ProdTax
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdTax.IataNum
	AND ProdIH.ClientCode  = ProdTax.ClientCode
	AND ProdIH.RecordKey   = ProdTax.RecordKey
	AND ProdIH.InvoiceDate = ProdTax.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdTax.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdTax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
       

SET @TransStart = getdate()  
DELETE ProdCR
FROM @Prodserver.database.DBA.ComRmks ProdCR
INNER JOIN @Prodserver.database.DBA.InvoiceHeader ProdIH
	ON (ProdIH.IataNum     = ProdCR.IataNum
	AND ProdIH.ClientCode  = ProdCR.ClientCode
	AND ProdIH.RecordKey   = ProdCR.RecordKey
	AND ProdIH.InvoiceDate = ProdCR.InvoiceDate)
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
	AND ProdCR.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdCR',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
     

SET @TransStart = getdate()  
DELETE ProdIH
FROM @Prodserver.database.DBA.InvoiceHeader ProdIH
INNER JOIN @StagServer.database.DBA.InvoiceHeader StagIH
	ON (StagIH.IataNum    = ProdIH.IataNum
	AND StagIH.ClientCode = ProdIH.ClientCode
	AND StagIH.RecordKey  = ProdIH.RecordKey)
WHERE StagIH.IMPORTDT = @MaxImportDt
	AND StagIH.IataNum = @IataNum
	AND StagIH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND ProdIH.IataNum = @IataNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ProdIH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
    
-------------------------------------------------------
-----	Begin INSERT into Production  
-------------------------------------------------------

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.InvoiceHeader
(RecordKey
,IataNum
,ClientCode
,InvoiceDate
,InvoiceNum
,TicketingBranch
,BookingBranch
,TtlInvoiceAmt
,TtlTaxAmt
,TtlCommissionAmt
,CurrCode
,OrigCountry
,SalesAgentID
,FOP
,CCCode
,CCNum
,CCExp
,CCApprovalCode
,GDSCode
,BackOfficeID
,IMPORTDT
,TtlCO2Emissions
,CCFirstSix
,CCLastFour
,JobInstanceId
,IsItineraryProcessed)
SELECT
RecordKey
,IataNum
,ClientCode
,InvoiceDate
,InvoiceNum
,TicketingBranch
,BookingBranch
,TtlInvoiceAmt
,TtlTaxAmt
,TtlCommissionAmt
,CurrCode
,OrigCountry
,SalesAgentID
,FOP
,CCCode
,CCNum
,CCExp
,CCApprovalCode
,GDSCode
,BackOfficeID
,IMPORTDT
,TtlCO2Emissions
,CCFirstSix
,CCLastFour
,JobInstanceId
,IsItineraryProcessed
FROM dba.InvoiceHeader IH
WHERE IH.IMPORTDT = @MaxImportDt
	AND IH.IataNum = @IataNum
	AND IH.InvoiceDate between @FirstInvDate AND @LastInvDate
	AND IH.RecordKey+ IH.IataNum 
		NOT IN (SELECT ProdIH.RecordKey+ProdIH.IataNum
				FROM @Prodserver.database.DBA.InvoiceHeader ProdIH
				WHERE ProdIH.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdIH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							 

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.dba.InvoiceDetail
(RecordKey
,IataNum
,SeqNum
,ClientCode
,InvoiceDate
,IssueDate
,VoidInd
,VoidReasonType
,Salutation
,FirstName
,Lastname
,MiddleInitial
,InvoiceType
,InvoiceTypeDescription
,DocumentNumber
,EndDocNumber
,VendorNumber
,VendorType
,ValCarrierNum
,ValCarrierCode
,VendorName
,BookingDate
,ServiceDate
,ServiceCategory
,InternationalInd
,ServiceFee
,InvoiceAmt
,TaxAmt
,TotalAmt
,CommissionAmt
,CancelPenaltyAmt
,CurrCode
,FareCompare1
,ReasonCode1
,FareCompare2
,ReasonCode2
,FareCompare3
,ReasonCode3
,FareCompare4
,ReasonCode4
,Mileage
,Routing
,DaysAdvPurch
,AdvPurchGroup
,TrueTktCount
,TripLength
,ExchangeInd
,OrigExchTktNum
,Department
,ETktInd
,ProductType
,TourCode
,EndorsementRemarks
,FareCalcLine
,GroupMult
,OneWayInd
,PrefTktInd
,HotelNights
,CarDays
,OnlineBookingSystem
,AccommodationType
,AccommodationDescription
,ServiceType
,ServiceDescription
,ShipHotelName
,Remarks1
,Remarks2
,Remarks3
,Remarks4
,Remarks5
,IntlSalesInd
,MatchedInd
,MatchedFields
,RefundInd
,OriginalInvoiceNum
,BranchIataNum
,GDSRecordLocator
,BookingAgentID
,TicketingAgentID
,OriginCode
,DestinationCode
,TktCO2Emissions
,CCMatchedRecordKey
,CCMatchedIataNum
,ACQMatchedInd
,ACQMatchedRecordKey
,ACQMatchedIataNum
,CarrierString
,ClassString
,CRMatchedInd
,CRMatchedRecordKey
,CRMatchedIataNum
,LastImportDt
,GolUpdateDt
,OrigTktAmt
,TktWasExchangedInd
,TicketGroupId
,OrigBaseFare
,TktOrder
,OrigFareCompare1
,OrigFareCompare2
)
SELECT
 ID.RecordKey
,ID.IataNum
,ID.SeqNum
,ID.ClientCode
,ID.InvoiceDate
,ID.IssueDate
,ID.VoidInd
,ID.VoidReasonType
,ID.Salutation
,ID.FirstName
,ID.Lastname
,ID.MiddleInitial
,ID.InvoiceType
,ID.InvoiceTypeDescription
,ID.DocumentNumber
,ID.EndDocNumber
,ID.VendorNumber
,ID.VendorType
,ID.ValCarrierNum
,ID.ValCarrierCode
,ID.VendorName
,ID.BookingDate
,ID.ServiceDate
,ID.ServiceCategory
,ID.InternationalInd
,ID.ServiceFee
,ID.InvoiceAmt
,ID.TaxAmt
,ID.TotalAmt
,ID.CommissionAmt
,ID.CancelPenaltyAmt
,ID.CurrCode
,ID.FareCompare1
,ID.ReasonCode1
,ID.FareCompare2
,ID.ReasonCode2
,ID.FareCompare3
,ID.ReasonCode3
,ID.FareCompare4
,ID.ReasonCode4
,ID.Mileage
,ID.Routing
,ID.DaysAdvPurch
,ID.AdvPurchGroup
,ID.TrueTktCount
,ID.TripLength
,ID.ExchangeInd
,ID.OrigExchTktNum
,ID.Department
,ID.ETktInd
,ID.ProductType
,ID.TourCode
,ID.EndorsementRemarks
,ID.FareCalcLine
,ID.GroupMult
,ID.OneWayInd
,ID.PrefTktInd
,ID.HotelNights
,ID.CarDays
,ID.OnlineBookingSystem
,ID.AccommodationType
,ID.AccommodationDescription
,ID.ServiceType
,ID.ServiceDescription
,ID.ShipHotelName
,ID.Remarks1
,ID.Remarks2
,ID.Remarks3
,ID.Remarks4
,ID.Remarks5
,ID.IntlSalesInd
,ID.MatchedInd
,ID.MatchedFields
,ID.RefundInd
,ID.OriginalInvoiceNum
,ID.BranchIataNum
,ID.GDSRecordLocator
,ID.BookingAgentID
,ID.TicketingAgentID
,ID.OriginCode
,ID.DestinationCode
,ID.TktCO2Emissions
,ID.CCMatchedRecordKey
,ID.CCMatchedIataNum
,ID.ACQMatchedInd
,ID.ACQMatchedRecordKey
,ID.ACQMatchedIataNum
,ID.CarrierString
,ID.ClassString
,ID.CRMatchedInd
,ID.CRMatchedRecordKey
,ID.CRMatchedIataNum
,ID.LastImportDt
,ID.GolUpdateDt
,ID.OrigTktAmt
,ID.TktWasExchangedInd
,ID.TicketGroupId
,ID.OrigBaseFare
,ID.TktOrder
,ID.OrigFareCompare1
,ID.OrigFareCompare2
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
	AND ID.RecordKey+ID.IataNum+CONVERT(VARCHAR,ID.SeqNum) 
		NOT IN (SELECT ProdID.RecordKey+ProdID.IataNum+CONVERT(VARCHAR,ProdID.SeqNum) 
				FROM @Prodserver.database.dba.InvoiceDetail ProdID
				WHERE ProdID.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.dba.TranSeg
(RecordKey
,IataNum
,SeqNum
,SegmentNum
,TypeCode
,ClientCode
,InvoiceDate
,IssueDate
,OriginCityCode
,SegmentCarrierCode
,SegmentCarrierName
,CodeShareCarrierCode
,EquipmentCode
,PrefAirInd
,DepartureDate
,DepartureTime
,FlightNum
,ClassOfService
,FareBasis
,TktDesignator
,ConnectionInd
,StopOverTime
,FrequentFlyerNum
,FrequentFlyerMileage
,CurrCode
,SEGDestCityCode
,SEGInternationalInd
,SEGArrivalDate
,SEGArrivalTime
,SEGSegmentValue
,SEGSegmentMileage
,SEGTotalMileage
,SEGFlightTime
,SEGMktOrigCityCode
,SEGMktDestCityCode
,SEGReturnInd
,NOXDestCityCode
,NOXInternationalInd
,NOXArrivalDate
,NOXArrivalTime
,NOXSegmentValue
,NOXSegmentMileage
,NOXTotalMileage
,NOXFlightTime
,NOXMktOrigCityCode
,NOXMktDestCityCode
,NOXConnectionString
,NOXReturnInd
,MINDestCityCode
,MINInternationalInd
,MINArrivalDate
,MINArrivalTime
,MINSegmentValue
,MINSegmentMileage
,MINTotalMileage
,MINFlightTime
,MINMktOrigCityCode
,MINMktDestCityCode
,MINConnectionString
,MINReturnInd
,MealName
,NOXSegmentCarrierCode
,NOXSegmentCarrierName
,NOXClassOfService
,MINSegmentCarrierCode
,MINSegmentCarrierName
,MINClassOfService
,NOXClassString
,NOXFareBasisString
,MINClassString
,MINFareBasisString
,NOXFlownMileage
,MINFlownMileage
,SEGCO2Emissions
,NOXCO2Emissions
,MINCO2Emissions
,FSeats
,BusSeats
,EconSeats
,TtlSeats
,SegTrueTktCount
,YieldInd
,YieldAmt
,YieldDatePosted
)
SELECT
 TS.RecordKey
,TS.IataNum
,TS.SeqNum
,TS.SegmentNum
,TS.TypeCode
,TS.ClientCode
,TS.InvoiceDate
,TS.IssueDate
,TS.OriginCityCode
,TS.SegmentCarrierCode
,TS.SegmentCarrierName
,TS.CodeShareCarrierCode
,TS.EquipmentCode
,TS.PrefAirInd
,TS.DepartureDate
,TS.DepartureTime
,TS.FlightNum
,TS.ClassOfService
,TS.FareBasis
,TS.TktDesignator
,TS.ConnectionInd
,TS.StopOverTime
,TS.FrequentFlyerNum
,TS.FrequentFlyerMileage
,TS.CurrCode
,TS.SEGDestCityCode
,TS.SEGInternationalInd
,TS.SEGArrivalDate
,TS.SEGArrivalTime
,TS.SEGSegmentValue
,TS.SEGSegmentMileage
,TS.SEGTotalMileage
,TS.SEGFlightTime
,TS.SEGMktOrigCityCode
,TS.SEGMktDestCityCode
,TS.SEGReturnInd
,TS.NOXDestCityCode
,TS.NOXInternationalInd
,TS.NOXArrivalDate
,TS.NOXArrivalTime
,TS.NOXSegmentValue
,TS.NOXSegmentMileage
,TS.NOXTotalMileage
,TS.NOXFlightTime
,TS.NOXMktOrigCityCode
,TS.NOXMktDestCityCode
,TS.NOXConnectionString
,TS.NOXReturnInd
,TS.MINDestCityCode
,TS.MINInternationalInd
,TS.MINArrivalDate
,TS.MINArrivalTime
,TS.MINSegmentValue
,TS.MINSegmentMileage
,TS.MINTotalMileage
,TS.MINFlightTime
,TS.MINMktOrigCityCode
,TS.MINMktDestCityCode
,TS.MINConnectionString
,TS.MINReturnInd
,TS.MealName
,TS.NOXSegmentCarrierCode
,TS.NOXSegmentCarrierName
,TS.NOXClassOfService
,TS.MINSegmentCarrierCode
,TS.MINSegmentCarrierName
,TS.MINClassOfService
,TS.NOXClassString
,TS.NOXFareBasisString
,TS.MINClassString
,TS.MINFareBasisString
,TS.NOXFlownMileage
,TS.MINFlownMileage
,TS.SEGCO2Emissions
,TS.NOXCO2Emissions
,TS.MINCO2Emissions
,TS.FSeats
,TS.BusSeats
,TS.EconSeats
,TS.TtlSeats
,TS.SegTrueTktCount
,TS.YieldInd
,TS.YieldAmt
,TS.YieldDatePosted 
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
	AND TS.RecordKey+TS.IataNum+CONVERT(VARCHAR,TS.SeqNum)
		NOT IN (SELECT ProdTS.RecordKey+ProdTS.IataNum+CONVERT(VARCHAR,ProdTS.SeqNum) 
				FROM @Prodserver.database.dba.TranSeg ProdTS
				WHERE ProdTS.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdTS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.Car
(RecordKey
,IataNum
,SeqNum
,CarSegNum
,ClientCode
,InvoiceDate
,IssueDate
,VoidInd
,VoidReasonType
,Salutation
,FirstName
,Lastname
,MiddleInitial
,CarType
,CarChainCode
,CarChainName
,CarCityCode
,CarCityName
,InternationalInd
,PickupDate
,DropoffDate
,CarDropoffCityCode
,NumDays
,NumCars
,CarQuotedRate
,QuotedCurrCode
,CarDailyRate
,TtlCarCost
,CarRateCat
,CarCompareRate1
,CarReasonCode1
,CarCompareRate2
,CarReasonCode2
,CarCommAmt
,CurrCode
,PrefCarInd
,CarConfNum
,FreqRenterProgram
,CarStatus
,Remarks1
,Remarks2
,Remarks3
,Remarks4
,Remarks5
,CommTrackInd
,CarCommPostDate
,MatchedInd
,MatchedFields
,GDSRecordLocator
,BookingAgentID
,CarDropOffCityName
,CO2Emissions
)
SELECT
 CAR.RecordKey
,CAR.IataNum
,CAR.SeqNum
,CAR.CarSegNum
,CAR.ClientCode
,CAR.InvoiceDate
,CAR.IssueDate
,CAR.VoidInd
,CAR.VoidReasonType
,CAR.Salutation
,CAR.FirstName
,CAR.Lastname
,CAR.MiddleInitial
,CAR.CarType
,CAR.CarChainCode
,CAR.CarChainName
,CAR.CarCityCode
,CAR.CarCityName
,CAR.InternationalInd
,CAR.PickupDate
,CAR.DropoffDate
,CAR.CarDropoffCityCode
,CAR.NumDays
,CAR.NumCars
,CAR.CarQuotedRate
,CAR.QuotedCurrCode
,CAR.CarDailyRate
,CAR.TtlCarCost
,CAR.CarRateCat
,CAR.CarCompareRate1
,CAR.CarReasonCode1
,CAR.CarCompareRate2
,CAR.CarReasonCode2
,CAR.CarCommAmt
,CAR.CurrCode
,CAR.PrefCarInd
,CAR.CarConfNum
,CAR.FreqRenterProgram
,CAR.CarStatus
,CAR.Remarks1
,CAR.Remarks2
,CAR.Remarks3
,CAR.Remarks4
,CAR.Remarks5
,CAR.CommTrackInd
,CAR.CarCommPostDate
,CAR.MatchedInd
,CAR.MatchedFields
,CAR.GDSRecordLocator
,CAR.BookingAgentID
,CAR.CarDropOffCityName
,CAR.CO2Emissions
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
	AND Car.RecordKey+Car.IataNum+CONVERT(VARCHAR,Car.SeqNum) 
		NOT IN (SELECT ProdCar.RecordKey+ProdCar.IataNum+CONVERT(VARCHAR,ProdCar.SeqNum) 
				FROM @Prodserver.database.DBA.Car ProdCar
				WHERE ProdCar.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdCar',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.Hotel
(RecordKey
,IataNum
,SeqNum
,HtlSegNum
,ClientCode
,InvoiceDate
,IssueDate
,VoidInd
,VoidReasonType
,Salutation
,FirstName
,Lastname
,MiddleInitial
,HtlChainCode
,HtlChainName
,GDSPropertyNum
,HtlPropertyName
,HtlAddr1
,HtlAddr2
,HtlAddr3
,HtlCityCode
,HtlCityName
,HtlState
,HtlPostalCode
,HtlCountryCode
,HtlPhone
,InternationalInd
,CheckinDate
,CheckoutDate
,NumNights
,NumRooms
,HtlQuotedRate
,QuotedCurrCode
,HtlDailyRate
,TtlHtlCost
,RoomType
,HtlRateCat
,HtlCompareRate1
,HtlReasonCode1
,HtlCompareRate2
,HtlReasonCode2
,HtlCommAmt
,CurrCode
,PrefHtlInd
,HtlConfNum
,FreqGuestProgram
,HtlStatus
,Remarks1
,Remarks2
,Remarks3
,Remarks4
,Remarks5
,CommTrackInd
,HtlCommPostDate
,MatchedInd
,MatchedFields
,GDSRecordLocator
,BookingAgentID
,MasterId
,CO2Emissions
,MilesFromAirport
,GroundTransCO2
)
SELECT
 HTL.RecordKey
,HTL.IataNum
,HTL.SeqNum
,HTL.HtlSegNum
,HTL.ClientCode
,HTL.InvoiceDate
,HTL.IssueDate
,HTL.VoidInd
,HTL.VoidReasonType
,HTL.Salutation
,HTL.FirstName
,HTL.Lastname
,HTL.MiddleInitial
,HTL.HtlChainCode
,HTL.HtlChainName
,HTL.GDSPropertyNum
,HTL.HtlPropertyName
,HTL.HtlAddr1
,HTL.HtlAddr2
,HTL.HtlAddr3
,HTL.HtlCityCode
,HTL.HtlCityName
,HTL.HtlState
,HTL.HtlPostalCode
,HTL.HtlCountryCode
,HTL.HtlPhone
,HTL.InternationalInd
,HTL.CheckinDate
,HTL.CheckoutDate
,HTL.NumNights
,HTL.NumRooms
,HTL.HtlQuotedRate
,HTL.QuotedCurrCode
,HTL.HtlDailyRate
,HTL.TtlHtlCost
,HTL.RoomType
,HTL.HtlRateCat
,HTL.HtlCompareRate1
,HTL.HtlReasonCode1
,HTL.HtlCompareRate2
,HTL.HtlReasonCode2
,HTL.HtlCommAmt
,HTL.CurrCode
,HTL.PrefHtlInd
,HTL.HtlConfNum
,HTL.FreqGuestProgram
,HTL.HtlStatus
,HTL.Remarks1
,HTL.Remarks2
,HTL.Remarks3
,HTL.Remarks4
,HTL.Remarks5
,HTL.CommTrackInd
,HTL.HtlCommPostDate
,HTL.MatchedInd
,HTL.MatchedFields
,HTL.GDSRecordLocator
,HTL.BookingAgentID
,HTL.MasterId
,HTL.CO2Emissions
,HTL.MilesFromAirport
,HTL.GroundTransCO2
FROM dba.Hotel HTL
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
				FROM @Prodserver.database.DBA.Hotel ProdHtl
				WHERE ProdHTL.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdHtl',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.Udef
(RecordKey
,IataNum
,SeqNum
,ClientCode
,InvoiceDate
,IssueDate
,UdefNum
,UdefType
,UdefData
)
SELECT
 UD.RecordKey
,UD.IataNum
,UD.SeqNum
,UD.ClientCode
,UD.InvoiceDate
,UD.IssueDate
,UD.UdefNum
,UD.UdefType
,UD.UdefData
FROM dba.Udef UD
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
				FROM @Prodserver.database.DBA.Udef ProdUD
				WHERE ProdUD.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdUdef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.Payment
(RecordKey
,IataNum
,SeqNum
,PaymentSeqNum
,ClientCode
,InvoiceDate
,IssueDate
,FOP
,CCCode
,CCNum
,CCExp
,CCApprovalCode
,CurrCode
,PaymentAmt
,CCFirstSix
,CCLastFour
)
SELECT
 Pay.RecordKey
,PAY.IataNum
,PAY.SeqNum
,PAY.PaymentSeqNum
,PAY.ClientCode
,PAY.InvoiceDate
,PAY.IssueDate
,PAY.FOP
,PAY.CCCode
,PAY.CCNum
,PAY.CCExp
,PAY.CCApprovalCode
,PAY.CurrCode
,PAY.PaymentAmt
,PAY.CCFirstSix
,PAY.CCLastFour
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
	AND PAY.RecordKey+PAY.IataNum+CONVERT(VARCHAR,PAY.SeqNum)
		NOT IN (SELECT ProdPAY.RecordKey+ProdPAY.IataNum+CONVERT(VARCHAR,ProdPAY.SeqNum) 
				FROM @Prodserver.database.DBA.Payment ProdPAY
				WHERE ProdPAY.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdPay',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.Tax
(RecordKey
,IataNum
,SeqNum
,TaxSeqNum
,ClientCode
,InvoiceDate
,IssueDate
,TaxId
,TaxAmt
,CurrCode
,TaxRate
)
SELECT
 TAX.RecordKey
,TAX.IataNum
,TAX.SeqNum
,TAX.TaxSeqNum
,TAX.ClientCode
,TAX.InvoiceDate
,TAX.IssueDate
,TAX.TaxId
,TAX.TaxAmt
,TAX.CurrCode
,TAX.TaxRate
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
	AND TAX.RecordKey+TAX.IataNum+CONVERT(VARCHAR,TAX.SeqNum)
	NOT IN (SELECT ProdTAX.RecordKey+ProdTAX.IataNum+CONVERT(VARCHAR,ProdTAX.SeqNum) 
	FROM @Prodserver.database.DBA.TAX ProdTAX
	WHERE ProdTAX.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdTax',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.ComRmks
(RecordKey
,IataNum
,SeqNum
,ClientCode
,InvoiceDate
,IssueDate
,Text1
,Text2
,Text3
,Text4
,Text5
,Text6
,Text7
,Text8
,Text9
,Text10
,Text11
,Text12
,Text13
,Text14
,Text15
,Text16
,Text17
,Text18
,Text19
,Text20
,Text21
,Text22
,Text23
,Text24
,Text25
,Text26
,Text27
,Text28
,Text29
,Text30
,Text31
,Text32
,Text33
,Text34
,Text35
,Text36
,Text37
,Text38
,Text39
,Text40
,Text41
,Text42
,Text43
,Text44
,Text45
,Text46
,Text47
,Text48
,Text49
,Text50
,Num1
,Num2
,Num3
,Num4
,Num5
,Num6
,Num7
,Num8
,Num9
,Num10
,Num11
,Num12
,Num13
,Num14
,Num15
,Num16
,Num17
,Num18
,Num19
,Num20
,Num21
,Num22
,Num23
,Num24
,Num25
,Num26
,Num27
,Num28
,Num29
,Num30
,Int1
,Int2
,Int3
,Int4
,Int5
,Int6
,Int7
,Int8
,Int9
,Int10
,Int11
,Int12
,Int13
,Int14
,Int15
,Int16
,Int17
,Int18
,Int19
,Int20
)
SELECT
 CR.RecordKey
,CR.IataNum
,CR.SeqNum
,CR.ClientCode
,CR.InvoiceDate
,CR.IssueDate
,CR.Text1
,CR.Text2
,CR.Text3
,CR.Text4
,CR.Text5
,CR.Text6
,CR.Text7
,CR.Text8
,CR.Text9
,CR.Text10
,CR.Text11
,CR.Text12
,CR.Text13
,CR.Text14
,CR.Text15
,CR.Text16
,CR.Text17
,CR.Text18
,CR.Text19
,CR.Text20
,CR.Text21
,CR.Text22
,CR.Text23
,CR.Text24
,CR.Text25
,CR.Text26
,CR.Text27
,CR.Text28
,CR.Text29
,CR.Text30
,CR.Text31
,CR.Text32
,CR.Text33
,CR.Text34
,CR.Text35
,CR.Text36
,CR.Text37
,CR.Text38
,CR.Text39
,CR.Text40
,CR.Text41
,CR.Text42
,CR.Text43
,CR.Text44
,CR.Text45
,CR.Text46
,CR.Text47
,CR.Text48
,CR.Text49
,CR.Text50
,CR.Num1
,CR.Num2
,CR.Num3
,CR.Num4
,CR.Num5
,CR.Num6
,CR.Num7
,CR.Num8
,CR.Num9
,CR.Num10
,CR.Num11
,CR.Num12
,CR.Num13
,CR.Num14
,CR.Num15
,CR.Num16
,CR.Num17
,CR.Num18
,CR.Num19
,CR.Num20
,CR.Num21
,CR.Num22
,CR.Num23
,CR.Num24
,CR.Num25
,CR.Num26
,CR.Num27
,CR.Num28
,CR.Num29
,CR.Num30
,CR.Int1
,CR.Int2
,CR.Int3
,CR.Int4
,CR.Int5
,CR.Int6
,CR.Int7
,CR.Int8
,CR.Int9
,CR.Int10
,CR.Int11
,CR.Int12
,CR.Int13
,CR.Int14
,CR.Int15
,CR.Int16
,CR.Int17
,CR.Int18
,CR.Int19
,CR.Int20
FROM dba.ComRmks CR
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
				FROM @Prodserver.database.DBA.ComRmks ProdCR
				WHERE ProdCR.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT ProdCR',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
INSERT INTO @Prodserver.database.DBA.client
(ClientCode
,IataNum
,CustName
,CustAddr1
,CustAddr2
,CustAddr3
,City
,STATE
,Zip
,CustPhone
,CountryCode
,AttnLine
,Email
,ConsolidationCode
,ClientRemark1
,ClientRemark2
,ClientRemark3
,ClientRemark4
,ClientRemark5
,ClientRemark6
,ClientRemark7
,ClientRemark8
,ClientRemark9
,ClientRemark10
)
SELECT 
 CL.ClientCode
,CL.IataNum
,CL.CustName
,CL.CustAddr1
,CL.CustAddr2
,CL.CustAddr3
,CL.City
,CL.STATE
,CL.Zip
,CL.CustPhone
,CL.CountryCode
,CL.AttnLine
,CL.Email
,CL.ConsolidationCode
,CL.ClientRemark1
,CL.ClientRemark2
,CL.ClientRemark3
,CL.ClientRemark4
,CL.ClientRemark5
,CL.ClientRemark6
,CL.ClientRemark7
,CL.ClientRemark8
,CL.ClientRemark9
,CL.ClientRemark10
FROM DBA.client CL
WHERE CL.IataNum = @IataNum
	AND CL.clientcode 
		NOT IN (SELECT ProdCL.clientcode
				FROM @Prodserver.database.DBA.client ProdCL 
				WHERE ProdCL.IataNum = @IataNum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT into Prod Client',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End of INSERT Production',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------ End of INSERT into Production --------------


------ Begin Hotel Edits for HNN ---------------

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin DEA Query Dates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



------------------------------------------
--Data Enhancement Automation HNN Queries
------------------------------------------
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

SELECT @HNNBeginDate = Min(IssueDate),@HNNEndDate = Max(IssueDate)
FROM @Prodserver.database.dba.Hotel ProdHTL
WHERE ProdHTL.MasterId is NULL
AND ProdHTL.IataNum =  @IataNum
AND ProdHTL.IssueDate >'2013-12-31'


EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = '@iatanum',
@Enhancement = 'HNN',
@Client = '@client',
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
@TextParam2 = '@prodserver',
@TextParam3 = '@database',
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
@CommANDLineArgs = NULL

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='END sending to DEA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End SP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
							   

