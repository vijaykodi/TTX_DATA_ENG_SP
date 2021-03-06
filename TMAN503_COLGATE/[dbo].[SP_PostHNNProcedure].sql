/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:52:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
	@BeginIssueDate datetime,
	@EndIssueDate datetime

AS
BEGIN
--Creater: Susan Quigley
--Create Date: 2/18/2013
--Modifier:  Tonya True
--Modified date: 4-1-2014
--Modified:  added procedure logging.

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CPAX'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='SP_PostHNNProcedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--This needs to be run after HNN is run for both agency and credit card data
--Hotel Sourcing--
--Update agency data with Preferred Indicator and preferred Rates--
--per Brent per incident #1076864 on 6/29/12...Nina

update dba.hotel
set prefhtlind = 'N'
where iatanum in ('CPAX')
and checkoutdate between '2012-01-01' and '2014-12-31'

update htl
set prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where  pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and htl.checkoutdate between pfh.seasonstartdate and pfh.seasonenddate
and htl.iatanum in ('CPAX')

Update dba.hotel 
set htlcommamt = 0
where iatanum in ('CPAX')
and checkoutdate between '2012-01-01' and '2014-12-31'

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
and htl.iatanum  in ('CPAX')
and htl.checkoutdate between '2012-01-01' and '2014-12-31'

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
and htl.iatanum in ('CPAX')
and htl.checkoutdate between '2012-01-01' and '2014-12-31'

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
and htl.iatanum in ('CPAX')
and htl.checkoutdate between '2012-01-01' and '2014-12-31'

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
and htl.iatanum in ('CPAX')
and htl.checkoutdate between '2012-01-01' and '2014-12-31'

--ADDED TO HANDLE THE NEW SEASON 5....COMMENTING OUT UNTIL THE DBA TEAM CAN UPDATE THE TABLE.
--//TT//03.04.2014
update htl
set htlcommamt = round(pfh.LRA_S5_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkoutdate between pfh.Season5Start and pfh.Season5End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CPAX')
and htl.checkoutdate between '2012-01-01' and '2014-12-31'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Updated rates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


--The below sqls need to be run after HNN is run on Credit Card.
--Hotel Sourcing--
--Update credit card data with Preferred Indicator and preferred Rates
--per Brent per incident #1076864 on 6/29/12...Nina

update dba.cchotel
set noshowind = 'N'
where iatanum = 'CPAXCC'
and transactiondate between '2012-01-01' and '2014-12-31'

Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.SeasonStartdate and pfh.SeasonEnddate
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.iatanum = 'CPAXCC'
and cchtl.transactiondate between '2012-01-01' and '2014-12-31'

update dba.cchotel
set othercharges = 0
where iatanum = 'CPAXCC'
and transactiondate between '2012-01-01' and '2014-12-31'

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
and cchtl.iatanum = 'CPAXCC'
and cchtl.transactiondate between '2012-01-01' and '2014-12-31'

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
and cchtl.iatanum = 'CPAXCC'
and cchtl.transactiondate between '2012-01-01' and '2014-12-31'

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
and cchtl.iatanum = 'CPAXCC'
and cchtl.transactiondate between '2012-01-01' and '2014-12-31'

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
and cchtl.iatanum = 'CPAXCC'
and cchtl.transactiondate between '2012-01-01' and '2014-12-31'

--ADDED TO HANDLE THE NEW SEASON 5....COMMENTING OUT UNTIL THE DBA TEAM CAN UPDATE THE TABLE.
--//TT//03.04.2014
update cchtl
set othercharges = round(pfh.LRA_S5_RT1_SGL * curr.baseunitspercurr,2)
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.departdate) between pfh.Season5Start and pfh.Season5End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.iatanum = 'CPAXCC'
and cchtl.transactiondate between '2012-01-01' and '2014-12-31'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Updated cc tables',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Post HNN procedure',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR





END

GO
