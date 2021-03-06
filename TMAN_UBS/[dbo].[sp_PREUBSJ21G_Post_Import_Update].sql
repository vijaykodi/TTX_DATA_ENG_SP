/****** Object:  StoredProcedure [dbo].[sp_PREUBSJ21G_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREUBSJ21G_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start J21G-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='BS' where iatanum ='PREUBS'
and recordkey like '%J21G-%' and (origcountry is null or origcountry <>'BS')--Update by LOC 3/7/2012


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End J21G- ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

UPDATE HTL
SET HTL.HTLREASONCODE1 = UD.UDEFDATA
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,5)
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY AND HTL.IATANUM = UD.IATANUM AND HTL.CLIENTCODE = UD.CLIENTCODE
and htl.seqnum = ud.seqnum and ud.udefdata not like 'z*%' and htl.htlreasoncode1 is null
and HTL.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'HOTEL REASON CODE' AND UD.RECORDKEY LIKE '%J21G-%'

UPDATE CAR
SET CAR.CARREASONCODE1 = UD.UDEFDATA
--SELECT UD.*
FROM DBA.UDEF UD, DBA.CAR CAR 
WHERE CAR.RECORDKEY = UD.RECORDKEY AND CAR.IATANUM = UD.IATANUM AND CAR.CLIENTCODE = UD.CLIENTCODE
and CAR.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'CAR REASON CODE' AND UD.RECORDKEY LIKE '%J21G-%'
and ud.udefdata like 'c%' AND UD.INVOICEDATE >='12/15/2011' and car.seqnum = ud.seqnum
and ud.udefdata not like 'z*%' and car.carreasoncode1 is null


-- Updating carrcommamt to the total car rate from remarks
update c
set carcommamt = NULL
from dba.car c
where c.recordkey like '%J21G-%' and carcommamt = '0'

update car
set carcommamt = udefdata
from dba.car car, dba.udef u
where car.recordkey = u.recordkey and car.seqnum = u.seqnum
and car.recordkey like '%J21G-%' and udeftype = 'cartotalrate'

-- Updating Amtrak Totalamt to value in U27 field
update i
set totalamt = substring(udefdata,7,6)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%J21G-%'
and valcarriercode  in('2V','7O') and udeftype = 'Z UDID' and udefdata like 'Z*U27%'

-- Update Text 18 with Online Reason Code ------------------ LOC 6/12/12
update c
set text18 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'Z G5 REMARKS' and text18 is null
and u.recordkey like '%J21G-%' and udefdata in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')

-------- Update Text8 with Booker GPN ----------------LOC/8/29/2012
update c
set text8 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs' and udeftype = 'SORT 6'
and u.recordkey like '%J21G-%' and ((text8 is null) or (text8 like 'Not%'))

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation J21G-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- LOC 6/1/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'SORT 2' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- LOC 6/1/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'SORT 7' and text23 is null

-------Update Text24 = Cost Center String --------------------------- LOC 6/1/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'SORT 1' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'Z G9 REMARKS' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------- LOC 6/1/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'HOTRSNCODE' and text26 is null

-------Update Text27 = TractID String --------------------------- LOC 6/1/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'Z G1 REMARKS' and text27 is null

-------Update Text29 = Approver GPN String --------------------------- LOC 6/1/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'Sort 8' and text29 is null

-- Update Text 13 with Online Reason Code  String ------------------ LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udeftype = 'Z G5 REMARKS' and text13 is null

------ Update Text 28 with Booker GPN String ------------------ LOC 8/29/12
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%J21G-%' and udefdata like 'Z*S6%' and text28 is null



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End J21G- ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
