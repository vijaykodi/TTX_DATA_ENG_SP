/****** Object:  StoredProcedure [dbo].[sp_PRE_UBS_BCDTktCode]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PRE_UBS_BCDTktCode]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
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
SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------


/************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity
--=====
--Next line commented out -- 07/08/2015  rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

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


--Log Activity
--Added by rcr  07/08/2015
WAITFOR DELAY '00:00.30' 
SET @TransStart = Getdate() 
--

--=====
--Next line commented out -- 07/08/2015  rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 1-Stored Procedure Start'
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
WAITFOR DELAY '00:00.30' 
SET @TransStart = Getdate() 
--
select distinct substring(id.recordkey,15,charindex('-',id.recordkey)-15), gdsrecordlocator,reasoncode1, 
case when right(udefdata,2) in ('PC','RB','XX','EX') then 'A1'
when right(udefdata,2) = 'UG' THEN 'A4' WHEN right(udefdata,2) = 'NR'THEN 'A6'
WHEN right(udefdata,2) = 'BC' THEN 'B1' WHEN right(udefdata,2) = 'CP' THEN 'B2'
WHEN right(udefdata,2) = 'ST' THEN 'B3' WHEN right(udefdata,2) = 'AP' THEN 'B5'
WHEN right(udefdata,2) = 'MI' THEN 'B6' WHEN right(udefdata,2) = 'NO' THEN 'B7'
WHEN right(udefdata,2) = 'CC' THEN 'B8' END, totalamt,
farecompare2,substring(udefdata,23,4), udefdata
 from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' 
and substring(id.recordkey,15,charindex('-',id.recordkey)-15) in ('6dff','27su','J21G','VP3G')
and id.invoicedate > '5-1-2013'
and udeftype = 'TK RMKS'
and substring(udefdata,7,10) = documentnumber
and substring(udefdata,23,4) not like '%/%'
ORDER BY 1,2,3

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Partial Select criteria -> farecompare2,substring(udefdata,23,4), udefdata'
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
select distinct substring(id.recordkey,15,charindex('-',id.recordkey)-15), gdsrecordlocator,reasoncode1, 
case when right(udefdata,2) in ('PC','RB','XX','EX') then 'A1'
when right(udefdata,2) = 'UG' THEN 'A4' WHEN right(udefdata,2) = 'NR'THEN 'A6'
WHEN right(udefdata,2) = 'BC' THEN 'B1' WHEN right(udefdata,2) = 'CP' THEN 'B2'
WHEN right(udefdata,2) = 'ST' THEN 'B3' WHEN right(udefdata,2) = 'AP' THEN 'B5'
WHEN right(udefdata,2) = 'MI' THEN 'B6' WHEN right(udefdata,2) = 'NO' THEN 'B7'
WHEN right(udefdata,2) = 'CC' THEN 'B8' END, totalamt,
farecompare2,substring(udefdata,24,5), udefdata
 from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' 
and substring(id.recordkey,15,charindex('-',id.recordkey)-15) in ('6dff','27su','J21G','VP3G')
and id.invoicedate > '5-1-2013'
and udeftype = 'TK RMKS'
and substring(udefdata,7,10) = documentnumber
and substring(udefdata,24,5) not like '%/%'
ORDER BY 1,2,3

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Partial Select criteria -> farecompare2,substring(udefdata,24,5), udefdata'
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
select distinct substring(id.recordkey,15,charindex('-',id.recordkey)-15), gdsrecordlocator,reasoncode1, 
case when right(udefdata,2) in ('PC','RB','XX','EX') then 'A1'
when right(udefdata,2) = 'UG' THEN 'A4' WHEN right(udefdata,2) = 'NR'THEN 'A6'
WHEN right(udefdata,2) = 'BC' THEN 'B1' WHEN right(udefdata,2) = 'CP' THEN 'B2'
WHEN right(udefdata,2) = 'ST' THEN 'B3' WHEN right(udefdata,2) = 'AP' THEN 'B5'
WHEN right(udefdata,2) = 'MI' THEN 'B6' WHEN right(udefdata,2) = 'NO' THEN 'B7'
WHEN right(udefdata,2) = 'CC' THEN 'B8' END, totalamt,
farecompare2,substring(udefdata,25,6), udefdata
 from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' 
and substring(id.recordkey,15,charindex('-',id.recordkey)-15) in ('6dff','27su','J21G','VP3G')
and id.invoicedate > '5-1-2013'
and udeftype = 'TK RMKS'
and substring(udefdata,7,10) = documentnumber
and substring(udefdata,25,6) not like '%/%'
ORDER BY 1,2,3


----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Partial Select criteria-> farecompare2,substring(udefdata,25,6), udefdata'
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

select distinct substring(id.recordkey,15,charindex('-',id.recordkey)-15), gdsrecordlocator,reasoncode1, 
case when right(udefdata,2) in ('PC','RB','XX','EX') then 'A1'
when right(udefdata,2) = 'UG' THEN 'A4' WHEN right(udefdata,2) = 'NR'THEN 'A6'
WHEN right(udefdata,2) = 'BC' THEN 'B1' WHEN right(udefdata,2) = 'CP' THEN 'B2'
WHEN right(udefdata,2) = 'ST' THEN 'B3' WHEN right(udefdata,2) = 'AP' THEN 'B5'
WHEN right(udefdata,2) = 'MI' THEN 'B6' WHEN right(udefdata,2) = 'NO' THEN 'B7'
WHEN right(udefdata,2) = 'CC' THEN 'B8' END, totalamt,
farecompare2,substring(udefdata,26,7), udefdata
 from dba.invoicedetail id, dba.udef u
where id.recordkey = u.recordkey and id.seqnum = u.seqnum
and id.iatanum = 'preubs' 
and substring(id.recordkey,15,charindex('-',id.recordkey)-15) in ('6dff','27su','J21G','VP3G')
and id.invoicedate > '5-1-2013'
and udeftype = 'TK RMKS'
and substring(udefdata,7,10) = documentnumber
and substring(udefdata,26,6) not like '%/%'
ORDER BY 1,2,3

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Partial Select criteria-> farecompare2,substring(udefdata,26,7), udefdata'
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
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--Added by rcr  07/08/2015
WAITFOR DELAY '00:00.30' 
SET @TransStart = Getdate() 
--

--====
--Next line Commented out  -  07/08/2015  rcr
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
