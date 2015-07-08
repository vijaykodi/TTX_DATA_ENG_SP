/****** Object:  StoredProcedure [dbo].[sp_TPTRXEU]    Script Date: 7/7/2015 11:23:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_TPTRXEU]
AS
BEGIN
 EXEC master..xp_cmdshell 'dtsrun /S TTXPASQL01 /U sa /P sqldba /N TPTRXEU'
END

GO

ALTER AUTHORIZATION ON [dbo].[sp_TPTRXEU] TO  SCHEMA OWNER 
GO

