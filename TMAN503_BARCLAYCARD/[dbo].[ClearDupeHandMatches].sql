/****** Object:  StoredProcedure [dbo].[ClearDupeHandMatches]    Script Date: 7/14/2015 7:49:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================
-- Author:		Ian Patmore
-- Create date: 15-AUG-2014

-- Stored procedure created to clear duplicate matches
-- made causing issues with reports - Case #43659
-- ======================================================

CREATE PROCEDURE [dbo].[ClearDupeHandMatches] AS
BEGIN

	SET NOCOUNT ON

DECLARE @ProcName varchar(50), @TransStart datetime

	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

--Log activity
SET @TransStart = getdate()
--Clear duplicate matches where the recordkey/ccrecordkey/seqnum exist more than once.
--ROW_NUMBER used to keep only the first time the match was made (IanP 15AUG14)
WITH x AS 
(
    SELECT y = ROW_NUMBER() 
                OVER( 
                  PARTITION BY RecordKey, SeqNum, CCMatchedRecordKey 
                  ORDER BY MatchCreateDate ASC), * 
    FROM dba.InvoiceDetailCCMatch
) 
DELETE FROM x 
WHERE  y > 1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ClearDupeHandMatches',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
			        
END


GO
