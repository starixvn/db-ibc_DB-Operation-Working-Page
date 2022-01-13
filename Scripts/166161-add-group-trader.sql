/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211231@Liam.Pham
Task : New Column for InfoSiteAutoAssignmentResult
DB: bodb_OWP	

Revisions:
	20211231@Liam.Pham: add column GroupTrader - [Redmine: #166161]	
*/

ALTER TABLE InfoSiteAutoAssignmentResult
ADD GroupTrader  NVARCHAR(200)