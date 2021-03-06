/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterCountry]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterCountry]
		@c1 int = NULL,
		@c2 nchar(2) = NULL,
		@c3 nvarchar(25) = NULL,
		@c4 nchar(1) = NULL,
		@c5 nchar(2) = NULL,
		@c6 nvarchar(100) = NULL,
		@c7 nchar(5) = NULL,
		@c8 nchar(3) = NULL,
		@c9 nvarchar(10) = NULL,
		@c10 nvarchar(20) = NULL,
		@c11 nchar(3) = NULL,
		@c12 nvarchar(20) = NULL,
		@pkc1 int = NULL,
		@bitmap binary(2)
as
begin  
update [dba].[MasterCountry] set
		[CountryCode] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [CountryCode] end,
		[CountryName] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [CountryName] end,
		[IntlDomCode] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [IntlDomCode] end,
		[ContinentCode] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [ContinentCode] end,
		[ContinentName] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [ContinentName] end,
		[PhoneCode] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [PhoneCode] end,
		[CurrencyCode] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [CurrencyCode] end,
		[RegionCode] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [RegionCode] end,
		[RegionName] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [RegionName] end,
		[CCMarket] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [CCMarket] end,
		[DIRegion] = case substring(@bitmap,2,1) & 8 when 8 then @c12 else [DIRegion] end
where [MasterCountryID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
