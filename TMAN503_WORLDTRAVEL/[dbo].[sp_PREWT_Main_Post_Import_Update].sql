/****** Object:  StoredProcedure [dbo].[sp_PREWT_Main_Post_Import_Update]    Script Date: 7/14/2015 8:16:56 PM ******/
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
