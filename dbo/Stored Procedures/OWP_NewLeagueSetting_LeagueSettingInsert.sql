
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
    20250927@Frankie: Add history log when system created setting- [Redmine: #236027]
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
         WK_NoOfHDP   NVARCHAR(100),
		 LogDataJson  VARCHAR(MAX),
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
                      WK_NoOfHDP,
					  LogDataJson
               FROM OPENXML(@idoc, '/Root/LeagueSetting', 1) WITH(OWPLeagueId INT, HasTV BIT, MaxbetWD_1H MONEY, MaxbetWD_HDP MONEY, MaxbetWD_OU MONEY, MaxbetWK_1H MONEY, MaxbetWK_HDP MONEY, MaxbetWK_OU MONEY, Spread_1HHDP MONEY, Spread_1HOU MONEY, Spread_HDP MONEY, Spread_OU MONEY, WD_NoOfHDP NVARCHAR(100), WK_NoOfHDP NVARCHAR(100),LogDataJson NVARCHAR(MAX));
        EXEC sp_xml_removedocument 
             @idoc;

        -- INSERT League Setting
		DECLARE @Log TABLE
		(
			LogDataJson VARCHAR(MAX),
			NewSettingId INT
		);

		MERGE dbo.LeagueManagementSetting AS target
		USING #tmpTable AS src
			ON 1 = 0   -- để luôn insert
		WHEN NOT MATCHED THEN
			INSERT (
				OWPLeagueId, 
				MaxbetWD_HDP, 
				MaxbetWK_HDP, 
				Spread_HDP, 
				Spread_OU, 
				WD_NoOfHDP, 
				WK_NoOfHDP
			)
			VALUES (
				src.OWPLeagueId,
				CASE WHEN src.MaxbetWD_HDP = '' THEN NULL ELSE src.MaxbetWD_HDP END,
				CASE WHEN src.MaxbetWK_HDP = '' THEN NULL ELSE src.MaxbetWK_HDP END,
				CASE WHEN src.Spread_HDP   = '' THEN NULL ELSE src.Spread_HDP   END,
				CASE WHEN src.Spread_OU    = '' THEN NULL ELSE src.Spread_OU    END, 
				src.WD_NoOfHDP, 
				src.WK_NoOfHDP
			)
            OUTPUT 
                src.LogDataJson,       
                inserted.Id
            INTO @Log (LogDataJson, NewSettingId);

		-- INSERT Log
		DECLARE @LogDate DATETIME = DATEADD(HOUR, 8, GETUTCDATE());

		INSERT INTO [LeagueSettingLog]
		(
			[CreatedDate], 
			[ModifiedBy], 
			[SettingId], 
			[Action], 
			[Content]
		)
		SELECT 
			@LogDate,              -- CreatedDate
			'SYSTEM',              -- ModifiedBy
			NewSettingId,          -- SettingId lấy từ @Log
			'Created the setting', -- Action
			LogDataJson            -- Content
		FROM @Log;

        DROP TABLE #tmpTable;
    END;