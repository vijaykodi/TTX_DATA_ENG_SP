/****** Object:  StoredProcedure [dbo].[sp_PREUBS3F1F_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBS3F1F_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 3F1F-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='BR' where iatanum ='PREUBS' and recordkey like '%3F1F-%'and (origcountry is null or origcountry ='XX')

UPDATE  htl
SET htl.htlreasoncode1 = udefdata
FROM    dba.Hotel htl , dba.udef ud
WHERE   htl.recordkey = ud.recordkey
AND htl.iatanum = ud.iatanum AND htl.seqnum = ud.seqnum AND htl.clientcode = ud.clientcode
AND htl.recordkey like '%3F1F-%' AND ud.udeftype = 'HOTEL REASON CODE'

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%3F1F-%' and text18 is null

-------- Update Remarks2 with GPN --------------------------------------- LOC/8/31/2012
update i
set remarks2 = substring(udefdata,10,8)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and isnull(remarks2,'Unknown') = 'Unknown' and udefdata like 'Z*CLRF02-%'

-------- Update Remarks1 with Trip Purpose ------------------------------ LOC/8/31/2012
update i
set remarks1 = substring(udefdata,10,2)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and remarks1 is NULL and udefdata like '%Z*CLRF06-%'

-------- Update Remarks5 with Cost Center ------------------------------LOC/8/31/2012
update i
set remarks5 = substring(udefdata,10,15)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and isnull(remarks5,'3F1F') = '3f1f' and udefdata like 'Z*CLRF01-%'

-------- Update Hotel Reason Code  ------------------------------------LOC/8/31/2012
update h
set htlreasoncode1 = substring(udefdata,13,12)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs' and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and htlreasoncode1 is NULL and udefdata like 'H-HTLREASON-%'

-------- Update Booker GPN--------------------------------------------LOC/8/31/2012
-------- Updated per case #19007-----TBo7.30.2013
update c
set text8 = substring(udefdata,10,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and text8 is NULL and udefdata like 'Z*CLRF08-%'
and isnull(text8,'Not') like 'Not%' 

-------- Update Approver GPN-------------------------------------------LOC/8/31/2012
-------- Updated per case #19007-----TBo7.30.2013
update c
set text14 = substring(udefdata,10,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and text14 is NULL and udefdata like 'Z*CLRF07-%'
and isnull(text14,'Not') like 'Not%' 

-------- Update TractID -----------------------------------------------LOC/8/31/2012
update c
set text17 = substring(udefdata,10,7)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and text17 is NULL and udefdata like 'Z*CLRF09-%'

-------- Update Text6 with T24 Flag -------- LOC/3/22/2013
update c
set text6 =  substring(udefdata,10,3)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%3F1F-%' and text17 is NULL and udefdata like 'Z*CLRF12-%' and text6 is null


-------- Update farecompare2 with Low Fare (ticket 1)--------------------------LOC/8/31/2012
update i
set farecompare2 = cast((substring(udefdata,15,charindex('-',udefdata)-1)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))as decimal)
from DBA.Currency CURRBASE,DBA.Currency CURRTO, dba.udef u, dba.invoicedetail i
where CURRTO.CurrCode ='USD' AND (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode
and CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate    AND CURRBASE.CurrCode = I.CurrCode
and CURRBASE.CurrBeginDate = I.IssueDate AND CURRBASE.BaseCurrCode = 'USD')
and udefdata like 'Z*TKT1-LWFARE-%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%3F1F-%' and i.farecompare2 is null
and i.iatanum = 'preubs'

-------- Update farecompare2 with Low Fare (ticket 2)--------------------------LOC/8/31/2012
update i2
set i2.farecompare2 = cast((substring(udefdata,15,charindex('-',udefdata)-1)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))as decimal)
from DBA.Currency CURRBASE,DBA.Currency CURRTO, dba.udef u, dba.invoicedetail i, dba.invoicedetail i2
where CURRTO.CurrCode ='USD' AND (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode
and CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate    AND CURRBASE.CurrCode = I.CurrCode
and CURRBASE.CurrBeginDate = I.IssueDate AND CURRBASE.BaseCurrCode = 'USD')
and udefdata like 'Z*TKT2-LWFARE-%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey = i2.recordkey and i2.seqnum > i.seqnum and  i.voidind = 'n' and i2.voidind = 'n'
and i.recordkey like '%3F1F%'
and i2.farecompare2 is null
and i.iatanum = 'preubs'

-------- Update Reasoncode1 for 1st ticket ------------------------------LOC/8/31/2012
update i
set reasoncode1 = substring(udefdata,charindex('RC-',udefdata)+3,2)
from dba.udef u, dba.invoicedetail i
where udefdata like 'Z*TKT1-LWFARE-%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like  '%3F1F%'
and isnull(i.reasoncode1,'z') = 'z'

-------- Update Reasoncode1 for 2nd ticket ------------------------------LOC/8/31/2012
update i2
set i2.reasoncode1 = substring(udefdata,charindex('RC-%',udefdata),2)
from dba.udef u, dba.invoicedetail i, dba.invoicedetail i2
where udefdata like 'Z*TKT2-LWFARE-%' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like  '%3F1F%'
and i2.reasoncode1 is null
and i.recordkey = i2.recordkey and i2.seqnum > i.seqnum and  i.voidind = 'n' and i2.voidind = 'n'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 3F1F-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and udefdata like 'H-USTRVLAPPR-%' and text22 is null

-------- New format as of September 2012------------------------------LOC/8/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' and text22 is null and udefdata like 'Z*CLRF02-%'

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%'  and udefdata like 'Z*CLRF06-%' and text23 is null

-------- New format as of September 2012------------------------------LOC/8/31/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' and text23 is null and udefdata like 'Z*CLRF06-%'


-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%3F1F-%' and udefdata like '%Z*CLRF06-%' and text24 is null

-------- New format as of September 2012------------------------------LOC/8/31/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' and text24 is null and udefdata like 'Z*CLRF01-%'


-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%'  and udefdata like 'H-REASON-%' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and udefdata like 'H-HTLREASON-%' and text26 is null

-------- New format as of September 2012------------------------------LOC/8/31/2012
update c
set text26 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and text26 is null and udefdata like 'H-HTLREASON-%'

-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and udefdata like 'H-USTRVLAPPR-%' and text27 is null

-------- New format as of September 2012------------------------------LOC/8/31/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and text27 is null and udefdata like 'Z*CLRF09-%'

-------- Update Text 28 with Booker GPN String ----------------------LOC/8/31/2012
update c
set text28 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and text28 is null and udefdata like 'Z*CLRF08-%'

-------- Update Text 29 with Approver GPN String ----------------------LOC/8/31/2012
update c
set text28 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%3F1F-%' 
and text28 is null and udefdata like 'Z*CLRF07-%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End 3F1F-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
--EXEC sp_PRE_UBS_MAIN

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  








GO
