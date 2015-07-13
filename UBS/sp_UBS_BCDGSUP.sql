/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='payment' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='Invoiceheader' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='tman_UBS']/UnresolvedEntity[@Name='invoicedetail' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='hotel' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='tman_ubs']/UnresolvedEntity[@Name='emea_rc_updates' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='tman_ubs']/UnresolvedEntity[@Name='emea_dataupdates' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='comrmks' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='client' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='tman_UBS']/UnresolvedEntity[@Name='ccticket' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='ccheader' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='car' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='udef' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='transeg' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_ubs']/UnresolvedEntity[@Name='tax' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 12:51:36 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_MAIN]    Script Date: 7/13/2015 12:51:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_UBS_MAIN]
@IATANUM VARCHAR (50),
@BEGINISSUEDATEMAIN DATETIME,
@ENDISSUEDATEMAIN DATETIME

 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBS'
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

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start UBS Main-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------GPN Padding to ensure 8 characters for all -----------------------------------------
update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where len(remarks2) <> 8 and remarks2 <> 'Unknown'
and IATANUM like @IATANUM
and Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='GPN Padding Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 not in (select corporatestructure from dba.rollup40)
and remarks2 <> 'Unknown' 
and IATANUM like @IATANUM

--------Update Reamrks1 with NULL when not in lookuptable .... LOC/12-3-2012
update id
set remarks1 = NULL
from dba.invoicedetail id
where remarks1 not in (select lookupvalue from dba.lookupdata
	where lookupname = 'trippur') and remarks1 is not NULL
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


-------- Update Remarks2 with Unknown when remarks2 is NULL-----------------------------------
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 is null and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Remarks2/GPN Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

--------CAR -- Move remarks values to comrmks -----------------------------------------------------
update c
set text42= remarks1 
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text42 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text43= remarks2 
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text43 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN
 
update c
set text44= remarks3
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text44 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text45= remarks4
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text45 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text46= remarks5
from dba.comrmks c, dba.car car
where c.recordkey = car.recordkey and c.seqnum = car.seqnum and text46 is NULL
 and c.IATANUM like @IATANUM and c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

-------CAR --Null remarks fields ---------------------------------------------------------------
update c
set c.remarks1 = null,c.remarks2 = null,c.remarks3 = null, c.remarks4 = NULL,c.remarks5 = NULL
from dba.car c
where  c.iatanum like @IATANUM AND c.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

--------CAR -- Update remarks from invoicedetail remarks --------------------------------------
update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3, car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car
where i.recordkey = car.recordkey and i.seqnum = car.seqnum and i.iatanum = car.iatanum 
and i.iatanum like @IATANUM and i.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Car remark fields Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- HOTEL --- Copy remarks to Comrmks ------------------------------------------------------
update c
set text37 = remarks1
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text37 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text38 = remarks2
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text38 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text39 = remarks3
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text39 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text40 = remarks4
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text40 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

update c
set text41 = remarks5
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum and c.iatanum = h.iatanum
and  text41 is null 
and  h.iatanum like @IATANUM AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN


--------HOTEL --Null remarks fields  ---------------------------------------------------------------
update h
set h.remarks1 = null, h.remarks2 = null, h.remarks3 = null, h.remarks4 = null ,h.remarks5 = null
from dba.hotel h
where  h.iatanum like @IATANUM
AND h.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

--------HOTEL -- Update remarks from invoicedetail remarks -------------------------------------
update h
set h.remarks1 = i.remarks1,  h.remarks2 = i.remarks2,h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum
and i.iatanum like @IATANUM and i.Invoicedate between @BeginISSUEDATEMAIN and @EndISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Hotel remark fields Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update null carrier code where carrier num exists -------------------------------------
update id
set id.valcarriercode = cr.carriercode
from dba.carriers cr, dba.invoicedetail id
where valcarriernum = carriernumber and valcarriernum is NULL and iatanum like @IATANUM
AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

--------  Update Carrier Names------------------------------------------------------------------
update id
set id.vendorname = cr.carriername
from dba.carriers cr, dba.invoicedetail id
where id.valcarriercode = cr.carriercode and id.vendorname <> cr.carriername and iatanum like @IATANUM
AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update id
set id.segmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.segmentcarriercode = cr.carriercode and id.segmentcarriername <> cr.carriername
and iatanum like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update id
set id.minsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.minsegmentcarriercode = cr.carriercode and id.minsegmentcarriername <> cr.carriername
and iatanum like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update id
set id.noxsegmentcarriername = cr.carriername
from dba.carriers cr, dba.transeg id
where id.noxsegmentcarriercode = cr.carriercode and  id.noxsegmentcarriername <> cr.carriername
and iatanum like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Update Porter Airlines in ID table -----------------------------------------------------
update i
set valcarriercode = 'PD', vendorname = 'PORTER AIRLINES', valcarriernum = '329'
from dba.transeg t, dba.invoicedetail i
where valcarriercode <> 'pd' and segmentcarriercode = 'pd'
and t.recordkey = i.recordkey and t.seqnum = i.seqnum and t.iatanum like @IATANUM
AND i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Carrier Name updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update Text10 with refund value for the Days in Country report------------------------
update c
set text10 = 'Refunded'
from dba.invoicedetail id, dba.invoicedetail  idd, dba.comrmks c
where id.recordkey <> idd.recordkey and id.documentnumber = idd.documentnumber and id.firstname = idd.firstname
and id.lastname = idd.lastname and id.recordkey = c.recordkey and id.seqnum = c.seqnum
and id.refundind = 'N' and idd.refundind = 'Y' and id.iatanum like @IATANUM
AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update c
set text10 = 'Not Refunded'
from dba.comrmks c
where text10 is NULL and iatanum like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text10 Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update Rail Data ------------------------------------------------------------
update dba.invoicedetail
set vendortype = 'RAIL'
where valcarriercode in ('9b','9f','2v','2r','TTL','ES','DB','2A')
and vendortype <>'FEES' and vendortype <>'RAIL' and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.transeg 
set typecode = 'R'
where segmentcarriercode in ('9b','9f','2v','2r','TTL','ES','DB','2A')
and typecode <>'R' and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update i
set vendortype = 'RAIL'
from dba.invoicedetail i, dba.transeg t
where i.recordkey = t.recordkey and i.seqnum = t.seqnum
and typecode = 'R'
and valcarriercode IN('@@','2C','3Y','2A') and segmentcarriercode IN('@@','2C','3Y','2A')
and i.IATANUM like @IATANUM and i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update i
set vendortype = 'RAIL'
from dba.invoicedetail i
where valcarriercode IN('@@','2C','3Y','2A') 
and recordkey not in (select recordkey from dba.transeg)
and i.IATANUM like @IATANUM and i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update t
set segmentcarriercode = '2V'
from dba.transeg t
where segmentcarriername = 'AMTRAK' and segmentcarriercode <>'2v'
and t.IATANUM like @IATANUM and t.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update i
set valcarriercode = segmentcarriercode
from dba.invoicedetail i, dba.transeg t
where valcarriercode = '2v' and i.iatanum <> 'preubs'
and i.recordkey = t.recordkey and i.seqnum = t.seqnum
and segmentcarriercode <>'2v' and segmentcarriername <> 'amtrak'
and i.IATANUM like @IATANUM and i.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Rail updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Update Fees -----------------------------------------------------------------------
update dba.invoicedetail
set vendortype = 'FEES'
where valcarriercode = 'XD'
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

----------Update Text1 with Booker Name from Text8 -------- Not at this time only in PreTrip data
---------- will update once we receive in post trip ------------------------ LOC/6/15/2012
update c
set text1 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text8 = substring(r.description,1,8)
and costructid = 'functional' and text8 is not null and text1 is null
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

----- Update Text2 with Approver Name from GPN value in Text14 ---------------------------- LOC/6/15/2012

update c
set text2 = substring(r.description,charindex('-',r.description)+1,240)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8) and costructid = 'functional'
and text14 is not null and text2 is  null
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

----------------------------------------------------------------------------------
-------Update the comrmks with the Travelers Name from the Hierarchy table provided by UBS.

-------- Transaction updates
-------- Update Text30 with any values in the remarks2 field that are not in the GPN list

update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i
where i.remarks2 not in (select gpn from dba.Employee) and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM like @IATANUM and c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and text30 is null


SET @TransStart = getdate()

--------Update Tex20 with the Traveler Name from the Hierarchy File ---------------------------------
------- Updated query to added the isnull(text20.... <> e.paxname .  This should update any values 
------- in text 20 when the GPN gets updated ... invoicedate can be changed throughout time as
------- as not to use such a large date range.
------- also added the remarks2 value of 000007% as this is another "unknown" gpn value...
update c
set text20 = paxname
from dba.Employee e, dba.comrmks c, dba.invoicedetail i
where e.gpn = i.remarks2
and remarks2 not like '99999%' and remarks2 not like '000007%' 
and c.recordkey = i.recordkey and c.seqnum = i.seqnum  
and c.IATANUM like @IATANUM and c.Invoicedate > '12-31-2012' and isnull(text20,'X') <> e.paxname

-------- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey 
AND C.IATANUM =I.IATANUM
and c.seqnum = i.seqnum  
and (isnull(c.text20, 'Non GPN') like '%Non GPN%'
	or c.text20 = ' ')
and ((i.remarks2 like ('99999%')) or (i.remarks2 like ('11111%'))
or (i.remarks2 ='Unknown'))
and c.IATANUM like @IATANUM and c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Text20 Update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

-------- Per email from Sue Shore on 2/3/2011
--------Updating GPN 00193610 fro Julie Zehnter to 99999997--------------------------------------------------------

update dba.invoicedetail
set remarks2 = '99999997'
where remarks2 = '00193619'

--------Update InvoiceDates to = ID Invoicedate ----------------------
update car
set car.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.car car
where car.invoicedate <> id.invoicedate and car.recordkey = id.recordkey and car.seqnum = id.seqnum
and car.IATANUM like @IATANUM and car.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update hotel
set hotel.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.hotel hotel
where hotel.invoicedate <> id.invoicedate and  hotel.recordkey = id.recordkey and hotel.seqnum = id.seqnum
and hotel.IATANUM like @IATANUM and hotel.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update cr
set cr.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.comrmks cr
where cr.invoicedate <> id.invoicedate and cr.recordkey = id.recordkey and cr.seqnum = id.seqnum
and cr.IATANUM like @IATANUM and cr.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update ts
set ts.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.transeg ts
where ts.invoicedate <> id.invoicedate and ts.recordkey = id.recordkey and ts.seqnum = id.seqnum
and ts.IATANUM like @IATANUM and ts.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update u
set u.invoicedate = id.invoicedate
from dba.invoicedetail id, dba.udef u
where u.invoicedate <> id.invoicedate and u.recordkey = id.recordkey and u.seqnum = id.seqnum
and u.IATANUM like @IATANUM and u.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

--------------------------------------------------------------------
-------- Update issuedates to equal invoicedates --------------------------------------------------
update dba.car
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.comrmks
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.hotel
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.transeg
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.udef
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.invoicedetail
set issuedate = invoicedate
where issuedate <> invoicedate and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Issue/Invoice Date match Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

------------------------------------------------------------------
-------- Update the booking data to the invoice date where null per email
-------- from UBS on 11/11/11. --------------------------------------------------------------------

update dba.invoicedetail
set bookingdate = invoicedate
where bookingdate is null
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

------Update Text5 with the region 
update c
set text5 = rollup2
from dba.rollup40 r, dba.invoicedetail i, dba.comrmks c
where r.corporatestructure = i.remarks2
and i.recordkey = c.recordkey and i.seqnum = c.seqnum
and remarks2 not like ('99999%') and costructid = 'GEO'
and c.IATANUM like @IATANUM and c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update cr
set text5 = 'Europe EMEA'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AT','AE','BE','CZ','FR','DE','HU','IL','IT','LU','NL','PL','RU','ES','SA','SE','CH','TR','GB','ZA')
and isnull(text5,'Unknown') = 'Unknown'

update cr
set text5 = 'Asia Pacific'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('AU','CN','HK','ID','IN','JP','MY','NZ','PH','KR','SG','TW','TH')
and isnull(text5,'Unknown') = 'Unknown'

update cr
set text5 = 'Americas'
from  dba.invoicedetail id, dba.comrmks cr, dba.country c, dba.invoiceheader ih
where  id.recordkey = cr.recordkey and id.seqnum = cr.seqnum
and id.recordkey = ih.recordkey and ih.origcountry = c.ctrycode
and origcountry in ('US','CA','BR') and isnull(text5,'Unknown') = 'Unknown'

--------Update remarks3 with rank code from HRI (rollup40)---------------------- LOC 7/12/2012

update i
set remarks3 = rollup10
from dba.invoicedetail i, dba.rollup40 r
where remarks2 = corporatestructure
and remarks3 is null and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Update any old PNR's where the GPN is not valid any more.  UBS says all GPNS are in the HRI file but we
-------- tend to find a few every month where they were in the list and now they are not so this is to catch
-------- those as they throw off the numbers of some reports ... LOC 7/27/2012
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where remarks2 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and remarks2 <> 'Unknown' and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

------ Update Text17 (TractID) to N/A where the value does not appear to be a TractID.---LOC /7/31/2012---
update c
set Text17 = 'N/A'
from dba.comrmks c
where isnull(c.Text17,'X') like '%' and not ((c.Text17  like '[1-9][0-9][0-9][0-9][0-9]') or 
(c.Text17 like '[1-9][0-9][0-9][0-9][0-9][0-9]') 
or(c.text17 like '[0-9][0-9][A-Z][A-Z][A-Z][1-9][0-9]')
or (c.Text17 = 'O') or (c.text17 = 'A')) 
and c.Text17 <> 'N/A'
and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

Update c
set Text17 = 'N/A'
from dba.comrmks c
where Text17 is null and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

Update c
set Text17 = 'N/A'
from dba.comrmks c
where Text17 in ('11111','111111') and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Booker GPN Validation ---When NULL------------------LOC/8/3/2012
update c
set text8 = 'Not Provided'
from dba.comrmks c
where  text8 is NULL and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Booker GPN Validation ----When Invalid-----------------LOC/8/3/2012
update c
set text8 = 'Not Valid'
from dba.comrmks c
where text8 <> 'Not Provided'
and text8 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and IATANUM like @IATANUM and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Approver GPN Validation ------When Null---------------LOC/8/3/2012
update c
set text14 = 'Not Provided'
from dba.comrmks c
where text14 is NULL and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

---------- Approver GPN Validation -----When Invalid----------------LOC/8/3/2012
update c
set text14 = 'Not Valid'
from dba.comrmks c
where text14 <> 'Not Provided'
and text14 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and IATANUM like @IATANUM
and Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Begin Delete/Insert',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update hotel and car dupe flags to N incase of data reload or changes .. LOC/4/23/2013
update dba.hotel set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and IATANUM like @IATANUM
update dba.car set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010' and IATANUM like @IATANUM


SET @TransStart = getdate()
-------- Update hotel dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.hotel First , dba.hotel Second
where First.IATANUM like @IATANUM and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator and First.htlConfNum = Second.htlConfNum
and First.IssueDate < Second.Issuedate and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and datediff(dd,first.checkindate,second.checkindate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.invoicedate > '12-31-2010'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel Dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
-------- Update Car dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.car First , dba.car Second
where First.IATANUM like @IATANUM and First.Iatanum = Second.Iatanum
and First.gdsrecordlocator = Second.gdsrecordlocator and First.CarConfNum = Second.CarConfNum
and First.IssueDate < Second.Issuedate and First.Recordkey <> Second.Recordkey
and First.ClientCode = Second.ClientCode
and datediff(dd,first.pickupdate,second.pickupdate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.invoicedate > '12-31-2010'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--- Update product type to be consistant... LOC/12/4/2012
update dba.invoicedetail
set producttype = Case when producttype = 'Air' then 'AIR' 
when producttype = 'Hotel' then 'HOTEL'
when producttype = 'Misc' then 'MISC'
when producttype = 'Rail' then 'RAIL'
end 

-------- Update Num1 with htlcomparerate2 from TMC data so that we can use this field for
	---- hotel rates in local currency ------ LOC/11/2/2012
update c
set num1 = htlcomparerate2
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey and c.seqnum = h.seqnum
and num1 is null
and c.IATANUM like @IATANUM
AND c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

update dba.hotel
set htlcomparerate2 = NULL
where htlcomparerate2 is not NULL
and IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Move document number to Text4 where length is greater than 10 .. LOC/5/28/2013
update c
set text4 = documentnumber
from dba.comrmks c, dba.invoicedetail id
where c.recordkey = id.recordkey  and c.seqnum = id.seqnum
and len(documentnumber) > 10 and id.iatanum <> 'preubs' and id.recordkey = c.recordkey
and c.IATANUM like @IATANUM
AND c.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

-------- Update document number to first 10 of dataprovided where match is made to cc data...LOC/5/28/2013
update id
set documentnumber = substring(documentnumber,1,10)
from TTXPASQL01.tman_UBS.dba.invoicedetail id, TTXPASQL01.tman_UBS.dba.ccticket cct
where len(documentnumber) > 10
and id.iatanum <> 'preubs' and id.iatanum like 'ubsbcd%'
and vendortype in ('bsp','nonbsp') and substring(documentnumber,1,10) = ticketnum 
and substring(passengername,1,5) = substring((lastname+'/'+firstname),1,5)
and matchedrecordkey is null

-------- Manual updates to be processed ------- these come from UBS and are run each month
-------- as both BCD and CWT data get over written ---- LOC 6/26/2013

update i
set remarks2 = (cast(correctgpn as decimal(2000))) 
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where i.recordkey = d.recordkey and iatanum like 'ubsbcd%'

update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where len(remarks2) <> 8 and remarks2 <> 'Unknown' and iatanum like 'ubsbcd%'

update h
set remarks2 = (cast(correctgpn as decimal(2000))) 
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where h.recordkey = d.recordkey and iatanum like 'ubsbcd%'

update h
set remarks2 = right('00000000'+Remarks2,8)
from dba.hotel h
where len(remarks2) <> 8 and remarks2 <> 'Unknown' and iatanum like 'ubsbcd%'

update c
set remarks2 = (cast(correctgpn as decimal(2000))) 
from dba.car c, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where c.recordkey = d.recordkey and iatanum like 'ubsbcd%'

update c
set remarks2 = right('00000000'+Remarks2,8)
from dba.car c
where len(remarks2) <> 8 and remarks2 <> 'Unknown' and iatanum like 'ubsbcd%'

update c 
set text20 = paxname 
from dba.Employee e, 
dba.comrmks c, 
dba.invoicedetail i 
where e.gpn = i.remarks2 
and remarks2 not like ('99999%') and remarks2 not like '000007%'
and c.recordkey = i.recordkey 
and c.seqnum = i.seqnum 
and c.IATANUM like @IATANUM 
and c.invoicedate > '1-1-2013' and c.text20 <> e.paxname

update i
set reasoncode1 = [air reason code]
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where i.recordkey = d.recordkey 
and [air reason code] is not null

update c
set text14 = [approver]
from dba.comrmks c, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where c.recordkey = d.recordkey 
and approver is not null

update c
set text2 = [approver name]
from dba.comrmks c, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where c.recordkey = d.recordkey 
and [approver name] is not null

update h
set htlreasoncode1 = htlreasoncode
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_dataupdates d
where h.recordkey = d.recordkey 
and htlreasoncode is not null

--------- Updates to EMEA Reason Codes ----- LOC/9/19/2013
update i
set reasoncode1 = newairrc
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where i.recordkey = r.recordkey and i.seqnum = r.seqnum and newairrc is not null

update r
set lastupdate = getdate()
from dba.invoicedetail i, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where i.recordkey = r.recordkey and i.seqnum = r.seqnum and newairrc is not null

update h
set htlreasoncode1 = newhtlrc
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where h.recordkey = r.recordkey and h.seqnum = r.seqnum and newhtlrc is not null

update r
set lastupdate = getdate()
from dba.hotel h, TTXPASQL01.tman_ubs.dba.emea_rc_updates r
where h.recordkey = r.recordkey and h.seqnum = r.seqnum and newhtlrc is not null


-------- Update TrackID from Pre Trip where mising or invalid ----- LOC/7/9/2013
update c2
set c2.text17 = c1.text17
from TTXPASQL01.TMAN_UBS.dba.comrmks c1, dba.comrmks c2, 
	 TTXPASQL01.TMAN_UBS.dba.invoicedetail i1, dba.invoicedetail i2
where c1.recordkey = i1.recordkey and c1.seqnum = i1.seqnum and c1.iatanum ='preubs'
and c2.recordkey = i2.recordkey and c2.seqnum = i2.seqnum and c2.iatanum like 'ubsbcd%'
and i1.documentnumber= i2.documentnumber and i1.gdsrecordlocator = i2.gdsrecordlocator
and c1.text17 <> 'N/A' and c2.text17 = 'N/A'
and c1.invoicedate > '1-1-2013' and c1.text17 not like '1111%'
and i1.lastname = i2.lastname

-------- Update the min and nox segment mileage where it is negative when it should be positive.
-------- This is happening throught the .dll and is occuring with exchanges.  -- This is affecting
-------- the UBS Segment Mileage reports ----- LOC/9/27/2013
update t
set  noxsegmentmileage = noxsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and noxsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'

update t
set  minsegmentmileage = minsegmentmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and minsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'

update i
set  mileage = mileage*-1
from dba.invoicedetail i
where i.mileage <0 
and i.invoicedate > '1-1-2012' and i.exchangeind = 'y'

-------- Update Hotel and Car Remakrs2 where not = to Invoicedetail Remarks2
update h set h.remarks2 = i.remarks2
from dba.hotel h, dba.invoicedetail i
where h.recordkey = i.recordkey and h.seqnum = i.seqnum
and h.remarks2 <> i.remarks2
and h.invoicedate > '1-1-2013' and i.iatanum <> 'preubs'

update c set c.remarks2 = i.remarks2
from dba.car c, dba.invoicedetail i
where c.recordkey = i.recordkey and c.seqnum = i.seqnum
and c.remarks2 <> i.remarks2
and c.invoicedate > '1-1-2013' and i.iatanum <> 'preubs'


---DELETE -- INSERT -- TO TABLES

delete TTXPASQL01.TMAN_ubs.dba.Invoiceheader
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN


delete TTXPASQL01.TMAN_ubs.dba.Invoicedetail
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.payment
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.tax
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.transeg
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.comrmks
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.car
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.hotel
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

delete TTXPASQL01.TMAN_ubs.dba.udef
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Delete Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()


----------------------------- INSERT  ---------------------------------------------------
insert into TTXPASQL01.TMAN_ubs.dba.Invoiceheader
SELECT *
from DBA.Invoiceheader
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_UBS.dba.Invoiceheader
WHERE IATANUM like @IATANUM
AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)


insert into TTXPASQL01.TMAN_UBS.dba.Invoicedetail
SELECT *
from DBA.Invoicedetail
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_UBS.dba.Invoicedetail
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_UBS.dba.Transeg
SELECT  *
from DBA.Transeg
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_UBS.dba.Transeg
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.Payment
SELECT *
from DBA.Payment
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.Payment
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)


insert into TTXPASQL01.TMAN_ubs.dba.Tax
SELECT *
from DBA.Tax
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN 
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.Tax 
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.car
SELECT *
from DBA.car
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.car
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)


insert into TTXPASQL01.TMAN_ubs.dba.hotel
SELECT *
from DBA.hotel
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.hotel
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.udef
SELECT *
from DBA.udef
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.udef
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.comrmks
SELECT *
from DBA.comrmks
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN
and recordkey not in(select recordkey from TTXPASQL01.TMAN_ubs.dba.comrmks
WHERE IATANUM like @IATANUM AND Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN)

insert into TTXPASQL01.TMAN_ubs.dba.client
SELECT *
from DBA.client
WHERE IATANUM like @IATANUM AND clientcode+iatanum not in(select clientcode+iatanum
from TTXPASQL01.TMAN_ubs.dba.client)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Insert Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
update cct
set cct.matchedrecordkey = id.recordkey, cct.matchediatanum = id.iatanum, cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum <> 'preubs'
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(25)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,5) = substring(passengername,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
and id.IATANUM like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cch
set cch.matchedrecordkey = id.recordkey, cch.matchediatanum = id.iatanum, cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum <> 'preubs'
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(25)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,5) = substring(passengername,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
and id.IATANUM like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update id
set id.matchedind = '2'
from TTXPASQL01.TMAN_UBS.dba.invoicedetail id, TTXPASQL01.TMAN_UBS.dba.ccticket cct, TTXPASQL01.TMAN_UBS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' and id.iatanum <> 'preubs'
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(25)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,5) = substring(passengername,1,5)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and cct.valcarriercode = id.valcarriercode
and id.IATANUM like @IATANUM AND id.Invoicedate between @BEGINISSUEDATEMAIN and @ENDISSUEDATEMAIN

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='UBS Main SP Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 




















GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_MAIN] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_UBS_BCDGSUP]    Script Date: 7/13/2015 12:51:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_BCDGSUP]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime

 AS
 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
--- This stored procedure is used when suplemental data is received from BCD from the Global data ----- 

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate
FROM dba.InvoiceDetail 
	where recordkey+iatanum+convert(varchar,seqnum) not in
	(SELECT recordkey+iatanum+convert(varchar,seqnum) from dba.comrmks
	where Invoicedate between @BeginIssueDate and @EndIssueDate
	 and iatanum = 'UBSBCDEU')
AND Invoicedate between @BeginIssueDate and @EndIssueDate
and iatanum = 'UBSBCDEU'

-- Move data from remarks 1,2,3,4,5 to text 32,33,34,35,36
update c
set c.text32 = i.remarks1,
	c.text33 = i.remarks2,
	c.text34 = i.remarks3,
	c.text35 =  i.remarks4,
	c.text36 = i.remarks5
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.iatanum = 'UBSBCDEU' 
and text32 is null and text33 is null and text34 is null and text35 is null and text36 is null
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

-- Null Remarks 1,2,3,4,5

update i
set i.remarks1 = null, i.remarks2 = null,i.remarks3 = null,i.remarks4 = null,i.remarks5 = null
from dba.invoicedetail i, dba.comrmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

--Update Remarks2 with GPN -- Non US
update i
set i.remarks2 = ud.udefdata
from dba.invoicedetail i, dba.udef ud, dba.invoiceheader ih
where i.recordkey = ih.recordkey
and i.recordkey = ud.recordkey
and i.seqnum = ud.seqnum
and i.iatanum = 'UBSBCDEU'
and ud.iatanum = 'UBSBCDEU'
and ud.udefnum = 2
and ih.origcountry <> 'US'
and isnull(i.remarks2,'Unknown') = 'Unknown'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

--- Set Remarks1 in invoicedetail to have the Trip Purpose code from Udef

update id
set remarks1 =  udefdata
from dba.invoicedetail id, dba.udef u, dba.invoiceheader ih
where id.recordkey = u.recordkey
and id.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and u.udefnum = '6'
and ih.origcountry <> 'US'
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate



--- Set Remarks3 in invoicedetail to have the Rank code from Udef for Non US

update id
set remarks3 =  udefdata
from dba.invoicedetail id, dba.udef u, dba.invoiceheader ih
where id.recordkey = u.recordkey
and id.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and u.udefnum = '5'
and ih.origcountry <> 'US'
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate


-- Set Remarks5 to Cost Center for EU
update id
set remarks5 = udefdata
from dba.invoicedetail id, dba.udef u, dba.invoiceheader ih
where id.recordkey = u.recordkey
and id.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and u.udefnum = '1'
and ih.origcountry <> 'US'
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate


-- Update value of ReasonCode3 to ReasonCode1
update c
set text47 = i.reasoncode1
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey
and c.seqnum = i.seqnum
and c.text47 is null
and i.iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate


update i
set reasoncode1 = NULL
from dba.invoicedetail i
where iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate


update i
set reasoncode1 = reasoncode3
from dba.invoicedetail i
where iatanum = 'UBSBCDEU'
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate

-- Set ReasonCode1 where value is FS to A1
update i
set reasoncode1 = 'A1'
from dba.invoicedetail i
where iatanum = 'UBSBCDEU'
and reasoncode1 in('FS','RB','XX')
AND i.Invoicedate between @BeginIssueDate and @EndIssueDate


----Update HtlReasonCode1 to HtlReasonCode2

update c
set text48 = h.htlreasoncode1
from dba.comrmks c, dba.hotel h
where c.recordkey = h.recordkey
and c.seqnum = h.seqnum
and c.text48 is null
and h.iatanum = 'UBSBCDEU'
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate


update h
set htlreasoncode1 = NULL
from dba.hotel h
where iatanum = 'UBSBCDEU'
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate


update h
set htlreasoncode1 = htlreasoncode2
from dba.hotel h
where iatanum = 'UBSBCDEU'
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate

--- Update text 14 with approver

update c
set text14 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'UBSBCDEU'
AND UDEFNUM = '8'
AND c.Invoicedate between @BeginIssueDate and @EndIssueDate

--- Update MCO Fees specific to BCDEU

update i
set vendortype = 'MCO'
from dba.invoicedetail i
where substring(documentnumber,1,3) ='907'
and vendortype <> 'FEES'
and servicedescription like ('%MCO%')
and IATANUM = 'UBSBCDEU'
AND Invoicedate between @BeginIssueDate and @EndIssueDate

-- Online Booking System Mapping --
update i
set onlinebookingsystem =  invoicetypedescription
from dba.invoicedetail i
where invoicetypedescription = 'Online' 
and iatanum = 'UBSBCDEU'
AND Invoicedate between @BeginIssueDate and @EndIssueDate


---- Change Iatanum to UBSBCDUSif data received from UBSBCDEU for BR and UY orig country.

update ih
set iatanum = 'UBSBCDUS'
from dba.invoiceheader ih
where iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND ih.Invoicedate between @BeginIssueDate and @EndIssueDate


update id
set id.iatanum = 'UBSBCDUS'
from dba.invoicedetail id, dba.invoiceheader ih
where id.recordkey = ih.recordkey
and id.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND id.Invoicedate between @BeginIssueDate and @EndIssueDate

update h
set h.iatanum = 'UBSBCDUS'
from dba.hotel h, dba.invoiceheader ih
where h.recordkey = ih.recordkey
and h.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND h.Invoicedate between @BeginIssueDate and @EndIssueDate

update c
set c.iatanum = 'UBSBCDUS'
from dba.car c, dba.invoiceheader ih
where c.recordkey = ih.recordkey
and c.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND c.Invoicedate between @BeginIssueDate and @EndIssueDate

update t
set t.iatanum = 'UBSBCDUS'
from dba.tax t, dba.invoiceheader ih
where t.recordkey = ih.recordkey
and t.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND t.Invoicedate between @BeginIssueDate and @EndIssueDate

update p
set p.iatanum = 'UBSBCDUS'
from dba.payment p, dba.invoiceheader ih
where p.recordkey = ih.recordkey
and p.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND p.Invoicedate between @BeginIssueDate and @EndIssueDate

update ts
set ts.iatanum = 'UBSBCDUS'
from dba.transeg ts, dba.invoiceheader ih
where ts.recordkey = ih.recordkey
and ts.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND ts.Invoicedate between @BeginIssueDate and @EndIssueDate

update u
set u.iatanum = 'UBSBCDUS'
from dba.udef u, dba.invoiceheader ih
where u.recordkey = ih.recordkey
and u.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND u.Invoicedate between @BeginIssueDate and @EndIssueDate

update cr
set cr.iatanum = 'UBSBCDUS'
from dba.comrmks cr, dba.invoiceheader ih
where cr.recordkey = ih.recordkey
and cr.iatanum = 'UBSBCDEU'
and origcountry in ('BR','UY')
AND cr.Invoicedate between @BeginIssueDate and @EndIssueDate




EXEC SP_UBS_MAIN
@IATANUM =  'UBSBCDEU',
@BEGINISSUEDATEMAIN= @BEGINISSUEDATE,
@ENDISSUEDATEMAIN = @ENDISSUEDATE

/************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  


































GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_BCDGSUP] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ROLLUP40]    Script Date: 7/13/2015 12:51:39 PM ******/
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

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 12:52:02 PM ******/
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

/****** Object:  Table [DBA].[Payment]    Script Date: 7/13/2015 12:52:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Payment](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[PaymentSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[CurrCode] [varchar](3) NULL,
	[PaymentAmt] [float] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Payment] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[LookupData]    Script Date: 7/13/2015 12:52:13 PM ******/
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

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/13/2015 12:52:14 PM ******/
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

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 12:52:23 PM ******/
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

/****** Object:  Table [DBA].[Hotel]    Script Date: 7/13/2015 12:52:51 PM ******/
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

/****** Object:  Table [DBA].[Employee]    Script Date: 7/13/2015 12:53:12 PM ******/
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

/****** Object:  Table [DBA].[Currency]    Script Date: 7/13/2015 12:53:17 PM ******/
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

/****** Object:  Table [DBA].[Country]    Script Date: 7/13/2015 12:53:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Country](
	[CtryCode] [varchar](5) NULL,
	[CtryName] [varchar](25) NULL,
	[IntlDomCode] [varchar](1) NULL,
	[ContinentCode] [varchar](2) NULL,
	[PhnCode] [varchar](4) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[TSLATEST] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Country] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/13/2015 12:53:23 PM ******/
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

/****** Object:  Table [DBA].[Client]    Script Date: 7/13/2015 12:53:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Client](
	[ClientCode] [varchar](15) NULL,
	[IataNum] [varchar](8) NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[State] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[CustPhone] [varchar](20) NULL,
	[CountryCode] [varchar](5) NULL,
	[AttnLine] [varchar](40) NULL,
	[Email] [varchar](80) NULL,
	[ConsolidationCode] [varchar](50) NULL,
	[ClientRemark1] [varchar](255) NULL,
	[ClientRemark2] [varchar](255) NULL,
	[ClientRemark3] [varchar](255) NULL,
	[ClientRemark4] [varchar](255) NULL,
	[ClientRemark5] [varchar](255) NULL,
	[ClientRemark6] [varchar](255) NULL,
	[ClientRemark7] [varchar](255) NULL,
	[ClientRemark8] [varchar](255) NULL,
	[ClientRemark9] [varchar](255) NULL,
	[ClientRemark10] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Carriers]    Script Date: 7/13/2015 12:53:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Carriers](
	[CarrierCode] [varchar](3) NOT NULL,
	[TypeCode] [char](1) NOT NULL,
	[Status] [char](1) NOT NULL,
	[CarrierName] [varchar](50) NOT NULL,
	[CarrierNumber] [smallint] NOT NULL,
 CONSTRAINT [PK_Carriers] PRIMARY KEY CLUSTERED 
(
	[CarrierCode] ASC,
	[TypeCode] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Carriers] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Car]    Script Date: 7/13/2015 12:53:54 PM ******/
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

/****** Object:  Table [DBA].[Udef]    Script Date: 7/13/2015 12:54:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Udef](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[UdefNum] [smallint] NOT NULL,
	[UdefType] [varchar](20) NULL,
	[UdefData] [varchar](255) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Udef] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[TranSeg]    Script Date: 7/13/2015 12:54:12 PM ******/
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

/****** Object:  Table [DBA].[Tax]    Script Date: 7/13/2015 12:54:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Tax](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[TaxSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[TaxId] [varchar](10) NULL,
	[TaxAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Tax] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PK_ROLLUP40]    Script Date: 7/13/2015 12:54:23 PM ******/
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

/****** Object:  Index [PaymentI1]    Script Date: 7/13/2015 12:54:24 PM ******/
CREATE CLUSTERED INDEX [PaymentI1] ON [DBA].[Payment]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [LookupDataI1]    Script Date: 7/13/2015 12:54:25 PM ******/
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

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/13/2015 12:54:25 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 12:54:26 PM ******/
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

/****** Object:  Index [HotelI1]    Script Date: 7/13/2015 12:54:26 PM ******/
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

/****** Object:  Index [Employee_PX]    Script Date: 7/13/2015 12:54:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Employee_PX] ON [DBA].[Employee]
(
	[GPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CurrencyPX]    Script Date: 7/13/2015 12:54:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CurrencyPX] ON [DBA].[Currency]
(
	[BaseCurrCode] ASC,
	[CurrCode] ASC,
	[CurrBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/13/2015 12:54:27 PM ******/
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

/****** Object:  Index [ClientPX]    Script Date: 7/13/2015 12:54:27 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ClientPX] ON [DBA].[Client]
(
	[IataNum] ASC,
	[ClientCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/13/2015 12:54:28 PM ******/
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

/****** Object:  Index [UdefI1]    Script Date: 7/13/2015 12:54:28 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [DBA].[Udef]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/13/2015 12:54:29 PM ******/
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

/****** Object:  Index [TaxI1]    Script Date: 7/13/2015 12:54:29 PM ******/
CREATE CLUSTERED INDEX [TaxI1] ON [DBA].[Tax]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Rollup40_I*]    Script Date: 7/13/2015 12:54:29 PM ******/
CREATE NONCLUSTERED INDEX [Rollup40_I*] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI1]    Script Date: 7/13/2015 12:54:29 PM ******/
CREATE NONCLUSTERED INDEX [RollupI1] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI2]    Script Date: 7/13/2015 12:54:29 PM ******/
CREATE NONCLUSTERED INDEX [RollupI2] ON [DBA].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [PaymentI2]    Script Date: 7/13/2015 12:54:29 PM ******/
CREATE NONCLUSTERED INDEX [PaymentI2] ON [DBA].[Payment]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PaymentPX]    Script Date: 7/13/2015 12:54:30 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [PaymentPX] ON [DBA].[Payment]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/13/2015 12:54:30 PM ******/
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

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/13/2015 12:54:30 PM ******/
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

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/13/2015 12:54:31 PM ******/
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

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/13/2015 12:54:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/13/2015 12:54:31 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 12:54:31 PM ******/
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

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 12:54:32 PM ******/
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

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 12:54:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 12:54:32 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 12:54:32 PM ******/
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

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 12:54:34 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 12:54:34 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 12:54:35 PM ******/
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

/****** Object:  Index [HotelI2]    Script Date: 7/13/2015 12:54:35 PM ******/
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

/****** Object:  Index [HotelI3]    Script Date: 7/13/2015 12:54:36 PM ******/
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

/****** Object:  Index [HotelPX]    Script Date: 7/13/2015 12:54:37 PM ******/
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

/****** Object:  Index [Employee_I1]    Script Date: 7/13/2015 12:54:37 PM ******/
CREATE NONCLUSTERED INDEX [Employee_I1] ON [DBA].[Employee]
(
	[GPN] ASC
)
INCLUDE ( 	[PaxName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CurrencyI1]    Script Date: 7/13/2015 12:54:37 PM ******/
CREATE NONCLUSTERED INDEX [CurrencyI1] ON [DBA].[Currency]
(
	[BaseCurrCode] ASC,
	[CurrBeginDate] ASC
)
INCLUDE ( 	[CurrCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CountryPX]    Script Date: 7/13/2015 12:54:38 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CountryPX] ON [DBA].[Country]
(
	[CtryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/13/2015 12:54:39 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI2]    Script Date: 7/13/2015 12:54:39 PM ******/
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

/****** Object:  Index [CarPX]    Script Date: 7/13/2015 12:54:40 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CarPX] ON [DBA].[Car]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/13/2015 12:54:41 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [DBA].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/13/2015 12:54:41 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [DBA].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/13/2015 12:54:42 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [DBA].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TaxI4]    Script Date: 7/13/2015 12:54:42 PM ******/
CREATE NONCLUSTERED INDEX [TaxI4] ON [DBA].[Tax]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TaxPX]    Script Date: 7/13/2015 12:54:42 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TaxPX] ON [DBA].[Tax]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[TaxSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 12:54:43 PM ******/
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

