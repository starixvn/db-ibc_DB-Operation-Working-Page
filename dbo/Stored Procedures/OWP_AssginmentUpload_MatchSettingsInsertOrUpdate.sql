
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchSettingsInsertOrUpdate] @MatchSettings NVARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpTable
     (MatchId     INT, 
      BetType     INT, 
      Spread      MONEY, 
      MaxBet      MONEY, 
      MaxBetCN88 MONEY, 
      SpreadCN88 MONEY
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchSettings;
     INSERT INTO #tmpTable
            SELECT MatchId, 
                   BetType, 
                   Spread, 
                   MaxBet, 
                   MaxBetCN88, 
                   SpreadCN88
            FROM OPENXML(@idoc, '/Root/MatchSetting', 1) WITH(MatchId INT, BetType INT, Spread MONEY, MaxBet MONEY, MaxBetCN88 MONEY, SpreadCN88 MONEY);
     EXEC sp_xml_removedocument 
          @idoc;

     -- DELETE MatchSetting
     DELETE ma
     FROM dbo.MatchSetting ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId;

     -- INSERT MatchSetting
     INSERT INTO [dbo].[MatchSetting]
     ([OWPMatchId], 
      [Bettype], 
      [Spread], 
      [Maxbet], 
      [MaxbetCN88], 
      [SpreadCN88]
     )
            SELECT MatchId, 
                   BetType, 
                   Spread, 
                   MaxBet, 
                   MaxBetCN88, 
                   SpreadCN88
            FROM #tmpTable t;

     -- DROP tmpTable
     DROP TABLE #tmpTable;