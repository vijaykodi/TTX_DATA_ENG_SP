/****** Object:  StoredProcedure [dbo].[dt_dropuserobjectbyid]    Script Date: 7/14/2015 7:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**	Drop an object from the dbo.dtproperties table
*/
create procedure dbo.dt_dropuserobjectbyid
	@id int
as
	set nocount on
	delete from dbo.dtproperties where objectid=@id

GO
GRANT EXECUTE ON [dbo].[dt_dropuserobjectbyid] TO [public] AS [dbo]
GO
