
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20201105@Jacob
Task : LA Auto Assignment
DB: bodb_OWP	

Revisions:
	20201105@Jacob: Alter DB - [Redmine: #144570]
*/

ALTER TABLE InfoSiteMatch
ADD ETPK NVARCHAR(2000);


ALTER TABLE MatchInfo
ADD ETPK NVARCHAR(2000);
