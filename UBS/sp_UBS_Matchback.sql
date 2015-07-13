/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='invoicedetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='ccticket' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='ccheader' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:34:48 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_Matchback]    Script Date: 7/13/2015 1:34:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_Matchback]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'UBSMatchback'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
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

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start -',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------- Delete all matched values that were flagged in CC Matchback for Iatanum PREUBS as these transactions should
------ not be used in matching .................
update dba.ccheader
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL, matchedind= NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.cchotel
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.cccar
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.ccticket
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchediatanum in ('preubs','BCDUBSEH','BCDUBSUH')

update dba.hotel
set matchedind = NULL where iatanum in ('preubs','BCDUBSEH','BCDUBSUH') and matchedind is not NULL

update dba.Invoicedetail
set matchedind = NULL where iatanum in ('preubs','BCDUBSEH','BCDUBSUH') and matchedind is not NULL

update dba.car
set matchedind = NULL where iatanum in ('preubs','BCDUBSEH','BCDUBSUH') and matchedind is not NULL

--------- Delete all matched values that were flagged in CC Matchback with a 3 or 4 as these are not trusted matches ------
----- CC table updates
update dba.ccheader
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL, matchedind= NULL
where matchedrecordkey in (select recordkey from dba.invoicedetail where matchedind in ('3','4'))

update dba.cchotel
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchedrecordkey in (select recordkey from dba.hotel where matchedind in ('3','4'))

update dba.cccar
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
where matchedrecordkey in (select recordkey from dba.car where matchedind in ('3','4'))
----- TMC table Updates ---- 
update dba.invoicedetail
set matchedind = NULL where matchedind in ('3','4')

update dba.hotel
set matchedind = NULL where matchedind in ('3','4')

update dba.car
set matchedind = NULL where matchedind in ('3','4')

--Update CCHotel where masterid does not match to dba.hotel.masterid but match has been made
update cch
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
--select h.matchedind,cch.HtlChainCode,cch.DescOfCharge,ccm.merchantaddr1,h.HtlPropertyName,h.HtlChainCode,h.htladdr1
 from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 
and h.MatchedInd <'5'
and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2014' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid <> ccmxref.parentid


--Update CCHeader where masterid does not match to dba.hotel.masterid but match has been made

update cch
set matchedrecordkey = NULL, matchediatanum = NULL, matchedclientcode = NULL, matchedseqnum = NULL
--select cch.HtlChainCode,cch.DescOfCharge,ccm.merchantaddr1,h.HtlPropertyName,h.HtlChainCode,h.htladdr1
 from dba.ccheader cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM
where cch.employeeid = h.remarks2 
--and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and h.matchedind <5 
and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2014' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid <> ccmxref.parentid


--update dba.hotel where recordkey no longer in matched recordkey for cchotel

update h
set MatchedInd=NULL
from dba.hotel h
where 
 h.invoicedate > '1-1-2014' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
 and h.MatchedInd<>0
and RecordKey not in (select matchedrecordkey from dba.cchotel where TransactionDate>='2014-01-01' and MatchedRecordKey is not null)


-----------------------------------------------------------------------------------------------------------------------------------
---- Additional CC Matching as not being matched by CC Match back ----- LOC/8/16/2013

-------- CC Ticket Matches -------------------------------------
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update id
set id.matchedind = '2'
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where substring(id.documentnumber,1,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' and id.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(75)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode and id.matchedind is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='ID Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------ Additional updates for CC Matchback ---------- LOC/6/19/2013
--------CCHTL updates ------matching on EmployeeID/GPN and first 5 of last/First name
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


--------Hotel updates -----matching on EmployeeID/GPN and first 5 of last/First name
Update h
set h.matchedind = '2' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(guestname,1,5) = substring(lastname+'/'+firstname,1,5)
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

-------Hotel updates ------matching on EmployeeID/GPN 
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN
Update h
set h.matchedind = '5' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.20*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.20*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd' and checkindate >= getdate()
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


-------Hotel updates ------matching on EmployeeID/GPN -- And Ttl cost at 40%
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN -- And Ttl cost at 40%
Update h
set h.matchedind = '6' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 and cch.arrivaldate = h.checkindate
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate = cch.arrivaldate
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


-------Hotel updates ------matching on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
 DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
Update h
set h.matchedind = '7' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm, DBA.HotelProperty HTLXREF, DBA.HotelProperty HTLPROP
,DBA.HotelProperty CCMXREF, DBA.HotelProperty HTLPROPCCM,
DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and h.matchedind is null and cch.matchedrecordkey = h.recordkey
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and HTLXREF.MasterID = H.MasterId and HTLXREF.ParentId = HTLPROP.MasterID
and CCMXREF.MasterID = ccm.MasterId and CCMXREF.ParentId = HTLPROPCCM.MasterID
and htlxref.parentid = ccmxref.parentid
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


-------Hotel updates ------matching on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
---- and First 5 of hotel name = first 5 of descofcharge
Update cch
set cch.matchedrecordkey = h.recordkey, cch.matchediatanum = h.iatanum, matchedclientcode = h.clientcode,
matchedseqnum = h.seqnum
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm,
DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and cch.matchedrecordkey is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and substring(htlpropertyname,1,5) = substring(descofcharge,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate

--------Hotel updates -----matching only on EmployeeID/GPN -- And Ttl cost at 40% -- and dates are 2 days off
---- and First 5 of hotel name = first 5 of descofcharge
Update h
set h.matchedind = '8' 
from dba.cchotel cch, dba.hotel h, dba.ccmerchant ccm,
DBA.Currency CURRBASE , dba.currency currto
where cch.employeeid = h.remarks2 
and h.matchedind is null
and h.invoicedate > '1-1-2013' and h.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and h.checkindate between  cch.arrivaldate -2 and cch.arrivaldate +2
and abs(ttlhtlcost)-(abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < (.40*ttlhtlcost)
and (abs(totalauthamt)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase))-abs(ttlhtlcost) < (.40*totalauthamt)
and ccm.merchantid = cch.merchantid 
and substring(htlpropertyname,1,5) = substring(descofcharge,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate


--------CCCAR updates ------
Update ccc
set ccc.matchedrecordkey = c.recordkey, ccc.matchediatanum = c.iatanum, matchedclientcode = c.clientcode,
ccc.matchedseqnum = c.seqnum
from dba.cccar ccc, dba.car c, dba.ccmerchant ccm
where ccc.employeeid = c.remarks2 and ccc.rentaldate = c.pickupdate
and ccc.matchedrecordkey is null
and c.invoicedate > '1-1-2013' and c.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(rentername,1,5) = substring(lastname+'/'+firstname,1,5)
and rentername<> lastname+'/'+firstname 
and abs(ttlcarcost)-abs(totalauthamt) < (.20*ttlcarcost)
and abs(totalauthamt)-abs(ttlcarcost) < (.20*totalauthamt)
and ccm.merchantid = ccc.merchantid 
--------Car updates -----
Update c
set c.matchedind = '2' 
from dba.cccar ccc, dba.car c, dba.ccmerchant ccm
where ccc.employeeid = c.remarks2 and ccc.rentaldate = c.pickupdate
and ccc.matchedrecordkey is null
and c.invoicedate > '1-1-2013' and c.iatanum not in ('preubs','BCDUBSEH','BCDUBSUH')
and substring(rentername,1,5) = substring(lastname+'/'+firstname,1,5)
and rentername<> lastname+'/'+firstname 
and abs(ttlcarcost)-abs(totalauthamt) < (.20*ttlcarcost)
and abs(totalauthamt)-abs(ttlcarcost) < (.20*totalauthamt)
and ccm.merchantid = ccc.merchantid 


SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBS Matchback Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_Matchback] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:34:49 PM ******/
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

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 1:34:50 PM ******/
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

/****** Object:  Table [DBA].[HotelProperty]    Script Date: 7/13/2015 1:35:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[HotelProperty](
	[MasterID] [int] NULL,
	[PhoneNumber] [varchar](20) NULL,
	[ChainCode] [varchar](6) NULL,
	[HotelPropertyName] [varchar](255) NULL,
	[HotelAddress1] [varchar](255) NULL,
	[HotelAddress2] [varchar](255) NULL,
	[HotelAddress3] [varchar](255) NULL,
	[HotelCityCode] [varchar](10) NULL,
	[HotelCityName] [varchar](100) NULL,
	[HotelStateProvince] [varchar](20) NULL,
	[HotelPostalCode] [varchar](15) NULL,
	[HotelCountryCode] [varchar](5) NULL,
	[HotelFaxNumber] [varchar](20) NULL,
	[PreferredHotelInd] [varchar](1) NULL,
	[NewHotelInd] [varchar](1) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[MaxScore] [float] NULL,
	[MatchScore] [float] NULL,
	[MatchRate] [float] NULL,
	[PropNameTokenCount] [float] NULL,
	[AddressTokenCount] [float] NULL,
	[CityTokenCount] [float] NULL,
	[PhoneToken01] [varchar](30) NULL,
	[PropNameToken01] [varchar](30) NULL,
	[PropNameToken02] [varchar](30) NULL,
	[PropNameToken03] [varchar](30) NULL,
	[PropNameToken04] [varchar](30) NULL,
	[PropNameToken05] [varchar](30) NULL,
	[PropNameToken06] [varchar](30) NULL,
	[PropNameToken07] [varchar](30) NULL,
	[AddressToken01] [varchar](30) NULL,
	[AddressToken02] [varchar](30) NULL,
	[AddressToken03] [varchar](30) NULL,
	[AddressToken04] [varchar](30) NULL,
	[AddressToken05] [varchar](30) NULL,
	[AddressToken06] [varchar](30) NULL,
	[AddressToken07] [varchar](30) NULL,
	[AddressToken08] [varchar](30) NULL,
	[AddressToken09] [varchar](30) NULL,
	[AddressToken10] [varchar](30) NULL,
	[CityToken01] [varchar](30) NULL,
	[CityToken02] [varchar](30) NULL,
	[CityToken03] [varchar](30) NULL,
	[CityToken04] [varchar](30) NULL,
	[CityToken05] [varchar](30) NULL,
	[StateToken01] [varchar](30) NULL,
	[PostalCodeToken01] [varchar](30) NULL,
	[CountryCodeToken01] [varchar](30) NULL,
	[PropNameTokenString] [varchar](75) NULL,
	[AddressTokenString] [varchar](75) NULL,
	[CityTokenString] [varchar](75) NULL,
	[ParentId] [int] NULL,
	[HotelUpdateInd] [char](10) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[Floors] [float] NULL,
	[Rooms] [float] NULL,
	[Suites] [float] NULL,
	[Restaurants] [float] NULL,
	[MeetingRooms] [float] NULL,
	[MeetingCapacity] [float] NULL,
	[MeetingSqFoot] [float] NULL,
	[EmailAddress] [varchar](100) NULL,
	[InternetAddress] [varchar](100) NULL,
	[ManagementName] [varchar](60) NULL,
	[HotelTypeName] [varchar](60) NULL,
	[LocationName] [varchar](60) NULL,
	[ScaleName] [varchar](60) NULL,
	[CountyName] [varchar](60) NULL,
	[FemaCode] [varchar](50) NULL,
	[TollFree] [varchar](50) NULL,
	[ChainName] [varchar](100) NULL,
	[Source] [varchar](4) NULL,
	[LocationId] [int] NULL,
	[NormPropertyName] [varchar](255) NULL,
	[NormAddress1] [varchar](255) NULL,
	[NormAddress2] [varchar](255) NULL,
	[NormAddress3] [varchar](255) NULL,
	[NormCityName] [varchar](100) NULL,
	[MetroArea] [varchar](100) NULL,
	[SubNeighborhood] [varchar](100) NULL,
	[NearestMasterID] [int] NULL,
	[ClusterID] [varchar](25) NULL,
	[StarRating] [varchar](10) NULL,
	[UversaID] [int] NULL,
	[LanyonID] [int] NULL,
	[SabrePropNum] [varchar](20) NULL,
	[GalileoPropNum] [varchar](20) NULL,
	[AmadeusPropNum] [varchar](20) NULL,
	[WorldSpanPropNum] [varchar](20) NULL,
	[UserDefined01] [varchar](50) NULL,
	[UserDefined02] [varchar](50) NULL,
	[UserDefined03] [varchar](50) NULL,
	[UserDefined04] [varchar](50) NULL,
	[UserDefined05] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[HotelProperty] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Hotel]    Script Date: 7/13/2015 1:35:16 PM ******/
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

/****** Object:  Table [DBA].[Currency]    Script Date: 7/13/2015 1:35:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Currency](
	[BaseCurrCode] [varchar](3) NULL,
	[CurrCode] [varchar](3) NULL,
	[CurrBeginDate] [datetime] NULL,
	[CurrEndDate] [datetime] NULL,
	[BaseUnitsPerCurr] [float] NULL,
	[CurrUnitsPerBase] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Currency] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCTicket]    Script Date: 7/13/2015 1:35:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCTicket](
	[RecordKey] [varchar](70) NULL,
	[IataNum] [varchar](8) NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[TktReferenceNum] [varchar](23) NULL,
	[TicketNum] [varchar](10) NULL,
	[ValCarrierCode] [varchar](3) NULL,
	[ValCarrierNum] [int] NULL,
	[TktOriginatingCCNum] [varchar](50) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[TransFeeInd] [varchar](1) NULL,
	[IssuerCity] [varchar](30) NULL,
	[IssuerState] [varchar](6) NULL,
	[ServiceDate] [datetime] NULL,
	[Routing] [varchar](40) NULL,
	[ClassOfService] [varchar](20) NULL,
	[TicketIssuer] [varchar](37) NULL,
	[BookedIataNum] [varchar](8) NULL,
	[PassengerName] [varchar](50) NULL,
	[OrigTicketNum] [varchar](10) NULL,
	[Remarks1] [varchar](40) NULL,
	[Remarks2] [varchar](40) NULL,
	[Remarks3] [varchar](40) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BilledDate] [datetime] NULL,
	[CarrierStr] [varchar](30) NULL,
	[TicketAmt] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BatchName] [varchar](30) NULL,
	[MerchantId] [varchar](40) NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[MatchedSeqNum] [int] NULL,
	[InternationalInd] [varchar](1) NULL,
	[Mileage] [float] NULL,
	[DaysAdvPurch] [smallint] NULL,
	[AdvPurchGroup] [varchar](20) NULL,
	[TrueTktCount] [smallint] NULL,
	[TripLength] [smallint] NULL,
	[AncillaryFeeInd] [int] NULL,
	[ServiceCat] [varchar](2) NULL,
	[AlternateName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCTicket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCMerchant]    Script Date: 7/13/2015 1:35:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCMerchant](
	[MerchantId] [varchar](40) NULL,
	[MerchantName1] [varchar](40) NULL,
	[MerchantName2] [varchar](40) NULL,
	[MerchantAddr1] [varchar](40) NULL,
	[MerchantAddr2] [varchar](40) NULL,
	[MerchantAddr3] [varchar](40) NULL,
	[MerchantAddr4] [varchar](40) NULL,
	[MerchantCity] [varchar](40) NULL,
	[MerchantState] [varchar](20) NULL,
	[MerchantZip] [varchar](15) NULL,
	[MerchantCtryCode] [varchar](15) NULL,
	[MerchantCtryName] [varchar](35) NULL,
	[MerchantPhone] [varchar](20) NULL,
	[SICCode] [varchar](4) NULL,
	[SICName] [varchar](130) NULL,
	[CorporateId] [varchar](19) NULL,
	[RecordofCharge] [varchar](13) NULL,
	[MerchantIndCode] [varchar](2) NULL,
	[MerchantSubIndCode] [varchar](3) NULL,
	[MerchantFederalTaxId] [varchar](9) NULL,
	[MerchantDunBradNum] [varchar](9) NULL,
	[MerchantOwnerTypeCd] [varchar](2) NULL,
	[MerchantPurchCd] [varchar](2) NULL,
	[PurgeInd] [varchar](1) NULL,
	[GenesisMajorIndCode] [varchar](4) NULL,
	[GenesisDetailIndCode] [varchar](4) NULL,
	[MerchantChain] [varchar](30) NULL,
	[MerchantBrand] [varchar](30) NULL,
	[MasterId] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCMerchant] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCHotel]    Script Date: 7/13/2015 1:35:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCHotel](
	[RecordKey] [varchar](70) NULL,
	[IataNum] [varchar](8) NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[HtlChainCode] [varchar](5) NULL,
	[HtlReferenceNum] [varchar](23) NULL,
	[HTLOriginatingCCNum] [varchar](50) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[DescOfCharge] [varchar](45) NULL,
	[GuestName] [varchar](50) NULL,
	[ArrivalDate] [datetime] NULL,
	[DepartDate] [datetime] NULL,
	[NumNights] [int] NULL,
	[NumPeople] [int] NULL,
	[RoomRate] [float] NULL,
	[RoomAmt] [float] NULL,
	[PhoneAmt] [float] NULL,
	[PhoneTax] [float] NULL,
	[FoodAmt] [float] NULL,
	[RoomServiceAmt] [float] NULL,
	[RoomServiceTax] [float] NULL,
	[TipAmt1] [float] NULL,
	[TipAmt2] [float] NULL,
	[OtherCharges] [float] NULL,
	[TotalAuthAmt] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[RoomType] [varchar](4) NULL,
	[City] [varchar](30) NULL,
	[State] [varchar](6) NULL,
	[FolioNum] [varchar](23) NULL,
	[NoShowInd] [varchar](1) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BilledDate] [datetime] NULL,
	[BatchName] [varchar](30) NULL,
	[MerchantId] [varchar](40) NULL,
	[HtlSeqNum] [int] NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[MatchedSeqNum] [int] NULL,
	[CountryCode] [varchar](3) NULL,
	[InternationalInd] [char](1) NULL,
	[MiniBarAmt] [float] NULL,
	[LoungeBarAmt] [float] NULL,
	[GiftShopAmt] [float] NULL,
	[DryCleanAmt] [float] NULL,
	[ValetAmt] [float] NULL,
	[MovieAmt] [float] NULL,
	[BusCtrAmt] [float] NULL,
	[HlthClbAmt] [float] NULL,
	[TransAmt] [float] NULL,
	[ConfRmAmt] [float] NULL,
	[INetAmt] [float] NULL,
	[AlternateName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCHotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCHeader]    Script Date: 7/13/2015 1:35:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCHeader](
	[RecordKey] [varchar](100) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[MerchantId] [varchar](40) NULL,
	[CCSourceFile] [varchar](10) NULL,
	[RptCreateDate] [datetime] NULL,
	[CCCycleDate] [datetime] NULL,
	[TransactionDate] [datetime] NULL,
	[PostDate] [datetime] NULL,
	[BilledDate] [datetime] NULL,
	[RecordType] [varchar](2) NULL,
	[TransactionNum] [varchar](23) NULL,
	[BatchNum] [varchar](24) NULL,
	[ControlCCNum] [varchar](50) NULL,
	[BasicCCNum] [varchar](50) NULL,
	[CreditCardNum] [varchar](50) NULL,
	[ChargeDesc] [varchar](50) NULL,
	[TransactionType] [varchar](5) NULL,
	[RefundInd] [varchar](1) NULL,
	[ChargeType] [varchar](20) NULL,
	[FinancialCatCode] [varchar](1) NULL,
	[DisputedFlag] [varchar](25) NULL,
	[CardHolderName] [varchar](50) NULL,
	[LocalCurrAmt] [float] NULL,
	[LocalTaxAmt] [float] NULL,
	[LocalCurrCode] [varchar](3) NULL,
	[BilledAmt] [float] NULL,
	[BilledTaxAmt] [float] NULL,
	[BilledTaxAmt2] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[BaseFare] [float] NULL,
	[IndustryCode] [varchar](2) NULL,
	[MatchedInd] [varchar](1) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BatchName] [varchar](30) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[CompanyName] [varchar](20) NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[CarHtlSeqNum] [int] NULL,
	[MatchedSeqNum] [int] NULL,
	[Remarks1] [varchar](40) NULL,
	[Remarks2] [varchar](40) NULL,
	[Remarks3] [varchar](40) NULL,
	[Remarks4] [varchar](40) NULL,
	[Remarks5] [varchar](40) NULL,
	[Remarks6] [varchar](40) NULL,
	[Remarks7] [varchar](40) NULL,
	[Remarks8] [varchar](40) NULL,
	[Remarks9] [varchar](40) NULL,
	[Remarks10] [varchar](40) NULL,
	[Remarks11] [varchar](40) NULL,
	[Remarks12] [varchar](40) NULL,
	[Remarks13] [varchar](40) NULL,
	[Remarks14] [varchar](40) NULL,
	[Remarks15] [varchar](40) NULL,
	[TransactionFlag] [char](1) NULL,
	[TransactionID] [varchar](20) NULL,
	[MarketCode] [varchar](10) NULL,
	[ImportDate] [datetime] NULL,
	[AncillaryFeeInd] [int] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[OriginatingCMAcctNum] [varchar](20) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[CCCar]    Script Date: 7/13/2015 1:35:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[CCCar](
	[RecordKey] [varchar](70) NULL,
	[IataNum] [varchar](8) NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[CarCompanyCode] [varchar](5) NULL,
	[CarReferenceNum] [varchar](23) NULL,
	[CarOriginatingCCNum] [varchar](50) NULL,
	[CostCenter] [varchar](14) NULL,
	[EmployeeId] [varchar](20) NULL,
	[SSNum] [varchar](11) NULL,
	[RentalDate] [datetime] NULL,
	[RentalLoc] [varchar](30) NULL,
	[RentalState] [varchar](2) NULL,
	[ReturnDate] [datetime] NULL,
	[ReturnLoc] [varchar](30) NULL,
	[ReturnState] [varchar](2) NULL,
	[RenterName] [varchar](50) NULL,
	[NumDays] [int] NULL,
	[RentalAgreementNum] [varchar](23) NULL,
	[CarId] [varchar](15) NULL,
	[CarClass] [varchar](4) NULL,
	[CarDesc] [varchar](42) NULL,
	[Mileage] [float] NULL,
	[GasAmt] [float] NULL,
	[TotalAuthAmt] [float] NULL,
	[BilledCurrCode] [varchar](3) NULL,
	[PurgeInd] [varchar](1) NULL,
	[BilledDate] [datetime] NULL,
	[BatchName] [varchar](30) NULL,
	[MerchantId] [varchar](40) NULL,
	[CarSeqNum] [int] NULL,
	[MatchedRecordKey] [varchar](70) NULL,
	[MatchedIataNum] [varchar](8) NULL,
	[MatchedClientCode] [varchar](15) NULL,
	[MatchedSeqNum] [int] NULL,
	[RentalCountryCode] [varchar](3) NULL,
	[ReturnCountryCode] [varchar](3) NULL,
	[InternationalInd] [char](1) NULL,
	[AlternateName] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[CCCar] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Car]    Script Date: 7/13/2015 1:36:07 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 1:36:14 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [PX_HotelProperty]    Script Date: 7/13/2015 1:36:14 PM ******/
CREATE UNIQUE CLUSTERED INDEX [PX_HotelProperty] ON [DBA].[HotelProperty]
(
	[MasterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI1]    Script Date: 7/13/2015 1:36:14 PM ******/
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

/****** Object:  Index [CurrencyPX]    Script Date: 7/13/2015 1:36:15 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CurrencyPX] ON [DBA].[Currency]
(
	[BaseCurrCode] ASC,
	[CurrCode] ASC,
	[CurrBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI1]    Script Date: 7/13/2015 1:36:15 PM ******/
CREATE CLUSTERED INDEX [CCTicketI1] ON [DBA].[CCTicket]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCMerchantI1]    Script Date: 7/13/2015 1:36:16 PM ******/
CREATE CLUSTERED INDEX [CCMerchantI1] ON [DBA].[CCMerchant]
(
	[GenesisMajorIndCode] ASC,
	[GenesisDetailIndCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHotelI1]    Script Date: 7/13/2015 1:36:16 PM ******/
CREATE CLUSTERED INDEX [CCHotelI1] ON [DBA].[CCHotel]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI1]    Script Date: 7/13/2015 1:36:17 PM ******/
CREATE CLUSTERED INDEX [CCHeaderI1] ON [DBA].[CCHeader]
(
	[IataNum] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCCarI1]    Script Date: 7/13/2015 1:36:18 PM ******/
CREATE CLUSTERED INDEX [CCCarI1] ON [DBA].[CCCar]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/13/2015 1:36:18 PM ******/
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

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 1:36:18 PM ******/
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

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 1:36:19 PM ******/
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

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 1:36:19 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 1:36:20 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 1:36:20 PM ******/
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

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 1:36:21 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 1:36:21 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 1:36:21 PM ******/
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

/****** Object:  Index [HotelI2]    Script Date: 7/13/2015 1:36:21 PM ******/
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

/****** Object:  Index [HotelI3]    Script Date: 7/13/2015 1:36:22 PM ******/
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

/****** Object:  Index [HotelPX]    Script Date: 7/13/2015 1:36:22 PM ******/
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

/****** Object:  Index [CurrencyI1]    Script Date: 7/13/2015 1:36:23 PM ******/
CREATE NONCLUSTERED INDEX [CurrencyI1] ON [DBA].[Currency]
(
	[BaseCurrCode] ASC,
	[CurrBeginDate] ASC
)
INCLUDE ( 	[CurrCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [CCTicketI2]    Script Date: 7/13/2015 1:36:23 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI2] ON [DBA].[CCTicket]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI3]    Script Date: 7/13/2015 1:36:23 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI3] ON [DBA].[CCTicket]
(
	[TicketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI4]    Script Date: 7/13/2015 1:36:23 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI4] ON [DBA].[CCTicket]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI5]    Script Date: 7/13/2015 1:36:23 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI5] ON [DBA].[CCTicket]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI6]    Script Date: 7/13/2015 1:36:24 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI6] ON [DBA].[CCTicket]
(
	[TransactionDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[ValCarrierCode],
	[EmployeeId],
	[TicketAmt],
	[MerchantId],
	[MatchedRecordKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketPX]    Script Date: 7/13/2015 1:36:24 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCTicketPX] ON [DBA].[CCTicket]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCMerchantPx]    Script Date: 7/13/2015 1:36:24 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCMerchantPx] ON [DBA].[CCMerchant]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [CCHotelI2]    Script Date: 7/13/2015 1:36:24 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI2] ON [DBA].[CCHotel]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHotelI3]    Script Date: 7/13/2015 1:36:24 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI3] ON [DBA].[CCHotel]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHotelI4]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHotelI4] ON [DBA].[CCHotel]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHotelPX]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCHotelPX] ON [DBA].[CCHotel]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeader_AncFee]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_AncFee] ON [DBA].[CCHeader]
(
	[AncillaryFeeInd] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[BilledCurrCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI2]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI2] ON [DBA].[CCHeader]
(
	[BilledDate] ASC,
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderI3]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI3] ON [DBA].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCHeaderPX]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCHeaderPX] ON [DBA].[CCHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI7]    Script Date: 7/13/2015 1:36:25 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI7] ON [DBA].[CCHeader]
(
	[TransactionDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[MerchantId],
	[BilledCurrCode],
	[EmployeeId],
	[MarketCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCTicketI8]    Script Date: 7/13/2015 1:36:26 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI8] ON [DBA].[CCHeader]
(
	[MarketCode] ASC,
	[TransactionDate] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[MerchantId],
	[BilledCurrCode],
	[EmployeeId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [CCCarI2]    Script Date: 7/13/2015 1:36:26 PM ******/
CREATE NONCLUSTERED INDEX [CCCarI2] ON [DBA].[CCCar]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCCarI3]    Script Date: 7/13/2015 1:36:26 PM ******/
CREATE NONCLUSTERED INDEX [CCCarI3] ON [DBA].[CCCar]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCCarI4]    Script Date: 7/13/2015 1:36:26 PM ******/
CREATE NONCLUSTERED INDEX [CCCarI4] ON [DBA].[CCCar]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CCCarPX]    Script Date: 7/13/2015 1:36:26 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CCCarPX] ON [DBA].[CCCar]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI2]    Script Date: 7/13/2015 1:36:27 PM ******/
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

/****** Object:  Index [CarPX]    Script Date: 7/13/2015 1:36:27 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CarPX] ON [DBA].[Car]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 1:36:27 PM ******/
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

