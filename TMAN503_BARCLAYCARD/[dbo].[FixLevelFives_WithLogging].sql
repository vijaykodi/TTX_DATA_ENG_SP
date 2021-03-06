/****** Object:  StoredProcedure [dbo].[FixLevelFives_WithLogging]    Script Date: 7/14/2015 7:49:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DC, CM
-- Create date: 11/03/13
-- Description:	Clear Level 5 Matched today

-- Update:		IP-22/05/13
-- Made changes to the stored procedure to
-- clear out incorrect level 5 matches.

-- Update:		IP-13/11/13
-- Added Serco multi-match clearing. #00025291 

-- Update:		IP-24/03/14
-- Added section to clear out incorrect auto
-- matches based on SeqNum

-- Update:		IP-23/04/14
-- Added level 6 auto matching  

-- Update:		IP-12/05/14
-- Added additional match criteria for auth code

-- Update:		IP-12/06/14
-- Added additional matching for FR/EI

-- Update:		IP-14/08/14
-- Added following clause for level6 matching to nullify duplicate matches
--		AND NOT EXISTS (
--			SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
--			WHERE idcm.CCMatchedRecordKey = cch.RecordKey
--			)	
-- =============================================
CREATE PROCEDURE [dbo].[FixLevelFives_WithLogging] AS
BEGIN



SET NOCOUNT ON
SET ANSI_WARNINGS OFF

----------------------------------------------------------------
--Next 2 lines commented out...rcr 07/02/2015
--DECLARE @ProcName varchar(50), @TransStart datetime
--	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
----------------------------------------------------------------

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)


--=================================
--Added by rcr  07/02/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @Iata varchar(50)
, @ProcName varchar(50)
, @TransStart datetime
, @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(50)

SET @Iata = 'LVL6'
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Start'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----
WAITFOR DELAY '00:00.30' 


----------------------------------------------------------------
--Next 3 original lines commented out...rcr 07/02/2015
----Log Activity
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----------------------------------------------------------------

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
	UPDATE tCCH
	SET tcch.matchedind = NULL
	FROM dba.CCHeader AS tcch
	INNER JOIN dba.InvoiceDetail AS id ON tcch.RecordKey = id.CCMatchedRecordKey
	WHERE 
	tcch.CCCycleDate between CAST(CONVERT(char(8), GETDATE(), 112) AS datetime)-31
		AND CAST(CONVERT(char(8), GETDATE(), 112) AS datetime)+31
	AND tcch.MatchedInd IN ('2','5')
	AND tcch.BilledAmt != id.TotalAmt
	AND id.IataNum NOT IN ('BCHRGUK','BCCHAMB')



----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  tcch.matchedind'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
	UPDATE id
	SET id.matchedind = NULL
	   ,id.ccmatchediatanum = NULL
	   ,id.CCMatchedRecordKey = NULL
	FROM dba.InvoiceDetail AS id
	INNER JOIN dba.CCHeader AS tcch ON tcch.RecordKey = id.CCMatchedRecordKey
	WHERE 
	tcch.CCCycleDate between CAST(CONVERT(char(8), GETDATE(), 112) AS datetime)-31
		AND CAST(CONVERT(char(8), GETDATE(), 112) AS datetime)+31
	AND id.MatchedInd IN ('2','5')
	AND tcch.BilledAmt != id.TotalAmt
	AND id.IataNum NOT IN ('BCHRGUK','BCCHAMB')

	DELETE idcm
	FROM dba.InvoiceDetailCCMatch AS idcm
	INNER JOIN dba.CCHeader AS tcch ON tcch.RecordKey = idcm.CCMatchedRecordKey
	INNER JOIN dba.InvoiceDetail AS id ON idcm.RecordKey = id.RecordKey
										AND idcm.SeqNum = id.SeqNum
										AND idcm.CCMatchedRecordKey = id.CCMatchedRecordKey
	WHERE 
	tcch.CCCycleDate between CAST(CONVERT(char(8), GETDATE(), 112) AS datetime)-31
		AND CAST(CONVERT(char(8), GETDATE(), 112) AS datetime)+31
	AND idcm.CCMatchedInd IN ('2','5')
	AND tcch.BilledAmt != id.TotalAmt
	AND id.MatchedInd IS NULL
	AND idcm.IataNum NOT IN ('BCHRGUK','BCCHAMB')

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Clear Incorrect Lvl 5 Matches'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----
--next line commented out by rcr 07/02/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Clear Incorrect Lvl 5 Matches',@BeginDate=NULL,@EndDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




--################ New Block Added to Unmatch Capita Level 5's ######################
--################		     MJ 16 OCT 2014					################

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
select 
RIGHT(tcch.CreditCardNum,4) "CardEnding"
,tidccm.RecordKey
		,tidccm.IataNum
		,tidccm.SeqNum
		,tidccm.CCMatchedRecordKey
		,tIDCCM.CCMatchedIataNum
		,tidccm.CCMatchedInd
		,tcch.ChargeDesc
		,tcch.BilledAmt
		,tcch.LocalCurrAmt
		,tid.invoicedate
		,tID.totalamt
		,tid.DocumentNumber
		,tih.InvoiceNum
		,tih.OrigCountry
into #MatchesToClear
from dba.ccheader tcch
inner join dba.InvoiceDetailCCMatch tIDCCM on tCCH.RecordKey = tIDCCM.CCMatchedRecordKey
inner join dba.invoicedetail tID on tIDCCM.RecordKey = tID.RecordKey
							and tIDCCM.IataNum = tID.Iatanum
							and tIDCCM.SeqNum = tID.SeqNum
INNER JOIN dba.invoiceheader tih ON tid.RecordKey = tih.RecordKey
						AND tid.IataNum = tih.IataNum
where tIDCCM.ccMatchedInd IN ('2','5')
and tcch.CCCycleDate between getdate() - 31 and getdate() + 31
AND tcch.BilledAmt != tID.TotalAmt
AND tcch.LocalCurrAmt != tID.TotalAmt
AND tid.IataNum IN ('BCCAPUK')
AND tcch.CCCycleDate >= '01 Oct 2014'


----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Populate #MatchesToClear'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--

update tID
SET tID.matchedind = NULL
         ,tID.ccmatchediatanum = NULL
         ,tID.CCMatchedRecordKey = NULL
from #MatchesToClear tMTC
inner join dba.invoicedetail tID on tMTC.RecordKey = tID.RecordKey
								and tMTC.IataNum = tID.IataNum
								and tMTC.SeqNum = tID.SeqNum
								

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') tID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
								
update tCCH
set tCCH.MatchedInd = NULL
	,tCCH.MatchedClientCode = NULL
	,tCCH.MatchedIataNum= null
	,tCCH.MatchedRecordKey = null
	,tCCH.MatchedSeqNum = null
--	,remarks15 = null
from #MatchesToClear tMTC
inner join dba.CCHeader tCCH on tMTC.CCMatchedRecordKey = tCCH.RecordKey
								and tMTC.CCMatchedIataNum = tCCH.IataNum

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') tCCH'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--

delete tIDCCM
--SELECT tIDCCM.*
from #MatchesToClear tMTC
INNER JOIN dba.InvoiceDetailCCMatch tIDCCM on tMTC.RecordKey = tIDCCM.RecordKey
										and tMTC.IataNum = tIDCCM.IataNum
										and tMTC.SeqNum = tIDCCM.SeqNum

DELETE FROM #MatchesToClear

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Delete from tIDCCM,#MatchesToClear'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--################  Unmatch Capita Level 5's END	 ######################
--################		     MJ 16 OCT 2014			 ######################

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--

--SET @TransStart = getdate()
--Create level 6 match
INSERT INTO dba.InvoiceDetailCCMatch
SELECT ih.RecordKey [RecordKey], ih.IataNum [IataNum], id.SeqNum [SeqNum], ih.ClientCode [ClientCode], ih.InvoiceDate [InvoiceDate], 
id.IssueDate [IssueDate], '6' [CCMatchedInd], cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
JOIN dba.InvoiceHeader ih ON ih.CCNum = cch.CreditCardNum
JOIN dba.InvoiceDetail id ON id.RecordKey = ih.RecordKey AND id.IataNum = ih.IataNum
LEFT OUTER JOIN dba.CCTicket cct ON cch.RecordKey = cct.RecordKey AND cch.IataNum = cct.IataNum
WHERE cch.CreditCardNum = ih.CCNum
AND cch.MatchedInd IS NULL
AND id.MatchedInd IS NULL
AND cch.BilledAmt = id.TotalAmt
AND (id.DocumentNumber = RIGHT(cch.ChargeDesc,LEN(id.DocumentNumber))
	OR ih.InvoiceNum = RIGHT(cch.ChargeDesc,LEN(ih.InvoiceNum))
	OR ih.InvoiceNum = LEFT(REPLACE(cch.ChargeDesc,'CWL-T        ',''),LEN(ih.InvoiceNum))
	OR ih.InvoiceNum = LEFT(REPLACE(cch.ChargeDesc,'CWT IRELAND 000000',''),LEN(ih.InvoiceNum))	
	OR ih.InvoiceNum = LEFT(REPLACE(cch.ChargeDesc,'ATP UK LTD   I-',''),LEN(ih.InvoiceNum))
	OR id.DocumentNumber = LEFT(REPLACE(cch.ChargeDesc,'AERLING     ',''),LEN(id.DocumentNumber))
	OR id.DocumentNumber = LEFT(REPLACE(cch.ChargeDesc,'RYANAIR     22400000',''),LEN(id.DocumentNumber))
	OR id.DocumentNumber = LEFT(REPLACE(cch.ChargeDesc,'FCM          ',''),LEN(id.DocumentNumber))
	--OR cch.ChargeDesc like ('%' + id.DocumentNumber + '%')
	--OR cch.ChargeDesc like ('%' + ih.InvoiceNum + '%')
	)
AND cch.TransactionDate BETWEEN DATEADD(day,-7,id.IssueDate) AND DATEADD(day,7,id.IssueDate)
AND NOT EXISTS (
	SELECT ih2.InvoiceNum, ih2.TtlInvoiceAmt FROM dba.InvoiceHeader ih2
	WHERE ih.InvoiceNum = ih2.InvoiceNum
	AND ih.TtlInvoiceAmt = ih2.TtlInvoiceAmt
	GROUP BY ih2.InvoiceNum, ih2.TtlInvoiceAmt
	HAVING COUNT(ih2.InvoiceNum+CAST(ih2.TtlInvoiceAmt AS VARCHAR)) > 1
	AND VendorType NOT IN ('NOMATCH','NOBILL')	
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = id.RecordKey
	AND idcm.SeqNum = id.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)
	

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Create level 6 match in IDCM'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----





--next 2 lines commented out -- rcr 07/02/2015		
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 match in IDCM',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
--Create level 6 match by local currency amount
INSERT INTO dba.InvoiceDetailCCMatch
SELECT ih.RecordKey [RecordKey], ih.IataNum [IataNum], id.SeqNum [SeqNum], ih.ClientCode [ClientCode], ih.InvoiceDate [InvoiceDate], 
id.IssueDate [IssueDate], '6' [CCMatchedInd], cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
JOIN dba.InvoiceHeader ih ON ih.CCNum = cch.CreditCardNum
JOIN dba.InvoiceDetail id ON id.RecordKey = ih.RecordKey AND id.IataNum = ih.IataNum
LEFT OUTER JOIN dba.CCTicket cct ON cch.RecordKey = cct.RecordKey AND cch.IataNum = cct.IataNum
WHERE cch.CreditCardNum = ih.CCNum
AND cch.MatchedInd IS NULL
AND id.MatchedInd IS NULL
AND cch.LocalCurrAmt = id.TotalAmt
AND cch.LocalCurrCode = id.CurrCode
AND (id.DocumentNumber = RIGHT(cch.ChargeDesc,LEN(id.DocumentNumber))
	OR ih.InvoiceNum = LEFT(REPLACE(cch.ChargeDesc,'CWL-T        ',''),LEN(ih.InvoiceNum))
	OR ih.InvoiceNum = RIGHT(cch.ChargeDesc,LEN(ih.InvoiceNum))
	--OR cch.ChargeDesc like ('%' + id.DocumentNumber + '%')
	--OR cch.ChargeDesc like ('%' + ih.InvoiceNum + '%')
	)
AND cch.TransactionDate BETWEEN DATEADD(day,-7,id.IssueDate) AND DATEADD(day,7,id.IssueDate)
AND NOT EXISTS (
	SELECT ih2.InvoiceNum, ih2.TtlInvoiceAmt FROM dba.InvoiceHeader ih2
	WHERE ih.InvoiceNum = ih2.InvoiceNum
	AND ih.TtlInvoiceAmt = ih2.TtlInvoiceAmt
	GROUP BY ih2.InvoiceNum, ih2.TtlInvoiceAmt
	HAVING COUNT(ih2.InvoiceNum) > 1
	AND VendorType NOT IN ('NOMATCH','NOBILL')	
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = id.RecordKey
	AND idcm.SeqNum = id.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)
	

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Create level 6 match in IDCM by local currency amount'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----




--Next lines commented out -- rcr 07/02/2015		
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 match in IDCM by local currency amount',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--

--Create level 6 match by CCApprovalCode
INSERT INTO dba.InvoiceDetailCCMatch
SELECT ih.RecordKey [RecordKey], ih.IataNum [IataNum], id.SeqNum [SeqNum], ih.ClientCode [ClientCode], ih.InvoiceDate [InvoiceDate], 
id.IssueDate [IssueDate], '6' [CCMatchedInd], cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
FROM dba.CCHeader cch
JOIN dba.InvoiceHeader ih ON cch.CreditCardNum = ih.CCNum
						AND cch.remarks11 = ih.CCApprovalCode
JOIN dba.InvoiceDetail id ON ih.RecordKey = id.RecordKey 
AND cch.MatchedInd IS NULL
AND id.MatchedInd IS NULL
AND cch.BilledAmt = id.TotalAmt
AND cch.Remarks11 LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9]%'
AND cch.TransactionDate BETWEEN DATEADD(day,-7,id.IssueDate) AND DATEADD(day,7,id.IssueDate)
AND id.VendorType NOT IN ('NOMATCH','NOBILL')
AND NOT EXISTS (
	SELECT ih2.InvoiceNum, ih2.TtlInvoiceAmt FROM dba.InvoiceHeader ih2
	WHERE ih.InvoiceNum = ih2.InvoiceNum
	AND ih.TtlInvoiceAmt = ih2.TtlInvoiceAmt
	GROUP BY ih2.InvoiceNum, ih2.TtlInvoiceAmt
	HAVING COUNT(ih2.InvoiceNum) > 1)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = id.RecordKey
	AND idcm.SeqNum = id.SeqNum
	)	
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)
	
	
----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Create level 6 match in IDCM by CCApprovalCode'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Next line commented out -- rcr 07/02/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 match in IDCM by CCApprovalCode',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--Removing due to incorrect multi matches. MJ 23DEC14

--SET @TransStart = getdate()
----Create level 6 match for Amex Barclays based on ticketnum and passenger name/50% total amount.
--INSERT INTO dba.InvoiceDetailCCMatch
--SELECT ih.RecordKey [RecordKey], ih.IataNum [IataNum], id.SeqNum [SeqNum], ih.ClientCode [ClientCode], ih.InvoiceDate [InvoiceDate], 
--id.IssueDate [IssueDate], '6' [CCMatchedInd], cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--FROM dba.CCHeader cch
--JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
--JOIN dba.InvoiceHeader ih ON ih.CCNum = cch.CreditCardNum
--JOIN dba.InvoiceDetail id ON id.RecordKey = ih.RecordKey AND id.IataNum = ih.IataNum
--JOIN dba.CCTicket cct ON cch.RecordKey = cct.RecordKey AND cch.IataNum = cct.IataNum
--WHERE cch.CreditCardNum = ih.CCNum
--AND cch.MatchedInd IS NULL
--AND id.MatchedInd IS NULL
--AND id.IataNum LIKE 'BCAMX%'
--AND (cch.BilledAmt BETWEEN 0.50*id.TotalAmt AND 1.50*id.TotalAmt
--		OR cct.PassengerName = id.Lastname+'/'+id.FirstName )
--AND (id.DocumentNumber = RIGHT(cch.ChargeDesc,LEN(id.DocumentNumber))
--OR cch.ChargeDesc like ('%' + LEFT(id.DocumentNumber,LEN(id.DocumentNumber)-1) + '%')
--)
--AND cch.TransactionDate BETWEEN DATEADD(day,-7,id.IssueDate) AND DATEADD(day,7,id.IssueDate)
--AND NOT EXISTS (
--	SELECT ih2.InvoiceNum, ih2.TtlInvoiceAmt FROM dba.InvoiceHeader ih2
--	WHERE ih.InvoiceNum = ih2.InvoiceNum
--	AND ih.TtlInvoiceAmt = ih2.TtlInvoiceAmt
--	GROUP BY ih2.InvoiceNum, ih2.TtlInvoiceAmt
--	HAVING COUNT(ih2.InvoiceNum+CAST(ih2.TtlInvoiceAmt AS VARCHAR)) > 1
--	AND VendorType NOT IN ('NOMATCH','NOBILL')	
--	)
--AND NOT EXISTS (
--	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
--	WHERE idcm.RecordKey = id.RecordKey
--	AND idcm.SeqNum = id.SeqNum
--	)
--AND NOT EXISTS (
--	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
--	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
--	)	
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 match for Amex Barclays based on ticketnum and passenger name',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR






--SET @TransStart = getdate()
----Create level 6 match BCFCMUK ID.Servicedescription
--INSERT INTO dba.InvoiceDetailCCMatch
--SELECT ih.RecordKey [RecordKey], ih.IataNum [IataNum], id.SeqNum [SeqNum], ih.ClientCode [ClientCode], ih.InvoiceDate [InvoiceDate], 
--id.IssueDate [IssueDate], '6' [CCMatchedInd], cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
--FROM dba.CCHeader cch
--JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
--JOIN dba.InvoiceHeader ih ON ih.CCNum = cch.CreditCardNum
--JOIN dba.InvoiceDetail id ON id.RecordKey = ih.RecordKey AND id.IataNum = ih.IataNum
--LEFT OUTER JOIN dba.CCTicket cct ON cch.RecordKey = cct.RecordKey AND cch.IataNum = cct.IataNum
--WHERE cch.CreditCardNum = ih.CCNum
--AND cch.MatchedInd IS NULL
--AND id.MatchedInd IS NULL
--AND cch.BilledAmt = id.TotalAmt
--AND id.IataNum = 'BCFCMUK'
--AND (id.ServiceDescription = RIGHT(cch.ChargeDesc,LEN(id.ServiceDescription)))
--AND cch.TransactionDate BETWEEN DATEADD(day,-7,id.IssueDate) AND DATEADD(day,7,id.IssueDate)
--AND NOT EXISTS (
--	SELECT ih2.InvoiceNum, ih2.TtlInvoiceAmt FROM dba.InvoiceHeader ih2
--	WHERE ih.InvoiceNum = ih2.InvoiceNum
--	AND ih.TtlInvoiceAmt = ih2.TtlInvoiceAmt
--	GROUP BY ih2.InvoiceNum, ih2.TtlInvoiceAmt
--	HAVING COUNT(ih2.InvoiceNum+CAST(ih2.TtlInvoiceAmt AS VARCHAR)) > 1
--	AND VendorType NOT IN ('NOMATCH','NOBILL')	
--	)
--AND NOT EXISTS (
--	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
--	WHERE idcm.RecordKey = id.RecordKey
--	AND idcm.SeqNum = id.SeqNum
--	)
--AND NOT EXISTS (
--	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
--	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
--	)	
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 match in IDCM for BCFCMUK Based on Servicedescriptions',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--
--SET @TransStart = getdate()
--Create level 6 match for Promoviatges/Desigual multi-matches and transactions missing EUR4 fees. 25Jun14 IanP
INSERT INTO dba.InvoiceDetailCCMatch
SELECT ih.RecordKey [RecordKey], ih.IataNum [IataNum], id.SeqNum [SeqNum], ih.ClientCode [ClientCode], ih.InvoiceDate [InvoiceDate], 
id.IssueDate [IssueDate], '6' [CCMatchedInd], cch.RecordKey [CCMatchedRecordKey], cch.IataNum [CCMatchedIataNum], GETDATE()	[MatchCreateDate]
FROM dba.CCHeader cch
JOIN dba.ProfileBuilds pb ON cch.CreditCardNum = pb.CHILDCARD
JOIN dba.InvoiceHeader ih ON ih.CCNum = cch.CreditCardNum
JOIN dba.InvoiceDetail id ON id.RecordKey = ih.RecordKey AND id.IataNum = ih.IataNum
LEFT OUTER JOIN dba.CCTicket cct ON cch.RecordKey = cct.RecordKey AND cch.IataNum = cct.IataNum
WHERE cch.CreditCardNum = ih.CCNum
AND cch.MatchedInd IS NULL
AND id.MatchedInd IS NULL
AND cch.BilledAmt BETWEEN ih.TtlInvoiceAmt-4 AND ih.TtlInvoiceAmt+4
AND ih.InvoiceNum = RIGHT(cch.ChargeDesc,LEN(ih.InvoiceNum))
AND cch.TransactionDate BETWEEN DATEADD(day,-7,id.IssueDate) AND DATEADD(day,7,id.IssueDate)
AND ih.IataNum = 'BCPROMDE'
AND NOT EXISTS (
	SELECT ih2.InvoiceNum, ih2.TtlInvoiceAmt FROM dba.InvoiceHeader ih2
	WHERE ih.InvoiceNum = ih2.InvoiceNum
	AND ih.TtlInvoiceAmt = ih2.TtlInvoiceAmt
	GROUP BY ih2.InvoiceNum, ih2.TtlInvoiceAmt
	HAVING COUNT(ih2.InvoiceNum+CAST(ih2.TtlInvoiceAmt AS VARCHAR)) > 1
	AND VendorType NOT IN ('NOMATCH','NOBILL')	
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.RecordKey = id.RecordKey
	AND idcm.SeqNum = id.SeqNum
	)
AND NOT EXISTS (
	SELECT 1 FROM dba.InvoiceDetailCCMatch idcm
	WHERE idcm.CCMatchedRecordKey = cch.RecordKey
	)

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Create level 6 match for Promoviatges/Desigual multi-matches and transactions missing EUR4 fees'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----
		
--Next line commented out -- rcr 07/02/2015		
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Create level 6 match for Promoviatges/Desigual multi-matches and transactions missing EUR4 fees',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--New Step Introduced to Match records on Card, Date, Amount due to no 
--useful information in Charge description. These is the logic used by BLR to 
--manually match, therefore putting into Automation should assist with 
--BLR matching more difficult matching.
EXEC dbo.AutomateGenericMatches


SET @TransStart = getdate()
--Update CCHeader matched indicator
UPDATE cch
SET cch.matchedind = '6'
FROM dba.CCHeader cch, dba.InvoiceDetailCCMatch idcm
WHERE cch.RecordKey = idcm.CCMatchedRecordKey
AND cch.IataNum = idcm.CCMatchedIataNum
AND idcm.CCMatchedInd = '6'
AND cch.MatchedInd IS NULL

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update level 6 matchedind in CCH'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----		
		
--Next line commented out -- rcr 07/02/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update level 6 matchedind in CCH',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update InvoiceDetail for debit matches
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

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update level 6 CC matchedind in ID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----		

--Next line commented out -- rcr 07/02/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update level 6 CC matchedind in ID',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update InvoiceDetail for credit matches
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

----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update level 6 CR matchedind in ID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----	

--Next line commented out -- rcr 07/02/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update level 6 CR matchedind in ID',@BeginDate=NULL,@EndDate=NULL,@IataNum='LVL6',@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Added by rcr  07/02/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--
----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----		
END

GO
