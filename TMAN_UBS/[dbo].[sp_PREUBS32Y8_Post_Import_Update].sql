/****** Object:  StoredProcedure [dbo].[sp_PREUBS32Y8_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS32Y8_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate =  Null    SET @ENDIssueDate = Null 
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 32Y8-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='GB'
where iatanum ='PREUBS' and recordkey like '%32Y8-%' and (origcountry is null or origcountry ='XX')

--update Air Reason Codes for UK --- Old process updated 5/3/2012 to G9.
--UPDATE id
--SET id.reasoncode1 = case when ud.udefdata = 'A' then 'A1'
--when ud.udefdata = 'P' then 'A4' when ud.udefdata = 'H' then 'RB' when ud.udefdata = 'G' then 'XX'
--when ud.udefdata = 'F' then 'B1' when ud.udefdata = 'C' then 'B2' when ud.udefdata = 'D' then 'B3'
--when ud.udefdata = 'J' then 'B4' when ud.udefdata = 'O' then 'B5' when ud.udefdata = 'B' then 'B6'
--when ud.udefdata = 'M' then 'B7'  end
----select ud.recordkey,ud.udefdata,ud.udeftype,id.reasoncode1
--from dba.invoicedetail id, dba.Udef ud
--WHERE id.recordkey = ud.recordkey
--and id.iatanum = ud.iatanum and id.clientcode = ud.clientcode
--and id.iatanum = 'PREUBS' and id.recordkey like '%32Y8-%' and ud.udeftype = 'AIRREASONCD'
--and id.reasoncode1 not in ('A1','A4','RB','XX','B1','B2','B3','B4','B5','B6','B7')

update i
set reasoncode1 = substring(udefdata,4,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%32Y8-%' and udefdata like 'G9-%'
and isnull(reasoncode1,'X') <> substring(udefdata,4,2)

--------- Not mapping incorrect codes to UBS codes per Ryan 5/3/2012 ----------------------------
--Update i
--set reasoncode1 = case when reasoncode1 = 'PC' then 'A1'
--when reasoncode1 = 'UG' then 'A4' when reasoncode1 = 'NR' then 'A6' when reasoncode1 = 'BC' then 'B1'
--when reasoncode1 = 'CP' then 'B2' when reasoncode1 = 'ST' then 'B3' when reasoncode1 = 'AP' then 'B5'
--when reasoncode1 = 'MI' then 'B6' when reasoncode1 = 'NO' then 'B7' when reasoncode1 = 'CC' then 'B8'
--when reasoncode1 in('RB','XX') then 'A1' end 
--from dba.invoicedetail i where iatanum = 'preubs'
--and substring(i.recordkey,15,charindex('-',i.recordkey)-15) = '32Y8'
--and reasoncode1 in ('PC','UG','NR','BC','CP','ST','AP','MI','NO','CC','RB','XX')

--Update Remarks2 with EmployeeID
UPDATE id
SET id.remarks2 = SUBSTRING(UD.UDEFDATA,3,8)
FROM DBA.UDEF UD, DBA.InvoiceDetail id
WHERE id.RECORDKEY = UD.RECORDKEY
AND id.IATANUM = UD.IATANUM AND id.CLIENTCODE = UD.CLIENTCODE
and id.seqnum = ud.seqnum and ud.udefdata like 'CR%' and id.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'ACCTDTLS'
AND UD.RECORDKEY LIKE '%32Y8-%'


--- Randomly Trip Purpose is not getting updated -- this is to catch those that did not get updated 
update i
set remarks1 = substring(udefdata,charindex('/',udefdata)-5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%32Y8-%' 
--and remarks1 <> substring(udefdata,charindex('/',udefdata)-5,2)
and udefdata like 'cr%..%..%' and remarks1 is  null

----- Update text 8 with Bookers GPN ------------------ LOC 5/9/2012
----- Updated per Case #19007 ----TBo 7.30.2013
update c
set text8 = udefdata
from dba.udef u, dba.comrmks c
where u.iatanum = 'preubs'
and u.recordkey = c.recordkey and u.seqnum = u.seqnum
and u.recordkey like '%32Y8-%' and udeftype = 'xrefc' and text8 is null and isnull(text8,'Not') like 'Not%' 

----- Update text14 with Approver GPN ---------------- LOC 5/9/2012
----- Updated per Case #19007 ----TBo 7.30.2013
update c
set text14 = udefdata
from dba.udef u, dba.comrmks c
where u.iatanum = 'preubs' and u.recordkey = c.recordkey and u.seqnum = u.seqnum
and u.recordkey like '%32Y8-%' and udeftype = 'xrefb' and text14 is null and isnull(text14,'Not') like 'Not%' 

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Booker/Approver Mapping 32Y8-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----- Update Text18 with Online Reason code ----------- LOC 6/12/12
update c
set text18 = substring(udefdata,33,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'CR%..%Y%'
and u.recordkey like '%32Y8-%' and substring(udefdata,33,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')
and text18 is null

----- Update Text17 with TractID ----------- LOC 9/20/12
----- Added as some PNR's are not being updated from the DM parsing
update c
set  text17 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udeftype = 'XREFD'
and  isnull(udefdata,'X') like '%' and not ((udefdata  like '[1-9][0-9][0-9][0-9][0-9]') or 
(udefdata like '[1-9][0-9][0-9][0-9][0-9][0-9]')or (udefdata = 'O'))
and isnull(text17,'N/A') = 'N/A' and c.invoicedate > '9-1-2012' and udefdata not like '1111%'

--------Update Text 7 with Project Code --------LOC/11/13/12
update c
set  text7 = substring(udefdata,charindex('....',udefdata)+5, 10)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%32Y8-%' 
and udefdata like '%cr%....%' and udefdata not like '%cr%.......%' and isnull(text7,'N/A') = 'N/A' 

----- Update text 6 with T24 Flag ------------------ LOC 5/9/2012
update c
set text6 = udefdata
from dba.udef u, dba.comrmks c
where u.iatanum = 'preubs'
and u.recordkey = c.recordkey and u.seqnum = u.seqnum
and u.recordkey like '%32Y8-%' and udeftype = 'xrefe' and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 32Y8-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/25/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udeftype = 'XREFD' and text27 is null

-------Update Text26 = HtlReasonCode1 --------------------------- LOC 5/25/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like 'G8-%' and text26 is null

-------Update Text23 = Trip Purpose --------------------------- LOC 5/25/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like 'CR%' and text23 is null

-------Update Text22 = GPN--------------------------- LOC 5/25/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like 'CR%' and text22 is NULL

-------Update Text24 = Cost Center--------------------------- LOC 5/25/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like 'CR%' and text24 is null

-------Update Text25 = Air ReasonCode String --------------------------- LOC 5/25/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like 'G9-' and text25 is null

-------Update Text28 = Bookers GPN String --------------------------- LOC 5/25/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udeftype = 'xrefc' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udeftype = 'xrefb' and text29 is null

----- Update Text13 with Online Reason code String ----------- LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like 'CR%..%Y%' and text13 is NULL

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47=  SUBSTRING(udefdata,41,1)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%32Y8-%' and udefdata like '%yo..nc%' 
and text47 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 32Y8-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
