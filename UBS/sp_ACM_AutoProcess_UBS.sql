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

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/8/2015 7:20:24 AM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_ACM_AutoProcess_UBS]    Script Date: 7/8/2015 7:20:24 AM ******/
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

/****** Object:  Table [DBA].[QSI]    Script Date: 7/8/2015 7:20:25 AM ******/
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

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/8/2015 7:20:28 AM ******/
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

/****** Object:  Table [DBA].[OpCarXRef]    Script Date: 7/8/2015 7:20:29 AM ******/
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

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/8/2015 7:20:30 AM ******/
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

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/8/2015 7:20:34 AM ******/
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

/****** Object:  Table [DBA].[CustRollup]    Script Date: 7/8/2015 7:20:47 AM ******/
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

/****** Object:  Table [DBA].[ContractRmks]    Script Date: 7/8/2015 7:20:50 AM ******/
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

/****** Object:  Table [DBA].[AirlineContracts]    Script Date: 7/8/2015 7:20:58 AM ******/
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

/****** Object:  Table [DBA].[AirlineContractMarkets]    Script Date: 7/8/2015 7:21:01 AM ******/
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

/****** Object:  Table [DBA].[AirlineContractGoals]    Script Date: 7/8/2015 7:21:12 AM ******/
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

/****** Object:  Table [DBA].[AirlineContractExhibits]    Script Date: 7/8/2015 7:21:15 AM ******/
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

/****** Object:  Table [DBA].[AirlineContractAirportStats]    Script Date: 7/8/2015 7:21:19 AM ******/
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

/****** Object:  Table [DBA].[ACMInfo]    Script Date: 7/8/2015 7:21:21 AM ******/
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

/****** Object:  Table [DBA].[TranSeg]    Script Date: 7/8/2015 7:21:28 AM ******/
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

/****** Object:  Index [QSI_PX]    Script Date: 7/8/2015 7:21:43 AM ******/
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

/****** Object:  Index [IOpCarXRef]    Script Date: 7/8/2015 7:21:43 AM ******/
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

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/8/2015 7:21:44 AM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/8/2015 7:21:44 AM ******/
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

/****** Object:  Index [CustRollupPX]    Script Date: 7/8/2015 7:21:45 AM ******/
CREATE UNIQUE CLUSTERED INDEX [CustRollupPX] ON [DBA].[CustRollup]
(
	[MasterCustNo] ASC,
	[CustNo] ASC,
	[AgencyIATANum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI1]    Script Date: 7/8/2015 7:21:45 AM ******/
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

/****** Object:  Index [AirlineContractsPX]    Script Date: 7/8/2015 7:21:46 AM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractsPX] ON [DBA].[AirlineContracts]
(
	[CustomerID] ASC,
	[ContractNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractMarketsPX]    Script Date: 7/8/2015 7:21:46 AM ******/
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

/****** Object:  Index [AirlineContractGoalsPX]    Script Date: 7/8/2015 7:21:46 AM ******/
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

/****** Object:  Index [AirlineContractExhibitsPX]    Script Date: 7/8/2015 7:21:47 AM ******/
CREATE UNIQUE CLUSTERED INDEX [AirlineContractExhibitsPX] ON [DBA].[AirlineContractExhibits]
(
	[CustomerID] ASC,
	[ContractNumber] ASC,
	[ExhibitNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [AirlineContractAirportStatsPX1]    Script Date: 7/8/2015 7:21:48 AM ******/
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

/****** Object:  Index [ACMInfoI1]    Script Date: 7/8/2015 7:21:48 AM ******/
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

/****** Object:  Index [TransegI1]    Script Date: 7/8/2015 7:21:49 AM ******/
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

/****** Object:  Index [IX_QSI_ORIG_DEST_BEGINDATE_ENDDATE]    Script Date: 7/8/2015 7:21:49 AM ******/
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

/****** Object:  Index [QSII1]    Script Date: 7/8/2015 7:21:50 AM ******/
CREATE NONCLUSTERED INDEX [QSII1] ON [DBA].[QSI]
(
	[Orig] ASC,
	[Dest] ASC,
	[FMS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/8/2015 7:21:50 AM ******/
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

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/8/2015 7:21:51 AM ******/
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

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/8/2015 7:21:52 AM ******/
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

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/8/2015 7:21:52 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/8/2015 7:21:52 AM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/8/2015 7:21:52 AM ******/
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

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/8/2015 7:21:53 AM ******/
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

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/8/2015 7:21:53 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/8/2015 7:21:53 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/8/2015 7:21:53 AM ******/
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

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/8/2015 7:21:55 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/8/2015 7:21:55 AM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/8/2015 7:21:55 AM ******/
CREATE NONCLUSTERED INDEX [RefundMatchCoverIndex01] ON [DBA].[InvoiceDetail]
(
	[DocumentNumber] ASC,
	[VendorType] ASC,
	[RefundInd] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

/****** Object:  Index [ContractRmksI2]    Script Date: 7/8/2015 7:21:55 AM ******/
CREATE NONCLUSTERED INDEX [ContractRmksI2] ON [DBA].[ContractRmks]
(
	[GoalExhibitNum] ASC,
	[GoalMarketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ContractRmksI4]    Script Date: 7/8/2015 7:21:55 AM ******/
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

/****** Object:  Index [ContractRmksPx]    Script Date: 7/8/2015 7:21:56 AM ******/
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

/****** Object:  Index [IX_CONTRACTRMKS_CONTRACTID]    Script Date: 7/8/2015 7:21:57 AM ******/
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

/****** Object:  Index [AirlineContractGoals_I44]    Script Date: 7/8/2015 7:21:57 AM ******/
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

/****** Object:  Index [IX_AirlineContractGoals]    Script Date: 7/8/2015 7:21:57 AM ******/
CREATE NONCLUSTERED INDEX [IX_AirlineContractGoals] ON [DBA].[AirlineContractGoals]
(
	[Status] ASC,
	[GoalType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMInfoI2]    Script Date: 7/8/2015 7:21:58 AM ******/
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

/****** Object:  Index [ACMInfoI3]    Script Date: 7/8/2015 7:21:58 AM ******/
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

/****** Object:  Index [ACMInfoI4]    Script Date: 7/8/2015 7:21:59 AM ******/
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

/****** Object:  Index [ACMInfoI5]    Script Date: 7/8/2015 7:21:59 AM ******/
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

/****** Object:  Index [ACMInfoPX]    Script Date: 7/8/2015 7:22:00 AM ******/
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

/****** Object:  Index [TransegPX]    Script Date: 7/8/2015 7:22:00 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [DBA].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
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

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/8/2015 7:22:03 AM ******/
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

