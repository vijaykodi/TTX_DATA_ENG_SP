/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterTimeZones]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterTimeZones]
    @c1 int,
    @c2 int,
    @c3 nchar(3),
    @c4 nvarchar(320),
    @c5 nchar(1),
    @c6 nvarchar(12),
    @c7 nvarchar(12),
    @c8 datetime,
    @c9 datetime,
    @c10 datetime,
    @c11 decimal(4,2)
as
begin  
	insert into [dba].[MasterTimeZones](
		[MasterTimeZoneID],
		[MasterCountryId],
		[TimeZoneCode],
		[TimeZoneName],
		[EffectiveDateStatus],
		[BeginDate],
		[BeginTime],
		[DiscontinueDate],
		[EndDate],
		[EndTime],
		[GMTAdjustment]
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
    @c11	) 
end  

GO
