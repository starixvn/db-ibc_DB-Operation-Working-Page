
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20210113@Esther
Task : Adding SABA 6mins match to LA Report
DB: bodb_OWP	

Revisions:
	20210113@Esther: Adding SABA 6mins match to LA Report - [Redmine: #148267]
*/
-- LA Report
ALTER TABLE [dbo].[LAReport]
ADD [ESoccer6Mins]   INT NULL;