/****** Object:  StoredProcedure [dbo].[sp_PREUBSQ7YG_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSQ7YG_Post_Import_Update]


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


--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start Q7YG-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--COST CENTER>.U*3-CCT-12345 to ID.Remarks5 
--TRAVELER GPN> .U*7-EMP-12345678 to ID.Remarks2 
--RANK CODE> .U*11-TST-MD 
--TRIP PURPOSE> .U*8-RST-NC to ID.Remarks1 
--BOOKERS GPN>.U*14-CD2-12345678 to text 8 
--APPROVERS GPN> U*9-APN-12345678 to CR.Text14 
--T24> U*12-MSP-N to text 6 
--HOTEL REASON CODE> U*23-HR-H1 to hotel.hotelreasoncode1 
--PROJ/OPP CODE> U*5-PJN-ABC1234567 to CR. Text7 
--RSHOW/RECRUIT/TRISK> U*13-CD1-GFDAS123456 
--TRACT/IBTF> U*6-ORN-111111 to CR.Text17 
--TTL PNR L- FARE> .U*17-LFQ-000.00 PLN to ID.FareCompare2


SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='PL'
where iatanum ='PREUBS' and recordkey like '%Q7YG-%' and (origcountry is null or origcountry <> 'PL')

-----Update text18 with the Online Reason Code of N/A as this PCC is not booking online.
update c
set text18 = 'N/A'
from dba.comrmks c where iatanum = 'preubs'
and recordkey like '%Q7YG-%'  and text18 is null

-------Update Text8 Booker GPN --------------------------- 
update c
set text8 = substring(udefdata,10,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%Q7YG-%' and udefdata like 'U*14%'
and ((text8 is null) or (text8 like 'Not%'))

---UPDATE REMARKS1 WITH TRIP PURPOSE
update i
set remarks1 = substring(udefdata,5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udeftype like 'U*8%'
and substring(udefdata,5,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')
and isnull(remarks1,'xx') not in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')


---- Update Cost Center From Udef -------------------------------------
update i
set remarks5 = substring(udefdata,5,20)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%Q7YG-%' and remarks5 is null and udeftype like 'U*3%'

-------- Update text6 with T24 Flag 
update c  
set text6 = substring(udefdata,10,1)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udefdata like 'U*12%' and text6 is null

---- Update Reasoncode1 ----------------------------------
update i
set reasoncode1 = substring(udefdata,10,2)
from dba.udef u, dba.invoicedetail i
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%Q7YG-%' and udefdata like 'U*21%' and reasoncode1 is null

---- Update Htlreasoncode1 ------------------------------
update h
set  htlreasoncode1= substring(udefdata,9,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%Q7YG-%' and htlreasoncode1 is null and udefdata like 'U*23%' 


----- Update Remarks2 with GPN 
update i
set remarks2 = substring(udefdata,5,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udeftype = 'U*7' and isnull(remarks2,'Unknown') = 'Unknown'

-----  Update text14 with Approver GPN ---------------
update c
set  text14 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%Q7YG-%' and udeftype like 'U*9%' and text14 is null



---------- Update Text 17 to Tractid -
update c
set  text17 = substring(udefdata,5,6)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%Q7YG-%' and udeftype like 'U*6%' and isnull(text17,'N/A') = 'N/A'

-------- Update Text7 with Project Code --- 
update c
set  text17 = substring(udefdata,9,10)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%Q7YG-%' 
and udefdata like 'U*5%' and isnull(text7,'N/A') = 'N/A'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation Q7YG-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text22 = GPN String --------------------------- 
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udeftype like 'U*7%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- 
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udeftype like 'U*8%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- 
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udeftype like 'U*3%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- 
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udefdata like 'U*21-%' and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udefdata like 'U*23-%' and text26 is null

-------Update Text27 = TractID String --------------------------- 
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udeftype like 'U*6-%' and text27 is null

-------Update Text28 = Booker GPN String --------------------------- 
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%Q7YG-%' and udefdata like 'U*14-%' and text28 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End Q7YG-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
