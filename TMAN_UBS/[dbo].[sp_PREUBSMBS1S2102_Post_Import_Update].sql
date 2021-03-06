/****** Object:  StoredProcedure [dbo].[sp_PREUBSMBS1S2102_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREUBSMBS1S2102_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start MBS1S2102-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='US'
where iatanum ='PREUBS' and recordkey like '%MBS1S2102-%' and (origcountry is null or origcountry ='XX')

/*Update Trip Purpose*/
UPDATE id
SET id.remarks1 = 'DI'
from dba.Udef ud, dba.invoicedetail id
WHERE ud.recordkey = id.recordkey and ud.iatanum = id.iatanum and ud.iatanum = 'PREUBS'
and id.Recordkey like '%MBS1S2102-%' and id.clientcode = ud.clientcode and id.remarks1 is null

/*Update Airline Reason Code*/
UPDATE id
SET id.reasoncode1 = 'A5'
from dba.invoicedetail id, dba.udef ud
WHERE id.recordkey = ud.recordkey
and id.iatanum = ud.iatanum and id.iatanum = 'PREUBS' and id.Recordkey like '%MBS1S2102-%'
and ud.clientcode = id.clientcode

/*Update Hotel Reason Code*/
UPDATE htl
SET htl.htlreasoncode1 = 'H3'
from dba.Udef ud, dba.hotel htl
WHERE ud.recordkey = htl.recordkey and ud.iatanum = htl.iatanum and ud.iatanum = 'PREUBS'
and htl.Recordkey like '%MBS1S2102-%' and htl.clientcode = ud.clientcode

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs'
and recordkey like '%MBS1S2102-%' and text18 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation MBS1S2102-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MBS1S2102-%' and udefdata like 'FF1/%'
and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MBS1S2102-%' and udefdata like 'FF10/%' and text24 is null


-------Update Text23 = Trip Purpose String --------------- LOC 5/31/2012
update c
set text23 = 'Hard Coded to DI'
from dba.comrmks c
where c.iatanum = 'preubs'
and recordkey like '%MBS1S2102-%' and text23 is null

-------Update Text25 = Air ReasonCode1 String -------------- LOC 5/31/2012
update c
set text25 = 'Hard Coded to A5'
from dba.comrmks c
where c.iatanum = 'preubs'
and c.recordkey like '%MBS1S2102-%' and text25 is null

-------Update Text26 = HtlsonCode1 String -------------- LOC 5/31/2012
update c
set text26 = 'Hard Coded to H3'
from dba.comrmks c
where c.iatanum = 'preubs'
and c.recordkey like '%MBS1S2102-%' and text26 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure Ebd MBS1S2102-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
