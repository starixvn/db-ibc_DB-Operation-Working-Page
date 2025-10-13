/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251009@Hank
Task : Insert new match offer
DB: bodb_OWP	

Revisions:
	 20251009@Hank: Insert new match offer - [Redmine: #238851]
*/
use [bodb_OWP]
GO

INSERT INTO RefResource(RefName, ResourceId, Value, [Order])
VALUES('MatchOffer', 48, 'Time Machine', 48)



