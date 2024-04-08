
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SyncAgentConfirm] @AgentConfirms NVARCHAR(MAX), 
                                                                  @ActorId       INT           = 0
AS

/*
Created: 20240404@Mira
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Mira: Sync agent confirm - [Redmine: #202819]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblAgentConfirm
        (OWPMatchId INT, 
         Agent      NVARCHAR(255)
        );
        INSERT INTO #tblAgentConfirm
               SELECT DISTINCT 
                      OWPMatchId, 
                      Agent
               FROM OPENJSON(@AgentConfirms) WITH(OWPMatchId INT, Agent NVARCHAR(255));

        -- insert
        INSERT INTO dbo.MatchAgentConfirm
        (OWPMatchId, 
         AgentId
        )
               SELECT t.OWPMatchId, 
                      a.AgentId
               FROM #tblAgentConfirm t
                    INNER JOIN AgentOption a WITH(NOLOCK) ON a.AgentName = t.Agent;
    END;