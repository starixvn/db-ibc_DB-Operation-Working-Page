/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20250824@Frankie
Task : sync isBlackList for OWPLeague
DB: bodb_OWP

Revisions:
	20250824@Frankie: Reset the isBlackList column to false - [Redmine: #234901]
*/

UPDATE dbo.OWPLeague set IsBlackList = 0