/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250325@Lilac
Task : Provider Verification
DB: bodb_OWP

Revisions:
	20250325@Lilac: Add column 'Remark', 'RemarkBy' table ProviderVerification.
			Add column 'MatchId' table MatchId  - [Redmine: #213719]
*/

ALTER TABLE AdminSiteLogs 
ALTER COLUMN CreatedDate DATETIME NOT NULL;

ALTER TABLE InfoSiteLogs 
ALTER COLUMN CreatedDate DATETIME NOT NULL;

ALTER TABLE OWPLogs 
ALTER COLUMN CreatedDate DATETIME NOT NULL;

ALTER TABLE MatchAgentConfirm  
ADD MatchId INT;

ALTER TABLE [ProviderVerification]
ADD Remark NVARCHAR(2000) NULL;

ALTER TABLE [ProviderVerification]
ADD [RemarkBy] NVARCHAR(2000) NULL;