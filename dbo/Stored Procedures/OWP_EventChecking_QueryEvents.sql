
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventChecking_QueryEvents] @ActorId          INT, 
                                                      @PageNumber       INT = 1, 
                                                      @PageSize         INT = 50, 
                                                      @IsHideDoneIssues BIT
AS

/*  
Created: 2020908@Tyler.Dang  
Task : Query leagues and matches
DB: bodb_OWP  
  
Revisions:  
 20200908@Tyler: Init SP  - [Redmine: #140620] 
 20201020@Esther: Remove EventDate  - [Redmine: #143792] 
 20201020@Mira: new add request, pagination  - [Redmine: #143792] 
*/

     SET NOCOUNT ON;
     DECLARE @LastDay INT= 7;
     DECLARE @FromDate DATETIME= DATEADD(day, -@LastDay, GETDATE());
	 
     -- Pagination
     DECLARE @FromRow INT= (@PageNumber - 1) * @PageSize + 1;
     DECLARE @ToRow INT= @PageNumber * @PageSize;

     -- Table issue
     DECLARE @tblIssues TABLE
     (PreMatchIssueId INT, 
      InfoSiteMatchId INT, 
      OWPLeagueId     INT, 
      [Message]       NVARCHAR(MAX), 
      IsRead          BIT, 
      LeagueName      NVARCHAR(500), 
      MatchName       NVARCHAR(500), 
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
                   l.OWPLeagueName, 
                   NULL, 
                   NULL, 
                   NULL, 
                   NULL, 
                   DATEADD(HOUR, 12, im.CreatedDate), 
                   im.UserId
            FROM
            (
                SELECT i.OWPLeagueId, 
                       MAX(m.CreatedDate) AS 'MaxDate'
                FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                     LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                WHERE i.OWPLeagueId IS NOT NULL
                GROUP BY i.OWPLeagueId
            ) AS x
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
                   ifm.LeagueName, 
                   NULL, 
                   ifm.HomeName, 
                   ifm.AwayName, 
                   ifm.EventDateTime, 
                   DATEADD(HOUR, 12, im.CreatedDate), 
                   im.UserId
            FROM
            (
                SELECT i.InfoSiteMatchId, 
                       MAX(m.CreatedDate) AS 'MaxDate'
                FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                     LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                WHERE i.InfoSiteMatchId IS NOT NULL
                GROUP BY i.InfoSiteMatchId
            ) AS x
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
                   n.LeagueName, 
                   n.MatchName, 
                   NULL, 
                   NULL, 
                   NULL, 
                   DATEADD(HOUR, 12, im.CreatedDate), 
                   im.UserId
            FROM
            (
                SELECT i.PreMatchIssueId, 
                       MAX(m.CreatedDate) AS 'MaxDate'
                FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                     LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                WHERE i.OWPLeagueId IS NULL
                      AND i.InfoSiteMatchId IS NULL
                GROUP BY i.PreMatchIssueId
            ) AS x
            INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.PreMatchIssueId = x.PreMatchIssueId
            INNER JOIN dbo.[NewAddRequest] AS n WITH(NOLOCK) ON n.PreMatchIssueId = x.PreMatchIssueId
            INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
            LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                       AND r.UserId = @ActorId
            WHERE x.MaxDate >= @FromDate
                  AND im.CreatedDate = x.MaxDate;

     --Result
     SELECT PreMatchIssueId, 
            LeagueId, 
            InfoSiteMatchId, 
            LeagueName, 
            MatchName, 
            HomeName, 
            AwayName, 
            EventDateTime, 
            IsRead, 
            Message, 
            CreatedDate, 
            Username, 
            IsDone
     FROM
     (
         SELECT ROW_NUMBER() OVER(
                ORDER BY p.IsDone ASC, 
                         i.IsRead ASC, 
                         i.CreatedDate DESC) AS RowNumber, 
                i.[PreMatchIssueId], 
                i.[OWPLeagueId] 'LeagueId', 
                i.[InfoSiteMatchId], 
                i.[LeagueName], 
                i.[MatchName], 
                i.[HomeName], 
                i.[AwayName], 
                i.[EventDateTime], 
                i.[IsRead], 
                i.[Message], 
                i.[CreatedDate], 
                CASE
                    WHEN u.[Nickname] IS NULL
                    THEN u.[Username]
                    ELSE u.[Nickname]
                END AS 'Username', 
                p.[IsDone]
         FROM dbo.[PreMatchIssue] AS p WITH(NOLOCK)
              LEFT JOIN @tblIssues AS i ON i.PreMatchIssueId = p.PreMatchIssueId
              INNER JOIN dbo.[User] AS u ON u.UserId = i.UserId
         WHERE @IsHideDoneIssues = 0
               OR p.IsDone = 0
     ) AS Paging
     WHERE Paging.RowNumber BETWEEN @FromRow AND @ToRow;