/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503']/UnresolvedEntity[@Name='reasoncodebycorp' and @Schema='dbo'] ******/
GO

/****** Object:  StoredProcedure [dbo].[insert_BookingCodes]    Script Date: 7/7/2015 9:23:42 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dbo].[insert_BookingCodes]
as
begin
    declare @currentNode as int, @parentnode as int
    declare @clientcode as varchar(50)
    declare @reasoncode as varchar(25)
    declare @description as varchar(100), @old_client as varchar(50)
  
    select @currentNode = max(node) + 1 from dbo.lookupdatatest

	declare t_cursor cursor for
	  select distinct CLIENTCODE,REASONCODE,DESCRIPTION
		from TMAN503.dbo.reasoncodebycorp
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
            insert into dbo.lookupdatatest values ('BookingReasonCode', 0, @clientcode,'',null,null,@parentnode)
            set @currentNode = @parentnode + 1
        END

        --insert reason code
        insert into dbo.lookupdatatest values ('BookingReasonCode',@parentnode,@reasoncode,@description,null,null,@currentnode)

        set @currentNode = @currentNode + 1
		fetch next from t_cursor into @clientcode, @reasoncode, @description
	end

	close t_cursor
	deallocate t_cursor

   return

end

GO

ALTER AUTHORIZATION ON [dbo].[insert_BookingCodes] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dbo].[LookupDataTest]    Script Date: 7/7/2015 9:23:42 PM ******/
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

