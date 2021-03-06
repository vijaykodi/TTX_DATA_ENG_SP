/****** Object:  StoredProcedure [dbo].[s_UpdateDates]    Script Date: 7/14/2015 7:34:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC s_UpdateDates AS

UPDATE DBA.DateRange

SET	RangeBegDate = DATEADD(qq, DATEDIFF(qq,0,getdate()), 0)
	, RangeEndDate = CONVERT(CHAR(10), DATEADD(ms, -3,DATEADD(qq,1,DATEADD(qq, DATEDIFF(qq,0,getdate()), 0))), 101)

WHERE RangeName = 'CURR QUARTER'
--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate = DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)
	, RangeEndDate = Convert(CHAR(10), DATEADD(ms, -3,DATEADD(yy,1,DATEADD(yy, DATEDIFF(yy,0,getdate()), 0))), 101)

WHERE RangeName = 'CURR YEAR'
----------------------------------------------------------------------

--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
	, RangeEndDate = CONVERT(CHAR(10), DATEADD(ms, -3,DATEADD(mm,1,DATEADD(mm, DATEDIFF(mm,0,getdate()), 0))), 101)

WHERE RangeName = 'CURRENT'
----------------------------------------------------------------------

--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
	, RangeEndDate = CONVERT(CHAR(10), DATEADD(ms, -3,DATEADD(mm,1,DATEADD(mm, DATEDIFF(mm,0,getdate()), 0))), 101)

WHERE RangeName = 'Current Period'
----------------------------------------------------------------------

--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate = DATEADD(mm,-1, DATEADD(mm, DATEDIFF(mm,0,getdate()), 0))
	, RangeEndDate =  CONVERT(CHAR(10), DATEADD(ms,-3, DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)), 101)

WHERE RangeName = 'Previous Period'
----------------------------------------------------------------------

--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate = DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)
	, RangeEndDate = CONVERT(CHAR(10), DATEADD(dd, -1, getdate()),101)

WHERE RangeName = 'YTD'
----------------------------------------------------------------------

--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate =  DATEADD(dd,-8,DATEADD(wk, DATEDIFF(wk,0,getdate()), 0))
	, RangeEndDate =   DATEADD(dd,-2,DATEADD(wk, DATEDIFF(wk,0,getdate()), 0))

WHERE RangeName = 'LAST WEEK'
----------------------------------------------------------------------

--------------------------------------------------------------------
UPDATE DBA.DateRange

SET	RangeBegDate =  DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
	, RangeEndDate =   CONVERT(CHAR(10), DATEADD(dd, -1, getdate()),101)

WHERE RangeName = 'MTD'
----------------------------------------------------------------------

GO
