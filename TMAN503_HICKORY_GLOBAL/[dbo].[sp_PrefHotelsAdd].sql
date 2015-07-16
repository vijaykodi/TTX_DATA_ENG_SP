/****** Object:  StoredProcedure [dbo].[sp_PrefHotelsAdd]    Script Date: 7/14/2015 8:10:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[sp_PrefHotelsAdd]
AS
BEGIN
--Creater: Nina Lutz
--Create Date: 10/29/2012

update htl
set prefhtlind = 'N'
from dba.hotel htl
where htl.checkindate between '2014-01-01' and '2014-12-31'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season1start and prefhtl.season1end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season2start and prefhtl.season2end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season3start and prefhtl.season3end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2014-01-01' and '2014-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season4start and prefhtl.season4end
and htl.prefhtlind = 'N'

------- 2015 Updates...added on 1/6/14 by Nina per case #00052692

update htl
set prefhtlind = 'N'
from dba.hotel htl
where htl.checkindate between '2015-01-01' and '2015-12-31'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season1start and prefhtl.season1end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season2start and prefhtl.season2end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season3start and prefhtl.season3end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'P'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate between '2015-01-01' and '2015-12-31'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season4start and prefhtl.season4end
and htl.prefhtlind = 'N'

END

GO
