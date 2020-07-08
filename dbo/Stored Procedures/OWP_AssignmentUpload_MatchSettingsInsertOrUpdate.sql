
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MatchSettingsInsertOrUpdate] @MatchSettings    NVARCHAR(MAX), 
                                                                         @IsUploadFMAndAIO BIT, 
                                                                         @MatchIds         VARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     DECLARE @allMatchIds TABLE(MatchId INT);
     INSERT INTO @allMatchIds
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);
     CREATE TABLE #tmpTable
     (MatchId    INT, 
      BetType    INT, 
      Spread     MONEY, 
      MaxBet     MONEY, 
      MaxBetCN88 MONEY, 
      SpreadCN88 MONEY
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchSettings;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   BetType, 
                   Spread, 
                   MaxBet, 
                   MaxBetCN88, 
                   SpreadCN88
            FROM OPENXML(@idoc, '/Root/MatchSetting', 1) WITH(MatchId INT, BetType INT, Spread MONEY, MaxBet MONEY, MaxBetCN88 MONEY, SpreadCN88 MONEY);
     EXEC sp_xml_removedocument 
          @idoc;

     -- DELETE Main MatchSetting
     DELETE ma
     FROM dbo.MatchSetting ma
          INNER JOIN @allMatchIds t ON t.MatchId = ma.OWPMatchId
          LEFT JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
     WHERE mm.ParentMatchId IS NULL;

     -- DELETE Minor MatchSetting	 
     DELETE ma
     FROM dbo.MatchSetting ma
          INNER JOIN @allMatchIds t ON t.MatchId = ma.OWPMatchId
          INNER JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
     WHERE @IsUploadFMAndAIO = 1
           OR (mm.MinorBettypeId NOT IN(-88, -89));

     -- INSERT Main MatchSetting
     INSERT INTO [dbo].[MatchSetting]
     ([OWPMatchId], 
      [Bettype], 
      [Spread], 
      [Maxbet], 
      [MaxbetCN88], 
      [SpreadCN88]
     )
            SELECT DISTINCT 
                   MatchId, 
                   t.BetType, 
                   CASE 
						WHEN Spread = ''
							THEN NULL
						ELSE Spread
						END 
                   ,CASE 
						WHEN MaxBet = ''
							THEN NULL
						ELSE MaxBet
						END  
                   ,CASE 
						WHEN MaxBetCN88 = ''
							THEN NULL
						ELSE MaxBetCN88
						END 
                   ,CASE 
						WHEN SpreadCN88 = ''
							THEN NULL
						ELSE SpreadCN88
						END 
            FROM #tmpTable t
                 INNER JOIN MajorBettype v WITH(NOLOCK) ON t.BetType = v.BettypeId
                 LEFT JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
            WHERE mm.ParentMatchId IS NULL;

     -- INSERT MINOR MatchSetting
     INSERT INTO [dbo].[MatchSetting]
     ([OWPMatchId], 
      [Bettype], 
      [Spread], 
      [Maxbet], 
      [MaxbetCN88], 
      [SpreadCN88]
     )
            SELECT DISTINCT 
                   MatchId, 
                   t.BetType, 
                   CASE 
						WHEN Spread = ''
							THEN NULL
						ELSE Spread
						END 
                   ,CASE 
						WHEN MaxBet = ''
							THEN NULL
						ELSE MaxBet
						END  
                   ,CASE 
						WHEN MaxBetCN88 = ''
							THEN NULL
						ELSE MaxBetCN88
						END 
                   ,CASE 
						WHEN SpreadCN88 = ''
							THEN NULL
						ELSE SpreadCN88
						END 
            FROM #tmpTable t
                 INNER JOIN MajorBettype v WITH(NOLOCK) ON t.BetType = v.BettypeId
                 INNER JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
            WHERE @IsUploadFMAndAIO = 1
                  OR (mm.MinorBettypeId NOT IN(-88, -89));
     -- DROP tmpTable
     DROP TABLE #tmpTable;