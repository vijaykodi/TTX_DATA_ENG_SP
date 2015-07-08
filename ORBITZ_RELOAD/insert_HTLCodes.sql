/****** Object:  StoredProcedure [dbo].[insert_HTLCodes]    Script Date: 7/7/2015 9:24:21 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dbo].[insert_HTLCodes]
as
begin
    declare @currentNode as int, @parentnode as int
    declare @clientcode as varchar(50)
    declare @reasoncode as varchar(25)
    declare @description as varchar(100), @old_client as varchar(50)
  
    select @currentNode = 1--max(ISNULL(node, 0)) + 1 from dbo.lookupdatatest

	declare t_cursor cursor for
	  select distinct CLIENTCODE,REASONCODE,DESCRIPTION
		from dbo.reasoncodebycorpHotel
		where dupes is null

	open t_cursor
	fetch next from t_cursor into @clientcode, @reasoncode, @description
	set @old_client = ''
   
	while @@fetch_status = 0
	begin
        --insert new parentnode if it's new
        if @clientcode <> @old_client
        BEGIN
            set @old_client = @clientcode
            set @parentnode = @currentNode
            insert into dbo.lookupdatatest values ('HTLReasonCode', 0, @clientcode,'',null,null,@parentnode)
            set @currentNode = @parentnode + 1
        END

        --insert reason code
        insert into dbo.lookupdatatest values ('HTLReasonCode',@parentnode,@reasoncode,@description,null,null,@currentnode)

        set @currentNode = @currentNode + 1
		fetch next from t_cursor into @clientcode, @reasoncode, @description
	end

	close t_cursor
	deallocate t_cursor

   return

end


SELECT * FROM dbo.reasoncodebycorpHOTEL AS rh
GO

ALTER AUTHORIZATION ON [dbo].[insert_HTLCodes] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dbo].[reasoncodebycorpHOTEL]    Script Date: 7/7/2015 9:24:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[reasoncodebycorpHOTEL](
	[ACCT name] [varchar](255) NULL,
	[CLIENTCODE] [varchar](50) NULL,
	[REASONCODE] [varchar](255) NULL,
	[DESCRIPTION] [varchar](255) NULL,
	[dupes] [varchar](1) NULL,
	[idcntr] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dbo].[reasoncodebycorpHOTEL] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dbo].[LookupDataTest]    Script Date: 7/7/2015 9:24:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LookupDataTest](
	[LookupName] [nvarchar](255) NULL,
	[ParentNode] [int] NULL,
	[LookupValue] [nvarchar](255) NULL,
	[LookupText] [nvarchar](255) NULL,
	[LookupNumber] [nvarchar](255) NULL,
	[LookupDate] [nvarchar](255) NULL,
	[Node] [int] NULL
) ON [PRIMARY]

GO

ALTER AUTHORIZATION ON [dbo].[LookupDataTest] TO  SCHEMA OWNER 
GO

