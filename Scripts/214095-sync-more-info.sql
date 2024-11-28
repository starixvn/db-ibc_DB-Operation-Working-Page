/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241125@Tim
Task : Event Picking New - Enhancement - Regelation/Bad Ranking/Postponed/Cancelled
DB: bodb_OWP

Revisions:
	20241125@Tim: Event Picking New - Enhancement - [Redmine: #214095]
*/

ALTER TABLE dbo.InfoSiteMatch ADD MatchStatus TINYINT
	,IsHomeBadRanking BIT
	,IsAwayBadRanking BIT
	,IsHomeDowngrade BIT
	,IsAwayDowngrade BIT
	,RoundConfirm VARCHAR(3)

GO
INSERT INTO dbo.EventPickingUpdateType (Id, UpdateType, RAndDUpdate)
VALUES (26, 'Match Postponed', 'Match Postponed')
    ,(27, 'Match Cancelled', 'Match Cancelled')