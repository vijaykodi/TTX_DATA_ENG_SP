/****** Object:  StoredProcedure [dbo].[SP_PostHotelUpdate]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHotelUpdate]
AS

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

--Log Activity
SET @TransStart = getdate()

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
Declare @Iata varchar(50)
--, @ProcName varchar(50)
--, @TransStart datetime
--, @BeginIssueDate datetime
--, @ENDIssueDate datetime
, @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)

SET @Iata = 'SP_PostHotelUpdate'
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------

--====
--Next Line commented out -- 07/08/2015  rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--====

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
--Added by rcr  07/08/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--

update h1
set h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode
from dba.hotel h1, dba.hotel h2
where h1.gdsrecordlocator = h2.gdsrecordlocator
and h1.iatanum <> 'preubs' and h2.iatanum = 'preubs' and h1.invoicedate > '6/1/2011'
and h1.voidind = 'n' and h2.voidind = 'n'
and h1.htlconfnum = h2.htlconfnum
and h1.htlcomparerate2 is null

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode --> h1.htlcomparerate2 is null'
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

update h1
set h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode
from dba.hotel h1, dba.hotel h2
where h1.gdsrecordlocator = h2.gdsrecordlocator
and h1.iatanum <> 'preubs' and h2.iatanum = 'preubs' and h1.invoicedate > '6/1/2011'
and datediff(dd,h1.checkindate, h2.checkindate) <2
and datediff(dd,h1.checkoutdate , h2.checkoutdate)<2
and h1.voidind = 'n' and h2.voidind = 'n'
and h1.htlcomparerate2 is null
and h1.htlcitycode = h2.htlcitycode

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode --> h1.htlcitycode = h2.htlcitycode'
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

update h1
set h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode
from dba.hotel h1, dba.hotel h2
where h1.gdsrecordlocator = h2.gdsrecordlocator
and h1.iatanum <> 'preubs' and h2.iatanum = 'preubs' and h1.invoicedate > '6/1/2011'
and datediff(dd,h1.checkindate, h2.checkindate) <2
and datediff(dd,h1.checkoutdate , h2.checkoutdate)<2
and h1.voidind = 'n' and h2.voidind = 'n'
and h1.htlcomparerate2 is null
and h1.htlcityname = h2.htlcityname

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode --> h1.htlcityname = h2.htlcityname'
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

update h1
set h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode
from dba.hotel h1, dba.hotel h2
where h1.gdsrecordlocator = h2.gdsrecordlocator
and h1.iatanum <> 'preubs'  and h2.iatanum = 'preubs' and h1.invoicedate > '6/1/2011'
and datediff(dd,h1.checkindate, h2.checkindate) <2
and datediff(dd,h1.checkoutdate , h2.checkoutdate)<2
and h1.voidind = 'n' and h2.voidind = 'n'
and h1.htlcomparerate2 is null
and substring(h1.htlpropertyname,1,8) = substring(h2.htlpropertyname,1,8)

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode --> substring(h1.htlpropertyname,1,8) = substring(h2.htlpropertyname,1,8)'
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

update h1
set h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode
from dba.hotel h1, dba.hotel h2
where h1.gdsrecordlocator = h2.gdsrecordlocator
and h1.iatanum <> 'preubs'  and h2.iatanum = 'preubs' and h1.invoicedate > '6/1/2011'
and h1.checkindate= h2.checkindate
and h1.checkoutdate = h2.checkoutdate
and h1.voidind = 'n' and h2.voidind = 'n'
and h1.htlcomparerate2 is null
and substring(h1.htlpropertyname,1,8) = substring(h2.htlpropertyname,1,8)
and h1.gdsrecordlocator = 'ZTCWUQ'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') h1.htlcomparerate2 = h2.htlquotedrate, h1.remarks4 = h2.quotedcurrcode --> h1.gdsrecordlocator = ZTCWUQ'
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

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--====
--Next line commented out - 07/08/2015 rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--====
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
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
	LOGGING_ENDED - END
************************************************************************/  


GO
