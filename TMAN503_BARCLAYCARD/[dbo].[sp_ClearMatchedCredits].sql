/****** Object:  StoredProcedure [dbo].[sp_ClearMatchedCredits]    Script Date: 7/14/2015 7:49:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ClearMatchedCredits] (@pi_RecordKey varchar(100))
AS

begin

 
UPDATE tCCH
SET tcch.matchedind = NULL
FROM dba.CCHeader tCCH
WHERE tCCH.recordkey = @pi_RecordKey
AND tCCH.IataNum <> 'BCHRGUK'

UPDATE tID
SET tID.CRMatchedInd = NULL --updated to set CRMatchedInd. IP
    ,tID.CRMatchedRecordKey = NULL
    ,tID.CRMatchedIataNum = NULL
FROM dba.InvoiceDetail tID
WHERE tID.CRMatchedRecordKey = @pi_RecordKey
AND tID.IataNum <> 'BCHRGUK'

DELETE tIDCCM
FROM dba.InvoiceDetailCCMatch tIDCCM
WHERE tIDCCM.CCMatchedRecordKey = @pi_RecordKey
AND tIDCCM.IataNum <> 'BCHRGUK'


END
GO
