/****** Object:  StoredProcedure [dbo].[sp_PREUBSRQ4C_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSRQ4C_Post_Import_Update]


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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start RQ4C-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='NZ'
where iatanum ='PREUBS' and recordkey like '%RQ4C-%' and (origcountry is null or origcountry ='XX')

---- Update Remarks2 using udeftype UDID5
update i
set remarks2 = udefdata
from dba.invoicedetail i, dba.udef u 
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid5' and u.recordkey like '%RQ4C-%' and remarks2 is null and i.iatanum = 'preubs'

----Update Remarks1 Trip purpose from udid U62-
update i
set remarks1 = substring(udefdata,5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u62-%'
and u.recordkey like '%RQ4C-%' and remarks1 is null and i.iatanum = 'preubs'

---- Update Remarks5 with Cost Center = U68----------------------------------
update i
set remarks5 = substring(udefdata,5,20)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u68-%'
and u.recordkey like '%RQ4C-%' and remarks5 is null and i.iatanum = 'preubs'

update i
set remarks5 = substring(udefdata,5,20)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u68-%'
and u.recordkey like '%RQ4C-%' 
and remarks5 <> SUBSTRING(udefdata,5,20)
and i.iatanum = 'preubs'
and SUBSTRING(udefdata,5,20) in (select rollup8 from dba.rollup40 where costructid = 'functional')

---- Update Reasoncode1  with U61 ----------------------------------------------
update i
set reasoncode1 = substring(udefdata,5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u61-%'
and u.recordkey like '%RQ4C-%' and reasoncode1 is null and i.iatanum = 'preubs'

---- Update HtlReasonCode 1 -----------------------------------------------------
update h
set htlreasoncode1 = substring(udefdata,5,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u65-%'
and u.recordkey like '%RQ4C-%' and htlreasoncode1 is null and h.iatanum = 'preubs'

---- Update fare compare2 with U69 --------------------------------
update i
set farecompare2 = substring(udefdata,5,20)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u69-%'
and u.recordkey like '%RQ4C-%' and farecompare2 is null and i.iatanum = 'preubs'

---- Update Comrks text17 with TracID
update c
set text17 = substring(udefdata,5,6)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u64-%'
and u.recordkey like '%RQ4C-%' and isnull(text17,'N/A') = 'N/A' and c.iatanum = 'preubs'

-------Update Online Booking -------------------------
update i
set onlinebookingsystem = substring(udefdata,4,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and substring(udefdata,4,2) in ('EB','AA') and substring(udefdata,1,3) = 'X/-'
and i.iatanum = 'preubs'

----- Update text8 with Booker GPN -- LOC/7/30/2012
update c
set text8 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u70-%'
and u.recordkey like '%RQ4C-%' and isnull(text8,'Not') like 'Not%' and c.iatanum = 'preubs'

----- Update text14 with Approver GPN -- LOC/7/30/2012
update c
set text14 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u67-%'
and u.recordkey like '%RQ4C-%' and isnull(text14, 'Not') like 'Not%' and c.iatanum = 'preubs'

----- Update text7 with IBD Project Code GPN -- LOC/7/30/2012
update c
set text7 = substring(udefdata,5,20)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u66-%'
and u.recordkey like '%RQ4C-%' and text7 is null and c.iatanum = 'preubs'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation RQ4C-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udeftype = 'UDID5' and text22 is null

-------Update Text23 = Trip Purpose String ---------------- LOC 5/31/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U62%' and text23 is null

-------Update Text24 = Cost Center String ---------------- LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U68%' and text24 is null

-------Update Text25 = Cost Center String ---------------- LOC 5/31/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U61%' and text25 is null

-------Update Text26 = Cost Center String ---------------- LOC 5/31/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U65%' and text26 is null

-------Update Text27 = TractID String ---------------- LOC 5/31/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U64%' and text27 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 7/30/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U70-%' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 7/30/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%RQ4C-%' and udefdata like 'U67-%' and text29 is null


--Move ID.TTLAMT to ComRmks Num 5 3/25/2015Case #06154137 

update c 
set Num5 = i.totalamt 
from dba.comrmks c, 
dba.invoicedetail i
where c.recordkey = i.recordkey 
and c.seqnum = i.seqnum 
and c.iatanum = 'preubs' 
and I.recordkey like '%RQ4C-%' 
and num5 is null 
and i.voidind='N' 
--and i.exchangeind='N' 
and i.refundind='N' 
and i.VendorType='pretkt'
and i.ProductType='air'
and i.IssueDate>='2015-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='save orig amt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update ID.TTL Amt from UDEF FF50 Case #06154137
update i
set totalamt = cast((substring(udefdata,5,10)*curr.BaseUnitsPerCurr)as decimal)
from DBA.Currency curr, dba.udef u, dba.invoicedetail i, dba.invoiceheader ih
where curr.CurrCode = ih.currcode AND (curr.BaseCurrCode = 'USD'
and curr.CurrBeginDate = I.IssueDate )
and i.recordkey = ih.recordkey
and udefdata like 'U63-%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and I.recordkey like '%RQ4C-%' 
and i.iatanum = 'preubs'
and i.VendorType='pretkt'
and i.ProductType='air'
and i.voidind='N' 
and i.refundind='N' 
and i.IssueDate>='2015-01-01'
AND UdefData NOT IN ('U63-0.00')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID.TotalAmt=FF50',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End RQ4C-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
