/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSUPRES]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSUPRES]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime


	SET @Iata = 'UBSUPRES'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = getdate()
    SET @ENDIssueDate = getdate() 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

--update dba.PreferredRestaurants Case # 25969 12/18/2013 KP
--DELETE EXISTING DATA
Truncate table dba.PREFERREDRESTAURANTS

SET @TransStart = getdate()
-------Insert new data from Temp into Production Table ---------------------------------------------

INSERT INTO DBA.PREFERREDRESTAURANTS
SELECT RestaurantGroupID, 
MerchantId, 
MerchantName1, 
MerchantName2, 
MerchantChain, 
MerchantBrand, 
MerchantAddr1, 
MerchantAddr2, 
MerchantAddr3, 
MerchantAddr4, 
MerchantCity, 
MerchantState, 
MerchantZip, 
MerchantCtryCode, 
MerchantCtryName, 
DiscountType, 
Tier1low, 
Tier1high, 
Tier2low, 
Tier2high, 
Tier3low, 
Tier3high, 
Tier4low, 
Tier4high, 
Tier1Rebate, 
Tier2Rebate, 
Tier3Rebate, 
Tier4Rebate, 
LessGratuity, 
LessTax, 
LessAlcohol, 
LessAdmin, 
DiscountAmt, 
PercentOfSpend, 
Threshold, 
UBSCHAINAME, 
Notes,
BeginDate,
EndDate

FROM DBO.PREFREST_TEMP


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Data Insert Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update PurgeInd (used as preferred indicator - Values Y or N) Case #25969
SET @TransStart = getdate()
update ccm 
set purgeind = 'Y' 
from dba.ccmerchant ccm, 
dba.preferredrestaurants pr 
where ccm.merchantid = pr.merchantid
and isnull(ccm.purgeind,'x') <>'Y'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-Purge Ind Update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Setting the ccm.CIDName = UBS chain name Case #25969
--Setting cchdr.remarks6 = UBS Chain Name - Case #37402 - Updated 22MAY2014 by SS
SET @TransStart = getdate()
--update ccm 
--set sicname = ubschainname 
--from dba.ccmerchant ccm, 
--dba.preferredrestaurants pr 
--where ccm.merchantid = pr.merchantid
--and sicname <> ubschainname
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-CIDName Update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--select cchdr.remarks6, pr.ubschainname
------- Remars6 is only 40 characters .. substring to resolve.  Only 1 has more than 40 as of /7/17/2014..LOC
update cchdr
set cchdr.Remarks6 = substring(pr.UBSChainName,1,40)
from dba.CCMerchant ccm, dba.ccheader cchdr, dba.preferredrestaurants pr
where ccm.merchantid = pr.merchantid 
and pr.merchantid = cchdr.merchantid
and ccm.merchantid = cchdr.MerchantId
and isnull(cchdr.remarks6,'z') <> pr.ubschainname

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-CIDName Update-CCHeader.Remarks6',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------ Preferred Restaurant Flagging --- 9/10/2014 .. LOC

-----------------Flag Restaurants from Preferred Table ---------
update cch
set purgeind = 'Y'
from dba.ccheader cch, dba.preferredrestaurants pr
where cch.merchantid = pr.merchantid
and cch.transactiondate between pr.begindate and pr.enddate
and isnull(purgeind,'N') in('N','E')

--------Changing the indicator to N when no longer Preferred for the date range
update cch
set purgeind = 'N'
from dba.ccheader cch, dba.preferredrestaurants pr
where cch.merchantid = pr.merchantid
and cch.transactiondate not between pr.begindate and pr.enddate
and isnull(purgeind,'Y') in ('Y','E')

-------- Change the inictor to E when included in the Exlude list
update cch
set purgeind = 'E'
from dba.ccheader cch, dba.ccmerchantexclude me
where cch.merchantid = me.merchantid
and category = 'Restaurant'

update cch
set purgeind = 'N'
from dba.ccheader cch, dba.ccmerchant ccm
where cch.merchantid = ccm.merchantid
and IndustryCode = '05'
and cch.purgeind is NULL


--Truncate table dba.PREFERREDRESTAURANTS_TEMP



--select distinct UBSchainname from dba.preferredrestaurants
--where len(ubschainname) > 39

 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
