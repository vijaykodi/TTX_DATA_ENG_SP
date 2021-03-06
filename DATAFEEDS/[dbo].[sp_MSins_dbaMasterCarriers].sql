/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterCarriers]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterCarriers]
    @c1 int,
    @c2 nchar(1),
    @c3 nvarchar(5),
    @c4 nvarchar(10),
    @c5 nvarchar(100),
    @c6 nchar(2),
    @c7 nvarchar(25),
    @c8 nchar(5),
    @c9 nchar(3),
    @c10 nchar(3),
    @c11 datetime,
    @c12 datetime,
    @c13 nchar(1),
    @c14 datetime
as
begin  
	insert into [dba].[MasterCarriers](
		[MasterCarriersID],
		[CarrierType],
		[CarrierCode],
		[CarrierNum],
		[CarrierName],
		[CarrierCountryCode],
		[Alliance],
		[CodeShareParent],
		[IATA],
		[ICAO],
		[BeginDate],
		[EndDate],
		[Status],
		[InsertDate]
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
    @c12,
    @c13,
    @c14	) 
end  

GO
