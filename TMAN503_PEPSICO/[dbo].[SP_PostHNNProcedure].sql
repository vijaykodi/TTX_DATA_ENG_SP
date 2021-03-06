/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:13:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN

----------------------------------- Run Car and Hotel Dupes ---------------- LOC/11/4/2013
-------- Update Car dupes -------------------------LOC/11/4/2013
update dba.CAR
set VoidReasonType = VoidInd

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM = 'PYAX' and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D' and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM = 'PYAX' and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum and First.IssueDate <= Second.Issuedate
and First.Recordkey = Second.Recordkey and First.ClientCode = Second.ClientCode
and first.CarSegNum < Second.CarSegNum
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D' and Second.voidind = 'N'


Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM = 'PYAX' and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.IssueDate <= Second.Issuedate and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and First.FirstName = Second.FirstName and First.Lastname = second.Lastname and first.CarChainCode = Second.CarChainCode
and First.CarCityName = Second.CarCityName and Second.voidind = 'N' and First.voidreasontype <> 'D'

Update carn
Set voidind = 'D'
from dba.car carn ,dba.car cary, dba.InvoiceDetail IDN, dba.invoicedetail IDY
where carn.IATANUM = 'PYAX' and cary.IataNum = 'PYAX' and carn.RecordKey = IDn.RecordKey
and carn.IataNum = idn.IataNum and carn.SeqNum = idn.SeqNum and cary.IataNum = 'PYAX'
and cary.RecordKey = IDy.RecordKey and cary.IataNum = idy.IataNum and cary.SeqNum = idy.SeqNum
and idy.ExchangeInd = 'Y' and idy.OrigExchTktNum = idn.DocumentNumber and idn.ExchangeInd = 'N'


-------- Update hotel dupes -------------------------LOC/11/4/2013
update dba.hotel
set VoidReasonType = VoidInd

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM = 'PYAX' and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum and First.IssueDate <= Second.Issuedate and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode 
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D' and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM = 'PYAX' and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum and First.IssueDate <= Second.Issuedate and First.Recordkey = Second.Recordkey
and First.ClientCode = Second.ClientCode and first.htlSegNum < Second.htlSegNum
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D' and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM = 'PYAX' and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.IssueDate <= Second.Issuedate and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and First.FirstName = Second.FirstName and First.Lastname = second.Lastname and first.HtlChainCode = Second.HtlChainCode
and first.HtlPropertyName = second.HtlPropertyName and First.HtlCityName = Second.HtlCityName
and Second.voidind = 'N' and First.voidreasontype <> 'D'

Update hoteln
Set voidind = 'D'
from dba.hotel hoteln ,dba.hotel hotely, dba.InvoiceDetail IDN, dba.invoicedetail IDY
where hoteln.IATANUM = 'PYAX' and hotely.IataNum = 'PYAX' and hoteln.RecordKey = IDn.RecordKey
and hoteln.IataNum = idn.IataNum and hoteln.SeqNum = idn.SeqNum and hotely.IataNum = 'PYAX'
and hotely.RecordKey = IDy.RecordKey and hotely.IataNum = idy.IataNum and hotely.SeqNum = idy.SeqNum
and idy.ExchangeInd = 'Y' and idy.OrigExchTktNum = idn.DocumentNumber and idn.ExchangeInd = 'N'



update dba.hotel
set prefhtlind = 'N'
where checkindate between '2013-01-01' and '2015-12-31'
and prefhtlind is null

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'


---2014
--need to add customer and modify dates
/* Cust ID from text32....need to use this to update the prefhtlind and the Customer field in preferred hotels
PEPB00 - PEPSICO
PEPS00 - PEPSICO
PEPS80 - PEPSICO
PEPS86 - PEPSICO
PEPY00 - YUM
*/
update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPB00','PEPS00','PEPS80','PEPS86')
and pref.Customer = 'PEPSICO'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPY00')
and pref.Customer = 'YUM'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPB00','PEPS00','PEPS80','PEPS86')
and pref.Customer = 'PEPSICO'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPY00')
and pref.Customer = 'YUM'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPB00','PEPS00','PEPS80','PEPS86')
and pref.Customer = 'PEPSICO'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPY00')
and pref.Customer = 'YUM'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPB00','PEPS00','PEPS80','PEPS86')
and pref.Customer = 'PEPSICO'

update htl
set htl.prefhtlind = 'Y'
from dba.comrmks cr,dba.hotel htl, dba.hotelproperty xref, dba.hotelproperty prop, dba.preferredhotels pref
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and prop.MasterID <> -1
and htl.prefhtlind = 'N'
and htl.RecordKey = cr.RecordKey
and cr.Text32 in ('PEPY00')
and pref.Customer = 'YUM'


update dba.cchotel
set noshowind = 'N'
where noshowind is null
and transactiondate between '2013-01-01' and '2015-12-31'

update dba.cchotel
set othercharges = 0
where othercharges is null
and transactiondate between '2013-01-01' and '2015-12-31'
---Pepsico
update cchtl
set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'PEPAXCC'
and pfh.Customer = 'PEPSICO'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 

update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'PEPAXCC'
and pfh.Customer = 'PEPSICO'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 

update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'PEPAXCC'
and pfh.Customer = 'PEPSICO'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 

update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'PEPAXCC'
and pfh.Customer = 'PEPSICO'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 
--yum
update cchtl
set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'YUMAXCC'
and pfh.Customer = 'YUM'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 

update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'YUMAXCC'
and pfh.Customer = 'YUM'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 

update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'YUMAXCC'
and pfh.Customer = 'YUM'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 

update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'
and cchtl.iatanum = 'YUMAXCC'
and pfh.Customer = 'YUM'
and cchtl.transactiondate between '2013-01-01' and '2015-12-31' 
END




GO
