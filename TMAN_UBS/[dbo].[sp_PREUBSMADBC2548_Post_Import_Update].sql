/****** Object:  StoredProcedure [dbo].[sp_PREUBSMADBC2548_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSMADBC2548_Post_Import_Update]


as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREUBS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 



--RM*PSCCLN- <local client number> // RM*ACECLN/<local client number>				CUSTOMER NUMBER
--RM*ACECRM/CENTRO COSTE-<cost center>				COST CENTER
--RM*ACECRM/EMPLEADO-<traveler gpn>				TRAVELER GPN
--RM*ACECRM/PROYECTO-<proj>				 PROJ/OPP CODE
--RM*ACECRM/TRSTAT-<rank code>				RANK CODE
--RM*ACECRM/REATRP-<trip purpose>				TRIP PURPOSE
--RM*ACECRM/APPROV-<approvers gpn>				APPROVERS GPN
--RM*ACECRM/TQ3CD2-<bookers gpn>				BOOKERS GPN
--RM*ACECRM/SOLICITUD-<tract ibtf>				TRACT/IBTF
--RM*ACECRM/BCDCD4-<hotel reason code>				HOTEL REASON CODE
--RM*ACECRM/MANAGE-<t24>				T24
--RM*ACECRM/TQ3CD1-<nonrefref indicator>				NONREFREF INDICATOR
--RM*ACECRM/BCDCD4-<Reason not online>		

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start MADBC2548-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='ES'
where iatanum ='PREUBS' and recordkey like '%MADBC2548%' and (origcountry is null or origcountry <> 'ES')

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
--Coding added for text 18 4/16/2015 #6291385
update c
set text18 = SUBSTRING(UDEFDATA,15,2)
from dba.comrmks c,
dba.Udef u
where c.iatanum = 'preubs' and c.recordkey like '%MADBC2548%' 
and c.IataNum=u.iatanum and c.RecordKey=u.recordkey and c.SeqNum=u.seqnum
and u.UdefData like 'ACECRM/BCDCD4-%'
and text18 is null
and u.UdefData <>'ACECRM/BCDCD4-'
and u.UdefData not like 'ACECRM/BCDCD4-/%'
and SUBSTRING(UDEFDATA,15,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')

--update c
--set text18 = 'N/A'
--from dba.comrmks c where iatanum = 'preubs'
--and recordkey like '%MADBC2548%'  and text18 is null


---- Update Reasoncode1 ----------------------------------
update i
set reasoncode1 =  right(udefdata,2)
from dba.udef u, dba.invoicedetail i
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%MADBC2548%' and udefdata like '%ACESV1/%' and reasoncode1 is null

---- Update Htlreasoncode1 ------------------------------
update h
set  htlreasoncode1= substring(udefdata,15,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%MADBC2548%' and htlreasoncode1 is null and udefdata like 'ACECRM/BCDCD4-%' 
AND UdefData <>'ACECRM/BCDCD4-<HOTEL REASON CODE>'


---UPDATE REMARKS1 WITH TRIP PURPOSE
update i
set remarks1 = substring(udefdata,15,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/REATRP-%'
and substring(udefdata,15,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')
and isnull(remarks1,'xx') not in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')

----- Update Remarks2 with GPN 
update i
set remarks2 = substring(udefdata,17,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/EMPLEADO-%' and isnull(remarks2,'Unknown') = 'Unknown'


---- Update Remarks5 w Cost Center From Udef -------------------------------------
update i
set remarks5 = substring(udefdata,21,6)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%MADBC2548%' and remarks5 is null and udefdata like 'ACECRM/CENTRO COSTE-%'

-------- Update text6 with T24 Flag 
update c  
set text6 = substring(udefdata,15,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/MANAGE-%' and text6 is null

-------- Update Text7 with Project Code --- 
update c
set  text7 = substring(udefdata,17,35)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%MADBC2548%' 
and udefdata like 'ACECRM/PROYECTO-%' and isnull(text7,'N/A') = 'N/A'


-------Update Text8 Booker GPN --------------------------- 
update c
set text8 = substring(udefdata,15,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/TQ3CD2-%'
and ((text8 is null) )


-----  Update text14 with Approver GPN ---------------
update c
set  text14 = substring(udefdata,15,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/APPROV-%' and text14 is null
AND UdefData <>'ACECRM/APPROV-<APPROVERS GPN>'


---------- Update Text 17 to Tractid -
update c
set  text17 = substring(udefdata,18,6)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/SOLICITUD-%' and isnull(text17,'N/A') = 'N/A'



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update to Comrmks for Validation Q7YG-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-------Update Text22 = GPN String --------------------------- 
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/EMPLEADO-%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- 
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/REATRP-%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- 
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/CENTRO COSTE-%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- 
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACESV1-%'  and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/BCDCD4-%'  and text26 is null

-------Update Text27 = TractID String --------------------------- 
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/SOLICITUD-%' and text27 is null

-------Update Text28 = Booker GPN String --------------------------- 
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like 'ACECRM/TQ3CD2-%' and text28 is null


-------- Update Text47 with Fare type -----
update c
set text47= substring(udefdata,15,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%MADBC2548%' and udefdata like '.acesv2-%' 
AND udefdata NOT LIKE 'ACECRM/TQ3CD1-%' and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End MADBC2548-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
