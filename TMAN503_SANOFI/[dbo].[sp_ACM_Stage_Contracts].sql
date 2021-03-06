/****** Object:  StoredProcedure [dbo].[sp_ACM_Stage_Contracts]    Script Date: 7/14/2015 8:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		  Chalrie Bradsher
-- Create date:	  2012-08-23
-- Description:	  Stage Contract data for Processing
-- =============================================
CREATE PROCEDURE [dbo].[sp_ACM_Stage_Contracts] (
	@CustomerID varchar(30)   -- MasterCustNo
	--@Contract varchar(30)	   -- ContractNumber....   If contract number is not provided then all contracts are re-staged
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    	
DECLARE @ClientRequestName varchar(20)
DECLARE @ContractCarrier varchar(50)
Declare @Contract varchar(30)

--  Update CustRollUp (adds Master value UBS for new/undefined clientcodes)

Insert into dba.CustRollup (AgencyIataNum, CustNo, MasterCustNo)
Select IH.IataNum, IH.ClientCode, 'SANOFI'
from dba.InvoiceHeader IH
left outer join dba.CustRollup CRoll on (IH.IataNum = CRoll.AgencyIataNum
and IH.ClientCode = CRoll.CustNo)
where IH.IataNum not like 'Pre%'
Group by  IH.IataNum, IH.ClientCode, CRoll.CustNo
having CRoll.CustNo is null

/************************************************************************
    Delete data for re-processing  (ContractRmks and ACMInfo only)
*************************************************************************/

Delete ACRmks
from dba.ContractRmks ACRmks, dba.CustRollup Croll, dba.AirlineContracts AC
where ACRmks.IataNum = CRoll.AgencyIataNum
and ACRmks.ClientCode = CRoll.CustNo
and ACRmks.ContractID = AC.ContractNumber
and CRoll.MasterCustNo = AC.CustomerID
and CRoll.MasterCustNo = 'SANOFI'
--and ContractID = isnull(@Contract,ContractID)

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
    and CRoll.MasterCustNo = 'SANOFI'
   -- and AC.ContractNumber = isnull(@Contract,AC.ContractNumber)
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
and CRoll.MasterCustNo = 'SANOFI'
--and AC.ContractNumber = isnull(@Contract,AC.ContractNumber)
order by 1

Open airline_cursor

fetch next from airline_cursor into @Contract, @ContractCarrier

while @@Fetch_Status = 0

  BEGIN
  
	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD, dba.InvoiceHeader IH, dba.CustRollUp CRoll
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
	 and ACRmks.Iatanum = CRoll.AgencyIataNum
	 and ACRmks.ClientCode = CRoll.CustNo
	 and IH.Iatanum = CRoll.AgencyIataNum
	 and IH.ClientCode = CRoll.CustNo
	 and CRoll.MasterCustNo = 'SANOFI'
	 and ACRmks.ContractID = @Contract
	
 
  fetch next from airline_cursor into @Contract, @ContractCarrier
  
  END

CLOSE airline_cursor
DEALLOCATE airline_cursor

--  Use AirlineContracts.ContractCarrierCodes on Current Schedule   

DECLARE airline_cursor CURSOR FOR
select Distinct ContractNumber, left(ContractCarrierCodes,2)
from dba.AirlineContracts AC, dba.ACMInfo ACMI, dba.CustRollup CRoll
where AC.CustomerID = CRoll.MasterCustNo
and ACMI.Iatanum = CRoll.AgencyIataNum
and ACMI.ClientCode = CRoll.CustNo
and CRoll.MasterCustNo = 'SANOFI'
--and AC.ContractNumber = isnull(@Contract,AC.ContractNumber)
order by 1

Open airline_cursor

-- Fetch gets first record
fetch next from airline_cursor into @Contract, @ContractCarrier

while @@Fetch_Status = 0

  BEGIN
  
	 update ACRmks
	 Set OnlineFlag = 'Y'
	 from dba.ContractRmks ACRmks, dba.TranSeg TS, dba.AirlineContractAirportStats ACSO,
	 dba.AirlineContractAirportStats ACSD, dba.InvoiceHeader IH, dba.CustRollUp CRoll
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
	 and ACRmks.Iatanum = CRoll.AgencyIataNum
	 and ACRmks.ClientCode = CRoll.CustNo
	 and IH.Iatanum = CRoll.AgencyIataNum
	 and IH.ClientCode = CRoll.CustNo
	 and CRoll.MasterCustNo = 'SANOFI'
	 and ACRmks.ContractID = @Contract
 
  fetch next from airline_cursor into @Contract, @ContractCarrier
  
  END

CLOSE airline_cursor
DEALLOCATE airline_cursor

--  Finish up online

update ACRmks
set OnlineFlag = 'N'
from dba.ContractRmks ACRmks, dba.InvoiceHeader IH, dba.CustRollup CRoll
where IH.RecordKey = ACRmks.RecordKey
and IH.IataNum = ACRmks.IataNum
and ACRmks.OnlineFlag is null
and IH.Iatanum = CRoll.AgencyIataNum
and IH.ClientCode = CRoll.CustNo
and CRoll.MasterCustNo = 'SANOFI'
--and ACRmks.ContractID = isnull(@Contract,ACRmks.ContractID)




END


GO
