
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderVerification_GetAgentOptions] 
AS

/*
Created: 20240404@Liam
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Liam: Get agent option - [Redmine: #202819]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT AgentId, 
               AgentName
        FROM AgentOption WITH(NOLOCK);
    END;


