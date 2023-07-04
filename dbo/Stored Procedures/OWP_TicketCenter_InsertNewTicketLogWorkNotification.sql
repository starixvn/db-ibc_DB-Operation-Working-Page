
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_InsertNewTicketLogWorkNotification] @ActorId             INT, 
                                                                             @IsImportant         BIT, 
                                                                             @IsWatcher           BIT, 
                                                                             @NotificationType    INT, 
                                                                             @SessionId           VARCHAR(100)  = NULL, 
                                                                             @TicketId            INT, 
                                                                             @NotificationContent NVARCHAR(MAX)
AS

/*
 Created: 20230612@Liam 
Task : send notification when there's a new message inserted
DB: bodb_OWP

Revisions:
	20230612@Liam: Init SP - [Redmine: #185890]
	20230703@Johnny: Get Ticket Log Work from bodb02 - [Redmine: #190284]
*/

     SET NOCOUNT ON;
     DECLARE @messageTemplate NVARCHAR(MAX);
     DECLARE @eventName NVARCHAR(2000);
     DECLARE @tblTicketLogWorkEvent TABLE
     (TicketId      INT, 
      AdminSiteId   INT, 
      LeagueId      INT, 
      HomeId        INT, 
      AwayId        INT, 
      EventDateTime DATETIME, 
      [Subject]     NVARCHAR(2000)
     );
     INSERT INTO @tblTicketLogWorkEvent
     (TicketId, 
      AdminSiteId, 
      LeagueId, 
      HomeId, 
      AwayId, 
      EventDateTime, 
      [Subject]
     )
            SELECT til.TicketId, 
                   til.AdminsiteId, 
                   COALESCE(m.leagueid, m14.leagueid) AS LeagueId, 
                   COALESCE(m.homeid, m14.homeid) AS HomeId, 
                   COALESCE(m.awayid, m14.awayid) AS AwayId, 
                   COALESCE(m.globalshowtime, m14.globalshowtime) AS EventDateTime, 
                   til.[Subject]
            FROM TicketIssueLogWork AS til WITH(NOLOCK)
                 LEFT JOIN [bodb02].[dbo].[match] AS m WITH(NOLOCK) ON til.AdminsiteId = m.matchid
                 LEFT JOIN [bodb02].[dbo].[match14] AS m14 WITH(NOLOCK) ON til.AdminsiteId = m14.matchid
            WHERE til.TicketId = @TicketId;
     -- username
     DECLARE @actorName NVARCHAR(50);
     DECLARE @tblReceivedUser TVP_INT;
     SELECT TOP 1 @actorName = CASE
                                   WHEN Nickname IS NOT NULL
                                   THEN Nickname
                                   ELSE Username
                               END
     FROM dbo.[User] WITH(NOLOCK)
     WHERE UserId = @ActorId;
     -- end
     -- Subject name
     SELECT TOP 1 @eventName = CASE
                                   WHEN til.LeagueId IS NOT NULL
                                   THEN '[' + CONVERT(NVARCHAR(100), AdminsiteId) + '] ' + l.leaguename + ' - ' + t.teamname + ' - vs - ' + ta.teamname
                                   WHEN til.[Subject] IS NOT NULL
                                   THEN [Subject]
                                   ELSE CONVERT(NVARCHAR(100), AdminsiteId)
                               END
     FROM @tblTicketLogWorkEvent AS til
          LEFT JOIN [bodb02].[dbo].[league] AS l ON til.LeagueId = l.leagueid
          LEFT JOIN [bodb02].[dbo].[Team] AS t ON til.HomeId = t.teamid
          LEFT JOIN [bodb02].[dbo].[Team] AS ta ON til.AwayId = ta.teamid
     WHERE til.TicketId = @TicketId;
     -- end

     SELECT @messageTemplate = REPLACE(REPLACE(@NotificationContent, '<Event>', @eventName), '<username>', @actorName);
     INSERT INTO @tblReceivedUser(Id)
     EXEC [dbo].[OWP_TicketCenterEvent_GetUserIdsByTicketId] 
          @TicketId = @TicketId;

     -- Delete creatorId
     DELETE FROM @tblReceivedUser
     WHERE Id = @ActorId;
     EXEC dbo.OWP_MessageInsert 
          @UserId = @ActorId, 
          @MessageContent = @messageTemplate, 
          @MessageType = @NotificationType, 
          @MessageTo = @tblReceivedUser, 
          @IsImportant = @IsImportant, 
          @IsWatcher = @IsWatcher, 
          @SessionId = @SessionId;