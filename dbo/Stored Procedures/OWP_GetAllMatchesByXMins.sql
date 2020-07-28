/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE dbo.[OWP_GetAllMatchesByXMins] @MatchIds VARCHAR(MAX)
	
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
	DECLARE @allMatchIds TABLE(MatchId INT);
    INSERT INTO @allMatchIds
        SELECT DISTINCT 
                val
        FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);

     -- Result
     SELECT m.[OWPMatchId] AS MatchId, 			
			mm.[ParentMatchId] AS ParentMatchId,
			mm.MinorBettypeId,
            l.[OWPLeagueName] AS LeagueName, 
            (CASE WHEN mmm.IsNeutral = 1 THEN h.OWPTeamName + ' (N)' ELSE h.OWPTeamName END) AS Home, 
            a.[OWPTeamName] AS Away, 
			mmm.[MatchNo]
	FROM dbo.OWPMatch m WITH(NOLOCK)
          LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
		  INNER JOIN dbo.OWPMatch mmm WITH(NOLOCK) ON 
				(m.OWPMatchId = mmm.OWPMatchId AND (mm.MinorBettypeId IS NULL OR mm.MinorBettypeId NOT IN (-1, -2, -88, -89))) OR
				(mm.ParentMatchId = mmm.OWPMatchId AND (mm.MinorBettypeId IN (-1, -2, -88, -89)))				
          INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON mmm.OWPHomeId = h.OWPTeamId
          INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON mmm.OWPAwayId = a.OWPTeamId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON mmm.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
		  INNER JOIN @allMatchIds t ON t.MatchId = m.OWPMatchId
     WHERE i.IsSelected = 1
END
