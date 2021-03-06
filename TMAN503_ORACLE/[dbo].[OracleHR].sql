/****** Object:  StoredProcedure [dbo].[OracleHR]    Script Date: 7/14/2015 8:12:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OracleHR]
as
--create
insert into dba.employee(Country, Status, GlobalEmployeeID, EmployeeID, LastName, FirstName, Email, CostCenter, LineOfBusiness, MLevel, ManagerGlobalID, ManagerID, MangerEmailAddress, Type)
select COUNTRY,'ACTIVE',GID,EID,LASTNAME,Firstname,EMail,COSTCENTER,LOB,CAREER,ManagerGID,NULL,NULL,EMPLOYEETYPE2
from dba.EmployeeTemp 
where [ACTION] = 'CREATE'
--Delete
update emp
set [Status] = 'INACTIVE'
from dba.employee emp inner join dba.EmployeeTemp tmp
on tmp.GID = emp.GlobalEmployeeID
where tmp.ACTION = 'DELETE'
--Update
update emp
set emp.country = tmp.COUNTRY
,emp.status = 'ACTIVE'
,emp.globalemployeeID = tmp.GID
,emp.employeeID = tmp.EID
,emp.lastname = tmp.LASTNAME
,emp.firstname = tmp.FIRSTNAME
,emp.email = tmp.EMAIL
,emp.costcenter = tmp.COSTCENTER
,emp.lineofbusiness = tmp.LOB
,emp.Mlevel = tmp.CAREER
,emp.managerglobalID = NULL
,emp.managerID = tmp.MANAGERGID
,emp.mangerEmailAddress = NULL
,emp.type = tmp.EmployeeType2
from dba.employee emp inner join dba.EmployeeTemp tmp
on tmp.GID = emp.GlobalEmployeeID
and emp.employeeID = tmp.EID
where tmp.ACTION = 'UPDATE'





GO
