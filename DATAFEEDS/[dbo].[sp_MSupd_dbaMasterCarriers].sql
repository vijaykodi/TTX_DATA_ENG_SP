/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterCarriers]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterCarriers]
		@c1 int = NULL,
		@c2 nchar(1) = NULL,
		@c3 nvarchar(5) = NULL,
		@c4 nvarchar(10) = NULL,
		@c5 nvarchar(100) = NULL,
		@c6 nchar(2) = NULL,
		@c7 nvarchar(25) = NULL,
		@c8 nchar(5) = NULL,
		@c9 nchar(3) = NULL,
		@c10 nchar(3) = NULL,
		@c11 datetime = NULL,
		@c12 datetime = NULL,
		@c13 nchar(1) = NULL,
		@c14 datetime = NULL,
		@pkc1 int = NULL,
		@bitmap binary(2)
as
begin  
update [dba].[MasterCarriers] set
		[CarrierType] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [CarrierType] end,
		[CarrierCode] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [CarrierCode] end,
		[CarrierNum] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [CarrierNum] end,
		[CarrierName] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [CarrierName] end,
		[CarrierCountryCode] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [CarrierCountryCode] end,
		[Alliance] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [Alliance] end,
		[CodeShareParent] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [CodeShareParent] end,
		[IATA] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [IATA] end,
		[ICAO] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [ICAO] end,
		[BeginDate] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [BeginDate] end,
		[EndDate] = case substring(@bitmap,2,1) & 8 when 8 then @c12 else [EndDate] end,
		[Status] = case substring(@bitmap,2,1) & 16 when 16 then @c13 else [Status] end,
		[InsertDate] = case substring(@bitmap,2,1) & 32 when 32 then @c14 else [InsertDate] end
where [MasterCarriersID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
