--select CWTCode, CWTChainName,TRXCode,TRXChainName,BrandName
--from dba.cwthtlchains



Insert into dba.cwthtlchains (CWTCode, CWTChainName,TRXCode,TRXChainName,BrandName)
					   select CWTCode, CWTChainName,TRXCode,TRXChainName,BrandName
from ATL892.TMAN503_CITI.dba.cwthtlchains