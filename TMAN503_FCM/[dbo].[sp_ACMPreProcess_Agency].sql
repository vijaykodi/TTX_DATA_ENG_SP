/****** Object:  StoredProcedure [dbo].[sp_ACMPreProcess_Agency]    Script Date: 7/14/2015 8:06:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==========================================================================================
-- Author:		  Charlie Bradsher
-- Create date:	  2012-09-19
-- Modify date:	  2013-03-25  Modified for EMC, update the CustRollUp checking query
-- Description:	  Pre Process Agency Data (
--			  Assigns client codes not associated with a MasterCustNo
--			  to the 'UNKNOWN' MasterCustno
--			  Needs to be saved and run from customer database
--			  This procedure calls a remote procedure on the processing server		
--			  Database and Process servers must be linked with RPC true, RPC Out = true
--			  Arguments for Customer information are hardcoded below
--                      set @Server as the processing server
--                      set @Prog with argumments for database servers
-- Modified:		   Charlie B 2013-02-09
--			   Changed ACMI.POSCountry field
--			   Updated OnlineFlag query
--			   Updated as generic (now grabs values from ACMDatabases/DRA)
-- ==========================================================================================
CREATE PROCEDURE [dbo].[sp_ACMPreProcess_Agency] @ImportDate DATETIME = NULL
AS
BEGIN
	DECLARE @LocalImportDate DATETIME

	SELECT @LocalImportDate = @ImportDate

	--  Update CustRollUp (adds Unknown Master for new/undefined clientcodes)
	INSERT INTO dba.CustRollup (
		AgencyIataNum
		,CustNo
		,MasterCustNo
		)
	SELECT IH.IataNum
		,IH.ClientCode
		,'UNKNOWN'
	FROM dba.InvoiceHeader IH
	LEFT OUTER JOIN dba.CustRollup CRoll ON (
			IH.IataNum = CRoll.AgencyIataNum
			AND IH.ClientCode = CRoll.CustNo
			)
	WHERE IH.IataNum NOT LIKE 'Pre%'
	GROUP BY IH.IataNum
		,IH.ClientCode
		,CRoll.CustNo
	HAVING CRoll.CustNo IS NULL

	-- Set Variables
	--  DECLARE @LocalImportDate datetime
	DECLARE @CustomerID VARCHAR(30)
	DECLARE @ClientRequestName VARCHAR(20)
	DECLARE @Contract VARCHAR(30)
	DECLARE @ContractCarrier VARCHAR(50)
	DECLARE @Server VARCHAR(50)
	DECLARE @User VARCHAR(100)
	DECLARE @Pword VARCHAR(100)
	DECLARE @RemoteArgs VARCHAR(500)
	DECLARE @Prod_Server VARCHAR(50)
	DECLARE @Prod_Database VARCHAR(50)
	DECLARE @Process_Server VARCHAR(50)
	DECLARE @ACMProcessor VARCHAR(500)
	DECLARE @ProcessArgs VARCHAR(500)
	DECLARE @Iata VARCHAR(50);
	DECLARE @ProcName VARCHAR(50);
	DECLARE @TransStart DATETIME;
	DECLARE @BeginIssueDate DATETIME;
	DECLARE @ENDIssueDate DATETIME;

	--  Set Import Date 
	IF @LocalImportDate IS NULL
	BEGIN
		SET @LocalImportDate = (
				SELECT max(ImportDt)
				FROM DBA.InvoiceHeader
				WHERE IataNum NOT LIKE 'PRE%'
				)
	END

	--  Set arguments to run autoprocessor for this client
	SET @CustomerID = (
			SELECT min(DRA.CustomerID)
			FROM dba.InvoiceHeader IH
				,ttxpaSQL09.TMAN503_REPORTS_ACM.dba.DRA DRA
			WHERE IataNum = ETLRequestName
				AND IH.ImportDt = @LocalImportDate
			)
	SET @Prod_Server = (
			SELECT ServerName
			FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases
			WHERE CustomerID = @CustomerID
				AND DatabaseCategory = 'PROD'
			)
	SET @Prod_Database = (
			SELECT DatabaseName
			FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases
			WHERE CustomerID = @CustomerID
				AND DatabaseCategory = 'PROD'
			)
	SET @Process_Server = (
			SELECT ProcessServer
			FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases
			WHERE CustomerID = @CustomerID
				AND DatabaseCategory = 'PROD'
			)
	SET @Process_Server = (
			SELECT '\\' + @Process_Server + '.TRXFS.TRX.COM'
			)
	SET @ACMProcessor = 'c:\ProcessACM\ProcessContracts.exe'
	SET @ProcessArgs = (
			SELECT '-TV5 -ID' + substring(convert(VARCHAR, @LocalImportDate, 111), 6, 15) + '/' + substring(convert(VARCHAR, @LocalImportDate, 111), 1, 4) + ' -IT' + substring(convert(VARCHAR, @LocalImportDate, 120), 12, 8)
			+ ' -CCFCM'
--			+ ' -DWTRUE'
--			+ ' -CS' + DataDSN + ' -TS' + ACMTermsDSN
			FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases
			WHERE CustomerID = @CustomerID
				AND DatabaseCategory = 'PROD'
			)
	SET @User = N'wtpdh\smsservice'
	SET @Pword = N'melanie'
	SET @Iata = 'FCMACM'
	SET @ProcName = CONVERT(VARCHAR(50), OBJECT_NAME(@@PROCID))
	/************************************************************************
    Delete data for re-processing  (ContractRmks and ACMInfo only)
*************************************************************************/
	SET @TransStart = GETDATE()

	DELETE ACRmks
	FROM dba.ContractRmks ACRmks
		,dba.InvoiceHeader IH
	WHERE ACRmks.Recordkey = IH.RecordKey
		AND ACRmks.IataNum = IH.IataNum
		AND IH.ImportDT = @LocalImportDate

	DELETE ACMI
	FROM dba.ACMInfo ACMI
		,dba.InvoiceHeader IH
	WHERE ACMI.Recordkey = IH.RecordKey
		AND ACMI.IataNum = IH.IataNum
		AND IH.ImportDT = @LocalImportDate

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '1-Delete ACRmks-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
    Update Transeg with Operating Carrier Code / Fare Basis / 
	Update InvoiceDetail Vendortype and ProductType for unidentified
*************************************************************************/
	SET @TransStart = GETDATE()

	UPDATE TS
	SET CodeshareCarrierCode = SegmentCarrierCode
	FROM dba.TranSeg TS
		,dba.InvoiceHeader IH
	WHERE IH.RecordKey = TS.RecordKey
		AND IH.IataNum = TS.IataNum
		AND IH.ImportDt = @LocalImportDate
		AND CodeshareCarrierCode IS NULL

	UPDATE TS
	SET FareBasis = left(ClassOfService, 1)
	FROM dba.Transeg TS
		,dba.InvoiceHeader IH
	WHERE IH.RecordKey = TS.RecordKey
		AND IH.IataNum = TS.IataNum
		AND IH.ImportDt = @LocalImportDate
		AND FareBasis IS NULL

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '2-Update TS-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
  Load ACMInfo table  ( note - this sets the ImportDt in ACMInfo)
*************************************************************************/
	SET @TransStart = GETDATE()

	INSERT INTO dba.ACMInfo (
		RecordKey
		,IataNum
		,SeqNum
		,SegmentNum
		,ClientCode
		,InvoiceDate
		,IssueDate
		,InterlineFlag
		,RouteType
		,POSCountry
		,DepartureDate
		,ImportDt
		,MinOpCarrierCode
		)
	SELECT TS.RecordKey
		,TS.IataNum
		,TS.SeqNum
		,TS.SegmentNum
		,TS.ClientCode
		,TS.InvoiceDate
		,TS.IssueDate
		,'Y'
		,'O'
		,left(IH.OrigCountry, 2)
		,TS.DepartureDate
		,IH.ImportDt
		,isnull(CodeShareCarrierCode, MinSegmentCarrierCode)
	FROM DBA.Transeg TS
		,DBA.InvoiceDetail ID
		,DBA.InvoiceHeader IH
	WHERE TS.MINDestCityCode IS NOT NULL
		AND ID.RecordKey = TS.RecordKey
		AND ID.Iatanum = TS.IataNum
		AND ID.SeqNum = TS.SeqNum
		AND IH.RecordKey = TS.RecordKey
		AND IH.Iatanum = TS.IataNum
		AND IH.RecordKey = ID.RecordKey
		AND IH.Iatanum = ID.IataNum
		AND TS.IssueDate = ID.IssueDate
		AND (
			ID.Vendortype IN (
				'BSP'
				,'NONBSP'
				,'BSPSTC'
				,'NONBSPSTC'
				,'RAIL'
				)
			OR ID.Vendortype = 'NONAIR'
			AND isnull(Producttype, 'UNKNOWN') IN (
				'RAIL'
				,'AIR'
				,'UNKNOWN'
				)
			)
		AND ID.VoidInd = 'N'
		AND IH.ImportDt = @LocalImportDate

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '3-Insert ACMInfo-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
  Set Route Type
*************************************************************************/
	SET @TransStart = GETDATE()

	--  Set Outbound
	UPDATE ACMI
	SET ACMI.RouteType = 'R'
	FROM dba.ACMInfo ACMI
		,dba.TranSeg TS
		,dba.TranSeg TS2
	WHERE ACMI.RecordKey = TS.RecordKey
		AND ACMI.IataNum = TS.IataNum
		AND ACMI.SeqNum = TS.SeqNum
		AND ACMI.SegmentNum = TS.SegmentNum
		AND TS.RecordKey = TS2.RecordKey
		AND TS.IataNum = TS2.IataNum
		AND TS.SeqNum = TS2.SeqNum
		AND TS2.SegmentNum > TS.SegmentNum
		AND TS.OriginCityCode = TS2.MinDestCityCode
		AND TS.MinDestCityCode = TS2.OriginCityCode
		AND ACMI.ImportDt = @LocalImportDate

	-- Flags Inbound Segment
	UPDATE ACMI
	SET ACMI.RouteType = 'R'
	FROM dba.ACMInfo ACMI
		,dba.TranSeg TS
		,dba.TranSeg TS2
	WHERE ACMI.RecordKey = TS2.RecordKey
		AND ACMI.IataNum = TS2.IataNum
		AND ACMI.SeqNum = TS2.SeqNum
		AND ACMI.SegmentNum = TS2.SegmentNum
		AND TS.RecordKey = TS2.RecordKey
		AND TS.IataNum = TS2.IataNum
		AND TS.SeqNum = TS2.SeqNum
		AND TS2.SegmentNum > TS.SegmentNum
		AND TS.OriginCityCode = TS2.MinDestCityCode
		AND TS.MinDestCityCode = TS2.OriginCityCode
		AND ACMI.ImportDt = @LocalImportDate

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '4-Set Route-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
    Set Interline Flag
*************************************************************************/
	SET @TransStart = GETDATE()

	UPDATE ACMI
	SET InterlineFlag = 'N'
	FROM dba.ACMInfo ACMI
	WHERE ACMI.ImportDt = @LocalImportDate
		AND RecordKey + IataNum + convert(CHAR, Seqnum) IN (
			SELECT DISTINCT TS.RecordKey + TS.IataNum + convert(CHAR, TS.Seqnum)
			FROM dba.ACMInfo ACMI --WITH (INDEX (ACMInfoI1))
			INNER JOIN dba.TranSeg TS WITH (INDEX (TransegI1)) ON (
					TS.RecordKey = ACMI.RecordKey
					AND TS.IataNum = ACMI.IataNum
					AND TS.SeqNum = ACMI.SeqNum
					AND TS.SegmentNum = ACMI.SegmentNum
					)
			WHERE ACMI.ImportDt = @LocalImportDate
			GROUP BY TS.RecordKey + TS.IataNum + convert(CHAR, TS.Seqnum)
			HAVING min(SegmentCarrierCode) = Max(SegmentCarrierCode)
			)

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '5-Set Interline-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
    Set FMS Fields for O & D and Long Haul Segment (of O&D)
*************************************************************************/
	SET @TransStart = GETDATE()

	--  O & D FMS - FlownCarrier/QSI/DepartureDate
	UPDATE ACMI
	SET ACMI.MINFMS = QSI.FMS
	FROM dba.TranSeg TS
		,dba.QSI QSI
		,dba.ACMInfo ACMI
	WHERE TS.MINMktOrigCityCode = QSI.ORIG
		AND TS.MINMktDestCityCode = QSI.DEST
		AND TS.MINSegmentCarrierCode = QSI.Airline
		AND ACMI.DepartureDate BETWEEN QSI.BeginDate
			AND QSI.EndDate
		AND TS.DepartureDate BETWEEN QSI.BeginDate
			AND QSI.EndDate
		AND ACMI.RecordKey = TS.RecordKey
		AND ACMI.IataNum = TS.IataNum
		AND ACMI.SeqNum = TS.SeqNum
		AND ACMI.SegmentNum = TS.SegmentNum
		AND ACMI.ImportDt = @LocalImportDate

	--  O & D FMS - FlownCarrier/QSI/IssueDate
	UPDATE ACMI
	SET ACMI.MINFMS = QSI.FMS
	FROM dba.TranSeg TS
		,dba.QSI QSI
		,dba.ACMInfo ACMI
	WHERE TS.MINMktOrigCityCode = QSI.ORIG
		AND TS.MINMktDestCityCode = QSI.DEST
		AND TS.MINSegmentCarrierCode = QSI.Airline
		AND ACMI.IssueDate BETWEEN QSI.BeginDate
			AND QSI.EndDate
		AND TS.IssueDate BETWEEN QSI.BeginDate
			AND QSI.EndDate
		AND ACMI.RecordKey = TS.RecordKey
		AND ACMI.IataNum = TS.IataNum
		AND ACMI.SeqNum = TS.SeqNum
		AND ACMI.SegmentNum = TS.SegmentNum
		AND ACMI.MINFMS IS NULL
		AND ACMI.ImportDt = @LocalImportDate

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '6-Set O and D-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
    Set DiscountedFare - Old Exchange Method
*************************************************************************/
	SET @TransStart = GETDATE()

	--  Set Discounted fare = MinSegmentValue
	UPDATE ACMI
	SET DiscountedFare = MinSegmentValue
	FROM dba.acminfo acmi
		,dba.transeg ts
	WHERE ACMI.RecordKey = TS.RecordKey
		AND ACMI.IataNum = TS.IataNum
		AND ACMI.SeqNum = TS.SeqNum
		AND ACMI.SegmentNum = TS.SegmentNum
		AND ACMI.ImportDt = @LocalImportDate

	--  Set DiscountedFare = Prorated base fare when sum of SegmentValue <> ticket price
	UPDATE ACMI
	SET DiscountedFare = TS.MINSegmentMileage / TS.MINTotalMileage * isnull(ID.InvoiceAmt, 0)
	FROM dba.TranSeg TS
		,dba.ACMInfo ACMI
		,dba.InvoiceDetail ID
	WHERE TS.RecordKey = ACMI.RecordKey
		AND TS.IataNum = ACMI.Iatanum
		AND TS.SeqNum = ACMI.SeqNum
		AND TS.SegmentNum = ACMI.SegmentNum
		AND TS.RecordKey = ID.RecordKey
		AND TS.IataNum = ID.Iatanum
		AND TS.SeqNum = ID.SeqNum
		AND ACMI.ImportDt = @LocalImportDate
		AND ACMI.RecordKey IN (
			SELECT DISTINCT ACMI.RecordKey
			FROM dba.acminfo ACMI
				,dba.InvoiceDetail ID
			WHERE ACMI.RecordKey = ID.RecordKey
				AND ACMI.IataNum = ID.IataNum
				AND ACMI.SeqNum = ID.SeqNum
				AND ACMI.ImportDt = @LocalImportDate
			GROUP BY ACMI.RecordKey
				,round(ID.InvoiceAmt, 0)
			HAVING round(ID.InvoiceAmt, 0) <> Round(sum(isnull(ACMI.DiscountedFare, 0)), 0)
			)

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '7-Set Discounted fare-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
    Insert ContractRmk records
*************************************************************************/
	SET @TransStart = GETDATE()

	INSERT INTO dba.ContractRmks (
		RecordKey
		,IataNum
		,SeqNum
		,SegmentNum
		,ClientCode
		,InvoiceDate
		,IssueDate
		,ContractID
		,RouteType
		,DiscountedFare
		,MINOpCarrierCode
		,InterlineInd
		,POSCountry
		,OnlineFlag
		,DepartureDate
		)
	SELECT ACMI.RecordKey
		,ACMI.IataNum
		,ACMI.SeqNum
		,ACMI.SegmentNum
		,ACMI.ClientCode
		,ACMI.InvoiceDate
		,ACMI.IssueDate
		,AC.ContractName
		,ACMI.RouteType
		,ACMI.DiscountedFare
		,ACMI.MINOpCarrierCode
		,ACMI.InterlineFlag
		,ACMI.POSCountry
		,'N'
		,ACMI.DepartureDate
	FROM dba.AirlineContracts AC
		,dba.ACMInfo ACMI
		,dba.CustRollUp CRoll
	WHERE CRoll.MasterCustNo = AC.CustomerID
		AND CRoll.AgencyIataNum = ACMI.IataNum
		AND CRoll.CustNo = ACMI.ClientCode
		AND ACMI.ImportDt = @LocalImportDate
		AND ACMI.IssueDate BETWEEN (
					SELECT Min(ACG.GoalBeginDate)
					FROM dba.AirlineContractGoals ACG
					WHERE ACG.ContractNumber = AC.ContractNumber
					)
			AND (
					SELECT Max(ACG.GoalEndDate)
					FROM dba.AirlineContractGoals ACG
					WHERE ACG.ContractNumber = AC.ContractNumber
					)
		AND ACMI.DepartureDate BETWEEN (
					SELECT Min(ACG.TravelBeginDate)
					FROM dba.AirlineContractGoals ACG
					WHERE ACG.ContractNumber = AC.ContractNumber
					)
			AND (
					SELECT Max(ACG.TravelEndDate)
					FROM dba.AirlineContractGoals ACG
					WHERE ACG.ContractNumber = AC.ContractNumber
					)

	--#50685		        and ACMI.RecordKey not in (select recordkey from dba.ContractRmks where iatanum='fcmacm'
	--				    and invoicedate>='2014-10-01')
	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '8-Set Contract Remarks-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	/************************************************************************
    Set Online Flag - contract carrier is the first airline in 
    the contractcarriercodes field of in AirlineContracts table
*************************************************************************/
	SET @TransStart = GETDATE()

	UPDATE ACRmks
	SET OnlineFlag = 'Y'
	FROM dba.ContractRmks ACRmks
		,dba.TranSeg TS
		,dba.QSI QSI
		,dba.InvoiceHeader IH
		,dba.AirlineContracts AC
	WHERE TS.RecordKey = ACRmks.RecordKey
		AND TS.IataNum = ACRmks.IataNum
		AND TS.SeqNum = ACRmks.SeqNum
		AND TS.SegmentNum = ACRmks.SegmentNum
		AND TS.RecordKey = IH.RecordKey
		AND TS.IataNum = IH.IataNum
		AND ACRmks.RecordKey = IH.RecordKey
		AND ACRmks.IataNum = IH.IataNum
		AND ACRmks.ContractID = AC.ContractName
		AND TS.MinMktOrigCityCode = QSI.Orig
		AND TS.MinMktDestCityCode = QSI.Dest
		AND TS.IssueDate BETWEEN QSI.BeginDate
			AND QSI.EndDate
		AND Charindex(QSI.Airline, AC.ContractCarrierCodes) > 0
		AND IH.ImportDt = @LocalImportDate

	UPDATE ACRmks
	SET OnlineFlag = 'N'
	FROM dba.ContractRmks ACRmks
		,dba.InvoiceHeader IH
	WHERE IH.RecordKey = ACRmks.RecordKey
		AND IH.IataNum = ACRmks.IataNum
		AND ACRmks.OnlineFlag IS NULL
		AND IH.ImportDt = @LocalImportDate

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '9-Set Online Flag-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	--  Update ACM Transaction Log    
	SET @TransStart = GETDATE()

	INSERT INTO ttxpaSQL09.TMAN503_Reports_ACM.dba.ACMProcessedTransactions
	SELECT @Prod_Server
		,@Prod_Database
		,IataNum
		,ImportDt
		,MasterCustNo
		,min(issuedate)
		,max(issuedate)
		,count(DISTINCT recordkey)
		,Sum(1)
	FROM dba.ACMInfo
		,dba.CustRollup
	WHERE agencyiatanum = iatanum
		AND custno = clientcode
		AND ImportDt = @LocalImportDate
	GROUP BY IataNum
		,MasterCustNo
		,ImportDt

	EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
		,@LogStart = @TransStart
		,@StepName = '10-Update ACM Log-'
		,@BeginDate = @LocalImportDate
		,@EndDate = @LocalImportDate
		,@IataNum = @Iata
		,@RowCount = @@ROWCOUNT
		,@ERR = @@ERROR;

	--  Execute SP to run ProcessContracts.exe - Runs on ttxsaSQL03 - Processes on ATL591 for database DSN specified
	SET @TransStart = GETDATE()

	DECLARE @return_value INT

	EXEC @return_value = ttxsaSQL03.server_Administration.dbo.sp_ExecuteACMProcessor 
		@RemoteBatch = @ACMProcessor
		,@RemoteServer = @Process_Server
		,@RemoteUser = @User
		,@RemotePword = @Pword
		,@RemoteArgs = @ProcessArgs

	SELECT 'Return Value' = @return_value
END

EXEC dbo.sp_LogProcErrors @ProcedureName = @ProcName
	,@LogStart = @TransStart
	,@StepName = '11-Execute sp on ACM Processor-'
	,@BeginDate = @LocalImportDate
	,@EndDate = @LocalImportDate
	,@IataNum = @Iata
	,@RowCount = @@ROWCOUNT
	,@ERR = @@ERROR;



GO
