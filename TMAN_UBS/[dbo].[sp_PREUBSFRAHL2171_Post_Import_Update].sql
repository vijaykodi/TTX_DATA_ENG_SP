/****** Object:  StoredProcedure [dbo].[sp_PREUBSFRAHL2171_Post_Import_Update]    Script Date: 7/14/2015 7:39:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREUBSFRAHL2171_Post_Import_Update]
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start FRAHL2171-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='DE'
where iatanum ='PREUBS' and recordkey like '%FRAHL2171-%' and (origcountry is null or origcountry ='XX')

---Update htl.reasoncode1 wit udef data
UPDATE HTL
SET  HTL.HTLREASONCODE1 = case
when substring(udefdata,13,2)in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')
	then substring(udefdata,13,2)
when substring(udefdata,12,2) in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')
	then substring(udefdata,12,2)
when substring(udefdata,14,2) in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')
	then substring(udefdata,14,2)
when substring(udefdata,15,2) in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')
	then substring(udefdata,15,2)
end
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY
AND HTL.seqnum = UD.seqnum AND HTL.CLIENTCODE = UD.CLIENTCODE
AND htl.recordkey like '%FRAHL2171-%' AND udefdata LIKE 'HHF-%'
and isnull(htlreasoncode1,'') not in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')

----------------------------------------------------------
--Update online booking system to = Y where booking agent = 0088GT

update dba.invoicedetail
set onlinebookingsystem = 'Y'
where bookingagentid = '0088GT' and recordkey like '%FRAHL2171-%'
and onlinebookingsystem <> 'Y'

------ Update Cost Center ----------------------------------------LOC 5/7/2012
update i
set remarks5 = substring(udefdata,(charindex('&kks',udefdata)+5),9)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like '%verk%&kks%'
and substring(udefdata,(charindex('&kks',udefdata)+5),9) not like '%&%'
and substring(udefdata,(charindex('&kks',udefdata)+5),9) not like '%/p%'
and remarks5 is null

------------ update cost center when person number present ---------
---------------------------- Person 1 ------------------------------
update i
set remarks5 = substring(udefdata,(charindex('&kks',udefdata)+5),5)
from dba.udef u, dba.invoicedetail i, TTXSASQL01.tman503_correx.dbo.pnr_name_all n
where u.recordkey like '%FRAHL2171-%' and u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and udefdata like '%verk%&kks%'
and right(u.recordkey,8) = right(n.pnr_id,8)
and right(u.udefdata,1) = '1'
and n.namenum  = '1.' and i.lastname = n.lastname and i.firstname = n.firstname
and substring(udefdata,(charindex('&kks',udefdata)+5),9) not like '%&%'
and substring(udefdata,(charindex('&kks',udefdata)+5),9) like '%/p%'
and remarks5 is null
-----------------------------Person 2 ------------------------------
update i
set remarks5 = substring(udefdata,(charindex('&kks',udefdata)+5),5)
from dba.udef u, dba.invoicedetail i, TTXSASQL01.tman503_correx.dbo.pnr_name_all n
where u.recordkey like '%FRAHL2171-%' and u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and udefdata like '%verk%&kks%'
and right(u.recordkey,8) = right(n.pnr_id,8)
and right(u.udefdata,1) = '2'
and n.namenum  = '2.' and i.lastname = n.lastname and i.firstname = n.firstname
and substring(udefdata,(charindex('&kks',udefdata)+5),9) not like '%&%'
and substring(udefdata,(charindex('&kks',udefdata)+5),9) like '%/p%'
and remarks5 is null

-----------Update Text14 with Aprover ------- LOC 5/7/2012 -----
update c
set text14 =  substring(udefdata,charindex('appr',udefdata)+5,8)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%FRAHL2171-%' and udefdata like 'appr%' and text14 is null

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
update c
set text18 = 'N/A'
from dba.comrmks c
where iatanum = 'preubs' and recordkey like '%FRAHL2171-%' and text18 is null

-------- Update Text7 with Project coce -------- LOC/11/12/2012
update c
set text7 =  substring(udefdata,12,10)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%FRAHL2171-%' and udefdata like 'verk+:proj:%%' and text7 is null

------- Update Text6 with T24 Flag from Udef data ------- LOC/3/19/2013
update c
set text6 =  substring(udefdata,5,3)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%FRAHL2171-%' and udefdata like '%CD7-%' and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation FRAHL2171-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like 'ORDREF-%' and text27 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like '%lf-%rc-%' and text25 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like 'RTRIP-%' and text23 is null

-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like 'VERK+:PERS-NR%' and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like 'VERK+:KKS%' and text24 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like 'HHF%' and udeftype = 'RM OTHER'
and text26 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/29/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like '%appr%' and udeftype = 'rm other'
and text29 is NULL

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= SUBSTRING(UdefData,CHARINDEX('HC-',udefdata)+3,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%FRAHL2171-%' and udefdata like 'LF-%HF-%RC-%' and text47 is NULL





EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End FRAHL2171-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC sp_PRE_UBS_MAIN_Mini 


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  












GO
