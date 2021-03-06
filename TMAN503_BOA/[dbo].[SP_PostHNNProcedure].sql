/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:50:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN




/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[SP_PostHNNProcedure]
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



--Creater: Nina Lutz
--Create Date: 2/18/2013

----- Added Car and Hotel Dupes as we found that production was not getting updated correctly due to dates
----- Added on 1/23/15 by Nina per case #00055500


-------- Update Car dupes -------------------------Nina 2/19/13
update dba.CAR
set VoidReasonType = VoidInd
where IataNum in ('BOFAAX','BOFAHRG')

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM in ('BOFAAX','BOFAHRG')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM in ('BOFAAX','BOFAHRG')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey = Second.Recordkey
and First.ClientCode = Second.ClientCode
and first.CarSegNum < Second.CarSegNum
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.car First , dba.car Second
where First.IATANUM in ('BOFAAX','BOFAHRG')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and First.FirstName = Second.FirstName
and First.Lastname = second.Lastname
and first.CarChainCode = Second.CarChainCode
and First.CarCityName = Second.CarCityName
and Second.voidind = 'N'
and First.voidreasontype <> 'D'

Update carn
Set voidind = 'D'
from dba.car carn ,dba.car cary, dba.InvoiceDetail IDN, dba.invoicedetail IDY
where carn.IATANUM in ('BOFAAX','BOFAHRG')
and cary.IataNum in ('BOFAAX','BOFAHRG')
and carn.RecordKey = IDn.RecordKey
and carn.IataNum = idn.IataNum
and carn.SeqNum = idn.SeqNum
and cary.IataNum in ('BOFAAX','BOFAHRG')
and cary.RecordKey = IDy.RecordKey
and cary.IataNum = idy.IataNum
and cary.SeqNum = idy.SeqNum
and idy.ExchangeInd = 'Y'
and idy.OrigExchTktNum = idn.DocumentNumber
and idn.ExchangeInd = 'N'


-------- Update hotel dupes -------------------------Nina 2/19/13
update dba.hotel
set VoidReasonType = VoidInd
where IataNum in ('BOFAAX','BOFAHRG')

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM in ('BOFAAX','BOFAHRG')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM in ('BOFAAX','BOFAHRG')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum
and First.IssueDate <= Second.Issuedate
and First.Recordkey = Second.Recordkey
and First.ClientCode = Second.ClientCode
and first.htlSegNum < Second.htlSegNum
--and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidreasontype <> 'D'
and Second.voidind = 'N'

Update First
Set voidind = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM in ('BOFAAX','BOFAHRG')
and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator
and First.IssueDate <= Second.Issuedate
and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and First.FirstName = Second.FirstName
and First.Lastname = second.Lastname
and first.HtlChainCode = Second.HtlChainCode
and first.HtlPropertyName = second.HtlPropertyName
and First.HtlCityName = Second.HtlCityName
and Second.voidind = 'N'
and First.voidreasontype <> 'D'

Update hoteln
Set voidind = 'D'
from dba.hotel hoteln ,dba.hotel hotely, dba.InvoiceDetail IDN, dba.invoicedetail IDY
where hoteln.IATANUM in ('BOFAAX','BOFAHRG')
and hotely.IataNum in ('BOFAAX','BOFAHRG')
and hoteln.RecordKey = IDn.RecordKey
and hoteln.IataNum = idn.IataNum
and hoteln.SeqNum = idn.SeqNum
and hotely.IataNum in ('BOFAAX','BOFAHRG')
and hotely.RecordKey = IDy.RecordKey
and hotely.IataNum = idy.IataNum
and hotely.SeqNum = idy.SeqNum
and idy.ExchangeInd = 'Y'
and idy.OrigExchTktNum = idn.DocumentNumber
and idn.ExchangeInd = 'N'


------Flag preferred hotels
update dba.hotel
set prefhtlind = 'N',
HtlCompareRate2 = 0
where checkindate between '2014-01-01' and '2015-12-31'
and prefhtlind is null 

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S1_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S2_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S3_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

update htl
set htl.prefhtlind ='Y',
htl.HtlCompareRate2 = round(pref.LRA_S4_RT1_SGL*curr.baseunitspercurr,2)
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref, dba.currency curr
where htl.checkindate between '2014-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr
and htl.HtlCompareRate2 = 0

--Per bank, the rate at the Hyatt Times Square changed to $410 starting on 10/23/14
--Added on 11/10/14 by Nina per case #00049407
update dba.Hotel
set HtlCompareRate2 = 410
where CheckinDate between '2014-10-23' and '2015-12-31'
and HtlPropertyName like '%HYATT%TIMES%'
and HtlCompareRate2 <> 410
and PrefHtlInd = 'Y'



--Update preferred hotels in cc data
--Added on 8/18/14 by Nina per case #00043356

update dba.cchotel
set noshowind = 'N'
where noshowind is null

update dba.cchotel
set othercharges = 0

update cchtl
set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.othercharges = 0

update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.othercharges = 0

update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.othercharges = 0

update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.othercharges = 0

--Per bank, the rate at the Hyatt Times Square changed to $410 starting on 10/23/14
--Added on 11/10/14 by Nina per case #00049407
update cchtl
set cchtl.othercharges = 410
from dba.CCHotel cchtl, dba.CCMerchant ccm
where cchtl.NoShowInd = 'Y'
and cchtl.ArrivalDate between '2014-10-23' and '2015-12-31'
and cchtl.OtherCharges <> 410
and cchtl.MerchantId = ccm.MerchantId
and ccm.MerchantName1 like '%HYATT%TIMES%'

END




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
