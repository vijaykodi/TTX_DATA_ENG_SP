/****** Object:  StoredProcedure [dbo].[sp_possiblematches]    Script Date: 7/14/2015 7:49:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC sp_possiblematches (@searchstring VARCHAR(50))
AS 
BEGIN

SELECT *
FROM dbo.v_RelevantMatch AS vrm
WHERE DocumentNumber LIKE '%'+@searchstring+'%'
OR GDSRecordLocator LIKE '%'+@searchstring+'%'
OR InvoiceNum LIKE '%'+@searchstring+'%'
END
GO
