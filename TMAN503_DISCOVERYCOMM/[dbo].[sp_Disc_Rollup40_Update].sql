/****** Object:  StoredProcedure [dbo].[sp_Disc_Rollup40_Update]    Script Date: 7/14/2015 8:01:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Disc_Rollup40_Update]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'DISCHR'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null     SET @ENDIssueDate = Null 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Discovery HR Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

-------- Pad all EmployeeID to 8 characters with leading 0 ---- LOC/11/8/2013
update dba.hierarchy_temp
set persno = right('00000000'+persno,8)
where len(persno) <> 8

update dba.hierarchy_temp
set supervisorPersNo = right('00000000'+supervisorPersNo,8)
where len(supervisorPersNo) <> 8

update dba.hierarchy_temp
set divisionhead = right('00000000'+divisionhead,8)
where len(divisionhead) <> 8
----------------------------------------------------------------------------------

insert into dba.rollup40
select  distinct 'Group',persno, lastname + ',' + firstname,
 1,'Group Selection',[Group],[Group], NULL ,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	from dba.hierarchy_temp
	where [Group] is not null and persno not in
		(select corporatestructure from dba.rollup40 where costructid = 'Group')
	
	
Insert into dba.rollup40 
select distinct 'Division', persno, lastname + ',' + firstname,
2,'Division Selection',DivisionTitle, DivisionTitle ,NULL ,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	from dba.hierarchy_temp where divisiontitle is not null and persno not in
		(select corporatestructure from dba.rollup40 where costructid = 'Division')


insert into dba.rollup40
select  distinct 'CostCenter',persno, lastname + ',' + firstname,
 3,'Cost Center Selection',CostCenter,CostCenter, NULL	,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	from dba.hierarchy_temp
	where costcenter is not null and persno not in
		(select corporatestructure from dba.rollup40 where costructid = 'CostCenter')
		
insert into dba.rollup40
select  distinct 'Geography',persno, lastname + ',' + firstname,
 4,'Geography Selection',Geography,Geography, NULL ,NULL,NULL ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL	,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	from dba.hierarchy_temp
	where Geography is not null and persno not in
		(select corporatestructure from dba.rollup40 where costructid = 'Geography')


insert into dba.rollup40
select  distinct 'Employee',persno, lastname + ',' + firstname,
 0,'Employee Selection',lastname + ',' + substring(firstname,1,4) + '-' + persno, lastname + ',' + firstname,
 [Group] ,[Group],Geography ,Geography,Location,Location,DivisionTitle,DivisionTitle
 ,OrganizationalUnitTitle,OrganizationalUnitTitle,MgrLevel, MgrLevel,SupervisorPersNo, SupervisorName
 ,PositionTitle,PositionTitle ,CoCode,CoCode,Platform,Platform,CostCenter,CostCenter,HireDate,HireDate
 ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	from dba.hierarchy_temp
	where  persno not in
		(select corporatestructure from dba.rollup40 where costructid = 'Employee')


insert into dba.rollup40
select  distinct 'DirectReport',persno, lastname + ',' + firstname,
 5,'Direct Report Selection',Substring(Supervisorname,1,40), SupervisorName,
 [Group] ,[Group],Geography ,Geography,Location,Location,DivisionTitle,DivisionTitle
 ,OrganizationalUnitTitle,OrganizationalUnitTitle,MgrLevel, MgrLevel,SupervisorPersNo, SupervisorName
 ,PositionTitle,PositionTitle ,CoCode,CoCode,Platform,Platform,CostCenter,CostCenter,HireDate,HireDate
 ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	from dba.hierarchy_temp
	where  persno not in
		(select corporatestructure from dba.rollup40 where costructid = 'DirectReport')

-------- Insert into lists ------- LOC/4/28/2013
insert into dba.listvalues
select distinct 'Division',rollup2 from dba.rollup40 where costructid = 'division'
and rollup2 not in (select listvalue from dba.listvalues)

insert into dba.listvalues
select distinct 'Group',rollup2 from dba.rollup40 where costructid = 'Group'
and rollup2 not in (select listvalue from dba.listvalues)

insert into dba.listvalues
select distinct 'Geography',rollup2 from dba.rollup40 where costructid = 'Geography'
and rollup2 not in (select listvalue from dba.listvalues)

insert into dba.listvalues
select distinct 'CostCenter',rollup2 from dba.rollup40 where costructid = 'CostCenter'
and rollup2 not in (select listvalue from dba.listvalues)


insert into dba.listvalues
select distinct 'Employee',rollup2 from dba.rollup40 where costructid = 'Employee'
and rollup2 not in (select listvalue from dba.listvalues)

-------- Insert Records into the Rollup40 Manager Table -- to be used in Rollup40 with
-------- costructid of Manager ------ LOC/11/8/2013
truncate table dba.rollup40_manager

insert into dba.rollup40_manager
select 'Backup',persNo, lastname+'/'+firstname+'-'+persno, '0','Manager',supervisorPersNo, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, lastname+'/'+firstname
from dba.hierarchy_temp

update dba.rollup40_manager
set rollupdesc2 = lastname+'/'+firstname 
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rollup2 = persno

-------- Update Rollup 3-12 this will give a Managerial rollup going backwards through the hierarchy
-------- LOC/11/8/2013

update rm
set rm.rollup3 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup2 = rh.persno 

update rm
set rm.rollupdesc3 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup3 = rh.persno 
----------------------------------
update rm
set rm.rollup4 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup3 = rh.persno 

update rm
set rm.rollupdesc4 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup4 = rh.persno 
----------------------------------
update rm
set rm.rollup5 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup4 = rh.persno 

update rm
set rm.rollupdesc5 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup5 = rh.persno 
----------------------------------
update rm
set rm.rollup6 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup5 = rh.persno 

update rm
set rm.rollupdesc6 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup6 = rh.persno 
----------------------------------
update rm
set rm.rollup7 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup6 = rh.persno 

update rm
set rm.rollupdesc7 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup7 = rh.persno 
----------------------------------
update rm
set rm.rollup8 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup7 = rh.persno 

update rm
set rm.rollupdesc8 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup8 = rh.persno 
----------------------------------
update rm
set rm.rollup9 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup8 = rh.persno 

update rm
set rm.rollupdesc9 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup9 = rh.persno 
----------------------------------
update rm
set rm.rollup10 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup9 = rh.persno 

update rm
set rm.rollupdesc10 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup10 = rh.persno 
----------------------------------
update rm
set rm.rollup11 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup10 = rh.persno 

update rm
set rm.rollupdesc11 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup11 = rh.persno 
----- Not needed as of Nov 13 but leaving just in case.
----------------------------------
update rm
set rm.rollup12 = rh.supervisorPersNo
from dba.rollup40_manager rm, dba.hierarchy_temp rh where  rm.rollup11 = rh.persno 

update rm
set rm.rollupdesc12 = rh.lastname+'/'+firstname
from dba.rollup40_manager rm, dba.hierarchy_temp rh where rm.rollup12 = rh.persno 
-------------------------------------------------------------------------------------------
-------- Insert into DBA.rollup40 -- Manager Level from Dba.rollup40_manager
-------- LOC/11/8/2013
insert into dba.rollup40
select 'Manager',corporatestructure, description, '6','Manager',NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL
from dba.rollup40_Manager
where costructid = 'Backup' 
and corporatestructure not in (select corporatestructure from dba.rollup40 where costructid = 'Manager')



---------- update rollup 2 --------------------------    
update dba.rollup40
set rollup2 = case when rm.rollup11 is not null and r.rollup2 is null then rm.rollup11   
			when rm.rollup10 is not null and r.rollup2 is null then rm.rollup10   
			when rm.rollup9 is not null and r.rollup2 is null then rm.rollup9   
			when rm.rollup8 is not null and r.rollup2 is null then rm.rollup8   
			when rm.rollup7 is not null and r.rollup2 is null then rm.rollup7   
			when rm.rollup6 is not null and r.rollup2 is null then rm.rollup6   
			when rm.rollup5 is not null and r.rollup2 is null then rm.rollup5   
			when rm.rollup4 is not null and r.rollup2 is null then rm.rollup4   
			when rm.rollup3 is not null and r.rollup2 is null then rm.rollup3   
			when rm.rollup2 is not null and r.rollup2 is null then rm.rollup2   end,
rollupdesc2 = Case when rm.rollup11 is not null and r.rollupdesc2 is null then rm.rollupdesc11   
			when rm.rollup10 is not null and r.rollupdesc2 is null then rm.rollupdesc10   
			when rm.rollup9 is not null and r.rollupdesc2 is null then rm.rollupdesc9   
			when rm.rollup8 is not null and r.rollupdesc2 is null then rm.rollupdesc8   
			when rm.rollup7 is not null and r.rollupdesc2 is null then rm.rollupdesc7   
			when rm.rollup6 is not null and r.rollupdesc2 is null then rm.rollupdesc6   
			when rm.rollup5 is not null and r.rollupdesc2 is null then rm.rollupdesc5   
			when rm.rollup4 is not null and r.rollupdesc2 is null then rm.rollupdesc4   
			when rm.rollup3 is not null and r.rollupdesc2 is null then rm.rollupdesc3   
			when rm.rollup2 is not null and r.rollupdesc2 is null then rm.rollupdesc2   end

from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'Manager'

-------------------Rollup 3 ------------------------
update r
set rollup3 = case   when r.rollup3 is null and rm.rollup10 is not null and r.rollup2 = rm.rollup11 then rm.rollup10
					 when r.rollup3 is null and rm.rollup9 is not null and r.rollup2 = rm.rollup10 then rm.rollup9
					 when r.rollup3 is null and rm.rollup8 is not null and r.rollup2 = rm.rollup9 then rm.rollup8
					 when r.rollup3 is null and rm.rollup7 is not null and r.rollup2 = rm.rollup8 then rm.rollup7
					 when r.rollup3 is null and rm.rollup6 is not null and r.rollup2 = rm.rollup7 then rm.rollup6
					 when r.rollup3 is null and rm.rollup5 is not null and r.rollup2 = rm.rollup6 then rm.rollup5
					 when r.rollup3 is null and rm.rollup4 is not null and r.rollup2 = rm.rollup5 then rm.rollup4
					 when r.rollup3 is null and rm.rollup3 is not null and r.rollup2 = rm.rollup4 then rm.rollup3
					 when r.rollup3 is null and rm.rollup2 is not null and r.rollup2 = rm.rollup3 then rm.rollup2
				end,
rollupdesc3 = case 	  when r.rollupdesc3 is null and rm.rollupdesc10 is not null and r.rollupdesc2 = rm.rollupdesc11 then rm.rollupdesc10
					 when r.rollupdesc3 is null and rm.rollupdesc9 is not null and r.rollupdesc2 = rm.rollupdesc10 then rm.rollupdesc9
					 when r.rollupdesc3 is null and rm.rollupdesc8 is not null and r.rollupdesc2 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc3 is null and rm.rollupdesc7 is not null and r.rollupdesc2 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc3 is null and rm.rollupdesc6 is not null and r.rollupdesc2 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc3 is null and rm.rollupdesc5 is not null and r.rollupdesc2 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc3 is null and rm.rollupdesc4 is not null and r.rollupdesc2 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc3 is null and rm.rollupdesc3 is not null and r.rollupdesc2 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc3 is null and rm.rollupdesc2 is not null and r.rollupdesc2 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and r.rollup2 is not null

--------------rollup 4---------------------------------
update r
set rollup4 = case   when r.rollup4 is null and rm.rollup9 is not null and r.rollup3 = rm.rollup10 then rm.rollup9
					 when r.rollup4 is null and rm.rollup8 is not null and r.rollup3 = rm.rollup9 then rm.rollup8
					 when r.rollup4 is null and rm.rollup7 is not null and r.rollup3 = rm.rollup8 then rm.rollup7
					 when r.rollup4 is null and rm.rollup6 is not null and r.rollup3 = rm.rollup7 then rm.rollup6
					 when r.rollup4 is null and rm.rollup5 is not null and r.rollup3 = rm.rollup6 then rm.rollup5
					 when r.rollup4 is null and rm.rollup4 is not null and r.rollup3 = rm.rollup5 then rm.rollup4
					 when r.rollup4 is null and rm.rollup3 is not null and r.rollup3 = rm.rollup4 then rm.rollup3
					 when r.rollup4 is null and rm.rollup2 is not null and r.rollup3 = rm.rollup3 then rm.rollup2
				end,
rollupdesc4 = case    when r.rollupdesc4 is null and rm.rollupdesc9 is not null and r.rollupdesc3 = rm.rollupdesc10 then rm.rollupdesc9
					 when r.rollupdesc4 is null and rm.rollupdesc8 is not null and r.rollupdesc3 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc4 is null and rm.rollupdesc7 is not null and r.rollupdesc3 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc4 is null and rm.rollupdesc6 is not null and r.rollupdesc3 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc4 is null and rm.rollupdesc5 is not null and r.rollupdesc3 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc4 is null and rm.rollupdesc4 is not null and r.rollupdesc3 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc4 is null and rm.rollupdesc3 is not null and r.rollupdesc3 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc4 is null and rm.rollupdesc2 is not null and r.rollupdesc3 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 5---------------------------------
update r
set rollup5 = case   when r.rollup5 is null and rm.rollup8 is not null and r.rollup4 = rm.rollup9 then rm.rollup8
					 when r.rollup5 is null and rm.rollup7 is not null and r.rollup4 = rm.rollup8 then rm.rollup7
					 when r.rollup5 is null and rm.rollup6 is not null and r.rollup4 = rm.rollup7 then rm.rollup6
					 when r.rollup5 is null and rm.rollup5 is not null and r.rollup4 = rm.rollup6 then rm.rollup5
					 when r.rollup5 is null and rm.rollup4 is not null and r.rollup4 = rm.rollup5 then rm.rollup4
					 when r.rollup5 is null and rm.rollup3 is not null and r.rollup4 = rm.rollup4 then rm.rollup3
					 when r.rollup5 is null and rm.rollup2 is not null and r.rollup4 = rm.rollup3 then rm.rollup2
				end,
rollupdesc5 = case   when r.rollupdesc5 is null and rm.rollupdesc8 is not null and r.rollupdesc4 = rm.rollupdesc9 then rm.rollupdesc8
					 when r.rollupdesc5 is null and rm.rollupdesc7 is not null and r.rollupdesc4 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc5 is null and rm.rollupdesc6 is not null and r.rollupdesc4 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc5 is null and rm.rollupdesc5 is not null and r.rollupdesc4 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc5 is null and rm.rollupdesc4 is not null and r.rollupdesc4 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc5 is null and rm.rollupdesc3 is not null and r.rollupdesc4 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc5 is null and rm.rollupdesc2 is not null and r.rollupdesc4 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 6---------------------------------
update r
set rollup6 = case	  when r.rollup6 is null and rm.rollup7 is not null and r.rollup5 = rm.rollup8 then rm.rollup7
					 when r.rollup6 is null and rm.rollup6 is not null and r.rollup5 = rm.rollup7 then rm.rollup6
					 when r.rollup6 is null and rm.rollup5 is not null and r.rollup5 = rm.rollup6 then rm.rollup5
					 when r.rollup6 is null and rm.rollup4 is not null and r.rollup5 = rm.rollup5 then rm.rollup4
					 when r.rollup6 is null and rm.rollup3 is not null and r.rollup5 = rm.rollup4 then rm.rollup3
					 when r.rollup6 is null and rm.rollup2 is not null and r.rollup5 = rm.rollup3 then rm.rollup2
				end,
rollupdesc6 = case   when r.rollupdesc6 is null and rm.rollupdesc7 is not null and r.rollupdesc5 = rm.rollupdesc8 then rm.rollupdesc7
					 when r.rollupdesc6 is null and rm.rollupdesc6 is not null and r.rollupdesc5 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc6 is null and rm.rollupdesc5 is not null and r.rollupdesc5 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc6 is null and rm.rollupdesc4 is not null and r.rollupdesc5 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc6 is null and rm.rollupdesc3 is not null and r.rollupdesc5 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc6 is null and rm.rollupdesc2 is not null and r.rollupdesc5 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 7---------------------------------
update r
set rollup7 = case	  when r.rollup7 is null and rm.rollup6 is not null and r.rollup6 = rm.rollup7 then rm.rollup6
					 when r.rollup7 is null and rm.rollup5 is not null and r.rollup6 = rm.rollup6 then rm.rollup5
					 when r.rollup7 is null and rm.rollup4 is not null and r.rollup6 = rm.rollup5 then rm.rollup4
					 when r.rollup7 is null and rm.rollup3 is not null and r.rollup6 = rm.rollup4 then rm.rollup3
					 when r.rollup7 is null and rm.rollup2 is not null and r.rollup6 = rm.rollup3 then rm.rollup2
				end,
rollupdesc7 = case   when r.rollupdesc7 is null and rm.rollupdesc6 is not null and r.rollupdesc6 = rm.rollupdesc7 then rm.rollupdesc6
					 when r.rollupdesc7 is null and rm.rollupdesc5 is not null and r.rollupdesc6 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc7 is null and rm.rollupdesc4 is not null and r.rollupdesc6 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc7 is null and rm.rollupdesc3 is not null and r.rollupdesc6 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc7 is null and rm.rollupdesc2 is not null and r.rollupdesc6 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 8---------------------------------
update r
set rollup8  = case   when r.rollup8 is null and rm.rollup5 is not null and r.rollup7 = rm.rollup6 then rm.rollup5
					 when r.rollup8 is null and rm.rollup4 is not null and r.rollup7 = rm.rollup5 then rm.rollup4
					 when r.rollup8 is null and rm.rollup3 is not null and r.rollup7 = rm.rollup4 then rm.rollup3
					 when r.rollup8 is null and rm.rollup2 is not null and r.rollup7 = rm.rollup3 then rm.rollup2
				end,
rollupdesc8 = case   when r.rollupdesc8 is null and rm.rollupdesc5 is not null and r.rollupdesc7 = rm.rollupdesc6 then rm.rollupdesc5
					 when r.rollupdesc8 is null and rm.rollupdesc4 is not null and r.rollupdesc7 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc8 is null and rm.rollupdesc3 is not null and r.rollupdesc7 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc8 is null and rm.rollupdesc2 is not null and r.rollupdesc7 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 9---------------------------------
update r
set rollup9 = case  when r.rollup9 is null and rm.rollup4 is not null and r.rollup8 = rm.rollup5 then rm.rollup4
					 when r.rollup9 is null and rm.rollup3 is not null and r.rollup8 = rm.rollup4 then rm.rollup3
					 when r.rollup9 is null and rm.rollup2 is not null and r.rollup8 = rm.rollup3 then rm.rollup2
				end,
rollupdesc9 = case    when r.rollupdesc9 is null and rm.rollupdesc4 is not null and r.rollupdesc8 = rm.rollupdesc5 then rm.rollupdesc4
					 when r.rollupdesc9 is null and rm.rollupdesc3 is not null and r.rollupdesc8 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc9 is null and rm.rollupdesc2 is not null and r.rollupdesc8 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 10---------------------------------
update r
set rollup10 = case  when r.rollup10 is null and rm.rollup3 is not null and r.rollup9 = rm.rollup4 then rm.rollup3
					 when r.rollup10 is null and rm.rollup2 is not null and r.rollup9 = rm.rollup3 then rm.rollup2
				end,
rollupdesc10 = case   when r.rollupdesc10 is null and rm.rollupdesc3 is not null and r.rollupdesc9 = rm.rollupdesc4 then rm.rollupdesc3
					 when r.rollupdesc10 is null and rm.rollupdesc2 is not null and r.rollupdesc9 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

--------------rollup 11---------------------------------
update r
set rollup11 = case  when r.rollup11 is null and rm.rollup2 is not null and r.rollup10 = rm.rollup3 then rm.rollup2
				end,
rollupdesc11 = case   when r.rollupdesc11 is null and rm.rollupdesc2 is not null and r.rollupdesc10 = rm.rollupdesc3 then rm.rollupdesc2
				
end
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' and r.rollup2 is not null

-----------Update bottom rollup to employee--------------------------------
update r
set r.rollup3 = rm.corporatestructure , r.rollupdesc3 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and r.rollup3 is null and r.rollup2 is not null

update r
set r.rollup4 = rm.corporatestructure , r.rollupdesc4 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and r.rollup4 is null and r.rollup2 is not null and r.rollup3 <> r.corporatestructure

update r
set r.rollup5 = rm.corporatestructure , r.rollupdesc5 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup5 is null and r.rollup2 is not null and r.rollup4 <> r.corporatestructure

update r
set r.rollup6 = rm.corporatestructure , r.rollupdesc6 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup6 is null and r.rollup2 is not null and r.rollup5 <> r.corporatestructure

update r
set r.rollup7 = rm.corporatestructure , r.rollupdesc7 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup7 is null and r.rollup2 is not null and r.rollup6 <> r.corporatestructure

update r
set r.rollup8 = rm.corporatestructure , r.rollupdesc8 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup8 is null and r.rollup2 is not null and r.rollup7 <> r.corporatestructure

update r
set r.rollup9 = rm.corporatestructure , r.rollupdesc9 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup9 is null and r.rollup2 is not null and r.rollup8 <> r.corporatestructure
 
update r
set r.rollup10 = rm.corporatestructure , r.rollupdesc10 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup10 is null and r.rollup2 is not null and r.rollup9 <> r.corporatestructure

update r
set r.rollup11 = rm.corporatestructure , r.rollupdesc11 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
 and r.rollup11 is null and r.rollup2 is not null and r.rollup10 <> r.corporatestructure

update r
set r.rollup12 = rm.corporatestructure , r.rollupdesc12 = rm.rollupdesc25 
from dba.rollup40 r, dba.rollup40_Manager rm
where r.corporatestructure = rm.corporatestructure and r.costructid = 'manager' 
and r.rollup12 is null and r.rollup2 is not null and r.rollup11 <> r.corporatestructure


GO
