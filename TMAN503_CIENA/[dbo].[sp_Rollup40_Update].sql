/****** Object:  StoredProcedure [dbo].[sp_Rollup40_Update]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Rollup40_Update]  

AS
--------Truncate and reload hierarchy from dba.hierarchy table --- LOC/12/29/2013



 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_Rollup40_Update]
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



delete from dba.rollup40 where costructid = 'cienahr'

----------------------
Insert into dba.rollup40
select 'CienaHR',employee_number, full_name,L1_SUP_EMP_NO, L1_SUPERVISOR, L2_SUP_EMP_NO, L2_SUPERVISOR,
L3_SUP_EMP_NO, L3_SUPERVISOR, L4_SUP_EMP_NO, L4_SUPERVISOR, L5_SUP_EMP_NO, L5_SUPERVISOR,
L6_SUP_EMP_NO, L6_SUPERVISOR, L7_SUP_EMP_NO, L7_SUPERVISOR, L8_SUP_EMP_NO, L8_SUPERVISOR, L9_SUP_EMP_NO, L9_SUPERVISOR, L10_SUP_EMP_NO, L10_SUPERVISOR
, NULL,NULL , NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL
, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL
from dba.hierarchy h
where employee_number not in (select corporatestructure from dba.rollup40 where costructid = 'CienaHR')



Insert into dba.rollup40
select 'Supervisor',employee_number, full_name, sup_emp_number, sup_name
,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl
,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL,NULl,NULL
from dba.hierarchy
where employee_number not in (select corporatestructure from dba.rollup40 where costructid = 'Supervisor')



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
