/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250520@Lilac
Task : Provider Verification
DB: bodb_OWP

Revisions:
	20250516@Lilac: Update confirm provider to cancel [Redmine: #228013]
*/

UPDATE t
SET t.AgentId = 12
FROM MatchAgentConfirm t
WHERE t.OWPMatchId = 13047583
