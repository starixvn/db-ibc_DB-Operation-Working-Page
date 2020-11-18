
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewMessage] @ActorId         INT, 
                                                                @Message         NVARCHAR(MAX), 
                                                                @PreMatchIssueId INT
AS

/*
Created: 20200914@Tyler
Task : Insert new message
DB: bodb_OWP

Revisions:
	20200914@Tyler: Init sync SP - [Redmine: #140620]
	20201003@Tyler: update other assignments  - [Redmine: #142258] 
	20201021@Esther: update receivers  - [Redmine: #143939]
	20201117@Esther: update event date  - [Redmine: #145409]
*/

     SET NOCOUNT ON;
     DECLARE @insertTime DATETIME= GETDATE();
     DECLARE @fromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @insertTime), '00:00:00');
     DECLARE @eventDate DATE= CAST(@fromDate AS DATE);
     DECLARE @estId INT;
     SELECT TOP 1 @estId = ResourceId
     FROM dbo.[RefResource] WITH(NOLOCK)
     WHERE RefName = N'Section'
           AND Value = N'EST';
     INSERT INTO [dbo].[PreMatchIssueMessage]
     ([PreMatchIssueId], 
      [CreatedDate], 
      [UserId], 
      [Message]
     )
     VALUES
     (@PreMatchIssueId, 
      @insertTime, 
      @ActorId, 
      @Message
     );
     IF NOT EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchIssueReceiver] WITH(NOLOCK)
         WHERE UserId = @ActorId
               AND PreMatchIssueId = @PreMatchIssueId
     )
         BEGIN
             INSERT INTO [dbo].[PreMatchIssueReceiver]
             ([PreMatchIssueId], 
              [UserId], 
              [IsRead]
             )
             VALUES
             (@PreMatchIssueId, 
              @ActorId, 
              1
             );
     END;

     ---- get assignment today ----
     DECLARE @tblReceivedUser TABLE
     (IssueId INT, 
      UserId  INT, 
      IsRead  BIT
     );
     INSERT INTO @tblReceivedUser
     (IssueId, 
      UserId, 
      IsRead
     )
            SELECT DISTINCT 
                   @PreMatchIssueId, 
                   a.[UserId], 
                   0
            FROM [dbo].[PreMatchAssignment] AS a WITH(NOLOCK)
                 INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON pl.PreMatchLeagueId = a.PreMatchLeagueId
                 INNER JOIN dbo.[InfoSiteMatch] AS m WITH(NOLOCK) ON m.OWPLeagueId = pl.OWPLeagueId
                 INNER JOIN dbo.[PreMatchIssue] AS p WITH(NOLOCK) ON p.PreMatchIssueId = @PreMatchIssueId
            WHERE(pl.OWPLeagueId = p.OWPLeagueId
                  OR m.InfoSiteMatchId = p.InfoSiteMatchId)
                 AND a.UserId <> @ActorId
                 AND a.UserId > 0
                 AND pl.EventDate >= @eventDate
            UNION
            SELECT @PreMatchIssueId, 
                   [UserId], 
                   0
            FROM [dbo].[User] WITH(NOLOCK)
            WHERE SectionId = @estId
                  AND UserId <> @ActorId
            UNION
            SELECT @PreMatchIssueId, 
                   @ActorId, 
                   1;

     ------update receiver (assignment)---------
     DELETE r
     FROM [dbo].[PreMatchIssueReceiver] AS r
          INNER JOIN @tblReceivedUser AS t ON t.IssueId = r.PreMatchIssueId
     WHERE t.UserId <> r.UserId
           AND r.UserId NOT IN
     (
         SELECT UserId
         FROM dbo.[PreMatchIssueMessage] AS p WITH(NOLOCK)
         WHERE p.PreMatchIssueId = t.IssueId
               AND DATEADD(HOUR, 12, p.CreatedDate) >= @fromDate
     );
     ----- insert receiver----
     INSERT INTO [dbo].[PreMatchIssueReceiver]
     ([PreMatchIssueId], 
      [UserId], 
      [IsRead]
     )
            SELECT t.IssueId, 
                   t.UserId, 
                   t.IsRead
            FROM @tblReceivedUser AS t
            WHERE t.UserId NOT IN
            (
                SELECT UserId
                FROM dbo.[PreMatchIssueMessage] AS p WITH(NOLOCK)
                WHERE p.PreMatchIssueId = t.IssueId
                      AND DATEADD(HOUR, 12, p.CreatedDate) >= @fromDate
            );	
     ---- update isRead-----
     UPDATE dbo.[PreMatchIssueReceiver] WITH(ROWLOCK)
       SET 
           IsRead = 0
     WHERE PreMatchIssueId = @PreMatchIssueId
           AND UserId <> @ActorId;

     -- Set undone
     UPDATE dbo.[PreMatchIssue] WITH(ROWLOCK)
       SET 
           IsDone = 0
     WHERE PreMatchIssueId = @PreMatchIssueId;