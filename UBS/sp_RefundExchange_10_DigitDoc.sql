/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 11:49:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Trent Watkins
-- Create date: 5/19/2011
-- Last update: 8/5/2011
-- Description:	Standardized logging and error handling for stored procedures
-- =============================================
CREATE PROCEDURE [dbo].[sp_LogProcErrors] (
	-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
	@ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount int, -- **REQUIRED** Total number of affected rows
	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error int, -- Error Trapping for this procedure
	@LogRowCount int, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message varchar(255), -- The Error Message for this Procedure
	@Error_Type int, -- Used to track where errors are raised inside this procedure
	@Error_Loc int -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [datetime] NOT NULL,
			[LogEnd] [datetime] NOT NULL,
			[RunByUSER] [char](30) NOT NULL,
			[StepName] [varchar](50) NOT NULL,
			[BeginIssueDate] [datetime] NULL,
			[EndIssueDate] [datetime] NULL,
			[IataNum] [varchar](50) NULL,
			[RowCount] [int] NOT NULL,
			[Error] [int] NOT NULL,
			[ErrorMessage] [nvarchar](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql nvarchar(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
	END

INSERT INTO dba.ProcedureLogs (
		ProcedureName
		,LogStart
		,LogEnd
		,RunByUSER
		,StepName
		,BeginIssueDate
		,EndIssueDate
		,IataNum
		,[RowCount]
		,Error
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GetDate()
		,@RunByUSER
		,@StepName
		,@BeginDate
		,@EndDate
		,@IataNum
		,@RowCount
		,@ERR
		,@Error_Message

IF @ERR <> 0
	BEGIN
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END		

GO

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_RefundExchange_10_DigitDoc]    Script Date: 7/13/2015 11:49:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_RefundExchange_10_DigitDoc]
	@BeginIssueDate     datetime,
	@EndIssueDate		datetime


AS

SET NOCOUNT ON

DECLARE  @ProcName varchar(50), @TransStart datetime


	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @TransStart = getdate()
	
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------------------************Back Office Data***************-----------------------------------------------

 ---------------------------------Refund/Exchange Process ----------------------------------------------------

 ------------------------------------Exchange Process--------------------------------------------------------
 --------------------------------- InvoiceDetail updates -----------------------------------------------------

--------STEP 1 - Update all Exchanged Tickets to have a TktWasExchangedInd of Y
UPDATE ot
SET TktWasExchangedInd = 'Y'  ,TktOrder = 1 ,TicketGroupId = substring(ot.documentnumber,1,10)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N'
AND e1.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
and isnull(ot.TktWasExchangedInd,'X') <> 'Y'
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update  all Exchanged Tickets to have a TktWasExchangedInd of Y',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- Update all Exchange Tickets to have TicketWasExchangedInd of Y  
-------- where the 1st exchanged ticket was exchanged for the 3rd ticket.
UPDATE ot
SET TktWasExchangedInd = 'Y'
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'Y' AND e1.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND ot.TktWasExchangedInd IS NULL
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum
and isnull(ot.TktWasExchangedInd,'X') <> 'Y'
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Exchange Tickets where the 1st exchanged ticket was exchanged for the 3rd ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 2 - Update all first level Exchange Tickets 
UPDATE e1
SET e1.TktOrder = 22
   ,e1.OrigTktAmt = ISNULL(ot.TotalAmt,0)
   ,e1.OrigBaseFare = ISNULL(ot.InvoiceAmt,0)
   ,e1.TicketGroupId = substring(ot.documentnumber,1,10)
   ,e1.OrigFareCompare1 = ISNULL(ot.FareCompare1,0)
   ,e1.OrigFareCompare2 = ISNULL(ot.FareCompare2,0)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all first level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 3 - Update all Second level Exchange Tickets 
UPDATE e2
SET e2.TktOrder = 23
   ,e2.OrigTktAmt = ISNULL(e1.TotalAmt,0) + e1.OrigTktAmt
   ,e2.OrigBaseFare = ISNULL(e1.InvoiceAmt,0) + e1.InvoiceAmt
   ,e2.TicketGroupId = substring(ot.documentnumber,1,10)
   ,e2.OrigFareCompare1 = ISNULL(e1.origFareCompare1,0) + ISNULL(e1.FareCompare1,0)
   ,e2.OrigFareCompare2 = ISNULL(e1.origFareCompare2,0) + ISNULL(e1.FareCompare2,0)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N'
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Second level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 4 - Update all Third level Exchange Tickets 
UPDATE e3
SET e3.TktOrder = 24
   ,e3.OrigTktAmt = ISNULL(e2.TotalAmt,0) + e2.OrigTktAmt
   ,e3.OrigBaseFare = ISNULL(e2.InvoiceAmt,0) + e2.InvoiceAmt
   ,e3.OrigFareCompare1 = ISNULL(e2.origFareCompare1,0) + ISNULL(e2.FareCompare1,0)
   ,e3.OrigFareCompare2 = ISNULL(e2.origFareCompare2,0) + ISNULL(e2.FareCompare2,0)
   ,e3.TicketGroupId = substring(ot.documentnumber,1,10)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') 
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N'
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Third level Exchange Tickets ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 5 - Update all Fourth level Exchange Tickets 
UPDATE e4
SET e4.TktOrder = 25
   ,e4.OrigTktAmt = ISNULL(e3.TotalAmt,0) + e3.OrigTktAmt
   ,e4.OrigBaseFare = ISNULL(e3.InvoiceAmt,0) + e3.InvoiceAmt
   ,e4.OrigFareCompare1 = ISNULL(e3.origFareCompare1,0) + ISNULL(e3.FareCompare1,0)
   ,e4.OrigFareCompare2 = ISNULL(e3.origFareCompare2,0) + ISNULL(e3.FareCompare2,0)
   ,e4.TicketGroupId = substring(ot.documentnumber,1,10)  
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and substring(e3.documentnumber,1,10) = e4.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y' AND e4.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP')
AND e3.VendorType IN ('BSP','NONBSP') AND e4.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum AND substring(e4.documentnumber,1,10) <> e4.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Fourth level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 6 - Update all Fifth level Exchange Tickets 
UPDATE e5
SET e5.TktOrder = 26
   ,e5.OrigTktAmt = ISNULL(e4.TotalAmt,0) + e4.OrigTktAmt
   ,e5.OrigBaseFare = ISNULL(e4.InvoiceAmt,0) + e4.InvoiceAmt
   ,e5.OrigFareCompare1 = ISNULL(e4.origFareCompare1,0) + ISNULL(e4.FareCompare1,0)
   ,e5.OrigFareCompare2 = ISNULL(e4.origFareCompare2,0) + ISNULL(e4.FareCompare2,0)
   ,e5.TicketGroupId = substring(ot.documentnumber,1,10) 
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and substring(e3.documentnumber,1,10) = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and substring(e4.documentnumber,1,10) = e5.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND ot.VendorType IN ('BSP','NONBSP')
AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' 
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum 
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum AND substring(e4.documentnumber,1,10) <> e4.OrigExchTktNum
AND substring(e5.documentnumber,1,10) <> e5.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Fifth level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 7 - Update all 6th level Exchange Tickets 
UPDATE e6
SET e6.TktOrder = 27
   ,e6.OrigTktAmt = ISNULL(e5.TotalAmt,0) + e5.OrigTktAmt
   ,e6.OrigBaseFare = ISNULL(e5.InvoiceAmt,0) + e5.InvoiceAmt
   ,e6.OrigFareCompare1 = ISNULL(e5.origFareCompare1,0) + ISNULL(e5.FareCompare1,0)
   ,e6.OrigFareCompare2 = ISNULL(e5.origFareCompare2,0) + ISNULL(e5.FareCompare2,0)
   ,e6.TicketGroupId = substring(ot.documentnumber,1,10)  
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and substring(e3.documentnumber,1,10) = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and substring(e4.documentnumber,1,10) = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and substring(e5.documentnumber,1,10) = e6.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP')
AND e3.VendorType IN ('BSP','NONBSP') AND e4.VendorType IN ('BSP','NONBSP')
AND e5.VendorType IN ('BSP','NONBSP') AND e6.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' 
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum AND substring(e4.documentnumber,1,10) <> e4.OrigExchTktNum
AND substring(e5.documentnumber,1,10) <> e5.OrigExchTktNum AND substring(e6.documentnumber,1,10) <> e6.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all 6th level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------STEP 7 - Update all 7th level Exchange Tickets 
UPDATE e7
SET e7.TktOrder = 28
   ,e7.OrigTktAmt = ISNULL(e6.TotalAmt,0) + e6.OrigTktAmt
   ,e7.OrigBaseFare = ISNULL(e6.InvoiceAmt,0) + e6.InvoiceAmt
   ,e7.OrigFareCompare1 = ISNULL(e6.origFareCompare1,0) + ISNULL(e6.FareCompare1,0)
   ,e7.OrigFareCompare2 = ISNULL(e6.origFareCompare2,0) + ISNULL(e6.FareCompare2,0)
   ,e7.TicketGroupId = substring(ot.documentnumber,1,10)   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and substring(e3.documentnumber,1,10) = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and substring(e4.documentnumber,1,10) = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and substring(e5.documentnumber,1,10) = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and substring(e6.documentnumber,1,10) = e7.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND e6.VendorType IN ('BSP','NONBSP') AND e7.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' AND e7.VoidInd = 'N' 
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum AND substring(e4.documentnumber,1,10) <> e4.OrigExchTktNum
AND substring(e5.documentnumber,1,10) <> e5.OrigExchTktNum AND substring(e6.documentnumber,1,10) <> e6.OrigExchTktNum
AND substring(e7.documentnumber,1,10) <> e7.OrigExchTktNum 
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs' and e7.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all 7th level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------STEP 8 - Update all Eighth level Exchange Tickets 
UPDATE e8
SET e8.TktOrder = 29
   ,e8.OrigTktAmt = ISNULL(e7.TotalAmt,0) + e7.OrigTktAmt
   ,e8.OrigBaseFare = ISNULL(e7.InvoiceAmt,0) + e7.InvoiceAmt
   ,e8.OrigFareCompare1 = ISNULL(e7.origFareCompare1,0) + ISNULL(e7.FareCompare1,0)
   ,e8.OrigFareCompare2 = ISNULL(e7.origFareCompare2,0) + ISNULL(e7.FareCompare2,0)
   ,e8.TicketGroupId = substring(ot.documentnumber,1,10)   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and substring(e3.documentnumber,1,10) = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and substring(e4.documentnumber,1,10) = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and substring(e5.documentnumber,1,10) = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and substring(e6.documentnumber,1,10) = e7.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e8 ON ( e7.IataNum = e8.Iatanum and substring(e7.documentnumber,1,10) = e8.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y' AND e4.ExchangeInd = 'Y'
AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y' AND e8.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND e6.VendorType IN ('BSP','NONBSP') AND e7.VendorType IN ('BSP','NONBSP')
AND e8.VendorType IN ('BSP','NONBSP') AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N' AND e5.VoidInd = 'N' AND e6.VoidInd = 'N'
AND e7.VoidInd = 'N' AND e8.VoidInd = 'N' 
AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum AND substring(e4.documentnumber,1,10) <> e4.OrigExchTktNum
AND substring(e5.documentnumber,1,10) <> e5.OrigExchTktNum AND substring(e6.documentnumber,1,10) <> e6.OrigExchTktNum
AND substring(e7.documentnumber,1,10) <> e7.OrigExchTktNum AND substring(e8.documentnumber,1,10) <> e8.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs' and e7.iatanum <> 'preubs' and e8.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Eighth level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 9 - Update all Ninth level Exchange Tickets 
UPDATE e9
SET e9.TktOrder = 210
   ,e9.OrigTktAmt = ISNULL(e7.TotalAmt,0) + e7.OrigTktAmt
   ,e9.OrigBaseFare = ISNULL(e7.InvoiceAmt,0) + e7.InvoiceAmt
   ,e9.OrigFareCompare1 = ISNULL(e8.origFareCompare1,0) + ISNULL(e8.FareCompare1,0)
   ,e9.OrigFareCompare2 = ISNULL(e8.origFareCompare2,0) + ISNULL(e8.FareCompare2,0)
   ,e9.TicketGroupId = substring(ot.documentnumber,1,10) 
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(ot.documentnumber,1,10) = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and substring(e1.documentnumber,1,10) = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and substring(e2.documentnumber,1,10) = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and substring(e3.documentnumber,1,10) = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and substring(e4.documentnumber,1,10) = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and substring(e5.documentnumber,1,10) = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and substring(e6.documentnumber,1,10) = e7.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e8 ON ( e7.IataNum = e8.Iatanum and substring(e7.documentnumber,1,10) = e8.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e9 ON ( e8.IataNum = e9.Iatanum and substring(e8.documentnumber,1,10) = e9.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y'
AND e8.ExchangeInd = 'Y' AND e9.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND e6.VendorType IN ('BSP','NONBSP') AND e7.VendorType IN ('BSP','NONBSP')
AND e8.VendorType IN ('BSP','NONBSP') AND e9.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' AND e7.VoidInd = 'N' AND e8.VoidInd = 'N' AND e9.VoidInd = 'N'

AND substring(e1.documentnumber,1,10) <> e1.OrigExchTktNum AND substring(e2.documentnumber,1,10) <> e2.OrigExchTktNum
AND substring(e3.documentnumber,1,10) <> e3.OrigExchTktNum AND substring(e4.documentnumber,1,10) <> e4.OrigExchTktNum
AND substring(e5.documentnumber,1,10) <> e5.OrigExchTktNum AND substring(e6.documentnumber,1,10) <> e6.OrigExchTktNum
AND substring(e7.documentnumber,1,10) <> e7.OrigExchTktNum AND substring(e8.documentnumber,1,10) <> e8.OrigExchTktNum
AND substring(e9.documentnumber,1,10) <> e9.OrigExchTktNum 
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs' and e7.iatanum <> 'preubs' and e8.iatanum <> 'preubs' and e9.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Ninth level Exchange Tickets ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------- TranSeg updates ----------------------------------------------------
-------- Set SegTrueTktCount  to 1 for all
update dba.transeg
set segtruetktcount = 1
where segtruetktcount is null and iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=' Set SegTrueTktCount  to 1 for all',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- Set SegTrueTktCount of original ticket to 0 where everything is the same
update tsorig
set tsorig.segtruetktcount = 0
from dba.transeg tsorig
inner join dba.invoicedetail idorig on ( idorig.iatanum = tsorig.iatanum and idorig.recordkey = tsorig.recordkey 
	and idorig.seqnum = tsorig.seqnum ) 
inner join dba.invoicedetail idexch on ( idorig.iatanum = idexch.iatanum and substring(idorig.documentnumber,1,10) = idexch.origexchtktnum ) 
inner join dba.transeg tsexch on ( idexch.iatanum = tsexch.iatanum and idexch.recordkey = tsexch.recordkey 
	and idexch.seqnum = tsexch.seqnum )
where idorig.exchangeind = 'n' and idexch.exchangeind = 'y'
and tsorig.segmentcarriercode = tsexch.segmentcarriercode and tsorig.origincitycode = tsexch.origincitycode 
and tsorig.segdestcitycode = tsexch.segdestcitycode and tsorig.departuredate = tsexch.departuredate
and tsorig.iatanum <> 'preubs' and idorig.iatanum <> 'preubs' and idexch.iatanum <> 'preubs' and tsexch.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set SegTrueTktCount of original ticket to 0 where everything is the same',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- The above may not be needed .... keeping for now
update tsorig
set tsorig.segtruetktcount = 0
from dba.transeg tsorig
inner join dba.invoicedetail idorig on ( idorig.iatanum = tsorig.iatanum and idorig.recordkey = tsorig.recordkey 
	and idorig.seqnum = tsorig.seqnum ) 
inner join dba.invoicedetail idexch on ( idorig.iatanum = idexch.iatanum and substring(idorig.documentnumber,1,10) = idexch.origexchtktnum ) 
inner join dba.transeg tsexch on ( idexch.iatanum = tsexch.iatanum and idexch.recordkey = tsexch.recordkey 
	and idexch.seqnum = tsexch.seqnum ) where idorig.exchangeind = 'n'
and idexch.exchangeind = 'y' and tsorig.segmentcarriercode = tsexch.segmentcarriercode 
and ((tsorig.origincitycode = tsexch.origincitycode or tsorig.segdestcitycode = tsexch.segdestcitycode)) 
and tsorig.departuredate = tsexch.departuredate
and tsorig.iatanum <> 'preubs' and idorig.iatanum <> 'preubs' and idexch.iatanum <> 'preubs' and tsexch.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set tsorig.segtruetktcount = 0',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Where dates have changed
update tsorig
set tsorig.segtruetktcount = 2
from dba.transeg tsorig
inner join dba.invoicedetail idorig on ( idorig.iatanum = tsorig.iatanum and idorig.recordkey = tsorig.recordkey 
	and idorig.seqnum = tsorig.seqnum ) 
inner join dba.invoicedetail idexch on ( idorig.iatanum = idexch.iatanum and substring(idorig.documentnumber,1,10) = idexch.origexchtktnum ) 
inner join dba.transeg tsexch on ( idexch.iatanum = tsexch.iatanum and idexch.recordkey = tsexch.recordkey 
	and idexch.seqnum = tsexch.seqnum ) where idorig.exchangeind = 'n'
and idexch.exchangeind = 'y' and tsorig.segmentcarriercode = tsexch.segmentcarriercode 
and tsorig.origincitycode = tsexch.origincitycode and tsorig.segdestcitycode = tsexch.segdestcitycode 
and tsorig.departuredate <> tsexch.departuredate and tsorig.segtruetktcount = 1
and tsorig.iatanum <> 'preubs' and idorig.iatanum <> 'preubs' and idexch.iatanum <> 'preubs' and tsexch.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update tsorig.segtruetktcount = 2 Where dates have changed',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 ------------------------------------Refund Process--------------------------------------------------------
 --------------------------------- InvoiceDetail updates -----------------------------------------------------
 --------STEP 1 - Update all Refunded Tickets to have a RefundInd as O
UPDATE ot
SET TktWasRefundedInd = 'F'  ,ot.NetTktAmt = ot.totalamt-(isnull(ot.nettktamt,0) + r1.totalamt)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.InvoiceDetail r1 ON ( ot.IataNum = r1.Iatanum and substring(ot.documentnumber,1,10) = substring(r1.documentnumber,1,10))
WHERE  isnull(ot.refundind,'X') = 'N'
AND r1.refundind = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND r1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND r1.VoidInd = 'N'
and isnull(ot.refundind,'X') <> 'Y' and ot.tktwasrefundedind <> 'F'
and ot.issuedate > getdate() -365 and ot.iatanum <> 'preubs' and r1.iatanum <> 'preubs'
and abs(ot.totalamt) - abs(r1.totalamt) between -10 and 10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Refunded Tickets to have a RefundInd as O',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO

ALTER AUTHORIZATION ON [dbo].[sp_RefundExchange_10_DigitDoc] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 11:49:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](255) NULL,
	[BeginIssueDate] [datetime] NULL,
	[EndIssueDate] [datetime] NULL,
	[IataNum] [varchar](50) NULL,
	[RowCount] [int] NOT NULL,
	[Error] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/13/2015 11:49:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNum] [varchar](15) NULL,
	[TicketingBranch] [varchar](10) NULL,
	[BookingBranch] [varchar](10) NULL,
	[TtlInvoiceAmt] [float] NULL,
	[TtlTaxAmt] [float] NULL,
	[TtlCommissionAmt] [float] NULL,
	[CurrCode] [varchar](30) NULL,
	[OrigCountry] [varchar](5) NULL,
	[SalesAgentID] [varchar](10) NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[GDSCode] [varchar](10) NULL,
	[BackOfficeID] [varchar](20) NULL,
	[IMPORTDT] [datetime] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 11:49:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[InvoiceType] [varchar](10) NULL,
	[InvoiceTypeDescription] [varchar](255) NULL,
	[DocumentNumber] [varchar](15) NULL,
	[EndDocNumber] [varchar](3) NULL,
	[VendorNumber] [varchar](15) NULL,
	[VendorType] [varchar](10) NULL,
	[ValCarrierNum] [smallint] NULL,
	[ValCarrierCode] [varchar](6) NULL,
	[VendorName] [varchar](40) NULL,
	[BookingDate] [datetime] NULL,
	[ServiceDate] [datetime] NULL,
	[ServiceCategory] [varchar](8) NULL,
	[InternationalInd] [varchar](1) NULL,
	[ServiceFee] [float] NULL,
	[InvoiceAmt] [float] NULL,
	[TaxAmt] [float] NULL,
	[TotalAmt] [float] NULL,
	[CommissionAmt] [float] NULL,
	[CancelPenaltyAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[FareCompare1] [float] NULL,
	[ReasonCode1] [varchar](6) NULL,
	[FareCompare2] [float] NULL,
	[ReasonCode2] [varchar](6) NULL,
	[FareCompare3] [float] NULL,
	[ReasonCode3] [varchar](6) NULL,
	[FareCompare4] [float] NULL,
	[ReasonCode4] [varchar](6) NULL,
	[Mileage] [float] NULL,
	[Routing] [varchar](120) NULL,
	[DaysAdvPurch] [smallint] NULL,
	[AdvPurchGroup] [varchar](10) NULL,
	[TrueTktCount] [int] NULL,
	[TripLength] [float] NULL,
	[ExchangeInd] [varchar](1) NULL,
	[OrigExchTktNum] [varchar](15) NULL,
	[Department] [varchar](40) NULL,
	[ETktInd] [varchar](1) NULL,
	[ProductType] [varchar](20) NULL,
	[TourCode] [varchar](15) NULL,
	[EndorsementRemarks] [varchar](60) NULL,
	[FareCalcLine] [varchar](255) NULL,
	[GroupMult] [smallint] NULL,
	[OneWayInd] [varchar](1) NULL,
	[PrefTktInd] [varchar](1) NULL,
	[HotelNights] [float] NULL,
	[CarDays] [float] NULL,
	[OnlineBookingSystem] [varchar](20) NULL,
	[AccommodationType] [varchar](10) NULL,
	[AccommodationDescription] [varchar](255) NULL,
	[ServiceType] [varchar](10) NULL,
	[ServiceDescription] [varchar](255) NULL,
	[ShipHotelName] [varchar](255) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[IntlSalesInd] [varchar](4) NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[RefundInd] [varchar](1) NULL,
	[OriginalInvoiceNum] [varchar](15) NULL,
	[BranchIataNum] [varchar](8) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[TicketingAgentID] [varchar](10) NULL,
	[OriginCode] [varchar](10) NULL,
	[DestinationCode] [varchar](10) NULL,
	[TktCO2Emissions] [float] NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [DBA].[InvoiceDetail] ADD [CCMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CCMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CarrierString] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ClassString] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [LastImportDt] [datetime] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [GolUpdateDt] [datetime] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigTktAmt] [float] NULL
SET ANSI_PADDING ON
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktWasExchangedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TicketGroupId] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OriginalDocumentNumber] [varchar](15) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigBaseFare] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktOrder] [int] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigFareCompare1] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigFareCompare2] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktWasRefundedInd] [char](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [NetTktAmt] [float] NULL

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[TranSeg]    Script Date: 7/13/2015 11:50:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[SegmentNum] [smallint] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[OriginCityCode] [varchar](10) NULL,
	[SegmentCarrierCode] [varchar](3) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[CodeShareCarrierCode] [varchar](3) NULL,
	[EquipmentCode] [varchar](10) NULL,
	[PrefAirInd] [varchar](1) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[FlightNum] [varchar](15) NULL,
	[ClassOfService] [varchar](8) NULL,
	[FareBasis] [varchar](30) NULL,
	[TktDesignator] [varchar](15) NULL,
	[ConnectionInd] [varchar](1) NULL,
	[StopOverTime] [smallint] NULL,
	[FrequentFlyerNum] [varchar](15) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SEGDestCityCode] [varchar](10) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [smallint] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [smallint] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [smallint] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [smallint] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [smallint] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [smallint] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](20) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](20) NULL,
	[SEGCO2Emissions] [float] NULL,
	[NOXCO2Emissions] [float] NULL,
	[MINCO2Emissions] [float] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[TtlSeats] [int] NULL,
	[SegTrueTktCount] [int] NULL,
	[YieldInd] [varchar](1) NULL,
	[YieldAmt] [float] NULL,
	[YieldDatePosted] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[TranSeg] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/13/2015 11:50:26 AM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[InvoiceDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 11:50:27 AM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/13/2015 11:50:28 AM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [DBA].[TranSeg]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/13/2015 11:50:28 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [DBA].[InvoiceHeader]
(
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/13/2015 11:50:29 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[BackOfficeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/13/2015 11:50:30 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI4] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/13/2015 11:50:30 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/13/2015 11:50:30 AM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 11:50:31 AM ******/
CREATE NONCLUSTERED INDEX [ACMTrueTkt] ON [DBA].[InvoiceDetail]
(
	[TrueTktCount] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 11:50:31 AM ******/
CREATE NONCLUSTERED INDEX [IDExchProc_I1] ON [DBA].[InvoiceDetail]
(
	[VoidInd] ASC,
	[ExchangeInd] ASC,
	[VendorType] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[IssueDate],
	[DocumentNumber],
	[TicketGroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 11:50:32 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 11:50:32 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 11:50:32 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[VoidInd] ASC,
	[VendorType] ASC,
	[ExchangeInd] ASC,
	[RefundInd] ASC
)
INCLUDE ( 	[RecordKey],
	[SeqNum],
	[ClientCode],
	[InvoiceDate],
	[IssueDate],
	[FirstName],
	[Lastname],
	[DocumentNumber],
	[BookingDate],
	[ServiceDate],
	[TotalAmt],
	[CurrCode],
	[ReasonCode1],
	[FareCompare2],
	[Routing],
	[DaysAdvPurch],
	[TripLength],
	[OnlineBookingSystem],
	[Remarks1],
	[Remarks2],
	[GDSRecordLocator]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 11:50:37 AM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 11:50:37 AM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 11:50:37 AM ******/
CREATE NONCLUSTERED INDEX [RefundMatchCoverIndex01] ON [DBA].[InvoiceDetail]
(
	[DocumentNumber] ASC,
	[VendorType] ASC,
	[RefundInd] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/13/2015 11:50:38 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [DBA].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 11:50:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [DBA].[TR_INVOICEDETAIL_I]
    ON [DBA].[InvoiceDetail]
 AFTER INSERT
    AS
BEGIN
        SET NOCOUNT ON;
        UPDATE i
                SET i.TicketGroupId = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.TicketGroupId FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (ins.RecordKey)
                        END
                ),
                i.OriginalDocumentNumber = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.OriginalDocumentNumber FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (ins.DocumentNumber)
                        END
                )
        FROM dba.InvoiceDetail i
        JOIN inserted ins
        ON i.RecordKey = ins.RecordKey
        AND i.IataNum = ins.IataNum
        AND i.SeqNum = ins.SeqNum
END


GO

