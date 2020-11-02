
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertOtherAssignment] @ActorId          INT, 
                                                                     @PreMatchLeagueId INT, 
                                                                     @NewValue         NVARCHAR(30)  = '', 
                                                                     @OldValue         NVARCHAR(30)  = '', 
                                                                     @NewNoteValue     NVARCHAR(200) = '', 
                                                                     @OldNoteValue     NVARCHAR(200) = '', 
                                                                     @Bettype          INT, 
                                                                     @IsTakeOver       BIT, 
                                                                     @PreMatchIssueId  INT           = NULL
AS

/*
Created: 20200930@Tyler
Task : Pre-Match Other Assignment
DB: bodb_OWP

Revisions:
	20200930@Tyler: Init SP - [Redmine: #142258]
	20201026@Tyler: update insert receiver  - [Redmine: #140772]  
	
*/

     SET NOCOUNT ON;
     DECLARE @userId INT;
     DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
     CREATE TABLE #tblMatchIssues(PreMatchIssueId INT);

     -- temp table
     INSERT INTO #tblMatchIssues(PreMatchIssueId)
            SELECT i.PreMatchIssueId
            FROM [dbo].[InfoSiteMatch] AS m WITH(NOLOCK)
                 INNER JOIN PreMatchLeague AS pl WITH(NOLOCK) ON pl.OWPLeagueId = m.OWPLeagueId
                 INNER JOIN PreMatchIssue AS i ON i.InfoSiteMatchId = m.InfoSiteMatchId
            WHERE pl.PreMatchLeagueId = @PreMatchLeagueId
                  AND m.EventDateTime BETWEEN DATEADD(DAY, DATEDIFF(DAY, 0, pl.EventDate), '12:00:00') AND DATEADD(DAY, DATEDIFF(DAY, -1, pl.EventDate), '11:59:59');
     --
	 SELECT @userId = u.UserId
     FROM dbo.[User] AS u WITH(NOLOCK)
     WHERE u.Username = @NewValue;
     IF NOT EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchAssignment]
         WHERE PreMatchLeagueId = @PreMatchLeagueId
               AND Bettype = @Bettype
               AND IsTakeOver = @IsTakeOver
               AND AssignmentType = 2
     )
         BEGIN
             INSERT INTO [dbo].[PreMatchAssignment]
             ([PreMatchLeagueId], 
              [UserId], 
              [Bettype], 
              [IsTakeOver], 
              [AssignmentType], 
              [AssignmentNote]
             )
             VALUES
             (@PreMatchLeagueId, 
              @userId, 
              @Bettype, 
              @IsTakeOver, 
              2, 
              @NewNoteValue
             );
         END;
         ELSE
         BEGIN
             UPDATE dbo.[PreMatchAssignment]
               SET 
                   UserId = @userId, 
                   AssignmentNote = @NewNoteValue
             WHERE PreMatchLeagueId = @PreMatchLeagueId
                   AND Bettype = @Bettype
                   AND IsTakeOver = @IsTakeOver
                   AND AssignmentType = 2;
         END;

     -- Insert for receiving isssue message
     INSERT INTO [dbo].[PreMatchIssueReceiver]
     ([PreMatchIssueId], 
      [UserId], 
      [IsRead]
     )
            SELECT @PreMatchIssueId, 
                   @userId, 
                   1
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM [dbo].[PreMatchIssueReceiver]
                WHERE UserId = @userId
                      AND PreMatchIssueId = @PreMatchIssueId
            )
                  AND @PreMatchIssueId IS NOT NULL;

     -- Receivers for infosite matches issue
     INSERT INTO [dbo].[PreMatchIssueReceiver]
     ([PreMatchIssueId], 
      [UserId], 
      [IsRead]
     )
            SELECT PreMatchIssueId, 
                   @userId, 
                   1
            FROM #tblMatchIssues AS i
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM [dbo].[PreMatchIssueReceiver]
                WHERE PreMatchIssueId = i.PreMatchIssueId
                      AND UserId = @userId
            );

     SET @Xml = (
     SELECT @preMatchLeagueId AS '@plid', 
            @userId AS '@uid', 
            @Bettype AS '@bt', 
            @IsTakeOver AS '@ito', 
            @NewValue AS '@un', 
            @NewNoteValue AS '@an' FOR XML PATH('z'), ROOT('r'));
     SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
     SET @EndRun = GETDATE();
     SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
     EXEC dbo.OWP_WriteLog 
          @CreatorId = @ActorId, 
          @SPName = 'OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment', 
          @LoggedDate = @StartRun, 
          @Duration = @Duration, 
          @ObjectId = @preMatchLeagueId, 
          @DataOld = @LogDataOld, 
          @Data = @LogData;