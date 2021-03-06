/****** Object:  StoredProcedure [dbo].[sp_PREUBSLOSN82456_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSLOSN82456_Post_Import_Update]


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


--RM*CLNB-3230			CUSTOMER NUMBER
--RM*CCT-				COST CENTER (remarks5)
--RM*EMP-				TRAVELER GPN (Remarks2)
--RM*PJN-				PROJ/OPP CODE (text7)
--RM*TST-				RANK CODE 
--RM*RST-				TRIP PURPOSE (Remarks1)
--RM*APN-				APPROVERS GPN (Text14)
--RM*CD2-				BOOKERS GPN (Text 8)
--RM*ORN-				TRACT/IBTF (Text 17)
--RM*CD1-				NONREFREF INDICATOR (Text 9)
--RM*PNR-				PNR ROUTING
--RM*RCO-				AIR REASON CODE (RC1)
--RM*HR-				HOTEL REASON CODE (HTLRC1)
--RM*MSP-				T24 (Text 6)
--RM*LFQ-NGN200000	Low Fare	

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start LOSN82456-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='NG'
where iatanum ='PREUBS' and recordkey like '%LOSN82456%' and (origcountry is null or origcountry <> 'NG')


---- Update Reasoncode1 ----------------------------------
update i
set reasoncode1 =  right(udefdata,2)
from dba.udef u, dba.invoicedetail i
where i.iatanum = 'preubs' and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and u.recordkey like '%LOSN82456%' and udefdata like 'RCO-%' 
and UdefType='RM OTHER' and reasoncode1 is null

---- Update Htlreasoncode1 ------------------------------
update h
set  htlreasoncode1= substring(udefdata,4,2)
from dba.hotel h, dba.udef u
where h.iatanum = 'preubs'
and h.recordkey = u.recordkey and h.seqnum = u.seqnum
and u.recordkey like '%LOSN82456%' and htlreasoncode1 is null and udefdata like 'HR-%' 
and UdefType='RM OTHER'


---UPDATE REMARKS1 WITH TRIP PURPOSE
update i
set remarks1 = substring(udefdata,5,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'RST-%'
and UdefType='RM OTHER'
and substring(udefdata,5,2) in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')
and isnull(remarks1,'xx') not in (select lookupvalue from dba.lookupdata where lookupname = 'trippur')

----- Update Remarks2 with GPN 
update i
set remarks2 = substring(udefdata,5,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'EMP-%' and isnull(remarks2,'Unknown') = 'Unknown'
and UdefType='RM OTHER'

---- Update Remarks5 w Cost Center From Udef -------------------------------------
update i
set remarks5 = substring(udefdata,5,6)
from dba.invoicedetail i, dba.udef u
where i.iatanum = 'preubs'
and i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.recordkey like '%LOSN82456%' and remarks5 is null and udefdata like 'CCT-%'
and UdefType='RM OTHER'

-------- Update text6 with T24 Flag 
update c  
set text6 = substring(udefdata,5,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'MSP-%' and text6 is null
and UdefType='RM OTHER'

-------- Update Text7 with Project Code --- 
update c
set  text7 = substring(udefdata,5,35)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%LOSN82456%' 
and udefdata like 'PJN-%' and isnull(text7,'N/A') = 'N/A'
and UdefType='RM OTHER'


-------Update Text8 Booker GPN --------------------------- 
update c
set text8 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and u.recordkey like '%LOSN82456%' and udefdata like 'CD2-%'
and ((text8 is null) )
and UdefType='RM OTHER'


-----  Update text9 with Refundable/Non ---------------
update c
set  text9 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%LOSN82456%' and udefdata like 'CD1-%' and text9 is null
and UdefType='RM OTHER'

-----  Update text14 with Approver GPN ---------------
update c
set  text14 = substring(udefdata,5,8)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum
and u.recordkey like '%LOSN82456%' and udefdata like 'APN-%' and text14 is null
and UdefType='RM OTHER'


---------- Update Text 17 to Tractid -
update c
set  text17 = substring(udefdata,5,6)
from dba.comrmks c, dba.udef u
where c.iatanum = 'preubs'
and c.recordkey = u.recordkey and c.seqnum = u.seqnum 
and u.recordkey like '%LOSN82456%' and udefdata like 'ORN-%' and isnull(text17,'N/A') = 'N/A'
and UdefType='RM OTHER'

-----Update text18 with the Online Reason Code of N/A as this PCC does not have online mapping
update c
set text18 = 'N/A'
from dba.comrmks c where iatanum = 'preubs'
and recordkey like '%LOSN82456%'  and text18 is null



EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update to Comrmks for Validation ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------Update Text13 = Online Reason String -----------No mapping given---------------- 
--update c
--set text13 = udefdata
--from dba.comrmks c, dba.udef u
--where c.recordkey = u.recordkey and c.seqnum = u.seqnum
--and c.iatanum = 'preubs'
--and u.recordkey like '%LOSN82456%' and udefdata like 'xxxx%' and text13 is null


-------Update Text22 = GPN String --------------------------- 
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'EMP-%' and text22 is null

-------Update Text23 = Trip Purpose String --------------------------- 
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'RST-%' and text23 is null

-------Update Text24 = Cost Center String --------------------------- 
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'CCT-%' and text24 is null

-------Update Text25 = Air ReasonCode1 String --------------------------- 
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'RCO-%'  and text25 is null

-------Update Text26 = HtlReasonCode1 String --------------------------
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'HR-%'  and text26 is null

-------Update Text27 = TractID String --------------------------- 
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'ORN-%' and text27 is null

-------Update Text28 = Booker GPN String --------------------------- 
update c
set text28 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'CD2-%' and text28 is null

-------Update Text29 = Approver GPN String --------------------------- 
update c
set text29 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and u.recordkey like '%LOSN82456%' and udefdata like 'APN-%' and text29 is null


-------- Update Text47 with Fare type -----
--update c
--set text47= substring(udefdata,15,2)
--from dba.udef u, dba.comrmks c
--where u.recordkey = c.recordkey and u.seqnum = c.seqnum
--and u.iatanum = 'preubs'
--and u.recordkey like '%LOSN82456%' and udefdata like 'xxxxx-%' 
-- and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End LOSN82456-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Exec sp_Main_Mini

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 
GO
