/****** Object:  StoredProcedure [dbo].[sp_YUMAXCC_Update]    Script Date: 7/14/2015 8:13:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_YUMAXCC_Update]
	
 AS
insert into dba.client
select distinct clientcode,iatanum,null,iatanum,null,null,null,null
,null,null,null,null,null,null,null,null,null,null,null,null
,null,null,null,null
from dba.ccheader
where iatanum ='YUMAXCC'
and clientcode+iatanum not in(select clientcode+iatanum
from dba.client
where iatanum ='YUMAXCC')
--set prugeind = W for records that were voided 
update t1
set t1.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t1.PurgeInd is null
and t1.iatanum ='YUMAXCC'
and t2.iatanum ='YUMAXCC'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))

update t2
set t2.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t2.PurgeInd is null
and t1.iatanum ='YUMAXCC'
and t2.iatanum ='YUMAXCC'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))

--BACKUP EID
update dba.CCHeader
set Remarks1 = EmployeeId
where IataNum = 'YUMAXCC'
and Remarks1 is null

--UPDATE BADIDs w/ID from agency where match
update cc
set cc.EmployeeId = cr.text1
from dba.CCHeader cc,dba.ComRmks cr
where cc.MatchedRecordKey = cr.RecordKey
and cc.MatchedIataNum = cr.IataNum
and cc.MatchedSeqNum = cr.SeqNum
and ISNULL(RIGHT('0000000000'+EmployeeID,10),'BAD') not in 
(select distinct RIGHT('0000000000'+employeeID1,10) from dba.employee where EmpEmail not like '%pep%')
and CC.IataNum = 'YUMAXCC'
--Default any not in Employee file
update dba.CCHeader
set EmployeeId = '999999999'
where ISNULL(RIGHT('0000000000'+EmployeeID,10),'BAD') not in 
(select distinct RIGHT('0000000000'+employeeID1,10) from dba.employee where EmpEmail not like '%pep%')
and IataNum = 'YUMAXCC'


update ch
set ch.remarks2 = em.costcenter
from dba.CCHeader ch, dba.employee em
where ch.Remarks1 = em.EmployeeID1
and ch.Remarks2 is null
and ch.IataNum = 'YUMAXCC'
and em.EmpEmail like '%@yum.com'

update ch
set ch.remarks2 = 'Not Provided'
from dba.CCHeader ch
where ch.Remarks2 is null
and ch.IataNum = 'YUMAXCC'
GO
