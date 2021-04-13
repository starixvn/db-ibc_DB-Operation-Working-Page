
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LeagueManagement_LeagueSettingInsert] @LeagueSettings NVARCHAR(MAX)
AS

/*
Created: 20210405@Mira
Task : League Management - Auto Input Max Bet to New League
DB: bodb_OWP

Revisions:
	20210405@Mira: Initial - [Redmine: #152542]
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
         Spread_OU    MONEY
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
                      Spread_OU
               FROM OPENXML(@idoc, '/Root/LeagueSetting', 1) WITH(OWPLeagueId INT, HasTV BIT, MaxbetWD_1H MONEY, MaxbetWD_HDP MONEY, MaxbetWD_OU MONEY, MaxbetWK_1H MONEY, MaxbetWK_HDP MONEY, MaxbetWK_OU MONEY, Spread_1HHDP MONEY, Spread_1HOU MONEY, Spread_HDP MONEY, Spread_OU MONEY);
        EXEC sp_xml_removedocument 
             @idoc;

        -- INSERT League Setting
        INSERT INTO dbo.NewLeagueSetting
        (OWPLeagueId, 
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
         Spread_OU
        )
               SELECT DISTINCT 
                      OWPLeagueId, 
                      HasTV,
                      CASE
                          WHEN MaxbetWD_1H = ''
                          THEN NULL
                          ELSE MaxbetWD_1H
                      END,
                      CASE
                          WHEN MaxbetWD_HDP = ''
                          THEN NULL
                          ELSE MaxbetWD_HDP
                      END,
                      CASE
                          WHEN MaxbetWD_OU = ''
                          THEN NULL
                          ELSE MaxbetWD_OU
                      END,
                      CASE
                          WHEN MaxbetWK_1H = ''
                          THEN NULL
                          ELSE MaxbetWK_1H
                      END,
                      CASE
                          WHEN MaxbetWK_HDP = ''
                          THEN NULL
                          ELSE MaxbetWK_HDP
                      END,
                      CASE
                          WHEN MaxbetWK_OU = ''
                          THEN NULL
                          ELSE MaxbetWK_OU
                      END,
                      CASE
                          WHEN Spread_1HHDP = ''
                          THEN NULL
                          ELSE Spread_1HHDP
                      END,
                      CASE
                          WHEN Spread_1HOU = ''
                          THEN NULL
                          ELSE Spread_1HOU
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
                      END
               FROM #tmpTable;

        -- DROP tmpTable
        DROP TABLE #tmpTable;
    END;