/****** Object:  StoredProcedure [dbo].[sp_FISCCAX_All]    Script Date: 7/14/2015 8:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_FISCCAX_All]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'FISCCAX'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='FISCCAX SP Start% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

-------- Update Employee Numbers ---- LOC/7/5/2013
-- Backup of original value--
update dba.ccheader
set remarks1 = employeeid where remarks1 is null


update cchn
set cchn.EmployeeId = cch.EmployeeId
from dba.CCHeader cchn, dba.CCHeader cch
where cchn.CreditCardNum = cch.CreditCardNum
and cch.EmployeeId is not null
and cchn.EmployeeId is null
 and cch.iatanum = 'FISCCAX'
 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Employee Num% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

 
 
 ---- Format to match hierarchy ------
 update cch set employeeid = right('0000000'+employeeid,7)
 from dba.ccheader cch
 where iatanum = 'FISCCAX' and len(employeeid) < 7  and employeeid <> 'Unknown'

 update cch set employeeid = 'E'+employeeid
 from dba.ccheader cch
 where iatanum = 'FISCCAX' and len(employeeid) < 8  and employeeid not like'E%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Format to match hierarchy% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


-------- Update transactions tables with Employee ID from CCHeader-------- LOC/7/5/2013
update ccc
set ccc.employeeid = cch.employeeid
from dba.cccar ccc, dba.ccheader cch
where ccc.recordkey = cch.recordkey and ccc.iatanum = cch.iatanum and isnull(ccc.employeeid,'X') <> cch.employeeid

update cchot
set cchot.employeeid = cch.employeeid
from dba.cchotel cchot, dba.ccheader cch
where cchot.recordkey = cch.recordkey and cchot.iatanum = cch.iatanum and isnull(cchot.employeeid,'X') <> cch.employeeid

update cce
set cce.employeeid = cch.employeeid
from dba.ccexpense cce, dba.ccheader cch
where cce.recordkey = cch.recordkey and cce.iatanum = cch.iatanum and isnull(cce.employeeid,'X') <> cch.employeeid

update cct
set cct.employeeid = cch.employeeid
from dba.ccticket cct, dba.ccheader cch
where cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum and isnull(cct.employeeid,'X') <> cch.employeeid

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update tables w/EmpID from CCHDR% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


-------- Manual CC matching as CC Matchback does not always match ---- LOC/7/3/2013

Update cct
set matchedrecordkey = i.recordkey, matchediatanum = i.iatanum, matchedclientcode = i.clientcode, 
matchedseqnum = i.seqnum
from dba.invoicedetail i, dba.ccticket cct
where i.documentnumber = cct.ticketnum
and cct.matchedrecordkey is null and vendortype in ('bsp','nonbsp')
and substring(lastname,1,5) like substring(passengername,1,5)

update cch
set matchedind = 'Y', cch.matchedrecordkey = cct.matchedrecordkey, cch.matchediatanum = cct.matchediatanum,
cch.matchedclientcode = cct.matchedclientcode
from dba.ccticket cct, dba.ccheader cch
where cct.recordkey = cch.recordkey and cct.transactiondate = cct.transactiondate
and cct.matchedrecordkey is not null and cch.matchedrecordkey is null

Update i
set matchedind = 'Y'
from dba.invoicedetail i, dba.ccticket cct
where i.documentnumber = cct.ticketnum
and cct.matchedrecordkey is null and vendortype in ('bsp','nonbsp')
and substring(lastname,1,5) like substring(passengername,1,5)
and cct.matchedrecordkey = i.recordkey

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Manual CCMB% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()



-------- Update Remarks 5 -- Set value = InReport where employee ID is in Rollup40 or there was a match to 
-------- a Agency Record -- If not in Rollup40 then set to NotInReport --- this will be used in the
-------- CC Only Profile so that only records show that are in the Hierarchy and/or agency data
-------- This will give a more true picture in the leakage reports -- LOC/9/25/2013

update dba.ccheader
set  remarks5 = 'InReport' 
where ((employeeid in (select corporatestructure from dba.rollup40 where costructid = 'HR'))
or (matchedrecordkey is not null))

update dba.ccheader
set  remarks5 = 'NotInReport' 
where employeeid Not in (select corporatestructure from dba.rollup40 where costructid = 'HR')
and remarks5 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RMKS5 from CCHDR% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

--make all unknown ticket issuer to the merchant name per case #32297 //TT
update CCTKT
set CCTKT.TicketIssuer = substring(CCMERCHANT.MerchantName1,1,37)
FROM dba.CCHeader CCHDR
 INNER JOIN dba.CCMerchant CCMERCHANT ON ( CCHDR.MerchantId = CCMERCHANT.MerchantId ) 
 INNER JOIN dba.CCTicket CCTKT ON ( CCHDR.RecordKey = CCTKT.RecordKey AND CCHDR.IataNum = CCTKT.IataNum AND CCTKT.MerchantId = CCMERCHANT.MerchantId ) 
where 1=1
AND CCHDR.importdate BETWEEN Getdate()-1 and getdate()
AND CCMERCHANT.GenesisMajorIndCode = '12'
AND CCTKT.AncillaryFeeInd IS NULL
AND CCTKT.MatchedRecordKey IS NULL
and CCTKT.TicketIssuer = 'unknown'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set Unknown TKT Issuer to Merchant% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


------Update ValCarrierCode ---------------------------------------------

update dba.ccticket set valcarriercode = carriercode
from dba.ccticket, dba.carriers
where valcarriernum = carriernumber and carriernumber not in ('00','9999','0','99','999')
and valcarriercode is null and typecode = 'a' and status = 'a'
and carriercode in (substring(carrierstr,1,2),substring(carrierstr,4,2),substring(carrierstr,7,2)
,substring(carrierstr,10,2))


update dba.ccticket
set valcarriercode = 
case when carrierstr like 'CA%' then 'CA' when carrierstr like 'VX%' then 'VX'
when carrierstr like 'QF%' then 'QF' when carrierstr like 'BV%' then 'BV'
when carrierstr like '41%' then 'QF'  when carrierstr like 'LH%' then 'LH'
when carrierstr like 'CO%' then 'CO' when carrierstr like 'DL%' then 'DL' 
when carrierstr like 'AA%' then 'AA' when carrierstr like 'UA%' then 'UA' 
when carrierstr like 'WN%' then 'WN' else valcarriercode end
where valcarriercode is null

update ct
set ct.valcarriercode = case when ct.valcarriercode is null 
and (ch.chargedesc like '%AIRASIA%' or ch.CompanyName like '%AIRASIA%') then 'AK'
when ct.valcarriercode is null  and (ch.chargedesc like '%ASIANA%' or ch.CompanyName like '%ASIANA%') then 'OZ'
when ct.valcarriercode is null  and (ch.chargedesc like '%AUSTRIAN%' or ch.CompanyName like '%AUSTRIAN%') then 'OS'
when ct.valcarriercode is null  and (ch.chargedesc like '%AVIANCA%' or ch.CompanyName like '%AVIANCA%') then 'AV'
when ct.valcarriercode is null  and (ch.chargedesc like '%BRITISH AIR%' or ch.CompanyName like '%BRITISH AIR%') then 'BA'
when ct.valcarriercode is null  and (ch.chargedesc like '%BULGARIA AI%' or ch.CompanyName like '%BULGARIA AI%') then 'FB'
when ct.valcarriercode is null  and (ch.chargedesc like '%CATHAY PA%' or ch.CompanyName like '%CATHAY PA%') then 'CX'
when ct.valcarriercode is null  and (ch.chargedesc like '%CONDOR FLU%' or ch.CompanyName like '%CONDOR FLU%') then 'DE'
when ct.valcarriercode is null  and (ch.chargedesc like '%EASYJET%' or ch.CompanyName like '%EASYJET%') then 'U2'
when ct.valcarriercode is null  and (ch.chargedesc like '%EGYPTAIR%' or ch.CompanyName like '%EGYPTAIR%') then 'MS'
when ct.valcarriercode is null  and (ch.chargedesc like '%EUROWINGS%' or ch.CompanyName like '%EUROWINGS%') then 'EW'
when ct.valcarriercode is null  and (ch.chargedesc like '%JET AIRW%' or ch.CompanyName like '%JET AIRW%') then '9W'
when ct.valcarriercode is null  and (ch.chargedesc like '%GERMANWINGS%' or ch.CompanyName like '%GERMANWINGS%') then '4U'
when ct.valcarriercode is null  and (ch.chargedesc like '%FLYBE%' or ch.CompanyName like '%FLYBE%') then 'BE'
when ct.valcarriercode is null  and (ch.chargedesc like '%KOREA%' or ch.CompanyName like '%KOREA%') then 'KE'
when ct.valcarriercode is null  and (ch.chargedesc like '%JET2%' or ch.CompanyName like '%JET2%') then 'LS'
when ct.valcarriercode is null  and (ch.chargedesc like '%COPA%' or ch.CompanyName like '%COPA%') then 'CM'
when ct.valcarriercode is null  and (ch.chargedesc like '%JETSTAR%' or ch.CompanyName like '%JETSTAR%') then 'JQ'
when ct.valcarriercode is null  and (ch.chargedesc like '%WEST JET%' or ch.CompanyName like '%WEST JET%') then 'WS'
when ct.valcarriercode is null  and (ch.chargedesc like '%WESTJET%' or ch.CompanyName like '%WESTJET%') then 'WS'
when ct.valcarriercode is null  and (ch.chargedesc like '%VARIG%' or ch.CompanyName like '%VARIG%') then 'RG'
when ct.valcarriercode is null  and (ch.chargedesc like '%COPA%' or ch.CompanyName like '%COPA%') then 'CM'
when ct.valcarriercode is null  and ch.chargedesc like '%VIRGIN%' and ct.valcarriernum = 856 then 'DJ'
when ct.valcarriercode is null  and ch.chargedesc like '%AIGL%' and ct.valcarriernum = 439 then 'ZI'
when ct.valcarriercode is null  and ch.chargedesc like '%BABOO%' and ct.valcarriernum = 33 then 'F7'
when ct.valcarriercode is null  and ch.chargedesc like '%QANTAS%' then 'QF'
when ct.valcarriercode is null  and ch.chargedesc like '%S A S%' then 'SK'
when ct.valcarriercode is null  and ch.chargedesc like '%SAS%' then 'SK'
when ct.valcarriercode is null  and ch.chargedesc like '%SINGAPORE%' then 'SQ'
when ct.valcarriercode is null  and ch.chargedesc like '%MALAYSIA%' then 'MH'
when ct.valcarriercode is null  and ch.chargedesc like '%SUN COUNT%' then 'SY'
when ct.valcarriercode is null  and ch.chargedesc like '%AIR BERLI%' then 'AB'
when ct.valcarriercode is null  and ch.chargedesc like '%AIR CHINA%' then 'CA'
else ct.valcarriercode
end
from dba.ccticket ct, dba.ccheader ch where ct.recordkey = ch.recordkey


update dba.ccticket set valcarriercode = carriercode
from dba.ccticket, dba.carriers
where valcarriernum = carriernumber and carriernumber not in ('00','9999','0','99','999')
and valcarriercode is null and typecode = 'a' and status = 'a'
and carrierstr is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update ValCarrierCode% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


--Update ccmerchant with the 2 letter country code instead of using the 3 number ISO country code....10/4/11 NL
update merch
set merch.merchantctrycode = iso.countrycode
from dba.ccmerchant merch,dba.ccisocountry iso
where merch.merchantctrycode = iso.isocountrynum

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CountryCode% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


--Ancillary fee updates per Jim on 02/27/2013
update dba.ccticket
set ancillaryfeeind = case when  ticketissuer like '%1ST BAG FEE%' and ancillaryfeeind is null then  1
when ticketissuer like '%BAGGAGE FEE%' and ancillaryfeeind is null then 1
when ticketissuer like '%2ND BAG FEE%' and ancillaryfeeind is null then 2
when ticketissuer like '%3RD BAG FEE%' and ancillaryfeeind is null then 3
when ticketissuer like '%4TH BAG FEE%' and ancillaryfeeind is null then 4
when ticketissuer like '%5TH BAG FEE%' and ancillaryfeeind is null then 5
when ticketissuer like '%6TH BAG FEE%' and ancillaryfeeind is null then 6
when ticketissuer like '%-INFLT%' and ancillaryfeeind is null then 16
when ticketissuer like '%*INFLT%' and ancillaryfeeind is null then 16
when ticketissuer like '%EXCS BAG FEE%' and ancillaryfeeind is null then 7
when ticketissuer like '%OVERWEIGHT%' and ancillaryfeeind is null then 8
when ticketissuer like '%OVERSIZE%' and ancillaryfeeind is null then 9
when ticketissuer like '%EXCS BAG FEE%' and ancillaryfeeind is null then 7
when ticketissuer like '%SPORT EQUIP%' and ancillaryfeeind is null then 10
when ticketissuer like '%EXCS BAG FEE%' and ancillaryfeeind is null then 7
when ticketissuer like '%UA AWRD ACCEL%' and ancillaryfeeind is null then 7
when ticketissuer like '%UA ECNMY PLUS%' and ancillaryfeeind is null then 7
when ticketissuer like '%UA PREM CABIN%' and ancillaryfeeind is null then 7
when ticketissuer like '%UA PREM LINE%' and ancillaryfeeind is null then 7
when ticketissuer like '%%UA MPI UPGRD%%' and ancillaryfeeind is null then 7
when ticketissuer like '%%SKYMILES FEE%%' and ancillaryfeeind is null then 7
when ticketissuer like '%%EASY CHECK IN%%' and ancillaryfeeind is null then 7
when ticketissuer = 'KLM LOUNGE ACCESS' and ancillaryfeeind is null then 7
when ticketissuer like '%UNITED-  UNITED.COM AWARD%' and ancillaryfeeind is null then 18
when ticketissuer like '%UNITED-  UNITED CONNECTIO%' and ancillaryfeeind is null then 7
when ticketissuer like '%UNITED-  UNITED.COM CUSTO%' and ancillaryfeeind is null then 21
when ticketissuer like '%UNITED-  WIPRO BPO PHILIP%' and ancillaryfeeind is null then 20
when ticketissuer like '%UNITED-  WIPRO SPECTRAMIN%' and ancillaryfeeind is null then 20
when ticketissuer like '%UNITED-  TICKET SVC CENTE%' and ancillaryfeeind is null then 21
when ticketissuer like '%MPI BOOK FEE%' and ancillaryfeeind is null then 30
when ticketissuer like '%RES BOOK FEE%' and ancillaryfeeind is null then 30
when ticketissuer like '%UA TKTG FEE%' and ancillaryfeeind is null then 30
when ticketissuer like '%UA UNCONF CHG%' and ancillaryfeeind is null then 30
when ticketissuer like '%UNITED-  UNITED.COM%' and ancillaryfeeind is null then 30
when ticketissuer like '%CONFIRM CHG$%' and ancillaryfeeind is null then 31
when ticketissuer like '%CNCL/PNLTY%' and ancillaryfeeind is null then 32
when ticketissuer like '%MUA CO PAY TI%' and ancillaryfeeind is null then 50
when ticketissuer like '%UA MISC FEE%' and ancillaryfeeind is null then 50
when ticketissuer like '%UNITED.COM-SWIT%' and ancillaryfeeind is null then 50
when passengername like '%first che%' and ancillaryfeeind is null then 1
when passengername like '%/SECOND CH%' and ancillaryfeeind is null then 2
when passengername like '%/THIRD CH%' and ancillaryfeeind is null then 3
when passengername like '%/FOURTH CH%' and ancillaryfeeind is null then 4
when passengername like '%/FIFTH CH%' and ancillaryfeeind is null then 5
when passengername like '%/SIXTH CH%' and ancillaryfeeind is null then 6
when passengername like '%EXCESS BA%' and ancillaryfeeind is null then 7
when passengername like '%/OVERWEIGH%' and ancillaryfeeind is null then 8
when passengername like '%/OVERSIZED%' and ancillaryfeeind is null then 9
when passengername like '%SPORT EQU%' and ancillaryfeeind is null then 10
when passengername like '%/SPORTING%' and ancillaryfeeind is null then 10
when passengername like '%/EXTRA LEG%' and ancillaryfeeind is null then 12
when passengername like '%/FIRST CLA%' and ancillaryfeeind is null then 13
when passengername like '%/ONEPASS R%' and ancillaryfeeind is null then 15
when passengername like '%/REWARD BO%' and ancillaryfeeind is null then 15
when passengername like '%/REWARD CH%' and ancillaryfeeind is null then 15
when passengername like '%/INFLIGHT%' and ancillaryfeeind is null then 16
when passengername like '%/LIQUOR%' and ancillaryfeeind is null then 16
when passengername like '%/SPECIAL S%' and ancillaryfeeind is null then 21
when passengername like '%/RESERVATI%' and ancillaryfeeind is null then 30
when passengername like '%/TICKETING%' and ancillaryfeeind is null then 30
when passengername like '%/CHANGE FE%' and ancillaryfeeind is null then 31
when passengername like '%/CHANGE PE%' and ancillaryfeeind is null then 32
when passengername like '%/PAST DATE%' and ancillaryfeeind is null then 31
when passengername like '%/P-CLUB DA%' and ancillaryfeeind is null then 60
when passengername like '%P-CLUB%' and ancillaryfeeind is null then 60
end


update dba.ccticket
set ancillaryfeeind = 1
where routing like 'XAA%' and routing like '%XAE%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 15
where routing like 'XAA%' and routing like '%XUP%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 60
where routing like 'XAA%' and routing like '%XAF%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 50
where routing like 'XAA%' and routing like '%XCA%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 30
where routing like 'XAA%' and routing like '%XOT%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 16
where routing like 'XAA%' and routing like '%XDF%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 30
where routing like 'XAA%' and routing like '%XAO%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 50
where routing like 'XAA%' and routing like '%XAA%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 21
where routing like 'XAA%' and routing like '%XTD%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 25
where routing like 'XAA%' and routing like '%XPC%' and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 31
where routing like 'XAA%' and routing like '%XPE%' and ancillaryfeeind is null and matchedrecordkey is null

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GATWICK S BAGGAGE%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0QYBAG%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0R2BAG%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0R6BAG%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0R7BAG%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%LHR T3- BAGGAGE%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%LHR T4 BAGGAGE%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%T1  BAGGAGE RECLAIM%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%T1 BAGGAGE RECLAIM%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%T3- BAGGAGE BELT%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (1)%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 2
WHERE MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (2)%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 7
WHERE MCHRGDESC1 LIKE '%EXCESS BAGGAGE CO%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%ALASKA AIR IN FLIGHT%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%FLY DUBAI-INFLIGHT%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%IN FLIGHT US AIRWAYS%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%INFLIGHT FOOD PURCHASE%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 8
WHERE MCHRGDESC1 LIKE '%KLM OVERBAGAGEKAS%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%AIRCELL GOGO INFLIGHT%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%AIRCELL*GOGO INFLIGHT%' AND ANCILLARYFEEIND IS NULL 

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%INFLIGHT US AIRWAYSQPS%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%SWA INFLIGHT WIFI%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%TRLPAY  GOGO INFLIGHT%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 55
WHERE MCHRGDESC1 LIKE '%AIRPORTBAGS.COM%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 60
WHERE MCHRGDESC1 LIKE '%AA ADMIRAL%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 60
WHERE MCHRGDESC1 LIKE '%AA ADMRL%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 60
WHERE MCHRGDESC1 LIKE '%ADMIRALS CLUB%' AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 70
WHERE MCHRGDESC1 LIKE '%INFLIGHT MEDICAL%' AND ANCILLARYFEEIND IS NULL

--*******Added 3/31/2010*******
update dba.ccticket
set ancillaryfeeind = 1
where ancillaryfeeind is null
and substring(ticketnum,1,2) in ('29','26') and valcarriercode = 'CO'
and ticketamt in (23,25) and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where ancillaryfeeind is null and substring(ticketnum,1,2) in ('29','26') and valcarriercode = 'CO'
and ticketamt in (27,30,32,35,45,50,9,10) and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AA' and ticketamt in (25)
and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AA' and ticketamt in (35,30,50,60)
and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AA' and ticketamt in (100)
and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AA' and ticketamt in (25) and substring(ticketnum,1,2) in ('26')
and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AA' and ticketamt in (35,30,50,60)
and substring(ticketnum,1,2) in ('26') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AA' and ticketamt in (100) and substring(ticketnum,1,2) in ('26')
and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 16
where valcarriercode = 'AA' and ticketamt in (3.29,5.29,6,4.49,8.29,10,7) and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'DL' and ticketamt in (23,25,32,35,27,30,50,55) 
and substring(ticketnum,1,2) IN ('25','29','82') and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'DL' and ticketamt in (32,35,27,30,50,55)
and substring(ticketnum,1,2) IN ('25','29','82') and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'UA' and ticketamt in (25)
and substring(ticketnum,1,2) IN ('40','46','45') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'UA' and ticketamt in (35,50)
and substring(ticketnum,1,2) IN ('40','46','45') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'US' and ticketamt in (23,25) and substring(ticketnum,1,2) IN ('24')
and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'US' and ticketamt in (35,50) and substring(ticketnum,1,2) IN ('24')
and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'WN' and ticketamt in (50,110) and substring(ticketnum,1,2) IN ('26')
and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 17
where valcarriercode = 'WN' and ticketamt in (10) and substring(ticketnum,1,2) IN ('06')
and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'LH' and ticketamt in (50)
and substring(ticketnum,1,2) IN ('16','26','27') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'LH' and ticketamt in (150)
and substring(ticketnum,1,2) IN ('16','26','27') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'BA' and ((ticketamt in (40,50,48,60) and billedcurrcode = 'USD'
and matchedrecordkey is null OR ticketamt in (28,35,32,40) and billedcurrcode = 'GBP'))
and substring(ticketnum,1,2) IN ('26','90') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'BA' and ((ticketamt in (112,140) and billedcurrcode = 'USD'
and matchedrecordkey is null OR ticketamt in (72,90) and billedcurrcode = 'GBP'))
and substring(ticketnum,1,2) IN ('26','90') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'SQ'
and ticketamt in (8,12,22,50,15,30,55,40,60,50,109,150,84,110,121,117,160,94,115,130,129,149,165,128)
and substring(ticketnum,1,2) IN ('16','18') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AF' and ticketamt in (55,100)
and substring(ticketnum,1,2) in ('82','16') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AF' and ticketamt in (200)
and substring(ticketnum,1,2) in ('82','16') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AS' and ticketamt in (20)
and substring(ticketnum,1,2) in ('21','16') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 4
where valcarriercode = 'AS' and ticketamt in (50)
and substring(ticketnum,1,2) in ('21','16') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AC' and ticketamt in (30,50,75,100,225)
and substring(ticketnum,1,2) in ('20','51') and matchedrecordkey is null and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'LX' and ticketamt in (250,150,50,120,450)
and matchedrecordkey is null and ancillaryfeeind is null

update ct
set ct.ancillaryfeeind = 16
from dba.ccheader ch,dba.ccticket ct
where chargedesc like '%inflight%' and ch.recordkey = ct.recordkey
and ct.ancillaryfeeind is null and ct.matchedrecordkey is null

update ce
set ce.ancillaryfeeind = 16
from dba.ccheader ch,dba.ccexpense ce
where chargedesc like '%inflight%' and ch.recordkey = ce.recordkey and ce.ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer in ('AIR NEW ZEALAND EXCESS BAG WL7', 'AIR NEW ZEALAND EXCESS BAG CH8', 'MAS EXCESS BAGGAGE - DOME'
, 'VIRGIN ATLANTIC CC ANCILLARIES', 'AIR NEW ZEALAND EXCESS BAG AK7') and matchedrecordkey is null and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 16
where ticketissuer in ('JETBLUE BUY ON BOARD', 'AMTRAK ONBOARD/ BOS 0049', 'ALASKA AIRLINES IN FLIGHT'
, 'FRONTIER ON BOARD SALES', 'AMTRAK ONBOARD/ PDX  WASHINGTON', 'AMTRAK ONBOARD/ PHL  WASHINGTON'
, 'KOREAN AIR DUTY-FREE (  )', 'WESTJET-BUY ON BOARD', 'ONBOARD SALES', 'AMTRAK ONBOARD/ SAC  WASHINGTON'
, 'EVA AIRWAYS IN FLIGHT DUTY FEE', 'AMTRAK ONBOARD/ NYP  WASHINGTON', 'EL AL DUTY FREE', 'SOUTHWEST ON BOARD'
, 'AMTRAK ONBOARD/ HAR  WASHINGTON', 'AMTRAK ONBOARD/ RVR  WASHINGTON', 'AMTRAK ONBOARD/ WAS  WASHINGTON'
, 'AMTRAK ONBOARD/ OAK  WASHINGTON', 'KOREAN AIR DUTY-FREE ($)') and matchedrecordkey is null and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer in ('AIR DO INTERNET', 'SOUTHWEST ONBOARD INTERNT', 'AIR FRANCE USA INTERNET') and matchedrecordkey is null and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 60
where ticketissuer in ('ADMIRAL CLUB', 'US AIRWAYS CLUB', 'CONTINENTAL PRESIDENT CLU', 'UNITED RED CARPET CLUB',
'THE LOUNGE VIRGIN BLUE')
and matchedrecordkey is null and ancillaryfeeind is null

update ce
set ancillaryfeeind = 16
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('AMTRAK - CAP CORR CAFE', 'AMTRAK - SURFLINER CAFE'
, 'AMTRAK CASCADES CAFE', 'AMTRAK FOOD & BEVERAGE', 'AMTRAK-CAFE', 'AMTRAK-DINING CAR', 'AMTRAK-EAST CAFE', 'AMTRAK-MIDWEST CAFE', 'AMTRAK-NORTHEAST CAFE'
, 'AMTRAK-SAN JOAQUINS CAFE') and ancillaryfeeind is null

update ce
set ancillaryfeeind = 60
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('AA ADMIRAL CLUB AUS', 'AA ADMIRAL CLUB LAX'
, 'AA ADMIRAL CLUB LGA D3', 'AA ADMIRALS CLUB MIAMI D', 'AIR CANADA CLUB', 'AMERICAN EXPRESS PLATINUM LOUNGE') and ancillaryfeeind is null

update ce
set ancillaryfeeind = 20
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('AIRCELL-ABS') and ancillaryfeeind is null

update ce
set ancillaryfeeind = 17
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('BAA ADVANCE') and ancillaryfeeind is null

update ce
set ancillaryfeeind = 16
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('ALPHA FLIGHT SERVICES') and ancillaryfeeind is null

update ce
set ancillaryfeeind = 16
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('DFASS CANADA COMPANY') and mchrgdesc1 like '%air canada on board%'
and ancillaryfeeind is null

update ce
set ancillaryfeeind = 15
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('DELTAMILES BY POINTS') and ancillaryfeeind is null

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 2
WHERE TicketIssuer LIKE '%extra baggage%' AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE TicketIssuer LIKE '%excess bag%' AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE TicketIssuer LIKE '%VIRGIN ATLANTIC XX ANCILLARIES%' AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE TicketIssuer LIKE '%IN FLIGHT%' OR TicketIssuer LIKE '%INFLIGHT%' OR TicketIssuer LIKE '%ONBOARD%' OR TicketIssuer LIKE '%ON BOARD%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE TicketIssuer LIKE '%DUTY FREE%' OR TicketIssuer LIKE '%DUTY-FREE%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE TicketIssuer LIKE '%KLM OPTIONAL SERVICES%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 60
WHERE TicketIssuer LIKE '%ADMIRALS CLUB%' OR TicketIssuer LIKE '%PRESIDENT CLU%' OR TicketIssuer LIKE '%CARPET CLUB%' OR TicketIssuer LIKE '%ADMIRAL CLUB%'
	OR TicketIssuer LIKE '%THE LOUNGE VIRGIN%' OR TicketIssuer LIKE '%US AIRWAYS CLUB%' OR TicketIssuer LIKE '%VIP LOUNGE%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 1
WHERE PassengerName LIKE '%/FIRST CHE%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 2
WHERE PassengerName LIKE '%/SECOND%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE PassengerName LIKE '%/EXCESS%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL 
UPDATE DBA.CCTicket
SET AncillaryFeeInd = 8
WHERE PassengerName LIKE '%/OVERWEIGH%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 11
WHERE PassengerName LIKE '%/SPECIAL%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 13
WHERE PassengerName LIKE '%/FIRST CLA%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 14
WHERE PassengerName LIKE '%/EXT ST%' OR PassengerName LIKE '%/EXTRA SEAT%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 15
WHERE PassengerName LIKE '%ONEPASS%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE PassengerName LIKE '%/HEADSET%' OR PassengerName LIKE '%/INFLIGHT%' OR PassengerName LIKE '%/LIQUOR%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 18
WHERE PassengerName LIKE '%/EXTRA LEG%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 30
WHERE PassengerName LIKE '%/FARELOCK%' OR PassengerName LIKE '%/FEE' OR PassengerName LIKE '%/REFUND%' OR PassengerName LIKE '%FEE.%' OR PassengerName LIKE '%KIOSK.%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 31
WHERE PassengerName LIKE '%/CHANGE PR%' OR PassengerName LIKE '%/SAME DAY%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 60
WHERE PassengerName LIKE '%P-CLUB%'  AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 19
WHERE PassengerName = 'MISC' OR PassengerName = 'MISceLLaNeOUS' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

update dba.ccheader
set ancillaryfeeind = 1
where (( chargedesc like '%1ST BAG FEE%' OR ChargeDesc like '%baggage fee%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 60
where (( chargedesc like '%ADMIRALS CLUB%' OR ChargeDesc like '%SKY TEAM LOUNGE%' OR ChargeDesc like '%REDCARPETCLUB%'
OR ChargeDesc like '%US AIRWAYS CLUB%' OR ChargeDesc like '%ALASKA AIR BOARDRM%' OR ChargeDesc like '%-BOARDROOM%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 16
where (( chargedesc like '%ALASKA AIR CO STORE%' OR ChargeDesc like '%IN FLIGHT%' OR ChargeDesc like '%ALASKA AIRLINE ONBOA%'
OR ChargeDesc like '%ONBOARD%' OR ChargeDesc like '%IN-FLIGHT%' OR ChargeDesc like '%DUTY FREE%'
OR ChargeDesc like '%SOUTHWESTAIR*INFLIGH%' OR ChargeDesc like '%*INFLT%' OR ChargeDesc like '%WESTJET BUY ON BOARD%'
OR ChargeDesc like '%PURCHASE ON JETBLUE%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 12
where (( chargedesc like '%ALASKA AIRLINES SEAT%' OR chargedesc like '%ECNMY PLUS%' OR chargedesc like '%ECONOMYPLUS%' 
OR chargedesc like '%ECONOMY PLUS%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 15
where (( chargedesc like '%BUY FLYING BLUE MILE%' OR chargedesc like '%MILEAGE PLUS%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 7
where (( chargedesc like '%CARGO POR EMISION%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 32
where (( chargedesc like '%CNCL/PNLTY%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 8
where (( chargedesc like '%OVERWEIGHT%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 20
where (( chargedesc like '%WIFI%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 30
where (( chargedesc like '%RES BOOK FEE%' OR chargedesc like '%UNCONF CHG%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 50
where (( chargedesc like '%OPTIONAL SERVICE%' OR chargedesc like '%NON-FLIGHT%' OR chargedesc like '%MISC FEE%' ))
and ancillaryfeeind is null

update cct
set ancillaryfeeind = 60
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%admirals club%' 
  or ccm.merchantname1 like '%admiral club%'   or ccm.merchantname1 like '%CONTINENTAL PRESIDENT%' 
  or ccm.merchantname1 like '%RED CARPET CLUB%'   or ccm.merchantname1 like '%AIRWAYS CLUB%'
  or ccm.merchantname1 like '%club spirit%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%DELTA AIR CARGO%' )) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%FRONTIER ON BOARD SALES%' 
  or ccm.merchantname1 like '%HORIZON AIR INFLIGHT%'   or ccm.merchantname1 like '%IN FLIGHT SALES%'
  or ccm.merchantname1 like '%IN-FLIGHT PRCHASE JETBLUE%'   or ccm.merchantname1 like '%ONBOARD SALES%'
  or ccm.merchantname1 like '%SOUTHWEST ON BOARD%'   or ccm.merchantname1 like '%UNITED AIRLINES ONBOARD%'
  or ccm.merchantname1 like '%US AIRWAYS COMPANY STORE%'   or ccm.merchantname1 like '%INFLIGHT ENTERTAINMENT%'
  or ccm.merchantname1 like '%SNCB/NMBS ON-BOARD%'   or ccm.merchantname1 like '%SNACK BAR T2%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 15
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%AMEX LIFEMILES%' )) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 50
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%AIRPORT KIOSKS%' )) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname2 like '%ONBOARD%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname2 like '%AIR CARGO%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((cch.chargedesc like '%EX BAG%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname2 like '%ON BOARD%'
OR ccm.merchantname2 like '%MOVIE SALES%'
OR ccm.merchantname2 like '%VIRGIN AMERICA ON BO%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 30
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((cch.chargedesc like '%REGIONAL EXPRESS CREDIT CARD SURCHARGE%')) and cct.ancillaryfeeind is null

--****** added 2/6/2013 *******

update dba.ccticket
set ancillaryfeeind = '15'
where issuercity = 'SKYMILES FEE'

update dba.ccticket
set ancillaryfeeind = '20'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and ticketamt = 7 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '17'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and issuercity = 'delta.com' and ticketamt = 9 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and ((issuercity <> 'delta.com' or issuercity is null)) and ticketamt = 9 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and ticketamt in (19, 9.5, 14.5, 29, 29.5, 39, 39.5, 49, 79) and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = '7'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and ticketamt in (40, 50) and ancillaryfeeind is null and matchedrecordkey is null

update ce
set ancillaryfeeind = 20
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and ((cm.merchantname1 like '%AIPORTWIRELESS%' 
OR cm.merchantname1 like '%AIRPORT WIRELESS%' OR cm.merchantname1 like '%BOINGO%' 
OR cm.merchantname1 like '%SWA INFLIGHT WIFI%' OR cm.merchantname1 like 'VIASAT'
))
and ce.ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and ticketamt = 59 and ancillaryfeeind is null and matchedrecordkey is null

-----------------
-----------------

update ct
set ct.ancillaryfeeind = ch.ancillaryfeeind from dba.ccticket ct, dba.ccheader ch where ct.recordkey = ch.recordkey and ct.iatanum = ch.iatanum and ct.ancillaryfeeind is null and ch.ancillaryfeeind is not null

update ce
set ce.ancillaryfeeind = ch.ancillaryfeeind from dba.ccexpense ce, dba.ccheader ch where ce.recordkey = ch.recordkey and ce.iatanum = ch.iatanum and ce.ancillaryfeeind is null and ch.ancillaryfeeind is not null

UPDATE CCH
SET CCH.AncillaryFeeInd = CCT.AncillaryFeeInd FROM DBA.CCHeader CCH, DBA.CCTicket CCT WHERE CCH.IataNum = CCT.IataNum AND CCH.RecordKey = CCT.RecordKey AND CCT.AncillaryFeeInd IS NOT NULL and CCH.AncillaryFeeInd IS NULL

UPDATE CCH
SET CCH.AncillaryFeeInd = CCE.AncillaryFeeInd FROM DBA.CCHeader CCH, DBA.CCExpense CCE WHERE CCH.IataNum = CCE.IataNum AND CCH.RecordKey = CCE.RecordKey AND CCE.AncillaryFeeInd IS NOT NULL and CCH.AncillaryFeeInd IS NULL


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-End Ansillary Fees Update% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()

declare @salutation varchar(10)
set @salutation = 'MR'
update ct
set passengername = SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation
from dba.CCTicket ct
where RIGHT(passengername, 2) in (@salutation)
and RIGHT(passengername, 3) != ' '+@salutation
and LEN(SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation) < 50

set @salutation = 'MS'
update ct
set passengername = SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation
from dba.CCTicket ct
where RIGHT(passengername, 2) in (@salutation)
and RIGHT(passengername, 3) != ' '+@salutation
and LEN(SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation) < 50

set @salutation = 'MRS'
update ct
set passengername = SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation
from dba.CCTicket ct
where RIGHT(passengername, 3) in (@salutation)
and RIGHT(passengername, 3) != ' '+@salutation
and LEN(SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation) < 50

set @salutation = 'Miss'
update ct
set passengername = SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation
from dba.CCTicket ct
where RIGHT(passengername, 4) in (@salutation)
and RIGHT(passengername, 5) != ' '+@salutation
and LEN(SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation) < 50

set @salutation = 'DR'
update ct
set passengername = SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation
from dba.CCTicket ct
where RIGHT(passengername, 2) in (@salutation)
and RIGHT(passengername, 3) != ' '+@salutation
and LEN(SUBSTRING(passengername, 1, charindex(@salutation, PassengerName)-1)+ ' '+@salutation) < 50


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set Saluatations% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


------------------------ Additional updates for CC Matchback ---------- LOC/8/12/2013
--------CCHTL updates ------
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
--select h.recordkey as htlRecord,cch.recordkey as ccmRecord,ccm.masterid as CCMMasterID
--, ccmxref.masterid as CCMXREFMaster, htlpropccm.parentid as HtlPropCCMParentid
--, h.masterid as HtlMaster, htlxref.masterid as HtlXrefMaster, htlprop.parentid as HtlHtlPropParent
--, guestname, lastname+'/'+firstname, totalauthamt , ttlhtlcost,(totalauthamt - ttlhtlcost)
--, ccm.merchantname1, htlpropertyname
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM, dba.comrmks c
where cch.employeeid = c.text2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013'
and h.recordkey = c.recordkey and h.seqnum = c.seqnum
and substring(guestname,1,8) = substring(lastname+'/'+firstname,1,8)
and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
--------Hotel updates -----
Update h
set h.matchedind = '2' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM, dba.comrmks c
where cch.employeeid = c.text2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013'
and h.recordkey = c.recordkey and h.seqnum = c.seqnum
and substring(guestname,1,8) = substring(lastname+'/'+firstname,1,8)
and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CCMB Updates% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

--added per Lisa case#30109  
update cct 
set cct.matchedrecordkey = TicketIssuer 
FROM dba.ccticket cct 
where MatchedRecordKey IS NULL 
and ((ticketissuer like ('American Express Travel Rel%'))or (ticketissuer like ('Kirchman%'))) 

-------- CC Header --Update the Matched Recordkey to = ticket issuer where the Ticket issuer is Amex or Kirchman 
-------- Per Dean and Kristin at FIS and case 30109.....LOC/4/18/2014 
update cch 
set cch.matchedrecordkey = TicketIssuer 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cch.MatchedRecordKey IS NULL 
and ((ticketissuer like ('American Express Travel Rel%'))or (ticketissuer like ('Kirchman%')))	

-------- To account for "other" transactions coming in under the American Express umbrella-------LOC 5/29/2014
Update cch
set cch.matchedrecordkey = ccm.merchantname1
from dba.ccheader cch, dba.ccmerchant ccm
where cch.merchantid = ccm.merchantid
and ccm.merchantname1 like 'american express%'
and matchedrecordkey is null


------------------- Update Iatanum for CAPCO data ----------------------------------LOC/10/22/2013
----- The client codes are actually the CID codes from Amex - First 3 characters are the country
----- market code and the last digits are the CID code which determines the division for 
----- FIS and Capital Markets (CAPCO).------------------------------------------------------------
-- ADDED delete statements to remove the previously loaded records w/the CAPCO IATANUM
--PER CASE #36809 Removing the previously loaded records //TT

DELETE CCHDR
--select RecordKey, ClientCode, IataNum
from dba.CCHeader CCHDR
where iatanum = 'CAPAXCC' 
and clientcode in ('012202934','017053422','035135655','036053620')
and RecordKey in (select RecordKey from dba.CCHeader where IataNum = 'FISCCAX' 
					and clientcode in ('012202934','017053422','035135655','036053620'))

Update dba.CCHEADER
set iatanum = 'CAPAXCC'
where iatanum = 'FISCCAX' and clientcode in ('012202934','017053422','035135655','036053620')

DELETE cctkt
--select RecordKey, ClientCode, IataNum
from dba.CCTicket cctkt
where iatanum in ( 'CAPAXCC')
and clientcode in ('012202934','017053422','035135655','036053620')
and RecordKey in (select RecordKey from dba.CCticket where IataNum = 'FISCCAX' 
					and clientcode in ('012202934','017053422','035135655','036053620'))
 
Update dba.CCticket
set iatanum = 'CAPAXCC'
where iatanum = 'FISCCAX' and clientcode in ('012202934','017053422','035135655','036053620')

DELETE CCAR
--select RecordKey, ClientCode, IataNum
from dba.CCCar CCAR
where iatanum = 'CAPAXCC' 
and clientcode in ('012202934','017053422','035135655','036053620')
and RecordKey in (select RecordKey from dba.CCcar where IataNum = 'FISCCAX' 
					and clientcode in ('012202934','017053422','035135655','036053620'))

Update dba.CCCar
set iatanum = 'CAPAXCC'
where iatanum = 'FISCCAX' and clientcode in ('012202934','017053422','035135655','036053620')

DELETE CCHTL
--select RecordKey, ClientCode, IataNum
from dba.CCHotel CCHTL
where iatanum = 'CAPAXCC' 
and clientcode in ('012202934','017053422','035135655','036053620')
and RecordKey in (select RecordKey from dba.CChotel where IataNum = 'FISCCAX' 
					and clientcode in ('012202934','017053422','035135655','036053620'))
Update dba.CChotel
set iatanum = 'CAPAXCC'
where iatanum = 'FISCCAX' and clientcode in ('012202934','017053422','035135655','036053620')

DELETE CCEXP
--select RecordKey, ClientCode, IataNum
from dba.CCExpense CCEXP
where iatanum = 'CAPAXcc' 
and clientcode in ('012202934','017053422','035135655','036053620')
and RecordKey in (select RecordKey from dba.CCexpense where IataNum = 'FISCCAX' 
					and clientcode in ('012202934','017053422','035135655','036053620'))
 
Update dba.CCexpense
set iatanum = 'CAPAXCC'
where iatanum = 'FISCCAX' and clientcode in ('012202934','017053422','035135655','036053620')


-------- Updating the US Capco data as it comes in the same CID as the US data.  Usinging the remarks1
-------- as this is the raw employee number -- no padding etc ... this is per FIS .. LOC/2/11/2014
--removing the previously loaded records to elminiate the duplicate key error for new imports
--case#36809 //TT

DELETE cchdr
--select RecordKey, ClientCode, IataNum
from dba.CCHeader cchdr
where iatanum = 'capaxcc' 
and len(remarks1) = 4 
and clientcode in ('037214717')
and RecordKey in (select RecordKey from dba.CCHeader where IataNum = 'FISCCAX'
					and len(remarks1) = 4 
					and clientcode in ('037214717'))

Update dba.ccheader
set iatanum = 'CAPAXCC'
where iatanum = 'FISCCAX' and len(remarks1) = 4 and clientcode in ('037214717')

DELETE cctkt
--select CCTKT.RecordKey, CCTKT.ClientCode, CCTKT.IataNum
from dba.ccticket cctkt, dba.ccheader cchdr
where 1=1
and cctkt.iatanum = 'CAPAXCC' 
and len(cchdr.remarks1) = 4 
and cctkt.clientcode in ('037214717')
and cctkt.recordkey = cchdr.recordkey
and cctkt.recordkey in (select CCTKT.recordkey from dba.ccticket cctkt, dba.ccheader cchdr
							where 1=1
							and cctkt.iatanum = 'FISCCAX' 
							and len(cchdr.remarks1) = 4 
							and cctkt.clientcode in ('037214717')
							and cctkt.recordkey = cchdr.recordkey )


Update cct
set iatanum = 'CAPAXCC'
from dba.ccticket cct, dba.ccheader cch
where cct.iatanum = 'FISCCAX' and len(cch.remarks1) = 4 and cct.clientcode in ('037214717')
and cct.recordkey = cch.recordkey

DELETE ccc
--select ccc.RecordKey, ccc.ClientCode, ccc.IataNum
from dba.CCCar ccc, dba.ccheader cchdr
where 1=1
and ccc.iatanum = 'CAPAXCC' 
and len(cchdr.remarks1) = 4 
and ccc.clientcode in ('037214717')
and ccc.recordkey = cchdr.recordkey
and ccc.recordkey in (select ccc.recordkey from dba.CCCar ccc, dba.ccheader cchdr
							where 1=1
							and ccc.iatanum = 'FISCCAX' 
							and len(cchdr.remarks1) = 4 
							and ccc.clientcode in ('037214717')
							and ccc.recordkey = cchdr.recordkey )

Update ccc
set iatanum = 'CAPAXCC'
from dba.cccar ccc, dba.ccheader cch
where ccc.iatanum = 'FISCCAX' and len(remarks1) = 4 and ccc.clientcode in ('037214717')
and ccc.recordkey = cch.recordkey

DELETE cchtl
--select cchtl.RecordKey, cchtl.ClientCode, cchtl.IataNum
from dba.cchotel cchtl, dba.ccheader cchdr
where 1=1
and cchtl.iatanum = 'CAPAXCC' 
and len(cchdr.remarks1) = 4 
and cchtl.clientcode in ('037214717')
and cchtl.recordkey = cchdr.recordkey
and cchtl.recordkey in (select cchtl.recordkey from dba.CCHotel cchtl, dba.ccheader cchdr
							where 1=1
							and cchtl.iatanum = 'FISCCAX' 
							and len(cchdr.remarks1) = 4 
							and cchtl.clientcode in ('037214717')
							and cchtl.recordkey = cchdr.recordkey )

Update cchtl
set iatanum = 'CAPAXCC'
from dba.cchotel cchtl, dba.ccheader cch
where cchtl.iatanum = 'FISCCAX' and len(remarks1) = 4 and cchtl.clientcode in ('037214717')
and cchtl.recordkey = cch.recordkey


DELETE cce
--select cce.RecordKey, cce.ClientCode, cce.IataNum
from dba.ccexpense cce, dba.ccheader cchdr
where 1=1
and cce.iatanum = 'CAPAXCC' 
and len(cchdr.remarks1) = 4 
and cce.clientcode in ('037214717')
and cce.recordkey = cchdr.recordkey
and cce.recordkey in (select cce.recordkey from dba.ccexpense cce, dba.ccheader cchdr
							where 1=1
							and cce.iatanum = 'FISCCAX' 
							and len(cchdr.remarks1) = 4 
							and cce.clientcode in ('037214717')
							and cce.recordkey = cchdr.recordkey )

Update cce
set iatanum = 'CAPAXCC'
from dba.ccexpense cce, dba.ccheader cch
where cce.iatanum = 'FISCCAX' and len(remarks1) = 4 and cce.clientcode in ('037214717')
and cce.recordkey = cch.recordkey



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CC TKT FIX NAME% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='FISCCAX SP end% ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
