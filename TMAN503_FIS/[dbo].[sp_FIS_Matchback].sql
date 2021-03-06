/****** Object:  StoredProcedure [dbo].[sp_FIS_Matchback]    Script Date: 7/14/2015 8:06:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_FIS_Matchback]

 AS
 SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,
 @BeginIssueDate datetime, @ENDIssueDate datetime
	SET @Iata = 'FISMatchback'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

--Log Activity
SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='1-Stored Procedure Start -',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---- Additional CC Matching as not begin matched by CC Match back ----- LOC/8/16/2013
-- added the corresponding matched credit card record in the invoice detail table.//TT//05.05.2014
update cct
set cct.matchedrecordkey = id.recordkey
, cct.matchediatanum = id.iatanum
, cct.matchedclientcode = id.clientcode
, cct.matchedseqnum = id.seqnum

from TTXPASQL01.TMAN503_FIS.dba.invoicedetail id, TTXPASQL01.TMAN503_FIS.dba.ccticket cct, TTXPASQL01.TMAN503_FIS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cct.matchedrecordkey is null 
and invoicedate > '1-1-2013' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(20)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,3) = substring(passengername,1,3)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and isnull(substring(cct.valcarriercode,3,1),substring(id.valcarriercode,3,1)) = substring(id.valcarriercode,3,1)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCT Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cch
set cch.matchedrecordkey = id.recordkey
, cch.matchediatanum = id.iatanum
, cch.matchedclientcode = id.clientcode
, cch.matchedseqnum = id.seqnum

from TTXPASQL01.TMAN503_FIS.dba.invoicedetail id, TTXPASQL01.TMAN503_FIS.dba.ccticket cct, TTXPASQL01.TMAN503_FIS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and cch.matchedrecordkey is null and invoicedate > '1-1-2013' 
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(20)and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,3) = substring(passengername,1,3)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and isnull(substring(cct.valcarriercode,3,1),substring(id.valcarriercode,3,1)) = substring(id.valcarriercode,3,1)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='CCH Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update id
set id.matchedind = '2'
, id.ccmatchedrecordkey = cct.recordkey
, id.ccmatchediatanum = cct.iatanum
from TTXPASQL01.TMAN503_FIS.dba.invoicedetail id, TTXPASQL01.TMAN503_FIS.dba.ccticket cct, TTXPASQL01.TMAN503_FIS.dba.ccheader cch
,DBA.Currency CURRBASE , dba.currency currto
where id.documentnumber = cct.ticketnum and cct.recordkey = cch.recordkey 
and id.matchedind is null and invoicedate > '1-1-2013' 
and id.recordkey = cct.matchedrecordkey
and id.totalamt - (cch.billedamt *  (CURRBASE.BaseUnitsPerCurr*CURRTO.CurrUnitsPerBase)) < abs(20)
and voidind = 'n'
and vendortype in ('bsp','nonbsp') and documentnumber not like '99999%'
and substring(lastname,1,3) = substring(passengername,1,3)
and (CURRBASE.BaseCurrCode = CURRTO.BaseCurrCode AND CURRBASE.CurrBeginDate = CURRTO.CurrBeginDate 
AND CURRBASE.BaseCurrCode = 'USD' ) and CURRTO.CurrCode ='usd'
and cch.billedcurrcode = CURRBASE.CurrCode  and currbase.currbegindate = cch.transactiondate
and isnull(substring(cct.valcarriercode,3,1),substring(id.valcarriercode,3,1)) = substring(id.valcarriercode,3,1)




------------------  Accounting for Voids and removing from appearing on reports --- LOC/2/4/2014

update cct1
set cct1.matchedrecordkey = id.recordkey
, cct1.matchediatanum = id.iatanum
, cct1.matchedclientcode = id.clientcode
, cct1.matchedseqnum = id.seqnum

from dba.ccticket cct1, dba.ccticket cct2, dba.invoicedetail id
where cct1.matchedrecordkey is null 
and cct1.recordkey <> cct2.recordkey and cct1.ticketnum = cct2.ticketnum
and cct1.ticketamt = cct2.ticketamt*-1 and cct1.ticketamt >0
and cct1.ticketnum = id.documentnumber
and cct1.ticketnum in 
	(select documentnumber from dba.invoicedetail where  voidind = 'y' and documentnumber not like '99999%')
and cct1.iatanum <> 'fisccah'  and cct2.iatanum <> 'fisccah'

update cct2
set cct2.matchedrecordkey = id.recordkey
, cct2.matchediatanum = id.iatanum
, cct2.matchedclientcode = id.clientcode
, cct2.matchedseqnum = id.seqnum

from dba.ccticket cct1, dba.ccticket cct2, dba.invoicedetail id
where cct2.matchedrecordkey is null 
and cct1.recordkey <> cct2.recordkey and cct1.ticketnum = cct2.ticketnum
and cct1.ticketamt = cct2.ticketamt*-1 and cct1.ticketamt >0
and cct1.ticketnum = id.documentnumber
and cct1.ticketnum in 
	(select documentnumber from dba.invoicedetail where  voidind = 'y' and documentnumber not like '99999%')
and cct1.iatanum <> 'fisccah'  and cct2.iatanum <> 'fisccah'

update cch
set cch.matchedrecordkey = cct.matchedrecordkey
, cch.matchediatanum = cct.matchediatanum
, cch.matchedclientcode = cct.matchedclientcode
, cch.matchedseqnum = cct.matchedseqnum
from dba.ccticket cct, dba.ccheader cch
where cch.matchedrecordkey is null and cct.matchedrecordkey is not null 
and cct.recordkey = cch.recordkey 


update id
set id.matchedind = '2'
, id.ccmatchedrecordkey = cct.recordkey
, id.ccmatchediatanum = cct.iatanum
from dba.ccticket cct, dba.invoicedetail id
where id.matchedind is null and cct.matchedrecordkey is not null 
and cct.ticketnum = id.documentnumber  
and vendortype in ('bsp','nonbsp')


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='Void Match back update Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,
@StepName='FIS Matchback Stored Procedure Complete-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO
