/****** Object:  StoredProcedure [dbo].[sp_UBS_RAILDB]    Script Date: 7/14/2015 7:39:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UBS_RAILDB]
 @BeginIssueDate datetime, 
 @ENDIssueDate datetime

 AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'UBSRDB'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @BeginIssueDate = @BeginIssuedate
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

------Insert into Production Tabel ----------------------------------------------------------------
--1/20/2014 updated substring of order date to convert(datetime,orderdate,103)kp #29923

INSERT INTO DBA.RailData
select distinct cast(CASE WHEN Datum IS NOT NULL and Datum <> ''THEN 
CONVERT(datetime,Datum,103) ELSE NULL END AS datetime)
,substring(Auftragsnummer,1,20) ,Null,'DE'
,substring([Reisender Nachname] + ' ' + [Reisender Vorname],1,100)
,[FKF: Abrechnungseinheit]
,'Deutsche Bhan'
,cast(CASE WHEN Reisedatum IS NOT NULL and Reisedatum <> ''THEN CONVERT(datetime,Reisedatum,103) ELSE NULL END AS datetime)
,NULL
,cast(CASE WHEN Reisedatum IS NOT NULL and Reisedatum <> ''THEN CONVERT(datetime,Reisedatum,103) ELSE NULL END AS datetime)
,Wagenklasse,NULL,substring(Beschreibung,1,charindex('-',Beschreibung)-1)
,substring(Beschreibung,charindex('-',Beschreibung)+1,20),NULL,NULL
,replace([Gesamtpreis Betrag],',','.'),0,0,0,'EUR'
,1
,NULL,NULL,NULL,NULL,NULL
,0,0,substring([FKF: Kostenstelle],1,50)
,NULL
,substring([Anzahl Erwachsener],1,20)
,NULL
,NULL,NULL,NULL,Null,NULL,@beginissuedate,NULL,NULL
from dba.deutschebhan_temp
where Auftragsnummer not in (select distinct transactionid from dba.raildata)
and [Leistung Subtyp] <> 'Sitz' -- sitz is a fee amount


-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT  TransactionID, 'UBSDB', '1', 'UBSDB',BookingDate, BookingDate
FROM dba.raildata 
	where transactionid not in
	(SELECT recordkey from dba.comrmks
	where iatanum = 'UBSDB')
and POS = 'DE'

update r
set TravelerGPN = right('00000000'+TravelerGPN,8)
from dba.raildata r
where r.pos = 'DE'
and len(TravelerGPN) <> 8
and TravelerGPN <> 'Unknown'

update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional')
and r.pos = 'DE'

-- Update Remarks2 with Unknown when remarks2 is NULL
update r
set TravelerGPN = 'Unknown'
from dba.raildata r
where TravelerGPN is null
and r.pos = 'DE'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Update Tex20 with the Traveler Name from the Hierarchy File

update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.raildata r
where e.gpn = r.travelerGPN
and c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSDB'
--and travelerGPN <> 'Unknown'
and text20 <> e.paxname

-- Update Text20 to the Traveler Name provided by the Rail Data when GPN not provided or dummy GPN used

update c
set text20 = substring(travelername,1,charindex(' ',travelername,1)-1)+ ','+ 
substring(travelername,charindex(' ',travelername)+1,20)
from dba.comrmks c, dba.raildata r
where c.recordkey = r.TransactionID 
and c.IATANUM = 'UBSDB'
and ((isnull(c.text20, 'Unknown') = 'Unknown')
	or (c.text20 = ' ')	)
and r.TravelerGPN ='Unknown'
and bookingdate > '6-1-2012'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text 20 Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-------- Update Advance Purchase days and group ----------------------------------
--select distinct carriername, transactionid, bookingdate, departdatetime, 
update dba.raildata 
set daysadvpurch = datediff(dd,bookingdate, departdatetime) 
from dba.raildata 
where departdatetime > '1-1-2013'  and carriername = 'Deutsche Bhan'


 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  



GO
