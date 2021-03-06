/****** Object:  StoredProcedure [dba].[LoadRollup40]    Script Date: 7/14/2015 8:17:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure dba.LoadRollup40
as 
begin

BEGIN TRANSACTION
update dba.costructload
set child =  right('000000' + convert(varchar, child, 6), 6)


update dba.costructload
set parent =  right('000000' + convert(varchar, parent, 6), 6)
where parent<>''

COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
, t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child
, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
, t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
, t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
 from dba.costructload t1
where parent = ''
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup1
and t2.COSTRUCTID = 'MANAGERIAL_new'
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
insert into dba.rollup40
values ('MANAGERIAL_new','Not Provided','Not Provided','009571','Gavrielov, Moshe','Not Provided', 'Not Provided', NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL)
COMMIT TRANSACTION




begin tran
delete dba.ROLLUP40
where COSTRUCTID = 'MANAGERIAL'
commit

begin tran
update dba.ROLLUP40
set COSTRUCTID = 'MANAGERIAL'
where COSTRUCTID = 'MANAGERIAL_new'
commit



end

GO
