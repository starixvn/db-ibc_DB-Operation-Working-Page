
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240307@Mira
Task : Event Picking - Highlight Blacklist and bad ranking strike out
DB: bodb_OWP

Revisions:
	20240307@Mira: Add IsBlackList column - [Redmine: #201375]
*/

ALTER TABLE dbo.InfositeMatch
ADD IsBlackList BIT NOT NULL
                    DEFAULT 0;