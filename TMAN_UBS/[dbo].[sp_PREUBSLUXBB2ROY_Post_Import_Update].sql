/****** Object:  StoredProcedure [dbo].[sp_PREUBSLUXBB2ROY_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREUBSLUXBB2ROY_Post_Import_Update]
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start LUXBB2ROY-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='LU'
where iatanum ='PREUBS' and recordkey like '%LUXBB2ROY-%' and (origcountry is null or origcountry ='XX')

-------Update Remarks1 = Trip Purpose to the New format as of 2/18/2013 
update i
set Remarks1 = substring(udefdata,charindex('#trr',udefdata)+5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#trr%') and Remarks1 is null

---- Update GPN with new format ----- LOC/2/19/2013
update i
set remarks2 = substring(udefdata,11,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum and i.iatanum = 'preubs'
and i.recordkey like '%LUXBB2ROY-%'
and udefdata like 'TRECR#EMP=%' and isnull(remarks2,'Unknown') = 'Unknown'
and substring(udefdata,11,8) in (select corporatestructure from TTXPASQL01.tman_ubs.dba.rollup40 
	where costructid = 'Functional')

-- Update Lux Cost Center
------ New format as of 2/18/2013 -- Leaving in old to handle old PNR's or PNR's without the new code
update i
set remarks5= substring(udefdata,charindex('#COS',udefdata)+5,5)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#COS%') and remarks5 is null
and substring(udefdata,charindex('#COS',udefdata)+5,5) not like '%#%'

update i
set remarks5=substring(udefdata,charindex('#COS',udefdata)+5,4)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#COS%') and remarks5 is null

------ Updates to the Cost Center prior to 2/20/2013 --- LOC
update i
set remarks5 = substring(udefdata,20,charindex('//',udefdata,8)) 
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('acecrf%') and remarks5 is null

update dba.invoicedetail 
set remarks5 = NULL
where remarks5 not like '%/%//%'
and iatanum = 'preubs'
and recordkey like '%LUXBB2ROY%'


update dba.invoicedetail
set remarks5=substring(remarks5,charindex('/',remarks5,4),charindex('//',remarks5)-3)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs' and u.recordkey like '%LUXBB2ROY%'
and udefdata like ('acecrf%') and remarks5 like '%/%'

update dba.invoicedetail
set  remarks5= substring(remarks5,2,5)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs' and u.recordkey like '%LUXBB2ROY%'
and udefdata like ('acecrf%') and remarks5 like '%/%'


SET @TransStart = getdate() 
 ------ Update ID.reasoncode1 from udefdata after ETL parsing done from udefdata like 'ACESV1%'----kp 9/2/2014-----------------------------
update i
set reasoncode1=u.udefdata 
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and UdefType='AIRREASONCD'
and i.ReasonCode1 is null
 EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update to ReasonCodes LUXBB2ROY-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text8 = Booker GPN with the new format --TBo  02/21/2013
update c
set text8 = substring(udefdata,charindex('#cd2',udefdata)+5,8)
from dba.udef u, dba.comrmks c
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#cd2%') and text8 is null

-------- Update Text7 with Project code - 2 seperate processes due to I can't make it work in one -- LOC/10/30/2012
update c
set text7 = substring(udefdata,9,charindex('//',udefdata)-3)
from dba.udef u, dba.comrmks c
where c.recordkey like '%LUXBB2ROY-%'
and udefdata like '%acecrf/%'
and c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and substring(udefdata,13,1) = '/'

update c
set text7 =substring(udefdata,9,charindex('//',udefdata)-2)
from dba.udef u, dba.comrmks c
where c.recordkey like '%LUXBB2ROY-%'
and udefdata like '%acecrf/%'
and c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and substring(udefdata,13,1) <> '/'

------- Update Text14 with Approver Name ----Need UBS to verify this is correct LOC 5/7/2012 ------
 ---- Verified by Ryan to use APPNM -- LOC 5/10/2012 ----------------------------------------------
update c
set text14 = substring(udefdata,charindex('appnm',udefdata)+6,8)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY-%'
and udefdata like '%acecrm%appnm%'
and text14 is null

-------Update Text17 = TractID with the new format --TBo  02/21/2013
update c
set text17 = substring(udefdata,charindex('#ord',udefdata)+5,9)
from dba.udef u, dba.comrmks c
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#ord%') and text17 is null
and substring(udefdata,charindex('#ord',udefdata)+5,9) not like '%#%'

update c
set text17 = substring(udefdata,charindex('#ord',udefdata)+5,8)
from dba.udef u, dba.comrmks c
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#ord%') and text17 is null
and substring(udefdata,charindex('#ord',udefdata)+5,8) not like '%#%'

update c
set text17 = substring(udefdata,charindex('#ord',udefdata)+5,7)
from dba.udef u, dba.comrmks c
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#ord%') and text17 is null
and substring(udefdata,charindex('#ord',udefdata)+5,7) not like '%#%'

update c
set text17 = substring(udefdata,charindex('#ord',udefdata)+5,6)
from dba.udef u, dba.comrmks c
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%' and u.udefdata like ('%trecr%#ord%') and text17 is null


-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
--Coding added for text 18 4/16/2015 #6291385
update c
set text18 = SUBSTRING(UDEFDATA,11,2)
from dba.comrmks c,
dba.Udef u
where c.iatanum = 'preubs' and c.recordkey like '%LUXBB2ROY%' 
and c.IataNum=u.iatanum and c.RecordKey=u.recordkey and c.SeqNum=u.seqnum
and u.UdefData like 'DCICR#CD4-%'
and text18 is null
and SUBSTRING(UDEFDATA,11,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')

--update c
--set text18 = 'N/A'
--from dba.comrmks c
--where iatanum = 'preubs'
--and recordkey like '%LUXBB2ROY%'
--and text18 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation LUXBB2ROY-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text22 = GPN String with the new format --TBo  02/21/2013
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY%'  and Text22 is null

-------Leaving in old to handle old PNR's or PNR's without the new code
-------Update Text22 = GPN String --------------------------- LOC 5/29/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like 'RM*ACECRM/TQ3D2-%'
and text22 is null


-------Update Text23 = Trip Purpose String with the new format --TBo  02/21/2013
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY%'  and Text23 is null

-------Leaving in old to handle old PNR's or PNR's without the new code
-------Update Text23 = Trip Purpose String --------------------------- LOC 5/29/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like 'TRREA%' and text23 is null

-------Update Text24 = Cost Center String with the new format --TBo  02/21/2013
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%'  and text24 is null
and udefdata like ('%trecr%#COS%')

-------Leaving in old to handle old PNR's or PNR's without the new code
-------Update Text24 = Cost Center String --------------------------- LOC 5/29/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like '%ACECRF//%'
and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like 'ACESV1/%'
and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 5/29/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like '%ACEHV2/%'
and text26 is null

-------Update Text27 = TractID String with the new format --TBo  02/21/2013
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%'  and text27 is null

-------Leaving in old to handle old PNR's or PNR's without the new code
-------Update Text27 = TractID String --------------------------- LOC 5/29/2012
-- Not sure this is correct .. Did not have noted on the maping doc-------
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like '%ACECRF//%'
and text27 is null

-------Update Text28 = Booker GPN String with the new format --TBo  02/21/2013
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%'  and text28 is null
-------Update Text29 = Approver GPN String with the new format --TBo  02/21/2013
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and udeftype = 'rm other' and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY%'  and text29 is null

-------Leaving in old to handle old PNR's or PNR's without the new code
-------Update Text29 = Approver GPN String --------------------------- LOC 5/29/2012
update c
set text29 = substring(udefdata,1,150)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and c.recordkey like '%LUXBB2ROY-%'
and udefdata like '%acecrm%appnm%'
and text29 is null

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47=substring(udefdata,charindex('rc1=',udefdata)+4,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%LUXBB2ROY-%' and udefdata like 'tmprp%' --and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End LUXBB2ROY-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
