/****** Object:  StoredProcedure [dbo].[s_HPS_ClaimsPaid]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[s_HPS_ClaimsPaid]
	(
		@fromdate datetime = '',
		@todate datetime = ''
	)  

AS  
BEGIN

	declare @added_date datetime, @eyemed_fromdate datetime, @eyemed_todate datetime
	set @added_date = getdate()

	if coalesce(@fromdate, '') = '' 
		set @fromdate = dbo.first_of_month( dbo.midnight(getdate()), -1)
	if coalesce(@todate, '') = '' 
		set @todate = dbo.last_of_month( dbo.midnight(getdate()), -1)
	select @eyemed_fromdate = dbo.first_of_month( @fromdate, -1)
		, @eyemed_todate = dbo.last_of_month( @todate, -1)


	insert into HPS_DB2PROD_PRODUCTION.dbo.rs_HPS_PaidClaimsDet (carrier_group, carrier, claim_id, cl_status, cl_sys_id, report_date, added_date)
	select  '', c.ec_ci_id, c.ec_cl_id+c.ec_cl_gen, c.cl_status_1+c.cl_status_2, c.ec_sys_id, c.report_date, (@added_date)
		from hps_ec.dbo.claimbase c 
		Where c.report_date between @fromdate and @todate
			and c.cl_status_1+c.cl_status_2 in ('02', '91')
			and c.ec_rec_id = 'CL'
	order by 1,2 

	update HPS_DB2PROD_PRODUCTION.dbo.rs_HPS_PaidClaimsDet 
	set carrier_group = c.carrier_group
	from HPS_DB2PROD_PRODUCTION.dbo.CarrierGroups c inner join HPS_DB2PROD_PRODUCTION.dbo.rs_HPS_PaidClaimsDet b
	on c.carrier_code = b.carrier
	where c.claims_db is not null
	and b.carrier_group = ''
	and b.added_date = @added_date
 
	Return
END


GO
