
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_EventChecking_CreateTab_QueryEvents] @ActorId    INT, 
                                                              @DataFilter NVARCHAR(2000)
AS

/*  
Created: 20201102@Esther.Nguyen  
Task : Query leagues and matches by filter 
DB: bodb_OWP  
  
Revisions:  
 20201102@Esther: Init SP  - [Redmine: #144692] 
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @getDate DATETIME= DATEADD(HOUR, 12, GETDATE());
        DECLARE @eventDate DATE= CAST(@getDate AS DATE);
        DECLARE @fromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');

		IF(@DataFilter <> '')
			BEGIN
				SELECT PreMatchIssueId, 
					 InfoSiteMatchId, 
					 LeagueId, 
					 IsRead, 
					 LeagueName, 
					 HomeName, 
					 AwayName, 
					 EventDateTime
					 FROM(
					-- insert league issue
					SELECT DISTINCT 
						   m.PreMatchIssueId AS 'PreMatchIssueId', 
						   NULL AS 'InfoSiteMatchId', 
						   pl.OWPLeagueId AS 'LeagueId',
						   CASE
							   WHEN r.IsRead IS NULL
							   THEN 1
							   ELSE r.IsRead
						   END AS 'IsRead', 
						   l.OWPLeagueName AS 'LeagueName', 
						   NULL AS 'HomeName', 
						   NULL AS 'AwayName', 
						   NULL AS 'EventDateTime'
					FROM dbo.[PreMatchLeague] AS pl WITH(NOLOCK)
						 INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
						 LEFT JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
						 LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
																					AND r.UserId = @ActorId
					WHERE pl.EventDate >= @eventDate
						  AND l.OWPLeagueName LIKE '%' + @DataFilter + '%'
					UNION ALL
					-- Table infositematch issue
					SELECT DISTINCT 
						   p.PreMatchIssueId AS 'PreMatchIssueId', 
						   m.InfoSiteMatchId AS 'InfoSiteMatchId', 
						   NULL AS 'LeagueId',
						   CASE
							   WHEN r.IsRead IS NULL
							   THEN 1
							   ELSE r.IsRead
						   END AS 'IsRead', 
						   m.LeagueName AS 'LeagueName', 
						   m.HomeName AS 'HomeName', 
						   m.AwayName AS 'AwayName', 
						   m.EventDateTime AS 'EventDateTime'
					FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
						 LEFT JOIN dbo.[PreMatchIssue] AS p WITH(NOLOCK) ON m.InfoSiteMatchId = p.InfoSiteMatchId
						 LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = p.PreMatchIssueId
																					AND r.UserId = @ActorId
					WHERE m.EventDateTime >= @fromDate
						  AND (m.LeagueName LIKE '%' + @DataFilter + '%'
							   OR m.HomeName LIKE '%' + @DataFilter + '%'
							   OR m.AwayName LIKE '%' + @DataFilter + '%'
							   OR (m.HomeName + ' -vs- ' + m.AwayName) LIKE '%' + @DataFilter + '%')) Results
					ORDER BY CASE
						WHEN LeagueId IS NULL
						THEN HomeName
						END ASC,
					CASE
						WHEN LeagueId IS NOT NULL
						THEN LeagueName
						END ASC;
						END;
    END;