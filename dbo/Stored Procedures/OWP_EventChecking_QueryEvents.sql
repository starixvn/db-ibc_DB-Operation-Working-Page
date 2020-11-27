
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventChecking_QueryEvents] @ActorId   INT, 
                                                      @MarketKey INT
AS

/*  
Created: 2020908@Tyler.Dang  
Task : Query leagues and matches
DB: bodb_OWP  
  
Revisions:  
 20200908@Tyler: Init SP  - [Redmine: #140620] 
 20201020@Esther: Remove EventDate  - [Redmine: #143792] 
 20201020@Mira: new add request, pagination  - [Redmine: #143792]
 20201102@Mira: remove pagination, IsHideDoneIssues - [Redmine: #143782]
 20201119@Carlos.nguyen: Event Tickets enhancement - Phase 1 (Task: Query two last message) - [Redmine: #145568]
 20201123@Esther: Event Tickets enhancement - Phase 1 (Task: Add filter) - [Redmine: #145568]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @LastDay INT= 7;
        DECLARE @earlyFilter INT= 2;
        DECLARE @FromDate DATETIME= DATEADD(day, -@LastDay, GETDATE());

        -- Table issue
        DECLARE @tblIssues TABLE
        (PreMatchIssueId INT, 
         InfoSiteMatchId INT, 
         OWPLeagueId     INT, 
         [Message]       NVARCHAR(MAX), 
         IsRead          BIT, 
         [Subject]       NVARCHAR(500), 
         LeagueName      NVARCHAR(500), 
         HomeName        NVARCHAR(500), 
         AwayName        NVARCHAR(500), 
         EventDateTime   DATETIME, 
         CreatedDate     DATETIME, 
         UserId          INT
        );

        -- insert league issue
        INSERT INTO @tblIssues
               SELECT m.PreMatchIssueId, 
                      NULL, 
                      x.OWPLeagueId, 
                      im.[Message],
                      CASE
                          WHEN r.IsRead IS NULL
                          THEN 1
                          ELSE r.IsRead
                      END AS 'IsRead', 
                      NULL, 
                      l.OWPLeagueName, 
                      NULL, 
                      NULL, 
                      NULL, 
                      DATEADD(HOUR, 12, im.CreatedDate), 
                      im.UserId
               FROM(SELECT i.OWPLeagueId, 
                           MAX(m.CreatedDate) AS 'MaxDate'
                    FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                         LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                    WHERE i.OWPLeagueId IS NOT NULL
                    GROUP BY i.OWPLeagueId) AS x
                   INNER JOIN dbo.[OWPLeague] AS l WITH(NOLOCK) ON l.OWPLeagueId = x.OWPLeagueId
                   INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.OWPLeagueId = x.OWPLeagueId
                   INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
                   LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                              AND r.UserId = @ActorId
               WHERE x.MaxDate >= @FromDate
                     AND im.CreatedDate = x.MaxDate;

        -- Table infositematch issue
        INSERT INTO @tblIssues
               SELECT m.PreMatchIssueId, 
                      x.InfoSiteMatchId, 
                      NULL, 
                      im.[Message],
                      CASE
                          WHEN r.IsRead IS NULL
                          THEN 1
                          ELSE r.IsRead
                      END AS 'IsRead', 
                      NULL, 
                      ifm.LeagueName, 
                      ifm.HomeName, 
                      ifm.AwayName, 
                      ifm.EventDateTime, 
                      DATEADD(HOUR, 12, im.CreatedDate), 
                      im.UserId
               FROM(SELECT i.InfoSiteMatchId, 
                           MAX(m.CreatedDate) AS 'MaxDate'
                    FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                         LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                    WHERE i.InfoSiteMatchId IS NOT NULL
                    GROUP BY i.InfoSiteMatchId) AS x
                   INNER JOIN dbo.[InfoSiteMatch] AS ifm WITH(NOLOCK) ON ifm.InfoSiteMatchId = x.InfoSiteMatchId
                   INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.InfoSiteMatchId = x.InfoSiteMatchId
                   INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
                   LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                              AND r.UserId = @ActorId
               WHERE x.MaxDate >= @FromDate
                     AND im.CreatedDate = x.MaxDate;

        -- Table newAddRequestIssues
        INSERT INTO @tblIssues
               SELECT m.PreMatchIssueId, 
                      NULL, 
                      NULL, 
                      im.[Message],
                      CASE
                          WHEN r.IsRead IS NULL
                          THEN 1
                          ELSE r.IsRead
                      END AS 'IsRead', 
                      n.[Subject], 
                      NULL, 
                      NULL, 
                      NULL, 
                      NULL, 
                      DATEADD(HOUR, 12, im.CreatedDate), 
                      im.UserId
               FROM(SELECT i.PreMatchIssueId, 
                           MAX(m.CreatedDate) AS 'MaxDate'
                    FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                         LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                    WHERE i.OWPLeagueId IS NULL
                          AND i.InfoSiteMatchId IS NULL
                    GROUP BY i.PreMatchIssueId) AS x
                   INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.PreMatchIssueId = x.PreMatchIssueId
                   INNER JOIN dbo.[NewAddRequest] AS n WITH(NOLOCK) ON n.PreMatchIssueId = x.PreMatchIssueId
                   INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
                   LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                              AND r.UserId = @ActorId
               WHERE x.MaxDate >= @FromDate
                     AND im.CreatedDate = x.MaxDate;

        --Result
        SELECT i.[PreMatchIssueId], 
               i.[OWPLeagueId] 'LeagueId', 
               i.[InfoSiteMatchId], 
               i.[LeagueName], 
               i.[HomeName], 
               i.[AwayName], 
               i.[EventDateTime], 
               i.[IsRead], 
               i.[CreatedDate],
               CASE
                   WHEN u.[Nickname] IS NULL
                   THEN u.[Username]
                   ELSE u.[Nickname]
               END AS 'Username',
               p.[IsDone], 
               i.[Subject]
        FROM dbo.[PreMatchIssue] AS p WITH(NOLOCK)
             LEFT JOIN @tblIssues AS i ON i.PreMatchIssueId = p.PreMatchIssueId
             INNER JOIN dbo.[User] AS u ON u.UserId = i.UserId
        ORDER BY p.IsDone ASC, 
                 i.IsRead ASC, 
                 i.CreatedDate DESC;
        SELECT p.PreMatchIssueId, 
               im.[Message] AS 'MessageContent', 
               DATEADD(HOUR, 12, im.CreatedDate) AS 'CreatedDate',
               CASE
                   WHEN u.[Nickname] IS NULL
                   THEN u.[Username]
                   ELSE u.[Nickname]
               END AS 'Username',
			   u.[Username] 'AccountName'
        FROM dbo.[PreMatchIssue] AS p WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = p.PreMatchIssueId
             INNER JOIN dbo.[User] AS u ON u.UserId = im.UserId
        ORDER BY p.PreMatchIssueId DESC;
        IF @MarketKey = @earlyFilter
            BEGIN
                SELECT DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()), '12:00:00') AS 'FromDate';
            END;
            ELSE
            BEGIN
                SELECT DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00') 'FromDate';
            END;
    END;