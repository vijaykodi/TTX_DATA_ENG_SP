/****** Object:  StoredProcedure [dbo].[sp_CITI_ENHANCED_AGENCY_FIX]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DAVID CUTTS
-- Create date: 01/03/2013>
-- Description:	PROC CREATED TO FIX PROBLEMS 
--				WITH CITI ENHANCED AGENCY DATA
-- =============================================
CREATE PROCEDURE [dbo].[sp_CITI_ENHANCED_AGENCY_FIX] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--===============================================
--LOGITECH CITI ENHANCED CLEANUP                
--###############################################
--REWRITE CCNUMS                                
--===============================================
Update dba.invoiceheader
Set ccnum = pb.childcard
FROM dba.InvoiceHeader AS ih
INNER JOIN dba.ProfileBuilds AS pb ON RIGHT(RTRIM(LTRIM(ih.CCNum)), 4) = RIGHT(pb.childcard, 4)
WHERE pb.GROUPNAME LIKE '%LOG%'
AND ih.IataNum LIKE '%log%'
AND ISNUMERIC(ih.CCNum)=1
AND LEN(ih.CCNum)!=16

--===============================================
--CLEAN UP VENDOR TYPES
--===============================================
UPDATE dba.InvoiceDetail
SET VendorType = 'NONBSP'
WHERE VendorType NOT IN ('BSP', 'NONBSP', 'HOTEL') OR VendorType IS NULL
END

GO
