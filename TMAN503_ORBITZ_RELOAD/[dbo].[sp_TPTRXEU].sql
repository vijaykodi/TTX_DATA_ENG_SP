/****** Object:  StoredProcedure [dbo].[sp_TPTRXEU]    Script Date: 7/14/2015 8:13:21 PM ******/
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
