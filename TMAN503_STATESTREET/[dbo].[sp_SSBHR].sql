/****** Object:  StoredProcedure [dbo].[sp_SSBHR]    Script Date: 7/14/2015 8:15:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Sp_ssbhr](@BeginIssueDate DATETIME, 
                                 @EndIssueDate   DATETIME) 
AS 
    SET nocount ON 

    DECLARE @Iata                VARCHAR(50), 
            @ProcName            VARCHAR(50), 
			@IataNum             VARCHAR(50), 
            @TransStart          DATETIME, 
            @LocalBeginIssueDate DATETIME, 
            @LocalEndIssueDate   DATETIME 

    SELECT @LocalBeginIssueDate = @BeginIssueDate, 
           @LocalEndIssueDate = @EndIssueDate 

    SET @Iata = 'SSBHR' 
    SET @ProcName = CONVERT(VARCHAR(50), Object_name(@@PROCID)) 
	SET @IataNum = 'SSBHR' 


    --Log Activity 
    SET @TransStart = Getdate() 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Start', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

 --Delete and Create Regional Hierarchy 
 --Per SF Case 06324864 Vijay kodi added
    SET @TransStart = Getdate() 

    DELETE FROM ttxpasql01.tman503_statestreet.dba.rollup40 
    WHERE  costructid = 'REGIONAL' 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='1-DELETE  ROLLUP40 TABLE REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

Insert ttxpasql01.TMAN503_STATESTREET.dba.rollup40
select distinct 'REGIONAL',DEPTID,DEPTIDDESCR, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from ttxpasql01.TMAN503_STATESTREET.dba.HIERARCHY_TEMP
where DEPTID IS NOT NULL
and LEVEL1 IS NOT NULL
and LEVEL1 <>''
and EndDate >= '2015-04-01'

   EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='2-INSERT INTO  ROLLUP40 TABLE REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 



    UPDATE ru40 
    SET    ru40.rollup1 = HR.region, 
           ru40.rollupdesc1 = HR.region 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND ru40.costructid = 'REGIONAL' 
           AND hr.unit IS NOT NULL 
           AND hr.unit <> '' 
           AND hr.unit IN (SELECT DISTINCT hr.unit 
                           FROM 
               ttxpasql01.tman503_statestreet.dba.hierarchy_temp 
               hr2 
                           WHERE  deptid = ru40.corporatestructure 
                                  AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='3-UPDATE ROLLUP1 AND ROLLUPDESC1 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 



 UPDATE ru40 
    SET    ru40.rollup2 = Substring(HR.level1, 4, 1), 
           ru40.rollupdesc2 = Substring(HR.level1, 4, 1) + ' - ' + HR.lvl1name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND HR.region = RU40.rollup1 
           AND ru40.costructid = 'REGIONAL' 
           AND Substring(HR.level1, 4, 1) IN (SELECT DISTINCT 
                                             Substring(HR.level1, 4, 1) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='4-UPDATE ROLLUP2 AND ROLLUPDESC2 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


  UPDATE ru40 
    SET    ru40.rollup3 = Substring(HR.level2, 4, 2), 
           ru40.rollupdesc3 = Substring(HR.level2, 4, 2) + ' - ' + HR.lvl2name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level1, 4, 1) = RU40.rollup2 
           AND ru40.costructid = 'REGIONAL' 
           AND hr.level2 IS NOT NULL 
           AND hr.level2 <> '' 
           AND Substring(HR.level2, 4, 2) IN (SELECT DISTINCT 
                                             Substring(HR.level2, 4, 2) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='5-UPDATE ROLLUP3 AND ROLLUPDESC3 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


 UPDATE ru40 
    SET    ru40.rollup4 = Substring(HR.level3, 4, 3), 
           ru40.rollupdesc4 = Substring(HR.level3, 4, 3) + ' - ' + HR.lvl3name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level2, 4, 2) = RU40.rollup3 
           AND ru40.costructid = 'REGIONAL' 
           AND hr.level3 IS NOT NULL 
           AND hr.level3 <> '' 
           AND Substring(HR.level3, 4, 3) IN (SELECT DISTINCT 
                                             Substring(HR.level3, 4, 3) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='6-UPDATE ROLLUP4 AND ROLLUPDESC4 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 



UPDATE ru40 
    SET    ru40.rollup5 = Substring(HR.level4, 4, 4), 
           ru40.rollupdesc5 = Substring(HR.level4, 4, 4) + ' - ' + HR.lvl4name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level3, 4, 3) = RU40.rollup4 
           AND ru40.costructid = 'REGIONAL' 
           AND hr.level4 IS NOT NULL 
           AND hr.level4 <> '' 
           AND Substring(HR.level4, 4, 4) IN (SELECT DISTINCT 
                                             Substring(HR.level4, 4, 4) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='7-UPDATE ROLLUP5 AND ROLLUPDESC5 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

 UPDATE ru40 
    SET    ru40.rollup6 = Substring(HR.level5, 4, 5), 
           ru40.rollupdesc6 = Substring(HR.level5, 4, 5) + ' - ' + HR.lvl5name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level4, 4, 4) = RU40.rollup5 
           AND ru40.costructid = 'REGIONAL' 
           AND hr.level5 IS NOT NULL 
           AND hr.level5 <> '' 
           AND Substring(HR.level5, 4, 5) IN (SELECT DISTINCT 
                                             Substring(HR.level5, 4, 5) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='8-UPDATE ROLLUP6 AND ROLLUPDESC6 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


UPDATE ru40 
    SET    ru40.rollup7 = Substring(HR.level6, 4, 6), 
           ru40.rollupdesc7 = Substring(HR.level6, 4, 6) + ' - ' + HR.lvl6name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level5, 4, 5) = RU40.rollup6 
           AND ru40.costructid = 'REGIONAL' 
           AND hr.level6 IS NOT NULL 
           AND hr.level6 <> '' 
           AND Substring(HR.level6, 4, 6) IN (SELECT DISTINCT 
                                             Substring(HR.level6, 4, 6) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='9-UPDATE ROLLUP7 AND ROLLUPDESC7 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


Insert ttxpasql01.TMAN503_STATESTREET.dba.rollup40 values ('REGIONAL','UNKNOWN','UNKNOWN', 'UNKNOWN','UNKNOWN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

   EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='10-INSERT INTO ROLLUP40 REGIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


  EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='11-Delete and Create Regional Hierarchy', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

 --Delete and Create GEO Hierarchy 
  --Per SF Case 06324864 Vijay kodi added
    SET @TransStart = Getdate() 

    DELETE FROM ttxpasql01.tman503_statestreet.dba.rollup40 
    WHERE  costructid = 'GEO' 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='12-DELETE  ROLLUP40 TABLE GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

Insert ttxpasql01.TMAN503_STATESTREET.dba.rollup40
select distinct 'GEO',DEPTID,DEPTIDDESCR, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from ttxpasql01.TMAN503_STATESTREET.dba.HIERARCHY_TEMP
where DEPTID IS NOT NULL
and LEVEL1 IS NOT NULL
and LEVEL1 <>''
and EndDate >= '2015-04-01'

  EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='13-INSERT INTO ROLLUP40 TABLE GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

 UPDATE ru40 
    SET    ru40.rollup1 = Substring(HR.unit, 1, 3), 
           ru40.rollupdesc1 = Substring(Substring(HR.unit, 1, 3), 1, 3) 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND ru40.costructid = 'GEO' 
           AND Substring(HR.unit, 1, 3) IS NOT NULL 
           AND Substring(HR.unit, 1, 3) <> '' 
           AND Substring(HR.unit, 1, 3) IN (SELECT DISTINCT 
Substring(Substring(HR.unit, 1, 3), 1, 3) 
 FROM 
ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
 WHERE  deptid = ru40.corporatestructure 
        AND enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='14-UPDATE ROLLUP1 AND ROLLUPDESC1 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup2 = Substring(HR.level1, 4, 1), 
           ru40.rollupdesc2 = Substring(HR.level1, 4, 1) + ' - ' + HR.lvl1name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.unit, 1, 3) = RU40.rollup1 
           AND ru40.costructid = 'GEO' 
           AND hr.level1 IS NOT NULL 
           AND hr.level1 <> '' 
           AND Substring(HR.level1, 4, 1) IN (SELECT DISTINCT 
                                             Substring(HR.level1, 4, 1) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='15-UPDATE ROLLUP2 AND ROLLUPDESC2 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup3 = Substring(HR.level2, 4, 2), 
           ru40.rollupdesc3 = Substring(HR.level2, 4, 2) + ' - ' + HR.lvl2name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level1, 4, 1) = RU40.rollup2 
           AND ru40.costructid = 'GEO' 
           AND hr.level2 IS NOT NULL 
           AND hr.level2 <> '' 
           AND Substring(HR.level2, 4, 2) IN (SELECT DISTINCT 
                                             Substring(HR.level2, 4, 2) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND hr.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='16-UPDATE ROLLUP3 AND ROLLUPDESC3 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup4 = Substring(HR.level3, 4, 3), 
           ru40.rollupdesc4 = Substring(HR.level3, 4, 3) + ' - ' + HR.lvl3name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level2, 4, 2) = RU40.rollup3 
           AND ru40.costructid = 'GEO' 
           AND hr.level3 IS NOT NULL 
           AND hr.level3 <> '' 
           AND Substring(HR.level3, 4, 3) IN (SELECT DISTINCT 
                                             Substring(HR.level3, 4, 3) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND HR.enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='17-UPDATE ROLLUP4 AND ROLLUPDESC4 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup5 = Substring(HR.level4, 4, 4), 
           ru40.rollupdesc5 = Substring(HR.level4, 4, 4) + ' - ' + HR.lvl4name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level3, 4, 3) = RU40.rollup4 
           AND ru40.costructid = 'GEO' 
           AND hr.level4 IS NOT NULL 
           AND hr.level4 <> '' 
           AND Substring(HR.level4, 4, 4) IN (SELECT DISTINCT 
                                             Substring(HR.level4, 4, 4) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='18-UPDATE ROLLUP5 AND ROLLUPDESC5 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup6 = Substring(HR.level5, 4, 5), 
           ru40.rollupdesc6 = Substring(HR.level5, 4, 5) + ' - ' + HR.lvl5name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level4, 4, 4) = RU40.rollup5 
           AND ru40.costructid = 'GEO' 
           AND hr.level5 IS NOT NULL 
           AND hr.level5 <> '' 
           AND Substring(HR.level5, 4, 5) IN (SELECT DISTINCT 
                                             Substring(HR.level5, 4, 5) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='19-UPDATE ROLLUP6 AND ROLLUPDESC6 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup7 = Substring(HR.level6, 4, 6), 
           ru40.rollupdesc7 = Substring(HR.level6, 4, 6) + ' - ' + HR.lvl6name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level5, 4, 5) = RU40.rollup6 
           AND ru40.costructid = 'GEO' 
           AND hr.level6 IS NOT NULL 
           AND hr.level6 <> '' 
           AND Substring(HR.level6, 4, 6) IN (SELECT DISTINCT 
                                             Substring(HR.level6, 4, 6) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate >= '2015-04-01') 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='20-UPDATE ROLLUP7 AND ROLLUPDESC7 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


Insert ttxpasql01.TMAN503_STATESTREET.dba.rollup40 values ('GEO','UNKNOWN','UNKNOWN', 'UNKNOWN','UNKNOWN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='21-INSERT INTO ROLLUP40 GEO', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='22-Delete and Create GEO Hierarchy', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


 --Delete and Create Functional Hierarchy 
    SET @TransStart = Getdate() 

    DELETE FROM ttxpasql01.tman503_statestreet.dba.rollup40 
    WHERE  costructid = 'FUNCTIONAL' 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='23-DELETE  ROLLUP40 TABLE FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


Insert ttxpasql01.TMAN503_STATESTREET.dba.rollup40
select distinct 'FUNCTIONAL',DEPTID,DEPTIDDESCR, 'STATE STREET','STATE STREET',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from ttxpasql01.TMAN503_STATESTREET.dba.HIERARCHY_TEMP
where DEPTID IS NOT NULL
and LEVEL1 IS NOT NULL
and LEVEL1 <>''
and EndDate> GETDATE()
 EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='24-INSERT INTO ROLLUP40 TABLE FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup2 = Substring(HR.level1, 4, 1), 
           ru40.rollupdesc2 = Substring(HR.level1, 4, 1) + ' - ' + HR.lvl1name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND ru40.costructid = 'FUNCTIONAL' 
           AND EndDate > Getdate() 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='25-UPDATE ROLLUP2 AND ROLLUPDESC2 FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup3 = Substring(HR.level2, 4, 2), 
           ru40.rollupdesc3 = Substring(HR.level2, 4, 2) + ' - ' + HR.lvl2name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level1, 4, 1) = RU40.rollup2 
           AND ru40.costructid = 'FUNCTIONAL' 
           AND hr.level1 IS NOT NULL 
           AND hr.level1 <> '' 
           AND Substring(HR.level2, 4, 2) IN (SELECT DISTINCT 
                                             Substring(HR.level2, 4, 2) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate > Getdate()) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='26-UPDATE ROLLUP3 AND ROLLUPDESC3 FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup4 = Substring(HR.level3, 4, 3), 
           ru40.rollupdesc4 = Substring(HR.level3, 4, 3) + ' - ' + HR.lvl3name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level2, 4, 2) = RU40.rollup3 
           AND ru40.costructid = 'FUNCTIONAL' 
           AND hr.level2 IS NOT NULL 
           AND hr.level2 <> '' 
           AND Substring(HR.level2, 4, 2) IN (SELECT DISTINCT 
                                             Substring(HR.level2, 4, 2) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate > Getdate()) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='27-UPDATE ROLLUP4 AND ROLLUPDESC4 FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup5 = Substring(HR.level4, 4, 4), 
           ru40.rollupdesc5 = Substring(HR.level4, 4, 4) + ' - ' + HR.lvl4name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level3, 4, 3) = RU40.rollup4 
           AND ru40.costructid = 'FUNCTIONAL' 
           AND hr.level3 IS NOT NULL 
           AND hr.level3 <> '' 
           AND Substring(HR.level3, 4, 3) IN (SELECT DISTINCT 
                                             Substring(HR.level3, 4, 3) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND begindate = Getdate() 
               AND enddate > Getdate()) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='28-UPDATE ROLLUP5 AND ROLLUPDESC5 FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup6 = Substring(HR.level5, 4, 5), 
           ru40.rollupdesc6 = Substring(HR.level5, 4, 5) + ' - ' + HR.lvl5name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level4, 4, 4) = RU40.rollup5 
           AND ru40.costructid = 'FUNCTIONAL' 
           AND hr.level4 IS NOT NULL 
           AND hr.level4 <> '' 
           AND Substring(HR.level4, 4, 4) IN (SELECT DISTINCT 
                                             Substring(HR.level4, 4, 4) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate > Getdate()) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='29-UPDATE ROLLUP6 AND ROLLUPDESC6 FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    UPDATE ru40 
    SET    ru40.rollup7 = Substring(HR.level6, 4, 6), 
           ru40.rollupdesc7 = Substring(HR.level6, 4, 6) + ' - ' + HR.lvl6name 
    FROM   ttxpasql01.tman503_statestreet.dba.hierarchy_temp HR, 
           ttxpasql01.tman503_statestreet.dba.rollup40 RU40 
    WHERE  HR.deptid = ru40.corporatestructure 
           AND Substring(HR.level5, 4, 5) = RU40.rollup6 
           AND ru40.costructid = 'FUNCTIONAL' 
           AND hr.level5 IS NOT NULL 
           AND hr.level5 <> '' 
           AND Substring(HR.level5, 4, 5) IN (SELECT DISTINCT 
                                             Substring(HR.level5, 4, 5) 
                                              FROM 
                   ttxpasql01.tman503_statestreet.dba.hierarchy_temp hr2 
                                              WHERE 
               deptid = ru40.corporatestructure 
               AND enddate > Getdate()) 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='30-UPDATE ROLLUP7 AND ROLLUPDESC7 FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 


Insert ttxpasql01.TMAN503_STATESTREET.dba.rollup40 values ('FUNCTIONAL','UNKNOWN','UNKNOWN', 'STATE STREET','STATE STREET','UNKNOWN','Z - UNKNOWN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

   EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='31-INSERT INTO ROLLUP40 TABLE FUNCTIONAL', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='32-Delete and Create Functional Hierarchy', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 

    SET @TransStart = Getdate() 

    EXEC dbo.Sp_logprocerrors 
      @ProcedureName=@ProcName, 
      @LogStart=@TransStart, 
      @StepName='Stored Procedure Ended', 
      @BeginDate=@LocalBeginIssueDate, 
      @EndDate=@LocalEndIssueDate, 
      @IataNum=@Iata, 
      @RowCount=@@ROWCOUNT, 
      @ERR=@@ERROR 
GO
