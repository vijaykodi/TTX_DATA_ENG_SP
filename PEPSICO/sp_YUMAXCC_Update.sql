/****** Object:  StoredProcedure [dbo].[sp_YUMAXCC_Update]    Script Date: 7/7/2015 9:12:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_YUMAXCC_Update]
	
 AS
insert into dba.client
select distinct clientcode,iatanum,null,iatanum,null,null,null,null
,null,null,null,null,null,null,null,null,null,null,null,null
,null,null,null,null
from dba.ccheader
where iatanum ='YUMAXCC'
and clientcode+iatanum not in(select clientcode+iatanum
from dba.client
where iatanum ='YUMAXCC')
--set prugeind = W for records that were voided 
update t1
set t1.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t1.PurgeInd is null
and t1.iatanum ='YUMAXCC'
and t2.iatanum ='YUMAXCC'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))

update t2
set t2.PurgeInd = 'W'
from dba.CCTicket t1, dba.CCTicket t2
where t1.TicketNum = t2.TicketNum
and t1.ticketamt > 0
and t2.TicketAmt = (t1.TicketAmt*-1)
and t1.TicketNum not like '%000000%'
and t2.TicketNum not like '%000000%'
and t1.TransactionDate = t2.TransactionDate 
and t1.MatchedRecordKey is null
and t2.MatchedRecordKey is null
and t2.PurgeInd is null
and t1.iatanum ='YUMAXCC'
and t2.iatanum ='YUMAXCC'
and (t1.ticketissuer like ('AMERICAN EXPRESS%')
or t1.ticketissuer like ('GBT%'))

--BACKUP EID
update dba.CCHeader
set Remarks1 = EmployeeId
where IataNum = 'YUMAXCC'
and Remarks1 is null

--UPDATE BADIDs w/ID from agency where match
update cc
set cc.EmployeeId = cr.text1
from dba.CCHeader cc,dba.ComRmks cr
where cc.MatchedRecordKey = cr.RecordKey
and cc.MatchedIataNum = cr.IataNum
and cc.MatchedSeqNum = cr.SeqNum
and ISNULL(RIGHT('0000000000'+EmployeeID,10),'BAD') not in 
(select distinct RIGHT('0000000000'+employeeID1,10) from dba.employee where EmpEmail not like '%pep%')
and CC.IataNum = 'YUMAXCC'
--Default any not in Employee file
update dba.CCHeader
set EmployeeId = '999999999'
where ISNULL(RIGHT('0000000000'+EmployeeID,10),'BAD') not in 
(select distinct RIGHT('0000000000'+employeeID1,10) from dba.employee where EmpEmail not like '%pep%')
and IataNum = 'YUMAXCC'


update ch
set ch.remarks2 = em.costcenter
from dba.CCHeader ch, dba.employee em
where ch.Remarks1 = em.EmployeeID1
and ch.Remarks2 is null
and ch.IataNum = 'YUMAXCC'
and em.EmpEmail like '%@yum.com'

update ch
set ch.remarks2 = 'Not Provided'
from dba.CCHeader ch
where ch.Remarks2 is null
and ch.IataNum = 'YUMAXCC'
GO

ALTER AUTHORIZATION ON [dbo].[sp_YUMAXCC_Update] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Employee]    Script Date: 7/7/2015 9:12:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Employee](
	[EmployeeID1] [varchar](20) NULL,
	[LastName] [varchar](35) NULL,
	[FirstName] [varchar](25) NULL,
	[MiddleName] [varchar](15) NULL,
	[EmpEmail] [varchar](100) NULL,
	[EmployeeType] [varchar](50) NULL,
	[EmployeeStatus] [varchar](20) NULL,
	[EmployeeID2] [varchar](20) NULL,
	[BusinessAddress] [varchar](50) NULL,
	[BusinessCity] [varchar](50) NULL,
	[BusinessStateCd] [varchar](20) NULL,
	[BusinessCountry] [varchar](50) NULL,
	[BusinessRegion] [varchar](50) NULL,
	[SupervisorID] [varchar](20) NULL,
	[SupervisorFirstName] [varchar](25) NULL,
	[SupervisorLastName] [varchar](35) NULL,
	[SupervisorEmail] [varchar](100) NULL,
	[CostCenter] [varchar](50) NULL,
	[DeptNumber] [varchar](50) NULL,
	[DivisionNumber] [varchar](50) NULL,
	[OrganizationUnit] [varchar](50) NULL,
	[Company] [varchar](50) NULL,
	[AdditionalInfo1] [varchar](50) NULL,
	[AdditionalInfo2] [varchar](50) NULL,
	[AdditionalInfo3] [varchar](50) NULL,
	[AdditionalInfo4] [varchar](50) NULL,
	[AdditionalInfo5] [varchar](50) NULL,
	[AdditionalInfo6] [varchar](50) NULL,
	[AdditionalInfo7] [varchar](50) NULL,
	[AdditionalInfo8] [varchar](50) NULL,
	[AdditionalInfo9] [varchar](50) NULL,
	[AdditionalInfo10] [varchar](50) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ImportDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Employee] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ComRmks]    Script Date: 7/7/2015 9:12:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[ComRmks](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[InvoiceDate] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[Text1] [varchar](150) NULL,
	[Text2] [varchar](150) NULL,
	[Text3] [varchar](150) NULL,
	[Text4] [varchar](150) NULL,
	[Text5] [varchar](150) NULL,
	[Text6] [varchar](150) NULL,
	[Text7] [varchar](150) NULL,
	[Text8] [varchar](150) NULL,
	[Text9] [varchar](150) NULL,
	[Text10] [varchar](150) NULL,
	[Text11] [varchar](150) NULL,
	[Text12] [varchar](150) NULL,
	[Text13] [varchar](150) NULL,
	[Text14] [varchar](150) NULL,
	[Text15] [varchar](150) NULL,
	[Text16] [varchar](150) NULL,
	[Text17] [varchar](150) NULL,
	[Text18] [varchar](150) NULL,
	[Text19] [varchar](150) NULL,
	[Text20] [varchar](150) NULL,
	[Text21] [varchar](150) NULL,
	[Text22] [varchar](150) NULL,
	[Text23] [varchar](150) NULL,
	[Text24] [varchar](150) NULL,
	[Text25] [varchar](150) NULL,
	[Text26] [varchar](150) NULL,
	[Text27] [varchar](150) NULL,
	[Text28] [varchar](150) NULL,
	[Text29] [varchar](150) NULL,
	[Text30] [varchar](150) NULL,
	[Text31] [varchar](150) NULL,
	[Text32] [varchar](150) NULL,
	[Text33] [varchar](150) NULL,
	[Text34] [varchar](150) NULL,
	[Text35] [varchar](150) NULL,
	[Text36] [varchar](150) NULL,
	[Text37] [varchar](150) NULL,
	[Text38] [varchar](150) NULL,
	[Text39] [varchar](150) NULL,
	[Text40] [varchar](150) NULL,
	[Text41] [varchar](150) NULL,
	[Text42] [varchar](150) NULL,
	[Text43] [varchar](150) NULL,
	[Text44] [varchar](150) NULL,
	[Text45] [varchar](150) NULL,
	[Text46] [varchar](150) NULL,
	[Text47] [varchar](150) NULL,
	[Text48] [varchar](150) NULL,
	[Text49] [varchar](150) NULL,
	[Text50] [varchar](150) NULL,
	[Num1] [float] NULL,
	[Num2] [float] NULL,
	[Num3] [float] NULL,
	[Num4] [float] NULL,
	[Num5] [float] NULL,
	[Num6] [float] NULL,
	[Num7] [float] NULL,
	[Num8] [float] NULL,
	[Num9] [float] NULL,
	[Num10] [float] NULL,
	[Num11] [float] NULL,
	[Num12] [float] NULL,
	[Num13] [float] NULL,
	[Num14] [float] NULL,
	[Num15] [float] NULL,
	[Num16] [float] NULL,
	[Num17] [float] NULL,
	[Num18] [float] NULL,
	[Num19] [float] NULL,
	[Num20] [float] NULL,
	[Num21] [float] NULL,
	[Num22] [float] NULL,
	[Num23] [float] NULL,
	[Num24] [float] NULL,
	[Num25] [float] NULL,
	[Num26] [float] NULL,
	[Num27] [float] NULL,
	[Num28] [float] NULL,
	[Num29] [float] NULL,
	[Num30] [float] NULL,
	[Int1] [int] NULL,
	[Int2] [int] NULL,
	[Int3] [int] NULL,
	[Int4] [int] NULL,
	[Int5] [int] NULL,
	[Int6] [int] NULL,
	[Int7] [int] NULL,
	[Int8] [int] NULL,
	[Int9] [int] NULL,
	[Int10] [int] NULL,
	[Int11] [int] NULL,
	[Int12] [int] NULL,
	[Int13] [int] NULL,
	[Int14] [int] NULL,
	[Int15] [int] NULL,
	[Int16] [int] NULL,
	[Int17] [int] NULL,
	[Int18] [int] NULL,
	[Int19] [int] NULL,
	[Int20] [int] NULL,
 CONSTRAINT [PK_ComRmks] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ComRmks] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Client]    Script Date: 7/7/2015 9:13:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Client](
	[ClientCode] [varchar](15) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[CustName] [varchar](40) NULL,
	[CustAddr1] [varchar](40) NULL,
	[CustAddr2] [varchar](40) NULL,
	[CustAddr3] [varchar](40) NULL,
	[City] [varchar](25) NULL,
	[STATE] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[CustPhone] [varchar](20) NULL,
	[CountryCode] [varchar](5) NULL,
	[AttnLine] [varchar](40) NULL,
	[Email] [varchar](80) NULL,
	[ConsolidationCode] [varchar](50) NULL,
	[ClientRemark1] [varchar](255) NULL,
	[ClientRemark2] [varchar](255) NULL,
	[ClientRemark3] [varchar](255) NULL,
	[ClientRemark4] [varchar](255) NULL,
	[ClientRemark5] [varchar](255) NULL,
	[ClientRemark6] [varchar](255) NULL,
	[ClientRemark7] [varchar](255) NULL,
	[ClientRemark8] [varchar](255) NULL,
	[ClientRemark9] [varchar](255) NULL,
	[ClientRemark10] [varchar](255) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientCode] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Client] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCTicket]    Script Date: 7/7/2015 9:13:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCTicket](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[TransactionDate] [datetime] NULL,
	[TktReferenceNum] [varchar](23) NULL,
	[TicketNum] [varchar](10) NULL,
	[ValCarrierCode] [varchar](3) NULL,
	[ValCarrierNum] [int] NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCTicket] ADD [TktOriginatingCCNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[CCTicket] ADD [CostCenter] [varchar](14) NULL
ALTER TABLE [dba].[CCTicket] ADD [EmployeeId] [varchar](20) NULL
ALTER TABLE [dba].[CCTicket] ADD [SSNum] [varchar](11) NULL
ALTER TABLE [dba].[CCTicket] ADD [TransFeeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCTicket] ADD [IssuerCity] [varchar](30) NULL
ALTER TABLE [dba].[CCTicket] ADD [IssuerState] [varchar](6) NULL
ALTER TABLE [dba].[CCTicket] ADD [ServiceDate] [datetime] NULL
ALTER TABLE [dba].[CCTicket] ADD [Routing] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [ClassOfService] [varchar](20) NULL
ALTER TABLE [dba].[CCTicket] ADD [TicketIssuer] [varchar](37) NULL
ALTER TABLE [dba].[CCTicket] ADD [BookedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCTicket] ADD [PassengerName] [varchar](50) NULL
ALTER TABLE [dba].[CCTicket] ADD [OrigTicketNum] [varchar](10) NULL
ALTER TABLE [dba].[CCTicket] ADD [Remarks1] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [Remarks2] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [Remarks3] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [PurgeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCTicket] ADD [BilledDate] [datetime] NULL
ALTER TABLE [dba].[CCTicket] ADD [CarrierStr] [varchar](30) NULL
ALTER TABLE [dba].[CCTicket] ADD [TicketAmt] [float] NULL
ALTER TABLE [dba].[CCTicket] ADD [BilledCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCTicket] ADD [BatchName] [varchar](30) NULL
ALTER TABLE [dba].[CCTicket] ADD [MerchantId] [varchar](40) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedRecordKey] [varchar](70) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedClientCode] [varchar](15) NULL
ALTER TABLE [dba].[CCTicket] ADD [MatchedSeqNum] [int] NULL
ALTER TABLE [dba].[CCTicket] ADD [InternationalInd] [varchar](1) NULL
ALTER TABLE [dba].[CCTicket] ADD [Mileage] [float] NULL
ALTER TABLE [dba].[CCTicket] ADD [DaysAdvPurch] [smallint] NULL
ALTER TABLE [dba].[CCTicket] ADD [AdvPurchGroup] [varchar](20) NULL
ALTER TABLE [dba].[CCTicket] ADD [TrueTktCount] [smallint] NULL
ALTER TABLE [dba].[CCTicket] ADD [TripLength] [smallint] NULL
ALTER TABLE [dba].[CCTicket] ADD [ServiceCat] [varchar](2) NULL
ALTER TABLE [dba].[CCTicket] ADD [AlternateName] [varchar](50) NULL
ALTER TABLE [dba].[CCTicket] ADD [AncillaryFeeInd] [int] NULL
 CONSTRAINT [PK_CCTicket] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCTicket] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[CCHeader]    Script Date: 7/7/2015 9:13:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[CCHeader](
	[RecordKey] [varchar](70) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
	[MerchantId] [varchar](40) NULL,
	[CCSourceFile] [varchar](10) NULL,
	[RptCreateDate] [datetime] NULL,
	[CCCycleDate] [datetime] NULL,
	[TransactionDate] [datetime] NULL,
	[PostDate] [datetime] NULL,
	[BilledDate] [datetime] NULL,
	[RecordType] [varchar](2) NULL,
	[TransactionNum] [varchar](23) NULL,
	[BatchNum] [varchar](23) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCHeader] ADD [ControlCCNum] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [BasicCCNum] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [CreditCardNum] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dba].[CCHeader] ADD [ChargeDesc] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [TransactionType] [varchar](5) NULL
ALTER TABLE [dba].[CCHeader] ADD [RefundInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [ChargeType] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [FinancialCatCode] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [DisputedFlag] [varchar](25) NULL
ALTER TABLE [dba].[CCHeader] ADD [CardHolderName] [varchar](50) NULL
ALTER TABLE [dba].[CCHeader] ADD [LocalCurrAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [LocalTaxAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [LocalCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledTaxAmt] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledTaxAmt2] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [BilledCurrCode] [varchar](3) NULL
ALTER TABLE [dba].[CCHeader] ADD [BaseFare] [float] NULL
ALTER TABLE [dba].[CCHeader] ADD [IndustryCode] [varchar](2) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [PurgeInd] [varchar](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [BatchName] [varchar](30) NULL
ALTER TABLE [dba].[CCHeader] ADD [CostCenter] [varchar](14) NULL
ALTER TABLE [dba].[CCHeader] ADD [EmployeeId] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [SSNum] [varchar](11) NULL
ALTER TABLE [dba].[CCHeader] ADD [CompanyName] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedRecordKey] [varchar](70) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedIataNum] [varchar](8) NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedClientCode] [varchar](15) NULL
ALTER TABLE [dba].[CCHeader] ADD [CarHtlSeqNum] [int] NULL
ALTER TABLE [dba].[CCHeader] ADD [MatchedSeqNum] [int] NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks1] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks2] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks3] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks4] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks5] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks6] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks7] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks8] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks9] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks10] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks11] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks12] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks13] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks14] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [Remarks15] [varchar](40) NULL
ALTER TABLE [dba].[CCHeader] ADD [TransactionFlag] [char](1) NULL
ALTER TABLE [dba].[CCHeader] ADD [TransactionID] [varchar](20) NULL
ALTER TABLE [dba].[CCHeader] ADD [MarketCode] [varchar](10) NULL
ALTER TABLE [dba].[CCHeader] ADD [ImportDate] [datetime] NULL
ALTER TABLE [dba].[CCHeader] ADD [AncillaryFeeInd] [int] NULL
ALTER TABLE [dba].[CCHeader] ADD [CCFirstSix] [int] NULL
SET ANSI_PADDING ON
ALTER TABLE [dba].[CCHeader] ADD [CCLastFour] [varchar](4) NULL
ALTER TABLE [dba].[CCHeader] ADD [OriginatingCMAcctNum] [varchar](20) NULL
 CONSTRAINT [PK_CCHeader] PRIMARY KEY NONCLUSTERED 
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[CCHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/7/2015 9:13:23 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [dba].[ComRmks]
(
	[IssueDate] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCTicketI1]    Script Date: 7/7/2015 9:13:23 PM ******/
CREATE CLUSTERED INDEX [CCTicketI1] ON [dba].[CCTicket]
(
	[IataNum] ASC,
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [CCHeaderI1]    Script Date: 7/7/2015 9:13:23 PM ******/
CREATE CLUSTERED INDEX [CCHeaderI1] ON [dba].[CCHeader]
(
	[IataNum] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[MatchedInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ComRmksI2]    Script Date: 7/7/2015 9:13:23 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI2] ON [dba].[ComRmks]
(
	[IssueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI3]    Script Date: 7/7/2015 9:13:24 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI3] ON [dba].[ComRmks]
(
	[IataNum] ASC,
	[ClientCode] ASC,
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [ComRmksI4]    Script Date: 7/7/2015 9:13:24 PM ******/
CREATE NONCLUSTERED INDEX [ComRmksI4] ON [dba].[ComRmks]
(
	[InvoiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI2]    Script Date: 7/7/2015 9:13:24 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI2] ON [dba].[CCTicket]
(
	[TransactionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI3]    Script Date: 7/7/2015 9:13:25 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI3] ON [dba].[CCTicket]
(
	[TicketNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI4]    Script Date: 7/7/2015 9:13:25 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI4] ON [dba].[CCTicket]
(
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCTicketI5]    Script Date: 7/7/2015 9:13:25 PM ******/
CREATE NONCLUSTERED INDEX [CCTicketI5] ON [dba].[CCTicket]
(
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeader_AncFee]    Script Date: 7/7/2015 9:13:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHeader_AncFee] ON [dba].[CCHeader]
(
	[AncillaryFeeInd] ASC,
	[TransactionDate] ASC,
	[IndustryCode] ASC,
	[IataNum] ASC,
	[ClientCode] ASC,
	[BilledCurrCode] ASC
)
INCLUDE ( 	[BilledAmt]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeaderI2]    Script Date: 7/7/2015 9:13:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI2] ON [dba].[CCHeader]
(
	[BilledDate] ASC,
	[BatchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [CCHeaderI3]    Script Date: 7/7/2015 9:13:25 PM ******/
CREATE NONCLUSTERED INDEX [CCHeaderI3] ON [dba].[CCHeader]
(
	[IndustryCode] ASC,
	[MerchantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [IX_CCHEADER_IMPORTDATE]    Script Date: 7/7/2015 9:13:26 PM ******/
CREATE NONCLUSTERED INDEX [IX_CCHEADER_IMPORTDATE] ON [dba].[CCHeader]
(
	[ImportDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

