/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:21:47 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_DataUpdates]    Script Date: 7/13/2015 1:21:48 PM ******/
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

ALTER AUTHORIZATION ON [dbo].[sp_UBS_DataUpdates] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ROLLUP40]    Script Date: 7/13/2015 1:21:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ROLLUP40](
	[COSTRUCTID] [varchar](50) NULL,
	[CORPORATESTRUCTURE] [varchar](50) NULL,
	[DESCRIPTION] [varchar](255) NULL,
	[ROLLUP1] [varchar](50) NULL,
	[ROLLUPDESC1] [varchar](255) NULL,
	[ROLLUP2] [varchar](50) NULL,
	[ROLLUPDESC2] [varchar](255) NULL,
	[ROLLUP3] [varchar](50) NULL,
	[ROLLUPDESC3] [varchar](255) NULL,
	[ROLLUP4] [varchar](50) NULL,
	[ROLLUPDESC4] [varchar](255) NULL,
	[ROLLUP5] [varchar](50) NULL,
	[ROLLUPDESC5] [varchar](255) NULL,
	[ROLLUP6] [varchar](50) NULL,
	[ROLLUPDESC6] [varchar](255) NULL,
	[ROLLUP7] [varchar](50) NULL,
	[ROLLUPDESC7] [varchar](255) NULL,
	[ROLLUP8] [varchar](50) NULL,
	[ROLLUPDESC8] [varchar](255) NULL,
	[ROLLUP9] [varchar](50) NULL,
	[ROLLUPDESC9] [varchar](255) NULL,
	[ROLLUP10] [varchar](50) NULL,
	[ROLLUPDESC10] [varchar](255) NULL,
	[ROLLUP11] [varchar](50) NULL,
	[ROLLUPDESC11] [varchar](255) NULL,
	[ROLLUP12] [varchar](50) NULL,
	[ROLLUPDESC12] [varchar](255) NULL,
	[ROLLUP13] [varchar](50) NULL,
	[ROLLUPDESC13] [varchar](255) NULL,
	[ROLLUP14] [varchar](50) NULL,
	[ROLLUPDESC14] [varchar](255) NULL,
	[ROLLUP15] [varchar](50) NULL,
	[ROLLUPDESC15] [varchar](255) NULL,
	[ROLLUP16] [varchar](50) NULL,
	[ROLLUPDESC16] [varchar](255) NULL,
	[ROLLUP17] [varchar](50) NULL,
	[ROLLUPDESC17] [varchar](255) NULL,
	[ROLLUP18] [varchar](50) NULL,
	[ROLLUPDESC18] [varchar](255) NULL,
	[ROLLUP19] [varchar](50) NULL,
	[ROLLUPDESC19] [varchar](255) NULL,
	[ROLLUP20] [varchar](50) NULL,
	[ROLLUPDESC20] [varchar](255) NULL,
	[ROLLUP21] [varchar](50) NULL,
	[ROLLUPDESC21] [varchar](255) NULL,
	[ROLLUP22] [varchar](50) NULL,
	[ROLLUPDESC22] [varchar](255) NULL,
	[ROLLUP23] [varchar](50) NULL,
	[ROLLUPDESC23] [varchar](255) NULL,
	[ROLLUP24] [varchar](50) NULL,
	[ROLLUPDESC24] [varchar](255) NULL,
	[ROLLUP25] [varchar](50) NULL,
	[ROLLUPDESC25] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ROLLUP40] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:22:00 PM ******/
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

/****** Object:  Table [DBA].[LookupData]    Script Date: 7/13/2015 1:22:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[LookupData](
	[LookupName] [varchar](30) NOT NULL,
	[ParentNode] [int] NOT NULL,
	[LookupValue] [varchar](100) NOT NULL,
	[LookupText] [varchar](255) NULL,
	[LookupNumber] [float] NULL,
	[LookupDate] [datetime] NULL,
	[Node] [int] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[LookupData] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 1:22:04 PM ******/
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

/****** Object:  Table [DBA].[Hotel]    Script Date: 7/13/2015 1:22:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Hotel](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[HtlSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[HtlChainCode] [varchar](6) NULL,
	[HtlChainName] [varchar](40) NULL,
	[GDSPropertyNum] [varchar](15) NULL,
	[HtlPropertyName] [varchar](40) NULL,
	[HtlAddr1] [varchar](40) NULL,
	[HtlAddr2] [varchar](40) NULL,
	[HtlAddr3] [varchar](40) NULL,
	[HtlCityCode] [varchar](10) NULL,
	[HtlCityName] [varchar](25) NULL,
	[HtlState] [varchar](20) NULL,
	[HtlPostalCode] [varchar](15) NULL,
	[HtlCountryCode] [varchar](5) NULL,
	[HtlPhone] [varchar](20) NULL,
	[InternationalInd] [varchar](1) NULL,
	[CheckinDate] [datetime] NULL,
	[CheckoutDate] [datetime] NULL,
	[NumNights] [smallint] NULL,
	[NumRooms] [smallint] NULL,
	[HtlQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[HtlDailyRate] [float] NULL,
	[TtlHtlCost] [float] NULL,
	[RoomType] [varchar](6) NULL,
	[HtlRateCat] [varchar](10) NULL,
	[HtlCompareRate1] [float] NULL,
	[HtlReasonCode1] [varchar](6) NULL,
	[HtlCompareRate2] [float] NULL,
	[HtlReasonCode2] [varchar](6) NULL,
	[HtlCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefHtlInd] [varchar](1) NULL,
	[HtlConfNum] [varchar](30) NULL,
	[FreqGuestProgram] [varchar](13) NULL,
	[HtlStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[HtlCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[MasterID] [int] NULL,
	[CO2Emissions] [float] NULL,
	[MilesFromAirport] [float] NULL,
	[GroundTransCO2] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Hotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[DataUpdatesTemp]    Script Date: 7/13/2015 1:22:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[DataUpdatesTemp](
	[RequestName] [varchar](50) NULL,
	[PRODUCT] [varchar](50) NULL,
	[RecordIdentifier] [varchar](50) NULL,
	[Sequence] [varchar](5) NULL,
	[RecordLocator] [varchar](10) NULL,
	[HotelName] [varchar](200) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNumber] [varchar](10) NULL,
	[TicketNumber] [varchar](255) NULL,
	[ReasonCode] [varchar](10) NULL,
	[TripPurpose] [varchar](10) NULL,
	[ApproverGPN] [varchar](10) NULL,
	[ApproverName] [varchar](50) NULL,
	[BookerGPN] [varchar](10) NULL,
	[BookerName] [varchar](50) NULL,
	[TravelerGPN] [varchar](10) NULL,
	[TractID] [varchar](10) NULL,
	[LowAirFare] [float] NULL,
	[FullAirFare] [float] NULL,
	[TicketAirAmount] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SegNum] [smallint] NULL,
	[ImportDt] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[DataUpdatesTemp] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[dataupdates]    Script Date: 7/13/2015 1:22:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[dataupdates](
	[RequestName] [varchar](50) NULL,
	[PRODUCT] [varchar](50) NULL,
	[RecordIdentifier] [varchar](50) NULL,
	[Sequence] [varchar](5) NULL,
	[RecordLocator] [varchar](10) NULL,
	[HotelName] [varchar](200) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNumber] [varchar](10) NULL,
	[TicketNumber] [varchar](255) NULL,
	[ReasonCode] [varchar](10) NULL,
	[TripPurpose] [varchar](10) NULL,
	[ApproverGPN] [varchar](10) NULL,
	[ApproverName] [varchar](50) NULL,
	[BookerGPN] [varchar](10) NULL,
	[BookerName] [varchar](50) NULL,
	[TravelerGPN] [varchar](10) NULL,
	[TractID] [varchar](10) NULL,
	[LowAirFare] [float] NULL,
	[FullAirFare] [float] NULL,
	[TicketAirAmount] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SegNum] [smallint] NULL,
	[ImportDt] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[dataupdates] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/13/2015 1:22:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ComRmks](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[Text1] [varchar](150) NULL,
	[Text2] [varchar](150) NULL,
	[Text3] [varchar](150) NULL,
	[Text4] [varchar](150) NULL,
	[Text5] [varchar](150) NULL,
	[Text6] [varchar](150) NULL,
	[Text7] [varchar](150) NULL,
	[Text8] [varchar](150) NULL,
	[Text9] [varchar](150) NULL,
	[Text10] [varchar](150) NULL,
	[Text11] [varchar](150) NULL,
	[Text12] [varchar](150) NULL,
	[Text13] [varchar](150) NULL,
	[Text14] [varchar](150) NULL,
	[Text15] [varchar](150) NULL,
	[Text16] [varchar](150) NULL,
	[Text17] [varchar](150) NULL,
	[Text18] [varchar](150) NULL,
	[Text19] [varchar](150) NULL,
	[Text20] [varchar](150) NULL,
	[Text21] [varchar](150) NULL,
	[Text22] [varchar](150) NULL,
	[Text23] [varchar](150) NULL,
	[Text24] [varchar](150) NULL,
	[Text25] [varchar](150) NULL,
	[Text26] [varchar](150) NULL,
	[Text27] [varchar](150) NULL,
	[Text28] [varchar](150) NULL,
	[Text29] [varchar](150) NULL,
	[Text30] [varchar](150) NULL,
	[Text31] [varchar](150) NULL,
	[Text32] [varchar](150) NULL,
	[Text33] [varchar](150) NULL,
	[Text34] [varchar](150) NULL,
	[Text35] [varchar](150) NULL,
	[Text36] [varchar](150) NULL,
	[Text37] [varchar](150) NULL,
	[Text38] [varchar](150) NULL,
	[Text39] [varchar](150) NULL,
	[Text40] [varchar](150) NULL,
	[Text41] [varchar](150) NULL,
	[Text42] [varchar](150) NULL,
	[Text43] [varchar](150) NULL,
	[Text44] [varchar](150) NULL,
	[Text45] [varchar](150) NULL,
	[Text46] [varchar](150) NULL,
	[Text47] [varchar](150) NULL,
	[Text48] [varchar](150) NULL,
	[Text49] [varchar](150) NULL,
	[Text50] [varchar](150) NULL,
	[Num1] [float] NULL,
	[Num2] [float] NULL,
	[Num3] [float] NULL,
	[Num4] [float] NULL,
	[Num5] [float] NULL,
	[Num6] [float] NULL,
	[Num7] [float] NULL,
	[Num8] [float] NULL,
	[Num9] [float] NULL,
	[Num10] [float] NULL,
	[Num11] [float] NULL,
	[Num12] [float] NULL,
	[Num13] [float] NULL,
	[Num14] [float] NULL,
	[Num15] [float] NULL,
	[Num16] [float] NULL,
	[Num17] [float] NULL,
	[Num18] [float] NULL,
	[Num19] [float] NULL,
	[Num20] [float] NULL,
	[Num21] [float] NULL,
	[Num22] [float] NULL,
	[Num23] [float] NULL,
	[Num24] [float] NULL,
	[Num25] [float] NULL,
	[Num26] [float] NULL,
	[Num27] [float] NULL,
	[Num28] [float] NULL,
	[Num29] [float] NULL,
	[Num30] [float] NULL,
	[Int1] [int] NULL,
	[Int2] [int] NULL,
	[Int3] [int] NULL,
	[Int4] [int] NULL,
	[Int5] [int] NULL,
	[Int6] [int] NULL,
	[Int7] [int] NULL,
	[Int8] [int] NULL,
	[Int9] [int] NULL,
	[Int10] [int] NULL,
	[Int11] [int] NULL,
	[Int12] [int] NULL,
	[Int13] [int] NULL,
	[Int14] [int] NULL,
	[Int15] [int] NULL,
	[Int16] [int] NULL,
	[Int17] [int] NULL,
	[Int18] [int] NULL,
	[Int19] [int] NULL,
	[Int20] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Car]    Script Date: 7/13/2015 1:23:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Car](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[CarSegNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[CarType] [varchar](6) NULL,
	[CarChainCode] [varchar](6) NULL,
	[CarChainName] [varchar](20) NULL,
	[CarCityCode] [varchar](10) NULL,
	[CarCityName] [varchar](25) NULL,
	[InternationalInd] [varchar](1) NULL,
	[PickupDate] [datetime] NULL,
	[DropoffDate] [datetime] NULL,
	[CarDropoffCityCode] [varchar](10) NULL,
	[NumDays] [smallint] NULL,
	[NumCars] [smallint] NULL,
	[CarQuotedRate] [float] NULL,
	[QuotedCurrCode] [varchar](3) NULL,
	[CarDailyRate] [float] NULL,
	[TtlCarCost] [float] NULL,
	[CarRateCat] [varchar](10) NULL,
	[CarCompareRate1] [float] NULL,
	[CarReasonCode1] [varchar](6) NULL,
	[CarCompareRate2] [float] NULL,
	[CarReasonCode2] [varchar](6) NULL,
	[CarCommAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[PrefCarInd] [varchar](1) NULL,
	[CarConfNum] [varchar](30) NULL,
	[FreqRenterProgram] [varchar](13) NULL,
	[CarStatus] [varchar](2) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[CommTrackInd] [varchar](5) NULL,
	[CarCommPostDate] [datetime] NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[CarDropOffCityName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Car] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PK_ROLLUP40]    Script Date: 7/13/2015 1:23:29 PM ******/
CREATE UNIQUE CLUSTERED INDEX [PK_ROLLUP40] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP1] ASC,
	[ROLLUP2] ASC,
	[ROLLUP3] ASC,
	[ROLLUP4] ASC,
	[ROLLUP5] ASC,
	[ROLLUP6] ASC,
	[ROLLUP7] ASC,
	[ROLLUP8] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [LookupDataI1]    Script Date: 7/13/2015 1:23:30 PM ******/
CREATE CLUSTERED INDEX [LookupDataI1] ON [DBA].[LookupData]
(
	[LookupName] ASC,
	[LookupValue] ASC,
	[ParentNode] ASC,
	[LookupText] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 1:23:31 PM ******/
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

/****** Object:  Index [HotelI1]    Script Date: 7/13/2015 1:23:32 PM ******/
CREATE CLUSTERED INDEX [HotelI1] ON [DBA].[Hotel]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/13/2015 1:23:33 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [DBA].[ComRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/13/2015 1:23:34 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [DBA].[Car]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Rollup40_I*]    Script Date: 7/13/2015 1:23:34 PM ******/
CREATE NONCLUSTERED INDEX [Rollup40_I*] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI1]    Script Date: 7/13/2015 1:23:34 PM ******/
CREATE NONCLUSTERED INDEX [RollupI1] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI2]    Script Date: 7/13/2015 1:23:34 PM ******/
CREATE NONCLUSTERED INDEX [RollupI2] ON [DBA].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 1:23:34 PM ******/
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

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 1:23:35 PM ******/
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

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 1:23:36 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 1:23:36 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 1:23:37 PM ******/
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

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 1:23:39 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 1:23:39 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 1:23:39 PM ******/
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

/****** Object:  Index [HotelI2]    Script Date: 7/13/2015 1:23:40 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [DBA].[Hotel]
(
	[VoidInd] ASC,
	[IataNum] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[NumRooms],
	[HtlReasonCode1],
	[CurrCode],
	[Remarks2],
	[MasterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI3]    Script Date: 7/13/2015 1:23:42 PM ******/
CREATE NONCLUSTERED INDEX [HotelI3] ON [DBA].[Hotel]
(
	[VoidInd] ASC,
	[IataNum] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[NumNights],
	[NumRooms],
	[HtlDailyRate],
	[CurrCode],
	[MasterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelPX]    Script Date: 7/13/2015 1:23:42 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [DBA].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/13/2015 1:23:43 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI2]    Script Date: 7/13/2015 1:23:44 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [DBA].[Car]
(
	[VoidInd] ASC,
	[IataNum] ASC,
	[IssueDate] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[CarCityCode],
	[NumDays],
	[NumCars],
	[CarDailyRate],
	[CurrCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarPX]    Script Date: 7/13/2015 1:23:45 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CarPX] ON [DBA].[Car]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 1:23:45 PM ******/
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

