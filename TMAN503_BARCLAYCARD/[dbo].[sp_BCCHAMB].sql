/****** Object:  StoredProcedure [dbo].[sp_BCCHAMB]    Script Date: 7/14/2015 7:49:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_BCCHAMB]AS

SET NOCOUNT ON

-- FIX AND POPULATE NULL TTLAMOUNT IN INVOICEDETAIL WHERE FEE 
-- AMOUNTS IS IN THE TICKET BUT NOT THE FEE RECORD
update dba.InvoiceDetail
set TotalAmt = ltrim(rtrim(
SUBSTRING(invoicetypedescription,CHARINDEX('Amount : ',invoicetypedescription)+9,len(invoicetypedescription)-CHARINDEX('Amount : ',invoicetypedescription)+9)
))
from dba.InvoiceDetail
where InvoiceTypeDescription like '%Amount : %'
and isnumeric(ltrim(rtrim(
SUBSTRING(invoicetypedescription,CHARINDEX('Amount : ',invoicetypedescription)+9,len(invoicetypedescription)-CHARINDEX('Amount : ',invoicetypedescription)+9)
))) = 1
and TotalAmt is null
and iatanum = 'BCCHAMB'




GO
