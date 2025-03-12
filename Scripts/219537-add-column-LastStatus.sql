/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250312@Frankie
Task : Event Picking New - Enhancement
DB: bodb_OWP

Revisions:
	20250312@Frankie: Add column 'LastStatus' table InfoSiteMatch  - [Redmine: #219537]
*/

ALTER TABLE dbo.[InfoSiteMatch]
ADD [LastStatus] NVARCHAR(20);