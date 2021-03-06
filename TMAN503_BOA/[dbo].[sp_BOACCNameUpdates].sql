/****** Object:  StoredProcedure [dbo].[sp_BOACCNameUpdates]    Script Date: 7/14/2015 7:50:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_BOACCNameUpdates]
AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'BOFACCVI'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))



/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[sp_BOACCNameUpdates]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/


--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Added additional name edits to accommodate for names that are separated by a space
--Added on 1/2/15 by Nina
BEGIN TRAN
update dba.CCHeader
set CardHolderName = substring(CardHolderName,1,CHARINDEX(' ',CardHolderName)-1)+'/'+substring(CardHolderName,CHARINDEX(' ',CardHolderName,1)+1,40)
where iatanum = 'BOFACCVI'
and CardHolderName not like '%/%'
and CardHolderName is not NULL
and CardHolderName not like '% % %'
and CardHolderName not like '%,%'
and IndustryCode in ('01','02','03','04')
and charindex(' ',CardHolderName) <> 0
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CardHolderName in CCHeader for space',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCTicket
Set passengername = substring(passengername,1,CHARINDEX(' ',passengername)-1)+'/'+substring(passengername,CHARINDEX(' ',passengername,1)+1,40)
where iatanum = 'BOFACCVI'
and passengername not like '%/%'
and passengername is not NULL
and passengername not like '% % %'
and passengername not like '%,%'
and charindex(' ',passengername) <> 0
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update PassengerName in CCTicktet for space',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCCar
Set RenterName = substring(RenterName,1,CHARINDEX(' ',RenterName)-1)+'/'+substring(RenterName,CHARINDEX(' ',RenterName,1)+1,40)
where iatanum = 'BOFACCVI'
and RenterName not like '%/%'
and RenterName is not NULL
and RenterName not like '% % %'
and RenterName not like '%,%'
and charindex(' ',RenterName) <> 0
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RenterName in CCCar for space',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCHotel
Set GuestName = substring(GuestName,1,CHARINDEX(' ',GuestName)-1)+'/'+substring(GuestName,CHARINDEX(' ',GuestName,1)+1,40)
where iatanum = 'BOFACCVI'
and GuestName not like '%/%'
and GuestName is not NULL
and GuestName not like '% % %'
and GuestName not like '%,%'
and charindex(' ',GuestName) <> 0
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update GuestName in CCHotel for space',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Added additional name edits to accommodate for names that are separated by a comma
--Added on 1/2/15 by Nina
BEGIN TRAN
update dba.CCHeader
set CardHolderName = substring(CardHolderName,1,CHARINDEX(',',CardHolderName)-1)+'/'+substring(CardHolderName,CHARINDEX(',',CardHolderName,1)+1,40)
where iatanum = 'BOFACCVI'
and CardHolderName not like '%/%'
and CardHolderName is not NULL
and CardHolderName like '%,%'
and IndustryCode in ('01','02','03','04')
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CardHolderName in CCHeader for comma',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCTicket
Set passengername = substring(passengername,1,CHARINDEX(',',passengername)-1)+'/'+substring(passengername,CHARINDEX(',',passengername,1)+1,40)
where iatanum = 'BOFACCVI'
and passengername not like '%/%'
and passengername is not NULL
and passengername like '%,%'
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update PassengerName in CCTicktet for comma',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCCar
Set RenterName = substring(RenterName,1,CHARINDEX(',',RenterName)-1)+'/'+substring(RenterName,CHARINDEX(',',RenterName,1)+1,40)
where iatanum = 'BOFACCVI'
and RenterName not like '%/%'
and RenterName is not NULL
and RenterName like '%,%'
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RenterName in CCCar for comma',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCHotel
Set GuestName = substring(GuestName,1,CHARINDEX(',',GuestName)-1)+'/'+substring(GuestName,CHARINDEX(',',GuestName,1)+1,40)
where iatanum = 'BOFACCVI'
and GuestName not like '%/%'
and GuestName is not NULL
and GuestName like '%,%'
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update GuestName in CCHotel for comma',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Added additional name edits to accommodate for names that are separated by multiple spaces
--Added on 1/2/15 by Nina
BEGIN TRAN
update dba.CCHeader
set CardHolderName = substring(CardHolderName,1,CHARINDEX('   ',CardHolderName)-1)+'/'+substring(CardHolderName,CHARINDEX('   ',CardHolderName,1)+3,40)
where iatanum = 'BOFACCVI'
and CardHolderName not like '%/%'
and CardHolderName is not NULL
and CardHolderName like '%   %'
and IndustryCode in ('01','02','03','04')
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CardHolderName in CCHeader for spaces',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCTicket
Set passengername = substring(passengername,1,CHARINDEX('   ',passengername)-1)+'/'+substring(passengername,CHARINDEX('   ',passengername,1)+3,40)
where iatanum = 'BOFACCVI'
and passengername not like '%/%'
and passengername is not NULL
and passengername like '%   %'
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update PassengerName in CCTicktet for spaces',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCCar
Set RenterName = substring(RenterName,1,CHARINDEX('   ',RenterName)-1)+'/'+substring(RenterName,CHARINDEX('   ',RenterName,1)+3,40)
where iatanum = 'BOFACCVI'
and RenterName not like '%/%'
and RenterName is not NULL
and RenterName like '%   %'
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RenterName in CCCar for spaces',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
update dba.CCHotel
Set GuestName = substring(GuestName,1,CHARINDEX('   ',GuestName)-1)+'/'+substring(GuestName,CHARINDEX('   ',GuestName,1)+3,40)
where iatanum = 'BOFACCVI'
and GuestName not like '%/%'
and GuestName is not NULL
and GuestName like '%   %'
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update GuestName in CCHotel for spaces',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
--Update NULL Names in CCHeader
--Added on 8/23/13 by Nina per case 00018437
BEGIN TRAN
	update cchdr1
	set cchdr1.cardholdername = cchdr2.CardHolderName 
	from dba.CCHeader cchdr1, dba.CCHeader cchdr2 
	where 1=1 
	and cchdr1.iatanum = 'BOFACCVI' 
	and cchdr2.Iatanum = 'BOFACCVI' 
	and cchdr1.CardHolderName is null 
	and cchdr2.CardHolderName is not null 
	and cchdr1.CreditCardNum = cchdr2.creditcardnum 
	and cchdr1.IndustryCode in ('01','02','03','04') 
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update CardHolderName in CCHeader',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update NULL Names in CCCar
--Added on 8/23/13 by Nina per case 00018437
BEGIN TRAN
	update cchdr1
	set cchdr1.rentername = cchdr2.CardHolderName
	from dba.CCCar cchdr1, dba.CCHeader cchdr2 
	where 1=1 
	and cchdr1.iatanum = 'BOFACCVI' 
	and cchdr2.Iatanum = 'BOFACCVI' 
	and cchdr1.RenterName is null 
	and cchdr2.CardHolderName is not null 
	and cchdr1.CarOriginatingCCNum = cchdr2.creditcardnum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RenterName in CCCar',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update NULL Names in CCHotel
--Added on 8/23/13 by Nina per case 00018437
BEGIN TRAN
	update cchdr1
	set cchdr1.GuestName = cchdr2.CardHolderName
	from dba.CCHotel cchdr1, dba.CCHeader cchdr2 
	where 1=1 
	and cchdr1.iatanum = 'BOFACCVI' 
	and cchdr2.Iatanum = 'BOFACCVI' 
	and cchdr1.GuestName is null 
	and cchdr2.CardHolderName is not null 
	and cchdr1.HtlOriginatingCCNum = cchdr2.creditcardnum 
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update GuestName in CCHotel',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Update NULL Names in CCTicket
--Added on 8/23/13 by Nina per case 00018437
BEGIN TRAN
	Update cchdr1
	set cchdr1.PassengerName = cchdr2.CardHolderName
	from dba.CCTicket cchdr1, dba.CCHeader cchdr2 
	where 1=1 
	and cchdr1.iatanum = 'BOFACCVI' 
	and cchdr2.Iatanum = 'BOFACCVI' 
	and cchdr1.PassengerName is null 
	and cchdr2.CardHolderName is not null 
	and cchdr1.TktOriginatingCCNum = cchdr2.creditcardnum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update PassengerName in CCTicket',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Additional edits to update the names in CCTicket, CCCar, and CCHotel
--Added on 8/28/13 by Nina per case #00020943
BEGIN TRAN
	update c
	set c.rentername = h.cardholdername
	from dba.CCCar c , dba.CCHeader h
	where c.RecordKey = h.RecordKey
	and c.RenterName not like '%/%'
	and h.IataNum = 'BOFACCVI'
	and c.MatchedRecordKey is null
	and h.IataNum = c.IataNum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RenterName in CCCar B',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
	update c
	set c.guestname = h.cardholdername
	from dba.CChotel c , dba.CCHeader h
	where c.RecordKey = h.RecordKey
	and c.guestname not like '%/%'
	and h.IataNum = 'BOFACCVI'
	and c.MatchedRecordKey is null
	and h.IataNum = c.IataNum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update GuestName in CCHotel B',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
	update c
	set c.passengername = h.cardholdername
	from dba.CCTicket c , dba.CCHeader h
	where c.RecordKey = h.RecordKey
	and c.PassengerName not like '%/%'
	and h.IataNum = 'BOFACCVI'
	and c.MatchedRecordKey is null
	and h.IataNum = c.IataNum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update PassengerName in CCTicket B',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
--Additional edits to update the names in CCTicket, CCCar, and CCHotel
--Added on 8/28/13 by Nina per case #00020943
BEGIN TRAN
	update c
	set c.rentername = h.cardholdername
	from dba.CCCar c , dba.CCHeader h
	where c.RecordKey = h.RecordKey
	and c.RenterName like '%/\%'
	and h.IataNum = 'BOFACCVI'
	and c.MatchedRecordKey is null
	and h.IataNum = c.IataNum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update RenterName in CCCar C',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
	update c
	set c.guestname = h.cardholdername
	from dba.CChotel c , dba.CCHeader h
	where c.RecordKey = h.RecordKey
	and c.guestname like '%/\%'
	and h.IataNum = 'BOFACCVI'
	and c.MatchedRecordKey is null
	and h.IataNum = c.IataNum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update GuestName in CCHotel C',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
BEGIN TRAN
	update c
	set c.passengername = h.cardholdername
	from dba.CCTicket c , dba.CCHeader h
	where c.RecordKey = h.RecordKey
	and c.PassengerName like '%/\%'
	and h.IataNum = 'BOFACCVI'
	and c.MatchedRecordKey is null
	and h.IataNum = c.IataNum
COMMIT TRAN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update PassengerName in CCTicket C',@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/
GO
