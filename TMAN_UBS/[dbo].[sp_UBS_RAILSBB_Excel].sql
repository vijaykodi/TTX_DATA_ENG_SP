/****** Object:  StoredProcedure [dbo].[sp_UBS_RAILSBB_Excel]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UBS_RAILSBB_Excel]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSRSBB'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = @BeginIssuedate
    SET @ENDIssueDate = Null 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

--- Delete records that do not have a orderdate with a . as these are header rows.--LOC 9/18/2012
Delete from dba.sbbtemp
where orderdate not like '%.%'

--there is not a field for billing date in the raildata table
--update dba.sbbtemp
--set billingdate = cast(CASE WHEN billingdate IS NOT NULL and billingdate <> ''THEN 
--substring(billingdate,7,4)+'-'+substring(billingdate,4,2)+'-'+substring(billingdate,1,2) 
--      ELSE NULL END AS datetime)

-------Insert into Production Tabel ----------------------------------------------------------------

INSERT INTO DBA.RailData
select cast(CASE WHEN orderdate IS NOT NULL and orderdate <> ''THEN 
substring(orderdate,7,4)+'-'+substring(orderdate,4,2)+'-'+substring(orderdate,1,2) 
      ELSE NULL END AS datetime)

,substring(DossierNbr,1,20) ,substring(InvoiceNumber,1,20) ,'CH'
,substring(TravelerLastName + ' ' + TravelerFirstName,1,100)
,CASE WHEN UserIDGPN like 'ubs.com%' then substring(UserIDGPN,8,8) else NULL END AS UserIdGPN
,NULL
,cast(CASE WHEN departdate IS NOT NULL and departdate <> ''THEN 
substring(departdate,7,4)+'-'+substring(departdate,4,2)+'-'+substring(departdate,1,2) 
      ELSE NULL END AS datetime)
,NULL
,cast(CASE WHEN returndate IS NOT NULL and returndate <> ''THEN 
substring(returndate,7,4)+'-'+substring(returndate,4,2)+'-'+substring(returndate,1,2) 
      ELSE NULL END AS datetime)
,Class,NULL,Origin,Destination,NULL,NULL
,Amount,0,0,0,'CHF', truetktcount
--,CASE WHEN CAST(Amount AS FLOAT) >= 0 THEN 1 ELSE -1 END AS TripCount
,NULL,NULL,NULL,NULL,NULL
,0,0,substring(CostCenter,1,50)
,substring(discount,1,20)--Putting discount here as Reference1 is the cost center
,substring(PersonalNbr,1,20)
,substring(OrderLastName + ' ' + OrderFirstName,1,100)
,NULL,NULL,NULL,Null,substring(description,1,50),month--@beginissuedate
from dba.sbbtempaug11
where dossiernbr not in (select distinct transactionid from dba.raildata)

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-SBB Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()


update r
set TravelerGPN = right('00000000'+TravelerGPN,8)
from dba.raildata r
where r.pos = 'CH'
and len(TravelerGPN) <> 8
and TravelerGPN <> 'Unknown'

update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional')
and r.pos = 'CH'


-- Update Remarks2 with Unknown when remarks2 is NULL
update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN is null
and r.pos = 'CH'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update Tex20 with the Traveler Name from the Hierarchy File

update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.raildata r
where e.gpn = r.travelerGPN
and c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRSBB'
and travelerGPN <> 'Unknown'
and text20 is NULL


-- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(Travelername,'UBSAG'))
from dba.comrmks c, dba.raildata r
where c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRSBB'
and (isnull(c.text20, 'Unknown') = 'Unknown'
	or c.text20 = '')
and r.TravelerGPN ='Unknown'
and bookingdate > '6-1-2012'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text 20 Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Truncate table dba.SBBTemp


GO
