/****** Object:  StoredProcedure [dbo].[sp_UBS_UBSIBD]    Script Date: 7/14/2015 7:39:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UBS_UBSIBD]
 AS
SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, 
@BeginIssueDate datetime, @ENDIssueDate datetime

	SET @Iata = 'UBSCIBD'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
    SET @BeginIssueDate = Null
    SET @ENDIssueDate = Null 
	SET @TransStart = getdate()

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
--SET @TransStart = getdate()

-------Insert into Production Table ---------------------------------------------LOC/10/2/2012
--Insert Alphi data-- UBSCIBD
INSERT INTO DBA.CarTransportation
SELECT 'ALEPH',UsagePeriod,DateOfTravel,NULL AS InvoiceNumber,Conf# AS 
ConfirmationNumber,Name , ISNULL(RIGHT('00000000'+GPN,8),'Unknown'), NULL AS BookedBy, DateOfTravel, 
TimeOfPU, PickUpAddress, FinalDestination,NULL AS DropOffTime 
,JustificationCode,CostCenter AS CostCenter , ProjectCode AS 
ProjectCode, Vendor, VehicleType, BaseRate, Tolls AS Tolls, 0 AS 
WaitingCost, Parking AS Parking , MeetGreetCharges, PhoneCharges AS 
PhoneCharges , ServiceCharges, AdditionalStops, WaitTime, 
Gratuity,FuelSurcharge ,Packages,Event,PCTNYSurcharge AS 
NYCWorkmansComp , Misc AS Extras, 0 AS AdminFee, Discount, SubTotal, 
StateSalesTax, Total, 0 AS Mileage, 0 AS CarbonEmissions, 'USD','US',GPN
FROM 
DBA.IBDtemp

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='1-Alphi Data Move Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @TransStart = getdate()

-- Insert Comrmks
INSERT INTO dba.ComRmks (RecordKey, IataNum, SeqNum, ClientCode,InvoiceDate, IssueDate)
SELECT DISTINCT  ConfirmationNbr, 'UBSCIBD', '1', 'UBSCIBD',BookingDate, BookingDate
FROM dba.cartransportation 
	where ConfirmationNbr not in
	(SELECT recordkey from dba.comrmks
	where iatanum = 'UBSCIBD')
and POS = 'US'
and source = 'ALEPH'

update c
set GPN = right('00000000'+GPN,8)
from dba.cartransportation c
where c.pos = 'US'
and len(GPN) <> 8
and GPN <> 'Unknown'
and source = 'ALEPH'

update c
set GPN = 'Unknown'
from dba.cartransportation c
where GPN not in (select corporatestructure from dba.rollup40 
	where costructid = 'functional')
and c.pos = 'US'
and source = 'ALEPH'


-- Update Remarks2 with Unknown when remarks2 is NULL
update c
set GPN = 'Unknown'
from dba.cartransportation c
where GPN is null
and c.pos = 'US'
and source = 'ALEPH'

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='2-Update remarks2 GPN Number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


--Update Tex20 with the Traveler Name from the Hierarchy File

update c
set c.text20 = e.paxname
from dba.employee e, dba.comrmks c, dba.cartransportation car
where e.gpn =  car.GPN
and c.recordkey = car.ConfirmationNbr 
and c.IATANUM = 'UBSCIBD'
and car.GPN <> 'Unknown'
and text20 is NULL
and source = 'ALEPH'


-- Update Text20 to the Traveler Name provided by the TMC when GPN not provided or dummy GPN used

update c
set text20 = (isnull(PassengerName,'UBSAG'))
from dba.comrmks c, dba.cartransportation car
where c.recordkey = car.ConfirmationNbr 
and c.IATANUM = 'UBSCIBD'
and (isnull(c.text20, 'Unknown') = 'Unknown'
	or c.text20 = '')
and car.GPN ='Unknown'
and bookingdate > '6-1-2012'
and source = 'ALEPH'


EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Text 20 Complete',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

Truncate table dba.ALEPHTemp

 
 /************************************************************************
	LOGGING_ENDED - BEGIN	--Vijay added 11/24/2014
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  


GO
