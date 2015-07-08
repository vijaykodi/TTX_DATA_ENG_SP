/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='InvoiceHeader' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='invoicedetail' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='employee' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='comrmks' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='client' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='city' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='udef' and @Schema='DBA'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_SANOFI']/UnresolvedEntity[@Name='transeg' and @Schema='DBA'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 5:17:43 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_SANOFI_Main]    Script Date: 7/7/2015 5:17:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_SANOFI_Main]
@BeginIssueDate datetime,
@EndIssueDate datetime,
@Iatanum varchar(8)

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	--SET @Iata = @Iatanum varchar -- 'SanMain'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))


--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Sanofi Main Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@IataNum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



----Start IntlSalesInd update 

----Removing original portion following this update to IntlSaleInd per conf call with Brent on 11/22/2013 Pam S
----Created SF 00026299 for this request to change IntlSalesInd for US to CA and CA to US travel from 'I' to 'D'
----Brent advised to make US-CA and CA-US as 'D' for Domestic (Asked if wanted 'T' for Transborder - he answered, "no")
-------all other travel will be 'I' for International
-----Verified with Brent that he meant for IntlSalesInd and not IntlInd.
-----Note - adjusted update to other server TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail since inserts are done before calling this main sp 11.26.2013 Pam S

----Update to Domestic if both origincitycode and SEGDestCityCode are in ('US','CA')
-----This should include within Canada per Charle's response from Sanofi:
-----We consider Domestic as anything within North America, US<>UA, CA<>US, CA<>CA.
SET @TransStart = getdate()
update  TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail 
set IntlSalesInd = 'D'
from TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.transeg ts
,TTXPASQL01.TMAN503_SANOFI.DBA.city c1, TTXPASQL01.TMAN503_SANOFI.DBA.city c2
where id.recordkey = ts.recordkey 
and id.seqnum = ts.seqnum
and c1.citycode = origincitycode 
and c2.citycode = SEGDestCityCode  
and c1.typecode = 'a' 
and c2.typecode = 'a' 
and vendortype in ('bsp','nonbsp') 
and voidind = 'n'
and (c1.countrycode  in ('US', 'CA') and c2.CountryCode  in ('US', 'CA'))
---and id.iatanum in ('SANBCDCA','SANBCDUS') ---covers these 2 only
and id.iatanum = @Iatanum 
--and id.Invoicedate between @BeginIssueDate and @EndIssueDate
and id.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='IntlSalesInd to D for US-CA,CA-US,CA-CA',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Next Update to International if either origincitycode or SEGDestCityCode are not in ('US','CA')
SET @TransStart = getdate()
update  TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail
set IntlSalesInd = 'I'
from TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.transeg ts
,TTXPASQL01.TMAN503_SANOFI.DBA.city c1, TTXPASQL01.TMAN503_SANOFI.DBA.city c2
where id.iatanum = ts.iatanum
and id.recordkey = ts.recordkey 
and id.seqnum = ts.seqnum
and c1.citycode = origincitycode 
and c2.citycode = SEGDestCityCode  
and c1.typecode = 'a' 
and c2.typecode = 'a' 
and vendortype in ('bsp','nonbsp') 
and voidind = 'n'
and (c1.countrycode not in ('US', 'CA') or  c2.CountryCode not in ('US', 'CA'))
--and id.iatanum in ('SANBCDCA','SANBCDUS') ---covers these 2 only
and id.iatanum = @Iatanum 
--and id.Invoicedate between @BeginIssueDate and @EndIssueDate
and id.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='IntlSalesInd to I for not US-CA or CA-US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Portion removing ---see notes above
--update i
--set IntlSalesInd = case when c1.countrycode in ('US', 'CA') and c2.countrycode in ('US','CA') then 'D' else 'I'end
--from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--and c1.typecode = 'a' and c2.typecode = 'a' and vendortype in ('bsp','nonbsp') and voidind = 'n'
--and i.iatanum = @Iatanum and i.Invoicedate between @BeginIssueDate and @EndIssueDate

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update all Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--update i set IntlSalesInd = 'I'
--from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--and c1.typecode = 'a' and c2.typecode = 'a'
--and vendortype in ('bsp','nonbsp') and voidind = 'n'
--and t.recordkey in (select  t.recordkey from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--	where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--	and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--	and c1.typecode = 'a' and c2.typecode = 'a'
--	and vendortype in ('bsp','nonbsp') and voidind = 'n' and c1.countrycode not in ('US', 'CA') 
--	and c2.countrycode not in ('US','CA') and segmentnum = '1')
--and t.recordkey in (select  t.recordkey from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--	where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--	and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--	and c1.typecode = 'a' and c2.typecode = 'a'
--	and vendortype in ('bsp','nonbsp') and voidind = 'n' and c1.countrycode  in ('US', 'CA') 
--	and c2.countrycode  in ('US','CA') and segmentnum <> '1')
--and i.iatanum = @Iatanum and i.Invoicedate between @BeginIssueDate and @EndIssueDate

--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Seg 1 Not D Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--update i set IntlSalesInd = 'I'
--from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--and c1.typecode = 'a' and c2.typecode = 'a'
--and vendortype in ('bsp','nonbsp') and voidind = 'n'
--and t.recordkey in (select  t.recordkey from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--	where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--	and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--	and c1.typecode = 'a' and c2.typecode = 'a'
--	and vendortype in ('bsp','nonbsp') and voidind = 'n' and c1.countrycode in ('US', 'CA') 
--	and c2.countrycode in ('US','CA') and segmentnum = '1')
--and t.recordkey in (select  t.recordkey from dba.invoicedetail i, dba.transeg t, dba.city c1, dba.city c2
--	where i.recordkey = t.recordkey and i.seqnum = t.seqnum
--	and c1.citycode = origincitycode and c2.citycode = mindestcitycode
--	and c1.typecode = 'a' and c2.typecode = 'a'
--	and vendortype in ('bsp','nonbsp') and voidind = 'n' and c1.countrycode not in ('US', 'CA') 
--	and c2.countrycode not in ('US','CA') and segmentnum <> '1')
--and i.iatanum = @Iatanum and i.Invoicedate between @BeginIssueDate and @EndIssueDate
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Seg 1 = D Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------END - IntlSalesInd Update ------------------------------------

SET @TransStart = getdate()
update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text11 = case when substring(text6,3,2) in ('CT','TD','IT','NI','VT','ET','EH','TE') then 'N'
	else 'Y' end
where Invoicedate between @BeginIssueDate and @EndIssueDate
--and iatanum in ('SANBCDCA','SANBCDUS') ---covers these 2 only
and iatanum = @Iatanum 
and Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text11 update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------END - TEXT11 UPDATES

----  *****Note Sanofi has overlapping Employee IDs, so must be very careful in doing updates for Employee
----             on 8/22/2014 results to query below = 169 employees that have the overlapping

----select distinct e1.employeeid1, e1.employeeid2,e1.lastname,e1.firstname,e1.Company
----,e2.employeeid1,e2.EmployeeID2,e2.lastname,e2.firstname,e2.Company
------,e2.BeginDate,e2.BeginDate
----from dba.employee e1, dba.employee e2
----where 1=1
----and e1.EmployeeID1 = e2.EmployeeID2
----and e1.EmployeeID2 <> e2.EmployeeID2
----and e1.EmployeeID1 <> e2.EmployeeID1
----and e1.BeginDate = e2.BeginDate
----and e1.EndDate = e2.EndDate



-------BEGIN FOR EMPLOYEE MAPPING -----------------------------------------

------------------Brent wanted this portion added per Internal Sanofi call on 11.22.2013 SF00026298 Pam S
------------------Note inserts into TTXPASQL01.TMAN503_SANOFI.DBA.comrmks are done before this sp
----Pam S Updated - 1/23/2014 - SANBCDUS files failing because "Invalid column name 'convergenceid'"
-----Sent email to Brent and Jim asking why other table deleted and to verify. 
----Found case 00028372 where mapping was updated to 'dba.employeeMappingGenzyme' by Nina on '12/27/2013' (which made all other non-Genzyme employees get updated incorrectly)
---- Pam S Updated again 2/4/2014 - See SF 00029200 and 00026764 ---Removing this portion for Employee mapping since data cannot be trusted
-----------Agency data for Merial and Genzym have PSIDs in U20 which updates text1 and does not match EmployeeID1
-----------Also PSIDs provided in agency data do not match EmployeeID2 correctly either.
--SET @TransStart = getdate()
--update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text50 = NULL
--where iatanum = @Iatanum and Invoicedate between @BeginIssueDate and @EndIssueDate

--update cr
--set text50 = e.EmployeeID1
--from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr, TTXPASQL01.tman503_sanofi.dba.employee e
--where cr.text1 = e.EmployeeID1
--and cr.iatanum = @Iatanum and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50 - Employee',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------------------------------------------------------------------------------
----Added 2.5.2014 by Pam S per SF 00030788
----Note only iatanum in ('SANBCDCA','SANBCDUS') currently using Text50 for conditions to update Text1

----ADDING PRELIMINARY STEPS TO UPDATE TEXT35 FOR EMAIL TO MATCH ON EMPLOYEE TABLE ALONG WITH TEXT50 --PAM S 2.11.2014
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014

--SET @TransStart = getdate()
--UPDATE CR
--SET CR.Text33 = substring(ud.udefdata,1,150)
--FROM TTXPASQL01.TMAN503_SANOFI.DBA.ComRmks CR
--Inner Join TTXPASQL01.TMAN503_SANOFI.DBA.Udef UD on 
--(CR.RecordKey = UD.RecordKey AND CR.SeqNum = UD.SeqNum and CR.IataNum = UD.IataNum
--AND CR.ClientCode = UD.ClientCode AND CR.InvoiceDate = UD.InvoiceDate and cr.IssueDate = ud.IssueDate )
--where UD.UdefNum = 114 and CR.text33 is null
----and CR.iatanum in ('SANBCDCA','SANBCDUS') ---covers these 2 only
--and CR.iatanum = @Iatanum 
--and CR.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text33 - Name for Email',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--UPDATE CR
--SET CR.Text34 = substring(ud.udefdata,1,150)
--FROM TTXPASQL01.TMAN503_SANOFI.DBA.ComRmks CR
--Inner Join TTXPASQL01.TMAN503_SANOFI.DBA.Udef UD on 
--(CR.RecordKey = UD.RecordKey AND CR.SeqNum = UD.SeqNum and CR.IataNum = UD.IataNum
--AND CR.ClientCode = UD.ClientCode AND CR.InvoiceDate = UD.InvoiceDate and cr.IssueDate = ud.IssueDate )
--where UD.UdefNum = 115 and CR.text34 is null
------and CR.iatanum in ('SANBCDCA','SANBCDUS') ---covers these 2 only
--and CR.iatanum = @Iatanum 
--and CR.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text34 - Domain of Email',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--Update CR
--Set text35 = isnull(text33,'') + '@' + isnull(text34,'')
--FROM TTXPASQL01.TMAN503_SANOFI.DBA.ComRmks CR
--where CR.iatanum in ('SANBCDCA','SANBCDUS')
--and cr.text35 is  null
--and (cr.text33 is not null or cr.text34 is not null)
----and CR.iatanum in ('SANBCDCA','SANBCDUS') ---covers these 2 only
--and CR.iatanum = @Iatanum 
--and CR.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text35 - Complete Email',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----------End updates for adding EMAIL to ComRmks Text35 -------------------------------------

----BCD no longer sending email info due to Decision Source ******** 
-------So removed all steps matching on email ----
-------Also removed U20 and replaced with UD 6 for EmployeeID for both SANBCDUS and SANBCDCA
-------SF 00032259 for SANBCDUS Pam S 2.28.2014 
-------SF 00032628 for SANBCDCA Pam S 3.5.2014 
-------SF 00035884 - While verifying data from March 2014 load, found previous records dated before March where 
-------              text1 was not updated becase they added employee # to the employee table on 4/10/2014
-------				 so, am removing dates from Employee Update steps


----Updates for Merial when Text50 = EmployeeID2 (PSID) and LastNames match 
----and Company names match without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
--and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
----and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.custname like '%merial%' 
and e.company like '%merial%' 
and cr.text50 = e.employeeid2
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
--and id.firstname = e.firstname
and isnull(cr.text1,'') <> e.Employeeid1 
---and cr.Text1 is null
and cr.Text50 is not null
and cr.iatanum = @Iatanum 
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Merial Text1 when Text50=EmployeeID2-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Updates for Text1 Merial when Text50 = EmployeeID2 (PSID) and LastNames match and emails match and going by CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014

----SET @TransStart = getdate()
----Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
----set text1 = EmployeeID1 
----from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
----, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
----where u.iatanum = cl.iatanum 
----and u.clientcode = cl.clientcode 
----and u.iatanum = cr.iatanum 
------and cr.iatanum in ('SANBCDCA','SANBCDUS') 
----and u.recordkey = cr.recordkey 
----and u.seqnum = cr.seqnum 
----and cr.iatanum = id.iatanum 
----and cr.recordkey = id.recordkey 
----and cr.seqnum = id.seqnum 
----and udefnum = 20 
----and cl.custname like 'merial%' 
----and cr.Text35 = e.EmpEmail
----and cr.text50 = e.employeeid2
----and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname
----and isnull(cr.text1,'') <> e.Employeeid1 
----and cr.iatanum = @Iatanum 
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
----EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Merial Text1 when Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for Text1 Merial when eliminating leading zeros of Text50 = EmployeeID2 (PSID), and match on Lastname and emails
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
------3/6/2014 - Added this step below for preceding 0's , and made adjustments
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
----and cr.iatanum in ('SANBCDCA','SANBCDUS') 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and (cl.CustName like '%Merial%' and e.Company like '%Merial%')
--and cr.Text35 = e.EmpEmail
--and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
--and REPLACE(LTRIM(REPLACE(cr.Text50, '0', ' ')), ' ', '0')= e.EmployeeID2
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
----and id.firstname = e.firstname
--and isnull(cr.text1,'') <> e.Employeeid1 
--and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Merial Text1 w/0 Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for Text1 Merial when eliminating leading 9's of Text50 = EmployeeID2 (PSID), and match on Lastname and emails
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
------and cr.iatanum in ('SANBCDCA','SANBCDUS') 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and (cl.CustName like '%Merial%' and e.Company like '%Merial%')
--and cr.Text35 = e.EmpEmail
--and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
--and REPLACE(LTRIM(REPLACE(cr.Text50, '9', ' ')), ' ', '9')= e.EmployeeID2
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
----and id.firstname = e.firstname
--and isnull(cr.text1,'') <> e.Employeeid1 
--and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Merial Text1 w/9 Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



---Updates for Text1 Merial when Text50 = EmployeeID1 (ConvID) and LastNames match and Company names match without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks  
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e  
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
--and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R' 
and cl.custname like '%merial%' 
and e.company like '%merial%' 
and cr.text50 = e.employeeid1
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
--and id.firstname = e.firstname
and isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null
and cr.Text50 is not null
and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Merial Text1 when Text50=EmployeeID1-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for Text1 Merial when Text50 = EmployeeID1 (ConvID) and LastNames match and Emails Match using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks  
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e  
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
----and cr.iatanum in ('SANBCDCA','SANBCDUS') 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.custname like 'merial%' 
--and cr.text50 = e.employeeid1
--and cr.Text35 = e.EmpEmail
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
----and id.firstname = e.firstname
--and isnull(cr.text1,'') <> e.Employeeid1 
--and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Merial Text1 when Text50=EmployeeID1-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------End Merial

---------Begin Genzyme 


---Updates for Genzyme when Text50 = EmployeeID2 (PSID) and LastNames match and Company matches without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e  
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
and u.recordkey = cr.recordkey 
--and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.custname like '%genz%' 
and e.company like '%genz%' 
and cr.text50 = e.employeeid2 
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
--and id.firstname = e.firstname 
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Genz. Text1 when Text50=EmployeeID2-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Updates for Genzyme when Text50 = EmployeeID2 (PSID) and LastNames match and Email matches using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e  
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
----and cr.iatanum in ('SANBCDCA','SANBCDUS') 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.custname like 'genz%' 
--and cr.text50 = e.employeeid2 
--and cr.Text35 = e.EmpEmail
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
----and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
--and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Genz. Text1 when Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for Genzyme when '400' or '4000'+ Text50 = EmployeeID2 (PSID) and LastNames match and Email matches using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
-------Revised 3.6.2014 and added step back in - see step below towards end ----
----SET @TransStart = getdate()
----Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
----set text1 = EmployeeID1 
----from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
----, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e  
----where u.iatanum = cl.iatanum 
----and u.clientcode = cl.clientcode 
----and u.iatanum = cr.iatanum 
----and u.recordkey = cr.recordkey 
------and cr.iatanum in ('SANBCDCA','SANBCDUS') 
----and u.seqnum = cr.seqnum 
----and cr.iatanum = id.iatanum 
----and cr.recordkey = id.recordkey 
----and cr.seqnum = id.seqnum 
----and udefnum = 20 
----and (cl.custname like 'genz%' or e.company like 'genz%')
----and (('400' + cr.Text50) = e.employeeid2 or ('4000' + cr.Text50) = e.employeeid2)
----and cr.Text35 = e.EmpEmail
----and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname 
----and isnull(cr.text1,'') <> e.Employeeid1
----and cr.iatanum = @Iatanum 
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
----EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Genz. Text1 w 400+Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Updates for Genzyme when Text50 = EmployeeID1 (ConvID) and LastNames match and Company matches without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
----and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.custname like '%genz%' 
and e.company like '%genz%' 
and cr.text50 = e.employeeid1 
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
--and id.firstname = e.firstname 
and isnull(cr.text1,'') <> e.Employeeid1
----and cr.Text1 is null
and cr.Text50 is not null
and cr.iatanum = @Iatanum 
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Genz. Text1 when Text50=EmployeeID1-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for Genzyme when Text50 = EmployeeID1 (ConvID) and LastNames match and Emails match using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
----and cr.iatanum in ('SANBCDCA','SANBCDUS') 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.custname like 'genz%' 
------and e.company like '%genz%' 
--and cr.text50 = e.employeeid1 
--and cr.Text35 = e.EmpEmail
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
----and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
--and cr.iatanum = @Iatanum 
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Genz. Text1 when Text50=EmployeeID1-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------End Genzyme (CustName)

-----------Begin Chattem

---Updates for Chattem when Text50 = EmployeeID1 (ConvID) and LastNames match and Company matches
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
--and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
----and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
--and cl.custname like '%chattem%' 
and e.company like '%chattem%' 
and cr.text50 = e.EmployeeID1
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
--and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
and cr.Text1 is null
and cr.Text50 is not null
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Chat. Text1 when Text50=EmployeeID1-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------End Chattem

--------------Begin %AVENTIS%' -------------

---Updates for %AVENTIS% when Text50 = EmployeeID2 (PSID) and LastNames match and Company matches without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
--and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.CustName like '%AVENTIS%'
and e.company like '%AVENTIS%' 
and cr.text50 = e.EmployeeID2
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
----and id.firstname = e.firstname 
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Avent. Text1 when Text50=EmployeeID2-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Updates for'%AVENTIS%' when Text50 = EmployeeID2 (PSID) and LastNames match and Emails matche using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
----and cr.iatanum in ('SANBCDCA','SANBCDUS') 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.CustName like '%AVENTIS%'
------and e.company like '%AVENTIS%'
--and cr.text50 = e.EmployeeID2
--and cr.Text35 = e.EmpEmail 
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
--and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Avent. Text1 when Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for'%Canada%' when replace('CA')in Text50 = ('00')in EmployeeID2 (PSID) and LastNames match and Emails match
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
----Updated 3/6/2014 Per SF 00032682 Pam S 
------- Analyzed - Even though emails removed from BCD Decision Source, this step can be added back in for Canada
--------Modifed from udefnum = 20 to: udefnum = 6 and udeftype = 'R' 
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where cr.iatanum = cl.iatanum 
and cr.clientcode = cl.ClientCode
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
and cr.IssueDate = id.IssueDate
and cr.ClientCode = id.ClientCode
and cr.iatanum = u.iatanum 
and cr.recordkey = u.recordkey 
and cr.seqnum = u.seqnum 
and cr.IssueDate = u.IssueDate
and cr.ClientCode = u.ClientCode
and id.ClientCode = cl.ClientCode
and u.ClientCode = cl.ClientCode
and udefnum = 6 and udeftype = 'R' 
and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
and REPLACE(cr.text50,'CA','00') = e.EmployeeID2
and LEFT(cr.text50,2) = 'CA'
and  (cl.custname like '%canada%' or e.company like '%canada%')
-------and cr.Text35 = e.EmpEmail 
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
and cr.iatanum in ('SANBCDCA') 
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from CA in Text50=EmployeeID2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added per review of data from SF 00037151 5/16/2014 Pam S
---Updates for'%Canada%' when replace('CA')in Text50 = ('90')in EmployeeID1 and LastNames match
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where cr.iatanum = cl.iatanum 
and cr.clientcode = cl.ClientCode
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
and cr.IssueDate = id.IssueDate
and cr.ClientCode = id.ClientCode
and cr.iatanum = u.iatanum 
and cr.recordkey = u.recordkey 
and cr.seqnum = u.seqnum 
and cr.IssueDate = u.IssueDate
and cr.ClientCode = u.ClientCode
and id.ClientCode = cl.ClientCode
and u.ClientCode = cl.ClientCode
and udefnum = 6 and udeftype = 'R' 
and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
and REPLACE(cr.text50,'CA','90') = e.EmployeeID1
and LEFT(cr.text50,2) = 'CA'
and  (cl.custname like '%canada%' or e.company like '%canada%')
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
and cr.iatanum in ('SANBCDCA') 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CA in Text50= 90 EmployeeID1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




---Updates for %AVENTIS% when Text50 = EmployeeID1 (ConvID) and LastNames match and Company matches without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.CustName like '%AVENTIS%'
and e.company like '%AVENTIS%' 
and cr.text50 = e.EmployeeID1
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
----and id.firstname = e.firstname 
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
--and cr.iatanum in ('SANBCDCA','SANBCDUS')
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Avent. Text1 when Text50=EmployeeID1-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for '%AVENTIS%' when Text50 = EmployeeID1 (ConvID) and LastNames match and Emails match using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.CustName like '%AVENTIS%'
----and e.company like '%AVENTIS%'
--and cr.text50 = e.EmployeeID1
--and cr.Text35 = e.EmpEmail 
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
----and cr.iatanum in ('SANBCDCA','SANBCDUS')
--and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Avent. Text1 when Text50=EmployeeID1-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




--------------End '%AVENTIS%'

--------------Begin  '%PASTEUR%' -------------------

---Updates for '%PASTEUR%' when Text50 = EmployeeID2 (PSID) and LastNames match and Company matches without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.CustName like '%PASTEUR%'
and e.company like '%PASTEUR%' 
and cr.text50 = e.EmployeeID2
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
----and id.firstname = e.firstname 
and isnull(cr.text1,'') <> e.Employeeid1
---and cr.Text1 is null
and cr.Text50 is not null
--and cr.iatanum in ('SANBCDCA','SANBCDUS')
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Past. Text1 when Text50=EmployeeID2-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Updates for '%PASTEUR%' when Text50 = EmployeeID2 (PSID) and LastNames match and Emails matche using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.CustName like '%PASTEUR%'
------and e.company like '%PASTEUR%' 
--and cr.text50 = e.EmployeeID2
--and cr.Text35 = e.EmpEmail 
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
----and cr.iatanum in ('SANBCDCA','SANBCDUS')
--and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Past. Text1 when Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




---Updates for '%PASTEUR%' when Text50 = EmployeeID1 (ConvID) and LastNames match and Company matches without matching on email
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where u.iatanum = cl.iatanum 
and u.clientcode = cl.clientcode 
and u.iatanum = cr.iatanum 
and u.recordkey = cr.recordkey 
and u.seqnum = cr.seqnum 
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
--and udefnum = 20 
and udefnum = 6 and UdefType = 'R'
and cl.CustName like '%PASTEUR%'
and e.company like '%PASTEUR%' 
and cr.text50 = e.EmployeeID1
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
----and id.firstname = e.firstname 
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
--and cr.iatanum in ('SANBCDCA','SANBCDUS')
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Past. Text1 when Text50=EmployeeID1-CompanyMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---Updates for '%PASTEUR%' when Text50 = EmployeeID1 (ConvID) and LastNames match and Emails match using CustName only
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cl.CustName like '%PASTEUR%'
----and e.company like '%PASTEUR%' 
--and cr.text50 = e.EmployeeID1
--and cr.Text35 = e.EmpEmail 
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
----and cr.iatanum in ('SANBCDCA','SANBCDUS')
--and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Past. Text1 when Text50=EmployeeID1-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------End  '%PASTEUR%'


-------------Begin Others where left 6 of EmployeeID2 = Text50 and LastNames and Emails Match 
-------------and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
-----Removing email steps -as of 2/3/2014 - BCD no longer sending email info due to Decision Source -SF 00032259 Pam S 2.28.2014

--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
--set text1 = EmployeeID1 
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cr.Text35 = e.EmpEmail 
--and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
--and cr.Text50 = LEFT(e.employeeid2,6)
--and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
------and id.firstname = e.firstname 
--and isnull(cr.text1,'') <> e.Employeeid1
----and cr.iatanum in ('SANBCDCA','SANBCDUS')
--and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --adding index for optimization
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Other. Text1 w/L6 Text50=EmployeeID2-EmailMatch',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



----Commenting out until further updates
--------To capture others ----
--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks
--set text50 = EmployeeID1
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e  
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cr.text1 is not null
--and cr.text1 = e.employeeid2
--and isnull(cr.text50,'') <> e.Employeeid1
--and id.lastname = e.lastname
--and left(id.firstname,1) = left(e.firstname,1)
--and cr.iatanum = @Iatanum and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Others Text50 when Text1 = EmployeeID2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks
--set text50 = EmployeeID1
--from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
--, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
--where u.iatanum = cl.iatanum 
--and u.clientcode = cl.clientcode 
--and u.iatanum = cr.iatanum 
--and u.recordkey = cr.recordkey 
--and u.seqnum = cr.seqnum 
--and cr.iatanum = id.iatanum 
--and cr.recordkey = id.recordkey 
--and cr.seqnum = id.seqnum 
--and udefnum = 20 
--and cr.text1 is not null
--and cr.text1 = e.employeeid1
--and isnull(cr.text50,'') <> e.Employeeid1
--and id.lastname = e.lastname
--and left(id.firstname,1) = left(e.firstname,1)
--and cr.iatanum = @Iatanum and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Others Text50 when Text1 = EmployeeID1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------Added 2.14.2014 by Pam S based on emails matching SF 00030788
----Others Update Text50 when Text1 = EmployeeID2 with Email Matching

----SET @TransStart = getdate()
----Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks
----set text1 = EmployeeID1
----from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
----, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
----where cr.iatanum in ('SANBCDCA','SANBCDUS')
----and cr.iatanum = cl.iatanum 
----and cr.clientcode = cl.ClientCode
----and cr.iatanum = id.iatanum 
----and cr.recordkey = id.recordkey 
----and cr.seqnum = id.seqnum 
----and cr.IssueDate = id.IssueDate
----and cr.ClientCode = id.ClientCode
----and cr.iatanum = u.iatanum 
----and cr.recordkey = u.recordkey 
----and cr.seqnum = u.seqnum 
----and cr.IssueDate = u.IssueDate
----and cr.ClientCode = u.ClientCode
----and id.ClientCode = cl.ClientCode
----and u.ClientCode = cl.ClientCode
----and udefnum = 20 
----and cr.text50 = e.employeeid2
----and cr.Text35 = e.EmpEmail --103,353
------and isnull(cr.text1,'') <> e.Employeeid1
----and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','') 
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='OthersText50 when Text1=EmployeeID2 w/Email Match',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------Others Update Text50 when Text1 = EmployeeID1 with Email Matching

----SET @TransStart = getdate()
----Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks
----set text1 = EmployeeID1
----from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
----, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
----where cr.iatanum in ('SANBCDCA','SANBCDUS')
----and cr.iatanum = cl.iatanum 
----and cr.clientcode = cl.ClientCode
----and cr.iatanum = id.iatanum 
----and cr.recordkey = id.recordkey 
----and cr.seqnum = id.seqnum 
----and cr.IssueDate = id.IssueDate
----and cr.ClientCode = id.ClientCode
----and cr.iatanum = u.iatanum 
----and cr.recordkey = u.recordkey 
----and cr.seqnum = u.seqnum 
----and cr.IssueDate = u.IssueDate
----and cr.ClientCode = u.ClientCode
----and id.ClientCode = cl.ClientCode
----and u.ClientCode = cl.ClientCode
----and udefnum = 20 
----and cr.text50 = e.EmployeeID1 
----and cr.Text35 = e.EmpEmail 
------and isnull(cr.text1,'') <> e.Employeeid1
----and replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''','') = replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''','')  
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='OthersText50 when Text1=EmployeeID1 w/Email Match',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Updated 3/6/2014 Per SF 00032682 Pam S 
------- Analyzed - data from BCD Decision Source
------- Noticed more current records using PeopleSoftId 
--------Found where Employee table had preceding '400' to the IDs in Agency data - Matched on names
--------based on Udefnum = 6 and udeftype = 'R' 
-----On 5/23/2014 - Took out join on Udef - because former UD20 had same issue - Therefore just using where '4' + RIGHT('0000' + text50, 7)= e.EmployeeID2

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e , TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH 
where 1 = 1
and cr.IataNum = cl.IataNum
and cr.ClientCode = cl.ClientCode

--and cr.iatanum in ('SANBCDCA','SANBCDUS') 

and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 

and cr.IataNum = ih.IataNum
and cr.RecordKey = ih.RecordKey
and cr.InvoiceDate = ih.InvoiceDate

and id.IssueDate between e.BeginDate and e.EndDate
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
and '4' + RIGHT('0000' + text50, 7)= e.EmployeeID2
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
and LEFT(id.firstname,1) = LEFT(e.FirstName,1)
and Text50 not in ( '0000000','00000000','123456','11111111','55555555','CA999999','APPLICANT'
,'CNTRCTANWA','CNTRCTDAJOHNSON','77777','777777','77777777','7777777777','99999','99999999')
and Text50 not like 'CNTRCTSAKHAN%' 
and Text50 not like 'EXT%'  
and cr.Text50 not like '%[A-Z][A-Z][A-Z]%'
--and cr.iatanum in ('SANBCDCA','SANBCDUS')
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from Text50=400 +EmployeeID2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Updated 3/6/2014 Per SF 00032682 Pam S 
------- Analyzed - data from BCD Decision Source
------- Noticed more current records using PeopleSoftId 
--------Found where BCD data had preceding 0's and Employee table did not
--------Matched on Last Names - based on Udefnum = 6 and udeftype = 'R' 
----Updated 5/23/2014 by PamS - added match on left(firstname,1) - from finding same LastName Roberts/ Diff first names - See EmployeeID1 in ('00030573','93030573')
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where cr.iatanum = cl.iatanum 
and cr.clientcode = cl.ClientCode
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
and cr.IssueDate = id.IssueDate
and cr.ClientCode = id.ClientCode
and cr.iatanum = u.iatanum 
and cr.recordkey = u.recordkey 
and cr.seqnum = u.seqnum 
and cr.IssueDate = u.IssueDate
and cr.ClientCode = u.ClientCode
and id.ClientCode = cl.ClientCode
and u.ClientCode = cl.ClientCode
and udefnum = 6 and udeftype = 'R' 
--and isnull(cr.text1,'') <> e.Employeeid1
and cr.Text1 is null
and cr.Text50 is not null
and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
and REPLACE(LTRIM(REPLACE(cr.Text50, '0', ' ')), ' ', '0')= e.EmployeeID2

and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
and LEFT(id.firstname,1) = LEFT(e.FirstName,1)
and Text50 not in ( '0000000','00000000','123456','11111111','55555555','CA999999','APPLICANT'
,'CNTRCTANWA','CNTRCTDAJOHNSON','77777','777777','77777777','7777777777','99999','99999999')
and Text50 not like 'CNTRCTSAKHAN%' 
and Text50 not like 'EXT%'  
and cr.Text50 not like '%[A-Z][A-Z][A-Z]%'

----and cr.iatanum in ('SANBCDCA','SANBCDUS')
and cr.iatanum = @Iatanum
--and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
--and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from Text50 w/ preceding 0s to EmployeeID2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----Added 5/12/2014 by Pam S SF 00037151 - after BCD resent 9/1/2012 to 2/28/2014 - from reanalyzing data with Udid 6 type R - 
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = Text50
from TTXPASQL01.TMAN503_SANOFI.DBA.udef u, TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e 
where cr.iatanum = cl.iatanum 
and cr.clientcode = cl.ClientCode
and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 
and cr.IssueDate = id.IssueDate
and cr.ClientCode = id.ClientCode
and cr.iatanum = u.iatanum 
and cr.recordkey = u.recordkey 
and cr.seqnum = u.seqnum 
and cr.IssueDate = u.IssueDate
and cr.ClientCode = u.ClientCode
and id.ClientCode = cl.ClientCode
and u.ClientCode = cl.ClientCode
and udefnum = 6 and udeftype = 'R' 
and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)
and REPLACE(cr.text50,'000','') = e.EmployeeID1
and LEFT(cr.text50,3) = '000'
--and  (cl.custname like '%canada%' or e.company like '%canada%')
-------and cr.Text35 = e.EmpEmail 
--and isnull(cr.text1,'') <> e.Employeeid1
and cr.Text1 is null
and cr.Text50 is not null
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
and LEFT(id.firstname,4) = LEFT(e.FirstName,4)
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from Text50 w/ preceding 0s to EmployeeID1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



------------------------------

----Updated 3/6/2014 Per SF 00032682 Pam S 
------- Analyzed - data from BCD Decision Source
------- Noticed more current records using PeopleSoftId 
--------Found where Employee Table had preceding 0's and BCD data did not
--------Matched on Last Names - based on Udefnum = 6 and udeftype = 'R' 
-----Updated 5/23/2014 - Found more previous records from UD20 that had same issue, so removing join to Udef and adding match on first name
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.client cl,TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
, TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id, TTXPASQL01.TMAN503_SANOFI.DBA.employee e , TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH 
where 1 = 1
and cr.IataNum = cl.IataNum
and cr.ClientCode = cl.ClientCode

--and cr.iatanum in ('SANBCDCA','SANBCDUS') 

and cr.iatanum = id.iatanum 
and cr.recordkey = id.recordkey 
and cr.seqnum = id.seqnum 

and cr.IataNum = ih.IataNum
and cr.RecordKey = ih.RecordKey
and cr.InvoiceDate = ih.InvoiceDate


and id.IssueDate between e.BeginDate and e.EndDate
and isnull(cr.text1,'') <> e.Employeeid1
--and cr.Text1 is null
and cr.Text50 is not null
and (cr.Text50 <> e.EmployeeID1 and cr.Text50 <> e.EmployeeID2)

and cr.Text50 = REPLACE(LTRIM(REPLACE(e.EmployeeID2, '0', ' ')), ' ', '0')

and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','')
and LEFT(id.FirstName,1) = LEFT(e.firstname,1)
and cr.Text50 not in ( '0000000','00000000','123456','11111111','55555555','CA999999','APPLICANT'
,'CNTRCTANWA','CNTRCTDAJOHNSON','77777','777777','77777777','7777777777','99999','99999999')
and cr.Text50 not like 'CNTRCTSAKHAN%' 
and cr.Text50 not like 'EXT%'  
and cr.Text50 not like '%[A-Z][A-Z][A-Z]%'

----and cr.iatanum in ('SANBCDCA','SANBCDUS')
and cr.iatanum = @Iatanum
----and cr.Invoicedate between @BeginIssueDate and @EndIssueDate
----and CR.Issuedate between @BeginIssueDate and @EndIssueDate --using index for optimization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text1 from Text50= EmployeeID2 with preceding 0s',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------------------------------------------------------------------------------------------------------------

---------Per SF 00044090 - Many records were not getting updated becasue Sanofi did not have company name in Employee table
-----------8/20/2014 Pam S added logic based on CustName from Agency = company showing in EmpEmail
---------------------adding cr.issuedate between e.begindate and e.enddate ....8/21/2014 Pam S

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.employeeid2)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 

and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','') 
--and id.firstname = e.firstname 

and replace(cl.CustName,' ','') = substring(empemail,charindex('@',empemail)+1,((Len(EmpEmail)-4) - (charindex('@',EmpEmail))))
and EmpEmail like '%@%.com'
 
------and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmployeeID2, Cust =EmpEmail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID1)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 

and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','') = Replace(replace(REPLACE(replace(e.lastname,' ',''),'-',''),'''',''),'.','') 
--and id.firstname = e.firstname 

and replace(cl.CustName,' ','') = substring(empemail,charindex('@',empemail)+1,((Len(EmpEmail)-4) - (charindex('@',EmpEmail))))
and EmpEmail like '%@%.com'
 
------and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmployeeID1, Cust =EmpEmail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---When Text50 = EmployeeID2 and Psgr First.Last Name = Email Name

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID2)

where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
and EmpEmail like '%.%@%.com'
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       = substring(empemail,(charindex('.',EmpEmail)+1),((charindex('@',EmpEmail))-(charindex('.',EmpEmail)+1)))
and Replace(replace(REPLACE(replace(id.FirstName,' ',''),'-',''),'''',''),'.','')
       = left(empemail,(charindex('.',EmpEmail)-1))
       
----and cl.CustName = substring(empemail,charindex('@',empemail)+1,((Len(EmpEmail)-4) - (charindex('@',EmpEmail))))

 --and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID2,Psr =EmpEmail Name',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---When Text50 = EmployeeID1 and Psgr First.Last Name = Email Name

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.employeeid1)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
and EmpEmail like '%.%@%.com'
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       = substring(empemail,(charindex('.',EmpEmail)+1),((charindex('@',EmpEmail))-(charindex('.',EmpEmail)+1)))
and Replace(replace(REPLACE(replace(id.FirstName,' ',''),'-',''),'''',''),'.','')
       = left(empemail,(charindex('.',EmpEmail)-1))
       
----and cl.CustName = substring(empemail,charindex('@',empemail)+1,((Len(EmpEmail)-4) - (charindex('@',EmpEmail))))

 --and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID1,Psr =EmpEmail Name',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------

-----8/22/2014 SF 00044090 - Adding Exact Match on Psgr First & Last Name to Employee First & Last Name
------------------------------------When Text50 = EmployeeID2 (PeopleSoft ID)

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID2)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
 
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       =  Replace(replace(REPLACE(replace(e.LastName,' ',''),'-',''),'''',''),'.','')
and Replace(replace(REPLACE(replace(id.FirstName,' ',''),'-',''),'''',''),'.','')
       = Replace(replace(REPLACE(replace(e.FirstName,' ',''),'-',''),'''',''),'.','')
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID2,ExactPsgrToEmp First-Last',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----8/22/2014 SF 00044090 - Adding Exact Match on Psgr First & Last Name to Employee First & Last Name
-------------------------------- ---When Text50 = EmployeeID1 (Convergence ID)


SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1 
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.employeeid1)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
 
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       =  Replace(replace(REPLACE(replace(e.LastName,' ',''),'-',''),'''',''),'.','')
and Replace(replace(REPLACE(replace(id.FirstName,' ',''),'-',''),'''',''),'.','')
       = Replace(replace(REPLACE(replace(e.FirstName,' ',''),'-',''),'''',''),'.','')
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID1,ExactPsgrToEmp First-Last',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------
------  8/22/2014 Pam S added per SF 00044090
------            When Psgr Last Name = Employee Last Name
------------------and extracting first portion of Psgr First Name to = Employee First Name where there are middle names or salutations in Psgr First Name
------------------when Text50 = ID2

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID2)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
       
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       =  Replace(replace(REPLACE(replace(e.LastName,' ',''),'-',''),'''',''),'.','')
       
and LEFT(Id.FirstName, CASE WHEN charindex(' ', ID.FirstName) = 0 THEN 
    LEN(ID.FirstName) ELSE charindex(' ', ID.FirstName) - 1 END)= e.firstname
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID2,ExtractPsgrToEmp First-Last',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------  8/22/2014 Pam S added per SF 00044090
------            When Psgr Last Name = Employee Last Name
------------------and extracting first portion of Psgr First Name to = Employee First Name where there are middle names or salutations in Psgr First Name
------------------when Text50 = ID1

SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID1)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
       
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       =  Replace(replace(REPLACE(replace(e.LastName,' ',''),'-',''),'''',''),'.','')
       
and LEFT(Id.FirstName, CASE WHEN charindex(' ', ID.FirstName) = 0 THEN 
    LEN(ID.FirstName) ELSE charindex(' ', ID.FirstName) - 1 END)= e.firstname
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID1,ExtractPsgrToEmp First-Last',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----8/22/2014 Pam S added for when:  Space in Id.LastName
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID2)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
       
and LEFT(Id.Lastname, CASE WHEN charindex(' ', ID.Lastname) = 0 THEN 
    LEN(ID.Lastname) ELSE charindex(' ', ID.Lastname) - 1 END) = e.LastName
       
and LEFT(Id.FirstName, CASE WHEN charindex(' ', ID.FirstName) = 0 THEN 
    LEN(ID.FirstName) ELSE charindex(' ', ID.FirstName) - 1 END)= e.firstname
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID2,SpacePsgrToEmpName',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-----8/22/2014 Pam S added for when:  Space in Id.LastName
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID1)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
       
and LEFT(Id.Lastname, CASE WHEN charindex(' ', ID.Lastname) = 0 THEN 
    LEN(ID.Lastname) ELSE charindex(' ', ID.Lastname) - 1 END) = e.LastName
       
and LEFT(Id.FirstName, CASE WHEN charindex(' ', ID.FirstName) = 0 THEN 
    LEN(ID.FirstName) ELSE charindex(' ', ID.FirstName) - 1 END)= e.firstname
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID1,SpacePsgrToEmpName',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------

-----8/22/2014 Pam S added for when:  Spaces in Id.PsgrName to EmailName
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID2)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
       
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       = substring(empemail,(charindex('.',EmpEmail)+1),((charindex('@',EmpEmail))-(charindex('.',EmpEmail)+1)))
       
and LEFT(Id.FirstName, CASE WHEN charindex(' ', ID.FirstName) = 0 THEN 
    LEN(ID.FirstName) ELSE charindex(' ', ID.FirstName) - 1 END)
       = left(empemail, charindex('.',EmpEmail)-1)
 and EmpEmail like '%.%@%.com'
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID2,SpacePsgrtoEmailName',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----8/22/2014 Pam S added for when:  Spaces in Id.PsgrName to EmailName
SET @TransStart = getdate()
Update TTXPASQL01.TMAN503_SANOFI.DBA.comrmks 
set text1 = EmployeeID1
from TTXPASQL01.TMAN503_SANOFI.DBA.comrmks cr
inner join TTXPASQL01.TMAN503_SANOFI.DBA.client cl on (cr.IataNum = cl.IataNum and cr.ClientCode = cl.ClientCode)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.invoicedetail id on (cr.IataNum = id.IataNum and cr.ClientCode = cl.ClientCode
                                                          and cr.RecordKey = id.RecordKey and cr.SeqNum = id.SeqNum
                                                          and cr.IssueDate = id.IssueDate and cr.InvoiceDate = id.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.udef u on (cr.IataNum = u.IataNum and cr.ClientCode = u.ClientCode
                                                and cr.RecordKey = u.RecordKey and cr.SeqNum = u.SeqNum
                                                and cr.IssueDate = u.IssueDate and cr.InvoiceDate = u.InvoiceDate)
inner join TTXPASQL01.TMAN503_SANOFI.DBA.InvoiceHeader IH on (cr.IataNum = ih.IataNum and cr.ClientCode = ih.ClientCode
                                                and cr.RecordKey = ih.RecordKey and cr.InvoiceDate = ih.InvoiceDate)

inner join TTXPASQL01.TMAN503_SANOFI.DBA.employee e on (cr.text50 = e.EmployeeID1)
where isnull(cr.text1,'') <> e.Employeeid1 
--and cr.Text1 is null 
and cr.Text50 is not null 
and cr.issuedate between e.begindate and e.enddate
and udefnum = 6 and UdefType = 'R' 
       
and Replace(replace(REPLACE(replace(id.lastname,' ',''),'-',''),'''',''),'.','')
       = substring(empemail,(charindex('.',EmpEmail)+1),((charindex('@',EmpEmail))-(charindex('.',EmpEmail)+1)))
       
and LEFT(Id.FirstName, CASE WHEN charindex(' ', ID.FirstName) = 0 THEN 
    LEN(ID.FirstName) ELSE charindex(' ', ID.FirstName) - 1 END)
       = left(empemail, charindex('.',EmpEmail)-1)
 and EmpEmail like '%.%@%.com'
            
and cr.iatanum in ('SANBCDCA','SANBCDUS') 
and cr.iatanum = @Iatanum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text50= EmpID1,SpacePsgrtoEmailName',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR





----End of Main sp ---

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Sanofi Main End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@Iatanum=@Iatanum,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO

ALTER AUTHORIZATION ON [dbo].[sp_SANOFI_Main] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 5:17:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

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
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

