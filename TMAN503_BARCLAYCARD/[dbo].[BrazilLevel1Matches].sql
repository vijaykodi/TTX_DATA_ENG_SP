/****** Object:  StoredProcedure [dbo].[BrazilLevel1Matches]    Script Date: 7/14/2015 7:49:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[BrazilLevel1Matches] AS 
begin 
BEGIN TRANSACTION

  BEGIN TRY
  --Drop table #level1matches
    CREATE TABLE  #level1Matches (RecordKey  VARCHAR(250)
                                 ,Iatanum   VARCHAR(8)
                                 ,SeqNum    INT
                                 ,ClientCode  VARCHAR(25)                           
                                 ,InvoiceDate DATETIME
                                 ,IssueDate   DATETIME
                                 ,MatchType   VARCHAR(1)                           
                                 ,CCMatchedRecordKey  VARCHAR(250)
                                 ,CCMatchedIataNum    VARCHAR(8)
                                 )


    CREATE CLUSTERED INDEX IX_level1Matches ON #Level1Matches
    (
	    [RecordKey] ASC,
	    [IataNum] ASC,
	    [ClientCode] ASC,
	    [SeqNum] ASC,
	    [InvoiceDate] ASC,
	    [IssueDate] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

    CREATE NONCLUSTERED INDEX IX_level1Matches_1 ON #Level1Matches
    (
	    [CCMatchedRecordKey] ASC,
	    [CCMatchedIataNum] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



    --Retrieve level 1 Matches
    INSERT INTO #Level1Matches
        (RecordKey
       , Iatanum
       , SeqNum
       , ClientCode
       , InvoiceDate
       , IssueDate
       , MatchType
       , CCMatchedRecordKey
       , CCMatchedIataNum
        )

    SELECT id.RecordKey
          ,id.IataNum
          ,id.SeqNum
          ,id.ClientCode
          ,id.InvoiceDate
          ,id.IssueDate
          ,'1'
          ,ch.RecordKey
          ,ch.IataNum

    FROM dba.CCHeader AS ch
    INNER JOIN dba.ProfileBuilds AS pb ON ch.CreditCardNum = pb.CHILDCARD
    INNER JOIN dba.CCTicket AS ct ON ch.RecordKey = ct.RecordKey
    INNER JOIN dba.InvoiceHeader AS ih ON ch.CreditCardNum = ih.CCNum
    INNER JOIN dba.InvoiceDetail AS id ON ih.RecordKey = id.RecordKey
    WHERE NOT EXISTS (SELECT 1 FROM dba.InvoiceDetailCCMatch AS idcm 
                                WHERE idcm.CCMatchedRecordKey = ch.RecordKey
                                AND idcm.CCMatchedIataNum = ch.IataNum)
    AND NOT EXISTS (SELECT 1 FROM dba.InvoiceDetailCCMatch AS idcm2 
                              WHERE idcm2.RecordKey = id.RecordKey
                              AND idcm2.IataNum = id.IataNum
                              AND idcm2.ClientCode = id.ClientCode
                              AND idcm2.SeqNum = id.SeqNum)
    AND ch.MatchedInd IS NULL
    AND ih.InvoiceDate = ch.TransactionDate
    AND ih.TtlInvoiceAmt = ch.LocalCurrAmt
    AND ih.CCApprovalCode = ch.Remarks11
    AND id.ValCarrierCode = ct.ValCarrierCode
    AND pb.ACCOUNTNAME LIKE '%embassy%'

    --Clear out any which could have been 1F:M matches  (dont do select distinct above because you could be matching wrong one)....what does this matter?
    DELETE lm 
    FROM #Level1Matches AS lm
    WHERE EXISTS (
                    SELECT CCMatchedRecordKey, SUM(1) 
                    FROM #Level1Matches AS lm2
                    WHERE lm.CCMatchedRecordKey = lm2.CCMatchedRecordKey
                    GROUP BY CCMatchedRecordKey
                    HAVING SUM(1) > 1
                  )

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

    SELECT RecordKey
       , IataNum
       , SeqNum
       , ClientCode
       , InvoiceDate
       , IssueDate
       , MatchType
       , CCMatchedRecordKey
       , CCMatchedIataNum
       , GETDATE()
    FROM #level1Matches AS lm    
    --Update CCHeader so that Tx won't appear unmatched

    UPDATE ch
    SET    MatchedRecordKey   = lm.RecordKey
          ,MatchedIataNum     = lm.Iatanum
          ,MatchedClientCode  = lm.ClientCode
          ,MatchedSeqNum      = lm.SeqNum
          ,MatchedInd         = lm.MatchType
    FROM #Level1Matches AS lm
    INNER JOIN dba.CCHeader AS ch ON lm.CCMatchedRecordKey = ch.RecordKey
                                 AND lm.CCMatchedIataNum = ch.IataNum

    UPDATE ID
    SET MatchedInd = lm.MatchType
        ,CCMatchedRecordKey = lm.CCMatchedRecordKey
        ,CCMatchedIataNum = lm.CCMatchedIataNum
    FROM dba.InvoiceDetail AS id
    INNER JOIN #Level1Matches AS lm ON id.RecordKey = lm.RecordKey
                                   AND id.IataNum = lm.Iatanum
                                   AND id.SeqNum = lm.SeqNum
                                   AND id.ClientCode = lm.ClientCode

END TRY
BEGIN CATCH
  PRINT '-------------------> '+ ERROR_MESSAGE()
  ROLLBACK
END CATCH  
COMMIT TRANSACTION                             

END 

GO
