/****** Object:  StoredProcedure [dbo].[AutomateGenericMatches]    Script Date: 7/14/2015 7:49:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AutomateGenericMatches] AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @ProcName varchar(50), @TransStart datetime
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))


--#######################################
--############ START ####################

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--#######################################
--############ UPDATE 1 #################

SET @TransStart = getdate()
INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 1',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--#######################################
--############ UPDATE 2 #################

SET @TransStart = getdate()
INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.ValCarrierCode IS null
AND idsum.ValCarrierCode IS null
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 2',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--#######################################
--############ UPDATE 3 #################

SET @TransStart = getdate()

INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.DocumentNumber = idsum.DocumentNumber
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 3',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--#######################################
--############ UPDATE 4 #################

SET @TransStart = getdate()


INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.DocumentNumber = idsum.DocumentNumber
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.ValCarrierCode IS null
AND idsum.ValCarrierCode IS null
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 4',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--#######################################
--############ UPDATE 5 #################

SET @TransStart = getdate()


INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.DocumentNumber = idsum.DocumentNumber
AND id.ValCarrierCode = idsum.ValCarrierCode
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 5',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--#######################################
--############ UPDATE 6 #################

SET @TransStart = getdate()


INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.ValCarrierCode = idsum.ValCarrierCode
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.RefundInd = 'N'
AND id.RefundInd = 'N'
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 6',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--#######################################
--############ UPDATE 7 #################

SET @TransStart = getdate()


INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc in ('CWT','CWT LB','GRAY DAWES TRAVEL','DB BAHN','PROMOVIATGES','CARLSON WAGONLIT ESPANA','RENFE 001'
	,'CARLSON WAGONLIT TRAVEL','AMERICAN EXPRESS TVL','AMERICAN EXPRESS L10 G45','AMERICAN EXPRESS BUSINESS','AMERICAN EXPRESS  MTO','AMERICAN EXPRESS TVL 20D')
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND (id.ServiceDate = idsum.ServiceDate or id.remarks3 = idsum.remarks3)
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.RefundInd = 'N'
AND id.RefundInd = 'N'
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey 

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 7',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--#######################################
--############ UPDATE 8 #################

SET @TransStart = getdate()

INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc LIKE 'AEV AG.VOYAGES%' or ChargeDesc like 'AEV AG VOYAGES%'
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname, ih.RecordKey) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.DocumentNumber = idsum.DocumentNumber
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt, ih.RecordKey
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = IDRow.InvoiceDate
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 8. AG RAIL',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




--#######################################
--############ UPDATE 9 #################

SET @TransStart = getdate()

INSERT INTO dba.InvoiceDetailCCMatch
SELECT idrow.RecordKey [RecordKey], idrow.IataNum [IataNum], idrow.SeqNum [SeqNum], idrow.ClientCode [ClientCode], idrow.InvoiceDate [InvoiceDate], 
idrow.IssueDate [IssueDate]
, CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd]
, cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--SELECT CASE WHEN CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDROW.TotalAmt AS DECIMAL(10,2)) THEN '6' ELSE 'I' end [CCMatchedInd],cch.CCCycleDate,cch.recordkey, cch.CreditCardNum, cch.chargedesc, cch.billedamt, idrow.*
from
	(
	SELECT CCCycleDate, recordkey, IataNum, chargedesc, CreditCardNum, BilledAmt, TransactionDate, MatchedInd
	, ROW_NUMBER() OVER(PARTITION BY CreditCardNum, BilledAmt, TransactionDate ORDER BY TransactionDate) "Rowval"
	from dba.CCHeader
	where MatchedInd is null
	AND CCCycleDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
	and (
	ChargeDesc LIKE 'AEV AG.VOYAGES%' or ChargeDesc like 'AEV AG VOYAGES%'
	)
	) cch
INNER join
(
SELECT ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.totalamt
,DENSE_RANK() OVER(PARTITION BY SUM(idsum.TotalAmt), id.InvoiceDate, ih.ccnum ORDER BY SUM(idsum.TotalAmt), id.invoicedate, ih.InvoiceNum, id.FirstName, id.Lastname, ih.RecordKey) "Rowval"
, SUM(idsum.TotalAmt) "CombinedTTL"
FROM dba.invoicedetail id, dba.InvoiceHeader ih, dba.invoicedetail idsum
WHERE ih.RecordKey = id.RecordKey
AND id.IataNum = idsum.iatanum
AND id.InvoiceDate = idsum.InvoiceDate
AND id.Lastname = idsum.Lastname
AND id.FirstName = idsum.FirstName
AND id.RefundInd = idsum.RefundInd
AND id.DocumentNumber = idsum.DocumentNumber
AND id.MatchedInd IS NULL
AND idsum.MatchedInd IS NULL
AND id.totalamt IS NOT NULL
AND idsum.totalamt IS NOT null
AND id.IataNum <> 'NOBILL'
AND idsum.IataNum <> 'NOBILL'
AND id.CCMatchedRecordKey IS NULL
AND idsum.CCMatchedRecordKey IS NULL
AND id.InvoiceDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
GROUP BY ih.CCNum, id.clientcode, id.recordkey, id.seqnum, id.IataNum, id.InvoiceDate, id.IssueDate
, ih.InvoiceNum
, id.FirstName, id.Lastname, id.TotalAmt, ih.RecordKey
) IDRow
ON ( cch.CreditCardNum = IDRow.CCNum
AND cch.TransactionDate = DATEADD(day,1,IDRow.InvoiceDate)
AND CAST(cch.BilledAmt AS DECIMAL(10,2)) = CAST(IDRow.CombinedTTL AS DECIMAL(10,2))
AND cch.Rowval = idrow.Rowval
)
WHERE NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = idrow.RecordKey
	AND idcm.SeqNum = idrow.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)		
ORDER BY cch.RecordKey

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 or Multi match in IDCM # 8. AG RAIL',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--#######################################
--######## MATCHED IND UPDATES ##########

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched Indicators',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

UPDATE cch
SET cch.matchedind = '6'
FROM dba.CCHeader cch, dba.InvoiceDetailCCMatch idcm
WHERE cch.RecordKey = idcm.CCMatchedRecordKey
AND cch.IataNum = idcm.CCMatchedIataNum
AND idcm.CCMatchedInd = '6'
AND cch.MatchedInd IS NULL
		
		
UPDATE id
SET id.matchedind = '6',
id.ccmatchedrecordkey = idcm.ccmatchedrecordkey,
id.ccmatchediatanum = idcm.ccmatchediatanum
FROM dba.InvoiceDetail id, dba.InvoiceDetailCCMatch idcm
WHERE id.RecordKey = idcm.RecordKey
AND id.SeqNum = idcm.SeqNum
AND id.IataNum = idcm.IataNum
AND idcm.CCMatchedInd = '6'
AND id.TotalAmt > '0'
AND id.MatchedInd IS NULL
	
	
UPDATE id
SET id.crmatchedind = '6',
id.crmatchedrecordkey = idcm.ccmatchedrecordkey,
id.crmatchediatanum = idcm.ccmatchediatanum,
id.matchedind = '6',
id.ccmatchedrecordkey = idcm.ccmatchedrecordkey,
id.ccmatchediatanum = idcm.ccmatchediatanum
FROM dba.InvoiceDetail id, dba.InvoiceDetailCCMatch idcm
WHERE id.RecordKey = idcm.RecordKey
AND id.SeqNum = idcm.SeqNum
AND id.IataNum = idcm.IataNum
AND idcm.CCMatchedInd = '6'
AND id.TotalAmt < '0'
AND id.MatchedInd IS NULL


UPDATE cch
SET cch.matchedind = 'I'
FROM dba.CCHeader cch, dba.InvoiceDetailCCMatch idcm
WHERE cch.RecordKey = idcm.CCMatchedRecordKey
AND cch.IataNum = idcm.CCMatchedIataNum
AND idcm.CCMatchedInd = 'I'
AND cch.MatchedInd IS NULL
	
	
UPDATE id
SET id.matchedind = 'I',
id.ccmatchedrecordkey = idcm.ccmatchedrecordkey,
id.ccmatchediatanum = idcm.ccmatchediatanum
FROM dba.InvoiceDetail id, dba.InvoiceDetailCCMatch idcm
WHERE id.RecordKey = idcm.RecordKey
AND id.SeqNum = idcm.SeqNum
AND id.IataNum = idcm.IataNum
AND idcm.CCMatchedInd = 'I'
AND id.TotalAmt > '0'
AND id.MatchedInd IS NULL
	
	
UPDATE id
SET id.crmatchedind = 'I',
id.crmatchedrecordkey = idcm.ccmatchedrecordkey,
id.crmatchediatanum = idcm.ccmatchediatanum,
id.matchedind = 'I',
id.ccmatchedrecordkey = idcm.ccmatchedrecordkey,
id.ccmatchediatanum = idcm.ccmatchediatanum
FROM dba.InvoiceDetail id, dba.InvoiceDetailCCMatch idcm
WHERE id.RecordKey = idcm.RecordKey
AND id.SeqNum = idcm.SeqNum
AND id.IataNum = idcm.IataNum
AND idcm.CCMatchedInd = 'I'
AND id.TotalAmt < '0'
AND id.MatchedInd IS NULL

--#######################################
--############ END ######################

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure End',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR


END

GO
