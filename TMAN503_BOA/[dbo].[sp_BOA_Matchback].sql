/****** Object:  StoredProcedure [dbo].[sp_BOA_Matchback]    Script Date: 7/14/2015 7:50:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_BOA_Matchback]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'BOAMatchback'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 




/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_BOA_Matchback]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/





--Log Activity
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start -',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

update ch 
set ch.MatchedInd = 'A' 
from dba.CCTicket ct, dba.CCHeader ch 
where ct.ticketissuer in ('AMERICAN EXPRESS TRAVEL', 
'AE GLOBAL BUSINESS TRAVE', 
'AE GLOBAL BUSINESS TRAVE', 
'AMEXONE') 
and ct.IataNum like 'BOFA%' 
and ct.PurgeInd is null 
and ct.matchedrecordkey is null 
and ch.MatchedInd is null 
and ct.RecordKey = ch.RecordKey 
and ct.IataNum = ch.IataNum 
and ct.TransactionDate >= '2013-01-01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update MatchedInd = A',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update t1
set t1.PurgeInd = 'W'
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
and t1.iatanum like 'BOFA%'
and t2.iatanum like 'BOFA%'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))
and t2.TransactionDate >= '2013-01-01'

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
and t1.iatanum like 'BOFA%'
and t2.iatanum like 'BOFA%'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))
and t2.TransactionDate >= '2013-01-01'


update ch 
set ch.MatchedInd = 'W' 
from dba.CCTicket ct, dba.CCHeader ch 
where ct.IataNum like 'BOFA%' 
and ct.PurgeInd = 'W' 
and ct.matchedrecordkey is null 
and ch.MatchedInd is null 
and ct.RecordKey = ch.RecordKey 
and ct.IataNum = ch.IataNum 
and ct.TransactionDate >= '2013-01-01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update MatchedInd = W',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate >= '2013-01-01' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate >= '2013-01-01' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update id
set id.matchedind = '2'
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate >= '2013-01-01' 
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--------------Additional updates for CC Matchback based on matching ticketnumbers------E.S/11/21/2013
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and id.invoicedate >= '2013-01-01' 
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
--and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and id.invoicedate >= '2013-01-01' 
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
--and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update id
set id.matchedind = '2'
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate >= '2013-01-01' 
and id.recordkey = cct.matchedrecordkey
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
--and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------ Additional updates for CC Matchback ---------- LOC/6/19/2013
--------CCHTL updates ------
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate >= '2013-01-01' 
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
--------Hotel updates -----
Update h
set h.matchedind = '2' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate >= '2013-01-01' 
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid



SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CBS Matchback Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/
GO
