/****** Object:  StoredProcedure [dbo].[sp_PREUBSQ2X2_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSQ2X2_Post_Import_Update]


as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start Q2X2-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='UY'
where iatanum ='PREUBS' and recordkey like '%Q2X2-%' and (origcountry is null or origcountry <> 'UY')

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
update c
set text18 = 'N/A'
from dba.comrmks c where iatanum = 'preubs'
and recordkey like '%Q2X2-%'  and text18 is null

-------Update Text8 Booker GPN --------------------------- LOC 8/29/2012
update c
set text8 = substring(udefdata,14,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%Q2X2-%' and udefdata like '.COD8/BOOKER-%'
and ((text8 is null) or (text8 like 'Not%'))

update i
set remarks1 = substring(udefdata,12,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD6/TRIP-%'
and substring(udefdata,12,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')
and isnull(remarks1,'xx') not in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')

-------- Update text6 with T24 Flag ---- LOC/3/22/2013
update c  
set text6 = substring(udefdata,12,3)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD11/T24-%' and text6 is null

-------- Update Remarks5 from Udef ------- LOC/8/15/2013
update i
set remarks5 = substring(udefdata,18,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD1/COSTCENTER-%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation Q2X2-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 6/1/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD2/GPIN-%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 6/1/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD6/TRIP-%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 6/1/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD1/COSTCENTER-%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like 'U*46-%' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like 'U*47-%' and text26 is null

-------Update Text27 = TractID String --------------------------- LOC 6/1/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD9/TRACT-%' and text27 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 6/1/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q2X2-%' and udefdata like '.COD8/BOOKER-%' and text28 is null

-------Update the US 3 character Cost Center to have a leading 0 ------------------------------
update dba.invoicedetail
set remarks5 = right('0000'+remarks5,4)
where right('0000'+remarks5,4) in (select rollup8 from dba.rollup40 where costructid = 'functional')
and len (remarks5) = 3 and iatanum = 'preubs' and recordkey like '%Q2X2-%' 


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End Q2X2-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  








GO
