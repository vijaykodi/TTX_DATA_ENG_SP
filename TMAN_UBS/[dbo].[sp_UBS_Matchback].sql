/****** Object:  StoredProcedure [dbo].[sp_UBS_Matchback]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_Matchback]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'UBSMatchback'
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
@StepName='1-Stored Procedure Start -',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------- Delete all matched values that were flagged in CC Matchback for Iatanum PREUBS as these transactions should
------ not be used in matching .................
update dba.ccheader
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL, matchedind= NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.cchotel
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.cccar
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.ccticket
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.hotel
set matchedind = NULL where iatanum in ('preubs','BCDUBSEH','BCDUBSUH') and matchedind is not NULL

update dba.Invoicedetail
set matchedind = NULL where iatanum in ('preubs','BCDUBSEH','BCDUBSUH') and matchedind is not NULL

update dba.car
set matchedind = NULL where iatanum in ('preubs','BCDUBSEH','BCDUBSUH') and matchedind is not NULL

--------- Delete all matched values that were flagged in CC Matchback with a 3 or 4 as these are not trusted matches ------
----- CC table updates
update dba.ccheader
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL, matchedind= NULL
where matchedrecordkey in (select recordkey from dba.invoicedetail where matchedind in ('3','4'))

update dba.cchotel
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchedrecordkey in (select recordkey from dba.hotel where matchedind in ('3','4'))

update dba.cccar
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchedrecordkey in (select recordkey from dba.car where matchedind in ('3','4'))
----- TMC table Updates ---- 
update dba.invoicedetail
set matchedind = NULL where matchedind in ('3','4')

update dba.hotel
set matchedind = NULL where matchedind in ('3','4')

update dba.car
set matchedind = NULL where matchedind in ('3','4')

--Update CCHotel where masterid does not match to dba.hotel.masterid but match has been made
update cch
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
--select h.matchedind,cch.HtlChainCode,cch.DescOfCharge,ccm.merchantaddr1,h.HtlPropertyName,h.HtlChainCode,h.htladdr1
 from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 
and h.MatchedInd <'5'
and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2014' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid <> ccmxref.parentid


--Update CCHeader where masterid does not match to dba.hotel.masterid but match has been made

update cch
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
--select cch.HtlChainCode,cch.DescOfCharge,ccm.merchantaddr1,h.HtlPropertyName,h.HtlChainCode,h.htladdr1
 from dba.ccheader cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 
--and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and h.matchedind <5 
and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2014' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid <> ccmxref.parentid


--update dba.hotel where recordkey no longer in matched recordkey for cchotel

update h
set MatchedInd=NULL
from dba.hotel h
where 
 h.invoicedate > '1-1-2014' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
 and h.MatchedInd<>0
and RecordKey not in (select matchedrecordkey from dba.cchotel where TransactionDate>='2014-01-01' and MatchedRecordKey is not null)


-----------------------------------------------------------------------------------------------------------------------------------
---- Additional CC Matching as not being matched by CC Match back ----- LOC/8/16/2013

-------- CC Ticket Matches -------------------------------------
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
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
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
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
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode and id.matchedind is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------ Additional updates for CC Matchback ---------- LOC/6/19/2013
--------CCHTL updates ------matching on EmployeeID/GPN and first 5 of last/First name
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


--------Hotel updates -----matching on EmployeeID/GPN and first 5 of last/First name
Update h
set h.matchedind = '2' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

-------Hotel updates ------matching on EmployeeID/GPN 
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN
Update h
set h.matchedind = '5' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd' and checkindate >= getdate()
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


-------Hotel updates ------matching on EmployeeID/GPN -- And Ttl cost at 40%
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN -- And Ttl cost at 40%
Update h
set h.matchedind = '6' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


-------Hotel updates ------matching on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
Update h
set h.matchedind = '7' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


-------Hotel updates ------matching on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
---- and First 5 of hotel name = first 5 of descofcharge
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm,
DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and substring(htlpropertyname,1,5) = substring(descofcharge,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
---- and First 5 of hotel name = first 5 of descofcharge
Update h
set h.matchedind = '8' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm,
DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and h.matchedind is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and substring(htlpropertyname,1,5) = substring(descofcharge,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


--------CCCAR updates ------
Update ccc
set ccc.matchedrecordkey = c.recordkey, ccc.matchediatanum = c.iatanum, matchedclientcode = c.clientcode,
ccc.matchedseqnum = c.seqnum
from dba.cccar ccc, dba.car c, dba.ccmerchant ccm
where ccc.employeeid = c.remarks2 and ccc.rentaldate = c.pickupdate
and ccc.matchedrecordkey is null
and c.invoicedate > '1-1-2013' and c.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(rentername,1,5) = substring(lastname+'/'+firstname,1,5)
and rentername<> lastname+'/'+firstname 
and abs(ttlcarcost)-abs(totalauthamt) < (.20*ttlcarcost)
and abs(totalauthamt)-abs(ttlcarcost) < (.20*totalauthamt)
and ccm.merchantid = ccc.merchantid 
--------Car updates -----
Update c
set c.matchedind = '2' 
from dba.cccar ccc, dba.car c, dba.ccmerchant ccm
where ccc.employeeid = c.remarks2 and ccc.rentaldate = c.pickupdate
and ccc.matchedrecordkey is null
and c.invoicedate > '1-1-2013' and c.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(rentername,1,5) = substring(lastname+'/'+firstname,1,5)
and rentername<> lastname+'/'+firstname 
and abs(ttlcarcost)-abs(totalauthamt) < (.20*ttlcarcost)
and abs(totalauthamt)-abs(ttlcarcost) < (.20*totalauthamt)
and ccm.merchantid = ccc.merchantid 


SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBS Matchback Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO
