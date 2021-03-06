/****** Object:  StoredProcedure [dbo].[sp_LOGCWT]    Script Date: 7/14/2015 8:11:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_LOGCWT] 

	@BeginIssueDate	datetime,
	@EndIssueDate	datetime

AS
--

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'LOGCWT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update car
set car.issuedate = cr.issuedate
from dba.car car, dba.invoicedetail cr
where car.issuedate <> cr.issuedate
AND CR.RecordKey = car.RecordKey
AND CR.IataNum = car.IataNum 
AND CR.SeqNum = car.SeqNum 
AND CR.ClientCode = car.ClientCode
and cr.iatanum ='LOGCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update htl
set htl.issuedate = cr.issuedate
from dba.hotel htl, dba.invoicedetail cr
where htl.issuedate <> cr.issuedate
AND CR.RecordKey = HTL.RecordKey
AND CR.IataNum = HTL.IataNum 
AND CR.SeqNum = HTL.SeqNum 
AND CR.ClientCode = HTL.ClientCode
and cr.iatanum ='LOGCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update htl',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--update CWT hotel chain codes added 7/27/09
update ht
set ht.htlchaincode = ch.trxcode,
ht.htlchainname = ch.trxchainname
from dba.hotel ht, dba.cwthtlchains ch
where len(ht.htlchaincode) > 2
and ht.htlchaincode = ch.cwtcode
and ht.iatanum = 'LOGCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update CWT hotel chain codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--update car chain code ZL1/ZL2 to ZL and update car chain name to National 3/19/10
update dba.car
set carchainname = 'NATIONAL CAR RENTAL',
carchaincode = 'ZL'
where iatanum = 'LOGCWT'
and carchainname is null
and cardailyrate is not null
and (carchaincode = 'ZL1'
or carchaincode = 'ZL2')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update car chain code ZL1/ZL2 to ZL',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update preferred car vendor per Brian...added 12/16/10
update dba.car
set prefcarind = 'Y'
where iatanum = 'LOGCWT'
and carchaincode in ('SX','ZD','ZI')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update preferred car vendor',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate)
	SELECT DISTINCT RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate, IssueDate
	  FROM dba.InvoiceDetail 
     WHERE iatanum in ('LOGCWT')
       AND RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) NOT IN (SELECT DISTINCT RecordKey+IataNum+CONVERT(VARCHAR,SeqNum)
			FROM dba.ComRmks 
			WHERE iatanum in ('LOGCWT'))
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='INSERT INTO dba.ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
   set valcarriercode ='ZZ',
       vendorname ='UNKNOWN AIRLINE',
       valcarriernum ='999'
 where iatanum ='LOGCWT'
   and valcarriercode ='***'
   and vendortype in ('BSP','NONBSP')
   and voidind ='N'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set valcarriercode = ZZ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.transeg
  set segmentcarriercode ='ZZ',
      segmentcarriername ='UNKNOWN AIRLINE'
where iatanum ='LOGCWT'
  and segmentcarriercode ='***'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set segmentcarriercode = ZZ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
  

SET @TransStart = getdate()
--POS Country
update dba.comrmks
set text50 = right(clientcode,2)
where iatanum ='LOGCWT'
and text50 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text50 = right(clientcode,2)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
---rEASONcODES
update dba.invoicedetail
set reasoncode1 = 'LU'
where iatanum ='LOGCWT'
and reasoncode3 in ('CF','CR','LC','MC','RF','SC','SD','SF','TP','UC','WF','XI','XX','L','Q')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set reasoncode1 = LU',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.invoicedetail
set reasoncode1 = '99'
where iatanum ='LOGCWT'
and reasoncode3 IS NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set reasoncode1 = 99',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
-- EMPLID FROM UDID
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/AT','342/ES','342/IT','342/NO','342/IE','342/FI','342/GB','342/MX','FT5-US/US','342/CN')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/HU','342/ZA')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 2
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/DE','342/FR')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/PL','342/SE')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 4',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/DK')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 5
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 5',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/IN','342/MY','342/SG')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 11
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 11',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--UDEF NL -Emplid
update cr
set cr.text1 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/NL')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum in (1, 3, 4)
AND LEN(UD.UDEFDATA) = 5
AND UD.UDEFDATA <>'NIJME'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum in (1, 3, 4)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
----Update US - Employee Number - #1070896
-- commented out 2/13/12
--update cr
--set cr.text1 = ud.udefdata
--from dba.comrmks cr, dba.udef ud
--where cr.iatanum = 'LOGCWT'
--and cr.clientcode in ('FT5-US/US')
--and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
--and cr.clientcode = ud.clientcode
--and cr.iatanum = ud.iatanum
--and ud.udefnum = 8
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update cr where udefnum = 8',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.comrmks
set text1 = '0'+text1
where iatanum = 'LOGCWT'
and len(text1) = 4
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text1 = 0+text1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--DEPT FROM UDID
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/AT','342/DE','342/ES','342/PL','342/IE','342/FI','342/GB','342/MX','342/CN')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 2
AND LEN(UD.UDEFDATA) = 9
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text4 = ud.udefdata where udefnum = 2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/DK','342/FR')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 1
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text4 = ud.udefdata where udefnum = 1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/HU','342/NO')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 3
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text4 = ud.udefdata where udefnum = 3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--UDEF NL -Dept
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/NL')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 3
AND LEN(UD.UDEFDATA) = 9
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text4 = ud.udefdata where UDEFDATA = 9',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--UDEF SE -Dept
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('342/SE')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum in (1, 5)
AND LEN(UD.UDEFDATA) = 9
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text4 = ud.udefdata where udefnum in (1, 5)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update US - Department - #1070896
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('FT5-US/US')
and cr.recordkey = ud.recordkey
and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 9
AND LEN(UD.UDEFDATA) = 9
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update US',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()  
update cr
set cr.text2 = em.location,
cr.text3 = em.region,
cr.text4 = em.deptid,
cr.text5 = em.supvid,
cr.text6 = em.vpid
from dba.comrmks cr, dba.employee em
where cr.text1 = em.emplid
AND cr.IATANUM = 'LOGCWT'
and len(cr.text1) = 5
and cr.text2 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text2 = em.location',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update US - Department - #1070896
update cr
set cr.text4 = ud.udefdata
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('FT5-US/US')
and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 2
AND LEN(UD.UDEFDATA) = 9
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update US DeptID',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text3 ='NAR'
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'
and cr.clientcode in ('FT5-US/US')
and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
and ud.udefdata in ('112','113','119','120','121','133')
and cr.text3 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update US Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
---add text3 update to NAR, EMEA, APAC based on clientcode
update dba.comrmks
set Text3 = case when RIGHT(clientcode,2) IN ('US','CA','MX') then 'NAR'
 when RIGHT(clientcode,2) IN ('CN','IN','KR','MY','SG') then 'APAC'
 when RIGHT(clientcode,2) IN ('NO','FI','DK','NL','HU','IT','SE','DE','FR',
 'IE','PL','GB','AT','ES','PT','ZA') then 'EMEA'
 end
from dba.ComRmks
where Text3 is null
and IataNum = 'LOGCWT'
and (ClientCode like '342/%'
or ClientCode like 'FT5-US/%')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Other Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.text9 ='US'
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'

and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
and ud.udefdata in ('112')
and cr.text9 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update US Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update cr
set cr.text9 ='CA'
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'

and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
and ud.udefdata in ('113','121')
and cr.text9 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CA Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text9 ='BR'
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'

and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
and ud.udefdata in ('119')
and cr.text9 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update BR Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update cr
set cr.text9 ='CL'
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'

and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
and ud.udefdata in ('120')
and cr.text9 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CL Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()
update cr
set cr.text9 ='AR'
from dba.comrmks cr, dba.udef ud
where cr.iatanum = 'LOGCWT'

and cr.recordkey = ud.recordkey
--and cr.seqnum = ud.seqnum
and cr.clientcode = ud.clientcode
and cr.iatanum = ud.iatanum
and ud.udefnum = 4
and ud.udefdata in ('133')
and cr.text9 is null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update AR Region',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.text8 = cr.text3 + '-' + cr.text4
from dba.comrmks cr
where cr.IATANUM = 'LOGCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set cr.text8 = cr.text3 + - + cr.text4',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.comrmks
   set text8 = 'UNK-XXXX'
where text8 is null
   and iatanum ='LOGCWT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text8 = UNK-XXXX where text8 is null',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update dba.comrmks
   set text8 = 'UNK-XXXX'
 where iatanum ='LOGCWT'
         and text8  not in 
     (select corporatestructure
        from dba.rollup40
       where costructid ='LOGITECH')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='set text8 = UNK-XXXX',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into dba.fareclassref
select distinct substring(id.valcarriercode,1,3),'DOM',null,
                substring(id.ServiceCategory,1,1),null,
                'Economy','Economy',null
from dba.InvoiceDetail id
where id.VendorType in ('BSP','NONBSP','RAIL')
and id.internationalind = 'D'
and not exists (select 1 from dba.fareclassref b
                where b.carriercode = substring(id.valcarriercode,1,3)
                and b.fareclasscode =  substring(id.ServiceCategory,1,1)
                )
and id.valcarriercode is not null 
and id.ServiceCategory is not null
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert into fareclassref from InvoiceDetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into dba.fareclassref
select distinct substring(ts.SegmentCarrierCode,1,3),'DOM',null,
                substring(ts.ClassOfService,1,1),null,
                'Economy','Economy',null
                from dba.transeg ts
where  not exists (select 1 from dba.fareclassref b
                where b.carriercode = substring(ts.SegmentCarrierCode,1,3)
                and b.fareclasscode =  substring(ts.ClassOfService,1,1))
and ts.SegmentCarrierCode is not null 
and ts.ClassOfService is not null
and ts.seginternationalind = 'D'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert DOM into fareclassref',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into dba.fareclassref
select distinct substring(ts.SegmentCarrierCode,1,3),'SHL',null,
                substring(ts.ClassOfService,1,1),null,
                'Economy','Economy',null
                from dba.transeg ts
where  not exists (select 1 from dba.fareclassref b
                where b.carriercode = substring(ts.SegmentCarrierCode,1,3)
                and b.fareclasscode =  substring(ts.ClassOfService,1,1))
and ts.SegmentCarrierCode is not null 
and ts.ClassOfService is not null
and ts.seginternationalind = 'I'
and ts.segsegmentmileage < 2500
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert SHL into fareclassref',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
insert into dba.fareclassref
select distinct substring(ts.SegmentCarrierCode,1,3),'LHL',null,
                substring(ts.ClassOfService,1,1),null,
                'Economy','Economy',null
                from dba.transeg ts
where  not exists (select 1 from dba.fareclassref b
                where b.carriercode = substring(ts.SegmentCarrierCode,1,3)
                and b.fareclasscode =  substring(ts.ClassOfService,1,1))
and ts.SegmentCarrierCode is not null 
and ts.ClassOfService is not null
and ts.seginternationalind = 'I'
and ts.segsegmentmileage > 2500
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert LHL into fareclassref',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update dba.invoicedetail
set intlsalesind = internationalind
from dba.invoicedetail
where intlsalesind is null
and internationalind is not null
and iatanum like 'LOG%'
and issuedate >'2010-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update intlsalesind with intlind',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update id
set id.intlsalesind = case when destctry.countrycode = origctry.countrycode then 'D'
when origctry.continentcode = destctry.continentcode then 'C'
end
from dba.invoicedetail id, dba.transeg ts, dba.city origcit, dba.city destcit, 
dba.logcountry origctry, dba.logcountry destctry
where id.origincode = origcit.citycode
and origcit.countrycode = origctry.countrycode
and id.destinationcode = destcit.citycode
and destcit.countrycode = destctry.countrycode
and origcit.typecode = ts.typecode
and destcit.typecode = ts.typecode
and id.recordkey = ts.recordkey
and id.seqnum = ts.seqnum
and ts.segmentnum = 1
and id.iatanum like 'LOG%'
and id.issuedate >'2010-12-31'
and id.internationalind = 'I'
--and id.intlsalesind <> 'C'
and origctry.continentcode = destctry.continentcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update intlsalesind with C',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update ts
set ts.mealname = ts.mininternationalind
from dba.transeg ts
where ts.iatanum like 'LOG%'
and ts.issuedate >'2010-12-31'
and (ts.mealname not in ('C','D','I')
or ts.mealname is null)
and ts.minMktDestCityCode >'A'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='insert LHL into fareclassref',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


update ts
set ts.mealname = case when destctry.countrycode = origctry.countrycode then 'D'
when origctry.continentcode = destctry.continentcode then 'C'
end
--select ts.minInternationalInd , case when destctry.countrycode = origctry.countrycode then 'D'
--when origctry.continentcode = destctry.continentcode then 'C'
--end,
--ts.minMktOrigCityCode,ts.minMktDestCityCode
from dba.transeg ts, dba.city origcit, dba.city destcit, 
dba.logcountry origctry, dba.logcountry destctry
where ts.minMktOrigCityCode = origcit.citycode
and origcit.countrycode = origctry.countrycode
and ts.minMktDestCityCode = destcit.citycode
and destcit.countrycode = destctry.countrycode
and origcit.typecode = ts.typecode
and destcit.typecode = ts.typecode
and ts.iatanum like 'LOG%'
and ts.issuedate >'2010-12-31'
and ts.mininternationalind = 'I'
--and id.intlsalesind <> 'C'
and origctry.continentcode = destctry.continentcode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='update mealname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


GO
