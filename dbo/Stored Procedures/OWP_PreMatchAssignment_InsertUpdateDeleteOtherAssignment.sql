USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment]    Script Date: 10/9/2020 9:05:19 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment] @ActorId          INT, 
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
	
*/

     SET NOCOUNT ON;
     DECLARE @userId INT;
     DECLARE @newUserId INT;
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

     -- new assignment
     IF(@OldValue = ''
        AND @NewValue <> '')
         BEGIN
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
             IF(@PreMatchIssueId IS NOT NULL)
                 BEGIN
                     IF NOT EXISTS
                     (
                         SELECT 1
                         FROM [dbo].[PreMatchIssueReceiver]
                         WHERE UserId = @userId
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
                              @userId, 
                              0
                             );
                     END;
             END;

             -- Receivers for infosite matches issue
             IF EXISTS
             (
                 SELECT 1
                 FROM #tblMatchIssues
             )
                 BEGIN
                     INSERT INTO [dbo].[PreMatchIssueReceiver]
                     ([PreMatchIssueId], 
                      [UserId], 
                      [IsRead]
                     )
                            SELECT PreMatchIssueId, 
                                   @userId, 
                                   0
                            FROM #tblMatchIssues AS i
                            WHERE NOT EXISTS
                            (
                                SELECT 1
                                FROM [dbo].[PreMatchIssueReceiver]
                                WHERE PreMatchIssueId = i.PreMatchIssueId
                                      AND UserId = @userId
                            );
             END;
             SET @Xml =
             (
                 SELECT @preMatchLeagueId AS '@plid', 
                        @userId AS '@uid', 
                        @Bettype AS '@bt', 
                        @IsTakeOver AS '@ito', 
                        @NewValue AS '@un', 
                        @NewNoteValue AS '@an' FOR XML PATH('z'), ROOT('r')
             );
             SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
     END;

     -- remove assignment
     IF(@OldValue <> ''
        AND @NewValue = '')
         BEGIN
             SELECT @userId = UserId
             FROM dbo.[PreMatchAssignment]
             WHERE PreMatchLeagueId = @PreMatchLeagueId
                   AND Bettype = @Bettype
                   AND IsTakeOver = @IsTakeOver
                   AND AssignmentType = 2;
             SET @Xml =
             (
                 SELECT @preMatchLeagueId AS '@plid', 
                        @userId AS '@uid', 
                        @Bettype AS '@bt', 
                        @IsTakeOver AS '@ito', 
                        @OldValue AS '@un', 
                        @OldNoteValue AS '@an' FOR XML PATH('z'), ROOT('r')
             );
             SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');

             -- delete from receiving isssue message
             DELETE r
             FROM [dbo].[PreMatchIssueReceiver] AS r
             WHERE @PreMatchIssueId IS NOT NULL
                   AND r.PreMatchIssueId = @PreMatchIssueId
                   AND r.UserId = @userId;
             DELETE r
             FROM [dbo].[PreMatchIssueReceiver] AS r
                  INNER JOIN #tblMatchIssues AS i ON i.PreMatchIssueId = r.PreMatchIssueId
             WHERE r.UserId = @userId;

             -- Note
             IF(@NewNoteValue = '')
                 BEGIN
                     -- delete asssignment
                     DELETE FROM dbo.[PreMatchAssignment]
                     WHERE PreMatchLeagueId = @PreMatchLeagueId
                           AND Bettype = @Bettype
                           AND IsTakeOver = @IsTakeOver
                           AND AssignmentType = 2;
             END;

             -- Note
             IF(@NewNoteValue <> @OldNoteValue)
                 BEGIN
                     -- delete asssignment
                     UPDATE dbo.[PreMatchAssignment]
                       SET 
                           UserId = 0, 
                           AssignmentNote = @NewNoteValue
                     WHERE PreMatchLeagueId = @PreMatchLeagueId
                           AND Bettype = @Bettype
                           AND IsTakeOver = @IsTakeOver
                           AND AssignmentType = 2;
                     SET @Xml =
                     (
                         SELECT @preMatchLeagueId AS '@plid', 
                                0 AS '@uid', 
                                @Bettype AS '@bt', 
                                @IsTakeOver AS '@ito', 
                                @NewValue AS '@un', 
                                @NewNoteValue AS '@an' FOR XML PATH('z'), ROOT('r')
                     );
                     SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             END;
     END;

     -- update assignment
     IF(@OldValue <> ''
        AND @NewValue <> ''
        AND @OldValue <> @NewValue)
         BEGIN
             SELECT @userId = UserId
             FROM dbo.[PreMatchAssignment]
             WHERE PreMatchLeagueId = @PreMatchLeagueId
                   AND Bettype = @Bettype
                   AND IsTakeOver = @IsTakeOver
                   AND AssignmentType = 2;
             --
             SELECT @newUserId = u.UserId
             FROM dbo.[User] AS u WITH(NOLOCK)
             WHERE u.Username = @NewValue;
             SET @Xml =
             (
                 SELECT @preMatchLeagueId AS '@plid', 
                        @userId AS '@uid', 
                        @Bettype AS '@bt', 
                        @IsTakeOver AS '@ito', 
                        @OldValue AS '@un', 
                        @OldNoteValue AS '@an' FOR XML PATH('z'), ROOT('r')
             );
             SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');

             -- delete from receiving isssue message
             DELETE r
             FROM [dbo].[PreMatchIssueReceiver] AS r
             WHERE @PreMatchIssueId IS NOT NULL
                   AND r.PreMatchIssueId = @PreMatchIssueId
                   AND r.UserId = @userId;
             DELETE r
             FROM [dbo].[PreMatchIssueReceiver] AS r
                  INNER JOIN #tblMatchIssues AS i ON i.PreMatchIssueId = r.PreMatchIssueId
             WHERE r.UserId = @userId;

             --
             UPDATE dbo.[PreMatchAssignment] WITH(ROWLOCK)
               SET 
                   UserId = @newUserId
             WHERE PreMatchLeagueId = @PreMatchLeagueId
                   AND Bettype = @Bettype
                   AND IsTakeOver = @IsTakeOver
                   AND AssignmentType = 2;

             -- Note
             IF(@NewNoteValue <> @OldNoteValue)
                 BEGIN
                     UPDATE dbo.[PreMatchAssignment]
                       SET 
                           AssignmentNote = @NewNoteValue
                     WHERE PreMatchLeagueId = @PreMatchLeagueId
                           AND Bettype = @Bettype
                           AND IsTakeOver = @IsTakeOver
                           AND AssignmentType = 2;
             END;

             -- Insert for receiving isssue message
             IF(@PreMatchIssueId IS NOT NULL)
                 BEGIN
                     INSERT INTO [dbo].[PreMatchIssueReceiver]
                     ([PreMatchIssueId], 
                      [UserId], 
                      [IsRead]
                     )
                     VALUES
                     (@PreMatchIssueId, 
                      @newUserId, 
                      0
                     );
             END;

             -- Receivers for infosite matches issue
             IF EXISTS
             (
                 SELECT 1
                 FROM #tblMatchIssues
             )
                 BEGIN
                     INSERT INTO [dbo].[PreMatchIssueReceiver]
                     ([PreMatchIssueId], 
                      [UserId], 
                      [IsRead]
                     )
                            SELECT PreMatchIssueId, 
                                   @newUserId, 
                                   0
                            FROM #tblMatchIssues AS i
                            WHERE NOT EXISTS
                            (
                                SELECT 1
                                FROM [dbo].[PreMatchIssueReceiver]
                                WHERE PreMatchIssueId = i.PreMatchIssueId
                                      AND UserId = @newUserId
                            );
             END;
             SET @Xml =
             (
                 SELECT @preMatchLeagueId AS '@plid', 
                        @newUserId AS '@uid', 
                        @Bettype AS '@bt', 
                        @IsTakeOver AS '@ito', 
                        @NewValue AS '@un', 
                        @NewNoteValue AS '@an' FOR XML PATH('z'), ROOT('r')
             );
             SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
     END;

     -- update assignment note
     IF(@OldValue = @NewValue)
         BEGIN
             -- Update AssignmentNote
             IF(@NewNoteValue <> ''
                AND @OldNoteValue = '')
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
                      0, 
                      @Bettype, 
                      @IsTakeOver, 
                      2, 
                      @NewNoteValue
                     );
                     SET @Xml =
                     (
                         SELECT pa.PreMatchLeagueId AS '@plid', 
                                pa.UserId AS '@uid', 
                                pa.Bettype AS '@bt', 
                                pa.IsTakeOver AS '@ito', 
                                u.Username AS '@un', 
                                pa.AssignmentNote AS '@an'
                         FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                              LEFT JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                         WHERE PreMatchLeagueId = @PreMatchLeagueId
                               AND Bettype = @Bettype
                               AND IsTakeOver = @IsTakeOver
                               AND AssignmentType = 2 FOR XML PATH('z'), ROOT('r')
                     );
                     SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             END;
             IF(@NewNoteValue <> ''
                AND @OldNoteValue <> '')
                 BEGIN
                     SET @Xml =
                     (
                         SELECT pa.PreMatchLeagueId AS '@plid', 
                                pa.UserId AS '@uid', 
                                pa.Bettype AS '@bt', 
                                pa.IsTakeOver AS '@ito', 
                                u.Username AS '@un', 
                                pa.AssignmentNote AS '@an'
                         FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                              LEFT JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                         WHERE PreMatchLeagueId = @PreMatchLeagueId
                               AND Bettype = @Bettype
                               AND IsTakeOver = @IsTakeOver
                               AND AssignmentType = 2 FOR XML PATH('z'), ROOT('r')
                     );
                     SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                     UPDATE dbo.[PreMatchAssignment]
                       SET 
                           AssignmentNote = @NewNoteValue
                     WHERE PreMatchLeagueId = @PreMatchLeagueId
                           AND Bettype = @Bettype
                           AND IsTakeOver = @IsTakeOver
                           AND AssignmentType = 2;
                     SET @Xml =
                     (
                         SELECT pa.PreMatchLeagueId AS '@plid', 
                                pa.UserId AS '@uid', 
                                pa.Bettype AS '@bt', 
                                pa.IsTakeOver AS '@ito', 
                                u.Username AS '@un', 
                                pa.AssignmentNote AS '@an'
                         FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                              LEFT JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                         WHERE PreMatchLeagueId = @PreMatchLeagueId
                               AND Bettype = @Bettype
                               AND IsTakeOver = @IsTakeOver
                               AND AssignmentType = 2 FOR XML PATH('z'), ROOT('r')
                     );
                     SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             END;
             IF(@NewNoteValue = ''
                AND @OldNoteValue <> '')
                 BEGIN
                     SET @Xml =
                     (
                         SELECT pa.PreMatchLeagueId AS '@plid', 
                                pa.UserId AS '@uid', 
                                pa.Bettype AS '@bt', 
                                pa.IsTakeOver AS '@ito', 
                                u.Username AS '@un', 
                                pa.AssignmentNote AS '@an'
                         FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                              LEFT JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                         WHERE PreMatchLeagueId = @PreMatchLeagueId
                               AND Bettype = @Bettype
                               AND IsTakeOver = @IsTakeOver
                               AND AssignmentType = 2 FOR XML PATH('z'), ROOT('r')
                     );
                     SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');

                     DELETE FROM [dbo].[PreMatchAssignment]
                     WHERE PreMatchLeagueId = @PreMatchLeagueId
                           AND Bettype = @Bettype
                           AND IsTakeOver = @IsTakeOver
                           AND AssignmentType = 2;
             END;
     END;
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