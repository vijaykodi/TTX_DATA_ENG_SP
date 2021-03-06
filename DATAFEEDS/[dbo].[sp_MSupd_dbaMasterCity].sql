/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterCity]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterCity]
		@c1 int = NULL,
		@c2 int = NULL,
		@c3 nvarchar(10) = NULL,
		@c4 nchar(1) = NULL,
		@c5 nvarchar(100) = NULL,
		@c6 nvarchar(10) = NULL,
		@c7 nvarchar(100) = NULL,
		@c8 int = NULL,
		@c9 nvarchar(10) = NULL,
		@c10 nvarchar(100) = NULL,
		@c11 nchar(3) = NULL,
		@c12 nchar(3) = NULL,
		@c13 nchar(2) = NULL,
		@c14 tinyint = NULL,
		@c15 int = NULL,
		@c16 int = NULL,
		@c17 int = NULL,
		@c18 int = NULL,
		@c19 int = NULL,
		@c20 datetime = NULL,
		@c21 datetime = NULL,
		@c22 datetime = NULL,
		@c23 decimal(9,6) = NULL,
		@c24 decimal(9,6) = NULL,
		@pkc1 int = NULL,
		@bitmap binary(3)
as
begin  
update [dba].[MasterCity] set
		[MasterCountryID] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [MasterCountryID] end,
		[StationCode] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [StationCode] end,
		[TypeCode] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [TypeCode] end,
		[StationName] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [StationName] end,
		[CityCode] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [CityCode] end,
		[CityName] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [CityName] end,
		[MasterStateProvID] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [MasterStateProvID] end,
		[MetroCode] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [MetroCode] end,
		[MetroName] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [MetroName] end,
		[CurrCode] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [CurrCode] end,
		[PhoneCode] = case substring(@bitmap,2,1) & 8 when 8 then @c12 else [PhoneCode] end,
		[TimeZoneCode] = case substring(@bitmap,2,1) & 16 when 16 then @c13 else [TimeZoneCode] end,
		[TimeZoneDiff] = case substring(@bitmap,2,1) & 32 when 32 then @c14 else [TimeZoneDiff] end,
		[MCTMax] = case substring(@bitmap,2,1) & 64 when 64 then @c15 else [MCTMax] end,
		[MCTDomDom] = case substring(@bitmap,2,1) & 128 when 128 then @c16 else [MCTDomDom] end,
		[MCTDomInt] = case substring(@bitmap,3,1) & 1 when 1 then @c17 else [MCTDomInt] end,
		[MCTIntDom] = case substring(@bitmap,3,1) & 2 when 2 then @c18 else [MCTIntDom] end,
		[MCTIntInt] = case substring(@bitmap,3,1) & 4 when 4 then @c19 else [MCTIntInt] end,
		[BeginDate] = case substring(@bitmap,3,1) & 8 when 8 then @c20 else [BeginDate] end,
		[EndDate] = case substring(@bitmap,3,1) & 16 when 16 then @c21 else [EndDate] end,
		[InsertDate] = case substring(@bitmap,3,1) & 32 when 32 then @c22 else [InsertDate] end,
		[Latitude] = case substring(@bitmap,3,1) & 64 when 64 then @c23 else [Latitude] end,
		[Longitude] = case substring(@bitmap,3,1) & 128 when 128 then @c24 else [Longitude] end
where [MasterCityID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
