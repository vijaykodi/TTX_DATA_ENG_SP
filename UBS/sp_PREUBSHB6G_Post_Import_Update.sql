/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/9/2015 12:16:13 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_PRE_UBS_MAIN_Mini]    Script Date: 7/9/2015 12:16:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PRE_UBS_MAIN_Mini]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

/***********************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------
---- Update Curr code in Invoicedetail in case we missing something in Currency Conversion
-- this will only happen when the total amt is 0 or NULL --

update id
set currcode = 'USD'
from dba.invoicedetail id, dba.invoiceheader ih
where id.currcode <> 'USD' and isnull(totalamt,0) = 0 and id.iatanum = 'preubs'
and id.recordkey = ih.recordkey and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1


update id
set totalamt = 0
from dba.invoicedetail id, dba.invoiceheader ih
where totalamt is null  and id.iatanum = 'preubs'
and id.recordkey = ih.recordkey and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1

--GPN Padding
update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where i.iatanum = 'PREUBS' and len(remarks2) <> 8  and remarks2 <> 'Unknown'

----- Transaction updates
-- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i, dba.invoiceheader ih
where i.Remarks2 not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional') 
and i.IATANUM = 'PREUBS' and ih.IataNum = 'PREUBS' and i.recordkey = ih.recordkey 
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and ih.importdt > getdate()-1

update i
set remarks2 = corporatestructure
from dba.invoicedetail i, dba.rollup40 u, dba.comrmks c
where i.recordkey = c.recordkey and i.IataNum  = c.IataNum and i.ClientCode = c.ClientCode
and i.IssueDate = c.IssueDate and i.SeqNum = c.SeqNum and u.COSTRUCTID = 'functional' 
and c.Text30 = corporatestructure  and i.Remarks2 = 'Unknown' 
and i.IataNum = 'PREUBS' and c.IataNum = 'PREUBS' 

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- Update Remarks2 with Unknown when remarks2 is NULL
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i, dba.invoiceheader ih
where i.Remarks2 is null and i.IATANUM = 'PREUBS' and ih.IataNum = 'PREUBS'
and i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate
and ih.importdt > getdate()-1

--CAR -- Update remarks from invoicedetail remarks

SET @TransStart = getdate()

update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3, car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car, dba.invoiceheader ih
where i.recordkey = car.recordkey  and i.seqnum = car.seqnum  and i.iatanum = car.iatanum 
and i.ClientCode = car.ClientCode and i.IssueDate = car.IssueDate and i.recordkey = ih.recordkey
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate 
and i.iatanum = 'PREUBS' and ih.IataNum = 'PREUBS' and car.IataNum = 'PREUBS'
and ih.importdt > getdate()-1


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-Update remarks in car from ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--HOTEL -- Update remarks from invoicedetail remarks

SET @TransStart = getdate()

update h
set h.remarks1 = i.remarks1, h.remarks2 = i.remarks2, h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h, dba.invoiceheader ih
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum 
and i.ClientCode = h.ClientCode and i.IssueDate = h.IssueDate and i.recordkey = ih.recordkey 
and i.iatanum = ih.iatanum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and i.iatanum = 'PREUBS' and h.IataNum = 'PREUBS' and ih.IataNum ='PREUBS' 
and ih.importdt > getdate()-1


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-Update remarks in hotel from ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Hotel reasoncode1, if incorrect, from BCD's MAX codes

SET @TransStart = getdate()

update h
set htlreasoncode1 = case 
when htlreasoncode1 = 'HN' then 'X1' when htlreasoncode1 = 'XH' then 'X2' when htlreasoncode1 = 'HX' then 'X4'
when htlreasoncode1 = 'HC' then 'X7' when htlreasoncode1 = 'HH' then Null end
from dba.hotel h
where h.iatanum = 'PREUBS' 
and h.HtlReasonCode1 in ('HN','XH','HX','HC','HH')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6-Update hotel reason codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--
--Update the comrmks with LastUpdateDate for New Bookings flag
-- need to substring udefdata to 150

SET @TransStart = getdate()

update cr
set cr.text19 = substring(ud.udefdata,1,150)
from dba.comrmks cr, dba.udef ud, dba.invoiceheader ih
WHERE cr.recordkey = ud.recordkey and cr.iatanum = ud.iatanum  and cr.clientcode = ud.clientcode 
and cr.IssueDate = ud.IssueDate and cr.recordkey = ih.recordkey and cr.IataNum = ih.IataNum
and cr.InvoiceDate = ih.InvoiceDate and cr.ClientCode = ih.ClientCode
and cr.iatanum = 'PREUBS' and ud.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS' and ud.udeftype = 'LASTUPDATE' 
and ud.udefnum = '999'  and cr.Text19 is null
and ih.importdt > getdate()-1

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Text 19',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------------------------
--Update the comrmks with the Travelers Name from the Hierarchy table provided by UBS.

SET @TransStart = getdate()

--Update Tex20 with the Traveler Name from the Hierarchy File
--Updated to utilize substring on e.paxname 25NOV2013/SS
update c
set c.text20 = substring(e.paxname,1,150)
from dba.employee e, dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and c.recordkey = i.recordkey  and c.IataNum = i.IataNum
and c.IssueDate = i.IssueDate and c.ClientCode = i.ClientCode   and c.seqnum = i.seqnum  
and c.IATANUM = 'PREUBS' and i.IataNum = 'PREUBS'  and ih.IataNum = 'PREUBS'  
and e.gpn = i.remarks2  and (i.remarks2 not like ('99999%') or i.Remarks2 <> 'Unknown')
and ih.importdt > getdate()-1

-- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(lastname,'UBSAG')+','+isnull(firstname,'UBSAG'))
from dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where c.recordkey = i.recordkey  AND C.IATANUM =I.IATANUM  and c.seqnum = i.seqnum  
and c.ClientCode = i.ClientCode and c.IssueDate = i.IssueDate and i.recordkey = ih.recordkey 
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and c.IATANUM = 'PREUBS' and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and (isnull(c.text20, 'Non GPN') like '%Non GPN%' 	or c.text20 = '')
and ((i.remarks2 like ('99999%')) or (i.remarks2 ='Unknown'))
and ih.importdt > getdate()-1

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Text 20',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------------------------------------------------------------------
-- update reasoncodes (air,car,hotel) to Null where *
-- At this time (12/27/2011) we do not know where the * is coming from
-- The records do not have values and should be NULL

update i
set reasoncode1 = NULL
from dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey 
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS' and i.reasoncode1 = '*' 
and ih.importdt > getdate()-1

update h
set htlreasoncode1 = NULL
from dba.hotel h, dba.invoiceheader ih
where h.recordkey = ih.recordkey and h.IataNum = ih.IataNum and h.ClientCode = ih.ClientCode
and h.InvoiceDate = ih.InvoiceDate and h.htlreasoncode1 = '*'  and h.IataNum = 'PREUBS'
and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1

update c
set carreasoncode1 = NULL
from dba.car c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum
and c.ClientCode = ih.ClientCode and c.InvoiceDate = ih.InvoiceDate
and c.carreasoncode1 = '*'  and c.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1

-- Set value to null if not in the "online" list


----- Null out the air reasoncode1 when no air segments are present
update i
set reasoncode1 = NULL, vendortype = 'NONAIR'
from dba.invoicedetail i
where i.iatanum = 'preubs' and reasoncode1 is not NULL 
and i.recordkey+convert(varchar,seqnum) not in 
	(select recordkey+convert(varchar,seqnum) from dba.transeg where iatanum = 'preubs')
and i.voidind = 'n' and i.RefundInd = 'n'  and i.ExchangeInd = 'n'
and i.recordkey+convert(varchar,seqnum)  in 
	(select recordkey+convert(varchar,seqnum) from dba.hotel where iatanum = 'preubs')

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update reasoncode1 when no air',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------ Updating the farecomare2 per UBS's instructions on 1/16/2012
-- this is Phase 1 to try to clean up the fare compare fares as we receive them from the TMC's.
-- this will set fare compare to 0 where the ticket(s) have not be issued
--added 12/9/2014 #48427  remove the default "0" misssed saving for all OOP bookings that are not ticketed
--reasoncodes beginning w B are oop
update i
set farecompare2 = '0'
from dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.iatanum = 'preubs' and ih.IataNum = 'preubs'
and i.DocumentNumber is NULL and i.ReasonCode1 not like 'b%'and substring(i.recordkey,15,4) <> 'r539'
and ih.importdt > getdate()-1


------- Start Split Ticket Updates for Farecompare2, ReasonCode1, and TotalAmt----- LOC/11/20/2013 #14059
------- FareCompare2 and ReasonCode1 updates ----------------------------------------------------
---Error converting data type varchar to float - commented out until can review data being converted
--Notes\ss - May need to restict to insure the udefdata isnumeric 25NOV2013/ss
update id
set reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,7)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,26,7) not like '%/%' and id.invoicedate > '11/1/2013'

update id
set reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,6)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,26,6)  like '[0-9][0-9][0-9][.][0-9][0-9]' and id.invoicedate > '11/1/2013'

update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,25,6)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and  substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,25,6) not like '%/%' 

update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,24,5)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,24,5) not like '%/%' 

update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,23,4)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and  substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,23,4) not like '%/%' 

------------------------------update Total amount for Exchanges  --KP/11/20/2013 #14059

update id
set totalamt = convert(float,substring(udefdata,18,8))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,7) like '%[0-9][0-9][0-9][0-9][0-9].%' --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

update id
set totalamt = convert(float,substring(udefdata,18,7))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,6) like '%[0-9][0-9][0-9][0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

update id
set totalamt = convert(float,substring(udefdata,18,6))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,7) like '%[0-9][0-9][0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

update id
set totalamt = convert(float,substring(udefdata,18,5))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,4) like '%[0-9][0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

update id
set totalamt = convert(float,substring(udefdata,18,4))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,4) like '%[0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Splittkt exch update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Updating the farecompare2 to = 0 when no reasoncode is provided
-------- per UBS instruction on the 9/6/2012 call ... LOC
update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.ReasonCode1 is NULL 
and i.ServiceDate > getdate()-50 and substring(i.recordkey,15,4)<> 'R539'

-- This will set the fare compare to 0 where there is no fare null or 0
update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.TotalAmt = '0' 
and i.ServiceDate > getdate()-50 and substring(i.recordkey,15,4)<> 'R539'

update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.TotalAmt is null
and i.ServiceDate > getdate()-50 and substring(i.recordkey,15,4)<> 'R539'

--This will set the fare comapre for all in policy records to = the total amt
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.reasoncode1 like 'a%'  and i.FareCompare2 <> i.TotalAmt
and substring(documentnumber,7,4) not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS')
and servicedate > getdate() -50

---- To set records with Multiple tickets that have B (out of policy codes)  
---- to = total amount to create a 0 missed savings 
---- This will update the 1st ticket
update i1
set i1.farecompare2 = i1.totalamt
from dba.invoicedetail i1, dba.invoicedetail i2, dba.invoiceheader ih
where i1.recordkey = i2.recordkey and i1.IataNum = i2.IataNum and i1.ClientCode = i2.ClientCode
and i1.IssueDate = i2.IssueDate and i1.recordkey = ih.recordkey  and i1.IataNum = ih.IataNum
and i1.ClientCode = ih.ClientCode and i1.InvoiceDate = ih.InvoiceDate and i2.recordkey = ih.recordkey 
and i2.IataNum = ih.IataNum and i2.ClientCode = ih.ClientCode and i2.InvoiceDate = ih.InvoiceDate
and i1.iatanum = 'preubs' and i2.iatanum = 'preubs' and ih.IataNum = 'preubs' and i1.seqnum < i2.seqnum 
and i1.farecompare2 <> i1.totalamt
and substring(i1.recordkey,15,4) not in ('6dff','27su','J21G','VP3G')

---- This will update the 2nd ticket 
update i2
set i2.farecompare2 = i2.totalamt
from dba.invoicedetail i1, dba.invoicedetail i2, dba.invoiceheader ih
where i1.recordkey = i2.recordkey and i1.IataNum = i2.IataNum and i1.ClientCode = i2.ClientCode
and i1.IssueDate = i2.IssueDate and i1.recordkey = ih.recordkey  and i1.IataNum = ih.IataNum
and i1.ClientCode = ih.ClientCode and i1.InvoiceDate = ih.InvoiceDate and i2.recordkey = ih.recordkey 
and i2.IataNum = ih.IataNum and i2.ClientCode = ih.ClientCode and i2.InvoiceDate = ih.InvoiceDate
and i1.iatanum = 'preubs' and i2.iatanum = 'preubs'  and ih.IataNum = 'preubs' and i1.seqnum < i2.seqnum  
and i1.farecompare2 = i1.totalamt 
and i2.farecompare2 <> i2.totalamt
and substring(i1.recordkey,15,4) not in ('6dff','27su','J21G','VP3G')

---- This changes the 3nd ticket to = total amount
update i3
set i3.farecompare2 = i3.totalamt
from dba.invoicedetail i1, dba.invoicedetail i2, dba.invoicedetail i3, dba.invoiceheader ih
where i1.recordkey = i2.recordkey and i1.IataNum = i2.IataNum and i1.ClientCode = i2.ClientCode
and i1.IssueDate = i2.IssueDate and i1.recordkey = i3.recordkey and i1.IataNum = i3.IataNum
and i1.ClientCode = i3.ClientCode and i1.IssueDate = i3.IssueDate and i2.recordkey = ih.recordkey
and i2.IataNum = ih.IataNum and i2.ClientCode = ih.ClientCode and i2.InvoiceDate = ih.InvoiceDate 
and i1.recordkey = ih.recordkey and i1.IataNum = ih.IataNum and i1.ClientCode = ih.ClientCode
and i1.InvoiceDate = ih.InvoiceDate and i3.recordkey = ih.recordkey and i3.IataNum = ih.IataNum
and i3.ClientCode = ih.ClientCode and i3.InvoiceDate = ih.InvoiceDate  and i1.seqnum  < i2.seqnum 
and i2.seqnum < i3.seqnum and i1.iatanum = 'preubs'  and i2.iatanum = 'preubs' 
and i3.IataNum = 'preubs' and ih.IataNum = 'preubs' and i1.totalamt = i1.farecompare2 
and substring(i1.recordkey,15,4) not in ('6dff','27su','J21G','VP3G')

---------- This will update the farecompare to equal the total amount when there is a OOP Reason code
---------- but the compare fare is higher than the total amount -- this is per UBS instruction
---------- on 9/6/2012 ... LOC
update i
set farecompare2 = I.TOTALAMT
from dba.invoicedetail i
where i.ReasonCode1 like 'b%'  and i.farecompare2 > totalamt
and i.IataNum = 'preubs'
and substring(documentnumber,7,4) not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS') and servicedate > getdate() -50

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Fare Compare Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--approved by UBS to set anything within $5 threshold to have 0 savings to help with negative sav amts
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where abs(farecompare2) -abs(totalamt) between .5 and 5
and iatanum = 'preubs'
and servicedate > getdate() -50

update i
set farecompare2 = totalamt
from dba.invoicedetail i
where abs(farecompare2) >abs(totalamt) 
and iatanum = 'preubs'
and servicedate > getdate() -50

---------- Mapping BCD reasoncode to UBS reasoncodes
SET @TransStart = getdate()
Update i
set reasoncode1 = case when reasoncode1 = 'PC' then 'A1'
when reasoncode1 = 'UG' then 'A4'
when reasoncode1 = 'NR' then 'A6'
when reasoncode1 = 'BC' then 'B1'
when reasoncode1 = 'CP' then 'B2'
when reasoncode1 = 'ST' then 'B3'
when reasoncode1 = 'AP' then 'B5'
when reasoncode1 = 'MI' then 'B6'
when reasoncode1 = 'NO' then 'B7'
when reasoncode1 = 'CC' then 'B8'
when reasoncode1 in('RB','XX','EX') then 'A1'
end 
from dba.invoicedetail i, dba.invoiceheader ih
where i.iatanum = 'PREUBS'
and ih.IataNum = 'PREUBS'
and i.ReasonCode1 in ('PC','UG','NR','BC','CP','ST','AP','MI','NO','CC','RB','XX','EX')
and i.recordkey = ih.recordkey 
and i.IataNum = ih.IataNum
and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate

-------------------------------------------------------------------------
----- Update Text 11 - already viewed on report Flag for records imported
-- but not for the 1st time.
update c
set text11 = 'Y'
from dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = c.recordkey and i.seqnum = c.seqnum  and i.ClientCode = c.ClientCode
and i.IssueDate = c.IssueDate and i.recordkey = ih.recordkey  and i.IataNum = ih.IataNum
and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate and i.iatanum = 'preubs'
and c.IataNum = 'preubs' and ih.IataNum = 'preubs' and abs(datediff(dd,ih.importdt, ih.invoicedate))>5
and c.Text11 is null and i.voidind = 'N'  and i.refundind = 'N'  and i.exchangeind = 'N'
and i.remarks2 <> 'Unknown' and isnull(c.Text21,'xx') not like '%hold%' 
and ih.importdt > getdate()-1

---------------Update Text 17 where Pending is the value----------------
update c
set text17 = NULL
from dba.comrmks c, dba.invoiceheader ih
where c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode and c.InvoiceDate = ih.InvoiceDate
and c.RecordKey = ih.RecordKey and ih.iatanum = 'preubs'  and c.IataNum = 'preubs' and c.Text17 = 'Pending' 
and ih.importdt > getdate()-1

--------------Update document number where one supplied in Secure Ticket remark------
--Added additional substring to force returning only 15 characters 25NOV2013/ss
update i
set documentnumber=substring(substring (udefdata,1,charindex('/',udefdata)-1),1,15)
from dba.udef u, dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.recordkey = u.recordkey  and i.seqnum = u.seqnum
and i.IataNum = u.IataNum and i.ClientCode = u.ClientCode and i.IssueDate = u.IssueDate
and u.iatanum = 'preubs' and i.IataNum = 'preubs' and ih.iatanum = 'preubs'
and i.DocumentNumber is null and substring (udefdata,1,charindex('/',udefdata)-1) <> 'HTE'
and u.UdefType = 'securedticket' 
and ih.importdt > getdate()-1

----- Update documentnumber when ticketing field shows ticketed however we are unable
-- to capture the ticket information -- added 4-9-2012 .. LOC
update i
set documentnumber = 'ACCESS DENIED'
from dba.udef u, dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.recordkey = u.recordkey  and i.seqnum = u.seqnum
and i.IataNum = u.IataNum and i.ClientCode = u.ClientCode and i.IssueDate = u.IssueDate
and u.iatanum = 'preubs' and i.IataNum = 'preubs' and ih.iatanum = 'preubs'
and u.UdefType = 'ticketed' and isnull(i.documentnumber,'HTE') = 'HTE' and i.voidind = 'n'
and ih.importdt > getdate()-1

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Doc Num Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- Update Text17 (TractID) to N/A where the value does not appear to be a TractID.------
----- commented out the ones with spaces per Ryan and team 8/22/2012 ------ 
update c
set Text17 = 'N/A'
from dba.comrmks c
where isnull(c.Text17,'X') like '%' and not ((c.Text17  like '[1-9][0-9][0-9][0-9][0-9]') or 
(c.Text17 like '[1-9][0-9][0-9][0-9][0-9][0-9]') 
or(c.text17 like '[0-9][0-9][A-Z][A-Z][A-Z][1-9][0-9]')
or (c.Text17 = 'O') or (c.text17 = 'A')) 
and c.iatanum = 'preubs' 
and c.Text17 <> 'N/A'

Update c
set Text17 = 'N/A'
from dba.comrmks c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode 
and c.InvoiceDate = ih.InvoiceDate and c.Text17 is null  and c.iatanum = 'preubs'
and ih.IataNum = 'preubs'

Update c
set Text17 = 'N/A'
from dba.comrmks c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode
and c.InvoiceDate = ih.InvoiceDate and c.Text17 in ('11111','111111','1111111')  and c.iatanum = 'preubs'
and ih.IataNum = 'preubs'

----- Update hotel date where date diff is greater than 100 -- this is due to an issue
-- with Amadeus -- Once corrected in Correx we can remove this -- LOC 7/22/2012
update id
set servicedate = servicedate-366
from dba.hotel h, dba.invoicedetail id, dba.invoiceheader ih
where h.recordkey = id.recordkey and h.seqnum = id.seqnum and h.ClientCode = id.ClientCode
and h.IssueDate = id.IssueDate and h.IataNum = id.IataNum and id.IataNum = ih.IataNum
and id.ClientCode = ih.ClientCode and id.InvoiceDate = ih.InvoiceDate and id.RecordKey = ih.RecordKey
and h.iatanum = 'preubs' and ih.IataNum = 'preubs' and id.IataNum = 'preubs'
and datediff (dd,h.issuedate, h.checkoutdate) > 366
and ih.importdt > getdate()-1

update h
set checkindate = checkindate-366, checkoutdate = checkoutdate-366
from dba.hotel h, dba.invoiceheader ih
where h.IataNum = ih.IataNum  and h.ClientCode = ih.ClientCode
and h.InvoiceDate = ih.InvoiceDate and h.RecordKey = ih.RecordKey
and h.IataNum = 'preubs' and ih.IataNum = 'preubs' and datediff (dd,h.issuedate, h.checkoutdate) > 366
and ih.importdt > getdate()-1

---------  Set Total amount to = U27 and Farecompare2 = U28 for BCDUS
---------  for BCD when Non ARC Carrier ---- LOC / 8/13/2012
update i
set totalamt = substring(u1.udefdata,5,10), farecompare2 = substring(u2.udefdata,5,10)
from dba.invoicedetail i, dba.udef u1, dba.udef u2, dba.InvoiceHeader IH
where i.recordkey = u1.recordkey  and i.seqnum = u1.seqnum and i.IataNum = u1.IataNum
and i.IssueDate = u1.IssueDate and i.ClientCode = u1.ClientCode and  i.recordkey = u2.recordkey 
and i.seqnum = u2.seqnum and i.IataNum = u2.IataNum and i.IssueDate = u2.IssueDate
and i.ClientCode = u2.ClientCode and u1.recordkey = u2.recordkey  and u1.seqnum = u2.seqnum
and u1.IataNum = u2.IataNum  and u1.ClientCode = u2.ClientCode and u1.IssueDate = u2.IssueDate
and i.RecordKey = ih.RecordKey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.IataNum = 'preubs' and ih.IataNum = 'preubs'
and u1.IataNum = 'preubs' and u2.IataNum = 'preubs' and u1.udefdata like 'U27%' 
and u2.udefdata like 'U28%' and i.TotalAmt = '0' and i.ValCarrierCode in ('9K','PD','WN','NK')
and ih.importdt > getdate()-1

---------  Set Total amount to = U27 and Farecompare2 = U28 for BCDEU
---------  for BCD when Non ARC Carrier ---- LOC / 8/13/2012
update i
set totalamt = substring(u1.udefdata,7,10), farecompare2 = substring(u2.udefdata,7,10)
from dba.invoicedetail i, dba.udef u1, dba.udef u2, dba.InvoiceHeader IH
where i.recordkey = u1.recordkey and i.seqnum = u1.seqnum and i.IataNum = u1.IataNum
and i.IssueDate = u1.IssueDate and i.ClientCode = u1.ClientCode and  i.recordkey = u2.recordkey 
and i.seqnum = u2.seqnum and i.IataNum = u2.IataNum and i.IssueDate = u2.IssueDate
and i.ClientCode = u2.ClientCode and u1.recordkey = u2.recordkey  and u1.seqnum = u2.seqnum
and u1.IataNum = u2.IataNum  and u1.ClientCode = u2.ClientCode and u1.IssueDate = u2.IssueDate
and i.RecordKey = ih.RecordKey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.IataNum = 'preubs' and ih.IataNum = 'preubs'
and u1.IataNum = 'preubs' and u2.IataNum = 'preubs' and u1.udefdata like 'Z*U27%' 
and u2.udefdata like 'Z*U28%' and i.TotalAmt = '0' and i.ValCarrierCode in ('9K','PD','WN','NK')
and ih.importdt > getdate()-1

---- To ensure any bookings that have had the air changed but not the hotel are still connected..LOC/2/19/2013
update h
set  h.seqnum = i2.seqnum, h.issuedate = i2.issuedate
from dba.invoicedetail i1, dba.invoicedetail i2, dba.hotel h
where i1.recordkey = h.recordkey and i1.recordkey = i2.recordkey  and i1.seqnum = h.seqnum 
and i1.IataNum = 'preubs' and i2.IataNum = 'preubs' and h.IataNum = 'preubs' and i1.voidind = 'y' 
and i2.voidind ='n' and i1.servicedate > '1-1-2014'


-------- The queries below are for the flagging of Refundable / Non Refunadable tickets
-------- BCD Americas is mapped from the G4 and then changed when necessary
-------- The code will first flag Hotel and Car only transactions as Not Required
-------- Then we look for specific text in the endorsement boxes to flag for Non Refundable tickets
-------- Then we will look for the Fare Type in the EMEA Data from BCD and flag per the codes
-------- When ticket number is present and no endorsements the R
-------- When ClientCode 6631020201 then use G4 only.
-------- When low cost carriers then G4 Only.
-------- When no ticket and no endorsement then N.

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text9 Updates Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update Text9 = Not Required for Hotel and Car Only Transactions --- LOC/1/15/2014
---------------------Hotel Only ---------------------------

update c
set Text9 = 'Not Required'
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.iatanum = 'preubs' and isnull(text9,'Not Provided') in ('Not Provided','Not Valid','N','R')
and i.recordkey in (select recordkey from dba.hotel)
and i.recordkey not in (select recordkey from dba.transeg)

------------------Car Only -------------------------------
update c
set Text9 = 'Not Required'
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and vendortype not in ('bsp','nonbsp','rail') and i.iatanum = 'preubs'
and isnull(text9,'Not Provided') in ('Not Provided','Not Valid','N','R')
and i.recordkey in (select recordkey from dba.car)
and i.recordkey not in (select recordkey from dba.transeg)

SET @TransStart = getdate()

--------  Update Text9 w Refundable Status of R or N KP 10/30/2013 Case#23060
--specific endorsements added to help with APAC data 4/22/2014
update c
set Text9 = case 
			when i.endorsementremarks = 'VALID ON CX ONLY NON-ENDO//REF.' then 'R'
		    when i.endorsementremarks like 'NONEND/REF%' then 'R' 
		    when i.endorsementremarks ='CHANGE FOC/NON END/REFER GGAIRBAGJSA' then 'R'
		    when i.endorsementremarks like '%NONENDO/REF%' then 'R'
		    when i.endorsementremarks like 'NON-END%' then 'R'	
		    when i.endorsementremarks='NONENDO/NOREF-VLD FB ONLY' then 'N'	    			
			when i.endorsementremarks like '%no%ref%' then 'N'
			when i.endorsementremarks like '%nonref%' then 'N'
			when i.endorsementremarks like '%non ref%' then 'N'
		    when i.endorsementremarks like '%nonrer%' then 'N'
		    when i.endorsementremarks like '%no rfnd%' then 'N'
		    when i.endorsementremarks like '%non%rfd%' then 'N'  
		     else 'R'  end
from  dba.invoicedetail i,dba.ComRmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.IataNum=c.IataNum and i.ClientCode=c.clientcode
and i.iatanum = 'preubs'  and i.endorsementremarks is not null  
and i.recordkey in (select recordkey from dba.transeg where iatanum = 'preubs')


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TEXT 9 TO N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 

-------- Process for EMEA -- Fare type code is mapped to Text47 .. below is the mapping
-------- of this code to R or N .. LOC/12/5/2013
--------------could not get case statement to work--LOC/12/5/2013
-------- Removing and document number is null per conversations with UBS ..LOC/2/11/2014
update c
set Text9 ='R' 
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and text47 in ('1N','2N','3N','1T','2T','3T','1F','2F','3F','1I','2I','3I','1','2','6') 
and c.iatanum = 'preubs' and isnull(text9,'N')= 'N' --and documentnumber is null

update c
set Text9 ='N' 
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and text47 in ('N','1C','2C','3C''1R','2R','3R','1B','2B','3B','1V','2V','3V','1Q','2Q','3Q','1L','3','4','5','7','8')
and c.iatanum = 'preubs' and isnull(text9,'R') = 'R' --and documentnumber is null

-------- Updateing to R when ticket number is present and no endorsements or code from BCD ---
-------- as discussed with UBS 2/11/2014/LOC

SET @TransStart = getdate()
update c
set Text9 = 'R' 
from  dba.invoicedetail i,dba.ComRmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.IataNum=c.IataNum and i.ClientCode=c.clientcode
and isnull(c.Text9,'X')  not in ('R','N','U') and i.iatanum = 'preubs'  
and i.documentnumber is not null and i.endorsementremarks is null
and i.recordkey in (select recordkey from dba.transeg where iatanum = 'preubs')

-------- Update Text 9 to G4 values for ClientCode 6631020201 - This is the account number
-------- BCD uses for consolidator invoices therefore there will be no endorsement in the pNR's--
-------- Per Mike Dove at BCD .. LOC/1/9/2014
Update c
set Text9 = Udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = u.iatanum
and c.clientcode = '6631020201'and c.iatanum = 'preubs' 
and udeftype = 'Z G4 REMARKS' and udefdata in ('r','u','n')
and c.recordkey in (select recordkey from dba.transeg where iatanum = 'preubs')


-------- Update Low Cost Carriers using the G4 field as endorsements do not come over in the 
-------- PNR's for these and for the most part they are non refundalbe and are being shown
-------- as refundable.  Per conversation with Jeremy and Mike Dove ..
-------- this is being set in 6DFF and 27SU but this is to ensure they are not overwritten by any of the code
-------- above.  I get confused and just makeing sure...LOC/1/10/2014.
---------------- For Sabre -------------------------------
Update c
set Text9 = Udefdata
from dba.invoicedetail i, dba.comrmks c, dba.udef u
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.valcarriercode in ('FL','WN','F9','NK','B6') and udeftype like '%g4%'
and i.invoicedate > '12-1-2013' and voidind = 'n'
and i.iatanum = 'preubs' and isnull(Text9,'X') <> Udefdata

---------------- For Apollo -------------------------------
Update c
set Text9 = substring(Udefdata,4,1)
from dba.comrmks c, dba.udef u, dba.invoicedetail i
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = u.iatanum
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and voidind = 'n' and c.iatanum = 'preubs' and udefdata like 'G4-%' and 
isnull(substring(Udefdata,4,1),'X') in ('r','u','n') and i.valcarriercode in ('FL','WN','F9','NK','B6')
and isnull(Text9,'X') <> substring(Udefdata,4,1)


-------- Update Text9 to N (Non Refundable) where no ticket and no price yet --- 
-------- Per UBS Team -- 12/10/2013/LOC -- commented out the totalamt = 0 to update those that 
------- are priced and not ticketed--- LOC/12/18/2013
update c
set text9 = 'N'
from  dba.invoicedetail i,dba.ComRmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.IataNum=c.IataNum and i.ClientCode=c.clientcode
and c.Text9 is null and i.iatanum = 'preubs' and documentnumber is null and endorsementremarks is null 
and exchangeind = 'N'  and isnull(c.text9,'X') <> 'N'
and i.recordkey in (select recordkey from dba.transeg where iatanum = 'preubs')



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TEXT 9 TO R IF NOT N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--testing moving to the end to see if something is undoing this update...set the fare comapare for all in policy records to = the total amt
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.reasoncode1 like 'a%'  and i.FareCompare2 <> i.TotalAmt
and substring(documentnumber,7,4) not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS')
and servicedate > getdate() -50

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End UBS Pre Main Mini SP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 
GO

ALTER AUTHORIZATION ON [dbo].[sp_PRE_UBS_MAIN_Mini] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_PREUBSHB6G_Post_Import_Update]    Script Date: 7/9/2015 12:16:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREUBSHB6G_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start HB6G-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='CH'
where iatanum ='PREUBS' and recordkey like '%HB6G-%'
and (origcountry is null or origcountry ='XX')


---May need to put some additional code in for the hotel reason code due to segment selecting--LOC/8/7/2012


------- Updating carrcommamt to the total car rate from remarks
update c
set carcommamt = NULL
from dba.car c
where c.recordkey like '%HB6G-%' and carcommamt = '0'

update car
set carcommamt = udefdata
from dba.car car, dba.udef u
where car.recordkey = u.recordkey and car.seqnum = u.seqnum
and car.recordkey like '%HB6G-%' and udeftype = 'cartotalrate'


----- Update Air Reason Codes if not updated in Parsing ------- LOC 8/7/2012
---------------Parse when no segment select ------------------  LOC/9/19/2012
update i
set reasoncode1 = right(udefdata,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%'
and udefdata like '.acesv1-%' and udefdata not like '%*%' and reasoncode1 is null

---------------parse when segment select -----------------------LOC / 9/19/2012
update i
set reasoncode1 =substring(udefdata,charindex('*',udefdata)-2,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%'
and udefdata like '.acesv1-%' and udefdata like '%*%' and reasoncode1 is null

---------------- Update HtlReasonCode1  -------- LOC/8/7/2012
-----------------Udate where no segment select or garbage data ------ LOC/9/19/2012
update h
set htlreasoncode1 = right(udefdata,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs'
and H.recordkey like '%HB6G-%' and udefdata like '.acehot-pr-hot-%'
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and right(udefdata,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')

----------------Update when segment select in string ------- LOC/9/19/2012
update h
set htlreasoncode1 = substring(udefdata,charindex('*',udefdata)-2,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%'
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('*',udefdata)-2,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')


update h
set htlreasoncode1 = substring(udefdata,charindex('#',udefdata)-2,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%'
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('#',udefdata)-2,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')


-------- Additional code added for new formats --- LOC/4/8/2014
update h
set htlreasoncode1 = substring(udefdata,charindex('UP',udefdata)-3,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%' and udefdata like '%up%'  
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('UP',udefdata)-3,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')

update h
set htlreasoncode1 = substring(udefdata,charindex('CO',udefdata)-3,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%' 
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('CO',udefdata)-3,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')


-------- Update Remarks2 with GPN ------------ LOC/8/7/2012
update i
set remarks2 = substring(udefdata,13,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-EMP/%' and isnull(remarks2,'Unknown') = 'Unknown'

-------- Update Remarks1 with Trip Purpose ------- LOC 8/7/2012
update i
set remarks1 = substring(udefdata,13,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum and i.iatanum = 'preubs' 
and i.recordkey like '%HB6G-%' and udefdata like '.ACECRM-TRR/%' and remarks1 is null

-------- Update Remarks5 with Cost Center -------- LOC/8/7/2012
update i
set remarks5 = substring(udefdata,13,7)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%' and udefdata like '.ACECRM-COS/%' and remarks5 is null


update i
set remarks5 =  substring(udefdata,13,7)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%' and udefdata like '.ACECRM-COS/%' 
and remarks5 <>substring(udefdata,13,7)
and substring(udefdata,13,7) in (select rollup8 from dba.rollup40 where costructid = 'functional' )



-------- Update Online booking type ----- LOC / 8/7/2012
update i
set onlinebookingsystem = 'Y'
from dba.invoicedetail i
where bookingagentid = '0VITN03'
and i.iatanum = 'preubs'
and i.recordkey like '%HB6G-%'

-------- Update Text 18 with Online Reason Code ------------------ LOC 8/7/12
update c
set text18 = substring(udefdata,13,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-CD4/%'
and substring(udefdata,13,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')
and text18 is null


-------- Update Text 17 with TractID ------------------ LOC 8/7/12
update c
set text17 = substring(udefdata,13,7)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-ORD/%'
and isnull(text17,'N/A')  = 'N/A'

-------- Update Text 8 with Booker GPN------------------ LOC 8/7/12
update c
set text8 = substring(udefdata,13,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-CD2/%' and text8 is null

-------- Update Text 14 with Approver GPN------------------ LOC 8/7/12
update c
set text14 = substring(udefdata,13,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-APP/%' and text14 is null

-------- Update Text 7 with Project Code------------------ LOC 8/7/12
update c
set text7 = substring(udefdata,13,20)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.ACECRM-PRJ/%' and text7 is null

-------- Update Text6 with T24 Flag ---- LOC/3/22/2013
update c
set text6 =  substring(udefdata,14,3)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.ACECRM-MNGR/%' and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation HB6G-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 8/7/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' And udefdata like 'acecrm-ord%' and text27 is null

-------Update Text25 = ReasonCode1  String --------------------------- LOC 8/7/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like'.acesv1-%' and text25 is null

-------Update Text23 = Trip Purpose  String --------------------------- LOC 8/7/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like'acecrm-trr/%' and text23 is null

-------Update Text22 = GPN  String --------------------------- LOC 8/7/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like 'acecrm-emp/%'
and text22 is null

-------Update Text24 = CostCenter  String --------------------------- LOC 8/7/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.acecrm-cos/%' and text24 is null

-------Update Text26 = Hotel Reason Code  String --------------------------- LOC 8/7/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.acehot-pr-hot%' and text26 is null

------ Update Text 13 with Online Reason Code String ------------------ LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%'  and udefdata like '.acecrm-cd4%' and text13 is null

update ih
set origcountry = 'CL'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%HB6G%' 
and origcountry = 'CH'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CL') 

update ih
set origcountry = 'CO'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%HB6G%' and origcountry = 'CH'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CO') 

update ih
set origcountry = 'PE'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%HB6G%' and origcountry = 'CH'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'PE') 

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= right(udefdata,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%HB6G%' and udefdata like '.acesv2-%' 
AND udefdata NOT LIKE '%*%' and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End HB6G- ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
EXEC sp_PRE_UBS_MAIN_Mini 

 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 












GO

ALTER AUTHORIZATION ON [dbo].[sp_PREUBSHB6G_Post_Import_Update] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ROLLUP40]    Script Date: 7/9/2015 12:16:15 PM ******/
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

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/9/2015 12:16:22 PM ******/
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

/****** Object:  Table [DBA].[LookupData]    Script Date: 7/9/2015 12:16:24 PM ******/
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

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/9/2015 12:16:25 PM ******/
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

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/9/2015 12:16:35 PM ******/
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

/****** Object:  Table [DBA].[Hotel]    Script Date: 7/9/2015 12:16:54 PM ******/
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

/****** Object:  Table [DBA].[Employee]    Script Date: 7/9/2015 12:17:03 PM ******/
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

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/9/2015 12:17:07 PM ******/
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

/****** Object:  Table [DBA].[Car]    Script Date: 7/9/2015 12:17:27 PM ******/
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

/****** Object:  Table [DBA].[Udef]    Script Date: 7/9/2015 12:17:40 PM ******/
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

/****** Object:  Table [DBA].[TranSeg]    Script Date: 7/9/2015 12:17:42 PM ******/
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

SET ANSI_PADDING ON

GO

/****** Object:  Index [PK_ROLLUP40]    Script Date: 7/9/2015 12:17:55 PM ******/
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

/****** Object:  Index [LookupDataI1]    Script Date: 7/9/2015 12:17:57 PM ******/
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

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/9/2015 12:17:58 PM ******/
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

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/9/2015 12:17:59 PM ******/
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

/****** Object:  Index [HotelI1]    Script Date: 7/9/2015 12:18:00 PM ******/
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

/****** Object:  Index [Employee_PX]    Script Date: 7/9/2015 12:18:02 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Employee_PX] ON [DBA].[Employee]
(
	[GPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/9/2015 12:18:03 PM ******/
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

/****** Object:  Index [CarI1]    Script Date: 7/9/2015 12:18:04 PM ******/
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

/****** Object:  Index [UdefI1]    Script Date: 7/9/2015 12:18:05 PM ******/
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

/****** Object:  Index [TransegI1]    Script Date: 7/9/2015 12:18:05 PM ******/
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

/****** Object:  Index [Rollup40_I*]    Script Date: 7/9/2015 12:18:06 PM ******/
CREATE NONCLUSTERED INDEX [Rollup40_I*] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI1]    Script Date: 7/9/2015 12:18:07 PM ******/
CREATE NONCLUSTERED INDEX [RollupI1] ON [DBA].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RollupI2]    Script Date: 7/9/2015 12:18:08 PM ******/
CREATE NONCLUSTERED INDEX [RollupI2] ON [DBA].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/9/2015 12:18:08 PM ******/
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

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/9/2015 12:18:10 PM ******/
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

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/9/2015 12:18:11 PM ******/
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

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/9/2015 12:18:12 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/9/2015 12:18:12 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/9/2015 12:18:13 PM ******/
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

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/9/2015 12:18:14 PM ******/
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

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/9/2015 12:18:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/9/2015 12:18:17 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/9/2015 12:18:17 PM ******/
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

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/9/2015 12:18:21 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/9/2015 12:18:21 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/9/2015 12:18:22 PM ******/
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

/****** Object:  Index [HotelI2]    Script Date: 7/9/2015 12:18:22 PM ******/
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

/****** Object:  Index [HotelI3]    Script Date: 7/9/2015 12:18:25 PM ******/
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

/****** Object:  Index [HotelPX]    Script Date: 7/9/2015 12:18:27 PM ******/
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

/****** Object:  Index [Employee_I1]    Script Date: 7/9/2015 12:18:27 PM ******/
CREATE NONCLUSTERED INDEX [Employee_I1] ON [DBA].[Employee]
(
	[GPN] ASC
)
INCLUDE ( 	[PaxName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/9/2015 12:18:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI2]    Script Date: 7/9/2015 12:18:29 PM ******/
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

/****** Object:  Index [CarPX]    Script Date: 7/9/2015 12:18:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CarPX] ON [DBA].[Car]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/9/2015 12:18:31 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [DBA].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/9/2015 12:18:31 PM ******/
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

/****** Object:  Index [TransegPX]    Script Date: 7/9/2015 12:18:31 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [DBA].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/9/2015 12:18:33 PM ******/
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

