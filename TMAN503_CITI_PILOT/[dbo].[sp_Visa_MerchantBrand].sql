/****** Object:  StoredProcedure [dbo].[sp_Visa_MerchantBrand]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[sp_Visa_MerchantBrand]
	
 AS

select distinct merchantbrand from dba.ccmerchant
where merchantbrand is not null

update dba.ccmerchant
set merchantbrand = 'United Airlines' where merchantname1 like 'United%016%'

update dba.ccmerchant
set merchantbrand = 'Lufthansa' where merchantname1 like '%Lufthansa%'

update dba.ccmerchant
set merchantbrand = 'British Airways' where merchantname1 like 'British A%'

update dba.ccmerchant
set merchantbrand = 'Aer Lingus' where merchantname1 like 'Aer Lingus%'

update ccmerchant
set merchantbrand = 'Alaska Airlines' where merchantname1 like 'Alaska Air%'

update ccmerchant
set merchantbrand = 'American Airlines' where merchantname1 like 'American%'

update ccmerchant
set merchantbrand = 'Continental' where merchantname1 like 'Continental%'

update ccmerchant
set merchantbrand = 'Delta' where merchantname1 like 'Delta%'

update ccmerchant
set merchantbrand = 'Southwest Airlines' where ((merchantname1 like 'Southwest%')
	or (merchantname1 like 'SWA%'))

update ccmerchant
set merchantbrand = 'WestJet' where merchantname1 like 'WestJet%'

GO
