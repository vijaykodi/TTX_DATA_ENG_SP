/****** Object:  StoredProcedure [dbo].[REC_COUNTS]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[REC_COUNTS]
AS
BEGIN

	declare @tables table ( qualifier varchar(50), [owner] varchar(12), 
		[tblname] varchar(120), colname varchar(120), colorder int, coltype int, typename varchar(60), 
		prec int, scale int, [length] int)

	declare @cnt_date datetime
	declare @tblname varchar(120), @stmt varchar(8000), @fstatus int, @dbname varchar(120)

	set @dbname = 'HPS_DB2PROD'
	set @cnt_date = getdate()	

	INSERT INTO  @tables
	SELECT  
	   TABLE_QUALIFIER = convert(sysname,DB_NAME()),  
	   TABLE_OWNER = convert(sysname,USER_NAME(o.uid)),  
	   TABLE_NAME = upper(convert(sysname,o.name)),  
	   COLUMN_NAME = upper(convert(sysname,c.name)), 
		COL_ORDER = c.colorder,
		[DATA_TYPE] = c.usertype,
		[TYPE_NAME] = t.name,
		[PRECISION] = c.prec,
		[SCALE] = c.[scale],
		[LENGTH] = c.length
    FROM  
	   sysobjects o,  
	   systypes t,  
	   syscolumns c  
	   LEFT OUTER JOIN syscomments m 
		on c.cdefault = m.id  
		AND m.colid = 1  
    WHERE  
		c.id = o.id  
	   AND (o.type not in ('P', 'FN', 'TF', 'IF') OR (o.type in ('TF', 'IF') and c.number = 0))  
	   AND c.xusertype = t.xusertype  
	   AND c.name like '%'  
	   AND convert(sysname,o.name) IN ('ADDRESS_HISTORY', 
		'AFFL_XREF', 'AG_CARRIERPRODUCTS', 'AGNTHIER','AGNTNAME', 'AIGPRODUCTDETAIL', 'APPT',
		'AVMA_EMI', 'AVMA_HSA_RATES', 'AVMA_PLAN_MAP',
		'BLOCK', 'BLRGCASE', 'BLRGCAT', 'BLRGPREM', 'BROKER', 'BROKER_XREF', 
		'CALLCENTERDATA', 'CARRIER', 'CARRIERGROUPS', 'CARRIERPARENTS',
		'CARRTOBLOK', 'CASE_BROKER', 'CASE_MASTER', 'CASE_POLICY_TYPE',
		'CASENAME', 'CASH_REPORT', 'CATMASTER', 'CATPEND', 'CHUBB_XREF', 'CODES', 'COMM',
		'CONTACT', 'CONTEXT', 'COVERAGE', 'COVERAGE_HISTORY', 'COVERAGE_VOLUME',
		'DEPENDENT', 'DEPENDENT_COVERAGE', 'ED_MBR_DOC', 'ED_MBR_MSTR',  
		'EMPLOYEE', 'EMPLOYEE_ADDRESS', 'EXCLUSION_RIDERS', 'FLD_FORCE', 
		'GRP_LISTBILL_DETL', 'GRP_LISTBILL_HIER', 'GRP_LISTBILL_SUMM', 'HIERARCHYDATA',
		'LICG_NAME', 'PAY_CALENDAR_DETAIL', 'PAY_CALENDAR_MASTER',
		'PYMTCASH', 'QUOTE_CASE', 'QUOTE_CASE_BROKER', 'QUOTE_CASE_STATUS',
		'QUOTE_COVER_STATUS', 'QUOTE_COVERAGE', 'RATE_ADJUSTMENT',
		'STATE_COUNTY_ZIP', 'STATS', 'TURBO052', 'TURBO074', 'TURBO224', 'TURBO225', 
		'TURBO457', 'TURBO464', 'TURBO74', 'TURBOBASELEVELS', 'TURBODESC', 'TURBORATEREC', 'UWCENSUS' )
	ORDER BY 1,2,3,5

	declare t_cursor cursor for
	  select distinct tblname from @tables  

	truncate table dbo.HPS_Rec_Counts_temp

	open t_cursor
	fetch next from t_cursor
		into @tblname
	set @fstatus = @@FETCH_STATUS

	WHILE  @fstatus = 0
	BEGIN 
		set @stmt = 'select getdate(), ''' + @dbname + ''', ''' + @tblname + ''', count(*) from dbo.' + @tblname	
		insert into dbo.HPS_Rec_Counts_temp
		exec (@stmt)
		fetch next from t_cursor into @tblname
		set @fstatus = @@FETCH_STATUS
	END

	close t_cursor
	deallocate t_cursor

	IF exists(select 1 from dbo.HPS_Rec_Counts_temp a LEFT OUTER JOIN HPS_DB2PROD_PRODUCTION.dbo.HPS_Rec_Counts b
			ON a.table_name = b.table_name
			AND a.[DB_Name] = b.[DB_Name]
			where a.table_name = coalesce(b.table_name, 'OOPS')
			and a.[DB_Name] = @dbname
			and a.rec_count < coalesce(b.rec_count, -1)
			and not exists( select 1 from HPS_DB2PROD_PRODUCTION.dbo.HPS_Rec_Counts c
							where c.[DB_Name] = b.[DB_Name]
							and c.table_name = coalesce(b.table_name, 'OOPS')
							and c.count_date > coalesce(b.count_date, '1/1/2070') ) )
		begin
			print 'Some tables have fewer records...'
			select * from dbo.HPS_Rec_Counts_temp a LEFT OUTER JOIN HPS_DB2PROD_PRODUCTION.dbo.HPS_Rec_Counts b
				ON a.table_name = b.table_name
				AND a.[DB_Name] = b.[DB_Name]
				where a.table_name = coalesce(b.table_name, 'OOPS')
				and a.[DB_Name] = @dbname
				and a.rec_count < coalesce(b.rec_count, -1)
				and not exists( select 1 from HPS_DB2PROD_PRODUCTION.dbo.HPS_Rec_Counts c
								where c.[DB_Name] = b.[DB_Name]
								and c.table_name = coalesce(b.table_name, 'OOPS')
								and c.count_date > coalesce(b.count_date, '1/1/2070') ) 
			return
		end
	ELSE
		insert into HPS_DB2PROD_PRODUCTION.dbo.HPS_Rec_Counts
		select * from dbo.HPS_Rec_Counts_temp


END

GO
