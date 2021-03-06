/****** Object:  StoredProcedure [dbo].[sp_CBS_Matchback]    Script Date: 7/14/2015 7:51:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CBS_Matchback]
@BeginIssueDate datetime,
@ENDIssueDate datetime

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CBSMatchback'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    

--Log Activity
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start -',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--All new edits done on 8/14/14 by Nina per case 00041716
update ch 
set ch.MatchedInd = 'A' 
from dba.CCTicket ct, dba.CCHeader ch 
where ct.ticketissuer in ('AMERICAN EXPRESS TRAVEL', 
'BCD TRAVEL', 
'BCD TRAVEL DBA', 
'AE GLOBAL BUSINESS TRAVE', 
'AE GLOBAL BUSINESS TRAVE', 
'AMEXONE') 
and ct.IataNum like 'CBS%' 
and ct.PurgeInd is null 
and ct.matchedrecordkey is null 
and ch.MatchedInd is null 
and ct.RecordKey = ch.RecordKey 
and ct.IataNum = ch.IataNum 
and ct.TransactionDate between @BeginIssueDate and @EndIssueDate 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update MatchedInd = A',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update ch 
set ch.MatchedInd = 'W' 
from dba.CCTicket ct, dba.CCHeader ch 
where ct.IataNum like 'CBS%' 
and ct.PurgeInd = 'W' 
and ct.matchedrecordkey is null 
and ch.MatchedInd is null 
and ct.RecordKey = ch.RecordKey 
and ct.IataNum = ch.IataNum 
and ct.TransactionDate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update MatchedInd = W',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update cch
set cch.matchedrecordkey = h.recordkey, 
cch.matchediatanum = h.iatanum, 
cch.matchedclientcode = h.clientcode,
cch.matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm 
where ccm.merchantid = cch.merchantid 
and cch.arrivaldate = h.checkindate 
and cch.matchedrecordkey is null 
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5) 
and substring(guestname,CHARINDEX('/',guestname,1)+1,5) = substring(firstname,1,5) 
and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost) 
and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt) 
and substring(ccm.merchantaddr1,1,6) = substring(h.htladdr1,1,6)
and h.InvoiceDate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Addtional Match Edits A',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update cch
set cch.matchedrecordkey = h.recordkey, 
cch.matchediatanum = h.iatanum, 
cch.matchedclientcode = h.clientcode,
cch.matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm 
where ccm.merchantid = cch.merchantid 
and cch.arrivaldate = h.checkindate 
and cch.matchedrecordkey is null 
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5) 
and substring(guestname,CHARINDEX('/',guestname,1)+1,5) = substring(firstname,1,5)
and SUBSTRING(cch.descofcharge, 1,5) = SUBSTRING(h.htlpropertyname, 1,5)
and h.InvoiceDate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Addtional Match Edits B',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

Update cchdr
set cchdr.matchedrecordkey = cch.matchedrecordkey,
cchdr.MatchedSeqNum = cch.MatchedSeqNum,
cchdr.matchediatanum = cch.matchediatanum, 
cchdr.matchedclientcode = cch.matchedclientcode,
cchdr.MatchedInd = '9'
from dba.ccheader cchdr, dba.cchotel cch
where  cchdr.recordkey = cch.recordkey
and cchdr.ClientCode = cch.ClientCode
and cchdr.IataNum = cch.IataNum 
and cch.matchedrecordkey is not null
and cchdr.MatchedRecordKey is null
and cchdr.TransactionDate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched Fields in CCHeader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CBS Matchback Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------------------------------------------------------
---- Additional CC Matching as not being matched by CC Match back ----- LOC/8/16/2013
---- Copied from UBS on 5/22/2015...LOC
-------- CC Ticket Matches -------------------------------------
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.IataNum like 'CBS%' 
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
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.IataNum like 'CBS%' 
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
and id.matchedind is null and invoicedate > '1-1-2013' and id.IataNum like 'CBS%' 
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode and id.matchedind is null

-------- CC Ticket Matches -------------------------------------
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = substring(cct.ticketnum,4,10) and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.IataNum like 'CBS%' 
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
where substring(id.documentnumber,1,10) = substring(cct.ticketnum,4,10) and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.IataNum like 'CBS%' 
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
where substring(id.documentnumber,1,10) = substring(cct.ticketnum,4,10) and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' and id.IataNum like 'CBS%' 
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode and id.matchedind is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


GO
