
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_Query] @EventDate DATE
AS

/*
 Created: 20240405@Johnny
 Task : query provider verification
 DB: bodb_OWP

 Revisions:
	20240405@Johnny: Initial SP - [Feature: #202819]
*/

     SET NOCOUNT ON;
     DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
     DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     DECLARE @BettypeHDP INT= 1, @Specific15Mins INT= -1, @Specific10Mins INT= -2, @Specific15MinsNoOfCorners INT= -5, @Specific15MinsTotalBooking INT= -8, @FastMarket INT= -88, @AllInOne INT= -89, @AllInOneTotalBookings INT= -189, @AllInOneCorners INT= -289, @FastMarketTotalBookings INT= -188, @FastMarketCorners INT= -288, @MatchStatusText NVARCHAR(100);
     DECLARE @tblRefResourceMatchStatus TABLE
     (Id    INT NOT NULL, 
      Value NVARCHAR(50) NOT NULL
     );
     INSERT INTO @tblRefResourceMatchStatus
     (Id, 
      Value
     )
            SELECT ResourceId, 
                   Value
            FROM dbo.RefResource WITH(NOLOCK)
            WHERE RefName = 'MatchStatus'
                  AND ResourceId IN(1, 2, 3, 4, 5, 6, 7);
     CREATE TABLE #tblMatchOfferResource
     (Id    INT NOT NULL, 
      Value NVARCHAR(50) NOT NULL
     );
     INSERT INTO #tblMatchOfferResource
     (Id, 
      Value
     )
            SELECT ResourceId, 
                   Value
            FROM dbo.RefResource WITH(NOLOCK)
            WHERE RefName = 'MatchOffer';
     -- Match ID List by Date
     CREATE TABLE #owpMatchListByDate
     (OWPMatchId     INT, 
      MatchNo        NVARCHAR(50), 
      EventDate      DATE, 
      EventDateTime  DATETIME, 
      KickOffTime    TIME(7), 
      OWPLeagueId    INT, 
      OWPHomeId      INT, 
      OWPAwayId      INT, 
      MatchStatus    NVARCHAR(15), 
      IsMinorMatch   BIT, 
      MinorBettypeId INT, 
      ParentMatchId  INT, 
      IsNeutral      BIT, 
      AgentEst       NVARCHAR(2000), 
      RemarkEst      NVARCHAR(2000), 
      RemarkBy       NVARCHAR(2000), 
      EstNote        NVARCHAR(4000)
     );
     INSERT INTO #owpMatchListByDate
     (OWPMatchId, 
      MatchNo, 
      EventDate, 
      EventDateTime, 
      KickOffTime, 
      OWPLeagueId, 
      OWPHomeId, 
      OWPAwayId, 
      MatchStatus, 
      IsMinorMatch, 
      MinorBettypeId, 
      ParentMatchId, 
      IsNeutral, 
      AgentEst, 
      RemarkEst, 
      RemarkBy, 
      EstNote
     )
            SELECT om.OWPMatchId, 
                   om.MatchNo, 
                   om.EventDate, 
                   om.EventDateTime, 
                   om.KickOffTime, 
                   om.OWPLeagueId, 
                   om.OWPHomeId, 
                   om.OWPAwayId, 
                   dbo.OWP_GetCurrentMatchStatus(om.EventDate, om.KickOffTime, mi.MatchStatus),
                   CASE
                       WHEN minor.MinorMatchId IS NULL
                       THEN 0
                       ELSE 1
                   END AS IsMinorMatch, 
                   minor.MinorBettypeId,
                   CASE
                       WHEN minor.ParentMatchId IS NULL
                       THEN om.OWPMatchId
                       ELSE minor.ParentMatchId
                   END AS ParentMatchId, 
                   om.IsNeutral, 
                   mi.Agent_EST, 
                   mi.Remark_EST, 
                   mi.RemarkBy, 
                   pv.ESTNote
            FROM dbo.OWPMatch AS om WITH(NOLOCK)
                 INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
                 LEFT JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
                 LEFT JOIN dbo.OWPMatch mp WITH(NOLOCK) ON mp.OWPMatchId = minor.ParentMatchId
                 LEFT JOIN dbo.ProviderVerification pv WITH(NOLOCK) ON om.OWPMatchId = pv.OWPMatchId
            WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate
                  AND mi.IsSelected = 1
                  AND (minor.IsRepresented = 1
                       OR minor.IsRepresented IS NULL);
     CREATE TABLE #tblOWPMatchFilter(OWPMatchId INT);
     INSERT INTO #tblOWPMatchFilter
            SELECT ml.ParentMatchId
            FROM #owpMatchListByDate AS ml WITH(NOLOCK)
                 INNER JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
                 INNER JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
                 INNER JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
                 INNER JOIN dbo.OWPMatch AS ma WITH(NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
            WHERE(ml.MinorBettypeId IN(@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne, @AllInOneTotalBookings, @AllInOneCorners, @FastMarketTotalBookings, @FastMarketCorners)
            OR ml.MinorBettypeId IS NOT NULL)
                 AND (ml.MatchStatus IN
            (
                SELECT [Value]
                FROM @tblRefResourceMatchStatus
            ))
            UNION
            SELECT ml.OWPMatchId
            FROM #owpMatchListByDate AS ml WITH(NOLOCK)
                 INNER JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
                 INNER JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
                 INNER JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
                 INNER JOIN dbo.OWPMatch AS ma WITH(NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
            WHERE(ml.MinorBettypeId NOT IN(@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne, @AllInOneTotalBookings, @AllInOneCorners, @FastMarketTotalBookings, @FastMarketCorners)
            OR ml.MinorBettypeId IS NULL)
                 AND (ml.MatchStatus IN
            (
                SELECT [Value]
                FROM @tblRefResourceMatchStatus
            ));

     -- Return Matches info
     SELECT ml.OWPMatchId, 
            ml.MatchNo, 
            ml.EventDateTime, 
            ml.KickOffTime, 
            l.OWPLeagueName AS League, 
            (CASE
                 WHEN ml.IsNeutral = 1
                 THEN h.OWPTeamName + ' (N)'
                 ELSE h.OWPTeamName
             END) AS Home, 
            a.OWPTeamName AS Away, 
            ml.AgentEst AS Agent, 
            ml.RemarkEst AS RemarkEst, 
            ml.RemarkBy, 
            STUFF(
     (
         SELECT ', ' + rs.ProviderName
         FROM dbo.[Provider] AS rs WITH(NOLOCK)
              INNER JOIN dbo.MatchProvider AS mp WITH(NOLOCK) ON rs.ProviderId = mp.ProviderId
         WHERE mp.OWPMatchId = ml.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS [Provider], 
            STUFF(
     (
         SELECT ', ' + rs.OtherProviderName
         FROM dbo.OtherProvider AS rs WITH(NOLOCK)
              INNER JOIN dbo.MatchOtherProvider AS mot WITH(NOLOCK) ON rs.OtherProviderId = mot.OtherProviderId
         WHERE mot.OWPMatchId = ml.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS OtherProvider, 
            ml.IsMinorMatch, 
            ml.ParentMatchId, 
            ml.EstNote
     FROM #owpMatchListByDate AS ml WITH(NOLOCK)
          INNER JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
          INNER JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
          INNER JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
     WHERE ml.OWPMatchId IN
     (
         SELECT OWPMatchId
         FROM #tblOWPMatchFilter
     )
           AND (ml.MatchStatus IN
     (
         SELECT [Value]
         FROM @tblRefResourceMatchStatus
     ))
     ORDER BY ml.MatchNo, 
              ml.EventDate, 
              ml.KickOffTime, 
              l.OWPLeagueName, 
              h.OWPTeamName, 
              ml.ParentMatchId, 
              ml.IsMinorMatch;
     SELECT mac.OWPMatchId, 
            mac.AgentId, 
            ao.AgentName
     FROM MatchAgentConfirm AS mac WITH(NOLOCK)
          INNER JOIN #owpMatchListByDate AS ml WITH(NOLOCK) ON ml.OWPMatchId = mac.OWPMatchId
          LEFT JOIN AgentOption AS ao WITH(NOLOCK) ON ao.AgentId = mac.AgentId;
     -- Get maxbet
     CREATE TABLE #tblMaxBet
     (OWPMatchId     INT, 
      ParentMatchId  INT, 
      Bettype        INT, 
      MinorBettypeId INT, 
      MaxBet         MONEY, 
      Spread         MONEY, 
      IsMatchSetting BIT, 
      LeagueId       INT
     );
     INSERT INTO #tblMaxBet
     (OWPMatchId, 
      ParentMatchId, 
      Bettype, 
      MinorBettypeId, 
      MaxBet, 
      Spread, 
      IsMatchSetting
     )
            SELECT ml.owpmatchid, 
                   ml.ParentMatchId, 
                   ms.Bettype, 
                   ml.MinorBettypeId, 
                   ms.Maxbet, 
                   ms.Spread, 
                   1
            FROM #owpMatchListByDate AS ml WITH(NOLOCK)
                 INNER JOIN dbo.MatchSetting AS ms WITH(NOLOCK) ON ml.owpmatchid = ms.OWPMatchId
            WHERE(ml.MatchStatus IN
            (
                SELECT [Value]
                FROM @tblRefResourceMatchStatus
            ));

     -- league setting
     INSERT INTO #tblMaxBet
     (OWPMatchId, 
      ParentMatchId, 
      LeagueId, 
      Bettype, 
      IsMatchSetting
     )
            SELECT ml.OWPMatchId, 
                   ml.ParentMatchId, 
                   ml.OWPLeagueId, 
                   ls.Bettype, 
                   0
            FROM #owpMatchListByDate AS ml WITH(NOLOCK)
                 INNER JOIN dbo.LeagueSetting AS ls WITH(NOLOCK) ON ml.OWPLeagueId = ls.LeagueId
            WHERE ml.OWPMatchId NOT IN
            (
                SELECT OWPMatchId
                FROM #tblMaxBet WITH(NOLOCK)
            )
                  AND ml.IsMinorMatch = 0
                  AND (ml.MatchStatus IN
            (
                SELECT [Value]
                FROM @tblRefResourceMatchStatus
            ))
            GROUP BY ml.OWPMatchId, 
                     ml.OWPLeagueId, 
                     ls.Bettype, 
                     ml.ParentMatchId;
     UPDATE mb
       SET 
           mb.MaxBet = dbo.OWP_MaxBetGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype), 
           mb.Spread = dbo.OWP_SpreadGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype)
     FROM #tblMaxBet AS mb
     WHERE mb.IsMatchSetting = 0;
     INSERT INTO #tblMaxBet
     (OWPMatchId, 
      ParentMatchId, 
      Bettype, 
      MinorBettypeId, 
      MaxBet, 
      Spread
     )
            SELECT t.OWPMatchId, 
                   t.ParentMatchId, 
                   t.InheritedBettypeId, 
                   t.MinorBettypeId, 
                   md.MaxBet, 
                   md.Spread
            FROM
            (
                SELECT ml.OWPMatchId, 
                       ml.ParentMatchId, 
                       mbt.ParentBettypeId, 
                       mbt.InheritedBettypeId, 
                       ml.MinorBettypeId,
                       CASE
                           WHEN mst.OWPMatchId IS NULL
                           THEN dbo.OWP_MaxBetGet(minor.ParentMatchId, ma.OWPLeagueId, @BettypeHDP)
                           ELSE mst.Maxbet
                       END AS MaxBetHDP
                FROM #owpMatchListByDate AS ml WITH(NOLOCK)
                     INNER JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON ml.OWPMatchId = minor.MinorMatchId
                     INNER JOIN dbo.OWPMatch AS ma WITH(NOLOCK) ON minor.ParentMatchId = ma.OWPMatchId
                     INNER JOIN dbo.MinorBettype AS mbt WITH(NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
                     LEFT JOIN dbo.MatchSetting AS mst WITH(NOLOCK) ON minor.ParentMatchId = mst.OWPMatchId
                                                                       AND mst.Bettype = @BettypeHDP
                WHERE ml.IsMinorMatch = 1
                      AND ml.OWPMatchId NOT IN
                (
                    SELECT OWPMatchId
                    FROM #tblMaxBet WITH(NOLOCK)
                )
                      AND (ml.MatchStatus IN
                (
                    SELECT [Value]
                    FROM @tblRefResourceMatchStatus
                ))
            ) AS t
            INNER JOIN dbo.MinorSetting AS m WITH(NOLOCK) ON t.MaxBetHDP BETWEEN ISNULL(FromMaxBet, 0) AND ISNULL(ToMaxBet, 99999999999)
            INNER JOIN dbo.MinorSettingDetail AS md WITH(NOLOCK) ON m.MinorSettingId = md.MinorSettingId
                                                                    AND md.MinorBettypeId = t.ParentBettypeId;

     -- Return Match Setting
     SELECT mb.OWPMatchId, 
            mb.ParentMatchId, 
            mb.Bettype, 
            mb.MinorBettypeId, 
            mb.MaxBet, 
            mb.Spread
     FROM #tblMaxBet AS mb WITH(NOLOCK);
     DROP TABLE #owpMatchListByDate;
     DROP TABLE #tblMatchOfferResource;
     DROP TABLE #tblOWPMatchFilter;
     DROP TABLE #tblMaxBet;