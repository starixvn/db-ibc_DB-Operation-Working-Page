
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240419@Mira
Task : Event Picking - Highlight Blacklist and bad ranking strike out
DB: bodb_OWP

Revisions:
	20240419@Mira: Add league/home/away blackList column - [Redmine: #203309]
*/

ALTER TABLE dbo.InfositeMatch
DROP CONSTRAINT DF__InfoSiteM__IsBla__6581EB1C
ALTER TABLE dbo.InfositeMatch DROP COLUMN IsBlackList;

-- add column
ALTER TABLE dbo.InfositeMatch
ADD IsLeagueBlackList BIT NULL, 
    IsHomeBlackList   BIT NULL, 
    IsAwayBlackList   BIT NULL;