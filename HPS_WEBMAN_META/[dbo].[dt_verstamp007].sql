/****** Object:  StoredProcedure [dbo].[dt_verstamp007]    Script Date: 7/14/2015 7:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**	This procedure returns the version number of the stored
**    procedures used by the the Microsoft Visual Database Tools.
**	Version is 7.0.05.
*/
create procedure dbo.dt_verstamp007
as
	select 7005

GO
GRANT EXECUTE ON [dbo].[dt_verstamp007] TO [public] AS [dbo]
GO
