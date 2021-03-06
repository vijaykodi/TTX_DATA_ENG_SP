/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 8:13:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]


AS
BEGIN

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime,	@BeginIssueDate datetime, @EndIssueDate datetime

	SET @Iata = 'all'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	SET @BeginIssuedate = getdate()
	SET @EndIssueDate = getdate()
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
	LOGGING_STARTED - BEGIN	--
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_STARTED - END
************************************************************************/ 

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='SP_PostHNNProcedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

--Request name OFBAST --cannot send chaincode or chain name - thay send a unique gds number for each property
--Using hotelproperty and join on hotel.masterid to update chaincode and chainname 
update h
set h.htlchaincode=hp.chaincode,
h.htlchainname=hp.chainname
from TTXPASQL01.TMAN503_ORBITZ.DBA.hotel h
INNER JOIN dba.HotelProperty HTLXREF ON ( ISNULL(H.MasterID,-1) = HTLXREF.MasterID )
 INNER JOIN dba.HotelProperty HP ON ( HTLXREF.ParentId = HP.MasterID )
where 
h.htlchaincode not in (select chaincode from TTXPASQL01.TMAN503_ORBITZ.DBA.chains where typecode='H')
and IATANUM in ('OFBAST')
and h.masterid is not null

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Processing OFB Chain Updates',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End PostHNN Procedure',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

 /************************************************************************
	LOGGING_ENDED - BEGIN	--
************************************************************************/
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  
END
GO
