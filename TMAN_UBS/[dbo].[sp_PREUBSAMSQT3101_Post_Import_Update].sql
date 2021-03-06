/****** Object:  StoredProcedure [dbo].[sp_PREUBSAMSQT3101_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSAMSQT3101_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()
/************************************************************************
	LOGGING_START - BEGIN Vijay Addded 11/24/2014
************************************************************************/
--Log Activity

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start AMSQT3101-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='NL'
where iatanum ='PREUBS'
and recordkey like '%AMSQT3101-%' and (origcountry is null or origcountry ='XX')

/*Update text15 = Secured Ticket */
--select cr.recordkey,cr.text15
update cr
set cr.text15 = ud.udefdata
from dba.udef ud,dba.comrmks cr
WHERE ud.recordkey = cr.recordkey and ud.iatanum = cr.iatanum and ud.seqnum = cr.seqnum
and ud.recordkey like '%AMSQT3101-%' and ud.udeftype = 'SECUREDTICKET'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End AMSQT3101-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
--UPDATE ih
--SET ih.origcountry = 'NL'
--from dba.invoiceheader ih, dba.client cl,dba.ComRmks cr
--WHERE ih.recordkey = cr.recordkey --and ih.iatanum = cr.iatanum--and ih.iatanum = 'PREUBS'
--and ih.recordkey like '%AMSQT3101-%' --and ih.clientcode = cr.clientcode
--and (ih.origcountry is null --or ih.origcountry ='XX')

-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN
/************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay Added 11/24/2014
************************************************************************/
--Log Activity

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  


GO
