/****** Object:  StoredProcedure [dbo].[hps_service_date2]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE      proc [dbo].[hps_service_date2]
as
--if exists (select * from dbo.sysobjects where id = object_id(N'[TEMPclaimsvcdate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
--		drop table dbo.TEMPclaimsvcdate
	
	    BEGIN
		CREATE TABLE [TEMPclaimsvcdate2] (
			[ec_ci_id] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_rec_id] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_pa_id] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_pa_rel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_sys_id] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_cl_id] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_cl_gen] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[Report_Date] [datetime] NULL ,
			[indexkey] [int] NULL ,
			[Service_From_Date] [datetime] NULL ,
			[Service_To_Date] [datetime] NULL, 
			[Provider_ID] CHAR(12) NULL,
			[Provider_Prefix] CHAR(9) NULL,
			[Provider_Suffix] CHAR(3) NULL,
			[Denied_Ind] CHAR(1) NULL
			
		) ON [PRIMARY]
		
		 END
	
	if @@error <> 0 return(1)

	if not exists (select * from dbo.sysobjects where id = object_id(N'[claimsvcdate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	    BEGIN
		CREATE TABLE [claimsvcdate] (
			[ec_ci_id] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_rec_id] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_pa_id] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_pa_rel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_sys_id] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_cl_id] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[ec_cl_gen] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[Report_Date] [datetime] NULL ,
			[indexkey] [int] NULL ,
			[Service_From_Date] [datetime] NULL ,
			[Service_To_Date] [datetime] NULL ,
			[Provider_ID] CHAR(12) NULL,
			[Provider_Prefix] CHAR(9) NULL,
			[Provider_Suffix] CHAR(3) NULL,
			[Denied_Ind] CHAR(1) NULL

		) ON [PRIMARY]

		CREATE CLUSTERED INDEX [ClaimSvcDatePX] ON [dbo].[claimsvcdate] 
		(
			[Service_From_Date] ASC, [ec_ci_id] ASC, [ec_rec_id] ASC, [ec_pa_id] ASC, [ec_sys_id] ASC, [ec_cl_id] ASC, [ec_cl_gen] ASC, [ec_pa_rel] ASC,
			[Report_Date] ASC, [indexkey] ASC
		) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
		
		CREATE NONCLUSTERED INDEX [ClaimSvcDateI1] ON [dbo].[claimsvcdate] 
		(
			[ec_ci_id],[ec_rec_id],[ec_sys_id],[Service_From_Date]
		) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [INDEXES]

        END
	
	if @@error <> 0 return(2)

	-- Get the service date of medical claims
	insert dbo.TEMPclaimsvcdate2
	select b.ec_ci_id
		, b.ec_rec_id
		, b.ec_pa_id
		, b.ec_pa_rel
		, b.ec_sys_id
		, b.ec_cl_id
		, b.ec_cl_gen
		, b.Report_Date
		, d.indexkey
		, case when isdate(cl_h_f_mm + '/' + cl_h_f_dd + '/' + cl_cl_cc + cl_cl_yy) = 1
		 then cl_h_f_mm + '/' + cl_h_f_dd + '/' + cl_cl_cc + cl_cl_yy
		 else NULL
		 end
		, case when isdate(cl_h_t_mm + '/' + cl_h_t_dd + '/' + cl_cl_cc + cl_cl_yy) = 1
		 then cl_h_t_mm + '/' + cl_h_t_dd + '/' + cl_cl_cc + cl_cl_yy
		 else NULL
		 end
		, d.cl_h_pr_spec + d.cl_h_pr_spec_id
		, d.cl_h_pr_spec + SUBSTRING(d.cl_h_pr_spec_id, 1, 8)
		, SUBSTRING(d.cl_h_pr_spec_id, 9, 3)
		, NULL 
	from dbo.claimbase b, dbo.claimmeddet d
	where b.ec_ci_id = d.ec_ci_id
	and  b.ec_rec_id = d.ec_rec_id
	and  b.ec_pa_id = d.ec_pa_id
	and  b.ec_pa_rel = d.ec_pa_rel
	and  b.ec_sys_id = d.ec_sys_id
	and  b.ec_cl_id = d.ec_cl_id
	and  b.ec_cl_gen = d.ec_cl_gen
	and  b.Report_Date = d.Report_Date
	
	if @@error <> 0 return(3)
	
	update dbo.TEMPclaimsvcdate2
	set denied_ind = case when u.CHG > 0 and u.PAID = u.DIS then 'Y' else 'N' end
	from (	select a.ec_ci_id, a.ec_rec_id, a.ec_pa_id, a.ec_pa_rel, a.ec_sys_id, a.ec_cl_id, a.ec_cl_gen, a.Report_Date
		, sum( case when a.ec_rec_id = 'CB'
					then (a.cl_h_paid_01 + a.cl_h_paid_02) * -1
					else (a.cl_h_paid_01 + a.cl_h_paid_02)
					end ) as PAID
		, sum( case when a.ec_rec_id = 'CB'
					then a.cl_h_chg * -1
					else a.cl_h_chg
					end ) as CHG
		, sum( case when a.ec_rec_id = 'CB'
					then a.cl_h_disallow * -1
					else a.cl_h_disallow
					end ) as DIS
		from dbo.claimmeddet a
		group by a.ec_ci_id, a.ec_rec_id, a.ec_pa_id, a.ec_pa_rel, a.ec_sys_id, a.ec_cl_id, a.ec_cl_gen, a.Report_Date ) u
	where dbo.TEMPclaimsvcdate2.ec_ci_id = u.ec_ci_id
	And dbo.TEMPclaimsvcdate2.ec_rec_id = u.ec_rec_id
	And dbo.TEMPclaimsvcdate2.ec_pa_id = u.ec_pa_id
	And dbo.TEMPclaimsvcdate2.ec_pa_rel = u.ec_pa_rel
	And dbo.TEMPclaimsvcdate2.ec_sys_id = u.ec_sys_id
	And dbo.TEMPclaimsvcdate2.ec_cl_id = u.ec_cl_id
	And dbo.TEMPclaimsvcdate2.ec_cl_gen = u.ec_cl_gen
	And dbo.TEMPclaimsvcdate2.Report_Date = u.Report_Date 
	
	if @@error <> 0 return(4)
	
	-- Get the service date of dental claims
	insert dbo.TEMPclaimsvcdate2
	select b.ec_ci_id
		, b.ec_rec_id
		, b.ec_pa_id
		, b.ec_pa_rel
		, b.ec_sys_id
		, b.ec_cl_id
		, b.ec_cl_gen
		, b.Report_Date
		, d.indexkey
		, case when isdate(cl_d_f_mm + '/' + cl_d_f_dd + '/' + cl_cl_cc + cl_cl_yy) = 1
		 then cl_d_f_mm + '/' + cl_d_f_dd + '/' + cl_cl_cc + cl_cl_yy
		 else NULL
		 end
		, NULL
		, cd.cl_den_pr_spec + cd.cl_den_pr_spec_id
		, cd.cl_den_pr_spec + SUBSTRING(cd.cl_den_pr_spec_id,1,8)
		, SUBSTRING(cd.cl_den_pr_spec_id, 9, 3)
		, NULL
	from dbo.claimbase b, dbo.claimdentaldet d, dbo.claimdentalbase cd
	where b.ec_ci_id = d.ec_ci_id
	and  b.ec_rec_id = d.ec_rec_id
	and  b.ec_pa_id = d.ec_pa_id
	and  b.ec_pa_rel = d.ec_pa_rel
	and  b.ec_sys_id = d.ec_sys_id
	and  b.ec_cl_id = d.ec_cl_id
	and  b.ec_cl_gen = d.ec_cl_gen
	and  b.Report_Date = d.Report_Date
	and  b.ec_ci_id = cd.ec_ci_id
	and  b.ec_rec_id = cd.ec_rec_id
	and  b.ec_pa_id = cd.ec_pa_id
	and  b.ec_pa_rel = cd.ec_pa_rel
	and  b.ec_sys_id = cd.ec_sys_id
	and  b.ec_cl_id = cd.ec_cl_id
	and  b.ec_cl_gen = cd.ec_cl_gen
	and  b.Report_Date = cd.Report_Date
	
	if @@error <> 0 return(5)
	
	update dbo.TEMPclaimsvcdate2
	set denied_ind = case when u.CHG > 0 and u.PAID = u.DIS then 'Y' else 'N' end
	from (	select a.ec_ci_id, a.ec_rec_id, a.ec_pa_id, a.ec_pa_rel, a.ec_sys_id, a.ec_cl_id, a.ec_cl_gen, a.Report_Date
		, sum( case when a.ec_rec_id = 'CB'
					then (a.cl_d_paid) * -1
					else (a.cl_d_paid)
					end ) as PAID
		, sum( case when a.ec_rec_id = 'CB'
					then a.cl_d_chg * -1
					else a.cl_d_chg
					end ) as CHG
		, sum( case when a.ec_rec_id = 'CB'
					then a.cl_d_disallow * -1
					else a.cl_d_disallow
					end ) as DIS
		from dbo.claimdentaldet a
		group by a.ec_ci_id, a.ec_rec_id, a.ec_pa_id, a.ec_pa_rel, a.ec_sys_id, a.ec_cl_id, a.ec_cl_gen, a.Report_Date ) u
	where dbo.TEMPclaimsvcdate2.ec_ci_id = u.ec_ci_id
	And dbo.TEMPclaimsvcdate2.ec_rec_id = u.ec_rec_id
	And dbo.TEMPclaimsvcdate2.ec_pa_id = u.ec_pa_id
	And dbo.TEMPclaimsvcdate2.ec_pa_rel = u.ec_pa_rel
	And dbo.TEMPclaimsvcdate2.ec_sys_id = u.ec_sys_id
	And dbo.TEMPclaimsvcdate2.ec_cl_id = u.ec_cl_id
	And dbo.TEMPclaimsvcdate2.ec_cl_gen = u.ec_cl_gen
	And dbo.TEMPclaimsvcdate2.Report_Date = u.Report_Date 

	if @@error <> 0 return(6)

	declare @oldrecs as int
	declare @newrecs as int
	
	set @oldrecs = (select count(*)
		from dbo.claimsvcdate )
	
	set @newrecs = (select count(*)
		from dbo.TEMPclaimsvcdate)
	
	--if @oldrecs > @newrecs  return(5)	--print 'OOPS! Do NOT rename claimsvcdate table!'
	if 1 = 1 return(5)
	else 
	begin
		---Moved the creation of the index after the insert for performance. jpb 05/13/2008
		--	CREATE  CLUSTERED  INDEX [ClaimSvcDatePX] ON [dbo].[TEMPclaimsvcdate]([ec_ci_id], [Report_Date], [ec_rec_id], [ec_pa_id], [ec_pa_rel], [ec_sys_id], [ec_cl_id], [ec_cl_gen], [indexkey]) WITH  FILLFACTOR = 90 ON [PRIMARY]
		CREATE CLUSTERED INDEX [ClaimSvcDatePX] ON [dbo].[TEMPclaimsvcdate] 
		(
			[Service_From_Date] ASC, [ec_ci_id] ASC, [ec_rec_id] ASC, [ec_pa_id] ASC, [ec_sys_id] ASC, [ec_cl_id] ASC, [ec_cl_gen] ASC, [ec_pa_rel] ASC,
			[Report_Date] ASC, [indexkey] ASC
		) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

		CREATE NONCLUSTERED INDEX [ClaimSvcDateI1] ON [dbo].[TEMPclaimsvcdate] 
		(
			[ec_ci_id],[ec_rec_id],[ec_sys_id],[Service_From_Date]
		) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [INDEXES]

		-- print 'Renaming claimsvcdate tables...'
		exec sp_rename 'claimsvcdate','claimsvcdateTEMP'
		exec sp_rename 'TEMPclaimsvcdate','claimsvcdate'
		exec sp_rename 'claimsvcdateTEMP','TEMPclaimsvcdate'
	
	end

	return (0)

GO
