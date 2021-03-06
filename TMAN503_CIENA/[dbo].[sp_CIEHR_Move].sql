/****** Object:  StoredProcedure [dbo].[sp_CIEHR_Move]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE
 PROCEDURE [dbo].[sp_CIEHR_Move]
AS


 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CIEHR_Move]
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


-------- Pad the employee ID's to 5 digits -------------------------------------------
update dba.hierarchytemp
set employee_number = right('00000'+employee_number,5), sup_emp_number = right('00000'+sup_emp_number,5)
,l1_sup_emp_no = right('00000'+l1_sup_emp_no,5),l2_sup_emp_no = right('00000'+l2_sup_emp_no,5),l3_sup_emp_no = right('00000'+l3_sup_emp_no,5)
,l4_sup_emp_no = right('00000'+l4_sup_emp_no,5), l5_sup_emp_no = right('00000'+l5_sup_emp_no,5)
,l6_sup_emp_no = right('00000'+l6_sup_emp_no,5), l7_sup_emp_no = right('00000'+l7_sup_emp_no,5)
,l8_sup_emp_no = right('00000'+l8_sup_emp_no,5), l9_sup_emp_no = right('00000'+l9_sup_emp_no,5)
,l10_sup_emp_no = right('00000'+l10_sup_emp_no,5)

-------- Insert New Employees ------ LOC'4/18/2013
insert into dba.hierarchy
select  Employee_number,FULL_NAME ,EMAIL_ADDRESS ,USER_PERSON_TYPE,SUP_EMP_NUMBER,Sup_Name, SUP_EMAIL ,HR_DEPT,COST_CENTER ,COUNTRY ,LOCATION
,L1_SUP_EMP_NO ,L1_SUPERVISOR ,L1_SUP_EMAIL ,L2_SUP_EMP_NO ,L2_SUPERVISOR ,L2_SUP_EMAIL
,L3_SUP_EMP_NO ,L3_SUPERVISOR ,L3_SUP_EMAIL ,L4_SUP_EMP_NO ,L4_SUPERVISOR ,L4_SUP_EMAIL
,L5_SUP_EMP_NO ,L5_SUPERVISOR ,L5_SUP_EMAIL ,L6_SUP_EMP_NO ,L6_SUPERVISOR ,L6_SUP_EMAIL
,L7_SUP_EMP_NO ,L7_SUPERVISOR ,L7_SUP_EMAIL 
,Region, GL_Project, GL_region,'Not Provided',getdate(),NULL
,L8_SUP_EMP_NO ,L8_SUPERVISOR ,L8_SUP_EMAIL ,L9_SUP_EMP_NO ,L9_SUPERVISOR ,L9_SUP_EMAIL
,L10_SUP_EMP_NO ,L10_SUPERVISOR ,L10_SUP_EMAIL 

from dba.hierarchytemp
where employee_number not in (select employee_number from dba.hierarchy)

-------- Update where changes to Employee Info ------ LOC/4/18/2013
update h
set h.FULL_NAME = ht.FULL_NAME ,h.EMAIL_ADDRESS = ht.EMAIL_ADDRESS
,h.USER_PERSON_TYPE = ht.USER_PERSON_TYPE, h.SUP_EMP_NUMBER = ht.SUP_EMP_NUMBER
,h.SUP_NAME = ht.SUP_NAME ,h.SUP_EMAIL = ht.SUP_EMAIL ,h.HR_DEPT =ht.HR_DEPT
,h.COST_CENTER = ht.COST_CENTER ,h.COUNTRY = ht.COUNTRY ,h.LOCATION = ht.LOCATION
,h.L1_SUP_EMP_NO = ht.L1_SUP_EMP_NO ,h.L1_SUPERVISOR = ht.L1_SUPERVISOR ,h.L1_SUP_EMAIL = ht.L1_SUP_EMAIL
,h.L2_SUP_EMP_NO = ht.L2_SUP_EMP_NO ,h.L2_SUPERVISOR = ht.L2_SUPERVISOR ,h.L2_SUP_EMAIL = ht.L2_SUP_EMAIL
,h.L3_SUP_EMP_NO = ht.L3_SUP_EMP_NO ,h.L3_SUPERVISOR = ht.L3_SUPERVISOR ,h.L3_SUP_EMAIL = ht.L3_SUP_EMAIL
,h.L4_SUP_EMP_NO = ht.L4_SUP_EMP_NO ,h.L4_SUPERVISOR = ht.L4_SUPERVISOR ,h.L4_SUP_EMAIL = ht.L4_SUP_EMAIL
,h.L5_SUP_EMP_NO = ht.L5_SUP_EMP_NO ,h.L5_SUPERVISOR = ht.L5_SUPERVISOR ,h.L5_SUP_EMAIL = ht.L5_SUP_EMAIL
,h.L6_SUP_EMP_NO = ht.L6_SUP_EMP_NO ,h.L6_SUPERVISOR = ht.L6_SUPERVISOR ,h.L6_SUP_EMAIL = ht.L6_SUP_EMAIL
,h.L7_SUP_EMP_NO = ht.L7_SUP_EMP_NO ,h.L7_SUPERVISOR = ht.L7_SUPERVISOR ,h.L7_SUP_EMAIL = ht.L7_SUP_EMAIL
,h.Region = ht.region, h.gl_project = ht.gl_project, h.gl_region = ht.gl_region
 ,h.LastChange = Getdate()
,h.L8_SUP_EMP_NO = ht.L8_SUP_EMP_NO ,h.L8_SUPERVISOR = ht.L8_SUPERVISOR ,h.L8_SUP_EMAIL = ht.L8_SUP_EMAIL
,h.L9_SUP_EMP_NO = ht.L9_SUP_EMP_NO ,h.L9_SUPERVISOR = ht.L9_SUPERVISOR ,h.L9_SUP_EMAIL = ht.L9_SUP_EMAIL
,h.L10_SUP_EMP_NO = ht.L10_SUP_EMP_NO ,h.L10_SUPERVISOR = ht.L10_SUPERVISOR ,h.L10_SUP_EMAIL = ht.L10_SUP_EMAIL

from dba.hierarchy h, dba.hierarchytemp ht
where h.employee_number = ht.employee_number 
and
((h.FULL_NAME <> ht.FULL_NAME) or(h.EMAIL_ADDRESS <> ht.EMAIL_ADDRESS)
or(h.USER_PERSON_TYPE <> ht.USER_PERSON_TYPE) or(h.SUP_EMP_NUMBER <> ht.SUP_EMP_NUMBER)
or(h.SUP_NAME <> ht.SUP_NAME) or(h.SUP_EMAIL <> ht.SUP_EMAIL) or(h.HR_DEPT <>ht.HR_DEPT)
or(h.COST_CENTER <> ht.COST_CENTER)or(h.COUNTRY <> ht.COUNTRY) or(h.LOCATION <> ht.LOCATION)
or(h.L1_SUP_EMP_NO <> ht.L1_SUP_EMP_NO)or(h.L1_SUPERVISOR <> ht.L1_SUPERVISOR)or(h.L1_SUP_EMAIL <> ht.L1_SUP_EMAIL)
or(h.L2_SUP_EMP_NO <> ht.L2_SUP_EMP_NO)or(h.L2_SUPERVISOR <> ht.L2_SUPERVISOR)or(h.L2_SUP_EMAIL <> ht.L2_SUP_EMAIL)
or(h.L3_SUP_EMP_NO <> ht.L3_SUP_EMP_NO)or(h.L3_SUPERVISOR <> ht.L3_SUPERVISOR)or(h.L3_SUP_EMAIL <> ht.L3_SUP_EMAIL)
or(h.L4_SUP_EMP_NO <> ht.L4_SUP_EMP_NO)or(h.L4_SUPERVISOR <> ht.L4_SUPERVISOR)or(h.L4_SUP_EMAIL <> ht.L4_SUP_EMAIL)
or(h.L5_SUP_EMP_NO <> ht.L5_SUP_EMP_NO)or(h.L5_SUPERVISOR <> ht.L5_SUPERVISOR)or(h.L5_SUP_EMAIL <> ht.L5_SUP_EMAIL)
or(h.L6_SUP_EMP_NO <> ht.L6_SUP_EMP_NO)or(h.L6_SUPERVISOR <> ht.L6_SUPERVISOR)or(h.L6_SUP_EMAIL <> ht.L6_SUP_EMAIL)
or(h.L7_SUP_EMP_NO <> ht.L7_SUP_EMP_NO)or(h.L7_SUPERVISOR <> ht.L7_SUPERVISOR)or(h.L7_SUP_EMAIL <> ht.L7_SUP_EMAIL)
or(h.L8_SUP_EMP_NO <> ht.L8_SUP_EMP_NO)or(h.L8_SUPERVISOR <> ht.L8_SUPERVISOR)or(h.L8_SUP_EMAIL <> ht.L8_SUP_EMAIL)
or(h.L9_SUP_EMP_NO <> ht.L9_SUP_EMP_NO)or(h.L9_SUPERVISOR <> ht.L9_SUPERVISOR)or(h.L9_SUP_EMAIL <> ht.L9_SUP_EMAIL)
or(h.L10_SUP_EMP_NO <> ht.L10_SUP_EMP_NO)or(h.L10_SUPERVISOR <> ht.L10_SUPERVISOR)or(h.L10_SUP_EMAIL <> ht.L10_SUP_EMAIL)

)



EXEC dbo.sp_rollup40_update



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
