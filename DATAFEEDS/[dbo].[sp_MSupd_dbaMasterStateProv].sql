/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterStateProv]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterStateProv]
		@c1 int = NULL,
		@c2 nchar(5) = NULL,
		@c3 nvarchar(50) = NULL,
		@c4 int = NULL,
		@pkc1 int = NULL,
		@bitmap binary(1)
as
begin  
update [dba].[MasterStateProv] set
		[StateProvCode] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [StateProvCode] end,
		[StateProvName] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [StateProvName] end,
		[MasterCountryID] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [MasterCountryID] end
where [MasterStateProvID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
