/****** Object:  StoredProcedure [dbo].[ClearProfiles]    Script Date: 7/14/2015 7:50:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ClearProfiles]
AS

BEGIN


 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[ClearProfiles]
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


 DELETE dba.Profiles WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

DELETE dba.ProfileFilters WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

DELETE dba.ProfileRelations WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

DELETE dba.ProfileReports WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)


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

END

GO
