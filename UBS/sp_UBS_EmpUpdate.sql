/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:25:50 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_GPN_Updates_All]    Script Date: 7/13/2015 1:25:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GPN_Updates_All]
@RequestName varchar(50) = NULL --For DEA
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'GPNUPDATE'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--=================================
--Added by rcr  07/08/2015
--Adding variables for logging.
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare 
--@Iata varchar(50)
--, @ProcName varchar(50)
--, @TransStart datetime
--, @BeginIssueDate datetime
--, @ENDIssueDate datetime
@LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(50)

--SET @Iata = ''
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------

--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 ----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
/************************************************************************
	LOGGING_START - END
************************************************************************/ 

-------- This stored procedure is used to run blanket GPN updates when needed due to hierarchy changes.
-------- This is set to update Pre Trip data and Back Office data.  No IATANUMs used in updating.
-------- The process below updates the dba.invoicedetail Remarks2, dba.hotel.remarks2, dba.car.remarks2, dba.raildata.gpn
-------- dba.comrmks.text20 and dba.comrmks.text30 fields.  Text30 should not need updating but leaving in just in case.
--******** This SP is set to look back 1 year from the invoicedate.  Change if necessary---------------------------------
-------- Created 5/14/2015...LOC

--Added by rcr  07/08/2015
WAITFOR DELAY '00:00.30' 
SET @TransStart = Getdate() 
--
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-GPN UPdate StartStart',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 ----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-GPN UPdate StartStart'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


--#690578 Update Remarks 2 with UDEF values for each POSTTrip PCC if now in rollup40 where it was not previously
--KP 6/8/2015
--BCD


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update i
set remarks2=udefdata
from dba.invoicedetail i, dba.udef ud, dba.invoiceheader ih
where i.recordkey = ih.recordkey
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum
and i.iatanum like 'UBSBCD%' and ud.iatanum like 'UBSBCD%'
and ud.udefnum = '2' and i.remarks2= 'Unknown'
and ud.UdefData not like '99999%'
and UdefData in (select corporatestructure from dba.rollup40 where costructid='functional')
and i.invoicedate > getdate() -365

 ----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') remarks2=udefdata -- like UBSBCD% and ud.iatanum like UBSBCD%'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
--Maritz
update i
set i.remarks2 = ud.udefdata
from dba.invoicedetail i, dba.udef ud
where i.iatanum = 'UBSMARUS' and ud.iatanum = 'UBSMARUS' and ud.udefnum = 91 
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum 
and i.remarks2 = 'Unknown'
and UdefData in (select corporatestructure from dba.rollup40 where costructid='functional')
and i.invoicedate > getdate() -365
 ----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') i.remarks2 = ud.udefdata  -- UBSMARUS and ud.iatanum = UBSMARUS'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
--Morley
update i
set i.remarks2=u.udefdata
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'UBSMORUS' and u.iatanum = 'UBSMORUS'and u.udefnum = 1
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.remarks2 = 'Unknown'
and u.UdefData not like '99999%'
and UdefData in (select corporatestructure from dba.rollup40 where costructid='functional')
and i.invoicedate > getdate() -365
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') i.remarks2 = ud.udefdata  -- UBSMORUS and u.iatanum = UBSMORUS'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
------- CWT Set remarks2 to GPN
update i
set i.remarks2 = substring(ud.udefdata,1,8)
from dba.invoicedetail i, dba.udef ud
where i.iatanum = 'UBSCWT' and ud.udefnum = 3
and substring(ud.udefdata,1,8) in (select corporatestructure 
	from dba.rollup40 where costructid = 'functional')
and i.recordkey = ud.recordkey and i.seqnum = ud.seqnum
and i.remarks2='unknown'
and i.invoicedate > getdate() -365
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') i.remarks2 = substring(ud.udefdata,1,8)  -- iatanum = UBSCWT'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	



--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
--ck with Lisa
--Reports are pulling OrigGPN from ComRmks.Text22
--Morley and Maritz procedures save original GPN from Remarks2 to Text33
--This step will update text22 if a numeric gpn and not in corporate structure
update cr
set text22=TEXT33
--select id.issuedate,Text33,TEXT22
from dba.ComRmks cr,
DBA.InvoiceDetail ID
Where cr.iatanum IN ('UBSMARUS','UBSMORUS') 
and cr.recordkey = Id.recordkey and cr.seqnum = Id.seqnum 
and id.VendorType in ('bsp','nonbsp')
and isnumeric(text33)=1
and cr.invoicedate > ='2015-01-01'
and text22 is null 

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Remarks2 update from UDEF'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--=====
--Next line commented out -- rcr 07/08/2015		
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Remarks2 update from UDEF',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
-- Update Text30 with any values in the remarks2 field that are not in the GPN list.  Back up and used in Data Validation
update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i
where i.remarks2 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and c.recordkey = i.recordkey and c.IataNum = i.IataNum and c.seqnum = i.seqnum   
and c.Text30 is null and i.invoicedate > getdate() -365

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') text30 = remarks2'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where i.remarks2 like '999999%'
and c.recordkey = i.recordkey and c.IataNum = i.IataNum and c.seqnum = i.seqnum    
and c.Text30 is null and i.invoicedate > getdate() -365

--=====
--Next 2 lines commented out -- rcr 07/08/2015
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text30 Updates Complete',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Text30 Updates Complete'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
------------- Update those not in the HRI to Unknown -----------------------------------------------------
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i
where isnull(i.Remarks2,'x') not in (select corporatestructure from dba.rollup40 where costructid = 'functional') 
and i.invoicedate > getdate() -365
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ID.Remarks2 Updates Complete'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	
---------- Update Remakrs2 to GPN where it was previously set to Unknown -----------------------------------
--------- commenting out due to updates Kara made per datafeed -- this can be removed when proved not needed.
--update i
--set remarks2 = corporatestructure
--from dba.invoicedetail i, dba.rollup40 u, dba.comrmks c
--where i.recordkey = c.recordkey and i.IataNum  = c.IataNum and i.ClientCode = c.ClientCode
--and i.IssueDate = c.IssueDate and i.SeqNum = c.SeqNum and u.COSTRUCTID = 'functional' 
--and c.Text30 = corporatestructure  and i.Remarks2 = 'Unknown' 
--and i.invoicedate > getdate() -365

--=====
--Next 2 lines commented out -- rcr 07/08/2015
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ID.Remarks2 Updates Complete',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
-------- Update dba.hotel.remarks2 to match dba.invoicedetail.remarks2 -----------------------------------
update h 
set h.remarks2 = i.remarks2
from dba.hotel h, dba.invoicedetail i
where h.recordkey = i.recordkey and h.seqnum = i.seqnum
and isnull(h.remarks2,'XX') <> i.remarks2
and i.invoicedate > getdate() -365
and i.iatanum <> 'preubs'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update dba.hotel.remarks2 to match dba.invoicedetail.remarks2'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
-------- Update dba.car.remarks2 to match dba.invoicedetail.remarks2 -----------------------------------
update c 
set c.remarks2 = i.remarks2
from dba.car c, dba.invoicedetail i
where c.recordkey = i.recordkey and c.seqnum = i.seqnum
and isnull(c.remarks2,'XX') <> i.remarks2
and i.invoicedate > getdate() -365 and i.iatanum <> 'preubs'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') c.h.Remraks2 Updates Complete'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--=====
--Next 2 lines commented out -- rcr 07/08/2015
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='c.h.Remraks2 Updates Complete',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
--ck with Lisa for other iatanums
--ck with Lisa for '00001234' gnps
-------- Update dba.comrmks.text20 with the HRI name when GPN present in HRI and not generic------------
update c
set c.text20 = substring(e.paxname,1,150)
from dba.employee e, dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey  and c.IataNum = i.IataNum and c.seqnum = i.seqnum  
and e.gpn = i.remarks2  and (i.remarks2 not like ('99999%') or i.Remarks2 <> 'Unknown')
and c.text20 <> substring(e.paxname,1,150)
and i.invoicedate > getdate() -365

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') c.text20 = substring(e.paxname,1,150)'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
-------- Update dba.comrmks.text20 to TMC provided name when GPN is not present in HRI or is Generic----
update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i
where c.recordkey = i.recordkey  AND C.IATANUM =I.IATANUM  and c.seqnum = i.seqnum  
and c.ClientCode = i.ClientCode and c.IssueDate = i.IssueDate
and (isnull(c.text20, 'Non GPN') like '%Non GPN%' 	or c.text20 = '')
and ((i.remarks2 like ('99999%')) or (i.remarks2 like ('000007%'))
or (i.remarks2 ='Unknown'))
and text20 <> (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
and i.invoicedate > getdate() -365

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Text20 Updates Complete'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--=====
--Next 2 lines commented out -- rcr 07/08/2015
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text20 Updates Complete',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====



--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
-------- Update dba.raildata -----------------------------------------------------------------------------
update r
set TravelerGPN = Text22
from dba.raildata r, dba.comrmks
where recordkey = transactionid
and TravelerGPN = 'Unknown' and iatanum  = 'UBSRSBB' and text22 is not NULL
and text22 in (select corporatestructure from dba.rollup40 where costructid = 'functional')
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Update dba.raildata'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update r
set TravelerGPN = right('00000000'+TravelerGPN,8)
from dba.raildata r
where r.pos = 'CH' and len(TravelerGPN) <> 8 and TravelerGPN <> 'Unknown'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  update r'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where isnull(TravelerGPN,'X') not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and r.pos = 'CH'

--=====
--Next line commented out -- rcr 07/08/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TravelerGPN Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  TravelerGPN Updates Complete'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR



--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
--------Update Tex20 with the Traveler Name from the Hierarchy File------------------------------------------
update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.raildata r
where e.gpn = r.travelerGPN
and c.recordkey = r.TransactionID  and c.IATANUM = 'UBSRSBB' and isnull(text20,'x') <> e.paxname
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  c.text20 = e.paxname'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR



--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
-------- Update Text20 to the Traveler Name provided by the Rail Data when GPN not provided or dummy GPN used
update c
set text20 = substring(travelername,1,charindex(' ',travelername,1)-1)+ ','+ 
substring(travelername,charindex(' ',travelername)+1,20)
from dba.comrmks c, dba.raildata r
where c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRSBB'
and ((isnull(c.text20, 'Unknown') = 'Unknown') 	or (c.text20 = ' ')	)
and r.TravelerGPN ='Unknown' and bookingdate > '6-1-2012'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Update Text20 to the Traveler Name'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
--=====
--Next 2 lines commented out -- rcr 07/08/2015
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Rail Data Updates Complete',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====


WAITFOR DELAY '00:00.30' 

SET @TransStart = getdate()
--=====
--Next 2 lines commented out -- rcr 07/08/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Rail Data Updates Complete',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Rail Data Updates Complete'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
GO

ALTER AUTHORIZATION ON [dbo].[sp_GPN_Updates_All] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_UBS_EmpUpdate]    Script Date: 7/13/2015 1:25:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_EmpUpdate]
 AS

---------------------------------------------------------------------------------
--Set Importdt
Begin
declare @importdt datetime 
 set @importdt = Getdate()
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

end
--Process to add entries to the Employee Table and then update the comrmks 
--with the Travelers Name from the Hierarchy table provided by UBS.


-- Add new entries to the Employee table
insert into dba.Employee
select substring(description,1,8),substring(description,10,250)
	,'Active',ROLLUP2,ROLLUP3,ROLLUP4,ROLLUP5,ROLLUP6,ROLLUP7
	,@importdt,'12-31-2049',@importdt, Rollup8
from dba.rollup40
where substring(description,1,8) not in (select gpn from dba.Employee)
and costructid = 'functional'

update E
set e.rollup2 = r.rollupdesc2
from dba.employee e, dba.rollup40 r where e.rollup2 <> r.rollupdesc2 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup3 = r.rollupdesc3
from dba.employee e, dba.rollup40 r where e.rollup3 <> r.rollupdesc3 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup4 = r.rollupdesc4
from dba.employee e, dba.rollup40 r where e.rollup4 <> r.rollupdesc4 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup5 = r.rollupdesc5
from dba.employee e, dba.rollup40 r where e.rollup5 <> r.rollupdesc5 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup6 = r.rollupdesc6
from dba.employee e, dba.rollup40 r where e.rollup6 <> r.rollupdesc6 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup7 = r.rollupdesc7
from dba.employee e, dba.rollup40 r where e.rollup7 <> r.rollupdesc7 and r.corporatestructure = e.gpn
and costructid = 'functional'

update e
set e.rollup8 = substring(r.rollupdesc8,charindex('-',r.rollupdesc8)+1,20)
from dba.employee e, dba.rollup40 r
where e.gpn = r.corporatestructure

exec dbo.sp_GPN_Updates_All

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_EmpUpdate] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ROLLUP40]    Script Date: 7/13/2015 1:25:52 PM ******/
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

/****** Object:  Table [DBA].[RailData]    Script Date: 7/13/2015 1:26:04 PM ******/
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

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:26:10 PM ******/
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

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/13/2015 1:26:12 PM ******/
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

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 1:26:17 PM ******/
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

/****** Object:  Table [DBA].[Hotel]    Script Date: 7/13/2015 1:26:34 PM ******/
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

/****** Object:  Table [DBA].[Employee]    Script Date: 7/13/2015 1:26:47 PM ******/
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

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/13/2015 1:26:50 PM ******/
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

/****** Object:  Table [DBA].[Car]    Script Date: 7/13/2015 1:27:09 PM ******/
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

/****** Object:  Table [DBA].[Udef]    Script Date: 7/13/2015 1:27:27 PM ******/
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

SET ANSI_PADDING ON

GO

/****** Object:  Index [PK_ROLLUP40]    Script Date: 7/13/2015 1:27:28 PM ******/
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

/****** Object:  Index [RD_PX]    Script Date: 7/13/2015 1:27:29 PM ******/
CREATE CLUSTERED INDEX [RD_PX] ON [DBA].[RailData]
(
	[BookingDate] ASC,
	[POS] ASC,
	[TravelerGPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/13/2015 1:27:30 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 1:27:30 PM ******/
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

/****** Object:  Index [HotelI1]    Script Date: 7/13/2015 1:27:31 PM ******/
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

/****** Object:  Index [Employee_PX]    Script Date: 7/13/2015 1:27:32 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Employee_PX] ON [DBA].[Employee]
(
	[GPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/13/2015 1:27:32 PM ******/
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

/****** Object:  Index [CarI1]    Script Date: 7/13/2015 1:27:32 PM ******/
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

/****** Object:  Index [UdefI1]    Script Date: 7/13/2015 1:27:33 PM ******/
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

/****** Object:  Index [Rollup40_I*]    Script Date: 7/13/2015 1:27:34 PM ******/
CREATE NONCLUSTERED INDEX [Rollup40_I*] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI1]    Script Date: 7/13/2015 1:27:34 PM ******/
CREATE NONCLUSTERED INDEX [RollupI1] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI2]    Script Date: 7/13/2015 1:27:34 PM ******/
CREATE NONCLUSTERED INDEX [RollupI2] ON [DBA].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/13/2015 1:27:34 PM ******/
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

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/13/2015 1:27:35 PM ******/
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

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/13/2015 1:27:35 PM ******/
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

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/13/2015 1:27:36 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/13/2015 1:27:36 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 1:27:36 PM ******/
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

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 1:27:37 PM ******/
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

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 1:27:38 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 1:27:38 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 1:27:39 PM ******/
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

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 1:27:43 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 1:27:43 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 1:27:44 PM ******/
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

/****** Object:  Index [HotelI2]    Script Date: 7/13/2015 1:27:45 PM ******/
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

/****** Object:  Index [HotelI3]    Script Date: 7/13/2015 1:27:46 PM ******/
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

/****** Object:  Index [HotelPX]    Script Date: 7/13/2015 1:27:48 PM ******/
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

/****** Object:  Index [Employee_I1]    Script Date: 7/13/2015 1:27:48 PM ******/
CREATE NONCLUSTERED INDEX [Employee_I1] ON [DBA].[Employee]
(
	[GPN] ASC
)
INCLUDE ( 	[PaxName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/13/2015 1:27:50 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI2]    Script Date: 7/13/2015 1:27:51 PM ******/
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

/****** Object:  Index [CarPX]    Script Date: 7/13/2015 1:27:52 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CarPX] ON [DBA].[Car]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/13/2015 1:27:53 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [DBA].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/13/2015 1:27:53 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [DBA].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 1:27:54 PM ******/
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

