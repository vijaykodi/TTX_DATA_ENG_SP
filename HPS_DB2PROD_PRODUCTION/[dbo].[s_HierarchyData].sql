/****** Object:  StoredProcedure [dbo].[s_HierarchyData]    Script Date: 7/14/2015 7:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





CREATE      proc [dbo].[s_HierarchyData]
as
set nocount on
	
	declare @count as int, @prev_count as int

	truncate table HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_temp
begin transaction
	insert into HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_temp
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
			, OWNING_CARRIER
		from HPS_DB2PROD_PRODUCTION.dbo.hierarchydata 
       where list_bill_case_num > '0'
         and list_bill_cim > '0'
COMMIT;
begin TRANSACTION
	--Update all levels of the case with a carrier code
	UPDATE	HPS_DB2PROD_PRODUCTION.dbo.rs_hierarchydata_temp 
	SET 	Carrier_Code =	( Select max(a.carrier_code)
				from HPS_DB2PROD_PRODUCTION.dbo.case_master a
				where a.case_num = rs_hierarchydata_temp.case_num )
	-- End update for carrier code
COMMIT TRANSACTION;

begin TRANSACTION
	-- Update L4/L5 cases with correct L1 Case and Cim if L2/L3 are not present
		update dbo.rs_hierarchydata_temp
		set L1_Case_Num = c.LIST_BILL_CASE_NUM,
			L1_Cim = c.LIST_BILL_CIM
		from dbo.rs_hierarchydata_temp a
		inner join dbo.hierarchydata b
		on b.LIST_BILL_CASE_NUM = a.Case_Num
		inner join dbo.hierarchydata c
		on c.LIST_BILL_CIM = b.HIGHEST_LVL_CIM
		and c.HIGHEST_LVL_CIM = b.HIGHEST_LVL_CIM
		where a.Case_Level in (4, 5)
		and a.L1_Cim <> b.HIGHEST_LVL_CIM	
COMMIT TRANSACTION;

	select @count = count(1) from hps_db2prod_production.dbo.rs_hierarchydata_temp
	select @prev_count = count(1) from hps_db2prod_production.dbo.hierarchydata
	if @count = @prev_count
	begin
		begin TRANSACTION
		exec sp_rename 'rs_hierarchydata','rs_hierarchydata1'
		exec sp_rename 'rs_hierarchydata_temp','rs_hierarchydata'
		exec sp_rename 'rs_hierarchydata1','rs_hierarchydata_temp'
		COMMIT TRANSACTION;
	end
	else
		RAISERROR (N'The aux hierarchydata table does not have the same number of records as the source table!', 20, 1)

	return 0






GO
