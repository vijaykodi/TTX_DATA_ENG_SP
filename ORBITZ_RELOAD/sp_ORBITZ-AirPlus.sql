/****** Cannot script Unresolved Entities : Server[@Name='TTXSASQL01']/Database[@Name='TMAN503_ORBITZ']/UnresolvedEntity[@Name='ComRmksAirPlus' and @Schema='dba'] ******/
GO

/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN503_ORBITZ']/UnresolvedEntity[@Name='Udef' and @Schema='dba'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/7/2015 11:14:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Trent Watkins
-- Create date: 5/19/2011
-- Last update: 8/5/2011
-- Description:	Standardized logging and error handling for stored procedures
-- =============================================
CREATE PROCEDURE [dbo].[sp_LogProcErrors] (
	-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
	@ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
	@RowCount int, -- **REQUIRED** Total number of affected rows
	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)
AS

SET NOCOUNT ON

/* Declare variables used by this procedure to track any errors it may generate */
DECLARE @Error int, -- Error Trapping for this procedure
	@LogRowCount int, -- The Number of rows being inserted into the ProcedureLogs table
	@Error_Message varchar(255), -- The Error Message for this Procedure
	@Error_Type int, -- Used to track where errors are raised inside this procedure
	@Error_Loc int -- The Location in this procedure where an error was spawned

SELECT @Error_Message = 'NO ERROR'
	
-- IF the dba.ProcedureLogs table does not exist in the database then we need to create it
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ProcedureLogs' AND TABLE_SCHEMA = 'dba')
	BEGIN
		CREATE TABLE [dba].[ProcedureLogs](
			[ProcedureName] [sysname] NOT NULL,
			[LogStart] [datetime] NOT NULL,
			[LogEnd] [datetime] NOT NULL,
			[RunByUSER] [char](30) NOT NULL,
			[StepName] [varchar](50) NOT NULL,
			[BeginIssueDate] [datetime] NULL,
			[EndIssueDate] [datetime] NULL,
			[IataNum] [varchar](50) NULL,
			[RowCount] [int] NOT NULL,
			[Error] [int] NOT NULL,
			[ErrorMessage] [nvarchar](2000) NOT NULL
		) ON [PRIMARY];
	END
		
/* Start the transaction to Log the Parent Procedure
and catch any errors that this procedure generates */

DECLARE @RunByUSER sysname
DECLARE @sql nvarchar(1000)
SELECT @RunByUSER = SYSTEM_USER

/* If an error number was passed to this procedure build a message and raise an error */
IF @ERR <> 0
	BEGIN
		SELECT @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
	END

INSERT INTO dba.ProcedureLogs (
		ProcedureName
		,LogStart
		,LogEnd
		,RunByUSER
		,StepName
		,BeginIssueDate
		,EndIssueDate
		,IataNum
		,[RowCount]
		,Error
		,ErrorMessage) 
	SELECT @ProcedureName
		,@LogStart
		,GetDate()
		,@RunByUSER
		,@StepName
		,@BeginDate
		,@EndDate
		,@IataNum
		,@RowCount
		,@ERR
		,@Error_Message

IF @ERR <> 0
	BEGIN
		SELECT @Error_Type = 50001, @Error_Loc = 1, @Error_Message = (SELECT 'ERROR: '+ RTRIM(CONVERT(CHAR(6),@ERR))+' , MESSAGE: '+ [text] FROM sys.messages WHERE message_id = @ERR AND language_id = 1033)
		RAISERROR(@Error_Message,18,1)
		RETURN
	END		


GO

ALTER AUTHORIZATION ON [dbo].[sp_LogProcErrors] TO  SCHEMA OWNER 
GO

/****** Object:  StoredProcedure [dbo].[sp_ORBITZ-AirPlus]    Script Date: 7/7/2015 11:14:18 PM ******/
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

ALTER AUTHORIZATION ON [dbo].[sp_ORBITZ-AirPlus] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ProcedureLogs]    Script Date: 7/7/2015 11:14:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[ProcedureLogs](
	[ProcedureName] [sysname] NOT NULL,
	[LogStart] [datetime] NOT NULL,
	[LogEnd] [datetime] NOT NULL,
	[RunByUSER] [char](30) NOT NULL,
	[StepName] [varchar](255) NULL,
	[BeginIssueDate] [datetime] NULL,
	[EndIssueDate] [datetime] NULL,
	[IataNum] [varchar](50) NULL,
	[RowCount] [int] NOT NULL,
	[Error] [int] NOT NULL,
	[ErrorMessage] [nvarchar](2000) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Payment]    Script Date: 7/7/2015 11:14:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Payment](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[PaymentSeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL
) ON [INDEXES]
SET ANSI_PADDING ON
ALTER TABLE [dba].[Payment] ADD [CCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[Payment] ADD [CCExp] [varchar](10) NULL
ALTER TABLE [dba].[Payment] ADD [CCApprovalCode] [varchar](10) NULL
ALTER TABLE [dba].[Payment] ADD [CurrCode] [varchar](3) NULL
ALTER TABLE [dba].[Payment] ADD [PaymentAmt] [float] NULL
ALTER TABLE [dba].[Payment] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[Payment] ADD [CCLastFour] [varchar](4) NULL
 CONSTRAINT [PK_Payment] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[Payment] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceHeader]    Script Date: 7/7/2015 11:14:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceNum] [varchar](15) NULL,
	[TicketingBranch] [varchar](10) NULL,
	[BookingBranch] [varchar](10) NULL,
	[TtlInvoiceAmt] [float] NULL,
	[TtlTaxAmt] [float] NULL,
	[TtlCommissionAmt] [float] NULL,
	[CurrCode] [varchar](30) NULL,
	[OrigCountry] [varchar](5) NULL,
	[SalesAgentID] [varchar](10) NULL,
	[FOP] [varchar](2) NULL,
	[CCCode] [varchar](6) NULL,
	[CCNum] [varchar](50) NULL,
	[CCExp] [varchar](10) NULL,
	[CCApprovalCode] [varchar](10) NULL,
	[GDSCode] [varchar](10) NULL,
	[BackOfficeID] [varchar](20) NULL,
	[IMPORTDT] [datetime] NULL,
	[TtlCO2Emissions] [float] NULL,
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[InvoiceDetail]    Script Date: 7/7/2015 11:14:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[VoidInd] [varchar](1) NULL,
	[VoidReasonType] [varchar](3) NULL,
	[Salutation] [varchar](10) NULL,
	[FirstName] [varchar](25) NULL,
	[Lastname] [varchar](35) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[InvoiceType] [varchar](10) NULL,
	[InvoiceTypeDescription] [varchar](255) NULL,
	[DocumentNumber] [varchar](15) NULL,
	[EndDocNumber] [varchar](3) NULL,
	[VendorNumber] [varchar](15) NULL,
	[VendorType] [varchar](10) NULL,
	[ValCarrierNum] [int] NULL,
	[ValCarrierCode] [varchar](6) NULL,
	[VendorName] [varchar](40) NULL,
	[BookingDate] [datetime] NULL,
	[ServiceDate] [datetime] NULL,
	[ServiceCategory] [varchar](8) NULL,
	[InternationalInd] [varchar](1) NULL,
	[ServiceFee] [float] NULL,
	[InvoiceAmt] [float] NULL,
	[TaxAmt] [float] NULL,
	[TotalAmt] [float] NULL,
	[CommissionAmt] [float] NULL,
	[CancelPenaltyAmt] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[FareCompare1] [float] NULL,
	[ReasonCode1] [varchar](6) NULL,
	[FareCompare2] [float] NULL,
	[ReasonCode2] [varchar](6) NULL,
	[FareCompare3] [float] NULL,
	[ReasonCode3] [varchar](6) NULL,
	[FareCompare4] [float] NULL,
	[ReasonCode4] [varchar](6) NULL,
	[Mileage] [float] NULL,
	[Routing] [varchar](120) NULL,
	[DaysAdvPurch] [int] NULL,
	[AdvPurchGroup] [varchar](10) NULL,
	[TrueTktCount] [int] NULL,
	[TripLength] [float] NULL,
	[ExchangeInd] [varchar](1) NULL,
	[OrigExchTktNum] [varchar](15) NULL,
	[Department] [varchar](40) NULL,
	[ETktInd] [varchar](1) NULL,
	[ProductType] [varchar](20) NULL,
	[TourCode] [varchar](15) NULL,
	[EndorsementRemarks] [varchar](60) NULL,
	[FareCalcLine] [varchar](255) NULL,
	[GroupMult] [int] NULL,
	[OneWayInd] [varchar](1) NULL,
	[PrefTktInd] [varchar](1) NULL,
	[HotelNights] [float] NULL,
	[CarDays] [float] NULL,
	[OnlineBookingSystem] [varchar](20) NULL,
	[AccommodationType] [varchar](10) NULL,
	[AccommodationDescription] [varchar](255) NULL,
	[ServiceType] [varchar](10) NULL,
	[ServiceDescription] [varchar](255) NULL,
	[ShipHotelName] [varchar](255) NULL,
	[Remarks1] [varchar](100) NULL,
	[Remarks2] [varchar](100) NULL,
	[Remarks3] [varchar](100) NULL,
	[Remarks4] [varchar](100) NULL,
	[Remarks5] [varchar](100) NULL,
	[IntlSalesInd] [varchar](4) NULL,
	[MatchedInd] [varchar](1) NULL,
	[MatchedFields] [varchar](255) NULL,
	[RefundInd] [varchar](1) NULL,
	[OriginalInvoiceNum] [varchar](15) NULL,
	[BranchIataNum] [varchar](8) NULL,
	[GDSRecordLocator] [varchar](10) NULL,
	[BookingAgentID] [varchar](10) NULL,
	[TicketingAgentID] [varchar](10) NULL,
	[OriginCode] [varchar](10) NULL,
	[DestinationCode] [varchar](10) NULL,
	[TktCO2Emissions] [float] NULL,
	[CCMatchedRecordKey] [varchar](100) NULL,
	[CCMatchedIataNum] [varchar](8) NULL,
	[ACQMatchedInd] [varchar](1) NULL,
	[ACQMatchedRecordKey] [varchar](100) NULL,
	[ACQMatchedIataNum] [varchar](8) NULL,
	[CarrierString] [varchar](50) NULL,
	[ClassString] [varchar](50) NULL,
	[CRMatchedInd] [varchar](1) NULL,
	[CRMatchedRecordKey] [varchar](100) NULL,
	[CRMatchedIataNum] [varchar](8) NULL,
	[LastImportDt] [datetime] NULL,
	[GolUpdateDt] [datetime] NULL,
	[OrigTktAmt] [float] NULL,
	[TktWasExchangedInd] [varchar](1) NULL,
	[TicketGroupId] [varchar](50) NULL
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[TranSeg]    Script Date: 7/7/2015 11:14:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[TranSeg](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [int] NOT NULL,
	[SegmentNum] [int] NOT NULL,
	[TypeCode] [varchar](1) NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[OriginCityCode] [varchar](10) NULL,
	[SegmentCarrierCode] [varchar](3) NULL,
	[SegmentCarrierName] [varchar](40) NULL,
	[CodeShareCarrierCode] [varchar](3) NULL,
	[EquipmentCode] [varchar](10) NULL,
	[PrefAirInd] [varchar](1) NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureTime] [varchar](5) NULL,
	[FlightNum] [varchar](15) NULL,
	[ClassOfService] [varchar](8) NULL,
	[FareBasis] [varchar](30) NULL,
	[TktDesignator] [varchar](15) NULL,
	[ConnectionInd] [varchar](1) NULL,
	[StopOverTime] [int] NULL,
	[FrequentFlyerNum] [varchar](15) NULL,
	[FrequentFlyerMileage] [float] NULL,
	[CurrCode] [varchar](3) NULL,
	[SEGDestCityCode] [varchar](10) NULL,
	[SEGInternationalInd] [varchar](1) NULL,
	[SEGArrivalDate] [datetime] NULL,
	[SEGArrivalTime] [varchar](5) NULL,
	[SEGSegmentValue] [float] NULL,
	[SEGSegmentMileage] [float] NULL,
	[SEGTotalMileage] [float] NULL,
	[SEGFlightTime] [int] NULL,
	[SEGMktOrigCityCode] [varchar](10) NULL,
	[SEGMktDestCityCode] [varchar](10) NULL,
	[SEGReturnInd] [int] NULL,
	[NOXDestCityCode] [varchar](10) NULL,
	[NOXInternationalInd] [varchar](1) NULL,
	[NOXArrivalDate] [datetime] NULL,
	[NOXArrivalTime] [varchar](5) NULL,
	[NOXSegmentValue] [float] NULL,
	[NOXSegmentMileage] [float] NULL,
	[NOXTotalMileage] [float] NULL,
	[NOXFlightTime] [int] NULL,
	[NOXMktOrigCityCode] [varchar](10) NULL,
	[NOXMktDestCityCode] [varchar](10) NULL,
	[NOXConnectionString] [varchar](19) NULL,
	[NOXReturnInd] [int] NULL,
	[MINDestCityCode] [varchar](10) NULL,
	[MINInternationalInd] [varchar](1) NULL,
	[MINArrivalDate] [datetime] NULL,
	[MINArrivalTime] [varchar](5) NULL,
	[MINSegmentValue] [float] NULL,
	[MINSegmentMileage] [float] NULL,
	[MINTotalMileage] [float] NULL,
	[MINFlightTime] [int] NULL,
	[MINMktOrigCityCode] [varchar](10) NULL,
	[MINMktDestCityCode] [varchar](10) NULL,
	[MINConnectionString] [varchar](19) NULL,
	[MINReturnInd] [int] NULL,
	[MealName] [varchar](4) NULL,
	[NOXSegmentCarrierCode] [varchar](3) NULL,
	[NOXSegmentCarrierName] [varchar](40) NULL,
	[NOXClassOfService] [varchar](8) NULL,
	[MINSegmentCarrierCode] [varchar](3) NULL,
	[MINSegmentCarrierName] [varchar](40) NULL,
	[MINClassOfService] [varchar](8) NULL,
	[NOXClassString] [varchar](20) NULL,
	[NOXFareBasisString] [varchar](100) NULL,
	[MINClassString] [varchar](20) NULL,
	[MINFareBasisString] [varchar](100) NULL,
	[NOXFlownMileage] [float] NULL,
	[MINFlownMileage] [float] NULL,
	[SEGCO2Emissions] [float] NULL,
	[NOXCO2Emissions] [float] NULL,
	[MINCO2Emissions] [float] NULL,
	[FSeats] [int] NULL,
	[BusSeats] [int] NULL,
	[EconSeats] [int] NULL,
	[TtlSeats] [int] NULL,
	[YieldInd] [varchar](1) NULL,
	[YieldAmt] [float] NULL,
	[YieldDatePosted] [datetime] NULL,
	[SegTrueTktCount] [int] NULL
) ON [INDEXES]

GO

SET ANSI_PADDING ON
GO

ALTER AUTHORIZATION ON [dba].[TranSeg] TO  SCHEMA OWNER 
GO

/****** Object:  Index [PaymentI1]    Script Date: 7/7/2015 11:14:43 PM ******/
CREATE CLUSTERED INDEX [PaymentI1] ON [dba].[Payment]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[PaymentSeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/7/2015 11:14:43 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [dba].[InvoiceHeader]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC,
	[OrigCountry] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/7/2015 11:14:44 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegI1]    Script Date: 7/7/2015 11:14:44 PM ******/
CREATE CLUSTERED INDEX [TransegI1] ON [dba].[TranSeg]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[IssueDate] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [PaymentI2]    Script Date: 7/7/2015 11:14:45 PM ******/
CREATE NONCLUSTERED INDEX [PaymentI2] ON [dba].[Payment]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/7/2015 11:14:45 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [dba].[InvoiceHeader]
(
	[BookingBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI5]    Script Date: 7/7/2015 11:14:45 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI5] ON [dba].[InvoiceHeader]
(
	[OrigCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/7/2015 11:14:45 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [dba].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/7/2015 11:14:45 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [dba].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/7/2015 11:14:45 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI3]    Script Date: 7/7/2015 11:14:46 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI3] ON [dba].[InvoiceDetail]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [InvoiceDetailI5]    Script Date: 7/7/2015 11:14:46 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI5] ON [dba].[InvoiceDetail]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailPX]    Script Date: 7/7/2015 11:14:46 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetailPX] ON [dba].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/7/2015 11:14:46 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [dba].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Index [TranSegI4]    Script Date: 7/7/2015 11:14:46 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI4] ON [dba].[TranSeg]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI5]    Script Date: 7/7/2015 11:14:46 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI5] ON [dba].[TranSeg]
(
	[ClientCode] ASC,
	[IataNum] ASC,
	[DepartureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TranSegI6]    Script Date: 7/7/2015 11:14:47 PM ******/
CREATE NONCLUSTERED INDEX [TranSegI6] ON [dba].[TranSeg]
(
	[OriginCityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [TransegPX]    Script Date: 7/7/2015 11:14:47 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [TransegPX] ON [dba].[TranSeg]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC,
	[SegmentNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

