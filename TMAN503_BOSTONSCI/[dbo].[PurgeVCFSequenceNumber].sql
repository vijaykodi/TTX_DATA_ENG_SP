/****** Object:  StoredProcedure [dbo].[PurgeVCFSequenceNumber]    Script Date: 7/14/2015 7:50:55 PM ******/
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


/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[PurgeVCFSequenceNumber]
************************************************************************/
--R. Robinson modified added time to stepname
declare @TransStart DATETIME declare @ProcName varchar(50)
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/



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

 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/



END

GO
