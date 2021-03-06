/****** Object:  StoredProcedure [dbo].[sp_PREUBSV180_Post_Import_Update]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSV180_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start V180--',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

update dba.invoiceheader
set origcountry ='CA'
where iatanum ='PREUBS'
and recordkey like '%V180-%' and (origcountry is null or origcountry ='XX')

-------- Update Remarks5 from Udef ---- LOC/8/15/2013
update i
set remarks5 = substring(udefdata,6,8)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%V180-%' and udefdata like 'U*21%'

------ Update to UBS Air Reason Codes -----------------------------------
update i
set reasoncode1 = case when substring(udefdata,1,2) in ('A1','A2','M1','L0','M2','O4','O5') THEN 'A1'
					   when substring(udefdata,1,2) = 'J1' then 'A4'
					   when substring(udefdata,1,2) = 'C2' then 'A5'
					   when substring(udefdata,1,2) in ('J2','J1') then 'B1'
					   when substring(udefdata,1,2) = 'D8' then 'B2'
					   when substring(udefdata,1,2) in('D1','D3','D4') then 'B3'
					   when substring(udefdata,1,2) = 'D6' then 'B5'
					   when substring(udefdata,1,2) in ('D2','D5') then 'B7'
					   end
from dba.invoicedetail i, dba.udef u
where u.recordkey like '%V180-%' and i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum and udeftype like '5.S*%'

---- Update to UBS Hotel Reason Codes -------------------------------------
Update h
set htlreasoncode1 = case when substring(udefdata,6,4) = '1000' then 'H1'
						  when substring(udefdata,6,4) in ('2001','2002','2003','2005') then 'H3'
						  when substring(udefdata,6,4) in ('2008','2010') then 'H5'
						  when substring(udefdata,6,4) = '4000' then 'H7'
						  when substring(udefdata,6,4) = '2009' then 'H8'
						  when substring(udefdata,6,4) in ('2004','2006') then 'X1'
						  when substring(udefdata,6,4) = '2007' then 'X7'
						  						  end
from dba.hotel h, dba.udef u
where u.recordkey like '%V180-%' and h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum and u.udefdata like 'U*32-%'

-------Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
--update c
--set text18 = 'N/A'
--from dba.comrmks c
--where iatanum = 'preubs' and substring(recordkey,15,charindex('-',recordkey)-15) = 'V180'
--and text18 is null

---- Update Online booking system ------ LOC 6/21/2012
update i
set onlinebookingsystem = 'Y'
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%V180-%' and substring(udefdata,1,6) = 'U*16-C' and onlinebookingsystem is NULL

--- Update Online Reason Code ---- LOC 6/21/2012
update c
set text18 = case when substring (udefdata,8,2) = 'AP' then 'YA'
				when substring(udefdata,8,2) in ('CT','EX') then 'NO'
				when substring(udefdata,8,2) = 'NE' then 'YN'
				when substring(udefdata,8,2) = 'NI' then 'YS'
				when substring(udefdata,8,2) = 'TD' then 'YH'
				when substring(udefdata,8,2) = 'NT' then 'YX'
				when substring(udefdata,8,1) = 'C' then 'YO'
				end
				from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udefdata like 'U*16-%' and text18 is NULL 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation V180-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 5/31/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udefdata like 'U*18-%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 5/31/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udeftype like 'U*9' and text23 is null

-------Update Text24 = Cost Center String ------------------- LOC 5/31/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udefdata like 'Z*S1%' --'U*21%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------- LOC 5/31/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udeftype = '5.S*' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------- LOC 5/31/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udefdata like 'U*32-%' and text26 is null

-------Update Text13 = Online Reason Code String --------------- LOC 5/31/2012
update c
set text12 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%V180-%' and udefdata like 'U*16-%' and text12 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End V180--',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
