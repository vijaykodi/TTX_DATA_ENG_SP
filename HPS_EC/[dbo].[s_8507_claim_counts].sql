/****** Object:  StoredProcedure [dbo].[s_8507_claim_counts]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Report 8507

-- Returns number of claims, months, and average number of claims per month
-- 	for each provider TIN

-- Number of months is just the months with some claim; do not count months w/o a claim

CREATE    PROC [dbo].[s_8507_claim_counts]( @from_paid datetime = '6/1/2009', 
	@to_paid datetime = '8/31/2009' )
AS
BEGIN

	set nocount on

	truncate table hps_ec.dbo.rs_CLAIM_COUNTS

	-- HPS_EC

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_h_pr_tax_id, ec_h_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_h_pr_name, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_h_pr_city, '') )
			+ '|' + rtrim( isnull(ec_h_pr_state, '') )
			+ '|' + rtrim( isnull(ec_h_pr_zip13_9, '') )
				+ left( isnull(ec_h_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_h_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_h_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_ec.dbo.claimbase a, hps_ec.dbo.medicalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and b.indexkey = 1
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date
	
	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_den_pr_tax_id, ec_den_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_den_pr_name, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_den_pr_city, '') )
			+ '|' + rtrim( isnull(ec_den_pr_state, '') )
			+ '|' + rtrim( isnull(ec_den_pr_zip13_9, '') )
				+ left( isnull(ec_den_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_den_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_den_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_ec.dbo.claimbase a, hps_ec.dbo.dentalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

	-- HPS_NEF

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_h_pr_tax_id, ec_h_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_h_pr_name, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_h_pr_city, '') )
			+ '|' + rtrim( isnull(ec_h_pr_state, '') )
			+ '|' + rtrim( isnull(ec_h_pr_zip13_9, '') )
				+ left( isnull(ec_h_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_h_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_h_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_nef.dbo.claimbase a, hps_nef.dbo.medicalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and b.indexkey = 1
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_den_pr_tax_id, ec_den_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_den_pr_name, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_den_pr_city, '') )
			+ '|' + rtrim( isnull(ec_den_pr_state, '') )
			+ '|' + rtrim( isnull(ec_den_pr_zip13_9, '') )
				+ left( isnull(ec_den_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_den_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_den_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_nef.dbo.claimbase a, hps_nef.dbo.dentalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

	-- HPS_DBPAID

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_h_pr_tax_id, ec_h_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_h_pr_name, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_h_pr_city, '') )
			+ '|' + rtrim( isnull(ec_h_pr_state, '') )
			+ '|' + rtrim( isnull(ec_h_pr_zip13_9, '') )
				+ left( isnull(ec_h_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_h_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_h_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_dbpaid.dbo.claimbase a, hps_dbpaid.dbo.medicalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and b.indexkey = 1
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_den_pr_tax_id, ec_den_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_den_pr_name, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_den_pr_city, '') )
			+ '|' + rtrim( isnull(ec_den_pr_state, '') )
			+ '|' + rtrim( isnull(ec_den_pr_zip13_9, '') )
				+ left( isnull(ec_den_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_den_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_den_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_dbpaid.dbo.claimbase a, hps_dbpaid.dbo.dentalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

	-- HPS_CULINARY

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_h_pr_tax_id, ec_h_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_h_pr_name, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_h_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_h_pr_city, '') )
			+ '|' + rtrim( isnull(ec_h_pr_state, '') )
			+ '|' + rtrim( isnull(ec_h_pr_zip13_9, '') )
				+ left( isnull(ec_h_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_h_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_h_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_culinary.dbo.claimbase a, hps_culinary.dbo.medicalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and b.indexkey = 1
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

	insert into hps_ec.dbo.rs_CLAIM_COUNTS
	
	select TIN = dbo.ssn( isnull( ec_den_pr_tax_id, ec_den_pr_ssn ) )
		, TYPE = case when left(a.ec_cl_id, 1) = 'E' and isnull( a.cl_user_field_b, '') = '' then 'EDI'
				else 'PAPER' end
-- 		, TYPE = case when a.cl_edi_trade_part = 'IMG' then 'Imaged'
-- 			when isnull(rtrim(a.cl_edi_trade_part), '') = '' then 'Paper'
-- 			else 'EDI'
-- 			end
		, PNAME = convert( varchar(12), a.report_date, 112) 
			+ '|' + rtrim( isnull(ec_den_pr_name, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr1, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr2, '') )
			+ '|' + rtrim( isnull(ec_den_pr_addr3, '') )
			+ '|' + rtrim( isnull(ec_den_pr_city, '') )
			+ '|' + rtrim( isnull(ec_den_pr_state, '') )
			+ '|' + rtrim( isnull(ec_den_pr_zip13_9, '') )
				+ left( isnull(ec_den_pr_zip49, ''), 2 )
				+ case when rtrim( '-' + right( isnull(ec_den_pr_zip49, ''), 4) ) = '-' then ''
					else '-' + right( isnull(ec_den_pr_zip49, ''), 4) end 
		, CLAIM =  a.ec_ci_id + a.ec_cl_id + a.ec_cl_gen 
		, YRMO = dbo.YRMO( a.Report_Date ) 
	
	from hps_culinary.dbo.claimbase a, hps_culinary.dbo.dentalproviderbase b
	
	where a.cl_status_1 + a.cl_status_2 = '02'
	and a.report_date between @from_paid and @to_paid
	and a.ec_ci_id = b.ec_ci_id
	and a.ec_rec_id = b.ec_rec_id
	and a.ec_pa_id = b.ec_pa_id
	and a.ec_pa_rel = b.ec_pa_rel
	and a.ec_sys_id = b.ec_sys_id
	and a.ec_cl_id = b.ec_cl_id
	and a.ec_cl_gen = b.ec_cl_gen
	and a.report_date = b.report_date

END

GO
