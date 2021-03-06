/****** Object:  StoredProcedure [dbo].[sp_CIEAXCC]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CIEAXCC]
	
@BeginIssueDate datetime = null,
@EndIssueDate datetime = null

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CIEAXCC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    

 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CIEAXCC]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/ 


--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
Update dba.CCHeader 
set MarketCode = 'MX' 
where iatanum = 'CIEAXCC' and ControlCCNum = '002079417000101' and isnull(marketcode,'X') <>'MX'
and ImportDate between getdate()-5 and getdate()

Update dba.CCHeader 
set MarketCode = 'JP' 
where iatanum = 'CIEAXCC' and ControlCCNum = '0101599010001' and isnull(marketcode,'X') <>'JP'
and ImportDate between getdate()-5 and getdate()

Update dba.CCHeader 
set MarketCode = 'SG' 
where iatanum = 'CIEAXCC' and ControlCCNum = '011110871' and isnull(marketcode,'X') <> 'SG'
and ImportDate between getdate()-5 and getdate()

Update dba.CCHeader 
set MarketCode = 'AR' 
where iatanum = 'CIEAXCC'  and ControlCCNum = '005202697000101' and isnull(marketcode,'X') <> 'AR'
and ImportDate between getdate()-5 and getdate()

Update dba.CCHeader 
set MarketCode = 'HK' 
where iatanum = 'CIEAXCC'   and marketcode = '009'
and ImportDate between getdate()-5 and getdate()

Update dba.CCHeader 
set MarketCode = 'SG' 
where iatanum = 'CIEAXCC'  and marketcode  = '011' and isnull(marketcode,'X') <> 'SG'
and ImportDate between getdate()-5 and getdate()


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC MarketCodes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update SSnum with Employeenum -- Employee Nums with longer than 11 characters have been right
-------- truncated.  These all start with 'WORKS 100' and are not in the hierarchy table--------- LOC/2/19/2013
SET @TransStart = getdate()
update dba.ccheader
set SSnum = right(employeeid,11)
where iatanum ='CIEAXCC' and ssnum is null
and importdate > getdate()-2
and employeeid <> 'UNKNOWN'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC  1-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.CCHeader 
set employeeid = 'Unknown'
where importdate > getdate()-2
and iatanum ='CIEAXCC'

update dba.ccheader
set employeeid = SUBSTRING(ssnum,len(ssnum)-4,7)
where SUBSTRING(ssnum,len(ssnum)-4,7) in (select employee_number from dba.hierarchy)
and EmployeeId = 'unknown'
and importdate > getdate()-2
and iatanum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 2-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ccheader
set employeeid = SUBSTRING(ssnum,len(ssnum)-3,7) 
where SUBSTRING(ssnum,len(ssnum)-3,7)  in (select employee_number from dba.hierarchy)
and EmployeeId = 'unknown'
and importdate > getdate()-2
and iatanum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 3-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ccheader
set employeeid = '0'+ssnum 
where '0'+ssnum  in (select employee_number from dba.hierarchy)
and EmployeeId = 'unknown'
and LEN(ssnum) = 3 and importdate > getdate()-2
and iatanum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 4-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.CCHeader
set employeeid = '0'+employeeid
where len(employeeid) = 4
and importdate > getdate()-2
and iatanum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 5-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.CCHeader
set employeeid = '00'+employeeid
where len(employeeid) = 3
and importdate > getdate()-2
and iatanum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 6-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.CCHeader
set employeeid = '000'+employeeid
where len(employeeid) = 2
and importdate > getdate()-2
and iatanum = 'CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 7-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cccar
set employeeid = cch.employeeid
from dba.CCCar cccar, dba.CCHeader cch
where cccar.RecordKey = cch.RecordKey 
and cccar.IataNum = cch.IataNum
and cch.ImportDate > getdate()-2
and cch.IataNum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 8-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cct
set employeeid = cch.employeeid
from dba.CCticket cct, dba.CCHeader cch
where cct.RecordKey = cch.RecordKey 
and cct.IataNum = cch.IataNum
and cch.importdate > getdate()-2
and cch.IataNum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 9-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cchtl
set employeeid = cch.employeeid
from dba.CChotel cchtl, dba.CCHeader cch
where cchtl.RecordKey = cch.RecordKey 
and cchtl.IataNum = cch.IataNum
and importdate > getdate()-2
and cch.IataNum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 10-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cce
set employeeid = cch.employeeid
from dba.CCexpense cce, dba.CCHeader cch
where cce.RecordKey = cch.RecordKey 
and cce.IataNum = cch.IataNum
and cch.ImportDate > getdate()-2
and cch.IataNum ='CIEAXCC'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 11-Employee ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC 12-Employee ID complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update cct
set cct.matchedrecordkey = id.recordkey, 
cct.matchediatanum = id.iatanum, 
cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where right(documentnumber,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null 
and cct.valcarriercode = id.valcarriercode
and cct.transactiondate between getdate() -60 and getdate()

update id
set id.matchedind = '5'
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where right(documentnumber,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null 
and id.recordkey = cct.matchedrecordkey
and cct.valcarriercode = id.valcarriercode
and cct.transactiondate between getdate() -60 and getdate()

update cch
set cch.matchedrecordkey = id.recordkey, 
cch.matchediatanum = id.iatanum, 
cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where right(documentnumber,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null 
and cct.valcarriercode = id.valcarriercode
and cct.transactiondate between getdate() -60 and getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC Document number match',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Update matched for ticketless carriers where tkt nbr from TMC and CCdata are different #30022
--02/06/14 KP
SET @TransStart = getdate()
update cct
set cct.matchedrecordkey = id.recordkey, 
cct.matchediatanum = id.iatanum, 
cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from  
dba.ccheader cch
inner join dba.ccticket cct on cct.recordkey = cch.recordkey
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCH.BilledCurrCode AND CURRBASE.CurrBeginDate = CCH.TransactionDate AND CURRBASE.CurrCode = CCT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
,dba.invoicedetail id
where 
cch.matchedrecordkey is null 
and id.servicedate=cct.servicedate
and CCH.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
and cct.valcarriercode = id.valcarriercode
and id.Lastname=SUBSTRING(cct.passengername, 1, CASE WHEN CHARINDEX('/', cct.passengername) > 0 THEN CHARINDEX('/', cct.passengername)-1
									ELSE LEN(cct.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cct.routing,1,3)
and cct.transactiondate between getdate() -60 and getdate()

update id
set id.matchedind = '5'
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where 
 cct.recordkey = cch.recordkey 
and id.matchedind is null 
and id.recordkey = cct.matchedrecordkey
and cct.valcarriercode = id.valcarriercode
and id.servicedate=cct.servicedate
and id.Lastname=SUBSTRING(cct.passengername, 1, CASE WHEN CHARINDEX('/', cct.passengername) > 0 THEN CHARINDEX('/', cct.passengername)-1
									ELSE LEN(cct.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cct.routing,1,3)
and cct.transactiondate between getdate() -60 and getdate()


update cch
set cch.matchedrecordkey = id.recordkey, 
cch.matchediatanum = id.iatanum, 
cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
From
dba.ccheader cch
inner join dba.ccticket cct on cct.recordkey = cch.recordkey
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCH.BilledCurrCode AND CURRBASE.CurrBeginDate = CCH.TransactionDate AND CURRBASE.CurrCode = CCT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
,dba.invoicedetail id
where 
cch.matchedrecordkey is null 
and id.servicedate=cct.servicedate
and CCH.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
and cct.valcarriercode = id.valcarriercode
and id.Lastname=SUBSTRING(cct.passengername, 1, CASE WHEN CHARINDEX('/', cct.passengername) > 0 THEN CHARINDEX('/', cct.passengername)-1
									ELSE LEN(cct.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cct.routing,1,3)
and cct.transactiondate between getdate() -60 and getdate()


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC Match No doc num',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEAXCC Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

exec dbo.sp_Ciena_Anc
--@iatanum = 'CIEAXCC'

   /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/      

GO
