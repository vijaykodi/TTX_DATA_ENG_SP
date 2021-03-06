/****** Object:  StoredProcedure [dbo].[sp_Process_ACM_On_Import_On_Staging]    Script Date: 7/14/2015 7:39:28 PM ******/
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
