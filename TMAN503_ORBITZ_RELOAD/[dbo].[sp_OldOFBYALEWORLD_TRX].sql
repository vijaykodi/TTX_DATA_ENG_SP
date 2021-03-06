/****** Object:  StoredProcedure [dbo].[sp_OldOFBYALEWORLD_TRX]    Script Date: 7/14/2015 8:13:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_OldOFBYALEWORLD_TRX]
	@BeginIssueDate       	datetime,
	@EndIssueDate		datetime

AS

update cr
set 
cr.text1 = 'UNKNOWN',
cr.text2 = 'UNKNOWN',
cr.text3 = 'UNKNOWN',
cr.text4 = 'UNKNOWN',
cr.text5 = 'UNKNOWN',
cr.text6 = 'UNKNOWN',
cr.text7 = 'UNKNOWN',
cr.text8 = 'UNKNOWN',
cr.text9 = 'UNKNOWN',
cr.text50 = 'UNKNOWN',
cr.text49 = 'UNKNOWN'
from dba.comrmks cr
where cr.iatanum = 'OFBWORLD'
and cr.text1 is null
and cr.issuedate between @BeginIssueDate and @EndIssueDate

--select hr.cost_center_1 as "TR1_Text1",hr.cost_center_2 as "TR2_Text2",hr.cost_center_3 as "TR3_text3"
--,hr.cost_center_4 as "TR4_text4",hr.Cost_Center_5 as "TR5_text5",'Not Found' as "TR6_Text6",'Not Found'as "TR7_Text7",hr.authorizer_emails as "TR8_Text8"
--,'Not Found' as "TR9_Text9",hr.email as "Text56", hr.Policy_APPR_EMAILS as "Text55"
update cr
set
cr.text1 = substring(hr.cost_center_1,1,150),
cr.text2 = substring(hr.cost_center_2,1,150),
cr.text3 = substring(hr.cost_center_3,1,150),
cr.text4 = substring(hr.cost_center_4,1,150),
cr.text5 = substring(hr.Cost_Center_5,1,150),
cr.text6 = 'Not Found',
cr.text7 = 'Not Found',
cr.text8 = substring(hr.authorizer_emails,1,150),
cr.text9 = 'Not Found',
cr.text50 = substring(hr.email,1,150),
cr.text49 = substring(hr.Policy_APPR_EMAILS,1,150)
from dba.udef ud, dba.comrmks cr, dba.Yale_HR_Data_full hr
where ud.recordkey = cr.recordkey
and ud.iatanum = cr.iatanum
and ud.seqnum = cr.seqnum
and ud.iatanum = 'ofbworld'
and ud.udefnum = '46'
and ud.udefdata = hr.cost_center_5
and cr.text1 = 'UNKNOWN'
and cr.issuedate between @BeginIssueDate and @EndIssueDate

GO
