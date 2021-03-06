/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterCountry]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterCountry]
    @c1 int,
    @c2 nchar(2),
    @c3 nvarchar(25),
    @c4 nchar(1),
    @c5 nchar(2),
    @c6 nvarchar(100),
    @c7 nchar(5),
    @c8 nchar(3),
    @c9 nvarchar(10),
    @c10 nvarchar(20),
    @c11 nchar(3),
    @c12 nvarchar(20)
as
begin  
	insert into [dba].[MasterCountry](
		[MasterCountryID],
		[CountryCode],
		[CountryName],
		[IntlDomCode],
		[ContinentCode],
		[ContinentName],
		[PhoneCode],
		[CurrencyCode],
		[RegionCode],
		[RegionName],
		[CCMarket],
		[DIRegion]
	) values (
    @c1,
    @c2,
    @c3,
    @c4,
    @c5,
    @c6,
    @c7,
    @c8,
    @c9,
    @c10,
    @c11,
    @c12	) 
end  

GO
