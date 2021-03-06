/****** Object:  StoredProcedure [dba].[TPTVCMCA_Delete]    Script Date: 7/14/2015 8:13:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dba].[TPTVCMCA_Delete]
@BeginIssueDate datetime,
@EndIssueDate datetime
 as
 DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 	@LocalBeginIssueDate datetime, 
	@LocalEndIssueDate datetime
	
 SET @Iata = 'TPTVCMCA'
 SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
 SELECT 
	@LocalBeginIssueDate = @BeginIssueDate,
	@LocalEndIssueDate = @EndIssueDate
 --set @LocalBeginIssueDate = null
 --set @LocalEndIssueDate = null
 
DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.InvoiceHeader ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete IH',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete InvoiceDetail Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.InvoiceDetail
                                    where iatanum = 'TPTVCMCA'
                                     and IssueDate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.Invoicedetail ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ID',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete Transeg Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.Transeg
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='transeg count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.transeg ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete transeg',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete ComRmks Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.ComRmks
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA',system_user)

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='comRmks Count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.comrmks ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete ComRmks',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete Tax Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.Tax
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='tax count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.tax ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete tax',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ._Delete Payment Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.Payment
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Payment Count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.payment ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete Payment',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete Udef Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.Udef
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Udef Count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.udef ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete UDEF',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete Car Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.Car
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Car Count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.car ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete Car',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


INSERT INTO TTXSASQL01.TMAN503_ORBITZ.dbo.edits (EditName, Results, BeginIssueDate, EndIssueDate, RunDate, Iatanum, Runby)
   (SELECT 'TTXPASQL01.TMAN503_ORBITZ_Delete Hotel Count', (select count(*)
                                     from TTXPASQL01.TMAN503_ORBITZ.dba.Hotel
                                    where iatanum = 'TPTVCMCA'
                                     and issuedate between @LocalBeginIssueDate and @LocalEndIssueDate ),  
     @LocalBeginIssueDate, @LocalEndIssueDate,getdate(), 'TPTVCMCA', system_user)
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel count',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


DELETE ih
from TTXPASQL01.TMAN503_ORBITZ.dba.hotel ih
WHERE ih.recordkey in (select Recordkey from TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey)
AND ih.IataNum = 'TPTVCMCA'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete Hotel',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


delete TTXPASQL01.TMAN503_ORBITZ.dba.deleterecordkey

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Delete temp recordkey file',@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
