/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:06:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Laurie Webb
--Create Date: 7/23/2013

update dba.hotel
set prefhtlind = 'N',
HtlCommAmt = 0
where checkindate between '2013-01-01' and '2014-12-31'
and prefhtlind is null 


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




END

GO
