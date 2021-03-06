/****** Object:  StoredProcedure [dbo].[s_AnnualLicensing4]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[s_AnnualLicensing4](@ReportYear CHAR(4) = '0')
AS

	DECLARE @StartCount NUMERIC(9)
	DECLARE @EndCount NUMERIC(9)
	DECLARE  @carrier varchar(2)
	
	IF @ReportYear = '0' SET @ReportYear = YEAR(DATEADD(dd, -1, getdate()))

	declare te cursor for
	    select carrier_code from hps_db2prod_production.dbo.carriergroups where claims_db = 'HPS_EC'
	open te
	fetch next from te into @carrier

	while @@fetch_status = 0 
	begin
		
		begin transaction
		
		INSERT INTO hps_vsam.dbo.rs_AnnualLicensing2_temp
			SELECT hps_vsam.dbo.carrier_group( u.CARRIER, 'group') AS "Carrier_Group"
				, u.CARRIER as CARRIER_CODE
				, u.CASE_NUM
				, u.L5_CASE_NUM
				, u.[STATE]
				, null as "SSN"
				, 0 AS "COL_PREM_A"
				, 0 AS "COL_PREM_B"
				, u."PAID_CLAIMS_A"
				, u."PAID_CLAIMS_B"
				, u."PAID_CL_AMT_A"
				, u."PAID_CL_AMT_B"
				, @ReportYear AS "ReportYear"
			FROM ( 
				Select a.ec_ci_id AS "CARRIER" 
					, coalesce( hd.L1_case_num, left(a.ec_pa_id, 6)) as "CASE_NUM"
					, left(a.ec_pa_id, 6) as "L5_CASE_NUM"
					, coalesce(me_state, '') AS "STATE" 
					, count(distinct case when a.report_date between '1/1/' + @ReportYear and '6/30/' + @ReportYear 
							then a.ec_cl_id  else null end ) AS "PAID_CLAIMS_A" 
					, count(distinct case when a.report_date between '7/1/' + @ReportYear and '12/31/' + @ReportYear 
							then a.ec_cl_id  else null end ) AS "PAID_CLAIMS_B"
					, sum( case when a.report_date between '1/1/' + @ReportYear and '6/30/' + @ReportYear 
							then case when a.ec_rec_id = 'CB' then -1 else 1 end * a.cl_c_chk_amt else 0 end ) AS "PAID_CL_AMT_A"
					, sum( case when a.report_date between '7/1/' + @ReportYear and '12/31/' + @ReportYear 
							then case when a.ec_rec_id = 'CB' then -1 else 1 end * a.cl_c_chk_amt else 0 end ) AS "PAID_CL_AMT_B"
					
				From ( dbo.claimcheck a 
					LEFT OUTER JOIN dbo.claimbasemembereligibility d
						On d.me_id = a.ec_pa_id
						and d.me_ci_id = a.ec_ci_id ) 
					LEFT OUTER JOIN hps_db2prod_production.dbo.rs_hierarchydata hd
						On hd.case_num = left(a.ec_pa_id, 6)
						and hd.carrier_code = a.ec_ci_id
				Where a.ec_ci_id = @carrier
				and a.ec_rec_id = 'CL'
				and a.report_date between '1/1/' + @ReportYear and '12/31/' + @ReportYear
				and coalesce( hd.case_level, 5) = 5
				Group by a.ec_ci_id, coalesce( hd.L1_case_num, left(a.ec_pa_id, 6)), left(a.ec_pa_id, 6), coalesce(me_state, '') ) u

		commit
		
		fetch next from te into @carrier
		
	end
	
	close  te
	deallocate  te

GO
