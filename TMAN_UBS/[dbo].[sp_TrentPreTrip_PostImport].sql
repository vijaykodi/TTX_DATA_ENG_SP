/****** Object:  StoredProcedure [dbo].[sp_TrentPreTrip_PostImport]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Trent Watkins
-- Create date: 12/21/2011
-- Description:	PreTrip PostImport Procedure Manager
-- =============================================
CREATE PROCEDURE [dbo].[sp_TrentPreTrip_PostImport]
	@ProcName nvarchar(100)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @var1 int,
	@PCCSet1 nvarchar(500),
	@PCCSet2 nvarchar(500),
	@PCCSet3 nvarchar(500),
	@PCCSet4 nvarchar(500),
	@PCCSet5 nvarchar(500)

	/* NOTE: Each PCC set should be set to all the PCCs that run as a group and around the same time */
	SET @PCCSet1 = '03XC,S0W5,S1IW'
	SET @PCCSet2 = '27SU,2VU,32Y8,3F1F'

	-- Make sure all of the PCC procedures have completed and are set to READY
	SELECT @var1 = COUNT(*)
	FROM DBA.PreTripProcedures
	WHERE PseudoCityCode IN (SELECT value FROM dbo.fnSplitString(@PCCSet1,','))
	AND COALESCE([Status],'') != 'READY'

	IF @var1 = 0
		BEGIN
			-- Execute the main procedure then update the PreTripProcedures table
			-- and reset the Status code
			EXEC (@ProcName);
			UPDATE DBA.PreTripProcedures
			SET [Status] = 'COMPLETE'
			WHERE PseudoCityCode IN (SELECT value FROM dbo.fnSplitString(@PCCSet1,','))
			--AND COALESCE([Status],'')
		END
END
GO
