/****** Object:  StoredProcedure [dbo].[sp_TrentPreTrip_Procedures]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Trent Watkins
-- Create date: 12/21/2011
-- Description:	To manage the UBS PreTrip Procedures
-- and manage the execution of the sp_pre_UBS_MAIN procedure
-- for PREUBS post import procedures.
-- =============================================
CREATE PROCEDURE [dbo].[sp_TrentPreTrip_Procedures]

	@CityCode varchar(25),			--PseudoCityCode for the PreTrip Procedure being executed
	@StatusCode varchar(25)			--Status of the PreTrip procedure
									--valid codes are START and END
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql nvarchar(2000), 
	@var1 int,
	@errMsg nvarchar(200)

	SELECT @var1 = COUNT(*)
	FROM dba.PreTripProcedures
	WHERE PseudoCityCode = @CityCode
	
	IF @var1 = 0
		BEGIN
			RAISERROR ('23001 - An Entry MUST exist in the DBA.PreTripProcedures table before running this procedure.',16,1)
		END	
	ELSE IF @var1 > 1
		BEGIN
			SET @errMsg = '23002 - More than 1 entry found in DBA.PreTripProcedures for '+@CityCode
			RAISERROR (@errMsg,16,1)
		END	
	ELSE
		BEGIN
			IF @StatusCode = 'START'
				BEGIN
					UPDATE dba.PreTripProcedures
					SET StartTime = GetDate(), EndTime = NULL, [Status] = 'RUNNING'
					WHERE PseudoCityCode = @CityCode
				END
			ELSE IF @StatusCode = 'END'
				BEGIN
					UPDATE dba.PreTripProcedures
					SET EndTime = GetDate(), [Status] = 'READY'
					WHERE PseudoCityCode = @CityCode;
					EXEC dbo.sp_PreTrip_PostImport @procname='sp_PreTrip_MAIN_TEST';
				END
		END
END
GO
