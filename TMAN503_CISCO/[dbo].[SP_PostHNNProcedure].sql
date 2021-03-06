/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:52:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Laurie Webb
--Create Date: 7/2/2013

----- Added Car and Hotel Dupes as we found that production was not getting updated correctly due to dates
----- Added on 1/26/15 by Nina


-------- Update Car dupes -------------------------Nina 1/26/15
update dba.CAR
set VoidReasonType = VoidInd
where IataNum in ('CISCOAX')

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM in ('CISCOAX')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM in ('CISCOAX')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey = Second.Recordkey
and First.ClientCode = Second.ClientCode
and first.CarSegNum < Second.CarSegNum
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM in ('CISCOAX')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and First.FirstName = Second.FirstName
and First.Lastname = second.Lastname
and first.CarChainCode = Second.CarChainCode
and First.CarCityName = Second.CarCityName
and Second.voidind = 'N'
and First.voidreasontype <> 'D'

Update carn
Set voidind = 'D'
from dba.car carn ,dba.car cary, dba.InvoiceDetail IDN, dba.invoicedetail IDY
where carn.IATANUM in ('CISCOAX')
and cary.IataNum in ('CISCOAX')
and carn.RecordKey = IDn.RecordKey
and carn.IataNum = idn.IataNum
and carn.SeqNum = idn.SeqNum
and cary.IataNum in ('CISCOAX')
and cary.RecordKey = IDy.RecordKey
and cary.IataNum = idy.IataNum
and cary.SeqNum = idy.SeqNum
and idy.ExchangeInd = 'Y'
and idy.OrigExchTktNum = idn.DocumentNumber
and idn.ExchangeInd = 'N'


-------- Update hotel dupes -------------------------Nina 1/26/15
update dba.hotel
set VoidReasonType = VoidInd
where IataNum in ('CISCOAX')

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM in ('CISCOAX')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM in ('CISCOAX')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey = Second.Recordkey
and First.ClientCode = Second.ClientCode
and first.htlSegNum < Second.htlSegNum
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM in ('CISCOAX')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and First.FirstName = Second.FirstName
and First.Lastname = second.Lastname
and first.HtlChainCode = Second.HtlChainCode
and first.HtlPropertyName = second.HtlPropertyName
and First.HtlCityName = Second.HtlCityName
and Second.voidind = 'N'
and First.voidreasontype <> 'D'

Update hoteln
Set voidind = 'D'
from dba.hotel hoteln ,dba.hotel hotely, dba.InvoiceDetail IDN, dba.invoicedetail IDY
where hoteln.IATANUM in ('CISCOAX')
and hotely.IataNum in ('CISCOAX')
and hoteln.RecordKey = IDn.RecordKey
and hoteln.IataNum = idn.IataNum
and hoteln.SeqNum = idn.SeqNum
and hotely.IataNum in ('CISCOAX')
and hotely.RecordKey = IDy.RecordKey
and hotely.IataNum = idy.IataNum
and hotely.SeqNum = idy.SeqNum
and idy.ExchangeInd = 'Y'
and idy.OrigExchTktNum = idn.DocumentNumber
and idn.ExchangeInd = 'N'



--2014 Preferred hotels updates
--Added on 3/25/14 by Nina per case #00033071
update dba.hotel
set prefhtlind = 'N'
,HtlCommAmt = '0'
where checkindate between '2014-01-01' and '2015-12-31'
and (prefhtlind <> 'C' or prefhtlind is null)


update htl
set htlcommamt = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
,prefhtlind= 'Y' 
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.prefhtlind = 'N'
and htl.htlcommamt ='0'
and htl.checkindate between '2014-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
,prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.prefhtlind = 'N'
and htl.htlcommamt ='0'
and htl.checkindate between '2014-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2)
,prefhtlind= 'Y' 
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.prefhtlind = 'N'
and htl.htlcommamt ='0'
and htl.checkindate between '2014-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
,prefhtlind= 'Y' 
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.prefhtlind = 'N'
and htl.htlcommamt ='0'
and htl.checkindate between '2014-01-01' and '2015-12-31'

--Update prefhtlind = C for preferred chain codes
--Added on 3/25/14 by Nina per case #00033071
update dba.Hotel
set PrefHtlInd = 'C'
where HtlChainCode in ('SW','SI','XR','MD','WI','WH','AL','EL','LC','MC','BR','LM','AK','CY','AR','RC','FN','TO','XV','RZ','EE'
,'6C','IC','UL','CP','IN','VN','HI','YZ','YO','AN','EH','HH','WA','HL','DT','ES','HX','GI','HG','CN','HT','AG','AW','GE','ET'
,'EM','MB','VC','BG','EB','KC')
and CheckinDate >= '2014-01-01'
and (PrefHtlInd = 'N' or PrefHtlInd is Null)

--Added additional checks to update the preferred chains/brands
--Added on 2/4/15 by Nina per case 06019473
update dba.Hotel
set PrefHtlInd = 'C'
where PrefHtlInd = 'N'
and CheckinDate >= '2014-01-01'
and MasterId <> '-1'
and (HtlPropertyName like '%Sheraton%' or HtlPropertyName like '%St%Regis%' or HtlPropertyName like '%Luxury%Coll%'
	or HtlPropertyName like 'W Hotels%' or HtlPropertyName like '%Le Meridien%' or HtlPropertyName like '%Westin%'
	or HtlPropertyName like '%Aloft%' or HtlPropertyName like '%Element%' or HtlPropertyName like '%Four%Points%'
	or HtlPropertyName like '%FourPoints%' or HtlPropertyName like '%Ritz%Carlton' or HtlPropertyName like '%Renaissance%'
	or HtlPropertyName like '%Marriott%' or HtlPropertyName like '%Gaylord%' or HtlPropertyName like '%AC Hotels%'
	or HtlPropertyName like '%Autograph%' or HtlPropertyName like '%Bvlgari%' or HtlPropertyName like '%Residence Inn%'
	or HtlPropertyName like 'Edition%' or HtlPropertyName like '%Oakwood%' or HtlPropertyName like '%Springhill%Suites%'
	or HtlPropertyName like '%Courtyard%' or HtlPropertyName like '%Townplace%Suites%' or HtlPropertyName like '%Fairfield%Inn%'
	or HtlPropertyName like '%Kimpton%' or HtlPropertyName like '%Intercontinental%' or HtlPropertyName like '%Crowne%Plaza%'
	or HtlPropertyName like '%Hotel Indigo%' or HtlPropertyName like '%Staybridge%' or HtlPropertyName like '%Even Hotels%'
	or HtlPropertyName like '%Hualuxe%' or HtlPropertyName like 'ANA Hotels%' or HtlPropertyName like '%Holiday Inn%'
	or HtlPropertyName like '%Candlewood%Suites%' or HtlPropertyName like '%Holiday%Express%' or HtlPropertyName like '%Waldorf%'
	or HtlPropertyName like '%Home2%' or HtlPropertyName like '%Hilton%' or HtlPropertyName like '%Embassy%Suites%'
	or HtlPropertyName like '%Conrad%Hotels%' or HtlPropertyName like '%Doubletree%' or HtlPropertyName like '%Homewood%Suites%'
	or HtlPropertyName like '%Garden%Inn%' or HtlPropertyName like '%Hampton%Inn%' or HtlPropertyName like 'W %'
	or HtlPropertyName like '%550%Moreland%Ap%' or HtlPropertyName like 'AC Hotel%' and HtlPropertyName like 'Holiday Bracebridge%'
	or HtlPropertyName like 'Imperial Riding School%' or HtlPropertyName like '%Double%tree%')


update dba.cchotel
set noshowind = 'N'
where noshowind is null

update dba.cchotel
set othercharges = 0

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

update dba.cchotel
set noshowind = 'C'
where transactiondate between '2014-01-01' and '2015-12-31'
and (noshowind ='N' or NoShowInd is null)
and htlchaincode in ('SW','SI','XR','MD','WI','WH','AL','EL','LC','MC','BR','LM','AK','CY','AR','RC','FN','TO','XV','RZ','EE'
,'6C','IC','UL','CP','IN','VN','HI','YZ','YO','AN','EH','HH','WA','HL','DT','ES','HX','GI','HG','CN','HT','AG','AW','GE','ET'
,'EM','MB','VC','BG','EB','KC')


END

GO
