/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:46:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Susan Quigley
--Create Date: 2/5/2013

update dba.hotel
set prefhtlind = 'N',
HtlCompareRate2 = 0
where checkindate between '2012-01-01' and '2012-12-31'
and prefhtlind is null 

--update dba.hotel
--set HtlCompareRate2 = 0
--where HtlCompareRate2 <> 0
--and checkindate between '2009-01-01' and '2013-12-31'

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2012-01-01' and '2012-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2012-01-01' and '2012-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2012-01-01' and '2012-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2012-01-01' and '2012-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update dba.hotel
set prefhtlind = 'N',
HtlCompareRate2 = 0
where checkindate between '2013-01-01' and '2013-12-31'
and prefhtlind is null 

--update dba.hotel
--set HtlCompareRate2 = 0
--where HtlCompareRate2 <> 0
--and checkindate between '2013-01-01' and '2013-12-31'

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2013-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2013-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2013-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2013-01-01' and '2013-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0




END

GO
