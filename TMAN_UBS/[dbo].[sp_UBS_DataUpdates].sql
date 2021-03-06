/****** Object:  StoredProcedure [dbo].[sp_UBS_DataUpdates]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_DataUpdates]
	--@BeginIssueDate     datetime,
	--@EndIssueDate		datetime

 AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @EndIssueDate datetime

	SET @Iata = 'UBSUpdate'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @BeginIssueDate = GETDATE()
    SET @ENDIssueDate = GETDATE() 
	SET @TransStart = getdate()

/************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
---///procedure to update monthly data updates from Ryan coming in via rqst UBSUPEMDAT\\

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start UBS Update Data-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
---delete records from table
delete dba.DataUpdates
where recordidentifier+product in (select recordidentifier+product from dba.dataupdatesTemp)

--insert records
INSERT INTO dba.dataupdates
select REQUESTNAME, PRODUCT, RecordIdentifier, Sequence, RecordLocator, HotelName, InvoiceDate, InvoiceNumber, TicketNumber, ReasonCode, TripPurpose, ApproverGPN, ApproverName, BookerGPN, BookerName, TravelerGPN, TractID, LowAirFare, FullAirFare, TicketAirAmount, CurrCode, SegNum, importdt
from dba.dataupdatestemp

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBS Update Data to prod table',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Approver GPN upates
update dba.dataupdates
set ApproverGPN=RTRIM(LTRIM(approvergpn))
where approvergpn is not null
and approvergpn like '[0-9]%'

update dba.dataupdates
set ApproverGPN=SUBSTRING(approvergpn,1,8)
where approvergpn is not null
and approvergpn like '[0-9]%'
and len(approvergpn) > 8

update dba.dataupdates
set approvergpn = right('00000000'+approvergpn,8)
where len(approvergpn) <> 8 and approvergpn is not null
and ApproverGPN  like '[0-9]%'

--Booker GPN updates
update dba.dataupdates
set bookerGPN=RTRIM(LTRIM(bookergpn))
where bookergpn is not null
and bookergpn like '[0-9]%'

update dba.dataupdates
set BookerGPN=SUBSTRING(BookerGPN,1,8)
where BookerGPN is not null
and BookerGPN like '[0-9]%'
and len(BookerGPN) > 8


update dba.dataupdates
set BookerGPN = right('00000000'+BookerGPN,8)
where len(BookerGPN) <> 8 and BookerGPN is not null
and BookerGPN  like '[0-9]%'

--Traveler GPN updates
update dba.dataupdates
set TravelerGPN=RTRIM(LTRIM(TravelerGPN))
where TravelerGPN is not null
and TravelerGPN like '[0-9]%'

update dba.dataupdates
set TravelerGPN=SUBSTRING(TravelerGPN,1,8)
where TravelerGPN is not null
and TravelerGPN like '[0-9]%'
and len(TravelerGPN) > 8

update dba.dataupdates
set TravelerGPN = right('00000000'+TravelerGPN,8)
where len(TravelerGPN) <> 8 and TravelerGPN is not null
and TravelerGPN  like '[0-9]%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='GPN set to 8 digits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--SEQNUM JOIN ADDED 4/7/2014 KP #34704 
--------- Reason code Updates ---------------------------
update i
set i.reasoncode1=d.ReasonCode
from dba.invoicedetail i, dba.DataUpdates d
where product = 'Air' and i.recordkey = d.recordidentifier
and i.gdsrecordlocator = d.recordlocator 
and d.reasoncode IS NOT NULL
--and d.reasoncode not in ( NULL ,'')
AND I.Seqnum=D.Sequence
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcda')
and isnull(i.reasoncode1,'XX') <> d.reasoncode
AND D.ImportDt>= '2014-01-01'


update h
set h.htlreasoncode1 = d.ReasonCode
from dba.hotel h, dba.DataUpdates d
where product = 'Hotel' and h.recordkey = d.recordidentifier
and d.reasoncode IS NOT NULL
--and d.reasoncode not in ( NULL ,'')
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcdh')
and isnull(h.htlreasoncode1,'XX') <> d.reasoncode
AND H.Seqnum=D.Sequence
AND D.ImportDt>= '2014-01-01'


update c
set c.carreasoncode1 = d.ReasonCode
from dba.car c, dba.DataUpdates d
where product = 'Car' and c.recordkey = d.recordidentifier
and d.reasoncode IS NOT NULL
--and d.reasoncode not in ( NULL ,'')
and d.reasoncode in (select lookupvalue from dba.lookupdata where lookuptext <> 'Unknown' and lookupname = 'rcdc')
and isnull(c.carreasoncode1,'XX') <> d.reasoncode
AND C.Seqnum=D.Sequence
AND D.ImportDt>= '2014-01-01'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ReasonCode Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

--------- Update Booker and Approver GPN's and Names ----------------------------------------------------
update c
set  text14= ApproverGPN
from dba.comrmks c, dba.dataupdates d
where c.recordkey = d.recordidentifier
AND ApproverGPN IS NOT NULL
--and approvergpn not in ( NULL ,'') 
and approvergpn <> isnull(text14,'XX')
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'
------ Once GPN is updated -- update name ---------
update c
set text2 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text2 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UPDATE-approver GPNS AND NAME-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------- Update Booker GPN and Name ----------------------------------------------------
update c
set text8=BookerGPN
from dba.comrmks c, dba.dataupdates d
where c.recordkey = d.recordidentifier
and bookergpn is not null
and bookergpn <> isnull(text8,'XX')
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

------ Once BookerGPN is updated -- update name ---------
update c
set text1 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text1 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update Booker GPN and Name-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------- Update Traveler GPN AND NAME  ----------------------------------------------------
UPDATE id
SET id.remarks2=d.TravelerGPN
FROM dba.InvoiceDetail id, dba.DataUpdates d
WHERE id.RecordKey=d.RecordIdentifier
AND d.TravelerGPN is not null
--AND d.TravelerGPN not in ( NULL ,'')
AND d.TravelerGPN <> isnull(id.Remarks2,'XX') 
AND ID.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

UPDATE htl
SET htl.remarks2 = d.TravelerGPN
FROM dba.DataUpdates d, dba.hotel htl
WHERE d.RecordIdentifier = htl.RecordKey
AND d.PRODUCT = 'hotel'
AND d.travelerGPN is not NULL
--AND d.BookerGPN not in ( NULL ,'')
AND d.travelerGPN <> isnull(htl.Remarks2,'XX')
AND HTL.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

UPDATE car
SET car.remarks2 = d.TravelerGPN
FROM dba.DataUpdates d, dba.car car
WHERE d.RecordIdentifier = car.RecordKey
AND d.PRODUCT = 'car'
AND d.TravelerGPN not in ( NULL ,'')
AND d.TravelerGPN <> isnull(car.Remarks2,'XX')
AND CAR.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'


------ Once Traveler GPN is updated -- update name ---------
update c
set text20 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text20 <> substring(r.description,charindex('-',r.description)+1,240)
and c.RecordKey in (select recordidentifier from dba.DataUpdates)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UPDATE-TRAVELER GPNS AND NAME-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

------ update TractID ---------
UPDATE c
SET c.text17 = d.tractid
FROM dba.ComRmks c, dba.DataUpdates d
WHERE d.RecordIdentifier = c.RecordKey
AND d.TractID not in ( NULL ,'')
AND d.TractID <> isnull(c.Text17,'XX')
AND C.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update TractID-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


------ update Trip Purpose ---------
UPDATE id
SET id.remarks1 = d.TripPurpose
FROM dba.invoicedetail id, dba.DataUpdates d
WHERE d.RecordIdentifier = id.RecordKey
--AND D.TripPurpose IS NOT NULL
AND d.trippurpose not in ( NULL ,'')
AND d.trippurpose <> isnull(id.remarks1,'XX')
AND id.SeqNum=D.Sequence
AND D.ImportDt>= '2014-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Update TripPurpose-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
------ update lowAirFare and Full Air Fare ---------
--UPDATE id
--SET id.farecompare2 = ISNULL(D.lowfare,0)*CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase
--FROM dba.invoicedetail id, 
--dba.DataUpdates d
--INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate AND CURRBASE.BaseCurrCode = d.currcode 
--INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
--WHERE d.RecordIdentifier = id.RecordKey
--and product = 'Air'
--and CURRTO.CurrCode ='USD'
--AND d.lowairfare not in ( NULL ,'')
--AND d.lowairfare <> id.farecompare2
--AND id.SeqNum=D.Sequence
--and d.importdt>='2014-01-01



--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='Update LowFare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--UPDATE id
--SET id.farecompare1 = d.fullairfare *(need currency conversion)
--FROM dba.invoicedetail id, dba.DataUpdates d
--INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = ID.CurrCode AND CURRBASE.CurrBeginDate = ID.IssueDate AND CURRBASE.BaseCurrCode = d.currcode 
--INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
--WHERE d.RecordIdentifier = id.RecordKey
--and product = 'Air'
--and CURRTO.CurrCode ='USD'
--AND d.fullairfare not in ( NULL ,'')
--AND d.fullairfare <> id.farecompare1
--AND id.SeqNum=D.Sequence
--AND D.ImportDt>= '2014-01-01'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
--@StepName='Update FullFare',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------- Set remarks2 to GPN FOR CWT 
--update i
--set i.remarks2 = substring(ud.udefdata,1,8)
--from dba.invoicedetail i, dba.udef ud
--where i.iatanum = 'UBSCWT' and ud.udefnum = 3
--and substring(ud.udefdata,1,8) in (select corporatestructure 
--	from dba.rollup40 where costructid = 'functional')
--and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum
--and isnull(i.remarks2,'unknown') = ('unknown')

--update i
--set remarks2 = right('00000000'+Remarks2,8)
--from dba.invoicedetail i
--where len(remarks2) <> 8 and iatanum = 'UBSCWT' and remarks2 <>'Unknown'

------- Update Text30 with any values in the remarks2 field that are not in the GPN list
--update c 
--set text30 = remarks2
--from  dba.comrmks c, dba.invoicedetail i
--where i.remarks2 not in (select gpn from dba.Employee)
--and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
--and remarks2 not in ('Unknown','999999NE','99999ANE') and c.IATANUM = 'UBSCWT'

--------- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
--update i
--set remarks2 = 'Unknown'
--select remarks2
--from dba.invoicedetail i
--where remarks2 not in (select corporatestructure from dba.rollup40) and IATANUM = 'UBSCWT'
--and recordkey in (select recordidentifier from dba.dataupdates)

---------Update Remarks2 with Unknown code when remarks2 is NULL
--update i
--set remarks2 = 'Unknown'
--from dba.invoicedetail i
--where remarks2 is null and IATANUM = 'UBSCWT'



-------CAR -- Update remarks from invoicedetail remarks
--update car
--set  car.remarks2 = i.remarks2

--from dba.invoicedetail i, dba.car car
--where i.recordkey = car.recordkey and i.seqnum = car.seqnum and i.iatanum = car.iatanum
--and i.iatanum = 'UBSCWT' and car.remarks2<>I.Remarks2 
--SET @TransStart = getdate()


-------HOTEL -- Update remarks from invoicedetail remarks
--update h
--set h.remarks2 = i.remarks2, 
--from dba.invoicedetail i, dba.hotel h
--where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum
--and i.iatanum = 'UBSCWT' and h.remarks1 is null

--SET @TransStart = getdate()

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
