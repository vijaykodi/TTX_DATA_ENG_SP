/****** Object:  StoredProcedure [dbo].[sp_CIEBOACC]    Script Date: 7/14/2015 7:51:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CIEBOACC]
	
 @BeginIssueDate datetime = null,
@EndIssueDate datetime = null

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'CIEBOACC'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    


 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_CIEBOACC]
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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update SSnum with Employeenum -- Employee Nums with longer than 11 characters have been right
-------- truncated.  These all start with 'WORKS 100' and are not in the hierarchy table--------- LOC/2/19/2013

update dba.ccheader
set SSnum = right(employeeid,11)
where iatanum ='CIEBOACC' and ssnum is null
and importdate > getdate()-2
and employeeid <> 'UNKNOWN'

update dba.CCHeader 
set employeeid = 'Unknown'
where importdate > getdate()-2
and iatanum ='CIEBOACC'


update dba.ccheader
set employeeid = SUBSTRING(ssnum,len(ssnum)-4,7)
where SUBSTRING(ssnum,len(ssnum)-4,7) in (select employee_number from dba.hierarchy)  
and iatanum ='CIEBOACC'
and EmployeeId = 'unknown'
and importdate > getdate()-2

update dba.ccheader
set employeeid = SUBSTRING(ssnum,len(ssnum)-3,7) 
where SUBSTRING(ssnum,len(ssnum)-3,7)  in (select employee_number from dba.hierarchy)  
and iatanum ='CIEBOACC'
and EmployeeId = 'unknown'
and importdate > getdate()-2

update dba.ccheader
set employeeid = '0'+ssnum 
where '0'+ssnum  in (select employee_number from dba.hierarchy)  
and iatanum ='CIEBOACC'
and EmployeeId = 'unknown'
and LEN(ssnum) = 3 and importdate > getdate()-2

update dba.CCHeader
set employeeid = '0'+employeeid
where len(employeeid) = 4
and importdate > getdate()-2
and iatanum ='CIEBOACC'

update dba.CCHeader
set employeeid = '00'+employeeid
where len(employeeid) = 3
and importdate > getdate()-2
and iatanum ='CIEBOACC'

update dba.CCHeader
set employeeid = '000'+employeeid
where len(employeeid) = 2
and importdate > getdate()-2
and iatanum ='CIEBOACC'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC CCHeader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cccar
set employeeid = cch.employeeid
from dba.CCCar cccar, dba.CCHeader cch
where cccar.RecordKey = cch.RecordKey 
and cccar.IataNum = cch.IataNum
and cch.ImportDate > getdate()-2
and cch.IataNum ='CIEBOACC'

 SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC cccar',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cct
set employeeid = cch.employeeid
from dba.CCticket cct, dba.CCHeader cch
where cct.RecordKey = cch.RecordKey 
and cct.IataNum = cch.IataNum
and cch.importdate > getdate()-2
and cch.IataNum ='CIEBOACC'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC ccticket',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cchtl
set employeeid = cch.employeeid
from dba.CChotel cchtl, dba.CCHeader cch
where cchtl.RecordKey = cch.RecordKey 
and cchtl.IataNum = cch.IataNum
and importdate > getdate()-2
and cch.IataNum ='CIEBOACC'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC CCHtl',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update cce
set employeeid = cch.employeeid
from dba.CCexpense cce, dba.CCHeader cch
where cce.RecordKey = cch.RecordKey 
and cce.IataNum = cch.IataNum
and cch.ImportDate > getdate()-2
and cch.IataNum ='CIEBOACC'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC CCExpense',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


update dba.ccheader
set marketcode = case when substring(CreditCardNum ,1,6) = '556960' then 'CA'
				      when substring(CreditCardNum ,1,6) = '556718' then 'US'
					  when substring(CreditCardNum ,1,6) = '556110' then 'UK'
					  when substring(CreditCardNum ,1,6) = '555001' then 'AU'
					  when substring(CreditCardNum ,1,6) = '533161' then 'EU'
					  end
where iatanum ='CIEBOACC'


---update market code if ccnumber is encrypted #30538 KP 2/7/14
update dba.ccheader
set marketcode = case when ccfirstsix = '556960' then 'CA'
				      when ccfirstsix = '556718' then 'US'
					  when ccfirstsix = '556110' then 'UK'
					  when ccfirstsix = '555001' then 'AU'
					  when ccfirstsix = '533161' then 'EU'
					  end
where iatanum ='CIEBOACC'
and marketcode is null


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC MarketCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Added Airline Cleanup By Brent Majors 03-05-2013--

update dba.CCTicket
set ValCarrierCode = SUBSTRING(CarrierStr,1,2)
where ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and carrierstr is not null
and IataNum ='CIEBOACC'

update cct
set ValCarrierCode = 'UA'
from dba.CCTicket cct, dba.CCMerchant ccm
where cct.ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and cct.MerchantId = ccm.MerchantId
and ccm.MerchantName2 like 'United Airlines%'
and cct.IataNum ='CIEBOACC'

update cct
set ValCarrierCode = 'US'
from dba.CCTicket cct, dba.CCMerchant ccm
where cct.ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and cct.MerchantId = ccm.MerchantId
and ccm.MerchantName2 like 'US Airways%'
and cct.IataNum ='CIEBOACC'

update cct
set ValCarrierCode = 'QF'
from dba.CCTicket cct, dba.CCMerchant ccm
where cct.ValCarrierCode not in (select distinct carriercode from dba.Carriers
where status = 'A')
and cct.MerchantId = ccm.MerchantId
and ccm.MerchantName2 like 'Qantas Airways%'
and cct.IataNum ='CIEBOACC'

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC Airlinecodes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--UPDATE COUNTRY CODES 
update ccm
set ccm.merchantctrycode = iso.countrycode
from dba.CCMerchant ccm, dba.CCISOCountry iso
where ccm.MerchantCtryCode = iso.CountryCode3

update ccm
set ccm.merchantctrycode = iso.countrycode
from dba.CCMerchant ccm, dba.CCISOCountry iso
where ccm.MerchantCtryCode = iso.ISOCountryNum

SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC CountryCodes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--update from airline cross reference for creidt card data where carrier codes in XX,**,009

update CCT
set valcarriercode = xref.carriercode,
valcarriernum = xref.carriernum
from dba.ccticket cct, dba.ccairlinexref xref
where xref.merchantid = cct.merchantid
and cct.valcarriercode in ('XX','**','009')
and cct.IataNum ='CIEBOACC'


update ccm
set SICCode = '7011'
from dba.CCMerchant ccm, dba.CCHotel cch
where cch.MerchantId = ccm.MerchantId
and cch.IataNum = 'CIEBOACC'

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Match w doc num',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---Update matched for ticketless carriers where tkt nbr from TMC and CCdata are different #30022
--02/06/14 KP

update cct
set cct.matchedrecordkey = id.recordkey, 
cct.matchediatanum = id.iatanum, 
cct.matchedclientcode = id.clientcode,
cct.matchedseqnum = id.seqnum
from  
dba.ccheader cch
inner join dba.ccticket cct on cct.recordkey = cch.recordkey
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCH.BilledCurrCode AND CURRBASE.CurrBeginDate = CCH.TransactionDate AND CURRBASE.CurrCode = CCT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
,dba.invoicedetail id
where 
cch.matchedrecordkey is null 
and id.servicedate=cct.servicedate
and CCH.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
and cct.valcarriercode = id.valcarriercode
and id.Lastname=SUBSTRING(cct.passengername, 1, CASE WHEN CHARINDEX('/', cct.passengername) > 0 THEN CHARINDEX('/', cct.passengername)-1
									ELSE LEN(cct.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cct.routing,1,3)
and cct.transactiondate between getdate() -60 and getdate()

update id
set id.matchedind = '5'
from dba.invoicedetail id, dba.ccticket cct, dba.ccheader cch
where 
 cct.recordkey = cch.recordkey 
and id.matchedind is null 
and id.recordkey = cct.matchedrecordkey
and cct.valcarriercode = id.valcarriercode
and id.servicedate=cct.servicedate
and id.Lastname=SUBSTRING(cct.passengername, 1, CASE WHEN CHARINDEX('/', cct.passengername) > 0 THEN CHARINDEX('/', cct.passengername)-1
									ELSE LEN(cct.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cct.routing,1,3)
and cct.transactiondate between getdate() -60 and getdate()


update cch
set cch.matchedrecordkey = id.recordkey, 
cch.matchediatanum = id.iatanum, 
cch.matchedclientcode = id.clientcode,
cch.matchedseqnum = id.seqnum
From
dba.ccheader cch
inner join dba.ccticket cct on cct.recordkey = cch.recordkey
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCH.BilledCurrCode AND CURRBASE.CurrBeginDate = CCH.TransactionDate AND CURRBASE.CurrCode = CCT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
,dba.invoicedetail id
where 
cch.matchedrecordkey is null 
and id.servicedate=cct.servicedate
and CCH.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
and cct.valcarriercode = id.valcarriercode
and id.Lastname=SUBSTRING(cct.passengername, 1, CASE WHEN CHARINDEX('/', cct.passengername) > 0 THEN CHARINDEX('/', cct.passengername)-1
									ELSE LEN(cct.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cct.routing,1,3)
and cct.transactiondate between getdate() -60 and getdate()

--Update for EasyJet - where credit card data uses EZ and agency data uses U2

update cctkt
set cctkt.matchedrecordkey = id.recordkey, 
cctkt.matchediatanum = id.iatanum, 
cctkt.matchedclientcode = id.clientcode,
cctkt.matchedseqnum = id.seqnum
FROM DBA.CCHeader CCHDR
 INNER JOIN DBA.CCTicket CCTKT ON ( CCHDR.RecordKey = CCTKT.RecordKey AND CCHDR.IataNum = CCTKT.IataNum AND CCHDR.TransactionDate = CCTKT.TransactionDate )
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCHDR.BilledCurrCode AND CURRBASE.CurrBeginDate = CCHDR.TransactionDate AND CURRBASE.CurrCode = CCTKT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCTKT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
inner join dba.InvoiceDetail id on (id.servicedate=cctkt.servicedate
and CCHDR.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
and id.Lastname=SUBSTRING(cctkt.passengername, 1, CASE WHEN CHARINDEX('/', cctkt.passengername) > 0 THEN CHARINDEX('/', cctkt.passengername)-1
									ELSE LEN(cctkt.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cctkt.routing,1,3))
where cctkt.valcarriercode='EZ'
and cctkt.matchedrecordkey is null
and cctkt.transactiondate between getdate() -60 and getdate()

update cctkt
set cctkt.matchedrecordkey = id.recordkey, 
cctkt.matchediatanum = id.iatanum, 
cctkt.matchedclientcode = id.clientcode,
cctkt.matchedseqnum = id.seqnum
FROM DBA.CCHeader CCHDR
 INNER JOIN DBA.CCTicket CCTKT ON ( CCHDR.RecordKey = CCTKT.RecordKey AND CCHDR.IataNum = CCTKT.IataNum AND CCHDR.TransactionDate = CCTKT.TransactionDate )
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCHDR.BilledCurrCode AND CURRBASE.CurrBeginDate = CCHDR.TransactionDate AND CURRBASE.CurrCode = CCTKT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCTKT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
inner join dba.InvoiceDetail id on (id.servicedate=cctkt.servicedate
and CCHDR.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
--and id.Lastname=SUBSTRING(cctkt.passengername, 1, CASE WHEN CHARINDEX('/', cctkt.passengername) > 0 THEN CHARINDEX('/', cctkt.passengername)-1
--									ELSE LEN(cctkt.passengername)
--								END) 
and substring(id.routing,1,3)=SUBSTRING(cctkt.routing,1,3))
where cctkt.valcarriercode='EZ'
and cctkt.matchedrecordkey is null
and cctkt.transactiondate between getdate() -60 and getdate()

update cchdr
set cchdr.matchedrecordkey = id.recordkey, 
cchdr.matchediatanum = id.iatanum, 
cchdr.matchedclientcode = id.clientcode,
cchdr.matchedseqnum = id.seqnum
FROM DBA.CCHeader CCHDR
 INNER JOIN DBA.CCTicket CCTKT ON ( CCHDR.RecordKey = CCTKT.RecordKey AND CCHDR.IataNum = CCTKT.IataNum AND CCHDR.TransactionDate = CCTKT.TransactionDate )
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCHDR.BilledCurrCode AND CURRBASE.CurrBeginDate = CCHDR.TransactionDate AND CURRBASE.CurrCode = CCTKT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCTKT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
inner join dba.InvoiceDetail id on (id.servicedate=cctkt.servicedate
and CCHDR.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
and id.Lastname=SUBSTRING(cctkt.passengername, 1, CASE WHEN CHARINDEX('/', cctkt.passengername) > 0 THEN CHARINDEX('/', cctkt.passengername)-1
									ELSE LEN(cctkt.passengername)
								END) 
and substring(id.routing,1,3)=SUBSTRING(cctkt.routing,1,3))
where cctkt.valcarriercode='EZ'
and cchdr.matchedrecordkey is null
and cctkt.transactiondate between getdate() -60 and getdate()

update cchdr
set cchdr.matchedrecordkey = id.recordkey, 
cchdr.matchediatanum = id.iatanum, 
cchdr.matchedclientcode = id.clientcode,
cchdr.matchedseqnum = id.seqnum
FROM DBA.CCHeader CCHDR
 INNER JOIN DBA.CCTicket CCTKT ON ( CCHDR.RecordKey = CCTKT.RecordKey AND CCHDR.IataNum = CCTKT.IataNum AND CCHDR.TransactionDate = CCTKT.TransactionDate )
 INNER JOIN DBA.Currency CURRBASE ON ( CURRBASE.CurrCode = CCHDR.BilledCurrCode AND CURRBASE.CurrBeginDate = CCHDR.TransactionDate AND CURRBASE.CurrCode = CCTKT.BilledCurrCode AND CURRBASE.CurrBeginDate = CCTKT.TransactionDate AND CURRBASE.BaseCurrCode = 'USD' )
 INNER JOIN DBA.Currency CURRTO ON ( CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate )
inner join dba.InvoiceDetail id on (id.servicedate=cctkt.servicedate
and CCHDR.BilledAmt* CURRBASE.BaseUnitsPerCurr * CURRTO.CurrUnitsPerBase=id.totalamt
--and id.Lastname=SUBSTRING(cctkt.passengername, 1, CASE WHEN CHARINDEX('/', cctkt.passengername) > 0 THEN CHARINDEX('/', cctkt.passengername)-1
--									ELSE LEN(cctkt.passengername)
--								END) 
and substring(id.routing,1,3)=SUBSTRING(cctkt.routing,1,3))
where cctkt.valcarriercode='EZ'
and cchdr.matchedrecordkey is null
and cctkt.transactiondate between getdate() -60 and getdate()



SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC Match No doc num',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------------------------------------------------------------

update cch
set matchedrecordkey = ccme.merchantid
from dba.ccheader cch, dba.ccmerchantexclude ccme, dba.ccticket cct
where ccme.merchantid = cct.ticketissuer
and cch.recordkey = cct.recordkey
and cch.matchedrecordkey is null
and category = 'TMC'

update cct
set matchedrecordkey = ccme.merchantid
from dba.ccheader cch, dba.ccmerchantexclude ccme, dba.ccticket cct
where ccme.merchantid = cct.ticketissuer
and cch.recordkey = cct.recordkey
and cct.matchedrecordkey is null
and category = 'TMC'

update cch
set matchedrecordkey = ccme.merchantid
from dba.ccheader cch, dba.ccmerchantexclude ccme
where cch.merchantid = ccme.merchantid
and matchedrecordkey is null
and category = 'Leakage'


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CIEBOACC Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


Exec TTXPASQL01.Tman503_Ciena.dbo.sp_CIENA_Anc

--@iatanum = 'CIEBOACC'


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
