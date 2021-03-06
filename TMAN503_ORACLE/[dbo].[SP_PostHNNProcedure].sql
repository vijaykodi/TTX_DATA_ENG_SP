/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:12:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN

--added new table based on CWT Harp Number 10/19/2009
--added in year 2013 to prevent PefHtlInd from being NULL- Dale 8/23/12
update dba.hotel
set prefhtlind = 'N'
where checkindate between '2012-01-01' and '2015-12-31'
and prefhtlind is null 


update dba.hotel
set htlcommamt = 0
where htlcommamt is null
and checkindate between '2012-01-01' and '2015-12-31'


--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period1single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel2009 cwt, dba.currency curr
--where ht.checkindate between cwt.room1start1 and cwt.room1end1
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2009-01-01' and '2009-12-31'


--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period1single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel cwt, dba.currency curr
--where ht.checkindate between cwt.room1start1 and cwt.room1end1
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2010-01-01' and '2011-12-31'


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0

---changing to use preferredhotels not harp 5/2012
update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0
--update ht
--set ht.htlcommamt = round(cwt.room1period2single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel2009 cwt, dba.currency curr
--where ht.checkindate between cwt.room1start2 and cwt.room1end2
--and cwt.harpnumber = ht.gdspropertynum
--and ht.prefhtlind ='Y'
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2009-01-01' and '2009-12-31'


--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period2single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel cwt, dba.currency curr
--where ht.checkindate between cwt.room1start2 and cwt.room1end2
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2010-01-01' and '2011-12-31'


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0
--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period3single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel2009 cwt, dba.currency curr
--where ht.checkindate between cwt.room1start3 and cwt.room1end3
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2009-01-01' and '2014-12-31'


--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period3single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel cwt, dba.currency curr
--where ht.checkindate between cwt.room1start3 and cwt.room1end3
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2010-01-01' and '2014-12-31'

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0


--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period4single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel2009 cwt, dba.currency curr
--where ht.checkindate between cwt.room1start4 and cwt.room1end4
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2009-01-01' and '2014-12-31'


--update ht
--set ht.prefhtlind = 'Y',
--ht.htlcommamt = round(cwt.room1period4single*curr.baseunitspercurr,2)
--from dba.hotel ht, dba.cwtprefhotel cwt, dba.currency curr
--where ht.checkindate between cwt.room1start4 and cwt.room1end4
--and cwt.harpnumber = ht.gdspropertynum
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = ht.issuedate
--and curr.currcode = cwt.currency
--and ht.htlcommamt = 0
--and ht.checkindate between '2010-01-01' and '2014-12-31'


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0


update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
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
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S5_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season5start and pref.season5end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0

update htl
set htl.prefhtlind ='Y',
htl.htlcommamt = round(pref.LRA_S5_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season5start and pref.season5end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.htlcommamt = 0
END

GO
