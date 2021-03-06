/****** Object:  StoredProcedure [dbo].[sp_MSins_dboRSSFeeds]    Script Date: 7/14/2015 7:29:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSins_dboRSSFeeds]
    @c1 int,
    @c2 varchar(50),
    @c3 varchar(100),
    @c4 varchar(2048),
    @c5 text,
    @c6 varchar(100),
    @c7 varchar(20),
    @c8 varchar(2),
    @c9 varchar(2),
    @c10 varchar(30),
    @c11 varchar(50),
    @c12 datetime
as
begin  
	insert into [dbo].[RSSFeeds](
		[RSS_ID],
		[RSS_TYPE],
		[RSS_TITLE],
		[RSS_LINK],
		[RSS_DETAILS],
		[RSS_PUBDATE],
		[RSS_OWNER],
		[CountryCode],
		[ContinentCode],
		[CountryName],
		[CreatedBy],
		[CreatedTimeStamp]
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
    @c12	) 
end  

GO
