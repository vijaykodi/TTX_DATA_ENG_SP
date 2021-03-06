/****** Object:  StoredProcedure [dbo].[sp_dm_dx]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE   PROC [dbo].[sp_dm_dx]
	(
		@List varchar(2000),
		@SplitOn varchar(5),
		@carrier varchar(2)
	)  
AS  
BEGIN

	declare @aux table 
		(
			pa_id	varchar(12),
			dx	varchar(12),
			sex	varchar(1),
			min_yrmo varchar(6),
			max_yrmo varchar(6),
			min_age	int,
			max_age	int,
			claims	int,
			charges	decimal(12,2)
		)

   Insert into @aux
	Select e.ec_pa_ssn, d.cl_med_id_id_a, e.ec_pa_sex
		, min( dbo.yrmo(a.service_from_date))
		, max( dbo.yrmo(a.service_from_date))
		, min( dbo.emp_age( e.ec_pa_b_date, a.service_from_date))
		, max( dbo.emp_age( e.ec_pa_b_date, a.service_from_date))
		, count( distinct a.ec_cl_id + a.ec_cl_gen )
		, sum( b.cl_tot_chg )
	from dbo.claimsvcdate a, dbo.claimbase b, dbo.claimmedbase d, dbo.claimpatient e
	where a.ec_ci_id = @carrier
	and a.ec_rec_id = 'cl'
	and a.ec_sys_id = 'm' 
	and a.indexkey = 1
	and d.cl_med_id_id_a in (select value from dbo.Split( @List, @SplitOn) )
	and (( a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date
	and a.ec_ci_id = d.ec_ci_id
	and a.ec_rec_id = d.ec_rec_id
	and a.ec_pa_id = d.ec_pa_id
	and a.ec_pa_rel = d.ec_pa_rel
	and a.ec_sys_id = d.ec_sys_id
	and a.ec_cl_id = d.ec_cl_id
	and a.ec_cl_gen = d.ec_cl_gen
	and a.report_date = d.report_date
	and a.ec_ci_id = e.ec_ci_id
	and a.ec_rec_id = e.ec_rec_id
	and a.ec_pa_id = e.ec_pa_id
	and a.ec_pa_rel = e.ec_pa_rel
	and a.ec_sys_id = e.ec_sys_id
	and a.ec_cl_id = e.ec_cl_id
	and a.ec_cl_gen = e.ec_cl_gen
	and a.report_date = e.report_date ))
	group by e.ec_pa_ssn, d.cl_med_id_id_a, e.ec_pa_sex

    Insert Into dbo.dm_dx 
	Select dx, sex, min_yrmo, max_yrmo, min_age, max_age, claims, charges	
	from @aux
	
	Return
END

GO
