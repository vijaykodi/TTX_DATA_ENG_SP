/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetCategories]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure sp_cmreport_GetCategories 
as
   select -1 as id,'<ALL>' as category UNION select distinct evcatid as id,category from EventTypes where evcatid >= 0 and category <> 'Trace' order by category

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetCategories] TO [public] AS [dbo]
GO
