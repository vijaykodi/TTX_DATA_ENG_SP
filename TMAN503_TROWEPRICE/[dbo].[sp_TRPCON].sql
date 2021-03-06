/****** Object:  StoredProcedure [dbo].[sp_TRPCON]    Script Date: 7/14/2015 8:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_TRPCON]
	
 AS

/* Created by Nina on 7/24/14 to map expense data in order to report correctly. */

update eh
set eh.Remarks1 = ed.RemarksEmp_Org1 
,eh.Remarks2 = ed.RemarksEmp_Org2 
,eh.Remarks3 = ed.RemarksEmp_Org3 
,eh.Remarks4 = ed.RemarksEmp_Org4 
,eh.Remarks5 = ed.RemarksEmp_Org5 
,eh.Remarks6 = ed.RemarksEmp_Org6 
from dba.ExpenseReportDetail ed, dba.ExpenseReportHeader eh 
where ed.ExpReportID = eh.ExpReportID 
--and eh.SrcSystemRef = 'ConcurSAE' 
and eh.ExpIataNum in ('TRPCON2','TRPCON')
and (eh.Remarks1 = '' or eh.Remarks1 is null)

update dba.ExpenseReportDetail
set ExpenseType = TransactionType
where TransactionType not in ('CHD','REG')
and ExpenseType is null
GO
