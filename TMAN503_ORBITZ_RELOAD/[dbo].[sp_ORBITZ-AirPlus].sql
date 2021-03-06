/****** Object:  StoredProcedure [dbo].[sp_ORBITZ-AirPlus]    Script Date: 7/14/2015 8:13:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------------------------------
/***** THIS IS NOT FINAL - ONLY TEMPORARY UNTIL COMPLETED.....See Kara and Pam S.....4/17/2014 *****/

--------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_ORBITZ-AirPlus]

	--@BeginIssueDate   	datetime,
	@EndIssueDate		datetime

AS

SET NOCOUNT ON

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime, @BeginIssueDate  datetime

	SET @Iata = 'ORBITZUS'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
	Set @BeginIssueDate = '04/01/2014'
	

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

---ONLY CLIENT INITIALLY IS HARTE HANKS  TEST CC IS TP 192000001069077 EXP 11/2015
----Harte Hanks live card is 192000501064750  exp 03/19
---IATANUM=24639860
--//Date range to use is previous weeks Monday - Sunday\\

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--always in the beginning


---Updated 7/11/2014 with new card from Kristina .....Pam S
SET @TransStart = getdate()

INSERT TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
					(RecordKey, IataNum, SeqNum, ClientCode, InvoiceDate,IssueDate
--------			,Text1,Text3,Text4,Text10,Text49) --removing due to new card for travel beginning 2 July 2014
					,Text1,Text10,Text49)
					
SELECT distinct ID.RecordKey, 'ORBITZ', ID.SeqNum, ID.ClientCode, ID.InvoiceDate, ID.IssueDate
---------			,'D','192000501064750','0319','840','N' ---Constants  ---
---------			,'D','192000001080264','0619','840','N' ---Constants  --- New card for Travel 2 July 2014  per Kristina email 7/11/2014 
                    ,'D','840','N' ---new Constants
from dba.InvoiceDetail ID
     Inner join dba.Payment PY on 
                    (ID.IataNum = PY.IataNum and ID.RecordKey = PY.Recordkey and ID.SeqNum = PY.seqnum
                     and ID.ClientCode = PY.ClientCode and  ID.InvoiceDate = PY.InvoiceDate
                     and ID.IssueDate = PY.IssueDate)

WHERE  ID.IataNum = 'ORBITZ'  
and id.clientcode in ('TPT-TP5920019')
and PY.fop in ('CC') and PY.CCCode = 'TP'
and PY.CCNUM in ('64750','80264')
----and PY.CCLastFour = '9077' ----was set to test cc

and ISNULL(ID.TotalAmt,'0') <> 0
AND ID.Voidind = 'N'
--and id.ExchangeInd = 'N' ---Do not import exchanges now - due to seqnum changes ******See Pam
--and ((id.ExchangeInd = 'N') or (Id.ExchangeInd = 'Y' and ID.Seqnum <> '1')) ---So Exch not same seqnum as orig tkt sent

and ID.IssueDate BETWEEN '04/01/2014' and @EndIssueDate
and PY.IssueDate BETWEEN '04/01/2014' and @EndIssueDate
--and id.issuedate >= '04/01/2014'
--and py.IssueDate >= '04/01/2014'

and ID.RecordKey+ID.IataNum+CONVERT(VARCHAR,ID.SeqNum) not in
  (select RecordKey+IataNum+CONVERT(VARCHAR,SeqNum) from TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
    where IataNum =  'ORBITZ' and ClientCode in ('TPT-TP5920019') 
    and IssueDate BETWEEN '04/01/2014' and @EndIssueDate 
    ---and id.issuedate >= '04/01/2014'
     )
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Insert ComRmksAirPlus',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR




------------For Exchanges Only where seqnum becomes 1 and orig tkt becomes seq 2  --------------------







--------- END Insert ComRmksAirPlus -------------


----------------------------------------


-----For ALL CLIENTS from InvoiceDetail and Payment
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
Set 
----Text1 = 'D', -- (constant in Insert Statement)
----Text2 = (See step for Text2 below -based on population of Text16 and fop)
Text3 =  Case
		 when PAY.CCNUM = '64750' then '192000501064750'
         when PAY.CCNUM = '80264' then '192000001080264' --- New card for Travel 2 July 2014  per Kristina email 7/11/2014 
         else Text3
		 End,
Text4 =  Case
		 when PAY.CCNUM = '64750' then '0319'
         when PAY.CCNUM = '80264' then '0619'
		 else Text4
		 End,
Text5 = RIGHT('000' + CONVERT(VARCHAR,isnull(id.valcarriernum,'0')), 3) + id.documentnumber,
Text6 = CONVERT(varchar,id.issuedate,112),
Text7 = COALESCE(ID.LastName+'/'+ID.FirstName,Id.LastName,ID.FirstName, 'Name Not Captured'),
Text8 = CASE WHEN ID.TotalAmt >= 0 THEN '+'ELSE '-' END, 
Text9 = CONVERT(NUMERIC,(ABS(ID.TotalAmt*100))),
--Text10 = '840', -- (constant in Insert Statement)
Text11 = IsNull(PAY.CCApprovalCode,'XXXX'),
Text12 = CONVERT(INT,(ABS(TaxAmt)*100)),
Text13 = ID.InternationalInd, 
Text14 = ID.BranchIataNum, 
Text15 = case 
	when ID.servicedate is not null then CONVERT(varchar,ID.servicedate,112)   
	when ID.servicedate is null then CONVERT(varchar,ID.issuedate,112)
	end, 
------------------------------------
--Text16 = --- service description or ticket # or Inv # -done by later steps
Text17 = '-' , --default value --see client specific overrides--EMPLOYEE ID
Text18 = '-' , --default value --see client specific overrides--DEPARTMENT
Text19 = '-' , --default value --see client specific overrides--PROJECT NAME
Text20 = '-' , --default value --see client specific overrides--ACCOUNTING UNIT
Text21 = '-' , --default value --see client specific overrides--Operating Unit
-------------------------------------------------------
-- Text22 - On 10.12.09 as JoAn realized profiles should be Boarding Date instead of Booking Date  (22 - BD)
Text22 = case
	when ID.servicedate is not null then REPLACE(CONVERT(varchar,ID.ServiceDate,06),' ','')  ---- ddmmmyy --without spaces
	when ID.servicedate is null then REPLACE(CONVERT(varchar,ID.IssueDate,06),' ','')
     	end,
Text23 = '-' , --default value --see client specific overrides-- PRODUCT NUMBER
Text24 = '-' , --default value --see client specific overrides-- TRIP PURPOSE
Text25 = '-' , --default value --see client specific overrides-- BUSINESS UNIT
Text26 = '-' , --default value --not required--DESTINATION
Text27 = IH.INVOICENUM,
Text28 = '-' , --default value --see client specific overrides--
Text29 = ID.clientcode,
Text35 = ID.tourcode,
Text37 = IH.INVOICENUM,
-- Text38 =  filler 2 --Not used
------Adding following from Payment
Text39 = PAY.FOP,
Text40 = PAY.CCCode,
Text41 = '192000',--first 6
Text42 = Case
		 when PAY.CCNUM = '64750' then '4750'
         when PAY.CCNUM = '80264' then '0264'
		 else Text42
		 End,
Text43 = Case
		 when PAY.CCNUM = '64750' then '192000501064750'
         when PAY.CCNUM = '80264' then '192000001080264' --- New card for Travel 2 July 2014  per Kristina email 7/11/2014 
         else Text43
		 End,
Text44 = Case
		 when PAY.CCNUM = '64750' then '0319'
         when PAY.CCNUM = '80264' then '0619'
		 else Text44
		 End,
Text45 = ID.ExchangeInd,
Text46 = ID.Voidind

from TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp
     Inner Join dba.InvoiceDetail ID on
					(CrAp.Recordkey = ID.Recordkey and CrAp.Seqnum = ID.Seqnum
					 and CrAp.IataNum = ID.Iatanum and CrAp.ClientCode = ID.ClientCode)
---- PS removed 7/16 due to exch	 RecordKey = 'TPT-JULUFWW2MZR-07022014'
                    ---and CrAp.IssueDate = ID.IssueDate and CrAp.InvoiceDate = ID.InvoiceDate)
	 Inner Join dba.Payment PAY on
					(ID.Recordkey = PAY.Recordkey and ID.Seqnum = PAY.Seqnum and
					 ID.IataNum = PAY.Iatanum and ID.ClientCode = PAY.ClientCode and
					 ID.IssueDate = PAY.IssueDate and ID.InvoiceDate = PAY.InvoiceDate)
	 Inner Join dba.InvoiceHeader IH on 
					(ID.RecordKey = IH.Recordkey and ID.ClientCode = IH.ClientCode
	                and ID.IataNum = IH.Iatanum and ID.InvoiceDate = IH.InvoiceDate)
Where CrAp.IataNum = 'ORBITZ'
and CrAp.Text49 = 'N'
----and id.ExchangeInd = 'N'
--and ((id.ExchangeInd = 'N') or (Id.ExchangeInd = 'Y' and ID.Seqnum <> '1')) ---So Exch not same seqnum as orig tkt sent
and CrAp.Issuedate BETWEEN '04/01/2014' and @EndIssueDate 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Update from ID-Pay-IH',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------------------------------

--------------------------------------For All Clients:

---- When to populate Text16 with Routing:

---- Text16 for Service Description 
----	If There is Routing and NOT a Service Fee
----	16.1.1  ORIGIN_LOC  Origin location, IATA Code      Mandorty Format:AN Length: 3 Start 128
----	16.1.2  SEGMENT_1	Info for first flight segment:	Mandorty Format:AN Length: 7 Start 131
----						• Destination:	alphabetic 3 characters
----						• Airline:		alphanumeric 3 characters (or 2 plus space)
----						• Class:		alphabetic 1 character
----						  e.g. FRALH C
----				Attention:	For low cost carrier flight the class has to be filled always with “Y”
----	16.1.3	SEGMENT_2	Info for second flight segment	Mandatory if Present!  Format: AN Length: 7 Start 138
----	16.1.4	SEGMENT_3	Info for third  flight segment	Mandatory if Present!  Format: AN Length: 7 Start 145
----	16.1.5	SEGMENT_4	Info for fourth flight segment	Mandatory if Present!  Format: AN Length: 7 Start 152

----  Text36 = ts1.farebasis -"Only if NON-BSP" according to spec - Formt: AN Length 15 Position: 482
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
set 
text16 = SUBSTRING(id.Routing,1,3)+
        ts1.SEGDestCityCode+ts1.SegmentCarrierCode+' '+substring(isnull(ts1.ClassOfService,' '),1,1)+
isnull(ts2.SEGDestCityCode+ts2.SegmentCarrierCode,' ')+' '+substring(isnull(ts2.ClassOfService,' '),1,1)+
isnull(ts3.SEGDestCityCode+ts3.SegmentCarrierCode,' ')+' '+substring(isnull(ts3.ClassOfService,' '),1,1)+
isnull(ts4.SEGDestCityCode+ts4.SegmentCarrierCode,' ')+' '+substring(isnull(ts4.ClassOfService,' '),1,1),

Text36 =case when vendortype in ('NONBSP') then ts1.farebasis else Text36 end

from dba.InvoiceDetail id
     Inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComrmksAirPlus CrAp on (id.iatanum = CrAp.iatanum and id.clientcode = CrAp.clientcode
									and id.recordkey = CrAp.recordkey and id.seqnum = CrAp.seqnum)
						----			and id.issuedate = CrAp.IssueDate)
     Inner join dba.transeg ts1 on (id.recordkey = ts1.recordkey and id.iatanum = ts1.iatanum 
                                    and id.seqnum = ts1.seqnum and ts1.segmentnum = 1)
     Left outer join dba.transeg ts2 on (id.recordkey = ts2.recordkey and id.iatanum = ts2.iatanum 
                                     and id.seqnum = ts2.seqnum and ts2.segmentnum = 2)
     Left outer join dba.transeg ts3 on (id.recordkey = ts3.recordkey and id.iatanum = ts3.iatanum 
                                     and id.seqnum = ts3.seqnum and ts3.segmentnum = 3)
     Left outer join dba.transeg ts4 on (id.recordkey = ts4.recordkey and id.iatanum = ts4.iatanum 
                                     and id.seqnum = ts4.seqnum and ts4.segmentnum = 4)
     
where id.iatanum = 'ORBITZ'
and id.vendortype in ('BSP','NONBSP')
and id.voidind = 'N'
--and id.ExchangeInd = 'N'
--and ((id.ExchangeInd = 'N') or (Id.ExchangeInd = 'Y' and ID.Seqnum <> '1')) ---So Exch not same seqnum as orig tkt sent

and id.valcarriernum <> '890'
and CrAp.text49 = 'N'

and CrAp.Issuedate BETWEEN '04/01/2014' and @EndIssueDate 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Routing',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------------------------------------------------------------------


---- When to populate with related ticket to BSP (890 XD) TAF fee:

----	16.2 IATA_TAF_DESC	IATA TAF, TRANSACTION_TYPE ”I”										Mandatory Formt: AN
----						(only BSP)
----	16.2.1 REF_PREFIX	Airline prefix of IATA TAF related flight ticket					Mandatory Format: AN Length: 3 Position: 128	
----						see field 5.1.1
----	16.2.2 REF_SERIAL_NO Airline serial number of the IATA TAF related flight ticketnumber	Mandatory Format: AN Length: 10 Position: 131 
----						 see field 5.1.2
----	16.2.3 FILLER Filler - space filled														Mandatory Format: AN Length: 18 Position: 141

----	16.3 NON_BSP_DESC	Related non air service		Mandatory Format: AN
----						(only NONBSP)
----	16.3.1 SERVICE_DESC  Service Description		Mandatory Format: AN Length: 31 Position: 128


----	Note: Griffin is different than some agencies:
----			1) Fees are on different recordkey /(row) than Ticket number but have same Invoice Number
----			2) Griffin uses Invoice Number in InvoiceTypeDescription instead of InvoiceHeader
----				because they issue a different invoice number per ticket
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
Set Text16 = convert(varchar(3),substring(ID2.vendornumber,3,3)) + convert (varchar(10),ID2.DocumentNumber)

from dba.InvoiceDetail ID1
		 Inner Join dba.InvoiceDetail ID2 on (ID1.InvoiceTypeDescription = ID2.InvoiceTypeDescription 									      and ID1.IssueDate = ID2.IssueDate
										  and ID1.Iatanum = ID2.Iatanum and ID1.ClientCode = ID2.ClientCode)
										 --and ID1.Recordkey = ID2.Recordkey and ID1.Seqnum = ID.Seqnum
										 --(Note: Not joining on Recordkey & Seqnum because same Invoice # has different Recordkeys)
										 
		Inner Join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on (ID1.Iatanum = CrAp.Iatanum and ID1.ClientCode = CrAp.ClientCode
										   and ID1.Recordkey = CrAp.Recordkey and ID1.Seqnum = CrAp.Seqnum)
									----	   and ID1.IssueDate = CrAp.IssueDate) 
			 
where ID1.iatanum = 'ORBITZ'
--and ID1.vendortype = 'bsp' --may add this back in if not doing updates to 'FEES'
							 --But must use Valcarriernum 890 which is considered BSP TAF
and ID1.valcarriernum = '890' and ID1.valcarriercode = 'XD'
and ID2.valcarriernum <> '890'
and CrAp.Text49 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate BETWEEN '04/01/2014' and @EndIssueDate 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text16-Service Description',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------------------------------------------------------------------


----*** Now update Text2 before populating Text16 in next step

-------------------------------------------------------------------------------------
------Text2 is TRANSACTION_TYPE - Mandatory - Format: A - Length: 1
------      BSP_Record: 
------          I = Iata(BSP)Service Fee 
------        * F = Flight
------      MA_record:
------          K = Commission sent to the customer (only where the IATA (BSP) pays commission.
------          A = Service Fee only for air travel (except for German rail Service Fee). 
------          O = Service Fee for all OTHER services (e.g. Service Fee for hotel reservation, car rental, issuing train tickets)
------        * F = Flight (net fares, low cost carrier)
------          T = Train
------          H = Hotel
------          C = Car
------          S = Ship
------          O = Other
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
Set Text2 = case 
			when CrAp.Text16 is not null and id.valcarriernum <> '890' then 'F'  --(Text16 either has routing or related tkt --For DBI and Merchant)
            when CrAp.Text16 is not null and id.valcarriernum not in ('890','554') and id.ProductType = 'RAIL' then 'T' --For Train
            when CrAp.Text16 is not null and id.valcarriernum = '890' and Pay.fop in ('CC') then 'I'        -- Iata(BSP)Service Fee -- For DBI only
			when CrAp.Text16 is not null and id.valcarriernum = '890' and Pay.fop in ('AR','CA','CK') then 'A'   -- Service Fee only for air travel (except for German rail Service Fee) -- For Merchant Only
			when CrAp.Text16 is null and Pay.fop in ('CC','VD') then 'F'			-- (Text16 has no routing or related tkt) --For DBI only
	        when CrAp.Text16 is null and Pay.fop in ('AR','CA','CK') then 'O'		-- Service Fee for all OTHER services     --For Merchant only
	        Else Text2 
	        End
	        from TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp
     Inner Join dba.InvoiceDetail ID on
					(CrAp.Recordkey = ID.Recordkey and CrAp.Seqnum = ID.Seqnum and
					 CrAp.IataNum = ID.Iatanum and CrAp.ClientCode = ID.ClientCode )
				---	 and CrAp.IssueDate = ID.IssueDate and CrAp.InvoiceDate = ID.InvoiceDate)
	 Inner Join dba.Payment PAY on
					(CrAp.Recordkey = PAY.Recordkey and CrAp.Seqnum = PAY.Seqnum and
					 CrAp.IataNum = PAY.Iatanum and CrAp.ClientCode = PAY.ClientCode) 
				---	 and CrAp.IssueDate = PAY.IssueDate and CrAp.InvoiceDate = PAY.InvoiceDate)
Where CrAp.IataNum = 'ORBITZ'
and CrAp.Text49 = 'N'
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate BETWEEN '04/01/2014' and @EndIssueDate 
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------------------------------------------------------------------

---- When to populate Text16 for all others that do not have Routing or Related ticket number to MCO (890):
----   Therefore when Text16 is null from updates in previous 2 steps

----5.5 TIX_DOC			Non air services (only NON-BSP)			Mandatory  Format: AN
----5.5.1 TIX_PREFIX	TRANSACTION_TYPE “T”, “H”, “S”,“O”, and “C”
----					***Has to be filled with zeros (000)	Mandatory  Format: N  Length: 3 Position 26

---- Update to Text16 when CrAp.Text16 is NULL after steps for Routing and Related Tkt above
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
Set
Text5  = Case 
	when ID.DocumentNumber is null then '000INV' + IH.InvoiceNum
	when ID.DocumentNumber is not null then '000' + ID.DocumentNumber ----ValCarriernum ***Has to be filled with zeros (000) - here in Text5, even if there is a valid valcarriernum 
	Else Text5														  ---- see below in Text16 where actual valcarriernum does get populated
	End,
 Text16 = Case 
	when ID.DocumentNumber is null then '000INV'+ IH.InvoiceNum
	when ID.DocumentNumber is not null then 
	RIGHT('000' + CONVERT(VARCHAR,isnull(id.valcarriernum,'0')), 3) + id.documentnumber
 	Else Text16
	END 
	   
from TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp
     Inner Join dba.InvoiceDetail ID on
					(CrAp.Recordkey = ID.Recordkey and CrAp.Seqnum = ID.Seqnum and
					 CrAp.IataNum = ID.Iatanum and CrAp.ClientCode = ID.ClientCode )
					 ---and CrAp.IssueDate = ID.IssueDate and CrAp.InvoiceDate = ID.InvoiceDate)
	 Inner Join dba.Payment PAY on
					(ID.Recordkey = PAY.Recordkey and ID.Seqnum = PAY.Seqnum and
					 ID.IataNum = PAY.Iatanum and ID.ClientCode = PAY.ClientCode and
					 ID.IssueDate = PAY.IssueDate and ID.InvoiceDate = PAY.InvoiceDate)
	 Inner Join dba.InvoiceHeader IH on (ID.RecordKey = IH.Recordkey and ID.ClientCode = IH.ClientCode
	                                  and ID.IataNum = IH.Iatanum and Id.InvoiceDate = IH.InvoiceDate)
where CrAp.Iatanum = 'ORBITZ'
and CrAp.Text16 is NULL
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text16 Null- Text5 Text16',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------------------------------------------------------------
-----(/PK-) Text17	Y	Employee number	6x
SET @TransStart = getdate()

Update CrAp
set text17 = substring(UD.UdefData,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode )
				---	 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 104
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text17 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text17 PK Employee no',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-----(/DS) Text18   Y   Department from Udef 100
SET @TransStart = getdate()

Update CrAp
set text18 = substring(UD.UdefData,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode) 
				---	 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 100
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text18 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text18 DS Department',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

------(/KS-) Text19	 Y	Project name	17x (optional) - not sending yet
SET @TransStart = getdate()

Update CrAp
set text19 = substring(UD.UdefData,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode) 
				----	 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 120
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text19 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text19 KS Project name',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------Delivery Note/Inv#* (/AE-) Text20	  Y  Accounting unit	4x
SET @TransStart = getdate()

Update CrAp
set text20 = substring(UD.UdefData,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode)
					---- and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 103
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text20 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text20 AE Accounting Unit',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------(/IK-) - 21	   Y    Operating unit	5x
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus 
set Text21 = substring(udefdata,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode)
				----	 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 101
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text21 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text21 IK Operating Unit',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------- (/PR-) - 23	Y	Product number	5x
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus 
set Text23 = substring(udefdata,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode)
				----	 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 102
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text23 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text23 PR - Product number',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-------- (/AU-) - 24	Y	purpose	17x
SET @TransStart = getdate()

Update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus 
set Text24 = substring(udefdata,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode)
			----		 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 123
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text24 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text24 AU Purpose',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



------ AK -25		Business unit	3x (optional) - did not send any
SET @TransStart = getdate()

Update CrAp
set text25 = substring(UD.UdefData,1,150)
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode)
			----		 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 103
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text25 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text25 AK Business Unit',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------ Destination (/RZ-) - 26	Y	destination	1x -- BILLABLE OR NOT BILLABLE
SET @TransStart = getdate()

Update CrAp
set text26 = case when UD.udefdata='BILLABLE' then 'B' else 'N' end
from TTXPASQL01.TMAN503_ORBITZ.dba.Udef UD
	inner join TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus CrAp on
     				(CrAp.Recordkey = UD.Recordkey and CrAp.Seqnum = UD.Seqnum
					 and CrAp.Iatanum = UD.Iatanum and CrAp.ClientCode = Ud.ClientCode)
				----	 and CrAp.IssueDate = UD.IssueDate and CrAp.InvoiceDate = UD.InvoiceDate)
where UdefNum = 121
and CrAp.Iatanum = 'ORBITZ'
and CrAp.Text26 = '-'
and CrAp.Text49 = 'N' 
--and CrAp.Text45 = 'N'
--and ((CrAp.Text45 = 'N') or (CrAp.Text45 = 'Y' and Crap.SeqNum <> 1))
and CrAp.Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Text26 RZ Destination',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


------------------------------------------------------------
----     QC Check 
     
---------- Text3 = TP card
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int3 = 1 
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus 
WHERE Iatanum = 'ORBITZ'
and Text3 in ('192000501064750','192000001080264')
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC Int3',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


---------    Text4 = Expiration. Date 
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int4=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus 
WHERE  iatanum = 'ORBITZ'
and text4 like '[0-9][0-9][0-9][0-9]'
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC Int4',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



---------   Text5 =  Ticket Number
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int5=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text5 like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 	
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int5 tkt',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int5=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and text5 like'554%'
and LEN(text5)=9
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int5 554',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int5=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and text5 like'526%'
and text5 <> '526'
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int5 526',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



----------   Text6 =   Transaction Date
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int6=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text6 like '20[0-9][0-9][0-9][0-9][0-9][0-9]'
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int6',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



------------- Text15 =  Departure Date
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int15=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus 
WHERE  iatanum = 'ORBITZ'
and text15 like '20[0-9][0-9][0-9][0-9][0-9][0-9]'
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int15',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



--------------- DBI_IK Text27 - Invoice number
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int27=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text27 like '%'
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int27',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



------------- Text29 = Client code 
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int29=1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text29 like '[0-9][0-9][0-9][0-9][0-9][0-9]' 	
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int29',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



------------  DBI_IK Text37 - Invoice number
SET @TransStart = getdate()

UPDATE TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
SET int37 = 1
FROM TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
WHERE  iatanum = 'ORBITZ'
and text37 like '%'
and text49 = 'N'   
--and Text45 = 'N'  
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC int37',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



SET @TransStart = getdate()

update TTXSASQL01.TMAN503_ORBITZ.dba.ComRmksAirPlus
set Text49 = 'Y'
WHERE Iatanum = 'ORBITZ'
and int3 = 1
and int4 = 1
and int5 = 1
and int6 = 1
and int15= 1
and int37 = 1
and text49 = 'N'
--and Text45 = 'N'
--and ((Text45 = 'N') or (Text45 = 'Y' and SeqNum <> 1))
and clientcode in ('TPT-TP5920019')
and Issuedate between '04/01/2014' and @EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='QC to Text49 Y',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End Stored Procedure',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



-------------------------------------------------------------
---After report from TTXDR is run and file sent to Airplus
--need to do an update statement showing those records are sent so they don't
--get sent in the next weeks file:

--Update ttxsasql01.tman503_orbitz.dba.ComRmksAirPlus 
--set text47 = getdate(), 
--    text49 = 'S' 
--from ttxsasql01.tman503_orbitz.dba.comrmksAirPlus crap
--where iatanum = 'ORBITZ'    
--and Text49 = 'y' 
--and Text39 = 'CC' and Text40 = 'TP'


GO
