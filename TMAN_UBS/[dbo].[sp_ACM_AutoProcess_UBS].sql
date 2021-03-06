/****** Object:  StoredProcedure [dbo].[sp_ACM_AutoProcess_UBS]    Script Date: 7/14/2015 7:39:23 PM ******/
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
, @LogStep varchar(250)
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
	--
	--@LogSegNbr is an incremented number that is automatically generated to show 
	--the actual number of Logged Segments within a stored procedure.
	--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
	--Example: 'Stored Procedure Started logging'
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
