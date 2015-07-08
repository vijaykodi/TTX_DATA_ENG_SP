/****** Object:  StoredProcedure [dbo].[sp_SSBAXCC]    Script Date: 7/7/2015 4:07:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[sp_SSBAXCC]
--@BeginIssueDate datetime,
--@EndIssueDate datetime

 AS


SET NOCOUNT ON

update dba.CCMerchant
set masterid = -1
where masterid is null 
and MerchantId in (select distinct MerchantId
from dba.CCHotel
where iatanum = 'SSBVCF')

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

---stopped here

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
set ancillaryfeeind = 4
where valcarriercode = 'AS'
and ticketamt in (50)
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

--****** added 2/6/2013 *******

update dba.ccticket
set ancillaryfeeind = '15'
where issuercity = 'SKYMILES FEE'

update dba.ccticket
set ancillaryfeeind = '20'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%'))
and valcarriercode = 'DL'
and ticketamt = 7
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '17'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%'))
and valcarriercode = 'DL'
and issuercity = 'delta.com'
and ticketamt = 9
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%'))
and valcarriercode = 'DL'
and ((issuercity <> 'delta.com' or issuercity is null))
and ticketamt = 9
and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%'))
and valcarriercode = 'DL'
and ticketamt in (19, 9.5, 14.5, 29, 29.5, 39, 39.5, 49, 79)
and ancillaryfeeind is null
and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = '7'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%'))
and valcarriercode = 'DL'
and ticketamt in (40, 50)
and ancillaryfeeind is null
and matchedrecordkey is null


update ce
set ancillaryfeeind = 20
from dba.ccexpense ce, dba.ccmerchant cm
where ce.merchantid = cm.merchantid
and ((cm.merchantname1 like '%AIPORTWIRELESS%' 
OR cm.merchantname1 like '%AIRPORT WIRELESS%'
OR cm.merchantname1 like '%BOINGO%'
OR cm.merchantname1 like '%SWA INFLIGHT WIFI%'
OR cm.merchantname1 like 'VIASAT'
))
and ce.ancillaryfeeind is null


update dba.ccticket
set ancillaryfeeind = '12'
where ((ticketnum like '014%' or ticketnum like '015%' or ticketnum like '016%'))
and valcarriercode = 'DL'
and ticketamt = 59
and ancillaryfeeind is null
and matchedrecordkey is null

-----------------
--added 08/29/2013

update dba.ccticket
set ancillaryfeeind = 1
where passengername like '%/1ST BAG%'
and ancillaryfeeind is null

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%GOGOAIR%'
AND ANCILLARYFEEIND IS NULL

UPDATE DBA.CCEXPENSE
SET ANCILLARYFEEIND = 20
WHERE MCHRGDESC1 LIKE '%GOGO DAY PAS%'
AND ANCILLARYFEEIND IS NULL

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


--update ccheader remarks1 - CB - case - 0031709 - 03/03
update cch 
set cch.remarks1 = cch.costcenter 
from dba.ccheader cch 
where costcenter in (select distinct corporatestructure from dba.rollup40) 
and cch.remarks1 is null 

update cch 
set cch.remarks1 = hr.deptid 
from dba.ccheader cch, dba.hierarchy_temp hr 
where cch.employeeid = hr.emplid 
and cch.remarks1 is null 
and hr.enddate >= getdate() 
and cch.transactiondate between hr.begindate and hr.enddate

--Update CCHeader Remarks2 to reflect BTA
--Added on 10/24/14 by Nina per case #00045815
--Modified on 12/11/14 by Nina since the CreditCardNumber is now showing encrypted so I took the FirstSix and LastFour to look for the BTA card 
update dba.CCHeader
set Remarks2 = 'BTA'
where cast(CCFirstSix as Char(6))+CCLastFour in ('3702721009','3702722007','3702722006','3702724009','3702723000','3702721002','3702721006'
,'3702721005','3702721004','3702721003','3702721006','3702721000','3702722001','3702722000','3702721008'
,'3702721008','3702721003','3702721004','3702722008','3702721007','3702723008')
and (Remarks2 <> 'BTA' or Remarks2 is null)


GO

ALTER AUTHORIZATION ON [dbo].[sp_SSBAXCC] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ROLLUP40]    Script Date: 7/7/2015 4:07:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ROLLUP40](
	[COSTRUCTID] [varchar](20) NOT NULL,
	[CORPORATESTRUCTURE] [varchar](40) NOT NULL,
	[DESCRIPTION] [varchar](255) NULL,
	[ROLLUP1] [varchar](40) NULL,
	[ROLLUPDESC1] [varchar](255) NULL,
	[ROLLUP2] [varchar](40) NULL,
	[ROLLUPDESC2] [varchar](255) NULL,
	[ROLLUP3] [varchar](40) NULL,
	[ROLLUPDESC3] [varchar](255) NULL,
	[ROLLUP4] [varchar](40) NULL,
	[ROLLUPDESC4] [varchar](255) NULL,
	[ROLLUP5] [varchar](40) NULL,
	[ROLLUPDESC5] [varchar](255) NULL,
	[ROLLUP6] [varchar](40) NULL,
	[ROLLUPDESC6] [varchar](255) NULL,
	[ROLLUP7] [varchar](40) NULL,
	[ROLLUPDESC7] [varchar](255) NULL,
	[ROLLUP8] [varchar](40) NULL,
	[ROLLUPDESC8] [varchar](255) NULL,
	[ROLLUP9] [varchar](40) NULL,
	[ROLLUPDESC9] [varchar](255) NULL,
	[ROLLUP10] [varchar](40) NULL,
	[ROLLUPDESC10] [varchar](255) NULL,
	[ROLLUP11] [varchar](40) NULL,
	[ROLLUPDESC11] [varchar](255) NULL,
	[ROLLUP12] [varchar](40) NULL,
	[ROLLUPDESC12] [varchar](255) NULL,
	[ROLLUP13] [varchar](40) NULL,
	[ROLLUPDESC13] [varchar](255) NULL,
	[ROLLUP14] [varchar](40) NULL,
	[ROLLUPDESC14] [varchar](255) NULL,
	[ROLLUP15] [varchar](40) NULL,
	[ROLLUPDESC15] [varchar](255) NULL,
	[ROLLUP16] [varchar](40) NULL,
	[ROLLUPDESC16] [varchar](255) NULL,
	[ROLLUP17] [varchar](40) NULL,
	[ROLLUPDESC17] [varchar](255) NULL,
	[ROLLUP18] [varchar](40) NULL,
	[ROLLUPDESC18] [varchar](255) NULL,
	[ROLLUP19] [varchar](40) NULL,
	[ROLLUPDESC19] [varchar](255) NULL,
	[ROLLUP20] [varchar](40) NULL,
	[ROLLUPDESC20] [varchar](255) NULL,
	[ROLLUP21] [varchar](40) NULL,
	[ROLLUPDESC21] [varchar](255) NULL,
	[ROLLUP22] [varchar](40) NULL,
	[ROLLUPDESC22] [varchar](255) NULL,
	[ROLLUP23] [varchar](40) NULL,
	[ROLLUPDESC23] [varchar](255) NULL,
	[ROLLUP24] [varchar](40) NULL,
	[ROLLUPDESC24] [varchar](255) NULL,
	[ROLLUP25] [varchar](40) NULL,
	[ROLLUPDESC25] [varchar](255) NULL,
 CONSTRAINT [PK_ROLLUP40] PRIMARY KEY CLUSTERED 
(
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ROLLUP40] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[hierarchy_temp]    Script Date: 7/7/2015 4:08:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dba].[hierarchy_temp](
	[PayStatusDescr] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[DeptID] [nvarchar](255) NULL,
	[DeptIDDescr] [nvarchar](255) NULL,
	[Co] [nvarchar](255) NULL,
	[OracleCompany] [nvarchar](255) NULL,
	[DeptDate] [nvarchar](255) NULL,
	[Unit] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[EMPLID] [nvarchar](255) NULL,
	[Location] [nvarchar](255) NULL,
	[PrimaryID] [nvarchar](255) NULL,
	[BankTitleDescr] [nvarchar](255) NULL,
	[BankTitleSumm] [nvarchar](255) NULL,
	[MailDrop] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Level1] [nvarchar](255) NULL,
	[Lvl1Name] [nvarchar](255) NULL,
	[Level2] [nvarchar](255) NULL,
	[Lvl2Name] [nvarchar](255) NULL,
	[Level3] [nvarchar](255) NULL,
	[Lvl3Name] [nvarchar](255) NULL,
	[Level4] [nvarchar](255) NULL,
	[Lvl4Name] [nvarchar](255) NULL,
	[Level5] [nvarchar](255) NULL,
	[Lvl5Name] [nvarchar](255) NULL,
	[Level6] [nvarchar](255) NULL,
	[Lvl6Name] [nvarchar](255) NULL,
	[EmployeeClassificationDescr] [nvarchar](255) NULL,
	[SupervisorName] [nvarchar](255) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY]

GO

ALTER AUTHORIZATION ON [dba].[hierarchy_temp] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCTicket]    Script Date: 7/7/2015 4:08:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCTicket](
	[RecordKey] [varchar](100) NOT NULL,
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
ALTER TABLE [dba].[CCTicket] ADD [MatchedRecordKey] [varchar](100) NULL
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCTicket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCMerchant]    Script Date: 7/7/2015 4:08:21 PM ******/
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
	[MasterID] [int] NULL,
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

/****** Object:  Table [dba].[CCHotel]    Script Date: 7/7/2015 4:08:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCHotel](
	[RecordKey] [varchar](100) NOT NULL,
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
ALTER TABLE [dba].[CCHotel] ADD [MatchedRecordKey] [varchar](100) NULL
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
ALTER TABLE [dba].[CCHotel] ADD [AlternateName] [varchar](50) NULL
 CONSTRAINT [PK_CCHotel] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCHeader]    Script Date: 7/7/2015 4:08:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCHeader](
	[RecordKey] [varchar](100) NOT NULL,
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
	[BatchNum] [varchar](24) NULL
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
ALTER TABLE [dba].[CCHeader] ADD [MatchedRecordKey] [varchar](100) NULL
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

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCExpense]    Script Date: 7/7/2015 4:08:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCExpense](
	[RecordKey] [varchar](100) NOT NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCExpense] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCAirSeg]    Script Date: 7/7/2015 4:08:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCAirSeg](
	[RecordKey] [varchar](100) NOT NULL,
	[IATANum] [varchar](8) NULL,
	[SegmentNum] [int] NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[SegmentCarrierCode] [varchar](2) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[FlightNum] [varchar](6) NULL,
	[FareBasis] [varchar](15) NULL,
	[ClassOfService] [varchar](2) NULL,
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
	[AirCurrCode] [varchar](3) NULL,
	[SEGArriveTime] [varchar](5) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCAirSeg] TO  SCHEMA OWNER 
GO

/****** Object:  Index [CCTicketI1]    Script Date: 7/7/2015 4:08:58 PM ******/
CREATE CLUSTERED INDEX [CCTicketI1] ON [dba].[CCTicket]
(
	[TransactionDate] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [CCHotelI1]    Script Date: 7/7/2015 4:08:59 PM ******/
CREATE CLUSTERED INDEX [CCHotelI1] ON [dba].[CCHotel]
(
	[TransactionDate] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [CCHeader_I1]    Script Date: 7/7/2015 4:08:59 PM ******/
CREATE CLUSTERED INDEX [CCHeader_I1] ON [dba].[CCHeader]
(
	[TransactionDate] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCExpenseI1]    Script Date: 7/7/2015 4:08:59 PM ******/
CREATE CLUSTERED INDEX [CCExpenseI1] ON [dba].[CCExpense]
(
	[TransactionDate] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ROLLUPI1]    Script Date: 7/7/2015 4:08:59 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI1] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ROLLUPI2]    Script Date: 7/7/2015 4:08:59 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI2] ON [dba].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ROLLUPI3]    Script Date: 7/7/2015 4:08:59 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI3] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP1] ASC,
	[ROLLUP2] ASC,
	[ROLLUP3] ASC,
	[ROLLUP4] ASC,
	[ROLLUP5] ASC,
	[ROLLUP6] ASC,
	[ROLLUP7] ASC,
	[ROLLUP8] ASC,
	[ROLLUP9] ASC,
	[ROLLUP10] ASC,
	[ROLLUP11] ASC,
	[ROLLUP12] ASC,
	[ROLLUP13] ASC,
	[ROLLUP14] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI1]    Script Date: 7/7/2015 4:09:01 PM ******/
CREATE NONCLUSTERED INDEX [RUI1] ON [dba].[ROLLUP40]
(
	[ROLLUP1] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI10]    Script Date: 7/7/2015 4:09:02 PM ******/
CREATE NONCLUSTERED INDEX [RUI10] ON [dba].[ROLLUP40]
(
	[ROLLUP10] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI2]    Script Date: 7/7/2015 4:09:02 PM ******/
CREATE NONCLUSTERED INDEX [RUI2] ON [dba].[ROLLUP40]
(
	[ROLLUP2] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI3]    Script Date: 7/7/2015 4:09:02 PM ******/
CREATE NONCLUSTERED INDEX [RUI3] ON [dba].[ROLLUP40]
(
	[ROLLUP3] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI4]    Script Date: 7/7/2015 4:09:02 PM ******/
CREATE NONCLUSTERED INDEX [RUI4] ON [dba].[ROLLUP40]
(
	[ROLLUP4] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI5]    Script Date: 7/7/2015 4:09:03 PM ******/
CREATE NONCLUSTERED INDEX [RUI5] ON [dba].[ROLLUP40]
(
	[ROLLUP5] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI6]    Script Date: 7/7/2015 4:09:03 PM ******/
CREATE NONCLUSTERED INDEX [RUI6] ON [dba].[ROLLUP40]
(
	[ROLLUP6] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI7]    Script Date: 7/7/2015 4:09:03 PM ******/
CREATE NONCLUSTERED INDEX [RUI7] ON [dba].[ROLLUP40]
(
	[ROLLUP7] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI8]    Script Date: 7/7/2015 4:09:03 PM ******/
CREATE NONCLUSTERED INDEX [RUI8] ON [dba].[ROLLUP40]
(
	[ROLLUP8] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RUI9]    Script Date: 7/7/2015 4:09:04 PM ******/
CREATE NONCLUSTERED INDEX [RUI9] ON [dba].[ROLLUP40]
(
	[ROLLUP9] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI3]    Script Date: 7/7/2015 4:09:04 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI3] ON [dba].[CCTicket]
(
	[TicketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI5]    Script Date: 7/7/2015 4:09:04 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI5] ON [dba].[CCTicket]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHotelI4]    Script Date: 7/7/2015 4:09:04 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI4] ON [dba].[CCHotel]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_AncFee]    Script Date: 7/7/2015 4:09:04 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_AncFee] ON [dba].[CCHeader]
(
	[AncillaryFeeInd] ASC,
	[IndustryCode] ASC,
	[BilledCurrCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_I3]    Script Date: 7/7/2015 4:09:07 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_I3] ON [dba].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)
INCLUDE ( 	[MatchedRecordKey],
	[MatchedIataNum],
	[MatchedClientCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_I4]    Script Date: 7/7/2015 4:09:07 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_I4] ON [dba].[CCHeader]
(
	[MatchedRecordKey] ASC,
	[MatchedIataNum] ASC,
	[MatchedClientCode] ASC,
	[CarHtlSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_PX]    Script Date: 7/7/2015 4:09:07 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCHeader_PX] ON [dba].[CCHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [IX_CCHEADER_IMPORTDATE]    Script Date: 7/7/2015 4:09:08 PM ******/
CREATE NONCLUSTERED INDEX [IX_CCHEADER_IMPORTDATE] ON [dba].[CCHeader]
(
	[ImportDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [CCExpenseI4]    Script Date: 7/7/2015 4:09:08 PM ******/
CREATE NONCLUSTERED INDEX [CCExpenseI4] ON [dba].[CCExpense]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

