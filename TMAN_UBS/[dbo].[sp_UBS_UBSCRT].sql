/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSCRT]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[sp_UBS_UBSCRT]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSCRT'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--SET @TransStart = getdate()

-------Insert into Production Table ---------------------------------------------LOC/10/2/2012
--Insert Radio Taxi Data-- UBSCRT
INSERT INTO DBA.CarTransportation
SELECT 'RADIOTAXIS',Date,TransactionDate,Invoice,Docket AS 
ConfirmationNumber,Passenger , ISNULL(RIGHT('00000000'+GPIN,8),'Unknown'), BookedBy, Date, PickupTime, 
PickUp, Destination,DropOffTime ,Journeydescription, 
CostCentre_ProjectCode AS CostCenter , CostCentre_ProjectCode AS 
ProjectCode, CompanyName, VehicleType, JourneyCost, 0 AS Tolls, 
WaitingCost, Parking AS Parking , 0 AS MeetGreatCharges, Phone AS 
PhoneCharges , 0 AS ServiceCharges, 0 AS AdditionalStops, 0 AS 
WaitingTimeMinutes, Gratuity,0 AS FuelSurcharge ,0 AS Package,0 AS
Events,0 AS NYCWorkmansComp, Other AS Extras, Admin, Discount, 
NetTotal, VAT, Total, 0 AS Mileage, 0 AS CarbonEmissions, 'GBP','GB',GPIN
FROM DBA.RadioTaxistemp

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Radio Taxi Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT  ConfirmationNbr, 'UBSCRT', '1', 'UBSCRT',BookingDate, BookingDate
FROM dba.cartransportation 
	where ConfirmationNbr not in
	(SELECT recordkey from dba.comrmks
	where iatanum = 'UBSCRT')
and POS = 'GB'
and source = 'RADIOTAXIS'

update c
set GPN = right('00000000'+GPN,8)
from dba.cartransportation c
where c.pos = 'GB'
and len(GPN) <> 8
and GPN <> 'Unknown'
and source = 'RADIOTAXIS'

update c
set GPN = 'Unknown'
from dba.cartransportation c
where GPN not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional')
and c.pos = 'GB'
and source = 'RADIOTAXIS'


-- Update Remarks2 with Unknown when remarks2 is NULL
update c
set GPN = 'Unknown'
from dba.cartransportation c
where GPN is null
and c.pos = 'GB'
and source = 'RADIOTAXIS'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update Tex20 with the Traveler Name from the Hierarchy File

update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.cartransportation car
where e.gpn =  car.GPN
and c.recordkey = car.ConfirmationNbr 
and c.IATANUM = 'UBSCRT'
and car.GPN <> 'Unknown'
and text20 is NULL
and source = 'RADIOTAXIS'


-- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(PassengerName,'UBSAG'))
from dba.comrmks c, dba.cartransportation car
where c.recordkey = car.ConfirmationNbr 
and c.IATANUM = 'UBSCRT'
and (isnull(c.text20, 'Unknown') = 'Unknown'
	or c.text20 = '')
and car.GPN ='Unknown'
and bookingdate > '6-1-2012'
and source = 'RADIOTAXIS'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text 20 Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

Truncate table dba.RADIOTAXISTemp


GO
