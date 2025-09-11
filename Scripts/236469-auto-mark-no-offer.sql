/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250911@los
Task : Add column IsNoOffer, IsManual
DB: bodb_OWP

Revisions:
	20250911@los: Event picking auto mark no offer  [Redmine: #236469]
*/
ALTER TABLE dbo.EventPickingNoOfferMatch
ADD [IsNoOffer] BIT,
[IsManual] BIT;
