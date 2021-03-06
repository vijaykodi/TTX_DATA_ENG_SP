/****** Object:  StoredProcedure [dbo].[sp_PREUBSR539_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSR539_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start R539-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='AU'
where iatanum ='PREUBS' and recordkey like '%R539-%' and (origcountry is null or origcountry ='XX')

---- Update Remarks2 using udeftype UDID5
update i
set remarks2 = udefdata
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid5' and u.recordkey like '%R539-%' and remarks2 is null and u.iatanum = 'preubs'

----Update Remarks1 Trip purpose from udid U62-
update i
set remarks1 = substring(udefdata,5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u62-%'
and u.recordkey like '%R539-%' and remarks1 is null and u.iatanum = 'preubs'

---- Update Remarks5 with Cost Center = U68----------------------------------
update i
set remarks5 = substring(udefdata,5,20)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u68-%'
and u.recordkey like '%R539-%' and remarks5 is null and u.iatanum = 'preubs'

---- Update Reasoncode1  with U61 ----------------------------------------------
update i
set reasoncode1 = substring(udefdata,5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u61-%'
and u.recordkey like '%R539-%' and reasoncode1 is null and u.iatanum = 'preubs'

---- Update HtlReasonCode 1 -----------------------------------------------------
update h
set htlreasoncode1 = substring(udefdata,5,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u65-%'
and u.recordkey like '%R539-%' and htlreasoncode1 is null and u.iatanum = 'preubs'

---- Update fare compare2 with U69 -------9/11/14 Yap advised include exchanges in this update----------
update i
set farecompare2 = substring(udefdata,5,20)*CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase--,cast(substring(udefdata,5,20)as float) 
from dba.invoicedetail i, dba.udef u,
DBA.Currency CURRBASE,DBA.Currency CURRTO 
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u69-%'
and u.recordkey like '%R539-%' 
and farecompare2 is null 
and u.iatanum = 'preubs' and servicedate > '11-1-2013' 
and ((substring(udefdata,5,20) like '[0-9][0-9][0-9].[0-9][0-9]')
or(substring(udefdata,5,20) like '[0-9][0-9][0-9][0-9].[0-9][0-9]')
or(substring(udefdata,5,20) like '[0-9][0-9][0-9][0-9][0-9].[0-9][0-9]')
or(substring(udefdata,5,20) like '[0-9][0-9].[0-9][0-9]'))
 and CURRBASE.CurrCode = 'AUD' 
 AND CURRBASE.CurrBeginDate = I.InvoiceDate 
 AND CURRBASE.BaseCurrCode = 'USD' 
 and CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
 AND CURRTO.CurrCode = 'USD' 
and i.VendorType='pretkt'
and i.ProductType='air'


---- Update Comrks text17 with TracID
update c
set text17 = substring(udefdata,5,7)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u64-%'
and u.recordkey like '%R539-%' and isnull(text17,'N/A') = 'N/A'  and u.iatanum = 'preubs'

-------Update Online Booking -------------------------
update i
set onlinebookingsystem = substring(udefdata,4,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey
and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and u.recordkey like '%R539-%' and substring(udefdata,4,2) in ('EB','AA') and substring(udefdata,1,3) = 'X/-'
and u.iatanum = 'preubs' and onlinebookingsystem is null

------Update Text8 with Booker GPN ---- LOC/7/30/2012

update c
set text8 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u70-%'
and u.recordkey like '%R539-%' and text8 is null and u.iatanum = 'preubs'

-----Update Text14 with Approver GPN ----- LOC/7/30/2012
update c
set text14 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u67-%'
and u.recordkey like '%R539-%' and text14 is null and u.iatanum = 'preubs'

----- Update text7 with IBD Project Code ---- LOC/7/30/2012
update c
set text7 = substring(udefdata,5,20)
from dba.comrmks c, dba.udef u 
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'udid' and udefdata like 'u66-%'
and u.recordkey like '%R539-%' and text7 is null and u.iatanum = 'preubs'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Begin Update to Comrmks for Validation R539-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U64-%' and text27 is null

-------Update Text26 =HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U65-%' and text26 is null

-------Update Text25 =ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U61-%' and text25 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U62-%' and text23 is null

-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udeftype = 'UDID5' and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U68-%' and text24 is null

-------Update Text28 = Booker GPN String --------------------------- LOC 7/30/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U70-%' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 7/30/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%R539-%' and udefdata like 'U67-%' and text29 is null


SET @TransStart = getdate()
--convert exchanged tkt mileage to positive nbr to be consistant with post trip data
update i
set  mileage = mileage*-1
from dba.invoicedetail i
where i.mileage <0 
and i.exchangeind = 'y'
and i.iatanum ='PREUBS' and i.recordkey like '%R539-%'


-----Move ID.TTLAMT to ComRmks Num 5 10/29/2013 Case #22650 
--9/11/14 Yap advised include exchanges in this update-

update c 
set Num5 = i.totalamt 
from dba.comrmks c, 
dba.invoicedetail i
where c.recordkey = i.recordkey 
and c.seqnum = i.seqnum 
and c.iatanum = 'preubs' 
and I.recordkey like '%R539-%' 
and num5 is null 
and i.voidind='N' 
--and i.exchangeind='N' 
and i.refundind='N' 
and i.VendorType='pretkt'
and i.ProductType='air'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-R539-U63 save orig amt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-----Update ID.TTLAMT to prorated amt from U63 10/29/2013 Case #22650 
--9/11/14 Yap advised include exchanges in this update-
update i 
set i.totalamt= 
 i.mileage/(SELECT SUM(iSUB.mileage) ttlmiles
FROM dba.invoicedetail iSUB 
WHERE iSUB.gdsrecordlocator = i.gdsrecordlocator 
AND iSUB.iatanum = I.iatanum 
and iatanum = 'preubs' 
-- AND isub.exchangeind = 'N' 
 AND isub.voidind = 'N' 
 and isub.RefundInd='n' 
 and isub.VendorType='pretkt'
and isub.ProductType='air'
 AND SUBSTRING(I.recordkey, 15, CHARINDEX('-', I.recordkey) - 15) = 'R539' 
 AND i.iatanum = 'preubs')* CAST (SUBSTRING(u.UdefData,5, 255) AS FLOAT)*CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase

FROM dba.invoicedetail i , 
dba.udef u , 
DBA.Currency CURRBASE,DBA.Currency CURRTO 
where i.recordkey = u.recordkey 
AND i.clientcode = u.clientcode 
AND i.iatanum = u.iatanum 
AND i.seqnum = u.seqnum 
and u.udeftype = 'udid' 
AND u.udefdata LIKE 'u63-%' 
AND u.recordkey like '%R539-%' 
AND i.iatanum = 'preubs' 
AND i.issuedate >= '2013-11-01' 
--AND i.exchangeind = 'N' 
and i.RefundInd='n' 
and VoidInd='n' 
and udefdata not like '%u63-0%' 
and udefdata not like '%u63-.' 
and udefdata not like '%u63-' 
and udefdata not like '%u63-N%' 
and i.VendorType='pretkt'
and i.ProductType='air'
 and CURRBASE.CurrCode = 'AUD' 
 AND CURRBASE.CurrBeginDate = I.InvoiceDate 
 AND CURRBASE.BaseCurrCode = 'USD' 
 and CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
 AND CURRTO.CurrCode = 'USD' 
 and mileage is not null 
 and isnumeric(SUBSTRING(UdefData,5,255))=1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-R539-U63 prorate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-Stored Procedure End R539-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
