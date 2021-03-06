/****** Object:  StoredProcedure [dbo].[sp_PRE_UBS_MAIN]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PRE_UBS_MAIN]
@RequestName varchar(50) = NULL --For DEA
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--=================================
--Added by rcr  07/10/2015
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

--Log Activity
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 ----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----

/************************************************************************
	LOGGING_START - END
************************************************************************/ 
--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
--Log Activity
WAITFOR DELAY '00:00.30'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-Stored Procedure Start'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----
---- Update Curr code in Invoicedetail in case we missing something in Currency Conversion
-- this will only happen when the total amt is 0 or NULL --

--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update id
set currcode = 'USD'
from dba.invoicedetail id, dba.invoiceheader ih
where id.currcode <> 'USD' and isnull(totalamt,0) = 0 and id.iatanum = 'preubs'
and id.recordkey = ih.recordkey and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1

----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update id - currcode = USD'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update id
set totalamt = 0
from dba.invoicedetail id, dba.invoiceheader ih
where totalamt is null  and id.iatanum = 'preubs'
and id.recordkey = ih.recordkey and id.iatanum = ih.iatanum
and id.InvoiceDate = ih.InvoiceDate and id.ClientCode = ih.ClientCode
and ih.importdt > getdate()-1

----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update id - totalamt = 0'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update car
set car.issuedate = id.issuedate
from dba.car car, dba.invoicedetail id, dba.invoiceheader ih
where car.issuedate <> id.issuedate AND id.RecordKey = car.RecordKey 
AND id.IataNum = car.IataNum AND id.SeqNum = car.SeqNum 
AND id.ClientCode = car.ClientCode and id.recordkey = ih.recordkey 
and id.IataNum = ih.IataNum and id.ClientCode = ih.ClientCode
and id.iatanum ='PREUBS' and ih.IataNum = 'PREUBS' and car.IataNum = 'PREUBS'
and ih.importdt > getdate()-1

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car issuedate',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update car issuedate'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update htl
set htl.issuedate = id.issuedate
from dba.hotel htl, dba.invoicedetail id, dba.invoiceheader ih
where htl.issuedate <> id.issuedate AND id.RecordKey = htl.RecordKey 
AND id.IataNum = htl.IataNum AND id.SeqNum = htl.SeqNum AND id.ClientCode = htl.ClientCode 
and id.recordkey = ih.recordkey and id.IataNum = ih.IataNum and id.ClientCode = ih.ClientCode
and id.iatanum ='PREUBS' and ih.IataNum = 'PREUBS' and htl.IataNum = 'PREUBS'
and ih.importdt > getdate()-1

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel issue date',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update hotel issue date'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--

--GPN Padding
update i
set remarks2 = right('00000000'+Remarks2,8)
from dba.invoicedetail i
where i.iatanum = 'PREUBS' and len(remarks2) <> 8  and remarks2 <> 'Unknown'
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') GPN Padding'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
-- Update Text30 with any values in the remarks2 field that are not in the GPN list
update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where i.remarks2 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and c.recordkey = i.recordkey and c.IataNum = i.IataNum and c.ClientCode = i.ClientCode
and c.IssueDate = i.IssueDate and c.seqnum = i.seqnum    and c.Text30 is null 
and c.IATANUM = 'PREUBS' and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and i.recordkey = ih.recordkey and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and i.IataNum = ih.IataNum  --and ih.importdt > getdate()-1

----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text30 with any values '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update c 
set text30 = remarks2
from  dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where i.remarks2 like '999999%'
and c.recordkey = i.recordkey and c.IataNum = i.IataNum and c.ClientCode = i.ClientCode
and c.IssueDate = i.IssueDate and c.seqnum = i.seqnum    and c.Text30 is null 
and c.IATANUM = 'PREUBS' and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and i.recordkey = ih.recordkey and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and i.IataNum = ih.IataNum  and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') text30 = remarks2'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--

----- Transaction updates
-- Update the remarks field to Unknown when the remarks2 value is not in the GPN list
--***********************************************************************************************************
-------- I have removed the Iatanum from this query and added uped the importdt to -180.  This will go back 180 days and update
-------- the unknows.  This way it will catch any Back Office updates that need to be made on a daily basis.  This should
-------- resolve the "mismatched" Executive Summary numbers .. LOC/5/14/2015.
update i
set remarks2 = 'Unknown'
from dba.invoicedetail i, dba.invoiceheader ih
where i.Remarks2 not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional') 
--and i.IATANUM = 'PREUBS' and ih.IataNum = 'PREUBS' 
and i.recordkey = ih.recordkey 
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and ih.importdt > getdate()-180
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') remarks2 = Unknown'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 2-Update remarks2 GPN Number'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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

--Set ReasonCode1 with specific values using BCD's MAX codes


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-Update reasoncode1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 3-Update reasoncode1 '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
--CAR -- Update remarks from invoicedetail remarks

SET @TransStart = getdate()

update car
set car.remarks1 = i.remarks1, car.remarks2 = i.remarks2, car.remarks3 = i.remarks3, car.remarks5 = i.remarks5
from dba.invoicedetail i, dba.car car, dba.invoiceheader ih
where i.recordkey = car.recordkey  and i.seqnum = car.seqnum  and i.iatanum = car.iatanum 
and i.ClientCode = car.ClientCode and i.IssueDate = car.IssueDate and i.recordkey = ih.recordkey
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate 
and i.iatanum = 'PREUBS' and ih.IataNum = 'PREUBS' and car.IataNum = 'PREUBS'


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4-Update remarks in car from ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 4-Update remarks in car from ID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
--HOTEL -- Update remarks from invoicedetail remarks

SET @TransStart = getdate()

update h
set h.remarks1 = i.remarks1, h.remarks2 = i.remarks2, h.remarks3 = i.remarks3, h.remarks5 = i.remarks5
from dba.invoicedetail i, dba.hotel h, dba.invoiceheader ih
where i.recordkey = h.recordkey and i.seqnum = h.seqnum and i.iatanum = h.iatanum 
and i.ClientCode = h.ClientCode and i.IssueDate = h.IssueDate and i.recordkey = ih.recordkey 
and i.iatanum = ih.iatanum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and i.iatanum = 'PREUBS' and h.IataNum = 'PREUBS' and ih.IataNum ='PREUBS' 


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-Update remarks in hotel from ID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 5-Update remarks in hotel from ID'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 6-Update hotel reason codes'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--

--
--- Update Porter Airlines in ID table

update i
set valcarriercode = 'PD', vendorname = 'PORTER AIRLINES', valcarriernum = '329'
from dba.transeg t, dba.invoicedetail i, dba.invoiceheader ih
where valcarriercode <> 'pd' and segmentcarriercode = 'pd'
and t.recordkey = i.recordkey  and t.seqnum = i.seqnum  and t.IataNum = t.IataNum
and t.ClientCode = i.ClientCode and t.IssueDate = i.IssueDate and i.recordkey = ih.recordkey 
and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate
and t.iatanum = 'PREUBS' and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Porter Airlines in ID table'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
--
update t 
set typecode = 'R'
from dba.transeg t, dba.invoiceheader ih
where segmentcarriercode in ('9b','9f','2v','2r','TTL','ES','DB') and typecode <>'R' 
and t.recordkey = ih.recordkey and t.IataNum = ih.IataNum and t.ClientCode = ih.ClientCode
and t.InvoiceDate = ih.InvoiceDate and t.iatanum = 'PREUBS' and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') typecode = R'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
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

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Text 19',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 7-Update Text 19'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update the comrmks with the Travelers Name'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 7-Update Text 20'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
insert into dba.client
select DISTINCT i.clientcode,'PREUBS',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from dba.invoicedetail i, dba.invoiceheader ih
where i.clientcode not in (select clientcode from dba.client where iatanum = 'PREUBS') 
and i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.iatanum = 'PREUBS' and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') insert into dba.client'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
------Update Text5 with the region 
update c
set c.text5 = r.rollup2
from dba.rollup40 r, dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
where i.recordkey = ih.recordkey  and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and c.recordkey = i.recordkey   and c.iatanum = i.iatanum
and c.seqnum = i.seqnum  and c.ClientCode = i.ClientCode and c.IssueDate = i.IssueDate
and c.IATANUM = 'PREUBS' and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and r.corporatestructure = i.remarks2  and i.remarks2 not like ('99999%')
and r.costructid = 'GEO'  and c.text5 is null
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text5 with the region '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update c
set c.text5 = case when ih.origcountry in ('AT','AE','BE','CZ','FR','DE','HU','IL','IT','LU','NL','PL','RU','ES','SA','SE','CH','TR','GB','ZA') then 'Europe EMEA'
when ih.origcountry in ('AU','CN','HK','ID','IN','JP','MY','NZ','PH','KR','SG','TW','TH') then 'Asia Pacific'
when ih.origcountry in ('US','CA','BR') then 'Americas'
else 'Unknown' end
from  dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
where  i.recordkey = ih.recordkey and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and c.recordkey = i.recordkey   and c.iatanum = i.iatanum
and c.seqnum = i.seqnum and c.ClientCode = i.ClientCode and c.IssueDate = i.IssueDate
and c.IATANUM = 'PREUBS' and i.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS' and c.text5 is null
and ih.importdt > getdate()-1

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Text 5',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 7-Update Text 5 '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  update reasoncodes - reasoncode1 = NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update h
set htlreasoncode1 = NULL
from dba.hotel h, dba.invoiceheader ih
where h.recordkey = ih.recordkey and h.IataNum = ih.IataNum and h.ClientCode = ih.ClientCode
and h.InvoiceDate = ih.InvoiceDate and h.htlreasoncode1 = '*'  and h.IataNum = 'PREUBS'
and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  htlreasoncode1 = NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update c
set carreasoncode1 = NULL
from dba.car c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum
and c.ClientCode = ih.ClientCode and c.InvoiceDate = ih.InvoiceDate
and c.carreasoncode1 = '*'  and c.IataNum = 'PREUBS' and ih.IataNum = 'PREUBS'
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  carreasoncode1 = NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
-- Set value to null if not in the "online" list

update i
set onlinebookingsystem = NULL
from dba.invoicedetail i, dba.invoiceheader ih
where onlinebookingsystem not in (select lookupvalue
	from dba.lookupdata where lookupname = 'online' and lookuptext= 'online')
and i.recordkey = ih.recordkey  and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate and i.iatanum = 'preubs' and ih.IataNum = 'preubs' 
and ih.importdt > getdate()-1
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  onlinebookingsystem = NULL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
-- Set to null if not in the Trip Purpose list -- copying invalid value to
-- text50 in comrmks first.
update c
set text50 = remarks1
from dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
where i.recordkey = c.recordkey and i.seqnum = c.seqnum  and i.ClientCode = c.ClientCode
and i.IssueDate = c.IssueDate and i.recordkey = ih.recordkey  and i.IataNum = ih.IataNum
and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate 
and i.iatanum = 'preubs' and c.IataNum = 'preubs' and ih.IataNum = 'preubs'
and i.Remarks1 not in (select lookupvalue from dba.lookupdata 	where lookupname = 'trippur') 
and c.Text50 is null
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  text50 = remarks1'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update i
set remarks1 = NULL
from dba.invoicedetail i, dba.invoiceheader ih
where i.recordkey = ih.recordkey  and i.IataNum = ih.IataNum and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate  and i.iatanum = 'preubs' and ih.IataNum = 'preubs' 
and i.remarks1 not in (select lookupvalue from dba.lookupdata where lookupname = 'trippur') 

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text1 - Trip Purpose',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Update Text1 - Trip Purpose'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Update reasoncode1 when no air'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update reasoncode1 when no air',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  farecompare2 = 0'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,7)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update id
set reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,6)
from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,26,6)  like '[0-9][0-9][0-9][.][0-9][0-9]' and id.invoicedate > '11/1/2013'
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  reasoncode1 = right(udefdata,2), farecompare2 = substring(udefdata,26,6)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,25,6)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and  substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,25,6) not like '%/%' 
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,25,6)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,24,5)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,24,5) not like '%/%' 
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,24,5)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
update id
set reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,23,4)
from dba.invoicedetail id, dba.udef u 
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' and id.invoicedate >'2013-11-01' 
and udeftype = 'TK RMKS' and  substring(udefdata,13,4) = substring(documentnumber,7,4)
and substring(udefdata,23,4) not like '%/%' 
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') reasoncode1 = right(udefdata,2), farecompare2 =substring(udefdata,23,4)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
----Added by rcr  07/10/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') totalamt = convert(float,substring(udefdata,18,8))'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----


--Added by rcr  07/10/2015
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') totalamt = convert(float,substring(udefdata,18,6))'
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') End Splittkt exch update'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Splittkt exch update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Updating the farecompare2 to = 0 when no reasoncode is provided
-------- per UBS instruction on the 9/6/2012 call ... LOC
update i
set farecompare2 = '0'
from dba.invoicedetail i
where  i.iatanum = 'preubs' 
and i.ReasonCode1 is NULL and i.ServiceDate > '12-10-2013' and substring(i.recordkey,15,4)<> 'R539'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') farecompare2 to = 0 when no reasoncode'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-- This will set the fare compare to 0 where there is no fare (null or 0)
update i
set farecompare2 = '0'
from dba.invoicedetail i
where i.iatanum = 'preubs' and i.TotalAmt = '0' 
and i.ServiceDate > '12-10-2013' and substring(i.recordkey,15,4)<> 'R539'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') fare compare to 0 where there is no fare'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') fare compare2 to 0 '
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
and recordkey not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS')
and servicedate > getdate() -50

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') fare comapre for all in policy records to = the total amt'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update the 1st Ticket - Set Records with Multiple Tickets(B) to = Total Amount to create a 0 Missed Savings'
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
set farecompare2 = TOTALAMT
from dba.invoicedetail i
where i.ReasonCode1 like 'b%'  and i.farecompare2 > totalamt
and i.IataNum = 'preubs' 
and recordkey not in (select i.recordkey from dba.udef u, dba.invoicedetail i 
	where u.recordkey = i.recordkey and u.seqnum = i.seqnum and substring(documentnumber,7,4) = substring(udefdata,13,4) 
	and udeftype = 'TK RMKS')
and servicedate > getdate() -50
---approved by UBS to set anything within $5 threshold to have 0 savings to help with negative sav amts

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') farecompare to equal the total amount ->OOP Reason code<-'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update i
set farecompare2 = totalamt
from dba.invoicedetail i
where abs(farecompare2) -abs(totalamt) between .01 and 5
and iatanum = 'preubs'
and servicedate > getdate() -350

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') farecompare2 = totalamt --- abs(farecompare2) -abs(totalamt) between .01 and 5'
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
and servicedate > getdate() -350

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') farecompare2 = totalamt --- abs(farecompare2) >abs(totalamt)'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-------- Mappings from BCD to UBS reason codes ----------------------
SET @TransStart = getdate()
Update i
set reasoncode1 = case when reasoncode1 = 'PC' then 'A1'
when reasoncode1 = 'UG' then 'A4' when reasoncode1 = 'NR' then 'A6'
when reasoncode1 = 'BC' then 'B1' when reasoncode1 = 'CP' then 'B2'
when reasoncode1 = 'ST' then 'B3' when reasoncode1 = 'AP' then 'B5'
when reasoncode1 = 'MI' then 'B6' when reasoncode1 = 'NO' then 'B7'
when reasoncode1 = 'CC' then 'B8' when reasoncode1 in('RB','XX','EX') then 'A1'
end 
from dba.invoicedetail i, dba.invoiceheader ih
where i.iatanum = 'PREUBS' and ih.IataNum = 'PREUBS'
and i.ReasonCode1 in ('PC','UG','NR','BC','CP','ST','AP','MI','NO','CC','RB','XX','EX')
and i.recordkey = ih.recordkey  and i.IataNum = ih.IataNum
and i.ClientCode = ih.ClientCode and i.InvoiceDate = ih.InvoiceDate

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Mappings from BCD to UBS reason codes'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text 17'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update document number -- documentnumber=substring(substring (udefdata,1,charindex(/,udefdata)-1),1,15)'
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update document number -- documentnumber = ACCESS DENIED'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

------------Update text15 with Secure Ticket GDS Remarks ------------------
update cr
set cr.text15 = substring(u.udefdata,1,150)
from dba.udef u,dba.comrmks cr, dba.invoiceheader ih
WHERE cr.recordkey = ih.recordkey and cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
and cr.InvoiceDate = ih.InvoiceDate and cr.recordkey = u.recordkey  and cr.seqnum = u.seqnum
and cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode and cr.IssueDate = u.IssueDate
and u.iatanum = 'preubs' and cr.IataNum = 'preubs' and ih.iatanum = 'preubs'
and u.udeftype = 'SECUREDTICKET'
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update text15 with Secure Ticket GDS Remarks'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
------ Update Text15 to Null where Secure Ticket remarks are there but we do have the 
------ ticket number and the fare.  This can occur if at the time we are trying to read the PNR
------ the system is down or a refund/exchange has occured to the record.  -- This way these
------ records do not show in the validation reports as unable to access when we actually have
------ the data in the database.... LOC/9/6/2012
update c
set text15 = NULL
from dba.comrmks c, dba.invoicedetail i, dba.invoiceheader ih
where c.recordkey = ih.recordkey and c.IataNum = ih.IataNum and c.ClientCode = ih.ClientCode
and c.InvoiceDate = ih.InvoiceDate and c.recordkey = i.recordkey  and c.seqnum = i.seqnum
and c.IataNum = i.IataNum and c.ClientCode = i.ClientCode and c.IssueDate = i.IssueDate
and i.iatanum = 'preubs' and c.IataNum = 'preubs' and ih.iatanum = 'preubs'
and c.text15 is not NULL and i.DocumentNumber not like '%access%'  and i.TotalAmt > 0 
and i.VoidInd = 'n'
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text15 to Null'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

---- Update Americas and EMEA with "Already seen" flag in Text 11 at 9:30 AM on Tuesday and Thursday
--------Not sure why this is in the Main as it is in the update SP .. LOC/9/12/2012
--update c
--set  text16 = getdate()
--from dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
--where i.recordkey = c.recordkey and i.seqnum = c.seqnum
--and i.recordkey = ih.recordkey
--and i.voidind = 'N'
--and i.refundind = 'N'
--and i.exchangeind = 'N'
--and i.remarks2 <> 'Unknown'
--and isnull(text21,'xx') not like '%hold%'
--and i.iatanum = 'Preubs'
--and importdt <= getdate()
--and text16 is null

-- Update Text17 (TractID) to N/A where the value does not appear to be a TractID.------
----- commented out the ones with spaces per Ryan and team 8/22/2012 ------ 
update c
set Text17 = 'N/A'
from dba.comrmks c
where isnull(c.Text17,'X') like '%' and not ((c.Text17  like '[1-9][0-9][0-9][0-9][0-9]') or 
(c.Text17 like '[1-9][0-9][0-9][0-9][0-9][0-9]') or (c.Text17 like '[1-9][0-9][0-9][0-9][0-9][0-9][0-9]') 
or(c.text17 like '[0-9][0-9][A-Z][A-Z][A-Z][1-9][0-9]')
or (c.Text17 = 'O') or (c.text17 = 'A')) 
and c.iatanum = 'preubs' 
and c.Text17 <> 'N/A'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text17 (TractID) to N/A '
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text17 to N/A  -- c.Text17 is null'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text17 to N/A  -- c.Text17 in (11111,111111,1111111) '
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update hotel date where date diff is greater than 100 '
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update hotel -- checkindate = checkindate-366 '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

----- Update void ind to Y when we have 2 entries in the invoicedetail for the same record
-- this is happening when we receive a PNR and them months later get it again as Correx removes
-- PNR's from their db when they have not been 'seen' in X number of days (even if they are still active).
-- working with Correx to see if they can change this .. LOC /7/26/2012
update i1
set voidind = 'Y'
from dba.invoicedetail i1, dba.invoicedetail i2, dba.invoiceheader ih1, dba.invoiceheader ih2
where substring(i1.recordkey,1,charindex('-',i1.recordkey)-1) = substring(i2.recordkey,1,charindex('-',i2.recordkey)-1)
and i1.recordkey <> i2.recordkey and i1.recordkey = ih1.recordkey and i1.IataNum = ih1.IataNum
and i1.ClientCode = ih1.ClientCode and i1.InvoiceDate = ih1.invoicedate and i2.recordkey = ih2.recordkey
and i2.IataNum = ih2.IataNum and i2.ClientCode = ih2.ClientCode and i1.InvoiceDate = ih2.invoicedate
and substring(ih1.recordkey,1,charindex('-',ih1.recordkey)-1) =
	substring(ih2.recordkey,1,charindex('-',ih2.recordkey)-1)
and i1.iatanum = 'preubs' and i2.iatanum = 'preubs' and ih1.iatanum = 'preubs' 
and ih2.iatanum = 'preubs' and i1.voidind = 'n' and i2.voidind = 'n'  
and datediff(dd,ih1.importdt, ih2.importdt) > 100 and ih1.importdt  < ih2.importdt
and i1.InvoiceDate is not null
and ih1.InvoiceDate is not null
and ih2.importdt > getdate()-1
------- runs in 4secs

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Update void ind to Y when we have 2 entries in the invoicedetail'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

---------- Booker GPN Validation ---When NULL------------------LOC/8/3/2012
---------- Per Case #19007 added more logic for nulls----------TBo/7/30/2013
update c
set text8 = 'Not Provided'
from dba.comrmks c, dba.invoiceheader ih
where c.RecordKey = ih.RecordKey and c.IataNum = ih.IataNum and c.InvoiceDate = ih.InvoiceDate
and c.ClientCode = ih.ClientCode and c.IataNum = 'preubs' and ih.IataNum = 'preubs'
and c.Text8 is NULL
and isnull(text8,'Not') like 'Not%'
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Booker GPN Validation ---When NULL--text8 = Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

---------- Booker GPN Validation ----When Invalid-----------------LOC/8/3/2012
update c
set text8 = 'Not Valid'
from dba.comrmks c, dba.InvoiceHeader IH
where c.RecordKey = ih.RecordKey and c.IataNum = ih.IataNum and c.InvoiceDate = ih.InvoiceDate
and c.ClientCode = ih.ClientCode and c.IataNum = 'preubs' and ih.IataNum = 'preubs'
and c.Text8 <> 'Not Provided'
and c.Text8 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ')  Booker GPN Validation ---When Invalid --text8 = Not Valid'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-------- Booker Name update to Text1 ------- LOC/7/25/2013
--Updated max length to 150 25NOV2013/ss
update c
set text1 = substring(r.description,charindex('-',r.description)+1,150)
from dba.comrmks c, dba.rollup40 r
where text8 = substring(r.description,1,8)
and costructid = 'functional' and text8 is not null and isnull(text1,'X') <> substring(r.description,charindex('-',r.description)+1,150)
and c.iatanum = 'preubs'


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Booker Name update to Text1'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

---------- Approver GPN Validation ------When Null---------------LOC/8/3/2012
---------- Per Case #19007 added more logic for nulls----------TBo/7/30/2013

update c
set text14 = 'Not Provided'
from dba.comrmks c
where c.IataNum = 'preubs'
and isnull(text14,'Not') like 'Not%'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Approver GPN Validation ------When Null --text14 = Not Provided'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

---------- Approver GPN Validation -----When Invalid----------------LOC/8/3/2012
update c
set text14 = 'Not Valid'
from dba.comrmks c
where c.IataNum = 'preubs'
and c.Text14 <> 'Not Provided'
and c.Text14 not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
-------------Approver GPN Validation ----- Not Provided but A% reasoncode ------ LOC/8/15/2012

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Approver GPN Validation ------When Null --text14 = Not Valid'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update c
set text14 = 'Not Applicable'
from dba.comrmks c, dba.invoicedetail i, dba.InvoiceHeader IH
where c.RecordKey = ih.RecordKey and c.IataNum = ih.IataNum and c.InvoiceDate = ih.InvoiceDate
and c.ClientCode = ih.ClientCode and i.RecordKey = ih.RecordKey and i.IataNum = ih.IataNum
and i.InvoiceDate = ih.InvoiceDate and i.ClientCode = ih.ClientCode and i.RecordKey = c.RecordKey
and i.IataNum = c.IataNum and i.ClientCode = c.ClientCode and i.IssueDate = c.IssueDate
and i.SeqNum = c.SeqNum and c.IataNum = 'preubs' and i.IataNum = 'preubs' and ih.iatanum = 'preubs'
and i.reasoncode1 like 'A%' and c.text14 like 'Not%'
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Approver GPN Validation ------When Null --text14 = Not Applicable'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

-------- Approver Name update to Text2 ------- LOC/7/25/2013
--Updated max length to 150 25NOV2013/ss
update c
set text2 = substring(r.description,charindex('-',r.description)+1,150)
from dba.comrmks c, dba.rollup40 r
where text14 = substring(r.description,1,8)
and costructid = 'functional' and text8 is not null and isnull(text2,'X') <> substring(r.description,charindex('-',r.description)+1,150)
and c.iatanum = 'preubs'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Approver Name update to Text2'
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
-------- Update Test PNR's to be Void and Unknown GPN to ensure they do not appear on reports 
-------- Using X as the Void Indicator so these can be found quickly if need be -- LOC/8/14/2012

update i
set voidind = 'X', remarks2 = 'Unknown'
from dba.invoicedetail i, dba.InvoiceHeader IH
where i.RecordKey = ih.RecordKey
and i.IataNum = ih.IataNum
and i.ClientCode = ih.ClientCode
and i.InvoiceDate = ih.InvoiceDate
and ((i.FirstName = 'William' and i.lastname = 'Never') or
		(i.Firstname = 'WY' and i.lastname = 'Trice') or
		(i.Firstname = 'Vernon' and i.lastname = 'Bear'))
and i.iatanum = 'preubs'
and i.voidind = 'n'
and ih.importdt > getdate()-1


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Test PNRs to be Void and Unknown GPN '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

--SET @TransStart = getdate()

-------- Update hotel and car dupe flags to N incase of data reload or changes .. LOC/4/23/2013
update dba.hotel set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update hotel dupe flags'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
update dba.car set voidind = 'N' where voidind = 'D' and invoicedate > '12-31-2010'
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update car dupe flags'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
-------- Update hotel dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.hotel First , dba.hotel Second, dba.InvoiceHeader IH
where First.Iatanum = 'Preubs' and second.IataNum = 'preubs' and ih.IataNum = 'preubs'
and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.htlConfNum = Second.htlConfNum and First.IssueDate < Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and datediff(dd,first.checkindate,second.checkindate) <5
and First.voidind = 'N' and Second.voidind = 'N'
and first.RecordKey = ih.RecordKey and First.IataNum = ih.IataNum
and First.InvoiceDate = ih.InvoiceDate and first.ClientCode = ih.ClientCode
and Second.RecordKey = ih.RecordKey and Second.IataNum = ih.IataNum
and Second.InvoiceDate = ih.InvoiceDate and Second.ClientCode = ih.ClientCode
and first.invoicedate > '12-31-2010'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update hotel Dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update hotel Dupes Complete'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

SET @TransStart = getdate()
-------- Update Car dupes -------------------------LOC/8/23/2012
Update First
Set VoidInd = 'D'
from dba.car First , dba.car Second, dba.InvoiceHeader IH
where First.Iatanum = 'Preubs' and second.IataNum = 'preubs' and ih.IataNum = 'preubs'
and First.Iatanum = Second.Iatanum and First.gdsrecordlocator = Second.gdsrecordlocator
and First.CarConfNum = Second.CarConfNum and First.IssueDate < Second.Issuedate
and First.Recordkey <> Second.Recordkey and First.ClientCode = Second.ClientCode
and datediff(dd,first.pickupdate,second.pickupdate) <5 and First.voidind = 'N'
and Second.voidind = 'N' and first.RecordKey = ih.RecordKey and First.IataNum = ih.IataNum
and First.InvoiceDate = ih.InvoiceDate and first.ClientCode = ih.ClientCode and Second.RecordKey = ih.RecordKey
and Second.IataNum = ih.IataNum and Second.InvoiceDate = ih.InvoiceDate and Second.ClientCode = ih.ClientCode
and first.invoicedate > '12-31-2010'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update car dupes Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update car dupes Complete'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--


update I
set producttype = Case when i.ProductType = 'Air' then 'AIR' 
when i.ProductType = 'Hotel' then 'HOTEL'
when i.ProductType = 'Misc' then 'MISC'
when i.ProductType = 'Rail' then 'RAIL'
end 
from dba.invoicedetail I
where i.IataNum = 'preubs'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') producttype = Case when i.ProductType = Air then AIR'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update i
set producttype = 'HOTEL'
from dba.invoicedetail i
where recordkey in (select recordkey from dba.hotel where iatanum = 'preubs')
and recordkey not in (select recordkey from dba.transeg where iatanum = 'preubs')
and producttype is NULL and iatanum = 'preubs' and documentnumber is null and vendornumber is null
and valcarriernum is null
and servicedate > getdate() -10

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') producttype = HOTEL'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--

update t
set segmentcarriername = 'SNCF' 
from dba.transeg t, dba.invoiceheader IH
where t.RecordKey = ih.RecordKey
and t.IataNum = ih.IataNum
and t.ClientCode = ih.ClientCode
and t.InvoiceDate = ih.InvoiceDate
and t.iatanum = 'preubs'
and ih.iatanum = 'preubs' 
and  segmentcarriercode = '2C' 
and segmentcarriername <> 'SNCF'
and ih.importdt > getdate()-1

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') segmentcarriername = SNCF' 
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') h.seqnum = i2.seqnum, h.issuedate = i2.issuedate' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
------ Update T-24 Text6 flag for consistancy ---- LOC/4/22/2013
update c 
set Text6 = case when Text6 = 'YES' then 'Y'
	when Text6 = 'No' then 'N' 
	else text6  end
from dba.comrmks c, dba.invoiceheader ih
where c.recordkey = ih.recordkey and importdt >=getdate()-5

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Text6 = case when Text6 = YES then Y'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Hotel Only -- Text9 = Not Required'
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Car Only -- Text9 = Not Required'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate() 
--
--SET @TransStart = getdate()

--------  Update Text9 w Refundable Status of R or N KP 10/30/2013 Case#23060
--add logic for APAC NONEND/REF/REROUTE W/OUT/REF ISSG OFF  to set as R 4/22/2014
update c
set Text9 = case when i.endorsementremarks like '%no%ref%' then 'N'
			when i.endorsementremarks like '%nonref%' then 'N'
			when i.endorsementremarks like '%non ref%' then 'N'
		    when i.endorsementremarks like '%nonrer%' then 'N'
		    when i.endorsementremarks like '%no rfnd%' then 'N'
		    when i.endorsementremarks like '%non%rfd%' then 'N' 
		    when i.endorsementremarks='NONENDO/NOREF-VLD FB ONLY' then 'N'
		    when i.endorsementremarks like 'NONEND/REF%' then 'R' 
		    when i.endorsementremarks = 'VALID ON CX ONLY NON-ENDO//REF.' then 'R'
		    else 'R'  end
from  dba.invoicedetail i,dba.ComRmks c
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.IataNum=c.IataNum and i.ClientCode=c.clientcode
and i.iatanum = 'preubs'  and i.endorsementremarks is not null  
and i.recordkey in (select recordkey from dba.transeg where iatanum = 'preubs')

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TEXT 9 TO N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') text47 in (1N,2N,3N,1T,2T,3T,1F,2F,3F,1I,2I,3I,1,2,6)' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

update c
set Text9 ='N' 
from dba.comrmks c, dba.invoicedetail i
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and text47 in ('N','1C','2C','3C','1R','2R','3R','1B','2B','3B','1V','2V','3V','1Q','2Q','3Q','1L','3','4','5','7','8')
and c.iatanum = 'preubs' and isnull(text9,'R') = 'R' --and documentnumber is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') text47 in (N,1C,2C,3C,1R,2R,3R,1B,2B,3B,1V,2V,3V,1Q,2Q,3Q,1L,3,4,5,7,8)' 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--
-------- Updating to R when ticket number is present and no endorsements or code from BCD ---
-------- as discussed with UBS 2/11/2014/LOC

--SET @TransStart = getdate()
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Updating to R when ticket number is present and no endorsements or code from BCD '
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text 9 to G4 values for ClientCode 6631020201'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Low Cost Carriers using the G4 field as endorsements'
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
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') For Apollo - Text9 = substring(Udefdata,4,1)'
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

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update Text9 to N (Non Refundable) where no ticket and no price yet'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--
-------- Update the min and nox segment mileage where it is negative when it should be positive.
-------- This is happening throught the .dll and is occuring with exchanges.  -- This is affecting
-------- the UBS Segment Mileage reports ----- LOC/6/16/2014
update t
set  noxsegmentmileage = noxsegmentmileage*-1, noxtotalmileage = noxtotalmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and noxsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') pdate the min and nox segment mileage where it is negative when it should be positive'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--
update t
set  minsegmentmileage = minsegmentmileage*-1, mintotalmileage = mintotalmileage*-1
from dba.transeg t, dba.invoicedetail i
where segsegmentmileage >0 and minsegmentmileage <0
and t.recordkey = i.recordkey and t.seqnum = i.seqnum
and t.invoicedate > '1-1-2012' and exchangeind = 'y'

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') minsegmentmileage = minsegmentmileage*-1, mintotalmileage = mintotalmileage*-1'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

update i
set  mileage = mileage*-1
from dba.invoicedetail i
where i.mileage <0 
and i.invoicedate > '1-1-2012' and i.exchangeind = 'y'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='TEXT 9 TO R IF NOT N',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') TEXT 9 TO R IF NOT N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--
 
 ------------------------------------------------------------------------------------------------------
 ---------------------------------Refund/Exchange Process -----------------------------Added 5/6/2014
 
--------STEP 1 - Update all Exchanged Tickets to have a TktWasExchangedInd of Y

UPDATE ot
SET TktWasExchangedInd = 'Y'  ,TktOrder = 1 ,TicketGroupId = ot.DocumentNumber
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N'
AND e1.ExchangeInd = 'Y' and e1.iatanum = 'preubs' and ot.iatanum= 'preubs'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
and isnull(ot.TktWasExchangedInd,'X') <> 'Y'
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 1 - Update all Exchanged Tickets to have a TktWasExchangedInd of Y'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

-------- Update all Exchange Tickets to have TicketWasExchangedInd of Y where 
-------- where the 1st exchanged ticket was exchanged for the 3rd ticket.
UPDATE ot
SET TktWasExchangedInd = 'Y'
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'Y' AND e1.ExchangeInd = 'Y' and e1.iatanum = 'preubs' and ot.iatanum= 'preubs'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G') AND ot.TktWasExchangedInd IS NULL
AND e1.DocumentNumber <> e1.OrigExchTktNum
and isnull(ot.TktWasExchangedInd,'X') <> 'Y'
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update all Exchanged Tickets to have a TktWasExchangedInd of Y -- where the 1st exchanged ticket was exchanged for the 3rd ticket.'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 2 - Update all first level Exchange Tickets 
UPDATE e1
SET e1.TktOrder = 2
   ,e1.OrigTktAmt = ISNULL(ot.TotalAmt,0)
   ,e1.OrigBaseFare = ISNULL(ot.InvoiceAmt,0)
   ,e1.TicketGroupId = ot.DocumentNumber
   ,e1.OrigFareCompare1 = ISNULL(ot.FareCompare1,0)
   ,e1.OrigFareCompare2 = ISNULL(ot.FareCompare2,0)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' and e1.iatanum = 'preubs' and ot.iatanum= 'preubs'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 2 - Update all first level Exchange Tickets '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 3 - Update all Second level Exchange Tickets 
UPDATE e2
SET e2.TktOrder = 3
   ,e2.OrigTktAmt = ISNULL(e1.TotalAmt,0) + e1.OrigTktAmt
   ,e2.OrigBaseFare = ISNULL(e1.InvoiceAmt,0) + e1.InvoiceAmt
   ,e2.TicketGroupId = ot.DocumentNumber
   ,e2.OrigFareCompare1 = ISNULL(e1.origFareCompare1,0) + ISNULL(e1.FareCompare1,0)
   ,e2.OrigFareCompare2 = ISNULL(e1.origFareCompare2,0) + ISNULL(e1.FareCompare2,0)
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' and e1.iatanum = 'preubs' and ot.iatanum= 'preubs' and e2.iatanum = 'preubs'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair') AND e2.VendorType IN ('PRETKT','PREMCO','nonair')
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 3 - Update all Second level Exchange Tickets '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 4 - Update all Third level Exchange Tickets 
UPDATE e3
SET e3.TktOrder = 4
   ,e3.OrigTktAmt = ISNULL(e2.TotalAmt,0) + e2.OrigTktAmt
   ,e3.OrigBaseFare = ISNULL(e2.InvoiceAmt,0) + e2.InvoiceAmt
   ,e3.OrigFareCompare1 = ISNULL(e2.origFareCompare1,0) + ISNULL(e2.FareCompare1,0)
   ,e3.OrigFareCompare2 = ISNULL(e2.origFareCompare2,0) + ISNULL(e2.FareCompare2,0)
   ,e3.TicketGroupId = ot.DocumentNumber
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair') 
AND e2.VendorType IN ('PRETKT','PREMCO','nonair') AND e3.VendorType IN ('PRETKT','PREMCO','nonair')
and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs' and e3.iatanum = 'preubs'
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 4 - Update all Third level Exchange Tickets'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 5 - Update all Fourth level Exchange Tickets 
UPDATE e4
SET e4.TktOrder = 5
   ,e4.OrigTktAmt = ISNULL(e3.TotalAmt,0) + e3.OrigTktAmt
   ,e4.OrigBaseFare = ISNULL(e3.InvoiceAmt,0) + e3.InvoiceAmt
   ,e4.OrigFareCompare1 = ISNULL(e3.origFareCompare1,0) + ISNULL(e3.FareCompare1,0)
   ,e4.OrigFareCompare2 = ISNULL(e3.origFareCompare2,0) + ISNULL(e3.FareCompare2,0)
   ,e4.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y' AND e4.ExchangeInd = 'Y'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair') AND e2.VendorType IN ('PRETKT','PREMCO','nonair')
AND e3.VendorType IN ('PRETKT','PREMCO','nonair') AND e4.VendorType IN ('PRETKT','PREMCO','nonair')
and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs' and e3.iatanum = 'preubs' and e4.iatanum = 'preubs'
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 5 - Update all Fourth level Exchange Tickets '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--


--------STEP 6 - Update all Fifth level Exchange Tickets 
UPDATE e5
SET e5.TktOrder = 6
   ,e5.OrigTktAmt = ISNULL(e4.TotalAmt,0) + e4.OrigTktAmt
   ,e5.OrigBaseFare = ISNULL(e4.InvoiceAmt,0) + e4.InvoiceAmt
   ,e5.OrigFareCompare1 = ISNULL(e4.origFareCompare1,0) + ISNULL(e4.FareCompare1,0)
   ,e5.OrigFareCompare2 = ISNULL(e4.origFareCompare2,0) + ISNULL(e4.FareCompare2,0)
   ,e5.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND ot.VendorType IN ('PRETKT','PREMCO','nonair')
AND e1.VendorType IN ('PRETKT','PREMCO','nonair') AND e2.VendorType IN ('PRETKT','PREMCO','nonair') AND e3.VendorType IN ('PRETKT','PREMCO','nonair')
AND e4.VendorType IN ('PRETKT','PREMCO','nonair') AND e5.VendorType IN ('PRETKT','PREMCO','nonair')
and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs'and e3.iatanum = 'preubs'and e4.iatanum = 'preubs'
and e5.iatanum = 'preubs'
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum 
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 6 - Update all Fifth level Exchange Tickets '
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 7 - Update all 6th level Exchange Tickets 
UPDATE e6
SET e6.TktOrder = 7
   ,e6.OrigTktAmt = ISNULL(e5.TotalAmt,0) + e5.OrigTktAmt
   ,e6.OrigBaseFare = ISNULL(e5.InvoiceAmt,0) + e5.InvoiceAmt
   ,e6.OrigFareCompare1 = ISNULL(e5.origFareCompare1,0) + ISNULL(e5.FareCompare1,0)
   ,e6.OrigFareCompare2 = ISNULL(e5.origFareCompare2,0) + ISNULL(e5.FareCompare2,0)
   ,e6.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair') AND e2.VendorType IN ('PRETKT','PREMCO','nonair')
AND e3.VendorType IN ('PRETKT','PREMCO','nonair') AND e4.VendorType IN ('PRETKT','PREMCO','nonair')
AND e5.VendorType IN ('PRETKT','PREMCO','nonair') AND e6.VendorType IN ('PRETKT','PREMCO','nonair')
and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs' and e3.iatanum = 'preubs' and e4.iatanum = 'preubs'
and e5.iatanum = 'preubs' and e6.iatanum = 'preubs'
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 7 - Update all 6th level Exchange Tickets'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 7 - Update all 6th level Exchange Tickets 
UPDATE e7
SET e7.TktOrder = 8
   ,e7.OrigTktAmt = ISNULL(e6.TotalAmt,0) + e6.OrigTktAmt
   ,e7.OrigBaseFare = ISNULL(e6.InvoiceAmt,0) + e6.InvoiceAmt
   ,e7.OrigFareCompare1 = ISNULL(e6.origFareCompare1,0) + ISNULL(e6.FareCompare1,0)
   ,e7.OrigFareCompare2 = ISNULL(e6.origFareCompare2,0) + ISNULL(e6.FareCompare2,0)
   ,e7.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and e6.documentnumber = e7.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair')
AND e2.VendorType IN ('PRETKT','PREMCO','nonair') AND e3.VendorType IN ('PRETKT','PREMCO','nonair')
AND e4.VendorType IN ('PRETKT','PREMCO','nonair') AND e5.VendorType IN ('PRETKT','PREMCO','nonair')
AND e6.VendorType IN ('PRETKT','PREMCO','nonair') AND e7.VendorType IN ('PRETKT','PREMCO','nonair')
and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs' and e3.iatanum = 'preubs' and e4.iatanum = 'preubs'
and e5.iatanum = 'preubs' and e6.iatanum = 'preubs' and e7.iatanum = 'preubs'
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' AND e7.VoidInd = 'N' AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
AND e7.DocumentNumber <> e7.OrigExchTktNum 
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 7 - Update all 6th level Exchange Tickets'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 8 - Update all Seventh level Exchange Tickets 
UPDATE e8
SET e8.TktOrder = 9
   ,e8.OrigTktAmt = ISNULL(e7.TotalAmt,0) + e7.OrigTktAmt
   ,e8.OrigBaseFare = ISNULL(e7.InvoiceAmt,0) + e7.InvoiceAmt
   ,e8.OrigFareCompare1 = ISNULL(e7.origFareCompare1,0) + ISNULL(e7.FareCompare1,0)
   ,e8.OrigFareCompare2 = ISNULL(e7.origFareCompare2,0) + ISNULL(e7.FareCompare2,0)
   ,e8.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and e6.documentnumber = e7.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e8 ON ( e7.IataNum = e8.Iatanum and e7.documentnumber = e8.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y' AND e4.ExchangeInd = 'Y'
AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y' AND e8.ExchangeInd = 'Y'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair')
AND e2.VendorType IN ('PRETKT','PREMCO','nonair') AND e3.VendorType IN ('PRETKT','PREMCO','nonair')
AND e4.VendorType IN ('PRETKT','PREMCO','nonair') AND e5.VendorType IN ('PRETKT','PREMCO','nonair')
AND e6.VendorType IN ('PRETKT','PREMCO','nonair') AND e7.VendorType IN ('PRETKT','PREMCO','nonair')
and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs' and e3.iatanum = 'preubs' and e4.iatanum = 'preubs'
and e5.iatanum = 'preubs' and e6.iatanum = 'preubs' and e7.iatanum = 'preubs' and e8.iatanum = 'preubs'
AND e8.VendorType IN ('PRETKT','PREMCO') AND ot.VoidInd = 'N' AND e1.VoidInd = 'N'
AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N' AND e5.VoidInd = 'N' AND e6.VoidInd = 'N'
AND e7.VoidInd = 'N' AND e8.VoidInd = 'N' AND IH.BackOfficeId IN ('27SU','6DFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
AND e7.DocumentNumber <> e7.OrigExchTktNum AND e8.DocumentNumber <> e8.OrigExchTktNum
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 8 - Update all Seventh level Exchange Tickets'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--------STEP 9 - Update all Eighth level Exchange Tickets 
UPDATE e9
SET e9.TktOrder = 10
   ,e9.OrigTktAmt = ISNULL(e7.TotalAmt,0) + e7.OrigTktAmt
   ,e9.OrigBaseFare = ISNULL(e7.InvoiceAmt,0) + e7.InvoiceAmt
   ,e9.OrigFareCompare1 = ISNULL(e8.origFareCompare1,0) + ISNULL(e8.FareCompare1,0)
   ,e9.OrigFareCompare2 = ISNULL(e8.origFareCompare2,0) + ISNULL(e8.FareCompare2,0)
   ,e9.TicketGroupId = ot.DocumentNumber   
FROM DBA.InvoiceDetail ot
INNER JOIN DBA.Invoiceheader ih ON ( ot.IataNum = ih.Iatanum and ot.recordkey = ih.recordkey)
INNER JOIN DBA.InvoiceDetail e1 ON ( ot.IataNum = e1.Iatanum and ot.documentnumber = e1.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e2 ON ( e1.IataNum = e2.Iatanum and e1.documentnumber = e2.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e3 ON ( e2.IataNum = e3.Iatanum and e2.documentnumber = e3.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e4 ON ( e3.IataNum = e4.Iatanum and e3.documentnumber = e4.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e5 ON ( e4.IataNum = e5.Iatanum and e4.documentnumber = e5.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e6 ON ( e5.IataNum = e6.Iatanum and e5.documentnumber = e6.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e7 ON ( e6.IataNum = e7.Iatanum and e6.documentnumber = e7.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e8 ON ( e7.IataNum = e8.Iatanum and e7.documentnumber = e8.OrigExchTktNum)
INNER JOIN DBA.InvoiceDetail e9 ON ( e8.IataNum = e9.Iatanum and e8.documentnumber = e9.OrigExchTktNum)
WHERE ot.ExchangeInd = 'N' AND e1.ExchangeInd = 'Y' AND e2.ExchangeInd = 'Y' AND e3.ExchangeInd = 'Y'
AND e4.ExchangeInd = 'Y' AND e5.ExchangeInd = 'Y' AND e6.ExchangeInd = 'Y' AND e7.ExchangeInd = 'Y'
AND e8.ExchangeInd = 'Y' AND e9.ExchangeInd = 'Y'
AND ot.VendorType IN ('PRETKT','PREMCO','nonair') AND e1.VendorType IN ('PRETKT','PREMCO','nonair')
AND e2.VendorType IN ('PRETKT','PREMCO','nonair') AND e3.VendorType IN ('PRETKT','PREMCO','nonair')
AND e4.VendorType IN ('PRETKT','PREMCO','nonair') AND e5.VendorType IN ('PRETKT','PREMCO','nonair')
AND e6.VendorType IN ('PRETKT','PREMCO','nonair') AND e7.VendorType IN ('PRETKT','PREMCO','nonair')
AND e8.VendorType IN ('PRETKT','PREMCO','nonair') AND e9.VendorType IN ('PRETKT','PREMCO','nonair')and ot.iatanum = 'preubs' and e1.iatanum= 'preubs' and e2.iatanum = 'preubs' and e3.iatanum = 'preubs' and e4.iatanum = 'preubs'
and e5.iatanum = 'preubs' and e6.iatanum = 'preubs' and e7.iatanum = 'preubs' and e8.iatanum = 'preubs' and e9.iatanum = 'prebus'
AND ot.VoidInd = 'N' AND e1.VoidInd = 'N' AND e2.VoidInd = 'N' AND e3.VoidInd = 'N' AND e4.VoidInd = 'N'
AND e5.VoidInd = 'N' AND e6.VoidInd = 'N' AND e7.VoidInd = 'N' AND e8.VoidInd = 'N' AND e9.VoidInd = 'N'
AND IH.BackOfficeId IN ('27SU','6DbFF','J21G','VP3G')
AND e1.DocumentNumber <> e1.OrigExchTktNum AND e2.DocumentNumber <> e2.OrigExchTktNum
AND e3.DocumentNumber <> e3.OrigExchTktNum AND e4.DocumentNumber <> e4.OrigExchTktNum
AND e5.DocumentNumber <> e5.OrigExchTktNum AND e6.DocumentNumber <> e6.OrigExchTktNum
AND e7.DocumentNumber <> e7.OrigExchTktNum AND e8.DocumentNumber <> e8.OrigExchTktNum
AND e9.DocumentNumber <> e9.OrigExchTktNum 
and ot.servicedate > getdate() -365

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') STEP 9 - Update all Eighth level Exchange Tickets'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

----------------------------------------------------------------------------------------------------------
------- Flagging for the Destination Pre Trip reports to flag travelto AU NZ and AU to NZ and NZ to AU-----

--- To AU/NZ from AU/NZ -- 
update dba.comrmks
set num10 = case when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and rollup12 = 'AU' and dcity.countrycode = 'NZ' 
			and t1.mindestcitycode = dcity.citycode and dcity.typecode = 'a' and t1.typecode = 'a'
			and t1.mindestcitycode is not null)  then 2
			when recordkey in  
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c
			where htlcitycode = c.citycode and c.countrycode = 'NZ' and iatanum = 'preubs' 
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 = 'AU'
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'
			when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and rollup12 = 'NZ' and dcity.countrycode = 'AU'
			and t1.mindestcitycode = dcity.citycode and dcity.typecode = 'a' and t1.typecode = 'a'
			and t1.mindestcitycode is not null) then 2 
			when recordkey in 
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c
			where htlcitycode = c.citycode and c.countrycode = 'AU' and iatanum = 'preubs' 
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 = 'NZ'
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'else  num10 end
where iatanum = 'preubs'
and recordkey in (select recordkey from dba.invoicedetail where servicedate >getdate()-30) 
and num10 is null


----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Flagging for the Destination Pre Trip reports to flag travelto AU NZ and AU to NZ and NZ to AU'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

--- To AU/NZ from AU/NZ -- For Generic / Unknown GPNs --------------------
update dba.comrmks
set num10 = case when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity, dba.invoiceheader ih
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and id.recordkey = ih.recordkey
			and rollup12 is null and ih.origcountry ='AU'  and dcity.countrycode = 'NZ' 
			and t1.mindestcitycode = dcity.citycode and dcity.typecode = 'a' and t1.typecode = 'a'
			and t1.mindestcitycode is not null)  then 2
			when recordkey in  
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c, dba.invoiceheader ih
			where htlcitycode = c.citycode and c.countrycode = 'NZ' and h.iatanum = 'preubs' and h.recordkey = ih.recordkey
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 is null and ih.origcountry ='AU'
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'
			when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity, dba.invoiceheader ih
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and id.recordkey = ih.recordkey
			and rollup12 is null and ih.origcountry ='NZ' and dcity.countrycode = 'AU'
			and t1.mindestcitycode = dcity.citycode and dcity.typecode = 'a' and t1.typecode = 'a'
			and t1.mindestcitycode is not null) then 2 
			when recordkey in 
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c, dba.invoiceheader ih
			where htlcitycode = c.citycode and c.countrycode = 'AU' and h.iatanum = 'preubs' and h.recordkey = ih.recordkey
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 is null and ih.origcountry ='NZ'
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'else  num10 end
where iatanum = 'preubs'
and recordkey in (select recordkey from dba.invoicedetail where servicedate >getdate()-30) 
and num10 is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') To AU/NZ from AU/NZ -- For Generic / Unknown GPNs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

update dba.comrmks
set num10 = case when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and rollup12 = 'AU' and dcity.countrycode = 'NZ' 
			and t1.mindestcitycode = dcity.citycode and dcity.typecode = 'a' and t1.typecode = 'a'
			and t1.mindestcitycode is not null)  then 2
			when recordkey in  
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c
			where htlcitycode = c.citycode and c.countrycode = 'NZ' and iatanum = 'preubs' 
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 = 'AU'
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'
			when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and rollup12 = 'NZ' and dcity.countrycode = 'AU'
			and t1.mindestcitycode = dcity.citycode and dcity.typecode = 'a' and t1.typecode = 'a'
			and t1.mindestcitycode is not null) then 2 
			when recordkey in 
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c
			where htlcitycode = c.citycode and c.countrycode = 'AU' and iatanum = 'preubs' 
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 = 'NZ'
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'else  num10 end
where iatanum = 'preubs'
and recordkey in (select recordkey from dba.invoicedetail where servicedate >getdate()-30) 
and num10 is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') dba.comrmks -- set num10 = case when recordkey'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

----- To AU/NZ not from AU/NZ 
update dba.comrmks
set num10 = case when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and dcity.citycode = mindestcitycode
			and isnull(rollup12,'XX') not in ('AU','NZ') and dcity.countrycode in ('AU','NZ')) then 2

	    	when recordkey in  
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c
			where htlcitycode = c.citycode and c.countrycode in('AU','NZ') and iatanum = 'preubs' 
			and remarks2 = corporatestructure and typecode = 'a' and rollup12 not in ('AU','NZ')
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'
			else  num10 end
where iatanum = 'preubs'
and recordkey in (select recordkey from dba.invoicedetail where servicedate >getdate()-30) 
and num10 is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') To AU/NZ not from AU/NZ'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

----- To AU/NZ not from AU/NZ for Generic and Unknown GPN's ----------------------------
update dba.comrmks
set num10 = case when recordkey in 
			(select id.recordkey  
			from dba.transeg t1, dba.rollup40 r, dba.invoicedetail id , dba.city dcity, dba.invoiceheader ih
			where id.recordkey = t1.recordkey and id.seqnum = t1.seqnum 
			and costructid = 'functional' and id.remarks2 = corporatestructure 	and id.iatanum = 'preubs'
			and dcity.citycode = mindestcitycode
			and id.recordkey = ih.recordkey
			and rollup12 is null and ih.origcountry not in ('AU','NZ') and dcity.countrycode in ('AU','NZ')) then 2

	    	when recordkey in  
			(select h.recordkey from dba.hotel h, dba.rollup40 r, dba.city c, dba.invoiceheader ih
			where htlcitycode = c.citycode and c.countrycode in('AU','NZ') and h.iatanum = 'preubs' 
			and remarks2 = corporatestructure and typecode = 'a'  and h.recordkey = ih.recordkey
			and rollup12 is null and ih.origcountry not in ('AU','NZ')
			and costructid = 'functional' and checkindate > getdate()-2) and num10 is null then '2'
			else  num10 end
where iatanum = 'preubs'
and recordkey in (select recordkey from dba.invoicedetail where servicedate >getdate()-30) 
and num10 is null

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') To AU/NZ not from AU/NZ for Generic and Unknown GPNs'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--

---------- Update Currency code and Htl Rates when something jacked up happens because of the currency table...
update htl
set  htldailyrate = (htlquotedrate)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)/numnights
,  htl.ttlhtlcost = (htlquotedrate)*(CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)
, htl.currcode = 'USD'
from dba.hotel htl, DBA.Currency CURRBASE , dba.currency currto
where (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
and CURRBASE.CurrBeginDate = HTL.IssueDate and currbase.currcode = quotedcurrcode
AND CURRBASE.BaseCurrCode = 'USD' ) 
and CURRTO.CurrCode ='usd' and htl.currcode <> 'usd' and iatanum = 'preubs'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End UBS Pre Main SP',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') End UBS Pre Main SP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

--Added by rcr  07/13/2015
SET @TransStart = Getdate()
--


--Data Enhancement Automation SQLMaint Queries
--Be sure to add the following just below the Alter Procedure if a RequestName is passed - @RequestName varchar(50) = NULL --For DEA
--Declare @SQLMaintBeginDate datetime
--Declare @SQLMaintEndDate datetime

--Select @SQLMaintBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
--from dba.Hotel
--Where MasterId is NULL
--AND IataNum = 'PREUBS'
--if @RequestName is not null
--begin
--	EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
--	@DatamanRequestName = @RequestName,
--	@Enhancement = 'SQLMaint',
--	@Client = 'UBS',
--	@Delay = 15,
--	@Priority = NULL,
--	@Notes = NULL,
--	@Suspend = false,
--	@RunAtTime = NULL,
--	@BeginDate = NULL,
--	@EndDate = NULL,
--	@DateParam1 = NULL,
--	@DateParam2 = NULL,
--	@TextParam1 = NULL,
--	@TextParam2 = NULL,
--	@TextParam3 = NULL,
--	@TextParam4 = NULL,
--	@TextParam5 = NULL,
--	@TextParam6 = NULL,
--	@TextParam7 = NULL,
--	@TextParam8 = NULL,
--	@TextParam9 = NULL,
--	@TextParam10 = NULL,
--	@TextParam11 = NULL,
--	@TextParam12 = NULL,
--	@TextParam13 = NULL,
--	@TextParam14 = NULL,
--	@TextParam15 = NULL,
--	@IntParam1 = NULL,
--	@IntParam2 = NULL,
--	@IntParam3 = NULL,
--	@IntParam4 = NULL,
--	@IntParam5 = NULL,
--	@BoolParam1 = NULL,
--	@BoolParam2 = NULL,
--	@BoolParam3 = NULL,
--	@BoolParam4 = NULL,
--	@BoolParam5 = NULL,
--	@BoolParam6 = NULL,
--	@BoolParam7 = NULL,
--	@BoolParam8 = NULL,
--	@BoolParam9 = NULL,
--	@BoolParam10 = NULL,
--	@CommandLineArgs = 'ttxpasql01 tman_ubs'
--end

/************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
WAITFOR DELAY '00:00.30' 
--Added by rcr  07/10/2015
SET @TransStart = Getdate() 
--
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/13/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName	,@IataNum=@Iata	,@LogStart=@TransStart	,@StepName=@LogStep	,@BeginDate=@LocalBeginIssueDate,@EndDate=@LocalEndIssueDate,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
