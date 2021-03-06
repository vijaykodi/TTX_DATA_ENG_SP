/****** Object:  StoredProcedure [dbo].[sp_UBSAXCC_All]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UBSAXCC_All]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSAXCC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()
	
 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
SET @TransStart = getdate()
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 


--Log Activity
update dba.ccticket
set valcarriercode = 'CA'
where carrierstr like '%CA%' and valcarriercode = 'A'

update dba.ccticket
set valcarriercode = 'VX'
where carrierstr like '%VX%' and valcarriercode = 'X'

update dba.ccticket
set valcarriercode = 'QF'
where carrierstr like '%QF%' and valcarriercode = 'F'

update dba.ccticket
set valcarriercode = 'BV'
where carrierstr like '%BV%' and valcarriercode = 'V'

update dba.ccticket
set valcarriercode = 'QF'
where carrierstr like '%41%' and valcarriercode = '41'
 
update dba.ccticket
set valcarriercode = 'LH'
where carrierstr like '%LH%' and valcarriercode = 'H'

update dba.ccticket
set valcarriercode = 'CO'
where carrierstr like '%CO%' and valcarriercode = 'O'

update dba.ccticket
set valcarriercode = 'ZZ' where valcarriercode = 'N'

--UPDATED airline Val Carrier Code per Case#12233...TBo 03.12.2013
update ct
set ct.valcarriercode =  
	case when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%AIRASIA%' or ch.CompanyName like '%AIRASIA%') then'AK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%ASIANA%' or ch.CompanyName like '%ASIANA%') then 'OZ'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%AUSTRIAN%' or ch.CompanyName like '%AUSTRIAN%') then 'OS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' AND (ch.chargedesc like '%AVIANCA%' or ch.CompanyName like '%AVIANCA%') THEN 'AV'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%BRITISH AIR%' or ch.CompanyName like '%BRITISH AIR%') THEN 'BA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%BULGARIA AI%' or ch.CompanyName like '%BULGARIA AI%') THEN 'FB'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%CATHAY PA%' or ch.CompanyName like '%CATHAY PA%') THEN 'CX'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%CONDOR FLU%' or ch.CompanyName like '%CONDOR FLU%') THEN 'DE'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%EASYJET%' or ch.CompanyName like '%EASYJET%') THEN 'U2'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%EGYPTAIR%' or ch.CompanyName like '%EGYPTAIR%') THEN 'MS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%EUROWINGS%' or ch.CompanyName like '%EUROWINGS%') THEN 'EW'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%JET AIRW%' or ch.CompanyName like '%JET AIRW%') THEN '9W'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%GERMANWINGS%' or ch.CompanyName like '%GERMANWINGS%') THEN '4U'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%FLYBE%' or ch.CompanyName like '%FLYBE%') THEN 'BE'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%KOREA%' or ch.CompanyName like '%KOREA%') THEN 'KE'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%JET2%' or ch.CompanyName like '%JET2%') THEN 'LS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%COPA%' or ch.CompanyName like '%COPA%') THEN 'CM'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%JETSTAR%' or ch.CompanyName like '%JETSTAR%') THEN 'JQ'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%WEST JET%' or ch.CompanyName like '%WEST JET%') THEN 'WS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%WESTJET%' or ch.CompanyName like '%WESTJET%') THEN 'WS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%VIRGIN%' and ct.valcarriernum = 856 THEN 'DJ'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%VARIG%' or ch.CompanyName like '%VARIG%') THEN 'RG'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%AIGL%' and ct.valcarriernum = 439 THEN 'ZI'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%BABOO%' and ct.valcarriernum = 33 THEN 'F7'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%QANTAS%' THEN 'QF'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%S A S%' OR ch.chargedesc like '%SAS%') THEN  'SK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%SINGAPORE%' THEN 'SQ'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%MALAYSIA%' THEN 'MH'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%SUN COUNT%' THEN 'SY'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%AIR BERLI%' THEN 'AB'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%AIR CHINA%' THEN 'CA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%British AirWays%' then 'BA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'American Airlin%' or ch.companyname like 'American airlin%')then 'AA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'Delta Air%' or ch.CompanyName like 'Delta%') then 'DL'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'japan airlin%' then 'JL'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'scandinavian%' then 'SK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'etihad%' then 'EY'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'US airway%'  OR ch.CompanyName like 'US Airway%')then 'US'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'Virgin America%' or ch.companyname like 'Virgin America%')then 'VX'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Admirals%' then 'AA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AA Inflight%' then 'AA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AADVANTAGE ELITE%' then 'AA'
		 --when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'SURF AIR%' then 'XX'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'UNITED%' or ch.companyname like 'United%')then 'UA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'SPIRIT%' or ch.companyname like 'Spirit%')then 'NK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'AIRTRAN%' or ch.companyname like 'AirTran%' )then 'FL'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'JETBLUE%' or ch.CompanyName like 'JetBlue%')then 'B6'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Alaska air%' then 'AS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%AIR Canada%' or ch.CompanyName like '%Air Canada%') then'AC'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'Porter%' or ch.CompanyName like 'Porter A%') then 'PD'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like '%Southwest%' or ch.CompanyName like '%Southwest%') then'WN'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Aeromexico%' then 'AM'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Gol Tran%' then 'G3'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'TAM%' then 'PZ'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Air Inuit%' then '3H'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'RyanAir%' Or ch.CompanyName like 'Ryanair%') then 'FR'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Swiss Int%' then 'LX'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'KLM%' then 'KL'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'Spice%' then 'SG'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'Frontier%' or ch.CompanyName like 'Frontier%') then 'F9'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'InterJet%' then '4O'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'CONCESIONARIA%' or ch.companyname like 'Volaris%') then 'Y4'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'KLM UK%' or ch.companyname like 'KLM UK%') then 'UK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'CARIBBEAN AIR%' then 'B8'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'NORWEGIAN%' then 'DY'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%LUFTHA%' then 'LH'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'HONG KONG AIR%' then 'HX'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%DRAGON%' then 'KA'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AIR INDIA%' then 'AI'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'CARIBBEAN AIR%' then 'B8'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'ALL NIPPON%' OR CH.CHARGEDESC LIKE 'ANA%')then 'NH'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'CHINA AIR%' then 'CI'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'PHILIPPINE AIR%' then 'PR'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'THAI AIR%' then 'TG'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'VIRGIN ATL%' THEN 'VS'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'EVA AIR%' then 'BR'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'CARIBBEAN AIR%' then 'B8'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'CHINA EASTER%' then 'MU'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'QATAR%' then 'QR'  
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'AIR NEW ZEALAND%' OR CH.CHARGEDESC LIKE 'AIR NZ%')then 'NZ'		 
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like '%POLISH Air%' then 'LO' 	
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'VIETNAM%' then 'VN' 
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'ALITALIA%' then 'AZ' 	
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and (ch.chargedesc like 'AIR FRANCE%' OR CT.TICKETISSUER LIKE 'AIR FRANCE%')then 'AF'		  
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'FINNAIR%' then 'AY'  
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'TURKISH AIR%' then 'TK' 
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AIR China%' then 'CA'  
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and CT.TICKETISSUER like 'LAN AIR%' then 'LA'	
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AIRLINK%' then 'ND'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AEROLINEAS%' then 'AR'
		
		else valcarriercode end


from dba.ccticket ct, dba.ccheader ch 
where ct.recordkey = ch.recordkey

--Updates to CCTicket where ticketnum is in the charge description  - #40031 1/6/2015

--Japan Airlines
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'JAPAN AIRLINES  131%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--ETIHAD AIRWAYS

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'ETIHAD AIRWAYS  607%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--BRITISH AIRWAYS
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'BRITISH AIRWAYS 125%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--CATHAY PACIFIC
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'CATHAY PACIFIC  160%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--SINGAPORE AIRLI
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'SINGAPORE AIRLI 618%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--All Nippon
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'ANA BSP         205%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--Lufthansa
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'DEUTSCHE LUFTHA 220%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--usairways

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'US AIRWAYS BSP  037%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'US AIRWAYS      037%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


--KLM
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10) 
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'KLM ROYAL DUTCH 074%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--delta
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'DELTA AIRLINE B 006%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--United
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10) 
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'UNITED AIR BSP  016%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--American
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'AMERICAN AIRLIN 0014%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

--Air Canada
update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'AIR CANADA BSP  014%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'SWISS INTL AIR  724%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'AIR FRANCE      057%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'SCANDINAVIAN AI 117%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'AIR CHINA BSP   999%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'EVA AIRWAYS BSP 695%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'QATAR AIRWAYS B 157%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'QANTAS AIRWAYS  081%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'THAI AIRWAYS BS 217%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'MALAYSIAN AIRLI 232%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'AMERICAN AIRLIN 001%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'PHILIPPINE AIRL 079%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'ASIANA AIRLINES 988%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)

update cct
set cct.ticketnum=SUBSTRING(cch.chargedesc,20,10)
from dba.CCHeader cch,
dba.CCTicket cct
where ChargeDesc  like 'CHINA EASTERN A 781%'
and cch.RecordKey=cct.RecordKey
and cct.ticketnum<>SUBSTRING(cch.chargedesc,20,10)


--Update ccmerchant with the 2 letter country code instead of using the 3 number ISO country code....10/4/11 NL
update merch
set merch.merchantctrycode = iso.countrycode
from dba.ccmerchant merch,dba.ccisocountry iso
where merch.merchantctrycode = iso.isocountrynum

--Ancillary fee updates per Jim on 02/27/2013
update dba.ccticket
set ancillaryfeeind = 1
where ticketissuer like '%1ST BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 1
where ticketissuer like '%BAGGAGE FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 2
where ticketissuer like '%2ND BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 3
where ticketissuer like '%3RD BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 4
where ticketissuer like '%4TH BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 5
where ticketissuer like '%5TH BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 6
where ticketissuer like '%6TH BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 16
where ticketissuer like '%-INFLT%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 16
where ticketissuer like '%*INFLT%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%EXCS BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 8
where ticketissuer like '%OVERWEIGHT%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 9
where ticketissuer like '%OVERSIZE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%EXCS BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 10
where ticketissuer like '%SPORT EQUIP%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%EXCS BAG FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA AWRD ACCEL%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA ECNMY PLUS%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA PREM CABIN%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA PREM LINE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%UA MPI UPGRD%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 7
where ticketissuer like '%SKYMILES FEE%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 17
where ticketissuer like '%EASY CHECK IN%'	 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 60
where ticketissuer = 'KLM LOUNGE ACCESS' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 18
where ticketissuer like '%UNITED-  UNITED.COM AWARD%'	 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 19
where ticketissuer like '%UNITED-  UNITED CONNECTIO%'	 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 21
where ticketissuer like '%UNITED-  UNITED.COM CUSTO%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer like '%UNITED-  WIPRO BPO PHILIP%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 20
where ticketissuer like '%UNITED-  WIPRO SPECTRAMIN%'	 and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 21
where ticketissuer like '%UNITED-  TICKET SVC CENTE%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%MPI BOOK FEE%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%RES BOOK FEE%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%UA TKTG FEE%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%UA UNCONF CHG%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 30
where ticketissuer like '%UNITED-  UNITED.COM%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 31
where ticketissuer like '%CONFIRM CHG$%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 32
where ticketissuer like '%CNCL/PNLTY%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 50
where ticketissuer like '%MUA CO PAY TI%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 50
where ticketissuer like '%UA MISC FEE%'	and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 50
where ticketissuer like '%UNITED.COM-SWIT%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 1
WHERE PASSENGERNAME LIKE '%/FIRST CHE%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 2
WHERE PASSENGERNAME LIKE '%/SECOND CH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 3
WHERE PASSENGERNAME LIKE '%/THIRD CH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 4
WHERE PASSENGERNAME LIKE '%/FOURTH CH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 5
WHERE PASSENGERNAME LIKE '%/FIFTH CH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 6
WHERE PASSENGERNAME LIKE '%/SIXTH CH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 7
WHERE PASSENGERNAME LIKE '%EXCESS BA%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 8
WHERE PASSENGERNAME LIKE '%/OVERWEIGH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 9
WHERE PASSENGERNAME LIKE '%/OVERSIZED%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 10
WHERE PASSENGERNAME LIKE '%SPORT EQU%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 10
WHERE PASSENGERNAME LIKE '%/SPORTING%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 12
WHERE PASSENGERNAME LIKE '%/EXTRA LEG%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 13
WHERE PASSENGERNAME LIKE '%/FIRST CLA%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 15
WHERE PASSENGERNAME LIKE '%/ONEPASS R%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 15
WHERE PASSENGERNAME LIKE '%/REWARD BO%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 15
WHERE PASSENGERNAME LIKE '%/REWARD CH%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 16
WHERE PASSENGERNAME LIKE '%/INFLIGHT%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 16
WHERE PASSENGERNAME LIKE '%/LIQUOR%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 21
WHERE PASSENGERNAME LIKE '%/SPECIAL S%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 30
WHERE PASSENGERNAME LIKE '%/RESERVATI%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 30
WHERE PASSENGERNAME LIKE '%/TICKETING%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 31
WHERE PASSENGERNAME LIKE '%/CHANGE FE%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 32
WHERE PASSENGERNAME LIKE '%/CHANGE PE%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 31
WHERE PASSENGERNAME LIKE '%/PAST DATE%' and ancillaryfeeind is null

UPDATE DBA.CCTICKET
SET ANCILLARYFEEIND = 60
WHERE PASSENGERNAME LIKE '%/P-CLUB DA%' and ancillaryfeeind is null

update dba.ccticket
set ancillaryfeeind = 60
where passengername like '%P-CLUB%' and ancillaryfeeind is null

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
where ancillaryfeeind is null
and substring(ticketnum,1,2) in ('29','26') and valcarriercode = 'CO'
and ticketamt in (27,30,32,35,45,50,9,10) and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 1
where valcarriercode = 'AA'
and ticketamt in (25,50) and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'AA'
and ticketamt in (35,30,50,60,75) and substring(ticketnum,1,3) in ('025','026','027','028') and matchedrecordkey is null

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
where valcarriercode = 'AA' and ticketamt in (35,30,50,60,75)
and substring(ticketnum,1,2) in ('26') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'AA' and ticketamt in (100)
and substring(ticketnum,1,2) in ('26') and ancillaryfeeind is null and matchedrecordkey is null

----------------NOT STANDARD---------commenting out per UBS...LOC---------------------
--update dba.ccticket
--set ancillaryfeeind = 16
--where valcarriercode = 'AA' and ticketamt in (3.29,5.29,6,4.49,8.29,10,7,9,25,30,35,50,60,75) and ancillaryfeeind is null

--update dba.ccticket
--set ancillaryfeeind = 1
--where valcarriercode = 'DL' and ticketamt in (23,25,32,35,27,30,50,55) 
--and substring(ticketnum,1,2) IN ('25','29','82') and matchedrecordkey is null
--------------------same as above???----------------------------------------
--update dba.ccticket
--set ancillaryfeeind = 2
--where valcarriercode = 'DL' and ticketamt in (32,35,27,30,50,55)
--and substring(ticketnum,1,2) IN ('25','29','82') and matchedrecordkey is null

--update dba.ccticket
--set ancillaryfeeind = 16
--where valcarriercode = 'DL' and ticketamt in (7.50,10,9,19,25,29,39,49,50,59,60,75) and ancillaryfeeind is null


--update dba.ccticket
--set ancillaryfeeind = 16
--where ticketamt in (2,7.50,12.50,10,9,15,19,20,25,29,30,35,39,40,49,50,59,60,75) 
--and ancillaryfeeind is null

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
where valcarriercode = 'US' and ticketamt in (23,25)
and substring(ticketnum,1,2) IN ('24') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 2
where valcarriercode = 'US' and ticketamt in (35,50)
and substring(ticketnum,1,2) IN ('24') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 7
where valcarriercode = 'WN' and ticketamt in (50,110)
and substring(ticketnum,1,2) IN ('26') and ancillaryfeeind is null and matchedrecordkey is null

update dba.ccticket
set ancillaryfeeind = 17
where valcarriercode = 'WN' and ticketamt in (10)
and substring(ticketnum,1,2) IN ('06') and ancillaryfeeind is null and matchedrecordkey is null

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
where ticketissuer in ('ADMIRAL CLUB',
'US AIRWAYS CLUB',
'CONTINENTAL PRESIDENT CLU', 'UNITED RED CARPET CLUB', 'THE LOUNGE VIRGIN BLUE') and matchedrecordkey is null
and ancillaryfeeind is null

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
WHERE TicketIssuer LIKE '%extra baggage%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE TicketIssuer LIKE '%excess bag%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE TicketIssuer LIKE '%VIRGIN ATLANTIC XX ANCILLARIES%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

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
WHERE PassengerName LIKE '%/FIRST CHE%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 2
WHERE PassengerName LIKE '%/SECOND%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 7
WHERE PassengerName LIKE '%/EXCESS%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 8
WHERE PassengerName LIKE '%/OVERWEIGH%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 11
WHERE PassengerName LIKE '%/SPECIAL%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 13
WHERE PassengerName LIKE '%/FIRST CLA%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 14
WHERE PassengerName LIKE '%/EXT ST%' OR PassengerName LIKE '%/EXTRA SEAT%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 15
WHERE PassengerName LIKE '%ONEPASS%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 16
WHERE PassengerName LIKE '%/HEADSET%' OR PassengerName LIKE '%/INFLIGHT%' OR PassengerName LIKE '%/LIQUOR%'
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 18
WHERE PassengerName LIKE '%/EXTRA LEG%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

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
WHERE PassengerName LIKE '%P-CLUB%' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

UPDATE DBA.CCTicket
SET AncillaryFeeInd = 19
WHERE PassengerName = 'MISC' OR PassengerName = 'MISceLLaNeOUS' 
AND AncillaryFeeInd IS NULL AND MatchedRecordKey IS NULL

update dba.ccheader
set ancillaryfeeind = 1
where (( chargedesc like '%1ST BAG FEE%' OR ChargeDesc like '%baggage fee%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 60
where (( chargedesc like '%ADMIRALS CLUB%'  OR ChargeDesc like '%SKY TEAM LOUNGE%'
OR ChargeDesc like '%REDCARPETCLUB%' OR ChargeDesc like '%US AIRWAYS CLUB%'
OR ChargeDesc like '%ALASKA AIR BOARDRM%' OR ChargeDesc like '%-BOARDROOM%' ))
and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 16
where (( chargedesc like '%ALASKA AIR CO STORE%'  OR ChargeDesc like '%IN FLIGHT%'
OR ChargeDesc like '%ALASKA AIRLINE ONBOA%' OR ChargeDesc like '%ONBOARD%'
OR ChargeDesc like '%IN-FLIGHT%' OR ChargeDesc like '%INFLIGH%'
OR ChargeDesc like '%DUTY FREE%' OR ChargeDesc like '%ON BOARD%'
OR ChargeDesc like 'VIRGIN AMERICA ON BO%'
OR ChargeDesc like '%SOUTHWESTAIR*INFLIGH%' OR ChargeDesc like '%*INFLT%' OR ChargeDesc like '%WESTJET BUY ON BOARD%'
OR ChargeDesc like '%PURCHASE ON JETBLUE%' )) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 12
where (( chargedesc like '%ALASKA AIRLINES SEAT%' OR chargedesc like '%ECNMY PLUS%'
OR chargedesc like '%ECONOMYPLUS%' OR chargedesc like '%ECONOMY PLUS%' ))
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
where (( chargedesc like '%WIFI%' OR chargedesc like '%MOVIE%')) and ancillaryfeeind is null

update dba.ccheader
set ancillaryfeeind = 30
where (( chargedesc like '%RES BOOK FEE%'
OR chargedesc like '%UNCONF CHG%' OR chargedesc like '%WEB CHECKIN%'
OR chargedesc like '%WEB SALES%')) and ancillaryfeeind is null


update dba.ccheader
set ancillaryfeeind = 50
where (( chargedesc like '%OPTIONAL SERVICE%' OR chargedesc like '%NON-FLIGHT%'
OR chargedesc like '%MISC FEE%' OR chargedesc like 'EASYJET LUTON BEDS'
OR chargedesc like 'ANA BSP         205483%' OR chargedesc like 'HAWAIIAN AIRLINES ON%')) and ancillaryfeeind is null

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

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


-------- Update Remarks14 with EmployeeID for backup-------------LOC/12/17/2012
update dba.ccheader
set remarks14 = employeeid where remarks14 is null

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='GPN Padding Begin%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='GPN Validation%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
update dba.CCHeader
set EmployeeId = '80704073'
where CreditCardNum =  '378297172051209' and IataNum = 'UBSAXCC'

update dba.CCTicket
set EmployeeId = '80704073'
where TktOriginatingCCNum =  '378297172051209' and IataNum = 'UBSAXCC'

update dba.CCcar
set EmployeeId = '80704073'
where CarOriginatingCCNum =  '378297172051209' and IataNum = 'UBSAXCC'

update dba.CCHotel
set EmployeeId = '80704073'
where HTLOriginatingCCNum =  '378297172051209' and IataNum = 'UBSAXCC'

update cchn
set cchn.EmployeeId = cch.EmployeeId
from dba.CCHeader cchn, dba.CCHeader cch
where cchn.CreditCardNum = cch.CreditCardNum
and cch.EmployeeId is not null and cchn.EmployeeId is null  and cch.iatanum = 'UBSAXCC'
 
 -------- Pad GPN to 8 characters -- LOC/12/17/2012
update cch
set employeeid = right('00000000'+employeeid,8)
from dba.ccheader cch where iatanum = 'UBSAXCC' and len(employeeid) <> 8 and employeeid <> 'Unknown'


update cch
set employeeid = 'Unknown'
from dba.ccheader cch
where employeeid not in (select corporatestructure from dba.rollup40 where costructid = 'functional')

update cch
set employeeid = 'Unknown'
from dba.ccheader cch where employeeid is NULL

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update EmployeeID in all Tables%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update transactions tables with Employee ID from CCHeader-------- LOC/12/17/2012
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

 ---Updates for Car Merchant Normalization --KP 1/10/2014
 --Setting vendor to 1 for Concord LLC
update dba.CCheader
set MerchantId='6316584531'
where MerchantId in ('6319850228')
and IataNum='UBSAXCC'

--Setting vendor to 1 for Dav - El
update dba.CCheader
set MerchantId='2209001072'
where MerchantId in ('5049002645')
and IataNum='UBSAXCC'

--Setting Bali Limo prior to 7/31/2013 to Preferred - after that to non preferred
update dba.CCheader
set MerchantId='5049006117A'
where MerchantId in ('5049006117')
and TransactionDate<='2013-07-31'
and IataNum='UBSAXCC'

-------------------- Rail Updates ----------------------------------------------------
-------- Per conversation with Mike G. 6/18/2014 ------------------------------------
-------- Updating the Matched Record Key for Rail CC transactions ------- LOC/6/18/2014
update cct
set matchedrecordkey = 	Case	
			when ticketissuer like 'DB BAHN%' then 'RAIL'
			when ticketissuer like 'ARLANDA EXPRESS%' then 'RAIL'
			when ticketissuer like 'BART%' then 'RAIL'
			when ticketissuer like '%SBB%' then 'RAIL'
			when ticketissuer like 'BERKELEY HEIGHTS%' then 'RAIL'
			when ticketissuer like 'BOLOGNA CENTRALE SELF SERVICE%' then 'RAIL'
			when ticketissuer like 'EAST COAST - EDINBURGH%' then 'RAIL'
			when ticketissuer like 'FIRST GREAT WEST%' then 'RAIL'
			when ticketissuer like 'FIRST SCOT%' then 'RAIL'
			when ticketissuer like 'Flytoget%' then 'RAIL'
			when ticketissuer like 'GENEVE%CFF%' then 'RAIL'
			when ticketissuer like 'GREAT WESTERN TRAINS%' then 'RAIL'
			when ticketissuer like 'GREATER ANGLIA%' then 'RAIL'
			when ticketissuer like 'HEATHROW EXPRESS OPE%' then 'RAIL'
			when ticketissuer like 'JFK TVM%NEW YORK%' then 'RAIL'
			when ticketissuer like 'KLOTEN FLUGHAFEN BAH%' then 'RAIL'
			when ticketissuer like 'LAUSANNE CFF%' then 'RAIL'
			when ticketissuer like 'LIRRNYTICKETS%' then 'RAIL'
			when ticketissuer like 'MARTA%' then 'RAIL'
			when ticketissuer like 'METRO%NORTH%' THEN 'RAIL'
			when ticketissuer like 'MILANO CENTRALE SELF SERV%' then 'RAIL'
			when ticketissuer like 'MTA MVM%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE 'NJT%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE 'RUMLANG BAULER BILLE%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE '%SNCB$' THEN 'RAIL'
			WHEN TICKETISSUER LIKE '%TRAIN%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE '%RAILWAY%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE '%SUBWAY%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE 'VBZ%ZUERICH%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE 'VBZ%ZURICH%' THEN 'RAIL'
			WHEN CHARGEDESC LIKE 'DB Vertrieb%' THEN 'RAIL'
			WHEN TICKETISSUER LIKE '%MARITZ%' THEN 'AIR'
			WHEN TICKETISSUER LIKE 'VENTRA VENDING%' THEN 'RAIL'
			END
from dba.ccticket cct, dba.ccheader cch
where ticketamt between '1' and '150' and cct.ancillaryfeeind is null
and cct.transactiondate >='1-1-2013' and cct.matchedrecordkey is null
and cct.recordkey = cch.recordkey 

update cch
set cch.matchedrecordkey = 'RAIL'
from dba.ccheader cch, dba.ccticket cct
where cch.recordkey = cct.recordkey and cct.matchedrecordkey = 'RAIL'
and cct.transactiondate >= '1-1-2013' and cch.matchedrecordkey is null

------------------------ Additional updates for CC Matchback ---------- LOC/6/19/2013
---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
SET @TransStart = getdate()
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

--Update specific to agency data containing documentnumbe differently KP/1/13/2015
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,6,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

----Update specific to agency data containing documentnumbe differently KP/1/13/2015
update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,6,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update id
set id.matchedind = '2'
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode and id.matchedind is null

----Update specific to agency data containing documentnumbe differently KP/1/13/2015
update id
set id.matchedind = '2'
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,6,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode and id.matchedind is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
--and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
--and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
--------CCHdr Updates -------------
update cchdr
set cchdr.matchedrecordkey = cch.recordkey, cchdr.matchediatanum = cch.iatanum, cchdr.matchedclientcode = cch.clientcode
from dba.ccheader cchdr, dba.cchotel cch
where cchdr.recordkey = cch.recordkey
and cchdr.matchedrecordkey is null and cch.recordkey is not null

--------Hotel updates -----
Update h
set h.matchedind = '2' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and guestname<> lastname+'/'+firstname and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-abs(totalauthamt) < (.20*ttlhtlcost)
and abs(totalauthamt)-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid

--------Case #38967 -- Per UBS -- Ensuring BCD does not show as leakage.....LOC/6/4/2014 
update cct 
set cct.matchedrecordkey = TicketIssuer 
FROM dba.ccticket cct 
where MatchedRecordKey IS NULL 
and ticketissuer like 'BCD%'

-------- CC Header --Update the Matched Recordkey to = ticket issuer where the Ticket issuer isBCD 
-------- Per UBS Case 38967.....LOC/6/4/2014 
update cch 
set cch.matchedrecordkey = TicketIssuer 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cch.MatchedRecordKey IS NULL 
and ticketissuer like 'BCD%'

--Per Mikes request add update to BCD when ChargeDesc like BCD (tkt issuer usually unknown)
update cch 
set cch.matchedrecordkey = 'BCD TRAVEL' 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cch.MatchedRecordKey IS NULL 
and cch.ChargeDesc LIKE '%BCD TRAVEL%'

update cct 
set cct.matchedrecordkey = 'BCD TRAVEL' 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cct.MatchedRecordKey IS NULL 
and cch.ChargeDesc LIKE '%BCD TRAVEL%'

--Update match based on ChargeDesc per Ryan #40031 1/6/2015

update cch 
set cch.matchedrecordkey = 'FRIGERIO' 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cch.MatchedRecordKey IS NULL 
and cch.ChargeDesc LIKE 'FRIGERIO VIAGGI SRL MILAN%'

update cch 
set cch.matchedrecordkey = 'BRITISH AIRWAYS UK' 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cch.MatchedRecordKey IS NULL 
and cch.ChargeDesc LIKE 'BRITISH AIRWAYS UK BSP THE TRAVEL COMP RUI%'

update cct 
set cct.matchedrecordkey = 'FRIGERIO' 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cct.MatchedRecordKey IS NULL 
and cch.ChargeDesc LIKE 'FRIGERIO VIAGGI SRL MILAN%'

update cct 
set cct.matchedrecordkey = 'BRITISH AIRWAYS UK' 
FROM dba.ccticket cct, dba.ccheader cch 
where cct.recordkey = cch.recordkey and cct.MatchedRecordKey IS NULL 
and cch.ChargeDesc LIKE 'BRITISH AIRWAYS UK BSP THE TRAVEL COMP RUI%'

--------Case #38967 -- Per UBS -- CCT update update matched recordkey to ANCFEE.....6/4/2014 
update dba.ccticket 
set matchedrecordkey = 'ANCFEE' 
where MatchedRecordKey IS NULL 
and AncillaryFeeInd is not null



-------- CC Header --Update the Matched Recordkey to ANCFEE  so fees doesnt show on leakage 
-------- Per UBS Case 38967...../6/4/2014 
update dba.ccheader  
set matchedrecordkey = 'ANCFEE' 
where MatchedRecordKey IS NULL 
and AncillaryFeeInd is not null

    -------- Update remarks6 with UBS RESTAURANT chain name --------
  update cch
  set remarks6 = substring(ubschainname,1,40)
  from dba.ccheader cch, dba.preferredrestaurants pr
  where cch.merchantid = pr.merchantid
  and remarks6 is null

--adding merchant table update for car service merchants that are being assinged a
--genesisdetailindcode that is keeping them out of preferred reports
 
 update dba.CCMerchant
set GenesisDetailIndCode='397'
where MerchantId in (select MerchantId from dbo.ccmerchant_include)
and GenesisDetailIndCode not in ('397','398')

 UPDATE M
 SET PurgeInd='E'
 FROM DBA.CCMerchant M,  DBa.CCMerchantExclude ME
  WHERE   M.MerchantId=ME.MERCHANTID   AND isnull(M.PurgeInd,'X') not in ('E','Y')
  and category = 'CarService' and GenesisDetailIndCode in ('397','398')
  
 UPDATE M
 SET PurgeInd='E'
  FROM DBA.CCMerchant M
  WHERE   isnull(M.PurgeInd,'X') not in ('E','Y')
  and M.GenesisDetailIndCode in ('397','398')
  AND M.MERCHANTID NOT IN (SELECT MERCHANTID FROM DBO.CCMerchant_INCLUDE)


update ccm
 set PurgeInd='N'
  from dba.CCMerchant ccm
 where GenesisDetailIndCode in ('397','398')
and purgeind  is NULL



  -------- Additional Updates for Remarks6 for Non preferred vendors ------#50693----- LOC/8/12/2014
  update cch
  set remarks6 = 'CREATIVE MOBILE TECHNOLOGY'
  from dba.ccheader cch, dba.ccmerchant ccm
  where cch.merchantid = ccm.merchantid
  and remarks6 is null and merchantname1 like '%cmt%' and siccode = '4121'
  
  update cch
  set remarks6 = 'CREATIVE MOBILE TECHNOLOGY'
  from dba.ccheader cch, dba.ccmerchant ccm
  where cch.merchantid = ccm.merchantid
  and remarks6 is null
  and cch.merchantid in ('1311000673','631900077')

--Merchant Chain 'UBER Global transactions updated to UBER in SFO ('1046399564') so Leakage report will rollup to 1 location 
 --Case#50693
 update cch
 set merchantid='1046399564'
 from dba.CCHeader cch
 where merchantid in ('9590115028','9562797001','9590115176','9492798889','9590115119',
'9590115101','9590115382','9502798911','9590115275','9573009511','9590115366','9412709263',
'9590115309','9422794420','9582706024','9491048641','9302961678','9590193280')

--
  update cch
  set remarks6 = 'UBER'
  from dba.ccheader cch, dba.ccmerchant ccm
  where cch.merchantid = ccm.merchantid
  and remarks6 is null and ccm.merchantid in ('2044388163','2044388155','1046399564','2044388189','2044388106','2044388148')

--GetRide transactions updated to New York city so Leakage report will rollup to 1 location 
 --Case#50693
  update cch
 set merchantid = '6319018651'
 from dba.ccheader cch
 where merchantid in
('1429742596')
 
  update cch
  set remarks6 = 'GETRIDE.COM'
  from dba.ccheader cch, dba.ccmerchant ccm
  where cch.merchantid = ccm.merchantid
  and remarks6 is null and ccm.merchantid in ('1429742596','6316095553','6319018651')

  -------------21 club update----------------------------------------------------------------------------------------
  update cch
  set merchantid = '1310208798'
  from dba.ccheader cch
  where merchantid = '6311080485'
  --------------------------------------------
  -------- Update document number to first 10 of dataprovided where match is made to cc data...LOC/5/28/2013
update id
set documentnumber = substring(documentnumber,1,10)
from dba.invoicedetail id, dba.ccticket cct
where len(documentnumber) > 10
and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH') and id.iatanum like 'ubsbcd%'
and vendortype in ('bsp','nonbsp') and substring(documentnumber,1,10) = ticketnum 
and substring(passengername,1,5) = substring((lastname+'/'+firstname),1,5)
and matchedrecordkey is null
and id.invoicedate > '1-1-2013'

----------------------------------------------------------------------------------------------------------------
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
SET @TransStart = getdate()

Exec dbo.sp_UBS_Matchback

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure End UBSAXCC-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 


GO
