/****** Object:  StoredProcedure [dbo].[dt_vcsenabled]    Script Date: 7/14/2015 7:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create proc dbo.dt_vcsenabled

as

set nocount on

declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iReturn int
    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 raiserror('', 16, -1) /* Can't Load Helper DLLC */



GO
GRANT EXECUTE ON [dbo].[dt_vcsenabled] TO [public] AS [dbo]
GO
