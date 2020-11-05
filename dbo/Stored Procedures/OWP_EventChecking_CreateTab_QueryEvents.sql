
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

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
                -- Table issue
                DECLARE @tblIssues TABLE
                (PreMatchIssueId INT, 
                 InfoSiteMatchId INT, 
                 OWPLeagueId     INT, 
                 IsRead          BIT, 
                 LeagueName      NVARCHAR(500), 
                 HomeName        NVARCHAR(500), 
                 AwayName        NVARCHAR(500), 
                 EventDateTime   DATETIME
                );

                -- insert league issue
                INSERT INTO @tblIssues
                       SELECT DISTINCT 
                              m.PreMatchIssueId, 
                              NULL, 
                              pl.OWPLeagueId,
                              CASE
                                  WHEN r.IsRead IS NULL
                                  THEN 1
                                  ELSE r.IsRead
                              END AS 'IsRead', 
                              l.OWPLeagueName, 
                              NULL, 
                              NULL, 
                              NULL
                       FROM dbo.[PreMatchLeague] AS pl WITH(NOLOCK)
                            INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
                            LEFT JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
                            LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                                       AND r.UserId = @ActorId
                       WHERE pl.EventDate >= @eventDate;

                -- Table infositematch issue
                INSERT INTO @tblIssues
                       SELECT DISTINCT 
                              p.PreMatchIssueId, 
                              m.InfoSiteMatchId, 
                              NULL,
                              CASE
                                  WHEN r.IsRead IS NULL
                                  THEN 1
                                  ELSE r.IsRead
                              END AS 'IsRead', 
                              m.LeagueName, 
                              m.HomeName, 
                              m.AwayName, 
                              m.EventDateTime
                       FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
                            LEFT JOIN dbo.[PreMatchIssue] AS p WITH(NOLOCK) ON m.InfoSiteMatchId = p.InfoSiteMatchId
                            LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = p.PreMatchIssueId
                                                                                       AND r.UserId = @ActorId
                       WHERE m.EventDateTime >= @fromDate;

                --Result
                SELECT i.[PreMatchIssueId], 
                       i.[OWPLeagueId] 'LeagueId', 
                       i.[InfoSiteMatchId], 
                       i.[LeagueName], 
                       i.[HomeName], 
                       i.[AwayName], 
                       i.[EventDateTime], 
                       i.[IsRead]
                FROM @tblIssues AS i
                WHERE i.LeagueName LIKE '%' + @DataFilter + '%'
                      OR i.HomeName LIKE '%' + @DataFilter + '%'
                      OR i.AwayName LIKE '%' + @DataFilter + '%'
                      OR (i.HomeName + ' -vs- ' + i.AwayName) LIKE '%' + @DataFilter + '%'
                ORDER BY CASE
                             WHEN i.OWPLeagueId IS NULL
                             THEN i.HomeName
                         END ASC,
                         CASE
                             WHEN i.OWPLeagueId IS NOT NULL
                             THEN i.LeagueName
                         END ASC;
        END;
    END;