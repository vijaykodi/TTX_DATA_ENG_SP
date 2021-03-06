/****** Object:  StoredProcedure [dbo].[sp_Hickory_DemoData]    Script Date: 7/14/2015 8:10:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Hickory_DemoData]

 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime ,@BeginIssueDate datetime,@ENDIssueDate datetime

	SET @Iata = 'DemoData'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @ENDIssueDate = getdate()-5
    set @beginissuedate = '4/1/2014'

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start Demo',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Duplicate data for a specific date range, client code, iatanum to be used as demo and give it a new iatanum of "DemoData"

insert into dba.client
select ClientCode + 'DM', 'DemoData', 'Demo Agency', CustAddr1, CustAddr2, CustAddr3, City, State, Zip, CustPhone, CountryCode, AttnLine, 
Email, ConsolidationCode, ClientRemark1, ClientRemark2, ClientRemark3, ClientRemark4, ClientRemark5, ClientRemark6, ClientRemark7, 
ClientRemark8, ClientRemark9, ClientRemark10
from dba.client 
where iatanum in ('prehgp','prehis')
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and clientcode+'DM' not in (select clientcode from dba.client where iatanum = 'DemoData')

insert into dba.invoiceheader
select RecordKey, 'DemoData', ClientCode + 'DM', InvoiceDate, InvoiceNum, TicketingBranch, BookingBranch, TtlInvoiceAmt, TtlTaxAmt, TtlCommissionAmt,
CurrCode, OrigCountry, SalesAgentID, FOP, CCCode, CCNum, CCExp, CCApprovalCode, GDSCode, BackOfficeID, IMPORTDT, TtlCO2Emissions,CLIQCID,CLIQUSER
from dba.invoiceheader
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.invoiceheader where iatanum = 'DemoData')

insert into dba.invoicedetail
select RecordKey, 'DemoData', SeqNum, ClientCode + 'DM', InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, Lastname, 
MiddleInitial, InvoiceType, InvoiceTypeDescription, DocumentNumber, EndDocNumber, VendorNumber, VendorType, ValCarrierNum, 
ValCarrierCode, VendorName, BookingDate, ServiceDate, ServiceCategory, InternationalInd, ServiceFee, InvoiceAmt, TaxAmt, 
TotalAmt, CommissionAmt, CancelPenaltyAmt, CurrCode, FareCompare1, ReasonCode1, FareCompare2, ReasonCode2, FareCompare3, 
ReasonCode3, FareCompare4, ReasonCode4, Mileage, Routing, DaysAdvPurch, AdvPurchGroup, TrueTktCount, TripLength, ExchangeInd, 
OrigExchTktNum, Department, ETktInd, ProductType, TourCode, EndorsementRemarks, FareCalcLine, GroupMult, OneWayInd, PrefTktInd, 
HotelNights, CarDays, OnlineBookingSystem, AccommodationType, AccommodationDescription, ServiceType, ServiceDescription, 
ShipHotelName, Remarks1, Remarks2, Remarks3, Remarks4, Remarks5, IntlSalesInd, MatchedInd, MatchedFields, RefundInd, 
OriginalInvoiceNum, BranchIataNum, GDSRecordLocator, BookingAgentID, TicketingAgentID, OriginCode, DestinationCode, OrigTktAmt, 
TktWasExchangedInd, TktCO2Emissions, CCMatchedRecordKey, CCMatchedIataNum, ACQMatchedInd, ACQMatchedRecordKey, ACQMatchedIataNum, 
CarrierString, ClassString, CRMatchedInd, CRMatchedRecordKey, CRMatchedIataNum, LastImportDt, GolUpdateDt
from dba.invoicedetail
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.invoicedetail where iatanum = 'DemoData')

insert into dba.transeg
select Recordkey,'DemoData', SeqNum, SegmentNum, TypeCode, ClientCode + 'DM', InvoiceDate, IssueDate, OriginCityCode, SegmentCarrierCode, 
SegmentCarrierName, CodeShareCarrierCode, EquipmentCode, PrefAirInd, DepartureDate, DepartureTime, FlightNum, ClassOfService, 
FareBasis, TktDesignator, ConnectionInd, StopOverTime, FrequentFlyerNum, FrequentFlyerMileage, CurrCode, SEGDestCityCode, 
SEGInternationalInd, SEGArrivalDate, SEGArrivalTime, SEGSegmentValue, SEGSegmentMileage, SEGTotalMileage, SEGFlightTime, 
SEGMktOrigCityCode, SEGMktDestCityCode, SEGReturnInd, NOXDestCityCode, NOXInternationalInd, NOXArrivalDate, NOXArrivalTime, 
NOXSegmentValue, NOXSegmentMileage, NOXTotalMileage, NOXFlightTime, NOXMktOrigCityCode, NOXMktDestCityCode, NOXConnectionString, 
NOXReturnInd, MINDestCityCode, MINInternationalInd, MINArrivalDate, MINArrivalTime, MINSegmentValue, MINSegmentMileage, 
MINTotalMileage, MINFlightTime, MINMktOrigCityCode, MINMktDestCityCode, MINConnectionString, MINReturnInd, MealName, 
NOXSegmentCarrierCode, NOXSegmentCarrierName, NOXClassOfService, MINSegmentCarrierCode, MINSegmentCarrierName, MINClassOfService, 
NOXClassString, NOXFareBasisString, MINClassString, MINFareBasisString, NOXFlownMileage, MINFlownMileage, SEGCO2Emissions, 
NOXCO2Emissions, MINCO2Emissions, FSeats, BusSeats, EconSeats, TtlSeats, SegTrueTktCount, YieldInd, YieldAmt, YieldDatePosted
from dba.TranSeg
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.transeg where iatanum = 'DemoData')

insert into dba.hotel
select RecordKey, 'DemoData', SeqNum, HtlSegNum, ClientCode + 'DM', InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, 
Lastname, MiddleInitial, HtlChainCode, HtlChainName, GDSPropertyNum, HtlPropertyName, HtlAddr1, HtlAddr2, HtlAddr3, HtlCityCode, 
HtlCityName, HtlState, HtlPostalCode, HtlCountryCode, HtlPhone, InternationalInd, CheckinDate, CheckoutDate, NumNights, NumRooms, 
HtlQuotedRate, QuotedCurrCode, HtlDailyRate, TtlHtlCost, RoomType, HtlRateCat, HtlCompareRate1, HtlReasonCode1, HtlCompareRate2, 
HtlReasonCode2, HtlCommAmt, CurrCode, PrefHtlInd, HtlConfNum, FreqGuestProgram, HtlStatus, Remarks1, Remarks2, Remarks3, Remarks4, 
Remarks5, CommTrackInd, HtlCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, '34' + BookingAgentID, MasterId, CO2Emissions, 
MilesFromAirport, GroundTransCO2
from dba.hotel
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.hotel where iatanum = 'DemoData')

insert into dba.car
select RecordKey, 'DemoData', SeqNum, CarSegNum,ClientCode + 'DM', InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, 
Lastname, MiddleInitial, CarType, CarChainCode, CarChainName, CarCityCode, CarCityName, InternationalInd, PickupDate, DropoffDate, 
CarDropoffCityCode, NumDays, NumCars, CarQuotedRate, QuotedCurrCode, CarDailyRate, TtlCarCost, CarRateCat, CarCompareRate1, 
CarReasonCode1, CarCompareRate2, CarReasonCode2, CarCommAmt, CurrCode, PrefCarInd, CarConfNum, FreqRenterProgram, CarStatus, 
Remarks1, Remarks2, Remarks3, Remarks4, Remarks5, CommTrackInd, CarCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, 
BookingAgentID, CarDropOffCityName, CO2Emissions
from dba.car
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.car where iatanum = 'DemoData')

insert into dba.udef
select RecordKey, 'DemoData', SeqNum, ClientCode + 'DM', InvoiceDate, IssueDate, UdefNum, UdefType, UdefData
from dba.udef
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.udef where iatanum = 'DemoData')

insert into dba.comrmks
select RecordKey, 'DemoData', SeqNum, ClientCode + 'DM', InvoiceDate, IssueDate, Text1, Text2, Text3, Text4, Text5, Text6, Text7, 
Text8, Text9, Text10, Text11, Text12, Text13, Text14, Text15, Text16, Text17, Text18, Text19, Text20, Text21, Text22, Text23, 
Text24, Text25, Text26, Text27, Text28, Text29, Text30, Text31, Text32, Text33, Text34, Text35, Text36, Text37, Text38, Text39, 
Text40, Text41, Text42, Text43, Text44, Text45, Text46, Text47, Text48, Text49, Text50, Num1, Num2, Num3, Num4, Num5, Num6, Num7, 
Num8, Num9, Num10, Num11, Num12, Num13, Num14, Num15, Num16, Num17, Num18, Num19, Num20, Num21, Num22, Num23, Num24, Num25, Num26, 
Num27, Num28, Num29, Num30, Int1, Int2, Int3, Int4, Int5, Int6, Int7, Int8, Int9, Int10, Int11, Int12, Int13, Int14, Int15, Int16, 
Int17, Int18, Int19, Int20
from dba.comrmks
where iatanum in ('prehgp','prehis')
and invoicedate between @beginissuedate and @endissuedate
and clientcode in ('010800','013930','014211','014215','014216','014302','014305','014307','014315','500705','501001','501600',
'501603','501605','501610','501611','501617','501619','501621','501622','501623','501624','501633','501638','501645','501668',
'502000','502236','502315','502424','502438','503020','503022','503030','503040','503110','503120','503135','503160',
'503170','503232','503234','503235','503236','503238','503242','503250','503255','503265','503280','503285','503301',
'503310','503320','503330','503350','503451','503460','503462','503510','503520','503800','504003','504145','505120',
'506800','514302','523460','J495243202','60010')
and recordkey not in (select recordkey from dba.comrmks where iatanum = 'DemoData')

--------Masking Names in invoicedetail
update ID
set ID.lastname = replace(ID.lastname,'t','8')    ,ID.firstname = replace(ID.firstname,'t','8')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'l','T')    ,firstname = replace(firstname,'l','T')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'s','L') ,firstname = replace(firstname,'s','L')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'d','S') ,firstname = replace(firstname,'d','S')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'n','D')   ,firstname = replace(firstname,'n','D')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'m','N')   ,firstname = replace(firstname,'m','N')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'c','M')   ,firstname = replace(firstname,'c','M')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'8','C')   ,firstname = replace(firstname,'8','C')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'u','9')   ,firstname = replace(firstname,'u','9')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'o','U')   ,firstname = replace(firstname,'o','U')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'i','O')  ,firstname = replace(firstname,'i','O')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'e','I')   ,firstname = replace(firstname,'e','I')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'a','E')   ,firstname = replace(firstname,'a','E')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

UPDATE ID
set lastname = replace(lastname,'9','A')   ,firstname = replace(firstname,'9','A')
FROM DBA.InvoiceDetail ID   
WHERE ID.IATANUM = 'DemoData'and invoicedate between @beginissuedate and @endissuedate

--------Carry the masked names down to car & hotel
update upd
set upd.lastname = id.lastname   ,upd.firstname = id.firstname
from  dba.car upd, dba.invoicedetail id
where upd.iatanum = id.iatanum and upd.recordkey = id.recordkey and upd.seqnum = id.seqnum
and upd.iatanum = 'DemoData'and id.iatanum = 'DemoData'
and id.invoicedate between @beginissuedate and @endissuedate

update upd
set upd.lastname = id.lastname   ,upd.firstname = id.firstname
from  dba.hotel upd, dba.invoicedetail id
where upd.iatanum = id.iatanum and upd.recordkey = id.recordkey and upd.seqnum = id.seqnum
and upd.iatanum = 'DemoData'and id.iatanum = 'DemoData'
and id.invoicedate between @beginissuedate and @endissuedate

--------------------------------------------------------------------------------------------------------------
--------- Update Agent sines so actual names do not appear ---------------------------------------------------
update dba.hotel
set bookingagentid = case when datepart(dd,invoicedate) in (1,6,11,15,22,27) then 'ZZZ' 
						when datepart(dd,invoicedate) in (2,7,12,16,23,28) then 'YYY' 
						when datepart(dd,invoicedate) in (3,8,13,17,24,29) then 'XXX' 
						when datepart(dd,invoicedate) in (4,9,14,18,25,30) then 'WWW' 
						when datepart(dd,invoicedate) in (5,10,19,20,21,26,31) then 'VVV' 
					else 'ZZZ' end
where iatanum = 'DemoData'
and bookingagentid not in ('ZZZ','YYY','XXX','WWW','VVV')
and invoicedate > '1-1-2014'

update dba.invoicedetail
set bookingagentid = case when datepart(dd,invoicedate) in (1,6,11,15,22,27) then 'ZZZ' 
						when datepart(dd,invoicedate) in (2,7,12,16,23,28) then 'YYY' 
						when datepart(dd,invoicedate) in (3,8,13,17,24,29) then 'XXX' 
						when datepart(dd,invoicedate) in (4,9,14,18,25,30) then 'WWW' 
						when datepart(dd,invoicedate) in (5,10,19,20,21,26,31) then 'VVV' 
					else 'ZZZ' end
where iatanum = 'DemoData'
and bookingagentid not in ('ZZZ','YYY','XXX','WWW','VVV')
and invoicedate > '1-1-2014'

--------- Update HtlRatCat to HFH randomley to help HFH numbers to be higher for demo data------------------
update dba.hotel
set htlratecat = 'HFH'
where iatanum = 'DemoData'
and invoicedate > '1-1-2014'
and datepart(dd,invoicedate) in (1,4,7,10,13,17,19,22,24,29,30) and isnull(htlratecat,'X')<> 'HFH'

GO
