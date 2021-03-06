/****** Object:  StoredProcedure [dbo].[sp_UBS_CATERING]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UBS_CATERING]

as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

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
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start CATERING',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update catering policy from other policy fields case#26948 kp

update dba.CATERING
set CATERINGPOLICY = CateringPolicy400
WHERE isnull(CateringPolicy,'') = ''
AND CATERINGPOLICY400 IS NOT NULL

update dba.CATERING
set CATERINGPOLICY = CateringPolicyCHI
WHERE isnull(CateringPolicy,'') =''
AND CATERINGPOLICYCHI IS NOT NULL

update dba.CATERING
set CATERINGPOLICY = CateringPolicyJC
WHERE isnull(CateringPolicy,'') = ''
AND CateringPolicyJC IS NOT NULL

update dba.CATERING
set CATERINGPOLICY = CateringPolicyNY
WHERE isnull(CateringPolicy,'') = ''
AND CateringPolicyNY IS NOT NULL


update dba.CATERING
set CATERINGPOLICY = CateringPolicyWH
WHERE isnull(CateringPolicy,'') =''
AND CateringPolicyWH IS NOT NULL

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Catering Policy Update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update catering appr signature from other signature fields case#26948 kp

update dba.CATERING
set CateringApprovalSignature = CateringApprovalSignature400
WHERE isnull(CateringApprovalSignature,'')=''
AND CateringApprovalSignature400 IS NOT NULL

update dba.CATERING
set CateringApprovalSignature = CateringApprovalSignatureCHI
WHERE isnull(CateringApprovalSignature,'')=''
AND CateringApprovalSignatureCHI IS NOT NULL

update dba.CATERING
set CateringApprovalSignature = CateringApprovalSignatureJC
WHERE isnull(CateringApprovalSignature,'')=''
AND CateringApprovalSignatureJC IS NOT NULL

update dba.CATERING
set CateringApprovalSignature = CateringApprovalSignatureNY
WHERE isnull(CateringApprovalSignature,'')=''
AND CateringApprovalSignatureNY IS NOT NULL


update dba.CATERING
set CateringApprovalSignature = CateringApprovalSignatureWH
WHERE isnull(CateringApprovalSignature,'')=''
AND CateringApprovalSignatureWH IS NOT NULL

update dba.CATERING
set CateringApprovalSignature = NULL
WHERE CateringApprovalSignature=''


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3-Catering Appr Sign Update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update catering client recruit name from other recruit name fields case#26948 kp


update dba.CATERING
set ClientRecruitname = ClientRecruitname400
WHERE isnull(ClientRecruitName,'')=''
AND ClientRecruitName400 IS NOT NULL

update dba.CATERING
set ClientRecruitname = ClientRecruitnameCHI
WHERE isnull(ClientRecruitName,'')=''
AND ClientRecruitnameCHI IS NOT NULL

update dba.CATERING
set ClientRecruitname = ClientRecruitnameJC
WHERE isnull(ClientRecruitName,'')=''
AND ClientRecruitnameJC IS NOT NULL

update dba.CATERING
set ClientRecruitname = ClientRecruitnameNY
WHERE isnull(ClientRecruitName,'')=''
AND ClientRecruitnameNY IS NOT NULL


update dba.CATERING
set ClientRecruitname = ClientRecruitnameWH
WHERE isnull(ClientRecruitName,'')=''
AND ClientRecruitnameWH IS NOT NULL


------------------------------------------------------------------
-------- Update MeetinghostGPN to unknown where null or not in rollup40 --------
update dba.catering
set MeetingHostGPN = 'Unknown'
where MeetingHostGPN is Null

update dba.catering
set MeetingHostGPN = 'Unknown'
where MeetingHostGPN not in (select corporatestructure from dba.rollup40 where costructid = 'functional')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-Catering Client Recruit Name Update',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--------Update Cost Center Split to cost Center -- per Mike G 3/17/2014
update dba.catering
set paymenttype = 'Cost Center'
where paymenttype = 'Cost Center Split'

--------Update Credit Card Split to Credit Card -- per Jeremy G 3/24/2014
update dba.catering
set paymenttype = 'Cost Center'
where paymenttype = 'Cost Center Split'

-------- Update different paymenttype that are coming across ---- LOC/3/24/2014
------- We will be leaving 2013 as Credit Card however 2014 will be coming in as Personal / Business as 2 
---- seperate types .. when we put in any updates we need to make sure to leave 2013 as is..LOC/3/24/2014
--4/8/2014 added booking date as prev nothing to limit to 2014 if re-load is done
--#34744 change mapping orig to Credit Card to be 'Credit Card - Corporate' 4/9/2014 KP
--('Credit Card Split', 'Credit Card/ Cost Center Split', 'Credit Card/Cost Center Split')

update dba.catering
set paymenttype = 'Credit Card - Corporate'
where paymenttype = 'Credit Card Split'
and BookingDate>='2014-01-01'

update dba.catering
set paymenttype = 'Credit Card - Corporate'
where paymenttype = 'Credit Card/ Cost Center Split'
and BookingDate>='2014-01-01'

update dba.catering
set paymenttype = 'Credit Card - Corporate'
where paymenttype = 'Credit Card/Cost Center Split'
and BookingDate>='2014-01-01'

update dba.catering
set paymenttype='Credit Card - Corporate'
where paymenttype='Credit Card'
and BookingDate>='2014-01-01'

update dba.catering
set paymenttype='Credit Card - Corporate'
where paymenttype='Credit Card - Corporate (UBS)'
and BookingDate>='2014-01-01'

update dba.catering
set paymenttype = 'Cost Center'
where paymenttype in ('Cash','Check')
and BookingDate>='2014-01-01'

update dba.catering
set paymenttype = 'Client Chargeback'
where paymenttype = 'Opportunity Code'
and BookingDate>='2014-01-01'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6-PaymentType Updates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---service  updates Case #32752 3/13/2014 KP

update dba.catering
set Service='Breakfast'
where service='AM Break'


update dba.catering
set Service='Snack Service'
where service='cake'


update dba.catering
set Service='Snack Service'
where service='Delivery/Pick Up'


update dba.catering
set Service='Snack Service'
where service='Delivery/PickUp'

update dba.catering
set Service='Snack Service'
where service='Disposables'

update dba.catering
set Service='Linen'
where service='Linen Service'

update dba.catering
set Service='Beverage Order'
where service='Pantry'

update dba.catering
set Service='Lunch'
where service='Vouchers'


-------- Update Floor to only be the number ------- per email from Mike G. 4/2/2014..LOC
update dba.catering
set floor = case when floor like '%th Floor' then replace(floor,'th floor','')
when floor like '%nd Floor' then  replace(floor,'nd floor','')
when floor like '%st Floor' then  replace(floor,'st floor','') 
when floor like '%rd Floor' then  replace(floor,'rd floor','')
when floor like 'grou' then '1'
else floor end


-------- Update Meeting Host Name where meeting Host is Robert McCann per email from Mike 5/1/2014...LOC
update dba.catering 
set meetinghost = 'Office of the Regional CEO'
where meetinghost like '%mccann%robert%'

--BookingEventType updates #26947  code below if needed if historical data is re loaded

--update dba.catering
--set BookingEventType=
--case when bookingeventtype 
--in ('Food Service - External Client','Food Service- Client Mtg')
--then 'Food Service - Client'
--when bookingeventtype IN('Food Service- Consultant Mtg') 
--then 'Food Service - Consultant'
--when bookingeventtype IN('Food Service- Internal Mtg','Internal Meeting','MD Buffet','Pantry Order')
--then 'Food Service - Internal'
--when bookingeventtype IN('Food Service - Recruiting','Food Service- Recruiting Mtg')
--then 'Food Service - Recruitment Ext'
--when bookingeventtype IN('Food Service- Vendor Mtg')
--then 'Food Service - Vendor'
--when bookingeventtype IN('Reception - Client','Reception- Client Mtg')
--then 'Function - Client'
--when bookingeventtype IN('Reception - Consultant','Reception- Consultant Mtg')
--then 'Function - Consultant'
--when bookingeventtype IN('Reception - Internal','Reception- Internal Mtg')
--then 'Function - Internal'
--when bookingeventtype IN('Reception - Recruiting','Reception- Recruiting Mtg')
--then 'Function - Recruitment'
--when bookingeventtype IN('Reception- Vendor Mtg')
--then 'Function - Vendor'
--when bookingeventtype IN('Client Meeting','Training (Client)')
--then 'Meeting - Client/External'
--when bookingeventtype IN('Consultant Meeting')
--then 'Meeting - Consultant'
--when bookingeventtype IN('EXTERNAL TENNANT','Internal Meeting','Training (Internal)')
--then 'Meeting - Internal'
--when bookingeventtype IN ('Recruiting Meeting')
--then 'Meeting - Recruitment Ext'
--when bookingeventtype IN ('Recruiting - Meeting')
--then 'Meeting - Recruitment Int'
--when bookingeventtype IN ('Vendor Meeting')
--then 'Meeting - Vendor'
--when bookingeventtype IN ('AV Loan')
--then 'Other - AV Loan'
--when bookingeventtype IN ('EDR')
--then 'Other - EDR'
--when bookingeventtype IN ('LR')
--then 'Other - LR'
--when bookingeventtype IN ('Facilities Set-up','Maintenance')
--then 'Other - Maintenance/Out of Use'
--when bookingeventtype IN ('TV')
--then 'Other - Media - TV/Press/Photo'
--when bookingeventtype IN ('Office Space')
--then 'Other - Office Space'
--when bookingeventtype IN ('Storage')
--then 'Other - Storage'
--when bookingeventtype IN ('Telepresence - Client','Telepresence- Client Mtg',
--'VC- Client Mtg','Video Conference - Client','Videoconference - Client')
--then 'Video - Client'
--when bookingeventtype IN ('Telepresence - Consultant','Telepresence- Consultant Mtg',
--'VC- Consultant Mtg','Video Conference - Consultant','Videoconference - Consultant')
--then'Video - Consultant'
--when bookingeventtype IN ('Telepresence - Internal','Telepresence- Internal Mtg',
--'VC- Internal Mtg','Video Conference - Internal','Videoconference - Internal')
--then 'Video - Internal'
--when bookingeventtype IN ('Telepresence - Recruiting','Telepresence- Recruiting Mtg',
--'VC- Recruiting Mtg','Video Conference - Recruiting','Videoconference - Recruiting')
--then 'Video - Recruitment Ext'
--when bookingeventtype IN ('Telepresence - Vendor','Telepresence- Vendor Mtg',
--'VC- Vendor Mtg','Video Conference - Vendor','Videoconference - Vendor')
--then 'Video - Vendor'
--else bookingeventtype end


-----Eventstart and evenend need to be in standard AM / PM format below formula converts 2400 to a.m.
--if it is needed 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  


GO
