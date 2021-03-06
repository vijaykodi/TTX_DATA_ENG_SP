/****** Object:  StoredProcedure [dbo].[sp_CBSEXCGERS]    Script Date: 7/14/2015 7:51:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CBSEXCGERS]
--@BeginIssueDate datetime,
--@EndIssueDate datetime

 AS
 
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,@BeginIssueDate datetime, @ENDIssueDate datetime

SET @Iata = 'CBSEXCGERS'
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @BeginIssueDate = getdate()
SET @ENDIssueDate = getdate()
SET @TransStart = getdate()    


 /************************************************************************
                LOGGING_START - BEGIN
----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CBSEXCGERS]
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

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start -',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update ex
set ex.CCMatchedRecordKey = ch.recordkey, 
ex.CCMatchedIataNum = ch.iatanum, 
ex.CCMatchedClientCode = ch.clientcode, 
ex.TMCMatchedRecordKey = ch.MatchedRecordKey, 
ex.TMCMatchedIataNum = ch.MatchedIataNum, 
ex.TMCMatchedClientCode = ch.MatchedClientCode, 
ex.TMCMatchedSeqNum = ch.MatchedSeqNum
from dba.ExpenseReportDetail ex, dba.ccheader ch
where ex.CreditCardTransReferenceNumber = SUBSTRING(ch.recordkey,3,15)
and ex.ExpenseType in ('airfare', 'airline ticket')
and ex.CCMatchedRecordKey is null 
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by reference number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ex
set ex.CCMatchedRecordKey = CCTKT.recordkey, 
ex.CCMatchedIataNum = CCTKT.iatanum, 
ex.CCMatchedClientCode = CCTKT.clientcode, 
ex.TMCMatchedRecordKey = 'MATCHED', 
ex.TMCMatchedIataNum = 'MATCHED', 
ex.TMCMatchedClientCode = 'MATCHED', 
ex.TMCMatchedSeqNum = '9'
from dba.ExpenseReportDetail ex, dba.CCTicket  CCTKT
where ex.CreditCardTransReferenceNumber = SUBSTRING(CCTKT.recordkey,3,15)
and ex.ExpenseType in ('airfare', 'airline ticket')
and ex.TMCMatchedRecordKey  is null 
AND(( CCTKT.TicketIssuer like '%media%' 
OR CCTKT.TicketIssuer like '%BCD TRAVEL%' 
OR CCTKT.TicketIssuer like '%american express%' 
OR CCTKT.TicketIssuer like '%AE Global Business%'))
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by Issuer',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = id.RecordKey,
ex.tmcmatchedclientcode = id.clientcode,
ex.tmcmatchediatanum = id.iatanum,
ex.tmcmatchedseqnum = id.seqnum
from dba.expensereportdetail ex , dba.InvoiceDetail id
where 1=1
and id.documentnumber  = substring(ex.Remarks10,5,10)
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
and ex.Remarks10 is not null
and ex.TMCMatchedRecordKey is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by document number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = id.RecordKey,
ex.tmcmatchedclientcode = id.clientcode,
ex.tmcmatchediatanum = id.iatanum,
ex.tmcmatchedseqnum = id.seqnum
from dba.expensereportdetail ex , dba.InvoiceDetail id
where 1=1
and id.documentnumber  = ex.Remarks10
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
and ex.Remarks10 is not null
and ex.TMCMatchedRecordKey is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by document number B',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = id.RecordKey,
ex.tmcmatchedclientcode = id.clientcode,
ex.tmcmatchediatanum = id.iatanum,
ex.tmcmatchedseqnum = id.seqnum
from dba.expensereportdetail ex , dba.InvoiceDetail id
where 1=1
and id.documentnumber  = SUBSTRING(ex.Remarks10,2,10)
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
and ex.Remarks10 is not null
and ex.TMCMatchedRecordKey is null 
AND LEN(EX.REMARKS10)>=10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by document number C',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = id.RecordKey,
ex.tmcmatchedclientcode = id.clientcode,
ex.tmcmatchediatanum = id.iatanum,
ex.tmcmatchedseqnum = id.seqnum
--SELECT REMARKS10,SUBSTRING(ex.Remarks10,4,10),DOCUMENTNUMBER, TOTALAMT,APPROVEDAMOUNT,EX.*
from dba.expensereportdetail ex , dba.InvoiceDetail id
where 1=1
and id.documentnumber  = SUBSTRING(ex.Remarks10,4,10)
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
and ex.Remarks10 is not null
and ex.TMCMatchedRecordKey is null 
AND LEN(EX.REMARKS10)>=10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by document number D',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = id.RecordKey,
ex.tmcmatchedclientcode = id.clientcode,
ex.tmcmatchediatanum = id.iatanum,
ex.tmcmatchedseqnum = id.seqnum
from dba.expensereportdetail ex , dba.InvoiceDetail id
where 1=1
and id.GDSRecordLocator = ex.Remarks10
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
and ex.Remarks10 is not null
and ex.TMCMatchedRecordKey is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched fields by GDS Locator',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update ex
set ex.CCMatchedRecordKey = CCTKT.recordkey, 
ex.CCMatchedIataNum = CCTKT.iatanum, 
ex.CCMatchedClientCode = CCTKT.clientcode, 
ex.TMCMatchedRecordKey = CCTKT.MatchedRecordKey, 
ex.TMCMatchedIataNum = CCTKT.MatchedIataNum, 
ex.TMCMatchedClientCode = CCTKT.MatchedClientCode, 
ex.TMCMatchedSeqNum = CCTKT.MatchedSeqNum
--select cctkt.matchedrecordkey,cctkt.ticketamt,ex.amount,cctkt.ticketnum,ex.remarks10,ex.*
from dba.ExpenseReportDetail ex, dba.CCTicket  CCTKT
where substring(ex.remarks10,5,10)= CCTKT.ticketnum
and ex.expensetype IN ('Airfare', 'Airline Ticket')
and ex.TMCMatchedRecordKey  is null 
AND CCTKT.MatchedRecordKey is not null
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
and len(cctkt.ticketnum)>='10'
and Remarks10<>'000000000000000'
and cctkt.ticketamt=ex.amount
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Matched CCTK Match',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SF#6646638  ExpenseHotelDetail update Iatanum as always null and previous matches used this field 7-13-2015
--ADD MATCH TO CCHOTEL MATCHES
update ex
set ex.iatanum=exd.expiatanum
from dba.ExpenseHotelDetail ex,
dba.ExpenseReportdetail exd
where ex.expreportid = exd.expreportid 
and ex.expreportlinenum=exd.expreportlinenum
and exd.ExpenseType='hotel'
and exd.expiatanum not in( 'CBSSAESS','CBSSAEST')
and ex.IataNum is null

--Hotel match to dba.hotel when have expensehoteldetail
SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = h.recordkey,
ex.TMCMatchedIataNum = h.IataNum,
ex.TMCMatchedClientCode = h.ClientCode,
ex.TMCMatchedSeqNum = h.SeqNum
from dba.ExpenseHotelDetail ex, dba.Hotel h, dba.expensereportheader exh
where 1=1
and ex.expreportid = exh.expreportid
and ex.hotelcheckindate = h.checkindate
and ex.hotelcheckoutdate = h.checkoutdate
--and ex.hotelchaincode = h.htlchaincode
and exh.lastname = h.Lastname 
and abs(ex.NumberNights) = abs(h.NumNights)
and ex.tmcmatchedrecordkey is null
and ex.iatanum not in( 'CBSSAESS','CBSSAEST')

--update match to dba.hotel when only have expensereportdetail and no expensehoteldetail
--MATCH USING HOTEL.HTLCHAINNAME
update exd
set exd.tmcmatchedrecordkey = h.recordkey,
exd.TMCMatchedIataNum = h.IataNum,
exd.TMCMatchedClientCode = h.ClientCode,
exd.TMCMatchedSeqNum = h.SeqNum
--SELECT EXD.EXPREPORTID,EXH.LASTNAME,EXH.FIRSTNAME,EXD.APPROVEDAMOUNT,
--EXD.DESCRIPTION,H.RecordKey, H.Lastname, H.FirstName,H.HtlPropertyName,H.HtlChainName,H.TTLHTLCOST
from dba.Hotel h, dba.expensereportheader exh,
DBA.EXPENSEREPORTDETAIL EXD
where 1=1
and exD.expreportid = exh.expreportid
and exH.EXPiatanum not in( 'CBSSAESS','CBSSAEST')
AND EXD.ExpenseType in ('Room Tax','Room Rate','Hotel (Inc','Hotel (Including taxes)', 'Hotel')
and exh.lastname = h.Lastname 
AND SUBSTRING (EXH.FirstName,1,4) = SUBSTRING(H.FIRSTNAME,1,4)
and exD.tmcmatchedrecordkey is null
AND SUBSTRING (EXD.DESCRIPTION,1,5) =SUBSTRING(H.HTLCHAINNAME,1,5)
AND H.CHECKINDATE BETWEEN EXH.PERIODBEGINDATE AND EXH.PERIODENDDATE
AND ABS(H.TTLHTLCOST)-abs(EXD.APPROVEDAMOUNT) < (.20*ttlhtlcost)
AND ABS(EXD.APPROVEDAMOUNT)-abs(H.TTLHTLCOST) < (.20*EXD.APPROVEDAMOUNT)

--MATCH USING TO HOTEL.HTLPROPERTYNAME
update exd
set exd.tmcmatchedrecordkey = h.recordkey,
exd.TMCMatchedIataNum = h.IataNum,
exd.TMCMatchedClientCode = h.ClientCode,
exd.TMCMatchedSeqNum = h.SeqNum
--SELECT EXD.EXPREPORTID,EXH.LASTNAME,EXH.FIRSTNAME,EXD.APPROVEDAMOUNT,
--EXD.DESCRIPTION,H.RecordKey, H.Lastname, H.FirstName,H.HtlPropertyName,H.HtlChainName,H.TTLHTLCOST
from dba.Hotel h, dba.expensereportheader exh,
DBA.EXPENSEREPORTDETAIL EXD
where 1=1
and exD.expreportid = exh.expreportid
and exH.EXPiatanum not in( 'CBSSAESS','CBSSAEST')
AND EXD.ExpenseType in ('Room Tax','Room Rate','Hotel (Inc','Hotel (Including taxes)', 'Hotel')
and exh.lastname = h.Lastname 
AND SUBSTRING (EXH.FirstName,1,4) = SUBSTRING(H.FIRSTNAME,1,4)
and exD.tmcmatchedrecordkey is null
AND SUBSTRING (EXD.DESCRIPTION,1,7) =SUBSTRING(H.HTLPROPERTYNAME,1,7)
AND H.CHECKINDATE BETWEEN EXH.PERIODBEGINDATE AND EXH.PERIODENDDATE
AND ABS(H.TTLHTLCOST)-abs(EXD.APPROVEDAMOUNT) < (.20*ttlhtlcost)
AND ABS(EXD.APPROVEDAMOUNT)-abs(H.TTLHTLCOST) < (.20*EXD.APPROVEDAMOUNT)


--Update to expensehoteldetail based on match in dba.cchotel

SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = cch.matchedrecordkey,
ex.TMCMatchedIataNum = cch.matchedIataNum,
ex.TMCMatchedClientCode = cch.matchedClientCode,
ex.TMCMatchedSeqNum = cch.matchedSeqNum,
ex.CCmatchedrecordkey = cch.recordkey,
ex.CCMatchedIataNum = cch.IataNum,
ex.CCMatchedClientCode = cch.ClientCode
from dba.ExpenseHotelDetail ex, 
 dba.expensereportheader exh,
dba.cchotel cch,
dba.ExpenseReportDetail exd
where 1=1
and ex.expreportid = exh.expreportid
and ex.ExpReportID=exd.expreportid
and ex.expreportlinenum=exd.expreportlinenum
and exd.ExpenseType='hotel'
and ex.hotelcheckindate = cch.arrivaldate
and ex.hotelcheckoutdate = cch.departdate
--and ex.hotelchaincode = h.htlchaincode
and exh.employeeid = cch.employeeid 
and exd.Amount=cch.totalauthamt
and ex.tmcmatchedrecordkey is null
and cch.MatchedRecordKey is not null
and exh.expiatanum not in( 'CBSSAESS','CBSSAEST')

--MATCH BASED ON CCHOTEL WHEN NO EXPENSEHOTELDETAIL
update exD
set exD.tmcmatchedrecordkey = cch.matchedrecordkey,
exD.TMCMatchedIataNum = cch.matchedIataNum,
exD.TMCMatchedClientCode = cch.matchedClientCode,
exD.TMCMatchedSeqNum = cch.matchedSeqNum,
exD.CCmatchedrecordkey = cch.recordkey,
exD.CCMatchedIataNum = cch.IataNum,
exD.CCMatchedClientCode = cch.ClientCode
--SELECT EXD.AMOUNT,CCH.TOTALAUTHAMT,EXD.Description,CCH.DESCOFCHARGE
from 
 dba.expensereportheader exh,
dba.cchotel cch,
dba.ExpenseReportDetail exd
where 1=1
and exD.expreportid = exh.expreportid
and exd.ExpenseType='hotel'
and  cch.arrivaldate BETWEEN EXH.PERIODBEGINDATE AND EXH.PERIODENDDATE
and exh.employeeid = cch.employeeid 
and exd.Amount=cch.totalauthamt
and exD.tmcmatchedrecordkey is null
and cch.MatchedRecordKey is not null
and exh.expiatanum not in( 'CBSSAESS','CBSSAEST')

--Update expense report detail to reflect match from expensehoteldetail 
update ex
set ex.tmcmatchedrecordkey = exd.tmcmatchedrecordkey,
ex.TMCMatchedIataNum = exd.TMCMatchedIataNum,
ex.TMCMatchedClientCode = exd.TMCMatchedClientCode,
ex.TMCMatchedSeqNum = exd.TMCMatchedSeqNum
from dba.ExpenseReportDetail ex, dba.ExpenseHotelDetail exd
where 1=1
and ex.ExpReportID = exd.ExpReportID
and ex.ExpReportLineNum = exd.ExpReportLineNum
and ex.ExpenseType = 'Hotel'
and ex.TMCMatchedRecordKey is null 
and exd.TMCMatchedRecordKey is not null
and ex.expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Hotel Matched',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.ExpenseReportDetail 
set AmountCurrencyCode = 'USD'
where AmountCurrencyCode = '' 
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CURR AND AMTS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.ExpenseReportDetail 
set approvedamount = Amount,
ApprovedAmountCurrencyCode = 'USD'
where ApprovedAmount = 0 
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CURR AND AMTS',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Showtime'
where Remarks10 = 'Showtime Networks'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for Showtime',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Corporate'
where Remarks10 = 'CBS Corporate'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for Corporate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Radio'
where Remarks1 in('R')
and Remarks10 <> 'CBS Radio'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS Radio',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Films'
where Remarks1 in('F')
and Remarks10 <> 'CBS Films'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS Films',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CTD'
where Remarks1 in('X')
and Remarks10 <> 'CTD'
and expiatanum not in( 'CBSSAESS','CBSSAEST') 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CTD',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS TV Stations'
where Remarks1 in('L' ,'M')
and Remarks10 <> 'CBS TV Stations'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS TV Stations',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Paramount TV'
where Remarks1 in('H')
and Remarks10 <> 'Paramount TV'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for Paramount TV',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Network Staff'
where Remarks1 in('B')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for Network Staff',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS News'
where Remarks1 in('C','N')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS News',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Sports'
where Remarks1 in('K','S')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS Sports',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Sports Network'
where Remarks1 in('T','O')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS Sports Network',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Studios'
where Remarks1 in('H')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS Studios',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Entertainment'
where Remarks1 in('E')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for CBS Entertainment',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'COE'
where Remarks1 in('J')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 for COE',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Corporate'
where Remarks1 in('A')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 to Corporate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Interactive'
where Remarks1 in('I')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 to CBS Interactive',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'CBS Outdoor'
where Remarks1 in('G')
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 to CBS Outdoor',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update dba.expensereportheader
set Remarks10 = 'CBS Films'
where Remarks1 = 'A'
and remarks2 = '0300'
and expiatanum not in( 'CBSSAESS','CBSSAEST')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 to CBS films',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Showtime'
where expiatanum in('CBSSAEST')
and Remarks10 is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 to Showtime',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.ExpenseReportHeader 
set Remarks10 = 'Simon &  Schuster'
where expiatanum in('CBSSAESS')
and Remarks10 is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks10 to Showtime',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = h.recordkey,
ex.TMCMatchedIataNum = h.IataNum,
ex.TMCMatchedClientCode = h.ClientCode,
ex.TMCMatchedSeqNum = h.SeqNum
from dba.ExpenseHotelDetail ex, dba.Hotel h, dba.expensereportheader exh
where 1=1
and ex.expreportid = exh.expreportid
and ex.hotelcheckindate = h.checkindate
and ex.hotelcheckoutdate = h.checkoutdate
and exh.lastname = h.Lastname 
and abs(ex.NumberNights) = abs(h.NumNights)
and ex.tmcmatchedrecordkey is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel matched records in Expense',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update ex
set ex.tmcmatchedrecordkey = exd.tmcmatchedrecordkey,
ex.TMCMatchedIataNum = exd.TMCMatchedIataNum,
ex.TMCMatchedClientCode = exd.TMCMatchedClientCode,
ex.TMCMatchedSeqNum = exd.TMCMatchedSeqNum
from dba.ExpenseReportDetail ex, dba.ExpenseHotelDetail exd
where 1=1
and ex.ExpReportID = exd.ExpReportID
and ex.ExpReportLineNum = exd.ExpReportLineNum
and ex.ExpenseType = 'Hotel'
and ex.TMCMatchedRecordKey is null 
and exd.TMCMatchedRecordKey is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel matched records in Expense',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

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
