/****** Object:  StoredProcedure [dbo].[BarclayCardNOBILL]    Script Date: 7/14/2015 7:49:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- Author:		Ian Patmore
-- Create date: 16-AUG-2013
-- Description: Update IataNum for non-billable TMC records
-- =========================================================

CREATE PROCEDURE [dbo].[BarclayCardNOBILL] AS
BEGIN
BEGIN TRANSACTION

BEGIN TRY
	SET NOCOUNT ON

DECLARE @NoBillIata AS VARCHAR(8)
	SET @NoBillIata = 'NOBILL'

 --Set IataNum of non-billable InvoiceDetail records to NOBILL
UPDATE id
SET id.IataNum = @NoBillIata
FROM dba.InvoiceDetail id
	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = id.RecordKey
											AND ih.IataNum = id.IataNum
											AND ih.ClientCode = id.ClientCode
											AND ih.InvoiceDate = id.InvoiceDate
WHERE (
	NOT EXISTS (
		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
		)
	OR NOT EXISTS (
		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
		))
	AND NOT EXISTS (
		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
														 AND idcm.iatanum = ih.iatanum 
														 AND idcm.invoicedate = ih.invoicedate 
														 AND idcm.clientcode = ih.clientcode
		)
	AND id.IataNum != @NoBillIata
			
	
-- Set IataNum of non-billable Udef records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP
--UPDATE u
--SET u.IataNum = @NoBillIata
--FROM dba.Udef u
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = u.RecordKey
--											AND ih.IataNum = u.IataNum
--											AND ih.ClientCode = u.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND u.IataNum != @NoBillIata		


-- Set IataNum of non-billable Car records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP	
--UPDATE c
--SET c.IataNum = @NoBillIata
--FROM dba.Car c
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = c.RecordKey
--											AND ih.IataNum = c.IataNum
--											AND ih.ClientCode = c.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND c.IataNum != @NoBillIata	
	
	
-- Set IataNum of non-billable Hotel records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP
--UPDATE h
--SET h.IataNum = @NoBillIata
--FROM dba.Hotel h
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = h.RecordKey
--											AND ih.IataNum = h.IataNum
--											AND ih.ClientCode = h.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND h.IataNum != @NoBillIata			


-- Set IataNum of non-billable Tax records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP
--UPDATE t
--SET t.IataNum = @NoBillIata
--FROM dba.Tax t
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = t.RecordKey
--											AND ih.IataNum = t.IataNum
											
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND t.IataNum != @NoBillIata	


-- Set IataNum of non-billable ComRmks records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP
--UPDATE cr
--SET cr.IataNum = @NoBillIata
--FROM dba.ComRmks cr
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = cr.RecordKey
--											AND ih.IataNum = cr.IataNum
--											AND ih.ClientCode = cr.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND cr.IataNum != @NoBillIata	


-- Set IataNum of non-billable TranSeg records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP
--UPDATE ts
--SET ts.IataNum = @NoBillIata
--FROM dba.TranSeg ts
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = ts.RecordKey
--											AND ih.IataNum = ts.IataNum
--											AND ih.ClientCode = ts.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND ts.IataNum != @NoBillIata		
		
		
-- Set IataNum of non-billable Payment records to NOBILL
--commented out as this was taking too long to run an was not necessary. IP
--UPDATE p
--SET p.IataNum = @NoBillIata
--FROM dba.Payment p
--	INNER JOIN dba.InvoiceHeader AS ih ON ih.RecordKey = p.RecordKey
--											AND ih.IataNum = p.IataNum
--											AND ih.ClientCode = p.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND p.IataNum != @NoBillIata	


-- Set IataNum of non-billable Client records to NOBILL
-- Removed dba.Client from procedure due to PK constraint issues
--UPDATE cl
--SET cl.IataNum = @NoBillIata
--FROM dba.Client cl
--	LEFT OUTER JOIN dba.InvoiceHeader AS ih ON ih.IataNum = cl.IataNum
--											AND ih.ClientCode = cl.ClientCode
--WHERE (
--	NOT EXISTS (
--		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
--		)
--	OR NOT EXISTS (
--		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
--		))
--	AND NOT EXISTS (
--		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
--														 AND idcm.iatanum = ih.iatanum 
--														 AND idcm.invoicedate = ih.invoicedate 
--														 AND idcm.clientcode = ih.clientcode
--		)
--	AND cl.IataNum != @NoBillIata	
	

-- Set IataNum of non-billable Invoice Header records to NOBILL
-- Do this last to ensure the JOIN's on previous tables exist
UPDATE ih
SET ih.IataNum = @NoBillIata
FROM dba.InvoiceHeader ih
WHERE (
	NOT EXISTS (
		SELECT 1 FROM dba.ProfileBuilds AS pb WHERE ih.ccnum IN (pb.CHILDCARD, pb.PARENTCARD)
		)
	OR NOT EXISTS (
		SELECT 1 FROM dba.CCHeader AS cch WHERE ih.ccnum = cch.CreditCardNum
		))
	AND NOT EXISTS (
		SELECT 1 FROM dba.invoicedetailccmatch AS idcm where idcm.recordkey = ih.recordkey
														 AND idcm.iatanum = ih.iatanum 
														 AND idcm.invoicedate = ih.invoicedate 
														 AND idcm.clientcode = ih.clientcode
		)
	AND ih.IataNum != @NoBillIata

COMMIT TRANSACTION   
--Revert NOBILL where we now have data in ProfileBuilds
--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.InvoiceDetail n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.InvoiceDetail n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.Tax n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.Tax n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.ComRmks n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.ComRmks n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.Car n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.car n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.hotel n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.hotel n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.transeg n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.TranSeg n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.InvoiceDetailCCMatch n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.InvoiceDetailCCMatch n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.Payment n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.Payment n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)

--UPDATE n
--SET n.iatanum = ih.iatanum
--FROM dba.Udef n, dba.InvoiceHeader ih
--WHERE ih.RecordKey = n.RecordKey
--and n.iatanum = 'nobill'
--AND ih.IataNum NOT LIKE 'nobill'
--AND NOT EXISTS (SELECT 1 FROM dba.udef n 
--WHERE n.RecordKey+n.IataNum = ih.RecordKey+ih.IataNum)



END TRY
BEGIN CATCH
  PRINT '-------------------> '+ ERROR_MESSAGE()
  ROLLBACK
END CATCH  


       
END


GO
