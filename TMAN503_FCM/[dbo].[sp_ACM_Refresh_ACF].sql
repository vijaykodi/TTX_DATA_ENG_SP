/****** Object:  StoredProcedure [dbo].[sp_ACM_Refresh_ACF]    Script Date: 7/14/2015 8:06:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:		  Chalrie Bradsher
-- Create date:	  2012-11-14
-- Update date:	  2013-03-25
-- Description:	  Refreshes AirlineContractFields table			  
-- ======================================================

CREATE PROCEDURE [dbo].[sp_ACM_Refresh_ACF]
AS
BEGIN
	SET NOCOUNT ON;
	
Declare @string nvarchar(500)
Declare @pos int
Declare @piece nvarchar(500)
Declare @strings table(string nvarchar(512))
Declare @Contract varchar(30)
Declare @Exhibit int
Declare @Market int
Declare @FieldName varchar(200)
Declare @CustomerID varchar(30)
	 
--  Update ACF

Insert into dba.AirlineContractFields
Select CustomerID, ContractNumber, null, null, 'ContractCarrierCodes',null, null
from dba.AirlineContracts
where ContractCarrierCodes is null
Union
Select CustomerID, ContractNumber, ExhibitNumber, null, 'PointOfSale',null, null
from dba.AirlineContractExhibits
where PointOfSale is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ClassOfService',null, null
from dba.AirlineContractMarkets
where ClassOfService is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FareBasis',null, null
from dba.AirlineContractMarkets
where FareBasis is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FlownCarriers',null, null
from dba.AirlineContractMarkets
where FlownCarriers is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'OperatingCarriers',null, null
from dba.AirlineContractMarkets
where OperatingCarriers is null
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ValidatingCarriers',null, null
from dba.AirlineContractMarkets
where ValidatingCarriers is null

DECLARE ParseField_cursor CURSOR FOR
Select distinct Customerid, ContractNumber, null, null, 'ContractCarrierCodes' as "FieldName", ContractCarrierCodes as "FieldValue"
from dba.AirlineContracts
--where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, null, 'PointOfSale', PointOfSale
from dba.AirlineContractExhibits
--where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ClassOfService', ClassOfService
from dba.AirlineContractMarkets
--where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FareBasis',FareBasis
from dba.AirlineContractMarkets
--where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'FlownCarriers', FlownCarriers
from dba.AirlineContractMarkets
--where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'OperatingCarriers', OperatingCarriers
from dba.AirlineContractMarkets
--where CustomerID = @CustomerID
Union
Select distinct Customerid, ContractNumber, ExhibitNumber, MarketNumber, 'ValidatingCarriers', ValidatingCarriers
from dba.AirlineContractMarkets
--where CustomerID = @CustomerID
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
