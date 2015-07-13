
SELECT iatanum,YEAR(ID.issuedate),MONTH(ID.issuedate),substring(convert(char(12),ID.issuedate,100),1,3)
       ,count(*) 
  FROM DBA.invoicedetail ID
 where issuedate BETWEEN { d '2011-01-01' } AND { d '2014-12-31' }
 and ID.vendortype like '%ST%'
group by iatanum,YEAR(ID.issuedate),MONTH(ID.issuedate),substring(convert(char(12),ID.issuedate,100),1,3)
order by 1,2,3