/****** Cannot script Unresolved Entities : Server[@Name='ttxsasql01']/Database[@Name='DataEnhancementAutomation']/UnresolvedEntity[@Name='SP_NewDataEnhancementRequest' and @Schema='dbo'] ******/
GO

/****** Object:  StoredProcedure [dbo].[sp_LogProcErrors]    Script Date: 7/13/2015 1:38:52 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_UBS_PrefHtlData_Update]    Script Date: 7/13/2015 1:38:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_UBS_PrefHtlData_Update]

AS
declare @TransStart DATETIME 
declare @ProcName varchar(50)
declare @TSUpdateEndSched nvarchar(50)
declare @IATANUM VARCHAR (50)


/************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 11/24/2014
--Modification:  Added Comment line for tracking
--R. Robinson
************************************************************************/
--R. Robinson modified 02/11/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
declare @tmpStepName nvarchar(50); set @tmpStepName = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9); set @tmpTimeStmp = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
----************************************************************************
------ Update dba.hotelproperty to set the NormPropertyName and PropertyName where norm name is NULL
update dba.hotelproperty 
set NormPropertyName = HotelPropertyName 
where normpropertyname is null and hotelpropertyname is not null and hotelpropertyname <> ''
and MasterID>1

------ Update dba.preferredhotels to set the Hotel Property Name and City to to match the Parent ID in dba.hotelporperty
update ph
set propname = dbo.topropercase (htlxref.normpropertyname)
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and propname <> htlxref.normpropertyname
and ph.MasterID <>'-1'
and ph.masterid is not null
and SEASON1START='2011-01-01'

update ph
set propcity = dbo.topropercase(htlxref.metroarea)
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and propcity <> htlxref.metroarea
and ph.MasterID <>'-1'
and ph.masterid is not null
and SEASON1START='2011-01-01'

--Master Chain Code updates so Top Hotel properties reports will return data with our without preferred
--SF# 6605617  KP 7/6/2015
 update ph
set ph.MASTERCHAINCODE=htlxref.chaincode
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and masterchaincode <> htlxref.chaincode
and ph.MasterID <>'-1'
and SEASON1START='2011-01-01'

 update ph
set ph.MASTERCHAINCODE=htlxref.chaincode
from dba.preferredhotels ph, dba.hotelproperty htlprop, dba.hotelproperty htlxref
where  ph.masterid = htlxref.masterid
and HTLXREF.ParentId = HTLPROP.MasterID  and masterchaincode is null
and ph.MasterID <>'-1'
and SEASON1START='2011-01-01'
 
  -------- Run HNN on Preferred Hotels table for any new hotels added
 --Data Enhancement Automation HNN Queries
Declare @HNNBeginDate datetime = '1/1/2014'
Declare @HNNEndDate datetime = '12/31/2020'

EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'UBSPH',
@Enhancement = 'HNN',
@Client = 'UBS',
@Delay = 15,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = @HNNBeginDate,
@EndDate = @HNNEndDate,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = 'Preferred',
@TextParam2 = 'TTXPASQL01',
@TextParam3 = 'TMAN_UBS',
@TextParam4 = 'DBA',
@TextParam5 = 'datasvc',
@TextParam6 = 'tman2009',
@TextParam7 = 'TTXSASQL03',
@TextParam8 = 'TTXCENTRAL',
@TextParam9 = 'DBA',
@TextParam10 = 'datasvc',
@TextParam11 = 'tman2009',
@TextParam12 = 'Push',
@TextParam13 = 'R',
@TextParam14 = NULL,
@TextParam15 = NULL,
@IntParam1 = NULL,
@IntParam2 = NULL,
@IntParam3 = NULL,
@IntParam4 = NULL,
@IntParam5 = NULL,
@BoolParam1 = NULL,
@BoolParam2 = NULL,
@BoolParam3 = NULL,
@BoolParam4 = NULL,
@BoolParam5 = NULL,
@BoolParam6 = NULL,
@BoolParam7 = NULL,
@BoolParam8 = NULL,
@BoolParam9 = NULL,
@BoolParam10 = NULL,
@CommandLineArgs = NULL


SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Pref Hotel Update Complete',@IataNum=@IATANUM,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

GO

ALTER AUTHORIZATION ON [dbo].[sp_UBS_PrefHtlData_Update] TO  SCHEMA OWNER 
GO

/****** Object:  UserDefinedFunction [dbo].[ToProperCase]    Script Date: 7/13/2015 1:38:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ToProperCase](@string VARCHAR(255)) 
RETURNS VARCHAR(255) 
AS BEGIN
   DECLARE @i INT           -- index
   DECLARE @l INT           -- input length
   DECLARE @c NCHAR(1)      -- current char
   DECLARE @f INT           -- first letter flag (1/0)
   DECLARE @o VARCHAR(255)  -- output string
   DECLARE @w VARCHAR(10)   -- characters considered as white space
   
   SET @w = '[' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(160) + ' ' + '-' + ']'
   SET @i = 0   SET @l = LEN(@string)
   SET @f = 1
   SET @o = ''

   WHILE @i <= @l
   BEGIN
     SET @c = SUBSTRING(@string, @i, 1)
     IF @f = 1
      BEGIN
      SET @o = @o + @c
      SET @f = 0
     END
     ELSE
     BEGIN
      SET @o = @o + LOWER(@c)
     END

   IF @c LIKE @w SET @f = 1

   SET @i = @i + 1
   END

    RETURN ltrim(rtrim(@o))
 END 
GO

ALTER AUTHORIZATION ON [dbo].[ToProperCase] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[ProcedureLogs]    Script Date: 7/13/2015 1:38:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[ProcedureLogs](
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

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[ProcedureLogs] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[PreferredHotels]    Script Date: 7/13/2015 1:38:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[PreferredHotels](
	[MAINPHONECOUNTRY] [varchar](15) NULL,
	[MAINPHONECITY] [varchar](15) NULL,
	[MAINPHONE] [varchar](20) NULL,
	[MASTERCHAINCODE] [varchar](5) NULL,
	[PROPNAME] [varchar](255) NULL,
	[PROPADD1] [varchar](255) NULL,
	[PROPADD2] [varchar](255) NULL,
	[PROPCITY] [varchar](100) NULL,
	[PROPSTATEPROV] [varchar](10) NULL,
	[PROPPOSTCODE] [varchar](20) NULL,
	[PROPCOUNTRY] [varchar](100) NULL,
	[SEASON1START] [datetime] NULL,
	[SEASON1END] [datetime] NULL,
	[SEASON2START] [datetime] NULL,
	[SEASON2END] [datetime] NULL,
	[SEASON3START] [datetime] NULL,
	[SEASON3END] [datetime] NULL,
	[SEASON4START] [datetime] NULL,
	[SEASON4END] [datetime] NULL,
	[LRA_S1_RT1_SGL] [float] NULL,
	[LRA_S2_RT1_SGL] [float] NULL,
	[LRA_S3_RT1_SGL] [float] NULL,
	[LRA_S4_RT1_SGL] [float] NULL,
	[RATE_CURR] [varchar](5) NULL,
	[AIRCITYCODE] [varchar](10) NULL,
	[InMasterHotel] [char](1) NULL,
	[MasterID] [int] NULL,
	[PropCountryCode] [varchar](5) NULL,
	[PrefInd] [char](1) NULL,
	[Customer] [varchar](50) NULL,
	[SeasonRate] [float] NULL,
	[SeasonStartDate] [datetime] NULL,
	[SeasonEndDate] [datetime] NULL,
	[MinorityOwned] [varchar](3) NULL,
	[WomanOwned] [varchar](3) NULL,
	[UversaID] [int] NULL,
	[LanyonID] [int] NULL,
	[SeasonRateCategory] [varchar](8) NULL,
	[SabreGDSCode] [varchar](8) NULL,
	[AmadeusGDSCode] [varchar](8) NULL,
	[ApolloGDSCode] [varchar](8) NULL,
	[WorldspanGDSCode] [varchar](8) NULL,
	[AnnualRoomNights] [int] NULL,
	[AnnualSpend] [float] NULL,
	[BrandName] [varchar](100) NULL,
	[HtlCityCode] [varchar](50) NULL,
	[GreenInd] [char](1) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[PreferredHotels] TO  SCHEMA OWNER 
GO

/****** Object:  Table [DBA].[HotelProperty]    Script Date: 7/13/2015 1:39:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBA].[HotelProperty](
	[MasterID] [int] NULL,
	[PhoneNumber] [varchar](20) NULL,
	[ChainCode] [varchar](6) NULL,
	[HotelPropertyName] [varchar](255) NULL,
	[HotelAddress1] [varchar](255) NULL,
	[HotelAddress2] [varchar](255) NULL,
	[HotelAddress3] [varchar](255) NULL,
	[HotelCityCode] [varchar](10) NULL,
	[HotelCityName] [varchar](100) NULL,
	[HotelStateProvince] [varchar](20) NULL,
	[HotelPostalCode] [varchar](15) NULL,
	[HotelCountryCode] [varchar](5) NULL,
	[HotelFaxNumber] [varchar](20) NULL,
	[PreferredHotelInd] [varchar](1) NULL,
	[NewHotelInd] [varchar](1) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[MaxScore] [float] NULL,
	[MatchScore] [float] NULL,
	[MatchRate] [float] NULL,
	[PropNameTokenCount] [float] NULL,
	[AddressTokenCount] [float] NULL,
	[CityTokenCount] [float] NULL,
	[PhoneToken01] [varchar](30) NULL,
	[PropNameToken01] [varchar](30) NULL,
	[PropNameToken02] [varchar](30) NULL,
	[PropNameToken03] [varchar](30) NULL,
	[PropNameToken04] [varchar](30) NULL,
	[PropNameToken05] [varchar](30) NULL,
	[PropNameToken06] [varchar](30) NULL,
	[PropNameToken07] [varchar](30) NULL,
	[AddressToken01] [varchar](30) NULL,
	[AddressToken02] [varchar](30) NULL,
	[AddressToken03] [varchar](30) NULL,
	[AddressToken04] [varchar](30) NULL,
	[AddressToken05] [varchar](30) NULL,
	[AddressToken06] [varchar](30) NULL,
	[AddressToken07] [varchar](30) NULL,
	[AddressToken08] [varchar](30) NULL,
	[AddressToken09] [varchar](30) NULL,
	[AddressToken10] [varchar](30) NULL,
	[CityToken01] [varchar](30) NULL,
	[CityToken02] [varchar](30) NULL,
	[CityToken03] [varchar](30) NULL,
	[CityToken04] [varchar](30) NULL,
	[CityToken05] [varchar](30) NULL,
	[StateToken01] [varchar](30) NULL,
	[PostalCodeToken01] [varchar](30) NULL,
	[CountryCodeToken01] [varchar](30) NULL,
	[PropNameTokenString] [varchar](75) NULL,
	[AddressTokenString] [varchar](75) NULL,
	[CityTokenString] [varchar](75) NULL,
	[ParentId] [int] NULL,
	[HotelUpdateInd] [char](10) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[Floors] [float] NULL,
	[Rooms] [float] NULL,
	[Suites] [float] NULL,
	[Restaurants] [float] NULL,
	[MeetingRooms] [float] NULL,
	[MeetingCapacity] [float] NULL,
	[MeetingSqFoot] [float] NULL,
	[EmailAddress] [varchar](100) NULL,
	[InternetAddress] [varchar](100) NULL,
	[ManagementName] [varchar](60) NULL,
	[HotelTypeName] [varchar](60) NULL,
	[LocationName] [varchar](60) NULL,
	[ScaleName] [varchar](60) NULL,
	[CountyName] [varchar](60) NULL,
	[FemaCode] [varchar](50) NULL,
	[TollFree] [varchar](50) NULL,
	[ChainName] [varchar](100) NULL,
	[Source] [varchar](4) NULL,
	[LocationId] [int] NULL,
	[NormPropertyName] [varchar](255) NULL,
	[NormAddress1] [varchar](255) NULL,
	[NormAddress2] [varchar](255) NULL,
	[NormAddress3] [varchar](255) NULL,
	[NormCityName] [varchar](100) NULL,
	[MetroArea] [varchar](100) NULL,
	[SubNeighborhood] [varchar](100) NULL,
	[NearestMasterID] [int] NULL,
	[ClusterID] [varchar](25) NULL,
	[StarRating] [varchar](10) NULL,
	[UversaID] [int] NULL,
	[LanyonID] [int] NULL,
	[SabrePropNum] [varchar](20) NULL,
	[GalileoPropNum] [varchar](20) NULL,
	[AmadeusPropNum] [varchar](20) NULL,
	[WorldSpanPropNum] [varchar](20) NULL,
	[UserDefined01] [varchar](50) NULL,
	[UserDefined02] [varchar](50) NULL,
	[UserDefined03] [varchar](50) NULL,
	[UserDefined04] [varchar](50) NULL,
	[UserDefined05] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [DBA].[HotelProperty] TO  SCHEMA OWNER 
GO

/****** Object:  Index [PreferredHotels_I1]    Script Date: 7/13/2015 1:39:15 PM ******/
CREATE CLUSTERED INDEX [PreferredHotels_I1] ON [DBA].[PreferredHotels]
(
	[MasterID] ASC,
	[SEASON1END] ASC,
	[SEASON2START] ASC,
	[SEASON2END] ASC,
	[SEASON3START] ASC,
	[SEASON3END] ASC,
	[SEASON4START] ASC,
	[SEASON4END] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [PX_HotelProperty]    Script Date: 7/13/2015 1:39:16 PM ******/
CREATE UNIQUE CLUSTERED INDEX [PX_HotelProperty] ON [DBA].[HotelProperty]
(
	[MasterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

SET ANSI_PADDING ON

GO

/****** Object:  Index [PreferredHotels_I2]    Script Date: 7/13/2015 1:39:16 PM ******/
CREATE NONCLUSTERED INDEX [PreferredHotels_I2] ON [DBA].[PreferredHotels]
(
	[PrefInd] ASC
)
INCLUDE ( 	[MasterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

