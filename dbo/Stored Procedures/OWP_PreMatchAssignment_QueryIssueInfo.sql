
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryIssueInfo] @PreMatchIssueId INT
AS

/*  
Created: 20201119@Tyler.Dang  
Task : Query issue info
DB: bodb_OWP  
  
Revisions:  
	20201119@Tyler: Init SP  - [Redmine: #145568]  
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT i.PreMatchIssueId, 
               i.InfoSiteMatchId, 
               i.OWPLeagueId AS 'LeagueId',
               CASE
                   WHEN i.InfoSiteMatchId IS NULL
                   THEN l.OWPLeagueName
                   ELSE m.LeagueName
               END AS 'LeagueName', 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime, 
               r.[Subject]
        FROM dbo.[PreMatchIssue] AS i
             LEFT JOIN dbo.[InfoSiteMatch] AS m ON i.InfoSiteMatchId = m.InfoSiteMatchId
                                                   AND i.InfoSiteMatchId IS NOT NULL
             LEFT JOIN dbo.[OWPLeague] AS l ON i.OWPLeagueId = l.OWPLeagueId
                                               AND i.OWPLeagueId IS NOT NULL
             LEFT JOIN dbo.[NewAddRequest] AS r ON i.PreMatchIssueId = r.PrematchIssueId
                                                   AND i.InfoSiteMatchId IS NULL
                                                   AND i.OWPLeagueId IS NULL
        WHERE i.PreMatchIssueId = @PreMatchIssueId;
    END;