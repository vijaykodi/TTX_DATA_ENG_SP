/****** Object:  StoredProcedure [dbo].[sp_SWAT$Compare_Tbl_Cnt]    Script Date: 7/14/2015 8:11:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SWAT$Compare_Tbl_Cnt]
  @Server1	varchar(50)
, @DB1		varchar(100)
, @Server2	varchar(50)
, @DB2		varchar(100)
AS
BEGIN
	DECLARE @SQL as nvarchar(1000)

	create table #Rp1_short (Tb1 varchar(100), Cnt1 varchar(50))
	create table #Rp2_short (Tb2 varchar(100), Cnt2 varchar(50))
	create table #Rp1_long  (Svr1 varchar(100), Tb1 varchar(100), Cnt1 varchar(50))
	create table #Rp2_long  (Svr2 varchar(100), Tb2 varchar(100), Cnt2 varchar(50))

	set @SQL=N'insert into #Rp1_short exec ' + @Server1 + '.' + @DB1 +
	'.dbo.sp_MSforeachtable @command1=" select ' + char(39) + '?' + CHAR(39) +
	  ', count(*) from ?"';
	exec sp_executesql  @SQL
	SET @SQL=N'insert into #Rp1_long (Svr1, Tb1, Cnt1) SELECT ' +
	char(39) + @Server1 + '.'  + @DB1 + CHAR(39)+
	', a.Tb1,a.Cnt1 from #Rp1_short a'
	exec sp_executesql  @SQL

	set @SQL=N'insert into #Rp2_short exec ' + @Server2 + '.' + @DB2 +
	'.dbo.sp_MSforeachtable @command1=" select ' + char(39) + '?' + CHAR(39) +
	  ', count(*) from ?"';
	exec sp_executesql  @SQL
	SET @SQL=N'insert into #Rp2_long (Svr2, Tb2, Cnt2) SELECT ' +
	char(39) + @Server2 + '.'  + @DB2 + CHAR(39)+
	', b.Tb2,b.Cnt2 from #Rp2_short b'
	exec sp_executesql  @SQL

	 
	select a.Svr1, a.tb1
	, left(convert(varchar,convert(money, Cnt1),1), len(convert(varchar,convert(money, Cnt1),1)) -3)
	,b.Svr2,b.tb2
	,left(convert(varchar,convert(money, Cnt2),1), len(convert(varchar,convert(money, Cnt2),1)) -3)

	from #Rp1_long a full outer join 
	#Rp2_long b
	on a.tb1=b.tb2

	drop table #Rp1_short
	drop table #Rp2_short
	drop table #Rp1_long
	drop table #Rp2_long
END

GO
