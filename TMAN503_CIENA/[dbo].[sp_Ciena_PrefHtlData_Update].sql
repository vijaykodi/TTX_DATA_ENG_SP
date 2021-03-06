/****** Object:  StoredProcedure [dbo].[sp_Ciena_PrefHtlData_Update]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Ciena_PrefHtlData_Update]

AS
declare @TransStart DATETIME 
declare @ProcName varchar(50)
declare @TSUpdateEndSched nvarchar(50)
declare @IATANUM VARCHAR (50)

set @ProcName = 'sp_Ciena_PrefHtlData_Update'--sql update from Brent
set @IATANUM = 'ALL'


 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_Ciena_PrefHtlData_Update]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
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




--------------------------------------------------------------------

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Pref Hotel Update Start',@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update agency data with Preferred Indicator and preferred Rates--
----- Set commission amount to 0  --- This field will be used for the PH Rate
 
Update dba.hotel 
set htlcommamt = 0
where checkoutdate between '2012-01-01' and '2013-12-31'

--------------------------------------------------------------------------------------------------------------

update h
set prefhtlind = 'Y'
from dba.hotel h, dba.hotelproperty hp, dba.preferredhotels ph, dba.hotelproperty hpRef
where  ph.masterid = hp.parentid
and hpRef.MasterID = h.MasterId
and  hpRef.ParentId = hp.MasterID
and (h.checkoutdate between ph.season1start and ph.season1end
	or (h.checkoutdate between ph.season2start and ph.season2end)
	or (h.checkoutdate between ph.season3start and ph.season3end)
	or (h.checkoutdate between ph.season4start and ph.season4end))
and ph.prefind = 'Y'
and invoicedate > '1/1/2012'
and prefhtlind <> 'Y'

----- Update Pref IND to N when not Y ----------------------
Update h
set prefhtlind = 'N'
from dba.hotel h
where prefhtlind is NULL
and invoicedate > '1/1/2012'

update h
set htlcommamt = 
	case when h.checkoutdate between ph.season1start and ph.season1end
	then round(ph.LRA_S1_RT1_SGL * curr.baseunitspercurr,2) 
	when h.checkoutdate between ph.season2start and ph.season2end
	then round(ph.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
	when h.checkoutdate between ph.season3start and ph.season3end
	then round(ph.LRA_S3_RT1_SGL * curr.baseunitspercurr,2) 
	when h.checkoutdate between ph.season4start and ph.season4end
	then round(ph.LRA_S4_RT1_SGL * curr.baseunitspercurr,2) 
	 
end
from dba.hotel h, dba.preferredhotels ph, dba.currency curr, dba.hotelproperty hp, dba.hotelproperty hpRef
where hpRef.MasterID = h.MasterId
and  hpRef.ParentId = HP.MasterID 
and ph.masterid = hp.parentid
and curr.basecurrcode = 'USD'
and curr.currbegindate = h.issuedate
and curr.currcode = ph.rate_curr
and prefhtlind = 'Y'
and invoicedate > '1/1/2012'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Pref Hotel Update End',@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
GO
