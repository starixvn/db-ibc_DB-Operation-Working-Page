
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SaveEstNote] @OwpMatchId INT, 
                                                             @EstNote    NVARCHAR(500) = NULL, 
                                                             @ActorId    INT
AS

/*
Created: 20240404@Liam
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Liam: save est note - [Redmine: #202819]
*/

    BEGIN
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @LogData NVARCHAR(MAX), @Xml XML, @EstAgentOld VARCHAR(500);
        SET @StartRun = GETDATE();
        SELECT @EstAgentOld = m.ESTNote
        FROM ProviderVerification AS m WITH(NOLOCK)
        WHERE m.OWPMatchId = @OwpMatchId;

        --Old data
        SET @Xml =
        (
            SELECT @EstAgentOld AS '@estNote' FOR XML PATH('z'), ROOT('r')
        );
        SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p WITH (NOLOCK)
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification
                  SET 
                      ESTNote = @EstNote
                WHERE OWPMatchId = @OwpMatchId;
        END;
            ELSE
            BEGIN
                INSERT INTO ProviderVerification
                (OWPMatchId, 
                 ESTNote
                )
                VALUES
                (@OwpMatchId, 
                 @EstNote
                );
        END;

        --New log data
        SET @Xml =
        (
            SELECT @EstNote AS '@estNote' FOR XML PATH('z'), ROOT('r')
        );
        SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        IF @LogData != @LogDataOld
            BEGIN
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_ProviderVerification_SaveEstNote', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @OwpMatchId, 
                     @Data = @LogData, 
                     @DataOld = @LogDataOld;
        END;
    END;
