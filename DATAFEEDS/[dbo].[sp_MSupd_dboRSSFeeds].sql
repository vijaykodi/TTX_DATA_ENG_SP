/****** Object:  StoredProcedure [dbo].[sp_MSupd_dboRSSFeeds]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dboRSSFeeds]
		@c1 int = NULL,
		@c2 varchar(50) = NULL,
		@c3 varchar(100) = NULL,
		@c4 varchar(2048) = NULL,
		@c5 text = NULL,
		@c6 varchar(100) = NULL,
		@c7 varchar(20) = NULL,
		@c8 varchar(2) = NULL,
		@c9 varchar(2) = NULL,
		@c10 varchar(30) = NULL,
		@c11 varchar(50) = NULL,
		@c12 datetime = NULL,
		@pkc1 int = NULL,
		@bitmap binary(2)
as
begin  
update [dbo].[RSSFeeds] set
		[RSS_TYPE] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [RSS_TYPE] end,
		[RSS_TITLE] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [RSS_TITLE] end,
		[RSS_LINK] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [RSS_LINK] end,
		[RSS_DETAILS] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [RSS_DETAILS] end,
		[RSS_PUBDATE] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [RSS_PUBDATE] end,
		[RSS_OWNER] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [RSS_OWNER] end,
		[CountryCode] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [CountryCode] end,
		[ContinentCode] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [ContinentCode] end,
		[CountryName] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [CountryName] end,
		[CreatedBy] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [CreatedBy] end,
		[CreatedTimeStamp] = case substring(@bitmap,2,1) & 8 when 8 then @c12 else [CreatedTimeStamp] end
where [RSS_ID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
