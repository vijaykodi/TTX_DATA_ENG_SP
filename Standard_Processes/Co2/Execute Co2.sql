SET @TransStart = getdate()
exec TTXPASQL01.tman503_ClientDB.dbo.sp_ClientDB_CO2_MAIN
@BEGINISSUEDATEMAIN = @BeginIssueDate,
@ENDISSUEDATEMAIN =@EndIssueDate
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='End of CO2',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
