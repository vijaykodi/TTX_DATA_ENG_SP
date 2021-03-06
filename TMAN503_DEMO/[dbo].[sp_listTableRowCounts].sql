/****** Object:  StoredProcedure [dbo].[sp_listTableRowCounts]    Script Date: 7/14/2015 8:00:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_listTableRowCounts] 
AS 
BEGIN

DROP TABLE TableRowCounts

CREATE TABLE TableRowCounts( 
		colid INT IDENTITY(1,1),
		schemaname varchar(100),
        tablename VARCHAR(100), 
        rowcnt INT,
		colcnt INT
    ) 

INSERT INTO TableRowCounts
SELECT s.TABLE_SCHEMA, o.name, MAX(i.rows), max(c.ordinal_position)
FROM sys.objects o, sysindexes i, INFORMATION_SCHEMA.TABLES s, INFORMATION_SCHEMA.columns c
WHERE i.id = o.object_id 
	AND o.schema_id NOT IN (4) 
	AND i.rows > 0
	AND s.table_name = o.name
	AND s.table_schema = c.table_schema and s.table_name = c.table_name
Group by s.TABLE_SCHEMA, o.name

END

GO
