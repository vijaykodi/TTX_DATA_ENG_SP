/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Nina Lutz
--Create Date: 04/02/2013

--Hotel Sourcing--
--Update agency data with Preferred Indicator and preferred Rates--

update dba.hotel
set prefhtlind = 'N'
where iatanum in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC','FISAXCC')
and checkindate >= '2012-01-01' 
AND PrefHtlInd IS null

--only need this once now!--
update htl
set prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where  pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and htl.checkindate between pfh.seasonstartdate and pfh.seasonenddate
and htl.CheckinDate >= '2012-01-01'
and htl.iatanum in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC')

Update dba.hotel 
set htlcommamt = 0
where iatanum in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC')
and checkindate >= '2012-01-01'

update htl
set htlcommamt = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
--,htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season1Start and pfh.Season1End
and htl.CheckinDate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum  in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC')

update htl
set htlcommamt = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2)
--,htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season2Start and pfh.Season2End
and htl.CheckinDate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC')

update htl
set htlcommamt = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2)
--,htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season3Start and pfh.Season3End
and htl.CheckinDate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC')

update htl
set htlcommamt = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
--,htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season4Start and pfh.Season4End
and htl.CheckinDate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('FISAX', 'FISGTD', 'FISAXUK','FISAXCC')

END
GO
