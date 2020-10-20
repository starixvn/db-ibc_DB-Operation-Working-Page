USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_EventChecking_QueryEvents]    Script Date: 9/23/2020 1:14:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventChecking_QueryEvents]  @ActorId   INT
AS

/*  
Created: 2020908@Tyler.Dang  
Task : Query leagues and matches
DB: bodb_OWP  
  
Revisions:  
 20200908@Tyler: Init SP  - [Redmine: #140620] 
 20201020@Esther: Remove EventDate  - [Redmine: #143792] 
*/

    BEGIN
        SET NOCOUNT ON;
        -- Table league issue
        DECLARE @tblLeagueIssues TABLE
        (PreMatchIssueId INT, 
         OWPLeagueId     INT, 
         [Message]       NVARCHAR(MAX), 
         IsRead          BIT, 
         LeagueName      NVARCHAR(500), 
         CreatedDate     DATETIME, 
         UserId          INT
        );
        INSERT INTO @tblLeagueIssues
               SELECT m.PreMatchIssueId, 
                      x.OWPLeagueId, 
                      im.[Message],
                      CASE
                          WHEN r.IsRead IS NULL
                          THEN 1
                          ELSE r.IsRead
                      END AS 'IsRead', 
                      l.OWPLeagueName, 
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
               WHERE im.CreatedDate = x.MaxDate;

        -- Table infositematch issue
        DECLARE @tblInfoSiteMatchIssues TABLE
        (PreMatchIssueId INT, 
         InfoSiteMatchId INT, 
         [Message]       NVARCHAR(MAX), 
         IsRead          BIT, 
         HomeName        NVARCHAR(500), 
         AwayName        NVARCHAR(500), 
         EventDateTime   DATETIME, 
         LeagueName      NVARCHAR(500), 
         CreatedDate     DATETIME, 
         UserId          INT
        );
        INSERT INTO @tblInfoSiteMatchIssues
               SELECT m.PreMatchIssueId, 
                      x.InfoSiteMatchId, 
                      im.[Message],
                      CASE
                          WHEN r.IsRead IS NULL
                          THEN 1
                          ELSE r.IsRead
                      END AS 'IsRead', 
                      ifm.HomeName, 
                      ifm.AwayName, 
                      ifm.EventDateTime, 
                      ifm.LeagueName, 
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
               WHERE im.CreatedDate = x.MaxDate;

        --Result
        SELECT i.[PreMatchIssueId], 
               i.[OWPLeagueId], 
               i.[InfoSiteMatchId],
               CASE
                   WHEN l.LeagueName IS NOT NULL
                   THEN l.LeagueName
                   ELSE im.LeagueName
               END AS 'LeagueName', 
               im.HomeName, 
               im.AwayName, 
               im.EventDateTime,
               CASE
                   WHEN l.LeagueName IS NOT NULL
                   THEN l.IsRead
                   ELSE im.IsRead
               END AS 'IsRead',
               CASE
                   WHEN l.LeagueName IS NOT NULL
                   THEN l.[Message]
                   ELSE im.[Message]
               END AS 'Message',
               CASE
                   WHEN l.LeagueName IS NOT NULL
                   THEN l.CreatedDate
                   ELSE im.CreatedDate
               END AS 'CreatedDate',
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS 'Username', 
               i.[IsDone]
        FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
             LEFT JOIN @tblLeagueIssues AS l ON i.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN @tblInfoSiteMatchIssues AS im ON i.InfoSiteMatchId = im.InfoSiteMatchId
             INNER JOIN dbo.[User] AS u ON u.UserId = l.UserId
                                           OR u.UserId = im.UserId
        ORDER BY i.IsDone ASC, 
                 'IsRead' ASC, 
                 'CreatedDate' DESC;
    END;