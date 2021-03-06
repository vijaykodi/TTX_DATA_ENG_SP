/****** Object:  StoredProcedure [dbo].[sp_Ciena_Matchback]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Ciena_Matchback]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'CienaMatchback'
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
--[sp_Ciena_Matchback]
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


---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN503_CIENA.dba.invoicedetail id, TTXPASQL01.TMAN503_CIENA.dba.ccticket cct, TTXPASQL01.TMAN503_CIENA.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' 
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
from TTXPASQL01.TMAN503_CIENA.dba.invoicedetail id, TTXPASQL01.TMAN503_CIENA.dba.ccticket cct, TTXPASQL01.TMAN503_CIENA.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

---MatchBack CCT for when no documentnumber given but all other fields match(employeeid, amt, carriercode,svcdate)
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN503_CIENA.dba.invoicedetail id, 
TTXPASQL01.TMAN503_CIENA.dba.ccticket cct, 
TTXPASQL01.TMAN503_CIENA.dba.ccheader cch,
TTXPASQL01.TMAN503_CIENA.DBA.COMRMKS CM
,TTXPASQL01.TMAN503_CIENA.DBA.Currency CURRBASE , TTXPASQL01.TMAN503_CIENA.dba.currency currto
where 
--substring(id.documentnumber,1,10) = cct.ticketnum  AND
cct.recordkey = cch.recordkey 
AND cct.matchedrecordkey is null and ID.invoicedate > '1-1-2013' 
and id.totalamt- (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(50)
and voidind = 'n'
and vendortype in ('bsp','nonbsp') 
--and documentnumber is null
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' )
 and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
AND CCT.EMPLOYEEID=CM.TEXT50
AND ID.RECORDKEY=CM.RECORDKEY
AND ID.IATANUM=CM.IATANUM
AND ID.CLIENTCODE=CM.CLIENTCODE
AND ID.SEQNUM=CM.SEQNUM
AND CCT.ServiceDate=ID.SERVICEDATE
and id.TotalAmt<>'0'

---MatchBack CCH for when no documentnumber given but all other fields match(employeeid, amt, carriercode,svcdate)
update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN503_CIENA.dba.invoicedetail id, 
TTXPASQL01.TMAN503_CIENA.dba.ccticket cct, 
TTXPASQL01.TMAN503_CIENA.dba.ccheader cch,
TTXPASQL01.TMAN503_CIENA.DBA.COMRMKS CM
,TTXPASQL01.TMAN503_CIENA.DBA.Currency CURRBASE , TTXPASQL01.TMAN503_CIENA.dba.currency currto
where 
--substring(id.documentnumber,1,10) = cct.ticketnum  AND
cct.recordkey = cch.recordkey 
AND cch.matchedrecordkey is null and ID.invoicedate > '1-1-2013' 
and id.totalamt- (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(50)
and voidind = 'n'
and vendortype in ('bsp','nonbsp') 
--and documentnumber is null
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' )
 and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
AND CCT.EMPLOYEEID=CM.TEXT50
AND ID.RECORDKEY=CM.RECORDKEY
AND ID.IATANUM=CM.IATANUM
AND ID.CLIENTCODE=CM.CLIENTCODE
AND ID.SEQNUM=CM.SEQNUM
AND CCT.ServiceDate=ID.SERVICEDATE
and id.TotalAmt<>'0'

update cch
set cch.MatchedRecordKey=cct.MatchedRecordKey
from dba.CCTICKET CCT,
dba.CCHeader cch
where 
cch.recordkey=cct.recordkey
and cch.iatanum=cct.iatanum
and cch.clientcode=cct.clientcode
and cch.transactiondate=cct.transactiondate
and cct.matchedrecordkey is not NULL
AND CCH.MatchedRecordKey IS NULL

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update id
set id.matchedind = '2'
from TTXPASQL01.TMAN503_CIENA.dba.invoicedetail id, TTXPASQL01.TMAN503_CIENA.dba.ccticket cct, TTXPASQL01.TMAN503_CIENA.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' 
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

--ID update with no doc number match but empl id, carrier, amount, servicedate match
update id
set id.matchedind = '3'
from TTXPASQL01.TMAN503_CIENA.dba.invoicedetail id, 
TTXPASQL01.TMAN503_CIENA.dba.ccticket cct, 
TTXPASQL01.TMAN503_CIENA.dba.ccheader cch,
TTXPASQL01.TMAN503_CIENA.DBA.COMRMKS CM
,TTXPASQL01.TMAN503_CIENA.DBA.Currency CURRBASE , TTXPASQL01.TMAN503_CIENA.dba.currency currto
where 
--substring(id.documentnumber,1,10) = cct.ticketnum  AND
cct.recordkey = cch.recordkey 
and id.matchedind is null and ID.invoicedate > '1-1-2013' 
and id.totalamt- (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(50)
and voidind = 'n'
and vendortype in ('bsp','nonbsp') 
--and documentnumber is null
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
AND CCT.EMPLOYEEID=CM.TEXT50
AND ID.RECORDKEY=CM.RECORDKEY
AND ID.IATANUM=CM.IATANUM
AND ID.CLIENTCODE=CM.CLIENTCODE
AND ID.SEQNUM=CM.SEQNUM
AND CCT.ServiceDate=ID.SERVICEDATE
and id.TotalAmt<>'0'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------ Additional updates for CC Matchback ---------- LOC/6/19/2013
--------CCHTL updates ------ chgd from guestname match for names only containing /
--and update employeeid join from h.remarks2 to comrmks.text50 KP/1/3/2014 #24019
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
--select h.recordkey as htlRecord,cch.recordkey as ccmRecord,ccm.masterid as CCMMasterID
--, ccmxref.masterid as CCMXREFMaster, htlpropccm.parentid as HtlPropCCMParentid
--, h.masterid as HtlMaster, htlxref.masterid as HtlXrefMaster, htlprop.parentid as HtlHtlPropParent
--, guestname, lastname+'/'+firstname, totalauthamt , ttlhtlcost,(totalauthamt - ttlhtlcost)
--, ccm.merchantname1, htlpropertyname
--from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
--,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
--where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
--and cch.matchedrecordkey is null
--and h.invoicedate > '1-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
--and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
--and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
--and ccm.merchantid = cch.merchantid 
--and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
--and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
--and htlxref.parentid = ccmxref.parentid

from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
dba.comrmks cm
where cch.employeeid = cm.text50 and cch.arrivaldate = h.checkindate
and h.recordkey=cm.recordkey
and h.iatanum=cm.iatanum
and h.seqnum=cm.seqnum
and cch.matchedrecordkey is null
and h.invoicedate > '01-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.35*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.35*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
--------Hotel updates -----
Update h
set h.matchedind = '2' 
--from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
--,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
--where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
--and h.matchedind is null and cch.matchedrecordkey = h.recordkey
--and h.invoicedate > '1-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
--and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
--and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
--and ccm.merchantid = cch.merchantid 
--and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
--and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
--and htlxref.parentid = ccmxref.parentid

from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
dba.comrmks cm
where cch.employeeid = cm.text50 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.recordkey=cm.recordkey
and h.iatanum=cm.iatanum
and h.seqnum=cm.seqnum
and h.invoicedate > '01-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.35*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.35*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid


--------CCHTL updates ------ Employeeid match, .40 cost and 2 days diff from checkin
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
--select h.recordkey as htlRecord,cch.recordkey as ccmRecord,ccm.masterid as CCMMasterID
--, ccmxref.masterid as CCMXREFMaster, htlpropccm.parentid as HtlPropCCMParentid
--, h.masterid as HtlMaster, htlxref.masterid as HtlXrefMaster, htlprop.parentid as HtlHtlPropParent
--, guestname, lastname+'/'+firstname, totalauthamt , ttlhtlcost,(totalauthamt - ttlhtlcost)
--, ccm.merchantname1, htlpropertyname
--from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
--,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
--where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
--and cch.matchedrecordkey is null
--and h.invoicedate > '1-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
--and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
--and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
--and ccm.merchantid = cch.merchantid 
--and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
--and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
--and htlxref.parentid = ccmxref.parentid

from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
dba.comrmks cm
where cch.employeeid = cm.text50 
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and h.recordkey=cm.recordkey
and h.iatanum=cm.iatanum
and h.seqnum=cm.seqnum
and cch.matchedrecordkey is null
and h.invoicedate > '01-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.40*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
--------Hotel updates -----
Update h
set h.matchedind = '4' 
--from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
--,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
--where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
--and h.matchedind is null and cch.matchedrecordkey = h.recordkey
--and h.invoicedate > '1-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
--and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
--and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
--and ccm.merchantid = cch.merchantid 
--and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
--and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
--and htlxref.parentid = ccmxref.parentid

from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
dba.comrmks cm
where cch.employeeid = cm.text50
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.recordkey=cm.recordkey
and h.iatanum=cm.iatanum
and h.seqnum=cm.seqnum
and h.invoicedate > '01-1-2013' 
--and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
--and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.40*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid


update cch
set cch.MatchedRecordKey=ccht.MatchedRecordKey
from dba.CChotel ccht,
dba.CCHeader cch
where 
cch.recordkey=ccht.recordkey
and cch.iatanum=ccht.iatanum
and cch.clientcode=ccht.clientcode
and cch.transactiondate=ccht.transactiondate
and ccht.matchedrecordkey is not NULL

--Set Matched recordkey so that known Uniglobe offices won't be pulled into Leakage Reports
--#34109 KP/4/21/14
SET @TransStart = getdate()

update dba.CCTicket
set MatchedRecordKey=TicketIssuer
where TicketIssuer in (
'UNIGLOBE AT BES', 
'UNIGLOBE AT BEST TRAVEL', 
'AGIS VOYAGES',
'UNIGLOBE PREMIE', 
'EVERGREEN INTL',
'Christian Kraus',
'Christian Krause-Cou', 
'Daniel Schubert',
'UNIGLOBE PREMIERE', 
'UNIGLOBE WAY TO', 
'AGIS VOYAGES SARL', 
'CHRISTIAN KRAUSE COURDOUA', 
'UNIGLOBE TRAVEL', 
'BBTF TRAVEL LTD', 
'UNIGLOBE NETWORK TRAVEL', 
'UNIGLOBE AT BEST TRA', 
'Air Ticket Team', 
'AIR TICKET TEAMREISEBUERO', 
'AIR TICKET TEAM REISEBUER',
'UNIGLOBE TRAVEL PARTNERS', 
'UNIGLOBE TOP FLIGHT')
and MatchedRecordKey is null


update cch
set cch.MatchedRecordKey=cct.ticketissuer
from dba.CCTicket cct,
dba.CCHeader cch
where 
cch.recordkey=cct.recordkey
and cch.iatanum=cct.iatanum
and cch.clientcode=cct.clientcode
and cch.transactiondate=cct.transactiondate
and cct.TicketIssuer in (
'UNIGLOBE AT BES', 
'UNIGLOBE AT BEST TRAVEL', 
'AGIS VOYAGES',
'UNIGLOBE PREMIE', 
'EVERGREEN INTL',
'Christian Kraus',
'Christian Krause-Cou', 
'Daniel Schubert',
'UNIGLOBE PREMIERE', 
'UNIGLOBE WAY TO', 
'AGIS VOYAGES SARL', 
'CHRISTIAN KRAUSE COURDOUA', 
'UNIGLOBE TRAVEL', 
'BBTF TRAVEL LTD', 
'UNIGLOBE NETWORK TRAVEL', 
'UNIGLOBE AT BEST TRA', 
'Air Ticket Team', 
'AIR TICKET TEAMREISEBUERO', 
'AIR TICKET TEAM REISEBUER',
'UNIGLOBE TRAVEL PARTNERS', 
'UNIGLOBE TOP FLIGHT')
and cch.MatchedRecordKey is null

--Per 2/6/2015 rqst from Marissa Farruggia - all EZ - Evergreen Intl (Easy Jet) should reflect matched
update dba.CCTicket
set MatchedRecordKey=TicketIssuer
where ValCarrierCode='EZ'
and MatchedRecordKey is null


update cch
set cch.MatchedRecordKey=cct.ticketissuer
from dba.CCTicket cct,
dba.CCHeader cch
where 
cch.recordkey=cct.recordkey
and cch.iatanum=cct.iatanum
and cch.clientcode=cct.clientcode
and cch.transactiondate=cct.transactiondate
and cct.ValCarrierCode='EZ'
and cch.MatchedRecordKey is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Ciena Matchback Known Uniglobe Office',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ciena Matchback Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
