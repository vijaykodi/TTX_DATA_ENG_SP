/****** Object:  StoredProcedure [dbo].[sp_ExecuteLocalBatchFile]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Trent Watkins
-- Create date: 10/15/2011
-- Last update: 8/5/2011 (Brian Perry)
-- Description:	Calls and executes a local batch file
-- the Paramter @BatchPath can be passed to the procedure
-- otherwise the default "hardcoded" path will be used
-- =============================================
CREATE PROCEDURE [dbo].[sp_ExecuteLocalBatchFile] (
	@RemoteBatch varchar(500), --Path to the Remote Batch file that needs to be executed
	@RemoteServer varchar(50), --Full UNC path to the remote server (EX: \\TTXPWS01.TRXFS.TRX.COM
	@RemoteUser varchar(100) = N'wtpdh\smsservice',	--Domain\Username that will logon to the RemoteServer
	@RemotePword varchar(100) = N'melanie', --Password for the username
	@RemoteArgs varchar(500)) --Arguments that will be passed into the RemoteBatch file
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 DECLARE @ProcName varchar(50), @ProcStart datetime
 SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
 SET @ProcStart = getdate()

 DECLARE @cmd varchar(2000)
 -- Log start of the dbo.sp_ExecuteLocalBatchFile procedure
 EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='1 - Starting dbo.sp_ExecuteLocalBatchFile [Executing PSEXEC]',@BEGINDate=NULL,@ENDDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
 
 SET @cmd = 'psexec -accepteula -d '+@RemoteServer+' -u ' +@RemoteUser+' -p '+@RemotePword+' '+@RemoteBatch+' '+@RemoteArgs

 EXECUTE master..xp_cmdshell @cmd
 
 EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='2 - Completed dbo.sp_ExecuteLocalBatchFile [Executing PSEXEC]',@BEGINDate=NULL,@ENDDate=NULL,@IataNum=NULL,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
END


GO
