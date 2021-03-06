/****** Object:  StoredProcedure [dbo].[LoadCostructLoad]    Script Date: 7/14/2015 8:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[LoadCostructLoad] @enddate as datetime, @begindate as datetime
as


--Step 1 to delete everything on employee_sanofi except Chattem (comes in separate file)
--done in SSIS

--Step 2 Mover data from Staging DBA.HR_File to Production DBA.Employee_Sanofi
--done in SSIS
--------------------------------------------------------------------------------------
---- Adding Logging per Jim's request in SF 00047318
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'SANHR'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Start Stored Procedure',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------------------------------------------------------------------------------------
--Step 3 Close period for Employee Table  This needs to come from date of file
SET @TransStart = getdate()
UPDATE DBA.Employee
SET EndDate = dateadd(d,-1,@begindate)
WHERE EndDate = '2099-12-31'
AND OrganizationUnit <> 'chattem'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 3 -Set EndDate',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--Step 4 Insert into DBA.Employee from DBA.Employee_Sanofi for all except Chattem
--If we have issues with dupes again, we will need to delete the duplicate Chattem employees from DBA.Employee

SET @TransStart = getdate()
insert into dba.employee
select left(convergenceID,20) AS EmployeeId1
,left(UPPER(LastName),35) AS LastName
,left(UPPER(FirstName),25) AS FirstName
,left(UPPER(MiddleName),15) AS MiddleName
,emailaddress AS EMPEmail
, Remote AS EmployeeType
,EmploymentStatus AS EmployeeStatus
,left(localid,20) AS EmployeeId2
,null AS BusinessAddress
,null AS BusinessCity
,null AS BusinessStateCd
,null AS BusinessCountry
,null AS BusinessRegion
,left(managerconvergenceid,20) as supervisorid
,left(UPPER(managerfirstname),25) AS SuroervisorFirstName
,left(UPPER(managerlastname),35) AS SupervisorLastName
,manageremailaddress AS SupervisorEmail
,costcenter AS CostCenter
,null AS DeptNumber
,null,businessUnit as organizationunit
,entitydescription as company
,null AS AdditionalInfo1
,null AS AdditionalInfo2
,null AS AdditionalInfo3
,null AS AdditionalInfo4
,null AS AdditionalInfo5
,null AS AdditionalInfo6
,null AS AdditionalInfo7
,null AS AdditionalInfo8
,null AS AdditionalInfo9
,null AS AdditionalInfo10
,@begindate as begindate --This needs to come from date of file
, '2099-12-31' as enddate
, getdate() as importdate
from dba.employee_sanofi
where BusinessUnit <> 'chattem'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Sep 4 Insert into dba.Employee',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Step 5: Delete duplicate Chattem employees

SET @TransStart = getdate()
delete dba.employee
where ((organizationunit = 'chattem' or company = 'USCHATTEM'))
and employeeid1 in (select distinct employeeid1 from dba.employee
where employeeid1 in ('00056950','00057025')
and ((organizationunit <> 'chattem' or company <> 'USCHATTEM')) )
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Sep 5 Delete duplicate Chattem',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Step 6: Create DBA.CostructLoad

-- Truncate table to clear out last loaded

SET @TransStart = getdate()
TRUNCATE TABLE DBA.CostructLoad
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 6a -Truncate dba.CostructLoad',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Insert data into CostructLoad excluding data that creates circular references.

SET @TransStart = getdate()
INSERT INTO DBA.CostructLoad
SELECT EmployeeId1,UPPER(LastName)+'/'+UPPER(FirstName),'SANOFI' 
FROM DBA.Employee 
where SupervisorId not in 
(SELECT DISTINCT EmployeeId1 FROM DBA.Employee)
AND EndDate = '2099-12-31'
AND EmployeeStatus in ('1','3','A')



UNION

SELECT EmployeeId1,UPPER(LastName)+'/'+UPPER(FirstName),SupervisorId
FROM DBA.Employee 
WHERE SupervisorId IN 
(SELECT DISTINCT EmployeeId1 FROM DBA.Employee)
AND EndDate = '2099-12-31'
AND EmployeeStatus in ('1','3','A')


UNION

SELECT DISTINCT 'SANOFI','SANOFI','' FROM DBA.Employee

order by 3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Step 6b -Insert dba.CostructLoad',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='END Stored Procedure',@BeginDate=@BeginDate,@EndDate=@EndDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
