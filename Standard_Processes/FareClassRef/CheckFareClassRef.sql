select distinct cr.Text14,TS.MINSegmentCarrierCode,TS.MINInternationalInd ,substring(TS.MINClassOfService,1,1), case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
, COUNT(*)
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' 
 AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' 
                                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode 
 AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' 
                                                                                                                else 'Intercontinental' end  
 AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 

WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
    AND CR.Text14 = 'Not Provided'
   AND ID.Iatanum IN ('ELCWT')
group by  cr.Text14,TS.MINSegmentCarrierCode,TS.MINInternationalInd ,substring(TS.MINClassOfService,1,1), case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
order by 2,3,4
