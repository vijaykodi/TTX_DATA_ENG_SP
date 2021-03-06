/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterHotelBrands]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterHotelBrands]
		@c1 int = NULL,
		@c2 nchar(6) = NULL,
		@c3 nvarchar(50) = NULL,
		@c4 nvarchar(50) = NULL,
		@c5 nvarchar(25) = NULL,
		@c6 datetime = NULL,
		@c7 datetime = NULL,
		@c8 datetime = NULL,
		@pkc1 int = NULL,
		@bitmap binary(1)
as
begin  
update [dba].[MasterHotelBrands] set
		[BrandCode] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [BrandCode] end,
		[BrandName] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [BrandName] end,
		[ChainName] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [ChainName] end,
		[Class] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [Class] end,
		[BeginDate] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [BeginDate] end,
		[EndDate] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [EndDate] end,
		[InsertDate] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [InsertDate] end
where [MasterHotelBrandsID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
