/****** Object:  StoredProcedure [dbo].[sp_cmreport_GetAuditActivityGraph]    Script Date: 7/14/2015 7:35:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure sp_cmreport_GetAuditActivityGraph (
	@eventDatabase nvarchar(256), 
	@startDate datetime, 
	@endDate datetime, 
	@databaseName nvarchar(50)
)
as
begin

declare @stmt nvarchar(2000)
declare @selectClause nvarchar(2000)
declare @fromClause nvarchar(500)
declare @whereClause nvarchar(1000)
declare @groupbyClause nvarchar(500)
declare @startDateStr nvarchar(40);
declare @endDateStr nvarchar(40);

    -- Process input
	set @startDateStr = dbo.fn_cmreport_GetDateString(@startDate);
	set @endDateStr = dbo.fn_cmreport_GetDateString(@endDate);

   -- prevents sql injection but set limitations on the database naming
   set @eventDatabase = dbo.fn_cmreport_ProcessString(@eventDatabase);
   set @databaseName = UPPER(dbo.fn_cmreport_ProcessString(@databaseName));

set @selectClause = 'SELECT 
    DateAdd(Millisecond, -DatePart(MilliSecond, startTime), DateAdd(Second, -DatePart(Second, startTime), DateAdd(Minute, -DatePart(Minute, startTime),startTime)))  UTCCollectionDateTime,  
    COUNT(DateAdd(Millisecond, -DatePart(MilliSecond, startTime), DateAdd(Second, -DatePart(Second, startTime), DateAdd(Minute, -DatePart(Minute, startTime),startTime))))  DataCount'
set @fromClause = ' FROM [' + @eventDatabase + '].dbo.Events'
set @whereClause = ' WHERE startTime >= CONVERT(DATETIME, ''' + @startDateStr + ''') and startTime <= CONVERT(DATETIME, ''' + @endDateStr + ''') ';
if @databaseName <> '%'
    set @whereClause = @whereClause + ' AND  UPPER(databaseName) like ''' + @databaseName + ''''
set @groupbyClause = ' GROUP BY (DateAdd(Millisecond, -DatePart(MilliSecond, startTime), DateAdd(Second, -DatePart(Second, startTime), DateAdd(Minute, -DatePart(Minute, startTime),startTime)))) ORDER BY UTCCollectionDateTime'

set @stmt = @selectClause + @fromClause + @whereClause + @groupbyClause

EXEC(@stmt)
end

GO
GRANT EXECUTE ON [dbo].[sp_cmreport_GetAuditActivityGraph] TO [public] AS [dbo]
GO
