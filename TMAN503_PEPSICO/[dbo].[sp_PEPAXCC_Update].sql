/****** Object:  StoredProcedure [dbo].[sp_PEPAXCC_Update]    Script Date: 7/14/2015 8:13:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PEPAXCC_Update]
	
 AS
insert into dba.client
select distinct clientcode,iatanum,null,iatanum,null,null,null,null
,null,null,null,null,null,null,null,null,null,null,null,null
,null,null,null,null
from dba.ccheader
where iatanum ='PEPAXCC'
and clientcode+iatanum not in(select clientcode+iatanum
from dba.client
where iatanum ='PEPAXCC')

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
and t1.iatanum ='PEPAXCC'
and t2.iatanum ='PEPAXCC'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))

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
and t1.iatanum ='PEPAXCC'
and t2.iatanum ='PEPAXCC'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))

---Changed 4/3/2015 to use dba.pepsihr table to also add manager name and employee id SF#06024181

--update cc
--set cc.remarks1 = '100000',
--cc.remarks2 = em.additionalinfo2
----select cc.recordkey,cc.CardHolderName,cc.employeeid, em.*
--from dba.ccheader cc, dba.employee em
--where RIGHT('0000000000'+cc.EmployeeID,10) = RIGHT('0000000000'+em.EmployeeID1,10)
--and cc.transactiondate > '2013-11-01'
--and cc.EmployeeId is not null
--and cc.EmployeeId not in ('999999999','0000000000')
--and em.EmpEmail like '%pepsico%'
--and cc.iatanum like 'PEP%'
--and cc.remarks1 is null

--update cc
--set cc.remarks3 = cr.text12,
--cc.remarks4 = cr.text14, 
--cc.remarks5 = cr.text16, 
--cc.remarks6 = cr.text18, 
--cc.remarks7 = cr.text20, 
--cc.remarks8 = cr.text21, 
--cc.remarks9 = cr.text22
----select cc.EmployeeId, cr.Text1,cc.matchedrecordkey, cc.*
--from dba.ComRmks cr, dba.CCHeader cc
--where cr.RecordKey = cc.MatchedRecordKey
--and cr.IataNum = cc.MatchedIataNum
--and cr.SeqNum = cc.MatchedSeqNum 
--and cc.iatanum like 'PEP%'
--and cc.TransactionDate > '2013-11-01'
--and RIGHT('0000000000'+cc.EmployeeID,10) <> RIGHT('0000000000'+cr.Text1,10)
--and cc.EmployeeId not in ('999999999','0000000000')
--and cc.remarks3 is null

--update cc
--set cc.remarks3 = em.additionalinfo3,
--cc.remarks4 = em.additionalinfo4, 
--cc.remarks5 = em.additionalinfo5, 
--cc.remarks6 = em.additionalinfo6, 
--cc.remarks7 = em.additionalinfo7, 
--cc.remarks8 = em.additionalinfo8, 
--cc.remarks9 = em.additionalinfo9
--from dba.ccheader cc, dba.employee em
--where RIGHT('0000000000'+cc.EmployeeID,10) = RIGHT('0000000000'+em.EmployeeID1,10)
--and cc.transactiondate > '2013-11-01'
--and cc.EmployeeId is not null
--and cc.EmployeeId not in ('999999999','0000000000')
--and em.EmpEmail like '%pepsico%'
--and cc.remarks3 is null
--and cc.iatanum like 'PEP%'
--changed remarks14 from employee firstname, lastname to manager firstname, lastname case# 06532058
update ch
set ch.Remarks1='100000', 
ch.Remarks2= hr.ORG_LVL_2_ID, 
ch.Remarks3= hr.ORG_LVL_3_ID, 
ch.Remarks4= hr.ORG_LVL_4_ID, 
ch.Remarks5= hr.ORG_LVL_5_ID, 
ch.Remarks6= hr.ORG_LVL_6_ID, 
ch.Remarks7= hr.ORG_LVL_7_ID, 
ch.remarks8= hr.ORG_LVL_8_ID, 
ch.Remarks9= hr.ORG_LVL_9_ID, 
--ch.remarks14= hr.FIRST_NAME+' '+hr.LAST_NAME,  
ch.remarks14= hr.MANAGER_FIRSTNAME+' '+hr.MANAGER_LASTNAME,
ch.remarks15= hr.MANAGER_EMPLOYEE_ID 

from dba.ccheader ch, dba.pepsihr hr 
where ch.transactiondate >= '2015-01-01' 
and ch.iatanum = 'PEPAXCC' 
and ch.Remarks15 is null 
and RIGHT('000000000'+employeeid,8) = RIGHT('000000000'+hr.employee_id,8)

--UPDATED airline Val Carrier Code per Case#06300750 4/22/2015 KP
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
		  when ct.valcarriercode= '0' and (ch.chargedesc like 'SPIRIT%' or ch.companyname like 'Spirit%')then 'NK'
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
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'GREAT LAKE%' then 'ZK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AER LINGUS%' then 'EI'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'EMIRATES%' then 'EK'
		 when isnull(ct.valcarriercode, 'XX') = 'XX' and ch.chargedesc like 'AZUL%' then 'AD'
		
		else valcarriercode end


from dba.ccticket ct, dba.ccheader ch 
where ct.recordkey = ch.recordkey


--added ancillary fee updates 12/10/2014 case 50998

/*Updated 2014SEP10 to include join to ccheader and filter for getdate()*/
update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%1ST BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%BAGGAGE FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%2ND BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 3
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%3RD BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 4
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%4TH BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 5
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%5TH BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 6
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%6TH BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%-INFLT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%*INFLT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EXCS BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 8
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%OVERWEIGHT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 9
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%OVERSIZE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EXCS BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 10
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%SPORT EQUIP%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EXCS BAG FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA AWRD ACCEL%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 12
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA ECNMY PLUS%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 13
from dba.ccticket cctkt inner 
join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA PREM CABIN%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 17
from dba.ccticket cctkt inner 
join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA PREM LINE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA MPI UPGRD%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%SKYMILES FEE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 17
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%EASY CHECK IN%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer = 'KLM LOUNGE ACCESS'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 18
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED.COM AWARD%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 19
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED CONNECTIO%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED.COM CUSTO%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 20
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  WIPRO BPO PHILIP%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 20
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  WIPRO SPECTRAMIN%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  TICKET SVC CENTE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%MPI BOOK FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%RES BOOK FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA TKTG FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA UNCONF CHG%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED-  UNITED.COM%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%CONFIRM CHG$%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 32
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%CNCL/PNLTY%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%MUA CO PAY TI%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UA MISC FEE%'	
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%UNITED.COM-SWIT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/FIRST CHE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/SECOND CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 3
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/THIRD CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 4
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/FOURTH CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 5
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where PASSENGERNAME LIKE '%/FIFTH CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 6
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/SIXTH CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%EXCESS BA%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 8
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/OVERWEIGH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 9
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/OVERSIZED%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 10
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%SPORT EQU%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 10
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/SPORTING%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 12
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/EXTRA LEG%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 13
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/FIRST CLA%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/ONEPASS R%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/REWARD BO%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/REWARD CH%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/INFLIGHT%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/LIQUOR%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/SPECIAL S%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/RESERVATI%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/TICKETING%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/CHANGE FE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 32
from dba.ccticket cctkt inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/CHANGE PE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/PAST DATE%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/P-CLUB DA%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where passengername like '%P-CLUB%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where routing like 'XAA%'
and routing like '%XAE%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XUP%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XAF%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XCA%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XOT%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XDF%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XAO%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XAA%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XTD%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 25
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XPC%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 31
from dba.ccticket cctkt 
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing like 'XAA%'
and cctkt.routing like '%XPE%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GATWICK S BAGGAGE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ccexp.ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0QYBAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R2BAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R6BAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%GOVTRIPTAV 0R7BAG%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%LHR T3- BAGGAGE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%LHR T4 BAGGAGE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%T1  BAGGAGE RECLAIM%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%T1 BAGGAGE RECLAIM%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%T3- BAGGAGE BELT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 1
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (1)%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 2
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%TVX LHR T5 BAG INT (2)%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 7
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%EXCESS BAGGAGE CO%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%ALASKA AIR IN FLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3


update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%FLY DUBAI-INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%IN FLIGHT US AIRWAYS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%INFLIGHT FOOD PURCHASE%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 8
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%KLM OVERBAGAGEKAS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AIRCELL GOGO INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AIRCELL*GOGO INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%INFLIGHT US AIRWAYSQPS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%SWA INFLIGHT WIFI%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%TRLPAY  GOGO INFLIGHT%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 55
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AIRPORTBAGS.COM%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 60
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AA ADMIRAL%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 60
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%AA ADMRL%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 60
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%ADMIRALS CLUB%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

update ccexp
SET ANCILLARYFEEIND = 70
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum) 
where ccexp.MCHRGDESC1 LIKE '%INFLIGHT MEDICAL%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3


update cctkt
set cctkt.AncillaryFeeInd = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AA'
and cctkt.ticketamt in (35,30,50,60)
and substring(cctkt.ticketnum,1,2) in ('26')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AA'
and cctkt.ticketamt in (100)
and substring(cctkt.ticketnum,1,2) in ('26')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AA'
and cctkt.ticketamt in (3.29,5.29,6,4.49,8.29,10,7)
AND cctkt.ANCILLARYFEEIND is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (23,25,32,35,27,30,50,55)
and substring(cctkt.ticketnum,1,2) IN ('25','29','82')
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (32,35,27,30,50,55)
and substring(cctkt.ticketnum,1,2) IN ('25','29','82')
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'UA'
and cctkt.ticketamt in (25)
and substring(cctkt.ticketnum,1,2) IN ('40','46','45')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'UA'
and cctkt.ticketamt in (35,50)
and substring(cctkt.ticketnum,1,2) IN ('40','46','45')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'US'
and cctkt.ticketamt in (23,25)
and substring(cctkt.ticketnum,1,2) IN ('24')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'US'
and cctkt.ticketamt in (35,50)
and substring(cctkt.ticketnum,1,2) IN ('24')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'WN'
and cctkt.ticketamt in (50,110)
and substring(cctkt.ticketnum,1,2) IN ('26')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 17
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'WN'
and cctkt.ticketamt in (10)
and substring(cctkt.ticketnum,1,2) IN ('06')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'LH'
and cctkt.ticketamt in (50)
and substring(cctkt.ticketnum,1,2) IN ('16','26','27')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'LH'
and cctkt.ticketamt in (150)
and substring(cctkt.ticketnum,1,2) IN ('16','26','27')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3


update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'BA'
and ((cctkt.ticketamt in (40,50,48,60)
and cctkt.billedcurrcode = 'USD'
and cctkt.matchedrecordkey is null
OR cctkt.ticketamt in (28,35,32,40)
and cctkt.billedcurrcode = 'GBP'))
and substring(cctkt.ticketnum,1,2) IN ('26','90')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'BA'
and ((cctkt.ticketamt in (112,140)
and cctkt.billedcurrcode = 'USD'
and cctkt.matchedrecordkey is null
OR cctkt.ticketamt in (72,90)
and cctkt.billedcurrcode = 'GBP'))
and substring(cctkt.ticketnum,1,2) IN ('26','90')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'SQ'
and cctkt.ticketamt in (8,12,22,50,15,30,55,40,60,50,109,150,84,110,121,117,160,94,115,130,129,149,165,128)
and substring(cctkt.ticketnum,1,2) IN ('16','18')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AF'
and cctkt.ticketamt in (55,100)
and substring(cctkt.ticketnum,1,2) in ('82','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AF'
and cctkt.ticketamt in (200)
and substring(cctkt.ticketnum,1,2) in ('82','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AS'
and cctkt.ticketamt in (20)
and substring(cctkt.ticketnum,1,2) in ('21','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 4
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AS'
and cctkt.ticketamt in (50)
and substring(cctkt.ticketnum,1,2) in ('21','16')
AND cctkt.ANCILLARYFEEIND is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'AC'
and cctkt.ticketamt in (30,50,75,100,225)
and substring(cctkt.ticketnum,1,2) in ('20','51')
and cctkt.matchedrecordkey is null
AND cctkt.ANCILLARYFEEIND is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.valcarriercode = 'LX'
and cctkt.ticketamt in (250,150,50,120,450)
and cctkt.matchedrecordkey is null
AND cctkt.ANCILLARYFEEIND is null
and cchdr.importdate >= getdate()-3


update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cchdr.chargedesc like '%inflight%'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('AIR NEW ZEALAND EXCESS BAG WL7',
'AIR NEW ZEALAND EXCESS BAG CH8',
'MAS EXCESS BAGGAGE - DOME',
'VIRGIN ATLANTIC CC ANCILLARIES',
'AIR NEW ZEALAND EXCESS BAG AK7')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('JETBLUE BUY ON BOARD',
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
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 20
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('AIR DO INTERNET',
'SOUTHWEST ONBOARD INTERNT',
'AIR FRANCE USA INTERNET')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.ticketissuer in ('ADMIRAL CLUB',
'US AIRWAYS CLUB',
'CONTINENTAL PRESIDENT CLU',
'UNITED RED CARPET CLUB',
'THE LOUNGE VIRGIN BLUE')
and cctkt.matchedrecordkey is null
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
where cchdr.chargedesc like '%inflight%'
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('AMTRAK - CAP CORR CAFE',
'AMTRAK - SURFLINER CAFE',
'AMTRAK CASCADES CAFE',
'AMTRAK FOOD & BEVERAGE',
'AMTRAK-CAFE',
'AMTRAK-DINING CAR',
'AMTRAK-EAST CAFE',
'AMTRAK-MIDWEST CAFE',
'AMTRAK-NORTHEAST CAFE',
'AMTRAK-SAN JOAQUINS CAFE')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 60
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('AA ADMIRAL CLUB AUS',
'AA ADMIRAL CLUB LAX',
'AA ADMIRAL CLUB LGA D3',
'AA ADMIRALS CLUB MIAMI D',
'AIR CANADA CLUB',
'AMERICAN EXPRESS PLATINUM LOUNGE')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 20
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('AIRCELL-ABS')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 17
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('BAA ADVANCE')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3


update ccexp
set ccexp.ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('ALPHA FLIGHT SERVICES')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 16
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid and ccexp.recordkey = cchdr.recordkey)
where ccm.merchantname1 in ('DFASS CANADA COMPANY')
and ccexp.mchrgdesc1 like '%air canada on board%'
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 15
from dba.ccexpense ccexp 
Inner Join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
Inner Join dba.ccheader cchdr on (ccm.merchantid = cchdr.merchantid)
where ccm.merchantname1 in ('DELTAMILES BY POINTS')
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%extra baggage%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%excess bag%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%VIRGIN ATLANTIC XX ANCILLARIES%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%IN FLIGHT%' OR TicketIssuer LIKE '%INFLIGHT%' OR TicketIssuer LIKE '%ONBOARD%' OR TicketIssuer LIKE '%ON BOARD%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%DUTY FREE%' OR TicketIssuer LIKE '%DUTY-FREE%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%KLM OPTIONAL SERVICES%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 60
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.TicketIssuer LIKE '%ADMIRALS CLUB%' OR TicketIssuer LIKE '%PRESIDENT CLU%' OR TicketIssuer LIKE '%CARPET CLUB%' OR TicketIssuer LIKE '%ADMIRAL CLUB%'
	OR cctkt.TicketIssuer LIKE '%THE LOUNGE VIRGIN%' OR TicketIssuer LIKE '%US AIRWAYS CLUB%' OR TicketIssuer LIKE '%VIP LOUNGE%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 1
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/FIRST CHE%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 2
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/SECOND%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 7
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/EXCESS%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 8
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/OVERWEIGH%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 11
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/SPECIAL%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 13
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/FIRST CLA%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 14
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/EXT ST%' OR PassengerName LIKE '%/EXTRA SEAT%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 15
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%ONEPASS%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 16
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/HEADSET%' OR PassengerName LIKE '%/INFLIGHT%' OR PassengerName LIKE '%/LIQUOR%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 18
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/EXTRA LEG%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 30
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/FARELOCK%' OR PassengerName LIKE '%/FEE' OR PassengerName LIKE '%/REFUND%' OR PassengerName LIKE '%FEE.%' OR PassengerName LIKE '%KIOSK.%'
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 31
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%/CHANGE PR%' OR PassengerName LIKE '%/SAME DAY%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 60
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName LIKE '%P-CLUB%' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cctkt
SET cctkt.AncillaryFeeInd = 19
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.PassengerName = 'MISC' OR PassengerName = 'MISceLLaNeOUS' 
AND cctkt.AncillaryFeeInd IS NULL
AND cctkt.MatchedRecordKey IS NULL
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 1
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%1ST BAG FEE%' OR ChargeDesc like '%baggage fee%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 60
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%ADMIRALS CLUB%' 
OR cchdr.ChargeDesc like '%SKY TEAM LOUNGE%'
OR cchdr.ChargeDesc like '%REDCARPETCLUB%'
OR cchdr.ChargeDesc like '%US AIRWAYS CLUB%'
OR cchdr.ChargeDesc like '%ALASKA AIR BOARDRM%'
OR cchdr.ChargeDesc like '%-BOARDROOM%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 16
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%ALASKA AIR CO STORE%' 
OR cchdr.ChargeDesc like '%IN FLIGHT%'
OR cchdr.ChargeDesc like '%ALASKA AIRLINE ONBOA%'
OR cchdr.ChargeDesc like '%ONBOARD%'
OR cchdr.ChargeDesc like '%IN-FLIGHT%'
OR cchdr.ChargeDesc like '%DUTY FREE%'
OR cchdr.ChargeDesc like '%SOUTHWESTAIR*INFLIGH%'
OR cchdr.ChargeDesc like '%*INFLT%'
OR cchdr.ChargeDesc like '%WESTJET BUY ON BOARD%'
OR cchdr.ChargeDesc like '%PURCHASE ON JETBLUE%' ))
and ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 12
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%ALASKA AIRLINES SEAT%'
OR cchdr.chargedesc like '%ECNMY PLUS%'
OR cchdr.chargedesc like '%ECONOMYPLUS%' 
OR cchdr.chargedesc like '%ECONOMY PLUS%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 15
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%BUY FLYING BLUE MILE%'
OR cchdr.chargedesc like '%MILEAGE PLUS%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 7
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%CARGO POR EMISION%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 32
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%CNCL/PNLTY%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 8
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%OVERWEIGHT%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 20
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%WIFI%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 30
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%RES BOOK FEE%'
OR cchdr.chargedesc like '%UNCONF CHG%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cchdr
set cchdr.ancillaryfeeind = 50
from dba.ccheader cchdr 
where (( cchdr.chargedesc like '%OPTIONAL SERVICE%'
OR cchdr.chargedesc like '%NON-FLIGHT%'
OR cchdr.chargedesc like '%MISC FEE%' ))
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.Ancillaryfeeind = 60
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%admirals club%' 
  or ccm.merchantname1 like '%admiral club%'
  or ccm.merchantname1 like '%CONTINENTAL PRESIDENT%'
  or ccm.merchantname1 like '%RED CARPET CLUB%'
  or ccm.merchantname1 like '%AIRWAYS CLUB%'
  or ccm.merchantname1 like '%club spirit%'))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 7
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%DELTA AIR CARGO%' ))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 16
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
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
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 15
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%AMEX LIFEMILES%' ))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 50
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname1 like '%AIRPORT KIOSKS%' ))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 16
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%ONBOARD%'))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 7
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%AIR CARGO%'))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 7
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((cch.chargedesc like '%EX BAG%'))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 16
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((ccm.merchantname2 like '%ON BOARD%'
OR ccm.merchantname2 like '%MOVIE SALES%'
OR ccm.merchantname2 like '%VIRGIN AMERICA ON BO%'))
and cctkt.ancillaryfeeind is null

update cctkt
set cctkt.Ancillaryfeeind = 30
from dba.ccticket cctkt 
INNER JOIN DBA.CCHeader cch ON ( cctkt.recordkey = cch.recordkey and cctkt.iatanum = cch.iatanum )
INNER JOIN DBA.CCMerchant ccm ON ( cctkt.MerchantId = ccm.merchantid )
where ((cch.chargedesc like '%REGIONAL EXPRESS CREDIT CARD SURCHARGE%'))
and cctkt.ancillaryfeeind is null

--****** added 2/6/2013 *******

update cctkt
set cctkt.ancillaryfeeind = '15'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where cctkt.issuercity = 'SKYMILES FEE'
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = '20'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt = 7
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = '17'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.issuercity = 'delta.com'
and cctkt.ticketamt = 9
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = '12'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and ((cctkt.issuercity <> 'delta.com' or cctkt.issuercity is null))
and cctkt.ticketamt = 9
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = '12'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (19, 9.5, 14.5, 29, 29.5, 39, 39.5, 49, 79)
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = '7'
from dba.ccticket cctkt 
Inner Join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum) 
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt in (40, 50)
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = 20
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
inner join dba.ccmerchant ccm on (ccexp.merchantid = ccm.merchantid)
where ((ccm.merchantname1 like '%AIPORTWIRELESS%' 
OR ccm.merchantname1 like '%AIRPORT WIRELESS%'
OR ccm.merchantname1 like '%BOINGO%'
OR ccm.merchantname1 like '%SWA INFLIGHT WIFI%'
OR ccm.merchantname1 like 'VIASAT'
))
and ccexp.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = '12'
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ((cctkt.ticketnum like '014%' or cctkt.ticketnum like '015%' or cctkt.ticketnum like '016%'))
and cctkt.valcarriercode = 'DL'
and cctkt.ticketamt = 59
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

-----------------
--added 08/29/2013

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.passengername like '%/1ST BAG%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

UPDATE ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
WHERE ccexp.MCHRGDESC1 LIKE '%GOGOAIR%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

UPDATE ccexp
SET ANCILLARYFEEIND = 20
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
WHERE ccexp.MCHRGDESC1 LIKE '%GOGO DAY PAS%'
AND ccexp.ANCILLARYFEEIND IS NULL
and cchdr.importdate >= getdate()-3

--added 9/22/2014

update cctkt

set ancillaryfeeind = 1
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'EBC/FEE'
and cchdr.importdate >= getdate()-3



--******Added 2/11/2014 for VCF imports

update cctkt
set cctkt.ancillaryfeeind = 1
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XAE'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 15
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XUP'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 60
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XAF'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XCA'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XOT'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 16
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XDF'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 30
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XAO'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 50
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where ccas.origincitycode = 'XAA'
and ccas.segdestcitycode = 'XAA'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 21
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'XAA'
and cctkt.routing = 'XTD'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 25
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'XAA'
and routing = 'XPC'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 31
from dba.ccairseg ccas
inner join dba.ccticket cctkt on ( cctkt.iatanum = ccas.iatanum and cctkt.recordkey = ccas.recordkey )
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.routing = 'XAA'
and cctkt.routing = 'XPE'
and cctkt.ancillaryfeeind is null
and cctkt.matchedrecordkey is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = 12
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ticketissuer like '%bulkhead%'
and cctkt.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3

update cctkt
set cctkt.ancillaryfeeind = cchdr.ancillaryfeeind
from dba.ccticket cctkt
inner join dba.ccheader cchdr on (cctkt.recordkey = cchdr.recordkey and cctkt.iatanum = cchdr.iatanum)
where cctkt.ancillaryfeeind is null
and cchdr.ancillaryfeeind is not null
and cchdr.importdate >= getdate()-3

update ccexp
set ccexp.ancillaryfeeind = cchdr.ancillaryfeeind
from dba.ccexpense ccexp
inner join dba.ccheader cchdr on (ccexp.recordkey = cchdr.recordkey and ccexp.iatanum = cchdr.iatanum)
where ccexp.recordkey = cchdr.recordkey
and ccexp.iatanum = cchdr.iatanum
and ccexp.ancillaryfeeind is null
and cchdr.ancillaryfeeind is not null


UPDATE cchdr
SET cchdr.AncillaryFeeInd = cctkt.AncillaryFeeInd
FROM DBA.ccheader cchdr
inner join DBA.ccticket cctkt on (cchdr.recordkey = cctkt.recordkey and cchdr.iatanum = cctkt.iatanum)
WHERE cchdr.RecordKey = cctkt.RecordKey
AND cctkt.AncillaryFeeInd IS NOT NULL
and cchdr.ancillaryfeeind is null
and cchdr.importdate >= getdate()-3


UPDATE cchdr
SET cchdr.AncillaryFeeInd = ccexp.AncillaryFeeInd
FROM DBA.ccheader cchdr
inner join DBA.ccexpense ccexp on (cchdr.recordkey = ccexp.recordkey and cchdr.iatanum = ccexp.iatanum)
WHERE ccexp.AncillaryFeeInd IS NOT NULL
and cchdr.AncillaryFeeInd IS NULL
and cchdr.importdate >= getdate()-3

update cm
set cm.merchantctrycode = iso.countrycode
from dba.CCMerchant cm, dba.CCISOCountry iso
where cm.MerchantCtryCode = iso.ISOCountryNum
and cm.merchantctrycode <> iso.countrycode

--CC MasterID
--Data Enhancement Automation HNN Queries
Declare @HNNCCBeginDate datetime
Declare @HNNCCEndDate datetime

Select @HNNCCBeginDate = Min(transactiondate),@HNNCCEndDate = Max(transactiondate)
from dba.CCHotel cht, dba.ccmerchant cm
Where cm.MasterId is NULL
AND cht.IataNum like '%AXCC%'
and cht.transactiondate >'2014-12-31'
and cht.merchantid = cm.merchantid

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'PYAX',
@Enhancement = 'HNN',
@Client = 'Pepsi/YUM',
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
@TextParam3 = 'TMAN503_PEPSICO',
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

GO
