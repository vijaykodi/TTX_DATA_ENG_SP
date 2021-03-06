/****** Object:  StoredProcedure [dba].[UpdateCostCenterFromEmpID]    Script Date: 7/14/2015 7:50:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dba].[UpdateCostCenterFromEmpID]

AS




----Added on May5 2015 by YL CASE  06266751
UPDATE cch
 SET cch.CostCenter = h.costcenternumber
 FROM dba.ccheader cch 
 INNER JOIN ttxsasql01.TMAN503_BOA.dba.hierarchy_temp h ON cch.EmployeeId = h.employeenumber
 WHERE cch.costcenter is null


----UPDATE Market Codes for MC data based on BIN Number
----Added on 5/12/15 by Nina
UPDATE dba.CCHeader
SET MarketCode = CASE WHEN CCFirstSix in ('540533','540534') THEN 'CA'
				 WHEN CCFirstSix = '547899' THEN 'US'
				 WHEN CCFirstSix in ('553162','556620','519760') THEN 'IN'
				 WHEN CCFirstSix in ('553152','553176') THEN 'KR'
				 WHEN CCFirstSix in ('516325','519765') THEN 'AU'
				 WHEN CCFirstSix = '547433' THEN 'NZ'
				 WHEN CCFirstSix in ('556905','556110') THEN 'GB'
				 WHEN CCFirstSix = '552519' THEN 'NO'
				 WHEN CCFirstSix = '552518' THEN 'DK'
				 WHEN CCFirstSix = '558791' THEN 'FI'
				 WHEN CCFirstSix = '541253' THEN 'SE'
				 WHEN CCFirstSix = '547785' THEN 'TW'
				 WHEN CCFirstSix = '547736' THEN 'MX'
				 WHEN CCFirstSix in ('519768','531219') THEN 'HK'
				 WHEN CCFirstSix = '556656' THEN 'TH'
				 WHEN CCFirstSix = '533161' THEN 'BE'
				 WHEN CCFirstSix in ('519788','552592') THEN 'SG'
				 WHEN CCFirstSix in ('533162') THEN 'CH'
				 WHEN CCFirstSix in ('525016') THEN 'JP'
				 WHEN CCFirstSix in ('552530') THEN 'BR'
				 WHEN CCFirstSix in ('522118') THEN 'ZA'
				 ELSE 'ZZ'
				 END
WHERE IataNum = 'BOFACCMC'
AND MarketCode = 'ZZ'

----UPDATE Market Codes for MC data based on BIN Number and Company ID
----Added on 5/12/15 by Nina
UPDATE dba.CCHeader
SET MarketCode = CASE WHEN CCFirstSix = '533161' and Remarks14 IN ('5000763','5000764') THEN 'FR'
					  WHEN CCFirstSix = '533161' and Remarks14 IN ('5000765','5000766') THEN 'IT'
					  WHEN CCFirstSix = '533161' and Remarks14 IN ('5000937','5000938') THEN 'DE'
					  WHEN CCFirstSix = '533161' and Remarks14 IN ('5001023','5001024') THEN 'ES'
					  WHEN CCFirstSix = '533161' and Remarks14 IN ('5002219','5002220') THEN 'NL'
					  WHEN CCFirstSix = '533161' and Remarks14 IN ('5002222') THEN 'LU'
					  WHEN CCFirstSix = '533161' and Remarks14 IN ('5002221') THEN 'BE'
					  ELSE 'BE'
					  END
WHERE IataNum = 'BOFACCMC'
AND MarketCode = 'BE'
AND TransactionDate >= '2015-01-01'
AND CCFirstSix = '533161'


GO
