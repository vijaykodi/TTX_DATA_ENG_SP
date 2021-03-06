/****** Object:  StoredProcedure [dbo].[sp_ACM_Move_to_Production]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_ACM_Move_to_Production]
AS
BEGIN

/************************************************************************
    Set arguments and variables
*************************************************************************/
   
   DECLARE @ImportDate datetime
   DECLARE @Iata VARCHAR(50);
   DECLARE @ProcName VARCHAR(50);
   DECLARE @TransStart DATETIME;
   DECLARE @BeginIssueDate DATETIME = getdate();
   DECLARE @ENDIssueDate DATETIME = getdate(); 



--==-----------------------------For Logging -------------------------------------------------------------------------------------
--=================================
--Added by rcr  07/07/2015
--Adding variables for logging.
--Using the defaults from 
--    Set the defaults here  --
--@LocalBeginIssueDate and @LocalEndIssueDate will be used for @BeginDate and @EndDate 
--=================================
Declare @LocalBeginIssueDate DATETIME = '2014-12-20 09:26:18.000'
, @LocalEndIssueDate DATETIME = '2014-12-20 09:26:18.000'
, @LogSegNbr int = 0
, @LogStep varchar(250)

SET @iata = (select distinct substring(iatanum,1,6) from dba.invoiceheader where importdt =  '2014-12-20 09:26:18.000')
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
--SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------


 --set '2014-12-20 09:26:18.000' =  '2014-09-25 11:09:11.000'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	set @ImportDate = (select max(importdt) from dba.invoiceheader where iatanum <> 'preubs')

-------------------************** Hoping this will work ****************--------------------
--  Pushes data to production when ACMProcessor completes
--  Program will fail if time to process > MaxProcessingTime for customer in ACMDatabases
--  Default fail time is 180 minutes 		---- UBS is set for 360 in the table.	    				    
--SET @TransStart = GETDATE();
--	 SET @ImportDate = (SELECT MAX(ImportDt)FROM DBA.InvoiceHeader WHERE IataNum NOT LIKE 'PRE%');
--    END;


 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
--Log Activity

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--

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
--Next line commented out -- rcr 
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_START - END
************************************************************************/ 

--    IF @ImportDate IS NULL
--    BEGIN


  -------Delete redundant ACMInfo records on production
	
	--Added by rcr  07/07/2015
	WAITFOR DELAY '00:00.30'
	SET @TransStart = Getdate() 
	--

	  Delete Prod
	  from TTXSASQL01.TMAN_UBS.dba.ACMInfo ACMI, dba.ACMinfo Prod
	  where ACMI.RecordKey = Prod.RecordKey and ACMI.IataNum = Prod.IataNum  and ACMI.SeqNum = Prod.SeqNum
	  --and ACMI.Clientcode = Prod.Clientcode  
	  and ACMI.Issuedate = Prod.Issuedate 
	  and ACMI.SegmentNum = Prod.SegmentNum and ACMI.ImportDt =  '2014-12-20 09:26:18.000'

--Next line commented out -- rcr 
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACMI_PROD',@BeginDate='2014-12-20 09:26:18.000',@EndDate='2014-12-20 09:26:18.000',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

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

			 

--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--			 
	--Add new ACMInfo records to production

	 Insert into TTXPASQL01.Tman_UBS.dba.ACMInfo
	 Select *
	 from TTXSASQL01.TMAN_UBS.dba.ACMInfo
	 where ImportDt =  '2014-12-20 09:26:18.000'

--Next line commented out -- rcr 	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_PUSH_ACMI',@BeginDate='2014-12-20 09:26:18.000',@EndDate='2014-12-20 09:26:18.000',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 
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



			  
SET @TransStart = GETDATE();			  
		   --Delete redundant ContractRmk records on production
			 
	  Delete ACRmks
	  from dba.ACMInfo ACMI,dba.ContractRmks ACRmks
	  where ACMI.RecordKey = ACRmks.RecordKey and ACMI.IataNum = ACRmks.IataNum
	  and ACMI.SeqNum = ACRmks.SeqNum --and ACMI.Clientcode = ACRmks.Clientcode 
	  and ACMI.Issuedate = ACRmks.Issuedate and ACMI.SegmentNum = ACRmks.SegmentNum 
	  and ACMI.ImportDt =  '2014-12-20 09:26:18.000'
	  
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-SQL_DEL_ACRMKS_PROD',@BeginDate='2014-12-20 09:26:18.000',@EndDate='2014-12-20 09:26:18.000',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;


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


SET @TransStart = GETDATE(); 			  
		--Add new ContractRmk records to production
-----**** Quering the ACMINFO table is causing major delays in the insert process .. The link was only being used to get the
-----     importdate so we will do this with the code below.---- LOC/8/1/2014
declare @begindate datetime, @enddate datetime, @iatanum varchar (10)

set @begindate = (select min(invoicedate) from dba.invoiceheader where importdt =  '2014-12-20 09:26:18.000')
set @enddate = (select max(invoicedate) from dba.invoiceheader where importdt =  '2014-12-20 09:26:18.000')
set @iatanum = (select distinct substring(iatanum,1,6) from dba.invoiceheader where importdt =  '2014-12-20 09:26:18.000')


Insert into dba.contractrmks
select * from TTXSASQL01.tman_ubs.dba.contractrmks
where invoicedate between @begindate and @enddate
and substring(iatanum,1,6) = @iatanum
	
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


--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='17-@SQL_PUSH_ACRMKS',@BeginDate='2014-12-20 09:26:18.000',@EndDate='2014-12-20 09:26:18.000',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;
 		    
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
--	
----Added by rcr  07/07/2015
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

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ACM Processing Complete',@BeginDate='2014-12-20 09:26:18.000',@EndDate='2014-12-20 09:26:18.000',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR;

 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--Added by rcr  07/07/2015
SET @TransStart = Getdate() 
WAITFOR DELAY '00:00.30'
----Added by rcr  07/07/2015
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

--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
end
--EXEC TTXPASQL01.TMAN_UBS.dbo.sp_UBS_Matchback;




GO
