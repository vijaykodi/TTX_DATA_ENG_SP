/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:16:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Nina Lutz
--Create Date: 04/02/2013

update htl
set prefhtlind = 'N'
from dba.hotel htl
where prefhtlind is null
and htl.checkindate >= '2012-01-01'


update htl
set prefhtlind = 'Y'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate >= '2012-01-01'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season1start and prefhtl.season1end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'Y'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate >= '2012-01-01'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season2start and prefhtl.season2end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'Y'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate >= '2012-01-01'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season3start and prefhtl.season3end
and htl.prefhtlind = 'N'


update htl
set prefhtlind = 'Y'
from dba.preferredhotels prefhtl, dba.hotelproperty htlxref,dba.hotelproperty htlprop,dba.hotel htl
where prefhtl.masterid = htlxref.masterid
and htlxref.parentid = htlprop.parentid
and htl.checkindate >= '2012-01-01'
and htl.masterid = htlprop.masterid
and htl.checkindate between prefhtl.season4start and prefhtl.season4end
and htl.prefhtlind = 'N'

END

GO
