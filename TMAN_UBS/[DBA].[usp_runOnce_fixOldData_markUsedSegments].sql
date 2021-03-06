/****** Object:  StoredProcedure [DBA].[usp_runOnce_fixOldData_markUsedSegments]    Script Date: 7/14/2015 7:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [DBA].[usp_runOnce_fixOldData_markUsedSegments]
AS
BEGIN
    SET NOCOUNT ON
    BEGIN
        declare @TicketGroupId varchar(50)
        declare cur CURSOR LOCAL FAST_FORWARD for
            select distinct(TicketGroupId) from dba.InvoiceDetail

        open cur

        fetch next from cur into @TicketGroupId

        while @@FETCH_STATUS = 0 
        BEGIN
            exec [DBA].[usp_markUsedSegments] @TicketGroupId

            fetch next from cur into @TicketGroupId
        END

        close cur
        deallocate cur
    END

END
GO
