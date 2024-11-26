/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241125@Tim
Task : Event Picking New - Highlight Regelation and Update how to get info Bad Ranking
DB: bodb_OWP

Revisions:
	20241125@Tim: Add more columns - [Redmine: #214095]
*/

ALTER TABLE dbo.InfoSiteMatch ADD MatchStatus TINYINT
	,IsHomeBadRanking BIT
	,IsAwayBadRanking BIT
	,IsHomeDowngrade BIT
	,IsAwayDowngrade BIT
	,RoundConfirm VARCHAR(3)