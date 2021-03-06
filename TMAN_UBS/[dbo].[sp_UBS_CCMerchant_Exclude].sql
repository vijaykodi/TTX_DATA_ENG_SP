/****** Object:  StoredProcedure [dbo].[sp_UBS_CCMerchant_Exclude]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_CCMerchant_Exclude]
 AS
  /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
 ---------------------------------------------------------------------------------------------------------
 -------- I am working on updating this process. I have created a table DBA.CarServ_Incl_Exc
 -------- This has the merchant ID and Include/Exclude column.  I have requested a SSIS be created
 -------- so that we can have UBS send the file to the AP and have it loaded (Case 41862).
 -------- Once this is completed we can update this process.  I need to make sure we dont have to create
 -------- a temp table first and then import to the Dba.CarServ_Incl_exc table...LOC 7/16/2014
 ----------------------------------------------------------------------------------------------------------
 --#34341  Setting CCMerchant PurgeInd=E for merchants to be Excluded from Preferred Vendor reports
  ------- updated from <> 'E' to not in ('E','Y') as this was changing the Preferreds to E.
 --#50693 - UBS no longer sending Exclude list - only sending Include which is Car Service vendors
 --they want marked as non preferred 
 --UPDATE M
 --SET PurgeInd='E'
 --FROM DBA.CCMerchant M,  DBO.CCMerchant_Exclude ME
 -- WHERE   M.MerchantId=ME.MERCHANTID   AND M.PurgeInd not in ('E','Y')
  
  
 --UPDATE M
 --SET PurgeInd='E'
 --FROM
 --DBA.CCMerchant M,
 --DBO.CCMerchant_Exclude ME
 -- WHERE
 -- M.MerchantId=ME.MERCHANTID
 -- AND M.PurgeInd IS NULL
  
  
 --qrys for merchant include 
--select PurgeInd
--from dba.ccmerchant
--where MerchantId in (select MerchantId from dbo.ccmerchant_include)
--and PurgeInd not in ('Y','N')
 
 
  update dba.CCMerchant
set PurgeInd='N'
from dba.ccmerchant
where MerchantId in (select MerchantId from dbo.ccmerchant_include)
and PurgeInd not in ('Y','N')


--select GenesisDetailIndCode
--from dba.ccmerchant
--where MerchantId in (select MerchantId from dbo.ccmerchant_include)
--and GenesisDetailIndCode not in ('397','398')

update dba.CCMerchant
set GenesisDetailIndCode='397'
where MerchantId in (select MerchantId from dbo.ccmerchant_include)
and GenesisDetailIndCode not in ('397','398')


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
