
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20201119@Tyler
Task : event tickets enhancement
DB: bodb_OWP	

Revisions:
	20201119@Tyler: remove MatchName in NewAddRequest - [Redmine: #145568]
*/

ALTER TABLE dbo.[NewAddRequest]
DROP COLUMN MatchName;

EXEC sp_rename 'NewAddRequest.LeagueName', 'Subject', 'COLUMN';
