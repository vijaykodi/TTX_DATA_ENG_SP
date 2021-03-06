/****** Object:  StoredProcedure [dbo].[sp_PREMIT]    Script Date: 7/14/2015 8:11:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_PREMIT]
@BeginIssueDate datetime,
@EndIssueDate datetime

 AS

SET NOCOUNT ON
DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'PREMIT'
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
--Update client codes that are less than 10 digits per case #00011859
--Added on 3/7/13 by Nina
UPDATE dba.InvoiceDetail
SET clientcode = case 
					when len(clientcode) = 9 then '0'+clientcode
					when len(clientcode) = 8 then '00'+clientcode
					when len(clientcode) = 7 then '000'+clientcode
                    when len(clientcode) = 6 then '0000'+clientcode
                    when len(clientcode) = 5 then '00000'+clientcode
                    when len(clientcode) = 4 then '000000'+clientcode
                    when len(clientcode) = 3 then '0000000'+clientcode
                    when len(clientcode) = 2 then '00000000'+clientcode
                    when len(clientcode) = 1 then '000000000'+clientcode
                    else clientcode
                    end
WHERE IataNum = 'PREMIT'
AND LEN(ClientCode) < 10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in InvoiceDetail',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--UPDATE TS.TypeCode from 'R' to 'A' Where 9F Eurostar, 
--TMC MIDAS needs these to display as air transactions. SF:#00041139
UPDATE TS
SET TS.TypeCode = 'A'
from dba.TranSeg TS, dba.InvoiceDetail ID
where TS.IataNum = 'PREMIT'
and id.IataNum = ts.IataNum
and id.RecordKey = ts.RecordKey
and id.SeqNum = ts.SeqNum
and ts.TypeCode = 'R' 
and ts.SegmentCarrierCode = '9F'
and ts.SegmentCarrierName = 'EUROSTAR'
and id.producttype = 'AIR'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set typecode = A for Eurostar',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--COMMON REMARKS-----------------------------------------------

SET @TransStart = getdate()
--MOVE EMAIL TO REMARKS1 & UPDATE 
UPDATE ID
SET ID.REMARKS2 = substring(REPLACE(REPLACE(UD.UDEFDATA,' ','@'), '//', '@'),1,100)
--select convert(char(10),getdate()-1,101),convert(char(10),getdate(),101),ih.importdt,id.remarks1, ud.udefdata
--select id.remarks2, substring(REPLACE(REPLACE(UD.UDEFDATA,' ','@'), '//', '@'),1,100)
FROM DBA.INVOICEHEADER IH, DBA.UDEF UD, DBA.INVOICEDETAIL ID 
WHERE IH.RECORDKEY = ID.RECORDKEY
AND IH.CLIENTCODE = ID.CLIENTCODE
AND ID.RECORDKEY = UD.RECORDKEY
AND ID.CLIENTCODE = UD.CLIENTCODE
AND ID.SEQNUM = UD.SEQNUM
AND ID.REMARKS2 IS NULL
AND ID.Iatanum = 'PREMIT'
AND UD.UDEFTYPE = '22'
AND IH.IMPORTDT >= convert(char(10),getdate()-1,101)
--between convert(char(10),getdate()-1,101) and convert(char(10),getdate(),101)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks2 with pretrip email addresses',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--MOVE MOBILE TO REMARKS4
UPDATE ID
SET ID.REMARKS4 = substring(REPLACE(UD.UDEFDATA,' ',''),1,100) 
FROM DBA.INVOICEHEADER IH, DBA.UDEF UD, DBA.INVOICEDETAIL ID 
WHERE IH.RECORDKEY = ID.RECORDKEY
AND IH.CLIENTCODE = ID.CLIENTCODE
AND ID.RECORDKEY = UD.RECORDKEY
AND ID.CLIENTCODE = UD.CLIENTCODE
AND ID.SEQNUM = UD.SEQNUM
AND ID.Remarks4 is null
AND ID.IATANUM = 'PREMIT'
AND UD.UDEFTYPE = '18'
AND IH.IMPORTDT >= convert(char(10),getdate()-1,101)
--between convert(char(10),getdate()-1,101) and convert(char(10),getdate(),101)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Remarks4 with UD18 (pretrip cell/mobile number)',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
UPDATE IH
SET IH.clientcode = ID.clientcode
FROM dba.InvoiceHeader IH, dba.InvoiceDetail ID                  
WHERE IH.IataNum = 'PREMIT'
AND IH.RecordKey = ID.RecordKey
AND IH.IataNum = ID.IataNum
AND IH.ClientCode <> ID.ClientCode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in InvoicHeader',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE TS
SET TS.clientcode = ID.clientcode
FROM dba.TranSeg TS, dba.InvoiceDetail ID                  
WHERE TS.IataNum = 'PREMIT'
AND TS.RecordKey = ID.RecordKey
AND TS.SeqNum = ID.SeqNum
AND TS.IataNum = ID.IataNum
AND TS.ClientCode <> ID.ClientCode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in TranSeg',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE CAR
SET CAR.clientcode = ID.clientcode
FROM dba.Car CAR, dba.InvoiceDetail ID                  
WHERE CAR.IataNum = 'PREMIT'
AND CAR.RecordKey = ID.RecordKey
AND CAR.SeqNum = ID.SeqNum
AND CAR.IataNum = ID.IataNum
AND CAR.ClientCode <> ID.ClientCode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in Car',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE HTL
SET HTL.clientcode = ID.clientcode
FROM dba.Hotel HTL, dba.InvoiceDetail ID                  
WHERE HTL.IataNum = 'PREMIT'
AND HTL.RecordKey = ID.RecordKey
AND HTL.SeqNum = ID.SeqNum
AND HTL.IataNum = ID.IataNum
AND HTL.ClientCode <> ID.ClientCode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in Hotel',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE UD
SET UD.clientcode = ID.clientcode
FROM dba.Udef UD, dba.InvoiceDetail ID                  
WHERE UD.IataNum = 'PREMIT'
AND UD.RecordKey = ID.RecordKey
AND UD.SeqNum = ID.SeqNum
AND UD.IataNum = ID.IataNum
AND UD.ClientCode <> ID.ClientCode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in Udef',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
UPDATE CR
SET CR.clientcode = ID.clientcode
FROM dba.ComRmks CR, dba.InvoiceDetail ID                  
WHERE CR.IataNum = 'PREMIT'
AND CR.RecordKey = ID.RecordKey
AND CR.SeqNum = ID.SeqNum
AND CR.IataNum = ID.IataNum
AND CR.ClientCode <> ID.ClientCode
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update clientcodes in ComRmks',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


/*Update Client Table*/
SET @TransStart = getdate()
insert into dba.client
select DISTINCT clientcode,'PREMIT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from dba.invoicedetail 
where clientcode not in (select clientcode from dba.client where iatanum = 'PREMIT')
and iatanum = 'PREMIT'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Add client codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----Added step per SF 00012307 4.3.2013 - Pam S
----UD23 for Low Cost Carrier Code
SET @TransStart = getdate()
update dba.InvoiceDetail
set ValCarrierCode = substring(ud.udefdata,4,2)
from dba.InvoiceDetail ID, dba.Udef UD
where id.iatanum = 'PREMIT'
and ud.UdefData like '23/%'
and (id.valcarriercode = 'YY' or id.ValCarrierCode is null)
and id.iatanum = ud.iatanum
and id.RecordKey = ud.RecordKey
and id.SeqNum = ud.SeqNum
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='UD23 for Low Cost ValCarrierCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Added step per SF 00012307 5.7.2013 - Pam S
----UD23 for Low Cost Carrier Code
SET @TransStart = getdate()
Update dba.TranSeg
set SegmentCarrierCode = substring(udefdata,4,2)
,NOXSegmentCarrierCode = substring(udefdata,4,2)
,MINSegmentCarrierCode = substring(udefdata,4,2)
from dba.Udef ud, dba.TranSeg TSeg
where TSeg.iatanum = 'PREMIT'
and UdefData like '23/%'
and ud.IataNum = TSeg.IataNum
and ud.RecordKey = TSeg.RecordKey
and ud.SeqNum = TSeg.SeqNum
and (TSeg.SegmentCarrierCode = 'YY' or TSeg.SegmentCarrierCode is null)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='UD23 for Low Cost Segs CarrierCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--###########################################################################################
--#############################   NEW PRETRIP MAPPINGS  #####################################
--###########################################################################################
--################# SF.COM - 00036632 #################
--################# GLOBAL MAPPINGS ###################


--#####################################################
-- Fare Exception Code ################################
--#####################################################
--SET @TransStart = getdate()
--update cr
--set cr.Text16 = substring(ud.udefdata,4,150)
----select cr.text16, substring(ud.udefdata, 4, 150)
--from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
--WHERE 
--id.recordkey = cr.recordkey
--and id.IataNum = cr.IataNum
--and id.SeqNum = cr.SeqNum
--and id.recordkey = ud.recordkey
--and id.IataNum = ud.IataNum
--and id.SeqNum = ud.SeqNum
--and id.iatanum = 'PREMIT'
--and ud.UdefData like 'EC/%'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel Rate Type to CRText17 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- Hotel Rate Type #######   CR 17   ##################
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text17 = substring(ud.udefdata,5,150)
--select cr.text17, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like '%FF3/%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Hotel Rate Type to CRText17 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- Policy Fare ############   CR 18   #################
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text18 = substring(ud.udefdata,5,150)
--select cr.text18, substring(ud.udefdata, 6, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF20/%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Policy Fare to cr18 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

----#####################################################
---- YY Decode ############   CR 19   ###################
----#####################################################
--SET @TransStart = getdate()
--update cr
--set cr.Text19 = substring(ud.udefdata,5,150)
----select cr.text19, substring(ud.udefdata, 6, 150)
--from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
--WHERE 
--id.recordkey = cr.recordkey
--and id.IataNum = cr.IataNum
--and id.SeqNum = cr.SeqNum
--and id.recordkey = ud.recordkey
--and id.IataNum = ud.IataNum
--and id.SeqNum = ud.SeqNum
--and id.iatanum = 'PREMIT'
--and ud.UdefData like 'FF23/%'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='YY Code to CR19 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- No Hotel Reason Code ###   CR 20   #################
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text20 = substring(ud.udefdata,5,150)
--select cr.text20, substring(ud.udefdata, 6, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF21/%'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='No Hotel Reason Code to cr20 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--################# CUSTOM MAPPINGS ###################

--#####################################################
-- EMPLOYEE ID #################   CR 01   ############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text1 = substring(ud.udefdata,5,150)
--select cr.text1, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'GSA/%'
and ud.ClientCode in ('0000003219')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Employee ID to cr1 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- COST CENTER #################   CR 03   ############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text3 = substring(ud.udefdata,5,150)
--select cr.text3, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in (  '0000000405','0000003125','0000003251',
						'0000003024','0000003249','0000003252',
						'0000003116','0000003250','0000003253')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center to cr3 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.Text3 = ud.udefdata
--select cr.text3, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and ud.ClientCode in ('0000003226')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center to cr3 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.Text3 = substring(ud.udefdata,4,150)
--select cr.text3, ud.clientcode, ud.udefdata, substring(ud.udefdata, 4, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'PO/%'
and ud.ClientCode in ('0000000181','0000000381')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center to cr3 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- DEPARTMENT #############   CR 04   ############
--#####################################################
--CODE
SET @TransStart = getdate()
update cr
set cr.Text4 = substring(ud.udefdata,5,150)
--select cr.text4, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in ('0000002071','0000003219')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Dept code to cr04 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--DEPT NAME
SET @TransStart = getdate()
update cr
set cr.Text25 = substring(ud.udefdata,5,150)
--select cr.text25, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in ('0000002100','0000002106','0000002107')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Dept code to cr04 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.Text25 = substring(ud.udefdata,5,150)
--select cr.text25, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'GSA/%' and ud.ClientCode in ('0000000181','0000003276')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Dept code to cr04 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- PROJECT CODE ################   CR 06   ############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text6 = substring(ud.udefdata,5,150)
--select cr.text6, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in ('0000003220','0000003261')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Project Code to cr06 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.Text31 = substring(ud.udefdata,5,150)
--select cr.text31, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in ('0000003276','0000000181','0000000381')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Project Code to cr06 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update cr
set cr.Text31 = substring(ud.udefdata,5,150)
--select cr.text31, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'GSA/%'
and ud.ClientCode in (  '0000003202')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Project Code to cr06 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.Text6 = substring(ud.udefdata,5,150)
--select cr.text6, ud.clientcode, ud.UdefType, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and ud.ClientCode in ('0000002071')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Project Code to cr06 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- BOOKER ################   CR 21   ############
--#####################################################
update cr
set cr.Text21 = ud.udefdata
--select cr.text21, ud.clientcode, ud.udefdata, substring(ud.udefdata, 9, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and id.ClientCode not in ('0000000711','0000000750')
and cr.Text21 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center to cr04 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.Text21 = substring(ud.udefdata,5,150)
--select cr.text21, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF5/%'
and ud.ClientCode in (  '0000000181','0000000381')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center to cr04 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
update cr
set cr.Text21 = substring(ud.udefdata,5,150)
--select cr.text21, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in (  '0000003290')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cost Center to cr04 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




--#####################################################
-- CHARGE CODE ################   CR 22   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text22 = substring(ud.udefdata,5,150)
--select cr.text22, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in (  '0000000711','0000000750')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Charge Code to cr22 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- DEAL CODE ##################   CR 24   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text24 = ud.udefdata
--select cr.text24, ud.clientcode, ud.udefdata, substring(ud.udefdata, 9, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and ud.ClientCode in (  '0000000111','0000000310','0000000311','0000000312','0000000313','0000000315','0000000318','0000000321','0000000322','0000000325'
,'0000000326','0000000328','0000000330','0000000331','0000000332','0000000333','0000000334' )						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Deal Code to cr24 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- DEPARTMENT #################   CR 25   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text25 = substring(ud.udefdata,5,150)
--select cr.text25, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'GSA/%'
and ud.ClientCode in (  '0000003276','0000003303')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Department to cr25 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
-- case  06381283  Yuliya Locka 2015-05-15
-- department mapping for 0000003077
SET @TransStart = getdate()
update cr
set cr.Text25 = substring(ud.udefdata,5,150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in (  '0000003307')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Department to cr25 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- JOB NUMBER #################   CR 26   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text26 = substring(ud.udefdata,5,150)
--select cr.text26, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in (  '0000003261','0000002031')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Job Number to cr26 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.Text26 = substring(ud.udefdata,5,150)
--select cr.text26, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'GSA/%'
and ud.ClientCode in (  '0000003225','0000003224')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Job Number to cr26 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- MIPL-NUMBER ################   CR 27   #############
--#####################################################
SET @TransStart = getdate()
		
--New SQL Statement added. MJ 12th Nov 14.
--Data from YOURREF is masked out, so i've joined to ACCTDTLS
--to get the full string. Had to join this way as multiple ACCTDTLS values.
update cr
set cr.Text27 = ud2.UdefData
--select cr.recordkey, cr.text27, ud1.clientcode, ud2.udefdata
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud1, dba.udef ud2
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud1.recordkey
and id.IataNum = ud1.IataNum
and id.SeqNum = ud1.SeqNum
and id.iatanum = 'PREMIT'
AND ud1.RecordKey = ud2.RecordKey
AND ud1.IataNum = ud2.IataNum
AND ud1.SeqNum = ud2.SeqNum
AND ud1.UdefType = 'YOURREF'
AND ud2.UdefType = 'ACCTDTLS'
AND RIGHT(ud1.UdefData,5) = RIGHT(ud2.UdefData,5)
and ud1.ClientCode in ( '0000000711','0000000750')		

--OLD SCRIPT
--update cr
--set cr.Text27 = substring(ud.udefdata,9,150)
----select cr.recordkey, cr.text27, ud.clientcode, ud.udefdata, substring(ud.udefdata, 9, 150)
--from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
--WHERE 
--id.recordkey = cr.recordkey
--and id.IataNum = cr.IataNum
--and id.SeqNum = cr.SeqNum
--and id.recordkey = ud.recordkey
--and id.IataNum = ud.IataNum
--and id.SeqNum = ud.SeqNum
--and id.iatanum = 'PREMIT'
--and ud.UdefType = 'YOURREF'
--and ud.ClientCode in ( '0000000711','0000000750' )


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='T Number Code to cr27 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- PO NUMBER ##################   CR 28   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text28 = substring(ud.udefdata,5,150)
--select cr.text28, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF2/%'
and ud.ClientCode in (  '0000003272','0000003257','0000003202','0000003224','0000003279','0000003303')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PO Number to cr28 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.Text28 = substring(ud.udefdata,5,150)
--select cr.text28, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF5/%'
and ud.ClientCode in ('0000003225')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PO Number to cr28 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update cr
set cr.Text28 = substring(ud.udefdata,5,150)
--select cr.text28, ud.clientcode, ud.udefdata, substring(ud.udefdata, 5, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'PO/%'
and ud.ClientCode in ('0000003290')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PO Number to cr28 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

update cr
set cr.Text28 = ud.udefdata
--select cr.text28, ud.clientcode, ud.udefdata, substring(ud.udefdata, 9, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and ud.ClientCode in ('0000000850','0000002031','0000002064','0000002076')						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='PO Number to cr28 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- POLICY NUMBER ##############   CR 29   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text29 = ud.udefdata
--select cr.text29, ud.clientcode, ud.udefdata
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and ud.ClientCode in ( '0000003001' )						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='T Number Code to cr29 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- REFERENCE NUMBER ###########   CR 32   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text32 = substring(ud.udefdata,5,150)
--select cr.text32, ud.clientcode, substring(ud.udefdata,5,150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefData like 'FF5/%'
and ud.ClientCode in ( '0000003290' )						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ref Number Code to cr32 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--#####################################################
-- T--NUMBER ##################   CR 33   #############
--#####################################################
SET @TransStart = getdate()
update cr
set cr.Text33 = ud.udefdata
--select cr.text33, ud.clientcode, ud.udefdata, substring(ud.udefdata, 9, 150)
from dba.InvoiceDetail id,dba.comrmks cr, dba.udef ud
WHERE 
id.recordkey = cr.recordkey
and id.IataNum = cr.IataNum
and id.SeqNum = cr.SeqNum
and id.recordkey = ud.recordkey
and id.IataNum = ud.IataNum
and id.SeqNum = ud.SeqNum
and id.iatanum = 'PREMIT'
and ud.UdefType = 'YOURREF'
and ud.ClientCode in ( '0000000710' )						
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='T Number Code to cr33 ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--##################################################################################
--###############      CR CLASS HIGHEST CLASS CODES UPDATES       ##################
--############################     BEGIN     #######################################
--########        ADDED BY MJ AND DC 03 SEP 2014. SF 00039453  #####################



--Update TS for MEalname SHL, LHL, DOM
--Update MealName with S, L, or I based on region per case #00012439
--Added on 4/10/13 by Nina
SET @TransStart = getdate()
update ts
set ts.mealname = ts.mininternationalind
from dba.transeg ts, dba.InvoiceHeader ih
where ts.iatanum in ('PREMIT')
and (ts.mealname not in ('S','L','D')
or ts.mealname is null)
and ts.minMktDestCityCode >'A'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set mealname = mininternationalind',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update ts
set ts.mealname = case when origctry.ContinentCode = destctry.ContinentCode and origcit.countrycode <> destcit.countrycode then 'SHL'
--select ts.mealname, case when origctry.ContinentCode = destctry.ContinentCode and origcit.countrycode <> destcit.countrycode then 'SHL'
when origctry.ContinentCode <> destctry.ContinentCode then 'LHL'
when origctry.ContinentCode = destctry.ContinentCode and origcit.countrycode = destcit.countrycode then 'DOM'
end
from dba.transeg ts, TTXPASQL01.TMAN503_MIDASTRAVEL.dba.city origcit, TTXPASQL01.TMAN503_MIDASTRAVEL.dba.city destcit, 
TTXPASQL01.TMAN503_MIDASTRAVEL.dba.country origctry, TTXPASQL01.TMAN503_MIDASTRAVEL.dba.country destctry, dba.InvoiceHeader ih
where ih.RecordKey = ts.RecordKey
and ih.IataNum = ts.IataNum
and isnull(ts.minMktOrigCityCode,ts.OriginCityCode) = origcit.citycode
and origcit.countrycode = origctry.ctrycode
and isnull(ts.minMktDestCityCode,ts.SEGDestCityCode) = destcit.citycode
and destcit.countrycode = destctry.ctrycode
and origcit.typecode = ts.typecode
and destcit.typecode = ts.typecode
and ts.TypeCode = 'A'
and ts.iatanum in ('PREMIT')
and (ts.mealname is null or LEN(ts.mealname) < 3)
--and ih.IMPORTDT = (select MAX(importdt) from dba.InvoiceHeader where IataNum = 'PREMIT')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set mealname = SHL,LHL,or DOM',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--First Class Update
update cr
set cr.text47 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
--select CR.RecordKey, ID.VENDORTYPE, cr.text47 , case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_midastravel.dba.InvoiceHeader IH
INNER JOIN tman503_midastravel.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_midastravel.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_midastravel.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
  INNER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSIDOTH 
 ON  (ALFOURCOSIDOTH.CarrierCode = '**'
 AND ALFOURCOSIDOTH.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1)
	  ) 

 LEFT OUTER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.CarrierCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   --AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'First'
   AND CR.text47 is null
   AND ID.Iatanum IN ('PREMIT')
   AND IH.Importdt = (select MAX(importdt) from dba.InvoiceHeader where IataNum = 'PREMIT')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set text47 to First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 
--Business Class Update
update cr
set cr.text47 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
--select CR.RecordKey, cr.text47 , case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_midastravel.dba.InvoiceHeader IH
INNER JOIN tman503_midastravel.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_midastravel.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_midastravel.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
  INNER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSIDOTH 
 ON  (ALFOURCOSIDOTH.CarrierCode = '**'
 AND ALFOURCOSIDOTH.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1)
	  ) 

 LEFT OUTER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.CarrierCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   --AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Business'
   AND CR.text47 is null
   AND ID.Iatanum IN ('PREMIT')
  AND IH.Importdt = (select MAX(importdt) from dba.InvoiceHeader where IataNum = 'PREMIT')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set text47 to Business',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Economy Plus Class Update  
update cr
set cr.text47 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
--select CR.RecordKey, cr.text47 , case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_midastravel.dba.InvoiceHeader IH
INNER JOIN tman503_midastravel.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_midastravel.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_midastravel.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
  INNER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSIDOTH 
 ON  (ALFOURCOSIDOTH.CarrierCode = '**'
 AND ALFOURCOSIDOTH.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1)
	  ) 

 LEFT OUTER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.CarrierCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   --AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Economy Plus'
   AND CR.text47 is null
   AND ID.Iatanum IN ('PREMIT')
  AND IH.Importdt = (select MAX(importdt) from dba.InvoiceHeader where IataNum = 'PREMIT')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set text47 to Economy Plus',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR  


--Economy Class Update
update cr
set cr.text47 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
--select CR.RecordKey, cr.text47 , case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM tman503_midastravel.dba.InvoiceHeader IH
INNER JOIN tman503_midastravel.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN tman503_midastravel.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN tman503_midastravel.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
  INNER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSIDOTH 
 ON  (ALFOURCOSIDOTH.CarrierCode = '**'
 AND ALFOURCOSIDOTH.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1)
	  ) 

 LEFT OUTER JOIN tman503_midastravel.dba.FareClassRef ALFOURCOSID ON  (ALFOURCOSID.CarrierCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = isnull(TS.MealName,'DOM')
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
  -- AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Economy'
   AND CR.text47 is null
   AND ID.Iatanum IN ('PREMIT')
   AND IH.Importdt = (select MAX(importdt) from dba.InvoiceHeader where IataNum = 'PREMIT')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Set text47 to Economy',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IATANUM=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
   
--##################################################################################
--###############      CR CLASS HIGHEST CLASS CODES UPDATES       ##################
--############################     END       #######################################
--##################################################################################

GO
