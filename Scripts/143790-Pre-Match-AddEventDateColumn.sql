/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20201021@Esther
Task : Event Checking - New Add 
DB: bodb_OWP	

Revisions:
	20201020@Esther: Add EventDate for PreMatchIssueReceiver - [Redmine: #143790]
*/

ALTER TABLE dbo.[PreMatchIssueReceiver] 
ADD EventDate DATE NULL;