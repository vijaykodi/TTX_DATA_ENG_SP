/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetDateTypes]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure sp_cmreport_GetDateTypes 
as
   SELECT 'Custom' as DisplayName, '0' as DisplayValue UNION
   SELECT 'Yesterday', '1' UNION 
   SELECT 'Last Week', '2' UNION
   SELECT 'Last Month', '3' UNION
   SELECT 'Today', '4' UNION
   SELECT 'This Week', '5' UNION
   SELECT 'This Month', '6' UNION
   SELECT 'This Quarter', '7' UNION
   SELECT 'Last Quarter', '8' ORDER BY DisplayValue

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetDateTypes] TO [public] AS [dbo]
GO
