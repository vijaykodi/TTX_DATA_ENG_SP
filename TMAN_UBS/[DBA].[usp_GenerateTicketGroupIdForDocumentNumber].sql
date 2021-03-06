/****** Object:  StoredProcedure [DBA].[usp_GenerateTicketGroupIdForDocumentNumber]    Script Date: 7/14/2015 7:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dba].[usp_GenerateTicketGroupIdForDocumentNumber]
AS
BEGIN
    SET NOCOUNT ON

    BEGIN
        UPDATE i
                SET i.TicketGroupId = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.TicketGroupId FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (i.RecordKey)
                        END
                ),
                i.OriginalDocumentNumber = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.OriginalDocumentNumber FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (i.DocumentNumber)
                        END
                )
        FROM dba.InvoiceDetail i WHERE i.DocumentNumber IS NOT NULL AND i.TicketGroupId IS NULL
    END

END


GO
