/****** Object:  StoredProcedure [dbo].[sp_ACM_Stage_Process_Agency_Scenario]    Script Date: 7/14/2015 8:06:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ==========================================================================================
-- Author:		  Charlie Bradsher
-- Create date:	  2013-11-20
-- Description:	  Stage (if needed) and process Agency Contract 
--			  Run this SP from ACM Application using ContractNumber argument
--			  Assigns client codes not associated with a MasterCustNo
--			  to the 'UNKNOWN' MasterCustno

--			  Needs to be saved and run from customer database
--			  This procedure calls a remote procedure on the processing server		
--			  Database and Process servers must be linked with RPC true, RPC Out = true
--			  Arguments for Customer information are hardcoded below
--                      set @Server as the processing server
--                      set @Prog with argumments for database servers
-- Modified:	  2013-08-01 - changed to sp to execute the ProcessContracts.exe
-- Modified:	  2013-11-20 - changed logic to stage contract based on counts or ACMI to ACRmks records
-- ==========================================================================================

CREATE PROCEDURE [dbo].[sp_ACM_Stage_Process_Agency_Scenario] (
	  @Contract varchar(30)
	  )	
AS
BEGIN		    --   Begin SP


--  Update CustRollUp (adds Unknown Master for new/undefined clientcodes)

Insert into dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
Select IH.IataNum, IH.ClientCode, 'UNKNOWN'
from dba.InvoiceHeader IH
left outer join dba.CustRollup CRoll on (IH.IataNum = CRoll.AgencyIataNum
and IH.ClientCode = CRoll.CustNo)
where IH.IataNum not like 'Pre%'
Group by  IH.IataNum, IH.ClientCode, CRoll.CustNo
having CRoll.CustNo is null


-- Set Variables

DECLARE @CustomerID varchar(30)
DECLARE @ClientRequestName varchar(20)
DECLARE @ContractCarrier varchar(50)
DECLARE @Server varchar(50) 
DECLARE @User varchar(100) 
DECLARE @Pword varchar(100) 
DECLARE @Prog varchar(500) 
DECLARE @RemoteArgs varchar(500) 
Declare @ContractStartDate datetime
Declare @ContractEnddate datetime
Declare @ACRmksStartDate datetime
Declare @ACRmksEnddate datetime
Declare @ACRmksCount int
Declare @ACMICount int
Declare @Staged varchar(200)
Declare @ContractNum varchar (50)

--  Set arguments to run autoprocessor for this client
Set @ContractNum = (Select ContractNumber from dba.AirlineContracts where ContractName = @Contract)
Set @CustomerID = (Select CustomerID from dba.AirlineContracts where ContractNumber = @ContractNum)
Set @Server = '\\TTXPVACMAPP01.TRXFS.TRX.COM'  --  server to run the processor
Set @User = N'wtpdh\smsservice'  
Set @Pword = N'melanie'
--  @prog = local path and executable + DSNs on @Server -CS = Contracts data -TS = Trans data
Set @Prog = 'c:\ProcessACM\ProcessContracts.exe '  
-- @RemoteArgs = Gets last import date from data
Set @RemoteArgs = (select '-CN'+@Contract)+' '+(select '-CI'+@CustomerID) + ' -CCFCM'
Set @Staged = 'Data was not staged'

/************************************************************************
    Check to see if Contract has to be re-staged
*************************************************************************/

Set @ContractStartDate = (Select StartDate from dba.AirlineContracts where ContractNumber = @ContractNum)
Set @ContractEndDate = (Select EndDate from dba.AirlineContracts where ContractNumber = @ContractNum)
Set @ACRmksCount = (Select count(*) from dba.ContractRmks where contractid = @Contract)
Set @ACMICount = (Select count(*) 
		      from dba.ACMinfo, dba.Custrollup 
		      where issuedate between @ContractStartDate and @ContractEndDate
		      and CustNo = ClientCode
		      and MasterCustNo = @CustomerID)

If @ACRmksCount <> @ACMICount

Set @Staged = 'Data was staged'

    BEGIN	--  Begin Staging


	  /************************************************************************
		Delete ContractRmks Data
	  *************************************************************************/

	  Delete ACRmks
	  from dba.ContractRmks ACRmks
	  where ContractID = @Contract

	  /************************************************************************
		Insert ContractRmk records
	  *************************************************************************/

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
	  , MINOpCarrierCode
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
		, AC.ContractName
		, ACMI.RouteType
		, ACMI.DiscountedFare
		, ACMI.MINOpCarrierCode
		, ACMI.InterlineFlag
		, ACMI.POSCountry
		, ACMI.DepartureDate
	    from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollUp CRoll
	    where CRoll.MasterCustNo = AC.CustomerID
	    and CRoll.AgencyIataNum = ACMI.IataNum
	    and CRoll.CustNo = ACMI.ClientCode
	    and AC.ContractNumber = @ContractNum
	    and ACMI.IssueDate between ( Select Min(ACG.GoalBeginDate)
						from dba.AirlineContractGoals  ACG
						where ACG.ContractNumber = @ContractNum)
		  			and ( Select Max(ACG.GoalEndDate)
						from dba.AirlineContractGoals  ACG
						where ACG.ContractNumber = @ContractNum)	    
	    and ACMI.DepartureDate between ( Select Min(ACG.TravelBeginDate)
						from dba.AirlineContractGoals  ACG
						where ACG.ContractNumber = @ContractNum)
		  			and ( Select Max(ACG.TravelEndDate)
						from dba.AirlineContractGoals  ACG
						where ACG.ContractNumber = @ContractNum)
          
	  /************************************************************************
		Set Online Flag - contract carrier is the first airline in 
		the contractcarriercodes field of in AirlineContracts table
	  *************************************************************************/

	  Set @ContractCarrier = (  select Distinct left(ContractCarrierCodes,2)
					    from dba.AirlineContracts AC
					    where AC.ContractNumber = @ContractNum)
      

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
    	  

	  --  Finish up online
        
	  update ACRmks
	  set OnlineFlag = 'N'
	  from dba.ContractRmks ACRmks, dba.InvoiceHeader IH
	  where IH.RecordKey = ACRmks.RecordKey
	  and IH.IataNum = ACRmks.IataNum
	  and ACRmks.ContractID = @Contract
	  and ACRmks.OnlineFlag is null
	 
	 Set @Staged = 'Data was staged'

    END   --  End Staging

--  Execute SP to run ProcessContracts.exe - Runs on ttxsaSQL03 - Processes on ATL591 for database DSN specified

DECLARE	@return_value int

   EXEC	@return_value = ttxsaSQL03.server_Administration.dbo.sp_ExecuteACMProcessor
		  @RemoteBatch = @Prog,
		  @RemoteServer = @Server,
		  @RemoteUser = @User,
		  @RemotePword = @Pword,
		  @RemoteArgs = @RemoteArgs

SELECT	'Return Value' = @return_value

END	  --  End SP




GO
