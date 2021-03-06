/****** Object:  StoredProcedure [dbo].[sp_PREHGP_Main_Post_Import_Update_HNN]    Script Date: 7/14/2015 8:10:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PREHGP_Main_Post_Import_Update_HNN]
@RequestName varchar(50) --For DEA
as

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'PREHGP'--update IataNum
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start RC5-',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Wyndham Jade Updates -----------------------------------------------------------
-------- Update Client Table --------------------------------------
insert Into dba.client
select DISTINCT id.clientcode,'PREHGP','Wyndham Jade',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue  and lookuptext = 'Wyndham Jade'
and ih.BackOfficeID in ('L850','KK70','6L31','9LD2','J495') 
and ih.iatanum = 'PREHGP' 
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Wyndham Jade')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '60010','Wyndham Jade',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '60010' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('L850','KK70','6L31','9LD2','J495')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- TS24 Upates --------------------------------------------------
-------- Update Client Table --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','TS24',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'TS24'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'TS24')
and ih.BackOfficeID in ('0GH7','X8D4','3DCB','G965','6Z2C','DS07','6WAF','0XTF','CMH1S211T','KA0C','1TN6','15QN','F2HH','W0RA')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '80540','TS24',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '80540' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('0GH7','X8D4','3DCB','G965','6Z2C','DS07','6WAF','0XTF','CMH1S211T','KA0C','1TN6','15QN','F2HH','W0RA')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- World Travel Service Updates --------------------------------
-------- Update Client Table --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','World Travel Service',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'World Travel Service'
and ih.BackOfficeID in ('550','230','0ZA','1EB','2BS','2VH','3DK','3y4','57K','59T','5HV','5TL','63D','7CD','7DR','7SR','7TP',
'7UU','7X1','85T','86F','89T','8CI','9HB','9HU','9NW','9TI','FJY','G7G','IPM','JJ5','K8M','L3P','M8S','O08','RXT','T67','T8P','Z6V','7IA','H86')
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'World Travel Service')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '60000','World Travel Service',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '60000' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('550','230','0ZA','1EB','2BS','2VH','3DK','3y4','57K','59T','5HV','5TL','63D','7CD','7DR','7SR','7TP',
'7UU','7X1','85T','86F','89T','8CI','9HB','9HU','9NW','9TI','FJY','G7G','IPM','JJ5','K8M','L3P','M8S','O08','RXT','T67','T8P','Z6V','7IA','H86')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- Campbell Travel Services Updates -----------------------------
-------- Update Client Table --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Campbell Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Campbell Travel'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Campbell Travel')
and ih.BackOfficeID in ('03NA','03QA','03RA','1BRB','1RI7','4JMF','4JOF','4JPF','4JQF','4Z4B','WL8A','WU9A','WU8A',
'WR2A','U430','S23B','S22B','R22B','OE5A','GM80','FS2A','6ZM1','3IGA','1JM4','Z9BB')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '59237','Campbell Travel Services',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '59237' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('03NA','03QA','03RA','1BRB','1RI7','4JMF','4JOF','4JPF','4JQF','4Z4B','WL8A','WU9A','WU8A',
'WR2A','U430','S23B','S22B','R22B','OE5A','GM80','FS2A','6ZM1','3IGA','1JM4','Z9BB')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

---------------------------------------------------------------------------------------------------------------------------
-------- Commenting out info for Caldwell as they are no longer a cliet of Hickory as of 9/17/2014 -----------------------
-------- Caldwell Travel Updates ----------------------------------------
-------- Update Client Table --------------------------------------
--insert into dba.client
--select DISTINCT id.clientcode,'PREHGP','Caldwell Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
--from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
--where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
--and ih.backofficeid = lookupvalue and lookuptext = 'Caldwell Travel'
--and ih.iatanum = 'PREHGP'
--and  id.clientcode not in ( select clientcode from dba.client where custname = 'Caldwell Travel')
--and ih.BackOfficeID in ('3Q32','C7F0','F7L0','P6U0','R26B')

---------- Update lookup with Agent Signes
--Insert into dba.agentname
--select distinct '90020','Caldwell Travel',i.bookingagentid, i.bookingagentid, getdate()
--from dba.invoicedetail i, dba.invoiceheader ih
--where i.bookingagentid not in (select bkgAgentid 
--	from dba.agentname where cid = '90020' )
--and i.recordkey = ih.recordkey 
--and ih.BackOfficeID in ('3Q32','C7F0','F7L0','P6U0','R26B')
--and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- Atlas Travel Updates --------------------------------------
-------- Update Client Table--------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Atlas Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Atlas Travel'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Atlas Travel')
and ih.BackOfficeID in ('C8FC','E8JC','M45B','TL7A','3SDB','5J82','6RT0','7VZA','8CIC','BOS1S210G','WLM1S2100')

-------- Plaza Travel Updates ------------------------------------------
-------- Update Client Table --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Plaza Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Plaza Travel'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Plaza Travel')
and ih.BackOfficeID in ('0REA','R9TG','F379','V5CF','SB6G','RQ0','TV3','JB0','1QH1','1XG0','5UVG','FU4H')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '73570','Plaza Travel',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '73570' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('0REA','R9TG','F379','V5CF','SB6G','RQ0','TV3','JB0','1QH1','1XG0','5UVG','FU4H')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- Fox World Travel Updates ------------------------------------
-------- Update Cust Names --------------------------------------
--Added on 3/28/13 by Nina per case #00013067
-------- Terminated as of 5/31/2014....LOC/Case 39030
--insert into dba.client
--select DISTINCT id.clientcode,'PREHGP','Fox World Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
--from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
--where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
--and ih.backofficeid = lookupvalue and lookuptext = 'Fox World Travel'
--and ih.iatanum = 'PREHGP'
--and  id.clientcode not in ( select clientcode from dba.client where custname = 'Fox World Travel')
--and ih.BackOfficeID in ('GO3','DF5','DB9','18VF', '10MN', '146L', '136T', '15XX', '2D09', 
--'C3D', '1X4Z', '13OY', 'T9N', '1TS0', 'W8S', '8TG', '1HH', 'NU9', 'JR2', 
-- 'MY2', '46P', '100T', '1TN9', '137J', '1CF2', '1Z7J', 'NX4','1CF0', '5U3')

---------- Update lookup with Agent Signes
--Insert into dba.agentname
--select distinct '75140','Fox World Travel',i.bookingagentid, i.bookingagentid, getdate()
--from dba.invoicedetail i, dba.invoiceheader ih
--where i.bookingagentid not in (select bkgAgentid 
--	from dba.agentname where cid = '75140' )
--and i.recordkey = ih.recordkey 
--and ih.BackOfficeID in ('GO3','DF5','DB9','18VF', '10MN', '146L', '136T', '15XX', '2D09', 
--'C3D', '1X4Z', '13OY', 'T9N', '1TS0', 'W8S', '8TG', '1HH', 'NU9', 'JR2', 
-- 'MY2', '46P', '100T', '1TN9', '137J', '1CF2', '1Z7J', 'NX4','1CF0', '5U3')
--and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- HMHF Updates ---------------------------------------
-------- Update Cust Names --------------------------------------
 --Added on 7/26/13 by Nina per Case #00018608
 --Added BackOfficeID of U6S on 8/14/13 per case #00018608
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','HMHF',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'HMHF'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'HMHF')
and ih.BackOfficeID in ('BYF','U6S')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '47170','HMHF',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '47170' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('BYF','U6S')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- The Travel Team Updates ---------------------------------------
-------- Update Cust Names --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','The Travel Team',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'The Travel Team'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'The Travel Team')
and ih.BackOfficeID in ('2R7X','2C2U') 

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '12345','The Travel Team',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '12345' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('2R7X','2C2U') 
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- CTM Updates ------------------------------------------
-------- Update Cust Names --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','CTM',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'CTM'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'CTM')
and ih.iatanum = 'PREHGP'and ih.BackOfficeID in ('C3P','1KT4','24II','18J9','1DF7','1X4J','1P4I',
'18K8','11K8','18J4', '18J5','1DE7','1DE8','18J6','1DF6','18J8','18J7','18K1','18K2','18K4', 
'18K6','1KO3','1HC4','1KR0','1NL0','1PS1','1SD6','1UL1','1UM2','1X4P', '1Y2I','1Y2M','1X4S','1LM9','1Y1R',
'24IH','18K3','1DD8','1DE1','1FS8', '18K5','1KB9','1Y1J','24IJ','1Y2G','148F','F42A','M3M4','H24F','3X2F', 
'QA5F','J4I0','82P0','SY02','N4WA','VK2A','FM2','76HG','Z2EH','84JF','Z5P5','PO0H','PY5H','QY7H','RC9H',
'25ZF','C9K2','G2YG','F0GG','F7RG','Z6XG','FU6H','26CF','F7MG','F0HG','P3FC','N1OG','5CWG','1TP2','TO8B')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '84690','CTM',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '84690' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('C3P','1KT4','24II','18J9','1DF7','1X4J','1P4I',
'18K8','11K8','18J4', '18J5','1DE7','1DE8','18J6','1DF6','18J8','18J7','18K1','18K2','18K4', 
'18K6','1KO3','1HC4','1KR0','1NL0','1PS1','1SD6','1UL1','1UM2','1X4P', '1Y2I','1Y2M','1X4S','1LM9','1Y1R',
'24IH','18K3','1DD8','1DE1','1FS8', '18K5','1KB9','1Y1J','24IJ','1Y2G','148F','F42A','M3M4','H24F','3X2F', 
'QA5F','J4I0','82P0','SY02','N4WA','VK2A','FM2','76HG','Z2EH','84JF','Z5P5','PO0H','PY5H','QY7H','RC9H',
'25ZF','C9K2','G2YG','F0GG','F7RG','Z6XG','FU6H','26CF','F7MG','F0HG','P3FC','N1OG','5CWG','1TP2','TO8B')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- A&I Updaetes ---------------------------------------
-------- Update Client Table --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','A&I',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'A&I'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'A&I')
and ih.BackOfficeID in ('X7Q','6S2','7ZO','UQM','S8W')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '85290','A&I',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '85290' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('X7Q','6S2','7ZO','UQM','S8W')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- Cassis Updates -----------------------------------------
-------- Update Cust Names --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Cassis',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Cassis'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Cassis')
and ih.BackOfficeID in ('78B1','GJ4A','4XG2','G543','C20G','Z5MG','AU7G')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '87090','Cassis',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '87090' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('78B1','GJ4A','4XG2','G543','C20G','Z5MG','AU7G')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- Tower Travel Updates -----------------------------------------
-------- Update Cust Names --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Tower Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Tower Travel'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Tower Travel')
and ih.BackOfficeID in ('SS8','AL5','75Z1','84M9','KW29')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '67890','Tower Travel',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '67890' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('SS8','AL5','75Z1','84M9','KW29')
and ih.iatanum = 'PREHGP' and bookingagentid is not null

-------- Hess Travel Updates -----------------------------------------
-------- Update Cust Names --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Hess Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Hess Travel'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Hess Travel')
and ih.BackOfficeID in ('N9P','Z65','QH8','03M','312','I8A','LE8','YF6')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '87654','Hess Travel',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '87654' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('N9P','Z65','QH8','03M','312','I8A','LE8','YF6')
and ih.iatanum = 'PREHGP' and bookingagentid is not null



-------- Travel Management Partners Updates ---------------------- case number: 51809
-------- Update Client Table --------------------------------------
insert Into dba.client
select DISTINCT id.clientcode,'PREHGP','Travel Management Partners',id.clientcode,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue  and lookuptext = 'Travel Management Partners'
and ih.BackOfficeID in ('1RF0','1WI9','1TG0','17EE','1A7Y','10EE','18QZ','2U8Z','1RL0','1RL2','1L20','17PU','1OX7') 
and ih.iatanum = 'PREHGP' 
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Travel Management Partners')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '54321','Travel Management Partners',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '54321' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('1RF0','1WI9','1TG0','17EE','1A7Y','10EE','18QZ','2U8Z','1RL0','1RL2','1L20','17PU','1OX7')
and ih.iatanum = 'PREHGP' and bookingagentid is not null


-------- Hickory General Updates ------------------------------------------
-------- Update Cust Names --------------------------------------
insert into dba.client
select DISTINCT id.clientcode,'PREHGP','Hickory Travel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL  
from dba.invoicedetail id, dba.lookupdata lu, dba.invoiceheader ih
where lu.lookupname = 'PCC' and id.recordkey = ih.recordkey
and ih.backofficeid = lookupvalue and lookuptext = 'Hickory Travel'
and ih.iatanum = 'PREHGP'
and  id.clientcode not in ( select clientcode from dba.client where custname = 'Hickory Travel')
and ih.BackOfficeID in ('HI70')

-------- Update lookup with Agent Signes
Insert into dba.agentname
select distinct '11111','Hickory Travel',i.bookingagentid, i.bookingagentid, getdate()
from dba.invoicedetail i, dba.invoiceheader ih
where i.bookingagentid not in (select bkgAgentid 
	from dba.agentname where cid = '11111' )
and i.recordkey = ih.recordkey 
and ih.BackOfficeID in ('HI70')
and ih.iatanum = 'PREHGP' and bookingagentid is not null


--------------------------------------------------------------------------------------------------------------------------
----**** Updateing Car only Transactions so that the Car Pickup location appears in the routing so that the field
-------- is not null in the Attachment Rate reports ----- LOC/8/15/2014

update i
set routing = carcitycode + ' - ' + Carcityname
from dba.invoicedetail i, dba.car c
where producttype = 'Car'
and i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.recordkey not in (select recordkey from dba.hotel)
and i.recordkey not in (select recordkey from dba.transeg)
and routing is NULL
and i.invoicedate > '1-1-2013'

--------------------------------------------------------------------------------------------------------------------------

---**************************************************************************************************
-------- Commenting out --- See new code below to pull from the full string of data in the UDEF field
-------- LOC/Nina /7/15/2014
 --Added on 1/17/13 by Nina per Case #00007797
 --Changed on 7/26/13 to use Remarks3 for Worldspan
 --Updated by Nina per case 00018341
--UPDATE htl
--SET htl.HtlRateCat = htl.RoomType
--from dba.Hotel htl where htl.Remarks3 = 'W' and htl.iatanum = 'PREHGP' and LEN(htl.RoomType) = 3 and htl.HtlRateCat is NULL
 
 --Added on 1/17/13 by Nina per Case #00007797
 --Changed on 7/26/13 to use Remarks3 for Worldspan
 --Updated by Nina per case 00018341
--UPDATE htl
--SET htl.HtlRateCat = SUBSTRING(htl.RoomType,4,10)
--from dba.Hotel htl, dba.Client cl where htl.Remarks3 = 'W' and htl.iatanum = 'PREHGP' and LEN(htl.RoomType) > 3 and htl.HtlRateCat is NULL

 --Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.RoomType = SUBSTRING(htl.RoomType,1,3)
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
--and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP' and LEN(htl.RoomType) > 3

-------- Pulling the HtlRate Category from the udef -- WorldSpan Only--------------
------- Commenting out the "in" statement so even the bad codes will get updated----- LOC/9/15/2014
Update h
set htlratecat = right(udefdata,3)
from dba.hotel h, dba.udef u
where h.recordkey = u.recordkey and h.seqnum = u.seqnum and htlsegnum = substring(udefdata,1,1)
and h.iatanum = 'Prehgp' and u.iatanum = 'prehgp'
and h.Remarks3 = 'W' and htlratecat is NULL
and u.udeftype = 'roomtype' and u.udefdata like '[0-9]/%'
--and right(udefdata,3) in (select lookupvalue from dba.lookupdata where lookupname = 'ratecode')
and h.invoicedate > '12-31-2012'

---------All GDS----------------------------------------------------------------------------
--Cleanup rate codes per case 00011012
--when HtlRateCat like '%xxx%' and iatanum = 'PREHGP' and HtlRateCat <> 'xxx' then 'xxx'

--Added on 2/15/13 by Nina
update dba.hotel
set HtlRateCat = 
case when HtlRateCat like '%AAA%' and iatanum = 'PREHGP' and HtlRateCat <> 'AAA' then 'AAA'
when HtlRateCat like '%ABC%' and iatanum = 'PREHGP' and HtlRateCat <> 'ABC' then 'ABC'
when HtlRateCat like '%AB2%' and iatanum = 'PREHGP' and HtlRateCat <> 'AB2' then 'AB2'
when HtlRateCat like '%AOM%' and iatanum = 'PREHGP' and HtlRateCat <> 'AOM' then 'AOM'
when HtlRateCat like '%PSQ%' and iatanum = 'PREHGP' and HtlRateCat <> 'PSQ' then 'PSQ'
when HtlRateCat like '%BCD%' and iatanum = 'PREHGP' and HtlRateCat <> 'BCD' then 'BCD'
when HtlRateCat like '%WTP%' and iatanum = 'PREHGP' and HtlRateCat <> 'WTP' then 'WTP'
when HtlRateCat like '%CWT%' and iatanum = 'PREHGP' and HtlRateCat <> 'CWT' then 'CWT'
when HtlRateCat like '%CCR%' and iatanum = 'PREHGP' and HtlRateCat <> 'CCR' then 'CCR'
when HtlRateCat like '%OMG%' and iatanum = 'PREHGP' and HtlRateCat <> 'OMG' then 'OMG'
when HtlRateCat like '%RNE%' and iatanum = 'PREHGP' and HtlRateCat <> 'RNE' then 'RNE'
when HtlRateCat like '%WTT%' and iatanum = 'PREHGP' and HtlRateCat <> 'WTT' then 'WTT'
when HtlRateCat like '%RN8%' and iatanum = 'PREHGP' and HtlRateCat <> 'RN8' then 'RN8'
when HtlRateCat like '%THR%' and iatanum = 'PREHGP' and HtlRateCat <> 'THR'	then 'THR'
when HtlRateCat like '%THN%' and iatanum = 'PREHGP' and HtlRateCat <> 'THN' then 'THN'
when HtlRateCat like '%THL%' and iatanum = 'PREHGP' and HtlRateCat <> 'THL' then 'THL'
when HtlRateCat like '%TL7%' and iatanum = 'PREHGP' and HtlRateCat <> 'TL7' then 'TL7'
when HtlRateCat like '%7TL%' and iatanum = 'PREHGP' and HtlRateCat <> '7TL' then '7TL'
when HtlRateCat like '%API%' and iatanum = 'PREHGP' and HtlRateCat <> 'API' then 'API'
when HtlRateCat like '%HFH%' and iatanum = 'PREHGP' and HtlRateCat <> 'HFH' then 'HFH'
when HtlRateCat like '%EZR%' and iatanum = 'PREHGP' and HtlRateCat <> 'EZR' then 'EZR'
when HtlRateCat like '%AMX%' and iatanum = 'PREHGP' and HtlRateCat <> 'AMX' then 'AMX'
when HtlRateCat like '%BAR%' and iatanum = 'PREHGP' and HtlRateCat <> 'BAR' then 'BAR'
when HtlRateCat like '%CC2%' and iatanum = 'PREHGP' and HtlRateCat <> 'CC2' then 'xxx'
when HtlRateCat like '%COR%' and iatanum = 'PREHGP' and HtlRateCat <> 'COR' then 'COR'
when HtlRateCat like '%EER%' and iatanum = 'PREHGP' and HtlRateCat <> 'EER' then 'EER'
when HtlRateCat like '%FHR%' and iatanum = 'PREHGP' and HtlRateCat <> 'FHR' then 'FHR'
when HtlRateCat like '%GHL%' and iatanum = 'PREHGP' and HtlRateCat <> 'GHL' then 'GHL'
when HtlRateCat like '%GOV%' and iatanum = 'PREHGP' and HtlRateCat <> 'GOV' then 'GOV'
when HtlRateCat like '%NET%' and iatanum = 'PREHGP' and HtlRateCat <> 'NET' then 'NET'
when HtlRateCat like '%PRE%' and iatanum = 'PREHGP' and HtlRateCat <> 'PRE' then 'PRE'
when HtlRateCat like '%RAC%' and iatanum = 'PREHGP' and HtlRateCat <> 'RAC' then 'RAC'
when HtlRateCat like '%SIG%' and iatanum = 'PREHGP' and HtlRateCat <> 'SIG' then 'SIG'
when HtlRateCat like '%THX%' and iatanum = 'PREHGP' and HtlRateCat <> 'THX' then 'THX'
when HtlRateCat like '%TSA%' and iatanum = 'PREHGP' and HtlRateCat <> 'TSA' then 'TSA'
when HtlRateCat like '%TXEL%' and iatanum = 'PREHGP' and HtlRateCat <> 'TZEL' then 'TZEL'
when HtlRateCat like '%XPV%' and iatanum = 'PREHGP' and HtlRateCat <> 'XPV' then 'XPV'
when HtlRateCat like '%Y8Z%' and iatanum = 'PREHGP' and HtlRateCat <> 'Y8Z' then 'Y8Z'

when HtlRateCat like '%NHF%' and iatanum = 'PREHGP' and HtlRateCat <> 'HFH' and Remarks3 = 'W' then  'HFH'
else htlratecat end

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Cleanup rate codes',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Added on 3/8/13 by Nina
Update dba.hotel
set Remarks1 = NULL
where IataNum = 'PREHGP'


--Updated on 9/25/12 by Nina per Case #00004214
--Updated on 2/22/13 by Nina
UPDATE  htl
SET htl.remarks1 = SUBSTRING(ud.udefdata,CHARINDEX('/',ud.udefdata)+1,100)
 FROM    dba.hotel htl,dba.udef ud
 WHERE   htl.recordkey = ud.recordkey
 AND htl.iatanum = ud.iatanum
 AND htl.seqnum = ud.seqnum
 and htl.HtlSegNum = substring(ud.UdefData,1,CHARINDEX('/',ud.udefdata)-1)
 AND htl.clientcode = ud.clientcode
--AND SUBSTRING(htl.RecordKey,CHARINDEX('-',htl.RecordKey)-4,4)  IN ('KK70','J495','6L31','9LD2','L850')
 AND ud.udeftype = 'CDNUM'
 AND htl.iatanum = 'PREHGP'
 
 --Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks1 = substring(htl.Remarks1,1,charindex('SYS',htl.Remarks1)-1)
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and htl.Remarks1 like '%[0-9]SYS%'

--Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks1 = substring(htl.Remarks1,1,charindex('SYS',htl.Remarks1)-2)
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners'
and htl.iatanum = 'PREHGP'
and htl.Remarks1 like '% SYS%'


SET @TransStart = getdate()
--HFH Override for certain CD Numbers and chain codes
--Added on 2/22/13 by Nina per case #00011359
--Changed to Remarks1 "like" per case #00011359 by Nina on 3/24/13
--Removed all filters for htlChainCodes per case #00011359...updated on 4/10/13 by Nina
--Added the htlchaincode filters back in per case #00011359...updated on 4/16/13 by Nina
update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP'
and Remarks1 like '%NEGATJ%'
and (HtlRateCat <> 'HFH' or HtlRateCat is null)
---and HtlChainCode in ('XL')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%LRHICKORYTRAVEL%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('LR')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%HICKRY SYS ADDED%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('CX')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%HICKRY%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('CX','PD','PK','RD')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%HICKORYTRAVEL%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('YO')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%HICKORYFIRST%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('PF')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%HFH%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('LQ')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%FIRSTBHICKORY%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('IQ')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%D883733065%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('HL')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%D622044014%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('XL')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%CustomTvlSyst%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('HI')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%CR10011%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('LM')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%CR07210%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('HY')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%CP10001029%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('FA','SL','YR')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%CNS00042%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('KC')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%CHIC%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('EQ')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%C9167196%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('KI')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%C1000555%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('OM')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%C10000616%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('OB')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%97533921%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('JT')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%1631000%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('RL')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%8000001165%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('DI','RA','WG','WR','WY')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%900000052%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('CP','HI','IC','IN','YO','YZ')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%883733065%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('HL')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%10002512%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('MU')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%1136143%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('DE')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%1109760%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('BW')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%600125%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('ME')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%543661%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('RF')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%128057%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('JD')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%74614%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('HH')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%10755%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('LZ')

update dba.hotel
set HtlRateCat = 'HFH'
where IataNum = 'PREHGP' and Remarks1 like '%6629%' and (HtlRateCat <> 'HFH' or HtlRateCat is null)
--and HtlChainCode in ('GX','LC','MD','SI','SW','WH','WI')
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HFH Override',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--End of case #00011359

SET @TransStart = getdate()
--BCD Override for certain CD Numbers and chain codes
--Added on 7/26/13 by Nina per case #00018351
update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%143167%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%265493%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%11849961%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%100221835%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%N100197%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%100197%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'BCD'
where IataNum = 'PREHGP' and Remarks1 like '%8000000682%' and (HtlRateCat <> 'BCD' or HtlRateCat is null)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='BCD Override',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--THR Override for certain CD Numbers and chain codes
--Added on 7/26/13 by Nina per case #00018351
update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%10002404%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%800000382%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%26555%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%C1000101%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%100205087%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%THOR%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%CR1804%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%5556%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%1635%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%91920421%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'THR'
where IataNum = 'PREHGP' and Remarks1 like '%547840%' and (HtlRateCat <> 'THR' or HtlRateCat is null)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='THR Override',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--ABC Override for certain CD Numbers and chain codes
--Added on 7/26/13 by Nina per case #00018351
update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%38514%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%1949%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%1636%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%788146199%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%CR18187%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%670065%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%C1000251%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%ABC%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%34283%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%8000000058%' and (HtlRateCat <> 'THR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'ABC'
where IataNum = 'PREHGP' and Remarks1 like '%10002511%' and (HtlRateCat <> 'ABC' or HtlRateCat is null)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='ABC Override',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--CCR Override for certain CD Numbers and chain codes
--Added on 7/26/13 by Nina per case #00018351
update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%56443%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%0014614%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%0560012819%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%CR63250%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%100859652%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%C100065%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%19811%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%CCR%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%8000000866%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%60021%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)

update dba.hotel
set HtlRateCat = 'CCR'
where IataNum = 'PREHGP' and Remarks1 like '%1000293%' and (HtlRateCat <> 'CCR' or HtlRateCat is null)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CCR Override',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--End of case #00018351

--Added on 3/8/13 by Nina
Update dba.hotel
set Remarks2 = NULL
where IataNum = 'PREHGP'

--Updated on 9/25/12 by Nina per Case #00004214
UPDATE  htl
 SET htl.remarks2 = SUBSTRING(udefdata,CHARINDEX('/',ud.udefdata)+1,100)
 FROM    dba.hotel htl,dba.udef ud
 WHERE   htl.recordkey = ud.recordkey
 AND htl.iatanum = ud.iatanum  AND htl.seqnum = ud.seqnum
 and htl.HtlSegNum = substring(ud.UdefData,1,CHARINDEX('/',ud.udefdata)-1)
 AND htl.clientcode = ud.clientcode
--AND SUBSTRING(htl.RecordKey,CHARINDEX('-',htl.RecordKey)-4,4)  IN ('KK70','J495','6L31','9LD2','L850')
 AND ud.udeftype = 'CMNCODE'
 AND htl.iatanum = 'PREHGP'
 
 --Update hotel remarks5 with invoicedetail remarks5 where hotel remarks5 is NULL
--Added on 4/29/14 per case #00035484
update ht
set ht.remarks5 = id.remarks5
from dba.hotel ht,dba.InvoiceDetail id
where ht.IataNum = 'PREHGP'
and ht.IataNum = id.IataNum and ht.RecordKey = id.RecordKey and ht.SeqNum = id.SeqNum
and ht.ClientCode = id.ClientCode and ht.Remarks5 is null and id.Remarks5 is not null
 
  --Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks2 = 'N'
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners' and htl.iatanum = 'PREHGP' and htl.Remarks2 like '%NO%'
 
--Added on 1/17/13 by Nina per Case #00007797
UPDATE htl
SET htl.Remarks2 = 'C'
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode
and cl.CustName = 'World Travel Partners' and htl.iatanum = 'PREHGP' and htl.Remarks2 not like '%NO%'
and htl.Remarks2 is not null and htl.Remarks2 <> 'N'


--Added on 2/1/13 by Nina per Case #00010302
UPDATE ht
SET ht.Salutation = SUBSTRING(ud.udefdata,3,10)
from dba.Hotel ht, dba.Udef ud
where ht.IataNum = 'PREHGP' and ht.IataNum = ud.IataNum and ht.RecordKey = ud.RecordKey
and ht.SeqNum = ud.SeqNum and ht.ClientCode = ud.ClientCode and ht.HtlSegNum = SUBSTRING(ud.udefdata,1,1)
and ud.UdefType = 'ARC NUMBER' and ud.UdefData like '[0-9]/%'

Update ht
SET ht.Salutation = SUBSTRING(ud.udefdata,4,10)
from dba.Hotel ht, dba.Udef ud
where ht.IataNum = 'PREHGP' and ht.IataNum = ud.IataNum and ht.RecordKey = ud.RecordKey
and ht.SeqNum = ud.SeqNum and ht.ClientCode = ud.ClientCode and ht.HtlSegNum = SUBSTRING(ud.udefdata,1,2)
and ud.UdefType = 'ARC NUMBER' and ud.UdefData like '[0-9][0-9]/%'
--End of Case #00010302

--Added on 4/26/13 by Nina per Case 00009123
Update ht
SET ht.Salutation = SUBSTRING(ud.udefdata,1,10)
from dba.Hotel ht, dba.Udef ud
where ht.IataNum = 'PREHGP' and ht.IataNum = ud.IataNum and ht.RecordKey = ud.RecordKey
and ht.SeqNum = ud.SeqNum and ht.ClientCode = ud.ClientCode and ud.UdefType = 'ARC NUMBER' 
and ud.UdefData not like '%/%'


 --Added on 2/21/13 by Nina per Case #00010302
UPDATE htl
SET htl.Salutation = '44713292'
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode and cl.CustName = 'Caldwell Travel' and htl.iatanum = 'PREHGP'
and (htl.Salutation is null or substring(htl.salutation,1,1) not between '0' and '9')

UPDATE htl
SET htl.Salutation = '45618996' 
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode and cl.CustName = 'Campbell Travel Services'
and htl.iatanum = 'PREHGP' and (htl.Salutation is null or substring(htl.salutation,1,1) not between '0' and '9')

UPDATE htl
SET htl.Salutation = '05838276' 
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode and cl.CustName = 'Plaza Travel' 
and htl.iatanum = 'PREHGP' and (htl.Salutation is null or substring(htl.salutation,1,1) not between '0' and '9')

UPDATE htl
SET htl.Salutation = '36504053' 
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode and cl.CustName = 'TS24' 
and htl.iatanum = 'PREHGP' and (htl.Salutation is null or substring(htl.salutation,1,1) not between '0' and '9')

UPDATE htl
SET htl.Salutation = '45513716'
from dba.Hotel htl, dba.Client cl
where cl.ClientCode = htl.ClientCode and cl.CustName = 'Wyndham Jade' 
and htl.iatanum = 'PREHGP' and (htl.Salutation is null or substring(htl.salutation,1,1) not between '0' and '9')
--End of Case #00010302


--Update Salutation for Fox Travel Services
--Added on 5/8/13 by Nina per Case #00014678
Update dba.Hotel
set Salutation = '52501584'
where IataNum = 'PREHGP' and Remarks5 = 'DB9'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52508820'
where IataNum = 'PREHGP' and Remarks5 = 'IZ7J'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52515164'
where IataNum = 'PREHGP' and Remarks5 = 'ITS0'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52515923'
where IataNum = 'PREHGP' and Remarks5 = 'ICF2'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52536680'
where IataNum = 'PREHGP' and Remarks5 = 'ICF0'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52545415'
where IataNum = 'PREHGP' and Remarks5 = '46P'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52552931'
where IataNum = 'PREHGP' and Remarks5 = 'MY2'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52567944'
where IataNum = 'PREHGP' and Remarks5 = '18VF'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52600575'
where IataNum = 'PREHGP' and Remarks5 = '5U3'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52600855'
where IataNum = 'PREHGP' and Remarks5 = '1HH'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52615695'
where IataNum = 'PREHGP' and Remarks5 = '1X4Z'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52623620'
where IataNum = 'PREHGP' and Remarks5 = '1TN9'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52638202'
where IataNum = 'PREHGP' and Remarks5 = '137J'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52640125'
where IataNum = 'PREHGP' and Remarks5 = '10MN'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52658163'
where IataNum = 'PREHGP' and Remarks5 IN ('100T','8TG','W8S')
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52700594'
where IataNum = 'PREHGP' and Remarks5 = 'LD4'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52747284'
where IataNum = 'PREHGP' and Remarks5 = '146L'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52749922'
where IataNum = 'PREHGP' and Remarks5 = '13OY'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52754645'
where IataNum = 'PREHGP' and Remarks5 = 'NX4'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52758414'
where IataNum = 'PREHGP' and Remarks5 = 'DF5'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52838951'
where IataNum = 'PREHGP' and Remarks5 = 'T9N'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52888986'
where IataNum = 'PREHGP' and Remarks5 = 'NU9'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52892346'
where IataNum = 'PREHGP' and Remarks5 = 'C3D'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52904972'
where IataNum = 'PREHGP' and Remarks5 IN('2D09','62R','GO3')
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52911423'
where IataNum = 'PREHGP' and Remarks5 IN('136T','15XX')
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '52912366'
where IataNum = 'PREHGP' and Remarks5 = 'JR2'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')
--End update for Fox Travel Services

--Update Salutation for World Travel Partners
--Added on 5/8/13 by Nina per Case #00014678
Update dba.Hotel
set Salutation = '11545472'
where IataNum = 'PREHGP' and Remarks5 = '550'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '11593234'
where IataNum = 'PREHGP' and Remarks5 = '9HU'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34506216'
where IataNum = 'PREHGP' and Remarks5 = 'T67'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34543390'
where IataNum = 'PREHGP' and Remarks5 IN ('230','0ZA','3DK','5TL','9HB')
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34543391'
where IataNum = 'PREHGP' and Remarks5 = 'RXT'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34599655'
where IataNum = 'PREHGP' and Remarks5 = '63D'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34611684'
where IataNum = 'PREHGP' and Remarks5 = '9TI'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34629895'
where IataNum = 'PREHGP' and Remarks5 = 'FJY'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34645284'
where IataNum = 'PREHGP' and Remarks5 = 'L3P'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '11545472'
where IataNum = 'PREHGP' and Remarks5 = '550'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '34717944'
where IataNum = 'PREHGP' and Remarks5 = '7TP'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44500282'
where IataNum = 'PREHGP' and Remarks5 = '9NW'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44510141'
where IataNum = 'PREHGP' and Remarks5 = 'O08'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44510465'
where IataNum = 'PREHGP' and Remarks5 = '86F'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44515903'
where IataNum = 'PREHGP' and Remarks5 = 'T8P'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44531804'
where IataNum = 'PREHGP' and Remarks5 = '2BS'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44536074'
where IataNum = 'PREHGP' and Remarks5 = '7X1'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44536295'
where IataNum = 'PREHGP' and Remarks5 = '57K'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44548840'
where IataNum = 'PREHGP' and Remarks5 = 'K8M'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44549864'
where IataNum = 'PREHGP' and Remarks5 = '8CI'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44579651'
where IataNum = 'PREHGP' and Remarks5 = 'M8S'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44608325'
where IataNum = 'PREHGP' and Remarks5 = '7DR'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44635290'
where IataNum = 'PREHGP' and Remarks5 = 'JJ5'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44643222'
where IataNum = 'PREHGP' and Remarks5 = '7UU'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44655273'
where IataNum = 'PREHGP' and Remarks5 = '59T'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44922776'
where IataNum = 'PREHGP' and Remarks5 = '85T'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44933755'
where IataNum = 'PREHGP' and Remarks5 = '7SR'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '44942542'
where IataNum = 'PREHGP' and Remarks5 IN ('1EB','3Y4','5HV','7CD','IPM','Z6V')
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '01531714'
where IataNum = 'PREHGP' and Remarks5 = '2VH'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')

Update dba.Hotel
set Salutation = '01629504'
where IataNum = 'PREHGP' and Remarks5 = 'G7G'
and (Salutation is null or substring(salutation,1,1) not between '0' and '9')
--End update for World Travel Partners

Update dba.ComRmks
set Text2 = 'US'
where IataNum = 'PREHGP'
and Text2 is null

--Updated on 9/25/12 by Nina per Case #00004214
UPDATE dba.hotel
SET htlconfnum = substring(htlconfnum,1,charindex('-',htlconfnum)-1)
WHERE iatanum = 'PREHGP'
AND htlconfnum like '%-%'

--Added on 11/20/12 by Nina per Case #00006772
UPDATE dba.InvoiceHeader
SET TicketingBranch = SUBSTRING(ticketingbranch,CHARINDEX('/',ticketingbranch)+1,10)
where IataNum = 'PREHGP' and TicketingBranch <> '0' and TicketingBranch like '%/%'

--added 5FEB2013 by Stan and Mo
SET @TransStart = getdate()

--use dba.hotel using dba.hotel_historical to reconstruct missing dba.hotel segments

--Commented out 26th Feb 13 - Discussion with Mark, Mo and Tanya.

--insert dba.Hotel
--select RecordKey, IataNum, SeqNum, HtlSegNum, ClientCode, InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, Lastname, MiddleInitial, HtlChainCode, HtlChainName, GDSPropertyNum, HtlPropertyName, HtlAddr1, HtlAddr2, HtlAddr3, HtlCityCode, HtlCityName, HtlState, HtlPostalCode, HtlCountryCode, HtlPhone, InternationalInd, CheckinDate, CheckoutDate, NumNights, NumRooms, HtlQuotedRate, QuotedCurrCode, HtlDailyRate, TtlHtlCost, RoomType, HtlRateCat, HtlCompareRate1, HtlReasonCode1, HtlCompareRate2, upper(substring(CONVERT(varchar(6),getdate(),106),1,6)), HtlCommAmt, CurrCode, PrefHtlInd, HtlConfNum, FreqGuestProgram, HtlStatus, Remarks1, Remarks2, Remarks3, Salutation, Remarks5, CommTrackInd, HtlCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, BookingAgentID, MasterId, CO2Emissions, MilesFromAirport, GroundTransCO2
--from dba.hotel_historical htlhist
--where recordkey+iatanum+HtlChainCode+convert(varchar(10),CheckinDate,120)+convert(varchar(10),CheckoutDate,120) not in 
--	(
--	select recordkey+iatanum+HtlChainCode+convert(varchar(10),CheckinDate,120)+convert(varchar(10),CheckoutDate,120)
--		from dba.Hotel
--	where IataNum = 'prehgp'
--	)
--and htlhist.Iatanum = 'prehgp'
--and htlhist.checkoutdate <= convert(VARCHAR(11),GETDATE(),120) 





--Commented out 28th Feb 13 - Now capturing data to audit table to determine dupe keys

--insert dba.Hotel
--select RecordKey, IataNum, SeqNum, HtlSegNum, ClientCode, InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, Lastname, MiddleInitial, HtlChainCode, HtlChainName, GDSPropertyNum, HtlPropertyName, HtlAddr1, HtlAddr2, HtlAddr3, HtlCityCode, HtlCityName, HtlState, HtlPostalCode, HtlCountryCode, HtlPhone, InternationalInd, CheckinDate, CheckoutDate, NumNights, NumRooms, HtlQuotedRate, QuotedCurrCode, HtlDailyRate, TtlHtlCost, RoomType, HtlRateCat, HtlCompareRate1, HtlReasonCode1, HtlCompareRate2, upper(substring(CONVERT(varchar(6),getdate(),106),1,6)), HtlCommAmt, CurrCode, PrefHtlInd, HtlConfNum, FreqGuestProgram, HtlStatus, Remarks1, Remarks2, Remarks3, Salutation, Remarks5, CommTrackInd, HtlCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, BookingAgentID, MasterId, CO2Emissions, MilesFromAirport, GroundTransCO2
--from dba.hotel_historical htlhist
--where not exists
--	(
--	select 1 
--	from dba.Hotel h
--	where htlhist.RecordKey = h.RecordKey
--	and htlhist.IataNum = h.IataNum
--	and isnull(htlhist.HtlChainCode,'ZZ') = isnull(h.HtlChainCode,'ZZ')
--	and isnull(htlhist.CheckinDate,'01 Jan 2099') = isnull(h.CheckinDate,'01 Jan 2099')
--	and isnull(htlhist.CheckoutDate,'01 Jan 2099') = isnull(h.CheckoutDate,'01 Jan 2099')
--	and h.IataNum = 'prehgp'
--	)
--and htlhist.Iatanum = 'prehgp'
--and htlhist.checkoutdate <= convert(VARCHAR(11),GETDATE(),120)


---HNN Cleanup for DEA
--Make sure to update the Iatanums for all agency data and update the production server

--Clean up hotel spaces
SET @TransStart = getdate()
/*htlpropertyname*/
update htl
set htl.htlpropertyname = rtrim(ltrim(htl.htlpropertyname))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlPropertyName,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr1*/
update htl
set htl.HtlAddr1 = rtrim(ltrim(htl.HtlAddr1))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlAddr1,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr2*/
update htl
set htl.HtlAddr2 = rtrim(ltrim(htl.HtlAddr2))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlAddr2,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlAddr3*/
update htl
set htl.HtlAddr3 = rtrim(ltrim(htl.HtlAddr3))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlAddr3,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlAddr3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlChainCode*/
update htl
set htl.HtlChainCode = rtrim(ltrim(htl.HtlChainCode))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlChainCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlChainCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlCountryCode*/
update htl
set htl.HtlCountryCode = rtrim(ltrim(htl.HtlCountryCode))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlCountryCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlCountryCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPhone*/
update htl
set htl.HtlPhone = rtrim(ltrim(htl.HtlPhone))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlPhone,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPhone',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*HtlPostalCode*/
update htl
set htl.HtlPostalCode = rtrim(ltrim(htl.HtlPostalCode))
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl
where substring(HtlPostalCode,1,1) = ' '
and htl.masterid is null
and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update HtlPostalCode',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Clean up unwanted characters in htlpropertyname and htladdr1
--Added on 4/18/13 by Nina per case 00011353
SET @TransStart = getdate()
UPDATE TTXPASQL01.TMAN503_HICKORY_GLOBAL.DBA.Hotel
SET HtlPropertyName = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlPropertyName,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
   ,HtlAddr1 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HtlAddr1,'''',''),'.',''),',',''),CHAR(160),''),CHAR(10),''),CHAR(13) + CHAR(10),''),CHAR(9),''),CHAR(0),''),CHAR(10) + CHAR(13),'')))
Where MasterId is null
and iatanum in ('PREHGP')
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update htlpropertyname and htladdr1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set masterid = -1
where masterid is null
and (htlpropertyname like 'OTHER%HOTELS%' or htlpropertyname like '%NONAME%')
and (htladdr1 is null or htladdr1 = '')
and invoicedate > '2011-12-31'


 update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set masterid = -1
where masterid is null
and (HtlPropertyName is null or HtlPropertyName = '')
and (HtlAddr1 is null or HtlAddr1 = '')
and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Parent id -1',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update htl
--set htl.htlcountrycode = ct.countrycode
--,htl.htlstate = ct.stateprovincecode
--from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl, dba.city ct
--where htl.htlcitycode = ct.citycode and  htl.masterid is null and htl.htlcountrycode is null
--and ct.countrycode <> 'ZZ' and ct.typecode ='a' and htl.invoicedate > '2011-12-31'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Country',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--SET @TransStart = getdate()
--update htl
--set htl.htlstate = t2.stateprovincecode
--from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl, dba.city t2
--where t2.typecode = 'A' and htl.htlcitycode = t2.citycode and htl.htlcountrycode = t2.countrycode
--and htl.htlstate is null and htl.htlcountrycode = 'US' and t2.countrycode = 'US'
--and htl.masterid is null and htl.invoicedate > '2011-12-31'

--update htl
--set htl.htlcountrycode = ct.countrycode
--,htl.htlstate = ct.stateprovincecode
--from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl, dba.city ct
--where htl.htlcitycode = ct.citycode and  htl.masterid is null and htl.htlcountrycode <> ct.countrycode
--and ct.typecode ='a' and htl.invoicedate > '2011-12-31'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='State',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update htl
set htl.htlstate = zp.state
from TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel htl, TTXSASQL03.ttxcentral.dba.USZipCodesDeluxe zp
where substring(htl.htlpostalcode,1,5) = zp.zipcode
and substring(htl.htlpostalcode,1,5) like '[0-9][0-9][0-9][0-9][0-9]'
and zp.PrimaryRecord = 'P' and htl.masterid is null and htl.htlstate is null
and htl.htlcountrycode = 'US' and htl.invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Zip',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htladdr3 = htlcityname
where masterid is null and htlcityname like '.%' and htladdr3 is null and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlcityname = null
where masterid is null and htlcityname like '.%' and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = 'AR'
where masterid is null and htlcountrycode = 'US' and htlstate is null and htladdr2 = 'ARKANSAS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = 'CA'
where masterid is null 	and htlcountrycode = 'US' 	and htlstate <> 'CA' and htladdr2 = 'CALIFORNIA'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = 'GA'
where masterid is null 	and htlcountrycode = 'US' 	and htlstate <> 'GA' and htladdr2 = 'GEORGIA' 
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = 'MA'
where masterid is null 	and htlcountrycode = 'US' 	and htlstate <> 'MA' and htladdr2 = 'MASSACHUSETTS'
and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = 'LA'
where masterid is null 	and htlcountrycode = 'US' 	and htlstate <> 'LA' and htladdr2 = 'LOUISIANA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = 'AZ'
where masterid is null 	and htlcountrycode = 'US' 	and htlstate <> 'AZ' and htladdr2 = 'ARIZONA'
and invoicedate > '2011-12-31'


update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = null,htlcountrycode = 'CA'
where htlcountrycode = 'US' and htladdr3 = 'CANADA' and masterid is null and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = null,htlcountrycode = 'GB'
where htlcountrycode = 'US' and htladdr3 = 'UNITED KINGDOM' and masterid is null and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = null,htlcountrycode = 'KR'
where htlcountrycode = 'US' and htladdr3 = 'SOUTH KOREA' and masterid is null and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlstate = null,htlcountrycode = 'JP'
where htlcountrycode = 'US' and htladdr3 = 'JAPAN' and masterid is null and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlcityname = 'NEW DELHI'
where htlcityname = 'DELHI'and HtlCountryCode = 'IN' and masterid is null and invoicedate > '2011-12-31'

update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
set htlcityname = 'NEW YORK' ,htlstate = 'NY'
where htlcityname = 'NEW YORK NY' OR htlCityName = 'NEW YORK, NY' and masterid is null and invoicedate > '2011-12-31'

UPDATE TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
SET HtlCityName = 'WASHINGTON' ,HtlState = 'DC'
WHERE HtlCityName = 'WASHINGTON DC' and masterid is null and invoicedate > '2011-12-31'

	update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
	set htlcityname = 'HERTOGENBOSCH'
	where masterid is null 	and htlcityname not like '[a-z]%' 	and htlpropertyname like '%MOEVENPICK HOTEL%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null 	and htlcityname not like '[a-z]%' 	and htlpropertyname like '%OAKWOOD CHELSEA%'
	and invoicedate > '2011-12-31'
	
	update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
	set htlcityname = 'NEW YORK'
	where masterid is null 	and htlcityname not like '[a-z]%' 	and htlpropertyname like '%LONGACRE HOUSE%'
	and invoicedate > '2011-12-31'


	update TTXPASQL01.TMAN503_HICKORY_GLOBAL.dba.hotel
	set htlcityname = 'BARCELONA'
	where masterid is null 	and htlcityname not like '[a-z]%' 	and htlpropertyname like '%HOTLE PUNTA PALMA%'
	and invoicedate > '2011-12-31'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End htl edits',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Capture data to audit table to determine reason for dupe keys

insert dba.HotelAudit
select RecordKey, IataNum, SeqNum, HtlSegNum, ClientCode, InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, Lastname, MiddleInitial, HtlChainCode, HtlChainName, GDSPropertyNum, HtlPropertyName, HtlAddr1, HtlAddr2, HtlAddr3, HtlCityCode, HtlCityName, HtlState, HtlPostalCode, HtlCountryCode, HtlPhone, InternationalInd, CheckinDate, CheckoutDate, NumNights, NumRooms, HtlQuotedRate, QuotedCurrCode, HtlDailyRate, TtlHtlCost, RoomType, HtlRateCat, HtlCompareRate1, HtlReasonCode1, HtlCompareRate2, upper(substring(CONVERT(varchar(6),getdate(),106),1,6)), HtlCommAmt, CurrCode, PrefHtlInd, HtlConfNum, FreqGuestProgram, HtlStatus, Remarks1, Remarks2, Remarks3, Salutation, Remarks5, CommTrackInd, HtlCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, BookingAgentID, MasterId, CO2Emissions, MilesFromAirport, GroundTransCO2, getdate()
from dba.hotel_historical htlhist
where not exists
	(
	select 1 
	from dba.Hotel h
	where htlhist.RecordKey = h.RecordKey 	and htlhist.IataNum = h.IataNum
	and isnull(htlhist.HtlChainCode,'ZZ') = isnull(h.HtlChainCode,'ZZ')
	and isnull(htlhist.CheckinDate,'01 Jan 2099') = isnull(h.CheckinDate,'01 Jan 2099')
	and isnull(htlhist.CheckoutDate,'01 Jan 2099') = isnull(h.CheckoutDate,'01 Jan 2099')
	and h.IataNum = 'prehgp'
	)
and exists
	(
	select 1 
	from dba.Hotel h
	where htlhist.RecordKey = h.RecordKey
	and htlhist.IataNum = h.IataNum 	and htlhist.SeqNum = h.SeqNum
	and htlhist.HtlSegNum = h.HtlSegNum 	and h.IataNum = 'prehgp'
	)
and htlhist.Iatanum = 'prehgp'
and htlhist.checkoutdate <= convert(VARCHAR(11),GETDATE(),120)

--Insert rows thats are not dupes and do not failing on Index.

insert dba.Hotel
select RecordKey, IataNum, SeqNum, HtlSegNum, ClientCode, InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, Lastname, MiddleInitial, HtlChainCode, HtlChainName, GDSPropertyNum, HtlPropertyName, HtlAddr1, HtlAddr2, HtlAddr3, HtlCityCode, HtlCityName, HtlState, HtlPostalCode, HtlCountryCode, HtlPhone, InternationalInd, CheckinDate, CheckoutDate, NumNights, NumRooms, HtlQuotedRate, QuotedCurrCode, HtlDailyRate, TtlHtlCost, RoomType, HtlRateCat, HtlCompareRate1, HtlReasonCode1, HtlCompareRate2, upper(substring(CONVERT(varchar(6),getdate(),106),1,6)), HtlCommAmt, CurrCode, PrefHtlInd, HtlConfNum, FreqGuestProgram, HtlStatus, Remarks1, Remarks2, Remarks3, Salutation, Remarks5, CommTrackInd, HtlCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, BookingAgentID, MasterId, CO2Emissions, MilesFromAirport, GroundTransCO2
from dba.hotel_historical htlhist
where not exists
	(
	select 1 
	from dba.Hotel h
	where htlhist.RecordKey = h.RecordKey
	and htlhist.IataNum = h.IataNum
	and isnull(htlhist.HtlChainCode,'ZZ') = isnull(h.HtlChainCode,'ZZ')
	and isnull(htlhist.CheckinDate,'01 Jan 2099') = isnull(h.CheckinDate,'01 Jan 2099')
	and isnull(htlhist.CheckoutDate,'01 Jan 2099') = isnull(h.CheckoutDate,'01 Jan 2099')
	and h.IataNum = 'prehgp'
	)
and not exists
	(
	select 1 
	from dba.Hotel h
	where htlhist.RecordKey = h.RecordKey 	and htlhist.IataNum = h.IataNum
	and htlhist.SeqNum = h.SeqNum 	and htlhist.HtlSegNum = h.HtlSegNum and h.IataNum = 'prehgp'
	)
and htlhist.Iatanum = 'prehgp'
and htlhist.checkoutdate <= convert(VARCHAR(11),GETDATE(),120)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Inserted missing hotels from dba.hotel_historical',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Copy dba.hotel to dba.hotel_historical 
truncate table dba.hotel_historical

SET @TransStart = getdate()

insert dba.hotel_historical
select RecordKey, IataNum, SeqNum, HtlSegNum, ClientCode, InvoiceDate, IssueDate, VoidInd, VoidReasonType, Salutation, FirstName, Lastname, MiddleInitial, HtlChainCode, HtlChainName, GDSPropertyNum, HtlPropertyName, HtlAddr1, HtlAddr2, HtlAddr3, HtlCityCode, HtlCityName, HtlState, HtlPostalCode, HtlCountryCode, HtlPhone, InternationalInd, CheckinDate, CheckoutDate, NumNights, NumRooms, HtlQuotedRate, QuotedCurrCode, HtlDailyRate, TtlHtlCost, RoomType, HtlRateCat, HtlCompareRate1, HtlReasonCode1, HtlCompareRate2, HtlReasonCode2, HtlCommAmt, CurrCode, PrefHtlInd, HtlConfNum, FreqGuestProgram, HtlStatus, Remarks1, Remarks2, Remarks3, Salutation, Remarks5, CommTrackInd, HtlCommPostDate, MatchedInd, MatchedFields, GDSRecordLocator, BookingAgentID, MasterId, CO2Emissions, MilesFromAirport, GroundTransCO2, GETDATE() as "BackupDate"
from dba.hotel htl
where htl.IataNum = 'prehgp' and htl.InvoiceDate > GETDATE()-365

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Inserted current dba.hotel to dba.hotel_historical',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime
Declare @HNNEndDate datetime

SET @TransStart = getdate()
Select @HNNBeginDate = Min(Issuedate),@HNNEndDate = Max(Issuedate)
from dba.Hotel
Where MasterId is NULL
AND IataNum = 'PREHGP'
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Get dates for NULL MasterIDs',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = @RequestName,
@Enhancement = 'HNN',
@Client = 'Hickory Global',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNBeginDate,
@EndDate = @HNNEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'agency',
@TextParam2 = 'ttxpasql01',
@TextParam3 = 'TMAN503_Hickory_Global',
@TextParam4 = 'DBA',
@TextParam5 = 'datasvc',
@TextParam6 = 'tman2009',
@TextParam7 = 'TTXSASQL03',
@TextParam8 = 'TTXCENTRAL',
@TextParam9 = 'DBA',
@TextParam10 = 'datasvc',
@TextParam11 = 'tman2009',
@TextParam12 = 'Push',
@TextParam13 = 'R',
@TextParam14 = NULL,
@TextParam15 = NULL,
@IntParam1 = NULL,
@IntParam2 = NULL,
@IntParam3 = NULL,
@IntParam4 = NULL,
@IntParam5 = NULL,
@BoolParam1 = NULL,
@BoolParam2 = NULL,
@BoolParam3 = NULL,
@BoolParam4 = NULL,
@BoolParam5 = NULL,
@BoolParam6 = NULL,
@BoolParam7 = NULL,
@BoolParam8 = NULL,
@BoolParam9 = NULL,
@BoolParam10 = NULL,
@CommandLineArgs = NULL
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Execute HNN',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--SET @TransStart = getdate()
----Call Sql Maint
--EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
--@DatamanRequestName = @RequestName,
--@Enhancement = 'SQLMaint',
--@Client = 'Hickory Sql Maint',
--@Delay = 15,
--@Priority = NULL,
--@Notes = NULL,
--@Suspend = false,
--@RunAtTime = NULL,
--@BeginDate = NULL,
--@EndDate = NULL,
--@DateParam1 = NULL,
--@DateParam2 = NULL,
--@TextParam1 = NULL,
--@TextParam2 = NULL,
--@TextParam3 = NULL,
--@TextParam4 = NULL,
--@TextParam5 = NULL,
--@TextParam6 = NULL,
--@TextParam7 = NULL,
--@TextParam8 = NULL,
--@TextParam9 = NULL,
--@TextParam10 = NULL,
--@TextParam11 = NULL,
--@TextParam12 = NULL,
--@TextParam13 = NULL,
--@TextParam14 = NULL,
--@TextParam15 = NULL,
--@IntParam1 = NULL,
--@IntParam2 = NULL,
--@IntParam3 = NULL,
--@IntParam4 = NULL,
--@IntParam5 = NULL,
--@BoolParam1 = NULL,
--@BoolParam2 = NULL,
--@BoolParam3 = NULL,
--@BoolParam4 = NULL,
--@BoolParam5 = NULL,
--@BoolParam6 = NULL,
--@BoolParam7 = NULL,
--@BoolParam8 = NULL,
--@BoolParam9 = NULL,
--@BoolParam10 = NULL,
--@CommandLineArgs = 'TTXPASQL01 TMAN503_Hickory_Global'
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Execute Sql Maint',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




GO
