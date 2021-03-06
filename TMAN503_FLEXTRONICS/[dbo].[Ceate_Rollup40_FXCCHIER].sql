/****** Object:  StoredProcedure [dbo].[Ceate_Rollup40_FXCCHIER]    Script Date: 7/14/2015 8:06:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Ceate_Rollup40_FXCCHIER]
as begin
-- add new employees
insert dba.Employee
select *
from dba.Employee_temp t
where t.EmployeeID1 not in (select distinct EmployeeID1 from dba.Employee)
--update existing employees
update e
set 
e.LastName = t.LastName, 
e.FirstName = t.FirstName, 
e.MiddleName = t.MiddleName, 
e.EmpEmail = t.EmpEmail, 
e.EmployeeType = t.EmployeeType, 
e.EmployeeStatus = t.EmployeeStatus, 
e.EmployeeID2 = t.EmployeeID2, 
e.BusinessAddress = t.BusinessAddress, 
e.BusinessCity = t.BusinessCity, 
e.BusinessStateCd = t.BusinessStateCd, 
e.BusinessCountry = t.BusinessCountry, 
e.BusinessRegion = t.BusinessRegion, 
e.SupervisorID = t. SupervisorID, 
e.SupervisorFirstName = t.SupervisorFirstName, 
e.SupervisorLastName = t.SupervisorLastName, 
e.SupervisorEmail = t.SupervisorEmail, 
e.CostCenter = t.CostCenter, 
e.DeptNumber = t.DeptNumber, 
e.DivisionNumber= t.DivisionNumber, 
e.OrganizationUnit = t.OrganizationUnit, 
e.Company=t.Company, 
e.AdditionalInfo1=t.AdditionalInfo1, 
e.AdditionalInfo2=t.AdditionalInfo2, 
e.AdditionalInfo3=t.AdditionalInfo3, 
e.AdditionalInfo4=t.AdditionalInfo4, 
e.AdditionalInfo5=t.AdditionalInfo5, 
e.AdditionalInfo6=t.AdditionalInfo6, 
e.AdditionalInfo7 = t.AdditionalInfo7, 
e.AdditionalInfo8 = t.AdditionalInfo8, 
e.AdditionalInfo9 = t.AdditionalInfo9, 
e.AdditionalInfo10= t.AdditionalInfo10, 
e.BeginDate =t.BeginDate , 
e.EndDate = t.EndDate, 
e.ImportDate= t.ImportDate
from dba.Employee_temp t, dba.Employee e
where e.EmployeeID1= t.EmployeeID1

--update status = 0 for empl that do not exist in temp
--update e 
--set e.EmployeeStatus = 0
--from dba.Employee e
--where e.EmployeeID1 not in (select distinct EmployeeID1 from dba.Employee_temp)
update  E
set   e.EmployeeStatus =   0
from   dba.Employee e left  outer   join     dba.Employee_temp t
on  e.EmployeeID1 =  t.EmployeeID1
where  t.EmployeeID1 is  null


--creating rollup40---
truncate table dba.costructload

insert dba.costructload
select EmployeeID1,(Lastname+'/'+Firstname),supervisorID 
from dba.employee

update dba.costructload
set parent = null
where child = parent

truncate table dba.rollup40_temp

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child
, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION, t1.Child, DESCRIPTION
 from dba.costructload t1
where parent is null
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup1
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
order by 2
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
order by 2
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
order by 2
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
order by 2
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
order by 2

INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
order by 2
INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.DESCRIPTION, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7

INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, rollup9, rollupdesc9, t1.Child
, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8

INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, rollup9, rollupdesc9, rollup10
, ROLLUPDESC10, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup10
and t2.rollup10 <> t2.rollup9

INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, rollup9, rollupdesc9, rollup10
, ROLLUPDESC10, rollup11, rollupdesc11, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup11
and t2.rollup11 <> t2.rollup10

INSERT INTO DBA.Rollup40_Temp
select 'HRHIERARCHY', t1.Child, t1.DESCRIPTION, ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, rollup9, rollupdesc9, rollup10
, ROLLUPDESC10, rollup11, rollupdesc11, rollup12, rollupdesc12, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION, t1.Child, t1.DESCRIPTION
 from dba.costructload t1, dba.rollup40_temp t2
where t1.parent = t2.rollup12
and t2.rollup12 <> t2.rollup11
COMMIT TRANSACTION


delete dba.ROLLUP40
where COSTRUCTID in( 'HRHIERARCHY')

insert dba.ROLLUP40
select *
from dba.rollup40_temp

INSERT INTO dba.rollup40 values('HRHIERARCHY','Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data',	'Not Provided',	'Not Provided In Data')

end





GO
