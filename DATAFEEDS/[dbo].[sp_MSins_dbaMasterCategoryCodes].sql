/****** Object:  StoredProcedure [dbo].[sp_MSins_dbaMasterCategoryCodes]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dbaMasterCategoryCodes]
    @c1 int,
    @c2 nchar(3),
    @c3 nchar(3),
    @c4 nvarchar(50),
    @c5 nvarchar(50),
    @c6 nvarchar(255),
    @c7 nchar(1),
    @c8 nchar(2),
    @c9 nchar(4),
    @c10 nchar(4),
    @c11 nvarchar(255),
    @c12 nvarchar(6),
    @c13 smallint,
    @c14 nvarchar(255),
    @c15 datetime
as
begin  
	insert into [dba].[MasterCategoryCodes](
		[MasterCategoryCodes],
		[IATACode],
		[IATANumber],
		[MCCCode],
		[MCCShortName],
		[MCCLongName],
		[TCCCode],
		[MISCode],
		[ICAOCode],
		[SICCode],
		[SICName],
		[NAICSCode],
		[USDOTAIDCode],
		[Notes],
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
    @c14,
    @c15	) 
end  

GO
