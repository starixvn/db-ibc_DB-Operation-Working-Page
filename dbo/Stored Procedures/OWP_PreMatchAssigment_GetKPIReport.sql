
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssigment_GetKPIReport]
AS

/*
Created: 20210330@Tyler
Task : PreMatchAssigment - Get adhoc report for KPI review
DB: bodb_OWP

Revisions:
	20210330@Tyler: Initial - [Redmine: #152255]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT im.LeagueName AS 'League', 
               '' AS 'Home', 
               '' AS 'Away', 
               '' AS 'EventDateTime', 
               'League' AS 'Type', 
               m.Message AS 'MessageContent', 
               m.CreatedDate AS 'CommentDate', 
               u.Username
        FROM PreMatchIssue i WITH(NOLOCK)
             INNER JOIN PreMatchIssueMessage m WITH(NOLOCK) ON i.PreMatchIssueId = m.PreMatchIssueId
             INNER JOIN
        (
            SELECT DISTINCT 
                   OWPLeagueId, 
                   LeagueName
            FROM InfoSiteMatch WITH(NOLOCK)
        ) im ON i.OWPLeagueId = im.OWPLeagueId
             INNER JOIN [User] u WITH(NOLOCK) ON m.UserId = u.UserId
        UNION
        SELECT im.LeagueName AS 'League', 
               im.HomeName AS 'Home', 
               im.AwayName AS 'Away', 
               im.EventDateTime AS 'EventDateTime', 
               'Match' AS 'Type', 
               m.Message AS 'MessageContent', 
               m.CreatedDate AS 'CommentDate', 
               u.Username
        FROM PreMatchIssue i WITH(NOLOCK)
             INNER JOIN PreMatchIssueMessage m WITH(NOLOCK) ON i.PreMatchIssueId = m.PreMatchIssueId
             INNER JOIN InfoSiteMatch im WITH(NOLOCK) ON i.InfoSiteMatchId = im.InfoSiteMatchId
             INNER JOIN [User] u WITH(NOLOCK) ON m.UserId = u.UserId
        UNION
        SELECT r.Subject AS 'League', 
               '' AS 'Home', 
               '' AS 'Away', 
               '' AS 'EventDateTime', 
               'Other' AS 'Type', 
               m.Message AS 'MessageContent', 
               m.CreatedDate AS 'CommentDate', 
               u.Username
        FROM PreMatchIssue i WITH(NOLOCK)
             INNER JOIN PreMatchIssueMessage m WITH(NOLOCK) ON i.PreMatchIssueId = m.PreMatchIssueId
             INNER JOIN NewAddRequest r WITH(NOLOCK) ON r.PrematchIssueId = i.PreMatchIssueId
             INNER JOIN [User] u WITH(NOLOCK) ON m.UserId = u.UserId
        WHERE i.InfoSiteMatchId IS NULL
              AND i.OWPLeagueId IS NULL
        ORDER BY League, 
                 CommentDate ASC;
    END;