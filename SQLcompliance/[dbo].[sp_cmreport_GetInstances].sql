/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetInstances]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure sp_cmreport_GetInstances 
as
select '<ALL>' as instance UNION select instance from Servers order by instance

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetInstances] TO [public] AS [dbo]
GO
