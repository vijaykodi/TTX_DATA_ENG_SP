/****** Object:  StoredProcedure [dbo].[sp_ACM_Stage_One_Contract]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		  Charlie Bradsher
-- Create date:	  2013-05-01
-- Description:	  re-stages dba.ContractRmks for one contract as an argument
-- =============================================
CREATE PROCEDURE [dbo].[sp_ACM_Stage_One_Contract] (
	@Contract varchar(30)	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  	
DECLARE @CustomerID varchar(30)
DECLARE @ContractCarrier varchar(50)
DECLARE  @ProcName varchar(50), @TransStart datetime


SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
Set @CustomerID = (Select CustomerID from dba.AirlineContracts where ContractNumber = @Contract)
set @ContractCarrier = (select left(ContractCarrierCodes,2) 
				from dba.AirlineContracts 
				where ContractNumber = @Contract)



--=================================
--Added by rcr  07/07/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @Iata varchar(50)
--, @ProcName varchar(50)
--, @TransStart datetime
--, @BeginIssueDate datetime
--, @ENDIssueDate datetime
, @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)

SET @Iata = @ContractCarrier
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------


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
    Delete data for re-processing  (ContractRmks and ACMInfo only)
*************************************************************************/

Delete ACRmks
from dba.ContractRmks ACRmks
where ContractID = @Contract

/************************************************************************
    Insert ContractRmk records
*************************************************************************/
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
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
    and ACMI.IataNum = CRoll.AgencyIataNum
    and ACMI.ClientCode = CRoll.CustNo
    and CRoll.MasterCustNo = @CustomerID
    and AC.ContractNumber = @Contract
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Insert ContractRmk records'
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

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--


	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD
	 where TS.RecordKey = ACRmks.RecordKey
	 and TS.IataNum = ACRmks.IataNum
	 and TS.SeqNum = ACRmks.SeqNum
	 and TS.SegmentNum = ACRmks.SegmentNum
	 and ACRmks.ContractId = @Contract
	 and TS.OriginCityCode = ACSO.StationCode
	 and ACSO.CarrierCode = @ContractCarrier
	 and TS.MinDestCityCode = ACSD.StationCode
	 and ACSD.CarrierCode = @ContractCarrier
	 AND ACRmks.DepartureDate between ACSO.BeginDate and ACSO.EndDate
	 AND ACRmks.DepartureDate between ACSD.BeginDate and ACSD.EndDate


 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Use AirlineContracts.ContractCarrierCodes on DepartureDate'
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

--  Use AirlineContracts.ContractCarrierCodes on Current Schedule   
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD
	 where TS.RecordKey = ACRmks.RecordKey
	 and TS.IataNum = ACRmks.IataNum
	 and TS.SeqNum = ACRmks.SeqNum
	 and TS.SegmentNum = ACRmks.SegmentNum
	 and ACRmks.ContractId = @Contract
	 and TS.OriginCityCode = ACSO.StationCode
	 and ACSO.CarrierCode = @ContractCarrier
	 and TS.MinDestCityCode = ACSD.StationCode
	 and ACSD.CarrierCode = @ContractCarrier
	 and ACSO.BeginDate = (select Max(BeginDate) from dba.AirlineContractAirportStats)
	 and ACSD.BeginDate = (select Max(BeginDate) from dba.AirlineContractAirportStats)	 


 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Use AirlineContracts.ContractCarrierCodes on Current Schedule'
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

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--
update ACRmks
set OnlineFlag = 'N'
from dba.ContractRmks ACRmks
where ACRmks.OnlineFlag is null
and ACRmks.ContractID = @Contract		

 ----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Finish up online'
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
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
   
END

GO
