/****** Object:  StoredProcedure [dbo].[sp_UBS_RAILTL]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_UBS_RAILTL]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSRTL'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null
	SET @TransStart = getdate()

 /************************************************************************
	LOGGING_STARTED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 
--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
-------------------- Updates to temp table ------------------------------------------------------------

update dba.trainline_temp
set TotalSupplemenCost = CAST(REPLACE(TotalSupplemenCost,'£','') AS FLOAT)

update dba.trainline_temp
set TicketArrangementFee = CAST(REPLACE(TicketArrangementFee,'£','') AS FLOAT)

update dba.trainline_temp
set BookingFee = CAST(REPLACE(BookingFee,'£','') AS FLOAT)

update dba.trainline_temp
set totalcost = case when totalcost like '£[0-9].[0-9][0-9]' then CAST(REPLACE(totalcost,'£','') AS FLOAT)
when totalcost like '£[0-9][0-9].[0-9][0-9]' then  CAST(REPLACE(totalcost,'£','') AS FLOAT)
when totalcost like '£[0-9][0-9][0-9].[0-9][0-9]' then CAST(REPLACE(totalcost,'£','') AS FLOAT)
when totalcost like '-£[0-9][0-9][0-9].[0-9][0-9]' then CAST(REPLACE(totalcost,'-£','-') AS FLOAT)
when totalcost like '-£[0-9][0-9].[0-9][0-9]' then CAST(REPLACE(totalcost,'-£','-') AS FLOAT)
when totalcost like '-£[0-9].[0-9][0-9]' then CAST(REPLACE(totalcost,'-£','-') AS FLOAT) 
else '1111.11' end
where totalcost like '%£%'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Temp Table updates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()
update dba.Trainline_Temp
set BookingDate=convert(datetime,bookingdate,103)

insert into dba.raildata
select convert(datetime,bookingdate,103),transactionnumber,BOOKINGID,'GB',TravellerName,substring([GPN-TravellerEmployeeNumber],1,8)
,'TrainLine',
convert(datetime,outwardlegdate,103),NULL,NULL,NULL,TICKETTYPE
,DepartureSTATION,ArrivalSTATION,NULL,NULL,TotalCost,BookingFee,'0.00','0.00','GBP',
CASE WHEN CAST(TotalCost AS FLOAT) >= 0 THEN 1 ELSE -1 END,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
CustomerName,NULL,NULL,NULL,OpportunityCode,ReasonforTravel,bookingdate,NULL,NULL
from dba.trainline_temp

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='3 -TL Move from temp to Raildata Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

---- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT  TransactionID, 'UBSRTL',
(datepart(mi,bookingdate)+datepart(hh,bookingdate)+datepart(mm,bookingdate)+datepart(dd,bookingdate))
, 'UBSRTL',BookingDate, BookingDate
FROM dba.raildata 
	where transactionid not in
	(SELECT recordkey from dba.comrmks 	where iatanum = 'UBSRTL') --and seqnum = '1')
and POS = 'GB'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='4 -ComRmks Create complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

update r
set TravelerGPN = right('00000000'+TravelerGPN,8)
from dba.raildata r
where r.pos = 'GB'
and len(TravelerGPN) <> 8
and TravelerGPN <> 'Unknown'

update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional')
and r.pos = 'GB'


---- Update Remarks2 with Unknown when remarks2 is NULL
update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN is null
and r.pos = 'GB'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='5-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


----Update Tex20 with the Traveler Name from the Hierarchy File
SET @TransStart = getdate()
update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.raildata r
where e.gpn = r.travelerGPN
and c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRTL'
and travelerGPN <> 'Unknown'
and text20 is NULL


---- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(Travelername,'UBSAG'))
from dba.comrmks c, dba.raildata r
where c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSRTL'
and (isnull(c.text20, 'Unknown') = 'Unknown'
	or c.text20 = '')
and r.TravelerGPN ='Unknown'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='6-Update Text 20 Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

---------- Update Advance Purchase days and group ----------------------------------
----select distinct carriername, transactionid, bookingdate, departdatetime, 
SET @TransStart = getdate()
update dba.raildata 
set daysadvpurch = datediff(dd,bookingdate, departdatetime) 
from dba.raildata 
where departdatetime > '1-1-2013'  and carriername = 'Trainline'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='7-Update Days Adv',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

Truncate table dba.Trainline_temp
SET @TransStart = getdate()

 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='8-Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
GO
