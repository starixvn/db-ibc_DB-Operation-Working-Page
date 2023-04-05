
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssigneeSuggestionList_GetAssignmentByDate] @EventDate DATE
AS

/*
Created: 202303238@Los
Task: Query assignment by date
DB: bodb_OWP   
 
Revisions:
	202303238@Los: Initial SP - [Redmine: #185365]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 1, @EventDate), '2AM');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '4PM');
        DECLARE @MainAssignmentType INT= 1;
        DECLARE @MJ INT= 1;
        DECLARE @HDP INT= 1, @OU INT= 3, @1H_HDP INT= 7, @1H_OU INT= 8;
        DECLARE @Specific15Mins INT= -1, @NoOfCorner INT= -3, @NextCorner INT= -4;

        -- select assignment info
        SELECT DISTINCT 
               a.UserId, 
               a.Bettype 'BettypeId', 
               a.OWPMatchId, 
               m.KickOffTime 'KOTime', 
               m.EventDateTime, 
               l.OWPLeagueName 'LeagueName', 
               mi.Remark,
               CASE
                   WHEN l.CategoryId = 1
                   THEN 1
                   ELSE 0
               END 'IsMajorLeague',
               CASE
                   WHEN mm.MinorMatchId IS NULL
                   THEN 1
                   ELSE 0
               END 'IsMainMatch',
               CASE
                   WHEN mm.MinorBettypeId IN(@NoOfCorner, @NextCorner)
                   THEN 1
                   ELSE 0
               END 'IsCornerMatch',
               CASE
                   WHEN mm.MinorBettypeId = @Specific15Mins
                   THEN 1
                   ELSE 0
               END 'Is15Mins', 
               h.OWPTeamName 'HomeName', 
               aw.OWPTeamName 'AwayName',
               CASE
                   WHEN mm.MinorBettypeId = @Specific15Mins
                   THEN msm.Maxbet
                   ELSE ms.Maxbet
               END 'MaxbetHDP', 
               mm.MinorBettypeId, 
               mm.ParentMatchId
        FROM Assignment AS a WITH(NOLOCK)
             INNER JOIN OWPMatch AS m WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
             INNER JOIN MatchInfo AS mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
             INNER JOIN OWPLeague AS l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
             INNER JOIN dbo.OWPTeam aw WITH(NOLOCK) ON m.OWPAwayId = aw.OWPTeamId
             LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
             LEFT JOIN MatchSetting AS ms WITH(NOLOCK) ON ms.OWPMatchId = m.OWPMatchId
                                                          AND ms.Bettype = @HDP
             LEFT JOIN MatchSetting AS msm WITH(NOLOCK) ON msm.OWPMatchId = mm.ParentMatchId
                                                           AND msm.Bettype = @HDP
        WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate
              AND a.AssignmentType = @MainAssignmentType
              AND a.Bettype IN(@HDP, @OU, @1H_HDP, @1H_OU)
             AND mi.MatchStatus NOT IN('Cancel', 'Suspended')
        AND (mm.MinorBettypeId IS NULL
             OR mm.MinorBettypeId IN(@NoOfCorner, @NextCorner, @Specific15Mins))
        ORDER BY UserId, 
                 EventDateTime, 
                 IsMainMatch, 
                 BettypeId;
    END;