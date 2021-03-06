/****** Object:  StoredProcedure [dbo].[sp_PREUBSC5S8_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSC5S8_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start C5S8-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='MY'
where iatanum ='PREUBS' and recordkey like '%C5S8-%' and (origcountry is null or origcountry ='XX')

---- Update Remarks2 with FF13 ------------------------------------------------
update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF13/%' and remarks2 is null

---- Update Trip Purpose FF11/ -----------------------------------------------
update i
set remarks1 = substring(udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF11/%' and remarks1 is null

---- Update Cost Center FF15/ -----------------------------------------------
update i
set remarks5 = substring(udefdata,6,20)
from dba.invoicedetail i, dba.udef u
where u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF15/%' and remarks5 is null

---- Update Fare Compare2  FF53/LF-/ -----------------------------------------------
update i
set farecompare2 = substring(udefdata,9,20)
from dba.invoicedetail i, dba.udef u
where u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF53/FL-%' and farecompare2 is null

---- Update Hotel Reasoncode1  FF18/ -----------------------------------------------
update h
set htlreasoncode1 = substring(udefdata,6,2)
from dba.hotel h, dba.udef u
where u.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF18%' and htlreasoncode1 is null

---- Update Air Reasoncode 1 from Udef - FF12/ -----------------------------------------------
update i
set reasoncode1 = substring(udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where u.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF12/%' and reasoncode1 is null

---- Update TracID from Udef - FF14/ -----------------------------------------------
update c
set text17 = substring(udefdata,6,20)
from dba.comrmks c, dba.udef u
where u.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%C5S8-%' and udeftype = '5XREMARKS' and udefdata like 'FF14/%' 
and isnull(text17,'N/A') = 'N/A'

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%C5S8-%' and text18 is null 

----- Update Text8 with Booker GPN -- LOC/9/4/2012
update c
set text8 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where  u.recordkey like '%C5S8-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF16%'

----- Update Text14 with Approver GPN -- LOC/9/4/2012
update c
set text14 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%C5S8-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not') like 'Not%' and u.iatanum = 'preubs' and udefdata like 'FF19%'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation C5S8-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 6/1/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF13/%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 6/1/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF11/%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 6/1/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF15/%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF12/%'
and text25 is null

-------Update Text26 = HtlReasonCode21 String --------------------------- LOC 6/1/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF18/%'
and text26 is null

-------Update Text27 = TractID String --------------------------- LOC 6/1/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF14/%'
and text27 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 9/4/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF16/%'
and text28 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%C5S8-%' and udefdata like 'FF19/%'
and text29 is null


--Move ID.TTLAMT to ComRmks Num 5 3/25/2015Case #06154137 

update c 
set Num5 = i.totalamt 
from dba.comrmks c, 
dba.invoicedetail i
where c.recordkey = i.recordkey 
and c.seqnum = i.seqnum 
and c.iatanum = 'preubs' 
and I.recordkey like '%C5S8-%' 
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
set totalamt = cast((substring(udefdata,9,10)*curr.BaseUnitsPerCurr)as decimal)
from DBA.Currency curr, dba.udef u, dba.invoicedetail i, dba.invoiceheader ih
where curr.CurrCode = ih.currcode AND (curr.BaseCurrCode = 'USD'
and curr.CurrBeginDate = I.IssueDate )
and i.recordkey = ih.recordkey
and udefdata like 'FF50/SF-%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and I.recordkey like '%C5S8-%' 
and i.iatanum = 'preubs'
and i.VendorType='pretkt'
and i.ProductType='air'
and i.voidind='N' 
and i.refundind='N' 
and i.IssueDate>='2015-01-01'
AND UdefData NOT IN ('FF50/SF-0')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID.TotalAmt=FF50',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End C5S8-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN







GO
