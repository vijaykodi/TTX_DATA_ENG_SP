/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 12:47:40 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_PREWT_Main_Post_Import_Update]    Script Date: 7/7/2015 12:47:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[sp_PREWT_Main_Post_Import_Update]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREWT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
    
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
  

SET @TransStart = getdate()

/*Update Client Table*/

insert into dba.client
select DISTINCT clientcode,'PREWT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from dba.invoicedetail 
where clientcode not in (select clientcode from dba.client where iatanum = 'PREWT')
and iatanum = 'PREWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Add client codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.text2 = ih.origcountry
from dba.invoiceheader ih, dba.comrmks cr
where ih.iatanum ='PREWT' and ih.recordkey = cr.recordkey and ih.iatanum = cr.iatanum
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Country',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----added step per SF 00014928 ...Pam S 2013-05-08
----for when Low fare is showing more than TotalAmt
SET @TransStart = getdate()
update dba.InvoiceDetail
set FareCompare2 = TotalAmt
from dba.InvoiceDetail
where IataNum = 'PREWT' and FareCompare2 > TotalAmt
AND Invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='When Low Fare > TotalAmt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--------------------------------------------------------------------------------------
----------------------- NON ARC CARRIER UPDATES --------------------------------------LOC/10/18/2013

-------per SF 00027025 - Pam S modified - 12/17/2013 --Combined former steps 1-5(below) of updating NON ARC CARRIERs
-------to look for expected fields and data between fields in correct format.
-------Updated tax amt field causing error - 
SET @TransStart = getdate()
update i
set valcarriercode = substring(u.udefdata,charindex('TVL',u.udefdata)+4,2),
documentnumber = substring(u.udefdata,charindex('Number is',u.udefdata)+10,13),

Invoiceamt = convert(money,substring(u.udefdata,charindex('*BF',u.udefdata)+3,((charindex('*TX',u.udefdata)) - (charindex('*BF',u.udefdata)+3)))),
taxamt = convert(money,substring(u.udefdata,charindex('*tx',u.udefdata)+3,((charindex('*TF',u.udefdata)) - (charindex('*tx',u.udefdata)+3)))),
Totalamt = convert(money,substring(u.udefdata,charindex('*TF',u.udefdata)+3,((charindex('/AC2',u.udefdata)) - (charindex('*TF',u.udefdata)+3)))),

vendorname = carriername,
vendortype = 'PRETKT'

from dba.udef u, dba.invoicedetail i, dba.carriers c
where u.recordkey = i.recordkey and u.seqnum = i.seqnum 
and u.udeftype = 'TVL AIR' and u.iatanum = 'PREWT' 
----Removing:
----and substring(u.udefdata,charindex('FLT-',u.udefdata)+4,4) in ('TVL','VL W','TVL Z')
                     ----there is no "FLT- in data, so charindex defaults to 0, causing inconsistancies
                     ----therefore using charindex on 'TVL' instead, as TVL is used in all records

and valcarriernum is null 
and isnull(totalamt,0) = 0  
and substring(u.udefdata,charindex('TVL',u.udefdata)+4,2) in ('WN','FL','B6')
and carriercode = substring(u.udefdata,charindex('TVL',u.udefdata)+4,2)

and u.UdefData like '%*TF%' ---(to only get fare info and eliminate records with missing fare info)

and substring(u.udefdata,charindex('*BF',u.udefdata)+3,((charindex('*Tx',u.udefdata)) - (charindex('*BF',u.udefdata)+3))) like '%.[0-9][0-9]' 
and substring(u.udefdata,charindex('*BF',u.udefdata)+3,((charindex('*Tx',u.udefdata)) - (charindex('*BF',u.udefdata)+3))) not like '%/%'
and substring(u.udefdata,charindex('*BF',u.udefdata)+3,((charindex('*Tx',u.udefdata)) - (charindex('*BF',u.udefdata)+3))) not like '%*%'

and substring(u.udefdata,charindex('*tx',u.udefdata)+3,((charindex('*TF',u.udefdata)) - (charindex('*tx',u.udefdata)+3))) like '%.[0-9][0-9]' --due to record that had '0.00 38'
and substring(u.udefdata,charindex('*tx',u.udefdata)+3,((charindex('*TF',u.udefdata)) - (charindex('*tx',u.udefdata)+3))) not like '%/%' 
and substring(u.udefdata,charindex('*tx',u.udefdata)+3,((charindex('*TF',u.udefdata)) - (charindex('*tx',u.udefdata)+3))) not like '%0.00*%'

and substring(u.udefdata,charindex('*TF',u.udefdata)+3,((charindex('/AC2',u.udefdata)) - (charindex('*TF',u.udefdata)+3))) like '%.[0-9][0-9]' 
and substring(u.udefdata,charindex('*TF',u.udefdata)+3,((charindex('/AC2',u.udefdata)) - (charindex('*TF',u.udefdata)+3))) not like '%/%'
and substring(u.udefdata,charindex('*TF',u.udefdata)+3,((charindex('/AC2',u.udefdata)) - (charindex('*TF',u.udefdata)+3))) not like '%*%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='steps 1-5 combined-NON ARC CARRIER UPDATES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
--update i
--set valcarriercode = substring(u.udefdata,8,2),
--documentnumber = substring(u.udefdata,charindex('Number is',u.udefdata)+10,13),
--Invoiceamt = convert(money,substring(u.udefdata,charindex('*BF',u.udefdata)+3,6)) ,
--taxamt = convert(money,substring(u.udefdata,charindex('*TX',u.udefdata)+3,5)), 
--Totalamt = convert(money,substring(u.udefdata,charindex('*TF',u.udefdata)+3,6)),
--vendorname = carriername, vendortype = 'PRETKT'
--from dba.udef u, dba.invoicedetail i, dba.carriers c
--where u.recordkey = i.recordkey and u.seqnum = i.seqnum 
--and u.udeftype = 'TVL AIR' and u.iatanum = 'PREWT' 
--and substring(u.udefdata,charindex('FLT-',u.udefdata)+4,4) in ('TVL','VL W','TVL Z')
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,6) not like '%/%'
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,6) not like '%*%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,5) not like '%/%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,5) not like '%0.00*%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,6) not like '%/%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,6) not like '%*%'
--and valcarriernum is null and isnull(totalamt,0) = 0  and substring(u.udefdata,8,2) in ('WN','FL','B6')
--and carriercode = substring(u.udefdata,8,2)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 1 -NON ARC CARRIER UPDATES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update i
--set valcarriercode = substring(u.udefdata,8,2),
--documentnumber = substring(u.udefdata,charindex('Number is',u.udefdata)+10,13),
--Invoiceamt = convert(money,substring(u.udefdata,charindex('*BF',u.udefdata)+3,6)) ,
--taxamt = convert(money,substring(u.udefdata,charindex('*TX',u.udefdata)+3,4)), 
--Totalamt = convert(money,substring(u.udefdata,charindex('*TF',u.udefdata)+3,6)),
--vendorname = carriername, vendortype = 'PRETKT'
--from dba.udef u, dba.invoicedetail i, dba.carriers c
--where u.recordkey = i.recordkey and u.seqnum = i.seqnum 
--and u.udeftype = 'TVL AIR' and u.iatanum = 'PREWT' 
--and substring(u.udefdata,charindex('FLT-',u.udefdata)+4,4) in ('TVL','VL W','TVL Z')
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,6) not like '%/%'
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,6) not like '%*%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%/%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%0.00*%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,6) not like '%/%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,6) not like '%*%'
--and valcarriernum is null and isnull(totalamt,0) = 0   and substring(u.udefdata,8,2) in ('WN','FL','B6')
--and carriercode = substring(u.udefdata,8,2)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 2 -NON ARC CARRIER UPDATES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update i
--set valcarriercode = substring(u.udefdata,8,2),
--documentnumber = substring(u.udefdata,charindex('Number is',u.udefdata)+10,13),
--Invoiceamt = convert(money,substring(u.udefdata,charindex('*BF',u.udefdata)+3,5)) ,
--taxamt = convert(money,substring(u.udefdata,charindex('*TX',u.udefdata)+3,4)), 
--Totalamt = convert(money,substring(u.udefdata,charindex('*TF',u.udefdata)+3,5)),
--vendorname = carriername, vendortype = 'PRETKT'
--from dba.udef u, dba.invoicedetail i, dba.carriers c
--where u.recordkey = i.recordkey and u.seqnum = i.seqnum and u.udeftype = 'TVL AIR' and u.iatanum = 'PREWT' 
--and substring(u.udefdata,charindex('FLT-',u.udefdata)+4,4) in ('TVL','VL W','TVL Z')
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,5) not like '%/%'
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,5) not like '%*%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%/%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%*%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,5) not like '%/%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,5) not like '%*%'
--and valcarriernum is null and isnull(totalamt,0) = 0  and substring(u.udefdata,8,2) in ('WN','FL','B6')
--and carriercode = substring(u.udefdata,8,2)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 3 -NON ARC CARRIER UPDATES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update i
--set valcarriercode = substring(u.udefdata,7,2),
--documentnumber = substring(u.udefdata,charindex('Number is',u.udefdata)+10,13),
--Invoiceamt = convert(money,substring(u.udefdata,charindex('*BF',u.udefdata)+3,6)) ,
--taxamt = convert(money,substring(u.udefdata,charindex('*TX',u.udefdata)+3,4)), 
--Totalamt = convert(money,substring(u.udefdata,charindex('*TF',u.udefdata)+3,6)),
--vendorname = carriername, vendortype = 'PRETKT'
--from dba.udef u, dba.invoicedetail i, dba.carriers c
--where u.recordkey = i.recordkey and u.seqnum = i.seqnum and u.udeftype = 'TVL AIR' and u.iatanum = 'PREWT' 
--and substring(u.udefdata,charindex('FLT-',u.udefdata)+4,4) in ('TVL','VL W','TVL Z')
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,6) not like '%/%'
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,6) not like '%*%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%/%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%0.00*%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,6) not like '%/%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,6) not like '%*%'
--and valcarriernum is null and isnull(totalamt,0) = 0  and substring(u.udefdata,7,2) in ('WN','FL','B6')
--and carriercode = substring(u.udefdata,7,2)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 4 -NON ARC CARRIER UPDATES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update i
--set valcarriercode = substring(u.udefdata,7,2),
--documentnumber = substring(u.udefdata,charindex('Number is',u.udefdata)+10,13),
--Invoiceamt = convert(money,substring(u.udefdata,charindex('*BF',u.udefdata)+3,5)) ,
--taxamt = convert(money,substring(u.udefdata,charindex('*TX',u.udefdata)+3,4)), 
--Totalamt = convert(money,substring(u.udefdata,charindex('*TF',u.udefdata)+3,5)),
--vendorname = carriername, vendortype = 'PRETKT'
--from dba.udef u, dba.invoicedetail i, dba.carriers c
--where u.recordkey = i.recordkey and u.seqnum = i.seqnum and u.udeftype = 'TVL AIR' and u.iatanum = 'PREWT' 
--and substring(u.udefdata,charindex('FLT-',u.udefdata)+4,4) in ('TVL','VL W','TVL Z')
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,5) not like '%/%'
--and substring(u.udefdata,charindex('*BF',u.udefdata)+3,5) not like '%*%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%/%'
--and substring(u.udefdata,charindex('*TX',u.udefdata)+3,4) not like '%0.00*%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,5) not like '%/%'
--and substring(u.udefdata,charindex('*TF',u.udefdata)+3,5) not like '%*%'
--and valcarriernum is null and isnull(totalamt,0) = 0  and substring(u.udefdata,7,2) in ('WN','FL','B6')
--and carriercode = substring(u.udefdata,7,2)
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 5 -NON ARC CARRIER UPDATES',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------------------------------------------------------------
-------------- Insert Transeg Data for Non ARC Carriers -----------------------------------------
---------Adding to temp table first then will move to Transeg -----------------------------------
---- Adding Segments from Udef where segment is 2nd character and 4 digit flight num-------------

---Adjusted next 4 Steps: 6,7,8,9 -
------per SF 00031242 -Pam S on 2.20.2014 where errored on Step 9 with:
------Msg 2627, Level 14, State 1, Line 1
------Violation of PRIMARY KEY constraint 'PK_TranSeg_NONARC_Temp'. 
------Cannot insert duplicate key in object 'dba.TranSeg_NONARC_Temp'. 
------The duplicate key value is (3BFVCX20140211RXT-159071115, PREWT, 2, 2).
------Note this was because it was trying to insert segment# = 2 twice - when should have actually been segment# =12
------So removed substring(u1.udefdata,1,1) and replaced with:
------,dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )

SET @TransStart = getdate()
insert into dba.transeg_nonarc_temp
select distinct u1.recordkey,u1.iatanum, u1.seqnum
-----,substring(u1.udefdata,2,1)
,dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )  
,'A',u1.clientcode,
u1.invoicedate, u1.issuedate, substring(u1.udefdata,charindex('CC1-',u1.udefdata)+4,3),
substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2), c.carriername,Null,NUll,Null,
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) , Null,
substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) , Null,Null,Null,Null,Null,Null,Null,'USD',
substring(u1.udefdata,charindex('CC2-',u1.udefdata)+4,3),'D',
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) as FlightDate,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,NULL
from dba.udef u1, dba.udef u2, dba.carriers c, dba.invoicedetail i
where u1.recordkey = u2.recordkey and u1.seqnum = u2.seqnum
and u1.udeftype = 'TVL AIR' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) not like '%/%' 
and u2.udeftype = '5. REMARKS' and u2.udefdata like '%/tkt%'
and u1.iatanum like 'pre%' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) not in ('TVL','VL W','TVL Z')
and carriercode = substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2)
and u1.recordkey+cast(u1.seqnum as varchar(4))+substring(u1.udefdata,2,1)
	not in (select recordkey+cast(seqnum as varchar(4))+CAST(segmentnum as varchar(4))from dba.transeg_nonarc_temp)
and i.recordkey = u1.recordkey and i.seqnum = u1.seqnum
and voidind = 'n' and refundind = 'n'
and c.typecode = 'a' and substring(u1.udefdata,2,1) <> '' and substring(u1.udefdata,2,1) like '[1-9]'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 6 insert into dba.transeg_nonarc_temp',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------Adjusting per SF 00031242 -Pam S on 2.20.2014 where errored with:
------Msg 2627, Level 14, State 1, Line 1
------Violation of PRIMARY KEY constraint 'PK_TranSeg_NONARC_Temp'. 
------Cannot insert duplicate key in object 'dba.TranSeg_NONARC_Temp'. 
------The duplicate key value is (3BFVCX20140211RXT-159071115, PREWT, 2, 2).
------Note this was because it was trying to insert segment# = 2 twice - when should have actually been segment# =12
------So removed substring(u1.udefdata,1,1) and replaced with:
------,dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )  
SET @TransStart = getdate()
---- Adding Segments from Udef where segment is 1st character and 4 digit flight num-------------
insert into dba.transeg_nonarc_temp
select distinct u1.recordkey,u1.iatanum, u1.seqnum
----,substring(u1.udefdata,1,1)
,dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )  
,'A',u1.clientcode,
u1.invoicedate, u1.issuedate, substring(u1.udefdata,charindex('CC1-',u1.udefdata)+4,3),
substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2), c.carriername,Null,NUll,Null,
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) , Null,
substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) , Null,Null,Null,Null,Null,Null,Null,'USD',
substring(u1.udefdata,charindex('CC2-',u1.udefdata)+4,3),'D',
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) as FlightDate,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,NULL
from dba.udef u1, dba.udef u2, dba.carriers c, dba.invoicedetail i
where u1.recordkey = u2.recordkey and u1.seqnum = u2.seqnum
and u1.udeftype = 'TVL AIR' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) not like '%/%' 
and u2.udeftype = '5. REMARKS' and u2.udefdata like '%/tkt%'
and u1.iatanum like 'pre%' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) not in ('TVL','VL W','TVL Z')
and carriercode = substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2)
and u1.recordkey+cast(u1.seqnum as varchar(4))+substring(u1.udefdata,1,1)
	not in (select recordkey+cast(seqnum as varchar(4))+CAST(segmentnum as varchar(4))from dba.transeg_nonarc_temp)
and i.recordkey = u1.recordkey and i.seqnum = u1.seqnum
and voidind = 'n' and refundind = 'n' and c.typecode = 'a'  and substring(u1.udefdata,1,1) <> ''
and substring(u1.udefdata,2,1) like '[1-9]'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 7 Adding Segments from Udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
----- Adding segments where segment is 1st character and flight num is 3 digits--------------------
insert into dba.transeg_nonarc_temp
select distinct u1.recordkey,u1.iatanum, u1.seqnum
----,substring(u1.udefdata,1,1)
,dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )  
,'A',u1.clientcode,
u1.invoicedate, u1.issuedate, substring(u1.udefdata,charindex('CC1-',u1.udefdata)+4,3),
substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2), c.carriername,Null,NUll,Null,
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) , Null,
substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,3) , Null,Null,Null,Null,Null,Null,Null,'USD',
substring(u1.udefdata,charindex('CC2-',u1.udefdata)+4,3),'D',
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) as FlightDate,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,NULL
from dba.udef u1, dba.udef u2, dba.carriers c, dba.invoicedetail i
where u1.recordkey = u2.recordkey and u1.seqnum = u2.seqnum
and u1.udeftype = 'TVL AIR' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,3) not like '%/%' 
and u2.udeftype = '5. REMARKS' and u2.udefdata like '%/tkt%'
and u1.iatanum like 'pre%' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) not in ('TVL','VL W','TVL Z')
and carriercode = substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2)
and u1.recordkey+cast(u1.seqnum as varchar(4))+substring(u1.udefdata,1,1)
	not in (select recordkey+cast(seqnum as varchar(4))+CAST(segmentnum as varchar(4))from dba.transeg_nonarc_temp)
and i.recordkey = u1.recordkey and i.seqnum = u1.seqnum and voidind = 'n' and refundind = 'n'
and c.typecode = 'a' and substring(u1.udefdata,1,1) <> '' and substring(u1.udefdata,2,1) like '[1-9]'
and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) like '%/%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 8 Adding segments where segment is 1st',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
----- Adding segments where segment is 2nd character and flight num is 3 digits--------------------
insert into dba.transeg_nonarc_temp
select distinct u1.recordkey,u1.iatanum, u1.seqnum
----,substring(u1.udefdata,2,1)
,dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )  
,'A',u1.clientcode,
u1.invoicedate, u1.issuedate, substring(u1.udefdata,charindex('CC1-',u1.udefdata)+4,3),
substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2), c.carriername,Null,NUll,Null,
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) , Null,
substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,3) , Null,Null,Null,Null,Null,Null,Null,'USD',
substring(u1.udefdata,charindex('CC2-',u1.udefdata)+4,3),'D',
convert(datetime,substring(u1.udefdata,charindex('air',u1.udefdata)+4,7)) as FlightDate,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,
Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,NULL
from dba.udef u1, dba.udef u2, dba.carriers c, dba.invoicedetail i
where u1.recordkey = u2.recordkey and u1.seqnum = u2.seqnum
and u1.udeftype = 'TVL AIR' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,3) not like '%/%' 
and u2.udeftype = '5. REMARKS' and u2.udefdata like '%/tkt%'
and u1.iatanum like 'pre%' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) not in ('TVL','VL W','TVL Z')
and carriercode = substring(u1.udefdata,charindex('tvl',u1.udefdata)+4,2)
and u1.recordkey+cast(u1.seqnum as varchar(4))+ dbo.udf_GetNumeric(left(u1.udefdata,(charindex(' TVL',u1.udefdata)) )  )
	not in (select recordkey+cast(seqnum as varchar(4))+CAST(segmentnum as varchar(4))from dba.transeg_nonarc_temp)
and i.recordkey = u1.recordkey and i.seqnum = u1.seqnum
and voidind = 'n' and refundind = 'n' and c.typecode = 'a'  and substring(u1.udefdata,2,1) <> ''
and substring(u1.udefdata,2,1) like '[1-9]' and substring(u1.udefdata,charindex('FLT-',u1.udefdata)+4,4) like '%/%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 9 Adding segments where segment is 2nd',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----SF 00031242 - Adjusted by Pam S - 2.20.2014 - SP was failing because of preceding spaces in 9 records
----for SegmentNum - would not have happened if properties of SegnmentNum in dba.transeg_nonarc_temp weren't as varchar(2)
----whereas in dba.TranSeg, SegmentNum is as an Int
----therefore, adding function dbo.udf_GetNumeric for (tsa.segmentnum)
SET @TransStart = getdate()
insert into dba.transeg 
select distinct * from dba.transeg_nonarc_temp tsa
--where tsa.recordkey+cast(tsa.seqnum as varchar(4))+CAST(tsa.segmentnum as varchar(4)) not in 
where tsa.recordkey+cast(tsa.seqnum as varchar(4))+CAST(dbo.udf_GetNumeric(tsa.segmentnum) as varchar(4)) not in 
(select ts.recordkey+cast(ts.seqnum as varchar(4))+CAST(ts.segmentnum as varchar(4)) 
from dba.transeg ts 
where ts.invoicedate > '7-1-2013' and ts.iatanum = 'prewt' and tsa.segmentcarriercode in ('wn','fl','wm','b6')
and ts.recordkey = tsa.recordkey and ts.iatanum = tsa.iatanum and ts.seqnum = tsa.seqnum
and ts.segmentnum = tsa.segmentnum) and tsa.segmentcarriercode in ('wn','fl','wm','b6')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 10 insert into dba.transeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update i
set vendorname = carriername
from dba.carriers c, dba.invoicedetail i
where valcarriercode = carriercode and typecode = 'a' and vendorname is null and iatanum = 'prewt'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 11 update vendorname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update I
set routing = origincitycode +'/' + segdestcitycode
from dba.invoicedetail i, dba.transeg_nonarc_temp t
where t.recordkey = i.recordkey and t.seqnum = i.seqnum and t.iatanum = 'PREWT' and routing is null 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='step 12 update routing',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----------------------------------------------------------------------
--Insert records into InvoiceDetail and Invoice Header when not
--present from Hotel and Car
-- Hotel insert

SET @TransStart = getdate()
insert into dba.invoicedetail (RecordKey,IataNum,SeqNum,ClientCode,InvoiceDate,IssueDate,VoidInd,VoidReasonType,Salutation,FirstName
,Lastname,MiddleInitial,InvoiceType,InvoiceTypeDescription,DocumentNumber,EndDocNumber,VendorNumber,VendorType,ValCarrierNum,ValCarrierCode
,VendorName,BookingDate,ServiceDate,ServiceCategory,InternationalInd,ServiceFee,InvoiceAmt,TaxAmt,TotalAmt,CommissionAmt,CancelPenaltyAmt,CurrCode
,FareCompare1,ReasonCode1,FareCompare2 ,ReasonCode2,FareCompare3,ReasonCode3,FareCompare4,ReasonCode4,Mileage,Routing,DaysAdvPurch,AdvPurchGroup
,TrueTktCount,TripLength,ExchangeInd,OrigExchTktNum,Department,ETktInd,ProductType,TourCode,EndorsementRemarks,FareCalcLine,GroupMult,OneWayInd,PrefTktInd,HotelNights,CarDays
,OnlineBookingSystem,AccommodationType,AccommodationDescription,ServiceType,ServiceDescription,ShipHotelName,Remarks1,Remarks2,Remarks3,Remarks4
,Remarks5,IntlSalesInd,MatchedInd,MatchedFields,RefundInd,OriginalInvoiceNum,BranchIataNum,GDSRecordLocator,BookingAgentID,TicketingAgentID
,OriginCode,DestinationCode,OrigTktAmt,TktCO2Emissions)
select distinct recordkey, iatanum, seqnum, clientcode, invoicedate, issuedate,
voidind, voidreasontype, salutation, firstname, lastname, middleinitial,
'Hotel',NULL,NULL,NULL,htlchaincode, 'NONAIR',NULL, NULL, HTLCHAINNAME,
invoicedate, checkindate, null, internationalind, 0, 0, 0, 0,
0, 0, currcode, null, null, null, null, null,null,null,null,null,null,
null, null, null, numnights, null,null,null,null,'Hotel',null,null,null,null,
null, null, numnights, null, null, null, null, null,null, null, null, null, null,
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null
from dba.hotel htl1
where recordkey not in (select recordkey from dba.invoicedetail)
and seqnum = (select min(seqnum) from dba.hotel htl2
                  where htl1.recordkey = htl2.recordkey and htl1.seqnum = htl2.seqnum)
and htlsegnum = (select min(htl2.htlsegnum) from dba.hotel htl2
                  where htl1.recordkey = htl2.recordkey and htl1.seqnum = htl2.seqnum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='hotel insert',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Car insert
SET @TransStart = getdate()
insert into dba.invoicedetail (RecordKey, IataNum,SeqNum,   ClientCode,      InvoiceDate,IssueDate,  VoidInd,VoidReasonType, Salutation,      FirstName,  Lastname,   MiddleInitial,      InvoiceType,InvoiceTypeDescription, DocumentNumber,   EndDocNumber,      VendorNumber,     VendorType, ValCarrierNum,    ValCarrierCode,      VendorName, BookingDate,      ServiceDate ,ServiceCategory,      InternationalInd, ServiceFee, InvoiceAmt, TaxAmt,     TotalAmt      ,CommissionAmt,   CancelPenaltyAmt, CurrCode    ,FareCompare1      ,ReasonCode1      ,FareCompare2     ,ReasonCode2      ,FareCompare3      ,ReasonCode3      ,FareCompare4     ,ReasonCode4,     Mileage,      Routing     ,DaysAdvPurch,    AdvPurchGroup     ,TrueTktCount      ,TripLength,      ExchangeInd ,OrigExchTktNum,  Department, ETktInd,      ProductType,      TourCode    ,EndorsementRemarks,    FareCalcLine,      GroupMult,  OneWayInd,  PrefTktInd, HotelNights,      CarDays,      OnlineBookingSystem,    AccommodationType,      AccommodationDescription      ,ServiceType      ,ServiceDescription      ,ShipHotelName,   Remarks1    ,Remarks2   ,Remarks3,  Remarks4,      Remarks5,   IntlSalesInd,     MatchedInd  ,MatchedFields,      RefundInd   ,OriginalInvoiceNum     ,BranchIataNum      ,GDSRecordLocator,      BookingAgentID    ,TicketingAgentID,      OriginCode, DestinationCode   ,OrigTktAmt ,TktCO2Emissions)
select recordkey, iatanum, seqnum, clientcode, invoicedate, issuedate,
voidind, voidreasontype, salutation, firstname, lastname, middleinitial,
'Car',NULL,NULL,NULL,carchaincode, 'NONAIR',NULL, NULL, carchainname,
invoicedate, pickupdate, null, internationalind, null, ttlcarcost, null, ttlcarcost,
carcommamt, null, currcode, null, null, null, null, null,null,null,null,null,null,
null, null, null, numdays, null,null,null,null,'Car',null,null,null,null,
null, null, numdays, null, null, null, null, null,null, null, null, null, null,
null, null, null, null, null, null, null, null, null, null, null, null, null, null, null
from dba.car car1
where recordkey not in (select recordkey from dba.invoicedetail)
and seqnum = (select min(seqnum) from dba.car car2
                  where car1.recordkey = car2.recordkey and car1.seqnum = car2.seqnum)
and carsegnum = (select min(car2.carsegnum) from dba.car car2
                  where car1.recordkey = car2.recordkey and car1.seqnum = car2.seqnum)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='car insert',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update Canadian Hotels with the Provence Code for per Holli ------- LOC/1/20/2014
update h
set htlstate = stateprovincecode
from dba.hotel h, dba.city c
where   htlstate is null and substring(h.htlcityname,1,8) = substring(c.cityname,1,8)
and htlcountrycode = 'ca' and c.typecode = 'a' and countrycode = htlcountrycode
and len(stateprovincecode) = 2

GO

ALTER AUTHORIZATION ON [dbo].[sp_PREWT_Main_Post_Import_Update] TO  SCHEMA OWNER 
GO

/****** Object:  UserDefinedFunction [dbo].[udf_GetNumeric]    Script Date: 7/7/2015 12:47:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[udf_GetNumeric]
(@strAlphaNumeric VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
END
END
RETURN ISNULL(@strAlphaNumeric,0)
END


GO

ALTER AUTHORIZATION ON [dbo].[udf_GetNumeric] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 12:47:43 PM ******/
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

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 12:47:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceHeader](
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
	[TtlCO2Emissions] [float] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL,
 CONSTRAINT [PK_InvoiceHeader_1] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 12:47:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceDetail](
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
	[OrigTktAmt] [float] NULL,
	[TktWasExchangedInd] [varchar](1) NULL,
	[TktCO2Emissions] [float] NULL,
 CONSTRAINT [PK_InvoiceDetail] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Hotel]    Script Date: 7/7/2015 12:48:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Hotel](
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
	[MasterId] [int] NULL,
	[CO2Emissions] [float] NULL,
	[MilesFromAirport] [float] NULL,
	[GroundTransCO2] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Hotel] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/7/2015 12:48:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ComRmks](
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
	[Int20] [int] NULL,
 CONSTRAINT [PK_ComRmks] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Client]    Script Date: 7/7/2015 12:49:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Client](
	[ClientCode] [varchar](15) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[STATE] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[CustPhone] [varchar](20) NULL,
	[CountryCode] [varchar](5) NULL,
	[AttnLine] [varchar](40) NULL,
	[Email] [varchar](80) NULL,
	[ConsolidationCode] [varchar](50) NULL,
	[ClientRemark1] [varchar](255) NULL,
	[ClientRemark2] [varchar](255) NULL,
	[ClientRemark3] [varchar](255) NULL,
	[ClientRemark4] [varchar](255) NULL,
	[ClientRemark5] [varchar](255) NULL,
	[ClientRemark6] [varchar](255) NULL,
	[ClientRemark7] [varchar](255) NULL,
	[ClientRemark8] [varchar](255) NULL,
	[ClientRemark9] [varchar](255) NULL,
	[ClientRemark10] [varchar](255) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientCode] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[City]    Script Date: 7/7/2015 12:49:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[City](
	[CityCode] [varchar](10) NOT NULL,
	[TypeCode] [varchar](1) NOT NULL,
	[CityName] [varchar](30) NULL,
	[AirportName] [varchar](30) NULL,
	[RegionCode] [varchar](10) NULL,
	[RegionName] [varchar](30) NULL,
	[StateProvinceCode] [varchar](5) NULL,
	[CountryCode] [varchar](5) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[TimeZoneDiff] [float] NULL,
	[TSLATEST] [datetime] NULL,
 CONSTRAINT [PK_City] PRIMARY KEY NONCLUSTERED 
(
	[CityCode] ASC,
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[City] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Carriers]    Script Date: 7/7/2015 12:49:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Carriers](
	[CarrierCode] [varchar](3) NOT NULL,
	[TypeCode] [varchar](1) NOT NULL,
	[Status] [varchar](1) NOT NULL,
	[CarrierName] [varchar](50) NOT NULL,
	[CarrierNumber] [smallint] NOT NULL,
 CONSTRAINT [PK_Carriers] PRIMARY KEY CLUSTERED 
(
	[CarrierCode] ASC,
	[TypeCode] ASC,
	[Status] ASC,
	[CarrierName] ASC,
	[CarrierNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Carriers] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Car]    Script Date: 7/7/2015 12:49:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Car](
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
	[CarDropOffCityName] [varchar](50) NULL,
	[CO2Emissions] [float] NULL,
 CONSTRAINT [PK_Car] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Car] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Udef]    Script Date: 7/7/2015 12:49:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Udef](
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

ALTER AUTHORIZATION ON [dba].[Udef] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg_NONARC_Temp]    Script Date: 7/7/2015 12:49:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[TranSeg_NONARC_Temp](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [varchar](2) NOT NULL,
	[SegmentNum] [varchar](2) NOT NULL,
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
	[StopOverTime] [int] NULL,
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
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
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
	[YieldDatePosted] [datetime] NULL,
 CONSTRAINT [PK_TranSeg_NONARC_Temp] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[TranSeg_NONARC_Temp] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 12:50:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
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
	[StopOverTime] [int] NULL,
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
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
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
	[YieldDatePosted] [datetime] NULL,
 CONSTRAINT [PK_TranSeg] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 12:51:01 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 12:51:02 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelI1]    Script Date: 7/7/2015 12:51:03 PM ******/
CREATE CLUSTERED INDEX [HotelI1] ON [dba].[Hotel]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/7/2015 12:51:03 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [dba].[ComRmks]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CityI1]    Script Date: 7/7/2015 12:51:04 PM ******/
CREATE UNIQUE CLUSTERED INDEX [CityI1] ON [dba].[City]
(
	[TypeCode] ASC,
	[CityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI1]    Script Date: 7/7/2015 12:51:04 PM ******/
CREATE CLUSTERED INDEX [CarI1] ON [dba].[Car]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[CarSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefI1]    Script Date: 7/7/2015 12:51:05 PM ******/
CREATE CLUSTERED INDEX [UdefI1] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 12:51:07 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/7/2015 12:51:08 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [dba].[InvoiceHeader]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/7/2015 12:51:08 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [dba].[InvoiceHeader]
(
	[BookingBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/7/2015 12:51:09 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 12:51:09 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [INvoiceDetailI2]    Script Date: 7/7/2015 12:51:09 PM ******/
CREATE NONCLUSTERED INDEX [INvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI3]    Script Date: 7/7/2015 12:51:11 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI3] ON [dba].[InvoiceDetail]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 12:51:12 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [HotelI2]    Script Date: 7/7/2015 12:51:14 PM ******/
CREATE NONCLUSTERED INDEX [HotelI2] ON [dba].[Hotel]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [HotelPX]    Script Date: 7/7/2015 12:51:14 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [HotelPX] ON [dba].[Hotel]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[HtlSegNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI2]    Script Date: 7/7/2015 12:51:14 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI2] ON [dba].[ComRmks]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI3]    Script Date: 7/7/2015 12:51:14 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI3] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI4]    Script Date: 7/7/2015 12:51:16 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI4] ON [dba].[ComRmks]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CarI2]    Script Date: 7/7/2015 12:51:16 PM ******/
CREATE NONCLUSTERED INDEX [CarI2] ON [dba].[Car]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [CarI3]    Script Date: 7/7/2015 12:51:16 PM ******/
CREATE NONCLUSTERED INDEX [CarI3] ON [dba].[Car]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CarI6]    Script Date: 7/7/2015 12:51:17 PM ******/
CREATE NONCLUSTERED INDEX [CarI6] ON [dba].[Car]
(
	[PickupDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI2]    Script Date: 7/7/2015 12:51:18 PM ******/
CREATE NONCLUSTERED INDEX [UdefI2] ON [dba].[Udef]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI3]    Script Date: 7/7/2015 12:51:18 PM ******/
CREATE NONCLUSTERED INDEX [UdefI3] ON [dba].[Udef]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefI4]    Script Date: 7/7/2015 12:51:18 PM ******/
CREATE NONCLUSTERED INDEX [UdefI4] ON [dba].[Udef]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [UdefI5]    Script Date: 7/7/2015 12:51:19 PM ******/
CREATE NONCLUSTERED INDEX [UdefI5] ON [dba].[Udef]
(
	[UdefNum] ASC,
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UdefPX]    Script Date: 7/7/2015 12:51:21 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UdefPX] ON [dba].[Udef]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[UdefNum] ASC,
	[UdefType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [TransegI2]    Script Date: 7/7/2015 12:51:21 PM ******/
CREATE NONCLUSTERED INDEX [TransegI2] ON [dba].[TranSeg]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

