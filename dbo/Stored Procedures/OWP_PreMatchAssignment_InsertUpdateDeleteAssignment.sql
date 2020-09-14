
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
	20200914@Tyler: Update issue receiver - [Redmine: #138643]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @userId INT;
        DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
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
                 [IsTakeOver]
                )
                VALUES
                (@PreMatchLeagueId, 
                 @userId, 
                 @Bettype, 
                 @IsTakeOver
                );

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
                         @userId, 
                         0
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
                          AND IsTakeOver = @IsTakeOver FOR XML PATH('z'), ROOT('r')
                );
                DELETE FROM dbo.[PreMatchAssignment]
                WHERE PreMatchLeagueId = @PreMatchLeagueId
                      AND Bettype = @Bettype
                      AND IsTakeOver = @IsTakeOver;

                -- delete from receiving isssue message
                DELETE r
                FROM [dbo].[PreMatchIssueReceiver] AS r
                     INNER JOIN dbo.[PreMatchIssue] AS i WITH(NOLOCK) ON i.PreMatchIssueId = r.PreMatchIssueId
                     INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON pl.OWPLeagueId = i.OWPLeagueId
                     INNER JOIN dbo.[PreMatchAssignment] AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                WHERE @PreMatchIssueId IS NOT NULL
                      AND r.PreMatchIssueId = @PreMatchIssueId
                      AND r.UserId = pa.UserId
                      AND pa.PreMatchLeagueId = @PreMatchLeagueId
                      AND pa.Bettype = @Bettype
                      AND pa.IsTakeOver = @IsTakeOver;

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
                          AND IsTakeOver = @IsTakeOver FOR XML PATH('z'), ROOT('r')
                );
                SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SELECT @userId = u.UserId
                FROM dbo.[User] AS u WITH(NOLOCK)
                WHERE u.Username = @NewValue;

                -- delete from receiving isssue message
                DELETE r
                FROM [dbo].[PreMatchIssueReceiver] AS r
                     INNER JOIN dbo.[PreMatchIssue] AS i WITH(NOLOCK) ON i.PreMatchIssueId = r.PreMatchIssueId
                     INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON pl.OWPLeagueId = i.OWPLeagueId
                     INNER JOIN dbo.[PreMatchAssignment] AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                WHERE @PreMatchIssueId IS NOT NULL
                      AND r.PreMatchIssueId = @PreMatchIssueId
                      AND r.UserId = pa.UserId
                      AND pa.PreMatchLeagueId = @PreMatchLeagueId
                      AND pa.Bettype = @Bettype
                      AND pa.IsTakeOver = @IsTakeOver;
                UPDATE dbo.[PreMatchAssignment] WITH(ROWLOCK)
                  SET 
                      UserId = @userId
                WHERE PreMatchLeagueId = @PreMatchLeagueId
                      AND Bettype = @Bettype
                      AND IsTakeOver = @IsTakeOver;

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
                         @userId, 
                         0
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
                          AND IsTakeOver = @IsTakeOver FOR XML PATH('z'), ROOT('r')
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