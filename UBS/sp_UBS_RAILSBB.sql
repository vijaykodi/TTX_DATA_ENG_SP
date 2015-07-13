/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:44:10 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_RAILSBB]    Script Date: 7/13/2015 1:44:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_RAILSBB]
 @BeginIssueDate datetime, 
 @ENDIssueDate datetime

 AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'UBSRSBB'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @BeginIssueDate = @BeginIssuedate
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

--- Delete records that do not have a orderdate with a . as these are header rows.--LOC 9/18/2012
Delete from dba.sbbtemp
where orderdate not like '%.%'

--there is not a field for billing date in the raildata table
--update dba.sbbtemp
--set billingdate = cast(CASE WHEN billingdate IS NOT NULL and billingdate <> ''THEN 
--substring(billingdate,7,4)+'-'+substring(billingdate,4,2)+'-'+substring(billingdate,1,2) 
--      ELSE NULL END AS datetime)

-------Insert into Production Tabel ----------------------------------------------------------------
--1/20/2014 updated substring of order date to convert(datetime,orderdate,103)kp #29923

INSERT INTO DBA.RailData
select cast(CASE WHEN orderdate IS NOT NULL and orderdate <> ''THEN 
CONVERT(datetime,orderdate,103) 
      ELSE NULL END AS datetime)
--substring(orderdate,7,4)+'-'+substring(orderdate,4,2)+'-'+substring(orderdate,1,2) 
--      ELSE NULL END AS datetime)
,substring(DossierNbr,1,20) ,substring(InvoiceNumber,1,20) ,'CH'
,substring(TravelerLastName + ' ' + TravelerFirstName,1,100)
,CASE WHEN UserIDGPN like 'ubs.com%' then substring(UserIDGPN,8,8) else NULL END AS UserIdGPN
,'SBB Rail'
,cast(CASE WHEN departdate IS NOT NULL and departdate <> ''THEN 
CONVERT(datetime,departdate,103)
--substring(departdate,7,4)+'-'+substring(departdate,4,2)+'-'+substring(departdate,1,2) 
      ELSE NULL END AS datetime)
,NULL
,cast(CASE WHEN returndate IS NOT NULL and returndate <> ''THEN 
CONVERT(datetime,returndate,103)
--substring(returndate,7,4)+'-'+substring(returndate,4,2)+'-'+substring(returndate,1,2) 
      ELSE NULL END AS datetime)
,Class,NULL,Origin,Destination,NULL,NULL
,Amount,0,0,0,'CHF'
,CASE WHEN CAST(Amount AS FLOAT) >= 0 THEN 1 ELSE -1 END AS TripCount
,NULL,NULL,NULL,NULL,NULL
,0,0,substring(CostCenter,1,50)
,substring(discount,1,20)--Putting discount here as Reference1 is the cost center
,substring(PersonalNbr,1,20)
,substring(OrderLastName + ' ' + OrderFirstName,1,100)
,NULL,NULL,NULL,Null,substring(description,1,50),@beginissuedate+20,NULL,NULL
from dba.sbbtemp
where dossiernbr not in (select distinct transactionid from dba.raildata)

----- Insert any refunds with -r at the end of the Dossier Number where the Dossier Number 
----- Exists in the rail data table prior to the current load --- LOC/3/1/2013

INSERT INTO DBA.RailData
select cast(CASE WHEN orderdate IS NOT NULL and orderdate <> ''THEN 
CONVERT(datetime,orderdate,103) 
      ELSE NULL END AS datetime)
--substring(orderdate,7,4)+'-'+substring(orderdate,4,2)+'-'+substring(orderdate,1,2) 
--      ELSE NULL END AS datetime)

,substring(DossierNbr,1,20)+'-R' ,substring(InvoiceNumber,1,20) ,'CH'
,substring(TravelerLastName + ' ' + TravelerFirstName,1,100)
,CASE WHEN UserIDGPN like 'ubs.com%' then substring(UserIDGPN,8,8) else NULL END AS UserIdGPN
,NULL
,cast(CASE WHEN departdate IS NOT NULL and departdate <> ''THEN 
CONVERT(datetime,departdate,103)
--substring(departdate,7,4)+'-'+substring(departdate,4,2)+'-'+substring(departdate,1,2) 
      ELSE NULL END AS datetime)
, null

,cast(CASE WHEN returndate IS NOT NULL and returndate <> ''THEN 
CONVERT(datetime,returndate,103)
--substring(returndate,7,4)+'-'+substring(returndate,4,2)+'-'+substring(returndate,1,2) 
      ELSE NULL END AS datetime)
,Class,NULL,Origin,Destination,NULL,NULL
,Amount,0,0,0,'CHF'
,CASE WHEN CAST(Amount AS FLOAT) >= 0 THEN 1 ELSE -1 END AS TripCount
,NULL,NULL,NULL,NULL,NULL
,0,0,substring(CostCenter,1,50)
,substring(discount,1,20)--Putting discount here as Reference1 is the cost center
,substring(PersonalNbr,1,20)
,substring(OrderLastName + ' ' + OrderFirstName,1,100)
,NULL,NULL,NULL,Null,substring(description,1,50),@Beginissuedate+20,NULL,NULL
from dba.SBBTemp
where dossiernbr in (select distinct transactionid from dba.raildata where month < @BeginIssueDate)


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-SBB Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT  TransactionID, 'UBSRSBB', '1', 'UBSRSBB',BookingDate, BookingDate
FROM dba.raildata 
	where transactionid not in
	(SELECT recordkey from dba.comrmks
	where iatanum = 'UBSRSBB')
and POS = 'CH'

-------- Update text 22 with original GPN provided.
update c
set text22 = TravelerGPN
from dba.comrmks c, dba.raildata r
where transactionid = recordkey
and text22 is null and c.iatanum = 'ubsrsbb'

update r
set TravelerGPN = right('00000000'+TravelerGPN,8)
from dba.raildata r
where r.pos = 'CH'
and len(TravelerGPN) <> 8
and TravelerGPN <> 'Unknown'

update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional')
and r.pos = 'CH'


-- Update Remarks2 with Unknown when remarks2 is NULL
update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN is null
and r.pos = 'CH'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update Tex20 with the Traveler Name from the Hierarchy File

update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.raildata r
where e.gpn = r.travelerGPN
and c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRSBB'
--and travelerGPN <> 'Unknown'
and isnull(text20,'x') <> e.paxname


-- Update Text20 to the Traveler Name provided by the Rail Data when GPN not provided or dummy GPN used

update c
set text20 = substring(travelername,1,charindex(' ',travelername,1)-1)+ ','+ 
substring(travelername,charindex(' ',travelername)+1,20)
from dba.comrmks c, dba.raildata r
where c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRSBB'
and ((isnull(c.text20, 'Unknown') = 'Unknown')
	or (c.text20 = ' ')	)
and r.TravelerGPN ='Unknown'
and bookingdate > '6-1-2012'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text 20 Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update Advance Purchase days and group ----------------------------------
--select distinct carriername, transactionid, bookingdate, departdatetime, 
update dba.raildata 
set daysadvpurch = datediff(dd,bookingdate, departdatetime) 
from dba.raildata 
where departdatetime > '1-1-2013'  and carriername = 'SBB Rail'




--Truncate table dba.SBBTemp
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_RAILSBB] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[SBBTemp]    Script Date: 7/13/2015 1:44:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[SBBTemp](
	[DossierNbr] [varchar](50) NULL,
	[OrderDate] [varchar](50) NULL,
	[UserIdGPN] [varchar](50) NULL,
	[OrderLastName] [varchar](50) NULL,
	[OrderFirstName] [varchar](50) NULL,
	[CostCenter] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[Class] [varchar](50) NULL,
	[Discount] [varchar](50) NULL,
	[DepartDate] [varchar](50) NULL,
	[ReturnDate] [varchar](50) NULL,
	[Origin] [varchar](50) NULL,
	[Destination] [varchar](50) NULL,
	[Amount] [varchar](50) NULL,
	[TravelerLastName] [varchar](50) NULL,
	[TravelerFirstName] [varchar](50) NULL,
	[ReferenceText1] [varchar](50) NULL,
	[MwStSatz1] [varchar](50) NULL,
	[BruttoMwSt1] [varchar](50) NULL,
	[MwStSatz2] [varchar](50) NULL,
	[BruttoMwSt2] [varchar](50) NULL,
	[MwStSatz3] [varchar](50) NULL,
	[BruttoMwSt3] [varchar](50) NULL,
	[MwStSatz4] [varchar](50) NULL,
	[BruttoMwSt4] [varchar](50) NULL,
	[PersonalNbr] [varchar](50) NULL,
	[ReferenceText2] [varchar](50) NULL,
	[BillingDate] [varchar](50) NULL,
	[InvoiceNumber] [varchar](50) NULL,
	[Month] [varchar](50) NULL,
	[TruetktCount] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[SBBTemp] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ROLLUP40]    Script Date: 7/13/2015 1:44:15 PM ******/
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

/****** Object:  Table [DBA].[RailData]    Script Date: 7/13/2015 1:44:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[RailData](
	[BookingDate] [datetime] NULL,
	[TransactionId] [varchar](20) NULL,
	[BookingId] [varchar](20) NULL,
	[POS] [varchar](3) NULL,
	[TravelerName] [varchar](100) NULL,
	[TravelerGPN] [varchar](20) NULL,
	[CarrierName] [varchar](50) NULL,
	[DepartDateTime] [datetime] NULL,
	[ArriveDateTime] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[ClassOfService] [varchar](10) NULL,
	[TicketType] [varchar](50) NULL,
	[OriginStation] [varchar](50) NULL,
	[DestStation] [varchar](50) NULL,
	[TicketCategory] [varchar](15) NULL,
	[TicketsIssued] [int] NULL,
	[TotalAmt] [float] NULL,
	[OtherCharges] [float] NULL,
	[DeliveryCharges] [float] NULL,
	[RefundAdminFee] [float] NULL,
	[CurrCode] [varchar](5) NULL,
	[TrueTktCount] [int] NULL,
	[OutboundKMs] [float] NULL,
	[OutboundMiles] [float] NULL,
	[ReturnKMs] [float] NULL,
	[ReturnMiles] [float] NULL,
	[CO2] [float] NULL,
	[Savings] [float] NULL,
	[MissedSavings] [float] NULL,
	[CostCenter] [varchar](50) NULL,
	[Reference1] [varchar](20) NULL,
	[PersonalNbr] [varchar](20) NULL,
	[BookerName] [varchar](100) NULL,
	[TransactionType] [varchar](100) NULL,
	[TISReference] [varchar](15) NULL,
	[CustomerId] [varchar](15) NULL,
	[OpportunityCode] [varchar](50) NULL,
	[ReasonForTravel] [varchar](50) NULL,
	[Month] [datetime] NULL,
	[DaysAdvPurch] [smallint] NULL,
	[AdvPurchGroup] [varchar](10) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[RailData] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:44:31 PM ******/
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

/****** Object:  Table [DBA].[Employee]    Script Date: 7/13/2015 1:44:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Employee](
	[GPN] [varchar](25) NULL,
	[PaxName] [varchar](250) NULL,
	[Status] [varchar](40) NULL,
	[ROLLUP2] [varchar](250) NULL,
	[ROLLUP3] [varchar](250) NULL,
	[ROLLUP4] [varchar](250) NULL,
	[ROLLUP5] [varchar](250) NULL,
	[ROLLUP6] [varchar](250) NULL,
	[ROLLUP7] [varchar](250) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ChangeDate] [datetime] NULL,
	[ROLLUP8] [varchar](250) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Employee] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/13/2015 1:44:36 PM ******/
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

SET ANSI_PADDING ON

GO

/****** Object:  Index [PK_ROLLUP40]    Script Date: 7/13/2015 1:44:57 PM ******/
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

/****** Object:  Index [RD_PX]    Script Date: 7/13/2015 1:44:58 PM ******/
CREATE CLUSTERED INDEX [RD_PX] ON [DBA].[RailData]
(
	[BookingDate] ASC,
	[POS] ASC,
	[TravelerGPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Employee_PX]    Script Date: 7/13/2015 1:44:58 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Employee_PX] ON [DBA].[Employee]
(
	[GPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/13/2015 1:44:58 PM ******/
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

/****** Object:  Index [Rollup40_I*]    Script Date: 7/13/2015 1:44:59 PM ******/
CREATE NONCLUSTERED INDEX [Rollup40_I*] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI1]    Script Date: 7/13/2015 1:44:59 PM ******/
CREATE NONCLUSTERED INDEX [RollupI1] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI2]    Script Date: 7/13/2015 1:45:00 PM ******/
CREATE NONCLUSTERED INDEX [RollupI2] ON [DBA].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Employee_I1]    Script Date: 7/13/2015 1:45:00 PM ******/
CREATE NONCLUSTERED INDEX [Employee_I1] ON [DBA].[Employee]
(
	[GPN] ASC
)
INCLUDE ( 	[PaxName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/13/2015 1:45:01 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

