/****** Object:  StoredProcedure [dba].[MoveCoStructLoadToRollup40]    Script Date: 7/14/2015 8:13:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dba].[MoveCoStructLoadToRollup40]
as
Begin
Begin tran
truncate table dba.rollup40_temp
insert into dba.rollup40_temp select * from dba.ROLLUP40 where COSTRUCTID = 'YUMHR'
delete from dba.ROLLUP40 where COSTRUCTID = 'YUMHR'
commit tran

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child
, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
 from dba.costructload t1
where parent = '' or parent is null
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup1
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7
order by 2
COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8,  ROLLUP9, ROLLUPDESC9, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'YUMHR', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8,  ROLLUP9, ROLLUPDESC9,  ROLLUP10, ROLLUPDESC10
,  t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, DBA.Rollup40 t2
where t1.parent = t2.rollup10
and t2.rollup10 <> t2.rollup9
order by 2
COMMIT TRANSACTION
end


GO
