/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Nina Lutz
--Create Date: 04/02/2013

update dba.hotel
set prefhtlind = 'N',
 htlcommamt = 0
where checkindate between '2013-01-01' and '2014-12-31'
and prefhtlind is null


---commented this out because we need to use the season 1, 2, 3, 4 dates to mark preferred
---and added prefhtiind = 'Y'
--update htl
--set prefhtlind= 'Y'
--from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
--where  pfh.masterid = HTLXREF.parentid
--and HTLXREF.MasterID = HTL.MasterId
--and htl.checkindate between pfh.seasonstartdate and pfh.seasonenddate
--and prefhtlind = 'N'

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
and htl.checkindate between '2013-01-01' and '2014-12-31'

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
and htl.checkindate between '2013-01-01' and '2014-12-31'

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
and htl.checkindate between '2013-01-01' and '2014-12-31'

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
and htl.checkindate between '2013-01-01' and '2014-12-31'



--Hotel Sourcing--
--Update credit card data with Preferred Indicator and preferred Rates--
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


END

GO
