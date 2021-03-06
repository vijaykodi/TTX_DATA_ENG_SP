/****** Object:  StoredProcedure [dbo].[hps_stats]    Script Date: 7/14/2015 7:34:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE       proc [dbo].[hps_stats]
as

	set nocount on
	
	declare @tables table ( qualifier varchar(50), owner varchar(12), 
		tblname varchar(120), colname varchar(120), coltype int, typename varchar(60))
	
	insert into  @tables
	SELECT  
	   TABLE_QUALIFIER = convert(sysname,DB_NAME()),  
	   TABLE_OWNER = convert(sysname,USER_NAME(o.uid)),  
	   TABLE_NAME = convert(sysname,o.name),  
	   COLUMN_NAME = convert(sysname,c.name),  
	   d.DATA_TYPE,  
	   convert (sysname,case  
	    when t.xusertype > 255 then t.name  
	    else d.TYPE_NAME collate database_default  
	   end) TYPE_NAME  --,  
	  FROM  
	   sysobjects o,  
	   master.dbo.spt_datatype_info d,  
	   systypes t,  
	   syscolumns c  
	   LEFT OUTER JOIN syscomments m on c.cdefault = m.id  
	    AND m.colid = 1  
	  WHERE  
	    c.id = o.id  
	   AND t.xtype = d.ss_dtype  
	   AND c.length = isnull(d.fixlen, c.length)  
	   AND (d.ODBCVer is null or d.ODBCVer = 2)  
	   AND (o.type not in ('P', 'FN', 'TF', 'IF') OR (o.type in ('TF', 'IF') and c.number = 0))  
	   AND isnull(d.AUTO_INCREMENT,0) = isnull(ColumnProperty (c.id, c.name, 'IsIdentity'),0)  
	   AND c.xusertype = t.xusertype  
	   AND c.name like '%'  
	   AND d.DATA_TYPE IN ( 2, 3, 4, 6)
	   AND convert(sysname,o.name)  IN ('VCASEM', 'VEMP', 'VCASEFIN',
		'ADDRESS_HISTORY', 'AFFL_XREF', 'AGNTNAME', 'APPT',
		'AVMA_EMI', 'AVMA_HSA_RATES', 'AVMA_PLAN_MAP',
		'BLOCK', 'BLRGCASE', 'BLRGPREM', 'BROKER', 'BROKER_XREF', 
		'CALLCENTERDATA', 'CARRIER', 'CARRIERGROUPS', 'CARRIERPARENTS',
		'CARRTOBLOK', 'CASE_BROKER', 'CASE_MASTER', 'CASE_POLICY_TYPE',
		'CASENAME', 'CASH_REPORT', 'CATMASTER', 'CAT_PEND_NOTE', 'CHUBB_XREF', 'CODES', 'COMM',
		'CONTACT', 'CONTEXT', 'COVERAGE', 
		'COVERAGE_HISTORY', 'COVERAGE_VOLUME',
		'DEPENDENT', 'DEPENDENT_COVERAGE', 'DTPROPERTIES', 
		'EMPLOYEE', 'EMPLOYEE_ADDRESS', 'FLD_FORCE', 'GRP_LISTBILL_HIER', 'HIERARCHYDATA', 'RS_HIERARCHYDATA',
		'LIGG_NAME', 'PAY_CALENDAR_DETAIL', 'PAY_CALENDAR_MASTER',
		'PYMTCASH', 'QUOTE_CASE', 'QUOTE_CASE_BROKER', 'QUOTE_CASE_STATUS',
		'QUOTE_COVER_STATUS', 'QUOTE_COVERAGE', 'RATE_ADJUSTMENT',
		'STATE_COUNTY_ZIP', 'STATS',
		'AIG_PENDED_DEL', 'AIG_SERVICECODE',
		'AIGCLAIMSDATADETAIL_P2', 'AIGCLAIMSDATAHEADER_P2',
		'AIGCLAIMSDATADETAIL', 'AIGCLAIMSDATAHEADER', 'AIGCLAIMSDATAPREMIUMS',
		'BASYS_TYPE_A', 'BASYS_TYPE_D', 'BASYS_TYPE_E', 'BASYS_TYPE_F',
		'BASYS_TYPE_G', 'BASYS_TYPE_H', 'BASYS_TYPE_I', 'BASYS_TYPE_J',
		'BASYS_TYPE_T', 'BASYS_TYPE_Z',
		'CLAIMBILLING', 'CLAIMCOMMENT', 'CLAIMDEDUCTIBLE', 'CLAIMDENTAL',
		'CLAIMHEADER', 'CLAIMINELIGIBLE', 'CLAIMLOADCOUNT',
		'CLAIMPAYTYPE',  
		'CLAIMADMISSION', 'CLAIMADMISSIONFILLER', 
		'CLAIMADMISSIONDESC', 'CLAIMALTERNATEPAYEE',
		'CLAIMBASE', 'CLAIMBASEMEMBERELIGIBILITY', 'CLAIMBASEPATIENTELIGIBILITY',
		'CLAIMCHECK', 
		'CLAIMCHECKADJUSTMENTSABPA', 'CLAIMCHECKFOOTERABPA', 'CLAIMCHECKVOIDSABPA',
		'CLAIMCHECKREFUNDSABPA',
		'CLAIMCUSTOM', 'CLAIMDENTALBASE', 'CLAIMDENTALDET', 
		'CLAIMDISABILITYBENEXPL', 'CLAIMDISABILITYFICAPARM', 'CLAIMDISABILITYFICPARMDET',
		'CLAIMDISABILITYITEM', 'CLAIMDISABILITYLASTCLAIM', 'CLAIMDISABILITYLET', 
		'CLAIMDISABILITYOVERRIDE', 'CLAIMDISABILITYPARM', 'CLAIMDISABILITYPERIOD',
		'CLAIMDISABILITYTOTALSTATUS', 'CLAIMDISALLOW', 'CLAIMEXTERNALBASE', 
		'CLAIMEXTERNALCOUNTER', 'CLAIMEXTERNALDESC', 'CLAIMEXTERNALDESCFILLER',
		'CLAIMEXTERNALITEM', 'CLAIMFILLER', 'CLAIMHOSPITAL', 'CLAIMHOSPITALUB', 
		'CLAIMINDICATOR', 'CLAIMLETTER', 'CLAIMLETTERDATA', 'CLAIMLETTERKEYVIOL',
		'CLAIMMEDBASE', 'CLAIMMEDDET', 'CLAIMMEMBER', 'CLAIMOVERRIDE', 
		'CLAIMPATIENT', 'CLAIMPATIENTCOB', 'CLAIMPATIENTFILLER',
		 'CLAIMPLANDATA',
		'CLAIMSPECIALTY', 'CLAIMSVCDATE', 
		'DENTALPROVIDERBASE', 'DENTALPROVIDERPLANDETAIL', 'DENTALSVCCODES',
		'DISABILITYPROVIDERBASE', 'MEDICALPROVIDERBASE',
		'PHARMACYCLAIMBASE', 'PHARMACYCOST', 'PHARMACYMEMBER', 'PHARMACYPATIENT',
		'PHARMACYPHYSICIAN', 'PHARMACYPROVIDERBASE', 'PREMIUMDATA_CASE',
		'PREMIUMDATA_EMPLOYEE', 'PREMIUMDATA_MONTHLY', 'REPRICEDINQUIRY',
		'SUBROGATIONLIENS')
	
	declare t_cursor cursor for
	  select distinct tblname from @tables
	
	declare @tblname varchar(120), @colname varchar(120)
	declare @stmt varchar(8000), @res varchar(6000), @token varchar(250)
	declare @colval varchar(120), @cval numeric (20, 4)
	declare @numcols int, @colnum int, @fstatus int
	declare @from int, @to int, @f int, @t int
	
	
	open t_cursor
	fetch next from t_cursor
		into @tblname
	set @fstatus = @@FETCH_STATUS
	
	WHILE  @fstatus = 0
	BEGIN
		declare c_cursor cursor for
		  select colname from @tables where tblname = @tblname
		open c_cursor
		fetch next from c_cursor into @colname
		set @stmt = 'select getdate(), ''reccount='' + cast(count(*) as varchar(12))'
		WHILE  @@FETCH_STATUS = 0
		BEGIN
			set @stmt = @stmt + ' + ''|' + @colname + '='' + cast(sum(cast(' + @colname + ' as numeric(20,4)) ) as varchar(32))'
			fetch next from c_cursor into @colname
		END
		close c_cursor
		deallocate c_cursor
		set @stmt = @stmt + ' from dbo.' + @tblname
		
	-- 	print @stmt
	
		truncate table dbo.Peter_Counts_temp
		insert into dbo.Peter_Counts_temp
		exec (@stmt)
		set @res = (select top 1 results from dbo.Peter_Counts_temp)
	
		if @@error <> 0 
		begin
			raiserror(' General error ...on Peter_Counts_temp', -1, -1)
			return (1)
		end
		
		set @from = 1
		select @to = charindex('|', @res, @from) 
		while @to <> 0
		begin
			set @token = substring( @res, @from, @to - @from)
			set @f = 1
			select @t = charindex('=', @token, @f)
			if @t <> 0
			begin
				set @colname = substring(@token, @f, @t-1)
				set @colval = substring(@token, @t+1, len(@token)-@t)
-- 				print 'colname = ' + @colname
-- 				print 'colval = ' + @colval
				if isnumeric(@colval) = 1
				begin
					insert into dbo.Peter_Counts2
					select getdate(), @tblname, @colname, cast( @colval as numeric (20,4))
				end
				if @@error <> 0 
				begin
					raiserror(' General error ...on Peter_Counts2', -1, -1)
					return (1)
				end
			end
	
			set @from = @to + 1
			select @to = charindex('|', @res, @from) 
		end
		set @to = len(@res)
	
-- 		print substring( @res, @from, @to - @from)
	
		set @token = substring( @res, @from, @to-@from)
		set @f = 1
		select @t = charindex('=', @token, @f)
		if @t <> 0
		begin
			set @colname = substring(@token, @f, @t-1)
			set @colval = substring(@token, @t+1, len(@token)-@t)
-- 			print 'colname = ' + @colname
-- 			print 'colval = ' + @colval
			if isnumeric(@colval) = 1
			begin
				insert into dbo.Peter_Counts2
				select getdate(), @tblname, @colname, cast( @colval as numeric (20,4))
			end
		end
	
		
		fetch next from t_cursor into @tblname
		set @fstatus = @@FETCH_STATUS
	
	END
	
-- 	print ''
	
	close t_cursor
	deallocate t_cursor

	return (0)

GO
