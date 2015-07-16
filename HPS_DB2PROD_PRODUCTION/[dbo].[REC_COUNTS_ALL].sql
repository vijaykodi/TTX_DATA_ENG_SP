/****** Object:  StoredProcedure [dbo].[REC_COUNTS_ALL]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[REC_COUNTS_ALL]
AS
BEGIN

	--exec HPS_DB2PROD_PRODUCTION.dbo.rec_counts
	--exec hps_vsam.dbo.rec_counts
	exec hps_ec.dbo.rec_counts
	--exec hps_nef.dbo.rec_counts
	--exec hps_dbpaid.dbo.rec_counts
	--exec hps_culinary.dbo.rec_counts
	--exec hps_avma.dbo.rec_counts
	--exec hillsboro.dbo.rec_counts
	--exec hps_scoreboard.dbo.rec_counts
	--exec hps_quotingsystem.dbo.rec_counts
	--exec solar_new.dbo.rec_counts
	--exec pharmacy.dbo.rec_counts

END

GO
