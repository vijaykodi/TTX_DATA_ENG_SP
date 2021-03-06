/****** Object:  StoredProcedure [dbo].[sp_ACM_Move_to_Production_ManualImportDt]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE PROCEDURE [dbo].[sp_ACM_Move_to_Production_ManualImportDt]
AS
BEGIN

/************************************************************************
    Set arguments and variables
*************************************************************************/
   
   DECLARE @Iata VARCHAR(50);
   DECLARE @ProcName VARCHAR(50);
   DECLARE @TransStart DATETIME;
   DECLARE @BeginIssueDate DATETIME = getdate();
   DECLARE @ENDIssueDate DATETIME = getdate(); 
   Declare @importdt datetime = getdate();

 --=================================
--Added by rcr  07/07/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
   Declare @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)
--SET @Iata = ''
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID)) --> initialized below
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()   --> initialized below
--=================================

   -------- This SP is used when specific importdate / date ranges are needed -------------------------------------------
   ------- The Import data will need to be adjusted to what is needed at the time the SP is run--------LOC/8/29/2014
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

-------------------************** Hoping this will work ****************--------------------
--  Pushes data to production when ACMProcessor completes
--  Program will fail if time to process > MaxProcessingTime for customer in ACMDatabases
--  Default fail time is 180 minutes 		---- UBS is set for 360 in the table.	    				    
--  SET @TransStart = GETDATE();
--    IF >='10-1-2013' IS NULL
--    BEGIN
--	 SET >='10-1-2013' = (SELECT MAX(ImportDt)FROM DBA.InvoiceHeader WHERE IataNum NOT LIKE 'PRE%');
--    END;

SET @TransStart = getdate()

 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity

--Next Line Commented out .. rcr 07/07/2015
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added by rcr  07/07/2015
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

--Added by rcr  07/02/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--
  -------Delete redundant ACMInfo records on production
	  Delete   from dba.ACMinfo 
	  where ImportDt  >='10-1-2013'

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACMI_PROD',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_DEL_ACMI_PROD'
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
	
	
				 
--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--			 
  	--Add new ACMInfo records to production
	 Insert into dba.ACMInfo
	 Select *
	 from TTXSASQL01.TMAN_UBS.dba.ACMInfo
	 where ImportDt  >='10-1-2013'
	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_PUSH_ACMI',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
	
----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_PUSH_ACMI'
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
		
	
	
				 
--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--					  
		  
		   --Delete redundant ContractRmk records on production
		 
	  Delete from dba.contractrmks 
	  where recordkey in (select recordkey from ttxsasql01.tman_ubs.dba.contractrmks where procenddate > getdate()-3)
	  --where recordkey in (select recordkey from dba.acminfo where ImportDt  >='10-1-2013')
	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACRMKS_PROD',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-SQL_DEL_ACRMKS_PROD'
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
		


--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--	
			  
		--Add new ContractRmk records to production
-----**** Quering the ACMINFO table is causing major delays in the insert process .. The link was only being used to get the
-----     importdate so we will do this with the code below.---- LOC/8/1/2014
--declare @begindate datetime, @enddate datetime, @iatanum varchar (10)

--set @begindate = (select min(invoicedate) from dba.invoiceheader where importdt  >='10-1-2013')
--set @enddate = (select max(invoicedate) from dba.invoiceheader where importdt  >='10-1-2013')
--set @iatanum =(select distinct substring(iatanum,1,6) from dba.invoiceheader where importdt  >='10-1-2013')

Insert into dba.contractrmks
select * from TTXSASQL01.tman_ubs.dba.contractrmks
where recordkey in (select recordkey from ttxsasql01.tman_ubs.dba.contractrmks where procenddate > getdate()-3)

--where recordkey in (select recordkey from dba.acminfo where importdt >='10-1-2013')
--and recordkey not in (select recordkey from dba.contractrmks)
--where invoicedate between @begindate and @enddate
--and iatanum <> 'preubs'
	
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-@SQL_PUSH_ACRMKS',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 		    

----Added by rcr  07/07/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') 17-@SQL_PUSH_ACRMKS'
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




--Added by rcr  07/02/2015
SET @TransStart = Getdate() 
--	

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ACM Processing Complete',@BeginDate=@importdt, @EndDate=@importdt,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 
----Added by rcr  07/02/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') ACM Processing Complete'
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
--Added by rcr  07/02/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--	

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 ----Added by rcr  07/02/2015
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
end
--EXEC TTXPASQL01.TMAN_UBS.dbo.sp_UBS_Matchback;



GO
