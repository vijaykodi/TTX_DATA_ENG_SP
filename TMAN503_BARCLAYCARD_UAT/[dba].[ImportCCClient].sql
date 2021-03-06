/****** Object:  StoredProcedure [dba].[ImportCCClient]    Script Date: 7/14/2015 7:49:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dba].[ImportCCClient]
	@IATANumber VARCHAR(8)
    --@CompanyIdentification DECIMAL(10), 
    --@SequenceNumber DECIMAL(5)
AS
BEGIN
	INSERT INTO
		[dba].[CCClient]
	SELECT
		CONVERT(VARCHAR(15), [HT].[CompanyIdentification]) AS [ClientCode],
		CONVERT(VARCHAR(8), @IATANumber) AS [IATANum],
		CONVERT(VARCHAR(50), [C].[CompanyName]) AS [CustName],
		CONVERT(VARCHAR(40), [C].[AddressLine1]) AS [CustAddr1],
		CONVERT(VARCHAR(40), [C].[AddressLine2]) AS [CustAddr2],
		CONVERT(VARCHAR(40), [C].[AddressLine3]) AS [CustAddr3],
		CONVERT(VARCHAR(25), [C].[City]) AS [City],
		CONVERT(VARCHAR(20), [C].[StateProvinceCode]) AS [State],
		CONVERT(VARCHAR(10), [C].[PostalCode]) AS [Zip],
		CONVERT(VARCHAR(20), NULL) AS [CustPhone],
		CONVERT(VARCHAR(5), [C].[ISOCountryCode]) AS [CountryCode],
		CONVERT(VARCHAR(40), NULL) AS [AttnLine],
		CONVERT(VARCHAR(80), NULL) AS [Email],
		CONVERT(VARCHAR(50), NULL) AS [ConsolidationCode],
		CONVERT(VARCHAR(255), [C].[OptionalField1]) AS [ClientRemark1],
		CONVERT(VARCHAR(255), [C].[OptionalField2]) AS [ClientRemark2],
		CONVERT(VARCHAR(255), [C].[OptionalField3]) AS [ClientRemark3],
		CONVERT(VARCHAR(255), [C].[OptionalField4]) AS [ClientRemark4],
		CONVERT(VARCHAR(255), [HT].[SequenceNumber]) AS [ClientRemark5],
		CONVERT(VARCHAR(255), NULL) AS [ClientRemark6],
		CONVERT(VARCHAR(255), NULL) AS [ClientRemark7],
		CONVERT(VARCHAR(255), NULL) AS [ClientRemark8],
		CONVERT(VARCHAR(255), NULL) AS [ClientRemark9],
		CONVERT(VARCHAR(255), NULL) AS [ClientRemark10]
	FROM
		[dba].[HeaderTrailer] AS [HT],
		[dba].[Company] AS [C]
	WHERE
		[HT].[TransactionCode] = 6 AND
		--[HT].[CompanyIdentification] = @CompanyIdentification AND
		--[HT].[SequenceNumber] = @SequenceNumber AND
		[HT].[TransactionCode] *= [C].[HeaderTrailerTransactionCode] AND
		[HT].[CompanyIdentification] *= [C].[HeaderTrailerCompanyIdentification] AND
		[HT].[SequenceNumber] *= [C].[HeaderTrailerSequenceNumber];
END;

GO
