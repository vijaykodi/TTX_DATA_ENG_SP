/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterTimeZones]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterTimeZones]
		@c1 int = NULL,
		@c2 int = NULL,
		@c3 nchar(3) = NULL,
		@c4 nvarchar(320) = NULL,
		@c5 nchar(1) = NULL,
		@c6 nvarchar(12) = NULL,
		@c7 nvarchar(12) = NULL,
		@c8 datetime = NULL,
		@c9 datetime = NULL,
		@c10 datetime = NULL,
		@c11 decimal(4,2) = NULL,
		@pkc1 int = NULL,
		@pkc2 int = NULL,
		@bitmap binary(2)
as
begin  
if (substring(@bitmap,1,1) & 2 = 2)
begin 
update [dba].[MasterTimeZones] set
		[MasterCountryId] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [MasterCountryId] end,
		[TimeZoneCode] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [TimeZoneCode] end,
		[TimeZoneName] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [TimeZoneName] end,
		[EffectiveDateStatus] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [EffectiveDateStatus] end,
		[BeginDate] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [BeginDate] end,
		[BeginTime] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [BeginTime] end,
		[DiscontinueDate] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [DiscontinueDate] end,
		[EndDate] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [EndDate] end,
		[EndTime] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [EndTime] end,
		[GMTAdjustment] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [GMTAdjustment] end
where [MasterTimeZoneID] = @pkc1
  and [MasterCountryId] = @pkc2
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end  
else
begin 
update [dba].[MasterTimeZones] set
		[TimeZoneCode] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [TimeZoneCode] end,
		[TimeZoneName] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [TimeZoneName] end,
		[EffectiveDateStatus] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [EffectiveDateStatus] end,
		[BeginDate] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [BeginDate] end,
		[BeginTime] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [BeginTime] end,
		[DiscontinueDate] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [DiscontinueDate] end,
		[EndDate] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [EndDate] end,
		[EndTime] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [EndTime] end,
		[GMTAdjustment] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [GMTAdjustment] end
where [MasterTimeZoneID] = @pkc1
  and [MasterCountryId] = @pkc2
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 
end 

GO
