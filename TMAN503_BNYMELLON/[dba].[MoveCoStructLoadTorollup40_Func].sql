/****** Object:  StoredProcedure [dba].[MoveCoStructLoadTorollup40_Func]    Script Date: 7/14/2015 7:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dba].[MoveCoStructLoadTorollup40_Func]
as
Begin



/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[MoveCoStructLoadTorollup40_Func]
************************************************************************/
--R. Robinson modified added time to stepname
declare @TransStart DATETIME declare @ProcName varchar(50)
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/



--TRUNCATE TABLE DBA.rollup40_temp

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child
, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
 from dba.costructload t1
where parent = ''
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup1
and t2.costructid = 'Functional_tmp'
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION
end

BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9
, ROLLUP10, ROLLUPDESC10, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup10
and t2.rollup10 <> t2.rollup9
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO DBA.rollup40
select 'Functional_tmp', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9
, ROLLUP10, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.rollup40 t2
where t1.parent = t2.rollup11
and t2.rollup11 <> t2.rollup10
and t2.costructid = 'Functional_tmp'
order by 2
COMMIT TRANSACTION


-- Rename original corporate structure

DELETE DBA.rollup40
WHERE CoStructID = 'Functional_bck'

UPDATE DBA.rollup40
SET CoStructID = 'Functional_bck'
WHERE CoStructID = 'Functional'

update dba.ROLLUP40
set COSTRUCTID = 'Functional'
where COSTRUCTID = 'functional_tmp'


 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/
GO
