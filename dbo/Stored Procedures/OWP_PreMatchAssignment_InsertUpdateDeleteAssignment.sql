USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment]    Script Date: 10/8/2020 9:09:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] @ActorId          INT, 
                                                                            @PreMatchLeagueId INT, 
                                                                            @NewValue         NVARCHAR(30) = '', 
                                                                            @OldValue         NVARCHAR(30) = '', 
                                                                            @Bettype          INT, 
                                                                            @IsTakeOver       BIT, 
                                                                            @PreMatchIssueId  INT          = NULL
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20200914@Tyler: Update issue receiver - [Redmine: #140620]
	20200903@Tyler: update other assignments  - [Redmine: #142258]  
	
*/

    BEGIN
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

        -- 
        IF(@OldValue = ''
           AND @NewValue <> '')
            BEGIN
                SELECT @userId = u.UserId
                FROM dbo.[User] AS u WITH(NOLOCK)
                WHERE u.Username = @NewValue;
                INSERT INTO [dbo].[PreMatchAssignment]
                ([PreMatchLeagueId], 
                 [UserId], 
                 [Bettype], 
                 [IsTakeOver], 
                 [AssignmentType]
                )
                VALUES
                (@PreMatchLeagueId, 
                 @userId, 
                 @Bettype, 
                 @IsTakeOver, 
                 1
                );

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
                -- Log
                SET @Xml =
                (
                    SELECT @preMatchLeagueId AS '@plid', 
                           @userId AS '@uid', 
                           @Bettype AS '@bt', 
                           @IsTakeOver AS '@ito', 
                           @NewValue AS '@un' FOR XML PATH('z'), ROOT('r')
                );
                SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        END;
        IF(@OldValue <> ''
           AND @NewValue = '')
            BEGIN
                SET @Xml =
                (
                    SELECT pa.PreMatchLeagueId AS '@plid', 
                           pa.UserId AS '@uid', 
                           pa.Bettype AS '@bt', 
                           pa.IsTakeOver AS '@ito', 
                           u.Username AS '@un'
                    FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                         INNER JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                    WHERE PreMatchLeagueId = @PreMatchLeagueId
                          AND Bettype = @Bettype
                          AND IsTakeOver = @IsTakeOver
                          AND AssignmentType = 1 FOR XML PATH('z'), ROOT('r')
                );
                SELECT @userId = UserId
                FROM dbo.[PreMatchAssignment]
                WHERE PreMatchLeagueId = @PreMatchLeagueId
                      AND Bettype = @Bettype
                      AND IsTakeOver = @IsTakeOver
                      AND AssignmentType = 1;

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

                -- delete asssignment
                DELETE FROM dbo.[PreMatchAssignment]
                WHERE PreMatchLeagueId = @PreMatchLeagueId
                      AND Bettype = @Bettype
                      AND IsTakeOver = @IsTakeOver
                      AND AssignmentType = 1;

                -- Log
                SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        END;
        IF(@OldValue <> ''
           AND @NewValue <> '')
            BEGIN
                SET @Xml =
                (
                    SELECT pa.PreMatchLeagueId AS '@plid', 
                           pa.UserId AS '@uid', 
                           pa.Bettype AS '@bt', 
                           pa.IsTakeOver AS '@ito', 
                           u.Username AS '@un'
                    FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                         INNER JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                    WHERE PreMatchLeagueId = @PreMatchLeagueId
                          AND Bettype = @Bettype
                          AND IsTakeOver = @IsTakeOver
                          AND AssignmentType = 1 FOR XML PATH('z'), ROOT('r')
                );
                SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SELECT @userId = UserId
                FROM dbo.[PreMatchAssignment]
                WHERE PreMatchLeagueId = @PreMatchLeagueId
                      AND Bettype = @Bettype
                      AND IsTakeOver = @IsTakeOver
                      AND AssignmentType = 1;

				SELECT @newUserId = u.UserId
                FROM dbo.[User] AS u WITH(NOLOCK)
                WHERE u.Username = @NewValue;

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


                UPDATE dbo.[PreMatchAssignment] WITH(ROWLOCK)
                  SET 
                      UserId = @newUserId
                WHERE PreMatchLeagueId = @PreMatchLeagueId
                      AND Bettype = @Bettype
                      AND IsTakeOver = @IsTakeOver
                      AND AssignmentType = 1;

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
                    SELECT pa.PreMatchLeagueId AS '@plid', 
                           pa.UserId AS '@uid', 
                           pa.Bettype AS '@bt', 
                           pa.IsTakeOver AS '@ito', 
                           u.Username AS '@un'
                    FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
                         INNER JOIN dbo.[User] AS u ON pa.UserId = u.UserId
                    WHERE PreMatchLeagueId = @PreMatchLeagueId
                          AND Bettype = @Bettype
                          AND IsTakeOver = @IsTakeOver
                          AND AssignmentType = 1 FOR XML PATH('z'), ROOT('r')
                );
                SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        END;
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_PreMatchAssignment_InsertUpdateDeleteAssignment', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @preMatchLeagueId, 
             @DataOld = @LogDataOld, 
             @Data = @LogData;
    END;