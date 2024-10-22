
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSLiveGameAssignment_Query] @FromDate      DATETIME, 
                                                       @ToDate        DATETIME, 
                                                       @Sports        VARCHAR(500), 
                                                       @OfferLives    VARCHAR(500), 
                                                       @LinkedMatches VARCHAR(500)
AS

/*  
Created: 20210113@Esther  
Task : Implement OS Live Game List  
DB: bodb_OWP  
  
Revisions:  
 20210113@Esther: Init SP [Redmine: #146963] 
 20210309@Carlos.Nguyen: Enhance OS Live Assignment - Phase 1 [Redmine: #150978]
 20210328@Carlos.Nguyen: Enhance OS Live Assignment - Phase 2 [Redmine: #155608]
 20210713@Carlos.nguyen: Get spread - [Redmine: #158285]
 20220113@Carlos.Nguyen: Link to AdminSite matches and filter by status [Redmine: #167315]
 20220517@Liam.Pham : Add IsNeutral [Redmine: #172762]
 20220629@Liam.Pham : Modify OS Event Upload [Redmine: #174437]
 20221026@carlos.nguyen: add adminSiteId [Redmine: #179306]

*/

    BEGIN
        SET NOCOUNT ON;
        SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
        SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
        DECLARE @tblLinkedMatches TABLE(mode VARCHAR(50));
        DECLARE @tblSports TABLE(sport VARCHAR(50));
        DECLARE @tblOfferLives TABLE(offerLive VARCHAR(15));
        DECLARE @tblOsMatch TABLE
        ([OSMatchId]        INT, 
         [AdminsiteMatchId] INT, 
         [League]           VARCHAR(500), 
         [Home]             VARCHAR(200), 
         [Away]             VARCHAR(200), 
         [MatchNo]          DOUBLE PRECISION, 
         [Reporter]         VARCHAR(2000), 
         [OfferLiveStatus]  VARCHAR(15), 
         [DateTime]         DATETIME, 
         [Sport]            VARCHAR(50), 
         [Category]         VARCHAR(100), 
         [NoHDP]            VARCHAR(20), 
         [MatchOffer]       VARCHAR(2000), 
         [AutoLink]         VARCHAR(100), 
         [Provider]         VARCHAR(900), 
         [OtherProvider]    VARCHAR(900), 
         [Service]          VARCHAR(7), 
         [IPTV]             VARCHAR(100), 
         [WB]               VARCHAR(100), 
         [Remark]           VARCHAR(2000), 
         [LinkMode]         VARCHAR(20), 
         [IsNeutral]        BIT
        );
        INSERT INTO @tblLinkedMatches(mode)
               SELECT t.val
               FROM dbo.fnc_SplitStrings(@LinkedMatches, ',') AS t OPTION(MAXRECURSION 0);
        INSERT INTO @tblSports(sport)
               SELECT t.val
               FROM dbo.fnc_SplitStrings(@Sports, ',') AS t OPTION(MAXRECURSION 0);
        INSERT INTO @tblOfferLives(offerLive)
               SELECT t.val
               FROM dbo.fnc_SplitStrings(@OfferLives, ',') AS t OPTION(MAXRECURSION 0);
        INSERT INTO @tblOsMatch
        ([OSMatchId], 
         [AdminsiteMatchId], 
         [League], 
         [Home], 
         [Away], 
         [MatchNo], 
         [Reporter], 
         [OfferLiveStatus], 
         [DateTime], 
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
         [LinkMode], 
         [IsNeutral]
        )
               -- Select OSMatch  
               SELECT m.[OSMatchId], 
                      m.[AdminsiteMatchId], 
                      l.[LeagueName], 
                      m.[HomeName], 
                      m.[AwayName], 
                      m.[MatchNo], 
                      m.[Reporter], 
                      m.[OfferLiveStatus], 
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
                      CASE
                          WHEN m.[AdminsiteMatchId] IS NULL
                               OR m.[AdminsiteMatchId] = 0
                          THEN 'UnLinked Match'
                          ELSE 'Linked Match'
                      END, 
                      m.[IsNeutral]
               FROM dbo.OSMatch m
                    INNER JOIN @tblSports AS tbls ON tbls.sport = m.Sport
                    INNER JOIN @tblOfferLives AS tblol ON tblol.offerLive = m.OfferLiveStatus
                    INNER JOIN dbo.OSLeague l WITH(NOLOCK) ON l.OSLeagueId = m.LeagueId
               WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;

        -- select OSMatch
        SELECT m.[OSMatchId], 
			   m.[AdminsiteMatchId],
               CASE WHEN bdo2m.matchid IS NOT NULL
				THEN CAST('TRUE' AS BIT)
				ELSE CAST('FALSE' AS BIT) END IsLinked, 
               m.Sport, 
               m.[League], 
               m.[Home], 
               m.[Away], 
               m.[MatchNo], 
               m.[Reporter], 
               m.[OfferLiveStatus] AS OfferLive, 
               m.[DateTime], 
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
               m.[IsNeutral]
        FROM @tblOsMatch m
             INNER JOIN @tblLinkedMatches AS lm ON LOWER(m.LinkMode) = LOWER(lm.mode)
			 LEFT JOIN bodb02.dbo.[match] AS bdo2m WITH(NOLOCK) ON 
				 bdo2m.matchid=m.AdminsiteMatchId
				 AND bdo2m.IsDeleted = 0
				 AND bdo2m.sporttype <> 1
        ORDER BY m.[DateTime] ASC;

        -- Select OSAssignment  
        SELECT osa.[OSMatchId], 
               osa.[AssignmentType], 
               osa.[BettypeName], 
               osa.[UserId], 
               u.[Username], 
               u.Nickname, 
               osa.[AssignmentNote]
        FROM @tblOsMatch AS osm
             INNER JOIN @tblLinkedMatches AS lm ON LOWER(osm.LinkMode) = LOWER(lm.mode)
             INNER JOIN dbo.OSAssignment AS osa WITH(NOLOCK) ON osm.OSMatchId = osa.OSMatchId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON osa.UserId = u.UserId;

        --- Select OSMaxbet  
        SELECT a.[OSMatchId], 
               a.[BettypeName], 
               a.[MaxBet], 
               a.[Spread]
        FROM dbo.OSMaxBet a
             INNER JOIN @tblOsMatch m ON m.OSMatchId = a.OSMatchId
             INNER JOIN @tblLinkedMatches AS lm ON LOWER(m.LinkMode) = LOWER(lm.mode);
    END;