/****** Object:  StoredProcedure [dbo].[s_Membership4]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[s_Membership4](@AsofDate as datetime = '1/1/1900')
AS

	DECLARE  @carrier_group varchar(120), @admin_db varchar(25), @carrier varchar(2), @claims_db varchar(25), @added_date datetime
	DECLARE @tranName varchar(12) 
	set nocount on

	set @tranName = 'A';
	if @AsofDate = '1/1/1900' set @AsofDate = dbo.last_of_month(dbo.midnight(getdate()), -1)
	set @added_date = getdate()

	exec dbo.s_MemberEligibility

	declare te cursor for
	    select carrier_group, carrier_code, admin_db from hps_db2prod_production.dbo.carriergroups 
		where claims_db = 'HPS_EC'
	open te
	fetch next from te into @carrier_group, @carrier, @admin_db

	while @@fetch_status = 0 
	begin
		
		if @admin_db is null
			or (@admin_db = 'vsam') --and not exists( select 1 from HPS_VSAM.DBO.VCASEM where CASE_HLTH_CARRIER = @carrier))
			or (@admin_db = 'db2prod' and not exists( select 1 from HPS_DB2PROD_PRODUCTION.DBO.CASE_MASTER where CARRIER_CODE = @carrier))
		begin
			begin tran @tranName
			
			INSERT INTO hps_db2prod_production.dbo.rs_MembershipDetail_temp
				Select @carrier_group AS "Carrier_Group"
					, d.me_ci_id AS "CARRIER" 
					, coalesce( hd.L1_case_num, left(d.me_id, 6)) as "CASE_NUM"
					, coalesce( hd.L4_case_num, left(d.me_id, 6)) as "L4_CASE_NUM"
					, left(d.me_id, 6) as "L5_CASE_NUM"
					, coalesce(case when isnumeric(d.me_ssn) = 1 then 
											case when d.me_ssn < 1000 then null 
												when d.me_ssn in (0, 100000000, 123456789) then null
											else d.me_ssn end
									when d.me_ssn in ('000000000','100000000','123456789') then null
								else d.me_ssn end, hd.L4_CASE_NUM, d.me_id) as "SSN"
				    , @AsofDate AS "AsofDate"
					, @added_date AS "ADDED_DATE"
					
				From dbo.claimbasemembereligibility d
					LEFT OUTER JOIN hps_db2prod_production.dbo.rs_hierarchydata hd
						On hd.case_num = left(d.me_id, 6)
						and hd.carrier_code = d.me_ci_id
				Where d.me_ci_id = @carrier
				and coalesce( hd.case_level, 5) = 5
				and exists( select 1 from dbo.MemberEligibility a 
					where a.me_ci_id = d.me_ci_id
						and a.me_id = d.me_id
						and a.me_elig_type not like '[NOP]%'
						and a.me_elig <= @AsofDate
						and not exists( select 1 from dbo.MemberEligibility b
					where b.me_ci_id = a.me_ci_id
						and b.me_id = a.me_id
						and b.me_elig_type like 'O%'
						and b.me_elig <= @AsofDate
						and b.me_elig > a.me_elig ))
				and not exists(select 1 from dbo.MemberEligibility c
						where c.me_ci_id = d.me_ci_id
						and c.me_id = d.me_id
						and c.me_elig_type like 'N%' )

			if @@error <> 0 rollback tran @tranName
			else commit tran @tranName
		end

		fetch next from te into @carrier_group, @carrier, @admin_db
		
	end
	
	close  te
	deallocate  te


GO
