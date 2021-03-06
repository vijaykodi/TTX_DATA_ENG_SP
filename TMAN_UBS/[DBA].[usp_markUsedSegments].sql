/****** Object:  StoredProcedure [DBA].[usp_markUsedSegments]    Script Date: 7/14/2015 7:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [DBA].[usp_markUsedSegments]
    @TicketGroupId varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dba.TranSeg SET SegTrueTktCount = 1 WHERE RecordKey IN (SELECT RecordKey FROM dba.InvoiceDetail WHERE TicketGroupId=@TicketGroupId);

    UPDATE t
    SET t.SegTrueTktCount = 0
    FROM dba.TranSeg t join dba.InvoiceDetail i ON i.RecordKey=t.RecordKey AND i.SeqNum=t.SeqNum AND i.IataNum=t.IataNum
    AND (i.DocumentNumber IN (SELECT ii.OrigExchTktNum FROM dba.InvoiceDetail ii join dba.TranSeg tt on ii.RecordKey=tt.RecordKey WHERE i.TicketGroupId=ii.TicketGroupId AND t.DepartureDate >= tt.IssueDate))
    WHERE i.TicketGroupId=@TicketGroupId

END


GO
