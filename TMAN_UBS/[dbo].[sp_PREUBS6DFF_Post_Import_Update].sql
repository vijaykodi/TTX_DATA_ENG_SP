/****** Object:  StoredProcedure [dbo].[sp_PREUBS6DFF_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS6DFF_Post_Import_Update]

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
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 6DFF-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='US' 
where iatanum ='PREUBS' and recordkey like '%6DFF-%' and (origcountry is null or origcountry ='XX')

UPDATE HTL
SET HTL.HTLREASONCODE1 = UD.UDEFDATA
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,5)
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY AND HTL.IATANUM = UD.IATANUM AND HTL.CLIENTCODE = UD.CLIENTCODE
and htl.seqnum = ud.seqnum and ud.udefdata not like 'z*%' and htl.htlreasoncode1 is null
and HTL.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'HOTEL REASON CODE' AND UD.RECORDKEY LIKE '%6DFF-%'

UPDATE CAR
SET CAR.CARREASONCODE1 = UD.UDEFDATA
--SELECT UD.*
FROM DBA.UDEF UD, DBA.CAR CAR
WHERE CAR.RECORDKEY = UD.RECORDKEY AND CAR.IATANUM = UD.IATANUM AND CAR.CLIENTCODE = UD.CLIENTCODE
and CAR.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'CAR REASON CODE' AND UD.RECORDKEY LIKE '%6DFF-%'
and ud.udefdata like 'c%' AND UD.INVOICEDATE >='12/15/2011' and car.seqnum = ud.seqnum
and ud.udefdata not like 'z*%' and car.carreasoncode1 is null

-- Updating carrcommamt to the total car rate from remarks
update c
set carcommamt = NULL
from dba.car c
where c.recordkey like '%6dff-%' and carcommamt = '0'

update car
set carcommamt = udefdata
from dba.car car, dba.udef u
where car.recordkey = u.recordkey and car.seqnum = u.seqnum
and car.recordkey like '%6dff-%' and udeftype = 'cartotalrate'

-- Updating Amtrak Totalamt to value in U27 field
update i
set totalamt = substring(udefdata,7,6)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%6dff-%' and valcarriercode  in('2V','7O')
and udeftype = 'Z UDID' and udefdata like 'Z*U27%'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6DFF-Amtrak Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----- Update Air Reason Codes if not updated in Parsing ------- LOC 6/1/2012
update i
set reasoncode1 = udefdata
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum and i.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'Z G9 Remarks' and reasoncode1 is null

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6DFF- Air ReasonCode Update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update Text 18 with Online Reason Code ------------------ LOC 6/12/12
-------- Update per Case #19007 ---TBo7.30.2013
update c
set text18 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%6dff-%' and udeftype = 'Z G5 REMARKS'
and udefdata in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')
and text18 is null
and isnull(text8,'Not') like 'Not%' 

------- Update text 9 with Refundable/Non-Refundable Case#21285-----------------TBo/9/3/2013
-------- updated filert for R,U,N as it was not looking for a substring and therefore not updating
-------- the data correctly.... LOC/9/25/2013
-------- also had to update the udefdata like field as it was not strong enough -- loc/9.25.2013

update c
set text9 = right(udefdata,1)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%6dff-%'  AND udefdata like '%G4-%'
AND text9 IS null and right(udefdata,1) in ('R','U','N')

-------- Update Text14 with Approver GPN ----------------LOC/8/15/2012
update c
set text14 = substring(udefdata,7,8)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udefdata like 'Z*U33%' and ((text14 is null) or (text14 like 'Not%'))

-------- Update Text8 with Booker GPN ----------------LOC/8/29/2012
update c
set text8 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype ='SORT 6'
and ((text8 is null) or (text8 like 'Not%'))

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6DFF-Booker/Approver GPN Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update Text6 with T-24 Flag -------- LOC/3/22/2013
update c
set text6 = substring(udefdata,7,3)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udefdata like 'Z*U20%' and text6 is null

-------- Update Text9 with Refundable/Non Refundable -------- LOC 8/29/2013
--update c
--set text9 = substring(udefdata,7,1)
--from dba.udef u, dba.comrmks c
--where u.recordkey = c.recordkey and u.seqnum = c.seqnum
--and u.iatanum = 'preubs'
--and substring(c.recordkey,15,charindex('-',c.recordkey)-15) = '6DFF'
--and udefdata like '%G4-%'
--and text9 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 6DFF-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/25/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'Z G1 REMARKS' and text27 is null

-------Update Text25 = ReasonCode1  String --------------------------- LOC 5/25/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'Z G9 REMARKS' and text25 is null

-------Update Text23 = Trip Purpose  String --------------------------- LOC 5/25/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'SORT 7' and text23 is null

-------Update Text22 = GPN  String --------------------------- LOC 5/25/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'SORT 2' and text22 is null

-------Update Text24 = CostCenter  String --------------------------- LOC 5/25/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'SORT 1' and text24 is null

-------Update Text26 = Hotel Reason Code  String --------------------------- LOC 5/25/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'HOTRSNCODE' and text26 is null

-------Update Text31 = Car Reason Code  String --------------------------- LOC 5/25/2012
update c
set text31 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udefdata like 'h-rc-%' and text31 is null

------ Update Text 13 with Online Reason Code String ------------------ LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udeftype = 'Z G5 REMARKS' and text13 is null

------ Update Text 29 with Approver GPN String ------------------ LOC 8/15/12
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udefdata like 'Z*U33%' and text29 is null

------ Update Text 28 with Booker GPN String ------------------ LOC 8/29/12
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%6dff-%' and udefdata like 'Z*S6%' and text28 is null

-------Update the US 3 character Cost Center to have a leading 0 ------------------------------

update dba.invoicedetail
set remarks5 = right('0000'+remarks5,4)
where right('0000'+remarks5,4) in (select rollup8 from dba.rollup40 where costructid = 'functional')
and len (remarks5) = 3
and iatanum = 'preubs' and recordkey like '%6dff-%' 

update ih
set origcountry = 'KY'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%6dff-%' and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'KY') 

update ih
set origcountry = 'CL'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%6dff-%' and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CL') 

update ih
set origcountry = 'CO'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%6dff-%' and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CO') 

update ih
set origcountry = 'PE'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%6dff-%' and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'PE') 

update ih
set origcountry = 'PA'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%6dff-%' and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'PA') 

--------- Temporary until filxed in Correx code -------------
update  dba.invoicedetail set voidind = 'N' where substring(recordkey,1,6) = 'ozfniy'
 --- tickets were voided and PNR is still live so should be showing --------
 -------- Refer to case 40199 -------------

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 6DFF- ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
