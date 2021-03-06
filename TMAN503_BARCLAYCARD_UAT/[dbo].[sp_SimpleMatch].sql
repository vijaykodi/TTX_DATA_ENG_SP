/****** Object:  StoredProcedure [dbo].[sp_SimpleMatch]    Script Date: 7/14/2015 7:49:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SimpleMatch] (@pi_IDRecordKey varchar(100), @pi_IDSeqNum integer, @pi_CCHRecordkey VARCHAR(100), @pi_MatchedInd varchar(1))
AS

begin

--ValidateRecordkeys



DECLARE @IataNum VARCHAR(10)
        ,@SeqNum INTEGER
        ,@ClientCode VARCHAR(25)
        ,@InvoiceDate DATETIME
        ,@IssueDate DATETIME
        
SELECT     @IataNum = IATANUM
        ,@SeqNum = SEQNUM
        ,@ClientCode = CLIENTCODE
        ,@InvoiceDate = INVOICEDATE
        ,@IssueDate = ISSUEDATE
        
FROM dba.invoicedetail WHERE recordkey = @pi_IDRecordkey   AND SeqNum = @pi_IDSeqNum

DECLARE @CCMatchedIataNum VARCHAR(10)

SELECT @CCMatchedIataNum FROM dba.ccheader WHERE recordkey = @pi_CCHRecordKey

INSERT INTO dba.InvoiceDetailCCMatch
        ( RecordKey
        ,IataNum
        ,SeqNum
        ,ClientCode
        ,InvoiceDate
        ,IssueDate
        ,CCMatchedInd
        ,CCMatchedRecordKey
        ,CCMatchedIataNum
        ,MatchCreateDate
        )

SELECT  @pi_IDRecordkey
        ,@IataNum
        ,@SeqNum        
        ,@ClientCode
        ,@InvoiceDate
        ,@IssueDate
        ,@pi_MatchedInd
        ,@pi_CCHRecordkey
        ,@CCMatchedIataNum
        ,GETDATE()
        
UPDATE dba.CCHeader
SET matchedind = 'H' WHERE dba.CCHeader.RecordKey = @pi_CCHRecordkey

UPDATE dba.InvoiceDetail 
SET MatchedInd = 'H' WHERE recordkey = @pi_IDRecordKey AND SeqNum = @SeqNum

END


GO
