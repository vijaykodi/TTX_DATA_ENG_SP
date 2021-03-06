/****** Object:  StoredProcedure [dbo].[spInsertProfileBuild]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spInsertProfileBuild] @bank          VARCHAR(255)  = NULL
                                        , @AccountName  varchar(255)  = NULL
                                        , @GroupName    varchar(255)  = NULL
                                        , @ParentCard   varchar(16)   = NULL
                                        , @ChildCard    varchar(16)   = NULL
                                        , @CutOffDate   INTEGER       = NULL
                                        , @DueDate      INTEGER       = NULL
                                        , @AgencyEmail  varchar(255)  = NULL
                                        , @CompanyEmail varchar(255)  = NULL
                                        , @BankEmail    varchar(255)  = NULL
                                        , @ShortName    varchar(50)   = NULL
                                        , @AgencyIata   varchar(8)    = NULL
                                        , @ActiveAccount  varchar(1)  = 'N'
                                        
AS 
	BEGIN
	
    SELECT * 
      FROM dba.ProfileBuilds tPB
    WHERE CHILDCARD = @ChildCard 
    IF @@ROWCOUNT = 0 
      INSERT INTO dba.ProfileBuilds
              ( BANK
                ,ACCOUNTNAME
                ,GROUPNAME
                ,PARENTCARD
                ,CHILDCARD
                ,CUTOFFDATE
                ,DUEDATE
                ,AGENCYEMAIL
                ,COMPANYEMAIL
                ,BANKEMAIL
                ,SHORTNAME
                ,AgencyIata
                ,ActiveAccount
                ,CreateDateTime
              )
      SELECT @bank
              ,@AccountName
              ,@GroupName
              ,@ParentCard
              ,@ChildCard
              ,@CutOffDate
              ,@DueDate
              ,@AgencyEmail
              ,@CompanyEmail
              ,@BankEmail
              ,@ShortName
              ,@AgencyIata
              ,@ActiveAccount
              ,GETDATE()
  END
GO
