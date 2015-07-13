/****** Cannot script Unresolved Entities : Server[@Name='TTXPASQL01']/Database[@Name='TMAN_UBS']/UnresolvedEntity[@Name='c'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_UBS_Americas_EMEA_Viewed]    Script Date: 7/13/2015 12:42:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[sp_UBS_Americas_EMEA_Viewed]


-- Update Americas and EMEA with "Already seen" flag in Text 11 at 9:30 AM on Tuesday and Thursday
as

update c
set text11 = 'Y', text16 = getdate()
from dba.invoicedetail i, dba.comrmks c, dba.invoiceheader ih
where i.recordkey = c.recordkey and i.seqnum = c.seqnum
and i.recordkey = ih.recordkey
and i.voidind = 'N'
and i.refundind = 'N'
and i.exchangeind = 'N'
and i.remarks2 <> 'Unknown'
and isnull(text21,'xx') not like '%hold%'
and i.iatanum = 'Preubs'
and text5  in ('Europe EMEA','Switzerland','UK','Americas')
and importdt <= getdate()
and text11 is null



GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_Americas_EMEA_Viewed] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceHeader]    Script Date: 7/13/2015 12:42:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceHeader](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[ClientCode] [varchar](15) NULL,
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
	[CCFirstSix] [int] NULL,
	[CCLastFour] [varchar](4) NULL,
	[CLIQCID] [varchar](100) NULL,
	[CLIQUSER] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceHeader] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[InvoiceDetail]    Script Date: 7/13/2015 12:42:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[InvoiceDetail](
	[RecordKey] [varchar](50) NOT NULL,
	[IataNum] [varchar](8) NOT NULL,
	[SeqNum] [smallint] NOT NULL,
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
	[ValCarrierNum] [smallint] NULL,
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
	[DaysAdvPurch] [smallint] NULL,
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
	[GroupMult] [smallint] NULL,
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
	[TktCO2Emissions] [float] NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [DBA].[InvoiceDetail] ADD [CCMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CCMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ACQMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CarrierString] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [ClassString] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedRecordKey] [varchar](100) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [CRMatchedIataNum] [varchar](8) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [LastImportDt] [datetime] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [GolUpdateDt] [datetime] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigTktAmt] [float] NULL
SET ANSI_PADDING ON
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktWasExchangedInd] [varchar](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TicketGroupId] [varchar](50) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OriginalDocumentNumber] [varchar](15) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigBaseFare] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktOrder] [int] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigFareCompare1] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [OrigFareCompare2] [float] NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [TktWasRefundedInd] [char](1) NULL
ALTER TABLE [DBA].[InvoiceDetail] ADD [NetTktAmt] [float] NULL

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[InvoiceDetail] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ComRmks]    Script Date: 7/13/2015 12:42:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ComRmks](
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
	[Int20] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ComRmks] TO  SCHEMA OWNER 
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI1]    Script Date: 7/13/2015 12:43:05 PM ******/
CREATE CLUSTERED INDEX [InvoiceHeaderI1] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[InvoiceDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI1]    Script Date: 7/13/2015 12:43:05 PM ******/
CREATE CLUSTERED INDEX [InvoiceDetailI1] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksI1]    Script Date: 7/13/2015 12:43:05 PM ******/
CREATE CLUSTERED INDEX [ComRmksI1] ON [DBA].[ComRmks]
(
	[IataNum] ASC,
	[IssueDate] ASC,
	[ClientCode] ASC,
	[RecordKey] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI2]    Script Date: 7/13/2015 12:43:05 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI2] ON [DBA].[InvoiceHeader]
(
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI3]    Script Date: 7/13/2015 12:43:06 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI3] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[OrigCountry] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate],
	[BackOfficeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderI4]    Script Date: 7/13/2015 12:43:06 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceHeaderI4] ON [DBA].[InvoiceHeader]
(
	[IataNum] ASC,
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[ClientCode],
	[InvoiceDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceHeaderPX]    Script Date: 7/13/2015 12:43:06 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceHeaderPX] ON [DBA].[InvoiceHeader]
(
	[RecordKey] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM]    Script Date: 7/13/2015 12:43:07 PM ******/
CREATE NONCLUSTERED INDEX [IX_INVOICEHEADER_IMPORTDT_I_RECORDKEY_IATANUM] ON [DBA].[InvoiceHeader]
(
	[IMPORTDT] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ACMTrueTkt]    Script Date: 7/13/2015 12:43:07 PM ******/
CREATE NONCLUSTERED INDEX [ACMTrueTkt] ON [DBA].[InvoiceDetail]
(
	[TrueTktCount] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[IssueDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IDExchProc_I1]    Script Date: 7/13/2015 12:43:10 PM ******/
CREATE NONCLUSTERED INDEX [IDExchProc_I1] ON [DBA].[InvoiceDetail]
(
	[VoidInd] ASC,
	[ExchangeInd] ASC,
	[VendorType] ASC
)
INCLUDE ( 	[RecordKey],
	[IataNum],
	[SeqNum],
	[ClientCode],
	[IssueDate],
	[DocumentNumber],
	[TicketGroupId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_PX]    Script Date: 7/13/2015 12:43:11 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [InvoiceDetail_PX] ON [DBA].[InvoiceDetail]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetail_TicketGroupId]    Script Date: 7/13/2015 12:43:11 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetail_TicketGroupId] ON [DBA].[InvoiceDetail]
(
	[TicketGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI2]    Script Date: 7/13/2015 12:43:12 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI2] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[VoidInd] ASC,
	[VendorType] ASC,
	[ExchangeInd] ASC,
	[RefundInd] ASC
)
INCLUDE ( 	[RecordKey],
	[SeqNum],
	[ClientCode],
	[InvoiceDate],
	[IssueDate],
	[FirstName],
	[Lastname],
	[DocumentNumber],
	[BookingDate],
	[ServiceDate],
	[TotalAmt],
	[CurrCode],
	[ReasonCode1],
	[FareCompare2],
	[Routing],
	[DaysAdvPurch],
	[TripLength],
	[OnlineBookingSystem],
	[Remarks1],
	[Remarks2],
	[GDSRecordLocator]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [InvoiceDetailI4]    Script Date: 7/13/2015 12:43:14 PM ******/
CREATE NONCLUSTERED INDEX [InvoiceDetailI4] ON [DBA].[InvoiceDetail]
(
	[ExchangeInd] ASC,
	[OrigExchTktNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [IXIDRefundMatch]    Script Date: 7/13/2015 12:43:15 PM ******/
CREATE NONCLUSTERED INDEX [IXIDRefundMatch] ON [DBA].[InvoiceDetail]
(
	[IataNum] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [RefundMatchCoverIndex01]    Script Date: 7/13/2015 12:43:15 PM ******/
CREATE NONCLUSTERED INDEX [RefundMatchCoverIndex01] ON [DBA].[InvoiceDetail]
(
	[DocumentNumber] ASC,
	[VendorType] ASC,
	[RefundInd] ASC,
	[IataNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [INDEXES]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [ComRmksPX]    Script Date: 7/13/2015 12:43:16 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ComRmksPX] ON [DBA].[ComRmks]
(
	[RecordKey] ASC,
	[IataNum] ASC,
	[SeqNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [INDEXES]
GO

/****** Object:  Trigger [DBA].[TR_INVOICEDETAIL_I]    Script Date: 7/13/2015 12:43:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [DBA].[TR_INVOICEDETAIL_I]
    ON [DBA].[InvoiceDetail]
 AFTER INSERT
    AS
BEGIN
        SET NOCOUNT ON;
        UPDATE i
                SET i.TicketGroupId = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.TicketGroupId FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (ins.RecordKey)
                        END
                ),
                i.OriginalDocumentNumber = (
                        CASE
                                WHEN i.ExchangeInd = 'Y'
                                        THEN (SELECT TOP 1 d.OriginalDocumentNumber FROM dba.InvoiceDetail d where d.DocumentNumber = i.OrigExchTktNum)
                                ELSE (ins.DocumentNumber)
                        END
                )
        FROM dba.InvoiceDetail i
        JOIN inserted ins
        ON i.RecordKey = ins.RecordKey
        AND i.IataNum = ins.IataNum
        AND i.SeqNum = ins.SeqNum
END


GO

