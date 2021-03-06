/****** Object:  StoredProcedure [dbo].[sp_CIEHDFCC]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CIEHDFCC]
	
@BeginIssueDate datetime = null,
@EndIssueDate datetime = null

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CIEHDFCC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    


 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CIEHDFCC]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/ 



--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEHDFCC Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
	
-------- Update SSnum with Employeenum -- Employee Nums with longer than 11 characters have been right
-------- truncated.  These all start with 'WORKS 100' and are not in the hierarchy table--------- LOC/2/19/2013

update dba.ccheader
set SSnum = right(employeeid,11)
where iatanum ='CIEHDFCC' and ssnum is null 
and importdate > getdate()-2
and employeeid <> 'UNKNOWN'

update dba.CCHeader 
set employeeid = 'Unknown' where importdate > getdate()-2 and iatanum ='CIEHDFCC'

update dba.ccheader
set employeeid = SUBSTRING(ssnum,len(ssnum)-4,7)
where SUBSTRING(ssnum,len(ssnum)-4,7) in (select employee_number from dba.hierarchy)  
and iatanum ='CIEHDFCC'
and EmployeeId = 'unknown' and importdate > getdate()-2

update dba.ccheader
set employeeid = SUBSTRING(ssnum,len(ssnum)-3,7) 
where SUBSTRING(ssnum,len(ssnum)-3,7)  in (select employee_number from dba.hierarchy)  
and iatanum ='CIEHDFCC'
and EmployeeId = 'unknown' and importdate > getdate()-2

update dba.ccheader
set employeeid = '0'+ssnum 
where '0'+ssnum  in (select employee_number from dba.hierarchy)  and iatanum ='CIEHDFCC'
and EmployeeId = 'unknown'
and LEN(ssnum) = 3 and importdate > getdate()-2


update cccar
set employeeid = cch.employeeid
from dba.CCCar cccar, dba.CCHeader cch
where cccar.RecordKey = cch.RecordKey and cccar.IataNum = cch.IataNum and importdate > getdate()-2
and cccar.iatanum ='CIEHDFCC'

update cct
set employeeid = cch.employeeid
from dba.CCticket cct, dba.CCHeader cch
where cct.RecordKey = cch.RecordKey and cct.IataNum = cch.IataNum and importdate > getdate()-2
and cct.iatanum ='CIEHDFCC'

update cchtl
set employeeid = cch.employeeid
from dba.CChotel cchtl, dba.CCHeader cch
where cchtl.RecordKey = cch.RecordKey and cchtl.IataNum = cch.IataNum and importdate > getdate()-2
and cchtl.iatanum ='CIEHDFCC'

update cce
set employeeid = cch.employeeid
from dba.CCexpense cce, dba.CCHeader cch
where cce.RecordKey = cch.RecordKey and cce.IataNum = cch.IataNum and importdate > getdate()-2
and cce.iatanum ='CIEHDFCC'


update dba.ccheader
set marketcode = case when substring(CreditCardNum ,1,6) = '532973' then 'IN'
				      when substring(CreditCardNum ,1,6) = '553162' then 'IN'
					  when substring(CreditCardNum ,1,6) = '556620' then 'IN'
					  end
	where iatanum ='CIEHDFCC'


--update market code where creditcardnum is encrypted #30538 KP 2/7/2014
update dba.ccheader
set marketcode = 'IN'
where ccfirstsix in ('532973','553162','556620')
and iatanum ='CIEHDFCC'
and marketcode is null

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEHDFCC MarketCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Added Airline Cleanup By Brent Majors 03-05-2013--

update dba.CCTicket
set ValCarrierCode = SUBSTRING(CarrierStr,1,2)
where ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and carrierstr is not null and iatanum ='CIEHDFCC'

update cct
set ValCarrierCode = 'UA'
from dba.CCTicket cct, dba.CCMerchant ccm
where cct.ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and cct.MerchantId = ccm.MerchantId
and ccm.MerchantName2 like 'United Airlines%' and cct.iatanum ='CIEHDFCC'

update cct
set ValCarrierCode = 'US'
from dba.CCTicket cct, dba.CCMerchant ccm
where cct.ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and cct.MerchantId = ccm.MerchantId
and ccm.MerchantName2 like 'US Airways%' and cct.iatanum ='CIEHDFCC'

update cct
set ValCarrierCode = 'QF'
from dba.CCTicket cct, dba.CCMerchant ccm
where cct.ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and cct.MerchantId = ccm.MerchantId and ccm.MerchantName2 like 'Qantas Airways%'
and cct.iatanum ='CIEHDFCC'

--UPDATE COUNTRY CODES 
update ccm
set ccm.merchantctrycode = iso.countrycode
from dba.CCMerchant ccm, dba.CCISOCountry iso where ccm.MerchantCtryCode = iso.CountryCode3 

update ccm
set ccm.merchantctrycode = iso.countrycode
from dba.CCMerchant ccm, dba.CCISOCountry iso where ccm.MerchantCtryCode = iso.ISOCountryNum 


--update from airline cross reference for creidt card data where carrier codes in XX,**,009

update CCT
set valcarriercode = xref.carriercode,
valcarriernum = xref.carriernum
from dba.ccticket cct, dba.ccairlinexref xref
where xref.merchantid = cct.merchantid and cct.valcarriercode in ('XX','**','009')
and cct.iatanum ='CIEHDFCC'

update ccm
set SICCode = '7011'
from dba.CCMerchant ccm, dba.CCHotel cch
where cch.MerchantId = ccm.MerchantId and cch.IataNum = 'CIEHDFCC'

update cct
set cct.matchedrecordkey = id.recordkey, 
cct.matchediatanum = id.iatanum, 
cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where right(documentnumber,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null 
and cct.valcarriercode = id.valcarriercode
and cct.transactiondate between getdate() -60 and getdate()

update id
set id.matchedind = '5'
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where right(documentnumber,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null 
and id.recordkey = cct.matchedrecordkey
and cct.valcarriercode = id.valcarriercode
and cct.transactiondate between getdate() -60 and getdate()


update cch
set cch.matchedrecordkey = id.recordkey, 
cch.matchediatanum = id.iatanum, 
cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where right(documentnumber,10) = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null 
and cct.valcarriercode = id.valcarriercode
and cct.transactiondate between getdate() -60 and getdate()

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEHDFCC Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


exec sp_CIENA_Anc
--@iatanum = 'CIEHDFCC' up dated by OP


 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/ 

GO
