
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_MaxBetInsertOrUpdate] @MaxBets  NVARCHAR(MAX), 
                                                                    @MatchIds VARCHAR(MAX)
AS

/*
Created: 20201224@Esther
Task : Event Upload for Othersports
DB: bodb_OWP

Revisions:
	20201224@Esther: New structure of Event Upload for Othersports - [Redmine: #146962]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @allMatchIds TABLE(MatchId INT);
        INSERT INTO @allMatchIds
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);
        CREATE TABLE #tmpTable
        (OSMatchId   INT, 
         BetTypeName NVARCHAR(200), 
         MaxBet      MONEY,
         Spread      MONEY
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @MaxBets;
        INSERT INTO #tmpTable
               SELECT DISTINCT 
                      OSMatchId, 
                      BetTypeName, 
                      MaxBet,
                      Spread
               FROM OPENXML(@idoc, '/Root/MatchSetting', 1) WITH(OSMatchId INT, BetTypeName NVARCHAR(200), MaxBet MONEY, Spread MONEY);
        EXEC sp_xml_removedocument 
             @idoc;

        -- DELETE Maxbet
        DELETE osm
        FROM dbo.OSMaxBet osm
             INNER JOIN @allMatchIds t ON t.MatchId = osm.OSMatchId;

        -- INSERT Maxbet
        INSERT INTO [dbo].[OSMaxBet]
        ([OSMatchId], 
         [BettypeName], 
         [MaxBet],
         [Spread]
        )
               SELECT DISTINCT 
                      OSMatchId, 
                      BetTypeName,
                      CASE
                          WHEN MaxBet = ''
                          THEN NULL
                          ELSE MaxBet
                      END,
                      CASE
                          WHEN Spread = ''
                          THEN NULL
                          ELSE Spread
                      END
               FROM #tmpTable t;  
        -- DROP tmpTable
        DROP TABLE #tmpTable;
    END;