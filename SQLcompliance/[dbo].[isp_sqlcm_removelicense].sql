/****** Object:  StoredProcedure [dbo].[isp_sqlcm_removelicense]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure [dbo].[isp_sqlcm_removelicense] (@licenseid int)
as

   -- (c) Copyright 2004-2006 Idera, a division of BBS Technologies, Inc., all rights reserved.
   -- SQLsecure, Idera and the Idera Logo are trademarks or registered trademarks
   -- of BBS Technologies or its subsidiaries in the United States and other jurisdictions.
   --
   -- Description :
   --              Remove a single license with license id
   -- 	           
	
	declare @result int
	declare @err int
	declare @errmsg nvarchar(500)
	declare @ans int

	-- Get application program name
	declare @programname nvarchar(128)
	select @programname = program_name from master..sysprocesses where spid= @@spid and sid = SUSER_SID(SYSTEM_USER)

	declare @connectionname nvarchar(128)
	set @connectionname = NULL
		
	BEGIN TRAN
	
		delete from Licenses where licenseid = @licenseid

		select @err = @@error

		if @err <> 0
		begin
			set @errmsg = 'Error: Failed to remove a license key with license id ' + CONVERT(NVARCHAR(256), @licenseid)
			RAISERROR (@errmsg, 16, 1)
			ROLLBACK TRAN
			return -1
		end
	COMMIT TRAN	

GO
