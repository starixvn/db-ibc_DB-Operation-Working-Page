USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_QueryByPreMatchLeagueId]    Script Date: 10/9/2020 10:22:39 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryByPreMatchLeagueId] @PreMatchLeagueId INT, 
                                                                       @ActorId          INT, 
                                                                       @StartTime        TIME(7) = NULL
AS

/*
Created: 20200818@Esther
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200818@Esther: Init sync SP - [Redmine: #138643]
	20200918@Tyler: Add matches/issue - [Redmine: #140620]
	20200903@Tyler: get other assignments  - [Redmine: #142258]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @StartNightTime DATETIME= @StartTime;
        DECLARE @EventFromDateTime DATETIME;
        DECLARE @eventDate DATETIME;
        SELECT @eventDate = p.EventDate
        FROM PreMatchLeague AS p WITH(NOLOCK)
        WHERE p.PreMatchLeagueId = @PreMatchLeagueId;

        -- Cal start time
        IF @StartTime IS NULL
            BEGIN
                SET @EventFromDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @eventDate), '12:00:00');
        END;
            ELSE
            IF @StartTime BETWEEN '00:00' AND '11:59'
                BEGIN
                    SET @EventFromDateTime = DATEADD(DAY, DATEDIFF(DAY, -1, @eventDate), @StartNightTime);
            END;
                ELSE
                BEGIN
                    SET @EventFromDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @eventDate), @StartNightTime);
            END;
        DECLARE @EventToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @eventDate), '11:59:59');

        -- query league info
        DECLARE @tblLeagueInfo TABLE
        (PreMatchLeagueId     INT, 
         LeagueId             INT, 
         LeagueName           NVARCHAR(500), 
         MatchCount           INT, 
         HDP                  NVARCHAR(30), 
         OU                   NVARCHAR(30), 
         HDPTakeOver          NVARCHAR(30), 
         OUTakeOver           NVARCHAR(30), 
         OtherHDPNote         NVARCHAR(200), 
         OtherOUNote          NVARCHAR(200), 
         OtherHDPTakeOverNote NVARCHAR(200), 
         OtherOUTakeOverNote  NVARCHAR(200), 
         BlackList            BIT, 
         Remark               NVARCHAR(2000)
        );
        INSERT INTO @tblLeagueInfo
               SELECT p.PreMatchLeagueId, 
                      p.OWPLeagueId, 
                      l.OWPLeagueName, 
                      COUNT(CASE
                                WHEN m1.LeagueName = l.OWPLeagueName
                                THEN 1
                                ELSE 0
                            END), 
                      '', 
                      '', 
                      '', 
                      '', 
                      '', 
                      '', 
                      '', 
                      '', 
                      l.IsBlackList, 
                      p.Remark 'Remark'
               FROM PreMatchLeague AS p WITH(ROWLOCK)
                    INNER JOIN OWPLeague AS l WITH(ROWLOCK) ON l.OWPLeagueId = p.OWPLeagueId
                    INNER JOIN InfoSiteMatch AS m1 WITH(NOLOCK) ON m1.OWPLeagueId = l.OWPLeagueId
               WHERE p.PreMatchLeagueId = @PreMatchLeagueId
                     AND m1.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
               GROUP BY p.PreMatchLeagueId, 
                        p.OWPLeagueId, 
                        l.OWPLeagueName, 
                        l.IsBlackList, 
                        p.Remark;

        -- Table league notes
        DECLARE @tblLeagueNotes TABLE
        (PreMatchNoteId INT, 
         OWPLeagueId    INT, 
         HasNotes       BIT
        );
        INSERT INTO @tblLeagueNotes
        EXEC dbo.[OWP_PreMatchAssignment_QueryLeagueNotes] 
             @EventDate = @EventDate;
        SELECT l.PreMatchLeagueId, 
               LeagueId, 
               LeagueName, 
               MatchCount, 
               HDP, 
               OU, 
               HDPTakeOver, 
               OUTakeOver, 
               OtherHDPNote, 
               OtherOUNote, 
               OtherHDPTakeOverNote, 
               OtherOUTakeOverNote, 
               BlackList, 
               Remark, 
               PreMatchIssueId, 
               HasMessages, 
               IsRead, 
               HasNotes, 
               PreMatchNoteId
        FROM @tblLeagueInfo AS l
             LEFT JOIN
        (
            SELECT TOP 1 i.PreMatchIssueId,
                         CASE
                             WHEN m.[Message] IS NOT NULL
                             THEN 1
                             ELSE 0
                         END AS 'HasMessages',
                         CASE
                             WHEN r.IsRead IS NOT NULL
                             THEN r.IsRead
                             ELSE 1
                         END AS 'IsRead', 
                         pl.PreMatchLeagueId
            FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                 INNER JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                 INNER JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = i.PreMatchIssueId
                 INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON pl.OWPLeagueId = i.OWPLeagueId
                                                                       AND pl.EventDate = i.EventDate
            WHERE r.userId = @ActorId
                  AND pl.PreMatchLeagueId = @PreMatchLeagueId
            ORDER BY m.CreatedDate DESC
        ) AS x ON x.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN @tblLeagueNotes AS n ON n.OWPLeagueId = l.LeagueId;

        -- Table infositematch issue
        DECLARE @tblInfoSiteMatchIssues TABLE
        (PreMatchIssueId INT, 
         InfoSiteMatchId INT, 
         [Message]       VARCHAR(MAX), 
         IsRead          BIT
        );
        INSERT INTO @tblInfoSiteMatchIssues
               SELECT m.PreMatchIssueId, 
                      x.InfoSiteMatchId, 
                      im.[Message],
                      CASE
                          WHEN r.IsRead IS NULL
                          THEN 1
                          ELSE r.IsRead
                      END AS 'IsRead'
               FROM
               (
                   SELECT i.InfoSiteMatchId, 
                          MAX(m.CreatedDate) AS 'MaxDate'
                   FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                        LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                   WHERE i.EventDate = @EventDate
                         AND i.InfoSiteMatchId IS NOT NULL
                   GROUP BY i.InfoSiteMatchId
               ) AS x
               INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.InfoSiteMatchId = x.InfoSiteMatchId
               INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
               LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                          AND r.UserId = @ActorId
               WHERE im.CreatedDate = x.MaxDate;

        --table match notes
        DECLARE @tblMatchNotes TABLE
        (PreMatchNoteId  INT, 
         InfoSiteMatchId INT, 
         HasNotes        BIT
        );
        INSERT INTO @tblMatchNotes
        EXEC dbo.[OWP_PreMatchAssignment_QueryInfoSiteMatchNotes] 
             @EventDate = @EventDate;
        SELECT m.InfoSiteMatchId, 
               m.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime, 
               pl.PreMatchLeagueId, 
               i.PreMatchIssueId,
               CASE
                   WHEN i.[Message] IS NOT NULL
                   THEN 1
                   ELSE 0
               END AS HasMessages, 
               i.IsRead,
			   n.HasNotes,
			   n.PreMatchNoteId
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON m.OWPLeagueId = pl.OWPLeagueId
             LEFT JOIN @tblInfoSiteMatchIssues AS i ON i.InfoSiteMatchId = m.InfoSiteMatchId
             LEFT JOIN @tblMatchNotes AS n ON n.InfoSiteMatchId = m.InfoSiteMatchId
        WHERE pl.PreMatchLeagueId = @PreMatchLeagueId
              AND m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
        ORDER BY EventDateTime ASC;
    END;