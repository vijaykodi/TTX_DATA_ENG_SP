/****** Object:  StoredProcedure [dbo].[sp_PREUBSVP3G_Post_Import_Update]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PREUBSVP3G_Post_Import_Update]

AS
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start VP3G-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


UPDATE HTL
SET HTL.HTLREASONCODE1 = substring(UD.UDEFDATA,1,2)
--SELECT HTL.RECORDKEY,HTL.IATANUM,HTL.INVOICEDATE,HTL.HTLREASONCODE1
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY AND HTL.IATANUM = UD.IATANUM AND HTL.CLIENTCODE = UD.CLIENTCODE
and HTL.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'HOTEL REASON CODE' AND UD.RECORDKEY LIKE '%VP3G-%'

UPDATE CAR
SET CAR.CARREASONCODE1 = udefdata
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,3)
FROM DBA.UDEF UD, DBA.CAR CAR
WHERE CAR.RECORDKEY = UD.RECORDKEY AND CAR.IATANUM = UD.IATANUM AND CAR.CLIENTCODE = UD.CLIENTCODE
AND UD.UDEFTYPE = 'CAR REASON CODE' AND UD.RECORDKEY LIKE '%VP3G-%' AND UD.UDEFDATA IN ('C1','C5')
 
-- Updating carrcommamt to the total car rate from remarks
update c
set carcommamt = NULL
from dba.car c
where c.recordkey like '%VP3G-%' and carcommamt = '0'

update car
set carcommamt = udefdata
from dba.car car, dba.udef u
where car.recordkey = u.recordkey and car.seqnum = u.seqnum 
and car.recordkey like '%VP3G-%' and udeftype = 'cartotalrate'


-- Update records that have TRN in the PNR to have values of Amtrak
--Update transeg first ----
update t
set segmentcarriercode = '2V',segmentcarriername = 'AMTRAK',
minsegmentcarriercode = '2V', minsegmentcarriername = 'AMTRAK',
noxsegmentcarriercode = '2V', noxsegmentcarriername = 'AMTRAK'
from  dba.transeg t
where recordkey in (select recordkey from dba.invoicedetail i
where producttype = 'rail' and isnull(valcarriercode,'XX') <> '2v'
and i.iatanum = 'preubs' and totalamt = 0 and i.recordkey like '%VP3G%')

update i
set valcarriernum = '554', valcarriercode = '2V', vendorname = 'AMTRAK'
from dba.invoicedetail i
where producttype = 'rail'
and isnull(valcarriercode,'XX') <> '2v' and i.iatanum = 'preubs'  and totalamt = 0 and i.recordkey like '%VP3G%'

-- Updating Amtrak Totalamt to value in U27 field

update i
set totalamt = substring(udefdata,5,6)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%VP3G-%'
and valcarriercode  in('2V','7O') and udeftype = 'TRMK' and udefdata like 'U27%' 

update i
set reasoncode1 = udefdata
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype like 'Z G3 R%' and reasoncode1 is null

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ComRmks Updates Start VP3G-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text18 with Online Reason Code ------- LOC/10/2/2012
update c
set text18 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'Z G5 REMARKS' and text18 is null
and u.recordkey like '%VP3G-%' 
and udefdata in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')

-------- Update Text14 with Approver GPN ----------------LOC/10/2/2012
update c
set text14 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype = 'sort 8' and ((text14 is null) or (text14 like 'Not%'))

-------- Update Text8 with Booker GPN ----------------LOC/10/2/2012
update c
set text8 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype = 'sort 6' and ((text8 is null) or (text8 like 'Not%'))

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Booker GPn Update complete VP3G-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update Text17 with TractID --- LOC/10/2/2012
update c
set text17 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype= 'Z G1 REMARKS' and isnull(text17,'N/A') = 'N/A'

------- Update Remarks2 with GPN --- LOC/10/2/2012
update i
set remarks2 = udefdata
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype = 'SORT 2'and isnull(remarks2, 'Unknown') = 'Unknown'

------- Update Remarks1 with Trip Purpose --- LOC/10/2/2012
update i
set remarks1 = udefdata
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype = 'SORT 7'and remarks1 is null

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Trip Pur Complete VP3G-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Update Remarks5 with CostCenter --- LOC/10/2/2012
update i
set remarks5 = udefdata
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%VP3G-%' and udeftype = 'SORT 1' and isnull(remarks5,'VP3G') = 'VP3G'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation VP3G-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC/10/2/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata = 'Z*s6-%'  and text27 is null
and u.recordkey like '%VP3G-%' 

-------------Update Comrmks with Hotel Code String from Udef ------ LOC 5/15/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'HO-%' and text26 is null
and u.recordkey like '%VP3G-%' 

-------Update Text25 = Air Reason Code String --------------------------- LOC/10/2/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'G9-%' and text25 is null
and u.recordkey like '%VP3G-%' 

-------Update Text23 = Trip Purpose --------------------------- LOC/10/2/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 7' and text23 is null
and u.recordkey like '%VP3G-%' 

-------Update Text22 = GPN String --------------------------- LOC/10/2/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 2' and text22 is null
and u.recordkey like '%VP3G-%' 

-------Update Text24 = Cost Center String--------------------------- LOC/10/2/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 1' and text24 is null
and u.recordkey like '%VP3G-%' 

-------Update Text28 = Booker GPN String --------------------------- LOC 8/29/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'Sort 6' and text28 is null
and u.recordkey like '%VP3G-%' 

-------Update Text29 = Approver GPN String --------------------------- LOC/10/2/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 8' and text29 is null
and u.recordkey like '%VP3G-%' 

-------Update Text31 = Car Reason Code String--------------- LOC 5/31/2012
update c
set text31 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'CO-%' and text31 is null
and u.recordkey like '%VP3G-%' 

-------Update Text13 with Online Reason Code String------- LOC/10/2/2012
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'G5-%' and text13 is null
and u.recordkey like '%VP3G-%' 

-------Update the US 3 character Cost Center to have a leading 0 ------------------------------

update dba.invoicedetail
set remarks5 = right('0000'+remarks5,4)
where right('0000'+remarks5,4) in (select rollup8 from dba.rollup40 where costructid = 'functional')
and len (remarks5) = 3 and iatanum = 'preubs'
and recordkey like '%VP3G-%' 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End VP3G-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
