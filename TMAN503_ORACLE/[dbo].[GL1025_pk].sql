/****** Object:  StoredProcedure [dbo].[GL1025_pk]    Script Date: 7/14/2015 8:12:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GL1025_pk]
AS
BEGIN
EXEC master..xp_cmdshell ' "\\ATL873\C$\Program Files\Microsoft SQL Server\80\Tools\Binn\dtsrun.exe" /S ATL873 /U sa /P sqldba /N ValidateGL1025_AUTO'
END

GO
