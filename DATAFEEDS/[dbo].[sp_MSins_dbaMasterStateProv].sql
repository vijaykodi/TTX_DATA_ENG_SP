/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterStateProv]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterStateProv]
    @c1 int,
    @c2 nchar(5),
    @c3 nvarchar(50),
    @c4 int
as
begin  
	insert into [dba].[MasterStateProv](
		[MasterStateProvID],
		[StateProvCode],
		[StateProvName],
		[MasterCountryID]
	) values (
    @c1,
    @c2,
    @c3,
    @c4	) 
end  

GO
