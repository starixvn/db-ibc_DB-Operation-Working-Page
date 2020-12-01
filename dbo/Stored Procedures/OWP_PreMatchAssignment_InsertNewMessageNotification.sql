
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewMessageNotification] @ActorId             INT, 
                                                                            @IsImportant         BIT, 
                                                                            @IsWatcher           BIT, 
                                                                            @NotificationType    INT, 
                                                                            @SessionId           VARCHAR(100)  = NULL, 
                                                                            @PreMatchIssueId     INT, 
                                                                            @NotificationContent NVARCHAR(MAX)
AS

/*
Created: 20200916@Tyler
Task : send notification when there's a new message inserted
DB: bodb_OWP

Revisions:
	20200916@Tyler: Init SP - [Redmine: #140620]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201021@Mira: New add request  - [Redmine: #140772]
	20201021@Esther: update Receivers  - [Redmine: #143939]
	20201117@Esther: update event date  - [Redmine: #145409]
	20201120@Mira: Modify Add New issue - [Redmine: #145568]
*/

     SET NOCOUNT ON;
     DECLARE @messageTemplate NVARCHAR(MAX);
     DECLARE @fromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '00:00:00');
     DECLARE @eventName NVARCHAR(2000);
     DECLARE @actorName NVARCHAR(50);
     DECLARE @tblReceivedUser TVP_INT;
     SELECT @actorName = CASE
                             WHEN Nickname IS NOT NULL
                             THEN Nickname
                             ELSE Username
                         END
     FROM dbo.[User] WITH(NOLOCK)
     WHERE UserId = @ActorId;
     SELECT @eventName = CASE
                             WHEN i.InfoSiteMatchId IS NULL
                                  AND i.OWPLeagueId IS NULL
                             THEN n.Subject
                             WHEN i.InfoSiteMatchId IS NOT NULL
                             THEN(m.LeagueName + ' - ' + m.HomeName + ' -vs- ' + m.AwayName)
                             ELSE l.OWPLeagueName
                         END
     FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
          LEFT JOIN [NewAddRequest] AS n WITH(NOLOCK) ON i.PreMatchIssueId = n.PrematchIssueId
          LEFT JOIN [InfoSiteMatch] AS m WITH(NOLOCK) ON i.InfoSiteMatchId = m.InfoSiteMatchId
          LEFT JOIN [OWPLeague] AS l WITH(NOLOCK) ON i.OWPLeagueId = l.OWPLeagueId
     WHERE i.PreMatchIssueId = @PreMatchIssueId;
     SELECT @messageTemplate = REPLACE(REPLACE(@NotificationContent, '<League Name>/<Event Name>', @eventName), '<username>', @actorName);
     INSERT INTO @tblReceivedUser(Id)
            SELECT UserId
            FROM dbo.[PreMatchIssueReceiver] WITH(NOLOCK)
            WHERE PreMatchIssueId = @PreMatchIssueId
                  AND UserId <> @ActorId
            UNION
            SELECT UserId
            FROM dbo.[PreMatchIssueMessage] AS p WITH(NOLOCK)
            WHERE PreMatchIssueId = @PreMatchIssueId
                  AND UserId <> @ActorId
                  AND DATEADD(HOUR, 12, p.CreatedDate) >= @fromDate
     EXEC dbo.OWP_MessageInsert 
          @UserId = @ActorId, 
          @MessageContent = @messageTemplate, 
          @MessageType = @NotificationType, 
          @MessageTo = @tblReceivedUser, 
          @IsImportant = @IsImportant, 
          @IsWatcher = @IsWatcher, 
          @SessionId = @SessionId;