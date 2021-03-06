/****** Object:  StoredProcedure [dbo].[CTS_Match]    Script Date: 7/14/2015 8:10:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[CTS_Match]
as 

-------- Update CTS so that all have USD as currency where null -- Per Hickory --- Aug/2014..LOC
update dba.ctsdata set net_pay_currency = 'USD'
where net_pay_currency is NULL

update dba.ctsdata set net_pay_currency = 'USD'
where net_pay_currency in ('','.')



update dba.ctsdata 
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL, market = NULL

-- 
UPDATE dba.Hotel
set HtlCommAmt = NULL ,CommTrackInd = NULL ,HtlCommPostDate = NULL ,voidreasontype = NULL ,Remarks4 = NULL
,MatchedInd = NULL ,matchedfields = NULL

--
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '1' 
from dba.Hotel htl, dba.ctsdata cts
where cts.MatchedRecordKey is NULL  and htl.GDSRecordLocator = cts.pnr_id
and htl.HtlConfNum = cts.confirmation and cts.status = 'A' and htl.iatanum in ('prehgp','prehis') 
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '1'
from dba.Hotel htl, dba.ctsdata cts
where cts.MatchedRecordKey is NULL and htl.GDSRecordLocator = cts.pnr_id and htl.HtlConfNum = cts.confirmation
and cts.status = 'P' and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL)) and htl.iatanum in ('prehgp','prehis')
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '1'
from dba.Hotel htl, dba.ctsdata cts
where cts.MatchedRecordKey is NULL and htl.GDSRecordLocator = cts.pnr_id and htl.HtlConfNum = cts.confirmation 
and cts.status = 'N' and ((htl.CommTrackInd not in('A','P') or htl.CommTrackInd is NULL)) and htl.iatanum in ('prehgp','prehis')
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '1'
from dba.Hotel htl, dba.ctsdata cts
where cts.MatchedRecordKey is NULL  and htl.GDSRecordLocator = cts.pnr_id and htl.HtlConfNum = cts.confirmation
and cts.status = 'S' and ((htl.CommTrackInd not in('A','P','N') or htl.CommTrackInd is NULL)) and htl.iatanum in ('prehgp','prehis')
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '1'
from dba.Hotel htl, dba.ctsdata cts
where cts.MatchedRecordKey is NULL  and htl.GDSRecordLocator = cts.pnr_id and htl.HtlConfNum = cts.confirmation
and cts.status = 'X' and ((htl.CommTrackInd not in('A','P','N','S') or htl.CommTrackInd is NULL)) and htl.iatanum in ('prehgp','prehis')
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '1'
from dba.Hotel htl, dba.ctsdata cts
where cts.MatchedRecordKey is NULL 
and htl.GDSRecordLocator = cts.pnr_id and htl.HtlConfNum = cts.confirmation and cts.status = 'C'
and ((htl.CommTrackInd not in('A','P','N','S','X') or htl.CommTrackInd is NULL)) and htl.iatanum in ('prehgp','prehis')
--

UPDATE HTL
set htl.HtlCommAmt = cts.commission ,htl.CommTrackInd = cts.status ,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source ,htl.Remarks4 = cts.check_num ,htl.MatchedInd = '1'
,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts where cts.matchedrecordkey = htl.RecordKey and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode and cts.matchedseqnum = htl.SeqNum and cts.matchedhtlsegnum = htl.HtlSegNum
and htl.iatanum in ('prehgp','prehis')
 -- 
------------------------------Questionable.  I may not understand but this has matched 
--------------records where the locator does not match  '4JCGW2','OJEPDB'
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '2'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckinDate,cts.in_date,htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,HTL.GDSRecordLocator,cts.pnr_id 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL and htl.HtlConfNum = cts.confirmation    AND CTS.Last_Name = HTL.LastName
   AND CTS.in_date = HTL.CheckinDate        and cts.status = 'A' and htl.iatanum in ('prehgp','prehis')       
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '2'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL  and htl.HtlConfNum = cts.confirmation    AND CTS.Last_Name = HTL.LastName
AND CTS.in_date = HTL.CheckinDate         and cts.status = 'P' and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))
and htl.iatanum in ('prehgp','prehis')
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '2'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL and htl.HtlConfNum = cts.confirmation AND CTS.Last_Name = HTL.LastName
AND CTS.in_date = HTL.CheckinDate        and cts.status = 'N' and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
and htl.iatanum in ('prehgp','prehis')    
--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '2'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL  and htl.HtlConfNum = cts.confirmation   AND CTS.Last_Name = HTL.LastName
AND CTS.in_date = HTL.CheckinDate         and cts.status = 'S' and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '2'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL and htl.HtlConfNum = cts.confirmation AND CTS.Last_Name = HTL.LastName
AND CTS.in_date = HTL.CheckinDate  and cts.status = 'X' and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
and htl.iatanum in ('prehgp','prehis')
--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '2'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
and htl.HtlConfNum = cts.confirmation
   AND CTS.Last_Name = HTL.LastName
   AND CTS.in_date = HTL.CheckinDate
   and cts.status = 'C'
    and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
    and htl.iatanum in ('prehgp','prehis')
  
--   

 UPDATE HTL
set htl.HtlCommAmt = cts.commission ,htl.CommTrackInd = cts.status ,htl.HtlCommPostDate = cts.deposit_date ,htl.voidreasontype = cts.pay_source
,htl.Remarks4 = cts.check_num ,htl.MatchedInd = '2' ,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey and cts.matchediatanum = htl.iatanum and cts.matchedclientcode = htl.clientcode
and cts.matchedseqnum = htl.SeqNum and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '2'
and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '3'
--select HTL.HtlConfNum, cts.confirmation,htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL  AND htl.GDSRecordLocator = cts.pnr_id
and substring(CTS.confirmation,1,5) = substring(HTL.HtlConfNum,1,5)
AND CTS.prop_city = HTL.HtlCityName and cts.status = 'A'
and htl.iatanum in ('prehgp','prehis')

-- 

update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '3'
--select HTL.HtlConfNum, cts.confirmation,htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL  AND htl.GDSRecordLocator = cts.pnr_id
and substring(CTS.confirmation,1,5) = substring(HTL.HtlConfNum,1,5)
AND CTS.prop_city = HTL.HtlCityName    and cts.status = 'P'
  and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))
  and htl.iatanum in ('prehgp','prehis')

--
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '3'
--select HTL.HtlConfNum, cts.confirmation,htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND htl.GDSRecordLocator = cts.pnr_id
and substring(CTS.confirmation,1,5) = substring(HTL.HtlConfNum,1,5)
AND CTS.prop_city = HTL.HtlCityName   and cts.status = 'N'
  and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
  and htl.iatanum in ('prehgp','prehis')

--
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '3'
--select HTL.HtlConfNum, cts.confirmation,htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL  AND htl.GDSRecordLocator = cts.pnr_id
and substring(CTS.confirmation,1,5) = substring(HTL.HtlConfNum,1,5)
AND CTS.prop_city = HTL.HtlCityName    and cts.status = 'S'
  and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
  and htl.iatanum in ('prehgp','prehis')

--
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '3'
--select HTL.HtlConfNum, cts.confirmation,htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL AND htl.GDSRecordLocator = cts.pnr_id
and substring(CTS.confirmation,1,5) = substring(HTL.HtlConfNum,1,5)
AND CTS.prop_city = HTL.HtlCityName   and cts.status = 'X'
  and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
and htl.iatanum in ('prehgp','prehis')

--
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '3'
--select HTL.HtlConfNum, cts.confirmation,htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL AND htl.GDSRecordLocator = cts.pnr_id
and substring(CTS.confirmation,1,5) = substring(HTL.HtlConfNum,1,5)
AND CTS.prop_city = HTL.HtlCityName   and cts.status = 'C'
  and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
  and htl.iatanum in ('prehgp','prehis')
  
  --
 UPDATE HTL
 set htl.HtlCommAmt = cts.commission ,htl.CommTrackInd = cts.status ,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source ,htl.Remarks4 = cts.check_num ,htl.MatchedInd = '3' ,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode and cts.matchedseqnum = htl.SeqNum and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '3'
and htl.iatanum in ('prehgp','prehis')

-- 
update cts
set cts.matchedrecordkey = htl.RecordKey ,cts.matchediatanum = htl.iatanum ,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum ,cts.matchedhtlsegnum = htl.HtlSegNum ,cts.market = '4' 
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND HTL.HtlChainCode = CTS.prop_chain
AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
AND Difference(CTS.First_Name, HTL.FirstName) = 4
AND CTS.Last_Name = HTL.LastName
AND (CTS.out_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate
  OR CTS.in_date   BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
  and cts.status = 'A'
  and htl.iatanum in ('prehgp','prehis')
 
------------------------------------------------------------------------------------------------------------------------------------------
update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '4'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND HTL.HtlChainCode = CTS.prop_chain
AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
AND Difference(CTS.First_Name, HTL.FirstName) = 4
AND CTS.Last_Name = HTL.LastName
AND (CTS.out_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate
  OR CTS.in_date   BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
  and cts.status = 'P'
  and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

----------------------------------------------------------------------------------------------------------------------------------------------

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '4'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND HTL.HtlChainCode = CTS.prop_chain
AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
AND Difference(CTS.First_Name, HTL.FirstName) = 4
AND CTS.Last_Name = HTL.LastName
AND (CTS.out_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate
  OR CTS.in_date   BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
  and cts.status = 'N'
  and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '4'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND HTL.HtlChainCode = CTS.prop_chain
AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
AND Difference(CTS.First_Name, HTL.FirstName) = 4
AND CTS.Last_Name = HTL.LastName
AND (CTS.out_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate
  OR CTS.in_date   BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
  and cts.status = 'S'
  and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')
 
--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '4'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND HTL.HtlChainCode = CTS.prop_chain
AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
AND Difference(CTS.First_Name, HTL.FirstName) = 4
AND CTS.Last_Name = HTL.LastName
AND (CTS.out_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate
  OR CTS.in_date   BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
  and cts.status = 'X'
  and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')
  
--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '4'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
AND HTL.HtlChainCode = CTS.prop_chain
AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
AND Difference(CTS.First_Name, HTL.FirstName) = 4
AND CTS.Last_Name = HTL.LastName
AND (CTS.out_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate
  OR CTS.in_date   BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
  and cts.status = 'C'
  and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

--

  UPDATE HTL
set htl.HtlCommAmt = cts.commission
,htl.CommTrackInd = cts.status
,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source
,htl.Remarks4 = cts.check_num
,htl.MatchedInd = '4'
,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey
and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode
and cts.matchedseqnum = htl.SeqNum
and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '4'
 and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '5'
--select htl.recordkey, cts.id,htl.FirstName name, cts.first_name,htl.Lastname, cts.last_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,htl.htlcityname,cts.prop_city
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
  AND HTL.HtlChainCode = CTS.prop_chain
    AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND substring(CTS.First_Name,1,1) = substring(HTL.FirstName,1,1)
   AND CTS.last_name = HTL.LastName
   AND (CTS.out_date BETWEEN HTL.CheckoutDate AND HTL.CheckoutDate + 1
    OR CTS.in_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
    and cts.status = 'A'
     and htl.iatanum in ('prehgp','prehis')

--

Update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '5'
--select htl.FirstName name, cts.first_name,htl.Lastname, cts.last_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
  AND HTL.HtlChainCode = CTS.prop_chain
    AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND substring(CTS.First_Name,1,1) = substring(HTL.FirstName,1,1)
   AND CTS.last_name = HTL.LastName
   AND (CTS.out_date BETWEEN HTL.CheckoutDate AND HTL.CheckoutDate + 1
    OR CTS.in_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
    and cts.status = 'P'
   and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))
    and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '5'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
  AND HTL.HtlChainCode = CTS.prop_chain
    AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND substring(CTS.First_Name,1,1) = substring(HTL.FirstName,1,1)
   AND CTS.last_name = HTL.LastName
   AND (CTS.out_date BETWEEN HTL.CheckoutDate AND HTL.CheckoutDate + 1
    OR CTS.in_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
    and cts.status = 'N'
  and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '5'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
  AND HTL.HtlChainCode = CTS.prop_chain
    AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND substring(CTS.First_Name,1,1) = substring(HTL.FirstName,1,1)
   AND CTS.last_name = HTL.LastName
   AND (CTS.out_date BETWEEN HTL.CheckoutDate AND HTL.CheckoutDate + 1
    OR CTS.in_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
    and cts.status = 'S'
  and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '5'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
  AND HTL.HtlChainCode = CTS.prop_chain
    AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND substring(CTS.First_Name,1,1) = substring(HTL.FirstName,1,1)
   AND CTS.last_name = HTL.LastName
   AND (CTS.out_date BETWEEN HTL.CheckoutDate AND HTL.CheckoutDate + 1
    OR CTS.in_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
    and cts.status = 'X'
  and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '5'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
  AND HTL.HtlChainCode = CTS.prop_chain
    AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND substring(CTS.First_Name,1,1) = substring(HTL.FirstName,1,1)
   AND CTS.last_name = HTL.LastName
   AND (CTS.out_date BETWEEN HTL.CheckoutDate AND HTL.CheckoutDate + 1
    OR CTS.in_date BETWEEN HTL.CheckinDate AND HTL.CheckoutDate)
    and cts.status = 'C'
  and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
   and htl.iatanum in ('prehgp','prehis')

--
  
 UPDATE HTL
set htl.HtlCommAmt = cts.commission
,htl.CommTrackInd = cts.status
,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source
,htl.Remarks4 = cts.check_num
,htl.MatchedInd = '5'
,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey
and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode
and cts.matchedseqnum = htl.SeqNum
and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '5'
 and htl.iatanum in ('prehgp','prehis')

-----------------------------------------------------------------------------------------------------------------------------

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '6'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckinDate,cts.in_date, htl.CheckoutDate,cts.out_date
--,case when in_date between CheckinDate and CheckoutDate then 'Y' else 'N' END
--,case when CheckinDate = in_date and out_date between CheckoutDate and CheckoutDate + 2 then 'Y' ELSE 'N' END
--,HTL.HtlChainCode, cts.prop_chain,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1)
   AND HtlAddr1 = prop_address1 
    and cts.status = 'A'
     and htl.iatanum in ('prehgp','prehis')

--
Update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '6'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1)
   AND HtlAddr1 = prop_address1 
        and cts.status = 'P'
           and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))
            and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '6'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1)
   AND HtlAddr1 = prop_address1 
        and cts.status = 'N'
    and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

----------------------------------------------------------------------------------------------------------------------------------

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '6'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1)
   AND HtlAddr1 = prop_address1 
        and cts.status = 'S'
    and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '6'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1)
   AND HtlAddr1 = prop_address1 
        and cts.status = 'X'
    and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '6'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 1)
   AND HtlAddr1 = prop_address1 
        and cts.status = 'C'
    and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')
 
 --
 
 UPDATE HTL
set htl.HtlCommAmt = cts.commission
,htl.CommTrackInd = cts.status
,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source
,htl.Remarks4 = cts.check_num
,htl.MatchedInd = '6'
,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey
and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode
and cts.matchedseqnum = htl.SeqNum
and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '6'
 and htl.iatanum in ('prehgp','prehis')
 
 
 ---------------------------------FALSE MATCHES---------------------------------------------------------------------------------------------
 
 update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '7'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3)
        and cts.status = 'A'
         and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '7'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3)
        and cts.status = 'P'
           and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))
            and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '7'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3)
        and cts.status = 'N'
    and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
 and htl.iatanum in ('prehgp','prehis')
 
--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '7'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3)
        and cts.status = 'S'
    and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '7'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3)
        and cts.status = 'X'
    and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '7'
--select htl.FirstName name, htl.Lastname, cts.full_name, htl.CheckoutDate,cts.out_date, HTL.HtlChainCode, cts.prop_chain,
--htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1,cts.prop_address1 
from dba.Hotel htl, dba.ctsdata cts
WHERE cts.MatchedRecordKey is NULL 
   AND HTL.HtlChainCode = CTS.prop_chain
   AND Difference(UPPER(CTS.prop_city), UPPER(HTL.HtlCityName)) = 4
   AND CTS.Last_Name = HTL.LastName
   AND (CTS.out_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3
    OR CTS.in_date     BETWEEN HTL.CheckinDate AND HTL.CheckoutDate + 3)
        and cts.status = 'C'
    and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--
 
 UPDATE HTL
set htl.HtlCommAmt = cts.commission
,htl.CommTrackInd = cts.status
,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source
,htl.Remarks4 = cts.check_num
,htl.MatchedInd = '7'
,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey
and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode
and cts.matchedseqnum = htl.SeqNum
and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '7'
 and htl.iatanum in ('prehgp','prehis')

 
--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '8'
--select confirmation,pnr_id,htlconfnum,gdsrecordlocator,htl.FirstName name, htl.Lastname, cts.full_name, HTL.HtlChainCode, cts.prop_chain, htl.CheckinDate,cts.in_date,
--htl.CheckoutDate,cts.out_date,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.ctsdata cts, dba.Hotel htl
where matchedrecordkey is null
and cts.confirmation=htl.HtlConfNum
and cts.last_name=htl.lastname
and cts.confirmation <> ''
and cts.confirmation not like '%+%'
and cts.confirmation NOT IN ('ROOMBLOCK','ARTHREX','GROUP','0','1','VIAEMAIL','SALES','ROOMINGLIST','DIRECT','CONFERENCE','CHRISTINE'
	,'ALEX','ANTHONY')
	and DATEDIFF(dd,CTS.out_date,HTL.CheckoutDate) between -3 and 3
		and DATEDIFF(dd,CTS.in_date,HTL.CheckinDate) between -3 and 3
        and cts.status = 'A'
         and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '8'
--select confirmation,pnr_id,htlconfnum,gdsrecordlocator,htl.FirstName name, htl.Lastname, cts.full_name, HTL.HtlChainCode, cts.prop_chain, htl.CheckinDate,cts.in_date,
--htl.CheckoutDate,cts.out_date,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.ctsdata cts, dba.Hotel htl
where matchedrecordkey is null
and cts.confirmation=htl.HtlConfNum
and cts.last_name=htl.lastname
and cts.confirmation <> ''
and cts.confirmation not like '%+%'
and cts.confirmation NOT IN ('ROOMBLOCK','ARTHREX','GROUP','0','1','VIAEMAIL','SALES','ROOMINGLIST','DIRECT','CONFERENCE','CHRISTINE'
	,'ALEX','ANTHONY')
	and DATEDIFF(dd,CTS.out_date,HTL.CheckoutDate) between -3 and 3
		and DATEDIFF(dd,CTS.in_date,HTL.CheckinDate) between -3 and 3
   and cts.status = 'P'
           and ((htl.CommTrackInd <> 'A' or htl.CommTrackInd is NULL))

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '8'
--select confirmation,pnr_id,htlconfnum,gdsrecordlocator,htl.FirstName name, htl.Lastname, cts.full_name, HTL.HtlChainCode, cts.prop_chain, htl.CheckinDate,cts.in_date,
--htl.CheckoutDate,cts.out_date,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.ctsdata cts, dba.Hotel htl
where matchedrecordkey is null
and cts.confirmation=htl.HtlConfNum
and cts.last_name=htl.lastname
and cts.confirmation <> ''
and cts.confirmation not like '%+%'
and cts.confirmation NOT IN ('ROOMBLOCK','ARTHREX','GROUP','0','1','VIAEMAIL','SALES','ROOMINGLIST','DIRECT','CONFERENCE','CHRISTINE'
	,'ALEX','ANTHONY')
	and DATEDIFF(dd,CTS.out_date,HTL.CheckoutDate) between -3 and 3
		and DATEDIFF(dd,CTS.in_date,HTL.CheckinDate) between -3 and 3
        and cts.status = 'N'
    and ((htl.CommTrackInd not in ('A','P') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '8'
--select confirmation,pnr_id,htlconfnum,gdsrecordlocator,htl.FirstName name, htl.Lastname, cts.full_name, HTL.HtlChainCode, cts.prop_chain, htl.CheckinDate,cts.in_date,
--htl.CheckoutDate,cts.out_date,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.ctsdata cts, dba.Hotel htl
where matchedrecordkey is null
and cts.confirmation=htl.HtlConfNum
and cts.last_name=htl.lastname
and cts.confirmation <> ''
and cts.confirmation not like '%+%'
and cts.confirmation NOT IN ('ROOMBLOCK','ARTHREX','GROUP','0','1','VIAEMAIL','SALES','ROOMINGLIST','DIRECT','CONFERENCE','CHRISTINE'
	,'ALEX','ANTHONY')
	and DATEDIFF(dd,CTS.out_date,HTL.CheckoutDate) between -3 and 3
		and DATEDIFF(dd,CTS.in_date,HTL.CheckinDate) between -3 and 3
        and cts.status = 'S'
    and ((htl.CommTrackInd not in ('A','P','N') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '8'
--select confirmation,pnr_id,htlconfnum,gdsrecordlocator,htl.FirstName name, htl.Lastname, cts.full_name, HTL.HtlChainCode, cts.prop_chain, htl.CheckinDate,cts.in_date,
--htl.CheckoutDate,cts.out_date,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.ctsdata cts, dba.Hotel htl
where matchedrecordkey is null
and cts.confirmation=htl.HtlConfNum
and cts.last_name=htl.lastname
and cts.confirmation <> ''
and cts.confirmation not like '%+%'
and cts.confirmation NOT IN ('ROOMBLOCK','ARTHREX','GROUP','0','1','VIAEMAIL','SALES','ROOMINGLIST','DIRECT','CONFERENCE','CHRISTINE'
	,'ALEX','ANTHONY')
	and DATEDIFF(dd,CTS.out_date,HTL.CheckoutDate) between -3 and 3
		and DATEDIFF(dd,CTS.in_date,HTL.CheckinDate) between -3 and 3
        and cts.status = 'X'
    and ((htl.CommTrackInd not in ('A','P','N','S') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--

update cts
set cts.matchedrecordkey = htl.RecordKey
,cts.matchediatanum = htl.iatanum
,cts.matchedclientcode = htl.clientcode
,cts.matchedseqnum = htl.SeqNum
,cts.matchedhtlsegnum = htl.HtlSegNum
,cts.market = '8'
--select confirmation,pnr_id,htlconfnum,gdsrecordlocator,htl.FirstName name, htl.Lastname, cts.full_name, HTL.HtlChainCode, cts.prop_chain, htl.CheckinDate,cts.in_date,
--htl.CheckoutDate,cts.out_date,htl.HtlPropertyName, cts.prop_name, htl.HtlAddr1,cts.prop_address1
from dba.ctsdata cts, dba.Hotel htl
where matchedrecordkey is null
and cts.confirmation=htl.HtlConfNum
and cts.last_name=htl.lastname
and cts.confirmation <> ''
and cts.confirmation not like '%+%'
and cts.confirmation NOT IN ('ROOMBLOCK','ARTHREX','GROUP','0','1','VIAEMAIL','SALES','ROOMINGLIST','DIRECT','CONFERENCE','CHRISTINE'
	,'ALEX','ANTHONY')
	and DATEDIFF(dd,CTS.out_date,HTL.CheckoutDate) between -3 and 3
		and DATEDIFF(dd,CTS.in_date,HTL.CheckinDate) between -3 and 3
        and cts.status = 'C'
    and ((htl.CommTrackInd not in ('A','P','N','S','X') or htl.CommTrackInd is NULL))
     and htl.iatanum in ('prehgp','prehis')

--
 
 UPDATE HTL
set htl.HtlCommAmt = cts.commission
,htl.CommTrackInd = cts.status
,htl.HtlCommPostDate = cts.deposit_date
,htl.voidreasontype = cts.pay_source
,htl.Remarks4 = cts.check_num
,htl.MatchedInd = '8'
,htl.matchedfields = cts.id
from dba.Hotel htl, dba.ctsdata cts
where cts.matchedrecordkey = htl.RecordKey
and cts.matchediatanum = htl.iatanum
and cts.matchedclientcode = htl.clientcode
and cts.matchedseqnum = htl.SeqNum
and cts.matchedhtlsegnum = htl.HtlSegNum
and cts.market = '8'
  and htl.iatanum in ('prehgp','prehis')
 


GO
