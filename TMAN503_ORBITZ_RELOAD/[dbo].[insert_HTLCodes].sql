/****** Object:  StoredProcedure [dbo].[insert_HTLCodes]    Script Date: 7/14/2015 8:13:20 PM ******/
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
