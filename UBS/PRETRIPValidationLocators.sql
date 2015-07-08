/****** Object:  StoredProcedure [DBA].[utilPopulateProfileRelations]    Script Date: 7/8/2015 7:08:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [DBA].[utilPopulateProfileRelations]asbegin      /*    This procedure will completely rebuild the ProfileRelations table. */      declare            @dist int,            @count int      delete from dba.ProfileRelations      insert into dba.ProfileRelations( ProfileName, Parent, dist)      select ProfileName, Parent, 1      from dba.Profiles      where Parent is not null      and Parent != ''      select @count=@@rowcount, @dist=2      while( @count > 0) begin            insert into dba.ProfileRelations( ProfileName, Parent, Dist)            select pr.ProfileName, p.parent, @dist            from dba.Profiles p                  inner join dba.ProfileRelations pr on p.ProfileName = pr.parent            where p.Parent is not null            and p.Parent != ''            and pr.Dist = (@dist - 1)                  select @count=@@rowcount, @dist = @dist + 1      endEND
GO

ALTER AUTHORIZATION ON [DBA].[utilPopulateProfileRelations] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[Profiles]    Script Date: 7/8/2015 7:08:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[Profiles](
	[ProfileName] [varchar](50) NOT NULL,
	[ProfileDescription] [varchar](80) NULL,
	[ProfileCategory] [varchar](40) NULL,
	[ReportHeader1] [varchar](100) NULL,
	[ReportHeader2] [varchar](100) NULL,
	[ReportHeader3] [varchar](100) NULL,
	[RemarkLine1] [varchar](100) NULL,
	[RemarkLine2] [varchar](100) NULL,
	[RemarkLine3] [varchar](100) NULL,
	[RemarkLine4] [varchar](100) NULL,
	[RemarkLine5] [varchar](100) NULL,
	[RemarkLine6] [varchar](100) NULL,
	[NumReportCopies] [smallint] NULL,
	[EMailAddress] [varchar](50) NULL,
	[FaxNum] [varchar](50) NULL,
	[CorporateStructure] [varchar](40) NULL,
	[Modified] [datetime] NULL,
	[Logo] [image] NULL,
	[UserID] [varchar](30) NULL,
	[Source] [char](1) NULL,
	[MailSubject] [varchar](255) NULL,
	[MailMessage] [varchar](2000) NULL,
	[SendSingle] [varchar](1) NULL,
	[MaxAttachSize] [varchar](10) NULL,
	[ZipAttachments] [varchar](1) NULL,
	[Parent] [varchar](50) NULL,
	[Language] [varchar](30) NULL,
	[CountryOrigin] [varchar](2) NULL,
	[EncryptPassword] [varchar](40) NULL,
	[WebAvailable] [varchar](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[Profiles] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProfileRelations]    Script Date: 7/8/2015 7:09:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ProfileRelations](
	[ProfileName] [varchar](50) NOT NULL,
	[Parent] [varchar](50) NULL,
	[Dist] [int] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ProfileRelations] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [UniprofPX]    Script Date: 7/8/2015 7:09:04 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UniprofPX] ON [DBA].[Profiles]
(
	[ProfileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [idx_ProfileRelations_Parent]    Script Date: 7/8/2015 7:09:04 AM ******/
CREATE NONCLUSTERED INDEX [idx_ProfileRelations_Parent] ON [DBA].[ProfileRelations]
(
	[Parent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [idx_ProfileRelations_ProfileName]    Script Date: 7/8/2015 7:09:04 AM ******/
CREATE NONCLUSTERED INDEX [idx_ProfileRelations_ProfileName] ON [DBA].[ProfileRelations]
(
	[ProfileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

ALTER TABLE [DBA].[ProfileRelations] ADD  DEFAULT ((1)) FOR [Dist]
GO

