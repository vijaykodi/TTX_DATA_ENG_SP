/****** Object:  StoredProcedure [dbo].[BuildBarclayCardProfiles]    Script Date: 7/14/2015 7:49:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--BEGIN TRANSACTION
--dbo.ClearProfiles
CREATE PROCEDURE [dbo].[BuildBarclayCardProfiles] AS
BEGIN
BEGIN TRANSACTION



--DECLARE #profiles   TABLE

--DROP TABLE #Profiles

--Build a working table
CREATE TABLE #Profiles
 (
	                            [ProfileName]           [varchar](50) NOT NULL,
	                            [ProfileDescription]    [varchar](80) NULL,
	                            [ProfileCategory]       [varchar](40) NULL,
	                            [ReportHeader1]         [varchar](100) NULL,
	                            [ReportHeader2]         [varchar](100) NULL,
	                            [NumReportCopies]       [smallint] NULL,
	                            [Modified]              [datetime] NULL,
	                            [Logo]                  [image] NULL,
	                            [UserID]                [varchar](30) NULL,
	                            [SendSingle]            [varchar](1) NULL,
	                            [MaxAttachSize]         [varchar](10) NULL,
	                            [ZipAttachments]        [varchar](1) NULL,
	                            [Parent]                [varchar](50) NULL,
	                            [WebAvailable]          [varchar](1) NULL,
	                            [IsoCountryCode]        [smallint]  NULL,
	                            [ProfileRelationRank]   [smallint] NULL	                            
                          )




--Pull Top LevelProfile

INSERT INTO #profiles (ProfileName
                       ,ProfileDescription
                       ,ProfileCategory
                       ,ReportHeader1
                       ,ReportHeader2
                       ,NumReportCopies
                       ,Modified
                       ,Logo
                       ,UserID
                       ,SendSingle
                       ,MaxAttachSize
                       ,ZipAttachments
                       ,Parent
                       ,WebAvailable
                       ,IsoCountryCode)
SELECT DISTINCT
       c.CompanyName 
        + ' + ' 
        + CAST(c.CompanyIdentification AS VARCHAR) AS ProfileName
      ,c.CompanyName                               AS ProfileDescription
      ,'CorporateTopLevel'                         AS ProfileCategory
      ,c.CompanyName + ' Top Level'                AS ReportHeader1
      ,CAST(c.CompanyIdentification AS VARCHAR)    AS ReportHeader2
      ,1                                           AS NumReportCopies
      ,GETDATE()                                   AS Modified
      ,NULL                                        AS Logo
      ,'VCFProfBuild'                              AS UserId
      ,'Y'                                         AS SendSingle
      ,255                                         AS MaxAttachSize
      ,'Y'                                         AS ZipAttachments
      ,NULL                                        AS Parent
      ,'Y'                                         AS WebAvailable
      ,c.ISOCountryCode                            AS CountryCode      
      
FROM dba.Company AS c WITH (NOLOCK)
WHERE NOT EXISTS (SELECT 1
                  FROM dba.Profiles AS p WITH(NOLOCK)
                  WHERE p.ProfileName = c.CompanyName + ' + '  + CAST(c.CompanyIdentification AS VARCHAR))
--Next exists to ensure that we dont create profile before we have card info populated in profilebuilds                  
AND EXISTS (SELECT 1 
              FROM dba.CardAccount AS ca
              WHERE c.CompanyIdentification = ca.HeaderTrailerCompanyIdentification)                  
                  

                  
--Pull sub level profiles                  
INSERT into #profiles  (ProfileName
                       ,ProfileDescription
                       ,ProfileCategory
                       ,ReportHeader1
                       ,ReportHeader2
                       ,NumReportCopies
                       ,Modified
                       ,Logo
                       ,UserID
                       ,SendSingle
                       ,MaxAttachSize
                       ,ZipAttachments
                       ,Parent
                       ,WebAvailable
                       ,IsoCountryCode)
                 

SELECT DISTINCT
      c.CompanyName+ ' + ' 
        + CAST(c.CompanyIdentification AS VARCHAR)
        +' + '+ o.[Description]                    AS ProfileName
      ,c.CompanyName +' - '+ o.[Description]       AS ProfileDescription
      ,'CorporateSubLevel'                         AS ProfileCategory
      ,c.CompanyName +' - '+ o.[Description]       AS ReportHeader1
      ,CAST(o.CompanyIdentification AS VARCHAR)    AS ReportHeader2
      ,1                                           AS NumReportCopies
      ,GETDATE()                                   AS Modified
      ,NULL                                        AS Logo
      ,'VCFProfBuild'                              AS UserId
      ,'Y'                                         AS SendSingle
      ,255                                         AS MaxAttachSize
      ,'Y'                                         AS ZipAttachments
      
      ,CASE WHEN oParent.[Description] != c.CompanyName
        THEN c.CompanyName+ ' + ' + CAST(c.CompanyIdentification AS VARCHAR) + ' + ' 
                           + oParent.[Description] 
                           
        ELSE oParent.[Description]+ ' + ' + CAST(c.CompanyIdentification AS VARCHAR)
       END                                         AS Parent
       
      ,'Y'                                         AS WebAvailable
      ,c.ISOCountryCode                            AS CountryCode

      
FROM dba.Organization AS o WITH (NOLOCK)
INNER JOIN dba.Company AS c WITH (NOLOCK) ON o.CompanyIdentification = c.CompanyIdentification
LEFT OUTER JOIN dba.Organization oParent WITH (NOLOCK) ON o.ParentHierarchyNode = oParent.HierarchyNode
WHERE o.[Description] != c.CompanyName
AND NOT EXISTS (SELECT 1
                  FROM dba.Profiles AS p WITH (NOLOCK)
                  WHERE p.ProfileName =   c.CompanyName+ ' + ' + CAST(c.CompanyIdentification AS VARCHAR)+' + '+ o.[Description] )
AND NOT EXISTS (SELECT 1
                  FROM #profiles AS p2
                  WHERE p2.ProfileName = c.CompanyName+ ' + ' + CAST(c.CompanyIdentification AS VARCHAR)+' + '+ o.[Description]) 
--Next exists to ensure that we dont create profile before we have card info populated in profilebuilds                  
AND EXISTS (SELECT 1 
              FROM dba.CardAccount AS ca
              WHERE c.CompanyIdentification = ca.HeaderTrailerCompanyIdentification)                   
                  
--Insert selected profiles into Profiles Table

INSERT INTO dba.Profiles
    (ProfileName
    ,ProfileDescription
    ,ProfileCategory
    ,ReportHeader1
    ,ReportHeader2
    ,NumReportCopies
    ,Modified
    ,Logo
    ,UserID
    ,SendSingle
    ,MaxAttachSize
    ,ZipAttachments
    ,Parent
    ,WebAvailable
    )
    
SELECT 
      ProfileName
    ,ProfileDescription
    ,ProfileCategory
    ,ReportHeader1
    ,ReportHeader2
    ,NumReportCopies
    ,Modified
    ,Logo
    ,UserID
    ,SendSingle
    ,MaxAttachSize
    ,ZipAttachments
    ,Parent
    ,WebAvailable
FROM #Profiles tP
WHERE NOT EXISTS (SELECT 1
                  FROM dba.Profiles AS tProf WITH (NOLOCK)
                  WHERE tP.ProfileName = tProf.ProfileName) 
 

--SELECT * FROM #profiles WHERE profilename  = 'CR SIT UILCO57'                                   
--ROLLBACK                  
--Insert Base Report set ... Probably need to update this based on the profile type sometime in the future to avoid granting all BC users access to all reports.

INSERT INTO dba.ProfileReports
    (
     ProfileName
    ,ReportName
    ,NumReportCopies
    ,ReportOrder
    )
SELECT tP.ProfileName             AS ProfileName
       ,tPreports.ReportName      AS ReportName
       ,1                         AS NumReportCopies
       ,tPreports.ReportOrder     AS ReportOrder
FROM #profiles tP
CROSS JOIN dba.ProfileReports AS tPreports WITH (NOLOCK)
WHERE tPreports.ProfileName = 'ProfileReportMaster' 
AND NOT EXISTS (SELECT 1
                  FROM dba.ProfileReports AS pr WITH (NOLOCK)
                  WHERE tP.ProfileName = pr.ProfileName
                  AND pr.ReportName = tPreports.ReportName)    
                  
--Insert Profile Filters for ALL Levels Currency

INSERT INTO dba.ProfileFilters
    (
     ProfileName
    ,RowNo
    ,Col
    ,FieldNum
    ,SelcExpr
    ,ALIAS
    )

SELECT DISTINCT 
       p.ProfileName                                                  AS ProfileName
      ,2                                                              AS RowNo
      ,1                                                              AS Col
      ,'CURRTO002'                                                    AS FieldNum
      
      ,'='+CHAR(39)
        +'~{Currency Code},'
        +ISNULL(cc.CurrencyCode, 'EUR')+'}'
        +CHAR(39)                                                     AS SelcExpr
      ,'TMAN'                                                         AS ALIAS

FROM #profiles AS p
LEFT OUTER JOIN   dba.CurrencyCodes AS cc WITH (NOLOCK) ON p.IsoCountryCode = cc.CurrencyNumber   
WHERE NOT EXISTS (SELECT 1 FROM DBA.ProfileFilters PF WHERE P.ProfileName = PF.ProfileName AND RowNo = 2 AND Col = 1 AND ALIAS = 'TMAN') 
--Should make sure that currency code tables are up to date so that loj is not necessary...or provide logging or metrics to check this



--Insert Profile Filters from ProfileBuilds TOP Level
INSERT INTO dba.ProfileFilters
    (
     ProfileName
    ,RowNo
    ,Col
    ,FieldNum
    ,SelcExpr
    ,ALIAS
    )
SELECT DISTINCT
       p.ProfileName                                                  AS ProfileName
      ,2                                                              AS RowNo
      ,2                                                              AS Col
      ,CASE WHEN p.ProfileCategory = 'CorporateTopLevel'
        THEN 'ProfileBuilds003'   
          ELSE 'ProfileBuilds002' 
       END                                                            AS FieldNum
      ,'='+CHAR(39)+p.ProfileName+CHAR(39)                            AS SelcExpr
      ,'TMAN'                                                  AS ALIAS
FROM #profiles AS p
LEFT OUTER JOIN dba.ProfileBuilds AS pb WITH (NOLOCK) ON pb.GROUPNAME = p.ProfileName



--Insert Profile Filters from ProfileBuilds Sub Levels
INSERT INTO dba.ProfileFilters
    (
     ProfileName
    ,RowNo
    ,Col
    ,FieldNum
    ,SelcExpr
    ,ALIAS
    )
SELECT DISTINCT
       p.ProfileName                                                  AS ProfileName
      ,2                                                              AS RowNo
      ,1                                                              AS Col
      ,CASE WHEN p.ProfileCategory = 'CorporateTopLevel'
        THEN 'CProfileBuilds003'   
          ELSE 'CProfileBuilds002' 
       END                                                            AS FieldNum
      ,'='+CHAR(39)+p.ProfileName+CHAR(39)                            AS SelcExpr
      ,'CMAN'                                                  AS ALIAS
FROM #profiles AS p
LEFT OUTER JOIN dba.ProfileBuilds AS pb WITH (NOLOCK) ON pb.GROUPNAME = p.ProfileName

--Add complete Profile hierarchy  into #profiles to build Profile Relations
                
INSERT into #profiles
    (
     ProfileName   
    ,Parent
    ,ProfileRelationRank
    )
SELECT DISTINCT p.ProfileName
       ,p.Parent
       ,pr.Dist
FROM dba.Profiles AS p  WITH (NOLOCK)
LEFT OUTER JOIN dba.ProfileRelations AS pr WITH (NOLOCK) ON p.ProfileName = pr.ProfileName
                                                         AND p.Parent = pr.Parent
INNER JOIN #profiles AS tempProf ON p.ProfileName = tempProf.Parent
WHERE NOT EXISTS (SELECT 1
                  FROM #profiles tP
                  WHERE tP.profileName = p.ProfileName)
        
--Set Base Starting Level for Profile Relations                  
UPDATE #profiles
SET ProfileRelationRank = 0
WHERE ISNULL(parent, '') = ''

--Set Profile Relations Rank - Don't Currently need to loop but it future proofs this code

DECLARE @BlankRank INT
SELECT @BlankRank = COUNT(*) FROM #profiles WHERE ProfileRelationRank IS NULL


WHILE @BlankRank > 0
BEGIN

  SELECT @BlankRank = COUNT(*) FROM #profiles WHERE ProfileRelationRank IS NULL
  
  UPDATE tP
  SET tP.ProfileRelationRank = tPParent.ProfileRelationRank + 1
  FROM #profiles tP
  INNER JOIN #profiles tPParent ON tp.Parent = tPParent.ProfileName                    
  WHERE tP.ProfileRelationRank IS NULL
  AND tPParent.ProfileRelationRank IS NOT NULL
  
  PRINT @BlankRank

END  --End Set ProfileRelations Loop

--SELECT * FROM #profiles WHERE profilerelationrank IS NULL
--SELECT * FROM #profiles WHERE profilename like 'ABC33 DEF LTD82%'--15424701
--Insert into ProfileRelations

INSERT INTO dba.ProfileRelations
    ( ProfileName
      , Parent
      , Dist )

SELECT tP.ProfileName
      ,tP.Parent
      ,tP.ProfileRelationRank
FROM #profiles tP
WHERE tP.ProfileRelationRank > 0
AND NOT EXISTS (SELECT 1
                FROM dba.ProfileRelations AS pr WITH (NOLOCK)
                WHERE tP.ProfileName = pr.ProfileName
                AND tp.Parent = pr.Parent
                AND tp.ProfileRelationRank = pr.Dist)
                
--Set the LOGos here (wont work above because of the distinct

UPDATE tP
SET tP.Logo = (SELECT Logo FROM dba.profiles WHERE profileName = '_No Data')
FROM dba.profiles tP
WHERE tP.Logo IS NULL                
                

            
   COMMIT TRANSACTION   
END   

GO
