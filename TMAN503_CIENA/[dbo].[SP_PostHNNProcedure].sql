/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--This needs to be run after HNN is run for both agency and credit card data
--Hotel Sourcing--
--Update agency data with Preferred Indicator and preferred Rates--
--per Brent per incident #1076864 on 6/29/12...Nina


 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[SP_PostHNNProcedure]
************************************************************************/
--R. Robinson modified added time to stepname
declare @TransStart DATETIME declare @ProcName varchar(50)
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
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


update dba.hotel
set prefhtlind = 'N'
where iatanum in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and checkoutdate between '2012-01-01' and '2015-12-31'

update htl
set prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where  pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and htl.checkoutdate between pfh.seasonstartdate and pfh.seasonenddate
and htl.iatanum in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')

Update dba.hotel 
set htlcommamt = 0
where iatanum in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and checkoutdate between '2012-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkoutdate between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum  in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and htl.checkoutdate between '2012-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkoutdate between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and htl.checkoutdate between '2012-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkoutdate between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and htl.checkoutdate between '2012-01-01' and '2015-12-31'

update htl
set htlcommamt = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkoutdate between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and htl.checkoutdate between '2012-01-01' and '2015-12-31'


--The below sqls need to be run after HNN is run on Credit Card.
--Hotel Sourcing--
--Update credit card data with Preferred Indicator and preferred Rates
--per Brent per incident #1078198 on 6/29/12...Nina

update dba.cchotel
set noshowind = 'N'
where iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and transactiondate between '2012-01-01' and '2015-12-31'

Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.SeasonStartdate and pfh.SeasonEnddate
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and cchtl.transactiondate between '2012-01-01' and '2015-12-31'

update dba.cchotel
set othercharges = 0
where iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and transactiondate between '2012-01-01' and '2015-12-31'

update cchtl
set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and cchtl.transactiondate between '2012-01-01' and '2015-12-31'

update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and cchtl.transactiondate between '2012-01-01' and '2015-12-31'

update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and cchtl.transactiondate between '2012-01-01' and '2015-12-31'

update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.iatanum IN ('CIEUNIGL', 'CIEUNIUK', 'CIEUNIUS')
and cchtl.transactiondate between '2012-01-01' and '2015-12-31'



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


END

GO
