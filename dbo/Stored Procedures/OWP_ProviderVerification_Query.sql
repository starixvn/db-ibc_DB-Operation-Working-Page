
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_Query] @EventDate DATE,
@IsMisMatch BIT
AS

/*
 Created: 20240405@Johnny
 Task : query provider verification
 DB: bodb_OWP

 Revisions:
	20240405@Johnny: Initial SP - [Feature: #202819]
	20250210@Los: Remove unuse column - [Feature: #213719]
*/

     SET NOCOUNT ON;
     DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
     DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     DECLARE @BettypeHDP INT= 1,
	 @BettypeOverUnder INT= 3,
	 @MatchStatusText NVARCHAR(100);
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
      IsNeutral      BIT, 
      AgentEst       NVARCHAR(2000), 
      RemarkEst      NVARCHAR(2000), 
      RemarkBy       NVARCHAR(2000)
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
      IsNeutral, 
      AgentEst, 
      RemarkEst, 
      RemarkBy
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
                   om.IsNeutral, 
                   mi.Agent_EST, 
                   mi.Remark_EST, 
                   mi.RemarkBy
               
            FROM dbo.OWPMatch AS om WITH(NOLOCK)
                 INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
				 LEFT JOIN dbo.MinorMatch AS mm WITH(NOLOCK) on om.OWPMatchId = mm.MinorMatchId
            WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate
                  AND mi.IsSelected = 1 
				  AND mm.MinorBettypeId IS NULL

     -- Return Matches info
     SELECT ml.OWPMatchId, 
            ml.MatchNo, 
			ml.MatchStatus,
            ml.EventDateTime, 
            ml.KickOffTime, 
            l.OWPLeagueName AS League, 
            (CASE
                 WHEN ml.IsNeutral = 1
                 THEN h.OWPTeamName + ' (N)'
                 ELSE h.OWPTeamName
             END) AS Home, 
            a.OWPTeamName AS Away, 
            ml.AgentEst, 
            ml.RemarkEst, 
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
     ), 1, 2, '') AS OtherProvider
     FROM #owpMatchListByDate AS ml WITH(NOLOCK)
          INNER JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
          INNER JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
          INNER JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
     WHERE l.OWPLeagueName NOT LIKE '%FANTASY%' AND ml.MatchStatus IN
     (
         SELECT [Value]
         FROM @tblRefResourceMatchStatus
     )
     ORDER BY ml.MatchNo, 
              ml.EventDate, 
              ml.KickOffTime, 
              l.OWPLeagueName, 
              h.OWPTeamName;

     SELECT mac.OWPMatchId, 
            mac.AgentId, 
            ao.AgentName
     FROM MatchAgentConfirm AS mac WITH(NOLOCK)
          INNER JOIN #owpMatchListByDate AS ml WITH(NOLOCK) ON ml.OWPMatchId = mac.OWPMatchId
          LEFT JOIN AgentOption AS ao WITH(NOLOCK) ON ao.AgentId = mac.AgentId;
   
     DROP TABLE #owpMatchListByDate;
     DROP TABLE #tblMatchOfferResource;
