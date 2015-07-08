/****** Object:  StoredProcedure [dbo].[sp_CurrUpdates]    Script Date: 7/7/2015 9:27:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_CurrUpdates]
as 
begin
--February 29, 2012 by Sue Quigley

UPDATE SB
SET SB.ConvertedAmt = SB.Amount*CURR.BaseUnitsPerCurr,
SB.CurrCode = 'USD'
FROM DBA.Currency CURR, dba.ServeBase SB
WHERE ((CURR.BaseCurrCode = 'USD'))
      AND SB.Currency = CURR.CurrCode
      AND SB.PNRCreation = CURR.CurrBeginDate
     and SB.Currency <> 'USD'
      and sb.convertedamt is null

UPDATE SB
SET SB.ConvertedAmt = SB.Amount*CURR.BaseUnitsPerCurr,
SB.CurrCode = 'USD'
FROM DBA.Currency CURR, dba.ServeBase SB
WHERE ((CURR.BaseCurrCode = 'USD'))
      AND SB.Currency = CURR.CurrCode
      AND SB.PNRCreation = CURR.CurrBeginDate
     and SB.Currency = 'USD'
      and sb.convertedamt is null
end
GO

ALTER AUTHORIZATION ON [dbo].[sp_CurrUpdates] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ServeBase]    Script Date: 7/7/2015 9:27:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ServeBase](
	[RecordID] [varchar](5) NOT NULL,
	[RecordCreation] [datetime] NOT NULL,
	[Authorisation] [varchar](10) NULL,
	[PNRUpdated] [char](1) NULL,
	[Owner] [varchar](10) NULL,
	[GDS] [char](2) NULL,
	[Locator] [char](6) NULL,
	[PNRCreation] [datetime] NULL,
	[CardName] [char](2) NULL,
	[Currency] [char](3) NULL,
	[Amount] [money] NULL,
	[TransType] [char](1) NULL,
	[CurrCode] [varchar](3) NULL,
	[ConvertedAmt] [float] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[ServeBase] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Currency]    Script Date: 7/7/2015 9:27:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[Currency](
	[BaseCurrCode] [varchar](3) NOT NULL,
	[CurrCode] [varchar](3) NOT NULL,
	[CurrBeginDate] [datetime] NOT NULL,
	[CurrEndDate] [datetime] NULL,
	[BaseUnitsPerCurr] [float] NULL,
	[CurrUnitsPerBase] [float] NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY NONCLUSTERED 
(
	[BaseCurrCode] ASC,
	[CurrCode] ASC,
	[CurrBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Currency] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ServerBasePX]    Script Date: 7/7/2015 9:27:12 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ServerBasePX] ON [dba].[ServeBase]
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [Currency_I1]    Script Date: 7/7/2015 9:27:12 PM ******/
CREATE CLUSTERED INDEX [Currency_I1] ON [dba].[Currency]
(
	[CurrBeginDate] ASC,
	[BaseCurrCode] ASC,
	[CurrCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

