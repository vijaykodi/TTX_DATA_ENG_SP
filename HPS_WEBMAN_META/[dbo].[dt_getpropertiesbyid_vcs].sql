/****** Object:  StoredProcedure [dbo].[dt_getpropertiesbyid_vcs]    Script Date: 7/14/2015 7:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure dbo.dt_getpropertiesbyid_vcs
    @id       int,
    @property varchar(64),
    @value    varchar(255) = NULL OUT

as

    set nocount on

    select @value = (
        select value
                from dbo.dtproperties
                where @id=objectid and @property=property
                )


GO
GRANT EXECUTE ON [dbo].[dt_getpropertiesbyid_vcs] TO [public] AS [dbo]
GO
