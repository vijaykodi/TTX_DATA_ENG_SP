/****** Object:  StoredProcedure [dbo].[sp_ACM_Stage_Process_On_Import_Lisa]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ====================================================================================================
-- Author:		  Charlie Bradsher
-- Create date:	  2013-09-12
-- Description:	  Stage and Process Data on Staging Server as data is imported
--			  Runs on the customer's staging server for ETLRequestName in dba.DRA on ACM Central
--
--			  ARGUMENTS:
--			  @ImportDate  - If not passed then uses the last ImportDt value from InvoiceHeader
--
--			  WHAT IT DOES:
--			  Processes data for the @ImportDate argument 	
--			  Default max time to process is 180 minutes if not specified in ACMDatabases
--			  See Documentation on ACM Central for details		  
-- ====================================================================================================

 CREATE PROCEDURE [dbo].[sp_ACM_Stage_Process_On_Import_Lisa]
    @ImportDate DATETIME = NULL
AS
BEGIN


/************************************************************************
    Set arguments and variables
*************************************************************************/
   
   -- DECLARE @ImportDate datetime  
    DECLARE @CustomerID VARCHAR(30);
    DECLARE @Prod_Server VARCHAR(50);
    DECLARE @Prod_Database VARCHAR(50);
    DECLARE @Process_Server VARCHAR(50); 
    DECLARE @Stage_Server VARCHAR(50);
    DECLARE @User VARCHAR(100); 
    DECLARE @Pword VARCHAR(100);
    DECLARE @ACMProcessor VARCHAR(500);
    DECLARE @ProcessArgs VARCHAR(500);
    DECLARE @Contract VARCHAR(30);
    DECLARE @ContractCarrier VARCHAR(50);
    DECLARE @ProcessorStartTime DATETIME;
    DECLARE @ProcessorEndTime DATETIME;
    DECLARE @MaxProcessorMins INT;
    DECLARE @SQL_GET_CUSTROLL  NVARCHAR(2000);
    DECLARE @SQL_GET_CUSTMAST  NVARCHAR(2000);
    DECLARE @SQL_CHECK_CUSTROLL  NVARCHAR(2000);
    DECLARE @SQL_PUSH_CUSTROLL  NVARCHAR(2000);
    DECLARE @SQL_AC  NVARCHAR(2000);
    DECLARE @SQL_ACE NVARCHAR(2000);	
    DECLARE @SQL_ACM NVARCHAR(2000);	
    DECLARE @SQL_ACG NVARCHAR(2000);
    DECLARE @SQL_DEL_ACMI_PROD NVARCHAR(2000);	
    DECLARE @SQL_DEL_ACRMKS_PROD NVARCHAR(2000);
    DECLARE @SQL_PUSH_ACMI NVARCHAR(2000);	
    DECLARE @SQL_PUSH_ACRMKS NVARCHAR(2000);  
    
   DECLARE @Iata VARCHAR(50);
   DECLARE @ProcName VARCHAR(50);
   DECLARE @TransStart DATETIME;
   DECLARE @BeginIssueDate DATETIME;
   DECLARE @ENDIssueDate DATETIME;   

   
--=================================
--Added by rcr  07/02/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
   DECLARE @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)


    IF @ImportDate IS NULL
    BEGIN
	 SET @ImportDate = (SELECT MAX(ImportDt)FROM DBA.InvoiceHeader WHERE IataNum NOT LIKE 'PRE%');
    END;
    
    
    SET @CustomerID = (SELECT MIN(DRA.CustomerID)FROM dba.InvoiceHeader IH, ttxpaSQL09.TMAN503_REPORTS_ACM.dba.DRA DRA WHERE IataNum = ETLRequestName AND IH.ImportDt = @ImportDate);
    SET @Prod_Server = 'TTXPASQL01';
    SET @Prod_Database = 'TMAN_UBS';
    
    SET @Process_Server = (SELECT ProcessServer FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases WHERE CustomerID = @CustomerID AND DatabaseCategory = 'Stage');
    SET @Process_Server = (SELECT '\\'+ @Process_Server+'.TRXFS.TRX.COM' );
    SET @MaxProcessorMins = (SELECT ISNULL(MaxProcessMinutes,180) FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases WHERE CustomerID = @CustomerID AND DatabaseCategory = 'STAGE');
    SET @User = N'wtpdh\smsservice';  
    SET @Pword = N'melanie';  --really?
    SET @ACMProcessor = 'c:\ProcessACM\ProcessContracts.exe';   
    SET @ProcessArgs = (SELECT '-CS'+DataDSN+' -TS'+ACMTermsDSN+' -ID'+SUBSTRING(CONVERT(VARCHAR,@ImportDate,111),6,15)+'/'+SUBSTRING(CONVERT(VARCHAR,@ImportDate,111),1,4)+' -IT'+SUBSTRING(CONVERT(VARCHAR,@ImportDate,120),12,8) FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases WHERE CustomerID = @CustomerID AND DatabaseCategory = 'STAGE');
	
	SET @Iata = 'UBS';
	SET @ProcName = CONVERT(VARCHAR(50),OBJECT_NAME(@@PROCID));
	SET @TransStart = getdate()

	
 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
/************************************************************************
	LOGGING_START - END
************************************************************************/ 
  
    
/************************************************************************
    Continue only if running on a staging server
*************************************************************************/  
   -- IF @Prod_Server = @@Servername
   -- BEGIN
	  --INSERT INTO ttxpaSQL09.TMAN503_Reports_ACM.dba.ACMAutoProcessLog (ProcessDate, ProcessValues, ProcessText)
	  --SELECT GETDATE(), @Prod_Server+'='+@@Servername,'Process failed - process musts run on staging server';

	  --PRINT 'This process must run on a staging server - check your settings';
	  --PRINT 'Prod Server is '+@Prod_Server+', running on '+@@ServerName;
	  --RETURN; 
   -- END;	     
/************************************************************************
    Prepare data for processing
*************************************************************************/
       
--  Update CustRollup on Production with new clientcodes and copy to staging 
--  (uses CustomerID from DRA for ETLRequestName)
SET @TransStart = GETDATE();

   SET @SQL_GET_CUSTMAST = 'Insert into TTXPASQL01.TMAN_UBS.dba.CustMast (AgencyIataNum, MasterCustNo)
				    Select distinct AgencyIataNum, MasterCustNo
				    from '+@Prod_Server+'.'+@Prod_Database+'.'+'dba.CustMast';
				    	
   SET @SQL_GET_CUSTROLL = 'Insert into TTXPASQL01.TMAN_UBS.dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
				    Select distinct AgencyIataNum, CustNo, MasterCustNo
				    from '+@Prod_Server+'.'+@Prod_Database+'.'+'dba.CustRollup';
				    
   SET @SQL_CHECK_CUSTROLL = 'Insert into TTXPASQL01.TMAN_UBS.dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
				    Select distinct IH.IataNum, IH.ClientCode, '''+@CustomerID+'''
				    from dba.InvoiceHeader IH
				    left outer join TTXPASQL01.TMAN_UBS.dba.CustRollup CRoll on (IH.IataNum = CRoll.AgencyIataNum
				    and IH.ClientCode = CRoll.CustNo)
				    where IH.IataNum not like ''Pre%''
				    Group by  IH.IataNum, IH.ClientCode, CRoll.CustNo
				    having CRoll.CustNo is null';	
				    
  SET @SQL_PUSH_CUSTROLL = 'Insert into '+@Prod_Server+'.'+@Prod_Database+'.'+'dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
				    Select IH.IataNum, IH.ClientCode, '''+@CustomerID+'''
				    from dba.InvoiceHeader IH
				    left outer join dba.CustRollup CRoll on (IH.IataNum = CRoll.AgencyIataNum
				    and IH.ClientCode = CRoll.CustNo)
				    where IH.IataNum not like ''Pre%''
				    Group by  IH.IataNum, IH.ClientCode, CRoll.CustNo
				    having CRoll.CustNo is null';					        	    			
    
    DELETE dba.CustRollup;
    DELETE dba.CustMast;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-ACM Begin Prepare data-',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-ACM Begin Prepare data-'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


SET @TransStart = GETDATE();
     
    EXEC sp_executesql @SQL_GET_CUSTMAST; 
    
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-ACM SQL_GET_CUSTMAST',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-ACM SQL_GET_CUSTMAST'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


SET @TransStart = GETDATE();
    EXEC sp_executesql @SQL_GET_CUSTROLL;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-ACM SQL_GET_CUSTROLL',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-ACM SQL_GET_CUSTROLL'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


SET @TransStart = GETDATE();
    EXEC sp_executesql @SQL_CHECK_CUSTROLL;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-ACM SQL_CHECK_CUSTROLL',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-ACM SQL_CHECK_CUSTROLL'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


SET @TransStart = GETDATE();
    EXEC sp_executesql @SQL_PUSH_CUSTROLL;
 
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-ACM SQL_PUSH_CUSTROLL',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-ACM SQL_PUSH_CUSTROLL'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


SET @TransStart = GETDATE();   
--  Delete data for re-processing  (ContractRmks and ACMInfo only)

    DELETE ACRmks
    FROM dba.ContractRmks ACRmks, dba.InvoiceHeader IH
    WHERE ACRmks.Recordkey = IH.RecordKey  AND ACRmks.IataNum = IH.IataNum AND IH.ImportDT = @ImportDate;

    DELETE ACMI
    FROM dba.ACMInfo ACMI, dba.InvoiceHeader IH
    WHERE ACMI.Recordkey = IH.RecordKey AND ACMI.IataNum = IH.IataNum AND IH.ImportDT = @ImportDate;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Delete data for re-processing',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 2-Delete data for re-processing'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


 SET @TransStart = GETDATE();   
--  Delete orphaned records  (ContractRmks and ACMInfo only)  
  
    DELETE dba.ACMInfo 
    WHERE Recordkey IN (SELECT ACMI.RecordKey
		FROM dba.ACMInfo ACMI
		LEFT OUTER JOIN dba.Transeg TS ON (TS.RecordKey = ACMI.RecordKey AND Ts.IataNum = ACMI.IataNum AND TS.SeqNum = ACMI.SeqNum AND TS.SegmentNum = ACMI.SegmentNum)
		GROUP BY TS.RecordKey, ACMI.RecordKey
		HAVING TS.RecordKey IS NULL);
		
    DELETE dba.ContractRmks 
    WHERE Recordkey IN (SELECT ACRmks.RecordKey
		FROM dba.ContractRmks ACRmks
		LEFT OUTER JOIN dba.Transeg TS ON (TS.RecordKey = ACRmks.RecordKey AND TS.IataNum = ACRmks.IataNum AND TS.SeqNum = ACRmks.SeqNum AND TS.SegmentNum = ACRmks.SegmentNum)
		GROUP BY TS.RecordKey, ACRmks.RecordKey
		HAVING TS.RecordKey IS NULL);				

 --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Delete Orphan Records ',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
  ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 2-Delete Orphan Records '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


SET @TransStart = GETDATE();
-- Operating Carrier and Fare Basis

    UPDATE TS
    SET TS.CodeshareCarrierCode = XR.OpCarrier
    FROM dba.TranSeg TS, TTXSASQL01.DATAFEEDS.dba.OpCarXref XR, dba.InvoiceHeader IH
    WHERE IH.RecordKey = TS.RecordKey AND IH.IataNum = TS.IataNum
    AND IH.ImportDt = @ImportDate
    AND TS.SegmentCarrierCode = XR.Carrier  AND TS.FlightNum = XR.FlightNum   
    AND TS.DepartureDate BETWEEN  XR.BeginService AND XR.EndService
    AND TS.CodeshareCarrierCode IS NULL;

    UPDATE TS
    SET CodeshareCarrierCode = SegmentCarrierCode
    FROM dba.TranSeg TS,dba.InvoiceHeader IH
    WHERE IH.RecordKey = TS.RecordKey     AND IH.IataNum = TS.IataNum
    AND IH.ImportDt = @ImportDate
    AND CodeshareCarrierCode IS NULL;

    UPDATE TS
    SET FareBasis = LEFT(ClassOfService,1)
    FROM dba.Transeg TS, dba.InvoiceHeader IH
    WHERE IH.RecordKey = TS.RecordKey     AND IH.IataNum = TS.IataNum
    AND IH.ImportDt = @ImportDate
    AND FareBasis IS NULL;
    
    --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-OperatingCarrier FB ',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 3-OperatingCarrier FB '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	

SET @TransStart = GETDATE();
/************************************************************************
  Refresh terms data
*************************************************************************/
--  truncate existing terms data

    DELETE dba.AirlineContracts;
    DELETE dba.AirlineContractExhibits;
    DELETE dba.AirlineContractMarkets;
    DELETE dba.AirlineContractGoals;
    
--  insert terms data to staging from production    
            
    SET @SQL_AC = 'Insert into dba.AirlineContracts
	Select AC.* 
	from '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContracts AC
	where scenario = ''N''';
    		  
    SET @SQL_ACE = 'Insert into dba.AirlineContractExhibits
	 Select ACE.* 
	 from '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContracts AC, '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContractExhibits ACE
	 where AC.CustomerID = ACE.CustomerID
	 and AC.ContractNumber = ACE.ContractNumber
	 and AC.scenario = ''N''';	
    		   
    SET @SQL_ACM = 'Insert into dba.AirlineContractMarkets
	 Select ACM.* 
	 from '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContracts AC, '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContractMarkets ACM
	  where AC.CustomerID = ACM.CustomerID
	 and AC.ContractNumber = ACM.ContractNumber
	 and AC.scenario = ''N''';	
    		   
    SET @SQL_ACG = 'Insert into dba.AirlineContractGoals
	 Select ACG.* 
	 from '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContracts AC, '+@Prod_Server+'.'+@Prod_Database+'.dba.AirlineContractGoals ACG
	 where AC.CustomerID = ACG.CustomerID
	 and AC.ContractNumber = ACG.ContractNumber
	 and AC.scenario = ''N''';		
    		   
    EXEC sp_executesql @SQL_AC;
    EXEC sp_executesql @SQL_ACE;
    EXEC sp_executesql @SQL_ACM;
    EXEC sp_executesql @SQL_ACG;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-Insert Terms ',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 4-Insert Terms '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

SET @TransStart = GETDATE();	   		   		   	 
/*******************************************************************************************
  Load ACMInfo table  ( note - this sets the ImportDt in ACMInfo = ImportDt in InvoiceHeader)
*******************************************************************************************/

    INSERT INTO dba.ACMInfo
      (RecordKey, IataNum, SeqNum, SegmentNum, ClientCode, InvoiceDate,IssueDate, InterlineFlag, RouteType
      , POSCountry,DepartureDate, ImportDt)

    SELECT TS.RecordKey, TS.IataNum, TS.SeqNum, TS.SegmentNum, TS.ClientCode, TS.InvoiceDate
    ,TS.IssueDate, 'Y', 'O',IH.OrigCountry,TS.DepartureDate, IH.ImportDt
    FROM DBA.Transeg TS, DBA.InvoiceDetail ID, DBA.InvoiceHeader IH
      WHERE  TS.MINDestCityCode IS NOT NULL
      AND ID.RecordKey = TS.RecordKey AND ID.Iatanum = TS.IataNum AND ID.SeqNum = TS.SeqNum
      AND IH.RecordKey = TS.RecordKey AND IH.Iatanum = TS.IataNum AND IH.RecordKey = ID.RecordKey
      AND IH.Iatanum = ID.IataNum AND TS.IssueDate = ID.IssueDate AND ID.VoidInd = 'N'
      AND (ID.Vendortype IN ('BSP','NONBSP', 'BSPSTC','NONBSPSTC', 'RAIL')
	    OR ID.Vendortype ='NONAIR' AND ISNULL(Producttype,'UNKNOWN') IN ('RAIL','AIR','UNKNOWN'))
      
      AND IH.ImportDt = @ImportDate;


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-Load ACM Tables ',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 5-Load ACM Tables '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

/************************************************************************
  Set Route Type (Default Value is "O"
*************************************************************************/
SET @TransStart = GETDATE();
--  Set Outbound

    UPDATE ACMI
    SET ACMI.RouteType = 'R'
    FROM dba.ACMInfo ACMI, dba.TranSeg TS,dba.TranSeg TS2
    WHERE ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum AND ACMI.SeqNum = TS.SeqNum
    AND ACMI.SegmentNum = TS.SegmentNum AND TS.RecordKey = TS2.RecordKey AND TS.IataNum = TS2.IataNum
    AND TS.SeqNum = TS2.SeqNum AND TS2.SegmentNum > TS.SegmentNum
    AND TS.OriginCityCode = TS2.MinDestCityCode AND TS.MinDestCityCode = TS2.OriginCityCode
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6-Set Outbound',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 6-Set Outbound '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


SET @TransStart = GETDATE();
-- Flags Inbound Segment

    UPDATE ACMI
    SET ACMI.RouteType = 'R'
    FROM dba.ACMInfo ACMI, dba.TranSeg TS,dba.TranSeg TS2
    WHERE ACMI.RecordKey = TS2.RecordKey AND ACMI.IataNum = TS2.IataNum AND ACMI.SeqNum = TS2.SeqNum
    AND ACMI.SegmentNum = TS2.SegmentNum AND TS.RecordKey = TS2.RecordKey AND TS.IataNum = TS2.IataNum
    AND TS.SeqNum = TS2.SeqNum AND TS2.SegmentNum > TS.SegmentNum
    AND TS.OriginCityCode = TS2.MinDestCityCode AND TS.MinDestCityCode = TS2.OriginCityCode
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Flag Inbound',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 7-Flag Inbound '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


SET @TransStart = GETDATE();
/************************************************************************
    Set Interline Flag
*************************************************************************/

    UPDATE ACMI
    SET InterlineFlag = 'N'
    FROM dba.ACMInfo ACMI
    WHERE ACMI.ImportDt = @ImportDate
	 AND RecordKey+IataNum+CONVERT(CHAR,Seqnum) IN (
	    SELECT DISTINCT TS.RecordKey+TS.IataNum+CONVERT(CHAR,TS.Seqnum)
	    FROM dba.TranSeg TS, dba.ACMInfo ACMI
	    WHERE TS.RecordKey = ACMI.RecordKey AND TS.IataNum = ACMI.IataNum AND TS.SeqNum = ACMI.SeqNum
	    AND TS.SegmentNum = ACMI.SegmentNum AND ACMI.ImportDt = @ImportDate
	    GROUP BY TS.RecordKey+TS.IataNum+CONVERT(CHAR,TS.Seqnum)
	    HAVING MIN(SegmentCarrierCode) = MAX(SegmentCarrierCode));

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='8-Set Interline',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 8-Set Interline '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
/************************************************************************
    Set Long Haul Fields 
*************************************************************************/
SET @TransStart = GETDATE();
--  Find MIN Long Haul Segment and update

    UPDATE ACMI
    SET ACMI.SegNum = ACMI.SegmentNum
    FROM dba.ACMInfo ACMI, dba.TranSeg TS
    WHERE ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum AND ACMI.SeqNum = TS.SeqNum
    AND ACMI.SegmentNum = TS.SegmentNum AND SegDestCityCode = MINDestCityCode
    AND ACMI.ImportDt = @ImportDate;

    UPDATE ACMI
    SET ACMI.Miles = TS.SegSegmentMileage
    FROM dba.ACMInfo ACMI, dba.TranSeg TS
    WHERE ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum AND ACMI.SeqNum = TS.SeqNum
    AND ACMI.SegmentNum = TS.SegmentNum
    AND ACMI.ImportDt = @ImportDate;

    DECLARE @SegNum INT;
    DECLARE @UPCount INT;

    SET @SegNum = 1;
    SET @UpCount = 1;

	WHILE @UpCount > 0 
	BEGIN
		UPDATE ACMI
		SET ACMI.Miles = TS.SegSegmentMileage, ACMI.SegNum = TS.SegmentNum
		FROM dba.ACMInfo ACMI, dba.TranSeg TS
		WHERE ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum AND ACMI.SeqNum = TS.SeqNum
		AND TS.MinDestCityCode IS NULL AND TS.SegmentNum = ACMI.SegmentNum+@SegNum
		AND ABS(TS.SegSegmentMileage) > ABS(ACMI.Miles) AND ACMI.SegNum IS NULL
		AND ACMI.ImportDt = @ImportDate;

		UPDATE ACMI
		SET ACMI.SegNum = ACMI.SegmentNum
		FROM dba.ACMInfo ACMI, dba.ACMInfo ACMI2
		WHERE ACMI.RecordKey = ACMI2.RecordKey AND ACMI.IataNum = ACMI2.IataNum AND ACMI.SeqNum = ACMI2.SeqNum
		AND ACMI.SegmentNum+@SegNum+1 = ACMI2.SegmentNum AND ACMI2.Miles IS NOT NULL AND ACMI.SegNum IS NULL
		AND ACMI.ImportDt = @ImportDate;

		SET @UpCount = @@Rowcount;	
		SET @SegNum = @SegNum+1;
	END;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Long Haul Fields  '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
/* **************************************************************************************************************************************************************************************************************
	END REPLACE WHILE LOOP
************************************************************************************************************************************************************************************************************** */
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACMI
    SET ACMI.SegNum = ACMI.SegmentNum, ACMI.Miles = TS.SegSegmentMileage
    FROM dba.ACMInfo ACMI, dba.TranSeg TS
    WHERE ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum AND ACMI.SeqNum = TS.SeqNum
    AND ACMI.SegmentNum = TS.SegmentNum AND  ACMI.SegNum IS NULL
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='9-Min LongHaul',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 9-Min LongHaul  '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


SET @TransStart = GETDATE();
-- Update 'em

    UPDATE ACMI
    SET ACMI.MINOpCarrierCode = TS.CodeShareCarrierCode,  ACMI.LongHaulOrigCityCode = TS.OriginCityCode
    , ACMI.LongHaulDestCityCode = TS.SegDestCityCode, ACMI.LongHaulMileage = ACMI.Miles
    , ACMI.LongHaulMktOrigCityCode = TS.SegMktOrigCityCode, ACMI.LongHaulMktDestCityCode = TS.SegMktDestCityCode
    FROM dba.ACMInfo ACMI, dba.TranSeg TS
    WHERE ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum AND ACMI.SeqNum = TS.SeqNum AND TS.SegmentNum = ACMI.SegNum
    AND ACMI.ImportDt = @ImportDate;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='10-Update EM',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 10-Update EM  '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR




SET @TransStart = GETDATE();
/************************************************************************
    Set FMS Fields for O & D and Long Haul Segment (of O&D)
*************************************************************************/

--  O & D FMS . Max FMS - FlownCarrier/QSI/DepartureDate

    UPDATE ACMI 
    SET ACMI.MINFMS = QSI.FMS
    FROM dba.TranSeg TS, TTXSASQL01.DATAFEEDS.dba.QSI QSI, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI
    WHERE TS.MINMktOrigCityCode = QSI.ORIG AND TS.MINMktDestCityCode = QSI.DEST
    AND TS.MINSegmentCarrierCode = QSI.Airline AND ACMI.DepartureDate BETWEEN QSI.BeginDate AND QSI.EndDate
    AND TS.DepartureDate BETWEEN QSI.BeginDate AND QSI.EndDate
    AND ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum
    AND ACMI.SeqNum = TS.SeqNum AND ACMI.SegmentNum = TS.SegmentNum
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Flown Carrier/O&D Departuredate',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 11-Flown Carrier/O&D Departuredate  '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--  O & D FMS - FlownCarrier/QSI/IssueDate
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACMI 
    SET ACMI.MINFMS = QSI.FMS
    FROM dba.TranSeg TS, TTXSASQL01.DATAFEEDS.dba.QSI QSI, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI
    WHERE TS.MINMktOrigCityCode = QSI.ORIG AND TS.MINMktDestCityCode = QSI.DEST
    AND TS.MINSegmentCarrierCode = QSI.Airline AND ACMI.IssueDate BETWEEN QSI.BeginDate AND QSI.EndDate
    AND TS.IssueDate BETWEEN QSI.BeginDate AND QSI.EndDate AND ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum 
    AND ACMI.SeqNum = TS.SeqNum AND ACMI.SegmentNum = TS.SegmentNum AND ACMI.MINFMS IS NULL
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Flown Carrier/O&D IssueDate',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 11-Flown Carrier/O&D IssueDate  '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--  LongHaul Segment FMS - FlownCarrier/QSI/DepartureDate
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACMI 
    SET ACMI.LongHaulFMS = QSI.FMS
    FROM dba.TranSeg TS, TTXSASQL01.DATAFEEDS.dba.QSI QSI, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI
    WHERE ACMI.LongHaulMktOrigCityCode = QSI.ORIG AND ACMI.LongHaulMktDestCityCode = QSI.DEST
    AND TS.MINSegmentCarrierCode = QSI.Airline AND ACMI.DepartureDate BETWEEN QSI.BeginDate AND QSI.EndDate
    AND TS.DepartureDate BETWEEN QSI.BeginDate AND QSI.EndDate AND ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum
    AND ACMI.SeqNum = TS.SeqNum AND ACMI.SegmentNum = TS.SegmentNum AND ACMI.LongHaulFMS IS NULL
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Flown Carrier/LH Depart Date',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 11-Flown Carrier/LH Depart Date '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
--  LongHaul Segment FMS - FlownCarrier/QSI/IssueDate

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACMI 
    SET ACMI.LongHaulFMS = QSI.FMS
    FROM dba.TranSeg TS, TTXSASQL01.DATAFEEDS.dba.QSI QSI, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI
    WHERE ACMI.LongHaulMktOrigCityCode = QSI.ORIG AND ACMI.LongHaulMktDestCityCode = QSI.DEST
    AND TS.MINSegmentCarrierCode = QSI.Airline AND ACMI.IssueDate BETWEEN QSI.BeginDate AND QSI.EndDate
    AND TS.IssueDate BETWEEN QSI.BeginDate AND QSI.EndDate AND ACMI.RecordKey = TS.RecordKey AND ACMI.IataNum = TS.IataNum
    AND ACMI.SeqNum = TS.SeqNum AND ACMI.SegmentNum = TS.SegmentNum AND ACMI.LongHaulFMS IS NULL
    AND ACMI.ImportDt = @ImportDate;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Flown Carrier/LH IssueDate',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 11-Flown Carrier/LH IssueDatee '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--  MktElasticityFactor(MaxFMS) - FlownCarrier/QSI/DepartureDate 
 --Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--
  
    UPDATE ACMI
    SET ACMI.MktElasticityFactor = QSI.MaxFMS
    FROM TTXSASQL01.TMAN_UBS.dba.acminfo ACMI, dba.transeg ts, TTXSASQL01.DATAFEEDS.dba.qsi QSI
    WHERE ACMI.recordkey = ts.recordkey AND ACMI.iatanum = TS.iatanum AND ACMI.seqnum = TS.seqnum
    AND ACMI.segmentnum = TS.segmentnum AND TS.MINMktOrigCityCode = QSI.orig AND TS.MINMktDestCityCode = QSI.dest
    AND TS.DepartureDate BETWEEN QSI.begindate AND QSI.enddate
    AND ACMI.DepartureDate BETWEEN QSI.begindate AND QSI.enddate
    AND ACMI.MktElasticityFactor IS NULL;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Flown Carrier/Mkt IssueDate',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 11-Flown Carrier/Mkt IssueDate '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--  MktElasticityFactor(MaxFMS) - FlownCarrier/QSI/IssueDate 
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACMI
    SET ACMI.MktElasticityFactor = QSI.MaxFMS
    FROM TTXSASQL01.TMAN_UBS.dba.acminfo ACMI, dba.transeg ts, TTXSASQL01.DATAFEEDS.dba.qsi QSI
    WHERE ACMI.recordkey = ts.recordkey AND ACMI.iatanum = TS.iatanum AND ACMI.seqnum = TS.seqnum
    AND ACMI.segmentnum = TS.segmentnum AND TS.MINMktOrigCityCode = QSI.orig AND TS.MINMktDestCityCode = QSI.dest
    AND TS.IssueDate BETWEEN QSI.begindate AND QSI.enddate AND ACMI.IssueDate BETWEEN QSI.begindate AND QSI.enddate
    AND ACMI.MktElasticityFactor IS NULL;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Flown Carrier',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 11-Flown Carrier '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR




SET @TransStart = GETDATE();
/************************************************************************
    Set DiscountedFare - Old Exchange Method
*************************************************************************/

--  Set Discounted fare = MinSegmentValue

    UPDATE ACMI
    SET DiscountedFare = MinSegmentValue
    FROM TTXSASQL01.TMAN_UBS.dba.acminfo acmi, dba.transeg ts
    WHERE ACMI.RecordKey = TS.RecordKey  AND ACMI.IataNum = TS.IataNum
    AND ACMI.SeqNum = TS.SeqNum AND ACMI.SegmentNum = TS.SegmentNum
    AND ACMI.ImportDt = @ImportDate;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Discounted fare = MinSegmentValue '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--  Set DiscountedFare = Prorated base fare when sum of SegmentValue <> ticket price
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACMI
    SET DiscountedFare = TS.MINSegmentMileage / TS.MINTotalMileage * ISNULL(ID.InvoiceAmt,0)
    FROM dba.TranSeg TS, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI, dba.InvoiceDetail ID
    WHERE TS.RecordKey = ACMI.RecordKey AND TS.IataNum = ACMI.Iatanum AND TS.SeqNum = ACMI.SeqNum
    AND TS.SegmentNum = ACMI.SegmentNum AND TS.RecordKey = ID.RecordKey AND TS.IataNum = ID.Iatanum
    AND TS.SeqNum = ID.SeqNum 
    AND ACMI.ImportDt = @ImportDate   
    AND ACMI.RecordKey IN ( SELECT DISTINCT ACMI.RecordKey
			FROM TTXSASQL01.TMAN_UBS.dba.acminfo ACMI, dba.InvoiceDetail ID 
			WHERE ACMI.RecordKey = ID.RecordKey AND ACMI.IataNum = ID.IataNum AND ACMI.SeqNum = ID.SeqNum
			AND ACMI.ImportDt = @ImportDate
	 GROUP BY ACMI.RecordKey, ROUND(ID.InvoiceAmt,0)
	 HAVING ROUND(ID.InvoiceAmt,0) <> ROUND(SUM(ISNULL(ACMI.DiscountedFare,0)),0)
    );
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='12-Set Discounted Fare',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 12-Set Discounted Fare '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR



SET @TransStart = GETDATE();

/************************************************************************
    Insert ContractRmk records
*************************************************************************/

    INSERT INTO dba.ContractRmks
    ( RecordKey , IataNum , SeqNum , SegmentNum , ClientCode , InvoiceDate , IssueDate , ContractID
    , RouteType , DiscountedFare , LongHaulOrigCityCode , LongHaulDestCityCode, LongHaulMktOrigCityCode ,LongHaulMktDestCityCode
    , LongHaulFMS , LongHaulMileage , MINOpCarrierCode , MINFMS , InterlineFlag , POSCountry , DepartureDate
    )
     
     SELECT 
	   ACMI.RecordKey, ACMI.IataNum , ACMI.SeqNum , ACMI.SegmentNum , ACMI.ClientCode , ACMI.InvoiceDate , ACMI.IssueDate
	 , AC.ContractNumber, ACMI.RouteType , ACMI.DiscountedFare , ACMI.LongHaulOrigCityCode , ACMI.LongHaulDestCityCode
	 , ACMI.LongHaulMktOrigCityCode, ACMI.LongHaulMktDestCityCode , ACMI.LongHaulFMS , ACMI.LongHaulMileage
	 , ACMI.MINOpCarrierCode , MINFMS , ACMI.InterlineFlag , ACMI.POSCountry , ACMI.DepartureDate
      FROM TTXSASQL01.TMAN_UBS.dba.AirlineContracts AC, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI, TTXSASQL01.TMAN_UBS.dba.CustRollUp CRoll
      WHERE CRoll.MasterCustNo = AC.CustomerID
      AND CRoll.AgencyIataNum = ACMI.IataNum
      AND CRoll.CustNo = ACMI.ClientCode
      AND ACMI.ImportDt = @importdate
      AND ACMI.IssueDate BETWEEN ( SELECT MIN(ACG.GoalBeginDate)
					 FROM TTXSASQL01.tman_ubs.dba.AirlineContractGoals  ACG
					 WHERE ACG.ContractNumber = AC.ContractNumber)
		  		 AND ( SELECT MAX(ACG.GoalEndDate)
					 FROM TTXSASQL01.tman_ubs.dba.AirlineContractGoals  ACG
					 WHERE ACG.ContractNumber = AC.ContractNumber)	    
      AND ACMI.DepartureDate BETWEEN ( SELECT MIN(ACG.TravelBeginDate)
					 FROM TTXSASQL01.tman_ubs.dba.AirlineContractGoals  ACG
					 WHERE ACG.ContractNumber = AC.ContractNumber)
		  		 AND ( SELECT MAX(ACG.TravelEndDate)
					 FROM TTXSASQL01.tman_ubs.dba.AirlineContractGoals  ACG
					 WHERE ACG.ContractNumber = AC.ContractNumber);
	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='13-Insert Contract Remarks',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
	
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 13-Insert Contract Remarks '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

	
	SET @TransStart = GETDATE();
      
/************************************************************************
    Set Online Flag - contract carrier is the first airline in 
    the contractcarriercodes field of in AirlineContracts table
*************************************************************************/

--  Use AirlineContracts.ContractCarrierCodes on DepartureDate
  
;WITH Airline AS(
	SELECT DISTINCT 
		ContractNumber, 
		LEFT(ContractCarrierCodes,2) AS ContractCarrierCodes
	FROM TTXSASQL01.TMAN_UBS.dba.AirlineContracts AC, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI, TTXSASQL01.TMAN_UBS.dba.CustRollup CRoll
	WHERE AC.CustomerID = CRoll.MasterCustNo
	AND ACMI.Iatanum = CRoll.AgencyIataNum
	AND ACMI.ClientCode = CRoll.CustNo
	AND ACMI.ImportDt = @ImportDate
)
UPDATE ACRmks
SET OnlineFlag = 'Y'
FROM 
TTXSASQL01.TMAN_UBS.dba.ContractRmks ACRmks
INNER JOIN dba.TranSeg TS ON TS.RecordKey = ACRmks.RecordKey
	AND TS.IataNum = ACRmks.IataNum
	AND TS.SeqNum = ACRmks.SeqNum
	AND TS.SegmentNum = ACRmks.SegmentNum
INNER JOIN dba.InvoiceHeader IH ON TS.RecordKey = IH.RecordKey
	AND TS.IataNum = IH.IataNum
	AND ACRmks.RecordKey = IH.RecordKey
	AND ACRmks.IataNum = IH.IataNum
INNER JOIN TTXSASQL01.DATAFEEDS.dba.AirlineContractAirportStats ACSO ON  TS.OriginCityCode = ACSO.StationCode
INNER JOIN TTXSASQL01.DATAFEEDS.dba.AirlineContractAirportStats ACSD ON TS.MinDestCityCode = ACSD.StationCode
INNER JOIN AirLine A ON ACRmks.ContractId = A.ContractNumber
	AND ACSO.CarrierCode = A.ContractCarrierCodes
	AND ACSD.CarrierCode = A.ContractCarrierCodes
WHERE 1=1
AND ACRmks.DepartureDate BETWEEN ACSO.BeginDate AND ACSO.EndDate
AND ACRmks.DepartureDate BETWEEN ACSD.BeginDate AND ACSD.EndDate
AND IH.ImportDt = @ImportDate
--  Use AirlineContracts.ContractCarrierCodes on Current Schedule 
 --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='14- Online Flag/1',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
  
  
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 14- Online Flag/1 '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR



--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--


	;WITH Airline AS(
		SELECT DISTINCT 
		ContractNumber, 
		LEFT(ContractCarrierCodes,2) AS ContractCarrierCodes
		FROM TTXSASQL01.TMAN_UBS.dba.AirlineContracts AC, TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI, TTXSASQL01.TMAN_UBS.dba.CustRollup CRoll
		WHERE AC.CustomerID = CRoll.MasterCustNo
		AND ACMI.Iatanum = CRoll.AgencyIataNum
		AND ACMI.ClientCode = CRoll.CustNo
		AND ACMI.ImportDt = @ImportDate
	)    
	UPDATE ACRmks
	SET OnlineFlag = 'Y'
	FROM 
	TTXSASQL01.TMAN_UBS.dba.ContractRmks ACRmks
	INNER JOIN dba.TranSeg TS ON TS.RecordKey = ACRmks.RecordKey
		AND TS.IataNum = ACRmks.IataNum
		AND TS.SeqNum = ACRmks.SeqNum
		AND TS.SegmentNum = ACRmks.SegmentNum
	INNER JOIN dba.InvoiceHeader IH ON TS.RecordKey = IH.RecordKey
		AND TS.IataNum = IH.IataNum
		AND ACRmks.RecordKey = IH.RecordKey
		AND ACRmks.IataNum = IH.IataNum
	INNER JOIN TTXSASQL01.DATAFEEDS.dba.AirlineContractAirportStats ACSO ON TS.OriginCityCode = ACSO.StationCode
	INNER JOIN TTXSASQL01.DATAFEEDS.dba.AirlineContractAirportStats ACSD ON TS.MinDestCityCode = ACSD.StationCode
	INNER JOIN Airline A ON ACRmks.ContractId = A.ContractNumber
	AND ACSO.CarrierCode = A.ContractCarrierCodes
	AND ACSD.CarrierCode = A.ContractCarrierCodes
	WHERE 1=1
	AND ACSO.BeginDate = (SELECT MAX(BeginDate) FROM TTXSASQL01.DATAFEEDS.dba.AirlineContractAirportStats)
	AND ACSD.BeginDate = (SELECT MAX(BeginDate) FROM TTXSASQL01.DATAFEEDS.dba.AirlineContractAirportStats)
	AND ACRmks.OnlineFlag IS NULL
	AND IH.ImportDt = @ImportDate;

 --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='14- Online Flag/2',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 14- Online Flag/2 '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--  Finish up online - set to "N" when null

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

    UPDATE ACRmks
    SET OnlineFlag = 'N'
    FROM TTXSASQL01.TMAN_UBS.dba.ContractRmks ACRmks, dba.InvoiceHeader IH
    WHERE IH.RecordKey = ACRmks.RecordKey AND IH.IataNum = ACRmks.IataNum AND  ACRmks.OnlineFlag IS NULL
    AND IH.ImportDt = @ImportDate;
 --EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='14- Online Flag/3/End',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 14- Online Flag/3/End '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


SET @TransStart = GETDATE();
INSERT INTO ttxpaSQL09.TMAN503_Reports_ACM.dba.ACMProcessedTransactions
SELECT @Prod_Server,@Prod_Database,IataNum, ImportDt , MasterCustNo, MIN(issuedate), MAX(issuedate), COUNT(DISTINCT recordkey), SUM(1) 
FROM TTXSASQL01.TMAN_UBS.dba.ACMInfo,TTXSASQL01.TMAN_UBS.dba.CustRollup
WHERE agencyiatanum = iatanum AND custno = clientcode
AND ImportDt = @ImportDate
GROUP BY IataNum, MasterCustNo, ImportDt;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='15-Insert Processed Trans',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 15-Insert Processed Trans '
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
/************************************************************************
    Execute SP to run ProcessContracts.exe - Runs on ATL875
    Processes on Customer Processing Server designated in ACMDatabases
    Moves data from Staging to Production
*************************************************************************/
--SET @TransStart = GETDATE();

--SET @SQL_DEL_ACMI_PROD =  'Delete Prod
--	  from dba.ACMInfo ACMI, TTXPASQL01.Tman_UBS.dba.ACMinfo Prod
--	  where ACMI.RecordKey = Prod.RecordKey
--	  and ACMI.IataNum = Prod.IataNum
--	  and ACMI.SeqNum = Prod.SeqNum
--	  and ACMI.Clientcode = Prod.Clientcode
--	  and ACMI.Issuedate = Prod.Issuedate
--	  and ACMI.SegmentNum = Prod.SegmentNum
--	  and ACMI.ImportDt = @Importdate'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='16- Process Contracts SQL_DEL_ACMI_PROD',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

--SET @TransStart = GETDATE();
	  
--    SET @SQL_DEL_ACRMKS_PROD =  'Delete ACRmks
--	  from TTXPASQL01.Tman_UBS.dba.ACMInfo ACMI,TTXPASQL01.Tman_UBS.dba.ContractRmks ACRmks
--	  where ACMI.RecordKey = ACRmks.RecordKey
--	  and ACMI.IataNum = ACRmks.IataNum
--	  and ACMI.SeqNum = ACRmks.SeqNum
--	  and ACMI.Clientcode = ACRmks.Clientcode
--	  and ACMI.Issuedate = ACRmks.Issuedate
--	  and ACMI.SegmentNum = ACRmks.SegmentNum
--	  and ACMI.ImportDt = @Importdate'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='16- Process Contracts SQL_DEL_ACRMKS_PROD',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
	  
-- SET @TransStart = GETDATE();
 
--  SET @SQL_PUSH_ACMI = 'Insert into TTXPASQL01.Tman_UBS.dba.ACMInfo
--	  Select *
--	  from dba.ACMInfo
--	  where ImportDt = @Importdate'
	
-- EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='16- Process Contracts SQL_PUSH_ACMI',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

-- SET @TransStart = GETDATE();
--  SET @SQL_PUSH_ACRMKS = 'Insert into TTXPASQL01.Tman_UBS.dba.ContractRmks
--	  Select ACRmks.*
--	  from dba.ContractRmks ACRmks, dba.ACMInfo ACMI
--	  where ACMI.RecordKey = ACRmks.RecordKey
--	  and ACMI.IataNum = ACRmks.IataNum
--	  and ACMI.SeqNum = ACRmks.SeqNum
--	  and ACMI.Clientcode = ACRmks.Clientcode
--	  and ACMI.Issuedate = ACRmks.Issuedate
--	  and ACMI.SegmentNum = ACRmks.SegmentNum
--	  and ACMI.ImportDt = @Importdate
--	  and acrmks.recordkey not in (select recordkey from dba.ContractRmks)'   
	    	
--  EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='16- Process Contracts SQL_PUSH_ACRMKS',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 SET @TransStart = GETDATE();			    
    SET @ProcessorEndTime = GETDATE()-1;
    SET @ProcessorStartTime = GETDATE();
     

    DECLARE	@return_value INT;

    EXEC	@return_value = atl875.server_Administration.dbo.sp_ExecuteACMProcessor
			@RemoteBatch = @ACMProcessor,
			@RemoteServer = @Process_Server,
			@RemoteUser = @User,
			@RemotePword = @Pword,
			@RemoteArgs = @ProcessArgs;

    SELECT	'Return Value' = @return_value;

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='16- Process Contracts sp_ExecuteACMProcessor',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 16- Process Contracts sp_ExecuteACMProcessor'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	

SET @TransStart = GETDATE();
----  Pushes data to production when ACMProcessor completes
----  Program will fail if time to process > MaxProcessingTime for customer in ACMDatabases
----  Default fail time is 180 minutes 		---- UBS is set for 360 in the table.	    				    

--WHILE DATEDIFF(mi,@ProcessorStartTime, GETDATE()) < @MaxProcessorMins
--BEGIN   

--	SET @ProcessorEndTime = (SELECT ISNULL(MAX(procenddate),@ProcessorEndTime) FROM dba.ContractRmks); 

--	IF @ProcessorEndTime > @ProcessorStartTime
--	BEGIN
	--	EXEC sp_executesql @SQL_DEL_ACMI_PROD, @Importdate = @Importdate;	  --  Delete redundant ACMInfo records on production

	--	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACMI_PROD',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
			 
	--	SET @TransStart = GETDATE();			 
	--	EXEC sp_executesql @SQL_PUSH_ACMI, @Importdate = @Importdate;	  --	Add new ACMInfo records to production
	--	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_PUSH_ACMI',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
			  
	--	SET @TransStart = GETDATE();			  
	--	EXEC sp_executesql @SQL_DEL_ACRMKS_PROD, @Importdate = @Importdate; --  Delete redundant ContractRmk records on production
	--	EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACRMKS_PROD',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

	--	SET @TransStart = GETDATE(); 			  
	--	EXEC sp_executesql @SQL_PUSH_ACRMKS, @Importdate = @Importdate;	  --	Add new ContractRmk records to production
 --		EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-@SQL_PUSH_ACRMKS',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
       		    
	--	RETURN;
	--END;
	--ELSE
	--	CONTINUE;	
	--END;
---------------************** Hoping this will work ****************--------------------
  ----Pushes data to production when ACMProcessor completes
 ---- Program will fail if time to process > MaxProcessingTime for customer in ACMDatabases
  ----Default fail time is 180 minutes 		---- UBS is set for 360 in the table.	    				    

WHILE DATEDIFF(mi,@ProcessorStartTime, GETDATE()) < @MaxProcessorMins
BEGIN   

	SET @ProcessorEndTime = (SELECT ISNULL(MAX(procenddate),@ProcessorEndTime) FROM dba.ContractRmks); 

	IF @ProcessorEndTime > @ProcessorStartTime
	BEGIN
		   --Delete redundant ACMInfo records on production
	  Delete Prod
	  from dba.ACMInfo ACMI, TTXPASQL01.Tman_UBS.dba.ACMinfo Prod
	  where ACMI.RecordKey = Prod.RecordKey
	  and ACMI.IataNum = Prod.IataNum
	  and ACMI.SeqNum = Prod.SeqNum
	  and ACMI.Clientcode = Prod.Clientcode
	  and ACMI.Issuedate = Prod.Issuedate
	  and ACMI.SegmentNum = Prod.SegmentNum
	  and ACMI.ImportDt = @Importdate

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACMI_PROD',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_DEL_ACMI_PROD'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
			 
SET @TransStart = GETDATE();			 
		  	--Add new ACMInfo records to production
	 Insert into TTXPASQL01.Tman_UBS.dba.ACMInfo
	 Select *
	 from dba.ACMInfo
	 where ImportDt = @Importdate
	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_PUSH_ACMI',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_PUSH_ACMI'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
				  
SET @TransStart = GETDATE();			  
		   --Delete redundant ContractRmk records on production
		 
	  Delete ACRmks
	  from TTXPASQL01.Tman_UBS.dba.ACMInfo ACMI,TTXPASQL01.Tman_UBS.dba.ContractRmks ACRmks
	  where ACMI.RecordKey = ACRmks.RecordKey
	  and ACMI.IataNum = ACRmks.IataNum
	  and ACMI.SeqNum = ACRmks.SeqNum
	  and ACMI.Clientcode = ACRmks.Clientcode
	  and ACMI.Issuedate = ACRmks.Issuedate
	  and ACMI.SegmentNum = ACRmks.SegmentNum
	  and ACMI.ImportDt = @Importdate
	  
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACRMKS_PROD',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

SET @TransStart = GETDATE(); 			  
		--Add new ContractRmk records to production
		
	  Insert into TTXPASQL01.Tman_UBS.dba.ContractRmks
	  Select ACRmks.*
	  from dba.ContractRmks ACRmks, dba.ACMInfo ACMI
	  where ACMI.RecordKey = ACRmks.RecordKey
	  and ACMI.IataNum = ACRmks.IataNum
	  and ACMI.SeqNum = ACRmks.SeqNum
	  and ACMI.Clientcode = ACRmks.Clientcode
	  and ACMI.Issuedate = ACRmks.Issuedate
	  and ACMI.SegmentNum = ACRmks.SegmentNum
	  and ACMI.ImportDt = '2014-06-10 11:56:37.000'
	  and acrmks.recordkey not in (select recordkey from TTXPASQL01.Tman_UBS.dba.ContractRmks)
	  
 		--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-@SQL_PUSH_ACRMKS',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
		----Added by rcr  07/07/2015
		set @LogSegNbr += 1 
		set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-@SQL_PUSH_ACRMKS'
		----
		EXEC dbo.sp_LogProcErrors 
			@ProcedureName=@ProcName
			,@IataNum=@Iata
			,@LogStart=@TransStart
			,@StepName=@LogStep
			,@BeginDate=@LocalBeginIssueDate
			,@EndDate=@LocalEndIssueDate
			,@RowCount=@@ROWCOUNT
			,@ERR=@@ERROR	
				    		    
		RETURN;
	END;
	ELSE
		CONTINUE;	
	END;
	 
 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
		----Added by rcr  07/07/2015
		set @LogSegNbr += 1 
		set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
		----
		EXEC dbo.sp_LogProcErrors 
			@ProcedureName=@ProcName
			,@IataNum=@Iata
			,@LogStart=@TransStart
			,@StepName=@LogStep
			,@BeginDate=@LocalBeginIssueDate
			,@EndDate=@LocalEndIssueDate
			,@RowCount=@@ROWCOUNT
			,@ERR=@@ERROR	
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  

end;
--	PRINT @ProcessorStartTime; 
--	PRINT @ProcessorEndTime;         
    
--END;
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ACM Process complete',@BeginDate=@ImportDate,@EndDate=@ImportDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;






GO
