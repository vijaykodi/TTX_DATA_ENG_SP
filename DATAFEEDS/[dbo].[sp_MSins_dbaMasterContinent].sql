/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterContinent]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterContinent]
    @c1 int,
    @c2 varchar(2),
    @c3 varchar(25)
as
begin  
	insert into [dba].[MasterContinent](
		[MasterContinentID],
		[ContinentCode],
		[ContinentName]
	) values (
    @c1,
    @c2,
    @c3	) 
end  

GO
