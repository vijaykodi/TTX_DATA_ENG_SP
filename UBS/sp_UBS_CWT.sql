/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='Tman_UBS']/UnresolvedEntity[@Name='Invoiceheader' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='Tman_UBS']/UnresolvedEntity[@Name='Invoicedetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='hotel' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='Tman_UBS']/UnresolvedEntity[@Name='Client' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='city' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContracts' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContractMarkets' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContractGoals' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='AirlineContractExhibits' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxpaSQL09']/Database[@Name='TMAN503_Reports_ACM']/UnresolvedEntity[@Name='ACMProcessedTransactions' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='server_Administration']/UnresolvedEntity[@Name='sp_ExecuteACMProcessor' and @Schema='dbo'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL03']/Database[@Name='ttxcentral']/UnresolvedEntity[@Name='USZipCodesDeluxe' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='Tman_UBS']/UnresolvedEntity[@Name='Transeg' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='tman_ubs']/UnresolvedEntity[@Name='sp_RefundExchange' and @Schema='dbo'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='ttxsasql01']/Database[@Name='DataEnhancementAutomation']/UnresolvedEntity[@Name='SP_NewDataEnhancementRequest' and @Schema='dbo'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:14:53 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_ACM_AutoProcess_UBS]    Script Date: 7/13/2015 1:14:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- ==========================================================================================
-- Author:		  Charlie Bradsher
-- Create date:	  2012-09-19
-- Modified date:	  2013-03-25
-- Description:	  Pre Process Corporate Data 
--			  Assigns UBS as CustomerID
--			  Needs to be saved and run from customer database
--			  This procedure calls a remote procedure on the processing server		
--			  Database and Process servers must be linked with RPC true, RPC Out = true
--			  Arguments for Customer information are hardcoded below
--                      set @Server as the processing server
--                      set @Prog with argumments for database servers
-- ==========================================================================================

CREATE PROCEDURE [dbo].[sp_ACM_AutoProcess_UBS]
	
AS
BEGIN

DECLARE @CustomerID varchar(30)
Set @CustomerID = 'UBS'
--------------------------------------------------------------------------------------------------------------------------------
-------------------------------For Logging -------------------------------------------------------------------------------------
Declare @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
		@BeginIssueDate datetime, @ENDIssueDate datetime, @LogSegNbr int = 0
, @LogStep varchar(50)
	SET @Iata = 'UBSCWT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()
---------------------------------------------------------------------------------------------------------------------------------
 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity

	--=================================
	--Added by rcr  06/30/2015
	--Adding two variables for logging.
	--=================================
	DECLARE @LocalBeginIssueDate DATETIME = GETDATE(), @LocalEndIssueDate DATETIME = GETDATE()


 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Start'
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

--  Update CustRollUp (adds Master value UBS for new/undefined clientcodes)
--Added by rcr  06/30/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = getdate()
--
Insert into dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
Select IH.IataNum, IH.ClientCode, 'UBS'
from dba.InvoiceHeader IH
left outer join dba.CustRollup CRoll on (IH.IataNum = CRoll.AgencyIataNum
and IH.ClientCode = CRoll.CustNo)
where IH.IataNum not like 'Pre%'
Group by  IH.IataNum, IH.ClientCode, CRoll.CustNo
having CRoll.CustNo is null


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  CustRollup insert complete-'
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





--Added by rcr  06/30/2015
SET @TransStart = getdate()
--

--  Drop back-up tables and back up existing terms data

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContracts_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContracts_Bak]

Select *
into dba.AirlineContracts_Bak
from dba.AirlineContracts

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractExhibits_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractExhibits_Bak]

Select *
into dba.AirlineContractExhibits_Bak
from dba.AirlineContractExhibits

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractMarkets_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractMarkets_Bak]

Select *
into dba.AirlineContractMarkets_Bak
from dba.AirlineContractMarkets

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractGoals_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractGoals_Bak]

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Dropping Tables Complete complete-'
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




--Added by rcr  06/30/2015
SET @TransStart = getdate()
--

Select *
into dba.AirlineContractGoals_Bak
from dba.AirlineContractGoals

delete from dba.AirlineContracts 
where CustomerID = @CustomerID

delete from dba.AirlineContractExhibits 
where CustomerID = @CustomerID

delete from dba.AirlineContractMarkets 
where CustomerID = @CustomerID

delete from dba.AirlineContractGoals 
where CustomerID = @CustomerID

Insert into dba.AirlineContracts
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContracts
where CustomerID = @CustomerID

Insert into dba.AirlineContractExhibits
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractExhibits
where CustomerID = @CustomerID

Insert into dba.AirlineContractMarkets
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractMarkets
where CustomerID = @CustomerID

Insert into dba.AirlineContractGoals
SELECT [CustomerID]
      ,[ContractNumber]
      ,[ExhibitNumber]
      ,[MarketNumber]
      ,[GoalNumber]
      ,[Status]
      ,[GoalType]
      ,[GoalValue]
      ,[Discount]
      ,[DiscountType]
      ,[Target]
      ,[Allowance]
      ,[GoalBeginDate]
      ,[GoalEndDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
      ,[TravelBeginDate]
      ,[TravelEndDate]
      ,[CurrCode]
      
      ,[DiscCurrCode]
      ,[MinPerformance]
      ,[InflectionPoint]
      ,[MaxPerformance]
      ,[MinPayment]
      ,[InflectionPayment]
      ,[MaxPayment]
      ,[Description]    
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractGoals
where CustomerID = @CustomerID

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Inserting/Deleting standard tablescomplete-'
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

-- Set Variables

DECLARE @ClientRequestName varchar(20)
DECLARE @Contract varchar(30)
DECLARE @ContractCarrier varchar(50)
DECLARE @ImportDate datetime
DECLARE @Server varchar(50) 
DECLARE @User varchar(100) 
DECLARE @Pword varchar(100) 
DECLARE @Prog varchar(500) 
DECLARE @RemoteArgs varchar(500) 

--  Set Import Date 
Set @ImportDate = (select max(ImportDt)from DBA.InvoiceHeader)
--  Set arguments to run autoprocessor for this client
Set @Server = '\\ATL591.TRXFS.TRX.COM'  --  server to run the processor
Set @User = N'wtpdh\smsservice'  
Set @Pword = N'melanie'
--  @prog = local path and executable + DSNs on @Server -CS = Contracts data -TS = Trans data
Set @Prog = 'c:\ProcessACM\ProcessContracts.exe -CSWA_UBS -TSWA_UBS'  
-- @RemoteArgs = Gets last import date from data
Set @RemoteArgs = (select '-ID'+substring(convert(varchar,max(importdt),111),6,15)+'/'+substring(convert(varchar,max(importdt),111),1,4)+' -IT'+substring(convert(varchar,max(importdt),120),12,8)
from dba.invoiceheader)

/************************************************************************
    Delete data for re-processing  (ContractRmks and ACMInfo only)
*************************************************************************/
--
--Added by rcr  06/30/2015
SET @TransStart = getdate()
--

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


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Delete ACMInfo and Contract Rmks tables complete-'
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
    Update MasterTables from ACMMaster
*************************************************************************/

--  add this code

/************************************************************************
    Update Transeg with Operating Carrier Code / Fare Basis / 
	Update InvoiceDetail Vendortype and ProductType for unidentified
*************************************************************************/

--Added by rcr  06/30/2015
SET @TransStart = getdate()
--

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

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  TS.CodeshareCarrierCode = XR.OpCarrier'
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




--Added by rcr  06/30/2015
SET @TransStart = getdate()
--
Update TS
Set CodeshareCarrierCode = SegmentCarrierCode
from dba.TranSeg TS,dba.InvoiceHeader IH
where IH.RecordKey = TS.RecordKey
and IH.IataNum = TS.IataNum
and IH.ImportDt = @ImportDate
and CodeshareCarrierCode is null


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  CodeshareCarrierCode = SegmentCarrierCode'
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



-------------------------------------------
--==Commented out by rcr 06/30/2015
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='CodeShareCarrierCode complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
-------------------------------------------

--Added by rcr  06/30/2015
SET @TransStart = getdate()
--
Update TS
Set FareBasis = left(ClassOfService,1)
from dba.Transeg TS, dba.InvoiceHeader IH
where IH.RecordKey = TS.RecordKey
and IH.IataNum = TS.IataNum
and IH.ImportDt = @ImportDate
and FareBasis is null

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  FareBasis complete-'
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
  Load ACMInfo table  ( note - this sets the ImportDt in ACMInfo)
*************************************************************************/
SET @TransStart = getdate()
INSERT INTO dba.ACMInfo
  (RecordKey, IataNum, SeqNum, SegmentNum, ClientCode, InvoiceDate,IssueDate, InterlineFlag, RouteType
  , POSCountry,DepartureDate, ImportDt)

SELECT TS.RecordKey, TS.IataNum, TS.SeqNum, TS.SegmentNum, TS.ClientCode, TS.InvoiceDate
,TS.IssueDate, 'Y', 'O',IH.OrigCountry,TS.DepartureDate, IH.ImportDt
FROM DBA.Transeg TS, DBA.InvoiceDetail ID, DBA.InvoiceHeader IH
  WHERE  TS.MINDestCityCode is not null
  AND ID.RecordKey = TS.RecordKey   AND ID.Iatanum = TS.IataNum   AND ID.SeqNum = TS.SeqNum   AND IH.RecordKey = TS.RecordKey
  AND IH.Iatanum = TS.IataNum   AND IH.RecordKey = ID.RecordKey   AND IH.Iatanum = ID.IataNum   and TS.IssueDate = ID.IssueDate
  and IH.IataNum not like 'PRE'   and IH.IataNum not like 'TEST'   and (ID.Vendortype in ('BSP','NONBSP', 'BSPSTC','NONBSPSTC', 'RAIL')
	or ID.Vendortype ='NONAIR' and isnull(Producttype,'UNKNOWN') in ('RAIL','AIR','UNKNOWN'))
  and ID.VoidInd = 'N'
  and IH.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') FareBasis complete-'
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
  Set Route Type
*************************************************************************/
--
--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
--  Set Outbound
Update ACMI
set ACMI.RouteType = 'R'
from dba.ACMInfo ACMI, dba.TranSeg TS,dba.TranSeg TS2
where ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and TS.RecordKey = TS2.RecordKey
and TS.IataNum = TS2.IataNum
and TS.SeqNum = TS2.SeqNum
and TS2.SegmentNum > TS.SegmentNum
and TS.OriginCityCode = TS2.MinDestCityCode
and TS.MinDestCityCode = TS2.OriginCityCode
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Outbound complete-'
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


--Added by rcr  06/30/2015
SET @TransStart = getdate()

-- Flags Inbound Segment
Update ACMI
Set ACMI.RouteType = 'R'
from dba.ACMInfo ACMI, dba.TranSeg TS,dba.TranSeg TS2
where ACMI.RecordKey = TS2.RecordKey and ACMI.IataNum = TS2.IataNum and ACMI.SeqNum = TS2.SeqNum and ACMI.SegmentNum = TS2.SegmentNum
and TS.RecordKey = TS2.RecordKey and TS.IataNum = TS2.IataNum and TS.SeqNum = TS2.SeqNum and TS2.SegmentNum > TS.SegmentNum
and TS.OriginCityCode = TS2.MinDestCityCode and TS.MinDestCityCode = TS2.OriginCityCode
and ACMI.ImportDt = @ImportDate

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Flag Inbound complete-'
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
    Set Interline Flag
*************************************************************************/
--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
update ACMI
Set InterlineFlag = 'N'
from dba.ACMInfo ACMI
where ACMI.ImportDt = @ImportDate
    and RecordKey+IataNum+convert(char,Seqnum) in (
	Select distinct TS.RecordKey+TS.IataNum+convert(char,TS.Seqnum)
	from dba.TranSeg TS, dba.ACMInfo ACMI 	where TS.RecordKey = ACMI.RecordKey and TS.IataNum = ACMI.IataNum 	and TS.SeqNum = ACMI.SeqNum
	and TS.SegmentNum = ACMI.SegmentNum 	and ACMI.ImportDt = @ImportDate 	group by TS.RecordKey+TS.IataNum+convert(char,TS.Seqnum)
	having min(SegmentCarrierCode) = Max(SegmentCarrierCode))


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Interline Flag complete-'
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

--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
--  Find MIN Long Haul Segment and update
Update ACMI
Set ACMI.SegNum = ACMI.SegmentNum
from dba.ACMInfo ACMI, dba.TranSeg TS
where ACMI.RecordKey = TS.RecordKey and ACMI.IataNum = TS.IataNum and ACMI.SeqNum = TS.SeqNum and ACMI.SegmentNum = TS.SegmentNum
and SegDestCityCode = MINDestCityCode
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACMI.SegNum = ACMI.SegmentNum'
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

--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
Update ACMI
Set ACMI.Miles = TS.SegSegmentMileage
from dba.ACMInfo ACMI, dba.TranSeg TS
where ACMI.RecordKey = TS.RecordKey and ACMI.IataNum = TS.IataNum and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACMI.Miles = TS.SegSegmentMileage'
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


Declare @SegNum int
Declare @UPCount int

Set @SegNum = 1
Set @UpCount = 1

While @UpCount > 0 
	
    BEGIN

	--Added by rcr  06/30/2015
	set  @TransStart = getdate()
	--

	 Update ACMI
	 Set ACMI.Miles = TS.SegSegmentMileage, ACMI.SegNum = TS.SegmentNum
	 from dba.ACMInfo ACMI, dba.TranSeg TS
	 where ACMI.RecordKey = TS.RecordKey
	 and ACMI.IataNum = TS.IataNum
	 and ACMI.SeqNum = TS.SeqNum
	 and TS.MinDestCityCode is null
	 and TS.SegmentNum = ACMI.SegmentNum+@SegNum
	 and abs(TS.SegSegmentMileage) > abs(ACMI.Miles)
	 and ACMI.SegNum is null
	 and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACMI.Miles = TS.SegSegmentMileage, ACMI.SegNum = TS.SegmentNum'
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


	--Added by rcr  06/30/2015
	SET @TransStart = Getdate() 
	--
	 Update ACMI
	 Set ACMI.SegNum = ACMI.SegmentNum
	 from dba.ACMInfo ACMI, dba.ACMInfo ACMI2
	 where ACMI.RecordKey = ACMI2.RecordKey
	 and ACMI.IataNum = ACMI2.IataNum
	 and ACMI.SeqNum = ACMI2.SeqNum
	 and ACMI.SegmentNum+@SegNum+1 = ACMI2.SegmentNum
	 and ACMI2.Miles is not null
	 and ACMI.SegNum is Null
	 and ACMI.ImportDt = @ImportDate


	----Added by rcr  07/07/2015
	set @LogSegNbr += 1 
	set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACMI.SegNum = ACMI.SegmentNum'
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


	 Set @UpCount = @@Rowcount	
	 Set @SegNum = @SegNum+1
    	
    END


--Added by rcr  06/30/2015
SET @TransStart = Getdate() 
--
Update ACMI
Set ACMI.SegNum = ACMI.SegmentNum, ACMI.Miles = TS.SegSegmentMileage
from dba.ACMInfo ACMI, dba.TranSeg TS
where ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and  ACMI.SegNum is null
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACMI.SegNum = ACMI.SegmentNum, ACMI.Miles = TS.SegSegmentMileage'
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

--
--Added by rcr  06/30/2015
SET @TransStart = Getdate() 
--

-- Update 'em
Update ACMI
Set ACMI.MINOpCarrierCode = TS.CodeShareCarrierCode,  ACMI.LongHaulOrigCityCode = TS.OriginCityCode
, ACMI.LongHaulDestCityCode = TS.SegDestCityCode, ACMI.LongHaulMileage = ACMI.Miles
, ACMI.LongHaulMktOrigCityCode = TS.SegMktOrigCityCode, ACMI.LongHaulMktDestCityCode = TS.SegMktDestCityCode
from dba.ACMInfo ACMI, dba.TranSeg TS
where ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and TS.SegmentNum = ACMI.SegNum
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update em'
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

---
--This code segment seems to represent the Long Haul Process' rcr
---
set  @TransStart = getdate()
--


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Long Haul complete-'
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
    Set FMS Fields for O & D and Long Haul Segment (of O&D)
*************************************************************************/
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

--  O & D FMS - FlownCarrier/QSI/DepartureDate
Update ACMI 
Set ACMI.MINFMS = QSI.FMS
From dba.TranSeg TS, dba.QSI QSI, dba.ACMInfo ACMI
where TS.MINMktOrigCityCode = QSI.ORIG
and TS.MINMktDestCityCode = QSI.DEST
and TS.MINSegmentCarrierCode = QSI.Airline
and ACMI.DepartureDate between QSI.BeginDate and QSI.EndDate
and TS.DepartureDate between QSI.BeginDate and QSI.EndDate
and ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') O & D FMS - FlownCarrier/QSI/DepartureDate '
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



--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
--  O & D FMS - FlownCarrier/QSI/IssueDate
Update ACMI 
Set ACMI.MINFMS = QSI.FMS
From dba.TranSeg TS, dba.QSI QSI, dba.ACMInfo ACMI
where TS.MINMktOrigCityCode = QSI.ORIG
and TS.MINMktDestCityCode = QSI.DEST
and TS.MINSegmentCarrierCode = QSI.Airline
and ACMI.IssueDate between QSI.BeginDate and QSI.EndDate
and TS.IssueDate between QSI.BeginDate and QSI.EndDate
and ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and ACMI.MINFMS is null
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') O & D FMS - FlownCarrier/QSI/IssueDate'
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



--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
--  LongHaul Segment FMS - FlownCarrier/QSI/DepartureDate
Update ACMI 
Set ACMI.LongHaulFMS = QSI.FMS
From dba.TranSeg TS, dba.QSI QSI, dba.ACMInfo ACMI
where ACMI.LongHaulMktOrigCityCode = QSI.ORIG
and ACMI.LongHaulMktDestCityCode = QSI.DEST
and TS.MINSegmentCarrierCode = QSI.Airline
and ACMI.DepartureDate between QSI.BeginDate and QSI.EndDate
and TS.DepartureDate between QSI.BeginDate and QSI.EndDate
and ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and ACMI.LongHaulFMS is null
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') O & D FMS - FlownCarrier/QSI/IssueDate'
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



--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
--  LongHaul Segment FMS - FlownCarrier/QSI/IssueDate
Update ACMI 
Set ACMI.LongHaulFMS = QSI.FMS
From dba.TranSeg TS, dba.QSI QSI, dba.ACMInfo ACMI
where ACMI.LongHaulMktOrigCityCode = QSI.ORIG
and ACMI.LongHaulMktDestCityCode = QSI.DEST
and TS.MINSegmentCarrierCode = QSI.Airline
and ACMI.IssueDate between QSI.BeginDate and QSI.EndDate
and TS.IssueDate between QSI.BeginDate and QSI.EndDate
and ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and ACMI.LongHaulFMS is null
and ACMI.ImportDt = @ImportDate


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') LongHaul Segment FMS - FlownCarrier/QSI/IssueDate'
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



----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set FMS complete-'
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
    Set DiscountedFare - Old Exchange Method
*************************************************************************/
--Added by rcr  06/30/2015
set  @TransStart = getdate()
--

--  Set Discounted fare = MinSegmentValue
update ACMI
set DiscountedFare = MinSegmentValue
from dba.acminfo acmi, dba.transeg ts
where ACMI.RecordKey = TS.RecordKey
and ACMI.IataNum = TS.IataNum
and ACMI.SeqNum = TS.SeqNum
and ACMI.SegmentNum = TS.SegmentNum
and ACMI.ImportDt = @ImportDate

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


--Added by rcr  06/30/2015
set  @TransStart = getdate()
--
--  Set DiscountedFare = Prorated base fare when sum of SegmentValue <> ticket price

Update ACMI
Set DiscountedFare = TS.MINSegmentMileage / TS.MINTotalMileage * isnull(ID.InvoiceAmt,0)
From dba.TranSeg TS, dba.ACMInfo ACMI, dba.InvoiceDetail ID
where TS.RecordKey = ACMI.RecordKey
and TS.IataNum = ACMI.Iatanum
and TS.SeqNum = ACMI.SeqNum
and TS.SegmentNum = ACMI.SegmentNum
and TS.RecordKey = ID.RecordKey
and TS.IataNum = ID.Iatanum
and TS.SeqNum = ID.SeqNum
and ACMI.ImportDt = @ImportDate
and ACMI.RecordKey in (
    select Distinct ACMI.RecordKey
    from dba.acminfo ACMI, dba.InvoiceDetail ID 
    where ACMI.RecordKey = ID.RecordKey
    and ACMI.IataNum = ID.IataNum
    and ACMI.SeqNum = ID.SeqNum
    and ACMI.ImportDt = @ImportDate
    group by ACMI.RecordKey, round(ID.InvoiceAmt,0)
    having round(ID.InvoiceAmt,0) <> Round(sum(isnull(ACMI.DiscountedFare,0)),0)
    )

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Set Discounted Fare complete-'
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


---===Start here 06/30/2015
--3:10am

/************************************************************************
    Insert ContractRmk records
*************************************************************************/
--Added by rcr  06/30/2015
set  @TransStart = getdate()
--

Insert into dba.ContractRmks
( RecordKey
, IataNum
, SeqNum
, SegmentNum
, ClientCode
, InvoiceDate
, IssueDate
, ContractID
, RouteType
, DiscountedFare
, LongHaulOrigCityCode
, LongHaulDestCityCode
, LongHaulMktOrigCityCode
, LongHaulMktDestCityCode
, LongHaulFMS
, LongHaulMileage
, MINOpCarrierCode
, MINFMS
, InterlineFlag
, POSCountry
, DepartureDate
)
 
 Select 
      ACMI.RecordKey
    , ACMI.IataNum
    , ACMI.SeqNum
    , ACMI.SegmentNum
    , ACMI.ClientCode
    , ACMI.InvoiceDate
    , ACMI.IssueDate
    , AC.ContractNumber
    , ACMI.RouteType
    , ACMI.DiscountedFare
    , ACMI.LongHaulOrigCityCode
    , ACMI.LongHaulDestCityCode
    , ACMI.LongHaulMktOrigCityCode
    , ACMI.LongHaulMktDestCityCode
    , ACMI.LongHaulFMS
    , ACMI.LongHaulMileage
    , ACMI.MINOpCarrierCode
    , MINFMS
    , ACMI.InterlineFlag
    , ACMI.POSCountry
    , ACMI.DepartureDate
  from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollUp CRoll
  where CRoll.MasterCustNo = AC.CustomerID
  and CRoll.AgencyIataNum = ACMI.IataNum
  and CRoll.CustNo = ACMI.ClientCode
  and ACMI.ImportDt = @ImportDate
  and ACMI.IssueDate between ( Select Min(ACG.GoalBeginDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)
		  	    and ( Select Max(ACG.GoalEndDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)	    
  and ACMI.DepartureDate between ( Select Min(ACG.TravelBeginDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)
		  	    and ( Select Max(ACG.TravelEndDate)
				    from dba.AirlineContractGoals  ACG
				    where ACG.ContractNumber = AC.ContractNumber)


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Insert Contract Rmks complete-'
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
    Set Online Flag - contract carrier is the first airline in 
    the contractcarriercodes field of in AirlineContracts table
*************************************************************************/

--  Use AirlineContracts.ContractCarrierCodes on DepartureDate  

DECLARE airline_cursor CURSOR FOR
select Distinct ContractNumber, left(ContractCarrierCodes,2)
from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollup CRoll
where AC.CustomerID = CRoll.MasterCustNo
and ACMI.Iatanum = CRoll.AgencyIataNum
and ACMI.ClientCode = CRoll.CustNo
and ACMI.ImportDt = @ImportDate
order by 1

Open airline_cursor

fetch next from airline_cursor into @Contract, @ContractCarrier

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

while @@Fetch_Status = 0

  BEGIN
  
	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD, dba.InvoiceHeader IH
	 where TS.RecordKey = ACRmks.RecordKey
	 and TS.IataNum = ACRmks.IataNum
	 and TS.SeqNum = ACRmks.SeqNum
	 and TS.SegmentNum = ACRmks.SegmentNum
	 and TS.RecordKey = IH.RecordKey
	 and TS.IataNum = IH.IataNum
	 and ACRmks.RecordKey = IH.RecordKey
	 and ACRmks.IataNum = IH.IataNum
	 and ACRmks.ContractId = @Contract
	 and TS.OriginCityCode = ACSO.StationCode
	 and ACSO.CarrierCode = @ContractCarrier
	 and TS.MinDestCityCode = ACSD.StationCode
	 and ACSD.CarrierCode = @ContractCarrier
	 AND ACRmks.DepartureDate between ACSO.BeginDate and ACSO.EndDate
	 AND ACRmks.DepartureDate between ACSD.BeginDate and ACSD.EndDate
	 and IH.ImportDt = @ImportDate
	
  fetch next from airline_cursor into @Contract, @ContractCarrier
  
  END

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Insert Contract Rmks complete-'
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



CLOSE airline_cursor
DEALLOCATE airline_cursor

--Added by rcr  06/30/2015
set  @TransStart = getdate()
--

--  Use AirlineContracts.ContractCarrierCodes on Current Schedule   
DECLARE airline_cursor CURSOR FOR
select Distinct ContractNumber, left(ContractCarrierCodes,2)
from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollup CRoll
where AC.CustomerID = CRoll.MasterCustNo
and ACMI.Iatanum = CRoll.AgencyIataNum
and ACMI.ClientCode = CRoll.CustNo
and ACMI.ImportDt = @ImportDate
order by 1

Open airline_cursor

-- Fetch gets first record
fetch next from airline_cursor into @Contract, @ContractCarrier

while @@Fetch_Status = 0

  BEGIN
  
	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD, dba.InvoiceHeader IH
	 where TS.RecordKey = ACRmks.RecordKey
	 and TS.IataNum = ACRmks.IataNum
	 and TS.SeqNum = ACRmks.SeqNum
	 and TS.SegmentNum = ACRmks.SegmentNum
	 and TS.RecordKey = IH.RecordKey
	 and TS.IataNum = IH.IataNum
	 and ACRmks.RecordKey = IH.RecordKey
	 and ACRmks.IataNum = IH.IataNum
	 and ACRmks.ContractId = @Contract
	 and TS.OriginCityCode = ACSO.StationCode
	 and ACSO.CarrierCode = @ContractCarrier
	 and TS.MinDestCityCode = ACSD.StationCode
	 and ACSD.CarrierCode = @ContractCarrier
	 and ACSO.BeginDate = (select Max(BeginDate) from dba.AirlineContractAirportStats)
	 and ACSD.BeginDate = (select Max(BeginDate) from dba.AirlineContractAirportStats)
	 and ACRmks.OnlineFlag is null
	 and IH.ImportDt = @ImportDate
 
  fetch next from airline_cursor into @Contract, @ContractCarrier
  
  END

CLOSE airline_cursor
DEALLOCATE airline_cursor

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  airline_cursor-'
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

--  Finish up online


--Added by rcr  06/30/2015
set  @TransStart = getdate()
--

update ACRmks
set OnlineFlag = 'N'
from dba.ContractRmks ACRmks, dba.InvoiceHeader IH
where IH.RecordKey = ACRmks.RecordKey
and IH.IataNum = ACRmks.IataNum
and  ACRmks.OnlineFlag is null
and IH.ImportDt = @ImportDate

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ONLINE FLAG-'
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


--Added by rcr  06/30/2015
set  @TransStart = getdate()
--

Insert into ttxpaSQL09.TMAN503_Reports_ACM.dba.ACMProcessedTransactions
Select 'TTXPASQL01','TMAN_UBS',IataNum, ImportDt , MasterCustNo, min(issuedate), max(issuedate), count(distinct recordkey), Sum(1) 
from dba.ACMInfo, dba.CustRollup
where agencyiatanum = iatanum
and custno = clientcode
and ImportDt = @ImportDate
group by IataNum, MasterCustNo, ImportDt


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') INSERT ACM REPORT'
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



--  Execute SP to run ProcessContracts.exe - Runs on ATL875 - Processes on ATL591 for database DSN specified
set @TransStart = getdate()
DECLARE	@return_value int

   EXEC	@return_value = TTXSASQL03.server_Administration.dbo.sp_ExecuteACMProcessor
		  @RemoteBatch = @Prog,
		  @RemoteServer = @Server,
		  @RemoteUser = @User,
		  @RemotePword = @Pword,
		  @RemoteArgs = @RemoteArgs

SELECT	'Return Value' = @return_value

END


----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACM SP Complete complete-'
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
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--Added by rcr  06/30/2015
WAITFOR DELAY '00:00.30'
set  @TransStart = getdate()
--

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




GO

ALTER AUTHORIZATION ON [dbo].[sp_ACM_AutoProcess_UBS] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_UBS_CWT]    Script Date: 7/13/2015 1:14:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_UBS_CWT]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'UBSCWT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update car
set car.issuedate = id.issuedate
from dba.car car, dba.invoicedetail id
where car.issuedate <> id.issuedate 
AND id.RecordKey = car.RecordKey and id.SeqNum = car.SeqNum and id.iatanum ='UBSCWT'

update htl
set htl.issuedate = i.issuedate
from dba.hotel htl, dba.invoicedetail i
where htl.issuedate <> i.issuedate
AND i.RecordKey = HTL.RecordKey AND i.SeqNum = HTL.SeqNum and i.iatanum ='UBSCWT'

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate
FROM dba.InvoiceDetail 
	where recordkey+iatanum+convert(varchar,seqnum) not in
	(SELECT recordkey+iatanum+convert(varchar,seqnum) from dba.comrmks
	where iatanum = 'UBSCWT')
and iatanum = 'UBSCWT'

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Insert Comrmks Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Move data from remarks 1,2,3,4,5 to text 32,33,34,35,36
update c
set c.text32 = i.remarks1, 	c.text33 = i.remarks2, 	c.text34 = i.remarks3,
	c.text35 =  i.remarks4, 	c.text36 = i.remarks5
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum and i.iatanum = 'UBSCWT' 
and text32 is null and text33 is null and text34 is null and text35 is null and text36 is null

------- Null Remarks 1,2,3,4,5
update i
set i.remarks1 = null, i.remarks2 = null,i.remarks3 = null,i.remarks4 = null,i.remarks5 = null
from dba.invoicedetail i, dba.comrmks c
where  i.iatanum = 'UBSCWT'
and i.recordkey = c.recordkey and i.seqnum = c.seqnum


------- Set remarks2 to GPN
update i
set i.remarks2 = substring(ud.udefdata,1,8)
from dba.invoicedetail i, dba.udef ud
where i.iatanum = 'UBSCWT' and ud.udefnum = 3
and substring(ud.udefdata,1,8) in (select corporatestructure 
	from dba.rollup40 where costructid = 'functional')
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum
and isnull(i.remarks2,'unknown') = ('unknown')

update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where len(remarks2) <> 8 and iatanum = 'UBSCWT' and remarks2 <>'Unknown'

------- Set remarks1 in invoicedetail to have the Trip Purpose code from Udef
update id
set remarks1 = substring(udefdata,1,100)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and u.iatanum = 'ubscwt' and u.udefnum = '1' and remarks1 is null

------- Set remarks5 to Udef 5 (cost center)
update i
set i.remarks5 = substring(udefdata,1,100)
from dba.invoicedetail i, dba.udef ud
where i.iatanum = 'UBSCWT' and ud.udefnum = 5
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum and remarks5 is null

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Remarks Updates Complete B - UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update onlinebooking system
update i
set onlinebookingsystem = 'Y'
from dba.invoicedetail i
where onlinebookingsystem is not NULL and i.iatanum = 'UBSCWT'

update i
set onlinebookingsystem = 'N'
from dba.invoicedetail i
where onlinebookingsystem is NULL and i.iatanum = 'UBSCWT'

update i
set onlinebookingsystem = 'N'
from dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey and origcountry = 'JP' and i.iatanum = 'UBSCWT'

----- Update Text17 with TRACTID -----  LOC -- 5/17/2012
update c
set text17 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where udefnum = '4' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'ubscwt' and text17 is null

update c
set Text17 = 'N/A'
from dba.comrmks c
where isnull(text17,'X') like '%' and not ((text17  like '[1-9][0-9][0-9][0-9][0-9]') or 
(text17 like '[1-9][0-9][0-9][0-9][0-9][0-9]')
or (text17 = 'O')
or(text17 = 'A'))
and text17 <> 'N/A' and IATANUM ='ubscwt'

Update c
set Text17 = 'N/A'
from dba.comrmks c
where Text17 is null and IATANUM = 'ubscwt'

-------Update approver name in text14
update c
set text14 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'ubscwt' and udefnum = '9'   and c.iatanum = 'UBSCWT'

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Approver Name update Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update Air and Hotel Reason Codes from Udids

-------- Air -------------
update c
set text47 = reasoncode1
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum and i.iatanum = 'UBSCWT' and text47 is null

update i
set reasoncode1 = NULL from dba.invoicedetail i where iatanum = 'UBSCWT'

update i
set reasoncode1 = substring(udefdata,1,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udefnum = '2'  and i.iatanum = 'UBSCWT'

------ Hotel ----------------
update c
set text48 = htlreasoncode1
from dba.hotel h, dba.comrmks c
where h.recordkey = c.recordkey and h.seqnum = c.seqnum and h.iatanum = 'UBSCWT' and text48 is null

update h
set htlreasoncode1 = NULL from dba.hotel h where iatanum = 'UBSCWT'

update h
set htlreasoncode1 = substring(udefdata,1,3)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum and udefnum = '8' and h.iatanum = 'UBSCWT'
and SUBSTRING(udefdata,1,3) in ('X10','X11','X12','X13')


update h
set htlreasoncode1 = substring(udefdata,1,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum and udefnum = '8' and h.iatanum = 'UBSCWT'
AND htlreasoncode1 is NULL and SUBSTRING(udefdata,1,3) NOT in ('X10','X11','X12','X13')
SET @TransStart = getdate()

--update h
--set htlreasoncode1 = substring(udefdata,1,3)
--from dba.hotel h, dba.udef u
--where h.recordkey = u.recordkey and h.seqnum = u.seqnum and udefnum = '8' and h.iatanum = 'UBSCWT'
--and substring(udefdata,1,3) in ('X10','X11','X12','X13')

SET @TransStart = getdate()


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='HtlReasonCode1 Update Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Added hotel chain code update provided by Sue 1DEC2009
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, dba.cwthtlchains ch
where len(ht.htlchaincode) > 2 and ht.htlchaincode = ch.cwtcode and iatanum ='UBSCWT'	

-------update car chain code ZL1/ZL2 to ZL and update car chain name to National 3/19/10
update dba.car
set carchainname = 'NATIONAL CAR RENTAL', carchaincode = 'ZL'
where iatanum = 'UBSCWT' and carchainname is null and cardailyrate is not null
and (carchaincode = 'ZL1' or carchaincode = 'ZL2')

-------CAR -- Move remarks values to comrmks
update c
set text42 = remarks1, text43 = remarks2, text44 = remarks3,text45 = remarks4, text46 = remarks5
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and c.iatanum = car.iatanum
and text42 is null and text43 is null and text44 is null and text45 is null and text46 is null
and c.iatanum = 'UBSCWT'

-------CAR --Null remarks fields 
update c
set c.remarks1 = null, c.remarks2 = null,c.remarks3 = null, c.remarks4 = NULL,c.remarks5 = NULL
from dba.car c
where  c.iatanum = 'UBSCWT' and c.remarks1 is not null

-------CAR -- Update remarks from invoicedetail remarks
update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3,
car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car
where i.recordkey = car.recordkey and i.seqnum = car.seqnum and i.iatanum = car.iatanum
and i.iatanum = 'UBSCWT' and car.remarks1 is null
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Car Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------HOTEL -- Move remarks values to comrmks
update c
set text21 = remarks1, text22 = remarks2, text23 = remarks3,text25 = remarks5
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and text21 is null and text22 is null and text23 is null and text25 is null
and c.iatanum = 'UBSCWT'

-------HOTEL --Null remarks fields 
update h
set h.remarks1 = null,h.remarks2 = null,h.remarks3 = null,h.remarks5 = null
from dba.hotel h
where  h.iatanum = 'UBSCWT' and h.remarks1 is not null

-------HOTEL -- Update remarks from invoicedetail remarks
update h
set h.remarks1 = i.remarks1, h.remarks2 = i.remarks2, h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum
and i.iatanum = 'UBSCWT' and h.remarks1 is null

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Hotel Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update null carrier code where carrier num exists
update id
set id.valcarriercode = cr.carriercode
from dba.carriers cr, dba.invoicedetail id
where valcarriernum = carriernumber and valcarriernum is NULL and iatanum = 'UBSCWT'

-------  Update Carrier Names
update id
set id.vendorname = cr.carriername
from dba.carriers cr, dba.invoicedetail id
where id.valcarriercode = cr.carriercode and id.vendorname <> cr.carriername
and iatanum = 'UBSCWT'

update id
set id.segmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.segmentcarriercode = cr.carriercode and id.segmentcarriername <> cr.carriername
and iatanum = 'UBSCWT'

update id
set id.minsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.minsegmentcarriercode = cr.carriercode and id.minsegmentcarriername <> cr.carriername
and iatanum = 'UBSCWT'

update id
set id.noxsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.noxsegmentcarriercode = cr.carriercode and id.noxsegmentcarriername <> cr.carriername
and iatanum = 'UBSCWT'

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Carrier Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update Text10 with refund value for the Days in Country report
update c
set text10 = 'Refunded'
from dba.invoicedetail id, dba.invoicedetail idd, dba.comrmks c
where id.recordkey <> idd.recordkey
and id.documentnumber = idd.documentnumber
and id.firstname = idd.firstname
and id.lastname = idd.lastname and id.recordkey = c.recordkey and id.seqnum = c.seqnum
and id.refundind = 'N' and idd.refundind = 'Y' and id.iatanum = 'UBSCWT' and c.text10 is NULL

update c
set text10 = 'Not Refunded'
from dba.comrmks c
where text10 is NULL and iatanum = 'UBSCWT'

----------------------------------------------------------------------------
-------Modify Invoice dates to be consistant using the ID invoice date
-------..transeg..

update ts
set ts.InvoiceDate = id.Invoicedate
from dba.invoicedetail id, dba.transeg ts
where id.recordkey = ts.recordkey and id.iatanum = ts.iatanum and id.seqnum = ts.seqnum
and id.invoicedate <> ts.invoicedate and id.iatanum = 'UBSCWT'  

--..hotel..
update htl
set htl.InvoiceDate = id.invoicedate
from dba.invoicedetail id, dba.hotel htl
where id.recordkey = htl.recordkey and id.iatanum = htl.iatanum and id.seqnum = htl.seqnum
and id.invoicedate <> htl.invoicedate and id.iatanum = 'UBSCWT' 

--..car..
update car
set car.Invoicedate = id.InvoiceDate
from dba.invoicedetail id, dba.car car
where id.recordkey = car.recordkey and id.iatanum = car.iatanum and id.seqnum = car.seqnum
and id.invoicedate <> car.invoicedate and id.iatanum = 'UBSCWT' 

--..udef..
update ud
set ud.InvoiceDate = id.InvoiceDate
from dba.invoicedetail id, dba.udef ud
where id.recordkey = ud.recordkey and id.iatanum = ud.iatanum and id.seqnum = ud.seqnum
and id.invoicedate <> ud.invoicedate and id.iatanum = 'UBSCWT' 

--..comrmks..
update cr 
set cr.InvoiceDate = id.invoicedate
from dba.invoicedetail id, dba.comrmks cr
where id.recordkey = cr.recordkey and id.iatanum = cr.iatanum and id.seqnum = cr.seqnum
and id.invoicedate <> cr.invoicedate and id.iatanum = 'UBSCWT' 

--..tax..
update tax
set tax.InvoiceDate = id.InvoiceDate
from dba.invoicedetail id, dba.tax tax
where id.recordkey = tax.recordkey and id.iatanum = tax.iatanum and id.seqnum = tax.seqnum
and id.invoicedate <> tax.invoicedate  and id.iatanum = 'UBSCWT' 

--..payment..
Update Pay
set Pay.InvoiceDate = id.InvoiceDate
from dba.invoicedetail id, dba.payment pay
where id.recordkey = pay.recordkey and id.iatanum = pay.iatanum and id.seqnum = pay.seqnum
and id.invoicedate <> pay.invoicedate and id.iatanum = 'UBSCWT' 

--..invoicehaader..
update ih
set ih.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.invoiceheader ih
where id.recordkey = ih.recordkey and id.iatanum = ih.iatanum 
and id.invoicedate <> ih.invoicedate and id.iatanum = 'UBSCWT'
 
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Inv/Iss Date Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------------------------
--Update the comrmks with the Travelers Name from the Hierarchy table provided by UBS.

----- Transaction updates
------- Update Text30 with any values in the remarks2 field that are not in the GPN list
update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i
where i.remarks2 not in (select gpn from dba.Employee)
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and remarks2 not in ('Unknown','999999NE','99999ANE') and c.IATANUM = 'UBSCWT'

------- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 not in (select corporatestructure from dba.rollup40) and IATANUM = 'UBSCWT'

-------Update Remarks2 with Unknown code when remarks2 is NULL
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 is null and IATANUM = 'UBSCWT'

-------Update Tex20 with the Traveler Name from the Hierarchy File

update c set text20 = substring(paxname,1,150)
from dba.Employee e, dba.comrmks c, dba.invoicedetail i
where e.gpn = i.remarks2
and remarks2 not in ('Unknown','99999999','99999990','99999989')
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM = 'UBSCWT'  and isnull(text20,' ') = ' '

------- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used
update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey  AND C.IATANUM =I.IATANUM and c.seqnum = i.seqnum  
and (isnull(c.text20, '- Non GPN') like '%- Non GPN%'
	or c.text20 = ' ')
and ((i.remarks2 like ('99999%')) or (i.remarks2 like ('11111%'))
or (i.remarks2 ='Unknown'))
and i.iatanum = 'UBSCWT'

update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where  remarks2 ='Unknown'
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM = 'UBSCWT' and  isnull(text20,' ') = ' '

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text20 Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------
-- Update issuedates to equal invoicedates
update dba.car
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.comrmks
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.hotel
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.transeg
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM = 'UBSCWT'

update dba.invoicedetail
set issuedate = invoicedate where issuedate <> invoicedate and IATANUM = 'UBSCWT'


------------------------------------------------------------------
-- Update the booking data to the invoice date where null per email
-- from UBS on 11/11/11.

update dba.invoicedetail
set bookingdate = invoicedate
where bookingdate is null and IATANUM = 'UBSCWT'

------Update Text5 with the region 
update c
set text5 = rollup2
from dba.rollup40 r, dba.invoicedetail i, dba.comrmks c
where r.corporatestructure = i.remarks2
and i.recordkey = c.recordkey and i.seqnum = c.seqnum
and remarks2 not like ('99999%') and costructid = 'GEO' and c.iatanum ='UBSCWT'

update cr
set text5 = 'Europe EMEA'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AT','AE','BE','CZ','FR','DE','HU','IL','IT','LU','NL','PL','RU','ES','SA','SE','CH','TR','GB','ZA')
and isnull(text5,'Unknown') = 'Unknown' and cr.iatanum ='UBSCWT'

update cr
set text5 = 'Asia Pacific'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AU','CN','HK','ID','IN','JP','MY','NZ','PH','KR','SG','TW','TH')
and cr.iatanum ='UBSCWT' and isnull(text5,'Unknown') = 'Unknown'

update cr
set text5 = 'Americas'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('US','CA','BR')
and cr.iatanum ='UBSCWT' and isnull(text5,'Unknown') = 'Unknown'

-----------------------------------------------------------------------
---**********************************************************************************
---This should begin to show up correctly in the Aug data ------------------------------


----- Update Opportunity/Project Code ----Remarks4 from Udef 7 ----- LOC 5/17/2012
----- This is on hold until CWT confirms.  As of now I see a country name in the UDID 7 field
------ added back in per Yap - 6/18/2013

update c
set text7 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'ubscwt'
and udefnum = '7' and text7 is null
and c.invoicedate > '6-1-2012'

----- Update Text8 with Booker GPN -- Per CWT on 5/16/2012 this is not yet in place so we may
----- not see a lot of movement for a month or 2 ...-- As well they will only be able to provide
----- the first and last name and not the GPN---------- LOC 5/17/2012 --------------------------

update c
set text8 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where udefnum = '6' and c.iatanum = 'ubscwt' and isnull(text8,'Not') like 'Not%'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum

----- Update Text14 with Approver GPN -- -- As well they will only be able to provide
----- the first and last name and not the GPN---------- LOC 5/17/2012 ---------------

update c
set text14 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where udefnum = '9' and c.iatanum = 'ubscwt' and isnull(text14,'Not') like 'Not%'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text14 Approver GPN Updates Complete- UBSCWT-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------Start  Udef String data for Validation report ---------LOC  7/31/2012

-------Update Text22 = GPN String----------------------------------- LOC 7/31/2012
update c
set text22 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text22 is null and udefnum = '3' and c.iatanum = 'UBSCWT' 

-------Update Text23 = Trip Purpose String--------------------------- LOC 7/31/2012
update c
set text23 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text23 is null and udefnum = '1' and c.iatanum = 'UBSCWT' 

-------Update Text24 = Cost Center String --------------------------- LOC 7/31/2012
update c
set text24 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text24 is null and udefnum = '5' and c.iatanum = 'UBSCWT' 

---- Not putting in Air and Hotel Reason Codes (Text25 and Text26 as they are in the actual
---- data fields and not from a string of data or udef.---- LOC/7/31/2012

-------Update Text27 = TractID String --------------------------- LOC 7/31/2012
update c
set text27 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text27 is null and udefnum = '4' and c.iatanum = 'UBSCWT' 

------ Will add Booker  once we have confirmed ----- LOC 7/31/2012

-------Update Text29 = Approver GPN String --------------------------- LOC 7/31/2012
update c
set text29 = substring(Udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text29 is null and udefnum = '9' and c.iatanum = 'UBSCWT' 


-----Online booking is Y if there is a value and N if not so no mapping required for
--  the validation..loc/7/31/2012.

update c
set num1 = htlcomparerate2
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum
and num1 is null
and c.IATANUM like 'UBSCWT'

update dba.hotel
set htlcomparerate2 = NULL
where htlcomparerate2 is not NULL
and IATANUM like 'UBSCWT'


--------update Product Type ---- LOC/11/30/2012
update t1
set producttype = 'Air'
from dba.invoicedetail t1, dba.transeg t2
where t1.recordkey = t2.recordkey
and t1.iatanum = t2.iatanum and t1.seqnum = t2.seqnum and t1.clientcode = t2.clientcode 
and t1.vendortype in ('BSP','NONBSP') and t1.producttype <> 'Air'
and t2.typecode = 'A'  and t1.IATANUM = 'UBSCWT'

update t1
set producttype = 'Hotel'
from dba.invoicedetail t1, dba.hotel t2
where t1.recordkey = t2.recordkey and t1.iatanum = t2.iatanum and t1.seqnum = t2.seqnum
and t1.clientcode = t2.clientcode and t1.issuedate = t2.issuedate and vendortype = 'NONAIR'
and t1.producttype <> 'Hotel'  and t1.IATANUM = 'UBSCWT'

update t1
set producttype = 'Car'
from dba.invoicedetail t1, dba.car t2
where t1.recordkey = t2.recordkey and t1.iatanum = t2.iatanum and t1.seqnum = t2.seqnum
and t1.clientcode = t2.clientcode and t1.issuedate = t2.issuedate and vendortype = 'NONAIR'
and t1.producttype <> 'Car'  and t1.IATANUM = 'UBSCWT'

update t1 
set producttype = 'Misc' from dba.invoicedetail t1 where producttype in ('M','R','H','C')
and vendortype = 'NONAIR'  and t1.IATANUM = 'UBSCWT'

update dba.invoicedetail
set producttype = 'FEES' where vendortype = 'FEES'
and iatanum = 'UBSCWT' and producttype <> 'FEES'

-------- Update hotel and car dupe flags to N incase of data reload or changes .. LOC/4/23/2013
update dba.hotel set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and Iatanum = 'UBSCWT'
update dba.car set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and Iatanum = 'UBSCWT'

-------- Update hotel dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.hotel First , dba.hotel Second, dba.InvoiceHeader IH
where First.Iatanum = 'UBSCWT' and second.IataNum = 'UBSCWT' and ih.IataNum = 'UBSCWT'
and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum and First.IssueDate < Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and datediff(dd,first.checkindate,second.checkindate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.RecordKey = ih.RecordKey and First.IataNum = ih.IataNum
and First.InvoiceDate = ih.InvoiceDate and first.ClientCode = ih.ClientCode
and Second.RecordKey = ih.RecordKey and Second.IataNum = ih.IataNum
and Second.InvoiceDate = ih.InvoiceDate and Second.ClientCode = ih.ClientCode
and first.invoicedate > '12-31-2010'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel Dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
-------- Update Car dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.car First , dba.car Second, dba.InvoiceHeader IH
where First.Iatanum = 'Preubs' and second.IataNum = 'preubs' and ih.IataNum = 'preubs'
and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum and First.IssueDate < Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and datediff(dd,first.pickupdate,second.pickupdate) <5 and First.voidind = 'N'
and Second.voidind = 'N' and first.RecordKey = ih.RecordKey and First.IataNum = ih.IataNum
and First.InvoiceDate = ih.InvoiceDate and first.ClientCode = ih.ClientCode and Second.RecordKey = ih.RecordKey
and Second.IataNum = ih.IataNum and Second.InvoiceDate = ih.InvoiceDate and Second.ClientCode = ih.ClientCode
and first.invoicedate > '12-31-2010'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Move document number to Text4 where length is greater than 10 .. LOC/5/28/2013
update c
set text4 = documentnumber
from dba.comrmks c, dba.invoicedetail id
where c.recordkey = id.recordkey  and c.seqnum = id.seqnum
and len(documentnumber) > 10 and id.iatanum = 'UBSCWT' and id.recordkey = c.recordkey

update id
set documentnumber = substring(documentnumber,6,10)
from dba.invoicedetail id, dba.ccticket cct
where len(documentnumber) > 10
and id.iatanum <> 'preubs' and id.invoicedate > '12-31-2011' and id.iatanum like 'ubscwt%'
and vendortype in ('bsp','nonbsp') and substring(documentnumber,6,10) = ticketnum 
and substring(passengername,1,5) = substring((lastname+'/'+firstname),1,5)
and matchedrecordkey is null


SET @TransStart = getdate()

-------- Update the min and nox segment mileage where it is negative when it should be positive.
-------- This is happening throught the .dll and is occuring with exchanges.  -- This is affecting
-------- the UBS Segment Mileage reports ----- LOC/9/27/2013
update t
set  noxsegmentmileage = noxsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and noxsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'
and i.iatanum = 'ubscwt'

update t
set  minsegmentmileage = minsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and minsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'
and i.iatanum = 'ubscwt'

update i
set  mileage = mileage*-1
from dba.invoicedetail i
where i.mileage <0 
and i.invoicedate > '1-1-2012' and i.exchangeind = 'y'
and i.iatanum = 'ubscwt'

-------- Update Refundable / Non refundable Indicator from the Pre Trip data as not received in the CWT feed..LOC/8/8/2014
update boc
set boc.text9 = ptc.text9--, count(*)
from dba.invoicedetail boi, dba.invoicedetail pti, dba.comrmks boc, dba.comrmks ptc
where boi.recordkey = boc.recordkey and boi.seqnum = boc.seqnum
and pti.recordkey = ptc.recordkey and pti.seqnum = ptc.seqnum
and boi.iatanum = 'ubscwt' and pti.iatanum = 'preubs'
and boi.voidind = 'n' and pti.voidind = 'n'
and boi.gdsrecordlocator = pti.gdsrecordlocator
and boi.documentnumber = pti.documentnumber
and boi.invoicedate >= '1-1-2012'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBSCWT mileage update-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Update data based on montly update file sent by Ryan for reasoncodes, GPN, Approvers etc
SET @TransStart = getdate()

--------- Reason code Updates ---------------------------
update i
set i.reasoncode1 = d.ReasonCode
from dba.invoicedetail i, dba.DataUpdates d
where product = 'Air' and i.recordkey = d.recordidentifier
and i.gdsrecordlocator = d.recordlocator 
and d.reasoncode is not NULL
--and d.reasoncode not in ( NULL ,'')
AND I.Seqnum=D.Sequence
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' 
and lookupname = 'rcda')
and i.reasoncode1 <> d.reasoncode
AND D.ImportDt>= '2014-01-01'
and I.iatanum = 'ubscwt'

update h
set h.htlreasoncode1 = d.ReasonCode
from dba.hotel h, dba.DataUpdates d
where product = 'Hotel' and h.recordkey = d.recordidentifier
and d.reasoncode is not NULL
--and d.reasoncode not in ( NULL ,'')
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcdh')
and h.htlreasoncode1 <> d.reasoncode
AND H.Seqnum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and H.iatanum = 'ubscwt'


update c
set c.carreasoncode1 = d.ReasonCode
from dba.car c, dba.DataUpdates d
where product = 'Car' and c.recordkey = d.recordidentifier
and d.reasoncode is not NULL
--and d.reasoncode not in ( NULL ,'')
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcdc')
and c.carreasoncode1 <> d.reasoncode
AND C.Seqnum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and C.iatanum = 'ubscwt'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ReasonCode Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

--------- Update Booker and Approver GPN's and Names ----------------------------------------------------
update c
set text14 = ApproverGPN
from dba.comrmks c, dba.dataupdates d
where c.recordkey = d.recordidentifier
and approvergpn is not null
--and approvergpn not in ( NULL ,'') 
and approvergpn <> text14
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and c.iatanum = 'ubscwt'
------ Once GPN is updated -- update name ---------
update c
set text2 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text2 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)
and c.iatanum = 'ubscwt'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UPDATE-approver GPNS AND NAME-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------- Update Booker GPN and Name ----------------------------------------------------
update c
set text8 = BookerGPN
from dba.comrmks c, dba.dataupdates d
where c.recordkey = d.recordidentifier
and BookerGPN is not null
--and bookergpn not in ( NULL ,'') 
and bookergpn <> text8
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and c.iatanum = 'ubscwt'

------ Once BookerGPN is updated -- update name ---------
update c
set text1 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text1 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)
and c.iatanum = 'ubscwt'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update Booker GPN and Name-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------- Update Traveler GPN AND NAME  ----------------------------------------------------
UPDATE id
SET id.remarks2 = d.TravelerGPN
FROM dba.InvoiceDetail id, dba.DataUpdates d
WHERE id.RecordKey=d.RecordIdentifier
--AND d.TravelerGPN not in ( NULL ,'')
AND d.TravelerGPN is not NULL 
AND d.TravelerGPN <> id.Remarks2 
AND ID.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

UPDATE htl
SET htl.remarks2 = d.TravelerGPN
FROM dba.DataUpdates d, dba.hotel htl
WHERE d.RecordIdentifier = htl.RecordKey
AND d.PRODUCT = 'hotel'
AND d.BookerGPN IS NOT NULL
--AND d.BookerGPN not in ( NULL ,'')
AND d.BookerGPN <> htl.Remarks2
AND HTL.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

UPDATE car
SET car.remarks2 = d.TravelerGPN
FROM dba.DataUpdates d, dba.car car
WHERE d.RecordIdentifier = car.RecordKey
AND d.PRODUCT = 'car'
AND d.TravelerGPN IS NOT NULL
--AND d.TravelerGPN not in ( NULL ,'')
AND d.TravelerGPN <> car.Remarks2
AND CAR.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'


------ Once Traveler GPN is updated -- update name ---------
update c
set text20 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text20 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdatesTemp)
and c.iatanum = 'ubscwt'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UPDATE-TRAVELER GPNS AND NAME-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

------ update TractID ---------
UPDATE c
SET c.text17 = d.tractid
FROM dba.ComRmks c, dba.DataUpdates d
WHERE d.RecordIdentifier = c.RecordKey
AND d.TractID IS NOT NULL
--AND d.TractID not in ( NULL ,'')
AND d.TractID <> c.Text17
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and c.iatanum = 'ubscwt'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update TractID-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


------ update Trip Purpose ---------
UPDATE id
SET id.remarks1 = d.TripPurpose
FROM dba.invoicedetail id, dba.DataUpdates d
WHERE d.RecordIdentifier = id.RecordKey
AND d.trippurpose IS NOT NULL
--AND d.trippurpose not in ( NULL ,'')
AND d.trippurpose <> id.remarks1
AND id.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
and Id.iatanum = 'ubscwt'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update TripPurpose-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----********************************************************************************************
------------- These updates must remain in the SP so they are run prior to the Exchange Refund process
------------- These updates were approved by UBS on 3/0/2015 to clean up the ticket numbers where the TMC's are
------------- adding digits to the end/beginning of the numbers.  This is causing issues with matchback as the 
------------- Refund Exchange process.... LOC
-------------
------------- Updates for tickets that have 14 digets.  Updating to 10.  this is for the original document number
------------- removing the last 4 digits.  the -O in the Text12 field will denote that this is an original Ticket Number
update c
set text12 = io.documentnumber +' -O'
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '14' and len(ie.origexchtktnum) = '10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2013' and text12 is null
and io.iatanum <> 'preubs'

Update io
set io.documentnumber = substring (io.documentnumber,1,10)
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '14' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 = io.documentnumber+' -O'
and io.iatanum <> 'preubs'

------------- Updates for tickets that have 13 digets.  Updating to 10.  this is for the original document number
------------- removing the last 4 digits.  the -O in the Text12 field will denote that this is an original Ticket Number
update c
set text12 = io.documentnumber +' -O'
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '13' and len(ie.origexchtktnum) = '10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2013' and text12 is null
and io.iatanum <> 'preubs'

Update io
set io.documentnumber = substring (io.documentnumber,1,10)
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '13' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,1,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 = io.documentnumber+' -O'
and io.iatanum <> 'preubs'

------------- Updates for tickets that have 15 digets.  Updating to 10.  this is for the original document number
------------- removing the first 5 digets.  the -O in the Text12 field will denote that this is an original Ticket Number
------------- Adding this to CWT procedure on production -- these are APAC transactions for the most part.
update c
set text12 = io.documentnumber +' -O'
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '15' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,6,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 is null
and io.iatanum <> 'preubs'

Update io
set io.documentnumber = substring (io.documentnumber,1,10)
from dba.invoiceheader ih, dba.invoicedetail io, dba.invoicedetail ie, dba.comrmks c
where ih.recordkey = io.recordkey and c.recordkey = io.recordkey and c.seqnum = io.seqnum
and len(io.documentnumber) = '15' and len(ie.origexchtktnum) ='10'
and substring(io.documentnumber,6,10) = ie.origexchtktnum and io.tktwasexchangedind is null
and io.invoicedate > '12-31-2012' and text12 = io.documentnumber+' -O'
and io.iatanum <> 'preubs'
----********************************************************************************************


EXEC TTXPASQL01.tman_ubs.dbo.sp_RefundExchange
@BEGINISSUEDATE=@BEGINISSUEDATE,
@ENDISSUEDATE=@ENDISSUEDATE 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Updates complete -- Refund Exchange Excecuted',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
------ update lowAirFare and Full Air Fare ---------
--UPDATE id
--SET id.farecompare2 = ISNULL(D.lowfare,0)*CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase
--FROM dba.invoicedetail id, 
--dba.DataUpdates d
--INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate AND CURRBASE.BaseCurrCode = d.currcode 
--INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
--WHERE d.RecordIdentifier = id.RecordKey
--and product = 'Air'
--and CURRTO.CurrCode ='USD'
--AND d.lowairfare not in ( NULL ,'')
--AND d.lowairfare <> id.farecompare2
--AND id.SeqNum=D.Sequence
--and d.importdt>='2014-01-01
--and Id.iatanum = 'ubscwt'



--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='Update LowFare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--UPDATE id
--SET id.farecompare1 = d.fullairfare *(need currency conversion)
--FROM dba.invoicedetail id, dba.DataUpdates d
--INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate AND CURRBASE.BaseCurrCode = d.currcode 
--INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
--WHERE d.RecordIdentifier = id.RecordKey
--and product = 'Air'
--and CURRTO.CurrCode ='USD'
--AND d.fullairfare not in ( NULL ,'')
--AND d.fullairfare <> id.farecompare1
--AND id.SeqNum=D.Sequence
--AND D.ImportDt>= '2014-01-01'
--and Id.iatanum = 'ubscwt'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='Update FullFare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBSCWT DataUpdates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


--------******** Update Staging with CWT data for ACM Procdessing ********************--------
insert into TTXSASQL01.Tman_UBS.dba.Client
select * 
from dba.client where clientcode not in (select clientcode 
from TTXSASQL01.Tman_UBS.dba.Client where iatanum ='UBSCWT')
and iatanum = 'UBSCWT'

insert into TTXSASQL01.Tman_UBS.dba.Invoiceheader
select * 
from dba.Invoiceheader where recordkey not in (select recordkey 
from TTXSASQL01.Tman_UBS.dba.Invoiceheader where iatanum ='UBSCWT' and invoicedate > '12-31-2013')
and iatanum = 'UBSCWT' and invoicedate > '12-31-2013'

insert into TTXSASQL01.Tman_UBS.dba.Invoicedetail
select * 
from dba.Invoicedetail where recordkey+convert(varchar,seqnum) not in (select recordkey +convert(varchar,seqnum)
from TTXSASQL01.Tman_UBS.dba.Invoicedetail where iatanum ='UBSCWT' and invoicedate > '12-31-2013')
and iatanum = 'UBSCWT' and invoicedate > '12-31-2013'

insert into TTXSASQL01.Tman_UBS.dba.Transeg
select * 
from dba.Transeg where recordkey+convert(varchar,seqnum) not in (select recordkey +convert(varchar,seqnum)
from TTXSASQL01.Tman_UBS.dba.Transeg where iatanum ='UBSCWT' and invoicedate > '12-31-2013')
and iatanum = 'UBSCWT' and invoicedate > '12-31-2013'
--****************************************************************
EXEC dbo.sp_ACM_AutoProcess_UBS
--****************************************************************
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ACM process SP Kicked Off',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------------------------------------------------
---HNN Cleanup for DEA
--Make sure to update the Iatanums for all agency data and update the production server
--ADDED per Case #19267.... TBo 07.30.2013

--Clean up hotel spaces
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from TTXPASQL01.TMAN_UBS.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Clean up unwanted characters in htlpropertyname and htladdr1
--Added on 4/18/13 by Nina per case 00011353
SET @TransStart = getdate()
UPDATE TTXPASQL01.TMAN_UBS.DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',','')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update TTXPASQL01.TMAN_UBS.dba.hotel
set masterid = -1
where masterid is null
and htlpropertyname like 'OTHER%HOTELS%'
or htlpropertyname like '%NONAME%'
and invoicedate > '2011-12-31'

-------------------------------------------------------------------------------------
 ---Pam S added:
SET @TransStart = getdate()
update TTXPASQL01.TMAN_UBS.dba.hotel
set htladdr1 = htladdr2
,htladdr2 = null
where masterid is null
and htladdr1 is null
and htladdr2 is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Move htladdr2 to 1 when null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update TTXPASQL01.TMAN_UBS.dba.hotel
set htladdr2 = null
where htladdr2 = htladdr1

------------------------------------------------------------------------

update TTXPASQL01.TMAN_UBS.dba.hotel
set masterid = -1
where masterid is null
and htlpropertyname is null
and htladdr1 is null
and invoicedate > '2011-12-31'

 update TTXPASQL01.TMAN_UBS.dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = ''
or HtlAddr1 is null or HtlAddr1 = '' )
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Parent id -1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update htl
set htl.htlcountrycode = ct.countrycode
,htl.htlstate = ct.stateprovincecode
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXPASQL01.TMAN_UBS.dba.city ct
where htl.htlcitycode = ct.citycode
and  htl.masterid is null
and htl.htlcountrycode is null
and ct.countrycode <> 'ZZ'
and ct.typecode ='a'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Country',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update htl
set htl.htlstate = t2.stateprovincecode
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXPASQL01.TMAN_UBS.dba.city t2
where t2.typecode = 'A'
and htl.htlcitycode = t2.citycode
and htl.htlcountrycode = t2.countrycode
and htl.htlstate is null
and htl.htlcountrycode = 'US'
and t2.countrycode = 'US'
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='State when Country = US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update htl
set htl.htlcountrycode = ct.countrycode
,htl.htlstate = ct.stateprovincecode
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXPASQL01.TMAN_UBS.dba.city ct
where htl.htlcitycode = ct.citycode
and  htl.masterid is null
and htl.htlcountrycode <> ct.countrycode
and ct.typecode ='a'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='State',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update htl
set htl.htlstate = zp.state
from TTXPASQL01.TMAN_UBS.dba.hotel htl, TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
where substring(htl.htlpostalcode,1,5) = zp.zipcode
and substring(htl.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P'
and htl.masterid is null
and htl.htlstate is null
and htl.htlcountrycode = 'US'
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update TTXPASQL01.TMAN_UBS.dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN_UBS.dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null
and invoicedate > '2011-12-31'

UPDATE TTXPASQL01.TMAN_UBS.dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null
and invoicedate > '2011-12-31'

	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'HERTOGENBOSCH'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%MOEVENPICK HOTEL%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%OAKWOOD CHELSEA%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%LONGACRE HOUSE%'
	and invoicedate > '2011-12-31'


	update TTXPASQL01.TMAN_UBS.dba.hotel
	set htlcityname = 'BARCELONA'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%HOTLE PUNTA PALMA%'
	and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End htl edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBSCWT Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

	
--add to the end after HNN cleanup sql's run
--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from  TTXPASQL01.TMAN_UBS.dba.Hotel
Where MasterId is NULL
and invoicedate > '2011-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'UBSCWT',
@Enhancement = 'HNN',
@Client = 'UBS',
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
@TextParam2 = 'TTXPASQL01',
@TextParam3 = 'TMAN_UBS',
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

 
/************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  








































GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_CWT] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ROLLUP40]    Script Date: 7/13/2015 1:14:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ROLLUP40](
	[COSTRUCTID] [varchar](50) NULL,
	[CORPORATESTRUCTURE] [varchar](50) NULL,
	[DESCRIPTION] [varchar](255) NULL,
	[ROLLUP1] [varchar](50) NULL,
	[ROLLUPDESC1] [varchar](255) NULL,
	[ROLLUP2] [varchar](50) NULL,
	[ROLLUPDESC2] [varchar](255) NULL,
	[ROLLUP3] [varchar](50) NULL,
	[ROLLUPDESC3] [varchar](255) NULL,
	[ROLLUP4] [varchar](50) NULL,
	[ROLLUPDESC4] [varchar](255) NULL,
	[ROLLUP5] [varchar](50) NULL,
	[ROLLUPDESC5] [varchar](255) NULL,
	[ROLLUP6] [varchar](50) NULL,
	[ROLLUPDESC6] [varchar](255) NULL,
	[ROLLUP7] [varchar](50) NULL,
	[ROLLUPDESC7] [varchar](255) NULL,
	[ROLLUP8] [varchar](50) NULL,
	[ROLLUPDESC8] [varchar](255) NULL,
	[ROLLUP9] [varchar](50) NULL,
	[ROLLUPDESC9] [varchar](255) NULL,
	[ROLLUP10] [varchar](50) NULL,
	[ROLLUPDESC10] [varchar](255) NULL,
	[ROLLUP11] [varchar](50) NULL,
	[ROLLUPDESC11] [varchar](255) NULL,
	[ROLLUP12] [varchar](50) NULL,
	[ROLLUPDESC12] [varchar](255) NULL,
	[ROLLUP13] [varchar](50) NULL,
	[ROLLUPDESC13] [varchar](255) NULL,
	[ROLLUP14] [varchar](50) NULL,
	[ROLLUPDESC14] [varchar](255) NULL,
	[ROLLUP15] [varchar](50) NULL,
	[ROLLUPDESC15] [varchar](255) NULL,
	[ROLLUP16] [varchar](50) NULL,
	[ROLLUPDESC16] [varchar](255) NULL,
	[ROLLUP17] [varchar](50) NULL,
	[ROLLUPDESC17] [varchar](255) NULL,
	[ROLLUP18] [varchar](50) NULL,
	[ROLLUPDESC18] [varchar](255) NULL,
	[ROLLUP19] [varchar](50) NULL,
	[ROLLUPDESC19] [varchar](255) NULL,
	[ROLLUP20] [varchar](50) NULL,
	[ROLLUPDESC20] [varchar](255) NULL,
	[ROLLUP21] [varchar](50) NULL,
	[ROLLUPDESC21] [varchar](255) NULL,
	[ROLLUP22] [varchar](50) NULL,
	[ROLLUPDESC22] [varchar](255) NULL,
	[ROLLUP23] [varchar](50) NULL,
	[ROLLUPDESC23] [varchar](255) NULL,
	[ROLLUP24] [varchar](50) NULL,
	[ROLLUPDESC24] [varchar](255) NULL,
	[ROLLUP25] [varchar](50) NULL,
	[ROLLUPDESC25] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ROLLUP40] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[QSI]    Script Date: 7/13/2015 1:15:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[QSI](
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

ALTER AUTHORIZATION ON [DBA].[QSI] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:15:06 PM ******/
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

/****** Object:  Table [DBA].[Payment]    Script Date: 7/13/2015 1:15:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Payment](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[PaymentSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
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
	[CCLastFour] [varchar](4) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Payment] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[OpCarXRef]    Script Date: 7/13/2015 1:15:13 PM ******/
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

/****** Object:  Table [DBA].[LookupData]    Script Date: 7/13/2015 1:15:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[LookupData](
	[LookupName] [varchar](30) NOT NULL,
	[ParentNode] [int] NOT NULL,
	[LookupValue] [varchar](100) NOT NULL,
	[LookupText] [varchar](255) NULL,
	[LookupNumber] [float] NULL,
	[LookupDate] [datetime] NULL,
	[Node] [int] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[LookupData] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/13/2015 1:15:14 PM ******/
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

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 1:15:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
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
	[TktCO2Emissions] [float] NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [DBA].[InvoiceDetail] ADD [CCMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CCMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CarrierString] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ClassString] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [LastImportDt] [datetime] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [GolUpdateDt] [datetime] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigTktAmt] [float] NULL
SET ANSI_PADDING ON
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktWasExchangedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TicketGroupId] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OriginalDocumentNumber] [varchar](15) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigBaseFare] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktOrder] [int] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigFareCompare1] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigFareCompare2] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktWasRefundedInd] [char](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [NetTktAmt] [float] NULL

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Hotel]    Script Date: 7/13/2015 1:15:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Hotel](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[HtlSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
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
	[MasterID] [int] NULL,
	[CO2Emissions] [float] NULL,
	[MilesFromAirport] [float] NULL,
	[GroundTransCO2] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Hotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Employee]    Script Date: 7/13/2015 1:15:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Employee](
	[GPN] [varchar](25) NULL,
	[PaxName] [varchar](250) NULL,
	[Status] [varchar](40) NULL,
	[ROLLUP2] [varchar](250) NULL,
	[ROLLUP3] [varchar](250) NULL,
	[ROLLUP4] [varchar](250) NULL,
	[ROLLUP5] [varchar](250) NULL,
	[ROLLUP6] [varchar](250) NULL,
	[ROLLUP7] [varchar](250) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ChangeDate] [datetime] NULL,
	[ROLLUP8] [varchar](250) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Employee] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[DataUpdatesTemp]    Script Date: 7/13/2015 1:15:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[DataUpdatesTemp](
	[RequestName] [varchar](50) NULL,
	[PRODUCT] [varchar](50) NULL,
	[RecordIdentifier] [varchar](50) NULL,
	[Sequence] [varchar](5) NULL,
	[RecordLocator] [varchar](10) NULL,
	[HotelName] [varchar](200) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNumber] [varchar](10) NULL,
	[TicketNumber] [varchar](255) NULL,
	[ReasonCode] [varchar](10) NULL,
	[TripPurpose] [varchar](10) NULL,
	[ApproverGPN] [varchar](10) NULL,
	[ApproverName] [varchar](50) NULL,
	[BookerGPN] [varchar](10) NULL,
	[BookerName] [varchar](50) NULL,
	[TravelerGPN] [varchar](10) NULL,
	[TractID] [varchar](10) NULL,
	[LowAirFare] [float] NULL,
	[FullAirFare] [float] NULL,
	[TicketAirAmount] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SegNum] [smallint] NULL,
	[ImportDt] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[DataUpdatesTemp] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[dataupdates]    Script Date: 7/13/2015 1:15:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[dataupdates](
	[RequestName] [varchar](50) NULL,
	[PRODUCT] [varchar](50) NULL,
	[RecordIdentifier] [varchar](50) NULL,
	[Sequence] [varchar](5) NULL,
	[RecordLocator] [varchar](10) NULL,
	[HotelName] [varchar](200) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNumber] [varchar](10) NULL,
	[TicketNumber] [varchar](255) NULL,
	[ReasonCode] [varchar](10) NULL,
	[TripPurpose] [varchar](10) NULL,
	[ApproverGPN] [varchar](10) NULL,
	[ApproverName] [varchar](50) NULL,
	[BookerGPN] [varchar](10) NULL,
	[BookerName] [varchar](50) NULL,
	[TravelerGPN] [varchar](10) NULL,
	[TractID] [varchar](10) NULL,
	[LowAirFare] [float] NULL,
	[FullAirFare] [float] NULL,
	[TicketAirAmount] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SegNum] [smallint] NULL,
	[ImportDt] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[dataupdates] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CWTHtlChains]    Script Date: 7/13/2015 1:15:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [DBA].[CWTHtlChains](
	[CWTCode] [nvarchar](3) NULL,
	[CWTChainName] [nvarchar](50) NULL,
	[TRXCode] [nvarchar](2) NULL,
	[TRXChainName] [nvarchar](50) NULL,
	[BrandName] [nvarchar](50) NULL
) ON [PRIMARY]

GO

ALTER AUTHORIZATION ON [DBA].[CWTHtlChains] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CustRollup]    Script Date: 7/13/2015 1:15:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CustRollup](
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

ALTER AUTHORIZATION ON [DBA].[CustRollup] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Country]    Script Date: 7/13/2015 1:15:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Country](
	[CtryCode] [varchar](5) NULL,
	[CtryName] [varchar](25) NULL,
	[IntlDomCode] [varchar](1) NULL,
	[ContinentCode] [varchar](2) NULL,
	[PhnCode] [varchar](4) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[TSLATEST] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Country] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ContractRmks]    Script Date: 7/13/2015 1:15:54 PM ******/
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

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/13/2015 1:16:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ComRmks](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
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
	[Int20] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Client]    Script Date: 7/13/2015 1:16:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Client](
	[ClientCode] [varchar](15) NULL,
	[IataNum] [varchar](8) NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[State] [varchar](20) NULL,
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
	[ClientRemark10] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCTicket]    Script Date: 7/13/2015 1:16:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCTicket](
	[RecordKey] [varchar](70) NULL,
	[IataNum] [varchar](8) NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[TktReferenceNum] [varchar](23) NULL,
	[TicketNum] [varchar](10) NULL,
	[ValCarrierCode] [varchar](3) NULL,
	[ValCarrierNum] [int] NULL,
	[TktOriginatingCCNum] [varchar](50) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[TransFeeInd] [varchar](1) NULL,
	[IssuerCity] [varchar](30) NULL,
	[IssuerState] [varchar](6) NULL,
	[ServiceDate] [datetime] NULL,
	[Routing] [varchar](40) NULL,
	[ClassOfService] [varchar](20) NULL,
	[TicketIssuer] [varchar](37) NULL,
	[BookedIataNum] [varchar](8) NULL,
	[PassengerName] [varchar](50) NULL,
	[OrigTicketNum] [varchar](10) NULL,
	[Remarks1] [varchar](40) NULL,
	[Remarks2] [varchar](40) NULL,
	[Remarks3] [varchar](40) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BilledDate] [datetime] NULL,
	[CarrierStr] [varchar](30) NULL,
	[TicketAmt] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BatchName] [varchar](30) NULL,
	[MerchantId] [varchar](40) NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[MatchedSeqNum] [int] NULL,
	[InternationalInd] [varchar](1) NULL,
	[Mileage] [float] NULL,
	[DaysAdvPurch] [smallint] NULL,
	[AdvPurchGroup] [varchar](20) NULL,
	[TrueTktCount] [smallint] NULL,
	[TripLength] [smallint] NULL,
	[AncillaryFeeInd] [int] NULL,
	[ServiceCat] [varchar](2) NULL,
	[AlternateName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCTicket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Carriers]    Script Date: 7/13/2015 1:16:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Carriers](
	[CarrierCode] [varchar](3) NOT NULL,
	[TypeCode] [char](1) NOT NULL,
	[Status] [char](1) NOT NULL,
	[CarrierName] [varchar](50) NOT NULL,
	[CarrierNumber] [smallint] NOT NULL,
 CONSTRAINT [PK_Carriers] PRIMARY KEY CLUSTERED 
(
	[CarrierCode] ASC,
	[TypeCode] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Carriers] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Car]    Script Date: 7/13/2015 1:16:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Car](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[CarSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
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
	[CarDropOffCityName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Car] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[AirlineContracts]    Script Date: 7/13/2015 1:16:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[AirlineContracts](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[AirlineName] [varchar](30) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[CustomerType] [varchar](2) NOT NULL,
	[ContractExtension] [int] NULL,
	[ContractSignedDate] [datetime] NULL,
	[Description] [varchar](100) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[Approved] [bit] NULL,
	[Notes] [varchar](1000) NULL,
	[Scenario] [char](1) NULL,
	[Processed] [char](1) NULL,
	[DNADomAdjustment] [float] NULL,
	[DNAIntAdjustment] [float] NULL,
	[ContractCarrierCodes] [varchar](255) NULL,
	[MeasureGoalsOnDate] [char](1) NULL,
	[MeasurePayOnDate] [char](1) NULL,
	[GoalMeasurementPeriod] [char](1) NULL,
	[PayMeasurementPeriod] [char](1) NULL,
	[GDS] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[AirlineContracts] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[AirlineContractMarkets]    Script Date: 7/13/2015 1:16:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[AirlineContractMarkets](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[ExhibitNumber] [int] NOT NULL,
	[MarketNumber] [int] NOT NULL,
	[Description] [varchar](200) NULL,
	[RouteType] [varchar](2) NULL,
	[ConnectionInd] [varchar](2) NULL,
	[OriginCityOperand] [varchar](2) NULL,
	[OriginCity] [varchar](2000) NULL,
	[DestinationCityOperand] [char](1) NULL,
	[DestinationCity] [varchar](2000) NULL,
	[OriginStateOperand] [char](1) NULL,
	[OriginState] [varchar](2000) NULL,
	[DestinationStateOperand] [char](1) NULL,
	[DestinationState] [varchar](2000) NULL,
	[OriginCountryOperand] [char](1) NULL,
	[OriginCountry] [varchar](2000) NULL,
	[DestinationCountryOperand] [char](1) NULL,
	[DestinationCountry] [varchar](2000) NULL,
	[ClassOfServiceOperand] [char](1) NULL,
	[ClassOfService] [varchar](255) NULL,
	[FareBasisOperand] [char](1) NULL,
	[FareBasis] [varchar](2000) NULL,
	[FlownCarriersOperand] [char](1) NULL,
	[FlownCarriers] [varchar](255) NULL,
	[TourCode] [varchar](255) NULL,
	[TicketDesignator] [varchar](15) NULL,
	[FlightNumberOperand] [char](1) NULL,
	[FlightNumber] [varchar](2000) NULL,
	[OriginContinentOperand] [char](1) NULL,
	[OriginContinent] [varchar](2000) NULL,
	[DestContinentOperand] [char](1) NULL,
	[DestContinent] [varchar](2000) NULL,
	[DirectionalInd] [char](1) NULL,
	[GatewayCityOperand] [char](1) NULL,
	[GatewayCity] [varchar](2000) NULL,
	[GatewayStateOperand] [char](1) NULL,
	[GatewayState] [varchar](2000) NULL,
	[GatewayCountryOperand] [char](1) NULL,
	[GatewayCountry] [varchar](2000) NULL,
	[GatewayContinentOperand] [char](1) NULL,
	[GatewayContinent] [varchar](2000) NULL,
	[ConnectingAirlineOperand] [char](1) NULL,
	[ConnectingAirline] [varchar](2000) NULL,
	[OWMinFare] [float] NULL,
	[RTMinFare] [float] NULL,
	[OvernightRqd] [char](1) NULL,
	[SatNightRqd] [char](1) NULL,
	[ValidDaysOperand] [char](1) NULL,
	[ValidDays] [varchar](20) NULL,
	[MktBeginDate] [datetime] NULL,
	[MktEndDate] [datetime] NULL,
	[ProcessLevel] [char](1) NULL,
	[TripOrigCityOperand] [char](1) NULL,
	[TripOrigCity] [varchar](2000) NULL,
	[TripOrigCountryOperand] [char](1) NULL,
	[TripOrigCountry] [varchar](2000) NULL,
	[TripOrigContinentOperand] [char](1) NULL,
	[TripOrigContinent] [varchar](2000) NULL,
	[DaysAdv] [int] NULL,
	[MktPairOperand] [char](1) NULL,
	[MktPair] [varchar](2000) NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[ValidatingCarriersOperand] [char](1) NULL,
	[ValidatingCarriers] [varchar](255) NULL,
	[OperatingCarriersOperand] [char](1) NULL,
	[OperatingCarriers] [varchar](255) NULL,
	[InterlineInd] [char](1) NULL,
	[MinimumQSI] [float] NULL,
	[MinimumStay] [int] NULL,
	[OnlineInd] [char](1) NULL,
	[OriginRegion] [varchar](40) NULL,
	[DestinationRegion] [varchar](40) NULL,
	[TripOriginRegion] [varchar](40) NULL,
	[GatewayRegion] [varchar](40) NULL,
	[MarketPairRegion] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[AirlineContractMarkets] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[AirlineContractGoals]    Script Date: 7/13/2015 1:16:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[AirlineContractGoals](
	[CustomerID] [varchar](30) NULL,
	[ContractNumber] [varchar](30) NULL,
	[ExhibitNumber] [int] NULL,
	[MarketNumber] [int] NULL,
	[GoalNumber] [int] NULL,
	[Status] [char](1) NULL,
	[GoalType] [varchar](50) NULL,
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
	[DiscCurrCode] [varchar](3) NULL,
	[MinPerformance] [float] NULL,
	[InflectionPoint] [float] NULL,
	[MaxPerformance] [float] NULL,
	[MinPayment] [float] NULL,
	[InflectionPayment] [float] NULL,
	[MaxPayment] [float] NULL,
	[Description] [varchar](1000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[AirlineContractGoals] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[AirlineContractExhibits]    Script Date: 7/13/2015 1:16:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[AirlineContractExhibits](
	[CustomerID] [varchar](30) NOT NULL,
	[ContractNumber] [varchar](30) NOT NULL,
	[ExhibitNumber] [int] NOT NULL,
	[Description] [varchar](100) NULL,
	[CustomerSubType] [varchar](100) NULL,
	[CustomerSubTypeInfo] [varchar](100) NULL,
	[ContractType] [varchar](2) NULL,
	[Commission] [char](1) NULL,
	[PointOfSaleOperand] [char](1) NULL,
	[PointOfSale] [varchar](2000) NULL,
	[AgencyName] [varchar](100) NULL,
	[IataNums] [varchar](2000) NULL,
	[CreatedBy] [varchar](30) NULL,
	[CreateDate] [datetime] NULL,
	[ModifiedBy] [varchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[CashPayPercent] [float] NULL,
	[CashPayCapAmount] [float] NULL,
	[TtlPayCapAmount] [float] NULL,
	[PayOnTicketTypeOperand] [char](1) NULL,
	[PayOnTicketType] [varchar](255) NULL,
	[GDS] [varchar](6) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[AirlineContractExhibits] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[AirlineContractAirportStats]    Script Date: 7/13/2015 1:16:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[AirlineContractAirportStats](
	[StationCode] [varchar](3) NULL,
	[CarrierCode] [varchar](3) NULL,
	[CarrierDepartures] [float] NULL,
	[StationDepartures] [float] NULL,
	[CarrierSeats] [float] NULL,
	[StationSeats] [float] NULL,
	[SeatShare] [float] NULL,
	[FlightShare] [float] NULL,
	[MaxSeatShare] [float] NULL,
	[MaxFlightShare] [float] NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[AirlineContractAirportStats] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ACMInfo]    Script Date: 7/13/2015 1:16:56 PM ******/
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

/****** Object:  Table [DBA].[Udef]    Script Date: 7/13/2015 1:17:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Udef](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[UdefNum] [smallint] NOT NULL,
	[UdefType] [varchar](20) NULL,
	[UdefData] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Udef] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[TranSeg]    Script Date: 7/13/2015 1:17:04 PM ******/
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

/****** Object:  Table [DBA].[Tax]    Script Date: 7/13/2015 1:17:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Tax](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[TaxSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[TaxId] [varchar](10) NULL,
	[TaxAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Tax] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PK_ROLLUP40]    Script Date: 7/13/2015 1:17:19 PM ******/
CREATE UNIQUE CLUSTERED INDEX [PK_ROLLUP40] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP1] ASC,
	[ROLLUP2] ASC,
	[ROLLUP3] ASC,
	[ROLLUP4] ASC,
	[ROLLUP5] ASC,
	[ROLLUP6] ASC,
	[ROLLUP7] ASC,
	[ROLLUP8] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [QSI_PX]    Script Date: 7/13/2015 1:17:22 PM ******/
CREATE UNIQUE CLUSTERED INDEX [QSI_PX] ON [DBA].[QSI]
(
	[BeginDate] ASC,
	[Orig] ASC,
	[Dest] ASC,
	[Airline] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PaymentI1]    Script Date: 7/13/2015 1:17:22 PM ******/
CREATE CLUSTERED INDEX [PaymentI1] ON [DBA].[Payment]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IOpCarXRef]    Script Date: 7/13/2015 1:17:22 PM ******/
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

/****** Object:  Index [LookupDataI1]    Script Date: 7/13/2015 1:17:23 PM ******/
CREATE CLUSTERED INDEX [LookupDataI1] ON [DBA].[LookupData]
(
	[LookupName] ASC,
	[LookupValue] ASC,
	[ParentNode] ASC,
	[LookupText] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/13/2015 1:17:23 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 1:17:23 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [DBA].[InvoiceDetail]
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

/****** Object:  Index [HotelI1]    Script Date: 7/13/2015 1:17:23 PM ******/
CREATE CLUSTERED INDEX [HotelI1] ON [DBA].[Hotel]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Employee_PX]    Script Date: 7/13/2015 1:17:24 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Employee_PX] ON [DBA].[Employee]
(
	[GPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CustRollupPX]    Script Date: 7/13/2015 1:17:24 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CustRollupPX] ON [DBA].[CustRollup]
(
	[MasterCustNo] ASC,
	[CustNo] ASC,
	[AgencyIATANum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI1]    Script Date: 7/13/2015 1:17:25 PM ******/
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

/****** Object:  Index [ComRmksI1]    Script Date: 7/13/2015 1:17:25 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [DBA].[ComRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ClientPX]    Script Date: 7/13/2015 1:17:25 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ClientPX] ON [DBA].[Client]
(
	[IataNum] ASC,
	[ClientCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI1]    Script Date: 7/13/2015 1:17:25 PM ******/
CREATE CLUSTERED INDEX [CCTicketI1] ON [DBA].[CCTicket]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/13/2015 1:17:26 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [DBA].[Car]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractsPX]    Script Date: 7/13/2015 1:17:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractsPX] ON [DBA].[AirlineContracts]
(
	[CustomerID] ASC,
	[ContractNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractMarketsPX]    Script Date: 7/13/2015 1:17:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractMarketsPX] ON [DBA].[AirlineContractMarkets]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractGoalsPX]    Script Date: 7/13/2015 1:17:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractGoalsPX] ON [DBA].[AirlineContractGoals]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC,
	[GoalNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractExhibitsPX]    Script Date: 7/13/2015 1:17:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractExhibitsPX] ON [DBA].[AirlineContractExhibits]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractAirportStatsPX1]    Script Date: 7/13/2015 1:17:28 PM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractAirportStatsPX1] ON [DBA].[AirlineContractAirportStats]
(
	[BeginDate] DESC,
	[EndDate] DESC,
	[StationCode] ASC,
	[CarrierCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI1]    Script Date: 7/13/2015 1:17:29 PM ******/
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

/****** Object:  Index [UdefI1]    Script Date: 7/13/2015 1:17:29 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [DBA].[Udef]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/13/2015 1:17:29 PM ******/
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

/****** Object:  Index [TaxI1]    Script Date: 7/13/2015 1:17:30 PM ******/
CREATE CLUSTERED INDEX [TaxI1] ON [DBA].[Tax]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Rollup40_I*]    Script Date: 7/13/2015 1:17:31 PM ******/
CREATE NONCLUSTERED INDEX [Rollup40_I*] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI1]    Script Date: 7/13/2015 1:17:31 PM ******/
CREATE NONCLUSTERED INDEX [RollupI1] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI2]    Script Date: 7/13/2015 1:17:31 PM ******/
CREATE NONCLUSTERED INDEX [RollupI2] ON [DBA].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_QSI_ORIG_DEST_BEGINDATE_ENDDATE]    Script Date: 7/13/2015 1:17:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_QSI_ORIG_DEST_BEGINDATE_ENDDATE] ON [DBA].[QSI]
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

/****** Object:  Index [QSII1]    Script Date: 7/13/2015 1:17:34 PM ******/
CREATE NONCLUSTERED INDEX [QSII1] ON [DBA].[QSI]
(
	[Orig] ASC,
	[Dest] ASC,
	[FMS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [PaymentI2]    Script Date: 7/13/2015 1:17:34 PM ******/
CREATE NONCLUSTERED INDEX [PaymentI2] ON [DBA].[Payment]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PaymentPX]    Script Date: 7/13/2015 1:17:34 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [PaymentPX] ON [DBA].[Payment]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/13/2015 1:17:34 PM ******/
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

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/13/2015 1:17:35 PM ******/
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

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/13/2015 1:17:35 PM ******/
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

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/13/2015 1:17:36 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/13/2015 1:17:36 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 1:17:36 PM ******/
CREATE NONCLUSTERED INDEX [ACMTrueTkt] ON [DBA].[InvoiceDetail]
(
	[TrueTktCount] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 1:17:37 PM ******/
CREATE NONCLUSTERED INDEX [IDExchProc_I1] ON [DBA].[InvoiceDetail]
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
	[TicketGroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 1:17:40 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 1:17:40 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 1:17:40 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[VoidInd] ASC,
	[VendorType] ASC,
	[ExchangeInd] ASC,
	[RefundInd] ASC
)
INCLUDE ( 	[RecordKey],
	[SeqNum],
	[ClientCode],
	[InvoiceDate],
	[IssueDate],
	[FirstName],
	[Lastname],
	[DocumentNumber],
	[BookingDate],
	[ServiceDate],
	[TotalAmt],
	[CurrCode],
	[ReasonCode1],
	[FareCompare2],
	[Routing],
	[DaysAdvPurch],
	[TripLength],
	[OnlineBookingSystem],
	[Remarks1],
	[Remarks2],
	[GDSRecordLocator]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 1:17:43 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 1:17:43 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 1:17:43 PM ******/
CREATE NONCLUSTERED INDEX [RefundMatchCoverIndex01] ON [DBA].[InvoiceDetail]
(
	[DocumentNumber] ASC,
	[VendorType] ASC,
	[RefundInd] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI2]    Script Date: 7/13/2015 1:17:43 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [DBA].[Hotel]
(
	[VoidInd] ASC,
	[IataNum] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[NumRooms],
	[HtlReasonCode1],
	[CurrCode],
	[Remarks2],
	[MasterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI3]    Script Date: 7/13/2015 1:17:44 PM ******/
CREATE NONCLUSTERED INDEX [HotelI3] ON [DBA].[Hotel]
(
	[VoidInd] ASC,
	[IataNum] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[NumNights],
	[NumRooms],
	[HtlDailyRate],
	[CurrCode],
	[MasterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelPX]    Script Date: 7/13/2015 1:17:44 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [DBA].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Employee_I1]    Script Date: 7/13/2015 1:17:45 PM ******/
CREATE NONCLUSTERED INDEX [Employee_I1] ON [DBA].[Employee]
(
	[GPN] ASC
)
INCLUDE ( 	[PaxName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CountryPX]    Script Date: 7/13/2015 1:17:45 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CountryPX] ON [DBA].[Country]
(
	[CtryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [ContractRmksI2]    Script Date: 7/13/2015 1:17:45 PM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI2] ON [DBA].[ContractRmks]
(
	[GoalExhibitNum] ASC,
	[GoalMarketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI4]    Script Date: 7/13/2015 1:17:46 PM ******/
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

/****** Object:  Index [ContractRmksPx]    Script Date: 7/13/2015 1:17:48 PM ******/
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

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID]    Script Date: 7/13/2015 1:17:48 PM ******/
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

/****** Object:  Index [ComRmksPX]    Script Date: 7/13/2015 1:17:49 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI2]    Script Date: 7/13/2015 1:17:49 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI2] ON [DBA].[CCTicket]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI3]    Script Date: 7/13/2015 1:17:49 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI3] ON [DBA].[CCTicket]
(
	[TicketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI4]    Script Date: 7/13/2015 1:17:49 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI4] ON [DBA].[CCTicket]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI5]    Script Date: 7/13/2015 1:17:50 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI5] ON [DBA].[CCTicket]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI6]    Script Date: 7/13/2015 1:17:50 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI6] ON [DBA].[CCTicket]
(
	[TransactionDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[ValCarrierCode],
	[EmployeeId],
	[TicketAmt],
	[MerchantId],
	[MatchedRecordKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketPX]    Script Date: 7/13/2015 1:17:51 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCTicketPX] ON [DBA].[CCTicket]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI2]    Script Date: 7/13/2015 1:17:52 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [DBA].[Car]
(
	[VoidInd] ASC,
	[IataNum] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[CarCityCode],
	[NumDays],
	[NumCars],
	[CarDailyRate],
	[CurrCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarPX]    Script Date: 7/13/2015 1:17:52 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CarPX] ON [DBA].[Car]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractGoals_I44]    Script Date: 7/13/2015 1:17:52 PM ******/
CREATE NONCLUSTERED INDEX [AirlineContractGoals_I44] ON [DBA].[AirlineContractGoals]
(
	[ContractNumber] ASC,
	[ExhibitNumber] ASC,
	[MarketNumber] ASC,
	[GoalNumber] ASC
)
INCLUDE ( 	[DiscountType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

ALTER INDEX [AirlineContractGoals_I44] ON [DBA].[AirlineContractGoals] DISABLE
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_AirlineContractGoals]    Script Date: 7/13/2015 1:17:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_AirlineContractGoals] ON [DBA].[AirlineContractGoals]
(
	[Status] ASC,
	[GoalType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI2]    Script Date: 7/13/2015 1:17:53 PM ******/
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

/****** Object:  Index [ACMInfoI3]    Script Date: 7/13/2015 1:17:55 PM ******/
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

/****** Object:  Index [ACMInfoI4]    Script Date: 7/13/2015 1:17:55 PM ******/
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

/****** Object:  Index [ACMInfoI5]    Script Date: 7/13/2015 1:17:55 PM ******/
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

/****** Object:  Index [ACMInfoPX]    Script Date: 7/13/2015 1:17:56 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ACMInfoPX] ON [DBA].[ACMInfo]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/13/2015 1:17:57 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [DBA].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/13/2015 1:17:57 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [DBA].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/13/2015 1:17:57 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [DBA].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TaxI4]    Script Date: 7/13/2015 1:17:57 PM ******/
CREATE NONCLUSTERED INDEX [TaxI4] ON [DBA].[Tax]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TaxPX]    Script Date: 7/13/2015 1:17:58 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TaxPX] ON [DBA].[Tax]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_ContractExtension]  DEFAULT ((0)) FOR [ContractExtension]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Approved]  DEFAULT ((0)) FOR [Approved]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Scenario]  DEFAULT ('N') FOR [Scenario]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_Processed]  DEFAULT ('N') FOR [Processed]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_MeasureGoalsOnDate]  DEFAULT ('F') FOR [MeasureGoalsOnDate]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_MeasurePayOnDate]  DEFAULT ('F') FOR [MeasurePayOnDate]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_GoalMeasurementPeriod]  DEFAULT ('Q') FOR [GoalMeasurementPeriod]
GO

ALTER TABLE [DBA].[AirlineContracts] ADD  CONSTRAINT [DF_AirlineContracts_PayMeasurementPeriod]  DEFAULT ('Q') FOR [PayMeasurementPeriod]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_FlownCarriersOperand]  DEFAULT ('N') FOR [FlownCarriersOperand]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_FlightNumberOperand]  DEFAULT ('I') FOR [FlightNumberOperand]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_DirectionalInd]  DEFAULT ('N') FOR [DirectionalInd]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_OvernightRqd]  DEFAULT ('N') FOR [OvernightRqd]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_SatNightRqd]  DEFAULT ('N') FOR [SatNightRqd]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_ValidDaysOperand]  DEFAULT ('I') FOR [ValidDaysOperand]
GO

ALTER TABLE [DBA].[AirlineContractMarkets] ADD  CONSTRAINT [DF_AirlineContractMarkets_OperatingCarriersOperand]  DEFAULT ('I') FOR [OperatingCarriersOperand]
GO

ALTER TABLE [DBA].[AirlineContractExhibits] ADD  CONSTRAINT [DF_AirlineContractExhibits_Commission]  DEFAULT ('N') FOR [Commission]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 1:18:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [DBA].[TR_INVOICEDETAIL_I]
    ON [DBA].[InvoiceDetail]
 AFTER INSERT
    AS
BEGIN
        SET NOCOUNT ON;
        UPDATE i
                SET i.TicketGroupId = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.TicketGroupId FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (ins.RecordKey)
                        END
                ),
                i.OriginalDocumentNumber = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.OriginalDocumentNumber FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (ins.DocumentNumber)
                        END
                )
        FROM dba.InvoiceDetail i
        JOIN inserted ins
        ON i.RecordKey = ins.RecordKey
        AND i.IataNum = ins.IataNum
        AND i.SeqNum = ins.SeqNum
END


GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lists of contract carrier codes' , @level0type=N'SCHEMA',@level0name=N'DBA', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'ContractCarrierCodes'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measure goals on flown or ticket date?' , @level0type=N'SCHEMA',@level0name=N'DBA', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'MeasureGoalsOnDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measure payment on flown or issued date?' , @level0type=N'SCHEMA',@level0name=N'DBA', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'MeasurePayOnDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Period for measuring performance goals' , @level0type=N'SCHEMA',@level0name=N'DBA', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'GoalMeasurementPeriod'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date period for payments' , @level0type=N'SCHEMA',@level0name=N'DBA', @level1type=N'TABLE',@level1name=N'AirlineContracts', @level2type=N'COLUMN',@level2name=N'PayMeasurementPeriod'
GO

