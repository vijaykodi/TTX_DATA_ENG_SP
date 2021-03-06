/****** Object:  StoredProcedure [dba].[LoadFunRollup40]    Script Date: 7/14/2015 8:14:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dba.LoadFunRollup40
--YL 06/04/2014
as 
insert into dba.rollup40(COSTRUCTID,CORPORATESTRUCTURE,DESCRIPTION
,ROLLUP1,ROLLUPDESC1,ROLLUP2,ROLLUPDESC2,ROLLUP3,ROLLUPDESC3,ROLLUP4,ROLLUPDESC4)
select  distinct 'Functional',left(DivisionNumber +'-' +OrganizationUnit,40),DeptNumber 
, 'Sandvik Global','Sandvik Global'--level1
,left(company,40),company --level2
,left(OrganizationUnit ,40),OrganizationUnit --level4
,left(DivisionNumber  ,40),DeptNumber --level3
from dba.Employee
where  OrganizationUnit <> 'PRD - Production'
GO
