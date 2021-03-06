/****** Object:  StoredProcedure [dbo].[sp_UBS_Americas_EMEA_Viewed]    Script Date: 7/14/2015 7:39:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_UBS_Americas_EMEA_Viewed]


-- Update Americas and EMEA with "Already seen" flag in Text 11 at 9:30 AM on Tuesday and Thursday
as

update c
set text11 = 'Y', text16 = getdate()
from dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.recordkey = ih.recordkey
and i.voidind = 'N'
and i.refundind = 'N'
and i.exchangeind = 'N'
and i.remarks2 <> 'Unknown'
and isnull(text21,'xx') not like '%hold%'
and i.iatanum = 'Preubs'
and text5  in ('Europe EMEA','Switzerland','UK','Americas')
and importdt <= getdate()
and text11 is null



GO
