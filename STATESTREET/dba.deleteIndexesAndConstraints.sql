/****** Object:  StoredProcedure [dba].[deleteIndexesAndConstraints]    Script Date: 7/7/2015 3:31:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dba].[deleteIndexesAndConstraints](@owner varchar(10), @tableName varchar(100)) AS
BEGIN
	declare @ltr nvarchar(1024);
	SELECT @ltr = ( select 'alter table ['+ @owner + '].[' + @tableName + '] drop constraint ' + c.name + ';'
		from sysobjects c join sysobjects p on c.Parent_Obj = p.[ID]
		where p.type = 'U' and p.[name] = @tableName /* is_primary_key = 1 */ 
		FOR xml path('') );
	exec sp_executesql @ltr;

	declare @qry nvarchar(1024);
	select @qry = (select 'drop index '+ i.name + ' on [' + @owner + '].[' + @tableName + '];'
		from sys.indexes i join sys.objects o on i.object_id = o.object_id
		where o.type = 'U' and o.[name] = @tableName and index_id > 0 /* is_primary_key<>1  */
		for xml path(''));
	exec sp_executesql @qry
END;

GO

ALTER AUTHORIZATION ON [dba].[deleteIndexesAndConstraints] TO  SCHEMA OWNER 
GO

