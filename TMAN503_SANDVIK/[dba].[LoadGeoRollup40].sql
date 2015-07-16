/****** Object:  StoredProcedure [dba].[LoadGeoRollup40]    Script Date: 7/14/2015 8:14:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure dba.LoadGeoRollup40
--YL 06/04/2014
as 
insert into dba.rollup40(COSTRUCTID,CORPORATESTRUCTURE,DESCRIPTION
,ROLLUP1,ROLLUPDESC1,ROLLUP2,ROLLUPDESC2,ROLLUP3,ROLLUPDESC3)
select  distinct 'Geographical',left(BusinessAddress,40),BusinessAddress
, 'Sandvik Global','Sandvik Global'--level1
,left(businesscountry,40),businesscountry --level2
,left(BusinessAddress,40),BusinessAddress  --level3
from dba.Employee
GO
