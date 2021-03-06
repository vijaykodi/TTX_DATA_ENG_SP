/****** Object:  StoredProcedure [dbo].[sp_ORAXCC]    Script Date: 7/14/2015 8:12:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ORAXCC](@BeginIssueDate  	datetime,
								  @EndIssueDate		datetime)

AS
SET NOCOUNT ON

DECLARE @Iata					varchar(50), 
		@ProcName				varchar(50), 
		@IataNum				varchar(50),
		@TransStart				datetime,	
		@LocalBeginIssueDate	datetime, 
		@LocalEndIssueDate		datetime  

    SELECT @LocalBeginIssueDate = @BeginIssueDate, 
           @LocalEndIssueDate	= @EndIssueDate 

	SET @Iata = 'ORAXCC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @IataNum = 'ORAXCC'
	
-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
insert into dba.client
select distinct clientcode,iatanum,null,null,null,null,null,null
,null,null,null,null,null,null,null,null,null,null,null,null
,null,null,null,null
from dba.ccheader
where iatanum ='ORAXCC'
and ClientCode is not null
and clientcode+iatanum not in(select clientcode+iatanum
from dba.client
where iatanum ='ORAXCC')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-insert client codes',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--set prugeind = W for records that were voided 
update t1
set t1.PurgeInd = 'W'
--select t1.TicketNum , t2.TicketNum,t1.ticketamt,t2.TicketAmt
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t1.PurgeInd is null
and t1.iatanum ='ORAXCC'
and t2.iatanum ='ORAXCC'
and t1.ticketissuer like ('CARLSON WAGONLIT%')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Wash 1)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update t2
set t2.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t2.PurgeInd is null
and t1.iatanum ='ORAXCC'
and t2.iatanum ='ORAXCC'
and t1.ticketissuer like ('CARLSON WAGONLIT%')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-Wash 2)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ccheader
set remarks1 = substring(clientcode,1,3)
    ,remarks2 = substring(clientcode,4,6)
from dba.CCHeader
where iatanum = 'ORCITIRU'
and Remarks1 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-set remarks1 and 2 ORCITIRU)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ccheader
set remarks1 = substring(controlccnum,1,3),
    remarks2 = substring(clientcode,4,6)
WHERE Remarks2 IS NULL
and controlccnum in ('378796577091009','379110536761000')
and iatanum ='ORAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-set remarks1 and 2 = substring(clientcode,4,6)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
update dba.ccheader 
set remarks2 = '323626'
where ControlCCNUM = '002000000003150'
and (remarks2 = '000000'
or Remarks2 is null)
and IataNum = 'ORAXCC'

update dba.ccheader 
set remarks2 = '323627'
where ControlCCNUM = '002000000003151'
and (remarks2 = '000000'
or Remarks2 is null)
and IataNum = 'ORAXCC'
SET @TransStart = getdate()
--remarks2 = CID
update dba.ccheader
set remarks2 = substring(clientcode,4,6)
WHERE Remarks2 IS NULL
and iatanum ='ORAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6-set remarks2 = substring(controlccnum,4,6)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.ccheader
set remarks1 = substring(controlccnum,1,3)
WHERE Remarks1 IS NULL
and iatanum ='ORAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-set remarks1 = substring(controlccnum,1,3)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
---Nina, this one I might change to parse from clientcode?? remarks2 = substring(clientcode,4,6)
update dba.CCHeader
set Remarks2 = substring(controlccnum,10,6)
from dba.ccheader
WHERE len(controlccnum) = 15
and substring(controlccnum,4,6) = '000000'
and IataNum = 'ORAXCC'
and (remarks2 = '000000'
or Remarks2 is null)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='8-set remarks2= substring(controlccnum,10,6)',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update ccmerchant with the 2 letter country code instead of using the 3 number ISO country code....10/4/11 NL
update merch
set merch.merchantctrycode = iso.countrycode
from dba.ccmerchant merch,dba.ccisocountry iso
where merch.merchantctrycode = iso.isocountrynum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='9-Update ccmerchant with the 2 letter country code',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update CCTKT
set CCTKT.ValCarrierCode = CAR.CarrierCode
FROM DBA.CCMerchant CCMERCHNT, DBA.CCTicket CCTKT, DBA.Carrier CAR, DBA.CCHeader CCHDR
WHERE CCMERCHNT.GenesisMajorIndCode = '12'
AND CCMERCHNT.MerchantId = CCTKT.MerchantId
AND CCMERCHNT.MERCHANTCHAIN = CAR.CARRIERNAME
AND (CCTKT.ValCarrierCode IS NULL OR CCTKT.ValCarrierCode = 'XX')
AND CCMERCHNT.MerchantChain IS NOT NULL
AND CCTKT.RecordKey = CCHDR.RecordKey
AND CCHDR.IndustryCode = '01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='10-Update cctkt valcarriercode 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update CCTKT
set CCTKT.ValCarrierCode = 'U2'
FROM DBA.CCMerchant CCMERCHNT, DBA.CCTicket CCTKT, DBA.CCHeader CCHDR
WHERE CCMERCHNT.GenesisMajorIndCode = '12'
AND CCMERCHNT.MerchantId = CCTKT.MerchantId
AND (CCTKT.ValCarrierCode IS NULL OR CCTKT.ValCarrierCode = 'XX')
AND CCMERCHNT.MerchantChain LIKE 'EASYJET'
AND CCTKT.RecordKey = CCHDR.RecordKey
AND CCHDR.IndustryCode = '01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='11-Update cctkt valcarriercode 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.CCTicket
set ValCarrierCode = case when TicketIssuer like 'AEROLINEAS ARGEN%' then 'AR'
when TicketIssuer like 'AMERICAN AIR%' then 'AA'
when TicketIssuer like 'AVIANCA%' then 'AV'
when TicketIssuer like 'AZUL LINHAS AEREAS%' then 'AD'
when TicketIssuer like 'COPA%' then 'CM'
when TicketIssuer like 'DELTA%' then 'DL'
when TicketIssuer like 'LAN CHILE%' then 'LA'
when TicketIssuer like 'TACA%' then 'TA'
when TicketIssuer like 'TAM%' then 'JJ'
when TicketIssuer like 'UNITED AIR%' then 'UA'
when TicketIssuer like 'US AIRWAYS%' then 'US'
when TicketIssuer like 'VARIG%' then 'RG'
when TicketIssuer like 'GOL%' then 'G3'
when TicketIssuer like 'AEROMEXICO%' then 'AM'
when TicketIssuer like 'VIRGIN AM%' then 'VX'
when TicketIssuer = 'VX' then 'VX'
when TicketIssuer like 'AIR CHINA%' then 'CA'
when TicketIssuer like 'VUELING%' then 'VY'
when TicketIssuer like 'RYANAIR%' then 'FR'
when TicketIssuer like 'SAUDI%' then 'SV'
when TicketIssuer like 'TRANSAVIA%' then 'HV'
END
from dba.CCTicket 
where (valcarriercode is null or ValCarrierCode = 'XX')
and ValCarrierNum in(0,999)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='12-Update cctkt valcarriercode 3',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
--Update credit card data with Preferred Indicator and preferred Rates per Brian...Incident #1072805
update dba.cchotel
set noshowind = 'N'
where iatanum = 'ORAXCC'
and transactiondate > '2010-12-31'
and NoShowInd is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='13-Update credit card data with Preferred Indicator',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update cch
set cch.noshowind = 'Y'
from dba.cchotel cch, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty hp, dba.hotelproperty HTLXREF
where ccm.merchantid = cch.merchantid
and pfh.masterid = hp.parentid
and HTLXREF.MasterID = CCM.MasterId
and  HTLXREF.ParentId = HP.MasterID 
and cch.transactiondate between pfh.seasonstartdate and pfh.seasonenddate
and cch.iatanum = 'ORAXCC'
and cch.transactiondate > '2010-12-31'
and cch.noshowind = 'N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='14-set cch.noshowind = Y',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.cchotel
set othercharges = 0
where iatanum = 'ORAXCC'
and transactiondate > '2010-12-31'
and OtherCharges is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='15-set othercharges = 0',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cchtl
set cchtl.othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2) 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, 
dba.hotelproperty HP, dba.hotelproperty HTLXREF
where ISNULL(cchtl.departdate,cchtl.transactiondate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = hp.parentid
and HTLXREF.MasterID = CCM.MasterId
and  HTLXREF.ParentId = HP.MasterID
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and ccm.merchantid = cchtl.merchantid 
and cchtl.iatanum = 'ORAXCC'
and cchtl.transactiondate > '2010-12-31'
and cchtl.othercharges = 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='16-set cchtl.othercharges = round(pfh.LRA_S1_RT1_SGL',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, 
dba.hotelproperty HP, dba.hotelproperty HTLXREF
where ISNULL(cchtl.departdate,cchtl.transactiondate) between pfh.Season2Start and pfh.Season2End
and pfh.masterid = hp.parentid
and HTLXREF.MasterID = CCM.MasterId
and  HTLXREF.ParentId = HP.MasterID
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and ccm.merchantid = cchtl.merchantid 
and cchtl.iatanum = 'ORAXCC'
and cchtl.transactiondate > '2010-12-31'
and cchtl.othercharges = 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-set cchtl.othercharges = round(pfh.LRA_S2_RT1_SGL',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2) 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, 
dba.hotelproperty HP, dba.hotelproperty HTLXREF
where ISNULL(cchtl.departdate,cchtl.transactiondate) between pfh.Season3Start and pfh.Season3End
and pfh.masterid = hp.parentid
and HTLXREF.MasterID = CCM.MasterId
and  HTLXREF.ParentId = HP.MasterID
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and ccm.merchantid = cchtl.merchantid 
and cchtl.iatanum = 'ORAXCC'
and cchtl.transactiondate > '2010-12-31'
and cchtl.othercharges = 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='18-set cchtl.othercharges = round(pfh.LRA_S3_RT1_SGL',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2) 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, 
dba.hotelproperty HP, dba.hotelproperty HTLXREF
where ISNULL(cchtl.departdate,cchtl.transactiondate) between pfh.Season4Start and pfh.Season4End
and pfh.masterid = hp.parentid
and HTLXREF.MasterID = CCM.MasterId
and  HTLXREF.ParentId = HP.MasterID
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and ccm.merchantid = cchtl.merchantid 
and cchtl.iatanum = 'ORAXCC'
and cchtl.transactiondate > '2010-12-31'
and cchtl.othercharges = 0
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='19-set cchtl.othercharges = round(pfh.LRA_S4_RT1_SGL',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.ccheader
set marketcode = '634'
where iatanum = 'ORCITIRU'
and (marketcode is null
or MarketCode <> '634')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='20-set marketcode = 634',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
/*Updated 2014SEP10 to include join to ccheader and filter for getdate()*/
update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%1ST BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='21-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%BAGGAGE FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='22-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%2ND BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='23-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 3
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%3RD BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='24-set ancillaryfeeind = 3',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 4
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%4TH BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='25-set ancillaryfeeind = 4',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 5
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%5TH BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='26-set ancillaryfeeind = 5',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 6
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%6TH BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='27-set ancillaryfeeind = 6',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%-INFLT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='28-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%*INFLT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='29-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EXCS BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='30-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 8
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%OVERWEIGHT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='31-set ancillaryfeeind = 8',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 9
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%OVERSIZE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='32-set ancillaryfeeind = 9',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EXCS BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='33-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 10
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%SPORT EQUIP%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='34-set ancillaryfeeind = 10',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EXCS BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='35-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA AWRD ACCEL%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='36-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 12
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA ECNMY PLUS%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='37-set ancillaryfeeind = 12',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 13
from dba.ccticket cctkt inner 
join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA PREM CABIN%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='38-set ancillaryfeeind = 13',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 17
from dba.ccticket cctkt inner 
join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA PREM LINE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='39-set ancillaryfeeind = 17',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA MPI UPGRD%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='40-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%SKYMILES FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='41-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 17
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EASY CHECK IN%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='42-set ancillaryfeeind = 17',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer = 'KLM LOUNGE ACCESS'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='43-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 18
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED.COM AWARD%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='44-set ancillaryfeeind = 18',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 19
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED CONNECTIO%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='45-set ancillaryfeeind = 19',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED.COM CUSTO%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='46-set ancillaryfeeind = 21',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 20
from dba.ccticket cctkt inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  WIPRO BPO PHILIP%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='47-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 20
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  WIPRO SPECTRAMIN%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='48-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  TICKET SVC CENTE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='49-set ancillaryfeeind = 21',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%MPI BOOK FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='50-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%RES BOOK FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='51-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA TKTG FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='52-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA UNCONF CHG%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='53-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED.COM%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='54-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%CONFIRM CHG$%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='55-set ancillaryfeeind = 31',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 32
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%CNCL/PNLTY%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='56-set ancillaryfeeind = 32',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%MUA CO PAY TI%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='57-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA MISC FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='58-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED.COM-SWIT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='59-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/FIRST CHE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='60-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/SECOND CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='61-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 3
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/THIRD CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='62-set ancillaryfeeind = 3',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 4
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/FOURTH CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='63-set ancillaryfeeind = 4',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 5
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/FIFTH CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='64-set ancillaryfeeind = 5',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 6
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/SIXTH CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='65-set ancillaryfeeind = 6',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%EXCESS BA%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='66-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 8
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/OVERWEIGH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='67-set ancillaryfeeind = 8',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 9
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/OVERSIZED%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='68-set ancillaryfeeind = 9',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 10
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%SPORT EQU%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='69-set ancillaryfeeind = 10',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 10
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/SPORTING%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='70-set ancillaryfeeind = 10',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 12
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/EXTRA LEG%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='71-set ancillaryfeeind = 12',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 13
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/FIRST CLA%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='72-set ancillaryfeeind = 13',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/ONEPASS R%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='73-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/REWARD BO%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='74-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/REWARD CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='75-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/INFLIGHT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='76-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/LIQUOR%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='77-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/SPECIAL S%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='78-set ancillaryfeeind = 21',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/RESERVATI%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='79-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cctkt
SET cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/TICKETING%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='80-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/CHANGE FE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='81-set ancillaryfeeind = 31',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 32
from dba.ccticket cctkt inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/CHANGE PE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='82-set ancillaryfeeind = 32',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/PAST DATE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='83-set ancillaryfeeind = 31',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/P-CLUB DA%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='84-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where passengername like '%P-CLUB%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='85-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where routing like 'XAA%'
and routing like '%XAE%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='86-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XUP%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='87-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XAF%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='88-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XCA%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='89-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XOT%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='90-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XDF%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='91-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XAO%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='92-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XAA%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='93-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XTD%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='94-set ancillaryfeeind = 21',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 25
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XPC%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='95-set ancillaryfeeind = 25',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)where cctkt.routing like 'XAA%'
and cctkt.routing like '%XPE%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='96-set ancillaryfeeind = 31',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GATWICK S BAGGAGE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='97-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ccexp.ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0QYBAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='98-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R2BAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='99-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R6BAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='100-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R7BAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='101-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%LHR T3- BAGGAGE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='102-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%LHR T4 BAGGAGE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='103-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%T1  BAGGAGE RECLAIM%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='104-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%T1 BAGGAGE RECLAIM%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='105-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%T3- BAGGAGE BELT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='106-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (1)%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='107-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 2
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (2)%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='108-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 7
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%EXCESS BAGGAGE CO%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='109-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%ALASKA AIR IN FLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='110-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%FLY DUBAI-INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='111-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%IN FLIGHT US AIRWAYS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='112-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%INFLIGHT FOOD PURCHASE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='113-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 8
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%KLM OVERBAGAGEKAS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='114-set ancillaryfeeind = 8',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AIRCELL GOGO INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='115-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AIRCELL*GOGO INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='116-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%INFLIGHT US AIRWAYSQPS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='117-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%SWA INFLIGHT WIFI%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='118-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%TRLPAY  GOGO INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='119-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 55
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AIRPORTBAGS.COM%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='120-set ancillaryfeeind = 55',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 60
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AA ADMIRAL%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='121-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 60
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AA ADMRL%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='122-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 60
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%ADMIRALS CLUB%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='123-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
SET ANCILLARYFEEIND = 70
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%INFLIGHT MEDICAL%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='124-set ancillaryfeeind = 70',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



update cctkt
set cctkt.AncillaryFeeInd = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AA'
and cctkt.ticketamt in (35,30,50,60)
and substring(cctkt.ticketnum,1,2) in ('26')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='125-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AA'
and cctkt.ticketamt in (100)
and substring(cctkt.ticketnum,1,2) in ('26')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='126-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AA'
and cctkt.ticketamt in (3.29,5.29,6,4.49,8.29,10,7)
AND cctkt.ANCILLARYFEEIND is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='127-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (23,25,32,35,27,30,50,55)
and substring(cctkt.ticketnum,1,2) IN ('25','29','82')
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='128-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (32,35,27,30,50,55)
and substring(cctkt.ticketnum,1,2) IN ('25','29','82')
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='129-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'UA'
and cctkt.ticketamt in (25)
and substring(cctkt.ticketnum,1,2) IN ('40','46','45')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='130-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'UA'
and cctkt.ticketamt in (35,50)
and substring(cctkt.ticketnum,1,2) IN ('40','46','45')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='131-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'US'
and cctkt.ticketamt in (23,25)
and substring(cctkt.ticketnum,1,2) IN ('24')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='132-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'US'
and cctkt.ticketamt in (35,50)
and substring(cctkt.ticketnum,1,2) IN ('24')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='133-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'WN'
and cctkt.ticketamt in (50,110)
and substring(cctkt.ticketnum,1,2) IN ('26')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='134-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 17
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'WN'
and cctkt.ticketamt in (10)
and substring(cctkt.ticketnum,1,2) IN ('06')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='135-set ancillaryfeeind = 17',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'LH'
and cctkt.ticketamt in (50)
and substring(cctkt.ticketnum,1,2) IN ('16','26','27')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='136-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'LH'
and cctkt.ticketamt in (150)
and substring(cctkt.ticketnum,1,2) IN ('16','26','27')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='137-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'BA'
and ((cctkt.ticketamt in (40,50,48,60)
and cctkt.billedcurrcode = 'USD'
and cctkt.matchedrecordkey is null
OR cctkt.ticketamt in (28,35,32,40)
and cctkt.billedcurrcode = 'GBP'))
and substring(cctkt.ticketnum,1,2) IN ('26','90')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='138-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'BA'
and ((cctkt.ticketamt in (112,140)
and cctkt.billedcurrcode = 'USD'
and cctkt.matchedrecordkey is null
OR cctkt.ticketamt in (72,90)
and cctkt.billedcurrcode = 'GBP'))
and substring(cctkt.ticketnum,1,2) IN ('26','90')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='139-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'SQ'
and cctkt.ticketamt in (8,12,22,50,15,30,55,40,60,50,109,150,84,110,121,117,160,94,115,130,129,149,165,128)
and substring(cctkt.ticketnum,1,2) IN ('16','18')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='140-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AF'
and cctkt.ticketamt in (55,100)
and substring(cctkt.ticketnum,1,2) in ('82','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='141-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AF'
and cctkt.ticketamt in (200)
and substring(cctkt.ticketnum,1,2) in ('82','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='142-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AS'
and cctkt.ticketamt in (20)
and substring(cctkt.ticketnum,1,2) in ('21','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='143-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 4
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AS'
and cctkt.ticketamt in (50)
and substring(cctkt.ticketnum,1,2) in ('21','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='144-set ancillaryfeeind = 4',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AC'
and cctkt.ticketamt in (30,50,75,100,225)
and substring(cctkt.ticketnum,1,2) in ('20','51')
and cctkt.matchedrecordkey is null
AND cctkt.ANCILLARYFEEIND is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='145-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'LX'
and cctkt.ticketamt in (250,150,50,120,450)
and cctkt.matchedrecordkey is null
AND cctkt.ANCILLARYFEEIND is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='146-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cchdr.chargedesc like '%inflight%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='147-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('AIR NEW ZEALAND EXCESS BAG WL7',
'AIR NEW ZEALAND EXCESS BAG CH8',
'MAS EXCESS BAGGAGE - DOME',
'VIRGIN ATLANTIC CC ANCILLARIES',
'AIR NEW ZEALAND EXCESS BAG AK7')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='148-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('JETBLUE BUY ON BOARD',
'AMTRAK ONBOARD/ BOS 0049',
'ALASKA AIRLINES IN FLIGHT',
'FRONTIER ON BOARD SALES',
'AMTRAK ONBOARD/ PDX  WASHINGTON',
'AMTRAK ONBOARD/ PHL  WASHINGTON',
'KOREAN AIR DUTY-FREE (  )',
'WESTJET-BUY ON BOARD',
'ONBOARD SALES',
'AMTRAK ONBOARD/ SAC  WASHINGTON',
'EVA AIRWAYS IN FLIGHT DUTY FEE',
'AMTRAK ONBOARD/ NYP  WASHINGTON',
'EL AL DUTY FREE',
'SOUTHWEST ON BOARD',
'AMTRAK ONBOARD/ HAR  WASHINGTON',
'AMTRAK ONBOARD/ RVR  WASHINGTON',
'AMTRAK ONBOARD/ WAS  WASHINGTON',
'AMTRAK ONBOARD/ OAK  WASHINGTON',
'KOREAN AIR DUTY-FREE ($)')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='149-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 20
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('AIR DO INTERNET',
'SOUTHWEST ONBOARD INTERNT',
'AIR FRANCE USA INTERNET')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='150-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('ADMIRAL CLUB',
'US AIRWAYS CLUB',
'CONTINENTAL PRESIDENT CLU',
'UNITED RED CARPET CLUB',
'THE LOUNGE VIRGIN BLUE')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='151-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
where cchdr.chargedesc like '%inflight%'
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='152-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('AMTRAK - CAP CORR CAFE',
'AMTRAK - SURFLINER CAFE',
'AMTRAK CASCADES CAFE',
'AMTRAK FOOD & BEVERAGE',
'AMTRAK-CAFE',
'AMTRAK-DINING CAR',
'AMTRAK-EAST CAFE',
'AMTRAK-MIDWEST CAFE',
'AMTRAK-NORTHEAST CAFE',
'AMTRAK-SAN JOAQUINS CAFE')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='153-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 60
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('AA ADMIRAL CLUB AUS',
'AA ADMIRAL CLUB LAX',
'AA ADMIRAL CLUB LGA D3',
'AA ADMIRALS CLUB MIAMI D',
'AIR CANADA CLUB',
'AMERICAN EXPRESS PLATINUM LOUNGE')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='154-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 20
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('AIRCELL-ABS')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='155-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 17
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('BAA ADVANCE')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='156-set ancillaryfeeind = 17',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('ALPHA FLIGHT SERVICES')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='157-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('DFASS CANADA COMPANY')
and ccexp.mchrgdesc1 like '%air canada on board%'
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='158-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 15
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('DELTAMILES BY POINTS')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='159-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%extra baggage%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='160-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%excess bag%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='161-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%VIRGIN ATLANTIC XX ANCILLARIES%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='162-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%IN FLIGHT%' OR TicketIssuer LIKE '%INFLIGHT%' OR TicketIssuer LIKE '%ONBOARD%' OR TicketIssuer LIKE '%ON BOARD%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='163-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%DUTY FREE%' OR TicketIssuer LIKE '%DUTY-FREE%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='164-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%KLM OPTIONAL SERVICES%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='165-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 60
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%ADMIRALS CLUB%' OR TicketIssuer LIKE '%PRESIDENT CLU%' OR TicketIssuer LIKE '%CARPET CLUB%' OR TicketIssuer LIKE '%ADMIRAL CLUB%'
	OR cctkt.TicketIssuer LIKE '%THE LOUNGE VIRGIN%' OR TicketIssuer LIKE '%US AIRWAYS CLUB%' OR TicketIssuer LIKE '%VIP LOUNGE%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='166-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/FIRST CHE%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='167-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/SECOND%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='168-set ancillaryfeeind = 2',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/EXCESS%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='169-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 8
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/OVERWEIGH%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='170-set ancillaryfeeind = 8',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 11
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/SPECIAL%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='171-set ancillaryfeeind = 11',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 13
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/FIRST CLA%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='172-set ancillaryfeeind = 13',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 14
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/EXT ST%' OR PassengerName LIKE '%/EXTRA SEAT%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='173-set ancillaryfeeind = 14',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 15
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%ONEPASS%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='174-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/HEADSET%' OR PassengerName LIKE '%/INFLIGHT%' OR PassengerName LIKE '%/LIQUOR%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='175-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 18
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/EXTRA LEG%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='176-set ancillaryfeeind = 18',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cctkt
SET cctkt.AncillaryFeeInd = 30
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/FARELOCK%' OR PassengerName LIKE '%/FEE' OR PassengerName LIKE '%/REFUND%' OR PassengerName LIKE '%FEE.%' OR PassengerName LIKE '%KIOSK.%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='177-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 31
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/CHANGE PR%' OR PassengerName LIKE '%/SAME DAY%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='178-set ancillaryfeeind = 31',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 60
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%P-CLUB%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='179-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
SET cctkt.AncillaryFeeInd = 19
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName = 'MISC' OR PassengerName = 'MISceLLaNeOUS' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='180-set ancillaryfeeind = 19',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 1
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%1ST BAG FEE%' OR ChargeDesc like '%baggage fee%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='181-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 60
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%ADMIRALS CLUB%' 
OR cchdr.ChargeDesc like '%SKY TEAM LOUNGE%'
OR cchdr.ChargeDesc like '%REDCARPETCLUB%'
OR cchdr.ChargeDesc like '%US AIRWAYS CLUB%'
OR cchdr.ChargeDesc like '%ALASKA AIR BOARDRM%'
OR cchdr.ChargeDesc like '%-BOARDROOM%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='182-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 16
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%ALASKA AIR CO STORE%' 
OR cchdr.ChargeDesc like '%IN FLIGHT%'
OR cchdr.ChargeDesc like '%ALASKA AIRLINE ONBOA%'
OR cchdr.ChargeDesc like '%ONBOARD%'
OR cchdr.ChargeDesc like '%IN-FLIGHT%'
OR cchdr.ChargeDesc like '%DUTY FREE%'
OR cchdr.ChargeDesc like '%SOUTHWESTAIR*INFLIGH%'
OR cchdr.ChargeDesc like '%*INFLT%'
OR cchdr.ChargeDesc like '%WESTJET BUY ON BOARD%'
OR cchdr.ChargeDesc like '%PURCHASE ON JETBLUE%' ))
and ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='183-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 12
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%ALASKA AIRLINES SEAT%'
OR cchdr.chargedesc like '%ECNMY PLUS%'
OR cchdr.chargedesc like '%ECONOMYPLUS%' 
OR cchdr.chargedesc like '%ECONOMY PLUS%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='184-set ancillaryfeeind = 12',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 15
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%BUY FLYING BLUE MILE%'
OR cchdr.chargedesc like '%MILEAGE PLUS%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='185-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 7
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%CARGO POR EMISION%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='186-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 32
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%CNCL/PNLTY%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='187-set ancillaryfeeind = 32',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 8
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%OVERWEIGHT%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='188-set ancillaryfeeind = 8',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 20
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%WIFI%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='189-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 30
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%RES BOOK FEE%'
OR cchdr.chargedesc like '%UNCONF CHG%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='190-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchdr
set cchdr.ancillaryfeeind = 50
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%OPTIONAL SERVICE%'
OR cchdr.chargedesc like '%NON-FLIGHT%'
OR cchdr.chargedesc like '%MISC FEE%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='191-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 60
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%admirals club%' 
  or ccm.merchantname1 like '%admiral club%'
  or ccm.merchantname1 like '%CONTINENTAL PRESIDENT%'
  or ccm.merchantname1 like '%RED CARPET CLUB%'
  or ccm.merchantname1 like '%AIRWAYS CLUB%'
  or ccm.merchantname1 like '%club spirit%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='192-set ancillaryfeeind = 60',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cctkt
set cctkt.Ancillaryfeeind = 7
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%DELTA AIR CARGO%' ))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='193-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cctkt
set cctkt.Ancillaryfeeind = 16
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%FRONTIER ON BOARD SALES%' 
  or ccm.merchantname1 like '%HORIZON AIR INFLIGHT%'
  or ccm.merchantname1 like '%IN FLIGHT SALES%'
  or ccm.merchantname1 like '%IN-FLIGHT PRCHASE JETBLUE%'
  or ccm.merchantname1 like '%ONBOARD SALES%'
  or ccm.merchantname1 like '%SOUTHWEST ON BOARD%'
  or ccm.merchantname1 like '%UNITED AIRLINES ONBOARD%'
  or ccm.merchantname1 like '%US AIRWAYS COMPANY STORE%'
  or ccm.merchantname1 like '%INFLIGHT ENTERTAINMENT%'
  or ccm.merchantname1 like '%SNCB/NMBS ON-BOARD%'
  or ccm.merchantname1 like '%SNACK BAR T2%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='194-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 15
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%AMEX LIFEMILES%' ))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='195-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 50
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%AIRPORT KIOSKS%' ))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='196-set ancillaryfeeind = 50',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 16
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%ONBOARD%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='197-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 7
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%AIR CARGO%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='198-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 7
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((cch.chargedesc like '%EX BAG%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='199-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 16
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%ON BOARD%'
OR ccm.merchantname2 like '%MOVIE SALES%'
OR ccm.merchantname2 like '%VIRGIN AMERICA ON BO%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='200-set ancillaryfeeind = 16',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.Ancillaryfeeind = 30
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((cch.chargedesc like '%REGIONAL EXPRESS CREDIT CARD SURCHARGE%'))
and cctkt.ancillaryfeeind is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='201-set ancillaryfeeind = 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--****** added 2/6/2013 *******

update cctkt
set cctkt.ancillaryfeeind = '15'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.issuercity = 'SKYMILES FEE'
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='202-set ancillaryfeeind = 15',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = '20'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt = 7
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='203-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = '17'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.issuercity = 'delta.com'
and cctkt.ticketamt = 9
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='204-set ancillaryfeeind = 17',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = '12'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and ((cctkt.issuercity <> 'delta.com' or cctkt.issuercity is null))
and cctkt.ticketamt = 9
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='205-set ancillaryfeeind = 12',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = '12'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (19, 9.5, 14.5, 29, 29.5, 39, 39.5, 49, 79)
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='206-set ancillaryfeeind = 12',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = '7'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (40, 50)
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='207-set ancillaryfeeind = 7',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ccexp
set ccexp.ancillaryfeeind = 20
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
inner join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
where ((ccm.merchantname1 like '%AIPORTWIRELESS%' 
OR ccm.merchantname1 like '%AIRPORT WIRELESS%'
OR ccm.merchantname1 like '%BOINGO%'
OR ccm.merchantname1 like '%SWA INFLIGHT WIFI%'
OR ccm.merchantname1 like 'VIASAT'
))
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='208-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = '12'
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt = 59
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='208-set ancillaryfeeind = 12',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----------------
--added 08/29/2013

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/1ST BAG%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='209-set ancillaryfeeind = 1',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


UPDATE ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
WHERE ccexp.MCHRGDESC1 LIKE '%GOGOAIR%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='210-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


UPDATE ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
WHERE ccexp.MCHRGDESC1 LIKE '%GOGO DAY PAS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='211-set ancillaryfeeind = 20',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




----******Added 2/11/2014 for VCF imports

--update cctkt
--set cctkt.ancillaryfeeind = 1
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XAE'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 15
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XUP'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 60
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XAF'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 50
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XCA'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 30
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XOT'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 16
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XDF'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 30
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XAO'
--and cctkt.ancillaryfeeind is null
--and cchdr.importdate >= getdate()-3

--update cctkt
--set cctkt.ancillaryfeeind = 50
--from dba.ccairseg ccas
--inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
--inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
--where ccas.origincitycode = 'XAA'
--and ccas.segdestcitycode = 'XAA'
--and cctkt.ancillaryfeeind is null
--and cctkt.matchedrecordkey is null
--and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'XAA'
and cctkt.routing = 'XTD'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='212-set ancillaryfeeind = 21',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 25
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'XAA'
and routing = 'XPC'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='213-set ancillaryfeeind = 25',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cctkt
set cctkt.ancillaryfeeind = 31
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'XAA'
and cctkt.routing = 'XPE'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='214-update ancillaryfeeind 31',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




update ct
set ct.ancillaryfeeind = ch.ancillaryfeeind
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.iatanum = ch.iatanum
and ct.ancillaryfeeind is null
and ch.ancillaryfeeind is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='215-set ct.ancillaryfeeind',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update ce
set ce.ancillaryfeeind = ch.ancillaryfeeind
from dba.ccexpense ce, dba.ccheader ch
where ce.recordkey = ch.recordkey
and ce.iatanum = ch.iatanum
and ce.ancillaryfeeind is null
and ch.ancillaryfeeind is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='216-set ce.ancillaryfeeind',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


UPDATE CCH
SET CCH.AncillaryFeeInd = CCT.AncillaryFeeInd
FROM DBA.CCHeader CCH, DBA.CCTicket CCT
WHERE CCH.IataNum = CCT.IataNum
AND CCH.RecordKey = CCT.RecordKey
AND CCT.AncillaryFeeInd IS NOT NULL
and CCH.AncillaryFeeInd IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='217-SET CCH.AncillaryFeeInd',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



UPDATE CCH
SET CCH.AncillaryFeeInd = CCE.AncillaryFeeInd
FROM DBA.CCHeader CCH, DBA.CCExpense CCE
WHERE CCH.IataNum = CCE.IataNum
AND CCH.RecordKey = CCE.RecordKey
AND CCE.AncillaryFeeInd IS NOT NULL
and CCH.AncillaryFeeInd IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='218-update ancillaryfeeind 30',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
