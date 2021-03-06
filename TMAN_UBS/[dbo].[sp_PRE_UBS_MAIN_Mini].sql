/****** Object:  StoredProcedure [dbo].[sp_PRE_UBS_MAIN_Mini]    Script Date: 7/14/2015 7:39:24 PM ******/
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
--=================================
--Added by rcr  07/13/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)
--==------------------------------------------------------------------------------------------------------------------------------
 ----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_START - END
************************************************************************/ 
--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
--Log Activity
WAITFOR DELAY '00:00.30'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-Stored Procedure Start'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

------
---- Update Curr code in Invoicedetail in case we missing something in Currency Conversion
-- this will only happen when the total amt is 0 or NULL --

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update id
set currcode = 'USD'
from dba.invoicedetail id, dba.invoiceheader ih
where id.currcode <> 'USD' and isnull(totalamt,0) = 0 and id.iatanum = 'preubs'
and id.recordkey = ih.recordkey and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update id - currcode = USD'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update id
set totalamt = 0
from dba.invoicedetail id, dba.invoiceheader ih
where totalamt is null  and id.iatanum = 'preubs'
and id.recordkey = ih.recordkey and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update id - totalamt = 0'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--GPN Padding
update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where i.iatanum = 'PREUBS' and len(remarks2) <> 8  and remarks2 <> 'Unknown'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') GPN Padding'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Transaction updates -- Update the remarks field to Unknown'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update i
set remarks2 = corporatestructure
from dba.invoicedetail i, dba.rollup40 u, dba.comrmks c
where i.recordkey = c.recordkey and i.IataNum  = c.IataNum and i.ClientCode = c.ClientCode
and i.IssueDate = c.IssueDate and i.SeqNum = c.SeqNum and u.COSTRUCTID = 'functional' 
and c.Text30 = corporatestructure  and i.Remarks2 = 'Unknown' 
and i.IataNum = 'PREUBS' and c.IataNum = 'PREUBS' 

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 2-Update remarks2 GPN Number'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-- Update Remarks2 with Unknown when remarks2 is NULL
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i, dba.invoiceheader ih
where i.Remarks2 is null and i.IATANUM = 'PREUBS' and ih.IataNum = 'PREUBS'
and i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Remarks2 with Unknown when remarks2 is NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
--CAR -- Update remarks from invoicedetail remarks

--SET @TransStart = getdate()

update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3, car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car, dba.invoiceheader ih
where i.recordkey = car.recordkey  and i.seqnum = car.seqnum  and i.iatanum = car.iatanum 
and i.ClientCode = car.ClientCode and i.IssueDate = car.IssueDate and i.recordkey = ih.recordkey
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate 
and i.iatanum = 'PREUBS' and ih.IataNum = 'PREUBS' and car.IataNum = 'PREUBS'
and ih.importdt > getdate()-1

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-Update remarks in car from ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 4-Update remarks in car from ID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
--HOTEL -- Update remarks from invoicedetail remarks

--SET @TransStart = getdate()

update h
set h.remarks1 = i.remarks1, h.remarks2 = i.remarks2, h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h, dba.invoiceheader ih
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum 
and i.ClientCode = h.ClientCode and i.IssueDate = h.IssueDate and i.recordkey = ih.recordkey 
and i.iatanum = ih.iatanum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and i.iatanum = 'PREUBS' and h.IataNum = 'PREUBS' and ih.IataNum ='PREUBS' 
and ih.importdt > getdate()-1

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-Update remarks in hotel from ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 5-Update remarks in hotel from ID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--Update Hotel reasoncode1, if incorrect, from BCD's MAX codes

--SET @TransStart = getdate()

update h
set htlreasoncode1 = case 
when htlreasoncode1 = 'HN' then 'X1' when htlreasoncode1 = 'XH' then 'X2' when htlreasoncode1 = 'HX' then 'X4'
when htlreasoncode1 = 'HC' then 'X7' when htlreasoncode1 = 'HH' then Null end
from dba.hotel h
where h.iatanum = 'PREUBS' 
and h.HtlReasonCode1 in ('HN','XH','HX','HC','HH')

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6-Update hotel reason codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 6-Update hotel reason codes'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--
--Update the comrmks with LastUpdateDate for New Bookings flag
-- need to substring udefdata to 150

--SET @TransStart = getdate()

update cr
set cr.text19 = substring(ud.udefdata,1,150)
from dba.comrmks cr, dba.udef ud, dba.invoiceheader ih
WHERE cr.recordkey = ud.recordkey and cr.iatanum = ud.iatanum  and cr.clientcode = ud.clientcode 
and cr.IssueDate = ud.IssueDate and cr.recordkey = ih.recordkey and cr.IataNum = ih.IataNum
and cr.InvoiceDate = ih.InvoiceDate and cr.ClientCode = ih.ClientCode
and cr.iatanum = 'PREUBS' and ud.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS' and ud.udeftype = 'LASTUPDATE' 
and ud.udefnum = '999'  and cr.Text19 is null
and ih.importdt > getdate()-1

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Text 19',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 7-Update Text 19'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
----------------------------------------------------------------------------------
--Update the comrmks with the Travelers Name from the Hierarchy table provided by UBS.

--SET @TransStart = getdate()

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Tex20 with the Traveler Name from the Hierarchy File'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Text 20',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 7-Update Text 20'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update reasoncodes (air,car,hotel) to Null'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update h
set htlreasoncode1 = NULL
from dba.hotel h, dba.invoiceheader ih
where h.recordkey = ih.recordkey and h.IataNum = ih.IataNum and h.ClientCode = ih.ClientCode
and h.InvoiceDate = ih.InvoiceDate and h.htlreasoncode1 = '*'  and h.IataNum = 'PREUBS'
and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') htlreasoncode1 = NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update c
set carreasoncode1 = NULL
from dba.car c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum
and c.ClientCode = ih.ClientCode and c.InvoiceDate = ih.InvoiceDate
and c.carreasoncode1 = '*'  and c.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') carreasoncode1 = NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update reasoncode1 when no air',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update reasoncode1 when no air'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Updating the farecomare2'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--


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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Start Split Ticket Updates for Farecompare2, ReasonCode1, and TotalAmt'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update id
set reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,6)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,26,6)  like '[0-9][0-9][0-9][.][0-9][0-9]' and id.invoicedate > '11/1/2013'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,6)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,25,6)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and  substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,25,6) not like '%/%' 

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,25,6)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,24,5)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,24,5) not like '%/%' 

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,24,5)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,23,4)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and  substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,23,4) not like '%/%' 

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,23,4)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

------------------------------update Total amount for Exchanges  --KP/11/20/2013 #14059

update id
set totalamt = convert(float,substring(udefdata,18,8))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,7) like '%[0-9][0-9][0-9][0-9][0-9].%' --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') totalamt = convert(float,substring(udefdata,18,8))'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update id
set totalamt = convert(float,substring(udefdata,18,7))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,6) like '%[0-9][0-9][0-9][0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') totalamt = convert(float,substring(udefdata,18,7))'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update id
set totalamt = convert(float,substring(udefdata,18,6))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,7) like '%[0-9][0-9][0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  totalamt = convert(float,substring(udefdata,18,6))'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update id
set totalamt = convert(float,substring(udefdata,18,5))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,4) like '%[0-9][0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') totalamt = convert(float,substring(udefdata,18,5))'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update id
set totalamt = convert(float,substring(udefdata,18,4))
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,18,4) like '%[0-9].%'  --and id.invoicedate > '11/1/2013'
and ((right(udefdata,2) = 'EX') or (totalamt = '0')) --and exchangeind = 'y'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Splittkt exch update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') End Splittkt exch update'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-------- Updating the farecompare2 to = 0 when no reasoncode is provided
-------- per UBS instruction on the 9/6/2012 call ... LOC
update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.ReasonCode1 is NULL 
and i.ServiceDate > getdate()-50 and substring(i.recordkey,15,4)<> 'R539'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Updating the farecompare2 to = 0 when no reasoncode is provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-- This will set the fare compare to 0 where there is no fare null or 0
update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.TotalAmt = '0' 
and i.ServiceDate > getdate()-50 and substring(i.recordkey,15,4)<> 'R539'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set the fare compare to 0 where there is no fare 0'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.TotalAmt is null
and i.ServiceDate > getdate()-50 and substring(i.recordkey,15,4)<> 'R539'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') set the fare compare to 0 where there is no fare null'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--This will set the fare comapre for all in policy records to = the total amt
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.reasoncode1 like 'a%'  and i.FareCompare2 <> i.TotalAmt
and substring(documentnumber,7,4) not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS')
and servicedate > getdate() -50

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set the fare comapre for all in policy records to = the total amt'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Records with Multiple Tickets(B) to = Total Amount to create a 0 Missed Savings'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') This will update the 2nd ticket'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') This changes the 3nd ticket to = total amount'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Fare Compare Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Fare Compare Updates Complete'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--approved by UBS to set anything within $5 threshold to have 0 savings to help with negative sav amts
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where abs(farecompare2) -abs(totalamt) between .5 and 5
and iatanum = 'preubs'
and servicedate > getdate() -50

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set anything within $5 threshold to have 0 savings'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where abs(farecompare2) >abs(totalamt) 
and iatanum = 'preubs'
and servicedate > getdate() -50

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set farecompare2 = totalamt'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
---------- Mapping BCD reasoncode to UBS reasoncodes
--SET @TransStart = getdate()
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Mapping BCD reasoncode to UBS reasoncodes'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text 11'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

---------------Update Text 17 where Pending is the value----------------
update c
set text17 = NULL
from dba.comrmks c, dba.invoiceheader ih
where c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode and c.InvoiceDate = ih.InvoiceDate
and c.RecordKey = ih.RecordKey and ih.iatanum = 'preubs'  and c.IataNum = 'preubs' and c.Text17 = 'Pending' 
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text 17 where Pending is the value'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update document number where one supplied in Secure Ticket remark'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Doc Num Updates Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Doc Num Updates Complete'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--


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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text17 (TractID) to N/A  -- (c.Text17 = O) or (c.text17 = A)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
Update c
set Text17 = 'N/A'
from dba.comrmks c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode 
and c.InvoiceDate = ih.InvoiceDate and c.Text17 is null  and c.iatanum = 'preubs'
and ih.IataNum = 'preubs'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text17 (TractID) to N/A  -- c.Text17 is null'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
Update c
set Text17 = 'N/A'
from dba.comrmks c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode
and c.InvoiceDate = ih.InvoiceDate and c.Text17 in ('11111','111111','1111111')  and c.iatanum = 'preubs'
and ih.IataNum = 'preubs'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text17 (TractID) to N/A  -- c.Text17 in (11111,111111,1111111)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update hotel date where date diff is greater than 100'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update h
set checkindate = checkindate-366, checkoutdate = checkoutdate-366
from dba.hotel h, dba.invoiceheader ih
where h.IataNum = ih.IataNum  and h.ClientCode = ih.ClientCode
and h.InvoiceDate = ih.InvoiceDate and h.RecordKey = ih.RecordKey
and h.IataNum = 'preubs' and ih.IataNum = 'preubs' and datediff (dd,h.issuedate, h.checkoutdate) > 366
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') checkindate = checkindate-366, checkoutdate = checkoutdate-366'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Total amount to = U27 and Farecompare2 = U28 for BCDUS'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Set Total amount to = U27 and Farecompare2 = U28 for BCDEU'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
---- To ensure any bookings that have had the air changed but not the hotel are still connected..LOC/2/19/2013
update h
set  h.seqnum = i2.seqnum, h.issuedate = i2.issuedate
from dba.invoicedetail i1, dba.invoicedetail i2, dba.hotel h
where i1.recordkey = h.recordkey and i1.recordkey = i2.recordkey  and i1.seqnum = h.seqnum 
and i1.IataNum = 'preubs' and i2.IataNum = 'preubs' and h.IataNum = 'preubs' and i1.voidind = 'y' 
and i2.voidind ='n' and i1.servicedate > '1-1-2014'


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') To ensure any bookings that have had the air changed but not the hotel are still connected'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- The queries below are for the flagging of Refundable / Non Refunadable tickets
-------- BCD Americas is mapped from the G4 and then changed when necessary
-------- The code will first flag Hotel and Car only transactions as Not Required
-------- Then we look for specific text in the endorsement boxes to flag for Non Refundable tickets
-------- Then we will look for the Fare Type in the EMEA Data from BCD and flag per the codes
-------- When ticket number is present and no endorsements the R
-------- When ClientCode 6631020201 then use G4 only.
-------- When low cost carriers then G4 Only.
-------- When no ticket and no endorsement then N.

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text9 Updates Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Text9 Updates Start'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Update Text9 = Not Required for Hotel and Car Only Transactions --- LOC/1/15/2014
---------------------Hotel Only ---------------------------

update c
set Text9 = 'Not Required'
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.iatanum = 'preubs' and isnull(text9,'Not Provided') in ('Not Provided','Not Valid','N','R')
and i.recordkey in (select recordkey from dba.hotel)
and i.recordkey not in (select recordkey from dba.transeg)
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') -Hotel Only - Text9 = Not Required'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

------------------Car Only -------------------------------
update c
set Text9 = 'Not Required'
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and vendortype not in ('bsp','nonbsp','rail') and i.iatanum = 'preubs'
and isnull(text9,'Not Provided') in ('Not Provided','Not Valid','N','R')
and i.recordkey in (select recordkey from dba.car)
and i.recordkey not in (select recordkey from dba.transeg)

--SET @TransStart = getdate()
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') - Car Only - Text9 = Not Required'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TEXT 9 TO N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 --SET @TransStart = getdate()
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') TEXT 9 TO N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Process for EMEA - Text9 = R'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update c
set Text9 ='N' 
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and text47 in ('N','1C','2C','3C''1R','2R','3R','1B','2B','3B','1V','2V','3V','1Q','2Q','3Q','1L','3','4','5','7','8')
and c.iatanum = 'preubs' and isnull(text9,'R') = 'R' --and documentnumber is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Process for EMEA - Text9 = N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Updating to R when ticket number is present and no endorsements or code from BCD ---
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Updating to R when ticket number is present and no endorsements or code from BCD  - Text9 = R'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Updating to R when ticket number is present and no endorsements or code from BCD  - Text9 = R'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Update Low Cost Carriers using the G4 field as endorsements do not come over in the PNRs - Text9 = Udefdata'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
---------------- For Apollo -------------------------------
Update c
set Text9 = substring(Udefdata,4,1)
from dba.comrmks c, dba.udef u, dba.invoicedetail i
where c.recordkey = u.recordkey and c.seqnum = u.seqnum and c.iatanum = u.iatanum
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and voidind = 'n' and c.iatanum = 'preubs' and udefdata like 'G4-%' and 
isnull(substring(Udefdata,4,1),'X') in ('r','u','n') and i.valcarriercode in ('FL','WN','F9','NK','B6')
and isnull(Text9,'X') <> substring(Udefdata,4,1)

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  For Apollo -- Text9 = substring(Udefdata,4,1)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

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


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TEXT 9 TO R IF NOT N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') TEXT 9 TO R IF NOT N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--testing moving to the end to see if something is undoing this update...set the fare comapare for all in policy records to = the total amt
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.reasoncode1 like 'a%'  and i.FareCompare2 <> i.TotalAmt
and substring(documentnumber,7,4) not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS')
and servicedate > getdate() -50

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End UBS Pre Main Mini SP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') End UBS Pre Main Mini SP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

WAITFOR DELAY '00:00.30' 
--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 
GO
