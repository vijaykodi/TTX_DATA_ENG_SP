/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_XILINX']/UnresolvedEntity[@Name='invoicedetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_XILINX']/UnresolvedEntity[@Name='ccticket' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_XILINX']/UnresolvedEntity[@Name='ccheader' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_XILCCVI]    Script Date: 7/7/2015 12:09:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_XILCCVI]
	
 AS


delete from dba.ccheader
where clientcode not in ('12886','12887')
and iatanum like 'XILCCVI'
 
delete from dba.ccticket
where clientcode not in ('12886','12887')
and iatanum like 'XILCCVI'
 
delete from dba.cccar
where clientcode not in ('12886','12887')
and iatanum like 'XILCCVI'
 
delete from dba.cchotel
where clientcode not in ('12886','12887')
and iatanum like 'XILCCVI'
 
delete from dba.ccexpense
where clientcode not in ('12886','12887')
and iatanum like 'XILCCVI'


insert into dba.client
select distinct clientcode,iatanum,null,null,null,null,null,null
,null,null,null,null,null,null,null,null,null,null,null,null
,null,null,null,null
from dba.ccheader
where clientcode+iatanum not in(select clientcode+iatanum
from dba.client
)
update a
set a.MarketCode = c.isocountrycode
from dba.CCHeader a, dba.CardAccount b, dba.CardHolder c
where a.CreditCardNum = b.AccountNumber 
and b.cardholderidentification = c.cardholderidentification
and a.IataNum like 'XILCCVI'and a.MarketCode is null
and exists (select MAX(trxdate) from dba.CardAccount d
                  where d.AccountNumber = b.accountnumber)
and exists (select MAX(trxdate) from dba.Cardholder e
                  where e.CardholderIdentification = c.CardholderIdentification)
--set prugeind = W for records that were voided 
update t1
set t1.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t1.PurgeInd is null

update t2
set t2.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t2.PurgeInd is null


update dba.ccticket
set valcarriercode = 'CA'
where carrierstr like '%CA%'
and valcarriercode = 'A'


update dba.ccticket
set valcarriercode = 'VX'
where carrierstr like '%VX%'
and valcarriercode = 'X'

update dba.ccticket
set valcarriercode = 'QF'
where carrierstr like '%QF%'
and valcarriercode = 'F'

update dba.ccticket
set valcarriercode = 'BV'
where carrierstr like '%BV%'
and valcarriercode = 'V'

update dba.ccticket
set valcarriercode = 'QF'
where carrierstr like '%41%'
and valcarriercode = '41'


update dba.ccticket
set valcarriercode = 'LH'
where carrierstr like '%LH%'
and valcarriercode = 'H'

update dba.ccticket
set valcarriercode = 'CO'
where carrierstr like '%CO%'
and valcarriercode = 'O'

update dba.ccticket
set valcarriercode = 'ZZ'
where valcarriercode = 'N'

update ct
set ct.valcarriercode = 'AK'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AIRASIA%'

update ct
set ct.valcarriercode = 'OZ'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%ASIANA%'

update ct
set ct.valcarriercode = 'AK'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AIRASIA%'

update ct
set ct.valcarriercode = 'OS'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AUSTRIAN%'

update ct
set ct.valcarriercode = 'AV'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AVIANCA%'

update ct
set ct.valcarriercode = 'BA'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%BRITISH AIR%'

update ct
set ct.valcarriercode = 'FB'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%BULGARIA AI%'

update ct
set ct.valcarriercode = 'CX'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%CATHAY PA%'

update ct
set ct.valcarriercode = 'DE'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%CONDOR FLU%'

update ct
set ct.valcarriercode = 'U2'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%EASYJET%'

update ct
set ct.valcarriercode = 'MS'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%EGYPTAIR%'

update ct
set ct.valcarriercode = 'EW'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%EUROWINGS%'

update ct
set ct.valcarriercode = '9W'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%JET AIRW%'

update ct
set ct.valcarriercode = '4U'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%GERMANWINGS%'

update ct
set ct.valcarriercode = 'BE'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%FLYBE%'

update ct
set ct.valcarriercode = 'KE'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%KOREA%'

update ct
set ct.valcarriercode = 'LS'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%JET2%'

update ct
set ct.valcarriercode = 'CM'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%COPA%'

update ct
set ct.valcarriercode = 'JQ'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%JETSTAR%'

update ct
set ct.valcarriercode = 'WS'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%WEST JET%'

update ct
set ct.valcarriercode = 'WS'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%WESTJET%'

update ct
set ct.valcarriercode = 'RG'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%VARIG%'

update ct
set ct.valcarriercode = 'CM'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%COPA%'

update ct
set ct.valcarriercode = 'DJ'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%VIRGIN%'
and ct.valcarriernum = 856

update ct
set ct.valcarriercode = 'ZI'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AIGL%'
and ct.valcarriernum = 439

update ct
set ct.valcarriercode = 'F7'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%BABOO%'
and ct.valcarriernum = 33

update ct
set ct.valcarriercode = 'QF'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%QANTAS%'

update ct
set ct.valcarriercode = 'SK'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%S A S%'

update ct
set ct.valcarriercode = 'SK'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%SAS%'

update ct
set ct.valcarriercode = 'SQ'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%SINGAPORE%'

update ct
set ct.valcarriercode = 'MH'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%MALAYSIA%'

update ct
set ct.valcarriercode = 'SY'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%SUN COUNT%'



update ct
set ct.valcarriercode = 'AB'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AIR BERLI%'

update ct
set ct.valcarriercode = 'CA'
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.valcarriercode = 'XX'
and ch.chargedesc like '%AIR CHINA%'

--Update ccmerchant with the 2 letter country code instead of using the 3 number ISO country code....10/4/11 NL
update merch
set merch.merchantctrycode = iso.countrycode
from dba.ccmerchant merch,dba.ccisocountry iso
where merch.merchantctrycode = iso.isocountrynum



--Ancillary fee updates per Jim on 11/14/11
update dba.ccticket
set ancillaryfeeind = 1
where ticketissuer like '%1ST BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 2
where ticketissuer like '%2ND BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 3
where ticketissuer like '%3RD BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 4
where ticketissuer like '%4TH BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 5
where ticketissuer like '%5TH BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 6
where ticketissuer like '%6TH BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 16
where ticketissuer like '%-INFLT%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%EXCS BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 8
where ticketissuer like '%OVERWEIGHT%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 9
where ticketissuer like '%OVERSIZE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%EXCS BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 10
where ticketissuer like '%SPORT EQUIP%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%EXCS BAG FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA AWRD ACCEL%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA ECNMY PLUS%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA PREM CABIN%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA PREM LINE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA MPI UPGRD%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%SKYMILES FEE%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 17
where ticketissuer like '%EASY CHECK IN%'	
and ancillaryfeeind is null


update dba.ccticket
set ancillaryfeeind = 60
where ticketissuer = 'KLM LOUNGE ACCESS'
and ancillaryfeeind is null


update dba.ccticket
set ancillaryfeeind = 18
where ticketissuer like '%UNITED-  UNITED.COM AWARD%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 19
where ticketissuer like '%UNITED-  UNITED CONNECTIO%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 21
where ticketissuer like '%UNITED-  UNITED.COM CUSTO%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer like '%UNITED-  WIPRO BPO PHILIP%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer like '%UNITED-  WIPRO SPECTRAMIN%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 21
where ticketissuer like '%UNITED-  TICKET SVC CENTE%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%MPI BOOK FEE%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%RES BOOK FEE%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%UA TKTG FEE%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%UA UNCONF CHG%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%UNITED-  UNITED.COM%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 31
where ticketissuer like '%CONFIRM CHG$%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 32
where ticketissuer like '%CNCL/PNLTY%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 50
where ticketissuer like '%MUA CO PAY TI%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 50
where ticketissuer like '%UA MISC FEE%'	
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 50
where ticketissuer like '%UNITED.COM-SWIT%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 1
WHERE PASSENGERNAME LIKE '%/FIRST CHE%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 2
WHERE PASSENGERNAME LIKE '%/SECOND CH%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 3
WHERE PASSENGERNAME LIKE '%/THIRD CH%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 4
WHERE PASSENGERNAME LIKE '%/FOURTH CH%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 5
WHERE PASSENGERNAME LIKE '%/FIFTH CH%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 6
WHERE PASSENGERNAME LIKE '%/SIXTH CH%'
and ancillaryfeeind is null




UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 7
WHERE PASSENGERNAME LIKE '%EXCESS BA%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 8
WHERE PASSENGERNAME LIKE '%/OVERWEIGH%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 9
WHERE PASSENGERNAME LIKE '%/OVERSIZED%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 10
WHERE PASSENGERNAME LIKE '%SPORT EQU%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 10
WHERE PASSENGERNAME LIKE '%/SPORTING%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 12
WHERE PASSENGERNAME LIKE '%/EXTRA LEG%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 13
WHERE PASSENGERNAME LIKE '%/FIRST CLA%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 15
WHERE PASSENGERNAME LIKE '%/ONEPASS R%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 15
WHERE PASSENGERNAME LIKE '%/REWARD BO%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 15
WHERE PASSENGERNAME LIKE '%/REWARD CH%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 16
WHERE PASSENGERNAME LIKE '%/INFLIGHT%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 16
WHERE PASSENGERNAME LIKE '%/LIQUOR%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 21
WHERE PASSENGERNAME LIKE '%/SPECIAL S%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 30
WHERE PASSENGERNAME LIKE '%/RESERVATI%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 30
WHERE PASSENGERNAME LIKE '%/TICKETING%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 31
WHERE PASSENGERNAME LIKE '%/CHANGE FE%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 32
WHERE PASSENGERNAME LIKE '%/CHANGE PE%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 31
WHERE PASSENGERNAME LIKE '%/PAST DATE%'
and ancillaryfeeind is null



UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 60
WHERE PASSENGERNAME LIKE '%/P-CLUB DA%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 60
where passengername like '%P-CLUB%'
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 1
where routing like 'XAA%'
and routing like '%XAE%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 15
where routing like 'XAA%'
and routing like '%XUP%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 60
where routing like 'XAA%'
and routing like '%XAF%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 50
where routing like 'XAA%'
and routing like '%XCA%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 30
where routing like 'XAA%'
and routing like '%XOT%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 16
where routing like 'XAA%'
and routing like '%XDF%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 30
where routing like 'XAA%'
and routing like '%XAO%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 50
where routing like 'XAA%'
and routing like '%XAA%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 21
where routing like 'XAA%'
and routing like '%XTD%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 25
where routing like 'XAA%'
and routing like '%XPC%'
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 31
where routing like 'XAA%'
and routing like '%XPE%'
and ancillaryfeeind is null
and matchedrecordkey is null



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GATWICK S BAGGAGE%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0QYBAG%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0R2BAG%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0R6BAG%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%GOVTRIPTAV 0R7BAG%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%LHR T3- BAGGAGE%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%LHR T4 BAGGAGE%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%T1  BAGGAGE RECLAIM%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%T1 BAGGAGE RECLAIM%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%T3- BAGGAGE BELT%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 1
WHERE MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (1)%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 2
WHERE MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (2)%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 7
WHERE MCHRGDESC1 LIKE '%EXCESS BAGGAGE CO%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%ALASKA AIR IN FLIGHT%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%FLY DUBAI-INFLIGHT%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%IN FLIGHT US AIRWAYS%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 16
WHERE MCHRGDESC1 LIKE '%INFLIGHT FOOD PURCHASE%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 8
WHERE MCHRGDESC1 LIKE '%KLM OVERBAGAGEKAS%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%AIRCELL GOGO INFLIGHT%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%AIRCELL*GOGO INFLIGHT%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%INFLIGHT US AIRWAYSQPS%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%SWA INFLIGHT WIFI%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%TRLPAY  GOGO INFLIGHT%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 55
WHERE MCHRGDESC1 LIKE '%AIRPORTBAGS.COM%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 60
WHERE MCHRGDESC1 LIKE '%AA ADMIRAL%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 60
WHERE MCHRGDESC1 LIKE '%AA ADMRL%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 60
WHERE MCHRGDESC1 LIKE '%ADMIRALS CLUB%'
AND ANCILLARYFEEIND IS NULL



UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 70
WHERE MCHRGDESC1 LIKE '%INFLIGHT MEDICAL%'
AND ANCILLARYFEEIND IS NULL




--*******Added 3/31/2010*******

update dba.ccticket
set ancillaryfeeind = 1
where ancillaryfeeind is null
and substring(ticketnum,1,2) in ('29','26')
and valcarriercode = 'CO'
and ticketamt in (23,25)
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where ancillaryfeeind is null
and substring(ticketnum,1,2) in ('29','26')
and valcarriercode = 'CO'
and ticketamt in (27,30,32,35,45,50,9,10)
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AA'
and ticketamt in (25)
and substring(ticketnum,1,3) in ('025','026','027','028')
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AA'
and ticketamt in (35,30,50,60)
and substring(ticketnum,1,3) in ('025','026','027','028')
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AA'
and ticketamt in (100)
and substring(ticketnum,1,3) in ('025','026','027','028')
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AA'
and ticketamt in (25)
and substring(ticketnum,1,2) in ('26')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AA'
and ticketamt in (35,30,50,60)
and substring(ticketnum,1,2) in ('26')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AA'
and ticketamt in (100)
and substring(ticketnum,1,2) in ('26')
and ancillaryfeeind is null
and matchedrecordkey is null


update dba.ccticket
set ancillaryfeeind = 16
where valcarriercode = 'AA'
and ticketamt in (3.29,5.29,6,4.49,8.29,10,7)
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'DL'
and ticketamt in (23,25,32,35,27,30,50,55)
and substring(ticketnum,1,2) IN ('25','29','82')
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'DL'
and ticketamt in (32,35,27,30,50,55)
and substring(ticketnum,1,2) IN ('25','29','82')
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'UA'
and ticketamt in (25)
and substring(ticketnum,1,2) IN ('40','46','45')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'UA'
and ticketamt in (35,50)
and substring(ticketnum,1,2) IN ('40','46','45')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'US'
and ticketamt in (23,25)
and substring(ticketnum,1,2) IN ('24')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'US'
and ticketamt in (35,50)
and substring(ticketnum,1,2) IN ('24')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'WN'
and ticketamt in (50,110)
and substring(ticketnum,1,2) IN ('26')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 17
where valcarriercode = 'WN'
and ticketamt in (10)
and substring(ticketnum,1,2) IN ('06')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'LH'
and ticketamt in (50)
and substring(ticketnum,1,2) IN ('16','26','27')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'LH'
and ticketamt in (150)
and substring(ticketnum,1,2) IN ('16','26','27')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'BA'
and ((ticketamt in (40,50,48,60)
and billedcurrcode = 'USD'
and matchedrecordkey is null
OR ticketamt in (28,35,32,40)
and billedcurrcode = 'GBP'))
and substring(ticketnum,1,2) IN ('26','90')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'BA'
and ((ticketamt in (112,140)
and billedcurrcode = 'USD'
and matchedrecordkey is null
OR ticketamt in (72,90)
and billedcurrcode = 'GBP'))
and substring(ticketnum,1,2) IN ('26','90')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'SQ'
and ticketamt in (8,12,22,50,15,30,55,40,60,50,109,150,84,110,121,117,160,94,115,130,129,149,165,128)
and substring(ticketnum,1,2) IN ('16','18')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AF'
and ticketamt in (55,100)
and substring(ticketnum,1,2) in ('82','16')
and ancillaryfeeind is null
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AF'
and ticketamt in (200)
and substring(ticketnum,1,2) in ('82','16')
and ancillaryfeeind is null
and matchedrecordkey is null


update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AS'
and ticketamt in (20)
and substring(ticketnum,1,2) in ('21','16')
and ancillaryfeeind is null
and matchedrecordkey is null


update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AC'
and ticketamt in (30,50,75,100,225)
and substring(ticketnum,1,2) in ('20','51')
and matchedrecordkey is null
and ancillaryfeeind is null




update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'LX'
and ticketamt in (250,150,50,120,450)
and matchedrecordkey is null
and ancillaryfeeind is null



update ct
set ct.ancillaryfeeind = 16
from dba.ccheader ch,dba.ccticket ct
where chargedesc like '%inflight%'
and ch.recordkey = ct.recordkey
and ct.ancillaryfeeind is null
and ct.matchedrecordkey is null



update ce
set ce.ancillaryfeeind = 16
from dba.ccheader ch,dba.ccexpense ce
where chargedesc like '%inflight%'
and ch.recordkey = ce.recordkey
and ce.ancillaryfeeind is null




update ce
set ancillaryfeeind = 20
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and ((cm.merchantname1 like '%AIPORTWIRELESS%' 
OR cm.merchantname1 like '%AIRPORT WIRELESS%'
OR cm.merchantname1 like '%BOINGO%'))
and ce.ancillaryfeeind is null




update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer in ('AIR NEW ZEALAND EXCESS BAG WL7',
'AIR NEW ZEALAND EXCESS BAG CH8',
'MAS EXCESS BAGGAGE - DOME',
'VIRGIN ATLANTIC CC ANCILLARIES',
'AIR NEW ZEALAND EXCESS BAG AK7')
and matchedrecordkey is null
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 16
where ticketissuer in ('JETBLUE BUY ON BOARD',
'AMTRAK ONBOARD/ BOS 0049',
'ALASKA AIRLINES IN FLIGHT',
'FRONTIER ON BOARD SALES',
'AMTRAK ONBOARD/ PDX  WASHINGTON',
'AMTRAK ONBOARD/ PHL  WASHINGTON',
'KOREAN AIR DUTY-FREE (  )',
'WESTJET-BUY ON BOARD',
'ONBOARD SALES',
'AMTRAK ONBOARD/ SAC  WASHINGTON',
'EVA AIRWAYS IN FLIGHT DUTY FEE',
'AMTRAK ONBOARD/ NYP  WASHINGTON',
'EL AL DUTY FREE',
'SOUTHWEST ON BOARD',
'AMTRAK ONBOARD/ HAR  WASHINGTON',
'AMTRAK ONBOARD/ RVR  WASHINGTON',
'AMTRAK ONBOARD/ WAS  WASHINGTON',
'AMTRAK ONBOARD/ OAK  WASHINGTON',
'KOREAN AIR DUTY-FREE ($)')
and matchedrecordkey is null
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer in ('AIR DO INTERNET',
'SOUTHWEST ONBOARD INTERNT',
'AIR FRANCE USA INTERNET')
and matchedrecordkey is null
and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 60
where ticketissuer in ('ADMIRAL CLUB',
'US AIRWAYS CLUB',
'CONTINENTAL PRESIDENT CLU',
'UNITED RED CARPET CLUB',
'THE LOUNGE VIRGIN BLUE')
and matchedrecordkey is null
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 16
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('AMTRAK - CAP CORR CAFE',
'AMTRAK - SURFLINER CAFE',
'AMTRAK CASCADES CAFE',
'AMTRAK FOOD & BEVERAGE',
'AMTRAK-CAFE',
'AMTRAK-DINING CAR',
'AMTRAK-EAST CAFE',
'AMTRAK-MIDWEST CAFE',
'AMTRAK-NORTHEAST CAFE',
'AMTRAK-SAN JOAQUINS CAFE')
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 60
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('AA ADMIRAL CLUB AUS',
'AA ADMIRAL CLUB LAX',
'AA ADMIRAL CLUB LGA D3',
'AA ADMIRALS CLUB MIAMI D',
'AIR CANADA CLUB',
'AMERICAN EXPRESS PLATINUM LOUNGE')
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 20
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('AIRCELL-ABS')
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 17
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('BAA ADVANCE')
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 16
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('ALPHA FLIGHT SERVICES')
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 16
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('DFASS CANADA COMPANY')
and mchrgdesc1 like '%air canada on board%'
and ancillaryfeeind is null



update ce
set ancillaryfeeind = 15
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and merchantname1 in ('DELTAMILES BY POINTS')
and ancillaryfeeind is null



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 2
WHERE TicketIssuer LIKE '%extra baggage%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE TicketIssuer LIKE '%excess bag%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE TicketIssuer LIKE '%VIRGIN ATLANTIC XX ANCILLARIES%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE TicketIssuer LIKE '%IN FLIGHT%' OR TicketIssuer LIKE '%INFLIGHT%' OR TicketIssuer LIKE '%ONBOARD%' OR TicketIssuer LIKE '%ON BOARD%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE TicketIssuer LIKE '%DUTY FREE%' OR TicketIssuer LIKE '%DUTY-FREE%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE TicketIssuer LIKE '%KLM OPTIONAL SERVICES%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 60
WHERE TicketIssuer LIKE '%ADMIRALS CLUB%' OR TicketIssuer LIKE '%PRESIDENT CLU%' OR TicketIssuer LIKE '%CARPET CLUB%' OR TicketIssuer LIKE '%ADMIRAL CLUB%'
	OR TicketIssuer LIKE '%THE LOUNGE VIRGIN%' OR TicketIssuer LIKE '%US AIRWAYS CLUB%' OR TicketIssuer LIKE '%VIP LOUNGE%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 1
WHERE PassengerName LIKE '%/FIRST CHE%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 2
WHERE PassengerName LIKE '%/SECOND%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE PassengerName LIKE '%/EXCESS%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 8
WHERE PassengerName LIKE '%/OVERWEIGH%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 11
WHERE PassengerName LIKE '%/SPECIAL%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 13
WHERE PassengerName LIKE '%/FIRST CLA%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 14
WHERE PassengerName LIKE '%/EXT ST%' OR PassengerName LIKE '%/EXTRA SEAT%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 15
WHERE PassengerName LIKE '%ONEPASS%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE PassengerName LIKE '%/HEADSET%' OR PassengerName LIKE '%/INFLIGHT%' OR PassengerName LIKE '%/LIQUOR%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 18
WHERE PassengerName LIKE '%/EXTRA LEG%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 30
WHERE PassengerName LIKE '%/FARELOCK%' OR PassengerName LIKE '%/FEE' OR PassengerName LIKE '%/REFUND%' OR PassengerName LIKE '%FEE.%' OR PassengerName LIKE '%KIOSK.%'
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 31
WHERE PassengerName LIKE '%/CHANGE PR%' OR PassengerName LIKE '%/SAME DAY%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL



UPDATE DBA.CCTicket
SET AncillaryFeeInd = 60
WHERE PassengerName LIKE '%P-CLUB%' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL


UPDATE DBA.CCTicket
SET AncillaryFeeInd = 19
WHERE PassengerName = 'MISC' OR PassengerName = 'MISceLLaNeOUS' 
AND AncillaryFeeInd IS NULL
AND MatchedRecordKey IS NULL

update dba.ccheader
set ancillaryfeeind = 1
where (( chargedesc like '%1ST BAG FEE%' OR ChargeDesc like '%baggage fee%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 60
where (( chargedesc like '%ADMIRALS CLUB%' 
OR ChargeDesc like '%SKY TEAM LOUNGE%'
OR ChargeDesc like '%REDCARPETCLUB%'
OR ChargeDesc like '%US AIRWAYS CLUB%'
OR ChargeDesc like '%ALASKA AIR BOARDRM%'
OR ChargeDesc like '%-BOARDROOM%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 16
where (( chargedesc like '%ALASKA AIR CO STORE%' 
OR ChargeDesc like '%IN FLIGHT%'
OR ChargeDesc like '%ALASKA AIRLINE ONBOA%'
OR ChargeDesc like '%ONBOARD%'
OR ChargeDesc like '%IN-FLIGHT%'
OR ChargeDesc like '%DUTY FREE%'
OR ChargeDesc like '%SOUTHWESTAIR*INFLIGH%'
OR ChargeDesc like '%*INFLT%'
OR ChargeDesc like '%WESTJET BUY ON BOARD%'
OR ChargeDesc like '%PURCHASE ON JETBLUE%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 12
where (( chargedesc like '%ALASKA AIRLINES SEAT%'
OR chargedesc like '%ECNMY PLUS%'
OR chargedesc like '%ECONOMYPLUS%' 
OR chargedesc like '%ECONOMY PLUS%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 15
where (( chargedesc like '%BUY FLYING BLUE MILE%'
OR chargedesc like '%MILEAGE PLUS%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 7
where (( chargedesc like '%CARGO POR EMISION%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 32
where (( chargedesc like '%CNCL/PNLTY%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 8
where (( chargedesc like '%OVERWEIGHT%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 20
where (( chargedesc like '%WIFI%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 30
where (( chargedesc like '%RES BOOK FEE%'
OR chargedesc like '%UNCONF CHG%' ))
and ancillaryfeeind is null


update dba.ccheader
set ancillaryfeeind = 50
where (( chargedesc like '%OPTIONAL SERVICE%'
OR chargedesc like '%NON-FLIGHT%'
OR chargedesc like '%MISC FEE%' ))
and ancillaryfeeind is null

update cct
set ancillaryfeeind = 60
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%admirals club%' 
  or ccm.merchantname1 like '%admiral club%'
  or ccm.merchantname1 like '%CONTINENTAL PRESIDENT%'
  or ccm.merchantname1 like '%RED CARPET CLUB%'
  or ccm.merchantname1 like '%AIRWAYS CLUB%'
  or ccm.merchantname1 like '%club spirit%'))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%DELTA AIR CARGO%' ))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%FRONTIER ON BOARD SALES%' 
  or ccm.merchantname1 like '%HORIZON AIR INFLIGHT%'
  or ccm.merchantname1 like '%IN FLIGHT SALES%'
  or ccm.merchantname1 like '%IN-FLIGHT PRCHASE JETBLUE%'
  or ccm.merchantname1 like '%ONBOARD SALES%'
  or ccm.merchantname1 like '%SOUTHWEST ON BOARD%'
  or ccm.merchantname1 like '%UNITED AIRLINES ONBOARD%'
  or ccm.merchantname1 like '%US AIRWAYS COMPANY STORE%'
  or ccm.merchantname1 like '%INFLIGHT ENTERTAINMENT%'
  or ccm.merchantname1 like '%SNCB/NMBS ON-BOARD%'
  or ccm.merchantname1 like '%SNACK BAR T2%'))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 15
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%AMEX LIFEMILES%' ))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 50
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%AIRPORT KIOSKS%' ))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%ONBOARD%'))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%AIR CARGO%'))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((cch.chargedesc like '%EX BAG%'))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%ON BOARD%'
OR ccm.merchantname2 like '%MOVIE SALES%'
OR ccm.merchantname2 like '%VIRGIN AMERICA ON BO%'))
and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 30
 from dba.ccticket cct 
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid )
where ((cch.chargedesc like '%REGIONAL EXPRESS CREDIT CARD SURCHARGE%'))
and cct.ancillaryfeeind is null

--Added by Nina on 9/24/12 per Jim's email on 9/13/12
update dba.ccticket
set ancillaryfeeind = 16
where ((passengername like '%/FOOD S-UA%' OR passengername like '%/CO INFLIG%' OR passengername like '%/INCABIN P%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 12
where ((passengername like '%/ECONOMY P%' OR passengername like '%/BULKHEAD%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 1
where ((passengername like '%/1ST BAG -%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 50
where ((passengername like '%/AU TRAVEL%' OR passengername like '%/CTO TRANS%' OR passengername like '%/UNACCOMPA%' OR passengername like '%/OTHER%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 9
where ((passengername like '%/GARMENT B%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 15
where ((passengername like '%/MILEAGE P%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 8
where ((passengername like '%/OWH - HEA%'))
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 10
where ((passengername like '%/DUFFEL BA%'))
and ancillaryfeeind is null

update ct
set ct.ancillaryfeeind = ch.ancillaryfeeind
from dba.ccticket ct, dba.ccheader ch
where ct.recordkey = ch.recordkey
and ct.iatanum = ch.iatanum
and ct.ancillaryfeeind is null
and ch.ancillaryfeeind is not null

update ce
set ce.ancillaryfeeind = ch.ancillaryfeeind
from dba.ccexpense ce, dba.ccheader ch
where ce.recordkey = ch.recordkey
and ce.iatanum = ch.iatanum
and ce.ancillaryfeeind is null
and ch.ancillaryfeeind is not null

UPDATE CCH
SET CCH.AncillaryFeeInd = CCT.AncillaryFeeInd
FROM DBA.CCHeader CCH, DBA.CCTicket CCT
WHERE CCH.IataNum = CCT.IataNum
AND CCH.RecordKey = CCT.RecordKey
AND CCT.AncillaryFeeInd IS NOT NULL
and CCH.AncillaryFeeInd IS NULL

UPDATE CCH
SET CCH.AncillaryFeeInd = CCE.AncillaryFeeInd
FROM DBA.CCHeader CCH, DBA.CCExpense CCE
WHERE CCH.IataNum = CCE.IataNum
AND CCH.RecordKey = CCE.RecordKey
AND CCE.AncillaryFeeInd IS NOT NULL
and CCH.AncillaryFeeInd IS NULL



update dba.cccar
set rentalloc = rentalloc+'XX'
where len(rentalloc) < 2

--******Added 2/11/2014 for VCF imports

update ct
set ancillaryfeeind = 1
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XAE'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 15
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XUP'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 60
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XAF'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 50
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XCA'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 30
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XOT'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 16
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XDF'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 30
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XAO'
and ancillaryfeeind is null

update ct
set ancillaryfeeind = 50
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where origincitycode = 'XAA'
and segdestcitycode = 'XAA'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 21
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where routing = 'XAA'
and routing = 'XTD'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 25
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where routing = 'XAA'
and routing = 'XPC'
and ancillaryfeeind is null
and matchedrecordkey is null

update ct
set ancillaryfeeind = 31
from dba.ccairseg ca
inner join dba.ccticket ct on ( ct.iatanum = ca.iatanum and ct.recordkey = ca.recordkey )
where routing = 'XAA'
and routing = 'XPE'
and ancillaryfeeind is null
and matchedrecordkey is null


---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN503_XILINX.dba.invoicedetail id, TTXPASQL01.TMAN503_XILINX.dba.ccticket cct, TTXPASQL01.TMAN503_XILINX.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
--and cct.valcarriercode = id.valcarriercode

update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN503_XILINX.dba.invoicedetail id, TTXPASQL01.TMAN503_XILINX.dba.ccticket cct, TTXPASQL01.TMAN503_XILINX.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
--and cct.valcarriercode = id.valcarriercode


update id
set id.matchedind = '2'
from TTXPASQL01.TMAN503_XILINX.dba.invoicedetail id, TTXPASQL01.TMAN503_XILINX.dba.ccticket cct, TTXPASQL01.TMAN503_XILINX.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' 
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
--and cct.valcarriercode = id.valcarriercode and id.matchedind is null

GO

ALTER AUTHORIZATION ON [dbo].[sp_XILCCVI] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Currency]    Script Date: 7/7/2015 12:09:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Currency](
	[BaseCurrCode] [varchar](3) NOT NULL,
	[CurrCode] [varchar](3) NOT NULL,
	[CurrBeginDate] [datetime] NOT NULL,
	[CurrEndDate] [datetime] NULL,
	[BaseUnitsPerCurr] [float] NULL,
	[CurrUnitsPerBase] [float] NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED 
(
	[BaseCurrCode] ASC,
	[CurrCode] ASC,
	[CurrBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Currency] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Client]    Script Date: 7/7/2015 12:09:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Client](
	[ClientCode] [varchar](15) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[STATE] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[CustPhone] [varchar](20) NULL,
	[CountryCode] [varchar](5) NULL,
	[AttnLine] [varchar](40) NULL,
	[Email] [varchar](80) NULL,
	[ConsolidationCode] [varchar](50) NULL,
	[ClientRemark1] [varchar](255) NULL,
	[ClientRemark2] [varchar](255) NULL,
	[ClientRemark3] [varchar](255) NULL,
	[ClientRemark4] [varchar](255) NULL,
	[ClientRemark5] [varchar](255) NULL,
	[ClientRemark6] [varchar](255) NULL,
	[ClientRemark7] [varchar](255) NULL,
	[ClientRemark8] [varchar](255) NULL,
	[ClientRemark9] [varchar](255) NULL,
	[ClientRemark10] [varchar](255) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientCode] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCTicket]    Script Date: 7/7/2015 12:09:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCTicket](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[TktReferenceNum] [varchar](23) NULL,
	[TicketNum] [varchar](10) NULL,
	[ValCarrierCode] [varchar](3) NULL,
	[ValCarrierNum] [int] NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCTicket] ADD [TktOriginatingCCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[CCTicket] ADD [CostCenter] [varchar](14) NULL
ALTER TABLE [dba].[CCTicket] ADD [EmployeeId] [varchar](20) NULL
ALTER TABLE [dba].[CCTicket] ADD [SSNum] [varchar](11) NULL
ALTER TABLE [dba].[CCTicket] ADD [TransFeeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCTicket] ADD [IssuerCity] [varchar](30) NULL
ALTER TABLE [dba].[CCTicket] ADD [IssuerState] [varchar](6) NULL
ALTER TABLE [dba].[CCTicket] ADD [ServiceDate] [datetime] NULL
ALTER TABLE [dba].[CCTicket] ADD [Routing] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [ClassOfService] [varchar](20) NULL
ALTER TABLE [dba].[CCTicket] ADD [TicketIssuer] [varchar](37) NULL
ALTER TABLE [dba].[CCTicket] ADD [BookedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCTicket] ADD [PassengerName] [varchar](50) NULL
ALTER TABLE [dba].[CCTicket] ADD [OrigTicketNum] [varchar](10) NULL
ALTER TABLE [dba].[CCTicket] ADD [Remarks1] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [Remarks2] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [Remarks3] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [PurgeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCTicket] ADD [BilledDate] [datetime] NULL
ALTER TABLE [dba].[CCTicket] ADD [CarrierStr] [varchar](30) NULL
ALTER TABLE [dba].[CCTicket] ADD [TicketAmt] [float] NULL
ALTER TABLE [dba].[CCTicket] ADD [BilledCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCTicket] ADD [BatchName] [varchar](30) NULL
ALTER TABLE [dba].[CCTicket] ADD [MerchantId] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedRecordKey] [varchar](70) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedClientCode] [varchar](15) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedSeqNum] [int] NULL
ALTER TABLE [dba].[CCTicket] ADD [InternationalInd] [varchar](1) NULL
ALTER TABLE [dba].[CCTicket] ADD [Mileage] [float] NULL
ALTER TABLE [dba].[CCTicket] ADD [DaysAdvPurch] [smallint] NULL
ALTER TABLE [dba].[CCTicket] ADD [AdvPurchGroup] [varchar](20) NULL
ALTER TABLE [dba].[CCTicket] ADD [TrueTktCount] [smallint] NULL
ALTER TABLE [dba].[CCTicket] ADD [TripLength] [smallint] NULL
ALTER TABLE [dba].[CCTicket] ADD [ServiceCat] [varchar](2) NULL
ALTER TABLE [dba].[CCTicket] ADD [AlternateName] [varchar](50) NULL
ALTER TABLE [dba].[CCTicket] ADD [AncillaryFeeInd] [int] NULL
 CONSTRAINT [PK_CCTicket] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCTicket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCMerchant]    Script Date: 7/7/2015 12:09:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCMerchant](
	[MerchantId] [varchar](40) NOT NULL,
	[MerchantName1] [varchar](40) NULL,
	[MerchantName2] [varchar](40) NULL,
	[MerchantAddr1] [varchar](40) NULL,
	[MerchantAddr2] [varchar](40) NULL,
	[MerchantAddr3] [varchar](40) NULL,
	[MerchantAddr4] [varchar](40) NULL,
	[MerchantCity] [varchar](40) NULL,
	[MerchantState] [varchar](20) NULL,
	[MerchantZip] [varchar](15) NULL,
	[MerchantCtryCode] [varchar](15) NULL,
	[MerchantCtryName] [varchar](35) NULL,
	[MerchantPhone] [varchar](20) NULL,
	[SICCode] [varchar](4) NULL,
	[MCCCode] [varchar](30) NULL,
	[CorporateId] [varchar](19) NULL,
	[RecordofCharge] [varchar](13) NULL,
	[MerchantIndCode] [varchar](2) NULL,
	[MerchantSubIndCode] [varchar](3) NULL,
	[MerchantFederalTaxId] [varchar](9) NULL,
	[MerchantDunBradNum] [varchar](9) NULL,
	[MerchantOwnerTypeCd] [varchar](2) NULL,
	[MerchantPurchCd] [varchar](2) NULL,
	[PurgeInd] [varchar](1) NULL,
	[GenesisMajorIndCode] [varchar](4) NULL,
	[GenesisDetailIndCode] [varchar](4) NULL,
	[MerchantChain] [varchar](30) NULL,
	[MerchantBrand] [varchar](30) NULL,
	[MasterId] [int] NULL,
 CONSTRAINT [PK_CCMerchant] PRIMARY KEY CLUSTERED 
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCMerchant] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCISOCountry]    Script Date: 7/7/2015 12:10:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCISOCountry](
	[CountryCode] [varchar](8) NOT NULL,
	[CountryName] [varchar](48) NULL,
	[CountryCode3] [varchar](8) NULL,
	[ISOCountryNum] [varchar](3) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[DinersCountryName] [varchar](50) NULL,
 CONSTRAINT [PK_CCISOCountry] PRIMARY KEY CLUSTERED 
(
	[CountryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCISOCountry] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCHotel]    Script Date: 7/7/2015 12:10:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCHotel](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[HtlChainCode] [varchar](5) NULL,
	[HtlReferenceNum] [varchar](23) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCHotel] ADD [HTLOriginatingCCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[CCHotel] ADD [CostCenter] [varchar](14) NULL
ALTER TABLE [dba].[CCHotel] ADD [EmployeeId] [varchar](20) NULL
ALTER TABLE [dba].[CCHotel] ADD [SSNum] [varchar](11) NULL
ALTER TABLE [dba].[CCHotel] ADD [DescOfCharge] [varchar](45) NULL
ALTER TABLE [dba].[CCHotel] ADD [GuestName] [varchar](50) NULL
ALTER TABLE [dba].[CCHotel] ADD [ArrivalDate] [datetime] NULL
ALTER TABLE [dba].[CCHotel] ADD [DepartDate] [datetime] NULL
ALTER TABLE [dba].[CCHotel] ADD [NumNights] [int] NULL
ALTER TABLE [dba].[CCHotel] ADD [NumPeople] [int] NULL
ALTER TABLE [dba].[CCHotel] ADD [RoomRate] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [RoomAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [PhoneAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [PhoneTax] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [FoodAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [RoomServiceAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [RoomServiceTax] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [TipAmt1] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [TipAmt2] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [OtherCharges] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [TotalAuthAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [BilledCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCHotel] ADD [RoomType] [varchar](4) NULL
ALTER TABLE [dba].[CCHotel] ADD [City] [varchar](30) NULL
ALTER TABLE [dba].[CCHotel] ADD [STATE] [varchar](6) NULL
ALTER TABLE [dba].[CCHotel] ADD [FolioNum] [varchar](23) NULL
ALTER TABLE [dba].[CCHotel] ADD [NoShowInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHotel] ADD [PurgeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHotel] ADD [BilledDate] [datetime] NULL
ALTER TABLE [dba].[CCHotel] ADD [BatchName] [varchar](30) NULL
ALTER TABLE [dba].[CCHotel] ADD [MerchantId] [varchar](40) NULL
ALTER TABLE [dba].[CCHotel] ADD [HtlSeqNum] [int] NULL
ALTER TABLE [dba].[CCHotel] ADD [MatchedRecordKey] [varchar](70) NULL
ALTER TABLE [dba].[CCHotel] ADD [MatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCHotel] ADD [MatchedClientCode] [varchar](15) NULL
ALTER TABLE [dba].[CCHotel] ADD [MatchedSeqNum] [int] NULL
ALTER TABLE [dba].[CCHotel] ADD [CountryCode] [varchar](3) NULL
ALTER TABLE [dba].[CCHotel] ADD [InternationalInd] [char](1) NULL
ALTER TABLE [dba].[CCHotel] ADD [MiniBarAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [LoungeBarAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [GiftShopAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [DryCleanAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [ValetAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [MovieAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [BusCtrAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [HlthClbAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [TransAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [ConfRmAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [INetAmt] [float] NULL
ALTER TABLE [dba].[CCHotel] ADD [AncillaryFeeInd] [int] NULL
ALTER TABLE [dba].[CCHotel] ADD [AlternateName] [varchar](50) NULL
 CONSTRAINT [PK_CCHotel] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCHeader]    Script Date: 7/7/2015 12:10:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCHeader](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[MerchantId] [varchar](40) NULL,
	[CCSourceFile] [varchar](10) NULL,
	[RptCreateDate] [datetime] NULL,
	[CCCycleDate] [datetime] NULL,
	[TransactionDate] [datetime] NULL,
	[PostDate] [datetime] NULL,
	[BilledDate] [datetime] NULL,
	[RecordType] [varchar](2) NULL,
	[TransactionNum] [varchar](23) NULL,
	[BatchNum] [varchar](23) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCHeader] ADD [ControlCCNum] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [BasicCCNum] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [CreditCardNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[CCHeader] ADD [ChargeDesc] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [TransactionType] [varchar](5) NULL
ALTER TABLE [dba].[CCHeader] ADD [RefundInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [ChargeType] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [FinancialCatCode] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [DisputedFlag] [varchar](25) NULL
ALTER TABLE [dba].[CCHeader] ADD [CardHolderName] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [LocalCurrAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [LocalTaxAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [LocalCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledTaxAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledTaxAmt2] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCHeader] ADD [BaseFare] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [IndustryCode] [varchar](2) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [PurgeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [BatchName] [varchar](30) NULL
ALTER TABLE [dba].[CCHeader] ADD [CostCenter] [varchar](14) NULL
ALTER TABLE [dba].[CCHeader] ADD [EmployeeId] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [SSNum] [varchar](11) NULL
ALTER TABLE [dba].[CCHeader] ADD [CompanyName] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedRecordKey] [varchar](70) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedClientCode] [varchar](15) NULL
ALTER TABLE [dba].[CCHeader] ADD [CarHtlSeqNum] [int] NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedSeqNum] [int] NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks1] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks2] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks3] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks4] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks5] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks6] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks7] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks8] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks9] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks10] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks11] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks12] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks13] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks14] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks15] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [TransactionFlag] [char](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [TransactionID] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [MarketCode] [varchar](10) NULL
ALTER TABLE [dba].[CCHeader] ADD [ImportDate] [datetime] NULL
ALTER TABLE [dba].[CCHeader] ADD [AncillaryFeeInd] [int] NULL
ALTER TABLE [dba].[CCHeader] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCHeader] ADD [CCLastFour] [varchar](4) NULL
 CONSTRAINT [PK_CCHeader] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCExpense]    Script Date: 7/7/2015 12:10:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCExpense](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[ReferenceNum] [varchar](23) NULL,
	[RocId] [varchar](13) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[UniversalNum] [varchar](20) NULL,
	[Street] [varchar](20) NULL,
	[City] [varchar](18) NULL,
	[STATE] [varchar](2) NULL,
	[Zip] [varchar](10) NULL,
	[CompanyName] [varchar](20) NULL,
	[MChrgDesc1] [varchar](50) NULL,
	[MChrgDesc2] [varchar](50) NULL,
	[MChrgDesc3] [varchar](50) NULL,
	[MChrgDesc4] [varchar](50) NULL,
	[IndustryCode] [varchar](2) NULL,
	[ExpenseSeqNum] [varchar](10) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BilledDate] [datetime] NULL,
	[BilledAmt] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BatchName] [varchar](30) NULL,
	[MerchantId] [varchar](40) NULL,
	[AncillaryFeeInd] [int] NULL,
 CONSTRAINT [PK_CCExpense] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCExpense] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCCar]    Script Date: 7/7/2015 12:10:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCCar](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[CarCompanyCode] [varchar](5) NULL,
	[CarReferenceNum] [varchar](23) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCCar] ADD [CarOriginatingCCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[CCCar] ADD [CostCenter] [varchar](14) NULL
ALTER TABLE [dba].[CCCar] ADD [EmployeeId] [varchar](20) NULL
ALTER TABLE [dba].[CCCar] ADD [SSNum] [varchar](11) NULL
ALTER TABLE [dba].[CCCar] ADD [RentalDate] [datetime] NULL
ALTER TABLE [dba].[CCCar] ADD [RentalLoc] [varchar](30) NULL
ALTER TABLE [dba].[CCCar] ADD [RentalState] [varchar](2) NULL
ALTER TABLE [dba].[CCCar] ADD [ReturnDate] [datetime] NULL
ALTER TABLE [dba].[CCCar] ADD [ReturnLoc] [varchar](30) NULL
ALTER TABLE [dba].[CCCar] ADD [ReturnState] [varchar](2) NULL
ALTER TABLE [dba].[CCCar] ADD [RenterName] [varchar](50) NULL
ALTER TABLE [dba].[CCCar] ADD [NumDays] [int] NULL
ALTER TABLE [dba].[CCCar] ADD [RentalAgreementNum] [varchar](23) NULL
ALTER TABLE [dba].[CCCar] ADD [CarId] [varchar](15) NULL
ALTER TABLE [dba].[CCCar] ADD [CarClass] [varchar](4) NULL
ALTER TABLE [dba].[CCCar] ADD [CarDesc] [varchar](42) NULL
ALTER TABLE [dba].[CCCar] ADD [Mileage] [float] NULL
ALTER TABLE [dba].[CCCar] ADD [GasAmt] [float] NULL
ALTER TABLE [dba].[CCCar] ADD [TotalAuthAmt] [float] NULL
ALTER TABLE [dba].[CCCar] ADD [BilledCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCCar] ADD [PurgeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCCar] ADD [BilledDate] [datetime] NULL
ALTER TABLE [dba].[CCCar] ADD [BatchName] [varchar](30) NULL
ALTER TABLE [dba].[CCCar] ADD [MerchantId] [varchar](40) NULL
ALTER TABLE [dba].[CCCar] ADD [CarSeqNum] [int] NULL
ALTER TABLE [dba].[CCCar] ADD [MatchedRecordKey] [varchar](70) NULL
ALTER TABLE [dba].[CCCar] ADD [MatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCCar] ADD [MatchedClientCode] [varchar](15) NULL
ALTER TABLE [dba].[CCCar] ADD [MatchedSeqNum] [int] NULL
ALTER TABLE [dba].[CCCar] ADD [RentalCountryCode] [varchar](3) NULL
ALTER TABLE [dba].[CCCar] ADD [ReturnCountryCode] [varchar](3) NULL
ALTER TABLE [dba].[CCCar] ADD [InternationalInd] [char](1) NULL
ALTER TABLE [dba].[CCCar] ADD [AlternateName] [varchar](50) NULL
 CONSTRAINT [PK_CCCar] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCCar] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCAirSeg]    Script Date: 7/7/2015 12:11:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCAirSeg](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[ClientCode] [varchar](15) NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[SegmentCarrierCode] [varchar](2) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[FlightNum] [varchar](6) NULL,
	[FareBasis] [varchar](15) NULL,
	[ClassofService] [varchar](2) NULL,
	[OriginCityCode] [varchar](3) NULL,
	[ConnectionInd] [varchar](15) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[SEGDestCityCode] [varchar](3) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [smallint] NULL,
	[SEGMktOrigCityCode] [varchar](3) NULL,
	[SEGMktDestCityCode] [varchar](3) NULL,
	[SEGReturnInd] [char](1) NULL,
	[MINDestCityCode] [varchar](3) NULL,
	[MINInternationalInd] [char](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [smallint] NULL,
	[MINMktOrigCityCode] [varchar](3) NULL,
	[MINMktDestCityCode] [varchar](3) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [smallint] NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](2) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[MealName] [varchar](4) NULL,
	[AirCurrCode] [varchar](3) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCAirSeg] ADD [SEGArriveTime] [varchar](5) NULL
 CONSTRAINT [PK_CCAirSeg] PRIMARY KEY CLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCAirSeg] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CardHolder]    Script Date: 7/7/2015 12:11:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CardHolder](
	[HeaderTrailerTransactionCode] [decimal](1, 0) NULL,
	[HeaderTrailerCompanyIdentification] [decimal](10, 0) NULL,
	[HeaderTrailerSequenceNumber] [decimal](5, 0) NULL,
	[LoadTransactionCode] [decimal](1, 0) NULL,
	[CompanyIdentification] [decimal](10, 0) NULL,
	[CardholderIdentification] [varchar](20) NULL,
	[HierarchyNode] [varchar](40) NULL,
	[FirstName] [varchar](20) NULL,
	[LastName] [varchar](20) NULL,
	[AddressLine1] [varchar](40) NULL,
	[AddressLine2] [varchar](40) NULL,
	[City] [varchar](20) NULL,
	[StateProvinceCode] [varchar](4) NULL,
	[ISOCountryCode] [decimal](5, 0) NULL,
	[PostalCode] [varchar](14) NULL,
	[AddressLine3] [varchar](40) NULL,
	[MailStop] [varchar](14) NULL,
	[PhoneNumber] [varchar](14) NULL,
	[FaxNumber] [varchar](14) NULL,
	[SSNOtherID] [varchar](20) NULL,
	[TrainingDate] [datetime] NULL,
	[EmailAddress] [varchar](128) NULL,
	[AuthorizedUser1] [varchar](26) NULL,
	[AuthorizedUser2] [varchar](26) NULL,
	[AuthorizedUser3] [varchar](26) NULL,
	[EmployeeID] [varchar](10) NULL,
	[HomePhoneNumber] [varchar](14) NULL,
	[MiddleName] [varchar](30) NULL,
	[VisaCommerceBuyerID] [varchar](19) NULL,
	[VehicleID] [varchar](20) NULL,
	[MiscellaneousField1] [varchar](16) NULL,
	[MiscellaneousField1Description] [varchar](26) NULL,
	[MiscellaneousField2] [varchar](16) NULL,
	[MiscellaneousField2Description] [varchar](26) NULL,
	[OptionalField1] [varchar](26) NULL,
	[OptionalField2] [varchar](26) NULL,
	[OptionalField3] [varchar](26) NULL,
	[OptionalField4] [varchar](26) NULL,
	[TrxId] [bigint] NULL,
	[TrxDate] [varchar](68) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CardHolder] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CardAccount]    Script Date: 7/7/2015 12:11:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CardAccount](
	[HeaderTrailerTransactionCode] [decimal](1, 0) NULL,
	[HeaderTrailerCompanyIdentification] [decimal](10, 0) NULL,
	[HeaderTrailerSequenceNumber] [decimal](5, 0) NULL,
	[LoadTransactionCode] [decimal](1, 0) NULL,
	[CardholderIdentification] [varchar](20) NULL,
	[AccountNumber] [varchar](19) NULL,
	[HierarchyNode] [varchar](40) NULL,
	[EffectiveDate] [datetime] NULL,
	[AccountOpenDate] [datetime] NULL,
	[AccountCloseDate] [datetime] NULL,
	[CardExpireDate] [datetime] NULL,
	[CardType] [decimal](1, 0) NULL,
	[SpendingLimit] [decimal](16, 2) NULL,
	[StatementType] [decimal](1, 0) NULL,
	[LastRevisionDate] [datetime] NULL,
	[TransactionSpendingLimit] [decimal](16, 2) NULL,
	[CorporationPaymentIndicator] [decimal](1, 0) NULL,
	[BillingAccountNumber] [varchar](19) NULL,
	[CostCenter] [varchar](50) NULL,
	[GLSubAccount] [varchar](76) NULL,
	[TransactionDailyLimit] [decimal](8, 0) NULL,
	[TransactionCycleLimit] [decimal](8, 0) NULL,
	[CashLimitAmount] [decimal](16, 2) NULL,
	[StatusCode] [decimal](2, 0) NULL,
	[ReasonStatusCode] [decimal](2, 0) NULL,
	[StatusDate] [datetime] NULL,
	[PreFundedIndicator] [decimal](1, 0) NULL,
	[CityPairProgramIndicator] [decimal](1, 0) NULL,
	[TaskOrderNumber] [varchar](26) NULL,
	[FleetServiceIndicator] [decimal](1, 0) NULL,
	[CreditRating] [varchar](2) NULL,
	[CreditRatingDate] [datetime] NULL,
	[AnnualFeeFlag] [decimal](1, 0) NULL,
	[AnnualFeeMonth] [decimal](2, 0) NULL,
	[CardReceiptVerificationFlag] [decimal](1, 0) NULL,
	[CheckIndicator] [decimal](1, 0) NULL,
	[AccountTypeFlag] [decimal](1, 0) NULL,
	[LostStolenDate] [datetime] NULL,
	[ChargeOffDate] [datetime] NULL,
	[ChargeOffAmount] [decimal](16, 2) NULL,
	[TransferAccountNumber] [varchar](19) NULL,
	[CallingCardPhoneType] [varchar](2) NULL,
	[EmbossLine1] [varchar](50) NULL,
	[EmbossLine2] [varchar](50) NULL,
	[LastCreditLimitChangeDate] [datetime] NULL,
	[LastMaintenanceDateNAR] [datetime] NULL,
	[OptionalField1] [varchar](26) NULL,
	[OptionalField2] [varchar](26) NULL,
	[OptionalField3] [varchar](26) NULL,
	[OptionalField4] [varchar](26) NULL,
	[TrxId] [bigint] NULL,
	[TrxDate] [varchar](68) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CardAccount] TO  SCHEMA OWNER 
GO

/****** Object:  Index [CCTicketI1]    Script Date: 7/7/2015 12:11:35 PM ******/
CREATE CLUSTERED INDEX [CCTicketI1] ON [dba].[CCTicket]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCHotelI1]    Script Date: 7/7/2015 12:11:37 PM ******/
CREATE CLUSTERED INDEX [CCHotelI1] ON [dba].[CCHotel]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCHeaderI1]    Script Date: 7/7/2015 12:11:37 PM ******/
CREATE CLUSTERED INDEX [CCHeaderI1] ON [dba].[CCHeader]
(
	[IataNum] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[MatchedInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCExpenseI1]    Script Date: 7/7/2015 12:11:38 PM ******/
CREATE CLUSTERED INDEX [CCExpenseI1] ON [dba].[CCExpense]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCCarI1]    Script Date: 7/7/2015 12:11:38 PM ******/
CREATE CLUSTERED INDEX [CCCarI1] ON [dba].[CCCar]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCTicketI2]    Script Date: 7/7/2015 12:11:39 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI2] ON [dba].[CCTicket]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI3]    Script Date: 7/7/2015 12:11:39 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI3] ON [dba].[CCTicket]
(
	[TicketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI4]    Script Date: 7/7/2015 12:11:39 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI4] ON [dba].[CCTicket]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI5]    Script Date: 7/7/2015 12:11:39 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI5] ON [dba].[CCTicket]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCMerchantI2]    Script Date: 7/7/2015 12:11:40 PM ******/
CREATE NONCLUSTERED INDEX [CCMerchantI2] ON [dba].[CCMerchant]
(
	[MerchantCtryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCHotelI2]    Script Date: 7/7/2015 12:11:40 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI2] ON [dba].[CCHotel]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHotelI3]    Script Date: 7/7/2015 12:11:40 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI3] ON [dba].[CCHotel]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHotelI4]    Script Date: 7/7/2015 12:11:40 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI4] ON [dba].[CCHotel]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_AncFee]    Script Date: 7/7/2015 12:11:40 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_AncFee] ON [dba].[CCHeader]
(
	[AncillaryFeeInd] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[BilledCurrCode] ASC
)
INCLUDE ( 	[BilledAmt]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_I3]    Script Date: 7/7/2015 12:11:41 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_I3] ON [dba].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)
INCLUDE ( 	[MatchedRecordKey],
	[MatchedIataNum],
	[MatchedClientCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_I4]    Script Date: 7/7/2015 12:11:42 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_I4] ON [dba].[CCHeader]
(
	[MatchedRecordKey] ASC,
	[MatchedIataNum] ASC,
	[MatchedClientCode] ASC,
	[CarHtlSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_PX]    Script Date: 7/7/2015 12:11:44 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCHeader_PX] ON [dba].[CCHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CCHeaderI2]    Script Date: 7/7/2015 12:11:45 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI2] ON [dba].[CCHeader]
(
	[BilledDate] ASC,
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeaderI3]    Script Date: 7/7/2015 12:11:45 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI3] ON [dba].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [IX_CCHEADER_IMPORTDATE]    Script Date: 7/7/2015 12:11:46 PM ******/
CREATE NONCLUSTERED INDEX [IX_CCHEADER_IMPORTDATE] ON [dba].[CCHeader]
(
	[ImportDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [CCExpenseI2]    Script Date: 7/7/2015 12:11:46 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI2] ON [dba].[CCExpense]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCExpenseI3]    Script Date: 7/7/2015 12:11:47 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI3] ON [dba].[CCExpense]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCExpenseI4]    Script Date: 7/7/2015 12:11:47 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI4] ON [dba].[CCExpense]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCCarI2]    Script Date: 7/7/2015 12:11:48 PM ******/
CREATE NONCLUSTERED INDEX [CCCarI2] ON [dba].[CCCar]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCCarI3]    Script Date: 7/7/2015 12:11:48 PM ******/
CREATE NONCLUSTERED INDEX [CCCarI3] ON [dba].[CCCar]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCCarI4]    Script Date: 7/7/2015 12:11:48 PM ******/
CREATE NONCLUSTERED INDEX [CCCarI4] ON [dba].[CCCar]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

