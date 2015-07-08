/****** Object:  StoredProcedure [dba].[utilPopulateProfileRelations]    Script Date: 7/7/2015 9:23:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dba].[utilPopulateProfileRelations]asbegin      /*    This procedure will completely rebuild the ProfileRelations table. */      declare            @dist int,            @count int      delete from dba.ProfileRelations      insert into dba.ProfileRelations( ProfileName, Parent, dist)      select ProfileName, Parent, 1      from dba.Profiles      where Parent is not null      and Parent != ''      select @count=@@rowcount, @dist=2      while( @count > 0) begin            insert into dba.ProfileRelations( ProfileName, Parent, Dist)            select pr.ProfileName, p.parent, @dist            from dba.Profiles p                  inner join dba.ProfileRelations pr on p.ProfileName = pr.parent            where p.Parent is not null            and p.Parent != ''            and pr.Dist = (@dist - 1)                  select @count=@@rowcount, @dist = @dist + 1      endEND

GO

ALTER AUTHORIZATION ON [dba].[utilPopulateProfileRelations] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Profiles]    Script Date: 7/7/2015 9:23:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Profiles](
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
	[LANGUAGE] [varchar](30) NULL,
	[CountryOrigin] [varchar](2) NULL,
	[EncryptPassword] [varchar](40) NULL,
	[WebAvailable] [varchar](1) NULL,
 CONSTRAINT [PK_Profiles] PRIMARY KEY CLUSTERED 
(
	[ProfileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Profiles] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProfileRelations]    Script Date: 7/7/2015 9:23:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ProfileRelations](
	[ProfileName] [varchar](50) NOT NULL,
	[Parent] [varchar](50) NULL,
	[Dist] [int] NOT NULL,
 CONSTRAINT [PK_ProfileRelations] PRIMARY KEY CLUSTERED 
(
	[ProfileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[ProfileRelations] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [idx_ProfileRelations_Parent]    Script Date: 7/7/2015 9:23:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_ProfileRelations_Parent] ON [dba].[ProfileRelations]
(
	[Parent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

ALTER TABLE [dba].[ProfileRelations] ADD  DEFAULT ((1)) FOR [Dist]
GO

