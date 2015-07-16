/****** Object:  StoredProcedure [dbo].[sp_MSdel_dbaMasterCarriers]    Script Date: 7/14/2015 7:29:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSdel_dbaMasterCarriers]
		@pkc1 int
as
begin  
	delete [dba].[MasterCarriers]
where [MasterCarriersID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end  

GO
