
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240325@Mira
Task : Sync Infosite - Correct Agent length
DB: bodb_OWP

Revisions:
	20240325@Mira: Add IsBlackList column - [Redmine: #202817]
*/

ALTER TABLE dbo.Agent 
ALTER COLUMN AgentName NVARCHAR(255) NOT NULL;