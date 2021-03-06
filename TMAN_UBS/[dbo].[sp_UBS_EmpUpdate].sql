/****** Object:  StoredProcedure [dbo].[sp_UBS_EmpUpdate]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_EmpUpdate]
 AS

---------------------------------------------------------------------------------
--Set Importdt
Begin
declare @importdt datetime 
 set @importdt = Getdate()
  /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

end
--Process to add entries to the Employee Table and then update the comrmks 
--with the Travelers Name from the Hierarchy table provided by UBS.


-- Add new entries to the Employee table
insert into dba.Employee
select substring(description,1,8),substring(description,10,250)
	,'Active',ROLLUP2,ROLLUP3,ROLLUP4,ROLLUP5,ROLLUP6,ROLLUP7
	,@importdt,'12-31-2049',@importdt, Rollup8
from dba.rollup40
where substring(description,1,8) not in (select gpn from dba.Employee)
and costructid = 'functional'

update E
set e.rollup2 = r.rollupdesc2
from dba.employee e, dba.rollup40 r where e.rollup2 <> r.rollupdesc2 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup3 = r.rollupdesc3
from dba.employee e, dba.rollup40 r where e.rollup3 <> r.rollupdesc3 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup4 = r.rollupdesc4
from dba.employee e, dba.rollup40 r where e.rollup4 <> r.rollupdesc4 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup5 = r.rollupdesc5
from dba.employee e, dba.rollup40 r where e.rollup5 <> r.rollupdesc5 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup6 = r.rollupdesc6
from dba.employee e, dba.rollup40 r where e.rollup6 <> r.rollupdesc6 and r.corporatestructure = e.gpn
and costructid = 'functional'

update E
set e.rollup7 = r.rollupdesc7
from dba.employee e, dba.rollup40 r where e.rollup7 <> r.rollupdesc7 and r.corporatestructure = e.gpn
and costructid = 'functional'

update e
set e.rollup8 = substring(r.rollupdesc8,charindex('-',r.rollupdesc8)+1,20)
from dba.employee e, dba.rollup40 r
where e.gpn = r.corporatestructure

exec dbo.sp_GPN_Updates_All

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
