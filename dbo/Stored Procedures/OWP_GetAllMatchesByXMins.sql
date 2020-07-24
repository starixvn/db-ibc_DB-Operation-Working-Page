/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE OWP_GetAllMatchesByXMins @LastTimeNotification DateTime
	
AS
/*
Created: 20200723@Esther.Nguyen
Task : Ready to Trade Status  
DB: bodb_OWP

Revisions:
	20200723@Esther.Nguyen: Staff's readiness notification - [Redmine: #137751]
*/
BEGIN
	
	SET NOCOUNT ON;
    DECLARE @XMins  DATETIME = DATEADD(MINUTE, 15,  GETDATE());

     -- Result
     SELECT m.[OWPMatchId] AS MatchId, 
            l.[OWPLeagueName] AS LeagueName, 
            (CASE WHEN m.IsNeutral = 1 THEN h.OWPTeamName + ' (N)' ELSE h.OWPTeamName END) AS Home, 
            a.[OWPTeamName] AS Away, 
            m.[KickOffTime],
			m.[MatchNo],
			mm.[ParentMatchId] AS ParentMatchId
	FROM dbo.OWPMatch m WITH(NOLOCK)
          LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
          INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
          INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
     WHERE i.IsSelected = 1
			AND m.KickOffTime BETWEEN CONVERT(char(5), @LastTimeNotification, 108) AND CONVERT(char(5), @XMins, 108)
            AND m.EventDate = CONVERT(VARCHAR(10), GETDATE(), 111)
END
