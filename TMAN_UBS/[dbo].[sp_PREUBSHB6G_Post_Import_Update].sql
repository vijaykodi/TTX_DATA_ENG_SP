/****** Object:  StoredProcedure [dbo].[sp_PREUBSHB6G_Post_Import_Update]    Script Date: 7/14/2015 7:39:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_PREUBSHB6G_Post_Import_Update]

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start HB6G-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


/*Update ih.origcountry if NULL*/

--SELECT ih.origcountry
update dba.invoiceheader
set origcountry ='CH'
where iatanum ='PREUBS' and recordkey like '%HB6G-%'
and (origcountry is null or origcountry ='XX')


---May need to put some additional code in for the hotel reason code due to segment selecting--LOC/8/7/2012


------- Updating carrcommamt to the total car rate from remarks
update c
set carcommamt = NULL
from dba.car c
where c.recordkey like '%HB6G-%' and carcommamt = '0'

update car
set carcommamt = udefdata
from dba.car car, dba.udef u
where car.recordkey = u.recordkey and car.seqnum = u.seqnum
and car.recordkey like '%HB6G-%' and udeftype = 'cartotalrate'


----- Update Air Reason Codes if not updated in Parsing ------- LOC 8/7/2012
---------------Parse when no segment select ------------------  LOC/9/19/2012
update i
set reasoncode1 = right(udefdata,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%'
and udefdata like '.acesv1-%' and udefdata not like '%*%' and reasoncode1 is null

---------------parse when segment select -----------------------LOC / 9/19/2012
update i
set reasoncode1 =substring(udefdata,charindex('*',udefdata)-2,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%'
and udefdata like '.acesv1-%' and udefdata like '%*%' and reasoncode1 is null

---------------- Update HtlReasonCode1  -------- LOC/8/7/2012
-----------------Udate where no segment select or garbage data ------ LOC/9/19/2012
update h
set htlreasoncode1 = right(udefdata,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs'
and H.recordkey like '%HB6G-%' and udefdata like '.acehot-pr-hot-%'
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and right(udefdata,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')

----------------Update when segment select in string ------- LOC/9/19/2012
update h
set htlreasoncode1 = substring(udefdata,charindex('*',udefdata)-2,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%'
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('*',udefdata)-2,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')


update h
set htlreasoncode1 = substring(udefdata,charindex('#',udefdata)-2,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%'
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('#',udefdata)-2,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')


-------- Additional code added for new formats --- LOC/4/8/2014
update h
set htlreasoncode1 = substring(udefdata,charindex('UP',udefdata)-3,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%' and udefdata like '%up%'  
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('UP',udefdata)-3,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')

update h
set htlreasoncode1 = substring(udefdata,charindex('CO',udefdata)-3,2)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum
and h.iatanum = 'preubs' and H.recordkey like '%HB6G-%'
and udefdata like '.acehot-pr-hot-%' 
and isnull(htlreasoncode1,'XXX') not in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')
and substring(udefdata,charindex('CO',udefdata)-3,2) in (select lookupvalue from dba.lookupdata where lookupname = 'rcdh' 
	and lookuptext <> 'unknown')


-------- Update Remarks2 with GPN ------------ LOC/8/7/2012
update i
set remarks2 = substring(udefdata,13,8)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-EMP/%' and isnull(remarks2,'Unknown') = 'Unknown'

-------- Update Remarks1 with Trip Purpose ------- LOC 8/7/2012
update i
set remarks1 = substring(udefdata,13,2)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum and i.iatanum = 'preubs' 
and i.recordkey like '%HB6G-%' and udefdata like '.ACECRM-TRR/%' and remarks1 is null

-------- Update Remarks5 with Cost Center -------- LOC/8/7/2012
update i
set remarks5 = substring(udefdata,13,7)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%' and udefdata like '.ACECRM-COS/%' and remarks5 is null


update i
set remarks5 =  substring(udefdata,13,7)
from dba.invoicedetail i, dba.udef u
where i.recordkey = u.recordkey and i.seqnum = u.seqnum
and i.iatanum = 'preubs' and i.recordkey like '%HB6G-%' and udefdata like '.ACECRM-COS/%' 
and remarks5 <>substring(udefdata,13,7)
and substring(udefdata,13,7) in (select rollup8 from dba.rollup40 where costructid = 'functional' )



-------- Update Online booking type ----- LOC / 8/7/2012
update i
set onlinebookingsystem = 'Y'
from dba.invoicedetail i
where bookingagentid = '0VITN03'
and i.iatanum = 'preubs'
and i.recordkey like '%HB6G-%'

-------- Update Text 18 with Online Reason Code ------------------ LOC 8/7/12
update c
set text18 = substring(udefdata,13,2)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-CD4/%'
and substring(udefdata,13,2) in (select lookupvalue from dba.lookupdata where lookupname = 'olreasoncode')
and text18 is null


-------- Update Text 17 with TractID ------------------ LOC 8/7/12
update c
set text17 = substring(udefdata,13,7)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs'
and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-ORD/%'
and isnull(text17,'N/A')  = 'N/A'

-------- Update Text 8 with Booker GPN------------------ LOC 8/7/12
update c
set text8 = substring(udefdata,13,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-CD2/%' and text8 is null

-------- Update Text 14 with Approver GPN------------------ LOC 8/7/12
update c
set text14 = substring(udefdata,13,8)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%'
and udefdata like '.ACECRM-APP/%' and text14 is null

-------- Update Text 7 with Project Code------------------ LOC 8/7/12
update c
set text7 = substring(udefdata,13,20)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.ACECRM-PRJ/%' and text7 is null

-------- Update Text6 with T24 Flag ---- LOC/3/22/2013
update c
set text6 =  substring(udefdata,14,3)
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.ACECRM-MNGR/%' and text6 is null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Begin Update to Comrmks for Validation HB6G-%',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-----------------------------------------------------------------------------------
-------Update Text27 = TractID String --------------------------- LOC 8/7/2012
update c
set text27 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' And udefdata like 'acecrm-ord%' and text27 is null

-------Update Text25 = ReasonCode1  String --------------------------- LOC 8/7/2012
update c
set text25 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like'.acesv1-%' and text25 is null

-------Update Text23 = Trip Purpose  String --------------------------- LOC 8/7/2012
update c
set text23 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like'acecrm-trr/%' and text23 is null

-------Update Text22 = GPN  String --------------------------- LOC 8/7/2012
update c
set text22 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like 'acecrm-emp/%'
and text22 is null

-------Update Text24 = CostCenter  String --------------------------- LOC 8/7/2012
update c
set text24 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.acecrm-cos/%' and text24 is null

-------Update Text26 = Hotel Reason Code  String --------------------------- LOC 8/7/2012
update c
set text26 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%' and udefdata like '.acehot-pr-hot%' and text26 is null

------ Update Text 13 with Online Reason Code String ------------------ LOC 6/12/12
update c
set text13 = udefdata
from dba.comrmks c, dba.udef u
where c.recordkey = u.recordkey and c.seqnum = u.seqnum
and c.iatanum = 'preubs' and C.recordkey like '%HB6G-%'  and udefdata like '.acecrm-cd4%' and text13 is null

update ih
set origcountry = 'CL'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%HB6G%' 
and origcountry = 'CH'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CL') 

update ih
set origcountry = 'CO'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%HB6G%' and origcountry = 'CH'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'CO') 

update ih
set origcountry = 'PE'
from dba.invoiceheader ih, dba.invoicedetail id
where ih.iatanum = 'preubs' and ih.recordkey like '%HB6G%' and origcountry = 'CH'
and ih.recordkey = id.recordkey
and remarks2 in (select corporatestructure from dba.rollup40 where rollup12 = 'PE') 

-------- Update Text47 with Fare type -------- TT 10/10/2013 CASE#22652
update c
set text47= right(udefdata,2)
from dba.udef u, dba.comrmks c
where u.recordkey = c.recordkey and u.seqnum = c.seqnum
and u.iatanum = 'preubs'
and u.recordkey like '%HB6G%' and udefdata like '.acesv2-%' 
AND udefdata NOT LIKE '%*%' and text47 is null


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Stored Procedure End HB6G- ',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-------Comment out this per Case #16728 --------------------------- TBo 6/17/2013
EXEC sp_PRE_UBS_MAIN_Mini 

 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/ 












GO
