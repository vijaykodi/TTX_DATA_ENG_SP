/****** Object:  StoredProcedure [dbo].[isp_sqlcm_addlicense]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure [dbo].[isp_sqlcm_addlicense] (@licensekey nvarchar(256))
as

   -- (c) Copyright 2004-2006 Idera, a division of BBS Technologies, Inc., all rights reserved.
   -- SQLsecure, Idera and the Idera Logo are trademarks or registered trademarks
   -- of BBS Technologies or its subsidiaries in the United States and other jurisdictions.
   --
   -- Description :
   --              Insert a single license
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
		
	if (@licensekey IS NULL)
	begin
		set @errmsg = N'License key cannot be null.'
		RAISERROR (@errmsg, 16, 1)
		return -1
	end 
	
	declare @mxlen int

	if (LEN(@licensekey) > 256)
	begin
		set @errmsg = N'License key cannot be longer than 256 characters.'
		RAISERROR (@errmsg, 16, 1)
		return -1
	end
	
	BEGIN TRAN
	
		insert into Licenses (licensekey, createdby, createdtm) values (@licensekey, SYSTEM_USER, GETUTCDATE())

		select @err = @@error

		if @err <> 0
		begin
			set @errmsg = 'Error: Failed to insert a new license key to Licenses table with licence ' + @licensekey
			RAISERROR (@errmsg, 16, 1)
			ROLLBACK TRAN
			return -1
		end

	COMMIT TRAN

	exec('select max(licenseid) from Licenses')
	

GO
