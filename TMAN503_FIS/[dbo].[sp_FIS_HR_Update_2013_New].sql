/****** Object:  StoredProcedure [dbo].[sp_FIS_HR_Update_2013_New]    Script Date: 7/14/2015 8:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_FIS_HR_Update_2013_New]

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

-------- Create the HR rollup table which includes the L rollups --------------------------
insert into dba.rollup40
select distinct 'HR',employeeid, substring(Fullname,1,30)+'-'+employeeid,'0','FISHR',substring(L3,1,40),L3,
substring(L4,1,40),L4,substring(L5,1,40),L5,substring(L6,1,40),L6,substring(L7,1,40), L7,substring(L8,1,40),L8
,substring(L9,1,40),L9,substring(L10,1,40),L10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL
from dba.hierarchy_TEMP
where employeeid not in (select corporatestructure from dba.rollup40 where costructid = 'HR')

-------- Create the Backup rollup with includes L rollups , manager info and Operation Number --------
insert into dba.rollup40
select distinct 'Backup',employeeid, substring(Fullname,1,30)+'-'+employeeid,'0','FISBU',substring(L3,1,40),L3,
substring(L4,1,40),L4,substring(L5,1,40),L5,substring(L6,1,40),L6,substring(L7,1,40), L7,substring(L8,1,40),L8
,substring(L9,1,40),L9,substring(L10,1,40),L10,ManagerEmployeeID, [Manager Name],
Ora_Operation, Operation_Name,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL, NULL,NULL
from dba.hierarchy_TEMP
where employeeid not in (select corporatestructure from dba.rollup40 where costructid = 'Backup')

--Fullname, EmployeeID, EmailAlias, Department, JobTitle, ManagerEmployeeID, Manager Name, Ora_Operation, 
--Operation_Name, L3, L4, L5, L6, L7, l8, L9, l10

-------- Insert Manager costruct into Rollup40_Manager to be used in constructing the Manager Rollup
-------- Truncte dba.rollup40_Manager before inserting new file
Truncate table dba.rollup40_manager

-------- in the rollup40 table ---------------------------------------------------------------------
insert into dba.rollup40_manager
select 'Backup',corporatestructure, description, '1','FISManager',rollup10, rollupdesc10
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
from dba.rollup40
where costructid = 'Backup' 

-------- Update Rollup 2-15-------------------------
update rm
set rm.rollup2 = rh.rollup10, rm.rollupdesc2 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rm.corporatestructure = rh.corporatestructure and rh.costructid = 'Backup'

update rm
set rm.rollup3 = rh.rollup10, rm.rollupdesc3 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup2 = rh.corporatestructure and rm.rollup2 <> 'e1030217'

update rm
set rm.rollup4 = rh.rollup10, rm.rollupdesc4 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup3 = rh.corporatestructure and rm.rollup3 <> 'e1030217'

update rm
set rm.rollup5 = rh.rollup10, rm.rollupdesc5 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup4 = rh.corporatestructure and rm.rollup4 <> 'e1030217'

update rm
set rm.rollup6 = rh.rollup10, rm.rollupdesc6 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup5 = rh.corporatestructure and rm.rollup5 <> 'e1030217'

update rm
set rm.rollup7 = rh.rollup10, rm.rollupdesc7 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup6 = rh.corporatestructure and rm.rollup6 <> 'e1030217'

update rm
set rm.rollup8 = rh.rollup10, rm.rollupdesc8 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup7 = rh.corporatestructure and rm.rollup7 <> 'e1030217'

update rm
set rm.rollup9 = rh.rollup10, rm.rollupdesc9 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup8 = rh.corporatestructure and rm.rollup8 <> 'e1030217'

update rm
set rm.rollup10 = rh.rollup10, rm.rollupdesc10 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup9 = rh.corporatestructure and rm.rollup9 <> 'e1030217'

update rm
set rm.rollup11 = rh.rollup10, rm.rollupdesc11 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup10 = rh.corporatestructure and rm.rollup10 <> 'e1030217'

update rm
set rm.rollup12 = rh.rollup10, rm.rollupdesc12 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup11 = rh.corporatestructure and rm.rollup11 <> 'e1030217'

update rm
set rm.rollup13 = rh.rollup10, rm.rollupdesc13 = rh.rollupdesc10
from dba.rollup40_manager rm, dba.rollup40 rh
where rh.costructid = 'Backup' and rm.rollup12 = rh.corporatestructure and rm.rollup12 <> 'e1030217'


------------------Insert into production -------------------------------------------------------
insert into dba.rollup40
select 'Manager',corporatestructure, description, '1','FISManager',NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
from dba.rollup40
where costructid = 'Backup' 
and corporatestructure not in (select corporatestructure from dba.rollup40 where costructid = 'Manager')

---------- update rollup 2 --------------------------    
update dba.rollup40
set rollup2 =   
			Case when rm.rollup13 ='e1030217' and r.rollup2 is null then rm.rollup13   
			when rm.rollup12 ='e1030217' and r.rollup2 is null then rm.rollup12   
			when rm.rollup11 ='e1030217' and r.rollup2 is null then rm.rollup11   
			when rm.rollup10 ='e1030217' and r.rollup2 is null then rm.rollup10   
			when rm.rollup9 ='e1030217' and r.rollup2 is null then rm.rollup9   
			when rm.rollup8 ='e1030217' and r.rollup2 is null then rm.rollup8   
			when rm.rollup7 ='e1030217' and r.rollup2 is null then rm.rollup7   
			when rm.rollup6 ='e1030217' and r.rollup2 is null then rm.rollup6   
			when rm.rollup5 ='e1030217' and r.rollup2 is null then rm.rollup5   
			when rm.rollup4 ='e1030217' and r.rollup2 is null then rm.rollup4   
			when rm.rollup3 ='e1030217' and r.rollup2 is null then rm.rollup3   
			when rm.rollup2 ='e1030217' and r.rollup2 is null then rm.rollup2   end,
rollupdesc2 = case when rm.rollup13 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc13   
			when rm.rollup12 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc12   
			when rm.rollup11 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc11   
			when rm.rollup10 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc10   
			when rm.rollup9 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc9   
			when rm.rollup8 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc8   
			when rm.rollup7 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc7   
			when rm.rollup6 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc6   
			when rm.rollup5 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc5   
			when rm.rollup4 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc4   
			when rm.rollup3 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc3   
			when rm.rollup2 ='e1030217' and r.rollupdesc2 is null then rm.rollupdesc2   end

from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'Manager'
and rm.corporatestructure <> 'e1030217'

------------------ROLLUP2 CLEANUP-----------------------------------------------------------------------
------ Update to unknown where Manager's manager is Unknown ---------------------------------------
update dba.rollup40
set rollupdesc2 = 'Unknown'
where rollupdesc2 is null and corporatestructure <> 'e1030217' and costructid = 'manager'

update dba.rollup40
set rollup2 = 'Unknown'
where rollup2 is null and corporatestructure <> 'e1030217' and costructid = 'manager'

-------------------Rollup 3 ------------------------
update r
set rollup3 = case    when r.rollup3 is null and rm.rollup12 <> 'Unknown' and r.rollup2 = rm.rollup13 then rm.rollup12
					 when r.rollup3 is null and rm.rollup11 <> 'Unknown' and r.rollup2 = rm.rollup12 then rm.rollup11
					 when r.rollup3 is null and rm.rollup10 <> 'Unknown' and r.rollup2 = rm.rollup11 then rm.rollup10
					 when r.rollup3 is null and rm.rollup9 <> 'Unknown' and r.rollup2 = rm.rollup10 then rm.rollup9
					 when r.rollup3 is null and rm.rollup8 <> 'Unknown' and r.rollup2 = rm.rollup9 then rm.rollup8
					 when r.rollup3 is null and rm.rollup7 <> 'Unknown' and r.rollup2 = rm.rollup8 then rm.rollup7
					 when r.rollup3 is null and rm.rollup6 <> 'Unknown' and r.rollup2 = rm.rollup7 then rm.rollup6
					 when r.rollup3 is null and rm.rollup5 <> 'Unknown' and r.rollup2 = rm.rollup6 then rm.rollup5
					 when r.rollup3 is null and rm.rollup4 <> 'Unknown' and r.rollup2 = rm.rollup5 then rm.rollup4
					 when r.rollup3 is null and rm.rollup3 <> 'Unknown' and r.rollup2 = rm.rollup4 then rm.rollup3
					 when r.rollup3 is null and rm.rollup2 <> 'Unknown' and r.rollup2 = rm.rollup3 then rm.rollup2
				end,
rollupdesc3 = case 	  when r.rollupdesc3 is null and rm.rollupdesc12 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc13 then rm.rollupdesc12
					 when r.rollupdesc3 is null and rm.rollupdesc11 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc12 then rm.rollupdesc11
					 when r.rollupdesc3 is null and rm.rollupdesc10 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc11 then rm.rollupdesc10
					 when r.rollupdesc3 is null and rm.rollupdesc9 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc10 then rm.rollupdesc9
					 when r.rollupdesc3 is null and rm.rollupdesc8 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc3 is null and rm.rollupdesc7 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc3 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc3 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc3 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc3 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc3 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc2 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup3 = NULL, rollupdesc3 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc2 = 'Unknown') or (rollupdesc3 = rollupdesc2))
and costructid = 'manager'

--------------rollup 4---------------------------------
update r
set rollup4 = case   when r.rollup4 is null and rm.rollup11 <> 'Unknown' and r.rollup3 = rm.rollup12 then rm.rollup11
					 when r.rollup4 is null and rm.rollup10 <> 'Unknown' and r.rollup3 = rm.rollup11 then rm.rollup10
					 when r.rollup4 is null and rm.rollup9 <> 'Unknown' and r.rollup3 = rm.rollup10 then rm.rollup9
					 when r.rollup4 is null and rm.rollup8 <> 'Unknown' and r.rollup3 = rm.rollup9 then rm.rollup8
					 when r.rollup4 is null and rm.rollup7 <> 'Unknown' and r.rollup3 = rm.rollup8 then rm.rollup7
					 when r.rollup4 is null and rm.rollup6 <> 'Unknown' and r.rollup3 = rm.rollup7 then rm.rollup6
					 when r.rollup4 is null and rm.rollup5 <> 'Unknown' and r.rollup3 = rm.rollup6 then rm.rollup5
					 when r.rollup4 is null and rm.rollup4 <> 'Unknown' and r.rollup3 = rm.rollup5 then rm.rollup4
					 when r.rollup4 is null and rm.rollup3 <> 'Unknown' and r.rollup3 = rm.rollup4 then rm.rollup3
					 when r.rollup4 is null and rm.rollup2 <> 'Unknown' and r.rollup3 = rm.rollup3 then rm.rollup2
				end,
rollupdesc4 = case    when r.rollupdesc4 is null and rm.rollupdesc11 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc12 then rm.rollupdesc11
					 when r.rollupdesc4 is null and rm.rollupdesc10 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc11 then rm.rollupdesc10
					 when r.rollupdesc4 is null and rm.rollupdesc9 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc10 then rm.rollupdesc9
					 when r.rollupdesc4 is null and rm.rollupdesc8 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc4 is null and rm.rollupdesc7 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc4 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc4 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc4 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc4 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc4 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc3 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup4 = NULL, rollupdesc4 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc3 = 'Unknown') or (rollupdesc4 = rollupdesc3))
and costructid = 'manager'

--------------rollup 5---------------------------------
update r
set rollup5 = case   when r.rollup5 is null and rm.rollup10 <> 'Unknown' and r.rollup4 = rm.rollup11 then rm.rollup10
					 when r.rollup5 is null and rm.rollup9 <> 'Unknown' and r.rollup4 = rm.rollup10 then rm.rollup9
					 when r.rollup5 is null and rm.rollup8 <> 'Unknown' and r.rollup4 = rm.rollup9 then rm.rollup8
					 when r.rollup5 is null and rm.rollup7 <> 'Unknown' and r.rollup4 = rm.rollup8 then rm.rollup7
					 when r.rollup5 is null and rm.rollup6 <> 'Unknown' and r.rollup4 = rm.rollup7 then rm.rollup6
					 when r.rollup5 is null and rm.rollup5 <> 'Unknown' and r.rollup4 = rm.rollup6 then rm.rollup5
					 when r.rollup5 is null and rm.rollup4 <> 'Unknown' and r.rollup4 = rm.rollup5 then rm.rollup4
					 when r.rollup5 is null and rm.rollup3 <> 'Unknown' and r.rollup4 = rm.rollup4 then rm.rollup3
					 when r.rollup5 is null and rm.rollup2 <> 'Unknown' and r.rollup4 = rm.rollup3 then rm.rollup2
				end,
rollupdesc5 = case   when r.rollupdesc5 is null and rm.rollupdesc10 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc11 then rm.rollupdesc10
					 when r.rollupdesc5 is null and rm.rollupdesc9 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc10 then rm.rollupdesc9
					 when r.rollupdesc5 is null and rm.rollupdesc8 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc5 is null and rm.rollupdesc7 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc5 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc5 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc5 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc5 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc5 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc4 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup5 = NULL, rollupdesc5 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc4 = 'Unknown') or (rollupdesc5 = rollupdesc4))
and costructid = 'manager'

--------------rollup 6---------------------------------
update r
set rollup6 = case	  when r.rollup6 is null and rm.rollup9 <> 'Unknown' and r.rollup5 = rm.rollup10 then rm.rollup9
					 when r.rollup6 is null and rm.rollup8 <> 'Unknown' and r.rollup5 = rm.rollup9 then rm.rollup8
					 when r.rollup6 is null and rm.rollup7 <> 'Unknown' and r.rollup5 = rm.rollup8 then rm.rollup7
					 when r.rollup6 is null and rm.rollup6 <> 'Unknown' and r.rollup5 = rm.rollup7 then rm.rollup6
					 when r.rollup6 is null and rm.rollup5 <> 'Unknown' and r.rollup5 = rm.rollup6 then rm.rollup5
					 when r.rollup6 is null and rm.rollup4 <> 'Unknown' and r.rollup5 = rm.rollup5 then rm.rollup4
					 when r.rollup6 is null and rm.rollup3 <> 'Unknown' and r.rollup5 = rm.rollup4 then rm.rollup3
					 when r.rollup6 is null and rm.rollup2 <> 'Unknown' and r.rollup5 = rm.rollup3 then rm.rollup2
				end,
rollupdesc6 = case   when r.rollupdesc6 is null and rm.rollupdesc9 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc10 then rm.rollupdesc9
					 when r.rollupdesc6 is null and rm.rollupdesc8 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc6 is null and rm.rollupdesc7 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc6 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc6 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc6 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc6 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc6 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc5 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup6 = NULL, rollupdesc6 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc5 = 'Unknown') or (rollupdesc6 = rollupdesc5))
and costructid = 'manager'

--------------rollup 7---------------------------------
update r
set rollup7 = case	  when r.rollup7 is null and rm.rollup8 <> 'Unknown' and r.rollup6 = rm.rollup9 then rm.rollup8
					 when r.rollup7 is null and rm.rollup7 <> 'Unknown' and r.rollup6 = rm.rollup8 then rm.rollup7
					 when r.rollup7 is null and rm.rollup6 <> 'Unknown' and r.rollup6 = rm.rollup7 then rm.rollup6
					 when r.rollup7 is null and rm.rollup5 <> 'Unknown' and r.rollup6 = rm.rollup6 then rm.rollup5
					 when r.rollup7 is null and rm.rollup4 <> 'Unknown' and r.rollup6 = rm.rollup5 then rm.rollup4
					 when r.rollup7 is null and rm.rollup3 <> 'Unknown' and r.rollup6 = rm.rollup4 then rm.rollup3
					 when r.rollup7 is null and rm.rollup2 <> 'Unknown' and r.rollup6 = rm.rollup3 then rm.rollup2
				end,
rollupdesc7 = case   when r.rollupdesc7 is null and rm.rollupdesc8 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc7 is null and rm.rollupdesc7 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc7 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc7 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc7 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc7 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc7 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc6 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup7 = NULL, rollupdesc7 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc6 = 'Unknown') or (rollupdesc7 = rollupdesc6))
and costructid = 'manager'

--------------rollup 8---------------------------------
update r
set rollup8  = case  when r.rollup8 is null and rm.rollup7 <> 'Unknown' and r.rollup7 = rm.rollup8 then rm.rollup7
					 when r.rollup8 is null and rm.rollup6 <> 'Unknown' and r.rollup7 = rm.rollup7 then rm.rollup6
					 when r.rollup8 is null and rm.rollup5 <> 'Unknown' and r.rollup7 = rm.rollup6 then rm.rollup5
					 when r.rollup8 is null and rm.rollup4 <> 'Unknown' and r.rollup7 = rm.rollup5 then rm.rollup4
					 when r.rollup8 is null and rm.rollup3 <> 'Unknown' and r.rollup7 = rm.rollup4 then rm.rollup3
					 when r.rollup8 is null and rm.rollup2 <> 'Unknown' and r.rollup7 = rm.rollup3 then rm.rollup2
				end,
rollupdesc8 = case   when r.rollupdesc8 is null and rm.rollupdesc7 <> 'Unknown' and r.rollupdesc7 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc8 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc7 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc8 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc7 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc8 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc7 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc8 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc7 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc8 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc7 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup8 = NULL, rollupdesc8 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc7 = 'Unknown') or (rollupdesc8 = rollupdesc7))
and costructid = 'manager'

--------------rollup 9---------------------------------
update r
set rollup9 = case  when r.rollup9 is null and rm.rollup6 <> 'Unknown' and r.rollup8 = rm.rollup7 then rm.rollup6
					 when r.rollup9 is null and rm.rollup5 <> 'Unknown' and r.rollup8 = rm.rollup6 then rm.rollup5
					 when r.rollup9 is null and rm.rollup4 <> 'Unknown' and r.rollup8 = rm.rollup5 then rm.rollup4
					 when r.rollup9 is null and rm.rollup3 <> 'Unknown' and r.rollup8 = rm.rollup4 then rm.rollup3
					 when r.rollup9 is null and rm.rollup2 <> 'Unknown' and r.rollup8 = rm.rollup3 then rm.rollup2
				end,
rollupdesc9 = case   when r.rollupdesc9 is null and rm.rollupdesc6 <> 'Unknown' and r.rollupdesc8 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc9 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc8 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc9 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc8 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc9 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc8 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc9 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc8 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup9 = NULL, rollupdesc9 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc8 = 'Unknown') or (rollupdesc9 = rollupdesc8))
and costructid = 'manager'

--------------rollup 10---------------------------------
update r
set rollup10 = case when r.rollup10 is null and rm.rollup5 <> 'Unknown' and r.rollup9 = rm.rollup6 then rm.rollup5
					 when r.rollup10 is null and rm.rollup4 <> 'Unknown' and r.rollup9 = rm.rollup5 then rm.rollup4
					 when r.rollup10 is null and rm.rollup3 <> 'Unknown' and r.rollup9 = rm.rollup4 then rm.rollup3
					 when r.rollup10 is null and rm.rollup2 <> 'Unknown' and r.rollup9 = rm.rollup3 then rm.rollup2
				end,
rollupdesc10 = case  when r.rollupdesc10 is null and rm.rollupdesc5 <> 'Unknown' and r.rollupdesc9 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc10 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc9 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc10 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc9 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc10 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc9 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup10 = NULL, rollupdesc10 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc9 = 'Unknown') or (rollupdesc10 = rollupdesc9))
and costructid = 'manager'

--------------rollup 11---------------------------------
update r
set rollup11 = case  when r.rollup11 is null and rm.rollup4 <> 'Unknown' and r.rollup10 = rm.rollup5 then rm.rollup4
					 when r.rollup11 is null and rm.rollup3 <> 'Unknown' and r.rollup10 = rm.rollup4 then rm.rollup3
					 when r.rollup11 is null and rm.rollup2 <> 'Unknown' and r.rollup10 = rm.rollup3 then rm.rollup2
				end,
rollupdesc11 = case   when r.rollupdesc11 is null and rm.rollupdesc4 <> 'Unknown' and r.rollupdesc10 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc11 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc10 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc11 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc10 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup11 = NULL, rollupdesc11 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc10 = 'Unknown') or (rollupdesc11 = rollupdesc10))
and costructid = 'manager'

--------------rollup 12---------------------------------
update r
set rollup12 = case  when r.rollup12 is null and rm.rollup3 <> 'Unknown' and r.rollup11 = rm.rollup4 then rm.rollup3
					 when r.rollup12 is null and rm.rollup2 <> 'Unknown' and r.rollup11 = rm.rollup3 then rm.rollup2
				end,
rollupdesc12 = case  when r.rollupdesc12 is null and rm.rollupdesc3 <> 'Unknown' and r.rollupdesc11 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc12 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc11 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup12 = NULL, rollupdesc12 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc11 = 'Unknown') or (rollupdesc12 = rollupdesc11))
and costructid = 'manager'

--------------rollup 13---------------------------------
update r
set rollup13 = case   when r.rollup13 is null and rm.rollup2 <> 'Unknown' and r.rollup12 = rm.rollup3 then rm.rollup2
				end,
rollupdesc13 = case  when r.rollupdesc13 is null and rm.rollupdesc2 <> 'Unknown' and r.rollupdesc12 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and rm.corporatestructure <> 'e1030217' and r.rollup2 ='e1030217'

update dba.rollup40
set rollup13 = NULL, rollupdesc12 = NULL where isnull(rollup2,'Unknown') <> 'Unknown' and ((rollupdesc12 = 'Unknown') or (rollupdesc13 = rollupdesc12))
and costructid = 'manager'

-----------Update bottom rollup to employee--------------------------------
update dba.rollup40
set rollup3 = corporatestructure , rollupdesc3 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup3 is null and rollup2 <> 'unknown'

update dba.rollup40
set rollup4 = corporatestructure , rollupdesc4 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup4 is null and rollup2 <> 'unknown' and rollup3 <> corporatestructure

update dba.rollup40
set rollup5 = corporatestructure , rollupdesc5 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup5 is null and rollup2 <> 'unknown' and rollup4 <> corporatestructure

update dba.rollup40
set rollup6 = corporatestructure , rollupdesc6 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup6 is null and rollup2 <> 'unknown' and rollup5 <> corporatestructure

update dba.rollup40
set rollup7 = corporatestructure , rollupdesc7 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup7 is null and rollup2 <> 'unknown' and rollup6 <> corporatestructure

update dba.rollup40
set rollup8 = corporatestructure , rollupdesc8 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup8 is null and rollup2 <> 'unknown' and rollup7 <> corporatestructure

update dba.rollup40
set rollup9 = corporatestructure , rollupdesc9 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup9 is null and rollup2 <> 'unknown' and rollup8 <> corporatestructure

update dba.rollup40
set rollup10 = corporatestructure , rollupdesc10 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup10 is null and rollup2 <> 'unknown' and rollup9 <> corporatestructure

update dba.rollup40
set rollup11 = corporatestructure , rollupdesc11 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup11 is null and rollup2 <> 'unknown' and rollup10 <> corporatestructure

update dba.rollup40
set rollup12 = corporatestructure , rollupdesc12 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup12 is null and rollup2 <> 'unknown' and rollup11 <> corporatestructure

update dba.rollup40
set rollup13 = corporatestructure , rollupdesc13 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup13 is null and rollup2 <> 'unknown' and rollup12 <> corporatestructure

update dba.rollup40
set rollup14 = corporatestructure , rollupdesc14 = substring(description,1,charindex('-',description)-1)
where costructid = 'manager' and rollup14 is null and rollup2 <> 'unknown' and rollup13 <> corporatestructure


GO
