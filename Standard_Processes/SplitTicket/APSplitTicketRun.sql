--WAITFOR DELAY '00:00:05'
---set up Split Ticket to DEA

         Declare @From as varchar(3)
         Declare @To as varchar(3)
         Declare @CommandLine as varchar(100)
         Declare @BeginIssueDate as datetime
         Declare @EndIssueDate as datetime
         Set @BeginIssueDate = '2012-01-01'
         Set @EndIssueDate = '2012-03-31'
       
      select @From = abs(datediff(dd,getdate(),@BeginIssueDate))
      select @To = abs(datediff(dd,getdate(),@EndIssueDate))
      set @CommandLine = '-RNAP -BD'+@From+ ' -ED'+@To+' -UIdatasvc -PWtman2009 -DS_APPLIED_MATERIALS_TTXPASQL01'
EXEC ttxsasql01.[DataEnhancementAutomation].[dbo].[SP_NewDataEnhancementRequest]
@DatamanRequestName = 'Applied Materials',
@Enhancement = 'SplitTkt',
@Client = 'Applied Materials',
@Delay = 10,
@Priority = NULL,
@Notes = NULL,
@Suspend = false,
@RunAtTime = NULL,
@BeginDate = NULL,
@EndDate = NULL,
@DateParam1 = NULL,
@DateParam2 = NULL,
@TextParam1 = NULL,
@TextParam2 = NULL,
@TextParam3 = NULL,
@TextParam4 = NULL,
@TextParam5 = NULL,
@TextParam6 = NULL,
@TextParam7 = NULL,
@TextParam8 = NULL,
@TextParam9 = NULL,
@TextParam10 = NULL,
@TextParam11 = NULL,
@TextParam12 = NULL,
@TextParam13 = NULL,
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
@CommandLineArgs = @CommandLine
