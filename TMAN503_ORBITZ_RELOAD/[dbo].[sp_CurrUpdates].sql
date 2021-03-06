/****** Object:  StoredProcedure [dbo].[sp_CurrUpdates]    Script Date: 7/14/2015 8:13:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_CurrUpdates]
as 
begin
--February 29, 2012 by Sue Quigley

UPDATE SB
SET SB.ConvertedAmt = SB.Amount*CURR.BaseUnitsPerCurr,
SB.CurrCode = 'USD'
FROM DBA.Currency CURR, dba.ServeBase SB
WHERE ((CURR.BaseCurrCode = 'USD'))
      AND SB.Currency = CURR.CurrCode
      AND SB.PNRCreation = CURR.CurrBeginDate
     and SB.Currency <> 'USD'
      and sb.convertedamt is null

UPDATE SB
SET SB.ConvertedAmt = SB.Amount*CURR.BaseUnitsPerCurr,
SB.CurrCode = 'USD'
FROM DBA.Currency CURR, dba.ServeBase SB
WHERE ((CURR.BaseCurrCode = 'USD'))
      AND SB.Currency = CURR.CurrCode
      AND SB.PNRCreation = CURR.CurrBeginDate
     and SB.Currency = 'USD'
      and sb.convertedamt is null
end
GO
