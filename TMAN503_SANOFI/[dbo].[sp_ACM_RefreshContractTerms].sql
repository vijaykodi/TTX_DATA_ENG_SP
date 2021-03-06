/****** Object:  StoredProcedure [dbo].[sp_ACM_RefreshContractTerms]    Script Date: 7/14/2015 8:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================
-- Author:		  Chalrie Bradsher
-- Create date:	  2012-11-14
-- Update date:	  2013-03-25
-- Update Desc:	  Added refresh of AirlineContractFields table
-- Description:	  Refreshes Contract Terms from ACM Master

--			  DO NOT RUN ON ttxpaSQL09 DATABASES!!!!!

--			  Check to see what will be deleted
--			  Select * from dba.airlinecontracts			  
-- ======================================================
CREATE PROCEDURE [dbo].[sp_ACM_RefreshContractTerms]
AS
BEGIN
	SET NOCOUNT ON;
	
Declare @CustomerID varchar(30)
Set @CustomerID = 'Sanofi'

Declare @string nvarchar(500)
Declare @pos int
Declare @piece nvarchar(500)
Declare @strings table(string nvarchar(512))
Declare @Contract varchar(30)
Declare @Exhibit int
Declare @Market int
Declare @FieldName varchar(200)

--  Drop back-up tables and back up existing terms data

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContracts_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContracts_Bak]

Select *
into dba.AirlineContracts_Bak
from dba.AirlineContracts

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractExhibits_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractExhibits_Bak]

Select *
into dba.AirlineContractExhibits_Bak
from dba.AirlineContractExhibits

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractMarkets_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractMarkets_Bak]

Select *
into dba.AirlineContractMarkets_Bak
from dba.AirlineContractMarkets

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[AirlineContractGoals_Bak]') AND type in (N'U'))
DROP TABLE [DBA].[AirlineContractGoals_Bak]

Select *
into dba.AirlineContractGoals_Bak
from dba.AirlineContractGoals

delete from dba.AirlineContracts 
where CustomerID = @CustomerID

delete from dba.AirlineContractExhibits 
where CustomerID = @CustomerID

delete from dba.AirlineContractMarkets 
where CustomerID = @CustomerID

delete from dba.AirlineContractGoals 
where CustomerID = @CustomerID

Insert into dba.AirlineContracts
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContracts
where CustomerID = @CustomerID

Insert into dba.AirlineContractExhibits
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractExhibits
where CustomerID = @CustomerID

Insert into dba.AirlineContractMarkets
Select *
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractMarkets
where CustomerID = @CustomerID

Insert into dba.AirlineContractGoals
SELECT [CustomerID]
      ,[ContractNumber]
      ,[ExhibitNumber]
      ,[MarketNumber]
      ,[GoalNumber]
      ,[Status]
      ,[GoalType]
      ,[GoalValue]
      ,[Discount]
      ,[DiscountType]
      ,[Target]
      ,[Allowance]
      ,[GoalBeginDate]
      ,[GoalEndDate]
      ,[ModifiedBy]
      ,[ModifiedDate]
      ,[TravelBeginDate]
      ,[TravelEndDate]
      ,[CurrCode]      
      ,[DiscCurrCode]
      ,[MinPerformance]
      ,[InflectionPoint]
      ,[MaxPerformance]
      ,[MinPayment]
      ,[InflectionPayment]
      ,[MaxPayment]
      ,[Description]
      
from ttxpaSQL09.TMAN503_Reports_ACM.dba.AirlineContractGoals
where CustomerID = @CustomerID

    
--  Update ACF

Delete from dba.AirlineContractFields where CustomerID = @CustomerID

Insert into dba.AirlineContractFields
Select CustomerID, ContractNumber, null, null, 'ContractCarrierCodes',null, null
from dba.AirlineContracts
where CustomerID = @CustomerID
and ContractCarrierCodes is null
Union
Select CustomerID, ContractNumber, ExhibitNumber, null, 'PointOfSale',null, null
from dba.AirlineContractExhibits
where CustomerID = @CustomerID
and PointOfSale is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ClassOfService',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and ClassOfService is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FareBasis',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and FareBasis is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FlownCarriers',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and FlownCarriers is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'OperatingCarriers',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and OperatingCarriers is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ValidatingCarriers',null, null
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
and ValidatingCarriers is null


DECLARE ParseField_cursor CURSOR FOR
Select distinct Customerid, ContractNumber, null, null, 'ContractCarrierCodes' as "FieldName", ContractCarrierCodes as "FieldValue"
from dba.AirlineContracts
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, null, 'PointOfSale', PointOfSale
from dba.AirlineContractExhibits
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ClassOfService', ClassOfService
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FareBasis',FareBasis
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FlownCarriers', FlownCarriers
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'OperatingCarriers', OperatingCarriers
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ValidatingCarriers', ValidatingCarriers
from dba.AirlineContractMarkets
where CustomerID = @CustomerID
Order by 1,2,3

Open ParseField_cursor

fetch next from ParseField_cursor into @CustomerID, @Contract, @Exhibit, @Market, @FieldName, @String

while @@Fetch_Status = 0

  BEGIN
         
	  if right(rtrim(@string),1) <> ','
          SELECT @string = @string  + ','

	  SELECT @pos =  patindex('%,%' , @string)
	  while @pos <> 0 
	  begin
	    SELECT @piece = left(@string, (@pos-1))
	    
	   insert into @strings(string) values ( cast(@piece as nvarchar(512)))

	   SELECT @string = stuff(@string, 1, @pos, '')
	   SELECT @pos =  patindex('%,%' , @string)
	  end

       
        Insert into dba.AirlineContractFields
	  SELECT @Customerid, @Contract, @Exhibit, @Market, @FieldName, null, string FROM @Strings
	  
	  Delete from @Strings
	  
fetch next from ParseField_cursor into @CustomerID, @Contract, @Exhibit, @Market, @FieldName, @String

  END

CLOSE ParseField_cursor
DEALLOCATE ParseField_cursor



   
END


GO
