/****** Object:  StoredProcedure [dbo].[dt_validateloginparams_u]    Script Date: 7/14/2015 7:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create proc dbo.dt_validateloginparams_u
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)
as

	-- This procedure should no longer be called;  dt_validateloginparams should be called instead.
	-- Calls are forwarded to dt_validateloginparams to maintain backward compatibility.
	set nocount on
	exec dbo.dt_validateloginparams
		@vchLoginName,
		@vchPassword 



GO
GRANT EXECUTE ON [dbo].[dt_validateloginparams_u] TO [public] AS [dbo]
GO
