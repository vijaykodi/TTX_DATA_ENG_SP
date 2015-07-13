select distinct vendortype
select *
from dba.invoicedetail
where vendortype like '%ST%'
and iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'



delete dba.invoicedetail
where vendortype like '%ST%'
and iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'
and seqnum > 999

delete dba.transeg
where iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'
and seqnum > 999

delete dba.payment
where iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'
and seqnum > 999

delete dba.tax
where iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'
and seqnum > 999

update dba.invoicedetail
set vendortype = 'BSP'
where vendortype like 'BSPSTC'
and iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'

update dba.invoicedetail
set vendortype = 'NONBSP'
where vendortype like 'NONBSPSTC'
and iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'

update dba.invoicedetail
set vendortype = 'RAIL'
where vendortype like 'RAILST%'
and iatanum ='APAX'
and issuedate between '2014-01-01' and '2014-09-14'