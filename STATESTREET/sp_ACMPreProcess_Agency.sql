/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='ACMProcessedTransactions' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_REPORTS_ACM']/UnresolvedEntity[@Name='ACMDatabases' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxsaSQL03']/Database[@Name='server_Administration']/UnresolvedEntity[@Name='sp_ExecuteACMProcessor' and @Schema='dbo'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_REPORTS_ACM']/UnresolvedEntity[@Name='DRA' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_ACMPreProcess_Agency]    Script Date: 7/7/2015 3:58:16 PM ******/
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
	--  DECLARE @ImportDate datetime
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

	--  Set Import Date 
	IF @ImportDate IS NULL
	BEGIN
		SET @ImportDate = (
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
				AND IH.ImportDt = @ImportDate
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
			SELECT '-TV5 -ID' + substring(convert(VARCHAR, @ImportDate, 111), 6, 15) + '/' + substring(convert(VARCHAR, @ImportDate, 111), 1, 4) + ' -IT' + substring(convert(VARCHAR, @ImportDate, 120), 12, 8)
			+ ' -CCStateStreet'
--			+ ' -CS' + DataDSN + ' -TS' + ACMTermsDSN 
--			+ ' -DWTRUE'
			FROM ttxpaSQL09.TMAN503_REPORTS_ACM.dba.ACMDatabases
			WHERE CustomerID = @CustomerID
				AND DatabaseCategory = 'PROD'
			)
	SET @User = N'wtpdh\smsservice'
	SET @Pword = N'melanie'

	/************************************************************************
    Delete data for re-processing  (ContractRmks and ACMInfo only)
*************************************************************************/
	DELETE ACRmks
	FROM dba.ContractRmks ACRmks
		,dba.InvoiceHeader IH
	WHERE ACRmks.Recordkey = IH.RecordKey
		AND ACRmks.IataNum = IH.IataNum
		AND IH.ImportDT = @ImportDate

	DELETE ACMI
	FROM dba.ACMInfo ACMI
		,dba.InvoiceHeader IH
	WHERE ACMI.Recordkey = IH.RecordKey
		AND ACMI.IataNum = IH.IataNum
		AND IH.ImportDT = @ImportDate

	/************************************************************************
    Update Transeg with Operating Carrier Code / Fare Basis / 
	Update InvoiceDetail Vendortype and ProductType for unidentified
*************************************************************************/
	UPDATE TS
	SET CodeshareCarrierCode = SegmentCarrierCode
	FROM dba.TranSeg TS
		,dba.InvoiceHeader IH
	WHERE IH.RecordKey = TS.RecordKey
		AND IH.IataNum = TS.IataNum
		AND IH.ImportDt = @ImportDate
		AND CodeshareCarrierCode IS NULL

	UPDATE TS
	SET FareBasis = left(ClassOfService, 1)
	FROM dba.Transeg TS
		,dba.InvoiceHeader IH
	WHERE IH.RecordKey = TS.RecordKey
		AND IH.IataNum = TS.IataNum
		AND IH.ImportDt = @ImportDate
		AND FareBasis IS NULL

	/************************************************************************
  Load ACMInfo table  ( note - this sets the ImportDt in ACMInfo)
*************************************************************************/
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
		AND IH.ImportDt = @ImportDate

	/************************************************************************
  Set Route Type
*************************************************************************/
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
		AND ACMI.ImportDt = @ImportDate

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
		AND ACMI.ImportDt = @ImportDate

	/************************************************************************
    Set Interline Flag
*************************************************************************/
	UPDATE ACMI
	SET InterlineFlag = 'N'
	FROM dba.ACMInfo ACMI
	WHERE ACMI.ImportDt = @ImportDate
		AND RecordKey + IataNum + convert(CHAR, Seqnum) IN (
			SELECT DISTINCT TS.RecordKey + TS.IataNum + convert(CHAR, TS.Seqnum)
			FROM dba.TranSeg TS
				,dba.ACMInfo ACMI
			WHERE TS.RecordKey = ACMI.RecordKey
				AND TS.IataNum = ACMI.IataNum
				AND TS.SeqNum = ACMI.SeqNum
				AND TS.SegmentNum = ACMI.SegmentNum
				AND ACMI.ImportDt = @ImportDate
			GROUP BY TS.RecordKey + TS.IataNum + convert(CHAR, TS.Seqnum)
			HAVING min(SegmentCarrierCode) = Max(SegmentCarrierCode)
			)

	/************************************************************************
    Set FMS Fields for O & D and Long Haul Segment (of O&D)
*************************************************************************/
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
		AND ACMI.ImportDt = @ImportDate

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
		AND ACMI.ImportDt = @ImportDate

	/************************************************************************
    Set DiscountedFare - Old Exchange Method
*************************************************************************/
	--  Set Discounted fare = MinSegmentValue
	UPDATE ACMI
	SET DiscountedFare = MinSegmentValue
	FROM dba.acminfo acmi
		,dba.transeg ts
	WHERE ACMI.RecordKey = TS.RecordKey
		AND ACMI.IataNum = TS.IataNum
		AND ACMI.SeqNum = TS.SeqNum
		AND ACMI.SegmentNum = TS.SegmentNum
		AND ACMI.ImportDt = @ImportDate

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
		AND ACMI.ImportDt = @ImportDate
		AND ACMI.RecordKey IN (
			SELECT DISTINCT ACMI.RecordKey
			FROM dba.acminfo ACMI
				,dba.InvoiceDetail ID
			WHERE ACMI.RecordKey = ID.RecordKey
				AND ACMI.IataNum = ID.IataNum
				AND ACMI.SeqNum = ID.SeqNum
				AND ACMI.ImportDt = @ImportDate
			GROUP BY ACMI.RecordKey
				,round(ID.InvoiceAmt, 0)
			HAVING round(ID.InvoiceAmt, 0) <> Round(sum(isnull(ACMI.DiscountedFare, 0)), 0)
			)

	/************************************************************************
    Insert ContractRmk records
*************************************************************************/
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
		AND ACMI.ImportDt = @ImportDate
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

	/************************************************************************
    Set Online Flag - contract carrier is the first airline in 
    the contractcarriercodes field of in AirlineContracts table
*************************************************************************/
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
		AND IH.ImportDt = @ImportDate

	UPDATE ACRmks
	SET OnlineFlag = 'N'
	FROM dba.ContractRmks ACRmks
		,dba.InvoiceHeader IH
	WHERE IH.RecordKey = ACRmks.RecordKey
		AND IH.IataNum = ACRmks.IataNum
		AND ACRmks.OnlineFlag IS NULL
		AND IH.ImportDt = @ImportDate

	UPDATE ACMI
	SET CustomerID = CRoll.MasterCustNo
	FROM dba.ACMInfo ACMI
		,dba.CustRollUp CRoll
	WHERE CRoll.AgencyIataNum = ACMI.IataNum
		AND CRoll.CustNo = ACMI.ClientCode

/*	  Update ACM Transaction Log     */

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
		AND ImportDt = @ImportDate
	GROUP BY IataNum
		,MasterCustNo
		,ImportDt

/*		  Execute SP to run ProcessContracts.exe - Runs on ttxsaSQL03 - Processes on ATL591 for database DSN specified */

		DECLARE	@return_value int
		   EXEC	@return_value = ttxsaSQL03.server_Administration.dbo.sp_ExecuteACMProcessor
				  @RemoteBatch = @ACMProcessor,
				  @RemoteServer = @Process_Server,
				  @RemoteUser = @User,
				  @RemotePword = @Pword,
				  @RemoteArgs = @ProcessArgs
		SELECT	'Return Value' = @return_value
END



GO

ALTER AUTHORIZATION ON [dbo].[sp_ACMPreProcess_Agency] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ACMInfo]    Script Date: 7/7/2015 3:58:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ACMInfo](
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
	[Commission] [float] NULL,
	[ProcEndDate] [datetime] NULL,
	[DiscountID] [int] NULL,
	[GoalID] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ACMInfo] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 3:58:24 PM ******/
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

/****** Object:  Table [dba].[QSI]    Script Date: 7/7/2015 3:58:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[QSI](
	[Airline] [varchar](3) NOT NULL,
	[BeginDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Orig] [varchar](3) NOT NULL,
	[Dest] [varchar](3) NOT NULL,
	[QSI] [float] NULL,
	[FMS] [float] NULL,
	[FMSCS] [float] NULL,
	[CustomerID] [varchar](30) NULL,
	[Contracts] [varchar](50) NULL,
	[Target] [float] NULL,
	[Allowance] [float] NULL,
	[MarketNote] [varchar](50) NULL,
	[LoadFile] [varchar](6) NULL,
	[NonStopCrr] [varchar](50) NULL,
	[MaxFMS] [float] NULL,
	[AMS] [float] NULL,
	[MaxAMS] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[QSI] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 3:58:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[InvoiceHeader](
	[RecordKey] [varchar](100) NOT NULL,
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
	[CCCode] [varchar](6) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[InvoiceHeader] ADD [CCExp] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CCApprovalCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [GDSCode] [varchar](10) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [BackOfficeID] [varchar](20) NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [IMPORTDT] [datetime] NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [TtlCO2Emissions] [float] NULL
ALTER TABLE [dba].[InvoiceHeader] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[InvoiceHeader] ADD [CCLastFour] [varchar](4) NULL
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

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 3:58:46 PM ******/
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
	[ClientCode] [varchar](15) NULL,
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
	[OriginalInvoiceNum] [varchar](15) NULL,
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

/****** Object:  Table [dba].[CustRollup]    Script Date: 7/7/2015 3:59:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CustRollup](
	[AgencyIATANum] [varchar](8) NULL,
	[MasterCustNo] [varchar](15) NULL,
	[CustNo] [varchar](15) NULL,
	[CustName] [varchar](40) NULL,
	[FeeInd] [varchar](1) NULL,
	[YieldInd] [varchar](1) NULL,
	[StartDate] [datetime] NULL,
	[SalesAgent] [varchar](40) NULL,
	[PaymentType] [varchar](7) NULL,
	[FeeIfUnderAmt] [float] NULL,
	[CreditCardNum] [varchar](25) NULL,
	[CreditCardExpdate] [varchar](7) NULL,
	[DefaultFee] [varchar](2) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CustRollup] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ContractRmks]    Script Date: 7/7/2015 3:59:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ContractRmks](
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
	[FarePct] [float] NULL,
	[Zone1Fare] [float] NULL,
	[Zone2Fare] [float] NULL,
	[Zone3Fare] [float] NULL,
	[Zone4Fare] [float] NULL,
	[Zone5Fare] [float] NULL,
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
	[Target] [float] NULL,
	[OnlineFlag] [char](1) NULL,
	[POSCountry] [varchar](50) NULL,
	[ContractCarrierFlag] [char](1) NULL,
	[MinOpCarrierCode] [varchar](50) NULL,
	[InterlineFlag] [char](1) NULL,
	[DiscountID] [int] NULL,
	[GoalID] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ContractRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContracts]    Script Date: 7/7/2015 3:59:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContracts](
	[ContractNumber] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [varchar](30) NOT NULL,
	[ContractName] [varchar](30) NOT NULL,
	[AirlineName] [varchar](50) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[ContractExtension] [datetime] NULL,
	[CustomerType] [varchar](2) NOT NULL,
	[ContractSignedDate] [datetime] NULL,
	[Description] [varchar](100) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[Approved] [bit] NULL,
	[Notes] [varchar](1000) NULL,
	[Status] [char](1) NULL,
	[Processed] [char](1) NULL,
	[ContractCarrierCodes] [varchar](255) NULL,
	[MeasureGoalsOnDate] [char](1) NULL,
	[MeasurePayOnDate] [char](1) NULL,
	[GoalMeasurementPeriod] [char](1) NULL,
	[PayMeasurementPeriod] [char](1) NULL,
	[TourCode] [varchar](255) NULL,
	[CreatedBy] [varchar](30) NULL,
	[CreatedDate] [datetime] NULL,
	[ApprovedBy] [varchar](30) NULL,
	[ApprovedDate] [datetime] NULL,
	[ProcessedDate] [datetime] NULL,
	[ContractType] [varchar](30) NULL,
	[Round] [int] NULL,
	[ProcessingStatus] [char](1) NULL,
 CONSTRAINT [PK_AirlineContracts] PRIMARY KEY CLUSTERED 
(
	[ContractNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContracts] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[AirlineContractGoals]    Script Date: 7/7/2015 3:59:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[AirlineContractGoals](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [int] NOT NULL,
	[ExhibitNumber] [int] NULL,
	[MarketNumber] [int] NULL,
	[GoalNumber] [int] NULL,
	[Status] [char](1) NULL,
	[GoalValue] [float] NULL,
	[Discount] [float] NULL,
	[DiscountType] [char](1) NULL,
	[Target] [float] NULL,
	[Allowance] [float] NULL,
	[GoalBeginDate] [datetime] NULL,
	[GoalEndDate] [datetime] NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[TravelBeginDate] [datetime] NULL,
	[TravelEndDate] [datetime] NULL,
	[CurrCode] [varchar](3) NULL,
	[Description] [varchar](200) NULL,
	[ClassOfServiceOperand] [char](1) NULL,
	[ClassOfService] [varchar](255) NULL,
	[FareBasisOperand] [char](1) NULL,
	[FareBasis] [varchar](2000) NULL,
	[TourCode] [varchar](255) NULL,
	[TicketDesignator] [varchar](15) NULL,
	[FlightNumberOperand] [char](1) NULL,
	[FlightNumber] [varchar](2000) NULL,
	[OWMinFare] [float] NULL,
	[RTMinFare] [float] NULL,
	[OvernightRqd] [char](1) NULL,
	[SatNightRqd] [char](1) NULL,
	[ValidDaysOperand] [char](1) NULL,
	[ValidDays] [varchar](20) NULL,
	[DaysAdv] [int] NULL,
	[MinimumStay] [int] NULL,
	[GoalType] [char](1) NULL,
	[ProcessLevel] [char](1) NULL,
	[ValidatingCarriersOperand] [char](1) NULL,
	[ValidatingCarriers] [varchar](255) NULL,
	[OperatingCarriersOperand] [char](1) NULL,
	[OperatingCarriers] [varchar](255) NULL,
	[InterlineInd] [char](1) NULL,
	[MinimumQSI] [float] NULL,
	[FlownCarriersOperand] [char](1) NULL,
	[FlownCarriers] [varchar](255) NULL,
	[RouteType] [varchar](2) NULL,
	[ConnectionInd] [varchar](2) NULL,
	[DirectionalInd] [char](1) NULL,
	[ConnectingAirlineOperand] [char](1) NULL,
	[ConnectingAirline] [varchar](2000) NULL,
	[OnlineInd] [char](1) NULL,
	[CaseTier] [int] NULL,
	[DaysAdv2] [varchar](30) NULL,
 CONSTRAINT [PK_AirlineContractGoals] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[AirlineContractGoals] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI1]    Script Date: 7/7/2015 3:59:29 PM ******/
CREATE CLUSTERED INDEX [ACMInfoI1] ON [dba].[ACMInfo]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 3:59:29 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [QSI_PX]    Script Date: 7/7/2015 3:59:29 PM ******/
CREATE UNIQUE CLUSTERED INDEX [QSI_PX] ON [dba].[QSI]
(
	[BeginDate] ASC,
	[Orig] ASC,
	[Dest] ASC,
	[Airline] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 3:59:30 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 3:59:31 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CustRollupPX]    Script Date: 7/7/2015 3:59:31 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CustRollupPX] ON [dba].[CustRollup]
(
	[MasterCustNo] ASC,
	[CustNo] ASC,
	[AgencyIATANum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

/****** Object:  Index [ACMInfoI2]    Script Date: 7/7/2015 3:59:31 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI2] ON [dba].[ACMInfo]
(
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI3]    Script Date: 7/7/2015 3:59:32 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI3] ON [dba].[ACMInfo]
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

/****** Object:  Index [ACMInfoI4]    Script Date: 7/7/2015 3:59:33 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI4] ON [dba].[ACMInfo]
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

/****** Object:  Index [ACMInfoI5]    Script Date: 7/7/2015 3:59:34 PM ******/
CREATE NONCLUSTERED INDEX [ACMInfoI5] ON [dba].[ACMInfo]
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

/****** Object:  Index [ACMInfoPX]    Script Date: 7/7/2015 3:59:35 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ACMInfoPX] ON [dba].[ACMInfo]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ACMINFO_IMPORTDT]    Script Date: 7/7/2015 3:59:35 PM ******/
CREATE NONCLUSTERED INDEX [IX_ACMINFO_IMPORTDT] ON [dba].[ACMInfo]
(
	[ImportDt] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[InvoiceDate],
	[IssueDate],
	[DepartureDate],
	[DiscountedFare],
	[POSCountry],
	[RouteType],
	[InterlineFlag],
	[MINOpCarrierCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_QSI_AIRLINE_ORIG_DEST_QSI_FMS]    Script Date: 7/7/2015 3:59:37 PM ******/
CREATE NONCLUSTERED INDEX [IX_QSI_AIRLINE_ORIG_DEST_QSI_FMS] ON [dba].[QSI]
(
	[Airline] ASC,
	[Orig] ASC,
	[Dest] ASC,
	[QSI] ASC,
	[FMS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_QSI_ORIG_DEST_BEGINDATE_ENDDATE]    Script Date: 7/7/2015 3:59:37 PM ******/
CREATE NONCLUSTERED INDEX [IX_QSI_ORIG_DEST_BEGINDATE_ENDDATE] ON [dba].[QSI]
(
	[Orig] ASC,
	[Dest] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)
INCLUDE ( 	[Airline],
	[FMS]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [QSII1]    Script Date: 7/7/2015 3:59:38 PM ******/
CREATE NONCLUSTERED INDEX [QSII1] ON [dba].[QSI]
(
	[Orig] ASC,
	[Dest] ASC,
	[FMS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/7/2015 3:59:38 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC,
	[IataNum] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 3:59:39 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_INVOICEHEADER_RECORDKEY_IATANUM_CLIENTCODE]    Script Date: 7/7/2015 3:59:40 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_RECORDKEY_IATANUM_CLIENTCODE] ON [dba].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[ClientCode] ASC
)
INCLUDE ( 	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/7/2015 3:59:40 PM ******/
CREATE NONCLUSTERED INDEX [IDExchProc_I1] ON [dba].[InvoiceDetail]
(
	[VoidInd] ASC,
	[ExchangeInd] ASC,
	[VendorType] ASC
)
INCLUDE ( 	[ClientCode],
	[DocumentNumber],
	[IataNum],
	[IssueDate],
	[RecordKey],
	[SeqNum],
	[TicketGroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [INvoiceDetailI2]    Script Date: 7/7/2015 3:59:41 PM ******/
CREATE NONCLUSTERED INDEX [INvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEDETAIL_ISSUEDATE]    Script Date: 7/7/2015 3:59:41 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEDETAIL_ISSUEDATE] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 3:59:42 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_ClientCode]    Script Date: 7/7/2015 3:59:42 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_ClientCode] ON [dba].[ContractRmks]
(
	[ClientCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_CONTRACTRMKS_CLIENTCODE_CONTRACTID_COMPIND_ISSUEDT]    Script Date: 7/7/2015 3:59:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_CONTRACTRMKS_CLIENTCODE_CONTRACTID_COMPIND_ISSUEDT] ON [dba].[ContractRmks]
(
	[ClientCode] ASC,
	[ContractID] ASC,
	[CompliantInd] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[MarketInd],
	[POSInd],
	[ExhibitNum],
	[MarketNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_CompliantInd]    Script Date: 7/7/2015 3:59:44 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_CompliantInd] ON [dba].[ContractRmks]
(
	[CompliantInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID]    Script Date: 7/7/2015 3:59:44 PM ******/
CREATE NONCLUSTERED INDEX [IX_CONTRACTRMKS_CONTRACTID] ON [dba].[ContractRmks]
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

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID_COMPIND_EXNUM_MARKETNUM_ISSUEDATE_POSCOUNTRY]    Script Date: 7/7/2015 3:59:45 PM ******/
CREATE NONCLUSTERED INDEX [IX_CONTRACTRMKS_CONTRACTID_COMPIND_EXNUM_MARKETNUM_ISSUEDATE_POSCOUNTRY] ON [dba].[ContractRmks]
(
	[ContractID] ASC,
	[CompliantInd] ASC,
	[ExhibitNum] ASC,
	[MarketNum] ASC,
	[IssueDate] ASC,
	[POSCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[RouteTypeInd],
	[FlownCarrierInd],
	[MarketInd],
	[FareBasisInd],
	[CodeShareInd],
	[ClassInd],
	[FlightNumInd],
	[POSInd],
	[OverNightInd],
	[DOWInd],
	[DaysAdvInd],
	[ValCarrierInd],
	[SatNtRqdInd]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID2]    Script Date: 7/7/2015 3:59:47 PM ******/
CREATE NONCLUSTERED INDEX [IX_CONTRACTRMKS_CONTRACTID2] ON [dba].[ContractRmks]
(
	[ContractID] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[SegmentNum],
	[ClientCode],
	[InvoiceDate],
	[IssueDate],
	[CompliantInd],
	[RouteType],
	[RouteTypeInd],
	[FlownCarrierInd],
	[MarketInd],
	[DesignatorInd],
	[FareBasisInd],
	[CodeShareInd],
	[ClassInd],
	[FlightNumInd],
	[POSInd],
	[DiscountInd],
	[FareAmtInd],
	[TourCodeInd],
	[OverNightInd],
	[DOWInd],
	[CarrierString],
	[DaysAdvInd],
	[ExcludedItem],
	[ExhibitNum],
	[MarketNum],
	[StgyExhibitNum],
	[StgyMarketNum],
	[FareAmt],
	[FarePct],
	[Zone1Fare],
	[Zone2Fare],
	[Zone3Fare],
	[Zone4Fare],
	[Zone5Fare],
	[PublishedFare],
	[DiscountedFare],
	[MktRegionInd],
	[RefundInd],
	[FairMktShr],
	[QSI],
	[GoalNumber],
	[ValCarrierInd],
	[SatNtRqdInd],
	[GoalExhibitNum],
	[GoalMarketNum],
	[GoalFlownCarrierInd],
	[OnlineInd],
	[InterlineInd],
	[GDSInd],
	[COSString],
	[COSTicketString],
	[MinStayInd],
	[DepartureDate],
	[Target],
	[OnlineFlag],
	[POSCountry],
	[ContractCarrierFlag],
	[MinOpCarrierCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_ContractRmks_ExhibitNum]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_ExhibitNum] ON [dba].[ContractRmks]
(
	[ExhibitNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_IataNum]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_IataNum] ON [dba].[ContractRmks]
(
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_ContractRmks_IssueDate]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_IssueDate] ON [dba].[ContractRmks]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_ContractRmks_MarketNum]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_MarketNum] ON [dba].[ContractRmks]
(
	[MarketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_MinOpCarrierCode]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_MinOpCarrierCode] ON [dba].[ContractRmks]
(
	[MinOpCarrierCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_POSCountry]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_POSCountry] ON [dba].[ContractRmks]
(
	[POSCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_RecordKey]    Script Date: 7/7/2015 3:59:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_RecordKey] ON [dba].[ContractRmks]
(
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_ContractRmks_RouteTypeInd]    Script Date: 7/7/2015 3:59:54 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_RouteTypeInd] ON [dba].[ContractRmks]
(
	[RouteTypeInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_ContractRmks_SegmentNum]    Script Date: 7/7/2015 3:59:54 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_SegmentNum] ON [dba].[ContractRmks]
(
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_ContractRmks_SeqNum]    Script Date: 7/7/2015 3:59:54 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContractRmks_SeqNum] ON [dba].[ContractRmks]
(
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_AIRLINECONTRACT_GOALS_CUSTOMERID_CONTRACTNO_EXHIBITNO_MARKETNO]    Script Date: 7/7/2015 3:59:54 PM ******/
CREATE NONCLUSTERED INDEX [IX_AIRLINECONTRACT_GOALS_CUSTOMERID_CONTRACTNO_EXHIBITNO_MARKETNO] ON [dba].[AirlineContractGoals]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC
)
INCLUDE ( 	[GoalBeginDate],
	[GoalEndDate],
	[TravelBeginDate],
	[TravelEndDate],
	[ClassOfServiceOperand],
	[ClassOfService],
	[FareBasisOperand],
	[FareBasis],
	[TourCode],
	[FlightNumberOperand],
	[FlightNumber],
	[OvernightRqd],
	[SatNightRqd],
	[ValidDaysOperand],
	[ValidDays],
	[DaysAdv],
	[ValidatingCarriersOperand],
	[ValidatingCarriers],
	[OperatingCarriersOperand],
	[OperatingCarriers],
	[InterlineInd],
	[FlownCarriersOperand],
	[FlownCarriers]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IX_AIRLINECONTRACTGOALS_CONTRACTNUMBER]    Script Date: 7/7/2015 3:59:56 PM ******/
CREATE NONCLUSTERED INDEX [IX_AIRLINECONTRACTGOALS_CONTRACTNUMBER] ON [dba].[AirlineContractGoals]
(
	[ContractNumber] ASC
)
INCLUDE ( 	[GoalBeginDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_AIRLINECONTRACTGOALS_DISCOUNTTYPE_CONTRACTNUMBER]    Script Date: 7/7/2015 3:59:56 PM ******/
CREATE NONCLUSTERED INDEX [IX_AIRLINECONTRACTGOALS_DISCOUNTTYPE_CONTRACTNUMBER] ON [dba].[AirlineContractGoals]
(
	[DiscountType] ASC
)
INCLUDE ( 	[ContractNumber],
	[ExhibitNumber],
	[MarketNumber],
	[GoalNumber],
	[Allowance],
	[GoalBeginDate],
	[GoalEndDate],
	[TravelBeginDate],
	[TravelEndDate],
	[CurrCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Approved]  DEFAULT ((0)) FOR [Approved]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Scenario]  DEFAULT ('I') FOR [Status]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Processed]  DEFAULT ('N') FOR [Processed]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_MeasureGoalsOnDate]  DEFAULT ('F') FOR [MeasureGoalsOnDate]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_MeasurePayOnDate]  DEFAULT ('F') FOR [MeasurePayOnDate]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_GoalMeasurementPeriod]  DEFAULT ('Q') FOR [GoalMeasurementPeriod]
GO

ALTER TABLE [dba].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_PayMeasurementPeriod]  DEFAULT ('Q') FOR [PayMeasurementPeriod]
GO

ALTER TABLE [dba].[AirlineContractGoals] ADD  CONSTRAINT [DF_AirlineContractGoals_FlightNumberOperand]  DEFAULT ('I') FOR [FlightNumberOperand]
GO

ALTER TABLE [dba].[AirlineContractGoals] ADD  CONSTRAINT [DF_AirlineContractGoals_OvernightRqd]  DEFAULT ('N') FOR [OvernightRqd]
GO

ALTER TABLE [dba].[AirlineContractGoals] ADD  CONSTRAINT [DF_AirlineContractGoals_SatNightRqd]  DEFAULT ('N') FOR [SatNightRqd]
GO

ALTER TABLE [dba].[AirlineContractGoals] ADD  CONSTRAINT [DF_AirlineContractGoals_ValidDaysOperand]  DEFAULT ('I') FOR [ValidDaysOperand]
GO

ALTER TABLE [dba].[AirlineContractGoals] ADD  CONSTRAINT [DF_AirlineContractGoals_OperatingCarriersOperand]  DEFAULT ('I') FOR [OperatingCarriersOperand]
GO

ALTER TABLE [dba].[AirlineContractGoals] ADD  CONSTRAINT [DF_AirlineContractGoals_DirectionalInd]  DEFAULT ('N') FOR [DirectionalInd]
GO

ALTER TABLE [dba].[AirlineContractGoals]  WITH CHECK ADD  CONSTRAINT [FK_AirlineContractGoals_AirlineContracts] FOREIGN KEY([ContractNumber])
REFERENCES [dba].[AirlineContracts] ([ContractNumber])
ON DELETE CASCADE
GO

ALTER TABLE [dba].[AirlineContractGoals] CHECK CONSTRAINT [FK_AirlineContractGoals_AirlineContracts]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lists of contract carrier codes' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'ContractCarrierCodes'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measure goals on flown or ticket date?' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'MeasureGoalsOnDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measure payment on flown or issued date?' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'MeasurePayOnDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Period for measuring performance goals' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'GoalMeasurementPeriod'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date period for payments' , @level0type=N'SCHEMA',@level0name=N'dba', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'PayMeasurementPeriod'
GO

