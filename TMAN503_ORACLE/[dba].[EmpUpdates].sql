/****** Object:  StoredProcedure [dba].[EmpUpdates]    Script Date: 7/14/2015 8:12:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dba.EmpUpdates
as
update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text20 = text9
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text20 is null

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text9 = '9999999999',
text26 = 'UPDATED'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text9 is null

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text9 = '9999999999',
text26 = 'UPDATED'
from ttxpasql01.TMAN503_Oracle.dba.comrmks
where iatanum = 'ORGDR'
and issuedate > '2012-01-01' 
and text9 <> '9999999999'
and RIGHT('000000000000000'+text9,15) not in (select RIGHT('000000000000000'+globalemployeeid,15) from ttxpasql01.TMAN503_Oracle.dba.employee)


update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text22 = text2
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text22 is null
 
update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text2 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text2 is null
 
update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text2 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text2 <> 'UNKNOWN'
and text2 not in (select distinct lineofbusiness from ttxpasql01.TMAN503_Oracle.dba.employee)
 
update cr
set cr.text2 = em.lineofbusiness,
cr.text26 = 'UPDATED'
from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text2 = 'UNKNOWN'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  ttxpasql01.TMAN503_Oracle.dba.comrmks
set text2 = NULL
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text2 = 'UNKNOWN'

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text23 = text3
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text23 is null
 
update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text3 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text3 is null 

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text3 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and Right('0000'+text3,4) not in (select distinct costcenter from ttxpasql01.TMAN503_Oracle.dba.employee)
and Text3 <> 'UNKNOWN'


update cr
set cr.text3 = em.costcenter,
cr.text26 = 'UPDATED'
from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text3 = 'UNKNOWN'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  ttxpasql01.TMAN503_Oracle.dba.comrmks
set text3 = NULL
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text3 = 'UNKNOWN'

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text24 = text4
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text24 is null

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text4 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text4 is null

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text4 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text4 <> 'UNKNOWN'
and RIGHT('000000'+text4,6) not in (select distinct employeeid from ttxpasql01.TMAN503_Oracle.dba.employee)


update cr
set cr.text4 = em.employeeid,
cr.text26 = 'UPDATED'
from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text4 = 'UNKNOWN'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  ttxpasql01.TMAN503_Oracle.dba.comrmks
set text4 = NULL
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text4 = 'UNKNOWN'

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text25 = text7
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text25 is null

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text7 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text7 is null

update ttxpasql01.TMAN503_Oracle.dba.comrmks
set text7 = 'UNKNOWN'
where iatanum = 'ORGDR'
and issuedate > '2012-01-01'
and text7 not in (select distinct MLevel from ttxpasql01.TMAN503_Oracle.dba.employee)
and Text7 <> 'UNKNOWN'


update cr
set cr.text7 = em.MLevel,
cr.text26 = 'UPDATED'
from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
where cr.iatanum = 'ORGDR'
and cr.issuedate > '2012-01-01'
and cr.text7 = 'UNKNOWN'
and RIGHT('000000000000000'+text9,15) = RIGHT('000000000000000'+em.globalemployeeid,15)

update  ttxpasql01.TMAN503_Oracle.dba.comrmks
set text7 = NULL
where iatanum = 'ORGDR'
and issuedate > '2009-12-31'
and text7 = 'UNKNOWN'
--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text20 = text9
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text20 is null

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text9 = '9999999999',
--text26 = 'UPDATED'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text9 is null

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text9 = '9999999999',
--text26 = 'UPDATED'
--from ttxpasql01.TMAN503_Oracle.dba.comrmks
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01' 
--and text9 <> '9999999999'
--and RIGHT('000000000000000'+text9,15) not in (select RIGHT('000000000000000'+globalemployeeid,15) 
--from ttxpasql01.TMAN503_Oracle.dba.employee)


--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text22 = text2
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text22 is null
 
--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text2 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text2 is null
 
--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text2 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text2 <> 'UNKNOWN'
--and text2 not in (select distinct lineofbusiness from ttxpasql01.TMAN503_Oracle.dba.employee)
 
--update cr
--set cr.text2 = em.lineofbusiness,
--cr.text26 = 'UPDATED'
--from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
--where cr.iatanum = 'ORGDR'
--and cr.issuedate > '2012-01-01'
--and cr.text2 = 'UNKNOWN'
--and cr.text9 = em.globalemployeeid

--update  ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text2 = NULL
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text2 = 'UNKNOWN'

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text23 = text3
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text23 is null
 
--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text3 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text3 is null 

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text3 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and Right('0000'+text3,4) not in (select distinct costcenter from ttxpasql01.TMAN503_Oracle.dba.employee)
--and Text3 <> 'UNKNOWN'


--update cr
--set cr.text3 = em.costcenter,
--cr.text26 = 'UPDATED'
--from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
--where cr.iatanum = 'ORGDR'
--and cr.issuedate > '2012-01-01'
--and cr.text3 = 'UNKNOWN'
--and cr.text9 = em.globalemployeeid

--update  ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text3 = NULL
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text3 = 'UNKNOWN'

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text24 = text4
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text24 is null

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text4 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text4 is null

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text4 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text4 <> 'UNKNOWN'
--and RIGHT('000000'+text4,6) not in (select distinct employeeid from ttxpasql01.TMAN503_Oracle.dba.employee)


--update cr
--set cr.text4 = em.employeeid,
--cr.text26 = 'UPDATED'
--from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
--where cr.iatanum = 'ORGDR'
--and cr.issuedate > '2012-01-01'
--and cr.text4 = 'UNKNOWN'
--and cr.text9 = em.globalemployeeid

--update  ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text4 = NULL
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text4 = 'UNKNOWN'

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text25 = text7
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text25 is null

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text7 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text7 is null

--update ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text7 = 'UNKNOWN'
--where iatanum = 'ORGDR'
--and issuedate > '2012-01-01'
--and text7 not in (select distinct MLevel from ttxpasql01.TMAN503_Oracle.dba.employee)
--and Text7 <> 'UNKNOWN'


--update cr
--set cr.text7 = em.MLevel,
--cr.text26 = 'UPDATED'
--from ttxpasql01.TMAN503_Oracle.dba.comrmks cr, ttxpasql01.TMAN503_Oracle.dba.employee em
--where cr.iatanum = 'ORGDR'
--and cr.issuedate > '2012-01-01'
--and cr.text7 = 'UNKNOWN'
--and cr.text9 = em.globalemployeeid

--update  ttxpasql01.TMAN503_Oracle.dba.comrmks
--set text7 = NULL
--where iatanum = 'ORGDR'
--and issuedate > '2009-12-31'
--and text7 = 'UNKNOWN'


GO
