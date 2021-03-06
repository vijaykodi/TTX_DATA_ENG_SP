/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterFareClassRef]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterFareClassRef]
    @c1 int,
    @c2 nvarchar(5),
    @c3 nvarchar(20),
    @c4 decimal(5,1),
    @c5 nchar(2),
    @c6 nvarchar(50),
    @c7 nvarchar(20),
    @c8 nvarchar(50),
    @c9 datetime,
    @c10 datetime,
    @c11 nvarchar(10),
    @c12 datetime,
    @c13 nvarchar(128)
as
begin  
	insert into [dba].[MasterFareClassRef](
		[MasterFareClassRefID],
		[AirlineCode],
		[StageCode],
		[FXCode],
		[FareClassCode],
		[FareClassString],
		[Cabin],
		[FXDesc],
		[BeginDate],
		[EndDate],
		[Status],
		[DateModified],
		[ModifiedBy]
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
    @c13	) 
end  

GO
