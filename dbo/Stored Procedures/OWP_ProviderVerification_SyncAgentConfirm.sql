
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SyncAgentConfirm] @AgentConfirms NVARCHAR(MAX)
AS

/*
Created: 20240404@Mira
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Mira: Sync agent confirm - [Redmine: #202819]
*/

    BEGIN
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX), @ActionName NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        SET @XmlLogOld = NULL;
        CREATE TABLE #tblAgentConfirm
        (OWPMatchId INT, 
         Agent      NVARCHAR(255)
        );
        INSERT INTO #tblAgentConfirm
               SELECT DISTINCT 
                      OWPMatchId, 
                      Agent
               FROM OPENJSON(@AgentConfirms) WITH(OWPMatchId INT, Agent NVARCHAR(255));

        -- delete exist OWPMatchId if run n-th
        DELETE t
        FROM dbo.MatchAgentConfirm t
             INNER JOIN #tblAgentConfirm a WITH(NOLOCK) ON a.OWPMatchId = t.OWPMatchId;

        -- insert
        INSERT INTO dbo.MatchAgentConfirm
        (OWPMatchId, 
         AgentId
        )
               SELECT t.OWPMatchId, 
                      a.AgentId
               FROM #tblAgentConfirm t
                    INNER JOIN AgentOption a WITH(NOLOCK) ON a.AgentName = t.Agent;

        --Write log
        SET @XmlLogNew =
        (
            SELECT t.OWPMatchId '@owpMatchId', 
                   ao.AgentName '@agentConfirm'
            FROM #tblAgentConfirm t
                 INNER JOIN AgentOption ao WITH(NOLOCK) ON ao.AgentName = t.Agent FOR XML PATH('z'), ROOT('r')
        );
        SET @LogNew = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogNew), '" />', '"/"');
        SET @LogOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogOld), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = 0, 
             @SPName = 'OWP_ProviderVerification_SaveAgentConfirm', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @Data = @LogNew, 
             @DataOld = @LogOld;

        -- drop table
        DROP TABLE #tblAgentConfirm;
    END;