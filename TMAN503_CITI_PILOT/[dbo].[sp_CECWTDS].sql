/****** Object:  StoredProcedure [dbo].[sp_CECWTDS]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_CECWTDS]


AS

SET NOCOUNT ON

---HNN Cleanup for DEA


update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set masterid = -1
where masterid is null
and (htlpropertyname like 'OTHER%HOTELS%' or htlpropertyname like '%NONAME%')
and (HtlAddr1 is null or HtlAddr1 = '' )


 update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = '')
and (HtlAddr1 is null or HtlAddr1 = '' )


update h
set h.htlcountrycode = ct.countrycode
,h.htlstate = ct.stateprovincecode
from TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel h, TTXPASQL01.TMAN503_CITI_PILOT.dba.city ct
where h.htlcitycode = ct.citycode
and  h.masterid is null
and h.htlcountrycode is null
and ct.countrycode <> 'ZZ'
and ct.typecode ='a'

update t1
set t1.htlstate = t2.stateprovincecode
from TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel t1, TTXPASQL01.TMAN503_CITI_PILOT.dba.city t2
where t2.typecode = 'A'
and t1.htlcitycode = t2.citycode
and t1.htlcountrycode = t2.countrycode
and t1.htlstate is null
and t1.htlcountrycode = 'US'
and t2.countrycode = 'US'
and t1.masterid is null

update h
set h.htlcountrycode = ct.countrycode
,h.htlstate = ct.stateprovincecode
from TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel h, TTXPASQL01.TMAN503_CITI_PILOT.dba.city ct
where h.htlcitycode = ct.citycode
and  h.masterid is null
and h.htlcountrycode <> ct.countrycode
and ct.typecode ='a'


update ht
set ht.htlstate = zp.state
from TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel ht, TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
where substring(ht.htlpostalcode,1,5) = zp.zipcode
and substring(ht.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P'
and ht.masterid is null
and ht.htlstate is null
and ht.htlcountrycode = 'US'

update dba.hotel
set remarks4 = htlcityname,
htlcityname = substring(htladdr3,1,25)
where iatanum like '%CWT'
and invoicedate >'2012-01-01'
and htlcityname like '.%'
and remarks4 is null
and htladdr3 not like '.%'


update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htladdr3 = htlcityname
where masterid is null
and htlcityname like '.%'
and htladdr3 is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcityname = null
where masterid is null
and htlcityname like '.%'

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = 'AR'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate is null
and htladdr2 = 'ARKANSAS'

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = 'CA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'CA'
and htladdr2 = 'CALIFORNIA'

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = 'GA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'GA'
and htladdr2 = 'GEORGIA'

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = 'MA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'MA'
and htladdr2 = 'MASSACHUSETTS'

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = 'LA'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'LA'
and htladdr2 = 'LOUISIANA'


update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = 'AZ'
where masterid is null
	and htlcountrycode = 'US'
	and htlstate <> 'AZ'
and htladdr2 = 'ARIZONA'


update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = null,
htlcountrycode = 'CA'
where htlcountrycode = 'US'
and htladdr3 = 'CANADA'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = null,
htlcountrycode = 'GB'
where htlcountrycode = 'US'
and htladdr3 = 'UNITED KINGDOM'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = null,
htlcountrycode = 'KR'
where htlcountrycode = 'US'
and htladdr3 = 'SOUTH KOREA'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlstate = null,
htlcountrycode = 'JP'
where htlcountrycode = 'US'
and htladdr3 = 'JAPAN'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'
and HtlCountryCode = 'IN'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcityname = 'NEW YORK'
,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY'
and masterid is null

UPDATE TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
SET HtlCityName = 'WASHINGTON'
,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC'
and masterid is null

	update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
	set htlcityname = 'HERTOGENBOSCH'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%MOEVENPICK HOTEL%'
	
	update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%OAKWOOD CHELSEA%'
	
	update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%LONGACRE HOUSE%'

	update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
	set htlcityname = 'BARCELONA'
	where masterid is null
	and htlcityname not like '[a-z]%'
	and htlpropertyname like '%HOTLE PUNTA PALMA%'
	
update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'CA'
WHERE HTLCITYNAME like 'BEVERLY HILLS%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'MI'
WHERE HTLCITYNAME like 'DETROIT%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'VA'
WHERE HTLCITYNAME like 'CHARLOTTESVILLE%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null
	
update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'PA'
,HTLCITYNAME = 'PHILADELPHIA'
WHERE HTLCITYNAME like 'PHILADELPHIA%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'CA'
,HTLCITYNAME = 'SAN FRANCISCO'
WHERE HTLCITYNAME like 'SAN FRANCISCO%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'DC'
,HTLCITYNAME = 'WASHINGTON'
WHERE HTLCITYNAME like 'WASHINGTON%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'GA'
,HTLCITYNAME = 'ATLANTA'
WHERE HTLCITYNAME like 'ATLANTA%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'TX'
,HTLCITYNAME = 'DALLAS'
WHERE HTLCITYNAME like 'DALLAS%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null
	
update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'CA'
,HTLCITYNAME = 'LOS ANGELES'
WHERE HTLCITYNAME like '%LOS ANGELES%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set htlcountrycode = 'US'
,HTLSTATE = 'NY'
,HTLCITYNAME = 'NEW YORK'
WHERE HTLCITYNAME like '%NEW YORK%'
AND HTLCOUNTRYCODE = 'US'
and masterid is null

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HTLSTATE = 'NC'
WHERE HTLCITYNAME = 'CHARLOTTE'
AND HTLCOUNTRYCODE = 'US'
and masterid is null
and HtlState is NULL

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HTLSTATE = 'SC'
WHERE HTLCITYNAME = 'HILTON HEAD'
AND HTLCOUNTRYCODE = 'US'
and masterid is null
and HtlState is NULL
					
update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HTLSTATE = 'NV',
HtlCityName = 'LAS VEGAS',
HtlCountryCode = 'US'
WHERE HTLCITYNAME = 'NEVADA'
AND HTLCOUNTRYCODE = 'NV'
AND HtlAddr3 = 'NEVADA, NV NV89109'
and masterid is null
and HtlState is NULL

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HTLSTATE = 'NY',
HtlCountryCode = 'US'
WHERE HTLCITYNAME = 'NEW YORK'
AND HTLCOUNTRYCODE = 'NY'
AND HtlAddr3 = 'NEW YORK, NY NY10019'
and masterid is null
and HtlState is NULL

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HtlCountryCode = 'GB'
WHERE HTLCITYNAME = 'LONDON'
AND HTLCOUNTRYCODE = 'UK'
AND HtlAddr3 = 'LONDON, UK SW1A1NY'
and masterid is null
and HtlState is NULL

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HtlCountryCode = 'JP'
WHERE HTLCITYNAME = 'TOKYO'
AND HTLCOUNTRYCODE = '10'
AND HtlAddr3 = 'TOKYO, 13 JP'
and masterid is null
and HtlState is NULL

update TTXPASQL01.TMAN503_CITI_PILOT.dba.hotel
set HtlCountryCode = 'ES'
WHERE HTLCITYNAME = 'BILBAO'
AND HTLCOUNTRYCODE = 'SP'
AND HtlAddr3 = 'BILBAO, SP ES48001'
and masterid is null
and HtlState is NULL


-----******Commenting out until the issue with HNN is resolved.....Updated on 4/28/15 by Nina*******
-- Maureen Rhodes (5/7/2015 6:48 AM) No additioal work to be done. Citi Pilot should not receive HNN #06330683
	
----add to the end after HNN cleanup sql's run
----Data Enhancement Automation HNN Queries
--Declare @HNNBeginDate datetime
--Declare @HNNEndDate datetime

--Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
--from  TTXPASQL01.TMAN503_CITI_PILOT.dba.Hotel
--Where MasterId is NULL
--AND IataNum like 'CE%'
--and issuedate > '2011-12-31'

--EXEC TTXSASQL01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
--@DatamanRequestName = 'CECWTDS',
--@Enhancement = 'HNN',
--@Client = 'Citi_Pilot',
--@Delay = 15,
--@Priority = NULL,
--@Notes = NULL,
--@Suspend = false,
--@RunAtTime = NULL,
--@BeginDate = @HNNBeginDate,
--@EndDate = @HNNEndDate,
--@DateParam1 = NULL,
--@DateParam2 = NULL,
--@TextParam1 = 'agency',
--@TextParam2 = 'TTXPASQL01',
--@TextParam3 = 'TMAN503_Citi_Pilot',
--@TextParam4 = 'DBA',
--@TextParam5 = 'datasvc',
--@TextParam6 = 'tman2009',
--@TextParam7 = 'TTXSASQL03',
--@TextParam8 = 'TTXCENTRAL',
--@TextParam9 = 'DBA',
--@TextParam10 = 'datasvc',
--@TextParam11 = 'tman2009',
--@TextParam12 = 'Push',
--@TextParam13 = 'R',
--@TextParam14 = NULL,
--@TextParam15 = NULL,
--@IntParam1 = NULL,
--@IntParam2 = NULL,
--@IntParam3 = NULL,
--@IntParam4 = NULL,
--@IntParam5 = NULL,
--@BoolParam1 = NULL,
--@BoolParam2 = NULL,
--@BoolParam3 = NULL,
--@BoolParam4 = NULL,
--@BoolParam5 = NULL,
--@BoolParam6 = NULL,
--@BoolParam7 = NULL,
--@BoolParam8 = NULL,
--@BoolParam9 = NULL,
--@BoolParam10 = NULL,
--@CommandLineArgs = NULL

------Execute HNN DEA for Credit Card data
--EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
--@DatamanRequestName = 'CECWTDS',
--@Enhancement = 'HNN',
--@Client = 'Citi_Pilot',
--@Delay = 15,
--@Priority = NULL,
--@Notes = NULL,
--@Suspend = false,
--@RunAtTime = NULL,
--@BeginDate = @HNNBeginDate,
--@EndDate = @HNNEndDate,
--@DateParam1 = NULL,
--@DateParam2 = NULL,
--@TextParam1 = 'card',
--@TextParam2 = 'TTXPASQL01',
--@TextParam3 = 'TMAN503_Citi_Pilot',
--@TextParam4 = 'DBA',
--@TextParam5 = 'datasvc',
--@TextParam6 = 'tman2009',
--@TextParam7 = 'TTXSASQL03',
--@TextParam8 = 'TTXCENTRAL',
--@TextParam9 = 'DBA',
--@TextParam10 = 'datasvc',
--@TextParam11 = 'tman2009',
--@TextParam12 = 'Push',
--@TextParam13 = 'R',
--@TextParam14 = NULL,
--@TextParam15 = NULL,
--@IntParam1 = NULL,
--@IntParam2 = NULL,
--@IntParam3 = NULL,
--@IntParam4 = NULL,
--@IntParam5 = NULL,
--@BoolParam1 = NULL,
--@BoolParam2 = NULL,
--@BoolParam3 = NULL,
--@BoolParam4 = NULL,
--@BoolParam5 = NULL,
--@BoolParam6 = NULL,
--@BoolParam7 = NULL,
--@BoolParam8 = NULL,
--@BoolParam9 = NULL,
--@BoolParam10 = NULL,
--@CommandLineArgs = NULL


GO
