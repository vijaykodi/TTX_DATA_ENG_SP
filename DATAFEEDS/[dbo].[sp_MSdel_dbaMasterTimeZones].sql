/****** Object:  StoredProcedure [dbo].[sp_MSdel_dbaMasterTimeZones]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSdel_dbaMasterTimeZones]
		@pkc1 int,
		@pkc2 int
as
begin  
	delete [dba].[MasterTimeZones]
where [MasterTimeZoneID] = @pkc1
  and [MasterCountryId] = @pkc2
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end  

GO
