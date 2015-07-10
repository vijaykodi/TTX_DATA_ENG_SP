/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_REPORTS_ACM']/UnresolvedEntity[@Name='DRA' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_REPORTS_ACM']/UnresolvedEntity[@Name='ACMDatabases' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/10/2015 10:05:25 AM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_Process_ACM_On_Import_On_Staging]    Script Date: 7/10/2015 10:05:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- ====================================================================================================
-- Author:		  Charlie Bradsher
-- Create date:	  2013-09-27
-- Description:	  WHEN TO RUN THIS PROCEDURE:
--			  ********  RUN THIS ON THE PRODUCTION DATABASE 
--                     for data Not loaded on staging (e.g. CWT data)
--
--			  If data is loaded to staging then:
--			  ********  RUN THE ACMPROCESSING PROCEDURE ON STAGING 
--
--			  ARGUMENTS:
--			  @ImportDate  - If not passed then uses the last ImportDt value from InvoiceHeader
--
--			  WHAT IT DOES:
--			   Copies InvoiceHeader/InvoiceDetail/Transeg data to staging for @ImportDate argument
--			   and Executes the stored procedure on customer's staging server to process ACM   
--			  1.  Set arguments and variables
--			  2.  Delete ACM data on Production for re-processing  
--			  3.  Set Operating Carrier and Fare Basis
--			  4.  Delete redundant data on staging
--			  5.  Move data to staging (from prod for @ImportDt)
-- ====================================================================================================

CREATE PROCEDURE [dbo].[sp_Process_ACM_On_Import_On_Staging]
@ImportDate datetime
	
AS
BEGIN
/************************************************************************
  1  Set arguments and variables
*************************************************************************/
   
--    DECLARE @ImportDate datetime
    DECLARE @CustomerID varchar(30)
    DECLARE @Prod_Server varchar(50)
    DECLARE @Prod_Database varchar(50)
    DECLARE @Stage_Server varchar(50)
    DECLARE @Stage_Database varchar(50)
  
    DECLARE @SQL_DEL_INVOICEHEADER_STAGE nvarchar(2000)
    DECLARE @SQL_DEL_INVOICEDETAIL_STAGE nvarchar(2000)
    DECLARE @SQL_DEL_TRANSEG_STAGE nvarchar(2000)
    DECLARE @SQL_MOVE_INVOICEHEADER  nvarchar(2000)
    DECLARE @SQL_MOVE_INVOICEDETAIL  nvarchar(3000)
    DECLARE @SQL_MOVE_TRANSEG nvarchar(4000)
    DECLARE @SQL_PROCESS_ON_STAGING nvarchar(2000)
    DECLARE  @ProcName varchar(50), @TransStart datetime
    If @ImportDate is null
    Begin
	 Set @ImportDate = (select max(ImportDt)from DBA.InvoiceHeader where iatanum not like 'PRE%')
    End
    	 
    Set @CustomerID = (Select min(DRA.CustomerID)from dba.InvoiceHeader IH, ttxpaSQL09.TMAN503_REPORTS_ACM.dba.DRA DRA where IataNum = ETLRequestName and IH.ImportDt = @ImportDate)
    Set @Prod_Server = (Select ServerName from ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases where CustomerID = @CustomerID and DatabaseCategory = 'PROD')
    Set @Prod_Database = (Select DatabaseName from ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases where CustomerID = @CustomerID and DatabaseCategory = 'PROD')
    Set @Stage_Server = (Select ServerName from ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases where CustomerID = @CustomerID and DatabaseCategory = 'Stage')
    Set @Stage_Database = (Select DatabaseName from ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases where CustomerID = @CustomerID and DatabaseCategory = 'Stage')
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @TransStart = getdate()
	

 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
 

/************************************************************************
    2.  Delete ACM data on Production for re-processing
*************************************************************************/
               
--  Delete ACM data on Production for re-processing  (ContractRmks and ACMInfo only)

    Delete ACRmks
    from dba.ContractRmks ACRmks, dba.InvoiceHeader IH
    where ACRmks.Recordkey = IH.RecordKey
    and ACRmks.IataNum = IH.IataNum
    and IH.ImportDT = @ImportDate

    Delete ACMI
    from dba.ACMInfo ACMI, dba.InvoiceHeader IH
    where ACMI.Recordkey = IH.RecordKey
    and ACMI.IataNum = IH.IataNum
    and IH.ImportDT = @ImportDate
    
--  Delete orphaned records  (ContractRmks and ACMInfo only)  
  
    Delete dba.ACMInfo 
    where Recordkey in (select ACMI.RecordKey
		from dba.ACMInfo ACMI
		left outer join dba.Transeg TS on (TS.RecordKey = ACMI.RecordKey and Ts.IataNum = ACMI.IataNum and TS.SeqNum = ACMI.SeqNum and TS.SegmentNum = ACMI.SegmentNum)
		group by TS.RecordKey, ACMI.RecordKey
		having TS.RecordKey is null)
		
    Delete dba.ContractRmks 
    where Recordkey in (select ACRmks.RecordKey
		from dba.ContractRmks ACRmks
		left outer join dba.Transeg TS on (TS.RecordKey = ACRmks.RecordKey and TS.IataNum = ACRmks.IataNum and TS.SeqNum = ACRmks.SeqNum and TS.SegmentNum = ACRmks.SegmentNum)
		group by TS.RecordKey, ACRmks.RecordKey
		having TS.RecordKey is null)				
 
/************************************************************************
    3.  Set Operating Carrier and Fare Basis
*************************************************************************/

    update TS
    set TS.CodeshareCarrierCode = XR.OpCarrier
    from dba.TranSeg TS, dba.OpCarXref XR, dba.InvoiceHeader IH
    where IH.RecordKey = TS.RecordKey
    and IH.IataNum = TS.IataNum
    and IH.ImportDt = @ImportDate
    and TS.SegmentCarrierCode = XR.Carrier
    and TS.FlightNum = XR.FlightNum
    and TS.DepartureDate between  XR.BeginService and XR.EndService
    and TS.CodeshareCarrierCode is null

    Update TS
    Set CodeshareCarrierCode = SegmentCarrierCode
    from dba.TranSeg TS,dba.InvoiceHeader IH
    where IH.RecordKey = TS.RecordKey
    and IH.IataNum = TS.IataNum
    and IH.ImportDt = @ImportDate
    and CodeshareCarrierCode is null

    Update TS
    Set FareBasis = left(ClassOfService,1)
    from dba.Transeg TS, dba.InvoiceHeader IH
    where IH.RecordKey = TS.RecordKey
    and IH.IataNum = TS.IataNum
    and IH.ImportDt = @ImportDate
    and FareBasis is null
  
    
/************************************************************************
    4.  Delete redundant InvoiceHeader data on staging and move from Prod
*************************************************************************/

-- Delete Redundant InvoiceHeader data on Staging

    Set @SQL_DEL_INVOICEHEADER_STAGE =  'Delete Stage
    from dba.InvoiceHeader IH, '+@Stage_Server+'.'+@Stage_Database+'.'+'dba.InvoiceHeader Stage
    where IH.RecordKey = Stage.RecordKey
    and IH.IataNum = Stage.IataNum
    and IH.ImportDt = '''+rtrim(convert(char,@Importdate,120))+''''

    EXEC sp_executesql @SQL_DEL_INVOICEHEADER_STAGE
    
    Set @SQL_MOVE_INVOICEHEADER = 
    'Insert into '+@Stage_Server+'.'+@Stage_Database+'.'+'dba.InvoiceHeader(
	   [RecordKey]
	  ,[IataNum]
	  ,[ClientCode]
	  ,[InvoiceDate]
	  ,[InvoiceNum]
	  ,[TicketingBranch]
	  ,[BookingBranch]
	  ,[TtlInvoiceAmt]
	  ,[TtlTaxAmt]
	  ,[TtlCommissionAmt]
	  ,[CurrCode]
	  ,[OrigCountry]
	  ,[SalesAgentID]
	  ,[FOP]
	  ,[CCCode]
	  ,[CCNum]
	  ,[CCExp]
	  ,[CCApprovalCode]
	  ,[GDSCode]
	  ,[BackOfficeID]
	  ,[IMPORTDT])
    SELECT Distinct 
	   IH.[RecordKey]
	  ,IH.[IataNum]
	  ,IH.[ClientCode]
	  ,IH.[InvoiceDate]
	  ,IH.[InvoiceNum]
	  ,IH.[TicketingBranch]
	  ,IH.[BookingBranch]
	  ,IH.[TtlInvoiceAmt]
	  ,IH.[TtlTaxAmt]
	  ,IH.[TtlCommissionAmt]
	  ,IH.[CurrCode]
	  ,IH.[OrigCountry]
	  ,IH.[SalesAgentID]
	  ,IH.[FOP]
	  ,IH.[CCCode]
	  ,IH.[CCNum]
	  ,IH.[CCExp]
	  ,IH.[CCApprovalCode]
	  ,IH.[GDSCode]
	  ,IH.[BackOfficeID]
	  ,IH.[IMPORTDT]
    from dba.InvoiceHeader IH, dba.InvoiceDetail ID, dba.Transeg TS
    where IH.RecordKey = ID.RecordKey
    and IH.IataNum = ID.IataNum
    and IH.RecordKey = TS.RecordKey
    and IH.IataNum = TS.IataNum
    and ID.RecordKey = TS.RecordKey
    and ID.IataNum = TS.IataNum
    and ID.SeqNum = TS.SeqNum
    and IH.IataNum NOT LIKE ''PRE%''
    and (ID.Vendortype in (''BSP'',''NONBSP'', ''BSPSTP'', ''RAIL'')
	  or ID.Vendortype =''NONAIR'' and Producttype in (''RAIL'',''AIR''))
    and ID.VoidInd = ''N''
    and TS.MinDestCityCode is not null
    and IH.ImportDt = '''+rtrim(convert(char,@Importdate,120))+''''
    
    EXEC sp_executesql @SQL_MOVE_INVOICEHEADER

/******************************************************************************
    5.  Delete redundant InvoiceDetail/Trans data on staging and move from Prod
*******************************************************************************/   
--  Delete Redundant InvoiceDetail and TranSeg data on staging    

    Set @SQL_DEL_INVOICEDETAIL_STAGE =  'Delete Stage
    from '+@Stage_Server+'.'+@Stage_Database+'.'+' dba.InvoiceHeader IH, '+@Stage_Server+'.'+@Stage_Database+'.'+'dba.InvoiceDetail Stage
    where IH.RecordKey = Stage.RecordKey
    and IH.IataNum = Stage.IataNum
    and IH.ImportDt = '''+rtrim(convert(char,@Importdate,120))+''''
    
    Set @SQL_DEL_TRANSEG_STAGE =  'Delete Stage
    from '+@Stage_Server+'.'+@Stage_Database+'.'+'dba.InvoiceHeader IH, '+@Stage_Server+'.'+@Stage_Database+'.'+'dba.TranSeg Stage
    where IH.RecordKey = Stage.RecordKey
    and IH.IataNum = Stage.IataNum
    and IH.ImportDt = '''+rtrim(convert(char,@Importdate,120))+''''
    
    EXEC sp_executesql @SQL_DEL_INVOICEDETAIL_STAGE
    EXEC sp_executesql @SQL_DEL_TRANSEG_STAGE        

-- Move InvoiceDetail 

    Set @SQL_MOVE_INVOICEDETAIL = 
    'INSERT INTO '+@Stage_Server+'.'+@Stage_Database+'.[dba].[InvoiceDetail]
	  ([RecordKey]
	  ,[IataNum]
	  ,[SeqNum]
	  ,[ClientCode]
	  ,[InvoiceDate]
	  ,[IssueDate]
	  ,[VoidInd]
	  ,[DocumentNumber]
	  ,[EndDocNumber]
	  ,[VendorNumber]
	  ,[VendorType]
	  ,[ValCarrierNum]
	  ,[ValCarrierCode]
	  ,[VendorName]
	  ,[BookingDate]
	  ,[ServiceDate]
	  ,[ServiceCategory]
	  ,[InternationalInd]
	  ,[ServiceFee]
	  ,[InvoiceAmt]
	  ,[TaxAmt]
	  ,[TotalAmt]
	  ,[CommissionAmt]
	  ,[CancelPenaltyAmt]
	  ,[CurrCode]
	  ,[Mileage]
	  ,[Routing]
	  ,[TripLength]
	  ,[ExchangeInd]
	  ,[OrigExchTktNum]
	  ,[ETktInd]
	  ,[ProductType]
	  ,[TourCode]
	  ,[ServiceType]
	  ,[RefundInd]
	  ,[OriginCode]
	  ,[DestinationCode])     
    SELECT Distinct 
	   ID.[RecordKey]
	  ,ID.[IataNum]
	  ,ID.[SeqNum]
	  ,ID.[ClientCode]
	  ,ID.[InvoiceDate]
	  ,ID.[IssueDate]
	  ,ID.[VoidInd]
	  ,ID.[DocumentNumber]
	  ,ID.[EndDocNumber]
	  ,ID.[VendorNumber]
	  ,ID.[VendorType]
	  ,ID.[ValCarrierNum]
	  ,ID.[ValCarrierCode]
	  ,ID.[VendorName]
	  ,ID.[BookingDate]
	  ,ID.[ServiceDate]
	  ,ID.[ServiceCategory]
	  ,ID.[InternationalInd]
	  ,ID.[ServiceFee]
	  ,ID.[InvoiceAmt]
	  ,ID.[TaxAmt]
	  ,ID.[TotalAmt]
	  ,ID.[CommissionAmt]
	  ,ID.[CancelPenaltyAmt]
	  ,ID.[CurrCode]
	  ,ID.[Mileage]
	  ,ID.[Routing]
	  ,ID.[TrueTktCount]
	  ,ID.[ExchangeInd]
	  ,ID.[OrigExchTktNum]
	  ,ID.[ETktInd]
	  ,ID.[ProductType]
	  ,ID.[TourCode]
	  ,ID.[ServiceType]
	  ,ID.[RefundInd]
	  ,ID.[OriginCode]
	  ,ID.[DestinationCode]
    from dba.InvoiceHeader IH, dba.InvoiceDetail ID, dba.Transeg TS
    where IH.RecordKey = ID.RecordKey
    and IH.IataNum = ID.IataNum
    and IH.RecordKey = TS.RecordKey
    and IH.IataNum = TS.IataNum
    and ID.RecordKey = TS.RecordKey
    and ID.IataNum = TS.IataNum
    and ID.SeqNum = TS.SeqNum
    and IH.IataNum NOT LIKE ''PRE%''
    and (ID.Vendortype in (''BSP'',''NONBSP'', ''BSPSTP'', ''RAIL'')
	  or ID.Vendortype =''NONAIR'' and Producttype in (''RAIL'',''AIR''))
    and ID.VoidInd = ''N''
    and TS.MinDestCityCode is not null
    and IH.ImportDt = '''+rtrim(convert(char,@Importdate,120))+''''

-- Move TranSeg 

Set @SQL_MOVE_TRANSEG = 
    'Insert into '+@Stage_Server+'.'+@Stage_Database+'.dba.TranSeg 
    (RecordKey,IataNum,SeqNum,SegmentNum,TypeCode,ClientCode,InvoiceDate,IssueDate,OriginCityCode,SegmentCarrierCode,SegmentCarrierName,CodeShareCarrierCode,EquipmentCode,PrefAirInd,DepartureDate,DepartureTime,FlightNum,ClassOfService,FareBasis,TktDesignator,ConnectionInd,StopOverTime,FrequentFlyerNum,FrequentFlyerMileage,CurrCode,SEGDestCityCode,SEGInternationalInd,SEGArrivalDate,SEGArrivalTime,SEGSegmentValue,SEGSegmentMileage,SEGTotalMileage,SEGFlightTime,SEGMktOrigCityCode,SEGMktDestCityCode,SEGReturnInd,NOXDestCityCode,NOXInternationalInd,NOXArrivalDate,NOXArrivalTime,NOXSegmentValue,NOXSegmentMileage,NOXTotalMileage,NOXFlightTime,NOXMktOrigCityCode,NOXMktDestCityCode,NOXConnectionString,NOXReturnInd,MINDestCityCode,MINInternationalInd,MINArrivalDate,MINArrivalTime,MINSegmentValue,MINSegmentMileage,MINTotalMileage,MINFlightTime,MINMktOrigCityCode,MINMktDestCityCode,MINConnectionString,MINReturnInd,MealName,NOXSegmentCarrierCode,NOXSegmentCarrierName,NOXClassOfService,MINSegmentCarrierCode,MINSegmentCarrierName,MINClassOfService)
    SELECT Distinct 
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
    from dba.InvoiceHeader IH, dba.InvoiceDetail ID, dba.Transeg TS
    where IH.RecordKey = ID.RecordKey
    and IH.IataNum = ID.IataNum
    and IH.RecordKey = TS.RecordKey
    and IH.IataNum = TS.IataNum
    and ID.RecordKey = TS.RecordKey
    and ID.IataNum = TS.IataNum
    and ID.SeqNum = TS.SeqNum
    and IH.IataNum NOT LIKE ''PRE%''
    and (ID.Vendortype in (''BSP'',''NONBSP'', ''BSPSTP'', ''RAIL'')
	  or ID.Vendortype =''NONAIR'' and Producttype in (''RAIL'',''AIR''))
    and ID.VoidInd = ''N''
    and TS.MinDestCityCode is not null
    and IH.ImportDt = '''+rtrim(convert(char,@Importdate,120))+''''
    

    EXEC sp_executesql @SQL_MOVE_INVOICEDETAIL
    EXEC sp_executesql @SQL_MOVE_TRANSEG   

/************************************************************************
    6.  Execute Stored Procedure to process ACM on staging
*************************************************************************/

    Set @SQL_PROCESS_ON_STAGING = 'Exec  '+@Stage_Server+'.'+@Stage_Database+'.dbo.sp_ACM_Stage_Process_On_Import'
    
 --   EXEC sp_executesql @SQL_PROCESS_ON_STAGING  

  
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  


END

GO

ALTER AUTHORIZATION ON [dbo].[sp_Process_ACM_On_Import_On_Staging] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/10/2015 10:05:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](255) NULL,
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

ALTER AUTHORIZATION ON [DBA].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[OpCarXRef]    Script Date: 7/10/2015 10:05:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[OpCarXRef](
	[Carrier] [char](3) NULL,
	[FlightNum] [varchar](10) NULL,
	[OpCarrier] [char](3) NULL,
	[BeginService] [datetime] NULL,
	[EndService] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[OpCarXRef] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/10/2015 10:05:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
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
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[GDSCode] [varchar](10) NULL,
	[BackOfficeID] [varchar](20) NULL,
	[IMPORTDT] [datetime] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ContractRmks]    Script Date: 7/10/2015 10:05:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ContractRmks](
	[RecordKey] [varchar](50) NULL,
	[IataNum] [varchar](8) NULL,
	[SeqNum] [smallint] NULL,
	[SegmentNum] [smallint] NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[ContractID] [varchar](30) NULL,
	[CompliantInd] [char](1) NULL,
	[RouteType] [char](1) NULL,
	[RouteTypeInd] [char](1) NULL,
	[FlownCarrierInd] [char](1) NULL,
	[MarketInd] [char](1) NULL,
	[DesignatorInd] [char](1) NULL,
	[FareBasisInd] [char](1) NULL,
	[CodeShareInd] [char](1) NULL,
	[ClassInd] [char](1) NULL,
	[FlightNumInd] [char](1) NULL,
	[POSInd] [char](1) NULL,
	[DiscountInd] [char](1) NULL,
	[FareAmtInd] [char](1) NULL,
	[TourCodeInd] [char](1) NULL,
	[OverNightInd] [char](1) NULL,
	[DOWInd] [char](1) NULL,
	[CarrierString] [varchar](50) NULL,
	[DaysAdvInd] [char](1) NULL,
	[ExcludedItem] [char](1) NULL,
	[ExhibitNum] [int] NULL,
	[MarketNum] [int] NULL,
	[StgyExhibitNum] [int] NULL,
	[StgyMarketNum] [int] NULL,
	[FareAmt] [float] NULL,
	[LongHaulOrigCityCode] [varchar](10) NULL,
	[LongHaulDestCityCode] [varchar](10) NULL,
	[LongHaulMktOrigCityCode] [varchar](10) NULL,
	[LongHaulMktDestCityCode] [varchar](10) NULL,
	[LongHaulFMS] [float] NULL,
	[LongHaulMileage] [float] NULL,
	[PublishedFare] [money] NULL,
	[DiscountedFare] [money] NULL,
	[MktRegionInd] [char](1) NULL,
	[RefundInd] [char](1) NULL,
	[FairMktShr] [float] NULL,
	[QSI] [float] NULL,
	[GoalNumber] [int] NULL,
	[ValCarrierInd] [char](1) NULL,
	[SatNtRqdInd] [char](1) NULL,
	[GoalExhibitNum] [int] NULL,
	[GoalMarketNum] [int] NULL,
	[GoalFlownCarrierInd] [char](1) NULL,
	[OnlineInd] [char](1) NULL,
	[InterlineInd] [char](1) NULL,
	[GDSInd] [char](1) NULL,
	[COSString] [varchar](50) NULL,
	[COSTicketString] [varchar](50) NULL,
	[MinStayInd] [char](1) NULL,
	[DepartureDate] [datetime] NULL,
	[MINFMS] [float] NULL,
	[MINOpCarrierCode] [varchar](3) NULL,
	[OnlineFlag] [char](1) NULL,
	[InterlineFlag] [char](1) NULL,
	[ContractCarrierFlag] [char](1) NULL,
	[POSCountry] [varchar](2) NULL,
	[SEGOpCarrierCode] [varchar](3) NULL,
	[NOXOpCarrierCode] [varchar](3) NULL,
	[farepct] [float] NULL,
	[SegNum] [int] NULL,
	[Miles] [float] NULL,
	[ProcEndDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ContractRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ACMInfo]    Script Date: 7/10/2015 10:06:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ACMInfo](
	[RecordKey] [varchar](50) NULL,
	[IataNum] [varchar](8) NULL,
	[SeqNum] [smallint] NULL,
	[SegmentNum] [smallint] NULL,
	[ClientCode] [varchar](15) NULL,
	[CustomerID] [varchar](30) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[DepartureDate] [datetime] NULL,
	[FareBeforeDiscount] [float] NULL,
	[DiscountedFare] [float] NULL,
	[ContractID] [varchar](30) NULL,
	[ExhibitNumber] [int] NULL,
	[MarketNumber] [int] NULL,
	[GoalNumber] [int] NULL,
	[RestrictionLevel] [float] NULL,
	[CabinCategory] [varchar](10) NULL,
	[ComfortLevel] [real] NULL,
	[FareCategory] [varchar](10) NULL,
	[ProjectedFare] [float] NULL,
	[ClassOfServiceScore] [float] NULL,
	[RefundedInd] [char](1) NULL,
	[POSCountry] [varchar](2) NULL,
	[RouteType] [char](1) NULL,
	[ContractCarrierFlag] [char](1) NULL,
	[InterlineFlag] [char](1) NULL,
	[MINOpCarrierCode] [varchar](3) NULL,
	[MINFMS] [float] NULL,
	[CO2Emissions] [float] NULL,
	[LongHaulOrigCityCode] [varchar](10) NULL,
	[LongHaulDestCityCode] [varchar](10) NULL,
	[LongHaulMktOrigCityCode] [varchar](10) NULL,
	[LongHaulMktDestCityCode] [varchar](10) NULL,
	[LongHaulFMS] [float] NULL,
	[LongHaulMileage] [float] NULL,
	[MktElasticityFactor] [float] NULL,
	[MarketCategory] [varchar](4) NULL,
	[SegNum] [int] NULL,
	[Miles] [float] NULL,
	[ImportDt] [datetime] NULL,
	[ProcEndDate] [datetime] NULL,
	[Commission] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ACMInfo] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[TranSeg]    Script Date: 7/10/2015 10:06:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[SegmentNum] [smallint] NOT NULL,
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
	[StopOverTime] [smallint] NULL,
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
	[SEGFlightTime] [smallint] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [smallint] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [smallint] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [smallint] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [smallint] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [smallint] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](20) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](20) NULL,
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
	[YieldDatePosted] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[TranSeg] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IOpCarXRef]    Script Date: 7/10/2015 10:06:55 AM ******/
CREATE UNIQUE CLUSTERED INDEX [IOpCarXRef] ON [DBA].[OpCarXRef]
(
	[Carrier] ASC,
	[FlightNum] ASC,
	[OpCarrier] ASC,
	[BeginService] ASC,
	[EndService] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/10/2015 10:06:56 AM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[InvoiceDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI1]    Script Date: 7/10/2015 10:06:57 AM ******/
CREATE CLUSTERED INDEX [ContractRmksI1] ON [DBA].[ContractRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI1]    Script Date: 7/10/2015 10:06:58 AM ******/
CREATE CLUSTERED INDEX [ACMInfoI1] ON [DBA].[ACMInfo]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/10/2015 10:06:59 AM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [DBA].[TranSeg]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/10/2015 10:07:00 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [DBA].[InvoiceHeader]
(
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/10/2015 10:07:01 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[BackOfficeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/10/2015 10:07:02 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI4] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/10/2015 10:07:03 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/10/2015 10:07:04 AM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ContractRmksI2]    Script Date: 7/10/2015 10:07:04 AM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI2] ON [DBA].[ContractRmks]
(
	[GoalExhibitNum] ASC,
	[GoalMarketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI4]    Script Date: 7/10/2015 10:07:05 AM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI4] ON [DBA].[ContractRmks]
(
	[ContractID] ASC,
	[MarketNum] ASC,
	[DepartureDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[CompliantInd],
	[ExhibitNum],
	[POSCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksPx]    Script Date: 7/10/2015 10:07:07 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ContractRmksPx] ON [DBA].[ContractRmks]
(
	[ContractID] ASC,
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID]    Script Date: 7/10/2015 10:07:08 AM ******/
CREATE NONCLUSTERED INDEX [IX_CONTRACTRMKS_CONTRACTID] ON [DBA].[ContractRmks]
(
	[ContractID] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI2]    Script Date: 7/10/2015 10:07:10 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI2] ON [DBA].[ACMInfo]
(
	[ImportDt] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI3]    Script Date: 7/10/2015 10:07:11 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI3] ON [DBA].[ACMInfo]
(
	[IssueDate] ASC,
	[DepartureDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[DiscountedFare]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI4]    Script Date: 7/10/2015 10:07:13 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI4] ON [DBA].[ACMInfo]
(
	[ContractCarrierFlag] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[IssueDate],
	[FareBeforeDiscount],
	[DiscountedFare],
	[ContractID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI5]    Script Date: 7/10/2015 10:07:16 AM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI5] ON [DBA].[ACMInfo]
(
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[FareBeforeDiscount],
	[DiscountedFare],
	[ContractID],
	[ContractCarrierFlag],
	[MINFMS]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoPX]    Script Date: 7/10/2015 10:07:17 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ACMInfoPX] ON [DBA].[ACMInfo]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/10/2015 10:07:18 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [DBA].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

