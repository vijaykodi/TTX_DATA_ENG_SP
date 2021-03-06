/****** Object:  StoredProcedure [dbo].[sp_export_tables]    Script Date: 7/14/2015 8:00:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_export_tables] 
AS 
-- EXEC [dbo].[export_tables]
-- EXEC dbo.listTableRowCounts
DECLARE @Counter INT, @MaxRows INT
DECLARE @tname varchar(100), @schemaname varchar(100), @colcnt int, @cnt2 int
DECLARE @sql varchar(8000), @Cmd varchar(8000)
SET @Counter = 1
SET @MaxRows = (select count(*) from TableRowCounts)
WHILE @Counter < @MaxRows + 1
BEGIN
	SET @tname = (Select tablename from TableRowCounts WHERE colid = @Counter)
	SET @schemaname = 'dba' --(Select schemaname from TableRowCounts WHERE colid = @Counter)
	SET @colcnt = (Select colcnt from TableRowCounts WHERE colid = @Counter)
	SET @sql = 'Select '
	SET @cnt2 = 1
	While @cnt2 < @colcnt
	Begin
-- ORIGINAL CODE HERE
-- SET @sql = @sql + 'ISNULL(cast([' + (Select column_name from INFORMATION_SCHEMA.columns where table_schema = @schemaname and table_name = @tname AND ordinal_position = @cnt2) + '] as varchar(100)),'''') + char(22) + '
SET @sql = @sql + (Select case data_type
                               when 'varchar' 
                               then column_name
                               else ISNULL(cast (column_name as varchar(100)),'''') 
                               end as column_name from INFORMATION_SCHEMA.columns 
                    where table_schema = @schemaname 
                      and table_name = @tname 
                      AND ordinal_position = @cnt2) + ' + char(22) + ' 

		SET @cnt2 = @cnt2 + 1
		--Print 'SQL1 = '+@sql

	End

 -- ORIGINAL CODE HERE
--	SET @sql = @sql + 'ISNULL(cast([' + (Select column_name from INFORMATION_SCHEMA.columns where table_schema = @schemaname and table_name = @tname AND ordinal_position = @colcnt) + '] as varchar(100)),'''') FROM TMAN503_DEMO.' + @schemaname + '.' + @tname
	SET @sql = @sql + (Select case data_type
                               when 'varchar' 
                               then column_name
                               else ISNULL(cast (column_name as varchar(100)),'''') 
                               end as column_name from INFORMATION_SCHEMA.columns 
                    where table_schema = @schemaname 
                      and table_name = @tname AND ordinal_position = @colcnt) + ' FROM TMAN503_DEMO.' + @schemaname + '.' + @tname
	
	SET @Cmd = 'bcp TMAN503_DEMO.' + @schemaname + '.' + @tname + ' out G:\PADB\' + @schemaname + '_' + @tname + '.dat -T -c -t "~" -r"\n"'
	--SET @Cmd = 'bcp "' + @sql + '" queryout E:\PADB\' + @schemaname + '_' + @tname + '.dat -S -T -c -r"\n"'
	
    --Print @sql
 	--Print @Cmd 	
	EXEC xp_cmdshell @Cmd
	
	SET @tname = ''
	SET @schemaname = ''
	SET @Cmd = ''
	SET @Counter = @Counter + 1
END



GO
