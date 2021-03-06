/****** Object:  StoredProcedure [dbo].[sp_FIS_HR_Insert]    Script Date: 7/14/2015 8:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_FIS_HR_Insert]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'FISHR'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='FISHirerchy SP Start% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
------------------------------------------------------------------------------------------------------------------

-------- Truncate rollup40 for new import from Hierarchy Temp ----------------------------------------------------
Truncate table dba.rollup40
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L1 = NULL , Mgr_EmpID_L1 = NULL where Mgr_Emp_Name_L1 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L2 = NULL , Mgr_EmpID_L2 = NULL where Mgr_Emp_Name_L2 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L3 = NULL , Mgr_EmpID_L3 = NULL where Mgr_Emp_Name_L3 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L4 = NULL , Mgr_EmpID_L4 = NULL where Mgr_Emp_Name_L4 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L5 = NULL , Mgr_EmpID_L5 = NULL where Mgr_Emp_Name_L5 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L6 = NULL , Mgr_EmpID_L6 = NULL where Mgr_Emp_Name_L6 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L7 = NULL , Mgr_EmpID_L7 = NULL where Mgr_Emp_Name_L7 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L8 = NULL , Mgr_EmpID_L8 = NULL where Mgr_Emp_Name_L8 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L9 = NULL , Mgr_EmpID_L9 = NULL where Mgr_Emp_Name_L9 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L10 = NULL , Mgr_EmpID_L10 = NULL where Mgr_Emp_Name_L10 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L11 = NULL , Mgr_EmpID_L11 = NULL where Mgr_Emp_Name_L11 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L12 = NULL , Mgr_EmpID_L12 = NULL where Mgr_Emp_Name_L12 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L13 = NULL , Mgr_EmpID_L13 = NULL where Mgr_Emp_Name_L13 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L14 = NULL , Mgr_EmpID_L14 = NULL where Mgr_Emp_Name_L14 = '' 
update dba.hierarchy_temp_EID set Mgr_Emp_Name_L15 = NULL , Mgr_EmpID_L15 = NULL where Mgr_Emp_Name_L15 = '' 

-------- Create the HR rollup table which includes the L rollups --------------------------
insert into dba.rollup40
select distinct 'HR',employeeid, substring(Fullname,1,30)+'-'+employeeid,'0','FISHR',substring(L3,1,40),L3,
substring(L4,1,40),L4,substring(L5,1,40),L5,substring(L6,1,40),L6,substring(L7,1,40), L7,substring(L8,1,40),L8
,substring(L9,1,40),L9,substring(L10,1,40),L10,Employee_Level,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL
from dba.hierarchy_TEMP_EID
where employeeid not in (select corporatestructure from dba.rollup40 where costructid = 'HR')
and mgr_emp_name_l2 not in ('','Martire, Frank')


-------- Create the Manager rollup table  -------------------------------------------------------------------------
insert into dba.rollup40
select distinct 'Manager',employeeid, substring(Fullname,1,30)+'-'+employeeid,'1','FISManager',Mgr_EmpID_L1
,Mgr_Emp_Name_L1,Mgr_EmpID_L2 ,Mgr_Emp_Name_L2, Mgr_EmpID_L3 ,Mgr_Emp_Name_L3, Mgr_EmpID_L4 ,Mgr_Emp_Name_L4 
,Mgr_EmpID_L5,Mgr_Emp_Name_l5, Mgr_EmpID_L6 ,Mgr_Emp_Name_L6, Mgr_EmpID_L7 ,Mgr_Emp_Name_L7, Mgr_EmpID_L8 ,Mgr_Emp_Name_L8 
,Mgr_EmpID_L9,Mgr_Emp_Name_L9, Mgr_EmpID_L10  ,Mgr_Emp_Name_L10, Mgr_EmpID_L11 ,Mgr_Emp_Name_L11, Mgr_EmpID_L12 ,Mgr_Emp_Name_L12
,Mgr_EmpID_L13,Mgr_Emp_Name_L13, Mgr_EmpID_L14 ,Mgr_Emp_Name_L14,Mgr_EmpID_L15  ,Mgr_Emp_Name_L15,NULL, NULL
,NULL, NULL ,NULL, NULL ,NULL, NULL ,NULL, NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from dba.hierarchy_TEMP_EID
where employeeid not in (select corporatestructure from dba.rollup40 where costructid = 'FISManager')
and mgr_emp_name_l2 not in ('','Martire, Frank')

update dba.rollup40 set rollup2 = 'Board of Directors' where rollupdesc2 = 'Board of Directors,'

-----------------------------------------------------------------------------------------------------------------
--------- Remove the values with a - in the value -------------------------
--update dba.rollup40
--set rollupdesc4 = replace(rollupdesc4,'-E0','') where rollupdesc4 like '%-E0'

--update dba.rollup40
--set rollupdesc4 = replace(rollupdesc4,'-E1','') where rollupdesc4 like '%-E1'

--update dba.rollup40
--set rollupdesc4 = replace(rollupdesc4,'-E2','') where rollupdesc4 like '%-E2'


-----------Update bottom rollup to employee--------------------------------
update dba.rollup40
set rollup3 = corporatestructure , rollupdesc3 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup3 is NULL and rollup2 <> 'unknown'

update dba.rollup40
set rollup4 = corporatestructure , rollupdesc4 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup4 is NULL and rollup2 <> 'unknown' and rollup3 is not NULL
and rollup3 <> corporatestructure

update dba.rollup40
set rollup5 = corporatestructure , rollupdesc5 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup5 is NULL and rollup2 <> 'unknown' and rollup4 is not NULL
and rollup4 <>corporatestructure

update dba.rollup40
set rollup6 = corporatestructure , rollupdesc6 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup6  is NULL and rollup2 <> 'unknown' and rollup5 is not NULL
and rollup5 <> corporatestructure

update dba.rollup40
set rollup7 = corporatestructure , rollupdesc7 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup7  is NULL and rollup2 <> 'unknown' and rollup6 is not NULL
and rollup6 <> corporatestructure

update dba.rollup40
set rollup8 = corporatestructure , rollupdesc8 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup8  is NULL and rollup2 <> 'unknown' and rollup7 is not NULL
and rollup7 <> corporatestructure

update dba.rollup40
set rollup9 = corporatestructure , rollupdesc9 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup9  is NULL and rollup2 <> 'unknown' and rollup8 is not NULL
and rollup8 <> corporatestructure

update dba.rollup40
set rollup10 = corporatestructure , rollupdesc10 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup10  is NULL and rollup2 <> 'unknown' and rollup9 is not NULL
 and rollup9 <> corporatestructure

update dba.rollup40
set rollup11 = corporatestructure , rollupdesc11 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup11  is NULL and rollup2 <> 'unknown' and rollup10 is not NULL
and rollup10 <> corporatestructure

update dba.rollup40
set rollup12 = corporatestructure , rollupdesc12 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup12  is NULL and rollup2 <> 'unknown' and rollup11 <>  NULL
and rollup11 <> corporatestructure

update dba.rollup40
set rollup13 = corporatestructure , rollupdesc13 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup13  is NULL and rollup2 <> 'unknown' and rollup12 is not NULL
 and rollup12 <> corporatestructure

update dba.rollup40
set rollup14 = corporatestructure , rollupdesc14 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup14  is NULL and rollup2 <> 'unknown' and rollup13 is not NULL
and rollup13 <> corporatestructure

update dba.rollup40
set rollup15 = corporatestructure , rollupdesc15 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup15  is NULL and rollup2 <> 'unknown' and rollup14 is not NULL
and rollup14 <> corporatestructure


-------- Forcing the Manager names to = the Employee Names -- The above updates for Last rollup do not match
------- for the managers where their name is not the same in the manager columns as it is for their own
------- employee name .. Lisa
update r2
set rollupdesc4 = r1.rollupdesc4 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup4 = r2.rollup4 and r1.corporatestructure = r1.rollup4 and r2.corporatestructure <> r2.rollup4
and r1.rollupdesc4 <> r2.rollupdesc4
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc5 = r1.rollupdesc5 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup5 = r2.rollup5 and r1.corporatestructure = r1.rollup5 and r2.corporatestructure <> r2.rollup5
and r1.rollupdesc5 <> r2.rollupdesc5
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc6 = r1.rollupdesc6 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup6 = r2.rollup6 and r1.corporatestructure = r1.rollup6 and r2.corporatestructure <> r2.rollup6
and r1.rollupdesc6 <> r2.rollupdesc6
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc7 = r1.rollupdesc7 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup7 = r2.rollup7 and r1.corporatestructure = r1.rollup7 and r2.corporatestructure <> r2.rollup7
and r1.rollupdesc7 <> r2.rollupdesc7
and r1.costructid = 'manager' and r2.costructid = 'manager'
update r2
set rollupdesc8 = r1.rollupdesc8 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup8 = r2.rollup8 and r1.corporatestructure = r1.rollup8 and r2.corporatestructure <> r2.rollup8
and r1.rollupdesc8 <> r2.rollupdesc8
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc9 = r1.rollupdesc9 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup9 = r2.rollup9 and r1.corporatestructure = r1.rollup9 and r2.corporatestructure <> r2.rollup9
and r1.rollupdesc9 <> r2.rollupdesc9
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc10 = r1.rollupdesc10 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup10 = r2.rollup10 and r1.corporatestructure = r1.rollup10 and r2.corporatestructure <> r2.rollup10
and r1.rollupdesc10 <> r2.rollupdesc10
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc11 = r1.rollupdesc11 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup11 = r2.rollup11 and r1.corporatestructure = r1.rollup11 and r2.corporatestructure <> r2.rollup11
and r1.rollupdesc11 <> r2.rollupdesc11
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc12 = r1.rollupdesc12 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup12 = r2.rollup12 and r1.corporatestructure = r1.rollup12 and r2.corporatestructure <> r2.rollup12
and r1.rollupdesc12 <> r2.rollupdesc12
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc13 = r1.rollupdesc13 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup13 = r2.rollup13 and r1.corporatestructure = r1.rollup13 and r2.corporatestructure <> r2.rollup13
and r1.rollupdesc13 <> r2.rollupdesc13
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc14 = r1.rollupdesc14 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup14 = r2.rollup14 and r1.corporatestructure = r1.rollup14 and r2.corporatestructure <> r2.rollup14
and r1.rollupdesc14 <> r2.rollupdesc14
and r1.costructid = 'manager' and r2.costructid = 'manager'

update r2
set rollupdesc15 = r1.rollupdesc15 
from dba.rollup40 r1, dba.rollup40 r2
where r1.rollup15 = r2.rollup15 and r1.corporatestructure = r1.rollup15 and r2.corporatestructure <> r2.rollup15
and r1.rollupdesc15 <> r2.rollupdesc15
and r1.costructid = 'manager' and r2.costructid = 'manager'
GO
