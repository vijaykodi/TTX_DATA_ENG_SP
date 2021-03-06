/****** Object:  StoredProcedure [dbo].[InvoiceDetailCCMatchFix]    Script Date: 7/14/2015 7:49:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ian Patmore
-- Create date: 15-AUG-2013
-- =============================================
CREATE PROCEDURE [dbo].[InvoiceDetailCCMatchFix] AS
BEGIN

	SET NOCOUNT ON

	DECLARE @MatchCreateDate DATETIME
	SET @MatchCreateDate = GETDATE()


-- Insert match details where a match exists in InvoiceDetail but does not appear in IDCM

    INSERT INTO dba.InvoiceDetailCCMatch
	        ( RecordKey ,
	          IataNum ,
	          SeqNum ,
	          ClientCode ,
	          InvoiceDate ,
	          IssueDate ,
	          CCMatchedInd ,
	          CCMatchedRecordKey ,
	          CCMatchedIataNum ,
	          MatchCreateDate
	        )
		SELECT
			 tiD.RecordKey
			,tiD.IataNum
			,tiD.SeqNum
			,tiD.ClientCode
			,tiD.InvoiceDate
			,tiD.IssueDate
			,tiD.MatchedInd
			,tiD.CCMatchedRecordKey
			,tiD.CCMatchedIataNum
			,@MatchCreateDate
		FROM dba.invoicedetail tiD WITH (NOLOCK)
		INNER JOIN dba.CCHeader AS tCCH ON tiD.CCMatchedRecordKey = tCCH.RecordKey
		WHERE 
			tCCH.MatchedInd != 'U'
			AND tCCH.MatchedInd IS NOT NULL
			AND tiD.CCMatchedRecordKey IS NOT NULL
			AND NOT EXISTS (SELECT 1 FROM dba.InvoiceDetailCCMatch AS idcm WHERE idcm.CCMatchedRecordKey = tCCH.RecordKey)


-- Clear remaining matched records from CCHeader where no corresponding match exists in InvoiceDetailCCMatch

	UPDATE tCCH	SET
		tcch.matchedind = NULL
	FROM dba.CCHeader AS tcch
		WHERE tCCH.MatchedInd NOT IN ('U', 'I')
		AND tCCH.MatchedInd IS NOT NULL
		AND NOT EXISTS (SELECT 1 FROM dba.InvoiceDetailCCMatch AS idcm WHERE idcm.CCMatchedRecordKey = tCCH.RecordKey)


-- Re-estabilsh a match in ID where TMC data has been re-imported

	UPDATE dba.InvoiceDetail SET
		MatchedInd = idcm.CCMatchedInd,
		CCMatchedRecordKey = idcm.CCMatchedRecordKey,
		CCMatchedIataNum = idcm.CCMatchedIataNum
	FROM dba.InvoiceDetail id
	INNER JOIN dba.InvoiceDetailCCMatch idcm ON id.RecordKey = idcm.RecordKey
											AND id.SeqNum = idcm.SeqNum
											AND id.CCMatchedRecordKey = idcm.CCMatchedRecordKey
		WHERE ( id.MatchedInd IS NULL
				OR id.MatchedInd <> idcm.CCMatchedInd )
		
-- Re-establish a match in CCH where data has been re-imported

	UPDATE dba.CCHeader SET
		MatchedInd = idcm.CCMatchedInd
	FROM dba.CCHeader cch
	INNER JOIN dba.InvoiceDetailCCMatch idcm ON cch.RecordKey = idcm.CCMatchedRecordKey
		WHERE ( cch.MatchedInd IS NULL
				OR cch.MatchedInd <> idcm.CCMatchedInd )
							        
END

GO
