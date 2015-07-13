/****** Object:  StoredProcedure [dbo].[sp_TrentPreTrip_PostImport]    Script Date: 7/13/2015 12:39:32 PM ******/
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

ALTER AUTHORIZATION ON [dbo].[sp_TrentPreTrip_PostImport] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[PreTripProcedures]    Script Date: 7/13/2015 12:39:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[PreTripProcedures](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProcedureName] [varchar](100) NOT NULL,
	[PseudoCityCode] [varchar](25) NOT NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Status] [varchar](25) NULL,
 CONSTRAINT [PK_PreTripProcedures] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ProcedureName] ASC,
	[PseudoCityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[PreTripProcedures] TO  SCHEMA OWNER 
GO

/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 7/13/2015 12:39:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnSplitString](@str NVARCHAR(MAX),@sep NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
	WITH a AS(
		SELECT CAST(0 AS BIGINT) AS idx1,CHARINDEX(@sep,@str) idx2
		UNION ALL
		SELECT idx2+1,CHARINDEX(@sep,@str,idx2+1)
		FROM a
		WHERE idx2>0
	)
	SELECT SUBSTRING(@str,idx1,COALESCE(NULLIF(idx2,0),LEN(@str)+1)-idx1) AS value
	FROM a
GO

ALTER AUTHORIZATION ON [dbo].[fnSplitString] TO  SCHEMA OWNER 
GO

