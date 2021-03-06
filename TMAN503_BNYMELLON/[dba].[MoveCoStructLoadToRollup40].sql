/****** Object:  StoredProcedure [dba].[MoveCoStructLoadToRollup40]    Script Date: 7/14/2015 7:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE
Procedure [dba].[MoveCoStructLoadToRollup40]
as
Begin

/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[MoveCoStructLoadToRollup40]
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




BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child
, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
 from dba.costructload t1
where parent is null
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select distinct 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup1
and t2.costructid = 'MANAGERIAL'
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, ROLLUP10
, ROLLUPDESC10, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup10
and t2.rollup10 <> t2.rollup9
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, ROLLUP10
, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup11
and t2.rollup11 <> t2.rollup10
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, ROLLUP10
, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11,ROLLUP12, ROLLUPDESC12,  t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup12
and t2.rollup12 <> t2.rollup11
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, ROLLUP10
, ROLLUPDESC10, ROLLUP11, ROLLUPDESC11,ROLLUP12, ROLLUPDESC12,  ROLLUP13, ROLLUPDESC13, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup13
and t2.rollup13 <> t2.rollup12
and t2.costructid = 'MANAGERIAL'
order by 2
COMMIT TRANSACTION
end

------ Insert 000000000 as the Uknown value as it is set in the TMC Stored Procedure ----------------------------
-- this is already inserted from costructload
--insert into dba.rollup40
--values ('MANAGERIAL','000000000','UNKNOWN','000259687','Hassell\Gerald','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN','000000000','UNKNOWN')


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
