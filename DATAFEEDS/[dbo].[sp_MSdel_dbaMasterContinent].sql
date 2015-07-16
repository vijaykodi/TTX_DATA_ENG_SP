/****** Object:  StoredProcedure [dbo].[sp_MSdel_dbaMasterContinent]    Script Date: 7/14/2015 7:29:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSdel_dbaMasterContinent]
		@pkc1 int
as
begin  
	delete [dba].[MasterContinent]
where [MasterContinentID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end  

GO
