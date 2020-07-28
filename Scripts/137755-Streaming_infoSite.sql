/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20200728@Carlos.Nguyen
Task : Update data Streaming sync from InfoSite
DB: bodb_OWP	

Revisions:
	20200728@Carlos.Nguyen: New structure of InfoSiteMatch - [Redmine: #137755]
*/

ALTER TABLE InfoSiteMatch
ADD [IPTV] NVARCHAR(2000);
GO



