/****** Object:  StoredProcedure [dbo].[ClearProfiles]    Script Date: 7/14/2015 7:49:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ClearProfiles]
AS

BEGIN

 DELETE dba.Profiles WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

DELETE dba.ProfileFilters WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

DELETE dba.ProfileRelations WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

DELETE dba.ProfileReports WHERE profilename NOT IN (
 '_No Data', 'Barclaycard', 'Barclaycard Master Profile', 'ProfileReportMaster', 'BARCLAYS BANK PLC FR-0477355 + 124588344'
)

END
GO
