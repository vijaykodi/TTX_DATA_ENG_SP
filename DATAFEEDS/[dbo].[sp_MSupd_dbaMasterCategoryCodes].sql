/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterCategoryCodes]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterCategoryCodes]
		@c1 int = NULL,
		@c2 nchar(3) = NULL,
		@c3 nchar(3) = NULL,
		@c4 nvarchar(50) = NULL,
		@c5 nvarchar(50) = NULL,
		@c6 nvarchar(255) = NULL,
		@c7 nchar(1) = NULL,
		@c8 nchar(2) = NULL,
		@c9 nchar(4) = NULL,
		@c10 nchar(4) = NULL,
		@c11 nvarchar(255) = NULL,
		@c12 nvarchar(6) = NULL,
		@c13 smallint = NULL,
		@c14 nvarchar(255) = NULL,
		@c15 datetime = NULL,
		@pkc1 int = NULL,
		@bitmap binary(2)
as
begin  
update [dba].[MasterCategoryCodes] set
		[IATACode] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [IATACode] end,
		[IATANumber] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [IATANumber] end,
		[MCCCode] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [MCCCode] end,
		[MCCShortName] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [MCCShortName] end,
		[MCCLongName] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [MCCLongName] end,
		[TCCCode] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [TCCCode] end,
		[MISCode] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [MISCode] end,
		[ICAOCode] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [ICAOCode] end,
		[SICCode] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [SICCode] end,
		[SICName] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [SICName] end,
		[NAICSCode] = case substring(@bitmap,2,1) & 8 when 8 then @c12 else [NAICSCode] end,
		[USDOTAIDCode] = case substring(@bitmap,2,1) & 16 when 16 then @c13 else [USDOTAIDCode] end,
		[Notes] = case substring(@bitmap,2,1) & 32 when 32 then @c14 else [Notes] end,
		[InsertDate] = case substring(@bitmap,2,1) & 64 when 64 then @c15 else [InsertDate] end
where [MasterCategoryCodes] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
