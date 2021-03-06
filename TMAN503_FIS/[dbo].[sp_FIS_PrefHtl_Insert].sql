/****** Object:  StoredProcedure [dbo].[sp_FIS_PrefHtl_Insert]    Script Date: 7/14/2015 8:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_FIS_PrefHtl_Insert] 
as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'FISCCAX'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
-------------------------------------------------------------------------------
-------- Please note ----------------------------------------------------------
-------- The following changes must take place yearly.
----1. Date ranges in the insert query
----2. Last line of the insert query must be commented out to insert a new years records.
----3. Once a new years records are inserted the last line must be placed back into the query for further
------ future processing throught the year.
--------------------------------------------------------------------------------
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='FIS PrefHotels SP Start% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Updates to data before import -------- 
-- added NLRA_S2 & NLRA_S3.... case#36371 // TT // 5.12.2014
update dba.PrefHotels_ClientSpecific
set NLRA_S1_RT1_SGL = case when NLRA_S1_RT1_SGL like '%n%' then 0 
					  when NLRA_S1_RT1_SGL like '.' then 0  end
    ,NLRA_S2_RT1_SGL = case when NLRA_S2_RT1_SGL like '%n%' then 0
					  when NLRA_S2_RT1_SGL like '.' then 0 	end	
    ,NLRA_S3_RT1_SGL = case when NLRA_S3_RT1_SGL like '%n%' then 0
					  when NLRA_S3_RT1_SGL like '.' then 0 	end		  
    ,NLRA_S4_RT1_SGL = case when NLRA_S4_RT1_SGL like '%n%' then 0
					  when NLRA_S4_RT1_SGL like '.' then 0 end
					  
update dba.PrefHotels_ClientSpecific
set LRA_S1_RT1_SGL = case when LRA_S1_RT1_SGL like '%n%' then 0 
					  when LRA_S1_RT1_SGL like '.' then 0  end
    ,LRA_S2_RT1_SGL = case when LRA_S2_RT1_SGL like '%n%' then 0
					  when LRA_S2_RT1_SGL like '.' then 0 	end	
    ,LRA_S3_RT1_SGL = case when LRA_S3_RT1_SGL like '%n%' then 0
					  when LRA_S3_RT1_SGL like '.' then 0 	end		  
    ,LRA_S4_RT1_SGL = case when LRA_S4_RT1_SGL like '%n%' then 0
					  when LRA_S4_RT1_SGL like '.' then 0 end					  
					  
update dba.prefhotels_propertybasic
set propcountry = 'United States of America'
where propcountry in ('USA','United States')


insert into dba.preferredhotels
select pb.MAINPHONECOUNTRY, pb.MAINPHONECITY, pb.MAINPHONE, substring(pb.sabre_chaincode,1,2),pb.PROPNAME, 
pb.PROPADD1, pb.PROPADD2, pb.PROPCITY, substring(pb.PROPSTATEPROV,1,10), substring(pb.PROPPOSTCODE,1,10), 
pb.PROPCOUNTRY,
cs.SEASON1START, cs.SEASON1END, cs.SEASON2START, cs.SEASON2END, cs.SEASON3START, cs.SEASON3END,
cs.SEASON4START, cs.SEASON4END, cs.LRA_S1_RT1_SGL, cs.LRA_S2_RT1_SGL, cs.LRA_S3_RT1_SGL, 
cs.LRA_S4_RT1_SGL, cs.RATE_CURR, 'XXX'
--AirCityCode XXX
, 'Y', NULL, ctry.ctrycode, 'Y','FIS',
'0'
-- SeasonRate XXX
, '1/1/2014','12/31/2014',pb.min_owned_cert, pb.wmn_owned_cert, NULL, pb.PropCode, 
'XXX'
--SeasonRateCategory XXX
, sabre_propcode, amadeus_propcode, apollo_propcode, wrldspan_propcode,
cs.NLRA_S1_RT1_SGL, cs.NLRA_S2_RT1_SGL, cs.NLRA_S3_RT1_SGL, cs.NLRA_S4_RT1_SGL,NULL, 
NULL, cs.CUST1_S1_RT1_SGL, cs.CUST1_S1_RT2_SGL, park_include, break_include, fitness_include_on,
local_phone_include, toll_card_call_include,NULL, wireless_include, comp_infax, airtrans_include,
offtrans_include, Null, Null, Null, Null, substring(Mgmtcompany,1,100), substring(ownercompany,1,100)

from dba.prefhotels_propertybasic pb, dba.prefhotels_clientspecific cs,
dba.country ctry
where pb.propcode = cs.propcode
and pb.propcountry = ctry.ctryname
and pb.propcode not in (select SabreGDSCode from dba.preferredhotels) 
--commented out this was hindering adding the 2014 season//TT//Case#30145
-- line has been commented back in as this needs to be there through out the year as new hotels are added and
-- the file contains current and new entries....LOC/4/16/2014

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='FIS PrefHotels SP END% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--per case#00016568 automating HNN to run against preferred
--add to the end after HNN cleanup sql's run
--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from  TTXPASQL01.TMAN503_FIS.dba.Hotel
Where MasterId is NULL
and invoicedate > '2011-12-31'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'FISGTD',
@Enhancement = 'HNN',
@Client = 'FIS',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNBeginDate,
@EndDate = @HNNEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'PREFERRED',
@TextParam2 = 'TTXPASQL01',
@TextParam3 = 'TMAN503_FIS',
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


GO
