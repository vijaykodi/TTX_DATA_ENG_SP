/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN

----Updated to 2015 per SF 06024523 2.13.2015 Pam S

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
--,HtlCompareRate2 = 0
where checkindate between '2015-01-01' and '2015-12-31'
--and prefhtlind is null 

update htl
set htl.prefhtlind ='Y'
--,htl.HtlCompareRate2 = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref --, dba.currency curr
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and prefhtlind = 'N'
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = htl.issuedate
--and curr.currcode = pref.rate_curr
--and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y'
--,htl.HtlCompareRate2 = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref --, dba.currency curr
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and prefhtlind = 'N'
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = htl.issuedate
--and curr.currcode = pref.rate_curr
--and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y'
--,htl.HtlCompareRate2 = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref --, dba.currency curr
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and prefhtlind = 'N'
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = htl.issuedate
--and curr.currcode = pref.rate_curr
--and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y'
--,htl.HtlCompareRate2 = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref --, dba.currency curr
where htl.checkindate between '2013-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and prefhtlind = 'N'
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = htl.issuedate
--and curr.currcode = pref.rate_curr
--and htl.HtlCompareRate2 = 0



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
