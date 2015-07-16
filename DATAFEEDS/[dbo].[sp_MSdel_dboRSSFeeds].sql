/****** Object:  StoredProcedure [dbo].[sp_MSdel_dboRSSFeeds]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSdel_dboRSSFeeds]
		@pkc1 int
as
begin  
	delete [dbo].[RSSFeeds]
where [RSS_ID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end  

GO
