
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_MatchInsertOrUpdate] @Matches NVARCHAR(MAX), 
                                                                   @UserId  INT
AS

/*
Created: 20201223@Mira
Task : Other Sport
DB: bodb_OWP

Revisions:
	20201223@Mira: Init SP [Redmine: #146962]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tmpTable
        (OSMatchId     INT, 
         HashKey       VARCHAR(200), 
         Sport         VARCHAR(50), 
         MatchNo	   DOUBLE PRECISION,
		 Reporter	   VARCHAR(2000),
         MatchStatus   VARCHAR(15), 
         EventDateTime DATETIME, 
         LeagueId      INT, 
         League        NVARCHAR(500), 
         Home          NVARCHAR(200), 
         Away          NVARCHAR(200), 
         Category      VARCHAR(100), 
         NoHDP         VARCHAR(20), 
         AutoLink      VARCHAR(100), 
         [Service]     VARCHAR(7), 
         IPTV          VARCHAR(100), 
         WB            VARCHAR(100), 
         Remark        VARCHAR(2000), 
         [Provider]    VARCHAR(900), 
         OtherProvider VARCHAR(900), 
         MatchOffer    VARCHAR(2000)
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @Matches;
        INSERT INTO #tmpTable
               SELECT 0, 
                      HashKey, 
                      Sport,
                      MatchNo,
					  Reporter,
                      MatchStatus, 
                      [DateTime], 
                      0, 
                      League, 
                      Home, 
                      Away, 
                      Category, 
                      NoHDP, 
                      AutoLink, 
                      [Service], 
                      IPTV, 
                      WB, 
                      Remark, 
                      [Provider], 
                      OtherProvider, 
                      MatchOffer
               FROM OPENXML(@idoc, '/Root/AssignmentModel', 1) WITH(HashKey VARCHAR(200), Sport VARCHAR(50), MatchNo DOUBLE PRECISION, Reporter VARCHAR(2000), MatchStatus VARCHAR(15), [DateTime] DATETIME, League NVARCHAR(500), Home NVARCHAR(200), Away NVARCHAR(200), Category VARCHAR(100), NoHDP VARCHAR(20), AutoLink VARCHAR(100), [Service] VARCHAR(7), IPTV VARCHAR(100), WB VARCHAR(100), Remark VARCHAR(2000), [Provider] VARCHAR(900), OtherProvider VARCHAR(900), MatchOffer VARCHAR(2000))
               ORDER BY [DateTime] ASC;
        EXEC sp_xml_removedocument 
             @idoc;

        -- Insert League
        INSERT INTO dbo.OSLeague(LeagueName)
               SELECT DISTINCT 
                      m.League
               FROM #tmpTable AS m
                    LEFT JOIN dbo.OSLeague AS l WITH(NOLOCK) ON m.League = l.LeagueName
               WHERE l.OSLeagueId IS NULL;

        -- UPDATE LeagueId to temp table
        UPDATE m
          SET 
              m.LeagueId = l.OSLeagueId
        FROM #tmpTable m
             INNER JOIN dbo.OSLeague l WITH(NOLOCK) ON m.League = l.LeagueName;

        -- Insert or UPDATE OSMatch
        MERGE INTO dbo.OSMatch WITH(ROWLOCK) AS om
        USING #tmpTable AS m
        ON m.LeagueId = om.LeagueId
           AND m.Home = om.HomeName
           AND m.Away = om.AwayName
           AND m.EventDateTime = om.EventDateTime
            WHEN MATCHED
            THEN UPDATE SET 
							om.[MatchNo]= m.[MatchNo],
							om.[Reporter]= m.[Reporter],
                            om.[MatchStatus] = m.[MatchStatus], 
                            om.[Sport] = m.[Sport], 
                            om.[Category] = m.[Category], 
                            om.[NoHDP] = m.[NoHDP], 
                            om.[MatchOffer] = m.[MatchOffer], 
                            om.[AutoLink] = m.[AutoLink], 
                            om.[Provider] = m.[Provider], 
                            om.[OtherProvider] = m.[OtherProvider], 
                            om.[Service] = m.[Service], 
                            om.[IPTV] = m.[IPTV], 
                            om.[WB] = m.[WB], 
                            om.[Remark] = m.[Remark], 
                            om.[UploadedBy] = @UserId
            WHEN NOT MATCHED BY TARGET
            THEN
              INSERT([LeagueId], 
                     [HomeName], 
                     [AwayName], 
                     [MatchNo],
					 [Reporter],
                     [MatchStatus], 
                     [EventDate], 
                     [EventDateTime], 
                     [Sport], 
                     [Category], 
                     [NoHDP], 
                     [MatchOffer], 
                     [AutoLink], 
                     [Provider], 
                     [OtherProvider], 
                     [Service], 
                     [IPTV], 
                     [WB], 
                     [Remark], 
                     [UploadedBy])
              VALUES
        (m.[LeagueId], 
         m.[Home], 
         m.[Away], 
         m.[MatchNo],
		 m.[Reporter],
         m.[MatchStatus], 
         m.[EventDateTime], 
         m.[EventDateTime], 
         m.[Sport], 
         m.[Category], 
         m.[NoHDP], 
         m.[MatchOffer], 
         m.[AutoLink], 
         m.[Provider], 
         m.[OtherProvider], 
         m.[Service], 
         m.[IPTV], 
         m.[WB], 
         m.[Remark], 
         @UserId
        );

        -- UPDATE MatchId to temp table
        UPDATE m
          SET 
              m.OSMatchId = om.OSMatchId
        FROM #tmpTable m
             INNER JOIN dbo.OSMatch om WITH(NOLOCK) ON m.LeagueId = om.LeagueId
                                                       AND m.Home = om.HomeName
                                                       AND m.Away = om.AwayName
                                                       AND m.[EventDateTime] = om.[EventDateTime];

        -- SELECT the result
        SELECT HashKey, 
               OSMatchId
        FROM #tmpTable;
        DROP TABLE #tmpTable;
    END;