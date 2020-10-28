/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20201020@Esther
Task : Event Checking - New Add 
DB: bodb_OWP	

Revisions:
	20201020@Esther: Remove EventDate from PreMatchIssue - [Redmine: #140772]
*/

ALTER TABLE dbo.[PreMatchIssue] 
DROP COLUMN EventDate;