
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SaveAgentConfirm] @OwpMatchId    INT, 
                                                                  @ActorId       INT, 
                                                                  @AgentSelected NVARCHAR(255) = NULL
AS

/*
Created: 20240404@Liam
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Liam: save agent confirm - [Redmine: #202819]
*/

    BEGIN
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX), @ActionName NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        SET @ActionName = '';
        SET @XmlLogOld =
        (
            SELECT STRING_AGG(ao.AgentName, ',') '@agentConfirm'
            FROM MatchAgentConfirm mc WITH(NOLOCK)
                 INNER JOIN AgentOption ao WITH(NOLOCK) ON mc.AgentId = ao.AgentId
            WHERE OWPMatchId = @OwpMatchId FOR XML PATH('z'), ROOT('r')
        );
        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification
                  SET 
                      IsConfirmManual = 1
                WHERE OWPMatchId = @OwpMatchId;
        END;
            ELSE
            BEGIN
                INSERT INTO ProviderVerification
                (OWPMatchId, 
                 IsConfirmManual
                )
                VALUES
                (@OwpMatchId, 
                 1
                );
        END;

        --- delete previous confirm
        DELETE FROM MatchAgentConfirm
        WHERE OWPMatchId = @OwpMatchId;

        --- insert current confirm
        INSERT INTO MatchAgentConfirm
        (OWPMatchId, 
         AgentId
        )
               SELECT @OwpMatchId, 
                      value
               FROM STRING_SPLIT(@AgentSelected, ',');

        --Write log
        SET @XmlLogNew =
        (
            SELECT STRING_AGG(ao.AgentName, ',') '@agentConfirm'
            FROM MatchAgentConfirm mc WITH(NOLOCK)
                 INNER JOIN AgentOption ao WITH(NOLOCK) ON mc.AgentId = ao.AgentId
            WHERE OWPMatchId = @OwpMatchId FOR XML PATH('z'), ROOT('r')
        );

        SET @LogNew = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogNew), '" />', '"/"');
        SET @LogOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogOld), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_ProviderVerification_SaveAgentConfirm', 
             @ObjectId = @OwpMatchId, 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @Data = @LogNew, 
             @DataOld = @LogOld;
    END;