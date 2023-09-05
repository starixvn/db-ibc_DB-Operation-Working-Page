/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230824@Mira
Task : Enhance LA report
DB: bodb_OWP	

Revisions:
	20230824@Mira: Add group 5 mins - [Redmine: #185887]
*/

-- Add ESoccer5MinsGroup column
ALTER TABLE dbo.LAReport
ADD ESoccer5MinsGroup MONEY;