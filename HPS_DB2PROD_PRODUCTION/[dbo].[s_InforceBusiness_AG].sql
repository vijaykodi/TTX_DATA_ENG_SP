/****** Object:  StoredProcedure [dbo].[s_InforceBusiness_AG]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE      proc [dbo].[s_InforceBusiness_AG]
as
set nocount on
	
	declare @count as int, @prev_count as int

	truncate table HPS_DB2PROD_PRODUCTION.dbo.rs_InforceBusiness_AG_temp

begin transaction
	insert into HPS_DB2PROD_PRODUCTION.dbo.rs_InforceBusiness_AG_temp
		SELECT CVGHIST.CARRIER AS "S13_CARRIER"
			,CVGHIST.CASE_NUM AS "S13_CASE_NUM"
			,CVGHIST.EMP_NUM AS "S13_EMP_NUM"
			,SUM(( case when isnumeric(CVGHIST.COV_VALUE) = 0 then 0.00     
			   when substring(CVGHIST.COV_VALUE,1,1) = '$'     
			   then cast(substring(CVGHIST.COV_VALUE,2,len(CVGHIST.COV_VALUE)-1) as float)    
			   else cast(CVGHIST.COV_VALUE as float)    
			   end ) /    
			   ( case when CVGHIST.COV_VALUE like '%.%' then 1.00    
				 else 100.00 end ) * 12) AS "S13_ANLZD_AMOUNT"

		 FROM DBO.AG_CarrierProducts AG_CarrierProducts,DBO.CASE_MASTER CASEMSTR,DBO.COVERAGE_HISTORY CVGHIST,DBO.EMPLOYEE EMPLOYEE
		 WHERE ((CASEMSTR.CARRIER_CODE in ('CR', 'MI', 'NX', 'NG', 'WF', 'NJ', 'NA', 'AD', 'DN', 'NH', 'UD', 
					'LD', 'LI', 'DC', 'DI', 'IW', 'NC', 'NI', 'NP', 'NQ', 'NS', 'UT', 'VI', 'CN', 'CX')))
		   AND ((CASEMSTR.CARRIER_CODE in ('CR', 'MI', 'NX', 'NG', 'WF', 'NJ', 'NA', 'AD', 'DN', 'NH', 'UD', 
					'LD', 'LI', 'DC', 'DI', 'IW', 'NC', 'NI', 'NP', 'NQ', 'NS', 'UT', 'VI', 'CN', 'CX')
		   AND CASEMSTR.CASE_NUM not in ('000000','','999999')
		   AND AG_CarrierProducts.Carrier_Code = CASEMSTR.CARRIER_CODE
		   AND  not exists(select 1 from dbo.AG_CarrierProducts b
							where b.carrier_code = AG_CarrierProducts.Carrier_Code
							and b.product_code = AG_CarrierProducts.Product_Code
							and b.product = AG_CarrierProducts.Product
							and b.size < AG_CarrierProducts.Size )
		   AND EMPLOYEE.CARRIER = CASEMSTR.CARRIER_CODE
		   AND EMPLOYEE.CASE_NUM = CASEMSTR.CASE_NUM
		   AND EMPLOYEE.OPTION_CODE like  AG_CarrierProducts.Product_Code 
		   AND CVGHIST.CARRIER = CASEMSTR.CARRIER_CODE
		   AND CVGHIST.CASE_NUM = CASEMSTR.CASE_NUM
		   AND CVGHIST.EMP_NUM = EMPLOYEE.EMP_NUM
		   AND CVGHIST.DEPENDENT_NUM = 0
		   AND CVGHIST.STATUS <> 'I'
		   AND CVGHIST.COV_QUALIFIER like '%premium%'
		   AND  not exists( select 1 from dbo.coverage_history a
						  where a.carrier = CVGHIST.CARRIER
						  and a.case_num = CVGHIST.CASE_NUM
						  and a.emp_num = CVGHIST.EMP_NUM
						  and a.dependent_num = CVGHIST.DEPENDENT_NUM
						  and a.status <> 'I'
						  and a.cov_entity = CVGHIST.COV_ENTITY
						  and a.cov_qualifier = CVGHIST.COV_QUALIFIER
						  and a.added_date > CVGHIST.ADDED_DATE
						  and (a.effective_date = CVGHIST.EFFECTIVE_DATE
							  or ( coalesce( a.term_date, '') = coalesce( CVGHIST.TERM_DATE, '') ) ) )
		   AND   not exists( select 1 from dbo.coverage_history b
						  where b.carrier = CVGHIST.CARRIER
						  and b.case_num = CVGHIST.CASE_NUM
						  and b.emp_num = CVGHIST.EMP_NUM
						  and b.dependent_num = CVGHIST.DEPENDENT_NUM
						  and b.status <> 'I'
						  and b.cov_entity = CVGHIST.COV_ENTITY
						  and b.cov_qualifier = CVGHIST.COV_QUALIFIER
						  and b.effective_date > CVGHIST.EFFECTIVE_DATE
						   AND  not exists( select 1 from dbo.coverage_history c
										  where c.carrier = b.CARRIER
										  and c.case_num = b.CASE_NUM
										  and c.emp_num = b.EMP_NUM
										  and c.dependent_num = b.DEPENDENT_NUM
										  and c.status <> 'I'
										  and c.cov_entity = b.COV_ENTITY
										  and c.cov_qualifier = b.COV_QUALIFIER
										  and c.added_date > b.ADDED_DATE
										  and (c.effective_date = b.EFFECTIVE_DATE
											  or ( coalesce( c.term_date, '') = coalesce( b.TERM_DATE, '') ) ) ) )))
		   AND ((CASEMSTR.CASENAME#CIM = CVGHIST.CIM
		   AND CASEMSTR.CASE_NUM = CVGHIST.CASE_NUM
		   AND CASEMSTR.CARRIER_CODE = CVGHIST.CARRIER
		   AND CASEMSTR.CASENAME#CIM = EMPLOYEE.CASENAME#CIM
		   AND CASEMSTR.CASE_NUM = EMPLOYEE.CASE_NUM
		   AND EMPLOYEE.CASENAME#CIM = CVGHIST.CIM
		   AND EMPLOYEE.CASE_NUM = CVGHIST.CASE_NUM
		   AND EMPLOYEE.EMP_NUM = CVGHIST.EMP_NUM
		   AND CASEMSTR.CASE_NUM NOT IN ( '', '999999' )))
		 GROUP BY CVGHIST.CARRIER,CVGHIST.CASE_NUM,CVGHIST.EMP_NUM
COMMIT;

		exec sp_rename 'rs_InforceBusiness_AG','rs_InforceBusiness_AG1'
		exec sp_rename 'rs_InforceBusiness_AG_temp','rs_InforceBusiness_AG'
		exec sp_rename 'rs_InforceBusiness_AG1','rs_InforceBusiness_AG_temp'

	return 0

GO
