/****** Object:  StoredProcedure [dbo].[sp_RefundExchange_ExtraTktCode]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_RefundExchange_ExtraTktCode]
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
SET TktWasExchangedInd = 'L'  ,TktOrder = 1 ,TicketGroupId = ot.DocumentNumber
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
inner join dba.comrmks  c on (ot.recordkey = c.recordkey and ot.seqnum = c.seqnum)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(text12,1,10) = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N'
AND e1.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
and isnull(ot.TktWasExchangedInd,'X') <> 'Y' and substring(text12,12,2) = '-O'
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update  all Exchanged Tickets to have a TktWasExchangedInd of Y',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- Update all Exchange Tickets to have TicketWasExchangedInd of Y  
-------- where the 1st exchanged ticket was exchanged for the 3rd ticket.
UPDATE ot
SET TktWasExchangedInd = 'L'
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
inner join dba.comrmks  c on (ot.recordkey = c.recordkey and ot.seqnum = c.seqnum)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(text12,1,10) = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'Y' AND e1.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND ot.TktWasExchangedInd IS NULL
AND e1.DocumentNumber <> e1.OrigExchTktNum
and isnull(ot.TktWasExchangedInd,'X') <> 'Y' and substring(text12,12,2) = '-O'
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Exchange Tickets where the 1st exchanged ticket was exchanged for the 3rd ticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 2 - Update all first level Exchange Tickets 
UPDATE e1
SET e1.TktOrder = 2
   ,e1.OrigTktAmt = ISNULL(ot.TotalAmt,0)
   ,e1.OrigBaseFare = ISNULL(ot.InvoiceAmt,0)
   ,e1.TicketGroupId = ot.DocumentNumber
   ,e1.OrigFareCompare1 = ISNULL(ot.FareCompare1,0)
   ,e1.OrigFareCompare2 = ISNULL(ot.FareCompare2,0)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
inner join dba.comrmks  c on (ot.recordkey = c.recordkey and ot.seqnum = c.seqnum)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and substring(text12,1,10) = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' and substring(text12,12,2) = '-O'
AND e1.DocumentNumber <> e1.OrigExchTktNum
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all first level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 3 - Update all Second level Exchange Tickets 
UPDATE e2
SET e2.TktOrder = 3
   ,e2.OrigTktAmt = ISNULL(e1.TotalAmt,0) + e1.OrigTktAmt
   ,e2.OrigBaseFare = ISNULL(e1.InvoiceAmt,0) + e1.InvoiceAmt
   ,e2.TicketGroupId = ot.DocumentNumber
   ,e2.OrigFareCompare1 = ISNULL(e1.origFareCompare1,0) + ISNULL(e1.FareCompare1,0)
   ,e2.OrigFareCompare2 = ISNULL(e1.origFareCompare2,0) + ISNULL(e1.FareCompare2,0)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N'
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Second level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 4 - Update all Third level Exchange Tickets 
UPDATE e3
SET e3.TktOrder = 4
   ,e3.OrigTktAmt = ISNULL(e2.TotalAmt,0) + e2.OrigTktAmt
   ,e3.OrigBaseFare = ISNULL(e2.InvoiceAmt,0) + e2.InvoiceAmt
   ,e3.OrigFareCompare1 = ISNULL(e2.origFareCompare1,0) + ISNULL(e2.FareCompare1,0)
   ,e3.OrigFareCompare2 = ISNULL(e2.origFareCompare2,0) + ISNULL(e2.FareCompare2,0)
   ,e3.TicketGroupId = ot.DocumentNumber
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') 
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N'
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum
and ot.servicedate > getdate() -365 and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Third level Exchange Tickets ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 5 - Update all Fourth level Exchange Tickets 
UPDATE e4
SET e4.TktOrder = 5
   ,e4.OrigTktAmt = ISNULL(e3.TotalAmt,0) + e3.OrigTktAmt
   ,e4.OrigBaseFare = ISNULL(e3.InvoiceAmt,0) + e3.InvoiceAmt
   ,e4.OrigFareCompare1 = ISNULL(e3.origFareCompare1,0) + ISNULL(e3.FareCompare1,0)
   ,e4.OrigFareCompare2 = ISNULL(e3.origFareCompare2,0) + ISNULL(e3.FareCompare2,0)
   ,e4.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y' AND e4.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP')
AND e3.VendorType IN ('BSP','NONBSP') AND e4.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Fourth level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 6 - Update all Fifth level Exchange Tickets 
UPDATE e5
SET e5.TktOrder = 6
   ,e5.OrigTktAmt = ISNULL(e4.TotalAmt,0) + e4.OrigTktAmt
   ,e5.OrigBaseFare = ISNULL(e4.InvoiceAmt,0) + e4.InvoiceAmt
   ,e5.OrigFareCompare1 = ISNULL(e4.origFareCompare1,0) + ISNULL(e4.FareCompare1,0)
   ,e5.OrigFareCompare2 = ISNULL(e4.origFareCompare2,0) + ISNULL(e4.FareCompare2,0)
   ,e5.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND ot.VendorType IN ('BSP','NONBSP')
AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' 
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum 
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Fifth level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 7 - Update all 6th level Exchange Tickets 
UPDATE e6
SET e6.TktOrder = 7
   ,e6.OrigTktAmt = ISNULL(e5.TotalAmt,0) + e5.OrigTktAmt
   ,e6.OrigBaseFare = ISNULL(e5.InvoiceAmt,0) + e5.InvoiceAmt
   ,e6.OrigFareCompare1 = ISNULL(e5.origFareCompare1,0) + ISNULL(e5.FareCompare1,0)
   ,e6.OrigFareCompare2 = ISNULL(e5.origFareCompare2,0) + ISNULL(e5.FareCompare2,0)
   ,e6.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP') AND e2.VendorType IN ('BSP','NONBSP')
AND e3.VendorType IN ('BSP','NONBSP') AND e4.VendorType IN ('BSP','NONBSP')
AND e5.VendorType IN ('BSP','NONBSP') AND e6.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' 
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all 6th level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------STEP 7 - Update all 7th level Exchange Tickets 
UPDATE e7
SET e7.TktOrder = 8
   ,e7.OrigTktAmt = ISNULL(e6.TotalAmt,0) + e6.OrigTktAmt
   ,e7.OrigBaseFare = ISNULL(e6.InvoiceAmt,0) + e6.InvoiceAmt
   ,e7.OrigFareCompare1 = ISNULL(e6.origFareCompare1,0) + ISNULL(e6.FareCompare1,0)
   ,e7.OrigFareCompare2 = ISNULL(e6.origFareCompare2,0) + ISNULL(e6.FareCompare2,0)
   ,e7.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and e6.documentnumber = e7.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND e6.VendorType IN ('BSP','NONBSP') AND e7.VendorType IN ('BSP','NONBSP')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' AND e7.VoidInd = 'N' 
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
AND e7.DocumentNumber <> e7.OrigExchTktNum 
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs' and e7.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all 7th level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------STEP 8 - Update all Eighth level Exchange Tickets 
UPDATE e8
SET e8.TktOrder = 9
   ,e8.OrigTktAmt = ISNULL(e7.TotalAmt,0) + e7.OrigTktAmt
   ,e8.OrigBaseFare = ISNULL(e7.InvoiceAmt,0) + e7.InvoiceAmt
   ,e8.OrigFareCompare1 = ISNULL(e7.origFareCompare1,0) + ISNULL(e7.FareCompare1,0)
   ,e8.OrigFareCompare2 = ISNULL(e7.origFareCompare2,0) + ISNULL(e7.FareCompare2,0)
   ,e8.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and e6.documentnumber = e7.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e8 ON ( e7.IataNum = e8.Iatanum and e7.documentnumber = e8.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y' AND e4.ExchangeInd = 'Y'
AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y' AND e8.ExchangeInd = 'Y'
AND ot.VendorType IN ('BSP','NONBSP') AND e1.VendorType IN ('BSP','NONBSP')
AND e2.VendorType IN ('BSP','NONBSP') AND e3.VendorType IN ('BSP','NONBSP')
AND e4.VendorType IN ('BSP','NONBSP') AND e5.VendorType IN ('BSP','NONBSP')
AND e6.VendorType IN ('BSP','NONBSP') AND e7.VendorType IN ('BSP','NONBSP')
AND e8.VendorType IN ('BSP','NONBSP') AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N' AND e5.VoidInd = 'N' AND e6.VoidInd = 'N'
AND e7.VoidInd = 'N' AND e8.VoidInd = 'N' 
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
AND e7.DocumentNumber <> e7.OrigExchTktNum AND e8.DocumentNumber <> e8.OrigExchTktNum
and ot.servicedate > getdate() -365
and ot.iatanum <> 'preubs' and e1.iatanum <> 'preubs' and e2.iatanum <> 'preubs' and e3.iatanum <> 'preubs' and e4.iatanum <> 'preubs' 
and e5.iatanum <> 'preubs' and e6.iatanum <> 'preubs' and e7.iatanum <> 'preubs' and e8.iatanum <> 'preubs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Eighth level Exchange Tickets',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------STEP 9 - Update all Ninth level Exchange Tickets 
UPDATE e9
SET e9.TktOrder = 10
   ,e9.OrigTktAmt = ISNULL(e7.TotalAmt,0) + e7.OrigTktAmt
   ,e9.OrigBaseFare = ISNULL(e7.InvoiceAmt,0) + e7.InvoiceAmt
   ,e9.OrigFareCompare1 = ISNULL(e8.origFareCompare1,0) + ISNULL(e8.FareCompare1,0)
   ,e9.OrigFareCompare2 = ISNULL(e8.origFareCompare2,0) + ISNULL(e8.FareCompare2,0)
   ,e9.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and e6.documentnumber = e7.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e8 ON ( e7.IataNum = e8.Iatanum and e7.documentnumber = e8.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e9 ON ( e8.IataNum = e9.Iatanum and e8.documentnumber = e9.OrigExchTktNum)
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

AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
AND e7.DocumentNumber <> e7.OrigExchTktNum AND e8.DocumentNumber <> e8.OrigExchTktNum
AND e9.DocumentNumber <> e9.OrigExchTktNum 
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
inner join dba.invoicedetail idexch on ( idorig.iatanum = idexch.iatanum and idorig.documentnumber = idexch.origexchtktnum ) 
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
inner join dba.invoicedetail idexch on ( idorig.iatanum = idexch.iatanum and idorig.documentnumber = idexch.origexchtktnum ) 
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
inner join dba.invoicedetail idexch on ( idorig.iatanum = idexch.iatanum and idorig.documentnumber = idexch.origexchtktnum ) 
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
INNER JOIN DBA.InvoiceDetail r1 ON ( ot.IataNum = r1.Iatanum and ot.documentnumber = r1.documentnumber)
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
