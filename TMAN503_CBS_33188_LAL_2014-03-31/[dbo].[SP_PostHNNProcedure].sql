/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:51:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS
BEGIN
--Creater: Nina Lutz
--Create Date: 04/02/2013
--Modifier:  Tonya True
--Modified date: 01.03.2014
--Modified:  Added for CBS per Case#26857

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'ALL'
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Post HNN Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



update htl
set htl.prefhtlind = 'N'
FROM dba.hotel htl
where htl.iatanum in ('CBSBCD','CBSAX')
and htl.checkindate between '2012-01-01' and '2013-12-31'

--only need this once now!--
update htl
set prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where  pfh.MasterID = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and htl.checkindate >= '2012-01-01'
and htl.checkindate between pfh.seasonstartdate and pfh.seasonenddate
and htl.iatanum in ('CBSBCD','CBSAX')

Update htl 
set htl.htlcommamt = 0
FROM dba.hotel htl
where htl.iatanum in ('CBSBCD','CBSAX')
and htl.checkindate between '2012-01-01' and '2013-12-31'


update htl
set htl.htlcommamt = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season1Start and pfh.Season1End
and htl.checkindate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum  in ('CBSBCD','CBSAX')

update htl
set htlcommamt = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2)
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season2Start and pfh.Season2End
and htl.checkindate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CBSBCD','CBSAX')

update htl
set htlcommamt = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2)
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season3Start and pfh.Season3End
and htl.checkindate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CBSBCD','CBSAX')

update htl
set htlcommamt = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season4Start and pfh.Season4End
and htl.checkindate >= '2012-01-01'
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.iatanum in ('CBSBCD','CBSAX')

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Post HNN Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



END
GO
