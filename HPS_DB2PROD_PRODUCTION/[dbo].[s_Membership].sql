/****** Object:  StoredProcedure [dbo].[s_Membership]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE   PROC [dbo].[s_Membership](@AsofDate as datetime = '1/1/1900')
AS

	SET NOCOUNT ON
	DECLARE  @carrier varchar(2), @claims_db varchar(16), @added_date datetime

	if @AsofDate = '1/1/1900' set @AsofDate = dbo.last_of_month(dbo.midnight(getdate()), -1)
	select @added_date = getdate()

	truncate table HPS_DB2PROD_PRODUCTION.dbo.rs_MembershipDetail_temp

	 --DB2PROD Cases
	print 'DB2PROD';

	declare td cursor for
		select carrier_code, claims_db from hps_db2prod_production.dbo.carriergroups where admin_db = 'db2prod'
	open td
	fetch next from td into @carrier, @claims_db

	while @@fetch_status = 0 
	begin
		begin transaction
		print @carrier
		commit 
		
		begin transaction
		
		INSERT INTO HPS_DB2PROD_PRODUCTION.dbo.rs_MembershipDetail_temp
			SELECT 	dbo.carrier_group2( CASEMSTR.CARRIER_CODE, 'group') AS "Carrier_Group"
				    , CASEMSTR.CARRIER_CODE AS "Carrier_Code"
				    , coalesce(hd.L1_CASE_NUM, CASEMSTR.CASE_NUM) AS "Case_Num"
				    , coalesce(hd.L4_CASE_NUM, CASEMSTR.CASE_NUM) AS "L4_Case_Num"
				    , CASEMSTR.CASE_NUM AS "L5_Case_Num"
					, case when EMPLOYEE.CARRIER is null then null
						else coalesce(cast(case when EMPLOYEE.SSN < 1000 then null 
											when EMPLOYEE.SSN in ('999999999','100000000','123456789') then null
											else EMPLOYEE.SSN end as varchar(12)), 
										hd.L4_CASE_NUM, CASEMSTR.CASE_NUM + dbo.fixed_len_int(EMPLOYEE.EMP_NUM, 3)) 
						end AS "SSN"
				    , @AsofDate AS "AsofDate"
					, @added_date AS ADDED_DATE
			 FROM (((( HPS_DB2PROD_PRODUCTION.DBO.CASENAME CASENAME INNER JOIN HPS_DB2PROD_PRODUCTION.DBO.CASE_MASTER CASEMSTR
						ON CASENAME.CIM = CASEMSTR.CASENAME#CIM ) 
					LEFT OUTER JOIN HPS_DB2PROD_PRODUCTION.DBO.rs_HierarchyData hd
						ON hd.case_num = CASEMSTR.CASE_NUM ) 
					LEFT OUTER JOIN HPS_DB2PROD_PRODUCTION.DBO.EMPLOYEE EMPLOYEE
						ON EMPLOYEE.CARRIER = CASEMSTR.CARRIER_CODE
						AND EMPLOYEE.CASE_NUM = CASEMSTR.CASE_NUM ) 
					LEFT OUTER JOIN HPS_DB2PROD_PRODUCTION.DBO.CASE_MASTER CASEMSTR2
						ON CASEMSTR2.CASE_NUM = hd.L1_CASE_NUM )
					LEFT OUTER JOIN HPS_DB2PROD_PRODUCTION.DBO.CASENAME CASENAME2
						ON CASENAME2.CIM = CASEMSTR2.CASENAME#CIM
			 WHERE (( isnull( CASEMSTR.CARRIER_CODE, '') not in ('', '9D', '00')
			   AND  dbo.case_effin_lite( @AsofDate, @AsofDate, 
					CASEMSTR.CASE_NUM, CASEMSTR.ACTIVE_CODE, CASEMSTR.REENTRY_DATE, CASEMSTR.INCEPTION_DATE, CASEMSTR.TERM_DATE ) = 'true'))
			   AND CASEMSTR.CARRIER_CODE = @carrier
			   AND coalesce(hd.case_level,5) = 5
			   AND dbo.emp_effin_lite(@AsofDate, @AsofDate, EMPLOYEE.REENTRY_DATE, EMPLOYEE.EFFECTIVE_DATE, EMPLOYEE.TERM_DATE ) = 'true'		
		
		commit
		
		fetch next from td into @carrier, @claims_db
	end

	close  td
	deallocate  td

	 --Claims   
	
	print 'EC Claims';
	execute HPS_EC.dbo.s_Membership4 @AsofDate

	 --Updates   
	print 'Updates';
	
	BEGIN TRANSACTION		
		INSERT INTO HPS_DB2PROD_PRODUCTION.dbo.rs_MembershipDetail
			SELECT * FROM HPS_DB2PROD_PRODUCTION.dbo.rs_MembershipDetail_temp
			ORDER BY Carrier_Group, Carrier_Code, Case_Num
	COMMIT;
	








GO
