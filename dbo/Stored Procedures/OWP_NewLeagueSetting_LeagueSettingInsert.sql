
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_LeagueSettingInsert] @LeagueSettings NVARCHAR(MAX)
AS

/*
Created: 20250707@Frankie
Task : League Management - Auto Input Max Bet to New League Detail
DB: bodb_OWP

Revisions:
	20250707@Frankie: Initial - [Redmine: #230948]
	20250729@Los: Get No.Hdp - [Redmine: #233921]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tmpTable
        (OWPLeagueId  INT, 
         HasTV        BIT, 
         MaxbetWD_1H  MONEY, 
         MaxbetWD_HDP MONEY, 
         MaxbetWD_OU  MONEY, 
         MaxbetWK_1H  MONEY, 
         MaxbetWK_HDP MONEY, 
         MaxbetWK_OU  MONEY, 
         Spread_1HHDP MONEY, 
         Spread_1HOU  MONEY, 
         Spread_HDP   MONEY, 
         Spread_OU    MONEY, 
         WD_NoOfHDP   NVARCHAR(100),
         WK_NoOfHDP   NVARCHAR(100)
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @LeagueSettings;
        INSERT INTO #tmpTable
               SELECT DISTINCT 
                      OWPLeagueId, 
                      HasTV, 
                      MaxbetWD_1H, 
                      MaxbetWD_HDP, 
                      MaxbetWD_OU, 
                      MaxbetWK_1H, 
                      MaxbetWK_HDP, 
                      MaxbetWK_OU, 
                      Spread_1HHDP, 
                      Spread_1HOU, 
                      Spread_HDP, 
                      Spread_OU, 
                      WD_NoOfHDP, 
                      WK_NoOfHDP
               FROM OPENXML(@idoc, '/Root/LeagueSetting', 1) WITH(OWPLeagueId INT, HasTV BIT, MaxbetWD_1H MONEY, MaxbetWD_HDP MONEY, MaxbetWD_OU MONEY, MaxbetWK_1H MONEY, MaxbetWK_HDP MONEY, MaxbetWK_OU MONEY, Spread_1HHDP MONEY, Spread_1HOU MONEY, Spread_HDP MONEY, Spread_OU MONEY, WD_NoOfHDP NVARCHAR(100), WK_NoOfHDP NVARCHAR(100));
        EXEC sp_xml_removedocument 
             @idoc;

        -- INSERT League Setting
        INSERT INTO dbo.LeagueManagementSetting
        (OWPLeagueId, 
         MaxbetWD_HDP, 
         MaxbetWK_HDP, 
         Spread_HDP, 
         Spread_OU, 
         WD_NoOfHDP, 
         WK_NoOfHDP
        )
               SELECT DISTINCT 
                      OWPLeagueId,
                      CASE
                          WHEN MaxbetWD_HDP = ''
                          THEN NULL
                          ELSE MaxbetWD_HDP
                      END,
                      CASE
                          WHEN MaxbetWK_HDP = ''
                          THEN NULL
                          ELSE MaxbetWK_HDP
                      END,
                      CASE
                          WHEN Spread_HDP = ''
                          THEN NULL
                          ELSE Spread_HDP
                      END,
                      CASE
                          WHEN Spread_OU = ''
                          THEN NULL
                          ELSE Spread_OU
                      END, 
                      WD_NoOfHDP, 
                      WK_NoOfHDP
               FROM #tmpTable;

        -- DROP tmpTable
        DROP TABLE #tmpTable;
    END;