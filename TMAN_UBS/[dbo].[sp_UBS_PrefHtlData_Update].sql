/****** Object:  StoredProcedure [dbo].[sp_UBS_PrefHtlData_Update]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_PrefHtlData_Update]

AS
declare @TransStart DATETIME 
declare @ProcName varchar(50)
declare @TSUpdateEndSched nvarchar(50)
declare @IATANUM VARCHAR (50)


/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 11/24/2014
--Modification:  Added Comment line for tracking
--R. Robinson
************************************************************************/
--R. Robinson modified 02/11/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
declare @tmpStepName nvarchar(50); set @tmpStepName = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9); set @tmpTimeStmp = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----************************************************************************
------ Update dba.hotelproperty to set the NormPropertyName and PropertyName where norm name is NULL
update dba.hotelproperty 
set NormPropertyName = HotelPropertyName 
where normpropertyname is null and hotelpropertyname is not null and hotelpropertyname <> ''
and MasterID>1

------ Update dba.preferredhotels to set the Hotel Property Name and City to to match the Parent ID in dba.hotelporperty
update ph
set propname = dbo.topropercase (htlxref.normpropertyname)
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and propname <> htlxref.normpropertyname
and ph.MasterID <>'-1'
and ph.masterid is not null
and SEASON1START='2011-01-01'

update ph
set propcity = dbo.topropercase(htlxref.metroarea)
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and propcity <> htlxref.metroarea
and ph.MasterID <>'-1'
and ph.masterid is not null
and SEASON1START='2011-01-01'

--Master Chain Code updates so Top Hotel properties reports will return data with our without preferred
--SF# 6605617  KP 7/6/2015
 update ph
set ph.MASTERCHAINCODE=htlxref.chaincode
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and masterchaincode <> htlxref.chaincode
and ph.MasterID <>'-1'
and SEASON1START='2011-01-01'

 update ph
set ph.MASTERCHAINCODE=htlxref.chaincode
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and masterchaincode is null
and ph.MasterID <>'-1'
and SEASON1START='2011-01-01'
 
  -------- Run HNN on Preferred Hotels table for any new hotels added
 --Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime = '1/1/2014'
Declare @HNNEndDate datetime = '12/31/2020'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'UBSPH',
@Enhancement = 'HNN',
@Client = 'UBS',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNBeginDate,
@EndDate = @HNNEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'Preferred',
@TextParam2 = 'TTXPASQL01',
@TextParam3 = 'TMAN_UBS',
@TextParam4 = 'DBA',
@TextParam5 = 'datasvc',
@TextParam6 = 'tman2009',
@TextParam7 = 'TTXSASQL03',
@TextParam8 = 'TTXCENTRAL',
@TextParam9 = 'DBA',
@TextParam10 = 'datasvc',
@TextParam11 = 'tman2009',
@TextParam12 = 'Push',
@TextParam13 = 'R',
@TextParam14 = NULL,
@TextParam15 = NULL,
@IntParam1 = NULL,
@IntParam2 = NULL,
@IntParam3 = NULL,
@IntParam4 = NULL,
@IntParam5 = NULL,
@BoolParam1 = NULL,
@BoolParam2 = NULL,
@BoolParam3 = NULL,
@BoolParam4 = NULL,
@BoolParam5 = NULL,
@BoolParam6 = NULL,
@BoolParam7 = NULL,
@BoolParam8 = NULL,
@BoolParam9 = NULL,
@BoolParam10 = NULL,
@CommandLineArgs = NULL


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Pref Hotel Update Complete',@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
