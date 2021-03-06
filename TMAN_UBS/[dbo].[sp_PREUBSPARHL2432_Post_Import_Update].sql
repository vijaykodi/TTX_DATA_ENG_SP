/****** Object:  StoredProcedure [dbo].[sp_PREUBSPARHL2432_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSPARHL2432_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start PARHL2432-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='FR'
where iatanum ='PREUBS' and recordkey like '%PARHL2432-%' and (origcountry is null or origcountry ='XX')


--- Update Air Reason Code -- 
update i
set reasoncode1 = substring(udefdata,(charindex('/',udefdata)-2),2)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like '%trerp%' 
--and ((isnull(reasoncode1,'A') not like 'A%') and (isnull(reasoncode1,'B') not like 'B%'))
and udefdata not like '%h[0-9]/%'

----- Update Text8 with Booker Name -----------------------Changed from Approver to booker per UBS
-- LOC/8/13/2013-----
update c
set text8= substring(udefdata,charindex('CD2',udefdata)+4,8)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and ((udefdata like '%cd2%') and (udefdata not like '%ace%'))
and text8 is null

------ Update Htl ReasonCode if not updated in DM Parsing --------- LOC 6/5/2012
update h
set htlreasoncode1 = udefdata
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udeftype = 'HTLREASONCD'
and isnull(htlreasoncode1,'') not in ('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')
and udefdata in('H1','H2','H3','H4','H5','H6','H7','H8','H9','X1','X2','X3')

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online....LOC/6/15/2012
--New mapping provided 4/16/2015 #6291385
update c
set text18 = SUBSTRING(UDEFDATA,11,2)
from dba.comrmks c,
dba.Udef u
where c.iatanum = 'preubs' and c.recordkey like '%PARHL2432-%' 
and c.IataNum=u.iatanum and c.RecordKey=u.recordkey and c.SeqNum=u.seqnum
and u.UdefData like 'DCICR#CD4%'
and text18 is null
and SUBSTRING(UDEFDATA,11,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')

--update c
--set text18 = 'N/A'
--from dba.comrmks c
--where iatanum = 'preubs' and recordkey like '%PARHL2432-%' 
--and text18 is null

-------- Update Remarks2 with GPN --- LOC/7/23/2013
Update i 
set remarks2 =  substring(udefdata,charindex('emp',udefdata)+4,charindex('#',udefdata)+2)
from dba.udef u, dba.invoicedetail i
where u.recordkey like '%PARHL2432-%' and udefdata like '%#emp%'--%acecrm-2cost%order%'
and i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and isnull(remarks2,'Unknown')= 'Unknown'


----- Remarks 5 w Cost Center if not done via etl parsing
update i
set remarks5= substring(udefdata,charindex('#COS',udefdata)+5,5)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and u.udefdata like ('%trecr%#COS%') 
and substring(udefdata,charindex('#COS',udefdata)+5,5) not like '%#%'
and substring(udefdata,charindex('#COS',udefdata)+5,5)<> Remarks5
and substring(udefdata,charindex('#COS',udefdata)+5,5)in (select rollup8 from dba.rollup40 where costructid = 'functional' )


-------- Update Text17 with TractID ------------------------------- LOC/8/14/2012
Update c 
set text17 = substring(udefdata,charindex('ord',udefdata)+4,charindex('#',udefdata))
from dba.udef u, dba.comrmks c
where u.recordkey like '%PARHL2432-%' and udefdata like '%#ord%'--%acecrm-2cost%order%'
and c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and isnull(text17,'N/A')= 'N/A'

-------- Update Text7 with Project Code ----------------------LOC/10/30/2012
Update c 
set text7 =  case when substring(udefdata,charindex('prj',udefdata)+4,charindex('#',udefdata)) not like '%#%'
then substring(udefdata,charindex('prj',udefdata)+4,charindex('#',udefdata))
when substring(udefdata,charindex('prj',udefdata)+4,charindex('#',udefdata)) like '%#%' then 
substring(udefdata,charindex('prj',udefdata)+4,charindex('#',udefdata)-1) end
from dba.udef u, dba.comrmks c
where u.recordkey like '%PARHL2432-%' and udefdata like '%#prj%'--'%acecrm%project%' and c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum and isnull(text7,'N/A')= 'N/A'  

-------- Update Trip Purpose ----- LOC/7/23/2013
Update i
set remarks1 = substring(udefdata,charindex('trr',udefdata)+4,charindex('#',udefdata)-4) 
from dba.udef u, dba.invoicedetail i
where u.recordkey like '%PARHL2432-%' and udefdata like '%#trr%'--'%acecrm%project%'
and i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and isnull(remarks1,'N/A')= 'N/A'  

-------- Update Text 6 with T-24 Flag from Udefdata -- LOC/3/19/2013
Update c 
set text6 =  substring(udefdata,24,3)
from dba.udef u, dba.comrmks c
where u.recordkey like '%PARHL2432-%' and udefdata like '%acecrm-tq3cd4:end-mngr:%' and c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation PARHL2432-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
update c
set text27 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where u.recordkey like '%PARHL2432-%' and udefdata like '%#ord%' and c.iatanum = 'preubs' and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and text27 is null

-------Update Text26 = HtlReasonCode String --------------------------- LOC 5/29/2012
update c
set text26 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like 'TRERP#RC1%' and text26 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like '%#trr%' and text23 is null

-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 =substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like '%#emp%' and text22 is null

-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like '%#cos%'  and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like '%trerp%'  and text25 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 5/29/2012
update c
set text29 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%PARHL2432-%' and udefdata like '%cd2%' and text29 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End PARHL2432-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
