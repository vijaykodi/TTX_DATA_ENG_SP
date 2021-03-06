/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterContinent]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterContinent]
		@c1 int = NULL,
		@c2 varchar(2) = NULL,
		@c3 varchar(25) = NULL,
		@pkc1 int = NULL,
		@bitmap binary(1)
as
begin  
update [dba].[MasterContinent] set
		[ContinentCode] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [ContinentCode] end,
		[ContinentName] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [ContinentName] end
where [MasterContinentID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
