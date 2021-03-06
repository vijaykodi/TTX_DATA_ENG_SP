/****** Object:  StoredProcedure [dba].[LoadEmployeeTable]    Script Date: 7/14/2015 7:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dba].[LoadEmployeeTable](@begindate datetime, @enddate datetime)
as
----MAPPING Employee table from spreadsheet BNYMellon provided that was initially loaded into the employee table incorrectly but moved to dba.employee_bnym----
----Added filter: and EmployeeID1 not in ('000000000') per SF 00045923 9/29/2014 Pam S after discovering ('000000000') getting overwritten

/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[LoadEmployeeTable]
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


update dba.employee
set enddate = @begindate - 1
where enddate = '2099-12-31'
and EmployeeID1 not in ('000000000')

INSERT INTO DBA.Employee
select substring(ID,1,20) AS EmployeeID1
,substring(Last,1,35) AS LastName
,substring(First,1,25) AS FirstName
,NULL AS MiddleName
,substring(email,1,100) AS EmpEmail
,NULL AS EmployeeType
,NULL AS EmployeeStatus
,substring(ID,1,20) AS EmployeeID2
,substring(Address1,1,50) AS BusinessAddress
,substring(City,1,50) AS BusinessCity
,substring(State,1,20) AS BusinessStateCd
,NULL AS CountryCode
,substring(Region,1,50) AS BusinessRegion
,substring(SupVID,1,20) AS SupervisorID
,substring(SupVFirst,1,25) AS SupervisorFirstName
,substring(SupVLast,1,35) AS SupervisorLastName
,NULL AS SupervisorEmail
,NULL AS CostCenter
,substring(DeptID,1,50) AS DeptNumber
,NULL AS DivisionNumber
,NULL AS OrganizationUnit
,NULL AS Company
,VCShort AS AdditionalInfo1
,VCDescrSector AS AdditionalInfo2
,HRShort AS AdditionalInfo3
,HRDescrBUD AS AdditionalInfo4
, NULL AS AdditionalInfo5
, NULL AS AdditionalInfo6
, NULL AS AdditionalInfo7
, NULL AS AdditionalInfo8
, NULL AS AdditionalInfo9
, Country1 AS AdditionalInfo10
,@begindate AS BeginDate
,'2099-12-31' AS EndDate
,GETDATE() AS ImportDate
from dba.employee_BNYM



----Update country code in employee table----

update dba.employee
set businesscountry = CASE WHEN AdditionalInfo10 = 'ARE' THEN 'AE' --United Arab Emirates
					WHEN AdditionalInfo10 = 'ARG' THEN 'AR' --Argentina
					WHEN AdditionalInfo10 = 'AUS' THEN 'AU' --Australia
					WHEN AdditionalInfo10 = 'BEL' THEN 'BE' --Belgium
					WHEN AdditionalInfo10 = 'BMU' THEN 'BM' --Bermuda
					WHEN AdditionalInfo10 = 'BRA' THEN 'BR' --Brazil
					WHEN AdditionalInfo10 = 'CAN' THEN 'CA' --Canada
					WHEN AdditionalInfo10 = 'CHE' THEN 'CZ' --Czechlosovakia
					WHEN AdditionalInfo10 = 'CHL' THEN 'CL' --Chile
					WHEN AdditionalInfo10 = 'CHN' THEN 'CN' --China
					WHEN AdditionalInfo10 = 'CYM' THEN 'KY' --Cayman Islands
					WHEN AdditionalInfo10 = 'DEU' THEN 'DE' --Germany
					WHEN AdditionalInfo10 = 'DNK' THEN 'DK' --Denmark
					WHEN AdditionalInfo10 = 'EGY' THEN 'EG' --Egypt
					WHEN AdditionalInfo10 = 'ESP' THEN 'ES' --Spain
					WHEN AdditionalInfo10 = 'FRA' THEN 'FR' --France
					WHEN AdditionalInfo10 = 'GBR' THEN 'GB' --Great Britain
					WHEN AdditionalInfo10 = 'HKG' THEN 'CN' --China/Hong Kong
					WHEN AdditionalInfo10 = 'IDN' THEN 'ID' --Indonesia
					WHEN AdditionalInfo10 = 'IND' THEN 'IN' --India
					WHEN AdditionalInfo10 = 'IRL' THEN 'IE' --Ireland could be Israel
					WHEN AdditionalInfo10 = 'ITA' THEN 'IT' --Italy
					WHEN AdditionalInfo10 = 'JEY' THEN 'GB' --This is Jersey which I thought was part of GB?
					WHEN AdditionalInfo10 = 'JPN' THEN 'JP' --Japan
					WHEN AdditionalInfo10 = 'KOR' THEN 'KR' --South Korea
					WHEN AdditionalInfo10 = 'LBN' THEN 'LB' --Lebanon
					WHEN AdditionalInfo10 = 'LUX' THEN 'LU' --Luxemburg
					WHEN AdditionalInfo10 = 'MEX' THEN 'MX' --Mexico
					WHEN AdditionalInfo10 = 'MYS' THEN 'MY' --Malaysia
					WHEN AdditionalInfo10 = 'NLD' THEN 'NL' --Netherlands
					WHEN AdditionalInfo10 = 'PHL' THEN 'PH' --Phillipines
					WHEN AdditionalInfo10 = 'POL' THEN 'PL' --Poland
					WHEN AdditionalInfo10 = 'RUS' THEN 'RU' --Russia
					WHEN AdditionalInfo10 = 'SGP' THEN 'SG' --Singapore
					WHEN AdditionalInfo10 = 'THA' THEN 'TH' --Thailand
					WHEN AdditionalInfo10 = 'TUR' THEN 'TR' --Turkey
					WHEN AdditionalInfo10 = 'TWN' THEN 'TW' --Taiwan
					WHEN AdditionalInfo10 = 'USA' THEN 'US' --United States
					WHEN AdditionalInfo10 = 'ZAF' THEN 'ZA' --South Africa
					ELSE ''
					END
-- validate all countries done

----Update Supervisor E-Mail address

update t1
set t1.supervisoremail = t2.empemail
 from dba.employee t1
 inner join dba.employee t2 on ( t1.supervisorid = t2.employeeid1 )
 where t1.supervisoremail is null
 
 -- Build Managerial 
--YL 10/20/2014
--YL 2015-01-29
delete from  dba.costructload
WHERE Child in (select EmployeeID1 from dba.Employee where enddate ='2099-12-31' )
-----------------------------------------------
insert into dba.CoStructLoad
SELECT  distinct EmployeeID1, LastName+'\'+FirstName,SupervisorID
from dba.employee
WHERE  enddate ='2099-12-31' 
 

insert into dba.CoStructLoad
values( '000000000', 'UNKNOWN', '000259687')


update dba.CoStructLoad
set parent = null 
where Child = Parent

-- Supervisors not in CS as child will roll to uknown
insert into dba.CoStructLoad
select distinct SupervisorID,SupervisorLastName+'\'+SupervisorFirstName,'000000000'  
from dba.employee
where SupervisorID not in (select Child from dba.CoStructLoad)
 and enddate ='2099-12-31' 
 

--Load rollup40
delete from dba.ROLLUP40
where COSTRUCTID = 'MANAGERIAL'
 
 /* can't use costructload for managerial and functional same time - YL 10/20/2014
 --Build functional corporate structure

truncate table DBA.CoStructLoad
 
 INSERT INTO DBA.CoStructLoad
 select distinct 'BNY MELLON','Bank of New York Mellon',''
 from dba.employee
 
 union 
 
 select distinct AdditionalInfo1,AdditionalInfo2,'BNY MELLON' 
 from dba.employee
 where additionalinfo3 is not null
and enddate ='2099-12-31' 
 
 UNION
 
 select distinct AdditionalInfo3,AdditionalInfo4,AdditionalInfo1 
 from dba.employee
where additionalinfo3 is not null
and enddate ='2099-12-31' 

*/

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
