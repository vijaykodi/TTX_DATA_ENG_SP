/****** Object:  StoredProcedure [dbo].[sp_GPN_Updates_All]    Script Date: 7/14/2015 7:39:24 PM ******/
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
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
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
, @LogStep varchar(250)

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
