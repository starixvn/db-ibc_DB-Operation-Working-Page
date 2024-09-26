
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20221203@Carlos.Nguyen
Task :  Enhance OS Live Assignment - Phase 2
DB: bodb_OWP	

Revisions:
	20221203@Tyler: Enhance OS Live Assignment - Phase 2 - [Redmine: #151572]
*/
ALTER TABLE OSMatch
ADD MatchNo DOUBLE PRECISION, Reporter VARCHAR(200);

