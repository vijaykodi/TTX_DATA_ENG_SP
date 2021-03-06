/****** Object:  StoredProcedure [dbo].[sp_CBSSAESS]    Script Date: 7/14/2015 7:51:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_CBSSAESS]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CBSSAESS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

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



 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CBSSAESS]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Added 7/9/2015 sf#6616946 tkt number not coming in expected field so remapping it
SET @TransStart = getdate()
UPDATE EX
SET EX.Remarks14=RemarksEntry_Custom14,
EX.Remarks10=REMARKSENTRY_CUSTOM14
from dba.expensereportdetail EX
where  ExpenseType IN ('Airfare', 'Airline Ticket')
and Remarks14 is NULL
AND RemarksEntry_Custom14 is not null
AND ExpIataNum = 'CBSSAESS'

UPDATE EX
SET EX.Remarks10=REMARKS14
from dba.expensereportdetail EX
where  ExpenseType IN ('Airfare', 'Airline Ticket')
and (Remarks10 is NULL OR Remarks10='')
AND Remarks14 is not null
AND ExpIataNum = 'CBSSAESS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remarks10 and 14 w tkt num',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--UPATE TMC MATCHED RECORDKEY IF SHOWING TMC MATCHED IN CCDATA
SET @TransStart = getdate()
update ex 
set ex.TMCMatchedRecordkey = CCT.MATCHEDRECORDKEY, 
ex.TMCMatchedIataNum = CCT.MATCHEDiatanum, 
ex.TMCMatchedClientCode = CCT.MATCHEDclientcode, 
ex.TMCMatchedSeqNum = CCT.MATCHEDseqNum 
from dba.expensereportdetail ex, dba.CCTICKET CCT 
where 1 = 1 
and EX.CCMATCHEDRECORDKEY=CCT.RECORDKEY 
and ex.TMCMatchedRecordkey is null 
and ex.expensetype IN ('Airfare', 'Airline Ticket')
AND EX.CCMATCHEDRECORDKEY IS NOT NULL
and ex.ExpIataNum = 'CBSSAESS'

update ex 
set ex.remarks10 = CCT.ticketnum, 
ex.remarks14 = CCT.ticketnum
from dba.expensereportdetail ex, dba.CCTICKET CCT 
where 1 = 1 
and EX.CCMATCHEDRECORDKEY=CCT.RECORDKEY 
and (ex.Remarks10 is null or ex.Remarks10='') 
and ex.expensetype IN ('Airfare', 'Airline Ticket')
AND EX.CCMATCHEDRECORDKEY IS NOT NULL
and ex.ExpIataNum = 'CBSSAESS'

--Added on 2/28/14 by Nina per Case #000
SET @TransStart = getdate()
update ex 
set ex.TMCMatchedRecordkey = id.recordkey, 
ex.TMCMatchedIataNum = id.iatanum, 
ex.TMCMatchedClientCode = id.clientcode, 
ex.TMCMatchedSeqNum = id.seqNum 
from dba.expensereportdetail ex, dba.invoicedetail id 
where 1 = 1 
and ((substring(ex.remarks14,4,10) = id.documentnumber) 
	or(ex.remarks14 = id.documentnumber)) 
and ex.TMCMatchedRecordkey is null 
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.ExpIataNum = 'CBSSAESS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--UPDATE FOR HOTEL MATCHES BASED ON CCHOTEL

update exD
set exD.tmcmatchedrecordkey = cch.matchedrecordkey,
exD.TMCMatchedIataNum = cch.matchedIataNum,
exD.TMCMatchedClientCode = cch.matchedClientCode,
exD.TMCMatchedSeqNum = cch.matchedSeqNum,
exD.CCmatchedrecordkey = cch.recordkey,
exD.CCMatchedIataNum = cch.IataNum,
exD.CCMatchedClientCode = cch.ClientCode
--SELECT EXD.TRANSACTIONDATE,CCH.TRANSACTIONDATE,CCH.ARRIVALDATE,EXD.AMOUNT,CCH.TOTALAUTHAMT,EXD.CHARGEDescription,CCH.DESCOFCHARGE
from 
 dba.expensereportheader exh,
dba.cchotel cch,
dba.ExpenseReportDetail exd
where 1=1
and exD.expreportid = exh.expreportid
and exd.ExpenseType in ('Room Tax','Room Rate','Hotel (Inc','Hotel (Including taxes)', 'Hotel')
--and  cch.arrivaldate BETWEEN EXH.PERIODBEGINDATE AND EXH.PERIODENDDATE
and exh.employeeid = cch.employeeid 
and exd.Amount=cch.totalauthamt
and exD.tmcmatchedrecordkey is null
and cch.MatchedRecordKey is not null
and exh.expiatanum in( 'CBSSAESS')
AND CCH.ARRIVALDate=EXD.TRANSACTIONDATE
AND EXD.ChargeDescription=SUBSTRING(CCH.DESCOFCHARGE,1,30)

--HOTEL MATCHES BASED ON dba.HOTEL
update exd
set exd.tmcmatchedrecordkey = h.recordkey,
exd.TMCMatchedIataNum = h.IataNum,
exd.TMCMatchedClientCode = h.ClientCode,
exd.TMCMatchedSeqNum = h.SeqNum
from dba.Hotel h, dba.expensereportheader exh,
DBA.EXPENSEREPORTDETAIL EXD,
dba.CCHotel cch
where 1=1
and exD.expreportid = exh.expreportid
and exH.EXPiatanum  in('CBSSAESS')
AND EXD.ExpenseType in ('Room Tax','Room Rate','Hotel (Inc','Hotel (Including taxes)', 'Hotel')
and exh.lastname = h.Lastname 
AND SUBSTRING (EXH.FirstName,1,4) = SUBSTRING(H.FIRSTNAME,1,4)
and exD.tmcmatchedrecordkey is null
AND SUBSTRING (EXD.chargeDESCRIPTION,1,6) =SUBSTRING(H.HTLPROPERTYNAME,1,6)
AND ABS(H.TTLHTLCOST)-abs(EXD.APPROVEDAMOUNT) < (.20*ttlhtlcost)
AND ABS(EXD.APPROVEDAMOUNT)-abs(H.TTLHTLCOST) < (.20*EXD.APPROVEDAMOUNT)
and cch.RecordKey=exd.CCMatchedRecordKey
and cch.IataNum=exd.CCMatchedIataNum
and cch.ArrivalDate=h.checkindate


--Added on 2/28/14 by Nina per Case #00031707
SET @TransStart = getdate()
update dba.expensereportheader 
set remarks10 = 'Simon & Schuster' 
where expiatanum = 'CBSSAESS'
and Remarks10 is null
and ImportDate >= getdate()-1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


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
