
/*
Added the following logic to update cr.Text14 - sq 3/13/2015
Updated logic for refunds outer join and refunds missing segments - sq 3/13/2015
*/

SET @TransStart = getdate()
/*First Class Cabin*/
update cr
set cr.Text14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
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
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'First'
   AND CR.Text14 = 'Not Provided'
   AND ID.Iatanum IN ('ELCWT')
   AND IH.Importdt >= getdate()-10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - First',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Business Class Cabin*/
update cr
set cr.Text14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Business'
   AND CR.Text14 ='Not Provided'
   AND ID.Iatanum IN ('ELCWT')
   AND IH.Importdt >= getdate()-10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Business',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Premium Economy Class Cabin*/
update cr
set cr.Text14 = case when alfourcosid.cabin is null then alfourcosidoth.cabin else alfourcosid.cabin end
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND TS.MinDestCityCode is not null
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end = 'Premium Economy'
   AND CR.Text14 ='Not Provided'
   AND ID.Iatanum IN ('ELCWT')
   AND IH.Importdt >= getdate()-10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Premium Economy',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

SET @TransStart = getdate()
/*Economy Class Cabin - includes 'Unclassified' cabin*/
update cr
set cr.Text14 = 'Economy'
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH
INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.Transeg TS ON ( TS.RecordKey = CR.RecordKey AND TS.IataNum = CR.IataNum AND TS.SeqNum = CR.SeqNum AND TS.ClientCode = CR.ClientCode AND TS.IssueDate = CR.IssueDate ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSIDOTH ON  (ALFOURCOSIDOTH.AirlineCode = '**' AND ALFOURCOSIDOTH.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSIDOTH.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 LEFT OUTER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.MasterFareClassRef_VW ALFOURCOSID ON  (ALFOURCOSID.AirlineCode = TS.MINSegmentCarrierCode AND ALFOURCOSID.StageCode = Case when isnull(TS.MINInternationalInd,'D') = 'D' then 'Domestic' when isnull(abs(ts.MINSegmentMileage),0) < 2500 then 'Regional' else 'Intercontinental' end  AND ALFOURCOSID.FareClassCode = substring(TS.MINClassOfService,1,1) ) 
 WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND case when ALFOURCOSID.Cabin is null then ALFOURCOSIDOTH.Cabin else  ALFOURCOSID.Cabin end in ('Economy', 'Unclassified')
   AND TS.MinDestCityCode is not null
   AND CR.Text14 ='Not Provided'
   AND ID.Iatanum IN ('ELCWT')
   AND IH.Importdt >= getdate()-10
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Economy',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

/*
Update refunds in dba.invoicedetail that do not have corresponding rows in dba.transeg
by linking the refund document number back to the original debit transaction and using the value
in cr.Text14
*/
SET @TransStart = getdate()
update cr
set cr.Text14 = crorig.Text14
FROM TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceHeader IH  
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail ID  ON ( ID.RecordKey = IH.RecordKey AND ID.IataNum = IH.IataNum AND ID.ClientCode = IH.ClientCode ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks CR ON ( CR.RecordKey = ID.RecordKey AND CR.IataNum = ID.IataNum AND CR.SeqNum = ID.SeqNum AND CR.ClientCode = ID.ClientCode AND CR.IssueDate = ID.IssueDate ) 

INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.InvoiceDetail IDOrig ON (IDOrig.Recordkey <> ID.Recordkey and IDOrig.IataNum = ID.IataNum AND IDOrig.ClientCode = ID.ClientCode and ID.documentnumber = IDOrig.DocumentNumber and IDOrig.RefundInd not in ('Y','P') ) 
 INNER JOIN TTXPASQL09.TMAN503_ESTEELAUDER.dba.ComRmks CROrig ON ( CROrig.RecordKey = IDOrig.RecordKey AND CROrig.IataNum = IDOrig.IataNum AND CROrig.SeqNum = IDOrig.SeqNum AND CROrig.ClientCode = IDOrig.ClientCode) 
WHERE 1=1
   AND ID.VoidInd = 'N'
   AND ID.VendorType IN ('BSP','NONBSP') /*Do we need to handle RAIL/ss*/                    
   AND ID.ValCarrierCode Not IN  ('2V','2R')
   AND CR.Text14 is null
   AND ID.Iatanum IN ('ELCWT')
   AND IH.Importdt >= getdate()-10
   and id.refundind in ('Y','P')
   and cr.Text14 = 'Not Provided'
   and not exists (select 1 from dba.transeg ts
                                                                                where ts.recordkey = id.recordkey
                                                                                and ts.iatanum = id.iatanum
                                                                                and ts.seqnum = id.seqnum
                                                                                )
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update Highest class flown - Refunds',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/*End CR.Text14 update for highest cabin flown*/

