/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20250821@Los
Task : Add new column NoOfferLive, ShortLeague
DB: bodb_OWP

Revisions:
	20250821@Los: Add new column NoOfferLive, ShortLeague - [Redmine: #234901]
*/


ALTER TABLE dbo.OWPLeague
ADD  [ShortLeague] VARCHAR(2000),
NoOfferLive BIT;