/****** Object:  StoredProcedure [dbo].[REC_COUNTS]    Script Date: 7/14/2015 7:34:23 PM ******/
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

	set @dbname = 'HPS_EC'
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
	   AND convert(sysname,o.name) IN ('ADA_CLAIMITEMDETAIL', 'ADA_CLAIMLEVEL', 
	'CLAIMADMISSION', 'CLAIMADMISSIONFILLER', 
	'CLAIMADMISSIONDESC', 'CLAIMALTERNATEPAYEE',
	'CLAIMBASE', 'CLAIMBASEMEMBERELIGIBILITY', 'CLAIMBASEPATIENTELIGIBILITY',
	'CLAIMCHECK', 'CLAIMCUSTOM', 'CLAIMDENTALBASE', 'CLAIMDENTALDET', 
	'CLAIMDISABILITYBENEXPL', 'CLAIMDISABILITYFICAPARM', 'CLAIMDISABILITYFICPARMDET',
	'CLAIMDISABILITYITEM', 'CLAIMDISABILITYLASTCLAIM', 'CLAIMDISABILITYLET', 
	'CLAIMDISABILITYOVERRIDE', 'CLAIMDISABILITYPARM', 'CLAIMDISABILITYPERIOD',
	'CLAIMDISABILITYTOTALSTATUS', 'CLAIMDISALLOW', 'CLAIMEXTERNALBASE', 
	'CLAIMEXTERNALCOUNTER', 'CLAIMEXTERNALDESC', 'CLAIMEXTERNALDESCFILLER',
	'CLAIMEXTERNALITEM', 'CLAIMFILLER', 'CLAIMHOSPITAL', 'CLAIMHOSPITALUB', 
	'CLAIMINDICATOR', 'CLAIMLETTER', 'CLAIMLETTERDATA', 'CLAIMLETTERKEYVIOL',
	'CLAIMMEDBASE', 'CLAIMMEDDET', 'CLAIMMEMBER', 'CLAIMOVERRIDE', 
	'CLAIMPATIENT', 'CLAIMPATIENTCOB', 'CLAIMPATIENTFILLER', 'CLAIMPLANDATA',
	'CLAIMSPECIALTY', 'DENTALPROVIDERBASE', 'DENTALPROVIDERPLANDETAIL', 
	'DISABILITYPROVIDERBASE', 'HCFA_CLAIMITEMDETAIL', 'HCFA_CLAIMLEVEL', 'MEDICALPROVIDERBASE', 
	'UB_CLAIMITEMDETAIL', 'UBCLAIMLEVEL' )
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

	IF exists(select 1 from dbo.HPS_Rec_Counts_temp a LEFT OUTER JOIN hps_db2prod_production.dbo.HPS_Rec_Counts b
			ON a.table_name = b.table_name
			AND a.[DB_Name] = b.[DB_Name]
			where a.table_name = coalesce(b.table_name, 'OOPS')
			and a.[DB_Name] = @dbname
			and a.rec_count < coalesce(b.rec_count, -1)
			and not exists( select 1 from hps_db2prod_production.dbo.HPS_Rec_Counts c
							where c.[DB_Name] = b.[DB_Name]
							and c.table_name = coalesce(b.table_name, 'OOPS')
							and c.count_date > coalesce(b.count_date, '1/1/2070') ) )
		begin
			print 'Some tables have fewer records...'
			select * from dbo.HPS_Rec_Counts_temp a LEFT OUTER JOIN hps_db2prod_production.dbo.HPS_Rec_Counts b
				ON a.table_name = b.table_name
				AND a.[DB_Name] = b.[DB_Name]
				where a.table_name = coalesce(b.table_name, 'OOPS')
				and a.[DB_Name] = @dbname
				and a.rec_count < coalesce(b.rec_count, -1)
				and not exists( select 1 from hps_db2prod_production.dbo.HPS_Rec_Counts c
								where c.[DB_Name] = b.[DB_Name]
								and c.table_name = coalesce(b.table_name, 'OOPS')
								and c.count_date > coalesce(b.count_date, '1/1/2070') ) 
			return
		end
	ELSE
		insert into hps_db2prod_production.dbo.HPS_Rec_Counts
		select * from dbo.HPS_Rec_Counts_temp


END

GO
