/****** Object:  StoredProcedure [dbo].[sp_TRPAX22]    Script Date: 7/7/2015 1:10:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_TRPAX22]
	
 AS



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



--Ancillary fee updates per Jim on 2013-02-27
update dba.ccticket
set ancillaryfeeind = 1
where ticketissuer like '%1ST BAG FEE%'
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 1
where ticketissuer like '%BAGGAGE FEE%'
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
set ancillaryfeeind = 16
where ticketissuer like '%*INFLT%'
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
and substring(ticketnum,1,2) in ('29','26') and valcarriercode = 'CO'
and ticketamt in (23,25)
and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where ancillaryfeeind is null
and substring(ticketnum,1,2) in ('29','26') and valcarriercode = 'CO'
and ticketamt in (27,30,32,35,45,50,9,10) and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AA'
and ticketamt in (25)
and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AA'
and ticketamt in (35,30,50,60)
and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AA'
and ticketamt in (100)
and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null



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
and ticketamt in (3.29,5.29,6,4.49,8.29,10,7) and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'DL'
and ticketamt in (23,25,32,35,27,30,50,55) and substring(ticketnum,1,2) IN ('25','29','82') and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'DL'
and ticketamt in (32,35,27,30,50,55)
and substring(ticketnum,1,2) IN ('25','29','82') and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'UA'
and ticketamt in (25)
and substring(ticketnum,1,2) IN ('40','46','45') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'UA'
and ticketamt in (35,50)
and substring(ticketnum,1,2) IN ('40','46','45') and ancillaryfeeind is null and matchedrecordkey is null



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
and substring(ticketnum,1,2) IN ('16','26','27') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'LH'
and ticketamt in (150)
and substring(ticketnum,1,2) IN ('16','26','27') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'BA'
and ((ticketamt in (40,50,48,60)
and billedcurrcode = 'USD'
and matchedrecordkey is null
OR ticketamt in (28,35,32,40)
and billedcurrcode = 'GBP'))
and substring(ticketnum,1,2) IN ('26','90') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'BA'
and ((ticketamt in (112,140)
and billedcurrcode = 'USD'
and matchedrecordkey is null
OR ticketamt in (72,90)
and billedcurrcode = 'GBP'))
and substring(ticketnum,1,2) IN ('26','90') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'SQ'
and ticketamt in (8,12,22,50,15,30,55,40,60,50,109,150,84,110,121,117,160,94,115,130,129,149,165,128)
and substring(ticketnum,1,2) IN ('16','18') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AF'
and ticketamt in (55,100)
and substring(ticketnum,1,2) in ('82','16') and ancillaryfeeind is null and matchedrecordkey is null



update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AF'
and ticketamt in (200)
and substring(ticketnum,1,2) in ('82','16') and ancillaryfeeind is null and matchedrecordkey is null


update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AS'
and ticketamt in (20)
and substring(ticketnum,1,2) in ('21','16') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 4
where valcarriercode = 'AS'
and ticketamt in (50)
and substring(ticketnum,1,2) in ('21','16') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AC'
and ticketamt in (30,50,75,100,225)
and substring(ticketnum,1,2) in ('20','51') and matchedrecordkey is null and ancillaryfeeind is null




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

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer in ('AIR NEW ZEALAND EXCESS BAG WL7', 'AIR NEW ZEALAND EXCESS BAG CH8', 'MAS EXCESS BAGGAGE - DOME', 'VIRGIN ATLANTIC CC ANCILLARIES', 'AIR NEW ZEALAND EXCESS BAG AK7') and matchedrecordkey is null and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 16
where ticketissuer in ('JETBLUE BUY ON BOARD', 'AMTRAK ONBOARD/ BOS 0049', 'ALASKA AIRLINES IN FLIGHT', 'FRONTIER ON BOARD SALES', 'AMTRAK ONBOARD/ PDX  WASHINGTON', 'AMTRAK ONBOARD/ PHL  WASHINGTON', 'KOREAN AIR DUTY-FREE (  )', 'WESTJET-BUY ON BOARD', 'ONBOARD SALES', 'AMTRAK ONBOARD/ SAC  WASHINGTON', 'EVA AIRWAYS IN FLIGHT DUTY FEE', 'AMTRAK ONBOARD/ NYP  WASHINGTON', 'EL AL DUTY FREE', 'SOUTHWEST ON BOARD', 'AMTRAK ONBOARD/ HAR  WASHINGTON', 'AMTRAK ONBOARD/ RVR  WASHINGTON', 'AMTRAK ONBOARD/ WAS  WASHINGTON', 'AMTRAK ONBOARD/ OAK  WASHINGTON', 'KOREAN AIR DUTY-FREE ($)') and matchedrecordkey is null and ancillaryfeeind is null



update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer in ('AIR DO INTERNET', 'SOUTHWEST ONBOARD INTERNT', 'AIR FRANCE USA INTERNET') and matchedrecordkey is null and ancillaryfeeind is null



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
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('AMTRAK - CAP CORR CAFE', 'AMTRAK - SURFLINER CAFE', 'AMTRAK CASCADES CAFE', 'AMTRAK FOOD & BEVERAGE', 'AMTRAK-CAFE', 'AMTRAK-DINING CAR', 'AMTRAK-EAST CAFE', 'AMTRAK-MIDWEST CAFE', 'AMTRAK-NORTHEAST CAFE', 'AMTRAK-SAN JOAQUINS CAFE') and ancillaryfeeind is null



update ce
set ancillaryfeeind = 60
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and merchantname1 in ('AA ADMIRAL CLUB AUS', 'AA ADMIRAL CLUB LAX', 'AA ADMIRAL CLUB LGA D3', 'AA ADMIRALS CLUB MIAMI D', 'AIR CANADA CLUB', 'AMERICAN EXPRESS PLATINUM LOUNGE') and ancillaryfeeind is null



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
where (( chargedesc like '%1ST BAG FEE%' OR ChargeDesc like '%baggage fee%' )) and ancillaryfeeind is null

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
OR ChargeDesc like '%PURCHASE ON JETBLUE%' )) and ancillaryfeeind is null

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
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%admirals club%' 
  or ccm.merchantname1 like '%admiral club%'
  or ccm.merchantname1 like '%CONTINENTAL PRESIDENT%'
  or ccm.merchantname1 like '%RED CARPET CLUB%'
  or ccm.merchantname1 like '%AIRWAYS CLUB%'
  or ccm.merchantname1 like '%club spirit%')) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 7
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%DELTA AIR CARGO%' )) and cct.ancillaryfeeind is null

update cct
set ancillaryfeeind = 16
 from dba.ccticket cct
INNER JOIN DBA.CCHeader cch ON ( cct.recordkey = cch.recordkey and cct.iatanum = cch.iatanum ) INNER JOIN DBA.CCMerchant ccm ON ( cct.MerchantId = ccm.merchantid ) where ((ccm.merchantname1 like '%FRONTIER ON BOARD SALES%' 
  or ccm.merchantname1 like '%HORIZON AIR INFLIGHT%'
  or ccm.merchantname1 like '%IN FLIGHT SALES%'
  or ccm.merchantname1 like '%IN-FLIGHT PRCHASE JETBLUE%'
  or ccm.merchantname1 like '%ONBOARD SALES%'
  or ccm.merchantname1 like '%SOUTHWEST ON BOARD%'
  or ccm.merchantname1 like '%UNITED AIRLINES ONBOARD%'
  or ccm.merchantname1 like '%US AIRWAYS COMPANY STORE%'
  or ccm.merchantname1 like '%INFLIGHT ENTERTAINMENT%'
  or ccm.merchantname1 like '%SNCB/NMBS ON-BOARD%'
  or ccm.merchantname1 like '%SNACK BAR T2%')) and cct.ancillaryfeeind is null

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
and ticketamt = 7
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '17'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and issuercity = 'delta.com'
and ticketamt = 9
and ancillaryfeeind is null

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
and ticketamt in (40, 50)
and ancillaryfeeind is null
and matchedrecordkey is null


update ce
set ancillaryfeeind = 20
from dba.ccexpense ce, dba.ccmerchant cm where ce.merchantid = cm.merchantid and ((cm.merchantname1 like '%AIPORTWIRELESS%' 
OR cm.merchantname1 like '%AIRPORT WIRELESS%'
OR cm.merchantname1 like '%BOINGO%'
OR cm.merchantname1 like '%SWA INFLIGHT WIFI%'
OR cm.merchantname1 like 'VIASAT'
))
and ce.ancillaryfeeind is null


update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%')) and valcarriercode = 'DL'
and ticketamt = 59
and ancillaryfeeind is null
and matchedrecordkey is null

-----------------

--******************************

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



GO

ALTER AUTHORIZATION ON [dbo].[sp_TRPAX22] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCTicket]    Script Date: 7/7/2015 1:10:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[CCTicket](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[TktReferenceNum] [varchar](23) NULL,
	[TicketNum] [varchar](10) NULL,
	[ValCarrierCode] [varchar](3) NULL,
	[ValCarrierNum] [int] NULL,
	[TktOriginatingCCNum] [varchar](50) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[TransFeeInd] [varchar](1) NULL,
	[IssuerCity] [varchar](30) NULL,
	[IssuerState] [varchar](6) NULL,
	[ServiceDate] [datetime] NULL,
	[Routing] [varchar](40) NULL,
	[ClassOfService] [varchar](20) NULL,
	[TicketIssuer] [varchar](37) NULL,
	[BookedIataNum] [varchar](8) NULL,
	[PassengerName] [varchar](50) NULL,
	[OrigTicketNum] [varchar](10) NULL,
	[Remarks1] [varchar](40) NULL,
	[Remarks2] [varchar](40) NULL,
	[Remarks3] [varchar](40) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BilledDate] [datetime] NULL,
	[CarrierStr] [varchar](30) NULL,
	[TicketAmt] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BatchName] [varchar](30) NULL,
	[MerchantId] [varchar](40) NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[MatchedSeqNum] [int] NULL,
	[InternationalInd] [varchar](1) NULL,
	[Mileage] [float] NULL,
	[DaysAdvPurch] [smallint] NULL,
	[AdvPurchGroup] [varchar](20) NULL,
	[TrueTktCount] [smallint] NULL,
	[TripLength] [smallint] NULL,
	[ServiceCat] [varchar](2) NULL,
	[AlternateName] [varchar](50) NULL,
	[AncillaryFeeInd] [int] NULL,
 CONSTRAINT [PK_CCTicket] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCTicket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCMerchant]    Script Date: 7/7/2015 1:11:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
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
	[MCCCode] [varchar](10) NULL,
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

/****** Object:  Table [dba].[CCISOCountry]    Script Date: 7/7/2015 1:11:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
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

/****** Object:  Table [dba].[CCHeader]    Script Date: 7/7/2015 1:11:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
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
	[BatchNum] [varchar](23) NULL,
	[ControlCCNum] [varchar](50) NULL,
	[BasicCCNum] [varchar](50) NULL,
	[CreditCardNum] [varchar](50) NULL,
	[ChargeDesc] [varchar](50) NULL,
	[TransactionType] [varchar](5) NULL,
	[RefundInd] [varchar](1) NULL,
	[ChargeType] [varchar](20) NULL,
	[FinancialCatCode] [varchar](1) NULL,
	[DisputedFlag] [varchar](25) NULL,
	[CardHolderName] [varchar](50) NULL,
	[LocalCurrAmt] [float] NULL,
	[LocalTaxAmt] [float] NULL,
	[LocalCurrCode] [varchar](3) NULL,
	[BilledAmt] [float] NULL,
	[BilledTaxAmt] [float] NULL,
	[BilledTaxAmt2] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BaseFare] [float] NULL,
	[IndustryCode] [varchar](2) NULL,
	[MatchedInd] [varchar](1) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BatchName] [varchar](30) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[CompanyName] [varchar](20) NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[CarHtlSeqNum] [int] NULL,
	[MatchedSeqNum] [int] NULL,
	[Remarks1] [varchar](40) NULL,
	[Remarks2] [varchar](40) NULL,
	[Remarks3] [varchar](40) NULL,
	[Remarks4] [varchar](40) NULL,
	[Remarks5] [varchar](40) NULL,
	[Remarks6] [varchar](40) NULL,
	[Remarks7] [varchar](40) NULL,
	[Remarks8] [varchar](40) NULL,
	[Remarks9] [varchar](40) NULL,
	[Remarks10] [varchar](40) NULL,
	[Remarks11] [varchar](40) NULL,
	[Remarks12] [varchar](40) NULL,
	[Remarks13] [varchar](40) NULL,
	[Remarks14] [varchar](40) NULL,
	[Remarks15] [varchar](40) NULL,
	[TransactionFlag] [char](1) NULL,
	[TransactionID] [varchar](20) NULL,
	[MarketCode] [varchar](10) NULL,
	[ImportDate] [datetime] NULL,
	[AncillaryFeeInd] [int] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[OriginatingCMAcctNum] [varchar](20) NULL,
 CONSTRAINT [PK_CCHeader] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCExpense]    Script Date: 7/7/2015 1:11:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
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

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI1]    Script Date: 7/7/2015 1:11:38 PM ******/
CREATE CLUSTERED INDEX [CCTicketI1] ON [dba].[CCTicket]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI1]    Script Date: 7/7/2015 1:11:38 PM ******/
CREATE CLUSTERED INDEX [CCHeaderI1] ON [dba].[CCHeader]
(
	[IataNum] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[MatchedInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCExpenseI1]    Script Date: 7/7/2015 1:11:40 PM ******/
CREATE CLUSTERED INDEX [CCExpenseI1] ON [dba].[CCExpense]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCTicketI2]    Script Date: 7/7/2015 1:11:41 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI2] ON [dba].[CCTicket]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI3]    Script Date: 7/7/2015 1:11:42 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI3] ON [dba].[CCTicket]
(
	[TicketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI4]    Script Date: 7/7/2015 1:11:42 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI4] ON [dba].[CCTicket]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI5]    Script Date: 7/7/2015 1:11:42 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI5] ON [dba].[CCTicket]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCMerchantI2]    Script Date: 7/7/2015 1:11:42 PM ******/
CREATE NONCLUSTERED INDEX [CCMerchantI2] ON [dba].[CCMerchant]
(
	[MerchantCtryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeader_AncFee]    Script Date: 7/7/2015 1:11:42 PM ******/
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

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI2]    Script Date: 7/7/2015 1:11:43 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI2] ON [dba].[CCHeader]
(
	[BilledDate] ASC,
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI3]    Script Date: 7/7/2015 1:11:44 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI3] ON [dba].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [IX_CCHEADER_IMPORTDATE]    Script Date: 7/7/2015 1:11:44 PM ******/
CREATE NONCLUSTERED INDEX [IX_CCHEADER_IMPORTDATE] ON [dba].[CCHeader]
(
	[ImportDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [CCExpenseI2]    Script Date: 7/7/2015 1:11:44 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI2] ON [dba].[CCExpense]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCExpenseI3]    Script Date: 7/7/2015 1:11:44 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI3] ON [dba].[CCExpense]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCExpenseI4]    Script Date: 7/7/2015 1:11:45 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI4] ON [dba].[CCExpense]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

