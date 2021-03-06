/****** Object:  StoredProcedure [dbo].[sp_UpdateVendorType]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* This Stored Procedure updates records to contain VendorType 'NONBSP'. This is needed to allow the BLR team to perform daily matching in the hand matching application
Requested by Mark Jones, SF Case 06635904 
-- Created by MD Sarkar
*/

CREATE PROCEDURE [dbo].[sp_UpdateVendorType]

AS

BEGIN

UPDATE TTXPASQL01.TMAN503_CITI_PILOT.dba.InvoiceDetail
SET VendorType = 'NONBSP'
WHERE VendorType = 'NONAIR'
AND
VendorName LIKE '%Visa Card%'

END
GO
