/****** Object:  StoredProcedure [dba].[MoveCoStructLoadToRollup40_Temp]    Script Date: 7/14/2015 8:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--Step 6:  Populate Rollup40_Temp from DBA.CostructLoad  
--******Need to modify this to go to all 25 levels of the structure to ensure we get all levels*******

/****** Object:  StoredProcedure [dba].[MoveCoStructLoadToRollup40_Temp]    Script Date: 01/07/2014 14:23:20 ******/

CREATE Procedure [dba].[MoveCoStructLoadToRollup40_Temp]
as
------------------------------------------------------------------------------
---- Adding Logging per Jim's request in SF 00047318
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,@enddate as datetime, @begindate as datetime

	SET @Iata = 'SANHR'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Start Stored Procedure',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------------------
SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child
, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
 from dba.costructload t1
where parent = ''
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent is blank',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup1
and t2.costructid = 'organizational_tmp'
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup1',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup2',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup3',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup4',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup5',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup6',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup7',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup8',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup9',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9
, ROLLUP10, ROLLUPDESC10, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup10
and t2.rollup10 <> t2.rollup9
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup10',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9
, ROLLUP10, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup11
and t2.rollup11 <> t2.rollup10
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup11',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9
, ROLLUP10, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11, ROLLUP12, ROLLUPDESC12, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup12
and t2.rollup12 <> t2.rollup11
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup12',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'Organizational_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9
, ROLLUP10, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11, ROLLUP12, ROLLUPDESC12, ROLLUP13, ROLLUPDESC13, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup13
and t2.rollup13 <> t2.rollup12
and t2.costructid = 'organizational_tmp'
order by 2
COMMIT TRANSACTION
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert Rollup40-parent=rollup13',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
begin tran
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Tran for Step 7',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Step 7:  Rename original corporate structure
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 7 Rename orig. corp.structure',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
DELETE DBA.Rollup40
WHERE CoStructID = 'Organizational_bck'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete Organizational_bck ',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE DBA.Rollup40
SET CoStructID = 'Organizational_bck'
WHERE CoStructID = 'Organizational'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update to Organizational_bck ',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE DBA.Rollup40
SET CoStructID = 'Organizational'
WHERE CoStructID = 'Organizational_tmp'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update to Organizational ',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

commit

--Step 8:  Create RU40XRef
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 8-Create RU40XRef',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




SET @TransStart = getdate()
begin tran
DELETE DBA.RU40XREF
WHERE CoStructId IN ('OrganizationalBck')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 8 Delete OrganizationalBck',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE DBA.RU40XREF
SET COSTRUCTID = 'OrganizationalBck'
WHERE CoStructId = 'Organizational'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 8 Update to OrganizationalBck',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO DBA.RU40XREF
select Costructid,CorporateStructure,CorporateStructure,Description,Description
from dba.rollup40
where costructid = 'Organizational'

union

select Costructid,CorporateStructure,Rollup14,Description,RollupDesc14
from dba.rollup40
where costructid = 'Organizational'  
and rollup14 <> rollup15

union

select Costructid,CorporateStructure,Rollup13,Description,RollupDesc13
from dba.rollup40
where costructid = 'Organizational'  
and rollup13 <> rollup14

union
 
select Costructid,CorporateStructure,Rollup12,Description,RollupDesc12
from dba.rollup40
where costructid = 'Organizational'  
and rollup12 <> rollup12

union
 
select Costructid,CorporateStructure,Rollup11,Description,RollupDesc11
from dba.rollup40
where costructid = 'Organizational'  
and rollup11 <> rollup12

union

select Costructid,CorporateStructure,Rollup10,Description,RollupDesc10
from dba.rollup40
where costructid = 'Organizational'  
and rollup10 <> rollup11

union

select Costructid,CorporateStructure,Rollup9,Description,RollupDesc9
from dba.rollup40
where costructid = 'Organizational'  
and rollup9 <> rollup10

union

select Costructid,CorporateStructure,Rollup8,Description,RollupDesc8
from dba.rollup40
where costructid = 'Organizational'  
and rollup8 <> rollup9

union

select Costructid,CorporateStructure,Rollup7,Description,RollupDesc7
from dba.rollup40
where costructid = 'Organizational'  
and rollup7 <> rollup8

union

select Costructid,CorporateStructure,Rollup6,Description,RollupDesc6
from dba.rollup40
where costructid = 'Organizational'  
and rollup6 <> rollup7

union

select Costructid,CorporateStructure,Rollup5,Description,RollupDesc5
from dba.rollup40
where costructid = 'Organizational'  
and rollup5 <> rollup6

union

select Costructid,CorporateStructure,Rollup4,Description,RollupDesc4
from dba.rollup40
where costructid = 'Organizational'  
and rollup4 <> rollup5

union

select Costructid,CorporateStructure,Rollup3,Description,RollupDesc3
from dba.rollup40
where costructid = 'Organizational'  
and rollup3 <> rollup4

union

select Costructid,CorporateStructure,Rollup2,Description,RollupDesc2
from dba.rollup40
where costructid = 'Organizational'  
and rollup2 <> rollup3

union

select Costructid,CorporateStructure,Rollup1,Description,RollupDesc1
from dba.rollup40
where costructid = 'Organizational'  
and rollup1 <> rollup2
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 8 INSERT INTO DBA.RU40XREF',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


commit


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End sp',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




GO
