
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220112@Tyler
Task : Link to AdminSite matches
DB: bodb_OWP	

Revisions:
	20220112@Tyler: change col name - [Redmine: #167315]
*/

EXEC sp_rename 
     'dbo.OSMatch.MatchStatus', 
     'OfferLiveStatus', 
     'COLUMN';
ALTER TABLE dbo.OSMatch
ADD AdminSiteMatchId INT;