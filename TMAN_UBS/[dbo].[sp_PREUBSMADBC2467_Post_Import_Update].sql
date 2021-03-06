/****** Object:  StoredProcedure [dbo].[sp_PREUBSMADBC2467_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSMADBC2467_Post_Import_Update]


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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start MADBC2467-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='ES'
where iatanum ='PREUBS' and recordkey like '%MADBC2467-%' and (origcountry is null or origcountry ='XX')

---- Update Reasoncode1 ---------------------------------- LOC 5/8/2012 -----------
update i
set reasoncode1 = right(udefdata,2)
from dba.udef u, dba.invoicedetail i
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%MADBC2467-%' and udefdata like '%acesv1%' and reasoncode1 is null

---- Update Htlreasoncode1 -------------------------------LOC 5/8/2012
update h
set  htlreasoncode1= right(udefdata,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%MADBC2467-%' and htlreasoncode1 is null and udefdata like '%acehv1%' and udefdata not like '%/s%'

----- Update Trip Purpose if the DM parsing does not --- LOC 6/13/2012
update i
set remarks1 = substring(udefdata,15,2)
from dba.udef u, dba.invoicedetail i
where u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%MADBC2467-%' and udefdata like 'ACECRM/REATRP%' and isnull(remarks1,'') = ''

----- Update Remarks2 with GPN when DM Parsiing does not ..... LOC 6/13/2012
update i
set remarks2 = substring(udefdata,17,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like 'ACECRM/EMPLEADO-%' and isnull(remarks2,'Unknown') = 'Unknown'


-----  Update text14 with Approver GPN -------------------LOC 5/8/2012
update c
set  text14 = substring(udefdata,6,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%MADBC2467-%' and udefdata like '%appr-%' and text14 is null

-----  Update text47 with EMEA Fare Type ----Where no segment select /S---------------LOC 10/2/2013
update c
set  text47 = right(udefdata,2)
from dba.comrmks c, dba.udef u
where u.iatanum = 'preubs' and u.recordkey = c.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%MADBC2467%' and udefdata like '%ACESV2%' and text47 is null
and u.invoicedate > '4-1-2013' 
and substring(udefdata,15,charindex('/',udefdata)-1) not like '%s%'
and text47 is null

-----  Update text47 with EMEA Fare Type ----With segment select /S---------------LOC 10/2/2013
update c
set text47 = substring(udefdata,charindex('/s',udefdata)-2,2)
from dba.comrmks c, dba.udef u
where u.iatanum = 'preubs' and u.recordkey = c.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%MADBC2467%' and udefdata like '%ACESV2%' and text47 is null
and u.invoicedate > '4-1-2013' 
and substring(udefdata,15,charindex('/',udefdata)-1) like '%s%'
and text47 is null

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%MADBC2467-%' and text18 is null

---------- Update Text 17 to Tractid --- LOC
update c
set  text17 = substring(udefdata,18,6)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%MADBC2467-%' and udefdata like 'ACECRM/SOLICITUD-%' and isnull(text17,'N/A') = 'N/A'

-------- Update Text7 with Project Code --- LOC/11/12/2012
update c
set  text17 = substring(udefdata,17,10)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%MADBC2467-%' and udefdata like 'ACECRM/PROYECTO-PORTUGAL%' and isnull(text7,'N/A') = 'N/A'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation MADBC2467-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like 'ACECRM/SOLICITUD-%'
and isnull(text27,'N/A') = 'N/A'

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like '%/REATRP-%' and text23 is null

-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like 'ACECRM/EMPLEADO-%'
and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like '%CENTRO COSTE-%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like '%acesv1%' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like '%acehv1%' and udefdata not like '%/s%' and text26 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/29/2012
update c
set text29 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2467-%' and udefdata like '%appr-%' and text29 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End MADBC2467-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_pre_ubs_main
 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO
