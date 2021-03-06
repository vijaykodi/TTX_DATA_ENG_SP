/****** Object:  StoredProcedure [dbo].[s_HierarchyData_jpb]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE     proc [dbo].[s_HierarchyData_jpb]
as

	set nocount on
	
	declare @count as int, @prev_count as int

	TRUNCATE TABLE HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_jpb_temp

	insert into HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_jpb_temp
		select distinct list_bill_case_num, list_bill_cim, parent_cim
			, case_use_ind
			, case when case_use_ind = 'REPORTING' then   
				 case when HIGHEST_LVL_CIM = LIST_BILL_CIM then 1  
				 when PARENT_CIM = HIGHEST_LVL_CIM then 2  
				 else 3 end    
				 when case_use_ind = 'SUPERBILL' then 2    
				 when case_use_ind = 'BILLPRINT' then 2    
				 when case_use_ind = 'BENFAVAIL' then 3    
				 when case_use_ind = 'INDIV-LB' then 4    
				 when case_use_ind = 'DTLCASE' then 5    
				 end   
			, dbo.hlevel_case3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 1, 0 ) as "CASE 1"
			, dbo.hlevel_case3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 2, 0 ) as "CASE 2"
			, dbo.hlevel_case3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 3, 0 ) as "CASE 3"
			, dbo.hlevel_case3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 4, 0 ) as "CASE 4"
			, dbo.hlevel_case3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 5, 0 ) as "CASE 5"  
			, dbo.hlevel_cim3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 1, 0 ) as "CIM 1"
			, dbo.hlevel_cim3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 2, 0 ) as "CIM 2"
			, dbo.hlevel_cim3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 3, 0 ) as "CIM 3"
			, dbo.hlevel_cim3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 4, 0 ) as "CIM 4"
			, dbo.hlevel_cim3 ( list_bill_case_num, case_use_ind, HIGHEST_LVL_CIM, PARENT_CIM, LIST_BILL_CIM, 5, 0 ) as "CIM 5"  
			, NULL
		from HPS_DB2PROD_PRODUCTION.dbo.hierarchydata 




	select @count = count(*) from HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_jpb_temp
	select @prev_count = count(*) from HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_jpb
	if @count > @prev_count
	begin
		exec sp_rename 'rs_hierarchydata_jpb','rs_hierarchydata2'
		exec sp_rename 'rs_hierarchydata_jpb_temp','rs_hierarchydata_jpb'
		exec sp_rename 'rs_hierarchydata2','rs_hierarchydata_jpb_temp'
	end
	else
		return 1

	return 0

GO
