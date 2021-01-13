
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 202101130@Mira
Task : OWP 2021 ENHANCEMENT
DB: bodb_OWP	

Revisions:
	20210113@Mira: save message in chat board - [Redmine: #148266]
*/

ALTER TABLE dbo.PreMatchIssueMessage
ADD IsSaved BIT NULL;