
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssigneeSuggestionList_GetMatchInfo] @OwpMatchId INT
AS

/*
Created: 20230324@Mira
Task : 
DB: bodb_OWP

Revisions:
   20230324@Mira: Initial - [Redmine: #185365]	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @HDP INT= 1;

        -- select maxbet
        SELECT m.OWPMatchId 'OwpMatchId', 
               l.OWPLeagueName 'LeagueName', 
               (CASE
                    WHEN m.IsNeutral = 1
                    THEN h.OWPTeamName + ' (N)'
                    ELSE h.OWPTeamName
                END) AS HomeName, 
               a.OWPTeamName 'AwayName', 
               m.EventDate, 
               m.EventDateTime 'KOTime', 
               m.MatchNo, 
               mm.MinorBettypeId, 
               ms.Maxbet 'MaxbetHDP',
               CASE
                   WHEN mm.MinorBettypeId IS NOT NULL
                   THEN mip.Remark
                   ELSE i.Remark
               END 'Remark'
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             LEFT JOIN dbo.MinorBettype mb WITH(NOLOCK) ON mm.MinorBettypeId = mb.MinorBettypeId
             INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
             INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
             LEFT JOIN dbo.MatchInfo AS mip WITH(NOLOCK) ON mm.ParentMatchId = mip.OWPMatchId
             LEFT JOIN dbo.MatchSetting ms WITH(NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
                                                           AND ms.Bettype = @HDP
        WHERE m.OWPMatchId = @OwpMatchId;
    END;