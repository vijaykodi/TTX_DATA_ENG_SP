/****** Object:  StoredProcedure [dbo].[PurgeVCFSequenceNumber]    Script Date: 7/14/2015 7:49:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Allen Reinmeyer
-- Create date: 10/31/2012
-- Description:	With a given sequence number as a parameter,
--      deletes the row in DBA.VCFSequenceNumbers
--      and sets CCHeader.Remarks15 to NULL where it was previously
--      set to the matching sequence number
-- =============================================
CREATE PROCEDURE [dbo].[PurgeVCFSequenceNumber]
	-- Add the parameters for the stored procedure here
	@seqNum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    DECLARE @seqNumExists as int
    DECLARE @rowsDeleted as int
    DECLARE @rowsUpdated as int
    DECLARE @errorNum as int
    
    SELECT @seqNumExists = v.sequencenum
        FROM dba.VCFSequenceNumbers v
        WHERE v.sequencenum = @seqNum
    
    --Check that the sequence number exists.  No point in trying
    --to update the tables with values that don't exist    
    If @seqNumExists is null 
        BEGIN
            print 'Sequence Number not found, stopping procedure!'
            return
        END
    
    UPDATE dba.CCHeader
    set Remarks15 = NULL
    WHERE Remarks15 = @seqNum
    
    SELECT @rowsUpdated = @@ROWCOUNT, @errorNum = @@ERROR
    print 'Updated ' + convert(char(6), @rowsUpdated) + ' rows in CCHeader'
    
    IF @errorNum <> 0 print @errorNum
    
    DELETE FROM dba.VCFSequenceNumbers
    WHERE sequencenum = @seqNum
    
    SELECT @rowsDeleted = @@ROWCOUNT, @errorNum = @@ERROR
    print 'Deleted ' + convert(char(6), @rowsDeleted) + ' rows in VCFSequenceNumbers'
    IF @errorNum <> 0 print @errorNum
    
    return
END

GO
