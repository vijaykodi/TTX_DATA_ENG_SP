/****** Object:  StoredProcedure [dbo].[sp_PREUBS6G2L_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PREUBS6G2L_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_START - END
************************************************************************/

--Log Activity

/*Get min and max invoicedate from dba.InvoiceHeader for most recent import*/ 
SET @TransStart = getdate()

select @BeginIssueDate =min(InvoiceDate), @EndIssueDate = max(InvoiceDate)
from dba.InvoiceHeader ih
where ih.iatanum = 'preubs'
and ih.recordkey like '%6G2L-%'
and ih.importdt = (select max(ImportDt) from dba.InvoiceHeader ih2
					where ih2.iatanum = 'preubs'
					and ih2.recordkey like '%6G2L-%')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PREUBS6G2L-Get Begin and End Dates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
raiserror('PREUBS6G2L Get Dates',0,1) with nowait

/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='PH'
where iatanum ='PREUBS' and recordkey like '%6G2L-%'
and (origcountry is null or origcountry ='XX')

---- Update GPN from Udef like FF25/FF2----------------------------------------
update i
set remarks2 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%6G2L-%' and isnull(remarks2,'Unknown') = 'Unknown' and udefdata like 'FF25/%'
and substring(udefdata,6,8) in (select corporatestructure from dba.rollup40 where costructid = 'functional')

update i
set remarks2 = substring(udefdata,5,8)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%6G2L-%' and isnull(remarks2,'Unknown') = 'Unknown' and udefdata like 'FF2/%'
and substring(udefdata,5,8) in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and isnull(remarks2,'Unknown') = 'Unknown'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='GPN Updated',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---- Update Trip Purpose from Udef FF12/ -----------------------------------
update i
set remarks1 = substring(udefdata,6,2)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%6G2L-%' and remarks1 is null and udefdata like 'FF12/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Trip Purpose Updated',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---- Update Cost Center From Udef16 -------------------------------------
update i
set remarks5 = substring(udefdata,6,20)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%6G2L-%' and remarks5 is null and udefdata like 'FF16/%'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center Updated',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update reasoncode1 from FF13 field-------
SET @TransStart = getdate()

update id
set reasoncode1 = substring(udefdata,6,2)
from dba.udef u, dba.invoicedetail id
where u.recordkey like '%6G2L-%' and u.recordkey = id.recordkey and u.seqnum = id.seqnum
and reasoncode1 is null and u.iatanum = 'preubs'
and udefdata like 'ff13%' and substring(udefdata,6,2) in (select lookupvalue 
	from dba.lookupdata where lookupname = 'reascode')

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ReasonCode1 Updated',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
	
	--------Update Fare Compare 2 when not updated in Dataman Parsing ..... 
update i
set farecompare2 = cast((substring(udefdata,6,10)*curr.BaseUnitsPerCurr)as decimal)
from DBA.Currency curr, dba.udef u, dba.invoicedetail i, dba.invoiceheader ih
where curr.CurrCode = ih.currcode AND (curr.BaseCurrCode = 'USD'
and curr.CurrBeginDate = I.IssueDate )
and i.recordkey = ih.recordkey
and udefdata like 'FF53%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%6G2L-%'
and i.iatanum = 'preubs' and substring(udefdata,6,10) like '%[0-9]%'
and isnull(farecompare2,'0') = '0'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='FareCompare2 Updated',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Move ID.TTLAMT to ComRmks Num 5 3/25/2015Case #06154137 
update c 
set Num5 = i.totalamt 
from dba.comrmks c, 
dba.invoicedetail i
where c.recordkey = i.recordkey 
and c.seqnum = i.seqnum 
and c.iatanum = 'preubs' 
and I.recordkey like '%6G2L-%' 
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
set totalamt = cast((substring(udefdata,6,10)*curr.BaseUnitsPerCurr)as decimal)
from DBA.Currency curr, dba.udef u, dba.invoicedetail i, dba.invoiceheader ih
where curr.CurrCode = ih.currcode AND (curr.BaseCurrCode = 'USD'
and curr.CurrBeginDate = I.IssueDate )
and i.recordkey = ih.recordkey
and udefdata like 'FF50/%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and I.recordkey like '%6G2L-%' 
and i.iatanum = 'preubs'
and i.VendorType='pretkt'
and i.ProductType='air'
and i.voidind='N' 
and i.refundind='N' 
and i.IssueDate>='2015-01-01'
AND UdefData NOT LIKE ('FF50/*%')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID.TotalAmt=FF50',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---- Update Hotel Reason Code from Udef FF19/ -------------------------------
update h
set htlreasoncode1 = substring (udefdata,6,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs' and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%6G2L-%' and htlreasoncode1 is null and udefdata like 'FF19/%'
and substring(udefdata,6,2) in (select lookupvalue from dba.lookupdata where lookupname = 'reascode')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PREUBS6G2L-Update text15 = Secured Ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
raiserror('PREUBS6G2L Update reasoncode1',0,1) with nowait

------ Online booking --
SET @TransStart = getdate()

UPDATE ID
SET id.onlinebookingsystem = RIGHT(RTRIM(UD.UDEFDATA), 2)
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,5)
FROM DBA.UDEF UD, DBA.invoicedetail ID
WHERE id.RECORDKEY = UD.RECORDKEY AND id.IATANUM = UD.IATANUM
AND id.CLIENTCODE = UD.CLIENTCODE AND UD.UDEFTYPE = 'ACCTDTLS'
AND ID.recordkey like '%6G2L-%' AND SUBSTRING(UD.UDEFDATA,1,5) LIKE 'FF34/'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PREUBS6G2L-Update onlinebookingsystem',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
raiserror('PREUBS6G2L Update onlinebookingsystem',0,1) with nowait

----- Update Text17 with TrackID from Udef FF15/ ----------------------------
update c
set text17 = substring (udefdata,6,20)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%6G2L-%' and text17 is null and udefdata like 'FF15/%'

----- Update Text8 with Booker GPN --?? NEED TO VALIDATE DATA ON THIS ONE
update c
set text8 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%6G2L-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and isnull(text8,'Not Valid') = 'Not Valid' and u.iatanum = 'preubs' and udefdata like 'FF17%'

----- Update Text14 with Approver GPN -- 

update c
set text14 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%6G2L-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and text14 is null and u.iatanum = 'preubs' and udefdata like 'FF20%'
and isnull(text14,'Not') like 'Not%' 

----- Update Text7 with IBD Project Code --
update c
set text7 = substring(udefdata,6,8)
from dba.udef u, dba.comrmks c
where u.recordkey like '%6G2L-%' and u.recordkey = c.recordkey and u.seqnum = c.seqnum
and text7 is null and u.iatanum = 'preubs' and udefdata like 'FF18%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 6G2L-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- 
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6G2L-%' and udefdata like 'FF15/%' and text27 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- 
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6G2L-%' and udefdata like 'FF19/%' and text26 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- 
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6G2L-%' and udefdata like 'FF13/%' and text25 is null

-------Update Text23 = Trip Purpose String --------------------------- 
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6G2L-%' and udefdata like 'FF12/%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- 
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6G2L-%' and udefdata like 'FF16/%' and text24 is null

-------Update Text22 = GPN String --------------------------- 
update c
set text22 = (u.udefdata + ' -- ' + uu.udefdata)
from dba.comrmks c, dba.udef u, dba.udef uu
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.recordkey = uu.recordkey and c.seqnum = uu.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6G2L-%' and u.udefdata like 'FF2/%' and uu.udefdata like 'FF25/%'
and text22 is null

-------Update Text28 = Booker GPN String --------------------------- 
update c
set text28 = u.udefdata 
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%6G2L-%'  and u.udefdata like 'FF17%' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- 
update c
set text29 = u.udefdata 
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and substring(u.recordkey,15,5) = '6G2L-'  and u.udefdata like 'FF20%' and text29 is null

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PREUBS6G2L- Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC sp_PRE_UBS_MAIN_Mini 

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  





GO
