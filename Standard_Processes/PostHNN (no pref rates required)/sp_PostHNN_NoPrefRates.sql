USE [TMAN503_Volvo]
GO
/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 05/12/2015 14:25:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Laurie Webb
--Create Date: 5/28/2014

update dba.hotel
set prefhtlind = 'N'
where checkindate between '2015-01-01' and '2015-12-31'

 
update htl
set htl.prefhtlind ='Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end


update htl
set htl.prefhtlind ='Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end


update htl
set htl.prefhtlind ='Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end


update htl
set htl.prefhtlind ='Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end



----CCard update:

update dba.cchotel
set noshowind = 'N'
where transactiondate between '2015-01-01' and '2015-12-31'

Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.transactiondate between '2015-01-01' and '2015-12-31'

Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.transactiondate between '2015-01-01' and '2015-12-31'


Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.transactiondate between '2015-01-01' and '2015-12-31'


Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where cchtl.TransactionDate between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and cchtl.transactiondate between '2015-01-01' and '2015-12-31'




END






