
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SaveEstAgent] @OwpMatchId INT, 
                                                               @EstAgent   NVARCHAR(500) = NULL
AS

/*
Created: 20240404@Los
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Los: save est agent - [Redmine: #202819]
*/

    BEGIN
        UPDATE MatchInfo
          SET 
              Agent_EST = @EstAgent
        WHERE OWPMatchId = @OwpMatchId;
    END;