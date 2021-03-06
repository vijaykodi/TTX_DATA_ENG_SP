/****** Object:  StoredProcedure [dbo].[sp_UBSVICC_CH]    Script Date: 7/14/2015 7:39:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UBSVICC_CH]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSVICC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()
	
 /************************************************************************
	LOGGING_STARTED - BEGIN	--
************************************************************************/
SET @TransStart = getdate()
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
--Update first six and last 4
SET @TransStart = getdate()
update cchdr
set ccfirstsix=SUBSTRING(creditcardnum,1,6),
cclastfour=SUBSTRING(creditcardnum,13,4)
from dba.CCHeader cchdr
where 
cchdr.iatanum = 'UBSVICC'
AND CCHDR.TransactionDate>='2015-01-01'
and cchdr.CCFirstSix is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update cchdr first 6 last 4',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
----SINGAPORE AIRLI
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,13,10)
--select cct.ticketnum,SUBSTRING(cch.chargedesc,13,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'SINGAPOREAI 8%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,13,10)
and cct.TicketNum='GAPOREAI 8'
and cch.iatanum = 'UBSVICC'
AND CCH.TransactionDate>='2015-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='tkt num for Singapore',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/*Update ccheader cardholdername and employeeid using ccemployee*/
SET @TransStart = getdate()

update cchdr
set cchdr.employeeid = a.employeeid
--select distinct cchdr.creditcardnum,cchdr.cardholdername,cchdr.employeeid,A.EMPLOYEEID
from ttxpasql01.tman_ubs.dba.ccemployee a, ttxpasql01.tman_ubs.dba.ccheader cchdr
where a.creditcardnum = cchdr.creditcardnum
AND A.ClientCode=CCHDR.ClientCode
AND A.IATANum=CCHDR.IATANUM
and (cchdr.employeeid ='unknown' or cchdr.EmployeeId is null)
and cchdr.iatanum = 'UBSVICC'
AND CCHDR.TransactionDate>='2015-01-01'
and a.employeeid  in (select corporatestructure from dba.rollup40 where costructid = 'functional')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update cchdr Employee ID',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

checkpoint

SET @TransStart = getdate()
update cchdr
set cchdr.cardholdername = ltrim(ccempn.cardholdername)
from ttxpasql01.tman_ubs.dba.ccheader cchdr, ttxpasql01.tman_ubs.dba.ccemployee ccempn
where cchdr.creditcardnum = ccempn.creditcardnum
AND CCEMPN.ClientCode=CCHDR.ClientCode
AND CCEMPN.IATANum=CCHDR.IATANUM
and cchdr.iatanum = 'UBSVICC'
and cchdr.cardholdername is null
and ccempn.cardholdername is not null
AND CCHDR.TransactionDate>='2015-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update cchdr name using employee',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cchn
set cchn.EmployeeId = cch.EmployeeId
from dba.CCHeader cchn, dba.CCHeader cch
where cchn.CreditCardNum = cch.CreditCardNum
AND CCHN.IataNum=CCH.IATANUM
and cch.EmployeeId is not null and cchn.EmployeeId is null  
and cchn.iatanum = 'UBSVICC'
AND CCHN.TransactionDate>='2015-01-01'

 
 -------- Pad GPN to 8 characters --
update cch
set employeeid = right('00000000'+employeeid,8)
from dba.ccheader cch where iatanum = 'UBSVICC' and len(employeeid) <> 8 and employeeid <> 'Unknown'
AND TransactionDate>='2015-01-01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='GPN Padding Begin%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- Update Remarks14 with EmployeeID for backup-------------

update dba.ccheader
set remarks14 = employeeid where 
remarks14 ='UNKNOWN'
AND EmployeeId <>'UNKNOWN'
AND iatanum = 'UBSVICC'
AND TransactionDate>='2015-01-01'

update dba.ccheader
set remarks14 = employeeid where 
remarks14 Is Null
AND iatanum = 'UBSVICC'
AND TransactionDate>='2015-01-01'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='GPN mOVE%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cch
set employeeid = 'Unknown'
from dba.ccheader cch
WHERE IataNum='UBSVICC'
AND TransactionDate >='2015-01-01'
AND EmployeeId<>'Unknown'
AND employeeid not in (select corporatestructure from dba.rollup40 where costructid = 'functional')

update cch
set employeeid = 'Unknown'
from dba.ccheader cch where employeeid is NULL
AND IataNum='UBSVICC'
AND TransactionDate >='2015-01-01'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update EmployeeID in all Tables%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update transactions tables with Employee ID from CCHeader-------- 
update ccc
set ccc.employeeid = cch.employeeid
from dba.cccar ccc, dba.ccheader cch
where ccc.recordkey = cch.recordkey and ccc.iatanum = cch.iatanum and isnull(ccc.employeeid,'X') <> cch.employeeid
AND CCC.IataNum='UBSVICC'
AND CCC.TransactionDate >='2015-01-01'


update cchot
set cchot.employeeid = cch.employeeid
from dba.cchotel cchot, dba.ccheader cch
where cchot.recordkey = cch.recordkey and cchot.iatanum = cch.iatanum and isnull(cchot.employeeid,'X') <> cch.employeeid
AND CCHOT.IataNum='UBSVICC'
AND CCHOT.TransactionDate >='2015-01-01'

update cce
set cce.employeeid = cch.employeeid
from dba.ccexpense cce, dba.ccheader cch
where cce.recordkey = cch.recordkey and cce.iatanum = cch.iatanum and isnull(cce.employeeid,'X') <> cch.employeeid
AND CCE.IataNum='UBSVICC'
AND CCE.TransactionDate >='2015-01-01'

update cct
set cct.employeeid = cch.employeeid
from dba.ccticket cct, dba.ccheader cch
where cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum and isnull(cct.employeeid,'X') <> cch.employeeid
AND CCT.IataNum='UBSVICC'
AND CCT.TransactionDate >='2015-01-01'


/*Start data edits - Common Routines for all customers*/
/*PURGEIND field in core tables (dba.ccheader, dba.ccticket, dba.cchotel and dba.cccar is used to store Preferred Indicator value*/
/*Set default values for preferred indicator/purge indicator column to "N"*/

SET @TransStart = getdate()

Update ttxpasql01.TMAN_UBS.dba.cccar
    set purgeind = 'N'
  where iatanum = 'UBSVICC'
 and purgeind is null
 AND TransactionDate >='2015-01-01'
 
update ttxpasql01.TMAN_UBS.dba.cchotel
    set purgeind = 'N'
  where iatanum = 'UBSVICC'
 and purgeind is null
 AND TransactionDate >='2015-01-01'
 
 update ttxpasql01.TMAN_UBS.dba.ccticket
    set purgeind = 'N'
  where iatanum = 'UBSVICC'
and purgeind is null
AND TransactionDate >='2015-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set all new PurgeInd(PrefInd) to N',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

checkpoint

/*Air Edits*/
/*update validating carrier codes from carrier table*/
/*Process assumes carrier num in source data is correct*/
/*Requires dba.carriers table to be updated - references TypeCode and Status*/

SET @TransStart = getdate()

update cct
   set cct.valcarriercode = c.carriercode, cct.valcarriernum = c.carriernumber
   from ttxpasql01.TMAN_UBS.dba.ccticket cct, ttxpasql01.TMAN_UBS.dba.carriers c
 where cct.valcarriernum = c.carriernumber
   and cct.valcarriernum <> 999
   and cct.valcarriercode <> c.carriercode
   and c.typecode = 'A'
   and c.status = 'Active'
   and cct.iatanum = 'UBSVICC'
   AND CCT.TransactionDate >='2015-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update cctkt carrier',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

checkpoint

/*Car edits*/
/*Update car chain codes*/
/*Case statements accessing remote servers are limited to 10*/
SET @TransStart = getdate()

update cccar
set CarCompanyCode = case 
when ccm.merchantname1 like '%Ace R%' then 'AC'
when ccm.merchantname1 like '%Alamo%' then 'AL'
when ccm.merchantname1 like '%Avis%' then 'ZI'
when ccm.merchantname1 like '%Budget%' then 'ZD'
when ccm.merchantname1 like '%Dollar%' then 'ZR'
when ccm.merchantname1 like '%Enterprise%' then 'ET'
when ccm.merchantname1 like '%EUROP%' then 'EP'
when ccm.merchantname1 like '%Hertz%' then 'ZE'
when ccm.merchantname1 like '%National%' then 'ZL'
when ccm.merchantname1 like '%Payless%' then 'ZA'
when ccm.merchantname1 like '%SIXT%' then 'HS'
when ccm.merchantname1 like '%Thrifty%' then 'TC'
end
from ttxpasql01.TMAN_UBS.dba.cccar cccar, ttxpasql01.TMAN_UBS.dba.ccmerchant ccm
where cccar.merchantid = ccm.merchantid
and cccar.iatanum = 'UBSVICC'
and (cccar.carcompanycode = 'XX'
or cccar.carcompanycode is null)
AND CCCAR.TransactionDate >='2015-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update cccar company code1',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update the cardholdername to be in the correct format for CCMB and then update CCTicket, CCCar, and CCHotel with the CardHoldername where the name = '/'

update ttxpasql01.TMAN_UBS.dba.CCHeader
set CardHolderName = substring(CardHolderName,CHARINDEX(' ',CardHolderName,1)+1,40)+'/'+substring(CardHolderName,1,CHARINDEX(' ',CardHolderName)-1)
where iatanum = 'UBSVICC'
and CardHolderName not like '%/%'
and CardHolderName is not NULL
and CardHolderName not like '% % %'
and charindex(' ',CardHolderName) <> 0
AND TransactionDate >='2015-01-01'

--update ttxpasql01.TMAN_UBS.dba.CCHeader
--set CardHolderName = substring(cardholdername,dbo.AT(' ',cardholdername,2)+1,20)+'/'+ substring(cardholdername,1,DBO.AT(' ',cardholdername,2))
--where IataNum = 'UBSVICC'
--and CardHolderName not like '%/%'
--and CardHolderName is not null
--and CardHolderName like '% % %'
--and CardHolderName not like '% % % %'

--update ttxpasql01.TMAN_UBS.dba.CCHeader
--set CardHolderName = substring(cardholdername,DBO.AT(' ',cardholdername,3)+1,20)+ '/' + substring(cardholdername,1,DBO.AT(' ',cardholdername,3))
--where IataNum = 'UBSVICC'
--and CardHolderName not like '%/%'
--and CardHolderName is not null
--and CardHolderName like '% % % %'
--and CardHolderName not like '% % % % %'

--update ttxpasql01.TMAN_UBS.dba.CCHeader
--set CardHolderName = substring(cardholdername,DBO.AT(' ',cardholdername,4)+1,20)+ '/' + substring(cardholdername,1,DBO.AT(' ',cardholdername,4))
--where IataNum = 'UBSVICC'
--and CardHolderName not like '%/%'
--and CardHolderName is not null
--and CardHolderName like '% % % % %'


update cctkt
set cctkt.passengername = cchdr.cardholdername
from ttxpasql01.TMAN_UBS.dba.CCHeader cchdr, ttxpasql01.TMAN_UBS.dba.CCTicket cctkt
where cchdr.IataNum = 'UBSVICC'
and cchdr.IataNum = cctkt.IataNum
and cchdr.RecordKey = cctkt.RecordKey
and cctkt.PassengerName = '/'
AND cctkt.TransactionDate >='2015-01-01'

update cctkt
set cctkt.passengername = cchdr.cardholdername
from ttxpasql01.TMAN_UBS.dba.CCHeader cchdr, ttxpasql01.TMAN_UBS.dba.CCTicket cctkt
where cchdr.IataNum = 'UBSVICC'
and cchdr.IataNum = cctkt.IataNum
and cchdr.RecordKey = cctkt.RecordKey
and cctkt.PassengerName is null
AND cctkt.TransactionDate >='2015-01-01'

update cccar
set cccar.rentername = cchdr.cardholdername
from ttxpasql01.TMAN_UBS.dba.CCHeader cchdr, ttxpasql01.TMAN_UBS.dba.CCCar cccar
where cchdr.IataNum = 'UBSVICC'
and cchdr.IataNum = cccar.IataNum
and cchdr.RecordKey = cccar.RecordKey
and cccar.rentername = '/'
AND CCHDR.TransactionDate >='2015-01-01'

update cchtl
set cchtl.GuestName = cchdr.cardholdername
from ttxpasql01.TMAN_UBS.dba.CCHeader cchdr, ttxpasql01.TMAN_UBS.dba.CCHotel cchtl
where cchdr.IataNum = 'UBSVICC'
and cchdr.IataNum = cchtl.IataNum
and cchdr.RecordKey = cchtl.RecordKey
and cchtl.GuestName = '/'
AND CCHDR.TransactionDate >='2015-01-01'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CC Names to correct format',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--UPDATED airline Val Carrier Code WHEN NULL
update ct
set ct.valcarriercode =  
	case 
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'HAHN AIR%' then 'HR' 	
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AIRSTANA%' then 'KC'		  
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'LUXAIR%' then 'LG'  
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'HELI AIR%' then 'YO' 
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'LAN AIR%' then 'LA'	
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'DARWIN%' then 'F7'
    	when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'GERMANW%' then '4U'
    	else valcarriercode end


from dba.ccticket ct, dba.ccheader ch 
where ct.recordkey = ch.recordkey
and ch.IndustryCode='01'
and ct.ValCarrierCode is null
AND CT.IATANUM='UBSVICC'
AND CT.TRANSACTIONDATE>='2015-01-01'

--UPDATE RAIL CARRIER CODE
update ct
set ct.valcarriercode =  
	case 
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AMTRAK%' then '2V' 	
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'EUROSTAR%' then '9F'		  
    	else valcarriercode end


from dba.ccticket ct, dba.ccheader ch 
where ct.recordkey = ch.recordkey
and ch.IndustryCode='02'
and ct.ValCarrierCode is null
AND CT.IATANUM='UBSVICC'
AND CT.TRANSACTIONDATE>='2015-01-01'


--CC MasterID
--Data Enhancement Automation HNN Queries
Declare @HNNCCBeginDate datetime
Declare @HNNCCEndDate datetime

Select @HNNCCBeginDate = Min(transactiondate),@HNNCCEndDate = Max(transactiondate)
from dba.CCHotel cht, dba.ccmerchant cm
Where cm.MasterId is NULL
AND cht.IataNum = 'UBSVICC'
and cht.transactiondate >'2015-01-31'
and cht.merchantid = cm.merchantid


EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'UBSVI345',
@Enhancement = 'HNN',
@Client = 'UBS',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNCCBeginDate,
@EndDate = @HNNCCEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'card',
@TextParam2 = 'ttxpaSQL01',
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


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure End %',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--Exec dbo.sp_UBS_Matchback - CK W LISA ON THIS
SET @TransStart = getdate()
 /************************************************************************
	LOGGING_ENDED - BEGIN	--
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 


GO
