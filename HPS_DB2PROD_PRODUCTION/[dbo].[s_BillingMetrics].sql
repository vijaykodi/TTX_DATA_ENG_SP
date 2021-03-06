/****** Object:  StoredProcedure [dbo].[s_BillingMetrics]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dbo].[s_BillingMetrics](@AsofDate as datetime = '1/1/1900')
AS

	declare @fromdate datetime, @todate datetime

	select @AsofDate = case when @AsofDate = '1/1/1900' then dbo.last_of_month(dbo.midnight(getdate()), -1)
			else dbo.last_of_month(dbo.midnight(getdate()), -0) end,
		@fromdate = dbo.first_of_month( dbo.midnight(@AsofDate), 0),
		@todate = dbo.last_of_month( dbo.midnight(@AsofDate), 0)

	exec HPS_DB2PROD_PRODUCTION.dbo.s_HPS_ClaimsPaid @fromdate, @todate 
	exec HPS_DB2PROD_PRODUCTION.dbo.s_Membership @AsofDate


GO
