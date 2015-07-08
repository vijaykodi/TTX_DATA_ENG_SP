/****** Object:  StoredProcedure [dba].[UpdateCostructload]    Script Date: 7/7/2015 12:07:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Yuliya Locka
create procedure [dba].[UpdateCostructload]
as
update   dba.costructload
set [desc]= left([desc],LEN([desc])-1)
where substring( [desc],LEN([desc]),1) =','


GO

ALTER AUTHORIZATION ON [dba].[UpdateCostructload] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[costructload]    Script Date: 7/7/2015 12:07:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[costructload](
	[child] [varchar](50) NULL,
	[desc] [varchar](255) NULL,
	[parent] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[costructload] TO  SCHEMA OWNER 
GO

