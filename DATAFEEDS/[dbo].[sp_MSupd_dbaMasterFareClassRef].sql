/****** Object:  StoredProcedure [dbo].[sp_MSupd_dbaMasterFareClassRef]    Script Date: 7/14/2015 7:29:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [sp_MSupd_dbaMasterFareClassRef]
		@c1 int = NULL,
		@c2 nvarchar(5) = NULL,
		@c3 nvarchar(20) = NULL,
		@c4 decimal(5,1) = NULL,
		@c5 nchar(2) = NULL,
		@c6 nvarchar(50) = NULL,
		@c7 nvarchar(20) = NULL,
		@c8 nvarchar(50) = NULL,
		@c9 datetime = NULL,
		@c10 datetime = NULL,
		@c11 nvarchar(10) = NULL,
		@c12 datetime = NULL,
		@c13 nvarchar(128) = NULL,
		@pkc1 int = NULL,
		@bitmap binary(2)
as
begin  
update [dba].[MasterFareClassRef] set
		[AirlineCode] = case substring(@bitmap,1,1) & 2 when 2 then @c2 else [AirlineCode] end,
		[StageCode] = case substring(@bitmap,1,1) & 4 when 4 then @c3 else [StageCode] end,
		[FXCode] = case substring(@bitmap,1,1) & 8 when 8 then @c4 else [FXCode] end,
		[FareClassCode] = case substring(@bitmap,1,1) & 16 when 16 then @c5 else [FareClassCode] end,
		[FareClassString] = case substring(@bitmap,1,1) & 32 when 32 then @c6 else [FareClassString] end,
		[Cabin] = case substring(@bitmap,1,1) & 64 when 64 then @c7 else [Cabin] end,
		[FXDesc] = case substring(@bitmap,1,1) & 128 when 128 then @c8 else [FXDesc] end,
		[BeginDate] = case substring(@bitmap,2,1) & 1 when 1 then @c9 else [BeginDate] end,
		[EndDate] = case substring(@bitmap,2,1) & 2 when 2 then @c10 else [EndDate] end,
		[Status] = case substring(@bitmap,2,1) & 4 when 4 then @c11 else [Status] end,
		[DateModified] = case substring(@bitmap,2,1) & 8 when 8 then @c12 else [DateModified] end,
		[ModifiedBy] = case substring(@bitmap,2,1) & 16 when 16 then @c13 else [ModifiedBy] end
where [MasterFareClassRefID] = @pkc1
if @@rowcount = 0
    if @@microsoftversion>0x07320000
        exec sp_MSreplraiserror 20598
end 

GO
