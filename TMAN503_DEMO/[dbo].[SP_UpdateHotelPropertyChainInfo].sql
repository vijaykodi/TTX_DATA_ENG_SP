/****** Object:  StoredProcedure [dbo].[SP_UpdateHotelPropertyChainInfo]    Script Date: 7/14/2015 8:00:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Jonathan Coplon
-- Create date: 4/12/2012
-- Description:	Updates HotelProperty Chain Information
-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateHotelPropertyChainInfo]
AS
BEGIN
	Declare @qry varchar(8000)

	--Set Chain Codes
	set @qry = 'update D'
      +' Set D.ChainCode = D1.ChainCode,'
      +'    D.ChainName = D1.ChainName'
      +' FROM DBA.HotelProperty D, DBA.HotelChains D1'
      +' WHERE (D.ChainCode IS NULL'
      +'   OR LEN(D.ChainCode) >= 3'
      +'   OR D.ChainCode = '''')'
      +' AND D1.KeyWord3 IS NOT NULL'
      +' AND (D.HotelPropertyName like (''% '' + D1.KeyWord1 + ''%''  + D1.KeyWord2 + ''%''  + D1.KeyWord3 + ''%'')'
      +'  OR  D.HotelPropertyName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%''  + D1.KeyWord3 + ''%'')'
      +'  OR  D.ChainName like (''% '' + D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%''  + D1.KeyWord3 + ''%'')'
      +'  OR  D.ChainName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'' + D1.KeyWord3 + ''%''))'
	
	 exec(@qry)

	 set @qry = 'update D'
      +' Set D.ChainCode = D1.ChainCode,'
      +'    D.ChainName = D1.ChainName'
      +' FROM DBA.HotelProperty D, DBA.HotelChains D1'
      +' WHERE (D.ChainCode IS NULL'
      +'   OR LEN(D.ChainCode) >= 3'
      +'   OR D.ChainCode = '''')'
      +' AND D1.KeyWord2 IS NOT NULL'
      +' AND  D1.KeyWord3 IS NULL'
      +' AND ((D.HotelPropertyName like (''% '' + D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'')'
      +'  OR D.HotelPropertyName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'')'
      +'  OR D.ChainName like (''% '' + D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'')'
      +'  OR D.ChainName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%''))'
      +'  OR ( D1.KeyWord1 IS NULL'
      +'  AND (D.HotelPropertyName like (''% '' + D1.KeyWord2 + ''%'')'
      +'  OR D.HotelPropertyName like (D1.KeyWord2 + ''%'')'
      +'  OR D.ChainName like (''% '' + D1.KeyWord2 + ''%'')'
      +'  OR D.ChainName like (D1.KeyWord2 + ''%''))))'

	 exec(@qry)

	set @qry = 'update D'
      +' Set D.ChainCode = D1.ChainCode,'
      +'    D.ChainName = D1.ChainName'
      +' FROM DBA.HotelProperty D, DBA.HotelChains D1'
      +' WHERE (D.ChainCode IS NULL'
      +'   OR LEN(D.ChainCode) >= 3'
      +'   OR D.ChainCode = '''')'
      +' AND D1.KeyWord1 IS NOT NULL'
      +' AND D1.KeyWord2 IS  NULL'
      +' AND D1.KeyWord3 IS NULL'
      +' AND (D.HotelPropertyName like (''% '' + D1.KeyWord1 + ''%'')'
      +'  OR D.HotelPropertyName like (D1.KeyWord1 + ''%'')'
      +'  OR D.ChainName like (''% '' + D1.KeyWord1 + ''%'')'
      +'  OR D.ChainName like (D1.KeyWord1 + ''%''))'

	 exec(@qry)

	 set @qry = 'update D'
      +' Set D.ChainCode = D1.ChainCode,'
      +'    D.ChainName = D1.ChainName'
      +' FROM DBA.HotelProperty D, DBA.HotelChains D1'
      +' WHERE (D.ChainCode IS NULL'
      +'   OR LEN(D.ChainCode) >= 3'
      +'   OR D.ChainCode = '''')'
      +' AND D1.KeyWord4 IS NOT NULL'
      +' AND (D.HotelPropertyName like (''% '' + D1.KeyWord4 +  ''%'')'
      +'  OR D.HotelPropertyName like (D1.KeyWord4 + ''%'')'
      +'  OR D.ChainName like (''% '' + D1.KeyWord4 + ''%'')'
      +'  OR D.ChainName like (D1.KeyWord4 + ''%''))'

	 exec(@qry)


	 set @qry = 'update D'
      +' Set D.ChainCode = ''WH'','
      +'    D.ChainName = ''W HOTELS'''
      +' FROM DBA.HotelProperty D'
      +' WHERE (D.ChainCode IS NULL'
      +'   OR LEN(D.ChainCode) >= 3'
      +'   OR D.ChainCode = '''')'
      +' AND (D.HotelPropertyName like (''W %'')'
      +'  OR D.ChainName like (''W %''))'

	 exec(@qry)


	 set @qry = 'update D'
      +' Set D.ChainCode = ''XX'''
      +' FROM DBA.HotelProperty D'
      +' WHERE (D.ChainCode IS NULL'
      +'   OR LEN(D.ChainCode) >= 3'
      +'   OR D.ChainCode = '''')'

	 exec(@qry)

--Update Star Ratings
	set @qry = 'UPDATE D'
	+' SET D.StarRating = D1.STRRating'
	+' FROM DBA.HotelProperty D, DBA.HotelChains D1'
	+' WHERE D1.KeyWord3 IS NOT NULL'
	+' AND D.StarRating is NULL'
	+' AND (D.HotelPropertyName like (''% '' + D1.KeyWord1 + ''%''  + D1.KeyWord2 + ''%''  + D1.KeyWord3 + ''%'')'
	+'  OR  D.HotelPropertyName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%''  + D1.KeyWord3 + ''%'')'
	+'  OR  D.ChainName like (''% '' + D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%''  + D1.KeyWord3 + ''%'')'
	+'  OR  D.ChainName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'' + D1.KeyWord3 + ''%''))'
	

	exec(@qry)

	set @qry = 'UPDATE D'
	+' SET D.StarRating = D1.STRRating'
	+' FROM DBA.HotelProperty D, DBA.HotelChains D1'
	+' WHERE D1.KeyWord2 IS NOT NULL'
	+' AND  D1.KeyWord3 IS NULL'
	+' AND D.StarRating is NULL'
	+' AND ((D.HotelPropertyName like (''% '' + D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'')'
	+'  OR D.HotelPropertyName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'')'
	+'  OR D.ChainName like (''% '' + D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%'')'
	+'  OR D.ChainName like (D1.KeyWord1 + ''%'' + D1.KeyWord2 + ''%''))'
	+'  OR ( D1.KeyWord1 IS NULL'
	+'  AND (D.HotelPropertyName like (''% '' + D1.KeyWord2 + ''%'')'
	+'  OR D.HotelPropertyName like (D1.KeyWord2 + ''%'')'
	+'  OR D.ChainName like (''% '' + D1.KeyWord2 + ''%'')'
	+'  OR D.ChainName like (D1.KeyWord2 + ''%''))))'


	exec(@qry)

	set @qry = 'UPDATE D'
	+' SET D.StarRating = D1.STRRating'
	+' FROM DBA.HotelProperty D, DBA.HotelChains D1'
	+' WHERE D1.KeyWord1 IS NOT NULL'
	+' AND D1.KeyWord2 IS  NULL'
	+' AND D1.KeyWord3 IS NULL'
	+' AND D.StarRating is NULL'
	+' AND (D.HotelPropertyName like (''% '' + D1.KeyWord1 + ''%'')'
	+'  OR D.HotelPropertyName like (D1.KeyWord1 + ''%'')'
	+'  OR D.ChainName like (''% '' + D1.KeyWord1 + ''%'')'
	+'  OR D.ChainName like (D1.KeyWord1 + ''%''))'
	
	      
	exec(@qry)

	set @qry = 'UPDATE D'
	+' SET D.StarRating = D1.STRRating'
	+' FROM DBA.HotelProperty D, DBA.HotelChains D1'
	+' WHERE D1.KeyWord4 IS NOT NULL'
	+' AND D.StarRating is NULL'
	+' AND (D.HotelPropertyName like (''% '' + D1.KeyWord4 +  ''%'')'
	+'  OR D.HotelPropertyName like (D1.KeyWord4 + ''%'')'
	+'  OR D.ChainName like (''% '' + D1.KeyWord4 + ''%'')'
	+'  OR D.ChainName like (D1.KeyWord4 + ''%''))'
	
	exec(@qry)

	set @qry = 'UPDATE D'
	+' SET D.StarRating = ''5'''
	+' FROM DBA.HotelProperty D, DBA.HotelChains D1'
	+' WHERE D.StarRating is NULL'
	+' AND (D.HotelPropertyName like (''W %'')'
	+'  OR D.ChainName like (''W %''))'
	
	exec(@qry)
	
	set @qry = 'UPDATE D'
	+' SET D.StarRating = ''2.9'''
	+' FROM DBA.HotelProperty D, DBA.HotelChains D1'
	+' WHERE (D.StarRating is NULL'
	+'  OR D.StarRating = '''')'
	exec(@qry)
	
	--Chain Specific Cleanup
	
	--Misc Properties
	update dba.hotelproperty
	set starrating = '2.9'
	,chaincode = 'XX'
	where hotelpropertyname not like '%AMERICINN%'
	and chaincode = 'AA'

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'BV'
	where hotelpropertyname like '%Chinas BEST VALUE INN%'

	update dba.hotelproperty
	set starrating = '3'
	,chaincode = 'BV'
	where hotelpropertyname like '%Canadas BEST VALUE INN%'

	update dba.hotelproperty
	set starrating = '2'
	,chaincode = 'BV'
	where hotelpropertyname like '%Americas BEST VALUE INN%'

	-- Best Western
	update dba.hotelproperty
	set starrating = '3.5'
	,chaincode = 'BW'
	where hotelpropertyname like '%Best Western Plus%'

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'BW'
	where hotelpropertyname like '%Best Western Premier%'


	-- Hilton Cleanup
	update dba.hotelproperty
	set starrating = '4.5'
	,chaincode = 'ES'
	where hotelpropertyname like '%Embassy s%'

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'DT'
	where hotelpropertyname like '%DoubleTree %'

	update dba.hotelproperty
	set starrating = '5'
	,chaincode = 'CN'
	where hotelpropertyname like '%Conrad %'

	-- Starwood Cleanup
	update dba.hotelproperty
	set starrating = '4.5'
	,chaincode = 'MD'
	where hotelpropertyname like '%Meridien %'

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'EL'
	where hotelpropertyname like '%ELEMENT %'

	update dba.hotelproperty
	set starrating = '4.5'
	,ChainName = 'SHERATON HOTELS AND RESORTS'
	where chaincode = 'SI'

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'SI'
	,ChainName = 'FOUR POINTS BY SHERATON'
	where hotelpropertyname like '%Four Points%'


	--Marriott Cleanup  
	update dba.hotelproperty
	set starrating = '5'
	,chaincode = 'MC'
	where hotelpropertyname like 'JW%'

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'AR'
	,ChainName = 'AC HOTELS BY MARRIOTT'
	where hotelpropertyname like 'AC %'

	update hp
	set hp.starrating = c.strrating
	from dba.hotelproperty hp, dba.hotelchains c
	where hp.chaincode = c.chaincode
	and hp.chaincode in ('MC','BR', 'CY','FN','RC','TO','XV','RZ')
	and hotelpropertyname not like 'JW%'
	and starrating <> strrating

	update hp
	set starrating = '4'
	,chaincode = 'CY'
	from dba.hotelproperty hp, dba.hotelchains c
	where hp.chaincode = c.chaincode
	and hp.chaincode in ('MC')
	and hotelpropertyname like '%Courtyard%'

	update hp
	set starrating = '5'
	,chaincode = 'RZ'
	from dba.hotelproperty hp, dba.hotelchains c
	where hp.chaincode = c.chaincode
	and hp.chaincode <> 'RZ'
	and hotelpropertyname like '%Ritz_C%'

	update dba.hotelproperty
	set starrating = '2.9'
	,chaincode = 'XX'
	where chaincode = 'BR'
	and hotelpropertyname <> ''
	and hotelpropertyname not like '%Ren%'
	and hotelpropertyname not like '%rnssance%'

	--- HYATT Updates 
	update dba.hotelproperty
	set starrating = '5'
	,chaincode = 'HY'
	where (hotelpropertyname like '%park hyatt%'
	or hotelpropertyname like '%grand hyatt%'
	or hotelpropertyname like '%Andaz%')

	update dba.hotelproperty
	set starrating = '4'
	,chaincode = 'HY'
	where (hotelpropertyname like '%hyatt house%'
	or hotelpropertyname like '%hyatt place%')

	--Accor Hotels
	update dba.hotelproperty
	set starrating = '4.5'
	,chaincode = 'RT'
	where (hotelpropertyname like '%PARTHENON%')

	update dba.hotelproperty
	set starrating = '3.5'
	,chaincode = 'RT'
	where (hotelpropertyname like '%Adagio%'
	or hotelpropertyname like '%Coralia%'
	or hotelpropertyname like '%PARTHENON%')

	update dba.hotelproperty
	set starrating = '3'
	,chaincode = 'RT'
	where (hotelpropertyname like '%All saison%'
	or hotelpropertyname like '%all season%'
	or hotelpropertyname like '%IBIS%')

	update dba.hotelproperty
	set starrating = '2'
	,chaincode = 'RT'
	where (hotelpropertyname like '%Etap%')
	
END



GO
