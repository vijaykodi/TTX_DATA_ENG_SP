/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterHotelBrands]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterHotelBrands]
    @c1 int,
    @c2 nchar(6),
    @c3 nvarchar(50),
    @c4 nvarchar(50),
    @c5 nvarchar(25),
    @c6 datetime,
    @c7 datetime,
    @c8 datetime
as
begin  
	insert into [dba].[MasterHotelBrands](
		[MasterHotelBrandsID],
		[BrandCode],
		[BrandName],
		[ChainName],
		[Class],
		[BeginDate],
		[EndDate],
		[InsertDate]
	) values (
    @c1,
    @c2,
    @c3,
    @c4,
    @c5,
    @c6,
    @c7,
    @c8	) 
end  

GO
