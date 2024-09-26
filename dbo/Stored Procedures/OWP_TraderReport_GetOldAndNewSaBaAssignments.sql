
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderReport_GetOldAndNewSaBaAssignments] @EventDate DATE
AS

/*    
 Created: 20220811@Mira
 Task : Trader Report
 DB: bodb_OWP    
    
 Revisions:
	20220811@Mira: Re-generate data for Trader report - [Redmine: #176575]	
	20230918@Los: Count suspened - [Redmine: #194475]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
        DECLARE @LA_Bettype INT= -1002;

        -- select SABA assignment
        SELECT DISTINCT 
               u.UserId, 
               ass.AssignmentId, 
               la.OWPLeagueName, 
               ma.OWPMatchId, 
               ma.EventDateTime
        FROM dbo.[User] u WITH(NOLOCK)
             LEFT JOIN dbo.Assignment ass WITH(NOLOCK) ON u.UserId = ass.UserId
             LEFT JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
             LEFT JOIN dbo.OWPLeague la WITH(NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
             LEFT JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
             LEFT OUTER JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
        WHERE mn.MinorMatchId IS NULL
              AND ass.AssignmentType = 1
              AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
              AND ass.Bettype <> @LA_Bettype
               AND mi.MatchStatus IN('Live', 'Suspended')
              AND la.OWPLeagueName LIKE '%SABA %'

        -- Union old SABA assignment
        UNION
        SELECT DISTINCT 
               u.UserId, 
               ass.AssignmentId, 
               la.OWPLeagueName, 
               ma.OWPMatchId, 
               ma.EventDateTime
        FROM dbo.[User] u WITH(NOLOCK)
             LEFT JOIN dbo.Assignment_Old ass WITH(NOLOCK) ON u.UserId = ass.UserId
             LEFT JOIN dbo.OWPMatch_Old ma WITH(NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
             LEFT JOIN dbo.OWPLeague la WITH(NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
             LEFT JOIN dbo.MatchInfo_Old mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
             LEFT OUTER JOIN dbo.MinorMatch_Old mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
        WHERE mn.MinorMatchId IS NULL
              AND ass.AssignmentType = 1
              AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
              AND ass.Bettype <> @LA_Bettype
               AND mi.MatchStatus IN('Live', 'Suspended')
              AND la.OWPLeagueName LIKE '%SABA %'
        ORDER BY UserId ASC, 
                 ma.EventDateTime ASC;
    END;