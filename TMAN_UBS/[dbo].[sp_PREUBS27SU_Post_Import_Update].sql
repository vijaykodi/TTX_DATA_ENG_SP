/****** Object:  StoredProcedure [dbo].[sp_PREUBS27SU_Post_Import_Update]    Script Date: 7/14/2015 7:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PREUBS27SU_Post_Import_Update]

AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()
--=================================
--Added by rcr  07/13/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(50)
--==------------------------------------------------------------------------------------------------------------------------------

/************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Log Activity
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start 27SU-% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--Added by rcr  07/13/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-Stored Procedure Start 27SU-%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
UPDATE HTL
SET HTL.HTLREASONCODE1 = substring(UD.UDEFDATA,1,2)
--SELECT HTL.RECORDKEY,HTL.IATANUM,HTL.INVOICEDATE,HTL.HTLREASONCODE1
FROM DBA.UDEF UD, DBA.HOTEL HTL
WHERE HTL.RECORDKEY = UD.RECORDKEY AND HTL.IATANUM = UD.IATANUM AND HTL.CLIENTCODE = UD.CLIENTCODE
and HTL.IATANUM = 'PREUBS' AND UD.UDEFTYPE = 'HTLREASONCD' AND UD.RECORDKEY LIKE '%27SU-%'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') HTL.HTLREASONCODE1 = substring(UD.UDEFDATA,1,2)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
UPDATE CAR
SET CAR.CARREASONCODE1 = udefdata
--SELECT UD.*, SUBSTRING(UD.UDEFDATA,1,3)
FROM DBA.UDEF UD, DBA.CAR CAR
WHERE CAR.RECORDKEY = UD.RECORDKEY AND CAR.IATANUM = UD.IATANUM AND CAR.CLIENTCODE = UD.CLIENTCODE
AND UD.UDEFTYPE = 'CAR REASON CODE' AND UD.RECORDKEY LIKE '%27SU-%' AND UD.UDEFDATA IN ('C1','C5')
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') CAR.CARREASONCODE1 = udefdata'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-- Updating carrcommamt to the total car rate from remarks
update c
set carcommamt = NULL
from dba.car c where c.recordkey like '%27su-%' and carcommamt = '0'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Updating carrcommamt to the total car rate from remarks'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update car
set carcommamt = udefdata
from dba.car car, dba.udef u
where car.recordkey = u.recordkey and car.seqnum = u.seqnum 
and car.recordkey like '%27su-%' and udeftype = 'cartotalrate'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') carcommamt = udefdata'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-- Update records that have TRN in the PNR to have values of Amtrak
--Update transeg first ----
update t
set segmentcarriercode = '2V',segmentcarriername = 'AMTRAK',
minsegmentcarriercode = '2V', minsegmentcarriername = 'AMTRAK',
noxsegmentcarriercode = '2V', noxsegmentcarriername = 'AMTRAK'
from  dba.transeg t
where recordkey in (select recordkey from dba.invoicedetail i
where producttype = 'rail' and isnull(valcarriercode,'XX') <> '2v'
and i.iatanum = 'preubs' and totalamt = 0 and i.recordkey like '%27su%')
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update records that have TRN in the PNR to have values of Amtrak -- Update transeg first'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update i
set valcarriernum = '554', valcarriercode = '2V', vendorname = 'AMTRAK'
from dba.invoicedetail i
where producttype = 'rail'
and isnull(valcarriercode,'XX') <> '2v' and i.iatanum = 'preubs'  and totalamt = 0 and i.recordkey like '%27su%'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') valcarriernum = 554, valcarriercode = 2V, vendorname = AMTRAK'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-- Updating Amtrak Totalamt to value in U27 field

update i
set totalamt = substring(udefdata,5,6)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%27su-%'
and valcarriercode  in('2V','7O') and udeftype = 'TRMK' and udefdata like 'U27%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') totalamt = substring(udefdata,5,6)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update i
set reasoncode1 = substring(udefdata,4,2)
from dba.udef u, dba.invoicedetail i
where u.recordkey = i.recordkey and u.seqnum = i.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%27su-%' and udefdata like 'G9-%' and reasoncode1 is null

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='27SU- Air RC Update% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 27SU- Air RC Update% '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text18 with Online Reason Code ------- LOC 6/12/12
update c
set text18 = substring(udefdata,4,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'G5-%'  and text18 is null
and u.recordkey like '%27su-%' and substring(udefdata,4,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text18 with Online Reason Code'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Update Text14 with Approver GPN ----------------LOC/8/15/2012
update c
set text14 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs' and u.recordkey like '%27su-%' and udeftype = 'sort 8'
and ((text14 is null) or (text14 like 'Not%'))
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text14 with Approver GPN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Update Text8 with Booker GPN ----------------LOC/8/29/2012
update c
set text8 = udefdata
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%27su-%' and udeftype = 'sort 6' and ((text8 is null) or (text8 like 'Not%'))
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text8 with Booker GPN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Update Text6 with T-24 mapping --- LOC/4/19/2013
update c
set text6 = substring(udefdata,5,1)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%27su-%' and udefdata like 'U20-%' and text6 is null
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text6 with T-24 mapping'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Update Text9 with Refundable/NonRefundable with -------- 8/29/2013
-------- Case #21285 TBo----09/03/2013 
-------- updated filert for R,U,N as it was not looking for a substring and therefore not updating
-------- the data correctly.... LOC/9/25/2013
update c
set text9 = right(udefdata,1)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%27su-%' and udefdata like '%G4-%' and right(udefdata,1) in ('R','U','N')
and text9 is null

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation 27SU-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Begin Update to Comrmks for Validation 27SU-%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 5/25/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'G1-%' and text27 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text27 = TractID String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------------Update Comrmks with Hotel Code String from Udef ------ LOC 5/15/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and U.UDEFTYPE = 'HTLREASONCD' and text26 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Comrmks with Hotel Code String from Udef'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text25 = Air Reason Code String --------------------------- LOC 5/25/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'G9-%' and text25 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text25 = Air Reason Code String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text23 = Trip Purpose --------------------------- LOC 5/25/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 7' and text23 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text23 = Trip Purpose'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-----update Remarks2 with GPN if not parsed from ETL
update id
set Remarks2 = udefdata
from dba.invoicedetail id, dba.udef u,
dba.Employee e
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'SORT 2' and remarks2 IS NULL
and u.recordkey like '%27su-%'
and u.UdefData=e.gpn
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update Remarks2 with GPN if not parsed from ETL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-------Update Text22 = GPN String --------------------------- LOC 5/25/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 2' and text22 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text22 = GPN String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text24 = Cost Center String--------------------------- LOC 5/25/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 1' and text24 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text24 = Cost Center String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text28 = Booker GPN String --------------------------- LOC 8/29/2012
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'Sort 6' and text28 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text28 = Booker GPN String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text29 = Approver GPN String --------------------------- LOC 5/25/2012
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udeftype = 'SORT 8' and text29 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text29 = Approver GPN String '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text31 = Car Reason Code String--------------- LOC 5/31/2012
update c
set text31 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'CO-%' and text31 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text31 = Car Reason Code String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update Text13 with Online Reason Code String------- LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and udefdata like 'G5-%' and text13 is null
and u.recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text13 with Online Reason Code String'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------Update the US 3 character Cost Center to have a leading 0 ------------------------------

update dba.invoicedetail 
set remarks5 = right('0000'+remarks5,4)
where right('0000'+remarks5,4) in (select rollup8 from dba.rollup40 where costructid = 'functional')
and len (remarks5) = 3 and iatanum = 'preubs'
and recordkey like '%27su-%' 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update the US 3 character Cost Center to have a leading 0 '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update ih
set origcountry = 'KY'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.recordkey like '%27su-%' 
and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'KY') 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  origcountry = KY' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


-------- Update FareCompare2 and ReasonCode1 from mappings in Udef data -- LOC/4/27/2013
-------- Mapings are for each ticket number and 1 query per fare compare length as I could not get
-------- any other mapping to work ... LOC
------------------------------ Commented out 12/3/2013 ---------------------------------------------
-------- Commenting this out as with the new split ticket process this will be updated in the 
-------- Pre_ubs_main stored procedure once Split ticket is resolved we can removed this from the SP but leaving
-------- for now so we know what was done historically ----- LOC/12/3/2013

--update i
--set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,23,4)
--from dba.invoicedetail i, dba.udef u
--where i.recordkey = u.recordkey and i.seqnum = u.seqnum
--and udeftype = 'TK RMKS' and i.iatanum = 'preubs'
--and documentnumber = substring(udefdata,7,10) and substring(udefdata,23,4) not like '%/%'
--and i.recordkey like '%27su-%' 

--update i
--set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,24,5)
--from dba.invoicedetail i, dba.udef u
--where i.recordkey = u.recordkey and i.seqnum = u.seqnum
--and udeftype = 'TK RMKS' and i.iatanum = 'preubs'
--and documentnumber = substring(udefdata,7,10) and substring(udefdata,24,5) not like '%/%'
--and i.recordkey like '%27su-%' 

--update i
--set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,25,6)
--from dba.invoicedetail i, dba.udef u
--where i.recordkey = u.recordkey and i.seqnum = u.seqnum
--and udeftype = 'TK RMKS' and i.iatanum = 'preubs'
--and documentnumber = substring(udefdata,7,10) and substring(udefdata,25,6) not like '%/%'
--and i.recordkey like '%27su-%' 

--update i
--set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,26,7)
--from dba.invoicedetail i, dba.udef u
--where i.recordkey = u.recordkey and i.seqnum = u.seqnum
--and udeftype = 'TK RMKS' and i.iatanum = 'preubs'
--and documentnumber = substring(udefdata,7,10) and substring(udefdata,26,7) not like '%/%'
--and i.recordkey like '%27su-%' 

--update i
--set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,27,8)
--from dba.invoicedetail i, dba.udef u
--where i.recordkey = u.recordkey and i.seqnum = u.seqnum
--and udeftype = 'TK RMKS' and i.iatanum = 'preubs'
--and documentnumber = substring(udefdata,7,10) and substring(udefdata,27,8) not like '%/%'
--and i.recordkey like '%27su-%' 


--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update ih
set origcountry = 'CL'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' 
and ih.recordkey like '%27su-%' 
and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CL') 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  origcountry = CL' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update ih
set origcountry = 'CO'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' 
and ih.recordkey like '%27su-%'  and origcountry = 'US'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CO') 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  origcountry = CO' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update ih
set origcountry = 'PE'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%27su-%' 
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'PE') 


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure End 27SU-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Stored Procedure End 27SU-%' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
EXEC sp_PRE_UBS_MAIN_Mini 

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Added by rcr  07/10/2015
WAITFOR DELAY '00:00.30' 
SET @TransStart = Getdate() 
--
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
---
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  













GO
