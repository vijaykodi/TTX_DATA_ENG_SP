/****** Object:  StoredProcedure [dbo].[sp_BOFACOST]    Script Date: 7/14/2015 7:50:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_BOFACOST]
AS

SET NOCOUNT ON



/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_BOFACOST]
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

delete 
from ttxpasql01.tman503_boa.dba.rollup40
where costructid = '91 Hierarchy'

Insert ttxpasql01.tman503_boa.dba.rollup40
select distinct '91 Hierarchy','0'+PRIMARY_COMPANY_CC,PRIMARY_COMPANY_CC_NAME, 'BOA Global','BOA Global',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91
where PRIMARY_COMPANY_CC IS NOT NULL
and ALT_91_2_DOT IS NOT NULL
and ALT_91_2_DOT <>''

update ru40
set ru40.ROLLUP2 = hr.ALT_91_2_DOT,
ru40.RollupDesc2 = hr.ALT_91_2_DOT+hr.ALT_91_2_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_2_DOT IS NOT NULL
and hr.ALT_91_2_DOT <>''
and hr.ALT_91_2_DOT in (select distinct hr.ALT_91_2_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP3 = hr.ALT_91_3_DOT,
ru40.RollupDesc3 = hr.ALT_91_3_DOT+hr.ALT_91_3_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_3_DOT IS NOT NULL
and hr.ALT_91_3_DOT <>''
and hr.ALT_91_3_DOT in (select distinct hr.ALT_91_3_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP4 = hr.ALT_91_4_DOT,
ru40.RollupDesc4 = hr.ALT_91_4_DOT+hr.ALT_91_4_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_4_DOT IS NOT NULL
and hr.ALT_91_4_DOT <>''
and hr.ALT_91_4_DOT in (select distinct hr.ALT_91_4_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP5 = hr.ALT_91_5_DOT,
ru40.RollupDesc5 = hr.ALT_91_5_DOT+hr.ALT_91_5_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_5_DOT IS NOT NULL
and hr.ALT_91_5_DOT <>''
and hr.ALT_91_5_DOT in (select distinct hr.ALT_91_5_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP6 = hr.ALT_91_6_DOT,
ru40.RollupDesc6 = hr.ALT_91_6_DOT+hr.ALT_91_6_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_6_DOT IS NOT NULL
and hr.ALT_91_6_DOT <>''
and hr.ALT_91_6_DOT in (select distinct hr.ALT_91_6_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP7 = hr.ALT_91_7_DOT,
ru40.RollupDesc7 = hr.ALT_91_7_DOT+hr.ALT_91_7_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_7_DOT IS NOT NULL
and hr.ALT_91_7_DOT <>''
and hr.ALT_91_7_DOT in (select distinct hr.ALT_91_7_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP8 = hr.ALT_91_8_DOT,
ru40.RollupDesc8 = hr.ALT_91_8_DOT+hr.ALT_91_8_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_8_DOT IS NOT NULL
and hr.ALT_91_8_DOT <>''
and hr.ALT_91_8_DOT in (select distinct hr.ALT_91_8_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP9 = hr.ALT_91_9_DOT,
ru40.RollupDesc9 = hr.ALT_91_9_DOT+hr.ALT_91_9_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_9_DOT IS NOT NULL
and hr.ALT_91_9_DOT <>''
and hr.ALT_91_9_DOT in (select distinct hr.ALT_91_9_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

update ru40
set ru40.ROLLUP10 = hr.ALT_91_10_DOT,
ru40.RollupDesc10 = hr.ALT_91_10_DOT+hr.ALT_91_10_DOT_NAME
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '91 Hierarchy'
and hr.ALT_91_10_DOT IS NOT NULL
and hr.ALT_91_10_DOT <>''
and hr.ALT_91_10_DOT in (select distinct hr.ALT_91_10_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

Insert ttxpasql01.tman503_boa.dba.rollup40 values('91 Hierarchy','9999999999','UNKNOWN', 'BOA Global','BOA Global','91........','91........Bank of America Consolidated            ','UNKNOWN','UNKNOWN',NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)



--BUILD 10 DOT HIERARCHY BASED ON COST CENTER TRANSLATION

delete 
from ttxpasql01.tman503_boa.dba.rollup40
where costructid = '10 Dot'

Insert ttxpasql01.tman503_boa.dba.rollup40
select distinct '10 Dot','0'+PRIMARY_COMPANY_CC,PRIMARY_COMPANY_CC_NAME, 'BOA Global','BOA Global','10 Dot','10 Dot',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91
where PRIMARY_COMPANY_CC IS NOT NULL
and PRIMARY_1_DOT IS NOT NULL
and PRIMARY_1_DOT <>''

update ru40
set ru40.ROLLUP3 = hr.PRIMARY_1_DOT,
ru40.RollupDesc3 = hr.PRIMARY_1_DOT+hr.PRIMARY_1_DOT_NAME,
ru40.ROLLUP4 = hr.PRIMARY_2_DOT,
ru40.ROLLUPDESC4 = hr.PRIMARY_2_DOT+hr.PRIMARY_2_DOT_NAME,
ru40.ROLLUP5 = hr.PRIMARY_3_DOT,
ru40.ROLLUPDESC5 = hr.PRIMARY_3_DOT+hr.PRIMARY_3_DOT_NAME,
ru40.ROLLUP6 = case when hr.PRIMARY_4_DOT = '' then NULL else hr.PRIMARY_4_DOT end ,
ru40.ROLLUPDESC6 = case when hr.PRIMARY_4_DOT = '' then NULL else hr.PRIMARY_4_DOT+hr.PRIMARY_4_DOT_NAME end,
ru40.ROLLUP7 = case when hr.PRIMARY_5_DOT = '' then NULL else hr.PRIMARY_5_DOT end ,
ru40.ROLLUPDESC7 = case when hr.PRIMARY_5_DOT = '' then NULL else hr.PRIMARY_5_DOT+hr.PRIMARY_5_DOT_NAME end,
ru40.ROLLUP8 = case when hr.PRIMARY_6_DOT = '' then NULL else hr.PRIMARY_6_DOT end,
ru40.ROLLUPDESC8 = case when hr.PRIMARY_6_DOT = '' then NULL else hr.PRIMARY_6_DOT+hr.PRIMARY_6_DOT_NAME end,
ru40.ROLLUP9 = case when hr.PRIMARY_7_DOT = '' then NULL else hr.PRIMARY_7_DOT end,
ru40.ROLLUPDESC9 = case when hr.PRIMARY_7_DOT = '' then NULL else hr.PRIMARY_7_DOT+hr.PRIMARY_7_DOT_NAME end,
ru40.ROLLUP10 = case when hr.PRIMARY_8_DOT = '' then NULL else hr.PRIMARY_8_DOT end,
ru40.ROLLUPDESC10 = case when hr.PRIMARY_8_DOT = '' then NULL else hr.PRIMARY_8_DOT+hr.PRIMARY_8_DOT_NAME end,
ru40.ROLLUP11 = case when hr.PRIMARY_9_DOT = '' then NULL else hr.PRIMARY_9_DOT end,
ru40.ROLLUPDESC11 = case when hr.PRIMARY_9_DOT = '' then NULL else hr.PRIMARY_9_DOT+hr.PRIMARY_9_DOT_NAME end,
ru40.ROLLUP12 = case when hr.PRIMARY_10_DOT = '' then NULL else hr.PRIMARY_10_DOT end,
ru40.ROLLUPDESC12 = case when hr.PRIMARY_10_DOT = '' then NULL else hr.PRIMARY_10_DOT+hr.PRIMARY_10_DOT_NAME end
from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
, ttxpasql01.tman503_boa.dba.rollup40 RU40
where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
and ru40.COSTRUCTID = '10 Dot'
and hr.PRIMARY_1_DOT IS NOT NULL
and hr.PRIMARY_1_DOT <>''
and hr.PRIMARY_1_DOT in (select distinct hr.PRIMARY_1_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP2 = hr.PRIMARY_1_DOT,
--ru40.RollupDesc2 = hr.PRIMARY_1_DOT+hr.PRIMARY_1_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.PRIMARY_1_DOT IS NOT NULL
--and hr.PRIMARY_1_DOT <>''
--and hr.PRIMARY_1_DOT in (select distinct hr.PRIMARY_1_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)


--update ru40
--set ru40.ROLLUP3 = hr.ALT_91_3_DOT,
--ru40.RollupDesc3 = hr.ALT_91_3_DOT+hr.ALT_91_3_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_3_DOT IS NOT NULL
--and hr.ALT_91_3_DOT <>''
--and hr.ALT_91_3_DOT in (select distinct hr.ALT_91_3_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP4 = hr.ALT_91_4_DOT,
--ru40.RollupDesc4 = hr.ALT_91_4_DOT+hr.ALT_91_4_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_4_DOT IS NOT NULL
--and hr.ALT_91_4_DOT <>''
--and hr.ALT_91_4_DOT in (select distinct hr.ALT_91_4_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP5 = hr.ALT_91_5_DOT,
--ru40.RollupDesc5 = hr.ALT_91_5_DOT+hr.ALT_91_5_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_5_DOT IS NOT NULL
--and hr.ALT_91_5_DOT <>''
--and hr.ALT_91_5_DOT in (select distinct hr.ALT_91_5_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP6 = hr.ALT_91_6_DOT,
--ru40.RollupDesc6 = hr.ALT_91_6_DOT+hr.ALT_91_6_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_6_DOT IS NOT NULL
--and hr.ALT_91_6_DOT <>''
--and hr.ALT_91_6_DOT in (select distinct hr.ALT_91_6_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP7 = hr.ALT_91_7_DOT,
--ru40.RollupDesc7 = hr.ALT_91_7_DOT+hr.ALT_91_7_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_7_DOT IS NOT NULL
--and hr.ALT_91_7_DOT <>''
--and hr.ALT_91_7_DOT in (select distinct hr.ALT_91_7_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP8 = hr.ALT_91_8_DOT,
--ru40.RollupDesc8 = hr.ALT_91_8_DOT+hr.ALT_91_8_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_8_DOT IS NOT NULL
--and hr.ALT_91_8_DOT <>''
--and hr.ALT_91_8_DOT in (select distinct hr.ALT_91_8_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP9 = hr.ALT_91_9_DOT,
--ru40.RollupDesc9 = hr.ALT_91_9_DOT+hr.ALT_91_9_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_9_DOT IS NOT NULL
--and hr.ALT_91_9_DOT <>''
--and hr.ALT_91_9_DOT in (select distinct hr.ALT_91_9_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

--update ru40
--set ru40.ROLLUP10 = hr.ALT_91_10_DOT,
--ru40.RollupDesc10 = hr.ALT_91_10_DOT+hr.ALT_91_10_DOT_NAME
--from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 HR
--, ttxpasql01.tman503_boa.dba.rollup40 RU40
--where '0'+hr.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE
--and ru40.COSTRUCTID = '10 Dot'
--and hr.ALT_91_10_DOT IS NOT NULL
--and hr.ALT_91_10_DOT <>''
--and hr.ALT_91_10_DOT in (select distinct hr.ALT_91_10_DOT from ttxpasql01.tman503_boa.DBA.COSTCENTERTO91 hr2 
--where '0'+hr2.PRIMARY_COMPANY_CC = ru40.CORPORATESTRUCTURE)

Insert ttxpasql01.tman503_boa.dba.rollup40 values('10 Dot','9999999999','ZZZZZZZZZZ_UNKNOWN', 'BOA Global','BOA Global','10 Dot','10 Dot','ZZZ...UNKNOWN','ZZZ...UNKNOWN',NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)




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
