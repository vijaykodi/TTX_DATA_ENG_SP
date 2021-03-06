/****** Object:  StoredProcedure [dbo].[sp_ReverseMultiMatch_4to1]    Script Date: 7/14/2015 7:49:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_ReverseMultiMatch_4to1]
	@pi_CCHRecordKey1 varchar(100),
	@pi_CCHRecordKey2 varchar(100),
	@pi_CCHRecordKey3 varchar(100),
	@pi_CCHRecordKey4 varchar(100),
	@pi_IDRecordKey varchar(100)
	
AS

SET NOCOUNT ON
BEGIN

DECLARE @MatchCreateDate DATETIME
SET @MatchCreateDate = GETDATE()

DECLARE @cchIataNum varchar(10)
SELECT @cchIataNum =  IataNum
	                    FROM dba.CCHeader	WITH (NOLOCK)
	                    WHERE RecordKey = @pi_CCHRecordKey1 

INSERT INTO dba.InvoiceDetailCCMatch 
    (RecordKey
   , IataNum
   , SeqNum
   , ClientCode
   , InvoiceDate
   , IssueDate
   , CCMatchedInd
   , CCMatchedRecordKey
   , CCMatchedIataNum
   , MatchCreateDate
    )

SELECT 
      RecordKey
      ,IataNum
      ,SeqNum
      ,ClientCode
      ,InvoiceDate
      ,IssueDate
      ,'I' --We should probably consider calling this something else.  1.  Because it will affect how the TMA report is built.  (try putting in a couple of these and validate TMA afterwards)  and 2.  So that we can track them easily.
      ,@pi_CCHRecordKey1 --CCH RecordKey
      ,@cchIataNum--CCH IatNum
      ,@MatchCreateDate --matchCreateDate
FROM dba.invoicedetail tiD WITH (NOLOCK)
WHERE RecordKey = @pi_IDRecordKey --updated to collect IDCM detail from correct recordkey -IP 12AUG13

--Update CCHeader With Match
Update H
Set MatchedInd = 'I'
From DBA.CCheader H
Where H.RecordKey IN (@pi_CCHRecordKey1, @pi_CCHRecordKey2, @pi_CCHRecordKey3, @pi_CCHRecordKey4)

--Update InvoiceDetail With Match
Update ID
Set MatchedInd = 'I',
CCMatchedRecordKey = @pi_CCHRecordKey1,
CCMatchedIataNum = @cchIataNum
From DBA.InvoiceDetail ID
Where ID.RecordKey = @pi_IDRecordKey

END




GO
