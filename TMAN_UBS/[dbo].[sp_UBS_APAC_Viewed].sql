/****** Object:  StoredProcedure [dbo].[sp_UBS_APAC_Viewed]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_UBS_APAC_Viewed]


-- Update APAC with "Already seen" flag in Text 11 at 8:30 PM on Monday and Wednesday
as
 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
DECLARE @ProcName varchar(50), @TransStart datetime

SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

update c
set text11 = 'Y', text16 = getdate()
from dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.recordkey = ih.recordkey
and i.voidind = 'N'
and i.refundind = 'N'
and i.exchangeind = 'N'
and i.remarks2 <> 'Unknown'
and isnull(text21,'xx') not like '%hold%'
and i.iatanum = 'Preubs'
and text5 = 'Asia Pacific'
and importdt <= getdate()
and text11 is null

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO
