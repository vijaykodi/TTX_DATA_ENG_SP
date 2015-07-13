
--------------------------------------------------------------
--Removing beginning and ending spaces in all hotel fields
--------------------------------------------------------------
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from @productionservcer.@productiondatabasename.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
and htl.iatanum = '@iatanum'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--------------------------------------------------------------
--Removing unseen characters in htlpropertyname and htladdr1
--------------------------------------------------------------

SET @TransStart = getdate()
UPDATE @productionservcer.@productiondatabasename.DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',','')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null
and iatanum in ('@iatanum')
and invoicedate between @BeginIssueDate and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
