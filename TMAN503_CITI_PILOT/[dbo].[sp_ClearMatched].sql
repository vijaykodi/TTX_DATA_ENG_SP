/****** Object:  StoredProcedure [dbo].[sp_ClearMatched]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ClearMatched] (@pi_RecordKey varchar(300))
AS

begin

 
UPDATE tCCH
SET tcch.matchedind = NULL
FROM dba.CCHeader tCCH
WHERE tCCH.recordkey = @pi_RecordKey

UPDATE tID
SET tID.MatchedInd = NULL
    ,tID.CCMatchedRecordKey = NULL
    ,tID.CCMatchedIataNum = NULL
FROM dba.InvoiceDetail tID
WHERE tID.CCMatchedRecordKey = @pi_RecordKey

DELETE tIDCCM
FROM dba.InvoiceDetailCCMatch tIDCCM
WHERE tIDCCM.CCMatchedRecordKey = @pi_RecordKey


END

GO
