USE [TMAN503_FLEXTRONICS]
GO
/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 05/28/2014 15:44:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Laurie Webb
--Create Date: 5/28/2014

update dba.hotel
set prefhtlind = 'N',
HtlCommAmt = 0
where checkindate between '2013-01-01' and '2014-12-31'
 


update htl
set htl.prefhtlind ='Y',
htl.HtlCommAmt = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCommAmt = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCommAmt = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCommAmt = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCommAmt = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCommAmt = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCommAmt = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCommAmt = 0


----CCard update:

update dba.cchotel
set noshowind = 'N'
where transactiondate between '2014-01-01' and '2014-12-31'

Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.SeasonStartdate and pfh.SeasonEnddate
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.transactiondate between '2014-01-01' and '2014-12-31'

update dba.cchotel
set othercharges = 0
where transactiondate between '2014-01-01' and '2014-12-31'

update cchtl
set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.transactiondate between '2014-01-01' and '2014-12-31'

update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.transactiondate between '2014-01-01' and '2014-12-31'

update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.transactiondate between '2014-01-01' and '2014-12-31'

update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.transactiondate between '2014-01-01' and '2014-12-31'

END






