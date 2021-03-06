/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:39:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
AS
BEGIN
--Creater: Nina Lutz
--Create Date: 10/29/2012
 /************************************************************************
	LOGGING_START - BEGIN
************************************************************************/
DECLARE  @ProcName varchar(50), @TransStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--Log Activity
SET @TransStart = getdate()


--=================================
--Added by rcr  07/08/2015
--Adding variables for logging.
--
--@LogSegNbr is an incremented number that is automatically generated to show 
--the actual number of Logged Segments within a stored procedure.
--When searching, use the literal string for best results.  (i.e. 'Stored Procedure Started logging')
--Example: 'Stored Procedure Started logging'
--=================================
--==-----------------------------For Logging -------------------------------------------------------------------------------------
Declare @Iata varchar(50)
--, @ProcName varchar(50)
--, @TransStart datetime
--, @BeginIssueDate datetime
--, @ENDIssueDate datetime
, @LocalBeginIssueDate DATETIME = GETDATE()
, @LocalEndIssueDate DATETIME = GETDATE()
, @LogSegNbr int = 0
, @LogStep varchar(250)

SET @Iata = 'SP_PostHNNProcedure'
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
--SET @BeginIssueDate = Null
--SET @ENDIssueDate = Null 
SET @TransStart = getdate()
--==------------------------------------------------------------------------------------------------------------------------------

 ----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Started logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


--=====
--Next line commented out - 07/08/2015 rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Started logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====
/************************************************************************
	LOGGING_START - END
************************************************************************/ 
--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
WAITFOR DELAY '00:00.30' 
--

Update dba.HotelProperty
set MetroArea = NormCityName
where MetroArea is null

 ----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') null--> MetroArea = NormCityName'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR	


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--
Update dba.HotelProperty
set MetroArea = NormCityName
where MetroArea = ''

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') empty--> MetroArea = NormCityName'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
	
	
--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--		
update dba.HotelProperty
set MetroArea = 'New York-Northern New Jersey-Long Island, NY-NJ-PA'
where MetroArea like '%New York%'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = New York-Northern New Jersey-Long Island, NY-NJ-PA'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	
update dba.HotelProperty
set MetroArea = 'Los Angeles-Long Beach-Santa Ana, CA'
where metroarea like '%Los Angeles%'
and HotelCountryCode = 'US'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = Los Angeles-Long Beach-Santa Ana, CA'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	
update dba.HotelProperty
set MetroArea = 'London'
where metroarea like '%London%'
and HotelCountryCode = 'GB'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = London'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

update dba.HotelProperty
set MetroArea = 'Zurich'
where metroarea like '%Zurich%'
and HotelCountryCode = 'CH'
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = Zurich'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

update dba.HotelProperty
set MetroArea = 'Hong Kong'
where metroarea like '%Hong Kong%'
and HotelCountryCode in ('TW','CN','HK')

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = Hong Kong'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

update dba.HotelProperty
set MetroArea = 'Singapore'
where metroarea like '%Singapore%'
and HotelCountryCode in ('SG')

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = Singapore'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

update dba.HotelProperty
set MetroArea = 'Beijing'
where metroarea like '%Beijing%'
and HotelCountryCode in ('CN')

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = Beijing'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

update dba.HotelProperty
set MetroArea = 'Chica-Naperville-Joliet, IL-IN-WI'
where MetroArea like '%Chica%'
and HotelCountryCode = 'US'
and HotelStateProvince = 'IL'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') MetroArea = Chica-Naperville-Joliet, IL-IN-WI'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	
update HTLPROP
set ChainCode= HtlChainCode
from dba.Hotel htl, dba.HotelProperty XREF, dba.HotelProperty HTLPROP
where htl.MasterID = xref.masterid
and xref.parentid = htlprop.MasterID
and htlprop.ChainCode = 'XX'
and htl.HtlChainCode not in ('XX','00','1A','CWT','EUO','GRP','OTE','RON')
and htl.IssueDate >= '2011-01-01' 

--====
--Next 2 lines commented out - 07/08/2015  rcr 
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='HTLPROP Updates',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--====

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') HTLPROP Updates'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--update dba.HotelProperty
--set ParentId = 75673
--where ParentId in (75673,174351)

--update dba.HotelProperty
--set ParentId = 75676
--where parentid in (75676,234633)

--update dba.HotelProperty
--set ParentId = 75646
--where MasterID in (305345,327283,194812)

--update dba.HotelProperty
--set ParentId = 75738
--where MasterID in (371621,351865)

--update dba.HotelProperty
--set ParentId = 75676
--where MasterID in (234633,234634,234635)

--update dba.HotelProperty
--set ParentId = 43875
--where MasterID in (379564)

--update dba.HotelProperty
--set ParentId = 82984
--where MasterID in (375182)

--update dba.HotelProperty
--set ParentId = 82984
--where MasterID in (375182,377340)

--update dba.PreferredHotels
--set MasterID = 82984
--where MasterID = 377340

--update dba.HotelProperty
--set ParentId = 48194
--where MasterID in (366385)

--update dba.PreferredHotels
--set MasterID = 48194
--where MasterID = 366385

--update dba.HotelProperty
--set ParentId = 48192
--where MasterID in (370563,370565,302251,203980,286916)

--update dba.PreferredHotels
--set MasterID = 48192
--where MasterID = 370563

--update dba.HotelProperty
--set ParentId = 39319
--where MasterID in (370458,370455)

--update dba.PreferredHotels
--set MasterID = 39319
--where MasterID = 370455

--update dba.HotelProperty
--set ParentId = 41602
--where parentid in (86578,233847)

--update dba.PreferredHotels
--set MasterID = 41602
--where MasterID = 86578

--update dba.HotelProperty
--set ParentId = 37332
--where masterid in (90193)

--update dba.Hotel
--set MasterID = 41042
--where MasterID in (41042,290819,328489,147916,147917,190132)

--update dba.HotelProperty
--set ParentId = 74327
--where masterid in (329906)

--update dba.HotelProperty
--set ParentId = 244555
--where masterid in (357951)

--update dba.PreferredHotels
--set MasterID = 244555
--where MasterID = 357951

--update dba.HotelProperty
--set ParentId = 149568
--where masterid in (371579)

--update dba.PreferredHotels
--set MasterID = 74328
--where MasterID = 377353

--update dba.HotelProperty
--set ParentId = 279995
--where masterid in (377365)

--update dba.PreferredHotels
--set MasterID = 279995
--where MasterID = 377365

--update dba.HotelProperty
--set ParentId = 75429
--where masterid in (377341)

--update dba.PreferredHotels
--set MasterID = 75429
--where MasterID = 377341

--update dba.hotelproperty
--set metroarea = 'JOHANNESBURG'
--where parentid = 105147

--update dba.HotelProperty
--set ParentId = 43047
--where masterid in (377364)

--update dba.PreferredHotels
--set MasterID = 43047
--where MasterID = 377364

--update dba.HotelProperty
--set ParentId = 3929
--where masterid in (360621)

--update dba.PreferredHotels
--set MasterID = 3929
--where MasterID = 360621

--update dba.HotelProperty
--set ParentId = 5709
--where masterid in (366193)

--update dba.PreferredHotels
--set MasterID = 5709
--where MasterID = 366193

--update dba.HotelProperty
--set MetroArea = 'St. Louis, MO-IL'
--where MetroArea = 'SAINT LOUIS'

--update dba.HotelProperty
--set ParentId = 44761
--where masterid in (84606,379566,370519,369921,327025,327814)

--update dba.HotelProperty
--set ParentId = 41720
--where masterid in (329813)

--update dba.PreferredHotels
--set MasterID = 41720
--where MasterID = 41721

--update dba.HotelProperty
--set ParentId = 71235
--where masterid in (294206,104171,150019,313224,329826,324641,324134)

--update dba.HotelProperty
--set ParentId = 153056
--where parentid in (224990)

--update dba.PreferredHotels
--set MasterID = 2120
--where MasterID = 330256

--update dba.HotelProperty
--set ParentId = 153056
--where MasterID in (375132)

--update dba.HotelProperty
--set ParentId = 6105
--where MasterID in (373291)

--update dba.HotelProperty
--set ParentId = 60152
--where MasterID in (378362)

--update dba.PreferredHotels
--set MasterID = 60203
--where MasterID = 60106

--update dba.HotelProperty
--set ParentId = 47970
--where MasterID in (377366)

--update dba.PreferredHotels
--set MasterID = 47970
--where MasterID = 377366

--update dba.HotelProperty
--set ParentId = 57808
--where MasterID in (375158)

--Update dba.HotelProperty
--set MetroArea = 'Miami-Fort Lauderdale-Pompano Beach, FL'
--where MetroArea = 'Miami Beach'

--update dba.PreferredHotels
--set MasterID = 81810
--where MasterID = 81807

--update dba.HotelProperty
--set ParentId = 75642
--where MasterID in (194865,194866,321813)

--update dba.HotelProperty
--set ParentId = 76361
--where MasterID in (377342)

--update dba.PreferredHotels
--set MasterID = 76361
--where MasterID = 377342

--update dba.Hotel
--set MasterID = 351780
--where MasterID in (29514,251896,293773,295356,330001,331197,361898)

--update dba.HotelProperty
--set ParentId = 53004
--where ParentId in (53005)

--update dba.PreferredHotels
--set MasterID = 53004
--where MasterID = 53005

--update dba.HotelProperty
--set ParentId = 5067
--where MasterID in (369242)

--update dba.PreferredHotels
--set MasterID = 5067
--where MasterID = 369242

--update dba.HotelProperty
--set ParentId = 36587
--where MasterID in (371348)

--update dba.HotelProperty
--set ParentId = 42936
--where MasterID in (123611)

--update dba.Hotel 
--set MasterID = '314337' where 
--MasterID in (289948,368802,251745,251933,293821,375365,315253,325633,372602,136491)

--Update dba.HotelProperty
--set MetroArea = 'SAINT PETERSBURG'
--where MetroArea like '%PETERSBURG%'
--and HotelCountryCode = 'RU'

--Update dba.HotelProperty
--set MetroArea = 'Tampa-St. Petersburg-Clearwater, FL'
--where MetroArea like '%PETERSBURG%'
--and HotelCountryCode = 'US'
--and HotelStateProvince = 'FL'
--and MetroArea <> 'Tampa-St. Petersburg-Clearwater, FL'

--Update dba.HotelProperty
--set MetroArea = 'St. Louis, MO-IL'
--where MetroArea like 'ST%Louis%'
--and HotelCountryCode = 'US'
--and HotelStateProvince in ('IL','MO')
--and MetroArea <> 'St. Louis, MO-IL'

--Update dba.HotelProperty
--set MetroArea = 'HONG KONG'
--where MetroArea like '%KOWLOON%'

--update dba.Hotel
--set MasterID = '46586'
--where MasterID in (366715,
--372682,
--378841)

----Nina and Tonya's updates
----Need to update in Central and then run preferred updates in UBS
--update dba.hotelproperty
--set parentid = '72586'
--where parentid = '331055'

--update dba.hotelproperty
--set parentid = '72592'
--where parentid = '179450'

--update dba.hotelproperty
--set parentid = '87451'
--where parentid = '83741'

--update dba.hotelproperty
--set parentid = '47494'
--where parentid = '105133'


--update dba.hotelproperty
--set parentid = '83747'
--where parentid = '83746'

--update dba.hotelproperty
--set parentid = '47537'
--where parentid = '377359'

--update dba.hotelproperty
--set parentid = '75004'
--where parentid = '329732'

--update dba.hotelproperty
--set parentid = '39902'
--where parentid in ('377188','379484','171908')

--update dba.hotelproperty
--set parentid = '29514'
--where parentid in ('361898')

--update dba.hotelproperty
--set parentid = '10725'
--where parentid in ('377377')

--update dba.hotelproperty
--set parentid = '40676'
--where parentid in ('377370')

--update dba.hotelproperty
--set parentid = '36507'
--where parentid in ('371350', '317423')

--update dba.hotelproperty
--set parentid = '91692'
--where parentid in ('41066', '379498')

--update dba.hotelproperty
--set parentid = '80268'
--where parentid in ('178965')

--update dba.hotelproperty
--set parentid = '75652'
--where parentid in ('377345')

--update dba.hotelproperty
--set parentid = '65589'
--where parentid in ('377352')

--update dba.hotelproperty
--set parentid = '65592'
--where parentid in ('377360')

--update dba.hotelproperty
--set parentid = '76025'
--where parentid in ('377343')

--update dba.hotelproperty
--set parentid = '74999'
--where parentid in ('377356')

--update dba.hotelproperty
--set hotelcityname = 'LUXEMBOURG'
--where parentid in (147249)
--and masterid = 147249
--and hotelcityname = 'LUXEMBOURG CITY'

--update dba.hotelproperty
--set parentid = 147249
--where parentid = 334417
--and hotelpropertyname like 'SOFITEL LUXEMBOURG EURO%'

--update dba.hotelproperty
--set parentid = 95566
--where parentid = 54278
--and masterid = 242953

--update dba.hotelproperty
--set parentid = 377365
--where parentid in (47647,279995)

--update dba.hotelproperty
--set parentid = 37302
--where parentid in (377374)

--update dba.hotelproperty
--set parentid = 43489
--where parentid in (234356)

--update dba.hotelproperty
--set parentid = 57807
--where parentid in (375174)

--update dba.hotelproperty
--set parentid = 18663
--where parentid in (377372)

--update dba.hotelproperty
--set parentid = 377362
--where parentid in (67809)

--update dba.hotelproperty
--set parentid = 377362
--where parentid in (351591,379630,367077)

--update dba.hotelproperty
--set parentid = 246314
--where parentid in (171016)
--and masterid in (246314,313196)

--update dba.hotelproperty
--set parentid = 68761
--where parentid in (173641)

--update dba.hotelproperty
--set parentid = 53963
--where parentid in (53934)
----and masterid in (246314,313196)
--and hotelpropertyname like '%LE MERIDIEN BUDAP%'

--update dba.hotelproperty
--set parentid = 297296
--where parentid in (80596)

--update dba.hotelproperty
--set parentid = 67150
--where parentid in (377348)

--update dba.hotelproperty
--set hotelpropertyname = 'JOLLY MILANOFIORI'
--where masterid = 51063
--and parentid = 51063

--update dba.hotelproperty
--set parentid = 77942
--where parentid in (377346)

--update dba.hotelproperty
--set parentid = 2120
--where parentid in (330256,369188,371698,379218)

--update dba.hotelproperty
--set parentid = 47648
--where parentid in (101921,329717)

--update dba.hotelproperty
--set parentid = 65592
--where parentid in (373997,379806)

--update dba.hotelproperty
--set parentid = 6105
--where parentid in (330237,370280)

--update dba.hotelproperty
--set parentid = 85240
--where parentid in (75365,380513)

--update dba.hotelproperty
--set parentid = 123
--where parentid in (279608,297787,300128)

--update dba.hotelproperty
--set parentid = 60203
--where parentid in (338767)

--update dba.hotelproperty
--set parentid = 3929
--where parentid in (5272,145421)

--update dba.hotelproperty
--set parentid = 75429
--where parentid in (223036,379886)

--update dba.hotelproperty
--set parentid = 84200
--where parentid in (17177)

--update dba.hotelproperty
--set parentid = 43711
--where parentid in (179894)

----Tonya's updates on 10/16/12
--update dba.hotelproperty
--set parentid = '55685' --Four Seasons London
--where parentid in ('233989')

--update dba.hotelproperty
--set parentid = '123733'
--where parentid in ('124326')

--update dba.hotelproperty
--set parentid = '65589' --Melia Barcelona Hotel
--where parentid in ('376061')

--update dba.HotelProperty
--set ParentId = 75646
--where MasterID in (246220,174351,170119,194812)

--update dba.HotelProperty
--set ParentId = 76361
--where MasterID in (102756)

--update dba.HotelProperty
--set ParentId = 43875
--where MasterID in (377367)

--update dba.PreferredHotels
--set MasterID = 43875
--where MasterID = 377367

--update dba.HotelProperty
--set ParentId = 77921
--where MasterID in (371670)

--update dba.PreferredHotels
--set MasterID = 77921
--where MasterID = 371670

--update dba.HotelProperty
--set ParentId = 48165
--where MasterID in (371430)

--update dba.HotelProperty
--set ParentId = 39675
--where MasterID in (166061,166081,166095,233729)

--update dba.HotelProperty
--set ParentId = 57807
--where MasterID in (351839,84707,357017,371482,225149,251916,293801,304853,331857,338447)

--update  dba.HotelProperty
--set PhoneNumber = 441316665124
--where MasterID = 57807

--update dba.HotelProperty
--set ParentId = 63302
--where MasterID in (371484)

--update dba.Hotel
--set MasterID = '317258'
--where MasterID in (47526,98283,103469,167000,191206,298766,298767,329351)

--update dba.HotelProperty
--set ParentId = 68637
--where MasterID in (145229,251849,293701,330110,371564)

--update dba.HotelProperty
--set ParentId = 27083
--where MasterID in (377375)

--update dba.PreferredHotels
--set MasterID = 27083
--where MasterID = 377375

--update dba.PreferredHotels
--set MasterID = 377365
--where MasterID = 279995

--update dba.HotelProperty
--set ParentId = 83050
--where MasterID in (246314)

--update dba.HotelProperty
--set ParentId = 313196
--where MasterID in (313196)

--update dba.HotelProperty
--set ParentId = 220186
--where MasterID in (220186)

--update dba.HotelProperty
--set ParentId = 55992
--where MasterID in (322870)

--update dba.HotelProperty
--set ParentId = 74466
--where MasterID in (371592)

--update dba.HotelProperty
--set ParentId = 53148
--where MasterID in (371458)

--update dba.HotelProperty
--set ParentId = 377357
--where MasterID in (336314,375470,376750,377357)

--update dba.HotelProperty
--set ParentId = 79785
--where MasterID in (329964,371669,379959)

--update dba.HotelProperty
--set ParentId = 64790
--where MasterID in (377355,379811)

--update dba.hotelproperty
--set phonenumber = '+34(91)4410015'
--where masterid = '64790'

--update dba.HotelProperty
--set ParentId = 66458
--where MasterID in (377349)

--update dba.PreferredHotels
--set MasterID = 66458
--where MasterID = 377349

--Update dba.HotelProperty
--set MetroArea = 'JOHANNESBURG'
--where MetroArea like '%SANDTON%'
--and HotelCountryCode = 'ZA'

--update dba.HotelProperty
--set ParentId = 60152
--where MasterID in (378362)

--update dba.hotelproperty
--set phonenumber = '33153434300'
--where masterid = '60152'

--update dba.HotelProperty
--set ParentId = 83746
--where MasterID in (83746,109166,234172)

--update dba.HotelProperty
--set ParentId = 83747
--where MasterID in (357572,83747)

--update dba.HotelProperty
--set ParentId = 47494
--where MasterID in (105133,
--376322,
--371708,
--157305,
--329636,47494)

--update dba.HotelProperty
--set PhoneNumber = '+961(1)971111',
--HotelAddress1 = 'MARTYRS  SQ. BEIRUT CENTRAL DISTRICT'
--where MasterID = '47494'

--update dba.HotelProperty
--set ParentId = 66448
--where MasterID in (377350)

--update dba.PreferredHotels
--set MasterID = 66448
--where MasterID = 377350

--update dba.HotelProperty
--set ParentId = 47477
--where MasterID in (377361)

--update dba.PreferredHotels
--set MasterID = 47477
--where MasterID = 377361

--update dba.HotelProperty
--set ParentId = 12237
--where MasterID in (189563,295132,323121)

--update dba.PreferredHotels
--set MasterID = 12237
--where MasterID = 189563

--update dba.HotelProperty
--set ParentId = 47583
--where MasterID in (377358)

--update dba.PreferredHotels
--set MasterID = 47583
--where MasterID = 377358

--update dba.HotelProperty
--set ParentId = 80609
--where MasterID in (145287,195715)

--update dba.HotelProperty
--set ParentId = 68760
--where MasterID in (371548)

--update dba.HotelProperty
--set ParentId = 157754
--where MasterID in (335777)

--update dba.PreferredHotels
--set MasterID = 157754
--where MasterID = 335777

--update dba.HotelProperty
--set ParentId = 80062
--where MasterID in (99063)

--update dba.HotelProperty
--set ParentId = 33745
--where MasterID in (376312)

--update dba.PreferredHotels
--set MasterID = 33745
--where MasterID = 376312

--update dba.HotelProperty
--set ParentId = 103123
--where MasterID in (103123,290849)

--update dba.HotelProperty
--set ParentId = 53101
--where MasterID in (53182,
--105045,
--108126)

--update dba.HotelProperty
--set ParentId = 80202
--where MasterID in (98361,
--195634,
--294835)

--update dba.HotelProperty
--set ParentId = 43712
--where MasterID in (377363)

--update dba.PreferredHotels
--set MasterID = 43712
--where MasterID = 377363

--update dba.HotelProperty
--set ParentId = 331850
--where MasterID in (377347)

--update dba.PreferredHotels
--set MasterID = 331850
--where MasterID = 377347

--update dba.PreferredHotels
--set MasterID = 47494
--where MasterID = 371708

--update dba.HotelProperty
--set ParentId = 74330
--where MasterID in (377354)

--update dba.PreferredHotels
--set MasterID = 74330
--where MasterID = 377354

--Using current year thru end of preferred data since UBS data from BCD is imported  
--including historical back 4 months
--Preferred data now avail thru 03-31-2016 KP 7/6/2015

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

update dba.hotel
set prefhtlind = 'N'
where prefhtlind is null
and checkoutdate between '2015-04-01' and '2016-03-31'
and InvoiceDate BETWEEN GETDATE()-90 AND GETDATE()
and iatanum <> 'PREUBS' --Change to Iatanum that had just been processed

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update dba.hotel'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

--set preferred rates to 0
Update dba.hotel 
set htlcommamt = 0
where htlcommamt is null
and checkoutdate between '2015-01-01' and '2016-03-31'
and InvoiceDate BETWEEN GETDATE()-90 AND GETDATE()
and iatanum <> 'PREUBS' --Change to Iatanum that had just been processed

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') set preferred rates to 0'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

--UBS not seeming to use season1 dates - using only seasonstart and season end
--made update to preferred hotel table to copy seasonstart and seasonend to season1start
--and season1end so below logic will udpate preferreds.

--update preferred hotels based upon season 1 date--most current date range
update htl
set prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where  pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and htl.checkindate between pfh.season1start and pfh.season1end
and htl.checkoutdate between '2015-04-01' and '2016-03-31'
and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update preferred hotels based upon season 1 date--most current date range'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

--Update season 1 rates
update htl
set htlcommamt = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.checkindate between pfh.Season1Start and pfh.Season1End
and htl.checkoutdate between '2015-04-01' and '2016-03-31'
and pfh.LRA_S1_RT1_SGL is not null
and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Season1-most current dt updates'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

--=====
--Next 2 lines commented out - 07/08/2015 rcr
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Season1-most current dt updates',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

--update preferred hotels based upon season 2 date--previous year since ubs sends rolling year data
--that includes booking for both last year and this year -- 
update htl
set prefhtlind= 'Y'
from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where  pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and htl.checkindate between pfh.season2start and pfh.season2end
and htl.checkoutdate between '2014-01-01' and '2016-03-31'
and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') update preferred hotels based upon season 2 date'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

--Update season 2 rates
update htl
set htlcommamt = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2),
htl.prefhtlind = 'Y'   
from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
where htl.checkindate between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = HTL.MasterId
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pfh.rate_curr
and htl.checkoutdate between '2014-01-01' and '2016-03-31'
and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed


----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Season2 updates'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--=====
--Next 2 lines commented out - 07/08/2015 rcr
--SET @TransStart = getdate()
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Season2 updates',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--=====

--Only use below if UBS adds seasons or additional years to data being processed
--update preferred hotels based upon season 3 date--
--update htl
--set prefhtlind= 'Y'
--from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
--where  pfh.masterid = HTLXREF.parentid
--and HTLXREF.MasterID = HTL.MasterId
--and htl.checkindate between pfh.season3start and pfh.SEASON3END
--and htl.checkoutdate between '2011-01-01' and '2012-12-31'
--and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed


--Update season 3 rates
--update htl
--set htlcommamt = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2),
--htl.prefhtlind = 'Y'   
--from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
--where htl.checkindate between pfh.Season3Start and pfh.Season3End
--and pfh.masterid = HTLXREF.parentid
--and HTLXREF.MasterID = HTL.MasterId
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = htl.issuedate
--and curr.currcode = pfh.rate_curr
--and htl.checkoutdate between '2011-01-01' and '2012-12-31'
--and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed


--update preferred hotels based upon season 4 date--
--update htl
--set prefhtlind= 'Y'
--from dba.hotel htl, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
--where  pfh.masterid = HTLXREF.parentid
--and HTLXREF.MasterID = HTL.MasterId
--and htl.checkindate between pfh.season4start and pfh.SEASON4END
--and htl.checkoutdate between '2011-01-01' and '2012-12-31'
--and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed


--Update season 4 rates
--update htl
--set htlcommamt = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2),
--htl.prefhtlind = 'Y'   
--from dba.hotel htl, dba.preferredhotels pfh, dba.currency curr, dba.hotelproperty HTLXREF
--where htl.checkindate between pfh.Season4Start and pfh.Season4End
--and pfh.masterid = HTLXREF.parentid
--and HTLXREF.MasterID = HTL.MasterId
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = htl.issuedate
--and curr.currcode = pfh.rate_curr
--and htl.checkoutdate between '2011-01-01' and '2012-12-31'
--and htl.iatanum <> 'PREUBS' --Change to Iatanum that had just been processed

SET @TransStart = getdate()

--Hotel Sourcing--
--Update credit card data with Preferred Indicator and preferred Rates--
update dba.cchotel
set noshowind = 'N'
where noshowind IS NULL
and ISNULL(transactiondate,arrivaldate)>='2015-01-01'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update credit card data with Preferred Indicator and preferred Rates'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR


--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	

Update cchtl
set cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.ccmerchant ccm, dba.preferredhotels pfh, dba.hotelproperty HTLXREF
where ISNULL(cchtl.transactiondate,cchtl.arrivaldate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and ISNULL(cchtl.transactiondate,cchtl.arrivaldate)>='2015-01-01'
and cchtl.NoShowInd<>'Y'

----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Update cchtl  - cchtl.noshowind = Y'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--No preferred Rates given for bookings past 3-31-2013 so not adding that to their process

--update dba.cchotel
--set othercharges = 0
 
--update cchtl
--set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2) 
--from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
--where ISNULL(cchtl.transactiondate,cchtl.arrivaldate) between pfh.Season1Start and pfh.Season1End
--and pfh.masterid = HTLXREF.parentid
--and HTLXREF.MasterID = CCM.MasterId
--and cchtl.merchantid = ccm.merchantid
--and curr.basecurrcode = 'USD'
--and curr.currbegindate = cchtl.transactiondate
--and curr.currcode = pfh.rate_curr  
 

--Added by rcr  07/08/2015
WAITFOR DELAY '00:00.30'
SET @TransStart = Getdate() 
--	
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') CCData Preferred Update'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR

--====
--Next line commented out - 07/08/2015  rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='CCData Preferred Update',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--==== 
 /************************************************************************
	LOGGING_ENDED - BEGIN
************************************************************************/
--Log Activity
--Added by rcr  07/08/2015
SET @TransStart = Getdate() 
--	
--====
--Next line commented out - 07/08/2015  rcr
--EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Stored Procedure Ended logging',@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
--====
----Added by rcr  07/08/2015
set @LogSegNbr += 1 
set @LogStep = convert( varchar(2) ,@LogSegNbr) + ') Stored Procedure Ended logging'
----
EXEC dbo.sp_LogProcErrors 
	@ProcedureName=@ProcName
	,@IataNum=@Iata
	,@LogStart=@TransStart
	,@StepName=@LogStep
	,@BeginDate=@LocalBeginIssueDate
	,@EndDate=@LocalEndIssueDate
	,@RowCount=@@ROWCOUNT
	,@ERR=@@ERROR
/************************************************************************
	LOGGING_ENDED - END
************************************************************************/  

END
GO
